# WAQTI — وَقْتِي
## وثيقة التوجيه الرئيسي للبناء (Master Build Directive)

| البند | القيمة |
|---|---|
| الإصدار | 2.0 (إعادة صياغة وتطوير للإصدار 1.0) |
| التاريخ | 2026-08-28 |
| الحالة | معتمَدة — مرجع ملزم للتنفيذ |
| الريبو | daood40/waqti |
| اللغة | عربي أولًا (RTL) + إنجليزي (LTR) |

> **ملاحظة على الإصدار 2.0:** أُعيد ترتيب الوثيقة، وصُحِّح الخلط بين *حالات* المهمة و*عروضها*، وحُدِّدت بنية التكرار (RRULE)، ونموذج Offline-first وحل التعارضات، وأُضيف تتبّع الوقت (بدونه لا يمكن الإجابة على "أين أضيع وقتي؟")، وأُضيفت معايير القبول والقرارات المعمارية والملاحق. سجل التغييرات في الملحق (ز).

---

## الجزء الأول — الرؤية والمبادئ

### 1. الرؤية

**وقتي** نظام شخصي متكامل لإدارة الوقت والمهام والعادات والأهداف والمشاريع والمواعيد والتركيز والإنجاز، بتجربة **سريعة، بسيطة، متوقَّعة**، تعمل دون إنترنت وتتزامن بين Android وiOS وWeb.

ليس To-Do List. هو الإجابة الدائمة على ثمانية أسئلة:

| السؤال | الميزة التي تجيب عنه |
|---|---|
| ماذا أفعل؟ | المهام + الأولويات |
| متى أفعله؟ | المخطط اليومي + التقويم |
| كم بقي؟ | المؤقت + المواعيد النهائية |
| ما الذي أنجزته؟ | Daily Review + الإحصائيات |
| أين أضيع وقتي؟ | تتبّع الوقت + توزيع الوقت |
| ما العادات التي أحافظ عليها؟ | Habit Tracker + Streaks |
| ما أهدافي؟ | الأهداف الهرمية |
| ما أولوياتي؟ | الرئيسية + الأولويات |

### 2. مبادئ المنتج

1. **Local-first:** الجهاز هو مصدر الحقيقة؛ الخادم للمزامنة والنسخ الاحتياطي.
2. **لا احتكاك:** إضافة مهمة في أقل من 3 ثوانٍ من أي شاشة.
3. **قابلية التنبؤ:** كل إجراء له نتيجة واضحة، وكل حذف له Undo.
4. **الخصوصية:** بيانات المستخدم شخصية؛ لا تحليلات سلوكية تُرسل خارج الجهاز إلا بموافقة.
5. **هادئ:** لا إزعاج بالإشعارات؛ التذكيرات ذكية ومحدودة.

### 3. القاعدة الأساسية للتنفيذ

الترتيب الإلزامي: **المعمارية → قاعدة البيانات المحلية والبعيدة → محرك المزامنة → الواجهة → الميزات → الاختبارات → البناء → النشر.**
التفاصيل غير المحددة: قرار هندسي متسق يُسجَّل في `docs/adr/`. المهمة لا تكتمل حتى يعمل التطبيق ويجتاز معايير القبول (§34).

---

## الجزء الثاني — النطاق

### 4. داخل النطاق (v1.0)

المهام، التكرار، التقويم، المخطط اليومي، العادات، التركيز (Pomodoro)، تتبّع الوقت، الأهداف، المشاريع (فردية)، التذكيرات، Daily/Weekly Review، الإحصائيات، الإنجازات (Achievements — موجودة في النموذج الأولي وتُحافَظ عليها)، البحث الشامل، المصادقة، المزامنة، Offline، الاشتراكات، لوحة إدارة أساسية.

### 5. مؤجَّل بقرار

