<div dir="rtl">

# ARCHITECTURE — معمارية وقتي

> المرجع الملزم: `WAQTI_MASTER_DIRECTIVE_v2.md` (§25–§28) · القرارات المفصلة في `adr/`

## 1. المعمارية الحالية (كما هي اليوم)

```
lib/
├── main.dart                    # MaterialApp + التوطين + تحميل الحالة
├── core/
│   ├── l10n.dart                # نصوص عربي/إنجليزي (حقول ثابتة الأنواع)
│   ├── theme.dart               # ThemeData فاتح/داكن + WaqtiColors (ThemeExtension)
│   └── app_info.dart
├── models/models.dart           # TaskItem, Recurrence, TaskCategory, UserProfile, DateKey
├── state/app_state.dart         # ChangeNotifier مركزي + حفظ JSON في shared_preferences
├── screens/                     # auth, shell (تنقل سفلي), subscription, tabs/*
└── widgets/                     # بطاقات، محررات، رسوم بيانية، خريطة حرارية
```

- **إدارة الحالة**: Provider فوق `AppState` واحد (ChangeNotifier).
- **التخزين**: مفتاح واحد `waqti.v1` في `shared_preferences` يحوي كل شيء JSON.
- **الاختبارات**: 27 اختباراً (نماذج، حالة، واجهة).

هذه المعمارية صالحة تماماً لحجم الميزات الحالي، وهي **نقطة البداية** لا الهدف النهائي.

## 2. المعمارية الهدف (التوجيه §26، ADR-002/003)

```
lib/
├── core/        # tokens، i18n، routing، db (Drift)، sync، notifications، di، utils
├── features/    # لكل ميزة: data/ domain/ presentation/
│   ├── auth/ home/ tasks/ recurrence/ calendar/ planner/ habits/ focus/
│   ├── time_tracking/ goals/ projects/ reviews/ stats/ achievements/
│   └── search/ settings/ subscriptions/ ai(flagged)/ admin/
└── shared/      # مكوّنات واجهة مشتركة
supabase/        # migrations/ functions/ policies/ seed/
```

- **Local-first**: SQLite (Drift) مصدر الحقيقة على الجهاز؛ Supabase للمزامنة والنسخ الاحتياطي (ADR-002).
- **Clean Architecture + Riverpod + Repository + DI** (ADR-003).
- **التكرار**: RRULE + استثناءات + توليد كسول (ADR-004) — تفاصيل §10.
- **المزامنة**: `sync_queue` محلي، LWW على مستوى الحقل، Tombstones، دمج للسجلات (ADR-006) — التصميم الكامل في `SYNC.md`.
- **التذكيرات محلية بالكامل** (ADR-005) و**الإحصائيات تُحسب على الجهاز** (ADR-007).

## 3. مسار الانتقال (من الحالي إلى الهدف)

القاعدة: **أصغر تعديل يحقق المتطلب، والتطبيق يعمل بعد كل خطوة.**

| خطوة | التغيير | ما يبقى ثابتاً |
|---|---|---|
| 1 | إدخال Drift بجداول §27 مع طبقة Repository؛ ترحيل بيانات `waqti.v1` القديمة عند أول تشغيل | الواجهة والشاشات كما هي |
| 2 | تفكيك `AppState` إلى مزودات Riverpod لكل ميزة تدريجياً (مهام ← عادات ← إعدادات) | العقود العامة للشاشات |
| 3 | استبدال نموذج التكرار الداخلي بـ RRULE مع محوّل من الأنواع الخمسة القديمة | بيانات المستخدم (تُرحَّل) |
| 4 | نقل الشاشات إلى `features/*/presentation` ملفاً ملفاً | السلوك المرئي (مطابقة النموذج) |
| 5 | إضافة الميزات الجديدة (مراحل §39) فوق الأساس الجديد | — |

## 4. قواعد عامة

- لا قيم خام في الواجهة: الألوان/المسافات من `WaqtiColors` وTokens (تُوسَّع في المرحلة 0).
- كل ميزة جديدة: اختبارات domain/data ≥ 80% (§35) قبل الدمج.
- أي قرار غير محدد في التوجيه → ADR جديد في `docs/adr/` بنفس القالب.

</div>
