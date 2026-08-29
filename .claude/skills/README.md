# حزمة مهارات Claude Code — 25 مهارة (تطبيقات، مواقع، خلفية، ذكاء اصطناعي، بيانات)

## لماذا 25 وليس 1000؟
Claude Code يحمّل **وصف** كل مهارة في كل جلسة، ويقرأ **محتواها** فقط عند الحاجة.
لذلك كثرة المهارات تستهلك توكنز وتُضعف اختيار المهارة الصحيحة. 25 مهارة مركّزة تغطي كل مسار عمل.

## التثبيت
### من الهاتف (Claude Code في تطبيق Claude)
افتح مستودعك في Claude Code والصق محتوى ملفات `paste/` بالترتيب (1 ثم 2 ...). كل ملف رسالة واحدة.

### من كمبيوتر
انسخ مجلد `skills/` إلى `~/.claude/skills/` (لكل المشاريع) أو `.claude/skills/` داخل المشروع.

## بعد التثبيت
- انسخ `CLAUDE.md.example` إلى جذر مشروعك باسم `CLAUDE.md` وعدّله.
- اكتب `/skills` في Claude Code للتأكد من ظهور 25 مهارة.

## المهارات
| المجموعة | المهارات |
|---|---|
| أساسية | token-efficiency, project-setup, debugging, code-review, quality-testing, git-workflow |
| ويب | web-frontend, web-performance, accessibility-seo, pwa-offline |
| جوال | flutter-arabic-app, android-kotlin, ios-swift, react-native-expo, mobile-release |
| خلفية | backend-api, database-design, api-integrations, web-security, devops-deploy |
| ذكاء اصطناعي وبيانات | ai-rag-agents, llm-prompting, ml-pipeline, data-analysis, docs-writing |

## التخصيص
عدّل أي SKILL.md مباشرة؛ التغيير يُلتقط في الجلسة نفسها. احذف مهارات التقنيات التي لا تستخدمها لتوفير التوكنز.
