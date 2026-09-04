import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// النسخة السحابية: صف واحد لكل مستخدم يحمل ملف البيانات كاملًا (JSON).
/// آخر كتابة تفوز (LWW) بحسب `updated_at`. RLS تضمن أن المستخدم لا يرى إلا صفه.
class CloudSnapshot {
  const CloudSnapshot({required this.payload, required this.updatedAt});
  final String payload;
  final DateTime updatedAt;
}

abstract class CloudBackupGateway {
  bool get isAvailable;
  Future<CloudSnapshot?> fetch();
  Future<DateTime> push(String payload, {required String appVersion});
}

class NoCloudBackupGateway implements CloudBackupGateway {
  const NoCloudBackupGateway();
  @override
  bool get isAvailable => false;
  @override
  Future<CloudSnapshot?> fetch() async => null;
  @override
  Future<DateTime> push(String payload, {required String appVersion}) async =>
      DateTime.now();
}

class SupabaseCloudBackupGateway implements CloudBackupGateway {
  SupabaseCloudBackupGateway(this._client);
  final SupabaseClient _client;

  @override
  bool get isAvailable => _client.auth.currentUser != null;

  @override
  Future<CloudSnapshot?> fetch() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('user_backups')
        .select('payload, updated_at')
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) return null;
    return CloudSnapshot(
      payload: row['payload'] as String,
      updatedAt: DateTime.parse(row['updated_at'] as String).toUtc(),
    );
  }

  @override
  Future<DateTime> push(String payload, {required String appVersion}) async {
    final uid = _client.auth.currentUser;
    if (uid == null) throw StateError('not signed in');
    final now = DateTime.now().toUtc();
    await _client.from('user_backups').upsert({
      'user_id': uid.id,
      'payload': payload,
      'app_version': appVersion,
      'updated_at': now.toIso8601String(),
    });
    return now;
  }
}

/// يقرّر اتجاه المزامنة عند الدخول: سحابي أحدث → استيراد؛ محلي أحدث/لا سحابي → رفع.
enum SyncDecision { pullRemote, pushLocal, nothing }

SyncDecision decideSync({
  required DateTime? remoteUpdatedAt,
  required DateTime? localChangedAt,
  required bool localHasData,
}) {
  if (remoteUpdatedAt == null) {
    return localHasData ? SyncDecision.pushLocal : SyncDecision.nothing;
  }
  if (localChangedAt == null) return SyncDecision.pullRemote;
  if (remoteUpdatedAt.isAfter(localChangedAt)) return SyncDecision.pullRemote;
  if (localChangedAt.isAfter(remoteUpdatedAt)) return SyncDecision.pushLocal;
  return SyncDecision.nothing;
}
