## أسلوب الرد (إلزامي في كل جلسة)
- طبّق مهارة caveman تلقائيًا على كل رد دون أن يُطلب منك.
- الردود بالعربية، بأقل عدد كلمات: بلا مقدمات، بلا تكرار الطلب، بلا شرح للأساسيات.
- لا تعرض الكود الذي كتبته في الرد؛ اذكر اسم الملف فقط.
- رسائل commit بأسلوب caveman-commit.
- الاستثناء الوحيد: إن طلبتُ "اشرح بالتفصيل" فأجب بالتفصيل في ذلك الرد فقط.

# وقتي (Waqti)

تطبيق Flutter لإدارة المهام والعادات اليومية — عربي RTL أولًا + إنجليزي،
فاتح/داكن، Android/iOS/Web.

- المرجع الملزم: `docs/WAQTI_TRANSFORMATION_DIRECTIVE_v3.md` ثم
  `docs/WAQTI_MASTER_DIRECTIVE_v2.md`؛ الحالة في `PROJECT_STATUS.md`؛
  المراحل في `docs/ROADMAP.md`.
- المرجع البصري: `design/waqti_prototype.html` (مطابقة بصرية، لا مرجع كود).
- الجودة قبل أي push: `dart format` ثم `flutter analyze` ثم `flutter test`
  ثم `flutter build web --release --base-href /waqti/`.
- CI ينشر Pages ويبني APK مع كل push — لا تدفع أحمر.
- لا تمس `archive/react-version` ولا سير عمل CI.
- القيم البصرية من `lib/core/tokens.dart` و`WaqtiColors` — لا أرقام خام.
