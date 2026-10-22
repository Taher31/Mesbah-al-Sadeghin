/**
 * The Android app is this web app in a WebView, its files inside the APK. The Java side is exposed
 * as `window.MesbahAndroid` (android/…/AppBridge.kt); where a WebView lacks a browser API (sharing,
 * keeping the screen on, saving a file) the app asks it instead. Null in a browser.
 */
export interface AndroidBridge {
  share(text: string, title: string): void
  copy(text: string): void
  keepScreenOn(on: boolean): void
  /** Asks where to save, then writes `text` there. */
  saveFile(name: string, mime: string, text: string): void
  /** Colours behind the status bar and the navigation bar, as #rrggbb. */
  systemBars(status: string, navigation: string): void
  /** The reader's data from the previous Android app, as a backup file; '' when there is none. */
  legacyData(): string
  /** The legacy data is safely in the app now; its old files can go. */
  legacyImported(): void
}

export const android: AndroidBridge | null = (window as { MesbahAndroid?: AndroidBridge }).MesbahAndroid ?? null
