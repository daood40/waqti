<div dir="rtl">

# ADR-003 — Clean Architecture + Feature-based + Riverpod + Repository + DI

**الحالة:** معتمد (التوجيه v2 §25) — التنفيذ تدريجي من المرحلة 0

## السياق
الحالة اليوم: `AppState` واحد (ChangeNotifier/Provider) يكفي للحجم الحالي لكنه سيصبح عنق زجاجة مع 17 ميزة و30+ جدولًا.

## القرار
هيكلة `lib/features/<feature>/{data,domain,presentation}` مع Riverpod لإدارة الحالة، وRepository يفصل الواجهة عن Drift/Supabase، وحقن تبعيات بسيط عبر مزودات Riverpod.

## البدائل المرفوضة
- Bloc: صخب شعائري أعلى بلا مكسب لقابلية الاختبار هنا.
- GetX: أنماط ضمنية تصعّب الاختبار والتتبع.

## النتائج
الانتقال ملفًا ملفًا (ميزة ميزة) مع بقاء التطبيق عاملًا بعد كل خطوة؛ لا إعادة كتابة كبرى دفعة واحدة.

</div>
