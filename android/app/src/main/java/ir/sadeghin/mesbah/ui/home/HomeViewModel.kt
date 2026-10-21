package ir.sadeghin.mesbah.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.ReadingProgress
import ir.sadeghin.mesbah.data.SectionRef
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class ContinueItem(
    val progress: ReadingProgress,
    val sectionTitle: String,
    /** Position of the section among the readable ones, as a 0..1 fraction of the book. */
    val fraction: Float,
)

/** A section on one of the home shelves, with enough context to recognise it at a glance. */
data class ShelfItem(
    val ref: SectionRef,
    val title: String,
    /** The group it sits in, e.g. «تعقیبات مشترکه», when there is one. */
    val group: String?,
    val visits: Int = 0,
)

class HomeViewModel(private val app: MesbahApp) : ViewModel() {

    val continueItems: StateFlow<List<ContinueItem>> = app.user.progress
        .map { list ->
            list.mapNotNull { p ->
                val toc = app.books.tableOfContents(p.book)
                val entry = toc[p.sectionId] ?: return@mapNotNull null
                val index = toc.indexOfReadable(p.sectionId).coerceAtLeast(0)
                ContinueItem(p, entry.title, (index + 1f) / toc.readable.size.coerceAtLeast(1))
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    /** `null` until loaded, so the empty-state hint doesn't flash on start. */
    val favorites: StateFlow<List<ShelfItem>?> = app.user.favorites
        .map { list -> list.mapNotNull { shelfItem(SectionRef(it.book, it.sectionId)) } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    val frequent: StateFlow<List<ShelfItem>> = app.user.frequent
        .map { list -> list.mapNotNull { v -> shelfItem(SectionRef(v.book, v.sectionId))?.copy(visits = v.count) } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    private suspend fun shelfItem(ref: SectionRef): ShelfItem? {
        val toc = app.books.tableOfContents(ref.book)
        val entry = toc[ref.sectionId] ?: return null
        return ShelfItem(ref, entry.title, toc.pathTo(ref.sectionId).lastOrNull()?.title)
    }

    fun selectEdition(book: Book) {
        viewModelScope.launch { app.settings.setEdition(book) }
    }

    /** First readable section, for opening a book nobody has started yet. */
    suspend fun firstSection(book: Book): Int = app.books.tableOfContents(book).readable.first().id
}
