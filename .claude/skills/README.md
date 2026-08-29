# حزمة Skills لـ Claude Code

## التثبيت (مرة واحدة)

### لتكون متاحة في كل مشاريعك
انسخ مجلد `skills` إلى `~/.claude/`:

    mkdir -p ~/.claude/skills
    cp -r skills/* ~/.claude/skills/

على Windows (PowerShell):

    New-Item -ItemType Directory -Force "$HOME\.claude\skills"
    Copy-Item -Recurse skills\* "$HOME\.claude\skills\"

### أو داخل مشروع واحد فقط
انسخ المجلد إلى `.claude/skills/` داخل مجلد المشروع، ثم ارفعه مع Git ليستفيد فريقك.

## التحقق
افتح Claude Code داخل مشروعك واكتب `/skills` أو اسأل: "ما المهارات المتاحة؟"
يجب أن ترى الأسماء الستة. إن كان المجلد جديدًا، أعد تشغيل Claude Code مرة واحدة.

## الاستخدام
لا تحتاج فعل شيء. عندما تطلب مثلًا "أضف شاشة إعدادات في تطبيق وقتي"، سيقرأ كلود مهارة flutter-arabic-app تلقائيًا ويلتزم بقواعدها.
يمكنك أيضًا استدعاء مهارة مباشرة: `/web-security` لمراجعة أمنية.

## المهارات
| المجلد | متى تعمل |
|---|---|
| flutter-arabic-app | أي عمل على Flutter |
| web-frontend | واجهات الويب وReact/Next.js |
| backend-api | مسارات API وقواعد البيانات |
| web-security | مراجعة أمنية وقبل النشر |
| ai-rag-agents | دمج LLM وRAG والوكلاء |
| quality-testing | اختبارات ومراجعة قبل التسليم |

## التعديل
افتح أي `SKILL.md` وعدّل القواعد بما يناسبك. كلود يلتقط التغيير في الجلسة نفسها.
