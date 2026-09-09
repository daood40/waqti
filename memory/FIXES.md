# memory/FIXES.md   (الأحدث في الأعلى)
## 2026-09-08 — أرقام الإحصائيات تلتف على هواتف 360dp
العَرَض: «1670» يظهر سطرين في بطاقة الإحصاءات. السبب الجذري: 4 بطاقات بعرض ضيق + ارتفاع سطر عربي 1.6. الحل: `FittedBox` في `StatCard` (`lib/widgets/common.dart`) · commit: eaef149. الوقاية: لقطات 360×640 ضمن توليد لقطات المتجر.
## 2026-09-08 — نقاط التقويم تفيض خارج الخلية
السبب الجذري: `Wrap` بلا حد داخل خلية ثابتة الارتفاع. الحل: صف واحد بحد 4 نقاط + `ClipRect` + ارتفاع سطر صريح (`lib/screens/tabs/calendar_tab.dart`). الوقاية: نفس اللقطات.
## 2026-09-08 — مقبض إعادة الترتيب الافتراضي يتراكب مع أزرار البطاقة على الويب/الأجهزة اللوحية
الحل: `buildDefaultDragHandles: false` + `ReorderableDelayedDragStartListener` لكل بطاقة (`lib/screens/tabs/tasks_tab.dart`).
## 2026-09-08 — شاشة دخول «غير متاح» أمام المراجع بلا خادم
الحل: `setOnboarded` يدخل كزائر مباشرة عندما `!auth.isAvailable` (`lib/state/app_state.dart`). الوقاية: `test/widget_test.dart`.
