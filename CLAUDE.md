# CLAUDE.md

## المشروع
- وقتي (Waqti): تطبيق Flutter لتتبع المهام والعادات اليومية مع إحصائيات وإنجازات. عربي/إنجليزي مع RTL كامل، والمستخدمون يتحدثون العربية أولًا.
- الموقع المنشور: https://daood40.github.io/waqti/ (ينشر تلقائيًا مع كل push).

## التقنيات
- Flutter (Dart SDK ^3.9)، إدارة الحالة: Provider (ChangeNotifier في `lib/state/app_state.dart`).
- تخزين محلي: shared_preferences (JSON). خط Tajawal. فاتح/داكن/تلقائي.
- المرجع الملزم للمواصفات: `docs/WAQTI_MASTER_DIRECTIVE_v2.md`، والحالة في `PROJECT_STATUS.md`.

## الأوامر
- install: `flutter pub get` · test: `flutter test` · lint: `flutter analyze` · format: `dart format .` · build: `flutter build web` / `flutter build apk`

## بنية المجلدات
- `lib/core/` الثيم والترجمة (l10n.dart) ومعلومات التطبيق.
- `lib/models/` النماذج · `lib/state/` الحالة · `lib/screens/` الشاشات (tabs داخلها) · `lib/widgets/` الويدجتات المشتركة.
- `test/` الاختبارات · `design/waqti_prototype.html` المرجع البصري.

## قواعد ثابتة
- طبّق مهارة token-efficiency في كل مهمة، وflutter-arabic-app لأي عمل على Flutter.
- لا نصوص ثابتة في الواجهة؛ كل شيء عبر `lib/core/l10n.dart` (عربي + إنجليزي).
- لا left/right؛ استخدم start/end وEdgeInsetsDirectional. لا أسرار في الكود.
- بعد أي تعديل: `flutter analyze` و`flutter test` يجب أن ينجحا، وdart format نظيف.

## لا تلمس
- ملفات مولّدة (build/، .dart_tool/)، أيقونات مولّدة عبر flutter_launcher_icons.
- `archive/react-version` (نسخة مؤرشفة).