| البند | القرار |
|---|---|
| المشاريع الجماعية (`project_members`) | Phase لاحقة؛ يُبقى الجدول في المخطط معطّلًا |
| مساعد AI | Phase 5؛ يُصمَّم كإضافة اختيارية خلف Feature Flag |
| مواقيت الصلاة ككتل زمنية تلقائية | اختياري في Phase 3، حساب محلي بلا شبكة |
| التقويم الهجري في العرض | Phase 3، عرض فقط |
| استيراد Google/Apple Calendar | Phase لاحقة |

---

## الجزء الثالث — الميزات

### 6. نظام التصميم

- RTL أولًا مع LTR كامل؛ Light / Dark / System؛ Design Tokens فقط (لا قيم خام).
- Premium، نظيف، غير مزدحم؛ مقياس مسافات 4pt؛ Typography عربية عالية الجودة.
- حالات: Skeleton، Empty، Error، Success، Offline Indicator خفيف.
- إتاحة: تباين AA، أهداف لمس ≥ 44px، Dynamic Type، تقليل الحركة.
- **المرجع البصري:** النموذج الأولي HTML الخاص بالمالك هو مرجع التصميم (مطابقة بصرية)، لا مرجع الكود.

### 7. التنقل

Bottom Navigation (هاتف) / Sidebar (Desktop وWeb):
**الرئيسية · المهام · التقويم · العادات · التركيز · الأهداف · الإحصائيات · الإعدادات**

> قرار v2: ثمانية أقسام كثيرة لشريط سفلي. على الهاتف يظهر 5 (الرئيسية، المهام، التقويم، العادات، المزيد) و"المزيد" يضم التركيز والأهداف والإحصائيات والإعدادات. زر "+" عائم لإضافة سريعة من أي شاشة.

### 8. الصفحة الرئيسية (Dashboard اليومي)

التاريخ (+ هجري اختياري)، الوقت، تحية بحسب الوقت، نسبة الإنجاز اليومية، المهام المهمة (Urgent/High أولًا)، الجدول اليومي (Timeline مصغّر)، عادات اليوم، المؤقت (الجلسة الجارية إن وُجدت)، الأهداف النشطة، ملخص اليوم.

### 9. المهام

**الحقول:**
```
id  title  description  priority (low|medium|high|urgent)
status (todo|in_progress|done|archived)
due_date  due_time  duration_minutes  category_id  project_id  goal_id
tags[]  recurrence_id  reminder_at  notes  attachments[]
completed_at  sort_order  created_at  updated_at  deleted_at
```

**تصحيح v2 — الحالات مقابل العروض:**
في v1.0 خُلط بين الاثنين. الحالة الحقيقية للمهمة هي `status` فقط. أما **Inbox / Today / Upcoming / Completed / Archived** فهي **عروض ذكية (Smart Views)** محسوبة:

| العرض | الشرط |
|---|---|
| Inbox | `due_date IS NULL AND status = todo` |
| Today | `due_date = today OR (overdue AND status ≠ done)` |
| Upcoming | `due_date > today` |
| Completed | `status = done` |
| Archived | `status = archived` |

- المهمة الفائتة (Overdue) تظهر في Today بتمييز بصري ولا "تختفي".
- المهام الفرعية (Subtasks): `parent_task_id` بمستوى واحد.
- إعادة الترتيب اليدوي بالسحب داخل القوائم (`sort_order`).

### 10. التكرار

يُخزَّن وفق **RFC 5545 RRULE** في `task_recurrence` (يغطي: كل يوم، كل اثنين، كل 3 أيام، أول يوم من الشهر، آخر جمعة، سنوي، Custom).

**قواعد v2 (كانت غير محددة):**
- النموذج: قاعدة واحدة + **توليد كسول** للتكرارات (Instances) عند العرض، مع تخزين الاستثناءات (`exceptions`) والحالات المكتملة فقط.
- إكمال تكرار = يُسجَّل للتاريخ ذاك فقط؛ التكرار التالي يظهر تلقائيًا.
- تعديل تكرار: خيار "هذا فقط" أو "هذا وما بعده" أو "الكل".
- حذف السلسلة يحفظ سجل المكتمل منها (لأجل الإحصائيات).
- `end_condition`: بلا نهاية / حتى تاريخ / بعد N مرة.

