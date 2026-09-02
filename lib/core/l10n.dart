/// نصوص التطبيق بالعربية والإنجليزية.
///
/// نستخدم أصنافًا ثابتة الحقول بدل خرائط نصية حتى يكتشف المحلّل
/// أي مفتاح ناقص وقت الترجمة لا وقت التشغيل.
class AppStrings {
  const AppStrings({
    required this.appName,
    required this.home,
    required this.calendar,
    required this.stats,
    required this.tasks,
    required this.achievements,
    required this.settings,
    required this.search,
    required this.monthlySchedule,
    required this.trackDesc,
    required this.completion,
    required this.completed,
    required this.remaining,
    required this.streak,
    required this.xp,
    required this.done,
    required this.late,
    required this.missed,
    required this.none,
    required this.addTask,
    required this.editTask,
    required this.newTask,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.category,
    required this.noCategory,
    required this.priority,
    required this.low,
    required this.medium,
    required this.high,
    required this.urgent,
    required this.overdueTitle,
    required this.overdueHint,
    required this.greetingMorning,
    required this.greetingAfternoon,
    required this.greetingEvening,
    required this.recurrence,
    required this.once,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.specificDays,
    required this.date,
    required this.weekday,
    required this.dayOfMonth,
    required this.chooseDays,
    required this.notifications,
    required this.save,
    required this.cancel,
    required this.delete,
    required this.noTasks,
    required this.categoriesManage,
    required this.addCategory,
    required this.categoryName,
    required this.weekdays,
    required this.weekdaysShort,
    required this.months,
    required this.avgCompletion,
    required this.bestStreak,
    required this.bestHabit,
    required this.worstHabit,
    required this.weeklyChart,
    required this.level,
    required this.yourLevel,
    required this.totalXp,
    required this.language,
    required this.theme,
    required this.light,
    required this.dark,
    required this.notifSettings,
    required this.masterNotif,
    required this.morningRecap,
    required this.eveningRecap,
    required this.dataMgmt,
    required this.exportData,
    required this.importData,
    required this.guestUser,
    required this.taskDetails,
    required this.commitment,
    required this.doneCount,
    required this.missedCount,
    required this.history,
    required this.close,
    required this.noResults,
    required this.achDesc,
    required this.lockedTitle,
    required this.noData,
    required this.login,
    required this.signup,
    required this.welcomeBack,
    required this.createAccountTitle,
    required this.authSubtitle,
    required this.email,
    required this.password,
    required this.fullName,
    required this.forgotPassword,
    required this.orContinueWith,
    required this.continueGoogle,
    required this.continueApple,
    required this.continueGuest,
    required this.noAccount,
    required this.haveAccount,
    required this.fillFields,
    required this.invalidEmail,
    required this.shortPassword,
    required this.resetLinkSent,
    required this.logout,
    required this.logoutConfirm,
    required this.subscription,
    required this.freePlan,
    required this.premiumPlan,
    required this.bronzePlan,
    required this.silverPlan,
    required this.goldPlan,
    required this.allBronzePlus,
    required this.allSilverPlus,
    required this.featTasks15,
    required this.featPrioritySupport,
    required this.subscribedTier,
    required this.habitScore,
    required this.habitScoreHint,
    required this.bestStreak2,
    required this.currentStreak,
    required this.subtasks,
    required this.subtaskHint,
    required this.dayNote,
    required this.dayNoteHint,
    required this.timeSlot,
    required this.slotAny,
    required this.slotMorning,
    required this.slotAfternoon,
    required this.slotEvening,
    required this.reminders,
    required this.addReminder,
    required this.quitHabit,
    required this.quitHint,
    required this.daysClean,
    required this.resisted,
    required this.quietHours,
    required this.quietHoursHint,
    required this.from,
    required this.to,
    required this.restoreBackup,
    required this.backupOf,
    required this.noBackup,
    required this.restored,
    required this.restoreConfirm,
    required this.exportCsv,
    required this.csvCopied,
    required this.filterAll,
    required this.sortManual,
    required this.sortPriority,
    required this.sortName,
    required this.sortScore,
    required this.quoteOfDay,
    required this.onb1Title,
    required this.onb1Body,
    required this.onb2Title,
    required this.onb2Body,
    required this.onb3Title,
    required this.onb3Body,
    required this.onbStart,
    required this.onbSkip,
    required this.onbNext,
    required this.whyHint,
    required this.step,
    required this.skipped,
    required this.skipDay,
    required this.skipHint,
    required this.dailyTarget,
    required this.targetHint,
    required this.unit,
    required this.unitHint,
    required this.quickSuggestions,
    required this.pauseTask,
    required this.resumeTask,
    required this.pausedTag,
    required this.pausedHint,
    required this.focusTimer,
    required this.focusStart,
    required this.focusPause,
    required this.focusResume,
    required this.focusReset,
    required this.focusDoneTitle,
    required this.focusMinutes,
    required this.focusMinutesMonth,
    required this.focusHint,
    required this.markDone,
    required this.chooseTaskOptional,
    required this.noTaskFocus,
    required this.minutesShort,
    required this.overdueRescue,
    required this.reminderTime,
    required this.noReminder,
    required this.hijriSuffix,
    required this.todayFocus,
    required this.monthlyPlan,
    required this.yearlyPlan,
    required this.saveBadge,
    required this.currentPlanTag,
    required this.mostPopular,
    required this.upgradeNow,
    required this.subscribeNow,
    required this.cancelSubscription,
    required this.manageSubscription,
    required this.subscribedMsg,
    required this.cancelledMsg,
    required this.perMonth,
    required this.perYear,
    required this.featAds,
    required this.featUnlimited,
    required this.featSync,
    required this.featBackup,
    required this.featStats,
    required this.featThemes,
    required this.featExport,
    required this.featGoals,
    required this.featFuture,
    required this.freeFeat1,
    required this.freeFeat2,
    required this.freeFeat3,
    required this.adBannerTitle,
    required this.adBannerSub,
    required this.adBannerTag,
    required this.accountSection,
    required this.subscriptionSection,
    required this.freeTag,
    required this.premiumTag,
    required this.dailyTrend,
    required this.tasksAxis,
    required this.customIconLabel,
    required this.customIconPlaceholder,
    required this.customColorLabel,
    required this.addNew,
    required this.enterTaskName,
    required this.deleteTaskConfirm,
    required this.deleteCategoryConfirm,
    required this.undo,
    required this.taskDeleted,
    required this.freeLimitReached,
    required this.exportCopied,
    required this.importHint,
    required this.importSuccess,
    required this.invalidFile,
    required this.hexColorHint,
    required this.simulatedNote,
    required this.today,
    required this.system,
    required this.todayTasks,
    required this.todayAllDone,
    required this.todayNoTasks,
    required this.loadDemoData,
    required this.demoLoaded,
    required this.yearHeatmap,
    required this.heatmapLegendLess,
    required this.heatmapLegendMissed,
    required this.heatmapLegendMore,
    required this.reorderHint,
    required this.about,
    required this.aboutVersion,
    required this.aboutDesc,
  });

