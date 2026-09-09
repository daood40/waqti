# حزمة الرفع للمتاجر — «وقتي» v1.3.3 (build 9)

كل ما تحتاجه لوحة Google Play وApp Store Connect، جاهز للنسخ. الترتيب الزمني في `docs/LAUNCH_PHASES.md`،
والمطابقة القانونية/التقنية في `docs/STORE_COMPLIANCE.md`.

## 1. الحِزم

| الملف | المصدر |
|---|---|
| `waqti-v1.3.3.aab` (Play، موقّع بمفتاح الرفع عند وجود الأسرار) | GitHub Release `v1.3.3` أو `Publish to Stores` |
| `waqti-v1.3.3.apk` (اختبار الجهاز) | GitHub Release `v1.3.3` |
| IPA (App Store) | `Publish to Stores` → iOS (توقيع سحابي بمفتاح ASC) |
| رموز فك التشويش | artifact `waqti-symbols-android` / `waqti-symbols-ios` — احفظها مع الإصدار |

## 2. الهوية

- الاسم: **وقتي** (Waqti). الحزمة: `com.waqti.waqti`. الفئة: Productivity. السعر: مجاني. اللغة الافتراضية: العربية (+ الإنجليزية).
- الأيقونة: Play 512×512 `docs/store/play-icon-512.png`؛ آبل 1024×1024 بلا شفافية `assets/branding/app_icon.png`.
- الرسم المميز (Play) 1024×500: `docs/store/play-feature-graphic-1024x500.png`.

## 3. اللقطات (نهائية بعناوين، مجموعة لكل لغة)

| المتجر | المقاس | عربي | إنجليزي |
|---|---|---|---|
| Google Play — هاتف | 1080×1920 | `docs/store/final/ar/play/` | `docs/store/final/en/play/` |
| App Store — iPhone 6.7"/6.9" | 1290×2796 | `docs/store/final/ar/iphone/` | `docs/store/final/en/iphone/` |
| App Store — iPad 13" | 2064×2752 | `docs/store/final/ar/ipad/` | `docs/store/final/en/ipad/` |

ارفع المجموعة العربية في تعريب `ar` والإنجليزية في `en-US`؛ لا تخلطهما.

## 4. النصوص

- الوصف القصير/الكامل/الكلمات المفتاحية (عربي + إنجليزي): `docs/STORE_LISTING.md`.
- ما الجديد: `distribution/whatsnew/whatsnew-ar`, `whatsnew-en-US`.
- الروابط: الخصوصية `https://daood40.github.io/waqti/privacy.html` · الدعم `https://daood40.github.io/waqti/support.html` · حذف الحساب `https://daood40.github.io/waqti/delete-account.html`.

## 5. الإجابات القانونية

### Google Play — Data safety
**الإصدار المرفوع بلا Supabase/Sentry (الحالة الآن)**: "Does your app collect or share any of the required user data types?" → **No**. لا مشاركة. التشفير: N/A. الحذف: N/A (لا حساب).

**عند تفعيل Supabase + Sentry (بعد إضافة الأسرار وإعادة البناء)**: Collects → Personal info: **Email address, Name** (App functionality, Account management؛ اختياري؛ قابل للحذف) · App activity: **No** · App info & performance: **Crash logs, Diagnostics** (App functionality) · Data encrypted in transit ✔ · Users can request deletion ✔ + رابط حذف الحساب أعلاه. لا مشاركة مع أطراف ثالثة.

### Google Play — الباقي
Ads: No · Content rating (IARC): Utility/Productivity، كل الإجابات No → Everyone · Target audience: 13+ (not designed for children) · News: No · Government: No · Financial features: None · Health: None · App access: All functionality available without special access (اذكر «المتابعة كزائر») · Privacy policy URL أعلاه.

### App Store — App Privacy
**بلا Supabase/Sentry**: **Data Not Collected**.
**مع Supabase + Sentry**: Data Linked to You → Contact Info (Email Address), Name, User Content (Other User Content) — Purpose: App Functionality · Data Not Linked to You → Diagnostics (Crash Data) — App Functionality · Tracking: **No**.

### App Store — الباقي
Age Rating: كل الأسئلة None → 4+ · Export compliance: No (ITSAppUsesNonExemptEncryption=false) · Content Rights: لا محتوى طرف ثالث · Sign in with Apple: غير مطلوب حاليًا (لا دخول طرف ثالث)؛ عند تفعيل Google يُفعَّل Apple معه (مفروض بالشيفرة).

## 6. ملاحظات المراجع + الحساب التجريبي
النص في `docs/STORE_LISTING.md` → "ملاحظات المراجع". بلا Supabase لا يوجد حساب أصلًا (اكتب: "No account exists in this version; use Continue as guest"). مع Supabase أنشئ حسابًا تجريبيًا في المرحلة 3 واكتبه هناك.

## 7. تسلسل الرفع (بعد إضافة الأسرار)
1. Actions → **Publish to Stores** → android ✔ (track: internal) + ios ✔.
2. Play: Testing → Internal → ثبّت ورجّب. ثم Closed testing (12 مختبِرًا × 14 يومًا) → Apply for production.
3. آبل: TestFlight → أكمل بطاقة الإصدار → Submit for Review (Manual release).
4. الإطلاق: Play production 20% → 50% → 100%؛ آبل Release.
