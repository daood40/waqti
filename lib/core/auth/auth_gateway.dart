/// بوابة المصادقة: واجهة واحدة يعتمد عليها التطبيق، وخلفها Supabase أو
/// «لا شيء» (وضع محلي). لا يعرف أي جزء من الواجهة تفاصيل المزوّد.
library;

/// المستخدم المُوثَّق كما يراه التطبيق.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.provider = 'email',
    this.emailConfirmed = true,
  });

  final String id;
  final String email;
  final String name;
  final String provider;
  final bool emailConfirmed;
}

/// حدث تغيّر جلسة.
enum AuthEvent { signedIn, signedOut, passwordRecovery, userUpdated }

/// خطأ مصادقة مفهوم للمستخدم (رمز ثابت تُترجمه الواجهة).
class AuthFailure implements Exception {
  const AuthFailure(this.code, [this.detail]);

  /// invalidCredentials | emailTaken | weakPassword | emailNotConfirmed |
  /// network | rateLimited | cancelled | unknown
  final String code;
  final String? detail;

  @override
  String toString() => 'AuthFailure($code${detail == null ? '' : ': $detail'})';
}

/// نتيجة إنشاء حساب: إمّا جلسة فورية أو انتظار تأكيد البريد.
class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation, this.user});
  final bool needsEmailConfirmation;
  final AuthUser? user;
}

abstract class AuthGateway {
  /// هل يوجد خادم مصادقة أصلًا؟ (false = وضع محلي).
  bool get isAvailable;
  bool get supportsGoogle;
  bool get supportsApple;

  AuthUser? get currentUser;
  Stream<AuthEvent> get events;

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<AuthUser> signIn({required String email, required String password});
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInWithApple();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String newPassword);
  Future<void> updateName(String name);
  Future<void> signOut();

  /// حذف الحساب نهائيًا (شرط آبل وGoogle Play). يُنفَّذ خادميًا عبر RPC.
  Future<void> deleteAccount();
}

/// لا خادم: كل الطرق تعيد «غير متاح». يُستخدم في الاختبارات والبناء بلا إعدادات.
class NoAuthGateway implements AuthGateway {
  const NoAuthGateway();

  @override
  bool get isAvailable => false;
  @override
  bool get supportsGoogle => false;
  @override
  bool get supportsApple => false;
  @override
  AuthUser? get currentUser => null;
  @override
  Stream<AuthEvent> get events => const Stream.empty();

  Never _unavailable() => throw const AuthFailure('unavailable');

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async => _unavailable();
  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async => _unavailable();
  @override
  Future<AuthUser?> signInWithGoogle() async => _unavailable();
  @override
  Future<AuthUser?> signInWithApple() async => _unavailable();
  @override
  Future<void> sendPasswordReset(String email) async => _unavailable();
  @override
  Future<void> updatePassword(String newPassword) async => _unavailable();
  @override
  Future<void> updateName(String name) async => _unavailable();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async => _unavailable();
}
