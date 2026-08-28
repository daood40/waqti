import { useI18n } from '../i18n.jsx'
import { habitBestStreak, habitStreak, todayKey } from '../storage.js'

function computeAchievements(state) {
  const completed = state.tasks.filter((x) => x.done)
  const bestStreak = Math.max(0, ...state.habits.map((h) => habitBestStreak(h)))
  // يوم مثالي: يوم فيه مهام وكلها منجزة
  const byDay = {}
  for (const task of state.tasks) {
    byDay[task.date] ??= { total: 0, done: 0 }
    byDay[task.date].total++
    if (task.done) byDay[task.date].done++
  }
  const perfectDays = Object.values(byDay).filter((d) => d.total > 0 && d.done === d.total).length

  return {
    perfectDays,
    completedCount: completed.length,
    bestStreak,
    unlocked: {
      firstTask: completed.length >= 1,
      tasks10: completed.length >= 10,
      tasks50: completed.length >= 50,
      tasks100: completed.length >= 100,
      firstHabit: state.habits.length >= 1,
      streak3: bestStreak >= 3,
      streak7: bestStreak >= 7,
      streak30: bestStreak >= 30,
      perfectDay: perfectDays >= 1,
    },
  }
}

export default function StatsView({ state }) {
  const { t, lang } = useI18n()
  const { perfectDays, completedCount, bestStreak, unlocked } = computeAchievements(state)

  // إنجاز المهام في آخر ٧ أيام
  const week = Array.from({ length: 7 }, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - (6 - i))
    const key = todayKey(d)
    const done = state.tasks.filter((x) => x.date === key && x.done).length
    const habitsDone = state.habits.filter((h) => h.log[key]).length
    return { key, dow: d.getDay(), count: done + habitsDone }
  })
  const max = Math.max(1, ...week.map((w) => w.count))

  const currentStreak = Math.max(0, ...state.habits.map((h) => habitStreak(h)))
  const fmt = (n) => n.toLocaleString(lang === 'ar' ? 'ar-EG' : 'en-US')

  const cards = [
    { label: t('completedTasks'), value: fmt(completedCount), icon: '✅' },
    { label: t('totalHabits'), value: fmt(state.habits.length), icon: '🔁' },
    { label: t('bestStreak'), value: `${fmt(Math.max(bestStreak, currentStreak))} ${t('days')}`, icon: '🔥' },
    { label: t('perfectDays'), value: fmt(perfectDays), icon: '🌟' },
  ]

  const achKeys = Object.keys(unlocked)

  return (
    <section>
      <div className="stat-grid">
        {cards.map((c) => (
          <div key={c.label} className="stat-card">
            <span className="stat-icon" aria-hidden>{c.icon}</span>
            <strong className="stat-value">{c.value}</strong>
            <span className="stat-label">{c.label}</span>
          </div>
        ))}
      </div>

      <h2 className="section-title">{t('last7')}</h2>
      <div className="chart" style={{ direction: lang === 'ar' ? 'rtl' : 'ltr' }}>
        {week.map(({ key, dow, count }) => (
          <div key={key} className="bar-col">
            <span className="bar-count">{count > 0 ? fmt(count) : ''}</span>
            <div className="bar-track">
              <div className="bar-fill" style={{ height: `${(count / max) * 100}%` }} />
            </div>
            <small>{t('weekdaysShort')[dow]}</small>
          </div>
        ))}
      </div>

      <h2 className="section-title">{t('achievements')}</h2>
      <ul className="ach-grid">
        {achKeys.map((key) => {
          const [title, desc] = t('ach')[key]
          return (
            <li key={key} className={unlocked[key] ? 'ach unlocked' : 'ach'}>
              <span className="ach-medal" aria-hidden>{unlocked[key] ? '🏅' : '🔒'}</span>
              <div>
                <strong>{title}</strong>
                <p>{desc}</p>
              </div>
            </li>
          )
        })}
      </ul>
    </section>
  )
}
