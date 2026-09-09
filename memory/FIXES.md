# memory/FIXES.md   (الأحدث في الأعلى)
## 2026-09-09 — جولة كسر طبقة الحالة (BUG-001…007) — qa/rounds/2026-09-09-state-layer.md
العَرَض: الحدود (اسم ≤60، تذكيرات ≤3، لا فراغ، لا معرّف مكرر، لا تصنيف فارغ/مكرر) كانت في الواجهة فقط؛ استيراد JSON بمهمة بلا `id` يفشل كله؛ قيمة تبدأ بـ `=` تُصدَّر في CSV كصيغة.
السبب الجذري: التحقق في الواجهة لا في `AppState`/النموذج؛ `fromJson` يفترض الأنواع.
الحل: `AppState.normalizeName` + رفض المكرر في `addTask/updateTask/addCategory`؛ `TaskItem.maxReminders` يُفرض في `fromJson`؛ قراءة متسامحة `_str/_int` في `models.dart`؛ تحييد `=+-@` في `exportCsv`.
الوقاية: `test/adversarial_test.dart` (19 محاولة) يعمل في CI.
## 2026-09-09 — تباين النص الثانوي وأزرار مملوءة تحت AA
السبب الجذري: `textMuted` فاتح 4.2:1 على الخلفية؛ أبيض على `primary` 3.6:1. الحل: `textMuted=#5F6D5C` (5.1:1)، خلفية `ElevatedButton` = `primaryDark` (5.7:1) في `lib/core/theme.dart`. الوقاية: أرقام التباين موثقة في `docs/DESIGN_AUDIT.md`.
## 2026-09-08 — أرقام الإحصائيات تلتف على هواتف 360dp
العَرَض: «1670» يظهر سطرين في بطاقة الإحصاءات. السبب الجذري: 4 بطاقات بعرض ضيق + ارتفاع سطر عربي 1.6. الحل: `FittedBox` في `StatCard` (`lib/widgets/common.dart`) · commit: eaef149. الوقاية: لقطات 360×640 ضمن توليد لقطات المتجر.
## 2026-09-08 — نقاط التقويم تفيض خارج الخلية
السبب الجذري: `Wrap` بلا حد داخل خلية ثابتة الارتفاع. الحل: صف واحد بحد 4 نقاط + `ClipRect` + ارتفاع سطر صريح (`lib/screens/tabs/calendar_tab.dart`). الوقاية: نفس اللقطات.
## 2026-09-08 — مقبض إعادة الترتيب الافتراضي يتراكب مع أزرار البطاقة على الويب/الأجهزة اللوحية
الحل: `buildDefaultDragHandles: false` + `ReorderableDelayedDragStartListener` لكل بطاقة (`lib/screens/tabs/tasks_tab.dart`).
## 2026-09-08 — شاشة دخول «غير متاح» أمام المراجع بلا خادم
الحل: `setOnboarded` يدخل كزائر مباشرة عندما `!auth.isAvailable` (`lib/state/app_state.dart`). الوقاية: `test/widget_test.dart`.
