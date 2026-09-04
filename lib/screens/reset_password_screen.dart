import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// تظهر بعد فتح رابط استرجاع كلمة المرور: كلمة مرور جديدة ثم العودة للتطبيق.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    final s = AppStrings.of(state.lang);
    if (_controller.text.length < 6) {
      setState(() => _error = s.shortPassword);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await state.completePasswordRecovery(_controller.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.passwordUpdated)));
    } catch (_) {
      if (mounted) setState(() => _error = s.errUnknown);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: WqCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.newPasswordTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _controller,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _save(),
                      enabled: !_busy,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _error!,
                          style: TextStyle(color: wq.missed, fontSize: 11.5),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _busy ? null : _save,
                      child: Text(s.savePassword),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
