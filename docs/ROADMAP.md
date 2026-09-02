<div dir="rtl">

# ROADMAP — خارطة طريق وقتي (وفق توجيه التحويل v3)

> المراجع: `WAQTI_TRANSFORMATION_DIRECTIVE_v3.md` (المراحل) +
> `WAQTI_MASTER_DIRECTIVE_v2.md` (المواصفات التفصيلية) + `AUDIT.md` (الواقع).
> القاعدة الثابتة: التطبيق يعمل وCI أخضر بعد **كل** خطوة.

## الموقع الحالي

**Phase 0 مكتملة** (هذه الجلسة) و**Phase 4 قيد التنفيذ**.
المراحل 1–3 لها أساس قائم يُستكمل تدريجيًا لا من الصفر.

| Phase | المحتوى | الحالة |
|---|---|---|
| **0 · Audit** | الفحوص الـ18 (`AUDIT.md`) | ✅ هذه الجلسة |
| **1 · Architecture** | ADRs ✅، ARCHITECTURE/SYNC ✅؛ يتبقى تنفيذ Drift+Riverpod (يُنفَّذ مع 5) | 🟡 أساس قائم |
| **2 · Design System** | الألوان/الخط/المكونات ✅؛ يتبقى رموز مسافات 4pt وسلم Typography مسمى ولون Urgent | 🟡 أساس قائم |
| **3 · Navigation** | 6 تبويبات + زر + مركزي ✅؛ يتحول إلى 5+"المزيد" عند إضافة أقسام جديدة (v2 §7) | 🟡 أساس قائم |
| **4 · Dashboard (Today-first)** | تحية/تاريخ، مهام اليوم مرتبة بالأولوية، Urgent، شريط المتأخرات، توحيد البحث | ⏳ **هذه الجلسة** |
| **5 · Tasks** | Drift + فصل Tasks/Habits + due date/time + Subtasks + Tags + Notes حقل + Progressive Disclosure + Quick Add متعدد الأنواع | ☐ |
| **6 · Calendar + My Day** | Week/Day/Agenda + Time Blocks + Events | ☐ |
| **7 · Habits** | عادات كمية ✅، Skip ✅، درجة عادة مرنة + سلسلة متسامحة ✅، إقلاع ✅؛ يتبقى تسجيل رجعي بواجهة مخصصة | 🟢 معظمه منجز |
| **8 · Reminders** | إشعارات محلية فعلية ✅ (3 تذكيرات/عادة، ساعات هدوء، ملخص صباحي/مسائي)؛ يتبقى Snooze | 🟢 معظمه منجز |
| **9 · Statistics** | اتجاهات إنتاجية، Overdue metrics، مراجعة يومية/أسبوعية | ☐ |
| **10 · Search** | FTS5 عبر Tasks/Habits/Events/Notes | ☐ |
| **11 · AI** | مساعد إنتاجية خلف Flag، معاينة بموافقة، مفاتيح على الخادم | ☐ |
| **12 · Offline** | قائم بطبيعته اليوم؛ يُثبَّت رسميًا فوق Drift | 🟡 |
| **13 · Sync** | Supabase وفق `SYNC.md` (queue/LWW حقلي/Tombstones/دمج) | ☐ |
| **14 · Security** | مصادقة حقيقية، RLS، Delete Account، خطط من الخادم، SQLCipher اختياري | ☐ |
| **15 · Testing** | رفع التغطية لأهداف v2 §35 + E2E متصفحي مؤتمت في CI | ☐ متدرجة مع كل مرحلة |
| **16 · Performance** | استعلامات مفهرسة، أهداف v2 §31، فحص أول تحميل الويب | ☐ |
| **17 · Final Polish** | الـ Final Audit بأدوار (Product/UX/UI/Eng/QA/Sec/Perf) وصقل ختامي | ☐ |

## اعتماديات حاكمة

- 5 قبل 6/7/8/10 (النموذج الجديد أساس الجميع).
- 13 قبل 14 الكاملة (لا Delete Account حقيقي بلا حساب حقيقي).
- 15 لا تُؤجل للنهاية: كل مرحلة تسلّم اختباراتها.

## المطلوب من المالك لاحقًا

لا شيء حتى Phase 13. عندها: مشروع Supabase، Google/Apple Sign-In،
مزود دفع، Sentry (مفصلة في `PROJECT_STATUS.md`).

</div>
