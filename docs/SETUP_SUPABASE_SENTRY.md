# إعداد Supabase وSentry — خطوة بخطوة (≈ 20 دقيقة)

لا ترسل أي «service_role» أو كلمة مرور قاعدة البيانات لأحد. المطلوب إرساله لي **ثلاث قيم عامة فقط**.

## أ) Supabase (10 دقائق)

1. افتح <https://supabase.com> → **Start your project** → سجّل بحساب GitHub أو بريد.
2. **New organization** (اسم أي شيء، الخطة Free) → **New project**:
   - Name: `waqti`
   - Database password: اختر كلمة قوية **واحفظها عندك** (لن أحتاجها).
   - Region: **Frankfurt (eu-central-1)** أو **Bahrain (me-south-1)** — الأقرب لمستخدميك.
   - Create → انتظر دقيقتين حتى يصبح Status = Active.
3. **SQL Editor** (القائمة اليسرى) → **New query** → افتح ملف
   `supabase/migrations/20260904000000_init.sql` من المستودع، انسخ محتواه كاملًا، الصقه، اضغط **Run**.
   يجب أن ترى `Success. No rows returned`.
4. **Authentication → Providers → Email**: تأكد أن Enable = ON، و**Confirm email = ON**. احفظ.
5. **Authentication → URL Configuration**:
   - Site URL: `https://daood40.github.io/waqti/`
   - Redirect URLs → Add: `waqti://login-callback/` ثم Add: `https://daood40.github.io/waqti/**` → Save.
6. **Authentication → Emails (Templates)**: اختياري الآن؛ اتركه.
7. **Project Settings → API**:
   - انسخ **Project URL** (مثل `https://abcd1234.supabase.co`).
   - انسخ **Publishable key** (يبدأ بـ `sb_publishable_`) — إن لم يظهر، انسخ **anon public** من Legacy keys.
   - **لا تنسخ** service_role.

أرسل لي: `SUPABASE_URL=...` و `SUPABASE_ANON_KEY=...`

## ب) Sentry (5 دقائق)

1. <https://sentry.io/signup/> → سجّل (Developer plan مجاني).
2. Create Project → Platform: **Flutter** → Alert frequency: Default → Project name: `waqti` → Create.
3. تظهر صفحة الإعداد وفيها `dsn: 'https://....ingest.sentry.io/....'` — انسخ قيمة DSN كاملة.
   (لاحقًا من Settings → Projects → waqti → Client Keys (DSN).)

أرسل لي: `SENTRY_DSN=...`

## ج) بعد إرسالك القيم (أنا)

1. أضعها في GitHub Secrets وأشغّل بناء تحقق.
2. أشغّل اختبار RLS الفعلي على مشروعك (دليل بوابة Database).
3. أُصدر بناء المتجر (AAB + IPA) وأرسل لك APK لتجربة الدخول والنسخة السحابية على هاتفك.

## د) لاحقًا (بعد الإطلاق): Google/Apple sign-in

الأزرار مخفية حتى تُضاف الإعدادات؛ الخطوات في `docs/LAUNCH_CHECKLIST.md` §0 (3–4).
لتفعيل Apple يُضاف سر `APPLE_SIGNIN_ENABLED=true` بعد إعداد المزوّد في Supabase.
