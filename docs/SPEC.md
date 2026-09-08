# وقتي — SPEC (ذاكرة البناء وفق `flutter-autobuild`)

> يُقرأ أولًا عند استئناف أي جلسة. المرجع الملزم يبقى
> `docs/WAQTI_TRANSFORMATION_DIRECTIVE_v3.md` ثم `docs/DEVELOPMENT_CONTRACT.md`.

## 1. الجملة الواحدة

تطبيق لمن يريد بناء عادات ومهام يومية ومتابعتها بسلاسل وتقويم وإحصاءات،
عربي أولًا، يعمل محليًا بلا حساب، ومع حساب يحتفظ بنسخة سحابية.

الفعل الجوهري: **إنهاء مهمة اليوم بنقرة واحدة من الشاشة الرئيسية.**

## 2. الشاشات

| الشاشة | الملف | الحالات الأربع |
|---|---|---|
| Onboarding | `lib/screens/onboarding_screen.dart` | ثابتة |
| Auth (دخول/تسجيل/نسيت/زائر) | `lib/screens/auth_screen.dart` | busy/error |
| Reset password | `lib/screens/reset_password_screen.dart` | busy/error |
| Shell (تبويبات) | `lib/screens/shell_screen.dart` | — |
| Home | `lib/screens/tabs/home_tab.dart` | فراغ/بيانات |
| Tasks (قائمة + بحث + ترتيب) | `lib/screens/tabs/tasks_tab.dart` | فراغ/بحث بلا نتائج/بيانات |
| Calendar (+ ورقة اليوم) | `lib/screens/tabs/calendar_tab.dart` | فراغ/بيانات |
| Stats | `lib/screens/tabs/stats_tab.dart` | فراغ/بيانات |
| Achievements | `lib/screens/tabs/achievements_tab.dart` | مقفول/مفتوح |
| Settings (حساب/سحابة/تصدير/حذف) | `lib/screens/tabs/settings_tab.dart` | حالة السحابة |
| Focus (مؤقّت) | `lib/screens/focus_screen.dart` | — |
| Subscription (قريبًا) | `lib/screens/subscription_screen.dart` | — |
| Sheets: محرر مهمة، تفاصيل، تصنيفات | `lib/widgets/*_sheet.dart` | تحقق من الإدخال |

## 3. نموذج البيانات

محلي: `shared_preferences` مفتاح `waqti.v1` (JSON كامل، `lastChangedAt`).

سحابي (Supabase، `supabase/migrations/20260904000000_init.sql`):

| جدول | أعمدة | قاعدة الوصول |
|---|---|---|
| `user_backups` | `user_id` pk→auth.users, `payload` text ≤2MB, `app_version`, `updated_at`, `created_at` | RLS: المالك فقط (select/insert/update/delete) |
| RPC `delete_own_account()` | — | security definer، يحذف المستخدم الحالي فقط |

الدمج: Last-Write-Wins بين `updated_at` السحابي و`lastChangedAt` المحلي
(`decideSync` في `lib/core/cloud_backup_service.dart`).

## 4. قرارات المكدّس (لماذا)

| القرار | الاختيار | السبب |
|---|---|---|
| المنصات | Android + iOS (Web يستضيف الخصوصية فقط) | قرار المالك |
| الحالة | Provider + `ChangeNotifier` واحد | موجود ومختبر؛ Riverpod تغيير بلا عائد الآن |
| التوجيه | Navigator 1 + Shell بتبويبات | لا روابط عميقة سوى `waqti://login-callback` |
| الخلفية | Supabase (بريد/كلمة مرور، Google/Apple عند التفعيل) | علاقي، RLS، مجاني للبداية |
| التخزين المحلي | `shared_preferences` | حجم البيانات صغير، لا استعلامات |
| الثيم | Material 3 + `WaqtiColors` + `lib/core/tokens.dart` | لا أرقام خام |
| الخط | Tajawal مضمّن | عربي أولًا |
| الأعطال | Sentry (بلا PII) | قرار المالك |
| CI | quality.yml / release.yml / publish.yml | لا تمس build-apk/deploy-pages |

## 5. خطة المراحل (تُحدَّث عند إتمام كل مرحلة)

- [x] **1 Skeleton** — بنية، ثيم فاتح/داكن، ترجمة، Shell، env، CI.
  - [x] lints صارمة (`analysis_options.yaml`) + `dart fix`
  - [x] كل الحواف `EdgeInsetsDirectional` / `AlignmentDirectional`
  - [x] ارتفاع سطر عربي في الثيم (`WqType.*Height`)
  - [x] `.gitignore` للأسرار + `env/example.json`
- [x] **2 Data & auth** — مخطط + RLS في نفس الـ commit، بوابات مصادقة، جلسة تدوم، حذف حساب.
- [x] **3 Core feature** — قائمة/تفاصيل/إنشاء/تعديل/حذف، حالات فراغ/بيانات، كل النصوص من `l10n.dart`.
- [x] **4 Features** — تذكيرات محلية، بحث/فرز، تقويم هجري، إحصاءات، إنجازات، تصدير، نسخة سحابية.
- [ ] **5 Polish** — مفاتيح القوائم، فحص `mounted` بعد كل `await`، إتاحة (48px، semantics، 1.3×)، جولة RTL وداكن.
- [ ] **6 Hardening** — مراجعة أمن، أداء (const/RepaintBoundary)، اختبارات إضافية.
- [x] **7 Release prep** — أيقونة/سبلاش، توقيع، نص المتجر، خصوصية، CI إصدار (v1.3.0 منشور).

## 6. ما لا نبنيه (مقصود)

Firebase، دردشة، وسائط، مدفوعات (الاشتراك "قريبًا")، ذكاء اصطناعي، سطح المكتب
كهدف إطلاق. تُحذف أزرارها من الواجهة بدل تركها ميتة.
