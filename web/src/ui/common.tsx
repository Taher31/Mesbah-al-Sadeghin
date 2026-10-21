import type { ComponentChildren } from 'preact'
import { useEffect, useRef } from 'preact/hooks'
import type { Book } from '../lib/books'
import { goBack } from '../lib/router'
import { useStore } from '../lib/store'
import { asset, toastStore } from '../lib/util'
import { Icon, type IconName } from './icons'

export function IconButton(props: {
  icon: IconName
  label: string
  onClick: () => void
  disabled?: boolean
  class?: string
  pressed?: boolean
}) {
  return (
    <button
      type="button"
      class={'icon-btn' + (props.class ? ' ' + props.class : '')}
      aria-label={props.label}
      title={props.label}
      aria-pressed={props.pressed}
      disabled={props.disabled}
      onClick={props.onClick}
    >
      <Icon name={props.icon} />
    </button>
  )
}

export function TopBar(props: {
  title?: string
  subtitle?: string
  back?: boolean
  actions?: ComponentChildren
  children?: ComponentChildren
  hidden?: boolean
  class?: string
}) {
  return (
    <header class={'topbar' + (props.hidden ? ' is-hidden' : '') + (props.class ? ' ' + props.class : '')}>
      <div class="topbar-inner">
        {props.back !== false && <IconButton icon="back" label="بازگشت" onClick={goBack} />}
        <div class="topbar-title">
          {props.children ?? (
            <>
              {props.title && <h1>{props.title}</h1>}
              {props.subtitle && <p>{props.subtitle}</p>}
            </>
          )}
        </div>
        {props.actions && <div class="topbar-actions">{props.actions}</div>}
      </div>
    </header>
  )
}

/** A book cover with the slight lift of a physical book. */
export function BookCover({ book, width, onClick }: { book: Book; width: number; onClick?: () => void }) {
  const img = <img class="cover" src={asset(book.cover)} alt="" width={width} height={Math.round(width / 0.72)} loading="lazy" decoding="async" />
  return onClick ? (
    <button type="button" class="cover-btn" onClick={onClick} aria-label="فهرست کتاب">
      {img}
    </button>
  ) : (
    img
  )
}

export function EmptyState({ icon, title, body, children }: { icon: IconName; title: string; body?: string; children?: ComponentChildren }) {
  return (
    <div class="empty">
      <div class="empty-icon">
        <Icon name={icon} size={36} />
      </div>
      <p class="empty-title">{title}</p>
      {body && <p class="empty-body">{body}</p>}
      {children}
    </div>
  )
}

export function LoadError({ retry }: { retry: () => void }) {
  return (
    <EmptyState icon="refresh" title="بارگیری ناموفق بود" body="اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.">
      <button type="button" class="btn btn-tonal" onClick={retry}>
        تلاش دوباره
      </button>
    </EmptyState>
  )
}

export function Loading() {
  return <div class="loading" role="progressbar" aria-label="در حال بارگیری" />
}

export function SectionLabel({ children, class: cls }: { children: ComponentChildren; class?: string }) {
  return <h2 class={'section-label' + (cls ? ' ' + cls : '')}>{children}</h2>
}

export function Ornament() {
  return (
    <div class="ornament" aria-hidden="true">
      <span />
      <i />
      <span />
    </div>
  )
}

export function Switch({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: string }) {
  return (
    <button type="button" role="switch" aria-checked={checked} aria-label={label} class="switch" onClick={() => onChange(!checked)}>
      <span class="switch-thumb" />
    </button>
  )
}

export function SwitchRow({ label, checked, onChange }: { label: string; checked: boolean; onChange: (v: boolean) => void }) {
  return (
    // Clicking anywhere on the label activates the switch (a labelable button) once.
    <label class="switch-row">
      <span>{label}</span>
      <Switch checked={checked} onChange={onChange} label={label} />
    </label>
  )
}

export function Segmented<T extends string | number>({
  options,
  value,
  onChange,
  label,
}: {
  options: { id: T; label: string }[]
  value: T
  onChange: (v: T) => void
  label: string
}) {
  return (
    <div class="segmented" role="radiogroup" aria-label={label}>
      {options.map((o) => (
        <button type="button" role="radio" aria-checked={o.id === value} class={o.id === value ? 'is-on' : ''} onClick={() => onChange(o.id)}>
          {o.id === value && <Icon name="check" size={16} />}
          {o.label}
        </button>
      ))}
    </div>
  )
}

export function Chip({ selected, onClick, children, style }: { selected: boolean; onClick: () => void; children: ComponentChildren; style?: string }) {
  return (
    <button type="button" class={'chip' + (selected ? ' is-on' : '')} aria-pressed={selected} onClick={onClick} style={style}>
      {children}
    </button>
  )
}

/** A bottom sheet over a dimmed screen; closes on the scrim, Escape, or `onClose`. */
export function Sheet({ onClose, label, children }: { onClose: () => void; label: string; children: ComponentChildren }) {
  const ref = useRef<HTMLDivElement>(null)
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', onKey)
    document.documentElement.classList.add('has-modal')
    ref.current?.focus()
    return () => {
      window.removeEventListener('keydown', onKey)
      document.documentElement.classList.remove('has-modal')
    }
  }, [])
  return (
    <div class="scrim" onClick={onClose}>
      <div class="sheet" role="dialog" aria-modal="true" aria-label={label} tabIndex={-1} ref={ref} onClick={(e) => e.stopPropagation()}>
        <div class="sheet-handle" />
        {children}
      </div>
    </div>
  )
}

export function Dialog({ title, onClose, children, actions }: { title: string; onClose: () => void; children: ComponentChildren; actions: ComponentChildren }) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', onKey)
    document.documentElement.classList.add('has-modal')
    return () => {
      window.removeEventListener('keydown', onKey)
      document.documentElement.classList.remove('has-modal')
    }
  }, [])
  return (
    <div class="scrim scrim-center" onClick={onClose}>
      <div class="dialog" role="dialog" aria-modal="true" aria-label={title} onClick={(e) => e.stopPropagation()}>
        <h2>{title}</h2>
        {children}
        <div class="dialog-actions">{actions}</div>
      </div>
    </div>
  )
}

export function ActionRow({ icon, label, onClick }: { icon: IconName; label: string; onClick: () => void }) {
  return (
    <button type="button" class="action-row" onClick={onClick}>
      <Icon name={icon} />
      <span>{label}</span>
    </button>
  )
}

export function Snackbar() {
  const t = useStore(toastStore)
  if (!t) return null
  return (
    <div class="snackbar" role="status" key={t.id}>
      <span>{t.text}</span>
      {t.action && (
        <button
          type="button"
          onClick={() => {
            t.action!.run()
            toastStore.set(null)
          }}
        >
          {t.action.label}
        </button>
      )}
    </div>
  )
}
