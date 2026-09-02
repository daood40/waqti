/// اقتباسات تحفيزية قصيرة — تتبدّل يوميًا بحسب يوم السنة.
class DailyQuote {
  const DailyQuote(this.ar, this.en);

  final String ar;
  final String en;

  String text(String lang) => lang == 'ar' ? ar : en;

  static DailyQuote forDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return kQuotes[dayOfYear % kQuotes.length];
  }
}

const kQuotes = <DailyQuote>[
  DailyQuote(
    'أحبّ الأعمال إلى الله أدومها وإن قلّ.',
    'The most beloved deeds are the most consistent, even if small.',
  ),
  DailyQuote(
    'لا تحتقر خطوة صغيرة؛ الجبال تُصعد خطوة خطوة.',
    'Never belittle a small step; mountains are climbed one step at a time.',
  ),
  DailyQuote('أنت ما تكرره كل يوم.', 'You are what you repeat every day.'),
  DailyQuote(
    'الانضباط هو أن تختار ما تريده أكثر على ما تريده الآن.',
    'Discipline is choosing what you want most over what you want now.',
  ),
  DailyQuote(
    'ابدأ من حيث أنت، بما لديك، بقدر ما تستطيع.',
    'Start where you are, with what you have, as much as you can.',
  ),
  DailyQuote(
    'يوم فائت لا يمحو شهرًا من الجهد — عُد غدًا.',
    'One missed day does not erase a month of effort — come back tomorrow.',
  ),
  DailyQuote('الاستمرار يهزم الكمال.', 'Consistency beats perfection.'),
  DailyQuote(
    'من سار على الدرب وصل.',
    'Whoever keeps walking the path arrives.',
  ),
  DailyQuote(
    'اجعل الخطوة الأولى سهلة لدرجة يصعب معها الرفض.',
    'Make the first step so easy you cannot say no.',
  ),
  DailyQuote(
    'لست متأخرًا؛ أنت في وقتك تمامًا إن بدأت الآن.',
    'You are not late; you are right on time if you start now.',
  ),
  DailyQuote(
    'العادة تُبنى بالتكرار لا بالحماس.',
    'Habits are built by repetition, not enthusiasm.',
  ),
  DailyQuote(
    '1% أفضل كل يوم = 37 ضعفًا في السنة.',
    '1% better each day = 37x in a year.',
  ),
  DailyQuote(
    'ركّز على النظام لا على الهدف؛ النتائج تتبع النظام.',
    'Focus on the system, not the goal; results follow the system.',
  ),
  DailyQuote(
    'أصعب جزء هو البداية — وقد بدأت.',
    'The hardest part is starting — and you already have.',
  ),
  DailyQuote(
    'راحة اليوم ليست فشلًا؛ إنها جزء من الطريق.',
    'Resting today is not failure; it is part of the road.',
  ),
  DailyQuote(
    'الوقت يمضي على أي حال — فلتمضِ نحو ما تريد.',
    'Time passes anyway — let it pass toward what you want.',
  ),
  DailyQuote(
    'قليل دائم خير من كثير منقطع.',
    'A little that lasts is better than a lot that stops.',
  ),
  DailyQuote('لا تكسر السلسلة مرتين متتاليتين.', 'Never miss twice in a row.'),
  DailyQuote(
    'ما لا يُقاس لا يتحسّن.',
    'What is not measured does not improve.',
  ),
  DailyQuote(
    'كل صباح فرصة جديدة لتكون النسخة التي تريدها.',
    'Every morning is a fresh chance to be who you want to be.',
  ),
  DailyQuote(
    'الصبر مفتاح كل إنجاز.',
    'Patience is the key to every achievement.',
  ),
  DailyQuote(
    'لا تنتظر الدافع؛ الفعل يصنع الدافع.',
    'Do not wait for motivation; action creates it.',
  ),
  DailyQuote(
    'أنجز أهم شيء أولًا، والباقي يتبع.',
    'Do the most important thing first; the rest follows.',
  ),
  DailyQuote(
    'عشر دقائق اليوم أفضل من ساعة "يومًا ما".',
    'Ten minutes today beat an hour "someday".',
  ),
  DailyQuote(
    'التقدم لا يُرى يوميًا لكنه يُحسّ شهريًا.',
    'Progress is invisible daily but obvious monthly.',
  ),
  DailyQuote(
    'امنح نفسك الفضل على كل خطوة.',
    'Give yourself credit for every step.',
  ),
  DailyQuote(
    'ازرع اليوم ما تريد حصاده غدًا.',
    'Plant today what you want to harvest tomorrow.',
  ),
  DailyQuote(
    'القوة لا تأتي من القدرة بل من الإرادة.',
    'Strength comes not from ability but from will.',
  ),
  DailyQuote(
    'كن أفضل من أمس، لا أفضل من غيرك.',
    'Be better than yesterday, not better than others.',
  ),
  DailyQuote(
    'النجاح مجموع جهود صغيرة تتكرر كل يوم.',
    'Success is the sum of small efforts repeated daily.',
  ),
];
