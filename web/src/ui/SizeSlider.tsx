import { useEffect, useRef, useState } from 'preact/hooks'
import { decimal, num } from '../lib/i18n'

interface Props {
  label: string
  value: number
  range: readonly [number, number]
  decimals?: boolean
  onChange: (value: number) => void
}

interface Drag {
  x: number
  y: number
  start: number
  value: number
  left: number
  width: number
  direction: 1 | -1
  axis: 'x' | 'y' | null
}

/** Touch scrolling never reaches the native range. A deliberate horizontal drag adjusts it;
 * the underlying input retains normal keyboard and assistive-technology range behavior. */
export function SizeSlider(props: Props) {
  const [draft, setDraft] = useState(props.value)
  const input = useRef<HTMLInputElement>(null)
  const drag = useRef<Drag | null>(null)
  const removeMouseListeners = useRef<(() => void) | null>(null)
  const ignoreMouseUntil = useRef(0)
  const step = props.decimals ? 0.1 : 1

  useEffect(() => {
    if (drag.current && drag.current.start !== props.value) {
      drag.current = null
      removeMouseListeners.current?.()
    }
    setDraft(props.value)
  }, [props.value])
  useEffect(() => () => removeMouseListeners.current?.(), [])

  const round = (value: number) => {
    const [min, max] = props.range
    const stepped = min + Math.round((value - min) / step) * step
    return Number(Math.max(min, Math.min(max, stepped)).toFixed(props.decimals ? 1 : 0))
  }
  const begin = (x: number, y: number): Drag | null => {
    const node = input.current
    if (!node) return null
    const rect = node.getBoundingClientRect()
    return {
      x, y, start: props.value, value: props.value,
      // The native thumb is 20px wide; its centre travels inside these end points.
      left: rect.left + 10,
      width: Math.max(1, rect.width - 20),
      direction: window.getComputedStyle(node).direction === 'rtl' ? -1 : 1,
      axis: null,
    }
  }
  const preview = (gesture: Drag, value: number) => {
    gesture.value = round(value)
    setDraft(gesture.value)
  }
  const cancel = () => {
    drag.current = null
    removeMouseListeners.current?.()
    setDraft(props.value)
  }
  const finish = () => {
    const gesture = drag.current
    drag.current = null
    removeMouseListeners.current?.()
    if (gesture?.axis === 'x') {
      setDraft(gesture.value)
      if (gesture.value !== gesture.start) props.onChange(gesture.value)
    } else setDraft(props.value)
  }
  const touchValue = (gesture: Drag, x: number) =>
    gesture.start + gesture.direction * ((x - gesture.x) / gesture.width) * (props.range[1] - props.range[0])
  const mouseValue = (gesture: Drag, x: number) => {
    const fraction = Math.max(0, Math.min(1, (x - gesture.left) / gesture.width))
    return props.range[0] + (gesture.direction === -1 ? 1 - fraction : fraction) * (props.range[1] - props.range[0])
  }

  const onMouseDown = (event: MouseEvent) => {
    if (event.button !== 0) return
    event.preventDefault()
    // A touch tap/scroll can generate compatibility mouse events after touchend.
    if (Date.now() < ignoreMouseUntil.current) return
    cancel()
    const gesture = begin(event.clientX, event.clientY)
    if (!gesture) return
    gesture.axis = 'x'
    drag.current = gesture
    input.current?.focus()
    preview(gesture, mouseValue(gesture, event.clientX))
    const move = (e: MouseEvent) => {
      if (drag.current === gesture) preview(gesture, mouseValue(gesture, e.clientX))
    }
    const up = (e: MouseEvent) => {
      if (drag.current !== gesture) return
      preview(gesture, mouseValue(gesture, e.clientX))
      finish()
    }
    const key = (e: KeyboardEvent) => {
      if (e.key === 'Escape') cancel()
    }
    window.addEventListener('mousemove', move)
    window.addEventListener('mouseup', up)
    window.addEventListener('blur', cancel)
    window.addEventListener('keydown', key)
    removeMouseListeners.current = () => {
      window.removeEventListener('mousemove', move)
      window.removeEventListener('mouseup', up)
      window.removeEventListener('blur', cancel)
      window.removeEventListener('keydown', key)
      removeMouseListeners.current = null
    }
  }

  const shown = props.decimals ? draft.toFixed(1) : String(Math.round(draft))
  return (
    <div class="slider">
      <div class="slider-head">
        <span>{props.label}</span>
        <b>{decimal(num(shown))}</b>
      </div>
      <div class="slider-control">
        <input
          ref={input}
          type="range"
          min={props.range[0]}
          max={props.range[1]}
          step={step}
          value={draft}
          aria-label={props.label}
          style={`--fill:${((draft - props.range[0]) / (props.range[1] - props.range[0])) * 100}%`}
          onInput={(e) => setDraft(Number((e.target as HTMLInputElement).value))}
          onChange={(e) => {
            const value = round(Number((e.target as HTMLInputElement).value))
            if (value !== props.value) props.onChange(value)
          }}
        />
        <div
          class="slider-gesture"
          aria-hidden="true"
          onMouseDown={onMouseDown}
          onTouchStart={(e) => {
            ignoreMouseUntil.current = Date.now() + 1000
            cancel()
            if (e.touches.length === 1) drag.current = begin(e.touches[0].clientX, e.touches[0].clientY)
          }}
          onTouchMove={(e) => {
            const gesture = drag.current
            if (!gesture) return
            if (e.touches.length !== 1) return cancel()
            const point = e.touches[0]
            if (!gesture.axis) {
              const dx = Math.abs(point.clientX - gesture.x)
              const dy = Math.abs(point.clientY - gesture.y)
              if (Math.max(dx, dy) < 10) return
              gesture.axis = dx > dy * 1.3 ? 'x' : 'y'
            }
            // Leave vertical gestures alone so the browser scrolls the sheet natively.
            if (gesture.axis !== 'x') return
            if (e.cancelable) e.preventDefault()
            preview(gesture, touchValue(gesture, point.clientX))
          }}
          onTouchEnd={(e) => {
            ignoreMouseUntil.current = Date.now() + 1000
            const gesture = drag.current
            if (gesture?.axis === 'x') {
              if (e.cancelable) e.preventDefault()
              if (e.changedTouches.length) preview(gesture, touchValue(gesture, e.changedTouches[0].clientX))
            }
            finish()
          }}
          onTouchCancel={() => {
            ignoreMouseUntil.current = Date.now() + 1000
            cancel()
          }}
        />
      </div>
    </div>
  )
}
