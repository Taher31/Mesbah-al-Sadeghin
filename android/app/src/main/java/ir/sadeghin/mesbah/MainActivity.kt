package ir.sadeghin.mesbah

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.WindowManager
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.LinearLayout
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.graphics.ColorUtils
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import java.io.File
import kotlin.concurrent.thread
import kotlin.math.max

/**
 * The app is the web app (`web/`) in a WebView, its files inside the APK (see [WebAssets]), so the
 * Android and web versions are one program. This activity supplies what a WebView lacks: the back
 * button, system bar colours, choosing and saving files, opening outside links, and [AppBridge].
 */
class MainActivity : ComponentActivity() {

    private lateinit var web: WebView
    private lateinit var statusBar: View
    private lateinit var navigationBar: View
    private val prefs by lazy { getSharedPreferences("shell", MODE_PRIVATE) }

    private var fileCallback: ValueCallback<Array<Uri>>? = null
    private val openFile = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        fileCallback?.onReceiveValue(uri?.let { arrayOf(it) })
        fileCallback = null
    }

    private var pendingSave: String? = null
    private val saveFile = registerForActivityResult(ActivityResultContracts.CreateDocument("application/json")) { uri ->
        val text = pendingSave
        pendingSave = null
        if (uri == null || text == null) return@registerForActivityResult
        val ok = runCatching { contentResolver.openOutputStream(uri)?.use { it.write(text.toByteArray()) } != null }.getOrDefault(false)
        toast(if (ok) "فایل پشتیبان ذخیره شد" else "ذخیره نشد")
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        // The last page colours, so the window doesn't flash another colour while the page loads.
        val statusColor = prefs.getInt(KEY_STATUS, SPLASH)
        val navigationColor = prefs.getInt(KEY_NAVIGATION, SPLASH)
        statusBar = View(this)
        navigationBar = View(this)
        web = WebView(this)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(statusBar, LinearLayout.LayoutParams(MATCH_PARENT, 0))
            addView(web, LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f))
            addView(navigationBar, LinearLayout.LayoutParams(MATCH_PARENT, 0))
        }
        setBarColors(statusColor, navigationColor)
        web.setBackgroundColor(navigationColor)
        setContentView(root)

        // The page sits between the system bars (and above the keyboard); the strips behind the bars
        // take the page's colours.
        ViewCompat.setOnApplyWindowInsetsListener(root) { _, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout())
            val ime = insets.getInsets(WindowInsetsCompat.Type.ime())
            statusBar.layoutParams.height = bars.top
            navigationBar.layoutParams.height = max(bars.bottom, ime.bottom)
            root.setPadding(bars.left, 0, bars.right, 0)
            statusBar.requestLayout()
            navigationBar.requestLayout()
            WindowInsetsCompat.CONSUMED
        }

        WebView.setWebContentsDebuggingEnabled(BuildConfig.DEBUG)
        web.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            // Text size is the app's own setting; the system font scale would apply on top of it.
            textZoom = 100
            allowFileAccess = false
            setSupportZoom(false)
        }
        web.addJavascriptInterface(AppBridge(this), "MesbahAndroid")
        web.webViewClient = object : WebViewClient() {
            override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? =
                if (request.url.host == WebAssets.HOST) WebAssets.serve(assets, request.url) else null

            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                if (request.url.host == WebAssets.HOST) return false
                openOutside(request.url)
                return true
            }
        }
        web.webChromeClient = object : WebChromeClient() {
            override fun onShowFileChooser(view: WebView, callback: ValueCallback<Array<Uri>>, params: FileChooserParams): Boolean {
                fileCallback?.onReceiveValue(null)
                fileCallback = callback
                // Backups are JSON, but file managers label .json files inconsistently.
                runCatching { openFile.launch("*/*") }.onFailure {
                    fileCallback = null
                    callback.onReceiveValue(null)
                    toast("برنامه‌ای برای انتخاب فایل پیدا نشد")
                }
                return true
            }
        }

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                // The page closes what is open or goes back a screen; on the home screen it declines.
                web.evaluateJavascript("!!(window.mesbahBack && window.mesbahBack())") { handled ->
                    if (handled != "true") {
                        isEnabled = false
                        onBackPressedDispatcher.onBackPressed()
                        isEnabled = true
                    }
                }
            }
        })

        if (savedInstanceState == null || web.restoreState(savedInstanceState) == null) web.loadUrl(startUrl(intent))
        warnIfWebViewTooOld()
        // The first Kotlin version unpacked the books here (about 25 MB); the web data replaces them.
        thread { File(noBackupFilesDir, "books").deleteRecursively() }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.data != null) web.loadUrl(startUrl(intent))
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        web.saveState(outState)
    }

    override fun onDestroy() {
        web.destroy()
        super.onDestroy()
    }

    /** A link to the website («…/#/r/1/10») opens the same place in the app. */
    private fun startUrl(intent: Intent?): String {
        val fragment = intent?.data?.fragment
        return "https://${WebAssets.HOST}/" + if (fragment.isNullOrEmpty()) "" else "#$fragment"
    }

    fun setBarColors(status: Int, navigation: Int) {
        statusBar.setBackgroundColor(status)
        navigationBar.setBackgroundColor(navigation)
        WindowCompat.getInsetsController(window, window.decorView).apply {
            isAppearanceLightStatusBars = ColorUtils.calculateLuminance(status) > 0.5
            isAppearanceLightNavigationBars = ColorUtils.calculateLuminance(navigation) > 0.5
        }
        prefs.edit().putInt(KEY_STATUS, status).putInt(KEY_NAVIGATION, navigation).apply()
    }

    fun keepScreenOn(on: Boolean) {
        if (on) window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    fun save(name: String, text: String) {
        pendingSave = text
        runCatching { saveFile.launch(name) }.onFailure {
            pendingSave = null
            toast("برنامه‌ای برای ذخیرهٔ فایل پیدا نشد")
        }
    }

    fun share(text: String, title: String) {
        val send = Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, text)
        if (title.isNotBlank()) send.putExtra(Intent.EXTRA_SUBJECT, title)
        runCatching { startActivity(Intent.createChooser(send, null)) }
    }

    private fun openOutside(uri: Uri) {
        val intent = if (uri.scheme == "mailto") Intent(Intent.ACTION_SENDTO, uri) else Intent(Intent.ACTION_VIEW, uri)
        try {
            startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            toast("برنامه‌ای برای باز کردن این پیوند پیدا نشد")
        }
    }

    /**
     * The web app needs Chrome 87 or newer as the phone's WebView. Phones that never update
     * «Android System WebView» can have an older one; say so instead of showing a broken page.
     */
    private fun warnIfWebViewTooOld() {
        val version = runCatching { WebSettings.getDefaultUserAgent(this) }.getOrNull()
            ?.let { Regex("""Chrome/(\d+)""").find(it)?.groupValues?.get(1)?.toIntOrNull() } ?: return
        if (version >= MIN_WEBVIEW) return
        AlertDialog.Builder(this)
            .setMessage(
                "نمایشگر وب گوشی شما قدیمی است و ممکن است برنامه درست نمایش داده نشود. " +
                    "لطفاً «Android System WebView» یا «Google Chrome» را از فروشگاه برنامه‌ها به‌روز کنید.",
            )
            .setPositiveButton("باشد", null)
            .show()
    }

    private fun toast(text: String) = Toast.makeText(this, text, Toast.LENGTH_SHORT).show()

    private companion object {
        const val KEY_STATUS = "status_color"
        const val KEY_NAVIGATION = "navigation_color"
        val SPLASH = Color.rgb(0x04, 0x20, 0x1C)
        const val MIN_WEBVIEW = 87
    }
}
