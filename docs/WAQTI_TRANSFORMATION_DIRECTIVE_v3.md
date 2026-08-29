# WAQTI — Master Professional Transformation Directive (v3)

> وردت من المالك بتاريخ 2026-08-28. تُقرأ مع `WAQTI_MASTER_DIRECTIVE_v2.md`؛
> عند التعارض يُقدَّم الأحدث (v3). الترجمة التنفيذية في `AUDIT.md` و`ROADMAP.md`.

## المهمة الرئيسية

تحويل المشروع الحالي (https://daood40.github.io/waqti/) إلى تطبيق
Productivity / Time Management احترافي حقيقي Production-Ready — ليس مجرد
To-Do List جميلة، بل نظام متكامل لإدارة: الوقت، المهام، العادات، التخطيط،
التقويم، التذكيرات، الإنجاز، المراجعة، الإنتاجية.

## النتيجة المطلوبة

Professional · Simple · Fast · Beautiful · Calm · Useful · Reliable ·
Scalable · Responsive · Accessible · Offline-capable where appropriate.

## القاعدة الأساسية

لا نبدأ بالكود:
**DISCOVER → AUDIT → PRODUCT DESIGN → UX → ARCHITECTURE → DATA MODEL →
DESIGN SYSTEM → IMPLEMENTATION → TESTING → SECURITY → PERFORMANCE →
FINAL AUDIT**

## فلسفة المنتج

وقتي يجيب المستخدم بسرعة عن: ماذا أفعل الآن؟ ما التالي؟ ما الذي تأخر؟
ما نسبة إنجازي؟ على ماذا أركز؟ كيف كان يومي/أسبوعي؟

## المتطلبات الوظيفية (ملخص ملزم)

- **Home/Today**: أولوية اليوم — التاريخ/الوقت/التحية، المهام الحالية
  والقادمة، الأولويات، نسبة الإنجاز، العادات، الأحداث، التذكيرات.
- **My Day**: Timeline أو Time Blocks أو صباح/ظهر/مساء — يُختار بعد UX Audit.
- **Task System**: Title, Description, Priority (Low/Medium/High/**Urgent**),
  Due Date/Time, Category, Tags, Reminder, Repeat, Subtasks, Notes, Status,
  timestamps.
- **Quick Add**: زر + → Task / Habit / Event / Note؛ الإضافة سريعة دائمًا.
- **Progressive Disclosure**: الأساسي أولًا ثم Advanced.
- **Recurring**: Daily/Weekly/Monthly/Custom مع معالجة حدود الشهور
  وعطلات الأسبوع والمناطق الزمنية.
- **Calendar**: Month/Week/Day/Agenda بجودة هاتف ممتازة.
- **Reminders**: Local + Push + Recurring + Snooze + Dismiss (معماريًا).
- **Habits**: Name, Frequency, Goal, Reminder, Streak صحيح (Missed/Pause/
  Skip/TZ — لا عدّاد وهمي), History, Progress, Statistics.
- **Statistics**: مفيدة فقط — كل Chart يقدم معلومة.
- **Search**: Tasks + Habits + Events + Notes.
- **Categories** قابلة للتخصيص. **Notes** بسيطة (ليست Notion).
- **AI**: Productivity Assistant لا Chatbot، بلا تعديلات حساسة دون تأكيد.
- **Navigation**: الرئيسية · المهام · التقويم · العادات · الإحصائيات ·
  المزيد + إنشاء سريع دائم.

## المتطلبات غير الوظيفية

- **Design System** كامل (Typography/Colors/Spacing/Components/States).
- لغة بصرية هادئة نظيفة حديثة Premium — بلا ازدحام أو ألوان كثيرة أو
  Animations عديمة الفائدة.
- **RTL أولًا** (اختبار التنقل والتقويم والأرقام والرسوم والنماذج)،
  **Dark Mode حقيقي**، **Accessibility** (Keyboard/Focus/Contrast/ARIA/
  Touch ≥ targets/Screen readers).
- **Offline First** (قراءة/إنشاء/تعديل/إكمال/حذف ثم مزامنة) و**Sync**
  يعالج Duplicates/Conflicts/Lost updates/Out-of-order/Retry.
- **Time zones** صحيحة في كل حسابات الوقت.
- **Data Model** مفصول: Users, Tasks, Subtasks, Habits, HabitLogs, Events,
  Reminders, Categories, Tags, Notes, Notifications, Statistics, AIActions,
  SyncState.
- **Security/Privacy**: أدنى بيانات، Export/Delete/Clear، لا أسرار في الكود.
- **Performance**: Dashboard/Calendar/List/Search/Stats/OfflineDB/Sync.
- **Error/Empty/Loading/Success/Retry/Confirmation** في كل ميزة.

## قاعدة UX

كل شاشة تجيب: ماذا يحدث الآن؟ ما الذي يجب أن أفعله؟ ما أهم Action؟

## المخرجات قبل التطوير (18)

Product/UX/UI/Technical/Architecture/DataModel/Security/Performance Audits،
Missing Features، Technical Debt، Skills Found/Used، Proposed Architecture،
Design System، Roadmap، Testing Plan، Risks، Definition of Done —
**منجزة في `docs/AUDIT.md`**.

## Definition of Done

المنتج النهائي لا يبدو كتطبيق To-Do مبتدئ؛ يبدو كمنتج Productivity حقيقي:
Professional, Fast, Simple, Stable, Scalable, Beautiful, Reliable.
