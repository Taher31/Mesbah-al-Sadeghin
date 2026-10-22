import { useState } from 'preact/hooks'
import { installPrompt, isAndroid, isIOS, isIOSSafari, isStandalone, offlineStore, retryOfflineFill, updateReady } from '../lib/pwa'
import { useStore } from '../lib/store'
import { ANDROID_APK, copyText, toast } from '../lib/util'
import { Icon } from './icons'
import { num, t } from '../lib/i18n'

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
    <button type="button" class="banner-close" aria-label={t('بستن')} onClick={dismiss}>
      <Icon name="close" size={20} />
    </button>
  )

  if (isIOSSafari) {
    return (
      <section class="banner" aria-label={t('نصب روی آیفون')}>
        {close}
        <h3>
          <Icon name="install" size={20} /> {t('نصب «مصباح الصادقین» روی آیفون')}
        </h3>
        <ol>
          <li>
            {t('در نوار Safari دکمهٔ اشتراک‌گذاری را بزنید')} <Icon name="iosShare" size={18} class="inline-icon" />
            <small>{t(' (در iOS ۲۶ ابتدا دکمهٔ «⋯»)')}</small>.
          </li>
          <li>
            {t('گزینهٔ {0} یا «افزودن به صفحهٔ اصلی» را انتخاب کنید', 'Add to Home Screen')} <Icon name="addBox" size={18} class="inline-icon" />
          </li>
          <li>{t('«Add / افزودن» را بزنید و برنامه را از صفحهٔ اصلی گوشی باز کنید.')}</li>
        </ol>
        <p class="banner-note">{t('بار اول که برنامهٔ نصب‌شده را باز می‌کنید اینترنت وصل باشد تا کتاب‌ها برای استفادهٔ بدون اینترنت ذخیره شوند.')}</p>
      </section>
    )
  }
  if (isIOS) {
    return (
      <section class="banner" aria-label={t('نصب روی آیفون')}>
        {close}
        <h3>
          <Icon name="install" size={20} /> {t('برای نصب روی آیفون، این صفحه را در Safari باز کنید')}
        </h3>
        <p>
          {t(
            'در مرورگر داخلی برنامه‌ها (مثل ایتا) امکان نصب نیست. از منوی همین صفحه «باز کردن در Safari» را بزنید، یا پیوند را کپی و در Safari باز کنید.',
          )}
        </p>
        <button
          type="button"
          class="btn btn-tonal"
          onClick={async () => toast((await copyText(location.href.split('#')[0])) ? t('پیوند کپی شد') : t('کپی نشد'))}
        >
          <Icon name="link" size={18} /> {t('کپی پیوند')}
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
      <Icon name="install" size={18} /> {t('نصب نسخهٔ وب')}
    </button>
  )
  if (isAndroid) {
    return (
      <section class="banner" aria-label={t('نسخهٔ اندروید')}>
        {close}
        <h3>
          <Icon name="install" size={20} /> {t('نسخهٔ اندروید')}
        </h3>
        <p>{t('برای گوشی‌های اندروید، برنامهٔ مصباح الصادقین را دانلود و نصب کنید؛ بدون اینترنت هم کار می‌کند.')}</p>
        <div class="banner-actions">
          <a class="btn btn-filled" href={ANDROID_APK} download>
            <Icon name="download" size={18} /> {t('دانلود نسخهٔ اندروید')}
          </a>
          {installButton}
        </div>
      </section>
    )
  }
  if (installButton) {
    return (
      <section class="banner" aria-label={t('نصب برنامه')}>
        {close}
        <p>
          {t('{0} را مثل یک برنامه نصب کنید تا بدون اینترنت هم در دسترس باشد.', t('مصباح الصادقین'))}
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
    return detailed ? <p class="offline-status muted">{t('ذخیره برای استفادهٔ بدون اینترنت پس از اولین بارگذاری کامل آغاز می‌شود.')}</p> : null
  }
  const percent = Math.floor((s.done / s.total) * 100)
  if (s.done >= s.total) {
    return (
      <p class="offline-status ok">
        <Icon name="offline" size={18} /> {t('همهٔ کتاب‌ها برای استفادهٔ بدون اینترنت آماده است')}
      </p>
    )
  }
  return (
    <div class="offline-status">
      <p>
        {s.failed ? t('دریافت کامل نشد؛ با اتصال دوباره ادامه می‌یابد') : t('در حال آماده‌سازی برای استفادهٔ بدون اینترنت…')} {num(percent)}%
      </p>
      <div class="progress" style={`--value:${percent}%`} />
      {s.failed && (
        <button type="button" class="btn btn-text" onClick={retryOfflineFill}>
          {t('تلاش دوباره')}
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
      <span>{t('نسخهٔ تازهٔ برنامه دریافت شد؛ چند لحظهٔ دیگر بارگذاری می‌شود.')}</span>
    </div>
  )
}
