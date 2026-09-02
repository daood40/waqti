import '../models/models.dart';

/// قالب عادة جاهز: يملأ محرر المهمة بنقرة واحدة.
class HabitTemplate {
  const HabitTemplate({
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.categoryId,
    this.target = 1,
    this.unitAr = '',
    this.unitEn = '',
    this.priority = TaskPriority.medium,
  });

  final String nameAr;
  final String nameEn;
  final String icon;

  /// معرّف التصنيف الافتراضي (c1 روحانيات، c2 صحة، c3 تطوير ذاتي، c4 إنتاجية).
  final String categoryId;
  final int target;
  final String unitAr;
  final String unitEn;
  final TaskPriority priority;

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String unit(String lang) => lang == 'ar' ? unitAr : unitEn;
}

/// مكتبة العادات الأكثر طلبًا في السوق العربي — تُعرض في محرر المهمة
/// وفي الحالة الفارغة حتى يبدأ المستخدم خلال ثوانٍ.
const kHabitTemplates = <HabitTemplate>[
  HabitTemplate(
    nameAr: 'صلاة الفجر في وقتها',
    nameEn: 'Fajr prayer on time',
    icon: '🕌',
    categoryId: 'c1',
    priority: TaskPriority.high,
  ),
  HabitTemplate(
    nameAr: 'ورد القرآن',
    nameEn: 'Quran reading',
    icon: '📖',
    categoryId: 'c1',
    priority: TaskPriority.high,
  ),
  HabitTemplate(
    nameAr: 'أذكار الصباح والمساء',
    nameEn: 'Morning & evening adhkar',
    icon: '🙏',
    categoryId: 'c1',
  ),
  HabitTemplate(
    nameAr: 'شرب الماء',
    nameEn: 'Drink water',
    icon: '💧',
    categoryId: 'c2',
    target: 8,
    unitAr: 'كوب',
    unitEn: 'cup',
  ),
  HabitTemplate(
    nameAr: 'رياضة 30 دقيقة',
    nameEn: 'Exercise 30 min',
    icon: '🏃',
    categoryId: 'c2',
    priority: TaskPriority.high,
  ),
  HabitTemplate(
    nameAr: 'المشي',
    nameEn: 'Walking',
    icon: '🚶',
    categoryId: 'c2',
    target: 10,
    unitAr: 'ألف خطوة',
    unitEn: 'k steps',
  ),
  HabitTemplate(
    nameAr: 'النوم قبل 11',
    nameEn: 'Sleep before 11',
    icon: '😴',
    categoryId: 'c2',
  ),
  HabitTemplate(
    nameAr: 'قراءة',
    nameEn: 'Reading',
    icon: '📚',
    categoryId: 'c3',
    target: 20,
    unitAr: 'صفحة',
    unitEn: 'pages',
  ),
  HabitTemplate(
    nameAr: 'تعلّم لغة',
    nameEn: 'Language practice',
    icon: '🗣️',
    categoryId: 'c3',
    target: 15,
    unitAr: 'دقيقة',
    unitEn: 'min',
  ),
  HabitTemplate(
    nameAr: 'كتابة اليوميات',
    nameEn: 'Journaling',
    icon: '✍️',
    categoryId: 'c3',
  ),
  HabitTemplate(
    nameAr: 'بلا هاتف قبل النوم',
    nameEn: 'No phone before bed',
    icon: '📵',
    categoryId: 'c4',
  ),
  HabitTemplate(
    nameAr: 'تخطيط الغد',
    nameEn: 'Plan tomorrow',
    icon: '🗓️',
    categoryId: 'c4',
  ),
];
