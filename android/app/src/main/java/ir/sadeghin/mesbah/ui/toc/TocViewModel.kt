package ir.sadeghin.mesbah.ui.toc

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.ReadingProgress
import ir.sadeghin.mesbah.data.TableOfContents
import ir.sadeghin.mesbah.data.TextNormalizer
import ir.sadeghin.mesbah.data.TocEntry
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class TocRow(
    val entry: TocEntry,
    val expanded: Boolean,
    /** Shown only while filtering, so a match can be placed in the book. */
    val path: String?,
    val favorite: Boolean,
    val current: Boolean,
)

class TocViewModel(private val app: MesbahApp, val book: Book) : ViewModel() {

    private val toc = MutableStateFlow<TableOfContents?>(null)
    private val expanded = MutableStateFlow<Set<Int>>(emptySet())
    val filter = MutableStateFlow("")

    val progress: StateFlow<ReadingProgress?> = app.user.progress
        .map { list -> list.firstOrNull { it.book == book } }
        .stateIn(viewModelScope, SharingStarted.Eagerly, null)

    private val favoriteIds = app.user.favorites.map { list -> list.filter { it.book == book }.mapTo(HashSet()) { it.sectionId } }

    val rows: StateFlow<List<TocRow>?> = combine(toc.filterNotNull(), expanded, filter, favoriteIds, progress) { toc, open, query, favs, prog ->
        val needle = TextNormalizer.normalize(query)
        if (needle.isNotEmpty()) {
            toc.entries
                .filter { TextNormalizer.normalize(it.title).contains(needle) }
                .map { e ->
                    val path = toc.pathTo(e.id).joinToString(" › ") { it.title }.ifEmpty { null }
                    TocRow(e, false, path, e.id in favs, e.id == prog?.sectionId)
                }
        } else {
            // Entries are in reading order; skip everything nested under a collapsed parent.
            var hideDeeperThan = Int.MAX_VALUE
            buildList {
                for (e in toc.entries) {
                    if (e.level > hideDeeperThan) continue
                    hideDeeperThan = Int.MAX_VALUE
                    val isOpen = e.id in open
                    add(TocRow(e, isOpen, null, e.id in favs, e.id == prog?.sectionId))
                    if (e.hasChildren && !isOpen) hideDeeperThan = e.level
                }
            }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    init {
        viewModelScope.launch {
            val contents = app.books.tableOfContents(book)
            // Open the branch the reader is currently in, so they land where they left off.
            app.user.progressFor(book)?.let { p -> expanded.value = contents.pathTo(p.sectionId).mapTo(HashSet()) { it.id } }
            toc.value = contents
        }
    }

    fun toggle(entry: TocEntry) {
        expanded.value = expanded.value.let { if (entry.id in it) it - entry.id else it + entry.id }
    }

    fun expandAll(open: Boolean) {
        expanded.value = if (open) toc.value?.entries?.filter { it.hasChildren }?.mapTo(HashSet()) { it.id }.orEmpty() else emptySet()
    }

    fun toggleFavorite(row: TocRow) {
        viewModelScope.launch {
            if (row.favorite) app.user.removeFavorite(book, row.entry.id) else app.user.addFavorite(book, row.entry.id)
        }
    }

    suspend fun firstSection(): Int = app.books.tableOfContents(book).readable.first().id
}
