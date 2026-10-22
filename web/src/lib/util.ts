import { android } from './native'
import { Store } from './store'

export const APP_NAME = 'مصباح الصادقین'
export const CHANNEL_URL = 'https://eitaa.com/sadeghin_ir'
/** Put next to the site by the deploy workflow; not part of the build or the offline cache. */
export const ANDROID_APK = import.meta.env.BASE_URL + 'download/mesbah-sadeghin.apk'

/** A file shipped in public/, addressed from the site root. */
export function asset(path: string): string {
  return import.meta.env.BASE_URL + path
}

export interface Toast {
  id: number
  text: string
  action?: { label: string; run: () => void }
}

export const toastStore = new Store<Toast | null>(null)
let toastTimer: ReturnType<typeof setTimeout> | undefined

/** A snackbar at the bottom; a new one replaces the current one. */
export function toast(text: string, action?: Toast['action']) {
  clearTimeout(toastTimer)
  const t = { id: Date.now(), text, action }
  toastStore.set(t)
  toastTimer = setTimeout(() => toastStore.get() === t && toastStore.set(null), action ? 5000 : 2600)
}

export async function copyText(text: string): Promise<boolean> {
  if (android) {
    android.copy(text)
    return true
  }
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch {
    // Older browsers, or clipboard blocked: the textarea route still works on iOS.
    const area = document.createElement('textarea')
    area.value = text
    area.setAttribute('readonly', '')
    area.style.cssText = 'position:fixed;top:0;opacity:0'
    document.body.appendChild(area)
    area.select()
    area.setSelectionRange(0, text.length)
    let ok = false
    try {
      ok = document.execCommand('copy')
    } catch {
      ok = false
    }
    area.remove()
    return ok
  }
}

/** The system share sheet where there is one; otherwise copies. */
export async function shareText(data: { text?: string; url?: string; title?: string }): Promise<'shared' | 'copied' | 'failed'> {
  if (android) {
    android.share([data.text, data.url].filter(Boolean).join('\n'), data.title ?? '')
    return 'shared'
  }
  if (navigator.share) {
    try {
      await navigator.share(data)
      return 'shared'
    } catch (e) {
      if ((e as DOMException)?.name === 'AbortError') return 'shared'
    }
  }
  const text = [data.text, data.url].filter(Boolean).join('\n')
  return (await copyText(text)) ? 'copied' : 'failed'
}

export function downloadFile(name: string, text: string, type = 'application/json') {
  if (android) return android.saveFile(name, type, text)
  const url = URL.createObjectURL(new Blob([text], { type }))
  const a = document.createElement('a')
  a.href = url
  a.download = name
  document.body.appendChild(a)
  a.click()
  a.remove()
  setTimeout(() => URL.revokeObjectURL(url), 10_000)
}

export function pickFile(accept: string): Promise<string | null> {
  return new Promise((resolve) => {
    const input = document.createElement('input')
    input.type = 'file'
    input.accept = accept
    input.onchange = async () => {
      const file = input.files?.[0]
      resolve(file ? await file.text() : null)
    }
    input.click()
  })
}
