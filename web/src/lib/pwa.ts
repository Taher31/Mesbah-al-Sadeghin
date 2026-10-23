import { android } from './native'
import { Store } from './store'

/**
 * Service-worker plumbing: registration, the offline download (the SW precaches the app shell on
 * install; the books and reader fonts are pulled in afterwards with visible progress), the
 * «new version» prompt, and install hints.
 */

export interface OfflineState {
  /** False until the service worker answers (or when there is none, e.g. in dev). */
  supported: boolean
  done: number
  total: number
  /** Last fill attempt failed part-way (usually connectivity); it resumes on the next visit. */
  failed: boolean
}

// The Android app carries everything in its APK: always ready offline.
export const offlineStore = new Store<OfflineState>({ supported: !!android, done: android ? 1 : 0, total: android ? 1 : 0, failed: false })
/** A new version has downloaded and is about to take over (the page then reloads by itself). */
export const updateReady = new Store(false)

let registration: ServiceWorkerRegistration | undefined

const ua = navigator.userAgent
export const isIOS = /iPad|iPhone|iPod/.test(ua) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
/** Real Safari, as opposed to another browser or an app's built-in browser (Eitaa, Telegram …). */
export const isIOSSafari = isIOS && /Version\/[\d.]+.*Safari\//.test(ua) && !/CriOS|FxiOS|EdgiOS|OPiOS|GSA\//.test(ua)
/** A browser on Android, where the app's APK is offered; not the Android app itself. */
export const isAndroid = /Android/i.test(ua) && !android
export const isStandalone =
  !!android || window.matchMedia('(display-mode: standalone)').matches || (navigator as { standalone?: boolean }).standalone === true

/** Chrome/Android's own install prompt, captured so the home screen can offer a button. */
export const installPrompt = new Store<{ prompt: () => Promise<unknown> } | null>(null)
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault()
  installPrompt.set(e as unknown as { prompt: () => Promise<unknown> })
})
window.addEventListener('appinstalled', () => installPrompt.set(null))

export function registerServiceWorker() {
  // The Android app serves its files from the APK and is updated with it; it needs no service
  // worker, and drops any that got registered.
  if (android) {
    navigator.serviceWorker?.getRegistrations().then((all) => all.forEach((r) => r.unregister()), () => {})
    return
  }
  if (!import.meta.env.PROD || !('serviceWorker' in navigator)) return
  const sw = navigator.serviceWorker
  sw.addEventListener('message', (e) => {
    const m = e.data
    if (m?.type === 'progress') offlineStore.set({ supported: true, done: m.done, total: m.total, failed: !!m.failed })
  })
  // A new version takes control as soon as it has downloaded (sw.js); reload into it. Not on the
  // very first install, which only starts controlling a page that is already current. The address
  // holds the reading position, so a reader comes back to the same paragraph.
  const updating = !!sw.controller
  let reloading = false
  sw.addEventListener('controllerchange', () => {
    if ((updating || updateReady.get()) && !reloading) {
      reloading = true
      location.reload()
    }
  })
  window.addEventListener('load', async () => {
    try {
      registration = await sw.register(import.meta.env.BASE_URL + 'sw.js')
    } catch {
      return
    }
    const watch = (worker: ServiceWorker | null) => {
      if (!worker) return
      const check = () => {
        if (worker.state === 'installed' && sw.controller) updateReady.set(true)
      }
      check()
      worker.addEventListener('statechange', check)
    }
    // The browser checks for updates as the page loads, so one may already be on its way.
    watch(registration.waiting)
    watch(registration.installing)
    registration.addEventListener('updatefound', () => watch(registration!.installing))
    const ready = await sw.ready
    ready.active?.postMessage({ type: 'fill' })
    if (isStandalone) navigator.storage?.persist?.().catch(() => {})
    // Long-lived home-screen apps never reload on their own; look for updates when reopened.
    let lastCheck = Date.now()
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible' && Date.now() - lastCheck > 30 * 60_000) {
        lastCheck = Date.now()
        registration?.update().catch(() => {})
      }
    })
  })
}

/** Starts the downloads again, e.g. after a failure. */
export function retryOfflineFill() {
  ;(registration?.active ?? navigator.serviceWorker?.controller)?.postMessage({ type: 'fill' })
}

// ---------------------------------------------------------------- keep the screen on while reading

let wakeLock: { release: () => Promise<void> } | null = null
let wantWakeLock = false

async function acquire() {
  const api = (navigator as { wakeLock?: { request: (t: 'screen') => Promise<{ release: () => Promise<void> }> } }).wakeLock
  if (!api || wakeLock || document.visibilityState !== 'visible') return
  try {
    wakeLock = await api.request('screen')
    ;(wakeLock as unknown as EventTarget).addEventListener?.('release', () => (wakeLock = null))
  } catch {
    wakeLock = null
  }
}

document.addEventListener('visibilitychange', () => {
  if (wantWakeLock && document.visibilityState === 'visible') acquire()
})

export const wakeLockSupported = !!android || 'wakeLock' in navigator

export function keepScreenOn(on: boolean) {
  if (android) return android.keepScreenOn(on)
  wantWakeLock = on
  if (on) acquire()
  else {
    wakeLock?.release().catch(() => {})
    wakeLock = null
  }
}
