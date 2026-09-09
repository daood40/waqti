# memory/TODO.md   (آخر تحديث: 2026-09-09)
## P0 — يمنع الإصدار على المتاجر (بيد المالك)
- [ ] حساب Google Play (25$) + Apple Developer (99$) وحجز الاسم «وقتي»
- [ ] الأسرار: PLAY_SERVICE_ACCOUNT_JSON, ANDROID_KEYSTORE_BASE64, ANDROID_KEY_PROPERTIES, ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8, APPLE_TEAM_ID
- [ ] اختبار APK v1.3.3 على جهاز حقيقي: تذكير يصل والتطبيق مغلق (R8) + قياس الإقلاع (البوابتان 13 و8)
- [ ] تفعيل حقيقي لمفتاح الإيقاف: عدّل `web/app-config.json` (maintenance=true) وتأكد من شاشة الحجب ثم أعده
## P1 — بعد أول رفع
- [ ] Supabase + Sentry (SUPABASE_URL, SUPABASE_ANON_KEY, SENTRY_DSN) ثم تشغيل test/integration/rls_test.dart وإعادة البناء
- [ ] اختبار Play المغلق (12 مختبِرًا × 14 يومًا) → Production access
- [ ] حساب مراجع تجريبي في App Review Information
## P2 / لاحقاً
- [ ] Google/Apple sign-in (معًا) · الباقات عبر RevenueCat · تنفيذ ADR-002/003/004/006 إن لزم الحجم
