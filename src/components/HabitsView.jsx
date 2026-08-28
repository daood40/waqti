import { useState } from 'react'
import { useI18n } from '../i18n.jsx'
import { habitStreak, todayKey, uid } from '../storage.js'

export default function HabitsView({ state, setState }) {
  const { t, lang } = useI18n()
  const [name, setName] = useState('')
  const today = todayKey()

  // آخر ٧ أيام (الأقدم أولاً)
  const week = Array.from({ length: 7 }, (_, i) => {
    const d = new Date()
    d.setDate(d.getDate() - (6 - i))
    return { key: todayKey(d), dow: d.getDay() }
  })

  const addHabit = (e) => {
    e.preventDefault()
    const trimmed = name.trim()
    if (!trimmed) return
    setState((s) => ({
      ...s,
      habits: [...s.habits, { id: uid(), name: trimmed, createdAt: today, log: {} }],
    }))
    setName('')
  }

  const toggleToday = (id) =>
    setState((s) => ({
      ...s,
      habits: s.habits.map((h) => {
        if (h.id !== id) return h
        const log = { ...h.log }
        if (log[today]) delete log[today]
        else log[today] = true
        return { ...h, log }
      }),
    }))

  const remove = (id) => {
    if (!confirm(t('confirmDeleteHabit'))) return
    setState((s) => ({ ...s, habits: s.habits.filter((h) => h.id !== id) }))
  }

  return (
    <section>
      <form className="add-row" onSubmit={addHabit}>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder={t('addHabitPlaceholder')}
          maxLength={100}
        />
        <button type="submit" className="primary">{t('add')}</button>
      </form>

      {state.habits.length === 0 ? (
        <p className="empty">{t('noHabits')}</p>
      ) : (
        <ul className="list">
          {state.habits.map((h) => {
            const doneToday = !!h.log[today]
            const streak = habitStreak(h)
            return (
              <li key={h.id} className="habit-card">
                <div className="habit-head">
                  <div>
                    <strong className="habit-name">{h.name}</strong>
                    <div className="habit-streak">
                      🔥 {t('streak')}: {streak} {t('days')}
                    </div>
                  </div>
                  <div className="habit-actions">
                    <button
                      className={doneToday ? 'primary small done-btn' : 'small done-btn'}
                      onClick={() => toggleToday(h.id)}
                    >
                      {doneToday ? `✓ ${t('doneToday')}` : t('markDone')}
                    </button>
                    <button className="icon-btn danger" onClick={() => remove(h.id)} aria-label={t('delete')}>
                      ✕
                    </button>
                  </div>
                </div>
                <div className="week-dots" dir="ltr" style={{ direction: lang === 'ar' ? 'rtl' : 'ltr' }}>
                  {week.map(({ key, dow }) => (
                    <div key={key} className="dot-col">
                      <span className={h.log[key] ? 'dot filled' : 'dot'} />
                      <small>{t('weekdaysShort')[dow]}</small>
                    </div>
                  ))}
                </div>
              </li>
            )
          })}
        </ul>
      )}
    </section>
  )
}