### 11. التقويم

عروض Day / Week / Month، عرض المهام والمواعيد (`calendar_events`) وجلسات التركيز في مكان واحد، إنشاء بالضغط المطوّل وسحب لتغيير الوقت والمدة (Drag & Drop على Web/Tablet؛ على الهاتف بالضغط المطوّل).

### 12. المخطط اليومي (Daily Planner)

Timeline من الاستيقاظ حتى النوم (أوقات قابلة للتخصيص) يعرض كتلًا زمنية:
`05:00 صلاة · 07:00 عمل · 10:00 مهمة …`

- الكتلة الزمنية (`time_block`) قد تُربط بمهمة أو مشروع أو عادة أو تكون حرة.
- تعديل الوقت والمدة بالسحب. اكتشاف التداخل وتنبيه خفيف.
- "خطة الغد" في Daily Review تُنشئ كتل الغد مباشرة.

### 13. العادات (Habit Tracker)

**الإنشاء:** اسم، أيقونة، لون، تكرار (يومي / أيام محددة / N مرات أسبوعيًا)، وقت مفضّل، هدف، Reminder.

**إضافة v2 — نوع العادة:**
- `boolean` (فعلت / لم أفعل)
- `quantitative` (هدف رقمي: 8 أكواب، 30 دقيقة) مع تسجيل تراكمي في اليوم.

**العرض:** Streak الحالي والأطول، Completion Rate (7/30/90 يومًا)، Calendar Heatmap سنوي.

**قواعد الـStreak (كانت غير محددة):** يُحسب وفق أيام العادة المجدولة فقط؛ يوم غير مجدول لا يكسر السلسلة؛ "تخطٍّ مبرَّر" (Skip) اختياري لا يكسر السلسلة ولا يُحتسب إنجازًا؛ التسجيل بأثر رجعي مسموح حتى 7 أيام.

### 14. التركيز (Focus Mode)

Pomodoro: 25/5 · 50/10 · Custom، مع Start / Pause / Resume / Stop، ربط الجلسة بمهمة اختياريًا، حفظ الجلسات في `focus_sessions` وتوليد `time_entries` منها.

**إضافة v2 — الموثوقية:** المؤقت يُحسب من `started_at` لا من عدّاد في الذاكرة (يبقى صحيحًا بعد قتل التطبيق)؛ إشعار محلي عند نهاية الجلسة؛ Android: Foreground Service؛ iOS: Local Notification + Live Activity إن أمكن. وضع "عدم الإزعاج" اختياري.

### 15. تتبّع الوقت (إضافة v2)

بدونه لا يمكن الإجابة على "كم ساعة عملت؟" و"أين أضيع وقتي؟".
- `time_entries`: بداية، نهاية، مرتبطة بمهمة/مشروع/فئة/عادة أو "غير مصنّف".
- المصادر: جلسات التركيز تلقائيًا، أو تسجيل يدوي، أو من كتل المخطط اليومي بعد تأكيدها.
- الفئات الافتراضية: عمل، دراسة، عبادة، صحة، عائلة، ترفيه، غير مصنّف.

### 16. الأهداف

```
id  title  description  parent_goal_id  horizon (yearly|quarterly|monthly|weekly)
deadline  priority  progress_mode (manual|milestones|tasks)  progress (0-100)
status (active|paused|done|dropped)
```

- هرمية: سنوي → شهري → أسبوعي → مهام يومية (`tasks.goal_id`).
- **قاعدة v2 — حساب التقدم:** `manual` يدوي؛ `milestones` = نسبة المعالم المنجزة؛ `tasks` = نسبة المهام المرتبطة المنجزة. تقدم الهدف الأب = متوسط أبنائه (قابل للتجاوز يدويًا).

