import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_info.dart';
import '../core/auth/auth_gateway.dart';
import '../core/cloud_backup_service.dart';

import '../models/models.dart';

/// إحصائيات شهر واحد.
class MonthStats {
  const MonthStats({
    required this.applicable,
    required this.done,
    required this.late,
    required this.missed,
  });

  final int applicable;
  final int done;
  final int late;
  final int missed;

  int get remaining => applicable - done;
  int get pct => applicable > 0 ? ((done / applicable) * 100).round() : 0;
}

/// مستوى المستخدم المحسوب من نقاط الخبرة.
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.current,
    required this.per,
  });

  final int level;
  final int current;
  final int per;

  int get pct => ((current / per) * 100).round();
}

/// الحالة المركزية للتطبيق: الإعدادات، الحساب، المهام، التصنيفات،
/// والاشتراك — مع حفظ تلقائي في [SharedPreferences].
class AppState extends ChangeNotifier {
  AppState._(this._prefs);

  static const _storageKey = 'waqti.v1';
  static const freePlanTaskLimit = 5;
  static const xpPerDone = 10;
  static const xpPerLate = 4;
  static const xpPerLevel = 300;

  final SharedPreferences _prefs;

  // ---------- الإعدادات ----------
  String lang = 'ar';
  ThemeMode themeMode = ThemeMode.light;
  bool notifMaster = true;
  bool morningRecap = true;
  bool eveningRecap = false;

  /// ساعات الهدوء: لا تذكيرات بين البداية والنهاية (بالدقائق منذ منتصف الليل).
  bool quietHoursOn = true;
  int quietStart = 22 * 60;
  int quietEnd = 7 * 60;

  /// هل شاهد المستخدم الجولة التعريفية؟
  bool onboarded = false;

  // ---------- الحساب ----------
  bool loggedIn = false;
  UserProfile? user;

  // ---------- الاشتراك ----------
  PlanTier tier = PlanTier.free;
  String billingCycle = 'monthly';

  bool get isPremium => tier != PlanTier.free;

  // ---------- البيانات ----------
  List<TaskCategory> categories = [];
  List<TaskItem> tasks = [];
  List<String> customIcons = [];
  List<int> customColors = [];

  /// دقائق التركيز (مؤقت بومودورو) مفهرسة بمفتاح التاريخ.
  Map<String, int> focusLog = {};

  // ---- الحساب والنسخة السحابية (تُحقن من main) ----
  AuthGateway auth = const NoAuthGateway();
  CloudBackupGateway cloud = const NoCloudBackupGateway();
  StreamSubscription<AuthEvent>? _authSub;
  Timer? _cloudTimer;

  /// آخر تغيير محلي في البيانات (للمقارنة مع السحابي).
  DateTime? lastChangedAt;

  /// آخر حفظ سحابي ناجح.
  DateTime? lastCloudSyncAt;
  CloudStatus cloudStatus = CloudStatus.idle;

  /// وصلنا رابط استرجاع كلمة مرور — تعرض الواجهة شاشة كلمة المرور الجديدة.
  bool passwordRecoveryPending = false;

