# memory/ARCHITECTURE.md   (آخر تحديث: 2026-09-09)
## الطبقات الفعلية اليوم
UI (`lib/screens`, `lib/widgets`) → State (`AppState` واحد، Provider) → Gateways (`lib/core/auth/*`, `lib/core/cloud_backup_service.dart`) → Data source (`shared_preferences` محليًا، Supabase سحابيًا عند التفعيل).
## المجلدات
`lib/core/` (config, l10n, theme, tokens, search, notifications, export) · `lib/models/` · `lib/state/` · `lib/screens/tabs/` (6 تبويبات) · `lib/widgets/` · `supabase/migrations/` · `test/`.
## تدفّق البيانات
كل تغيير يمر بـ `AppState._commit()`: يحفظ محليًا فورًا، يُخطر الواجهة، ويجدول رفعًا سحابيًا مؤجَّلًا (3 ث) إن وُجد حساب. عند العودة للمقدمة `onAppResumed` يزامن (LWW على مستوى السجل الكامل بطابع `updated_at`). الإشعارات تُعاد جدولتها بعد كل تغيير (`NotificationService.bind`).
## قواعد ممنوعة
- لا استدعاء Supabase من الواجهة؛ فقط عبر البوابات.
- كل نص ظاهر من `lib/core/l10n.dart`؛ القيم البصرية من `lib/core/tokens.dart` و`WaqtiColors`.
- `EdgeInsetsDirectional`/`AlignmentDirectional` فقط.
- لا أسرار في الشيفرة؛ الصلاحيات في RLS على الخادم.
## ملاحظة صدق
ADR-002/003/004/006 (Drift، Riverpod، RRULE، LWW حقلي) معتمدة في التوجيه لكن **غير منفَّذة**؛ الشيفرة الحالية Provider + shared_preferences + 5 أنواع تكرار + LWW على مستوى السجل. لا تفترض وجودها.
