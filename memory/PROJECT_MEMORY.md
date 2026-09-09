# memory/PROJECT_MEMORY.md   (آخر تحديث: 2026-09-09)
## ما هو
«وقتي» تطبيق Flutter لتتبع المهام والعادات اليومية (سلاسل مرنة، تقويم، إحصاءات، تذكيرات محلية)، عربي RTL أولًا + إنجليزي، لمن يريد الالتزام بعادات يومية بلا تعقيد.
## المكدّس
Flutter 3.35.1 · Provider + `ChangeNotifier` واحد (`lib/state/app_state.dart`) · `shared_preferences` (مفتاح `waqti.v1`) · `flutter_local_notifications` · Supabase (اختياري عبر dart-define؛ غير مفعّل في البناء الحالي) · Sentry (اختياري) · `flutter_secure_storage` للجلسة.
## الحالة اليوم
- يعمل: كل الميزات كزائر بلا خادم؛ الويب منشور؛ إصدار GitHub v1.3.2 (build 8) بحِزم APK/AAB/iOS-nosign/Windows/Web؛ CI أخضر (quality/build-apk/deploy-pages/release).
- لا يعمل / غير مفعّل: الحساب والنسخة السحابية (تحتاج `SUPABASE_URL`/`SUPABASE_ANON_KEY` في Secrets)، تقارير الأعطال (تحتاج `SENTRY_DSN`)، الرفع الفعلي للمتاجر (يحتاج حسابات المطوّر وأسرارها).
## أين توقّفنا
2026-09-09: التطبيق مطابق لشروط Play/App Store (`docs/STORE_COMPLIANCE.md`) وحزمة الرفع جاهزة (`docs/SUBMISSION_PACK.md`). الخطوة التالية المباشرة: المالك ينشئ حسابَي Play وApple ويضيف الأسرار (`docs/LAUNCH_PHASES.md` المرحلتان 1–2)، ثم `Publish to Stores`.
