import { isAndroid, wakeLockSupported } from '../lib/pwa'
import { clearVisits, exportBackup, importBackup, setSetting, settingsStore, useStore } from '../lib/store'
import { ANDROID_APK, downloadFile, pickFile, toast } from '../lib/util'
import { SectionLabel, SwitchRow, TopBar } from '../ui/common'
import { Icon } from '../ui/icons'
import { OfflineStatus } from '../ui/PwaUi'
import { TextSettingsPanel } from '../ui/TextSettings'

export function SettingsScreen() {
  const settings = useStore(settingsStore)
  return (
    <main class="page">
      <TopBar title="تنظیمات" />
      <div class="content settings">
        <SectionLabel>متن</SectionLabel>
        <TextSettingsPanel />

        <hr />
        <SectionLabel>مطالعه</SectionLabel>
        {wakeLockSupported && (
          <SwitchRow label="روشن ماندن صفحه هنگام مطالعه" checked={settings.keepScreenOn} onChange={(v) => setSetting('keepScreenOn', v)} />
        )}
        <div class="stack">
          <button
            type="button"
            class="btn btn-outlined btn-block"
            onClick={() => {
              clearVisits()
              toast('فهرست پرکاربردها پاک شد')
            }}
          >
            پاک کردن فهرست پرکاربردها
          </button>
        </div>

        <hr />
        <SectionLabel>پشتیبان‌گیری از داده‌های من</SectionLabel>
        <p class="help">
          منتخب‌ها، نشانه‌ها و یادداشت‌ها، جای مطالعه و تنظیمات را در یک فایل ذخیره کنید تا در گوشی یا مرورگر دیگری، یا پس از پاک شدن
          داده‌های مرورگر، بازگردانید. بازیابی، داده‌های فعلی را پاک نمی‌کند و فقط موارد تازه را می‌افزاید.
        </p>
        <div class="stack">
          <button
            type="button"
            class="btn btn-tonal btn-block"
            onClick={() => {
              const date = new Date().toISOString().slice(0, 10)
              downloadFile(`mesbah-backup-${date}.json`, exportBackup())
            }}
          >
            <Icon name="download" size={18} />
            ذخیرهٔ فایل پشتیبان
          </button>
          <button
            type="button"
            class="btn btn-outlined btn-block"
            onClick={async () => {
              const text = await pickFile('application/json,.json')
              if (text == null) return
              toast(importBackup(text) ? 'داده‌ها بازیابی شد' : 'این فایل پشتیبانِ مصباح الصادقین نیست')
            }}
          >
            <Icon name="upload" size={18} />
            بازیابی از فایل پشتیبان
          </button>
        </div>

        <hr />
        <SectionLabel>استفاده بدون اینترنت</SectionLabel>
        <OfflineStatus detailed />

        {isAndroid && (
          <>
            <hr />
            <SectionLabel>نسخهٔ اندروید</SectionLabel>
            <p class="help">برنامهٔ اندروید مصباح الصادقین را می‌توانید مستقیم نصب کنید.</p>
            <a class="btn btn-tonal btn-block" href={ANDROID_APK} download>
              <Icon name="download" size={18} />
              دانلود نسخهٔ اندروید
            </a>
          </>
        )}
      </div>
    </main>
  )
}
