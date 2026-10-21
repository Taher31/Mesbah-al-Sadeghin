package ir.sadeghin.mesbah.data

data class TocEntry(
    val id: Int,
    val level: Int,
    val title: String,
    /** Group headers (e.g. «تعقیبات مشترکه») only organise the list and have no text of their own. */
    val hasContent: Boolean,
    val parentId: Int?,
    val hasChildren: Boolean,
)

class TableOfContents(val entries: List<TocEntry>) {
    private val byId = entries.associateBy { it.id }

    /** Sections that can be opened, in reading order — what the reader pages through. */
    val readable: List<TocEntry> = entries.filter { it.hasContent }

    operator fun get(id: Int): TocEntry? = byId[id]

    fun indexOfReadable(id: Int): Int = readable.indexOfFirst { it.id == id }

    /** Ancestors from the root down, e.g. to show «تعقیبات نماز › تعقیبات مشترکه». */
    fun pathTo(id: Int): List<TocEntry> {
        val path = ArrayDeque<TocEntry>()
        var cur = byId[id]?.parentId?.let { byId[it] }
        while (cur != null) {
            path.addFirst(cur)
            cur = cur.parentId?.let { byId[it] }
        }
        return path.toList()
    }
}

enum class ParagraphKind {
    /** First short line of a section, usually repeating its title. */
    Heading,
    Body,
    /** Arabic text of a supplication (Anis). */
    Arabic,
    /** Persian translation following an [Arabic] line (Anis, with-translation edition). */
    Translation,
    /** Author's explanation set apart from the supplication (marked «« in the source). */
    Note,
    Footnote,
    /** `[ص 31]` page reference of the printed book (Safineh). */
    PageMarker,
}

data class Paragraph(
    /** Stable key inside the section: `tpart` for Anis, the source line number for Safineh. */
    val key: Int,
    val kind: ParagraphKind,
    val text: String,
)

data class SearchHit(
    val book: Book,
    val sectionId: Int,
    val paragraphKey: Int,
    val sectionTitle: String,
    val snippet: String,
    val highlights: List<IntRange>,
)

data class SearchResult(val hits: List<SearchHit>, val capped: Boolean)

data class ReadingProgress(
    val book: Book,
    val sectionId: Int,
    val paragraphKey: Int,
    val updatedAt: Long,
)

/** A section the reader pinned for quick access — e.g. the supplications of a daily routine. */
data class Favorite(val book: Book, val sectionId: Int, val position: Int)

/** How often a section has been opened; feeds the «پرکاربرد» shelf. */
data class Visit(val book: Book, val sectionId: Int, val count: Int, val lastOpened: Long)

/** A page of the reader. Normally all sections of one book, but the favourites list mixes books. */
data class SectionRef(val book: Book, val sectionId: Int)

data class Bookmark(
    val id: Long,
    val book: Book,
    val sectionId: Int,
    /** [SECTION_LEVEL] when the whole section is bookmarked rather than one paragraph. */
    val paragraphKey: Int,
    val excerpt: String,
    val note: String?,
    val createdAt: Long,
) {
    companion object {
        const val SECTION_LEVEL = -1
    }
}