### 17. المشاريع

مهام، معالم، مواعيد نهائية، تقدم، ملاحظات، ملفات. فردية في v1.0 (انظر §5).

### 18. التذكيرات والإشعارات

| النوع | القناة | ملاحظة |
|---|---|---|
| Task Reminder | إشعار محلي | يعمل Offline |
| Habit Reminder | إشعار محلي | بحسب أيام العادة فقط |
| Goal Deadline | إشعار محلي | قبل 7 / 3 / 1 يوم |
| Focus Reminder | إشعار محلي | نهاية الجلسة/الاستراحة |
| Daily Planning | إشعار محلي | صباحًا، وقت قابل للتخصيص |
| Daily Review | إشعار محلي | مساءً، وقت قابل للتخصيص |
| Sync / الحساب | Push | فقط ما يتعلق بالخادم |

- **قرار v2:** كل التذكيرات الشخصية **محلية** (لا تعتمد على الخادم)، وتُعاد جدولتها بعد إعادة تشغيل الجهاز. حد أقصى يومي للإشعارات قابل للضبط. Snooze: 10 د / 1 س / الغد.

### 19. Daily Review

نهاية اليوم: ماذا أنجزت؟ (يُملأ تلقائيًا) · ما لم يُنجز؟ (مع خيار ترحيل للغد) · كم ساعة عمل؟ وكم تركيز؟ (من `time_entries`) · ما أكثر ما أضاع وقتك؟ · أهم إنجاز؟ · خطة الغد (تُنشئ كتل الغد). تقييم اليوم 1–5. يُحفظ في `daily_reviews`.

### 20. Weekly Review

نسبة الإنجاز، المهام، العادات، التركيز، الأهداف، الوقت، أفضل يوم، أسوأ يوم، اتجاه التحسن مقارنة بالأسبوع السابق. يُحفظ في `weekly_reviews`.

### 21. الإحصائيات

Charts: Tasks Completed، Focus Time، Habit Completion، Goal Progress، Time Distribution (من `time_entries`). تقارير Daily / Weekly / Monthly / Yearly. **تُحسب محليًا** على الجهاز (لا حاجة للاتصال).

### 22. الإنجازات (Achievements)

موجودة في النموذج الأولي وتُحافَظ عليها: شارات لأول مهمة، Streak 7/30/100، 10 ساعات تركيز، إلخ. القواعد في ملف إعداد (`achievements.json`) لا في الكود.

### 23. البحث الشامل

Tasks، Projects، Habits، Goals، Notes. محلي عبر SQLite FTS5؛ نتائج فورية أثناء الكتابة؛ فلاتر بالنوع والتاريخ.

### 24. مساعد AI (Phase 5، اختياري)

يستطيع: ترتيب المهام، اقتراح جدول، اكتشاف التعارضات، تقسيم الهدف إلى خطوات، اقتراح وقت مناسب، تحليل الإنتاجية، اقتراح تحسينات.

**قواعد v2:**
- كل اقتراح يُعرض كـ**معاينة تتطلب موافقة**؛ AI لا يكتب في القاعدة مباشرة.
- يُرسل للنموذج **الحد الأدنى** من البيانات (عناوين ومواعيد؛ لا ملاحظات إلا بموافقة).
- المفاتيح على الخادم فقط (Edge Function). Rate Limiting وفق الخطة. تسجيل الطلبات في `ai_requests`.
- خلف Feature Flag ويعمل التطبيق كاملًا بدونه.

---

## الجزء الرابع — البنية التقنية

### 25. القرارات المعمارية (ADRs)

