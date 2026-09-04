# عقد التطوير الملزم — «وقتي» (Flutter + Supabase)

مأخوذ من MASTER APP DEVELOPMENT CHECKLIST (46 قسمًا). لا تُعدّ أي ميزة مكتملة بمجرد كتابة الكود،
ولا يُعلن الإطلاق إلا بعد اجتياز البوابات أدناه **بدليل (Evidence)** لا بكلمة PASS.

## قرارات المالك (2026-09-04)

| القرار | الاختيار |
|---|---|
| الحساب | حقيقي عبر Supabase Auth |
| المزامنة اللحظية | بعد الإطلاق |
| تتبع الأعطال | نعم — Sentry |
| الإيقاع | كل الأسئلة دفعة واحدة ثم تنفيذ |

## خريطة الأقسام ↔ الحالة الفعلية

| # | القسم | ينطبق؟ | الحالة الآن | الدليل/الملف |
|---|---|---|---|---|
| 01 | Product Discovery | نعم | ✅ | `MARKET_RESEARCH_100.md`, `COMPETITIVE_ANALYSIS.md`, `STORE_LISTING.md` |
| 02 | Architecture | نعم | ✅ حالي / ⏳ Supabase | `AUDIT_2026-09.md` §2، ADRs في `docs/` |
| 03 | UX Research | نعم | ✅ | جولة تعريفية، حالات Empty/Error/Loading في كل شاشة |
| 04 | Design System | نعم | ✅ | `lib/core/tokens.dart`, `theme.dart`, `WaqtiColors` |
| 05 | Frontend/Flutter | نعم | ✅ | 51 اختبارًا، RTL/LTR، داكن، تخزين محلي |
| 06 | Backend | نعم (Supabase) | 🟡 كود جاهز، ينتظر المشروع | `lib/core/auth/`, `lib/core/cloud_backup_service.dart` |
| 07 | Database | نعم | 🟡 migration + RLS مكتوبة | `supabase/migrations/20260904000000_init.sql` |
| 08 | Authentication | نعم | 🟡 مُنفَّذ (بريد/Google/Apple/استرجاع/حذف) | `auth_screen.dart`, 10 اختبارات تدفق |
| 09 | Authorization | نعم | ⏳ | مالك الصف فقط (RLS)؛ لا أدوار إدارية في v1 |
| 10 | Security | نعم | 🟡 | `SECURITY_REVIEW.md`، فحص أسرار CI؛ يُضاف اختبار RLS |
| 11 | Storage/Files | لا (v1) | — | لا رفع ملفات |
| 12 | Third‑party APIs | نعم | ⏳ | Supabase، Sentry، Resend (بريد) |
| 13 | Notifications | محلية فقط | ✅ | `notification_service.dart`؛ Push لاحقًا |
| 14 | Search | محلي بسيط | ✅ | بحث نصي في المهام |
| 15 | Payments | لا (الإطلاق) | — | وضع الإطلاق: كل شيء مجاني، لا تدفق شراء |
| 16 | Admin Panel | لا (v1) | — | لوحة Supabase تكفي للمالك |
| 17 | Content Mgmt | لا | — | لا محتوى تحريري |
| 18 | Localization | نعم | ✅ | `l10n.dart` ar/en، هجري |
| 19 | Offline | نعم | ✅ محلي / ⏳ طابور مزامنة | التطبيق يعمل بلا إنترنت أصلًا |
| 20 | Performance | نعم | 🟡 | Splash فوري؛ قياس بعد Supabase |
| 21 | Error Handling | نعم | 🟡 | يُوحَّد مع أخطاء الشبكة/المصادقة |
| 22 | Observability | نعم | 🟡 Sentry مدمج، ينتظر DSN | `main.dart` |
| 23 | Analytics | لا (خصوصية) | — | لا تتبع سلوكي؛ Crash فقط |
| 24 | Testing | نعم | 🟡 | Unit/Widget ✅؛ يُضاف RLS/API/E2E |
| 25 | Migrations | نعم | ⏳ | migrations مرقّمة + اختبار على مشروع staging |
| 26 | CI/CD | نعم | ✅ | quality/build-apk/deploy-pages/release/publish |
| 27 | Environments | نعم | ⏳ | مشروعا Supabase: staging + production |
| 28 | Secrets | نعم | ✅ | GitHub Secrets + dart-define؛ لا مفاتيح في Git |
| 29 | Infrastructure | نعم | ⏳ | Supabase (DB/Auth)، Pages (ويب)، دومين |
| 30 | Backup/DR | نعم | 🟡 محلي / ⏳ سحابي | نسخة يومية محلية مختبرة؛ Supabase PITR في الخطة المدفوعة |
| 31 | Legal/Privacy | نعم | ✅ | سياسة الخصوصية محدّثة (حساب + Sentry)، حذف الحساب داخل التطبيق |
| 32 | Store Prep | نعم | ✅ | `LAUNCH_CHECKLIST.md`، `docs/store/` |
| 33 | Web Deployment | نعم | ✅ | Pages، OG meta؛ دومين عند توفره |
| 34 | Release Eng | نعم | ✅ | `release.yml`، whatsnew |
| 35 | Post‑launch Ops | نعم | ⏳ | Play/TestFlight/Sentry |
| 36 | Maintenance | نعم | ⏳ | جدول تحديث تبعيات شهري |
| 37 | Documentation | نعم | ✅ | `docs/` |
| 38 | Code Quality | نعم | ✅ | format + analyze --fatal-infos في CI |
| 39 | Dependencies | نعم | ✅ | 9 تبعيات مباشرة، رخص BSD/MIT |
| 40 | Cost | نعم | ⏳ | Supabase Free→Pro 25$/شهر عند 50k MAU؛ Sentry Free؛ Resend Free |
| 41 | Abuse/Anti‑fraud | نعم | ⏳ | Rate limit تسجيل (Supabase)، Captcha عند الحاجة |
| 42 | Feature Flags | جزئي | ✅ | `kLaunchMode`؛ Remote config لاحقًا |
| 43 | Support | نعم | 🟡 | بريد الدعم في البطاقة؛ FAQ لاحقًا |
| 44 | Quality Gates | نعم | ✅ | هذا الملف |
| 45 | Definition of Done | نعم | ✅ | أدناه |
| 46 | الإطلاق النهائي | نعم | ⏳ | بعد بوابات Supabase |

