# قائمة الإطلاق — «وقتي» v1.2.2

كل ما لا يتطلب حسابًا مدفوعًا **منجز**. المتبقي فقط ما تشترطه المتاجر من المالك.

## ✅ منجز (بلا تدخل)

| البند | الحالة |
|---|---|
| التطبيق: مزايا 100 تطبيق، وضع الإطلاق (كل شيء مجاني)، 48 اختبارًا، مراجعة أمنية، تدقيق أزرار آلي | ✅ |
| الويب منشور | ✅ <https://daood40.github.io/waqti/> |
| حِزم الإصدار (APK/AAB/Windows zip+MSIX/Web/iOS) | ✅ <https://github.com/daood40/waqti/releases/latest> |
| سياسة الخصوصية (عربي/إنجليزي) | ✅ <https://daood40.github.io/waqti/privacy.html> |
| بطاقة المتجر: الاسم، الوصف القصير/الكامل، الكلمات المفتاحية، ملاحظة المراجع | ✅ `docs/STORE_LISTING.md` |
| لقطات هاتف 1290×2796 (5) | ✅ `docs/screenshots/` |
| لقطات iPad 13" 2064×2752 (4) | ✅ `docs/store/ipad-*.png` |
| رسم Play المميز 1024×500 | ✅ `docs/store/play-feature-graphic-1024x500.png` |
| أيقونة 512×512 (Play) / 1024×1024 (آبل) | ✅ `assets/branding/app_icon.png` (1024) |
| نصوص «ما الجديد» عربي/إنجليزي | ✅ `distribution/whatsnew/` |
| مفتاح رفع أندرويد (keystore) | ✅ أُرسل إليك — احفظه |
| سير عمل النشر الآلي للمتاجر الثلاثة | ✅ `.github/workflows/publish.yml` |

## 🟡 بيدك (مرة واحدة، ~ساعة إجمالًا)

### 1. Google Play (25$ مرة واحدة)
1. أنشئ حساب مطور في <https://play.google.com/console> → Create app: «وقتي»، App، Free، اللغة الافتراضية العربية.
2. **Set up your app** — الإجابات:
   - App access: *All functionality is available without special access*.
   - Ads: **No**. Content rating: استبيان IARC → فئة Utility/Productivity → كل الإجابات **No** → Everyone.
   - Target audience: 13+ (ليس موجّهًا للأطفال). News app: No. Data safety: **Does not collect or share any user data** — البيانات على الجهاز فقط، ولا تُنقل.
   - Government app: No. Financial features: None. Health: None. Privacy policy: <https://daood40.github.io/waqti/privacy.html>.
3. Store listing: انسخ النصوص من `docs/STORE_LISTING.md`، الأيقونة 512 (صغّر `app_icon.png`)، الرسم المميز، اللقطات.
4. Setup → API access → Create service account → Grant access (Release manager) → أضف مفتاح JSON كسر `PLAY_SERVICE_ACCOUNT_JSON` + مفتاح الرفع (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_PROPERTIES`).
5. Actions → Publish to Stores → android ✔، track = **internal** → ثم production عند رضاك.

### 2. App Store (99$/سنة)
1. <https://developer.apple.com/programs/enroll> (يستغرق القبول 1–2 يوم).
2. Certificates, IDs & Profiles → Identifiers → + App ID: `com.waqti.waqti`.
3. App Store Connect → My Apps → + → New App: iOS، «وقتي»، Bundle ID أعلاه، SKU `waqti`.
4. Users and Access → Integrations → App Store Connect API → Generate key (Access: App Manager) → الأسرار `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` + `APPLE_TEAM_ID` (Membership).
5. Actions → Publish to Stores → ios ✔ → يظهر البناء في TestFlight خلال دقائق.
6. في App Store Connect: App Information (Category: Productivity)، Pricing: Free، App Privacy: **Data Not Collected**، Age Rating: كلها None → 4+، اللقطات (6.7" من `docs/screenshots/`، iPad 13" من `docs/store/`)، النصوص، اختر البناء، App Review notes من `docs/STORE_LISTING.md` → **Submit for Review**.

### 3. Microsoft Store (19$ مرة واحدة)
1. <https://partner.microsoft.com/dashboard> → Apps and games → New product → MSIX → احجز «وقتي».
2. Product identity → الأسرار `MSIX_PUBLISHER`, `MSIX_IDENTITY_NAME`, `MSIX_PUBLISHER_DISPLAY_NAME`؛ Store ID → `MS_PRODUCT_ID`؛ Account settings → Seller ID → `MS_SELLER_ID`.
3. Account settings → User management → Azure AD applications → Create new → Manager → Add key → `MS_TENANT_ID`, `MS_CLIENT_ID`, `MS_CLIENT_SECRET`.
4. Actions → Publish to Stores → windows ✔ → ثم أكمل Properties (Productivity، الخصوصية) وStore listing وSubmit.

### 4. الويب (اختياري)
دومين خاص: اشترِ الدومين → سجل CNAME إلى `daood40.github.io` → Settings → Pages → Custom domain.

## بعد الإطلاق
- راقب Crashes/ANRs في Play Console وTestFlight feedback.
- كل إصدار جديد: ارفع `version:` في `pubspec.yaml` و`kAppVersion` → Release Builds (version vX.Y.Z) → Publish to Stores.