  bool get hasAccount => user?.hasAccount ?? false;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState._(prefs);
    state._restore();
    return state;
  }

  // =======================================================================
  // الحفظ والاستعادة
  // =======================================================================

  void _restore() {
    // حتى قراءة المفتاح نفسها قد ترمي إذا كان المخزون بنوع غير متوقع —
    // تلف التخزين يجب ألا يمنع التطبيق من الإقلاع أبدًا.
    final String? raw;
    try {
      raw = _prefs.getString(_storageKey);
    } catch (_) {
      categories = _defaultCategories();
      return;
    }
    if (raw == null) {
      categories = _defaultCategories();
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      lang = json['lang'] as String? ?? 'ar';
      themeMode = switch (json['theme'] as String?) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
      notifMaster = json['notifMaster'] as bool? ?? true;
      morningRecap = json['morningRecap'] as bool? ?? true;
      eveningRecap = json['eveningRecap'] as bool? ?? false;
      quietHoursOn = json['quietOn'] as bool? ?? true;
      quietStart = (json['quietStart'] as num?)?.toInt() ?? 22 * 60;
      quietEnd = (json['quietEnd'] as num?)?.toInt() ?? 7 * 60;
      onboarded = json['onboarded'] as bool? ?? false;
      loggedIn = json['loggedIn'] as bool? ?? false;
      lastChangedAt = DateTime.tryParse(json['changedAt'] as String? ?? '');
      lastCloudSyncAt = DateTime.tryParse(json['cloudSyncAt'] as String? ?? '');
      user = json['user'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : null;
      // ترحيل: بيانات قديمة بـ isPremium فقط تُرفع للذهبي.
      tier = json.containsKey('tier')
          ? PlanTier.fromKey(json['tier'] as String?)
          : ((json['isPremium'] as bool? ?? false)
                ? PlanTier.gold
                : PlanTier.free);
      billingCycle = json['billingCycle'] as String? ?? 'monthly';
      categories = ((json['categories'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskCategory.fromJson)
          .toList();
      tasks = ((json['tasks'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskItem.fromJson)
          .toList();
      customIcons = ((json['customIcons'] as List?) ?? const [])
          .whereType<String>()
          .toList();
      customColors = ((json['customColors'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toList();
      focusLog = {};
      ((json['focus'] as Map?) ?? const {}).forEach((k, v) {
        if (v is num) focusLog[k as String] = v.toInt();
      });
      if (categories.isEmpty && tasks.isEmpty) {
        categories = _defaultCategories();
      }
    } catch (_) {
      // بيانات تالفة — نبدأ من جديد بدل تعطيل التطبيق.
      categories = _defaultCategories();
    }
  }

  Future<void> _persist() async {
    final json = <String, dynamic>{
      'lang': lang,
      'theme': switch (themeMode) {
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
        ThemeMode.light => 'light',
      },
      'notifMaster': notifMaster,
      'morningRecap': morningRecap,
      'eveningRecap': eveningRecap,
      'quietOn': quietHoursOn,
      'quietStart': quietStart,
      'quietEnd': quietEnd,
      'onboarded': onboarded,
      'loggedIn': loggedIn,
      if (lastChangedAt != null) 'changedAt': lastChangedAt!.toIso8601String(),
      if (lastCloudSyncAt != null)
        'cloudSyncAt': lastCloudSyncAt!.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
      'tier': tier.name,
      'billingCycle': billingCycle,
      'categories': categories.map((c) => c.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'customIcons': customIcons,
      'customColors': customColors,
      'focus': focusLog,
    };
    final encoded = jsonEncode(json);
    await _prefs.setString(_storageKey, encoded);
    _rollDailyBackup(encoded);
  }

  static const _backupKey = 'waqti.backup.v1';
  static const _backupDateKey = 'waqti.backup.date';

  /// نسخة احتياطية محلية واحدة يوميًا (أول حفظ في اليوم يحفظ حالة
  /// اليوم السابق) — تحمي من الحذف الخاطئ أو استيراد ملف تالف.
  void _rollDailyBackup(String encoded) {
    try {
      final today = DateKey.fromDate(DateTime.now());
      if (_prefs.getString(_backupDateKey) == today) return;
      _prefs.setString(_backupKey, encoded);
      _prefs.setString(_backupDateKey, today);
    } catch (_) {}
  }

  /// تاريخ آخر نسخة احتياطية محلية إن وُجدت.
  DateTime? get backupDate {
    try {
      return DateKey.tryParse(_prefs.getString(_backupDateKey));
    } catch (_) {
      return null;
    }
  }

  /// يستعيد النسخة الاحتياطية المحلية. يرجع `false` إن لم توجد.
  bool restoreBackup() {
    final String? raw;
    try {
      raw = _prefs.getString(_backupKey);
    } catch (_) {
      return false;
    }
    if (raw == null) return false;
    return importJson(raw, full: true);
  }

  void _commit() {
    lastChangedAt = DateTime.now().toUtc();
    _persist();
    notifyListeners();
    _scheduleCloudPush();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cloudTimer?.cancel();
    super.dispose();
  }

  static List<TaskCategory> _defaultCategories() => [
    const TaskCategory(id: 'c1', name: 'روحانيات', colorValue: 0xFF6E8F72),
    const TaskCategory(id: 'c2', name: 'صحة', colorValue: 0xFFE3A93F),
    const TaskCategory(id: 'c3', name: 'تطوير ذاتي', colorValue: 0xFF4C8DE0),
    const TaskCategory(id: 'c4', name: 'إنتاجية', colorValue: 0xFF8E6CE0),
  ];

  // =======================================================================
  // الإعدادات
  // =======================================================================

  void setLang(String value) {
    if (lang == value) return;
    lang = value;
    _commit();
  }

  void setThemeMode(ThemeMode value) {
    if (themeMode == value) return;
    themeMode = value;
    _commit();
  }

  void setNotifMaster(bool value) {
    notifMaster = value;
    _commit();
  }

  void setMorningRecap(bool value) {
    morningRecap = value;
    _commit();
  }

  void setEveningRecap(bool value) {
    eveningRecap = value;
    _commit();
  }

  void setQuietHours({bool? on, int? start, int? end}) {
    quietHoursOn = on ?? quietHoursOn;
    quietStart = start ?? quietStart;
    quietEnd = end ?? quietEnd;
    _commit();
  }

  /// هل الدقيقة [minuteOfDay] داخل ساعات الهدوء؟ (يدعم النطاق العابر لمنتصف الليل)
  bool isQuietAt(int minuteOfDay) {
    if (!quietHoursOn) return false;
    if (quietStart <= quietEnd) {
      return minuteOfDay >= quietStart && minuteOfDay < quietEnd;
    }
    return minuteOfDay >= quietStart || minuteOfDay < quietEnd;
  }

  void setOnboarded() {
    if (onboarded) return;
    onboarded = true;
    _commit();
  }

  // =======================================================================
  // الحساب: زائر محلي أو حساب حقيقي عبر AuthGateway + نسخة سحابية
  // =======================================================================

  /// يربط خدمات المصادقة والسحابة (يُستدعى مرة من main). يستعيد جلسة محفوظة.
  void attachServices({
    required AuthGateway authGateway,
    required CloudBackupGateway cloudGateway,
  }) {
    auth = authGateway;
    cloud = cloudGateway;
    _authSub?.cancel();
    _authSub = auth.events.listen(_onAuthEvent);
    final current = auth.currentUser;
    if (current != null) {
      unawaited(onSignedIn(current));
    } else if (hasAccount) {
      // جلسة الخادم انتهت بينما التطبيق يظن أنه مسجّل — نعود لشاشة الدخول.
      _clearLocalAccount(wipeData: true);
    }
  }

  void _onAuthEvent(AuthEvent event) {
    switch (event) {
      case AuthEvent.signedIn:
        final u = auth.currentUser;
        if (u != null && (user?.id != u.id || !loggedIn)) {
          unawaited(onSignedIn(u));
        }
      case AuthEvent.signedOut:
        if (hasAccount) _clearLocalAccount(wipeData: true);
      case AuthEvent.passwordRecovery:
        passwordRecoveryPending = true;
        notifyListeners();
      case AuthEvent.userUpdated:
        final u = auth.currentUser;
        if (u != null && hasAccount) {
          user = UserProfile(
            name: u.name,
            email: u.email,
            id: u.id,
            provider: u.provider,
          );
          _commit();
        }
    }
  }

  /// بعد دخول حقيقي: حفظ الملف الشخصي ثم مصالحة البيانات مع السحابة.
  Future<void> onSignedIn(AuthUser u) async {
    user = UserProfile(
      name: u.name,
      email: u.email,
      id: u.id,
      provider: u.provider,
    );
    loggedIn = true;
    _commit();
    await syncWithCloud();
  }

  /// مصالحة الدخول: السحابي أحدث → استيراد؛ المحلي أحدث → رفع.
  Future<void> syncWithCloud() async {
    if (!hasAccount || !cloud.isAvailable) return;
    cloudStatus = CloudStatus.syncing;
    notifyListeners();
    try {
      final remote = await cloud.fetch();
      final decision = decideSync(
        remoteUpdatedAt: remote?.updatedAt,
        localChangedAt: lastCloudSyncAt == null ? lastChangedAt : lastChangedAt,
        localHasData: tasks.isNotEmpty,
      );
      switch (decision) {
        case SyncDecision.pullRemote:
          _applyCloudPayload(remote!.payload);
          lastCloudSyncAt = remote.updatedAt;
          lastChangedAt = remote.updatedAt;
          await _persist();
        case SyncDecision.pushLocal:
          lastCloudSyncAt = await cloud.push(
            cloudPayload(),
            appVersion: kAppVersion,
          );
          await _persist();
        case SyncDecision.nothing:
          lastCloudSyncAt ??= remote?.updatedAt;
      }
      cloudStatus = CloudStatus.synced;
    } catch (_) {
      cloudStatus = CloudStatus.error;
    }
    notifyListeners();
  }

  /// ملف السحابة: البيانات فقط (لا إعدادات الجهاز ولا حالة الدخول).
  String cloudPayload() => jsonEncode({
    'v': 1,
    'categories': categories.map((c) => c.toJson()).toList(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'customIcons': customIcons,
    'customColors': customColors,
    'focus': focusLog,
  });

  void _applyCloudPayload(String payload) {
    importJson(payload, full: true);
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      customIcons = ((json['customIcons'] as List?) ?? const [])
          .whereType<String>()
          .toList();
      customColors = ((json['customColors'] as List?) ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList();
    } catch (_) {}
  }

  /// رفع مؤجَّل (3 ث) بعد كل تغيير — يدمج التغييرات المتتالية في طلب واحد.
  void _scheduleCloudPush() {
    if (!hasAccount || !cloud.isAvailable) return;
    _cloudTimer?.cancel();
    _cloudTimer = Timer(const Duration(seconds: 3), () async {
      cloudStatus = CloudStatus.syncing;
      notifyListeners();
      try {
        lastCloudSyncAt = await cloud.push(
          cloudPayload(),
          appVersion: kAppVersion,
        );
        cloudStatus = CloudStatus.synced;
        await _persist();
      } catch (_) {
        cloudStatus = CloudStatus.error;
      }
      notifyListeners();
    });
  }

  /// يُستدعى بعد فشل سابق أو من زر «إعادة المحاولة».
  void retryCloudPush() => _scheduleCloudPush();

  void signInAsGuest(String guestLabel) {
    user = UserProfile(name: guestLabel);
    loggedIn = true;
    _commit();
  }

  /// خروج: حساب حقيقي → إنهاء الجلسة ومسح النسخة المحلية؛ زائر → إبقاء البيانات.
  Future<void> signOut() async {
    if (hasAccount) {
      _cloudTimer?.cancel();
      try {
        if (cloud.isAvailable && lastChangedAt != null) {
          lastCloudSyncAt = await cloud.push(
            cloudPayload(),
            appVersion: kAppVersion,
          );
        }
      } catch (_) {}
      await auth.signOut();
      _clearLocalAccount(wipeData: true);
      return;
    }
    loggedIn = false;
    user = null;
    _commit();
  }

  Future<void> deleteAccount() async {
    _cloudTimer?.cancel();
    await auth.deleteAccount();
    _clearLocalAccount(wipeData: true);
  }

  void _clearLocalAccount({required bool wipeData}) {
    loggedIn = false;
    user = null;
    passwordRecoveryPending = false;
    cloudStatus = CloudStatus.idle;
    lastCloudSyncAt = null;
    if (wipeData) {
      tasks = [];
      categories = _defaultCategories();
      focusLog = {};
      lastChangedAt = null;
    }
    _commit();
  }

  Future<void> completePasswordRecovery(String newPassword) async {
    await auth.updatePassword(newPassword);
    passwordRecoveryPending = false;
    notifyListeners();
  }

  // =======================================================================
  // الاشتراك (محاكاة — بدون دفع فعلي)
  // =======================================================================

  void setBillingCycle(String cycle) {
    billingCycle = cycle;
    _commit();
  }

  void setTier(PlanTier value) {
    tier = value;
    _commit();
  }

  /// توافق خلفي مع الاختبارات والاستدعاءات القديمة.
  void setPremium(bool value) => setTier(value ? PlanTier.gold : PlanTier.free);

  // =======================================================================
  // المهام
  // =======================================================================

  /// قابل للتعديل في الاختبارات؛ الافتراضي من [kLaunchMode].
  static bool launchMode = kLaunchMode;

  bool get canAddTask {
    if (launchMode) return true;
    final limit = tier.taskLimit;
    return limit == null || tasks.length < limit;
  }

  TaskItem? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  TaskCategory? categoryById(String? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// يضيف مهمة جديدة. يرجع `false` عند بلوغ حد الخطة المجانية.
  bool addTask(TaskItem task) {
    if (!canAddTask) return false;
    tasks.add(task);
    _commit();
    return true;
  }

  void updateTask(TaskItem task) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    tasks[index] = task;
    _commit();
  }

  /// يحذف المهمة ويرجعها مع موضعها للسماح بالتراجع.
  (TaskItem, int)? removeTask(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = tasks.removeAt(index);
    _commit();
    return (removed, index);
  }

  /// يعيد ترتيب المهام (سحب وإفلات في تبويب المهام).
  void reorderTask(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= tasks.length) return;
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    final task = tasks.removeAt(oldIndex);
    tasks.insert(target.clamp(0, tasks.length), task);
    _commit();
  }

  /// يزرع بيانات تجريبية (ضمن حد الخطة المجانية) مع سجل إنجاز
  /// عشوائي واقعي للأيام الماضية من الشهر الحالي — للاستكشاف السريع.
  void seedDemoData() {
    if (tasks.isNotEmpty) return;
    final demo = [
      TaskItem(
        id: TaskItem.newId(),
        name: 'الصلاة في وقتها',
        icon: '🙏',
        colorValue: 0xFF6E8F72,
        categoryId: 'c1',
        priority: TaskPriority.high,
      ),
      TaskItem(
        id: TaskItem.newId(),
        name: 'قراءة القرآن',
        icon: '📖',
        colorValue: 0xFF6E8F72,
        categoryId: 'c1',
        priority: TaskPriority.high,
      ),
      TaskItem(
        id: TaskItem.newId(),
        name: 'الرياضة',
        icon: '🏃‍♂️',
        colorValue: 0xFFE3A93F,
        categoryId: 'c2',
      ),
      TaskItem(
        id: TaskItem.newId(),
        name: 'قراءة كتاب',
        icon: '📚',
        colorValue: 0xFF4C8DE0,
        categoryId: 'c3',
        priority: TaskPriority.low,
        recurrence: const Recurrence(
          type: RecurrenceType.specificDays,
          days: [0, 2, 4],
        ),
      ),
      TaskItem(
        id: TaskItem.newId(),
        name: 'شرب 2 لتر ماء',
        icon: '💧',
        colorValue: 0xFF3FB6B0,
        categoryId: 'c2',
      ),
    ];
    final random = Random();
    final today = DateTime.now();
    for (final task in demo) {
      for (var back = 1; back <= today.day - 1; back++) {
        final date = DateTime(today.year, today.month, today.day - back);
        if (!task.isApplicableOn(date)) continue;
        final roll = random.nextDouble();
        task.setStatusOn(
          date,
          roll < 0.72
              ? TaskStatus.done
              : (roll < 0.87 ? TaskStatus.doneLate : TaskStatus.missed),
        );
      }
    }
    tasks.addAll(demo);
    _commit();
  }

  void restoreTask(TaskItem task, int index) {
    tasks.insert(index.clamp(0, tasks.length), task);
    _commit();
  }

  /// يقلّب حالة اليوم: بدون حالة ← منجز ← متأخر ← فائت ← راحة ← بدون حالة.
  void cycleStatus(String taskId, DateTime date) {
    final task = taskById(taskId);
    if (task == null || !task.isApplicableOn(date)) return;
    final next = switch (task.statusOn(date)) {
      null => TaskStatus.done,
      TaskStatus.done => TaskStatus.doneLate,
      TaskStatus.doneLate => TaskStatus.missed,
      TaskStatus.missed => TaskStatus.skipped,
      TaskStatus.skipped => null,
    };
    _applyStatus(task, date, next);
    _commit();
  }

  /// يضبط حالة يوم مباشرةً (من نافذة التفاصيل مثلًا).
  void setStatus(String taskId, DateTime date, TaskStatus? status) {
    final task = taskById(taskId);
    if (task == null || !task.isApplicableOn(date)) return;
    _applyStatus(task, date, status);
    _commit();
  }

  void _applyStatus(TaskItem task, DateTime date, TaskStatus? status) {
    task.setStatusOn(date, status);
    if (!task.isMeasurable) return;
    // التقدم الكمي يتبع الحالة: منجز = الهدف كاملًا، بلا حالة = صفر.
    if (status == null) {
      task.setProgressOn(date, 0);
    } else if (status.isCompleted) {
      task.setProgressOn(date, task.target);
    }
  }

  /// عادة قابلة للقياس: زيادة تقدم اليوم بخطوة؛ بلوغ الهدف يعني الإنجاز.
  void incrementProgress(String taskId, DateTime date, {int step = 1}) {
    final task = taskById(taskId);
    if (task == null || !task.isApplicableOn(date)) return;
    final next = (task.progressOn(date) + step).clamp(0, task.target);
    task.setProgressOn(date, next);
    if (next >= task.target) {
      task.setStatusOn(date, TaskStatus.done);
    } else if (task.statusOn(date)?.isCompleted ?? false) {
      task.setStatusOn(date, null);
    }
    _commit();
  }

  /// إيقاف مؤقت / استئناف مع الاحتفاظ بالسجل السابق.
  void setPaused(String taskId, bool paused) {
    final task = taskById(taskId);
    if (task == null) return;
    final now = DateTime.now();
    task.pausedAt = paused ? DateTime(now.year, now.month, now.day) : null;
    _commit();
  }

  /// يوميات: ملاحظة يوم لمهمة.
  void setNote(String taskId, DateTime date, String text) {
    final task = taskById(taskId);
    if (task == null) return;
    task.setNoteOn(date, text);
    _commit();
  }

  void toggleSubtask(String taskId, int index) {
    final task = taskById(taskId);
    if (task == null || index < 0 || index >= task.subtasks.length) return;
    task.subtasks[index].done = !task.subtasks[index].done;
    _commit();
  }

  /// عادة إقلاع: عدد الأيام منذ آخر زلّة (أو منذ الإنشاء إن لم تحدث).
  int daysSinceSlip(TaskItem task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime? lastSlip;
    task.statuses.forEach((key, status) {
      if (status != TaskStatus.missed) return;
      final d = DateKey.tryParse(key);
      if (d != null && (lastSlip == null || d.isAfter(lastSlip!))) lastSlip = d;
    });
    final from =
        lastSlip ??
        DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
    final days = today.difference(from).inDays;
    return days < 0 ? 0 : days;
  }

  // =======================================================================
  // مؤقت التركيز
  // =======================================================================

  void addFocusMinutes(int minutes, {DateTime? date}) {
    if (minutes <= 0) return;
    final key = DateKey.fromDate(date ?? DateTime.now());
    focusLog[key] = (focusLog[key] ?? 0) + minutes;
    _commit();
  }

  int focusMinutesOn(DateTime date) => focusLog[DateKey.fromDate(date)] ?? 0;

  int focusMinutesInMonth(int year, int month) {
    var total = 0;
    focusLog.forEach((key, minutes) {
      final d = DateKey.tryParse(key);
      if (d != null && d.year == year && d.month == month) total += minutes;
    });
    return total;
  }

  void addCustomIcon(String icon) {
    if (icon.isEmpty || customIcons.contains(icon)) return;
    customIcons.add(icon);
    _commit();
  }

  void addCustomColor(int colorValue) {
    if (customColors.contains(colorValue)) return;
    customColors.add(colorValue);
    _commit();
  }

  // =======================================================================
  // التصنيفات
  // =======================================================================

  TaskCategory addCategory(String name, int colorValue) {
    final category = TaskCategory(
      id: TaskItem.newId(),
      name: name,
      colorValue: colorValue,
    );
    categories.add(category);
    _commit();
    return category;
  }

  void removeCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    for (final t in tasks) {
      if (t.categoryId == id) t.categoryId = null;
    }
    _commit();
  }

  // =======================================================================
  // اليوم والمتأخرات
  // =======================================================================

  /// المهام مرتبة تنازليًا بالأولوية (عاجلة أولًا) مع ثبات الترتيب اليدوي
  /// داخل الأولوية الواحدة.
  static List<TaskItem> sortedByPriority(List<TaskItem> list) {
    final indexed = list.asMap().entries.toList()
      ..sort((a, b) {
        final byPriority = b.value.priority.index.compareTo(
          a.value.priority.index,
        );
        return byPriority != 0 ? byPriority : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  /// المهام المتأخرة: أيام مستحقة خلال آخر [lookBackDays] يومًا
  /// (قبل اليوم) بقيت بلا أي حالة. الأحدث أولًا ثم الأعلى أولوية.
  List<({TaskItem task, DateTime date})> overdueEntries({
    int lookBackDays = 7,
  }) {
    final now = DateTime.now();
    final entries = <({TaskItem task, DateTime date})>[];
    for (var back = 1; back <= lookBackDays; back++) {
      final date = DateTime(now.year, now.month, now.day - back);
      for (final task in sortedByPriority(tasks)) {
        // عادة الإقلاع: يوم بلا تسجيل = بلا زلّة، فلا تُعدّ متأخرة.
        if (task.isQuit) continue;
        final created = DateTime(
          task.createdAt.year,
          task.createdAt.month,
          task.createdAt.day,
        );
        if (date.isBefore(created)) continue; // لا تأخر قبل وجود المهمة
        if (task.isApplicableOn(date) && task.statusOn(date) == null) {
          entries.add((task: task, date: date));
        }
      }
    }
    return entries;
  }

  // =======================================================================
  // الإحصائيات
  // =======================================================================

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  MonthStats monthStats(int year, int month, {List<TaskItem>? subset}) {
    final list = subset ?? tasks;
    final dim = daysInMonth(year, month);
    int applicable = 0, done = 0, late = 0, missed = 0;
    for (final task in list) {
      for (var d = 1; d <= dim; d++) {
        final date = DateTime(year, month, d);
        if (!task.isApplicableOn(date)) continue;
        final status = task.statusOn(date);
        if (status == TaskStatus.skipped) continue; // يوم راحة لا يُحسب
        applicable++;
        switch (status) {
          case TaskStatus.done:
            done++;
          case TaskStatus.doneLate:
            late++;
          case TaskStatus.missed:
            missed++;
          case TaskStatus.skipped || null:
            break;
        }
      }
    }
    return MonthStats(
      applicable: applicable,
      done: done,
      late: late,
      missed: missed,
    );
  }

  /// عدد الأيام المتتالية (انتهاءً باليوم) التي أُنجزت فيها كل المهام
  /// المستحقة. الإنجاز المتأخر يُنقذ السلسلة، ويوم الراحة لا يقطعها
  /// ولا يُحسب، والأيام بلا مهام مستحقة لا تقطع التتابع.
  int currentStreak() {
    var date = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 730; i++) {
      final day = DateTime(date.year, date.month, date.day);
      final relevant = tasks
          .where(
            (t) =>
                t.isApplicableOn(day) && t.statusOn(day) != TaskStatus.skipped,
          )
          .toList(growable: false);
      if (relevant.isNotEmpty) {
        final allDone = relevant.every(
          (t) => t.statusOn(day)?.isCompleted ?? false,
        );
        if (!allDone) {
          // اليوم الحالي وما زال مفتوحًا (لا فوات مسجّل) لا يكسر السلسلة —
          // وإلا لظهر "0" كل صباح قبل أول إنجاز.
          final todayStillOpen =
              i == 0 &&
              relevant.every((t) => t.statusOn(day) != TaskStatus.missed);
          if (!todayStillOpen) break;
        } else {
          streak++;
        }
      }
      // نطرح يومًا بمكوّنات التاريخ لا بـ Duration حتى لا يُقفَز
      // فوق يوم عند تحول التوقيت الصيفي.
      date = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  /// إجمالي الإنجازات المكتملة (في الوقت أو متأخرة) عبر كل الأيام.
  int totalDone() {
    var count = 0;
    for (final task in tasks) {
      for (final status in task.statuses.values) {
        if (status == TaskStatus.done || status == TaskStatus.doneLate) {
          count++;
        }
      }
    }
    return count;
  }

  /// درجة عادة مرنة (نموذج Loop): متوسط أسّي على آخر 60 يومًا مستحقًا؛
  /// اليوم الفائت يُنقص الدرجة تدريجيًا بدل تصفير كل شيء. 0–100.
  int habitScore(TaskItem task, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    var score = 0.0;
    const alpha = 0.12; // 1 - 0.88: نصف عمر ≈ 5 أيام مستحقة
    var counted = 0;
    var date = DateTime(now.year, now.month, now.day - 120);
    final today = DateTime(now.year, now.month, now.day);
    while (!date.isAfter(today)) {
      final created = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      if (!date.isBefore(created) && task.isApplicableOn(date)) {
        final status = task.statusOn(date);
        if (status != TaskStatus.skipped) {
          final isToday = date == today;
          // اليوم الحالي غير المكتمل بعد لا يُحسب ضده.
          if (!(isToday && status == null)) {
            final value = (status?.isCompleted ?? false) ? 1.0 : 0.0;
            score = score * (1 - alpha) + value * alpha;
            counted++;
          }
        }
      }
      date = DateTime(date.year, date.month, date.day + 1);
    }
    if (counted == 0) return 0;
    // تطبيع: بعد n أيام يكون أقصى ممكن (1-(1-a)^n)؛ نقسم عليه حتى تبدأ
    // العادة الجديدة من درجة عادلة.
    final maxPossible = 1 - _pow(1 - alpha, counted);
    return ((score / maxPossible) * 100).round().clamp(0, 100);
  }

  static double _pow(double base, int exp) {
    var r = 1.0;
    for (var i = 0; i < exp; i++) {
      r *= base;
    }
    return r;
  }

  /// متوسط درجات العادات النشطة.
  int overallScore() {
    final active = tasks.where((t) => !t.isPaused).toList(growable: false);
    if (active.isEmpty) return 0;
    final total = active.fold<int>(0, (sum, t) => sum + habitScore(t));
    return (total / active.length).round();
  }

  /// أطول سلسلة لمهمة واحدة عبر كل الوقت (أيام مستحقة متتالية مكتملة؛
  /// يوم الراحة لا يقطع).
  int taskBestStreak(TaskItem task) {
    final keys = task.statuses.keys.map(DateKey.tryParse).whereType<DateTime>();
    if (keys.isEmpty) return 0;
    var date = keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    var best = 0, run = 0;
    while (!date.isAfter(end)) {
      if (task.isApplicableOn(date)) {
        final status = task.statusOn(date);
        if (status?.isCompleted ?? false) {
          run++;
          if (run > best) best = run;
        } else if (status != TaskStatus.skipped && date != end) {
          run = 0;
        }
      }
      date = DateTime(date.year, date.month, date.day + 1);
    }
    return best;
  }

  /// أطول سلسلة إجمالية (كل المهام المستحقة مكتملة) عبر كل الوقت.
  int longestStreak() {
    DateTime? first;
    for (final t in tasks) {
      for (final k in t.statuses.keys) {
        final d = DateKey.tryParse(k);
        if (d != null && (first == null || d.isBefore(first))) first = d;
      }
    }
    if (first == null) return 0;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    var date = first;
    var best = 0, run = 0;
    while (!date.isAfter(end)) {
      final relevant = tasks.where(
        (t) => t.isApplicableOn(date) && t.statusOn(date) != TaskStatus.skipped,
      );
      if (relevant.isNotEmpty) {
        final allDone = relevant.every(
          (t) => t.statusOn(date)?.isCompleted ?? false,
        );
        if (allDone) {
          run++;
          if (run > best) best = run;
        } else if (date != end) {
          run = 0;
        }
      }
      date = DateTime(date.year, date.month, date.day + 1);
    }
    return best;
  }

  int totalXp() {
    var xp = 0;
    for (final task in tasks) {
      for (final status in task.statuses.values) {
        if (status == TaskStatus.done) xp += xpPerDone;
        if (status == TaskStatus.doneLate) xp += xpPerLate;
      }
    }
    return xp;
  }

  LevelInfo levelInfo() {
    final xp = totalXp();
    return LevelInfo(
      level: xp ~/ xpPerLevel + 1,
      current: xp % xpPerLevel,
      per: xpPerLevel,
    );
  }

  /// نسبة التزام مهمة واحدة خلال شهر معيّن.
  int taskCommitment(TaskItem task, int year, int month) {
    final dim = daysInMonth(year, month);
    int applicable = 0, done = 0;
    for (var d = 1; d <= dim; d++) {
      final date = DateTime(year, month, d);
      if (!task.isApplicableOn(date)) continue;
      final status = task.statusOn(date);
      if (status == TaskStatus.skipped) continue;
      applicable++;
      if (status == TaskStatus.done) done++;
    }
    return applicable > 0 ? ((done / applicable) * 100).round() : 0;
  }

  /// عدد المهام المنجزة لكل يوم من الشهر (لرسم منحنى الإنجازات).
  List<int> dailyDoneCounts(int year, int month) {
    final dim = daysInMonth(year, month);
    return List.generate(dim, (i) {
      final date = DateTime(year, month, i + 1);
      return tasks.where((t) => t.statusOn(date) == TaskStatus.done).length;
    });
  }

  /// نسبة إنجاز يوم واحد (لخريطة السنة الحرارية).
  /// ترجع -1 إذا لم تكن هناك مهام مستحقة في ذلك اليوم.
  int dailyCompletionPct(DateTime date) {
    var applicable = 0, done = 0;
    for (final task in tasks) {
      if (!task.isApplicableOn(date)) continue;
      final status = task.statusOn(date);
      if (status == TaskStatus.skipped) continue;
      applicable++;
      if (status == TaskStatus.done) done++;
    }
    if (applicable == 0) return -1;
    return ((done / applicable) * 100).round();
  }

  /// نسب الإنجاز الأسبوعية (كل 7 أيام من الشهر).
  List<({String label, int pct})> weeklyBuckets(int year, int month) {
    final dim = daysInMonth(year, month);
    final buckets = <({String label, int pct})>[];
    for (var start = 1; start <= dim; start += 7) {
      final end = (start + 6).clamp(1, dim);
      int applicable = 0, done = 0;
      for (final task in tasks) {
        for (var d = start; d <= end; d++) {
          final date = DateTime(year, month, d);
          if (!task.isApplicableOn(date)) continue;
          final status = task.statusOn(date);
          if (status == TaskStatus.skipped) continue;
          applicable++;
          if (status == TaskStatus.done) done++;
        }
      }
      buckets.add((
        label: '$start-$end',
        pct: applicable > 0 ? ((done / applicable) * 100).round() : 0,
      ));
    }
    return buckets;
  }

  ({TaskItem task, int pct})? bestHabit(int year, int month) =>
      _extremeHabit(year, month, best: true);

  ({TaskItem task, int pct})? worstHabit(int year, int month) =>
      _extremeHabit(year, month, best: false);

  ({TaskItem task, int pct})? _extremeHabit(
    int year,
    int month, {
    required bool best,
  }) {
    if (tasks.isEmpty) return null;
    final ranked =
        tasks
            .map((t) => (task: t, pct: taskCommitment(t, year, month)))
            .toList()
          ..sort((a, b) => b.pct.compareTo(a.pct));
    return best ? ranked.first : ranked.last;
  }

  // =======================================================================
  // تصدير واستيراد البيانات
  // =======================================================================

  String exportJson() {
    final payload = {
      'app': 'waqti',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// تصدير CSV: صف لكل (مهمة، يوم) له حالة — يُفتح في Excel/Sheets.
  String exportCsv() {
    final buffer = StringBuffer('task,date,status,progress,note\n');
    String esc(String v) => '"${v.replaceAll('"', '""')}"';
    for (final task in tasks) {
      final keys = task.statuses.keys.toList()..sort();
      for (final key in keys) {
        final status = task.statuses[key]!.key;
        final progress = task.progress[key]?.toString() ?? '';
        final note = task.notes[key] ?? '';
        buffer.writeln('${esc(task.name)},$key,$status,$progress,${esc(note)}');
      }
    }
    return buffer.toString();
  }

  /// يرجع `true` عند نجاح الاستيراد. مع [full] يستعيد الإعدادات أيضًا
  /// (للنسخة الاحتياطية المحلية).
  bool importJson(String raw, {bool full = false}) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (full) {
        focusLog = {};
        ((json['focus'] as Map?) ?? const {}).forEach((k, v) {
          if (v is num) focusLog[k as String] = v.toInt();
        });
      }
      final newCategories = ((json['categories'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskCategory.fromJson)
          .toList();
      final newTasks = ((json['tasks'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskItem.fromJson)
          .toList();
      if (newCategories.isEmpty && newTasks.isEmpty) return false;
      if (newCategories.isNotEmpty) categories = newCategories;
      if (newTasks.isNotEmpty) tasks = newTasks;
      _commit();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// حالة النسخة السحابية للعرض في الإعدادات.
enum CloudStatus { idle, syncing, synced, error }