  final String appName;
  final String home;
  final String calendar;
  final String stats;
  final String tasks;
  final String achievements;
  final String settings;
  final String search;
  final String monthlySchedule;
  final String trackDesc;
  final String completion;
  final String completed;
  final String remaining;
  final String streak;
  final String xp;
  final String done;
  final String late;
  final String missed;
  final String none;
  final String addTask;
  final String editTask;
  final String newTask;
  final String name;
  final String description;
  final String color;
  final String icon;
  final String category;
  final String noCategory;
  final String priority;
  final String low;
  final String medium;
  final String high;
  final String urgent;
  final String overdueTitle;
  final String overdueHint;
  final String greetingMorning;
  final String greetingAfternoon;
  final String greetingEvening;
  final String recurrence;
  final String once;
  final String daily;
  final String weekly;
  final String monthly;
  final String specificDays;
  final String date;
  final String weekday;
  final String dayOfMonth;
  final String chooseDays;
  final String notifications;
  final String save;
  final String cancel;
  final String delete;
  final String noTasks;
  final String categoriesManage;
  final String addCategory;
  final String categoryName;
  final List<String> weekdays;
  final List<String> weekdaysShort;
  final List<String> months;
  final String avgCompletion;
  final String bestStreak;
  final String bestHabit;
  final String worstHabit;
  final String weeklyChart;
  final String level;
  final String yourLevel;
  final String totalXp;
  final String language;
  final String theme;
  final String light;
  final String dark;
  final String notifSettings;
  final String masterNotif;
  final String morningRecap;
  final String eveningRecap;
  final String dataMgmt;
  final String exportData;
  final String importData;
  final String guestUser;
  final String taskDetails;
  final String commitment;
  final String doneCount;
  final String missedCount;
  final String history;
  final String close;
  final String noResults;
  final String achDesc;
  final String lockedTitle;
  final String noData;
  final String login;
  final String signup;
  final String welcomeBack;
  final String createAccountTitle;
  final String authSubtitle;
  final String email;
  final String password;
  final String fullName;
  final String forgotPassword;
  final String orContinueWith;
  final String continueGoogle;
  final String continueApple;
  final String continueGuest;
  final String noAccount;
  final String haveAccount;
  final String fillFields;
  final String invalidEmail;
  final String shortPassword;
  final String resetLinkSent;
  final String logout;
  final String logoutConfirm;
  final String subscription;
  final String freePlan;
  final String premiumPlan;
  final String bronzePlan;
  final String silverPlan;
  final String goldPlan;
  final String allBronzePlus;
  final String allSilverPlus;
  final String featTasks15;
  final String featPrioritySupport;
  final String subscribedTier;
  final String habitScore;
  final String habitScoreHint;
  final String bestStreak2;
  final String currentStreak;
  final String subtasks;
  final String subtaskHint;
  final String dayNote;
  final String dayNoteHint;
  final String timeSlot;
  final String slotAny;
  final String slotMorning;
  final String slotAfternoon;
  final String slotEvening;
  final String reminders;
  final String addReminder;
  final String quitHabit;
  final String quitHint;
  final String daysClean;
  final String resisted;
  final String quietHours;
  final String quietHoursHint;
  final String from;
  final String to;
  final String restoreBackup;
  final String backupOf;
  final String noBackup;
  final String restored;
  final String restoreConfirm;
  final String exportCsv;
  final String csvCopied;
  final String filterAll;
  final String sortManual;
  final String sortPriority;
  final String sortName;
  final String sortScore;
  final String quoteOfDay;
  final String onb1Title;
  final String onb1Body;
  final String onb2Title;
  final String onb2Body;
  final String onb3Title;
  final String onb3Body;
  final String onbStart;
  final String onbSkip;
  final String onbNext;
  final String whyHint;
  final String step;
  final String skipped;
  final String skipDay;
  final String skipHint;
  final String dailyTarget;
  final String targetHint;
  final String unit;
  final String unitHint;
  final String quickSuggestions;
  final String pauseTask;
  final String resumeTask;
  final String pausedTag;
  final String pausedHint;
  final String focusTimer;
  final String focusStart;
  final String focusPause;
  final String focusResume;
  final String focusReset;
  final String focusDoneTitle;
  final String focusMinutes;
  final String focusMinutesMonth;
  final String focusHint;
  final String markDone;
  final String chooseTaskOptional;
  final String noTaskFocus;
  final String minutesShort;
  final String overdueRescue;
  final String reminderTime;
  final String noReminder;
  final String hijriSuffix;
  final String todayFocus;
  final String monthlyPlan;
  final String yearlyPlan;
  final String saveBadge;
  final String currentPlanTag;
  final String mostPopular;
  final String upgradeNow;
  final String subscribeNow;
  final String cancelSubscription;
  final String manageSubscription;
  final String subscribedMsg;
  final String cancelledMsg;
  final String perMonth;
  final String perYear;
  final String featAds;
  final String featUnlimited;
  final String featSync;
  final String featBackup;
  final String featStats;
  final String featThemes;
  final String featExport;
  final String featGoals;
  final String featFuture;
  final String freeFeat1;
  final String freeFeat2;
  final String freeFeat3;
  final String adBannerTitle;
  final String adBannerSub;
  final String adBannerTag;
  final String accountSection;
  final String subscriptionSection;
  final String freeTag;
  final String premiumTag;
  final String dailyTrend;
  final String tasksAxis;
  final String customIconLabel;
  final String customIconPlaceholder;
  final String customColorLabel;
  final String addNew;
  final String enterTaskName;
  final String deleteTaskConfirm;
  final String deleteCategoryConfirm;
  final String undo;
  final String taskDeleted;
  final String freeLimitReached;
  final String exportCopied;
  final String importHint;
  final String importSuccess;
  final String invalidFile;
  final String hexColorHint;
  final String simulatedNote;
  final String today;
  final String system;
  final String todayTasks;
  final String todayAllDone;
  final String todayNoTasks;
  final String loadDemoData;
  final String demoLoaded;
  final String yearHeatmap;
  final String heatmapLegendLess;
  final String heatmapLegendMissed;
  final String heatmapLegendMore;
  final String reorderHint;
  final String about;
  final String aboutVersion;
  final String aboutDesc;