| # | القرار | البديل المرفوض | السبب |
|---|---|---|---|
| ADR-001 | Flutter (Android/iOS/Web)، والبناء الحالي للتحويل من النموذج الأولي هو الأساس؛ نسخة React مؤرشفة في `archive/react-version` | البدء من جديد | حفظ العمل المنجز والمطابقة البصرية |
| ADR-002 | Local-first: SQLite (Drift) مصدر الحقيقة + Supabase للمزامنة | Supabase أولًا مع Cache | Offline حقيقي وسرعة |
| ADR-003 | Clean Architecture + Feature-based + Riverpod + Repository + DI | Bloc/GetX | قابلية اختبار |
| ADR-004 | التكرار بـ RRULE + توليد كسول | توليد مسبق لكل التكرارات | لا انفجار في الصفوف |
| ADR-005 | التذكيرات محلية بالكامل | Push من الخادم | تعمل Offline وبلا تكلفة |
| ADR-006 | حل التعارضات: LWW على مستوى الحقل + Tombstones؛ السجلات الإضافية (logs/entries) بالدمج (Union) | LWW على مستوى الصف | لا فقدان لإكمالات العادات |
| ADR-007 | الإحصائيات تُحسب على الجهاز | على الخادم | Offline + خصوصية |

### 26. هيكل المشروع

```
lib/
  core/       (theme/tokens, i18n, routing, db, sync, notifications, di, utils)
  features/
    auth/ home/ tasks/ recurrence/ calendar/ planner/ habits/ focus/
    time_tracking/ goals/ projects/ reviews/ stats/ achievements/
    search/ settings/ subscriptions/ ai/(flagged) admin/
      data/ domain/ presentation/
  shared/
supabase/   migrations/ functions/ policies/ seed/
docs/       adr/ ARCHITECTURE.md DATABASE.md SYNC.md ...
test/ integration_test/
```

### 27. قاعدة البيانات

PostgreSQL (Supabase) للبعيدة، SQLite (Drift) للمحلية **بنفس المخطط**. UUID (يُولَّد على الجهاز)، `created_at/updated_at` بـ UTC، `deleted_at` (Tombstone)، `device_id`، `version`. RLS على كل جدول (`user_id = auth.uid()`).

| المجال | الجداول |
|---|---|
| الحسابات | `users`, `profiles`, `devices`, `settings` |
| المهام | `tasks`, `task_recurrence`, `recurrence_exceptions`, `categories`, `tags`, `task_tags`, `attachments`, `notes` |
| المشاريع | `projects`, `milestones`, `project_members` (معطّل) |
| العادات | `habits`, `habit_logs` |
| الوقت | `focus_sessions`, `time_entries`, `time_blocks`, `calendar_events` |
| الأهداف | `goals`, `goal_milestones` |
| المراجعات | `daily_reviews`, `weekly_reviews` |
| الإنجازات | `achievements`, `user_achievements` |
| التنبيهات | `reminders`, `notifications` |
| الاشتراكات | `plans`, `subscriptions`, `payments` |
| النظام | `sync_queue` (محلي فقط), `ai_requests`, `audit_logs` |

> إضافات v2: `devices`, `recurrence_exceptions`, `categories`, `tags`, `task_tags`, `time_entries`, `time_blocks`, `achievements`, `user_achievements`, `plans`, `payments`, `sync_queue`. حُذف `analytics` (تُحسب محليًا).

### 28. محرك المزامنة (SYNC.md)

- كل تغيير محلي يدخل `sync_queue` ويُرفع عند الاتصال؛ السحب بـ `updated_at > last_sync_at` لكل جدول.
- التعارض: مقارنة على مستوى الحقل بـ `updated_at`؛ الحذف يفوز إذا كان الأحدث (Tombstone)؛ `habit_logs` و`time_entries` و`focus_sessions` تُدمج بلا حذف.
- Idempotent: إعادة الإرسال آمنة. مؤشر حالة المزامنة في الإعدادات مع "مزامنة الآن" ويوميات أخطاء.
- تسجيل الخروج يحذف البيانات المحلية بعد التأكد من رفع الطابور.

### 29. المصادقة والحساب

