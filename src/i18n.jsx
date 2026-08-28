import { createContext, useContext, useEffect, useState } from 'react'

export const translations = {
  ar: {
    appName: 'وقتي',
    tagline: 'مهامك وعاداتك اليومية',
    tasks: 'المهام',
    habits: 'العادات',
    stats: 'الإحصائيات',
    today: 'مهام اليوم',
    overdue: 'مهام متأخرة',
    addTaskPlaceholder: 'أضف مهمة جديدة…',
    addHabitPlaceholder: 'أضف عادة جديدة…',
    add: 'إضافة',
    delete: 'حذف',
    noTasks: 'لا مهام لليوم — أضف مهمتك الأولى!',
    noHabits: 'لا عادات بعد — ابدأ بعادة صغيرة!',
    doneToday: 'أُنجزت اليوم',
    markDone: 'إنجاز اليوم',
    streak: 'سلسلة',
    days: 'يوم',
    bestStreak: 'أفضل سلسلة',
    completedTasks: 'مهام منجزة',
    totalHabits: 'عادات نشطة',
    perfectDays: 'أيام مثالية',
    last7: 'آخر ٧ أيام',
    achievements: 'الإنجازات',
    progressToday: 'تقدّم اليوم',
    allDone: 'أحسنت! أنجزت كل مهام اليوم 🎉',
    confirmDeleteTask: 'حذف هذه المهمة؟',
    confirmDeleteHabit: 'حذف هذه العادة وسجلّها؟',
    langButton: 'English',
    weekdaysShort: ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'],
    ach: {
      firstTask: ['البداية', 'أنجزت أول مهمة'],
      tasks10: ['منتج', 'أنجزت ١٠ مهام'],
      tasks50: ['مثابر', 'أنجزت ٥٠ مهمة'],
      tasks100: ['بطل الإنتاجية', 'أنجزت ١٠٠ مهمة'],
      firstHabit: ['عادة أولى', 'أضفت أول عادة'],
      streak3: ['ثبات', 'سلسلة عادة ٣ أيام'],
      streak7: ['أسبوع كامل', 'سلسلة عادة ٧ أيام'],
      streak30: ['شهر ذهبي', 'سلسلة عادة ٣٠ يوماً'],
      perfectDay: ['يوم مثالي', 'أنجزت كل مهام يوم كامل'],
    },
  },
  en: {
    appName: 'Waqti',
    tagline: 'Your daily tasks & habits',
    tasks: 'Tasks',
    habits: 'Habits',
    stats: 'Stats',
    today: "Today's tasks",
    overdue: 'Overdue tasks',
    addTaskPlaceholder: 'Add a new task…',
    addHabitPlaceholder: 'Add a new habit…',
    add: 'Add',
    delete: 'Delete',
    noTasks: 'No tasks for today — add your first one!',
    noHabits: 'No habits yet — start with a small one!',
    doneToday: 'Done today',
    markDone: 'Mark done',
    streak: 'Streak',
    days: 'days',
    bestStreak: 'Best streak',
    completedTasks: 'Tasks completed',
    totalHabits: 'Active habits',
    perfectDays: 'Perfect days',
    last7: 'Last 7 days',
    achievements: 'Achievements',
    progressToday: "Today's progress",
    allDone: 'Well done! All tasks completed 🎉',
    confirmDeleteTask: 'Delete this task?',
    confirmDeleteHabit: 'Delete this habit and its log?',
    langButton: 'عربي',
    weekdaysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    ach: {
      firstTask: ['First step', 'Completed your first task'],
      tasks10: ['Productive', 'Completed 10 tasks'],
      tasks50: ['Persistent', 'Completed 50 tasks'],
      tasks100: ['Productivity hero', 'Completed 100 tasks'],
      firstHabit: ['First habit', 'Added your first habit'],
      streak3: ['Consistency', '3-day habit streak'],
      streak7: ['Full week', '7-day habit streak'],
      streak30: ['Golden month', '30-day habit streak'],
      perfectDay: ['Perfect day', 'Completed all tasks in a day'],
    },
  },
}

const I18nContext = createContext(null)

export function I18nProvider({ initialLang, onLangChange, children }) {
  const [lang, setLang] = useState(initialLang || 'ar')

  useEffect(() => {
    document.documentElement.lang = lang
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr'
    onLangChange?.(lang)
  }, [lang])

  const t = (key) => translations[lang][key] ?? key
  return <I18nContext.Provider value={{ lang, setLang, t }}>{children}</I18nContext.Provider>
}

export function useI18n() {
  return useContext(I18nContext)
}
