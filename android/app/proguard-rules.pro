# The page calls AppBridge by name through the WebView; keep its methods.
-keepclassmembers class ir.sadeghin.mesbah.AppBridge {
    @android.webkit.JavascriptInterface <methods>;
}
