package ir.sadeghin.mesbah

import android.annotation.TargetApi
import android.content.Context
import android.graphics.Rect
import android.os.Build
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.webkit.WebView

/** Sends the phone's selection-menu Share action through the reader's citation formatter. */
class CitationWebView(context: Context) : WebView(context) {

    override fun startActionMode(callback: ActionMode.Callback): ActionMode? =
        super.startActionMode(wrap(callback))

    @TargetApi(23)
    override fun startActionMode(callback: ActionMode.Callback, type: Int): ActionMode? =
        super.startActionMode(wrap(callback), type)

    private fun wrap(callback: ActionMode.Callback): ActionMode.Callback {
        // View's legacy overload can forward into the typed overload on newer Android versions.
        if (callback is WrappedCallback) return callback
        val wrapped = SelectionCallback(callback)
        return if (Build.VERSION.SDK_INT >= 23) FloatingCallback(wrapped) else wrapped
    }

    private fun isShareItem(item: MenuItem): Boolean {
        if (Build.VERSION.SDK_INT >= 23 && item.itemId == android.R.id.shareText) return true
        // Chromium's WebView uses its own resource id instead of the platform shareText id.
        if (runCatching { resources.getResourceEntryName(item.itemId) }.getOrNull() == SHARE_RESOURCE) return true
        if (Build.VERSION.SDK_INT >= 26) {
            val provider = WebView.getCurrentWebViewPackage()?.packageName ?: return false
            return runCatching {
                context.packageManager.getResourcesForApplication(provider).getResourceEntryName(item.itemId)
            }.getOrNull() == SHARE_RESOURCE
        }
        return false
    }

    private interface WrappedCallback

    private inner class SelectionCallback(val original: ActionMode.Callback) : ActionMode.Callback, WrappedCallback {
        private var sharing = false

        override fun onCreateActionMode(mode: ActionMode, menu: Menu): Boolean = original.onCreateActionMode(mode, menu)

        override fun onPrepareActionMode(mode: ActionMode, menu: Menu): Boolean = original.onPrepareActionMode(mode, menu)

        override fun onDestroyActionMode(mode: ActionMode) = original.onDestroyActionMode(mode)

        override fun onActionItemClicked(mode: ActionMode, item: MenuItem): Boolean {
            if (!isShareItem(item)) return original.onActionItemClicked(mode, item)
            if (sharing) return true
            sharing = true
            // Keep the selection alive until the page reads both its text and printed-page range.
            return try {
                evaluateJavascript("Boolean(window.mesbahShareSelection && window.mesbahShareSelection())") { handled ->
                    sharing = false
                    if (handled == "true") mode.finish()
                    else original.onActionItemClicked(mode, item)
                }
                true
            } catch (_: RuntimeException) {
                sharing = false
                original.onActionItemClicked(mode, item)
            }
        }
    }

    /** Preserve WebView's floating-toolbar positioning instead of covering the selected words. */
    @TargetApi(23)
    private class FloatingCallback(private val delegate: SelectionCallback) : ActionMode.Callback2(), WrappedCallback {
        override fun onCreateActionMode(mode: ActionMode, menu: Menu): Boolean = delegate.onCreateActionMode(mode, menu)

        override fun onPrepareActionMode(mode: ActionMode, menu: Menu): Boolean = delegate.onPrepareActionMode(mode, menu)

        override fun onActionItemClicked(mode: ActionMode, item: MenuItem): Boolean = delegate.onActionItemClicked(mode, item)

        override fun onDestroyActionMode(mode: ActionMode) = delegate.onDestroyActionMode(mode)

        override fun onGetContentRect(mode: ActionMode, view: View, outRect: Rect) {
            val original = delegate.original
            if (original is ActionMode.Callback2) original.onGetContentRect(mode, view, outRect)
            else super.onGetContentRect(mode, view, outRect)
        }
    }

    private companion object {
        const val SHARE_RESOURCE = "select_action_menu_share"
    }
}