Email + Password، Google (+ Apple على iOS إلزامي)، Reset، Verification، Logout، Delete Account (حذف الخادم + المحلي، فترة سماح 30 يومًا). **الاستخدام بلا حساب مسموح** (Local-only) مع دعوة للحساب عند الحاجة للمزامنة.

### 30. الخصوصية والأمان

RLS، تشفير في النقل والسكون، Secure Storage للـTokens، Access Control، Audit Logs للإجراءات الحساسة، لا أسرار في الكود، تشفير قاعدة SQLite المحلية (SQLCipher) اختياري بقفل بيومتري، تصدير بيانات المستخدم (JSON/CSV) — حق ملكية البيانات.

### 31. الأداء

Pagination، Caching، Lazy Loading، استعلامات مفهرسة، صور مضغوطة، Riverpod بانتقائية إعادة البناء.
**أهداف:** فتح بارد < 1.5s، إضافة مهمة وظهورها < 100ms، البحث < 100ms، عرض الشهر < 200ms لـ 5,000 مهمة.

### 32. الاشتراكات

الخطط من `plans` (Backend) بلا أسعار في الكود؛ الحدود في `plans.limits` (JSON)؛ Free/Premium كما في النموذج الأولي؛ مزود الدفع خلف واجهة `PaymentProvider` (RevenueCat مرشح للجوال + Stripe للويب — يُثبَّت في ADR).

### 33. لوحة الإدارة

Users، Subscriptions، Analytics (مجمّعة بلا بيانات شخصية)، Reports، Support، System Health. واجهة ويب مستقلة بأدوار `admin | support`.

---

## الجزء الخامس — الجودة والتسليم

### 34. معايير القبول (Definition of Done)

الميزة منجزة فقط إذا: كود بلا `TODO` · اختبارات تنجح في CI · تعمل Offline ثم تتزامن · RTL وLTR وDark Mode مفحوصة · Mobile وTablet وDesktop/Web · Undo/Confirmation حيث يلزم · بلا Dummy data · موثقة في `PROJECT_STATUS.md`.

### 35. الاختبارات

Unit، Integration، Widget، E2E. تغطية ≥ 80% لـ `domain/data`، ≥ 60% لـ `presentation`.
إلزامي: Tasks، **Recurrence (مجموعة حالات RRULE + الاستثناءات + المناطق الزمنية + التوقيت الصيفي)**، Calendar، Habits (قواعد Streak)، Focus (استمرار المؤقت بعد قتل التطبيق)، Goals (حساب التقدم)، **Sync (تعارضات، Tombstones، انقطاع أثناء الرفع)**، Notifications، Auth.

### 36. الإطلاق

Android، iOS، Web. Production config، Environment variables (الملحق ب)، Logging، Crash Reporting (Sentry)، Analytics مجمّعة اختيارية بموافقة، CI/CD (الحالي: Flutter APK + Flutter Web على GitHub Pages — يُحافَظ عليه)، Build scripts، Fastlane للمتاجر.

### 37. الممنوعات

Fake Features، Dummy Buttons، Fake Backend، Mock Production Data، Broken Navigation، `TODO` بدل التنفيذ، قيم خام خارج الـTokens، مكوّنات مكررة، تذكيرات تعتمد على الخادم.

### 38. التوثيق

`README.md`, `ARCHITECTURE.md`, `DATABASE.md`, `SYNC.md`, `SECURITY.md`, `DEPLOYMENT.md`, `TESTING.md`, `CONTRIBUTING.md`, `docs/adr/*`, `PROJECT_STATUS.md`, `ROADMAP.md`.

### 39. مراحل التنفيذ

| المرحلة | المخرجات |
|---|---|
| 0 | المعمارية، Tokens، Drift Schema، CI، ADRs |
| 1 | المهام + التكرار + الفئات/الوسوم + البحث + الإشعارات المحلية (Local-only كامل) |
| 2 | العادات + التركيز + تتبّع الوقت + الإنجازات |
| 3 | التقويم + المخطط اليومي + الأهداف + المشاريع + المراجعات + الإحصائيات |
| 4 | المصادقة + المزامنة + الاشتراكات + الإدارة |
| 5 | AI (Flag) + استيراد التقويمات + المشاريع الجماعية |

