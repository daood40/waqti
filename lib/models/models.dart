import 'dart:math';

/// حالة إنجاز مهمة في يوم معيّن.
enum TaskStatus {
  done,
  doneLate,
  missed,

  /// يوم راحة: لا يُحسب مع المستحق ولا يكسر السلسلة (مرض، سفر…).
  skipped;

  String get key => switch (this) {
    TaskStatus.done => 'done',
    TaskStatus.doneLate => 'late',
    TaskStatus.missed => 'missed',
    TaskStatus.skipped => 'skip',
  };

  /// أُنجزت (في وقتها أو متأخرة).
  bool get isCompleted =>
      this == TaskStatus.done || this == TaskStatus.doneLate;

  static TaskStatus? fromKey(String? key) => switch (key) {
    'done' => TaskStatus.done,
    'late' => TaskStatus.doneLate,
    'missed' => TaskStatus.missed,
    'skip' => TaskStatus.skipped,
    _ => null,
  };
}

/// أولوية المهمة — بترتيب تصاعدي حتى يصلح `index` للفرز.
enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  static TaskPriority fromKey(String? key) => switch (key) {
    'low' => TaskPriority.low,
    'high' => TaskPriority.high,
    'urgent' => TaskPriority.urgent,
    _ => TaskPriority.medium,
  };
}

/// باقات الاشتراك — قيمة متدرجة تجعل الترقية مُبرَّرة.
enum PlanTier {
  free,
  bronze,
  silver,
  gold;

  /// حد المهام للباقة — `null` يعني بلا حدود.
  int? get taskLimit => switch (this) {
    PlanTier.free => 5,
    PlanTier.bronze => 15,
    PlanTier.silver || PlanTier.gold => null,
  };

  static PlanTier fromKey(String? key) => switch (key) {
    'bronze' => PlanTier.bronze,
    'silver' => PlanTier.silver,
    'gold' => PlanTier.gold,
    _ => PlanTier.free,
  };
}

/// فترة اليوم المفضلة للعادة — تُجمّع بها بطاقة اليوم.
enum TimeSlot {
  any,
  morning,
  afternoon,
  evening;

  static TimeSlot fromKey(String? key) => switch (key) {
    'morning' => TimeSlot.morning,
    'afternoon' => TimeSlot.afternoon,
    'evening' => TimeSlot.evening,
    _ => TimeSlot.any,
  };
}

/// مهمة فرعية داخل قائمة تحقق.
class Subtask {
  Subtask({required this.title, this.done = false});

  String title;
  bool done;

  Map<String, dynamic> toJson() => {'t': title, if (done) 'd': true};

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    title: json['t'] as String? ?? '',
    done: json['d'] as bool? ?? false,
  );
}

/// نوع تكرار المهمة.
enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
  specificDays;

  String get key => switch (this) {
    RecurrenceType.once => 'once',
    RecurrenceType.daily => 'daily',
    RecurrenceType.weekly => 'weekly',
    RecurrenceType.monthly => 'monthly',
    RecurrenceType.specificDays => 'specific',
  };

  static RecurrenceType fromKey(String? key) => switch (key) {
    'once' => RecurrenceType.once,
    'weekly' => RecurrenceType.weekly,
    'monthly' => RecurrenceType.monthly,
    'specific' => RecurrenceType.specificDays,
    _ => RecurrenceType.daily,
  };
}

/// قاعدة تكرار المهمة (يومي، أسبوعي، شهري، أيام محددة، أو مرة واحدة).
class Recurrence {
  const Recurrence({
    this.type = RecurrenceType.daily,
    this.weekday = 0,
    this.dayOfMonth = 1,
    this.days = const [],
    this.date,
  });

  final RecurrenceType type;

  /// يوم الأسبوع للتكرار الأسبوعي — 0 = الأحد … 6 = السبت.
  final int weekday;

  /// يوم الشهر للتكرار الشهري (1–31).
  final int dayOfMonth;

  /// أيام الأسبوع للتكرار "أيام محددة" — 0 = الأحد … 6 = السبت.
  final List<int> days;

  /// تاريخ التنفيذ لمهمة "مرة واحدة".
  final DateTime? date;

  Recurrence copyWith({
    RecurrenceType? type,
    int? weekday,
    int? dayOfMonth,
    List<int>? days,
    DateTime? date,
  }) {
    return Recurrence(
      type: type ?? this.type,
      weekday: weekday ?? this.weekday,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      days: days ?? this.days,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.key,
    'weekday': weekday,
    'dayOfMonth': dayOfMonth,
    'days': days,
    if (date != null) 'date': DateKey.fromDate(date!),
  };

  factory Recurrence.fromJson(Map<String, dynamic> json) => Recurrence(
    type: RecurrenceType.fromKey(json['type'] as String?),
    weekday: (json['weekday'] as num?)?.toInt() ?? 0,
    dayOfMonth: (json['dayOfMonth'] as num?)?.toInt() ?? 1,
    days: ((json['days'] as List?) ?? const [])
        .map((e) => (e as num).toInt())
        .toList(),
    date: DateKey.tryParse(json['date'] as String?),
  );
}

/// تصنيف للمهام (روحانيات، صحة، …).
class TaskCategory {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  TaskCategory copyWith({String? name, int? colorValue}) => TaskCategory(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': colorValue,
  };

