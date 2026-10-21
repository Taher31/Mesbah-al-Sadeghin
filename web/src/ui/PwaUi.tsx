import { useState } from 'preact/hooks'
import { fa } from '../lib/normalize'
import { applyUpdate, installPrompt, isAndroid, isIOS, isIOSSafari, isStandalone, offlineStore, retryOfflineFill, updateReady } from '../lib/pwa'
import { useStore } from '../lib/store'
import { ANDROID_APK, copyText, toast } from '../lib/util'
import { Icon } from './icons'

const HINT_KEY = 'mesbah.installHintDismissed'
const HINT_PAUSE = 30 * 24 * 3600_000

function hintDismissed(): boolean {
  try {
    return Date.now() - Number(localStorage.getItem(HINT_KEY) || 0) < HINT_PAUSE
  } catch {
    return false
  }
}

/**
 * How to install: step-by-step «Add to Home Screen» in iPhone Safari; in an app's built-in
 * browser (Eitaa, Telegram …), where installing is impossible, a pointer to Safari instead; on
 * Android the native app's APK, plus Chrome's own install prompt when it offers one.
 */
export function InstallBanner() {
  const [hidden, setHidden] = useState(hintDismissed)
  const prompt = useStore(installPrompt)
  if (isStandalone || hidden) return null
  const dismiss = () => {
    try {
      localStorage.setItem(HINT_KEY, String(Date.now()))
    } catch {
      // ignore
    }
    setHidden(true)
  }
  const close = (
    <button type="button" class="banner-close" aria-label="بستن" onClick={dismiss}>
      <Icon name="close" size={20} />
    </button>
  )

  if (isIOSSafari) {
    return (
      <section class="banner" aria-label="نصب روی آیفون">
        {close}
        <h3>
          <Icon name="install" size={20} /> نصب «مصباح الصادقین» روی آیفون
        </h3>
        <ol>
          <li>
            در نوار Safari دکمهٔ اشتراک‌گذاری <Icon name="iosShare" size={18} class="inline-icon" /> را بزنید
            <small> (در iOS ۲۶ ابتدا دکمهٔ «⋯»)</small>.
          </li>
          <li>
            گزینهٔ <b dir="ltr">Add to Home Screen</b> یا «افزودن به صفحهٔ اصلی» <Icon name="addBox" size={18} class="inline-icon" /> را
            انتخاب کنید.
          </li>
          <li>«Add / افزودن» را بزنید و برنامه را از صفحهٔ اصلی گوشی باز کنید.</li>
        </ol>
        <p class="banner-note">بار اول که برنامهٔ نصب‌شده را باز می‌کنید اینترنت وصل باشد تا کتاب‌ها برای استفادهٔ بدون اینترنت ذخیره شوند.</p>
      </section>
    )
  }
  if (isIOS) {
    return (
      <section class="banner" aria-label="نصب روی آیفون">
        {close}
        <h3>
          <Icon name="install" size={20} /> برای نصب روی آیفون، این صفحه را در Safari باز کنید
        </h3>
        <p>
          در مرورگر داخلی برنامه‌ها (مثل ایتا) امکان نصب نیست. از منوی همین صفحه «باز کردن در Safari» را بزنید، یا پیوند را کپی و در
          Safari باز کنید.
        </p>
        <button
          type="button"
          class="btn btn-tonal"
          onClick={async () => toast((await copyText(location.href.split('#')[0])) ? 'پیوند کپی شد' : 'کپی نشد')}
        >
          <Icon name="link" size={18} /> کپی پیوند
        </button>
      </section>
    )
  }
  const installButton = prompt && (
    <button
      type="button"
      class="btn btn-outlined"
      onClick={async () => {
        await prompt.prompt()
        installPrompt.set(null)
      }}
    >
      <Icon name="install" size={18} /> نصب نسخهٔ وب
    </button>
  )
  if (isAndroid) {
    return (
      <section class="banner" aria-label="نسخهٔ اندروید">
        {close}
        <h3>
          <Icon name="install" size={20} /> نسخهٔ اندروید
        </h3>
        <p>برای گوشی‌های اندروید، برنامهٔ مصباح الصادقین را دانلود و نصب کنید؛ بدون اینترنت هم کار می‌کند.</p>
        <div class="banner-actions">
          <a class="btn btn-filled" href={ANDROID_APK} download>
            <Icon name="download" size={18} /> دانلود نسخهٔ اندروید
          </a>
          {installButton}
        </div>
      </section>
    )
  }
  if (installButton) {
    return (
      <section class="banner" aria-label="نصب برنامه">
        {close}
        <p>
          <b>مصباح الصادقین</b> را مثل یک برنامه نصب کنید تا بدون اینترنت هم در دسترس باشد.
        </p>
        <div class="banner-actions">{installButton}</div>
      </section>
    )
  }
  return null
}

/** «Ready offline» or the download's progress; nothing where there is no service worker. */
export function OfflineStatus({ detailed }: { detailed?: boolean }) {
  const s = useStore(offlineStore)
  if (!s.supported || s.total === 0) {
    return detailed ? <p class="offline-status muted">ذخیره برای استفادهٔ بدون اینترنت پس از اولین بارگذاری کامل آغاز می‌شود.</p> : null
  }
  const percent = Math.floor((s.done / s.total) * 100)
  if (s.done >= s.total) {
    return (
      <p class="offline-status ok">
        <Icon name="offline" size={18} /> همهٔ کتاب‌ها برای استفادهٔ بدون اینترنت آماده است
      </p>
    )
  }
  return (
    <div class="offline-status">
      <p>
        {s.failed ? 'دریافت کامل نشد؛ با اتصال دوباره ادامه می‌یابد' : 'در حال آماده‌سازی برای استفادهٔ بدون اینترنت…'} {fa(percent)}٪
      </p>
      <div class="progress" style={`--value:${percent}%`} />
      {s.failed && (
        <button type="button" class="btn btn-text" onClick={retryOfflineFill}>
          تلاش دوباره
        </button>
      )}
    </div>
  )
}

export function UpdateBanner() {
  const ready = useStore(updateReady)
  if (!ready) return null
  return (
    <div class="update-banner" role="status">
      <span>نسخهٔ تازهٔ برنامه آماده است</span>
      <button type="button" onClick={applyUpdate}>
        به‌روزرسانی
      </button>
    </div>
  )
}