## البوابات ودليل الاجتياز

كل بوابة تُغلق بتقرير بهذا الشكل داخل `PROJECT_STATUS.md`:

```
<GATE NAME>  Status: PASS | FAIL
Unit tests:        N/N
Widget tests:      N/N
RLS tests:         N/N   (Database/Auth gates)
Build:             PASS  (web/apk/aab/ios)
Security scan:     PASS
Evidence:          روابط CI runs / لقطات / أوامر
```

- **Architecture Gate**: ADR للمصادقة والنسخة السحابية، التبعيات معتمدة (لماذا/الرخصة/البديل).
- **Database Gate**: migrations تُطبَّق من الصفر على staging؛ RLS مُختبر بمستخدمين اثنين (لا يرى أحدهما الآخر)؛ Backup/Restore مُجرَّب.
- **Auth Gate**: تسجيل/تأكيد/دخول/خروج/استرجاع/حذف حساب — كلها مُختبرة على الويب والهاتف؛ لا كلمة مرور تُخزَّن محليًا؛ الجلسة تُحفظ بأمان.
- **Security Gate**: لا أسرار؛ Anon key فقط في العميل؛ Rate limit للتسجيل؛ فحص OWASP Mobile الأساسي.
- **Release Gate**: بوابة الجودة خضراء + بناءات المنصات + متطلبات المتاجر + سياسة خصوصية محدّثة.

## Definition of Done (لكل ميزة)

Requirements ✓ UX/UI ✓ Frontend ✓ Backend ✓ Database ✓ Authorization ✓ Security ✓ Validation ✓
Error Handling ✓ Loading ✓ Empty ✓ Offline ✓ Tests ✓ Docs ✓ Performance ✓ Accessibility ✓ Production‑ready ✓