  factory TaskCategory.fromJson(Map<String, dynamic> json) => TaskCategory(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    colorValue: (json['color'] as num?)?.toInt() ?? 0xFF6E8F72,
  );
}

/// مهمة أو عادة يتتبعها المستخدم.
class TaskItem {
  TaskItem({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = '✅',
    this.colorValue = 0xFF6E8F72,
    this.categoryId,
    this.priority = TaskPriority.medium,
    this.recurrence = const Recurrence(),
    this.notificationsOn = true,
    this.target = 1,
    this.unit = '',
    this.pausedAt,
    this.timeSlot = TimeSlot.any,
    this.isQuit = false,
    List<int>? reminders,
    List<Subtask>? subtasks,
    Map<String, TaskStatus>? statuses,
    Map<String, int>? progress,
    Map<String, String>? notes,
    DateTime? createdAt,
  }) : reminders = reminders ?? [],
       subtasks = subtasks ?? [],
       statuses = statuses ?? {},
       progress = progress ?? {},
       notes = notes ?? {},
       createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  String description;
  String icon;
  int colorValue;
  String? categoryId;
  TaskPriority priority;
  Recurrence recurrence;
  bool notificationsOn;

  /// الهدف اليومي للعادات القابلة للقياس (8 أكواب، 20 صفحة…).
  /// 1 = عادة عادية تُنجز بنقرة.
  int target;

  /// وحدة القياس الاختيارية (كوب، صفحة، دقيقة…).
  String unit;

  /// إيقاف مؤقت: المهمة غير مستحقة من هذا التاريخ فصاعدًا مع
  /// الاحتفاظ بسجلها السابق. `null` = نشطة.
  DateTime? pausedAt;

  /// أوقات التذكير اليومية بالدقائق منذ منتصف الليل (8:30 = 510) —
  /// حتى ثلاثة أوقات في اليوم.
  final List<int> reminders;

  /// فترة اليوم (صباح/ظهر/مساء) — تجميع بصري وافتراضي للتذكير.
  TimeSlot timeSlot;

  /// عادة إقلاع (تدخين، سهر…): الإنجاز = "قاومتُ اليوم"، والفوات = زلّة.
  bool isQuit;

  /// قائمة تحقق فرعية (خطوات).
  final List<Subtask> subtasks;

  /// التقدم اليومي للعادات القابلة للقياس مفهرسًا بمفتاح التاريخ.
  final Map<String, int> progress;

  /// يوميات: ملاحظة نصية لكل يوم.
  final Map<String, String> notes;

  bool get isMeasurable => target > 1;
  bool get isPaused => pausedAt != null;

  /// توافق: أول وقت تذكير أو لا شيء.
  int? get reminderMinutes => reminders.isEmpty ? null : reminders.first;

  String noteOn(DateTime date) => notes[DateKey.fromDate(date)] ?? '';

  void setNoteOn(DateTime date, String text) {
    final key = DateKey.fromDate(date);
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      notes.remove(key);
    } else {
      notes[key] = trimmed;
    }
  }

  /// تاريخ إنشاء المهمة — يحدّ حساب المتأخرات فلا تُحسب أيام
  /// ما قبل وجود المهمة.
  final DateTime createdAt;

  /// حالات الإنجاز مفهرسة بمفتاح تاريخ كامل `yyyy-MM-dd`
  /// (بخلاف النموذج الأولي الذي كان يفهرس برقم اليوم فقط،
  /// وهو ما كان يكرر نفس الحالات في كل الشهور).
  final Map<String, TaskStatus> statuses;

  /// هل تنطبق المهمة على هذا اليوم بحسب قاعدة تكرارها؟
  bool isApplicableOn(DateTime date) {
    final paused = pausedAt;
    if (paused != null) {
      final since = DateTime(paused.year, paused.month, paused.day);
      if (!date.isBefore(since)) return false;
    }
    final r = recurrence;
    final sundayBased = date.weekday % 7; // الأحد = 0 … السبت = 6
    return switch (r.type) {
      RecurrenceType.daily => true,
      RecurrenceType.weekly => sundayBased == r.weekday,
      RecurrenceType.monthly => date.day == r.dayOfMonth,
      RecurrenceType.specificDays => r.days.contains(sundayBased),
      RecurrenceType.once =>
        r.date != null &&
            r.date!.year == date.year &&
            r.date!.month == date.month &&
            r.date!.day == date.day,
    };
  }

  TaskStatus? statusOn(DateTime date) => statuses[DateKey.fromDate(date)];

  int progressOn(DateTime date) => progress[DateKey.fromDate(date)] ?? 0;

  void setProgressOn(DateTime date, int value) {
    final key = DateKey.fromDate(date);
    if (value <= 0) {
      progress.remove(key);
    } else {
      progress[key] = value;
    }
  }

