# مراحل إطلاق «وقتي» على Google Play وApp Store

> الحالة الآن: الشيفرة والاختبارات وCI والحِزم وبطاقة المتجر **جاهزة** (v1.3.0، `af4222a`).
> المتبقي حسابات وأسرار لا يملكها إلا المالك. كل مرحلة لها مالك، مدة، وبوابة خروج.
> القاعدة: **لا مفتاح ولا كلمة سر في المحادثة** — الأسرار في GitHub → Settings → Secrets → Actions.

| المرحلة | المالك | المدة | البوابة |
|---|---|---|---|
| 0. الخدمات (Supabase + Sentry) | أنت ثم أنا | 20 د + 1 س | اختبار RLS الحقيقي أخضر، عطل تجريبي يظهر في Sentry |
| 1. حسابات المتاجر | أنت | 30 د (+ انتظار قبول آبل 1–2 يوم) | الاسم «وقتي» محجوز في المتجرين |
| 2. الأسرار + بناء التحقق | أنت ثم أنا | 20 د + 15 د | `Publish to Stores` يمر بلا خطأ «سر ناقص» |
| 3. اختبار الجهاز الحقيقي | أنت | 20 د | تذكير يصل والتطبيق مغلق، دخول + نسخة سحابية تعمل |
| 4. Google Play: داخلي → مغلق → إنتاج | أنا ثم أنت | 14 يومًا (شرط Google للحسابات الجديدة) | Production access ممنوح، إصدار إنتاج بنسبة 20% |
| 5. App Store: TestFlight → مراجعة | أنا ثم أنت | 1–3 أيام مراجعة | حالة «Ready for Sale» |
| 6. يوم الإطلاق | أنت وأنا | 1 س | الروابط تعمل، لا أعطال في أول 24 س |
| 7. ما بعد الإطلاق | أنا | مستمر | v1.3.1 خلال أسبوعين إن ظهرت أعطال |

---

## المرحلة 0 — الخدمات (اليوم)

**أنت (20 دقيقة)** — الدليل التفصيلي: `docs/SETUP_SUPABASE_SENTRY.md`.
1. Supabase: مشروع جديد → SQL Editor → الصق `supabase/migrations/20260904000000_init.sql` → Run → Authentication → URL Configuration (Site URL + `waqti://login-callback/`).
2. Sentry: مشروع Flutter → انسخ DSN.
3. أضف في GitHub Secrets: `SUPABASE_URL`، `SUPABASE_ANON_KEY`، `SENTRY_DSN`. (يمكنك إرسال القيم الثلاث لي في المحادثة — عامة بطبيعتها.)

**أنا (ساعة)**
1. أشغّل `test/integration/rls_test.dart` على مشروعك: مستخدم لا يقرأ صف غيره (دليل بوابة Database).
2. أشغّل `Release Builds` وأرسل لك APK للتجربة.
3. أُطلق عطلًا تجريبيًا وأتأكد من ظهوره في Sentry مع فك التتبع.

**بوابة الخروج**: RLS أخضر + Sentry يستقبل + APK بحساب حقيقي يعمل.

## المرحلة 1 — حسابات المتاجر (اليوم؛ آبل تحتاج انتظارًا)

**أنت**
1. Google Play Console <https://play.google.com/console> — 25$ مرة واحدة. أكمل التحقق من الهوية (قد يستغرق يومًا).
2. Apple Developer Program <https://developer.apple.com/programs/enroll> — 99$/سنة. القبول 1–2 يوم عمل (أحيانًا أكثر للأفراد).
3. فور التفعيل: احجز الاسم «وقتي» — Play: Create app؛ آبل: Identifiers → App ID `com.waqti.waqti` ثم App Store Connect → New App (SKU `waqti`).
4. احفظ ملفَي مفتاح الرفع (`upload-keystore.jks` + `key.properties`) في مدير كلمات مرور. فقدانهما = لا تحديثات مستقبلية على Play.

**بوابة الخروج**: الاسم محجوز في المتجرين، الحسابان فعّالان.

## المرحلة 2 — الأسرار وبناء التحقق

**أنت (20 دقيقة)** — الجدول الكامل في `docs/LAUNCH_PLAYBOOK.md` (المسار ب):
- Play: `PLAY_SERVICE_ACCOUNT_JSON` (Setup → API access → service account بصلاحية Release manager)، `ANDROID_KEYSTORE_BASE64`، `ANDROID_KEY_PROPERTIES`.
- App Store: `ASC_KEY_ID`، `ASC_ISSUER_ID`، `ASC_KEY_P8` (Users and Access → Integrations → API key بصلاحية App Manager)، `APPLE_TEAM_ID`.

**أنا (15 دقيقة)**
1. أشغّل `Publish to Stores` بمسار Play = internal وiOS = TestFlight.
2. أحفظ رموز فك التشويش (`waqti-symbols-*`) وأرفعها إلى Sentry.

**بوابة الخروج**: البناءان يظهران في Play Internal testing وTestFlight.

## المرحلة 3 — اختبار الجهاز الحقيقي (لا يمكن محاكاته هنا)

