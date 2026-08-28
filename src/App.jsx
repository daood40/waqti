import { useEffect, useMemo, useState } from 'react'
import { I18nProvider, useI18n } from './i18n.jsx'
import { loadState, saveState, todayKey } from './storage.js'
import TasksView from './components/TasksView.jsx'
import HabitsView from './components/HabitsView.jsx'
import StatsView from './components/StatsView.jsx'

function Shell({ state, setState }) {
  const { t, lang, setLang } = useI18n()
  const [tab, setTab] = useState('tasks')

  const theme = state.settings.theme
  useEffect(() => {
    if (theme) document.documentElement.dataset.theme = theme
    else delete document.documentElement.dataset.theme
  }, [theme])

  const toggleTheme = () => {
    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    const current = theme || (systemDark ? 'dark' : 'light')
    setState((s) => ({ ...s, settings: { ...s.settings, theme: current === 'dark' ? 'light' : 'dark' } }))
  }

  const isDark =
    theme === 'dark' ||
    (!theme && typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches)

  const today = todayKey()
  const todayTasks = state.tasks.filter((x) => x.date === today)
  const doneCount = todayTasks.filter((x) => x.done).length
  const progress = todayTasks.length ? Math.round((doneCount / todayTasks.length) * 100) : 0

  const tabs = [
    { id: 'tasks', label: t('tasks'), icon: '✓' },
    { id: 'habits', label: t('habits'), icon: '↻' },
    { id: 'stats', label: t('stats'), icon: '▤' },
  ]

  return (
    <div className="app">
      <header className="header">
        <div className="brand">
          <h1>{t('appName')}</h1>
          <p>{t('tagline')}</p>
        </div>
        <div className="header-actions">
          <button className="chip" onClick={() => setLang(lang === 'ar' ? 'en' : 'ar')} title="Language">
            {t('langButton')}
          </button>
          <button className="chip" onClick={toggleTheme} title="Theme" aria-label="Toggle theme">
            {isDark ? '☀️' : '🌙'}
          </button>
        </div>
      </header>

      {tab === 'tasks' && todayTasks.length > 0 && (
        <div className="progress-card">
          <div className="progress-label">
            <span>{t('progressToday')}</span>
            <span>{doneCount}/{todayTasks.length}</span>
          </div>
          <div className="progress-track">
            <div className="progress-fill" style={{ width: `${progress}%` }} />
          </div>
          {progress === 100 && <p className="all-done">{t('allDone')}</p>}
        </div>
      )}

      <main className="content">
        {tab === 'tasks' && <TasksView state={state} setState={setState} />}
        {tab === 'habits' && <HabitsView state={state} setState={setState} />}
        {tab === 'stats' && <StatsView state={state} />}
      </main>

      <nav className="tabbar">
        {tabs.map(({ id, label, icon }) => (
          <button key={id} className={tab === id ? 'tab active' : 'tab'} onClick={() => setTab(id)}>
            <span className="tab-icon" aria-hidden>{icon}</span>
            {label}
          </button>
        ))}
      </nav>
    </div>
  )
}

export default function App() {
  const [state, setState] = useState(loadState)

  useEffect(() => {
    saveState(state)
  }, [state])

  const setLangInState = useMemo(
    () => (lang) => setState((s) => (s.settings.lang === lang ? s : { ...s, settings: { ...s.settings, lang } })),
    []
  )

  return (
    <I18nProvider initialLang={state.settings.lang} onLangChange={setLangInState}>
      <Shell state={state} setState={setState} />
    </I18nProvider>
  )
}
