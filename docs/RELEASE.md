# دليل إطلاق «وقتي» على المتاجر

الإصدار الحالي: `1.1.0+2` (يُغيَّر من سطر `version:` في `pubspec.yaml`؛
الرقم بعد `+` هو رقم البنية ويجب زيادته مع كل رفع للمتاجر).

معرّف التطبيق على كل المنصات: `com.waqti.waqti`.

## طريقة إنتاج الحِزم (جاهزة)

من GitHub → تبويب **Actions** → **Release Builds** → **Run workflow**
(أو ادفع وسمًا مثل `v1.1.0`). ينتج 4 حِزم في Artifacts:

| الحزمة | المحتوى | وجهتها |
|---|---|---|
| `waqti-android` | `app-release.aab` + `app-release.apk` | Google Play |
| `waqti-windows` | `waqti-windows.zip` + `*.msix` | Microsoft Store |
| `waqti-web` | `waqti-web.zip` | أي استضافة ويب |
| `waqti-ios-nosign` | `Runner.app` بلا توقيع | يوقَّع من Mac |

---

## 1) أندرويد — Google Play

**مرة واحدة: أنشئ مفتاح الرفع** (على جهازك، واحتفظ به في مكان آمن):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

**اربطه بالمشروع** بأحد طريقين:

- محليًا: أنشئ `android/key.properties` (المستودع يتجاهله تلقائيًا):

  ```properties
  storePassword=كلمة السر
  keyPassword=كلمة السر
  keyAlias=upload
  storeFile=../upload-keystore.jks
  ```

  ثم: `flutter build appbundle --release`

- عبر CI: أضف سرّين في GitHub → Settings → Secrets → Actions:
  - `ANDROID_KEYSTORE_BASE64`: ناتج `base64 -w0 upload-keystore.jks`
  - `ANDROID_KEY_PROPERTIES`: محتوى ملف key.properties أعلاه
    (مع `storeFile=../upload-keystore.jks`)

  بعدها كل تشغيل لـ Release Builds ينتج AAB موقّعًا جاهزًا للرفع.

**الرفع**: [Play Console](https://play.google.com/console) → أنشئ التطبيق →
Production → أنشئ إصدارًا وارفع `app-release.aab` → أكمل بطاقة المتجر
(الوصف، لقطات شاشة، أيقونة 512 موجودة في
`assets/branding/app_icon.png`) → أرسل للمراجعة.
بدون مفتاح، الـ AAB الناتج موقّع بمفاتيح debug ولن يقبله المتجر.

## 2) آبل — App Store

بناء iOS الموقّع يتطلب جهاز Mac وحساب
[Apple Developer](https://developer.apple.com) (99$/سنة). على الـ Mac:

```bash
git clone https://github.com/daood40/waqti.git && cd waqti
flutter pub get
open ios/Runner.xcworkspace   # اختر فريقك في Signing & Capabilities
flutter build ipa --release
```

ثم ارفع `build/ios/ipa/*.ipa` عبر تطبيق **Transporter** أو
`xcrun altool`، وأكمل البطاقة في
[App Store Connect](https://appstoreconnect.apple.com).
كل شيء داخل المشروع جاهز: اسم العرض «وقتي»، الأيقونات مولّدة،
وبند التشفير `ITSAppUsesNonExemptEncryption=false` مضاف
(يوفّر سؤال التصدير عند كل رفع).

## 3) ويندوز — Microsoft Store

سجّل في [Partner Center](https://partner.microsoft.com/dashboard)
(رسم لمرة واحدة) واحجز اسم التطبيق، ثم خذ من صفحة
Product identity القيم الثلاث وضعها في `pubspec.yaml` تحت `msix_config`:

- `identity_name` ← Package/Identity/Name
- `publisher` ← Package/Identity/Publisher (أضف السطر)
- `publisher_display_name` ← PublisherDisplayName

ثم شغّل Release Builds (أو على جهاز ويندوز:
`flutter build windows --release && dart run msix:create --store`)
وارفع ملف `.msix` الناتج في Partner Center.
حزمة `waqti-windows.zip` تعمل مباشرة على أي ويندوز للتجربة خارج المتجر.

## 4) الويب

منشور تلقائيًا مع كل push على:
<https://daood40.github.io/waqti/>

للنشر على نطاق خاص: فك `waqti-web.zip` على أي استضافة ثابتة
(البناء فيه بـ `--base-href /` فيعمل من جذر النطاق مباشرة).
التطبيق PWA كامل: يعمل دون اتصال بعد أول زيارة وقابل للتثبيت.

---

## قائمة تحقق قبل كل إصدار

1. ارفع `version:` في `pubspec.yaml` (مثال: `1.2.0+3`).
2. `dart format . && flutter analyze && flutter test` — كله أخضر.
3. `flutter build web --release --base-href /waqti/` يبني بلا أخطاء.
4. جرّب التطبيق في المتصفح: تسجيل الدخول، إضافة مهمة، إكمالها،
   التبويبات الستة، تبديل اللغة والمظهر.
5. ادفع وسمًا `vX.Y.Z` ليبني Release Builds الحِزم الأربع.