  static const ar = AppStrings(
    appName: 'وقتي',
    home: 'الرئيسية',
    calendar: 'التقويم',
    stats: 'الإحصائيات',
    tasks: 'المهام والعادات',
    achievements: 'الإنجازات',
    settings: 'الإعدادات',
    search: 'ابحث عن مهمة أو عادة...',
    monthlySchedule: 'الجدول الشهري',
    trackDesc: 'تابع إنجاز مهامك وعاداتك اليومية',
    completion: 'نسبة الإنجاز',
    completed: 'مهمة منجزة',
    remaining: 'مهمة متبقية',
    streak: 'أيام متتالية',
    xp: 'نقطة',
    done: 'تم الإنجاز',
    late: 'تم الإنجاز متأخرًا',
    missed: 'لم يتم الإنجاز',
    none: 'لا توجد مهمة',
    addTask: 'إضافة مهمة',
    editTask: 'تعديل مهمة',
    newTask: 'مهمة جديدة',
    name: 'الاسم',
    description: 'الوصف',
    color: 'اللون',
    icon: 'الأيقونة',
    category: 'التصنيف',
    noCategory: 'بدون تصنيف',
    priority: 'الأولوية',
    low: 'منخفضة',
    medium: 'متوسطة',
    high: 'عالية',
    urgent: 'عاجلة',
    overdueTitle: 'مهام متأخرة',
    overdueHint: 'انقر لإنجازها الآن',
    greetingMorning: 'صباح الخير',
    greetingAfternoon: 'طاب يومك',
    greetingEvening: 'مساء الخير',
    recurrence: 'التكرار',
    once: 'مرة واحدة',
    daily: 'يومي',
    weekly: 'أسبوعي',
    monthly: 'شهري',
    specificDays: 'أيام محددة',
    date: 'التاريخ',
    weekday: 'يوم الأسبوع',
    dayOfMonth: 'يوم من الشهر',
    chooseDays: 'اختر الأيام',
    notifications: 'الإشعارات',
    save: 'حفظ',
    cancel: 'إلغاء',
    delete: 'حذف',
    noTasks: 'لا توجد مهام بعد. أضف أول مهمة لك!',
    categoriesManage: 'إدارة التصنيفات',
    addCategory: 'إضافة تصنيف',
    categoryName: 'اسم التصنيف',
    weekdays: [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ],
    weekdaysShort: ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'],
    months: [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ],
    avgCompletion: 'متوسط الإنجاز',
    bestStreak: 'أطول تتابع',
    bestHabit: 'أكثر عادة التزامًا',
    worstHabit: 'أقل عادة التزامًا',
    weeklyChart: 'الإحصائيات الأسبوعية',
    level: 'المستوى',
    yourLevel: 'مستواك الحالي',
    totalXp: 'إجمالي النقاط',
    language: 'اللغة',
    theme: 'المظهر',
    light: 'فاتح',
    dark: 'داكن',
    notifSettings: 'إعدادات الإشعارات',
    masterNotif: 'تفعيل جميع الإشعارات',
    morningRecap: 'الملخص الصباحي',
    eveningRecap: 'الملخص المسائي',
    dataMgmt: 'إدارة البيانات',
    exportData: 'تصدير البيانات',
    importData: 'استيراد البيانات',
    guestUser: 'مستخدم زائر',
    taskDetails: 'تفاصيل المهمة',
    commitment: 'نسبة الالتزام',
    doneCount: 'مرات الإنجاز',
    missedCount: 'مرات عدم الإنجاز',
    history: 'سجل الإنجازات هذا الشهر',
    close: 'إغلاق',
    noResults: 'لا توجد نتائج مطابقة',
    achDesc: 'إنجازاتك تُفتح تلقائيًا كلما تقدمت',
    lockedTitle: 'مقفل',
    noData: 'لا توجد بيانات كافية بعد',
    login: 'تسجيل الدخول',
    signup: 'إنشاء حساب',
    welcomeBack: 'مرحبًا بعودتك',
    createAccountTitle: 'أنشئ حسابك',
    authSubtitle: 'نظّم مهامك وعاداتك اليومية بكل سهولة',
    email: 'البريد الإلكتروني',
    password: 'كلمة المرور',
    fullName: 'الاسم الكامل',
    forgotPassword: 'هل نسيت كلمة المرور؟',
    orContinueWith: 'أو تابع عبر',
    continueGoogle: 'المتابعة عبر Google',
    continueApple: 'المتابعة عبر Apple',
    continueGuest: 'المتابعة كزائر',
    noAccount: 'ليس لديك حساب؟',
    haveAccount: 'لديك حساب بالفعل؟',
    fillFields: 'يرجى تعبئة جميع الحقول',
    invalidEmail: 'يرجى إدخال بريد إلكتروني صالح',
    shortPassword: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    resetLinkSent:
        'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني (محاكاة)',
    logout: 'تسجيل الخروج',
    logoutConfirm: 'هل تريد تسجيل الخروج؟ بياناتك ستبقى محفوظة على هذا الجهاز.',
    subscription: 'الاشتراك المميز',
    freePlan: 'الخطة المجانية',
    premiumPlan: 'وقتي Premium',
    bronzePlan: 'برونزي',
    silverPlan: 'فضي',
    goldPlan: 'ذهبي',
    allBronzePlus: 'كل مزايا البرونزي، إضافةً إلى:',
    allSilverPlus: 'كل مزايا الفضي، إضافةً إلى:',
    featTasks15: 'حتى 15 مهمة وعادة',
    featPrioritySupport: 'أولوية في الدعم',
    subscribedTier: 'تم تفعيل باقتك بنجاح 🎉 (محاكاة — بدون دفع فعلي)',
    habitScore: 'درجة الاستمرارية',
    habitScoreHint: 'تهبط تدريجيًا مع الفوات ولا تُصفَّر — لا قلق سلسلة',
    bestStreak2: 'أطول سلسلة',
    currentStreak: 'السلسلة الحالية',
    subtasks: 'قائمة التحقق (خطوات)',
    subtaskHint: 'خطوة جديدة… ثم Enter',
    dayNote: 'ملاحظة اليوم',
    dayNoteHint: 'كيف كان الأمر؟ ماذا تعلمت؟',
    timeSlot: 'فترة اليوم',
    slotAny: 'أي وقت',
    slotMorning: '☀️ صباحًا',
    slotAfternoon: '🌤️ ظهرًا',
    slotEvening: '🌙 مساءً',
    reminders: 'أوقات التذكير (حتى 3)',
    addReminder: '+ وقت',
    quitHabit: 'عادة أريد الإقلاع عنها',
    quitHint: 'الإنجاز = قاومتُ اليوم، والفوات = زلّة تعيد العدّاد',
    daysClean: 'يومًا بلا زلّة',
    resisted: 'قاومت اليوم',
    quietHours: 'ساعات الهدوء',
    quietHoursHint: 'لا تذكيرات في هذه الفترة',
    from: 'من',
    to: 'إلى',
    restoreBackup: 'استعادة النسخة الاحتياطية المحلية',
    backupOf: 'نسخة تلقائية من',
    noBackup: 'لا توجد نسخة احتياطية بعد',
    restored: 'تمت الاستعادة ✅',
    restoreConfirm: 'سيتم استبدال بياناتك الحالية بالنسخة الاحتياطية. متابعة؟',
    exportCsv: 'تصدير CSV',
    csvCopied: 'تم نسخ CSV إلى الحافظة ✅',
    filterAll: 'الكل',
    sortManual: 'ترتيبي',
    sortPriority: 'الأولوية',
    sortName: 'الاسم',
    sortScore: 'الدرجة',
    quoteOfDay: 'حكمة اليوم',
    onb1Title: 'مهامك وعاداتك في مكان واحد',
    onb1Body:
        'أضف عادة بنقرة، وأنجزها بنقرة. اليوم أولًا: ما عليك الآن، وما تأخر.',
    onb2Title: 'بلا قلق سلسلة',
    onb2Body:
        'إنجاز متأخر يحفظ سلسلتك، يوم راحة لا يكسرها، ودرجة استمرارية تهبط تدريجيًا بدل التصفير.',
    onb3Title: 'بياناتك على جهازك',
    onb3Body:
        'بلا حساب إلزامي، بلا إعلانات، بلا تتبع. نسخة احتياطية تلقائية وتصدير بنقرة.',
    onbStart: 'ابدأ الآن',
    onbSkip: 'تخطٍّ',
    onbNext: 'التالي',
    whyHint: 'لماذا هذه العادة مهمة لك؟ (يظهر في التذكير)',
    step: 'خطوة',
    skipped: 'راحة',
    skipDay: 'يوم راحة',
    skipHint: 'لا يُحسب ولا يكسر السلسلة',
    dailyTarget: 'الهدف اليومي',
    targetHint: '1 = نقرة واحدة، أو رقم مثل 8',
    unit: 'الوحدة (اختياري)',
    unitHint: 'كوب، صفحة، دقيقة…',
    quickSuggestions: '⚡ اقتراحات سريعة',
    pauseTask: 'إيقاف مؤقت',
    resumeTask: 'استئناف',
    pausedTag: 'موقوفة',
    pausedHint: 'العادة الموقوفة لا تُحسب ولا تظهر في اليوم حتى تستأنفها',
    focusTimer: 'مؤقت التركيز',
    focusStart: 'ابدأ',
    focusPause: 'إيقاف',
    focusResume: 'متابعة',
    focusReset: 'إعادة',
    focusDoneTitle: 'أحسنت! جلسة تركيز مكتملة 🎉',
    focusMinutes: 'دقائق التركيز',
    focusMinutesMonth: 'دقائق التركيز هذا الشهر',
    focusHint: 'اختر مدة، ابدأ، وابتعد عن الهاتف. تُسجَّل الدقائق تلقائيًا.',
    markDone: 'تحديد كمنجزة',
    chooseTaskOptional: 'التركيز على (اختياري)',
    noTaskFocus: 'بدون مهمة',
    minutesShort: 'د',
    overdueRescue: 'أنجزها الآن لتحمي سلسلتك',
    reminderTime: 'وقت التذكير',
    noReminder: 'بدون تذكير',
    hijriSuffix: 'هـ',
    todayFocus: 'تركيز',
    monthlyPlan: 'شهري',
    yearlyPlan: 'سنوي',
    saveBadge: 'وفّر 33%',
    currentPlanTag: 'خطتك الحالية',
    mostPopular: 'الأكثر اختيارًا',
    upgradeNow: 'الترقية الآن',
    subscribeNow: 'اشترك الآن',
    cancelSubscription: 'إلغاء الاشتراك',
    manageSubscription: 'إدارة الاشتراك',
    subscribedMsg: 'تم تفعيل اشتراكك المميز بنجاح 🎉 (محاكاة — بدون دفع فعلي)',
    cancelledMsg: 'تم إلغاء الاشتراك المميز',
    perMonth: 'شهريًا',
    perYear: 'سنويًا',
    featAds: 'إزالة الإعلانات',
    featUnlimited: 'مهام وعادات غير محدودة',
    featSync: 'مزامنة بين الأجهزة',
    featBackup: 'نسخ احتياطي تلقائي',
    featStats: 'إحصائيات متقدمة',
    featThemes: 'تخصيص الثيمات والألوان',
    featExport: 'تصدير البيانات',
    featGoals: 'أهداف طويلة المدى',
    featFuture: 'الوصول للمزايا الجديدة مستقبلًا',
    freeFeat1: 'حتى 5 مهام وعادات',
    freeFeat2: 'إحصائيات أساسية',
    freeFeat3: 'يحتوي على إعلانات',
    adBannerTitle: 'أزل الإعلانات وافتح كل المزايا',
    adBannerSub: 'جرّب وقتي Premium الآن',
    adBannerTag: 'إعلان',
    accountSection: 'الحساب',
    subscriptionSection: 'الاشتراك',
    freeTag: 'مجاني',
    premiumTag: 'Premium',
    dailyTrend: 'الرسم البياني للإنجازات',
    tasksAxis: 'عدد المهام المنجزة',
    customIconLabel: 'أضف أيقونتك الخاصة',
    customIconPlaceholder: 'اكتب أو الصق إيموجي',
    customColorLabel: 'لون مخصص',
    addNew: 'إضافة',
    enterTaskName: 'يرجى إدخال اسم المهمة',
    deleteTaskConfirm:
        'هل أنت متأكد من حذف هذه المهمة؟ سيُحذف سجل إنجازها أيضًا.',
    deleteCategoryConfirm:
        'حذف هذا التصنيف؟ ستبقى المهام المرتبطة به بدون تصنيف.',
    undo: 'تراجع',
    taskDeleted: 'تم حذف المهمة',
    freeLimitReached:
        'وصلت للحد الأقصى في الخطة المجانية (5 مهام). قم بالترقية لإضافة المزيد.',
    exportCopied: 'تم نسخ بياناتك إلى الحافظة بصيغة JSON',
    importHint: 'الصق بيانات JSON التي صدّرتها سابقًا',
    importSuccess: 'تم استيراد البيانات بنجاح',
    invalidFile: 'بيانات غير صالحة',
    hexColorHint: 'كود اللون مثل 6E8F72',
    simulatedNote: 'محاكاة — بدون دفع فعلي',
    today: 'اليوم',
    system: 'تلقائي',
    todayTasks: 'مهام اليوم',
    todayAllDone: 'أحسنت! أنجزت كل مهام اليوم 🎉',
    todayNoTasks: 'لا توجد مهام مستحقة اليوم',
    loadDemoData: 'تحميل بيانات تجريبية',
    demoLoaded: 'تم تحميل البيانات التجريبية',
    yearHeatmap: 'خريطة السنة',
    heatmapLegendLess: 'أقل',
    heatmapLegendMissed: 'فائت',
    heatmapLegendMore: 'أكثر',
    reorderHint: 'اضغط مطولًا واسحب لإعادة الترتيب',
    about: 'حول التطبيق',
    aboutVersion: 'الإصدار',
    aboutDesc: 'تطبيق لتتبع المهام والعادات اليومية، مبني بـ Flutter.',
  );

