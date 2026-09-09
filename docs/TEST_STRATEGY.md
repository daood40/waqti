# استراتيجية الاختبار (qa-test-strategy) — 2026-09-09

## التوزيع الفعلي
| الطبقة | العدد | الملفات | الزمن محليًا |
|---|---|---|---|
| وحدة (منطق التواريخ/التكرار/الإحصاء/JSON/CSV/المزامنة/الإعداد البعيد) | ~70 | `models_test`, `app_state_test`, `cloud_sync_test`, `search_test`, `remote_config_test`, `secure_session_storage_test`, `version_sync_test`, `adversarial_test` | ~5 ث |
| widget (الرحلات الحرجة والإتاحة) | ~12 | `widget_test`, `flows_test`, `a11y_test`, `editor_guard_test`, `compliance_test`, `remote_config_test` | ~15 ث |
| تكامل | 1 (متخطّى بلا خادم) | `test/integration/rls_test.dart` + `supabase/tests/rls_checks.sql` | يحتاج مشروع Supabase |
| E2E متصفح (مسح نقر + لقطات) | سكربتات Playwright في بيئة البناء | `scratchpad/*.mjs` (خارج المستودع) | ~2 دقيقة |

## المسار الحرج (تغطية إلزامية 100%)
1. أول تشغيل → الرئيسية كزائر → إضافة مهمة → إنجازها → بقاؤها بعد إعادة الفتح.
2. تعديل/حذف مع تراجع؛ حارس التعديلات غير المحفوظة.
3. تصدير JSON/CSV واستيرادهما (بما فيها ملفات تالفة).
4. تبديل اللغة والثيم أثناء التشغيل.
5. (مع خادم) دخول → نسخة سحابية → خروج يمسح → حذف حساب.

## معايير الدخول والخروج
- قبل أي commit: `dart format` + `flutter analyze --fatal-infos` + `flutter test` خضراء محليًا.
- قبل أي إصدار: `docs/RELEASE_GATE.md` بالبوابات الـ17 (PASS/FAIL/NOT RUN) — بلا استثناء.
- ما يوقف الإصدار: أي عطل حرج/مهم مفتوح في `memory/BUGS.md`، أي بوابة أمن أو أسرار غير PASS، انهيار على جهاز حقيقي.
- ما يُؤجَّل بتسجيل: أعطال بسيطة مرئية بلا فقدان بيانات (رقم + شدة + إصدار مستهدف في `memory/TODO.md`).

## حزمة الانحدار
كل عطل مُصلَح يُضاف اختباره إلى `test/` (مثال: BUG-001…007 → `adversarial_test.dart`). سجل الجولات في `qa/rounds/`.

## الإيقاع
- كل دفع: `quality.yml` (format/analyze/test/prod-config/secrets) + `build-apk.yml`.
- كل إصدار: `release.yml` → حِزم + رموز؛ بوابة يدوية على جهاز حقيقي (البوابة 13).
- كل اختبار متقطّع يُصلَح أو يُحذف خلال أسبوع (لا يوجد حاليًا).
