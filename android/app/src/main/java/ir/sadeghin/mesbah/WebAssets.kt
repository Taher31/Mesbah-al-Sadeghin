package ir.sadeghin.mesbah

import android.content.res.AssetManager
import android.net.Uri
import android.webkit.WebResourceResponse
import java.io.ByteArrayInputStream
import java.io.IOException

/**
 * Serves the built web app from the APK's `assets/web/` (copied there by the build, see
 * app/build.gradle.kts) at https://appassets.androidplatform.net/. An https address, unlike
 * file://, gives the page a proper origin: storage, fetch and module scripts behave as on the site.
 */
object WebAssets {
    /** The host WebView reserves for apps' own files; it is never a real site. */
    const val HOST = "appassets.androidplatform.net"

    private val types = mapOf(
        "html" to "text/html",
        "js" to "text/javascript",
        "css" to "text/css",
        "json" to "application/json",
        "webmanifest" to "application/manifest+json",
        "woff2" to "font/woff2",
        "webp" to "image/webp",
        "png" to "image/png",
        "jpg" to "image/jpeg",
        "svg" to "image/svg+xml",
        "ico" to "image/x-icon",
        "txt" to "text/plain",
    )
    private val text = setOf("html", "js", "css", "json", "webmanifest", "svg", "txt")

    fun serve(assets: AssetManager, uri: Uri): WebResourceResponse {
        val path = uri.path.orEmpty().trimStart('/').ifEmpty { "index.html" }
        val extension = path.substringAfterLast('.', "").lowercase()
        return try {
            val stream = assets.open("web/$path")
            WebResourceResponse(types[extension] ?: "application/octet-stream", if (extension in text) "utf-8" else null, stream)
        } catch (_: IOException) {
            WebResourceResponse("text/plain", "utf-8", 404, "Not Found", emptyMap(), ByteArrayInputStream(ByteArray(0)))
        }
    }
}