  static const en = AppStrings(
    appName: 'Waqti',
    home: 'Home',
    calendar: 'Calendar',
    stats: 'Statistics',
    tasks: 'Tasks & Habits',
    achievements: 'Achievements',
    settings: 'Settings',
    search: 'Search tasks or habits...',
    monthlySchedule: 'Monthly Schedule',
    trackDesc: 'Track your daily tasks and habits',
    completion: 'Completion',
    completed: 'Completed',
    remaining: 'Remaining',
    streak: 'Day Streak',
    xp: 'pts',
    done: 'Done',
    late: 'Done late',
    missed: 'Not done',
    none: 'No task',
    addTask: 'Add Task',
    editTask: 'Edit Task',
    newTask: 'New Task',
    name: 'Name',
    description: 'Description',
    color: 'Color',
    icon: 'Icon',
    category: 'Category',
    noCategory: 'No category',
    priority: 'Priority',
    low: 'Low',
    medium: 'Medium',
    high: 'High',
    urgent: 'Urgent',
    overdueTitle: 'Overdue tasks',
    overdueHint: 'Tap to complete now',
    greetingMorning: 'Good morning',
    greetingAfternoon: 'Good afternoon',
    greetingEvening: 'Good evening',
    recurrence: 'Recurrence',
    once: 'Once',
    daily: 'Daily',
    weekly: 'Weekly',
    monthly: 'Monthly',
    specificDays: 'Specific days',
    date: 'Date',
    weekday: 'Weekday',
    dayOfMonth: 'Day of month',
    chooseDays: 'Choose days',
    notifications: 'Notifications',
    save: 'Save',
    cancel: 'Cancel',
    delete: 'Delete',
    noTasks: 'No tasks yet. Add your first one!',
    categoriesManage: 'Manage Categories',
    addCategory: 'Add Category',
    categoryName: 'Category name',
    weekdays: [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ],
    weekdaysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    months: [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    avgCompletion: 'Avg. completion',
    bestStreak: 'Best streak',
    bestHabit: 'Top habit',
    worstHabit: 'Weakest habit',
    weeklyChart: 'Weekly stats',
    level: 'Level',
    yourLevel: 'Current level',
    totalXp: 'Total points',
    language: 'Language',
    theme: 'Theme',
    light: 'Light',
    dark: 'Dark',
    notifSettings: 'Notification settings',
    masterNotif: 'Enable all notifications',
    morningRecap: 'Morning recap',
    eveningRecap: 'Evening recap',
    dataMgmt: 'Data management',
    exportData: 'Export data',
    importData: 'Import data',
    guestUser: 'Guest user',
    taskDetails: 'Task details',
    commitment: 'Commitment rate',
    doneCount: 'Times completed',
    missedCount: 'Times missed',
    history: "This month's log",
    close: 'Close',
    noResults: 'No matching results',
    achDesc: 'Achievements unlock automatically as you progress',
    lockedTitle: 'Locked',
    noData: 'Not enough data yet',
    login: 'Log In',
    signup: 'Sign Up',
    welcomeBack: 'Welcome back',
    createAccountTitle: 'Create your account',
    authSubtitle: 'Organize your daily tasks and habits with ease',
    email: 'Email',
    password: 'Password',
    fullName: 'Full name',
    forgotPassword: 'Forgot password?',
    orContinueWith: 'Or continue with',
    continueGoogle: 'Continue with Google',
    continueApple: 'Continue with Apple',
    continueGuest: 'Continue as guest',
    noAccount: "Don't have an account?",
    haveAccount: 'Already have an account?',
    fillFields: 'Please fill in all fields',
    invalidEmail: 'Please enter a valid email address',
    shortPassword: 'Password must be at least 6 characters',
    resetLinkSent: 'A password reset link was sent to your email (simulated)',
    logout: 'Log Out',
    logoutConfirm: 'Log out? Your data will remain saved on this device.',
    subscription: 'Premium Subscription',
    freePlan: 'Free plan',
    premiumPlan: 'Waqti Premium',
    bronzePlan: 'Bronze',
    silverPlan: 'Silver',
    goldPlan: 'Gold',
    allBronzePlus: 'Everything in Bronze, plus:',
    allSilverPlus: 'Everything in Silver, plus:',
    featTasks15: 'Up to 15 tasks & habits',
    featPrioritySupport: 'Priority support',
    subscribedTier: 'Your plan is active 🎉 (simulated — no real payment)',
    habitScore: 'Consistency score',
    habitScoreHint: 'Drops gradually on misses, never resets to zero',
    bestStreak2: 'Best streak',
    currentStreak: 'Current streak',
    subtasks: 'Checklist (steps)',
    subtaskHint: 'New step… then Enter',
    dayNote: 'Today\'s note',
    dayNoteHint: 'How did it go? What did you learn?',
    timeSlot: 'Time of day',
    slotAny: 'Any time',
    slotMorning: '☀️ Morning',
    slotAfternoon: '🌤️ Afternoon',
    slotEvening: '🌙 Evening',
    reminders: 'Reminder times (up to 3)',
    addReminder: '+ time',
    quitHabit: 'A habit to quit',
    quitHint: 'Done = I resisted today; a miss resets the counter',
    daysClean: 'days clean',
    resisted: 'Resisted today',
    quietHours: 'Quiet hours',
    quietHoursHint: 'No reminders during this window',
    from: 'From',
    to: 'To',
    restoreBackup: 'Restore local backup',
    backupOf: 'Auto backup from',
    noBackup: 'No backup yet',
    restored: 'Restored ✅',
    restoreConfirm:
        'Your current data will be replaced by the backup. Continue?',
    exportCsv: 'Export CSV',
    csvCopied: 'CSV copied to clipboard ✅',
    filterAll: 'All',
    sortManual: 'My order',
    sortPriority: 'Priority',
    sortName: 'Name',
    sortScore: 'Score',
    quoteOfDay: 'Quote of the day',
    onb1Title: 'Tasks and habits in one place',
    onb1Body:
        'Add a habit in one tap, finish it in one tap. Today first: what is due now and what is late.',
    onb2Title: 'No streak anxiety',
    onb2Body:
        'Late completion keeps your streak, rest days never break it, and a consistency score fades instead of resetting.',
    onb3Title: 'Your data stays on your device',
    onb3Body:
        'No mandatory account, no ads, no tracking. Automatic backup and one-tap export.',
    onbStart: 'Get started',
    onbSkip: 'Skip',
    onbNext: 'Next',
    whyHint: 'Why does this habit matter to you? (shown in reminders)',
    step: 'step',
    skipped: 'Skipped',
    skipDay: 'Rest day',
    skipHint: 'Not counted, streak stays safe',
    dailyTarget: 'Daily target',
    targetHint: '1 = one tap, or a number like 8',
    unit: 'Unit (optional)',
    unitHint: 'cup, page, minute…',
    quickSuggestions: '⚡ Quick suggestions',
    pauseTask: 'Pause',
    resumeTask: 'Resume',
    pausedTag: 'Paused',
    pausedHint: 'Paused habits are not counted or shown until you resume them',
    focusTimer: 'Focus timer',
    focusStart: 'Start',
    focusPause: 'Pause',
    focusResume: 'Resume',
    focusReset: 'Reset',
    focusDoneTitle: 'Well done! Focus session complete 🎉',
    focusMinutes: 'Focus minutes',
    focusMinutesMonth: 'Focus minutes this month',
    focusHint:
        'Pick a length, start, put the phone down. Minutes are logged automatically.',
    markDone: 'Mark as done',
    chooseTaskOptional: 'Focus on (optional)',
    noTaskFocus: 'No task',
    minutesShort: 'min',
    overdueRescue: 'Do it now to protect your streak',
    reminderTime: 'Reminder time',
    noReminder: 'No reminder',
    hijriSuffix: 'AH',
    todayFocus: 'Focus',
    monthlyPlan: 'Monthly',
    yearlyPlan: 'Yearly',
    saveBadge: 'Save 33%',
    currentPlanTag: 'Your current plan',
    mostPopular: 'Most popular',
    upgradeNow: 'Upgrade now',
    subscribeNow: 'Subscribe now',
    cancelSubscription: 'Cancel subscription',
    manageSubscription: 'Manage subscription',
    subscribedMsg:
        'Your Premium subscription is active 🎉 (simulated — no real payment)',
    cancelledMsg: 'Premium subscription cancelled',
    perMonth: '/month',
    perYear: '/year',
    featAds: 'Remove ads',
    featUnlimited: 'Unlimited tasks & habits',
    featSync: 'Cross-device sync',
    featBackup: 'Automatic backup',
    featStats: 'Advanced statistics',
    featThemes: 'Custom themes & colors',
    featExport: 'Data export',
    featGoals: 'Long-term goals',
    featFuture: 'Access to future features',
    freeFeat1: 'Up to 5 tasks & habits',
    freeFeat2: 'Basic statistics',
    freeFeat3: 'Contains ads',
    adBannerTitle: 'Remove ads and unlock everything',
    adBannerSub: 'Try Waqti Premium now',
    adBannerTag: 'Ad',
    accountSection: 'Account',
    subscriptionSection: 'Subscription',
    freeTag: 'Free',
    premiumTag: 'Premium',
    dailyTrend: 'Achievements Chart',
    tasksAxis: 'Tasks completed',
    customIconLabel: 'Add your own icon',
    customIconPlaceholder: 'Type or paste an emoji',
    customColorLabel: 'Custom color',
    addNew: 'Add',
    enterTaskName: 'Please enter a task name',
    deleteTaskConfirm:
        'Delete this task? Its completion history will be deleted too.',
    deleteCategoryConfirm:
        'Delete this category? Its tasks will become uncategorized.',
    undo: 'Undo',
    taskDeleted: 'Task deleted',
    freeLimitReached:
        'You reached the free plan limit (5 tasks). Upgrade to add more.',
    exportCopied: 'Your data was copied to the clipboard as JSON',
    importHint: 'Paste the JSON data you exported earlier',
    importSuccess: 'Data imported successfully',
    invalidFile: 'Invalid data',
    hexColorHint: 'Hex code like 6E8F72',
    simulatedNote: 'Simulated — no real payment',
    today: 'Today',
    system: 'Auto',
    todayTasks: "Today's tasks",
    todayAllDone: 'Well done! You completed all of today\'s tasks 🎉',
    todayNoTasks: 'No tasks due today',
    loadDemoData: 'Load demo data',
    demoLoaded: 'Demo data loaded',
    yearHeatmap: 'Year heatmap',
    heatmapLegendLess: 'Less',
    heatmapLegendMissed: 'Missed',
    heatmapLegendMore: 'More',
    reorderHint: 'Long-press and drag to reorder',
    about: 'About',
    aboutVersion: 'Version',
    aboutDesc: 'A daily tasks & habits tracker built with Flutter.',
  );

  static AppStrings of(String langCode) => langCode == 'en' ? en : ar;
}
