# Supabase — إعداد المشروع (مرة واحدة)

1. **المخطط**: افتح SQL Editor في لوحة Supabase والصق محتوى `migrations/20260904000000_init.sql` ثم Run.
   (أو عبر CLI: `supabase link --project-ref <ref>` ثم `supabase db push`.)
2. **Authentication → URL Configuration**:
   - Site URL: `https://daood40.github.io/waqti/`
   - Redirect URLs: `https://daood40.github.io/waqti/**` و `waqti://login-callback/`
3. **Authentication → Providers**:
   - Email: مفعّل، Confirm email = ON.
   - Google: Client ID/Secret من Google Cloud (OAuth consent + Web client). أضف أيضًا iOS client ID في Authorized Client IDs.
   - Apple: Services ID + Team ID + Key ID + .p8 من Apple Developer.
4. **Authentication → Rate Limits**: اترك الافتراضي (يحمي من التسجيل الآلي).
5. **القيم للتطبيق**: Settings → API → Project URL و Publishable (anon) key → أسرار GitHub
   `SUPABASE_URL` و `SUPABASE_ANON_KEY`.

## اختبار RLS (دليل البوابة)

`test/integration/rls_test.dart` ينشئ مستخدمين ويتحقق أن أحدهما لا يقرأ صف الآخر.
يعمل فقط عند توفر `SUPABASE_URL`/`SUPABASE_ANON_KEY` كمتغيرات بيئة:

```bash
SUPABASE_URL=... SUPABASE_ANON_KEY=... flutter test test/integration/rls_test.dart
```
