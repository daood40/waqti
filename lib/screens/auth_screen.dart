import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_gateway.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// شاشة الدخول: حساب حقيقي (بريد/كلمة مرور، Google، Apple) عبر AuthGateway،
/// أو المتابعة كزائر محليًا. عند غياب الخادم تُعرض المتابعة كزائر فقط.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum _Mode { login, signup, forgot, emailSent, resetSent }

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _Mode _mode = _Mode.login;
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String _describe(Object e, AppStrings s) {
    if (e is AuthFailure) {
      return switch (e.code) {
        'invalidCredentials' => s.errInvalidCredentials,
        'emailTaken' => s.errEmailTaken,
        'weakPassword' => s.errWeakPassword,
        'emailNotConfirmed' => s.errEmailNotConfirmed,
        'network' => s.errNetwork,
        'rateLimited' => s.errRateLimited,
        'cancelled' => s.cancelled,
        'unavailable' => s.authUnavailable,
        _ => s.errUnknown,
      };
    }
    return s.errUnknown;
  }

  Future<void> _run(Future<void> Function() action) async {
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = _describe(e, s));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// بعد نجاح الدخول: إن كانت الشاشة مدفوعة فوق التطبيق (من الإعدادات) نغلقها.
  void _finish() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final signup = _mode == _Mode.signup;

    if (_mode == _Mode.forgot) {
      if (!_emailRegex.hasMatch(email)) {
        setState(() => _error = s.invalidEmail);
        return;
      }
      await _run(() async {
        await state.auth.sendPasswordReset(email);
        if (mounted) setState(() => _mode = _Mode.resetSent);
      });
      return;
    }
    if (email.isEmpty || password.isEmpty || (signup && name.isEmpty)) {
      setState(() => _error = s.fillFields);
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = s.invalidEmail);
      return;
    }
    if (password.length < 6) {
      setState(() => _error = s.shortPassword);
      return;
    }
    await _run(() async {
      if (signup) {
        final res = await state.auth.signUp(
          email: email,
          password: password,
          name: name,
        );
        if (res.needsEmailConfirmation) {
          if (mounted) setState(() => _mode = _Mode.emailSent);
          return;
        }
        if (res.user != null) await state.onSignedIn(res.user!);
        _finish();
      } else {
        final u = await state.auth.signIn(email: email, password: password);
        await state.onSignedIn(u);
        _finish();
      }
    });
  }

  Future<void> _social(Future<AuthUser?> Function() call) async {
    final state = context.read<AppState>();
    await _run(() async {
      final u = await call();
      // null = تدفق ويب بإعادة توجيه؛ حدث signedIn سيتكفّل بالباقي.
      if (u != null) {
        await state.onSignedIn(u);
        _finish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final auth = state.auth;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  _Logo(appName: s.appName, subtitle: s.authSubtitle),
                  const SizedBox(height: 26),
                  WqCard(
                    padding: const EdgeInsets.all(22),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!auth.isAvailable)
                            _notice(s.authUnavailable, wq)
                          else if (_mode == _Mode.emailSent)
                            _sent(
                              s.confirmEmailTitle,
                              s.confirmEmailBody,
                              s,
                              wq,
                            )
                          else if (_mode == _Mode.resetSent)
                            _sent(s.forgotTitle, s.resetEmailSent, s, wq)
                          else
                            ..._form(s, wq, auth),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () {
                                    state.signInAsGuest(s.guestUser);
                                    _finish();
                                  },
                            style: TextButton.styleFrom(
                              foregroundColor: wq.textMuted,
                            ),
                            child: Text(
                              s.continueGuest,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _form(AppStrings s, WaqtiColors wq, AuthGateway auth) {
    final signup = _mode == _Mode.signup;
    final forgot = _mode == _Mode.forgot;
    return [
      if (!forgot)
        SegmentedPills(
          options: [s.login, s.signup],
          selectedIndex: signup ? 1 : 0,
          onSelected: (i) => setState(() {
            _mode = i == 1 ? _Mode.signup : _Mode.login;
            _error = null;
          }),
        ),
      const SizedBox(height: 18),
      Text(
        forgot
            ? s.forgotTitle
            : signup
            ? s.createAccountTitle
            : s.welcomeBack,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      if (signup) ...[
        _label(s.fullName, wq),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          enabled: !_busy,
        ),
        const SizedBox(height: 14),
      ],
      _label(s.email, wq),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: forgot ? TextInputAction.done : TextInputAction.next,
        textDirection: TextDirection.ltr,
        autofillHints: const [AutofillHints.email],
        enabled: !_busy,
        onSubmitted: forgot ? (_) => _submit() : null,
        decoration: const InputDecoration(
          hintText: 'name@example.com',
          hintTextDirection: TextDirection.ltr,
        ),
      ),
      if (!forgot) ...[
        const SizedBox(height: 14),
        _label(s.password, wq),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: [
            signup ? AutofillHints.newPassword : AutofillHints.password,
          ],
          enabled: !_busy,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              tooltip: s.password,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: wq.textMuted,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
      if (!signup)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _mode = forgot ? _Mode.login : _Mode.forgot;
                    _error = null;
                  }),
            child: Text(
              forgot ? s.backToLogin : s.forgotPassword,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        )
      else
        const SizedBox(height: 14),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _error!,
            style: TextStyle(color: wq.missed, fontSize: 11.5),
          ),
        ),
      ElevatedButton(
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                forgot
                    ? s.sendResetLink
                    : signup
                    ? s.signup
                    : s.login,
              ),
      ),
      if (!forgot && (auth.supportsGoogle || auth.supportsApple)) ...[
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Divider(color: wq.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                s.orContinueWith,
                style: TextStyle(fontSize: 12, color: wq.textMuted),
              ),
            ),
            Expanded(child: Divider(color: wq.border)),
          ],
        ),
        const SizedBox(height: 16),
        if (auth.supportsGoogle)
          _OAuthButton(
            label: s.continueGoogle,
            icon: 'G',
            onTap: _busy ? null : () => _social(auth.signInWithGoogle),
          ),
        if (auth.supportsGoogle && auth.supportsApple)
          const SizedBox(height: 9),
        if (auth.supportsApple)
          _OAuthButton(
            label: s.continueApple,
            icon: '',
            onTap: _busy ? null : () => _social(auth.signInWithApple),
          ),
      ],
      const SizedBox(height: 6),
      if (!forgot)
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() {
                  _mode = signup ? _Mode.login : _Mode.signup;
                  _error = null;
                }),
          child: Text(
            '${signup ? s.haveAccount : s.noAccount} '
            '${signup ? s.login : s.signup}',
          ),
        ),
    ];
  }

  Widget _sent(String title, String body, AppStrings s, WaqtiColors wq) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 40, color: wq.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: wq.textMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() => _mode = _Mode.login),
            child: Text(s.backToLogin),
          ),
        ],
      );

  Widget _notice(String text, WaqtiColors wq) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: wq.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12.5, color: wq.textMuted),
    ),
  );

  Widget _label(String text, WaqtiColors wq) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: wq.textMuted,
      ),
    ),
  );
}

class _Logo extends StatelessWidget {
  const _Logo({required this.appName, required this.subtitle});

  final String appName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: wq.primaryDark.withValues(alpha: .3),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/branding/app_icon.png', fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Text(
          appName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 12.5, color: wq.textMuted)),
      ],
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final wq = context.wq;
    return Material(
      color: wq.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: wq.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
