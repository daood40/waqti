import { useState } from 'react'
import { useI18n } from '../i18n.jsx'
import { todayKey, uid } from '../storage.js'

export default function TasksView({ state, setState }) {
  const { t } = useI18n()
  const [text, setText] = useState('')
  const today = todayKey()

  const todayTasks = state.tasks.filter((x) => x.date === today)
  const overdue = state.tasks.filter((x) => x.date < today && !x.done)

  const addTask = (e) => {
    e.preventDefault()
    const trimmed = text.trim()
    if (!trimmed) return
    setState((s) => ({
      ...s,
      tasks: [...s.tasks, { id: uid(), text: trimmed, done: false, date: today, completedAt: null }],
    }))
    setText('')
  }

  const toggle = (id) =>
    setState((s) => ({
      ...s,
      tasks: s.tasks.map((x) =>
        x.id === id ? { ...x, done: !x.done, completedAt: !x.done ? new Date().toISOString() : null } : x
      ),
    }))

  const remove = (id) => {
    if (!confirm(t('confirmDeleteTask'))) return
    setState((s) => ({ ...s, tasks: s.tasks.filter((x) => x.id !== id) }))
  }

  const TaskItem = ({ task }) => (
    <li className={task.done ? 'item done' : 'item'}>
      <label className="item-main">
        <input type="checkbox" checked={task.done} onChange={() => toggle(task.id)} />
        <span className="item-text">{task.text}</span>
      </label>
      <button className="icon-btn danger" onClick={() => remove(task.id)} aria-label={t('delete')}>
        ✕
      </button>
    </li>
  )

  return (
    <section>
      <form className="add-row" onSubmit={addTask}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder={t('addTaskPlaceholder')}
          maxLength={200}
        />
        <button type="submit" className="primary">{t('add')}</button>
      </form>

      <h2 className="section-title">{t('today')}</h2>
      {todayTasks.length === 0 ? (
        <p className="empty">{t('noTasks')}</p>
      ) : (
        <ul className="list">
          {todayTasks.map((task) => (
            <TaskItem key={task.id} task={task} />
          ))}
        </ul>
      )}

      {overdue.length > 0 && (
        <>
          <h2 className="section-title warn">{t('overdue')}</h2>
          <ul className="list">
            {overdue.map((task) => (
              <TaskItem key={task.id} task={task} />
            ))}
          </ul>
        </>
      )}
    </section>
  )
}
