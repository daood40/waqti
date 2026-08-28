<div dir="rtl">

# ROADMAP — خارطة طريق وقتي

> المرجع: `WAQTI_MASTER_DIRECTIVE_v2.md` §39 · الحالة التفصيلية في `../PROJECT_STATUS.md`

## الموقع الحالي: نهاية "ما قبل المرحلة 0"

أُنجز: تحويل النموذج الأولي إلى Flutter عامل (Android/iOS/Web) بمطابقة بصرية، CI كامل (APK + Pages)، أرشفة نسخة React، ووثائق المعمارية والقرارات (هذه الجلسة).

## المراحل

### المرحلة 0 — الأساس ⏳ (جارية)
- [x] ADRs 001–007 موثقة في `adr/`
- [x] ARCHITECTURE.md وSYNC.md وPROJECT_STATUS.md
- [x] CI: بناء APK + نشر Pages مع كل push
- [x] Tokens أولية (`WaqtiColors` ThemeExtension)
- [ ] توسيع Design Tokens (مسافات 4pt، Typography، أنصاف الأقطار)
- [ ] Drift Schema بجداول §27 + طبقة Repository + ترحيل بيانات `waqti.v1`
- [ ] هيكلة `features/` وإدخال Riverpod تدريجياً

### المرحلة 1 — المهام Local-only كاملة
- [ ] فصل `status` عن سجل الإكمال + Smart Views (Inbox/Today/Upcoming/Completed/Archived)
- [ ] مهام فرعية (مستوى واحد)، وسوم، ملاحظات
- [ ] التكرار RRULE + استثناءات + توليد كسول + محوّل من النموذج القديم
- [ ] إشعارات محلية فعلية (تُعاد جدولتها بعد إعادة التشغيل)
- [ ] بحث شامل SQLite FTS5
- [ ] تنقل 5 تبويبات + "المزيد" + زر "+" عائم (إضافة < 3 ثوانٍ)

### المرحلة 2 — العادات والتركيز والوقت
- [ ] عادات كمية (`quantitative`) + Skip مبرَّر + تسجيل رجعي 7 أيام
- [ ] قواعد Streak وفق الأيام المجدولة فقط
- [ ] Focus/Pomodoro موثوق (حساب من `started_at`، Foreground Service)
- [ ] تتبّع الوقت `time_entries` + الفئات الافتراضية
- [ ] نقل قواعد الإنجازات إلى `achievements.json`

### المرحلة 3 — التقويم والتخطيط والأهداف
- [ ] تقويم Day/Week/Month موحّد (مهام + مواعيد + جلسات)
- [ ] المخطط اليومي `time_blocks` + اكتشاف التداخل
- [ ] الأهداف الهرمية بحساب تقدم §16 + المشاريع الفردية
- [ ] Daily/Weekly Review + خطة الغد
- [ ] اختياري: مواقيت الصلاة محلياً، عرض هجري

### المرحلة 4 — الحساب والمزامنة والاشتراكات
- [ ] Supabase: مخطط §27 + RLS + مصادقة (Email/Google/Apple)
- [ ] محرك المزامنة وفق `SYNC.md` (sync_queue، LWW حقلي، Tombstones، دمج)
- [ ] اشتراكات فعلية من `plans` خلف `PaymentProvider`
- [ ] لوحة إدارة ويب بأدوار admin/support
- 🔑 تتطلب Credentials من المالك (ملحق ج)

### المرحلة 5 — الإضافات
- [ ] مساعد AI خلف `FEATURE_AI` (معاينة بموافقة، مفاتيح على الخادم)
- [ ] استيراد Google/Apple Calendar
- [ ] المشاريع الجماعية (`project_members`)

## معيار الانتقال بين المراحل

لا تُفتح مرحلة قبل استيفاء Definition of Done (§34) لمكونات المرحلة السابقة: اختبارات خضراء في CI، عمل Offline، فحص RTL/LTR/Dark، لا Dummy data، توثيق في PROJECT_STATUS.

</div>
