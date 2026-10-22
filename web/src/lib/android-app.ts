import { android } from './native'
import { goBack, routeStore } from './router'
import { importBackup } from './store'
import { toast } from './util'

/** Hooks the app up to its Android shell; does nothing in a browser. */
export function connectAndroid() {
  if (!android) return

  // The phone's back button (AppBridge asks this first): an open sheet, dialog or find bar closes,
  // as with Escape; then back through the screens; on the home screen the app is left.
  ;(window as { mesbahBack?: () => boolean }).mesbahBack = () => {
    if (document.querySelector('.scrim, .find-bar')) {
      window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
      return true
    }
    if (routeStore.get().path.length === 0) return false
    goBack()
    return true
  }

  // Favourites, bookmarks and reading positions of the previous Android app (installed over it).
  const legacy = android.legacyData()
  if (legacy && importBackup(legacy)) {
    android.legacyImported()
    toast('منتخب‌ها و نشانه‌های نسخهٔ قبلی برنامه منتقل شد')
  }
}
