# دليل الإطلاق خطوة بخطوة — «وقتي»

اختر أحد مسارين: **(أ) تطلقه بنفسك** أو **(ب) تفوّضني** بربط الحسابات عبر
GitHub Secrets فأرفع الحِزم للمتاجر الثلاثة بضغطة واحدة. الويب منشور أصلًا.

> القاعدة الذهبية: **لا ترسل أي مفتاح أو كلمة سر في المحادثة.** كل الأسرار توضع
> في: المستودع → Settings → Secrets and variables → Actions → New repository secret.

---

## مرحلة 0 — مشترك للمسارين (30 دقيقة)

1. **قرار الباقات**: اختر (1) إخفاء الأسعار في الإصدار الأول أو (2) دفع حقيقي عبر RevenueCat. أخبرني بالرقم وأنفّذه.
2. **مفتاح رفع أندرويد**: احفظ الملفين اللذين أرسلتهما لك (`upload-keystore.jks` + `key.properties`) في مكان آمن (مدير كلمات مرور). فقدانه = لا تحديثات مستقبلية للتطبيق على Google Play.
3. **الحسابات** (رسوم لمرة واحدة/سنوية):
   - Google Play Console: <https://play.google.com/console> — 25$ مرة واحدة.
   - Apple Developer Program: <https://developer.apple.com/programs/enroll> — 99$/سنة.
   - Microsoft Partner Center: <https://partner.microsoft.com/dashboard/registration> — 19$ مرة واحدة (فرد).
4. **احجز اسم التطبيق «وقتي»** في المتاجر الثلاثة فور تفعيل الحسابات (الأسماء قد تُحجز).

---

## المسار (أ): تطلقه بنفسك

### A1 — أنتج الحِزم
GitHub → Actions → **Release Builds** → Run workflow → انتظر ~12 دقيقة → نزّل Artifacts الأربعة.
(لتوقيع أندرويد أضف السرّين `ANDROID_KEYSTORE_BASE64` و`ANDROID_KEY_PROPERTIES` أولًا — انظر `docs/RELEASE.md`.)

### A2 — Google Play (45 دقيقة)
1. Create app → الاسم **وقتي** → تطبيق → مجاني.
2. **Set up your app** (القائمة اليسرى): أكمل كل البنود — سياسة الخصوصية: `https://daood40.github.io/waqti/privacy.html`؛ الإعلانات: لا؛ الوصول: كل الميزات متاحة بلا دخول (اذكر «المتابعة كزائر»)؛ التصنيف: استبيان → للجميع؛ الفئة: Productivity؛ Data safety: لا يجمع بيانات، لا يشارك، البيانات على الجهاز.
3. **Main store listing**: انسخ النصوص من `docs/STORE_LISTING.md`، الأيقونة 512 من `assets/branding/app_icon.png`، Feature graphic 1024×500 (أرسله لك عند الطلب)، اللقطات من `docs/screenshots/`.
4. **Production → Create new release** → ارفع `app-release.aab` → ملاحظات الإصدار → Review → Start rollout.
   المراجعة: 1–7 أيام.

### A3 — App Store (ساعة، يتطلب Mac أو المسار ب)
1. App Store Connect → My Apps → + → New App: iOS، الاسم **وقتي**، اللغة العربية، Bundle ID `com.waqti.waqti` (أنشئه أولًا في Certificates, IDs & Profiles → Identifiers)، SKU `waqti`.
2. على Mac: `git clone` → `flutter build ipa --release` (بعد اختيار الفريق في Xcode) → ارفع الـ IPA عبر تطبيق **Transporter**.
3. في App Store Connect: أكمل بطاقة التطبيق (النصوص واللقطات نفسها)، App Privacy: «Data Not Collected»، التصنيف العمري 4+، اختر البناء المرفوع، App Review Information: اكتب ملاحظة المراجع من `docs/STORE_LISTING.md`.
4. Submit for Review. المراجعة: 1–3 أيام.

### A4 — Microsoft Store (30 دقيقة)
1. Partner Center → Apps and games → New product → MSIX → احجز الاسم **وقتي**.
2. Product identity → ضع القيم الثلاث كأسرار في GitHub: `MSIX_PUBLISHER` (Package/Properties/Publisher مثل `CN=...`)، `MSIX_IDENTITY_NAME` (Package/Identity/Name)، `MSIX_PUBLISHER_DISPLAY_NAME`.
3. شغّل Release Builds مجددًا → `.msix` للمتجر يظهر في الإصدار. (بدون الأسرار يُنتج MSIX اختباري للتثبيت الجانبي فقط.)
4. Submissions → Packages → ارفع MSIX → Properties (الفئة Productivity، سياسة الخصوصية) → Store listings (النصوص واللقطات) → Submit. المراجعة: 1–3 أيام.

