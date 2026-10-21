package ir.sadeghin.mesbah.ui.reader

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.Paragraph
import ir.sadeghin.mesbah.data.SectionRef
import ir.sadeghin.mesbah.data.TextNormalizer
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/** What the pager pages through, and where it opens. */
data class ReaderPages(val refs: List<SectionRef>, val initialPage: Int)

data class SectionHeader(val title: String, val path: List<String>)

class ReaderViewModel(
    private val app: MesbahApp,
    private val book: Book,
    private val startSection: Int,
    val favoritesMode: Boolean,
    query: String?,
) : ViewModel() {

    /** Folded once here; every paragraph highlights against it. */
    val normalizedQuery: String? = query?.let(TextNormalizer::normalize)?.takeIf { it.length >= 2 }

    private val _pages = MutableStateFlow<ReaderPages?>(null)
    val pages: StateFlow<ReaderPages?> = _pages.asStateFlow()

    val favorites: StateFlow<Set<SectionRef>> = app.user.favorites
        .map { list -> list.mapTo(HashSet()) { SectionRef(it.book, it.sectionId) } }
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptySet())

    /** Bookmarked paragraph keys per section. */
    val bookmarks: StateFlow<Map<SectionRef, Set<Int>>> = app.user.bookmarks
        .map { list -> list.groupBy({ SectionRef(it.book, it.sectionId) }, { it.paragraphKey }).mapValues { it.value.toSet() } }
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyMap())

    private val visited = HashSet<SectionRef>()
    private var progressJob: Job? = null

    init {
        viewModelScope.launch {
            val start = SectionRef(book, startSection)
            var refs = if (favoritesMode) {
                app.user.favorites.first().map { SectionRef(it.book, it.sectionId) }
            } else {
                app.books.tableOfContents(book).readable.map { SectionRef(book, it.id) }
            }
            if (start !in refs) refs = listOf(start) + refs
            _pages.value = ReaderPages(refs, refs.indexOf(start))
        }
    }

    suspend fun paragraphs(ref: SectionRef): List<Paragraph> = app.books.section(ref.book, ref.sectionId)

    suspend fun header(ref: SectionRef): SectionHeader {
        val toc = app.books.tableOfContents(ref.book)
        return SectionHeader(toc[ref.sectionId]?.title.orEmpty(), toc.pathTo(ref.sectionId).map { it.title })
    }

    /** Called when a page settles: counts the visit (once per stay) for the «پرکاربرد» shelf. */
    fun onPageShown(ref: SectionRef) {
        if (visited.add(ref)) viewModelScope.launch { app.user.recordVisit(ref.book, ref.sectionId) }
    }

    /** Debounced: scrolling reports positions constantly, the database only needs the resting one. */
    fun onPosition(ref: SectionRef, paragraphKey: Int) {
        progressJob?.cancel()
        progressJob = viewModelScope.launch {
            delay(700)
            app.user.saveProgress(ref.book, ref.sectionId, paragraphKey)
        }
    }

    /** @return true when the section is now a favourite. */
    fun toggleFavorite(ref: SectionRef): Boolean {
        val adding = ref !in favorites.value
        viewModelScope.launch {
            if (adding) app.user.addFavorite(ref.book, ref.sectionId) else app.user.removeFavorite(ref.book, ref.sectionId)
        }
        return adding
    }

    /** @return true when the paragraph is now bookmarked. */
    fun toggleBookmark(ref: SectionRef, paragraph: Paragraph): Boolean {
        val adding = bookmarks.value[ref]?.contains(paragraph.key) != true
        viewModelScope.launch {
            if (adding) {
                app.user.addBookmark(ref.book, ref.sectionId, paragraph.key, paragraph.text)
            } else {
                app.user.removeBookmark(ref.book, ref.sectionId, paragraph.key)
            }
        }
        return adding
    }

    fun setShowTranslation(show: Boolean) {
        viewModelScope.launch { app.settings.setShowTranslation(show) }
    }
}
