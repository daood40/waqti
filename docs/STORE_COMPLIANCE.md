# مطابقة شروط المتاجر — «وقتي» v1.3.3 (2026-09-09)

كل بند: الشرط → الحالة → الدليل. ✅ منجز في الشيفرة/الموقع، 🟡 يُنجز في لوحة المتجر بيدك (الإجابات جاهزة).

## Google Play

| الشرط | الحالة | الدليل |
|---|---|---|
| Target API ≥ 35 (مطلوب من أغسطس 2025) | ✅ 36 | Flutter 3.35 الافتراضي (`flutter.targetSdkVersion`) |
| دعم صفحات 16 KB (مطلوب من نوفمبر 2025) | ✅ | فحص `readelf` على APK v1.3.1 (وتنطبق على كل بناء لاحق بنفس الحزم): كل `.so` بمحاذاة ≥ 0x4000 |
| App Bundle موقّع + Play App Signing | ✅ | `release.yml`/`publish.yml` (AAB)؛ مفتاح الرفع لديك |
| سياسة الخصوصية في البطاقة **وداخل التطبيق** | ✅ | الإعدادات → حول → سياسة الخصوصية → `privacy.html` |
| حذف الحساب داخل التطبيق + **رابط ويب** لطلب الحذف | ✅ | الإعدادات → حذف الحساب؛ `https://daood40.github.io/waqti/delete-account.html` |
| Data safety مطابق للواقع | 🟡 إجابات جاهزة | `docs/LAUNCH_CHECKLIST.md` §1 (يجمع: بريد، اسم، سجلات أعطال؛ مشفّر؛ قابل للحذف) |
| أذونات بالحد الأدنى، لا SCHEDULE_EXACT_ALARM | ✅ | `AndroidManifest.xml`: POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE فقط |
| إذن الإشعارات (Android 13+) يُطلب في سياقه | ✅ | `NotificationService._ensurePermission` |
| لا محتوى نائب/«قريبًا» ولا شراء وهمي | ✅ | قسم الباقات مخفي في وضع الإطلاق (`kLaunchMode`) — `test/compliance_test.dart` |
| يعمل بلا تسجيل دخول | ✅ | «المتابعة كزائر» |
| Predictive back (Android 13+) | ✅ | `enableOnBackInvokedCallback="true"` + `PopScope` |
| Edge-to-edge (Android 15) | ✅ | `SafeArea`/`MediaQuery.paddingOf` في القشرة والصفحات |
| لا نص مشفّر غير آمن (cleartext) | ✅ | `usesCleartextTraffic="false"` |
| تصنيف المحتوى، الجمهور 13+، لا إعلانات | 🟡 | `docs/LAUNCH_CHECKLIST.md` §1 |
| اختبار مغلق 12 مختبِرًا × 14 يومًا (حساب شخصي جديد) | 🟡 | `docs/LAUNCH_PHASES.md` المرحلة 4 |

## App Store

| الإرشاد | الحالة | الدليل |
|---|---|---|
| 5.1.1(v) حذف الحساب من داخل التطبيق | ✅ | الإعدادات → حذف الحساب (`delete_own_account` RPC) |
| 5.1.1 خصوصية: Privacy manifest + بطاقة App Privacy | ✅ / 🟡 | `ios/Runner/PrivacyInfo.xcprivacy` يصرّح: بريد، اسم، محتوى المستخدم (مرتبط)، بيانات أعطال (غير مرتبطة)، لا تتبع؛ الإجابات في `docs/LAUNCH_CHECKLIST.md` §2 |
| 5.1.1(ii) لا إجبار على حساب لوظائف لا تحتاجه | ✅ | زائر بكل المزايا |
| 4.8 Sign in with Apple عند وجود دخول طرف ثالث | ✅ مفروض بالشيفرة | `AuthScreen._showGoogle`: Google يظهر على iOS/macOS فقط مع Apple |
| 2.1 اكتمال التطبيق، لا «قريبًا» ولا أزرار معطّلة | ✅ | شاشة الباقات غير قابلة للوصول في وضع الإطلاق |
| 3.1.1 لا مدفوعات خارج آبل | ✅ | لا تدفق شراء |
| 2.5.x دعم iPad دون متطلبات تعدد المهام | ✅ | `UIRequiresFullScreen=true`؛ الشبكات متجاوبة؛ لقطات iPad 13" |
| 5.1.2 لا تتبع، لا ATT | ✅ | `NSPrivacyTracking=false`، لا SDK إعلانات |
| 2.3 بيانات وصفية صادقة + Support URL + Privacy URL | ✅ | `support.html`، `privacy.html`، `docs/STORE_LISTING.md` |
| 2.1 حساب تجريبي للمراجع | 🟡 | يُنشأ في المرحلة 3 ويُكتب في App Review Information |
| تصدير التشفير | ✅ | `ITSAppUsesNonExemptEncryption=false` |
| سلاسل الأذونات | ✅ لا أذونات حساسة | لا كاميرا/موقع/جهات اتصال |
| اسم العرض وأيقونة 1024 بلا شفافية | ✅ | `CFBundleDisplayName=وقتي`، `remove_alpha_ios: true` |

## مشترك

| البند | الحالة | الدليل |
|---|---|---|
| صفحات عامة: الخصوصية، الدعم، حذف الحساب (عربي/إنجليزي) | ✅ | `web/privacy.html`, `web/support.html`, `web/delete-account.html` |
| روابط الدعم والتراخيص داخل التطبيق | ✅ | الإعدادات → حول (`showLicensePage`) |
| تقارير الأعطال بلا PII | ✅ | Sentry `sendDefaultPii=false` |
| تشويش + رموز مؤرشفة | ✅ | `--obfuscate --split-debug-info`، artifacts `waqti-symbols-*` |

## ما يبقى بيدك
1. إجابات Data safety / App Privacy (جاهزة حرفيًا في `docs/LAUNCH_CHECKLIST.md`).
2. حساب المراجع التجريبي بعد المرحلة 3.
3. الاختبار المغلق 14 يومًا على Play.
