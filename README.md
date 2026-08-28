<div dir="rtl">

# وقتي ⏰

**وقتي** — تطبيق مهام وعادات يومية، سريع وبسيط، يعمل على الويب كتطبيق PWA وعلى أندرويد عبر Capacitor.

🌐 **جرّبه الآن:** [daood40.github.io/waqti](https://daood40.github.io/waqti/)

## المزايا

- ✅ **قائمة مهام يومية** — إضافة وإنجاز وحذف المهام، مع قسم للمهام المتأخرة وشريط تقدّم اليوم
- 🔁 **تتبع العادات المتكررة** — إنجاز يومي، سلسلة أيام متتالية (Streak)، وعرض آخر ٧ أيام
- 📊 **إحصائيات وإنجازات** — مهام منجزة، أفضل سلسلة، أيام مثالية، رسم بياني لآخر أسبوع، وشارات إنجاز تُفتح تدريجياً
- 🌍 **عربي وإنجليزي** — دعم كامل للاتجاه RTL/LTR مع تبديل فوري للغة
- 🌙 **وضع فاتح وداكن** — يتبع إعداد النظام تلقائياً مع إمكانية التبديل اليدوي
- 📱 **PWA يعمل بدون إنترنت** — قابل للتثبيت على الهاتف والحاسوب، وService Worker يخزّن التطبيق كاملاً
- 🔒 **خصوصية تامة** — كل البيانات تُحفظ محلياً على جهازك (localStorage) ولا تُرسل لأي خادم

## التقنيات

- [React 18](https://react.dev) + [Vite 6](https://vite.dev)
- [Capacitor 7](https://capacitorjs.com) لبناء تطبيق أندرويد
- GitHub Actions للنشر التلقائي وبناء الـ APK

## التشغيل محلياً

```bash
npm install        # تثبيت الحزم
npm run dev        # خادم التطوير على http://localhost:5173
npm run build      # بناء نسخة الإنتاج في dist/
npm run icons      # إعادة توليد أيقونات التطبيق
```

## النشر على GitHub Pages

Workflow ‏`.github/workflows/deploy-pages.yml` يبني التطبيق وينشره على GitHub Pages تلقائياً **مع كل push**.

المتطلبات (مرة واحدة):

1. من إعدادات المستودع: **Settings ← Pages ← Source ← GitHub Actions**
2. ليكون الرابط `daood40.github.io/waqti/` يجب أن يكون اسم المستودع `waqti` (أعد تسميته من **Settings ← General ← Repository name**)

## بناء APK أندرويد

Workflow ‏`.github/workflows/build-apk.yml` يبني نسخة أندرويد (Debug APK) مع كل push:

1. افتح تبويب **Actions** في المستودع
2. اختر آخر تشغيل ناجح لـ **Build Android APK**
3. حمّل ملف **waqti-debug-apk** من قسم Artifacts
4. انقل ملف `app-debug.apk` لهاتفك وثبّته (فعّل "التثبيت من مصادر غير معروفة")

> ملاحظة: هذه نسخة Debug موقّعة بمفتاح تطوير — مناسبة للتجربة الشخصية. للنشر على Google Play تحتاج توقيعاً بمفتاح Release خاص بك.

للبناء محلياً (يتطلب Android Studio أو SDK + Java 21):

```bash
VITE_BASE=./ npm run build
npx cap add android
npx cap sync android
cd android && ./gradlew assembleDebug
```

## بنية المشروع

```
├── public/            # الأصول الثابتة: manifest، أيقونات، Service Worker
├── scripts/           # مولّد الأيقونات (بدون مكتبات خارجية)
├── src/
│   ├── components/    # شاشات المهام والعادات والإحصائيات
│   ├── i18n.jsx       # الترجمة العربية/الإنجليزية واتجاه الصفحة
│   ├── storage.js     # الحفظ المحلي وحسابات السلاسل
│   ├── App.jsx        # الهيكل العام والتنقل والثيم
│   └── styles.css     # الأنماط (فاتح/داكن، RTL)
├── capacitor.config.json
└── .github/workflows/ # النشر على Pages وبناء الـ APK
```

</div>
