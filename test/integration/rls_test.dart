// اختبار RLS الفعلي على مشروع Supabase حقيقي (دليل بوابة Database).
// يُتخطّى تلقائيًا بلا SUPABASE_URL/SUPABASE_ANON_KEY في البيئة.
// تشغيل: SUPABASE_URL=... SUPABASE_ANON_KEY=... flutter test test/integration/rls_test.dart
@Tags(['integration'])
library;

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final url = Platform.environment['SUPABASE_URL'] ?? '';
  final key = Platform.environment['SUPABASE_ANON_KEY'] ?? '';
  final enabled = url.isNotEmpty && key.isNotEmpty;

  test(
    'a user cannot read or write another user\'s backup row',
    () async {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final a = SupabaseClient(url, key);
      final b = SupabaseClient(url, key);
      // يتطلب تعطيل Confirm email على مشروع staging، أو مستخدمين مؤكدين مسبقًا.
      final ra = await a.auth.signUp(
        email: 'rls-a-$stamp@example.com',
        password: 'Passw0rd!$stamp',
      );
      final rb = await b.auth.signUp(
        email: 'rls-b-$stamp@example.com',
        password: 'Passw0rd!$stamp',
      );
      expect(ra.session, isNotNull, reason: 'staging must auto-confirm email');
      expect(rb.session, isNotNull);

      await a.from('user_backups').upsert({
        'user_id': ra.user!.id,
        'payload': '{"owner":"a"}',
      });

      // B لا يرى صف A.
      final seenByB = await b
          .from('user_backups')
          .select('user_id')
          .eq('user_id', ra.user!.id);
      expect(seenByB, isEmpty);

      // B لا يستطيع الكتابة باسم A (RLS with check).
      expect(
        () => b.from('user_backups').upsert({
          'user_id': ra.user!.id,
          'payload': '{"owner":"b"}',
        }),
        throwsA(isA<PostgrestException>()),
      );

      // A يرى صفه.
      final own = await a.from('user_backups').select('payload').single();
      expect(own['payload'], '{"owner":"a"}');

      // حذف الحساب ذاتيًا يزيل الصف (cascade) ويُنهي الجلسة.
      await a.rpc('delete_own_account');
      await b.rpc('delete_own_account');
    },
    skip: enabled ? false : 'SUPABASE_URL/SUPABASE_ANON_KEY not set',
  );
}
