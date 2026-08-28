// حفظ واسترجاع بيانات "وقتي" محلياً على الجهاز (localStorage)
const KEY = 'waqti-data-v1'

export const todayKey = (d = new Date()) => {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

export const defaultState = {
  tasks: [], // {id, text, done, date: 'YYYY-MM-DD', completedAt}
  habits: [], // {id, name, createdAt, log: {'YYYY-MM-DD': true}}
  settings: { lang: 'ar', theme: null }, // theme: null = حسب النظام
}

export function loadState() {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return structuredClone(defaultState)
    const parsed = JSON.parse(raw)
    return { ...structuredClone(defaultState), ...parsed, settings: { ...defaultState.settings, ...parsed.settings } }
  } catch {
    return structuredClone(defaultState)
  }
}

export function saveState(state) {
  try {
    localStorage.setItem(KEY, JSON.stringify(state))
  } catch {
    // مساحة التخزين ممتلئة أو مرفوضة — نتجاهل بصمت
  }
}

export const uid = () => Date.now().toString(36) + Math.random().toString(36).slice(2, 8)

// حساب سلسلة الأيام المتتالية لعادة (تنتهي اليوم أو أمس)
export function habitStreak(habit, ref = new Date()) {
  let streak = 0
  const d = new Date(ref)
  if (!habit.log[todayKey(d)]) d.setDate(d.getDate() - 1) // اليوم لم يُنجز بعد؟ ابدأ من أمس
  while (habit.log[todayKey(d)]) {
    streak++
    d.setDate(d.getDate() - 1)
  }
  return streak
}

export function habitBestStreak(habit) {
  const dates = Object.keys(habit.log).filter((k) => habit.log[k]).sort()
  let best = 0
  let cur = 0
  let prev = null
  for (const k of dates) {
    if (prev) {
      const p = new Date(prev)
      p.setDate(p.getDate() + 1)
      cur = todayKey(p) === k ? cur + 1 : 1
    } else {
      cur = 1
    }
    best = Math.max(best, cur)
    prev = k
  }
  return best
}