**أنت (20 دقيقة)** — من رابط Internal testing (أندرويد) وTestFlight (iOS):
1. أنشئ حسابًا ببريدك، أكّد البريد، أضف مهمة، أغلق التطبيق، افتحه: الجلسة باقية والمهمة موجودة.
2. أضف عادة بتذكير بعد دقيقتين، أغلق التطبيق تمامًا: يصل الإشعار، والنقر عليه يفتح المهمة.
3. سجّل الخروج ثم الدخول من الجهاز الآخر: البيانات تعود من السحابة.
4. بدّل اللغة إلى الإنجليزية والوضع الداكن: لا تشوّه.
5. الإعدادات → حذف الحساب: يعمل ويعيدك لشاشة الدخول.

**أنا**: أصلح أي خلل فورًا وأعيد البناء (R8 مفعّل أول مرة على جهاز حقيقي — الإشعارات هي البند الحساس).

**بوابة الخروج**: الخمسة أعلاه تمر على أندرويد وiOS.

## المرحلة 4 — Google Play: داخلي → مغلق → إنتاج

> الحسابات الشخصية الجديدة تشترط **اختبارًا مغلقًا بـ 12 مختبِرًا على الأقل لمدة 14 يومًا متواصلة** قبل السماح بالإنتاج. ابدأ هذه المرحلة مبكرًا بالتوازي مع آبل.

**أنت**
1. Testing → Closed testing → Create track → أضف قائمة بريد 12+ شخصًا (أصدقاء/عائلة) وشارك رابط الانضمام.
2. Set up your app: الإجابات جاهزة حرفيًا في `docs/LAUNCH_CHECKLIST.md` §1 (Data safety: يجمع البريد والاسم وسجلات الأعطال، مشفّر، قابل للحذف داخل التطبيق).
3. Store listing: النصوص من `docs/STORE_LISTING.md`، الأيقونة 512، الرسم المميز `docs/store/play-feature-graphic-1024x500.png`، اللقطات `docs/screenshots/`.
4. بعد 14 يومًا: Dashboard → Apply for production access → أجب عن الأسئلة (ما اختبرته، وما غيّرته).

**أنا**: أرفع كل بناء جديد إلى المسار المغلق عبر `Publish to Stores` (`play_track = closed` عند الحاجة أُضيفه للسير).

**بوابة الخروج**: Production access ممنوح.

## المرحلة 5 — App Store: TestFlight → المراجعة

**أنت**
1. App Store Connect → App Information: الفئة Productivity؛ Pricing: Free؛ Availability: كل الدول.
2. App Privacy: **Data Linked to You** = Contact Info (Email)، Name، User Content؛ **Not Linked** = Diagnostics (Crash Data)؛ Tracking = No. Age Rating: كل الأسئلة None → 4+.
3. الإصدار 1.3.0: اللقطات 6.7" من `docs/screenshots/` وiPad 13" من `docs/store/`، النصوص والكلمات المفتاحية من `docs/STORE_LISTING.md`، اختر بناء TestFlight.
4. App Review Information: ملاحظة المراجع من `docs/STORE_LISTING.md` + حساب تجريبي (بريد/كلمة مرور أنشأتهما في المرحلة 3). أرفق أن «المتابعة كزائر» متاحة بلا حساب.
5. Submit for Review. الرفض الشائع وحلّه جاهز: رابط الخصوصية يعمل، لا شراء رقمي خارج آبل (الباقات «قريبًا»)، حذف الحساب داخل التطبيق موجود.

**بوابة الخروج**: «Ready for Sale» (اختر Manual release لتتحكم في يوم الإطلاق).

## المرحلة 6 — يوم الإطلاق

1. **أنت**: Play → Production → Create release → البناء نفسه الذي اجتاز المغلق → Staged rollout **20%**. آبل → Release this version.
2. **أنا**: وسم `v1.3.0` مطابق للبناء المرفوع، تحديث `README.md` بروابط المتجرين، ومراقبة Sentry.
3. بعد 48 ساعة بلا أعطال: ارفع Play إلى 50% ثم 100%.

**بوابة الخروج**: الروابط تعمل على المتجرين، معدل الأعطال في Sentry صفر أو مفسَّر.

## المرحلة 7 — ما بعد الإطلاق (أول شهر)

- أسبوعيًا: Play Console → Android vitals (ANR/Crash)، App Store Connect → Crashes، Sentry → Issues.
- الردود على المراجعات خلال 48 ساعة (نبرة قصيرة، شكر + ما سيتغير).
- v1.3.1 عند تجميع 3 إصلاحات أو أي عطل يتكرر: أرفع `version` و`kAppVersion` → `Release Builds` → `Publish to Stores`.
- بعد الاستقرار: تفعيل Google/Apple sign-in (الخطوات في `docs/LAUNCH_CHECKLIST.md` §0)، ثم قرار الباقات (RevenueCat) — حينها تُطبَّق مهارة `flutter-monetization`.

---

## ماذا أحتاج منك الآن (بالترتيب)

1. `SUPABASE_URL` + `SUPABASE_ANON_KEY` + `SENTRY_DSN` (المرحلة 0).
2. تأكيد أن حسابَي Google Play وApple قيد الإنشاء (المرحلة 1).
3. الأسرار الثمانية للمتجرين (المرحلة 2).

كل ما عدا ذلك أُنفّذه بلا أسئلة.
