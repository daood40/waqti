import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../app_config.dart';
import 'auth_gateway.dart';

/// تنفيذ Supabase Auth: بريد/كلمة مرور + Google + Apple.
/// المفتاح المستخدم عام (publishable/anon)؛ الحماية الحقيقية في RLS خادميًا.
class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client) {
    _sub = _client.auth.onAuthStateChange.listen((data) {
      final mapped = switch (data.event) {
        AuthChangeEvent.signedIn || AuthChangeEvent.initialSession
            when data.session != null =>
          AuthEvent.signedIn,
        AuthChangeEvent.signedOut => AuthEvent.signedOut,
        AuthChangeEvent.passwordRecovery => AuthEvent.passwordRecovery,
        AuthChangeEvent.userUpdated => AuthEvent.userUpdated,
        _ => null,
      };
      if (mapped != null) _events.add(mapped);
    });
  }

  final SupabaseClient _client;
  final _events = StreamController<AuthEvent>.broadcast();
  StreamSubscription<AuthState>? _sub;
  bool _googleReady = false;

  @override
  bool get isAvailable => true;

  @override
  bool get supportsGoogle => AppConfig.hasGoogle;

  @override
  bool get supportsApple =>
      kIsWeb || (!kIsWeb && (Platform.isIOS || Platform.isMacOS));

  @override
  AuthUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AuthEvent> get events => _events.stream;

  static AuthUser? _map(User? u) {
    if (u == null) return null;
    final meta = u.userMetadata ?? const {};
    final name =
        (meta['full_name'] ?? meta['name'] ?? meta['display_name'] ?? '')
            .toString()
            .trim();
    return AuthUser(
      id: u.id,
      email: u.email ?? '',
      name: name.isEmpty ? (u.email ?? '').split('@').first : name,
      provider: u.appMetadata['provider']?.toString() ?? 'email',
      emailConfirmed: u.emailConfirmedAt != null,
    );
  }

  /// يحوّل أخطاء Supabase إلى رموز ثابتة تُترجمها الواجهة.
  static AuthFailure _fail(Object e) {
    if (e is AuthFailure) return e;
    if (e is AuthException) {
      final m = e.message.toLowerCase();
      final code = e.code ?? '';
      if (code == 'invalid_credentials' || m.contains('invalid login')) {
        return const AuthFailure('invalidCredentials');
      }
      if (code == 'user_already_exists' || m.contains('already registered')) {
        return const AuthFailure('emailTaken');
      }
      if (code == 'weak_password' || m.contains('password')) {
        return const AuthFailure('weakPassword');
      }
      if (code == 'email_not_confirmed' || m.contains('not confirmed')) {
        return const AuthFailure('emailNotConfirmed');
      }
      if (code == 'over_request_rate_limit' || m.contains('rate limit')) {
        return const AuthFailure('rateLimited');
      }
      return AuthFailure('unknown', e.message);
    }
    final text = e.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('failed host lookup')) {
      return const AuthFailure('network');
    }
    return AuthFailure('unknown', e.toString());
  }

  String? get _redirect => kIsWeb ? null : AppConfig.authRedirectUrl;

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _redirect,
        data: {'full_name': name},
      );
      return SignUpResult(
        needsEmailConfirmation: res.session == null,
        user: _map(res.user),
      );
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _map(res.user)!;
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _client.auth.signInWithOAuth(OAuthProvider.google);
        return null; // يعود عبر إعادة التوجيه ثم حدث signedIn.
      }
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        await google.initialize(
          clientId: AppConfig.googleIosClientId.isEmpty
              ? null
              : AppConfig.googleIosClientId,
          serverClientId: AppConfig.googleWebClientId,
        );
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthFailure('unknown', 'no id token');
      final res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return _map(res.user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('cancelled');
      }
      throw _fail(e);
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    try {
      if (kIsWeb) {
        await _client.auth.signInWithOAuth(OAuthProvider.apple);
        return null;
      }
      final rawNonce = _client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) throw const AuthFailure('unknown', 'no id token');
      final res = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      // آبل تعطي الاسم في أول دخول فقط — نحفظه في بيانات المستخدم.
      final given = credential.givenName;
      if (given != null && given.isNotEmpty) {
        final full = [
          given,
          credential.familyName ?? '',
        ].where((p) => p.isNotEmpty).join(' ');
        await _client.auth.updateUser(
          UserAttributes(data: {'full_name': full}),
        );
      }
      return _map(res.user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure('cancelled');
      }
      throw _fail(e);
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email, redirectTo: _redirect);
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<void> updateName(String name) async {
    try {
      await _client.auth.updateUser(UserAttributes(data: {'full_name': name}));
    } catch (e) {
      throw _fail(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // فشل الشبكة لا يمنع الخروج محليًا؛ الجلسة تُمسح على الجهاز.
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // دالة SQL بصلاحية المُعرِّف تحذف auth.users للمستخدم الحالي فقط.
      await _client.rpc('delete_own_account');
      await _client.auth.signOut();
    } catch (e) {
      throw _fail(e);
    }
  }

  void dispose() {
    _sub?.cancel();
    _events.close();
  }
}
