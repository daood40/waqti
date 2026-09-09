import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_info.dart';
import '../core/l10n.dart';
import '../core/remote_config.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// شاشة الحجب عن بُعد: تحديث إجباري أو صيانة (البوابة 16).
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.of(state.lang);
    final wq = context.wq;
    final cfg = state.remoteConfig;
    final update = cfg.requiresUpdate();
    final custom = cfg.message(state.lang).trim();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  update ? Icons.system_update_rounded : Icons.build_rounded,
                  size: 56,
                  color: wq.primaryDark,
                ),
                const SizedBox(height: 18),
                Text(
                  update ? s.updateRequiredTitle : s.maintenanceTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  custom.isNotEmpty
                      ? custom
                      : (update ? s.updateRequiredBody : s.maintenanceBody),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: wq.textMuted),
                ),
                const SizedBox(height: 22),
                if (update)
                  ElevatedButton(
                    onPressed: () => launchUrl(
                      Uri.parse(AppLinks.playStore),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(s.openStore),
                  )
                else
                  ElevatedButton(
                    onPressed: () =>
                        state.checkRemoteConfig(const HttpRemoteConfigSource()),
                    child: Text(s.retry),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
