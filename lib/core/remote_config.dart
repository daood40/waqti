import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_info.dart';

/// مفتاح إيقاف عن بُعد (qa-production-readiness البوابة 16 / ops-monitoring):
/// ملف JSON ثابت على GitHub Pages يقرأه التطبيق عند الإقلاع.
/// السلوك الافتراضي عند أي فشل: **لا حجب** (fail-open).
class RemoteConfig {
  const RemoteConfig({
    this.minSupportedVersion,
    this.maintenance = false,
    this.messageAr = '',
    this.messageEn = '',
  });

  /// أقل إصدار مسموح (مثل "1.3.0"). null = لا قيد.
  final String? minSupportedVersion;
  final bool maintenance;
  final String messageAr;
  final String messageEn;

  static const RemoteConfig none = RemoteConfig();

  static RemoteConfig? tryParse(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final msg = json['message'];
      return RemoteConfig(
        minSupportedVersion: json['minSupportedVersion'] is String
            ? json['minSupportedVersion'] as String
            : null,
        maintenance: json['maintenance'] == true,
        messageAr: msg is Map && msg['ar'] is String ? msg['ar'] as String : '',
        messageEn: msg is Map && msg['en'] is String ? msg['en'] as String : '',
      );
    } catch (_) {
      return null;
    }
  }

  /// هل [current] أقل من [minSupportedVersion]؟ (مقارنة دلالية x.y.z)
  bool requiresUpdate([String current = kAppVersion]) {
    final min = minSupportedVersion;
    if (min == null || min.isEmpty) return false;
    return compareVersions(current, min) < 0;
  }

  bool get blocks => maintenance || requiresUpdate();

  String message(String lang) => lang == 'en' ? messageEn : messageAr;

  /// -1 إذا a < b، 0 إذا تساويا، 1 إذا a > b. أجزاء غير رقمية = 0.
  static int compareVersions(String a, String b) {
    List<int> parts(String v) => v
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList(growable: true);
    final pa = parts(a);
    final pb = parts(b);
    while (pa.length < 3) {
      pa.add(0);
    }
    while (pb.length < 3) {
      pb.add(0);
    }
    for (var i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] < pb[i] ? -1 : 1;
    }
    return 0;
  }
}

/// مصدر الإعداد — قابل للاستبدال في الاختبارات.
abstract class RemoteConfigSource {
  Future<RemoteConfig?> load();
}

/// يجلب `app-config.json` من الموقع مع مهلة قصيرة؛ أي خطأ → null.
class HttpRemoteConfigSource implements RemoteConfigSource {
  const HttpRemoteConfigSource({this.timeout = const Duration(seconds: 4)});

  final Duration timeout;

  @override
  Future<RemoteConfig?> load() async {
    try {
      final uri = Uri.parse(
        '${AppLinks.remoteConfig}?t=${DateTime.now().millisecondsSinceEpoch}',
      );
      final res = await http.get(uri).timeout(timeout);
      if (res.statusCode != 200) return null;
      return RemoteConfig.tryParse(res.body);
    } catch (_) {
      return null;
    }
  }
}