  void setStatusOn(DateTime date, TaskStatus? status) {
    final key = DateKey.fromDate(date);
    if (status == null) {
      statuses.remove(key);
    } else {
      statuses[key] = status;
    }
  }

  TaskItem deepCopy() => TaskItem(
    id: id,
    name: name,
    description: description,
    icon: icon,
    colorValue: colorValue,
    categoryId: categoryId,
    priority: priority,
    recurrence: recurrence,
    notificationsOn: notificationsOn,
    target: target,
    unit: unit,
    pausedAt: pausedAt,
    timeSlot: timeSlot,
    isQuit: isQuit,
    reminders: List.of(reminders),
    subtasks: [
      for (final st in subtasks) Subtask(title: st.title, done: st.done),
    ],
    statuses: Map.of(statuses),
    progress: Map.of(progress),
    notes: Map.of(notes),
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'desc': description,
    'icon': icon,
    'color': colorValue,
    if (categoryId != null) 'category': categoryId,
    'priority': priority.name,
    'recurrence': recurrence.toJson(),
    'notif': notificationsOn,
    if (target > 1) 'target': target,
    if (unit.isNotEmpty) 'unit': unit,
    if (pausedAt != null) 'pausedAt': DateKey.fromDate(pausedAt!),
    if (reminders.isNotEmpty) 'reminders': reminders,
    if (timeSlot != TimeSlot.any) 'slot': timeSlot.name,
    if (isQuit) 'quit': true,
    if (subtasks.isNotEmpty)
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
    'createdAt': DateKey.fromDate(createdAt),
    'statuses': statuses.map((k, v) => MapEntry(k, v.key)),
    if (progress.isNotEmpty) 'progress': progress,
    if (notes.isNotEmpty) 'notes': notes,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    final rawStatuses = (json['statuses'] as Map?) ?? const {};
    final statuses = <String, TaskStatus>{};
    rawStatuses.forEach((key, value) {
      final status = TaskStatus.fromKey(value as String?);
      if (status != null) statuses[key as String] = status;
    });
    final rawProgress = (json['progress'] as Map?) ?? const {};
    final progress = <String, int>{};
    rawProgress.forEach((key, value) {
      if (value is num) progress[key as String] = value.toInt();
    });
    final notes = <String, String>{};
    ((json['notes'] as Map?) ?? const {}).forEach((key, value) {
      if (value is String && value.isNotEmpty) notes[key as String] = value;
    });
    // ترحيل: 'reminder' المفرد القديم → قائمة.
    final reminders = <int>[
      ...((json['reminders'] as List?) ?? const []).whereType<num>().map(
        (e) => e.toInt(),
      ),
    ];
    if (reminders.isEmpty && json['reminder'] is num) {
      reminders.add((json['reminder'] as num).toInt());
    }
    final subtasks = ((json['subtasks'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Subtask.fromJson)
        .toList();
    return TaskItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['desc'] as String? ?? '',
      icon: json['icon'] as String? ?? '✅',
      colorValue: (json['color'] as num?)?.toInt() ?? 0xFF6E8F72,
      categoryId: json['category'] as String?,
      priority: TaskPriority.fromKey(json['priority'] as String?),
      recurrence: json['recurrence'] is Map<String, dynamic>
          ? Recurrence.fromJson(json['recurrence'] as Map<String, dynamic>)
          : const Recurrence(),
      notificationsOn: json['notif'] as bool? ?? true,
      target: ((json['target'] as num?)?.toInt() ?? 1).clamp(1, 100000),
      unit: json['unit'] as String? ?? '',
      pausedAt: DateKey.tryParse(json['pausedAt'] as String?),
      timeSlot: TimeSlot.fromKey(json['slot'] as String?),
      isQuit: json['quit'] as bool? ?? false,
      reminders: reminders,
      subtasks: subtasks,
      progress: progress,
      notes: notes,
      // بيانات قديمة بلا createdAt: نعتبرها موجودة منذ زمن حتى لا
      // تختفي متأخراتها الحقيقية.
      createdAt:
          DateKey.tryParse(json['createdAt'] as String?) ?? DateTime(2000),
      statuses: statuses,
    );
  }

  static String newId() {
    final rand = Random();
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = rand.nextInt(1 << 30).toRadixString(36);
    return 't$now$salt';
  }
}

/// بيانات المستخدم المسجّل محليًا.
class UserProfile {
  const UserProfile({
    required this.name,
    this.email = '',
    this.id,
    this.provider = 'local',
  });

  final String name;
  final String email;

  /// معرّف الحساب الحقيقي (Supabase). null = زائر محلي.
  final String? id;

  /// email | google | apple | local
  final String provider;

  bool get hasAccount => id != null;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    if (id != null) 'id': id,
    'provider': provider,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    id: json['id'] as String?,
    provider: json['provider'] as String? ?? 'local',
  );
}

/// أدوات تحويل التاريخ من/إلى مفتاح نصي `yyyy-MM-dd`.
abstract final class DateKey {
  static String fromDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? tryParse(String? key) {
    if (key == null || key.isEmpty) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}