---

## الملاحق

### (أ) الحالات الموحدة
```
task.status:   todo | in_progress | done | archived
goal.status:   active | paused | done | dropped
habit_log:     done | skipped | partial(value)
focus_session: running | paused | completed | abandoned
sync_queue:    pending | in_flight | failed
```

### (ب) متغيرات البيئة
```
SUPABASE_URL=  SUPABASE_ANON_KEY=  SUPABASE_SERVICE_ROLE_KEY=(خادم فقط)
SENTRY_DSN=  APP_ENV=(dev|staging|prod)
PAYMENT_PROVIDER=  REVENUECAT_KEY=  STRIPE_SECRET=(خادم فقط)
AI_PROVIDER=  AI_API_KEY=(خادم فقط)  FEATURE_AI=(true|false)
```

### (ج) ما يحتاج Credentials خارجية
Google/Apple Sign-In، Apple Developer + Google Play، مزود الدفع، Sentry، مزود AI (لاحقًا).

### (د) أمثلة RRULE
```
كل يوم:               FREQ=DAILY
كل اثنين:              FREQ=WEEKLY;BYDAY=MO
كل 3 أيام:             FREQ=DAILY;INTERVAL=3
أول يوم من الشهر:      FREQ=MONTHLY;BYMONTHDAY=1
آخر جمعة من الشهر:     FREQ=MONTHLY;BYDAY=-1FR
```

### (هـ) قواعد Undo
الحذف: Soft delete + Snackbar "تراجع" 5 ثوانٍ قبل التثبيت. الإكمال: قابل للتراجع من القائمة. حذف مشروع/هدف: Confirmation + Undo.

### (و) رسالة مرافقة لجلسة Claude Code
> الملف `docs/WAQTI_MASTER_DIRECTIVE_v2.md` يحل محل التوجيه السابق. **لا تبدأ من جديد** ولا تلمس `archive/react-version` ولا سير عمل البناء الحالي. اقرأ `PROJECT_STATUS.md` ثم اعمل Gap Analysis (موجود يُبقى / موجود يُعدَّل / جديد)، حدّث `ARCHITECTURE.md` و`ROADMAP.md` وأنشئ `docs/adr/` و`SYNC.md`، ثم أكمل من المرحلة الحالية. عند التعارض مع كود قائم: أصغر تعديل يحقق المتطلب مع توثيق السبب. حدّث `PROJECT_STATUS.md` نهاية الجلسة.

### (ز) سجل التغييرات عن v1.0
| النوع | التغيير |
|---|---|
| تصحيح | فصل حالات المهمة عن العروض الذكية (Inbox/Today/… كانت مدرجة كحالات) |
| تصحيح | 8 أقسام في Bottom Navigation → 5 + "المزيد" |
| تصحيح | حذف جدول `analytics` (تُحسب محليًا) وإضافة الجداول الناقصة |
| قرار | Local-first بـ SQLite/Drift كمصدر حقيقة، وتذكيرات محلية بالكامل |
| قرار | نموذج التكرار RRULE + استثناءات + توليد كسول |
| قرار | حل التعارضات بمستوى الحقل + دمج للسجلات |
| قرار | استخدام بلا حساب مسموح؛ المشاريع الجماعية وAI مؤجلان خلف Flags |
| إضافة | تتبّع الوقت، كتل المخطط اليومي، نوع العادة الكمي، قواعد Streak، حساب تقدم الأهداف |
| إضافة | الإنجازات (من النموذج الأولي)، تصدير البيانات، موثوقية مؤقت التركيز |
| إضافة | DoD، أهداف أداء، تغطية اختبار، الملاحق |
