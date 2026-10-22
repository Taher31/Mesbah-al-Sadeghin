package ir.sadeghin.mesbah

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.webkit.JavascriptInterface

/**
 * `window.MesbahAndroid` in the page (web/src/lib/native.ts lists the same methods). Calls arrive on
 * a WebView thread; anything touching the UI moves to the main thread. Only the app's own pages are
 * ever loaded (other links open outside), so only they can reach it.
 */
class AppBridge(private val activity: MainActivity) {

    private val legacy = LegacyData(activity)

    @JavascriptInterface
    fun share(text: String, title: String) = activity.runOnUiThread { activity.share(text, title) }

    @JavascriptInterface
    fun copy(text: String) = activity.runOnUiThread {
        val clipboard = activity.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText(activity.getString(R.string.app_name), text))
    }

    @JavascriptInterface
    fun keepScreenOn(on: Boolean) = activity.runOnUiThread { activity.keepScreenOn(on) }

    @JavascriptInterface
    fun saveFile(name: String, @Suppress("UNUSED_PARAMETER") mime: String, text: String) = activity.runOnUiThread { activity.save(name, text) }

    @JavascriptInterface
    fun systemBars(status: String, navigation: String) {
        val s = runCatching { Color.parseColor(status) }.getOrNull() ?: return
        val n = runCatching { Color.parseColor(navigation) }.getOrNull() ?: return
        activity.runOnUiThread { activity.setBarColors(s, n) }
    }

    @JavascriptInterface
    fun legacyData(): String = legacy.export()

    @JavascriptInterface
    fun legacyImported() = legacy.delete()
}