### A5 — الويب
لا شيء. منشور على <https://daood40.github.io/waqti/>. لدومين خاص: اشتره، أضف CNAME إلى `daood40.github.io`، ثم Settings → Pages → Custom domain.

---

## المسار (ب): تفوّضني — أضف هذه الأسرار وأنا أرفع

| المتجر | ما تضيفه أنت (Secrets) | كيف تحصل عليه |
|---|---|---|
| الخدمات | `SUPABASE_URL`، `SUPABASE_ANON_KEY`، `SENTRY_DSN`، `GOOGLE_WEB_CLIENT_ID`، `GOOGLE_IOS_CLIENT_ID` | Supabase → Settings → API؛ Sentry → Project → DSN؛ Google Cloud → Credentials (انظر `docs/LAUNCH_CHECKLIST.md` §0) |
| Google Play | `PLAY_SERVICE_ACCOUNT_JSON` | Play Console → Setup → API access → Create service account (Google Cloud) → JSON key → ارجع وامنحه **Release manager** |
| | `ANDROID_KEYSTORE_BASE64` | ناتج `base64 -w0 upload-keystore.jks` (ويندوز: `certutil -encode` ثم احذف السطرين الأول والأخير) |
| | `ANDROID_KEY_PROPERTIES` | محتوى ملف key.properties الذي أرسلته |
| App Store | `ASC_KEY_ID`، `ASC_ISSUER_ID`، `ASC_KEY_P8` | App Store Connect → Users and Access → Integrations → App Store Connect API → Generate (Access: **App Manager**) — Key ID وIssuer ID ظاهران، ومحتوى ملف `.p8` |
| | `APPLE_TEAM_ID` | developer.apple.com → Membership details |
| Microsoft Store | `MS_TENANT_ID`، `MS_CLIENT_ID`، `MS_CLIENT_SECRET` | Partner Center → Account settings → User management → Azure AD applications → Add → Create new (Manager) → Add new key |
| | `MS_SELLER_ID`، `MS_PRODUCT_ID` | Partner Center → Account settings → Legal info → Seller ID؛ والتطبيق → Product identity → Store ID (يبدأ بـ 9) |
| | `MSIX_PUBLISHER`، `MSIX_IDENTITY_NAME`، `MSIX_PUBLISHER_DISPLAY_NAME` | Partner Center → التطبيق → Product identity (تُستخدم في بناء MSIX للمتجر) |

**سير العمل جاهز**: `.github/workflows/publish.yml` — Actions → **Publish to Stores** → Run workflow. اختر المتاجر والمسار (Play: internal أولًا ثم production). كل وظيفة تتحقق من أسرارها وتفشل برسالة تسمّي الناقص.
- Google Play: يبني AAB موقّعًا بمفتاح الرفع ويرفعه مع نصوص «ما الجديد» من `distribution/whatsnew/`.
- App Store: يوقّع سحابيًا بمفتاح App Store Connect API (بلا Mac) ويرفع IPA إلى TestFlight/App Store Connect مباشرة.
- Microsoft Store: يبني MSIX بهوية المتجر ويرسله إلى Partner Center عبر MSStore CLI.
ما لا تسمح به الواجهات البرمجية (استبيان التصنيف العمري وData safety في Play، App Privacy في آبل) إجاباته جاهزة في `docs/LAUNCH_CHECKLIST.md`.

**ما يبقى بيدك حتمًا** (المتاجر تشترط الحساب المالك): دفع الرسوم، قبول الاتفاقيات (Paid Apps Agreement)، والضغط النهائي على «Submit for review» في App Store إن رغبت بالمراجعة قبل الإرسال.

---

## قائمة التحقق النهائية (أُنجزت)

- [x] 40 اختبارًا وحدويًا + تحليل ثابت بلا تحذيرات
- [x] اختبار E2E في متصفح حقيقي: دخول، إضافة/إكمال مهمة، التبويبات الستة، عربي/إنجليزي، فاتح/داكن، القوالب، العادات الكمية، يوم الراحة
- [x] بناء ناجح: أندرويد (APK/AAB)، iOS (بلا توقيع)، ويب، ويندوز (CI)
- [x] مراجعة أمنية: `docs/SECURITY_REVIEW.md` — بلا نتائج حرجة
- [x] سياسة خصوصية منشورة، بطاقة متجر، 5 لقطات 1290×2796
- [ ] **اختبار الإشعارات على جهاز حقيقي** (لا يمكن محاكاته هنا): ثبّت APK من Artifacts، أضف عادة بوقت تذكير بعد دقيقتين، أغلق التطبيق، وتأكد من وصول الإشعار
- [ ] قرار الباقات (0.1 أعلاه)
