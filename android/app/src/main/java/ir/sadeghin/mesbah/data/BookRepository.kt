package ir.sadeghin.mesbah.data

import android.database.sqlite.SQLiteDatabase
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.ConcurrentHashMap

/** Read-only access to the installed book databases. */
class BookRepository(private val installer: BookInstaller) {

    private val databases = ConcurrentHashMap<Book, SQLiteDatabase>()
    private val tocs = ConcurrentHashMap<Book, TableOfContents>()
    private val sections = LruCache<Pair<Book, Int>, List<Paragraph>>(48)

    private fun db(book: Book): SQLiteDatabase = databases.getOrPut(book) {
        SQLiteDatabase.openDatabase(
            installer.databaseFile(book).path,
            null,
            SQLiteDatabase.OPEN_READONLY or SQLiteDatabase.NO_LOCALIZED_COLLATORS,
        )
    }

    suspend fun tableOfContents(book: Book): TableOfContents = tocs[book] ?: withContext(Dispatchers.IO) {
        val rows = mutableListOf<Triple<Int, Int, Pair<String, Boolean>>>()
        db(book).rawQuery("SELECT tindex, tlevel, ttitle, ttext FROM table2 ORDER BY tindex", null).use { c ->
            while (c.moveToNext()) {
                rows += Triple(c.getInt(0), c.getInt(1), c.getString(2).orEmpty().trim() to (c.getInt(3) == 1))
            }
        }
        // Parents are implied by indentation level; rebuild them with a stack walk.
        val stack = ArrayDeque<Pair<Int, Int>>() // (level, id)
        val entries = rows.mapIndexed { i, (id, level, rest) ->
            while (stack.isNotEmpty() && stack.last().first >= level) stack.removeLast()
            val parent = stack.lastOrNull()?.second
            stack.addLast(level to id)
            val nextLevel = rows.getOrNull(i + 1)?.second ?: 0
            TocEntry(id, level, rest.first, rest.second, parent, hasChildren = nextLevel > level)
        }
        TableOfContents(entries).also { tocs[book] = it }
    }

    suspend fun section(book: Book, sectionId: Int): List<Paragraph> {
        sections.get(book to sectionId)?.let { return it }
        return withContext(Dispatchers.IO) {
            val title = tableOfContents(book)[sectionId]?.title.orEmpty()
            val paragraphs = if (book.hasParagraphTable) loadParagraphs(book, sectionId) else loadLines(book, sectionId, title)
            sections.put(book to sectionId, paragraphs)
            paragraphs
        }
    }

    private fun loadParagraphs(book: Book, sectionId: Int): List<Paragraph> {
        val result = mutableListOf<Paragraph>()
        db(book).rawQuery(
            "SELECT tpart, tType, ttext FROM Ntable3 WHERE tindex = ? ORDER BY tpart",
            arrayOf(sectionId.toString()),
        ).use { c ->
            while (c.moveToNext()) {
                val key = c.getInt(0)
                val raw = c.getString(2).orEmpty().trim()
                if (raw.isEmpty()) continue
                val kind = when (c.getInt(1)) {
                    1 -> ParagraphKind.Arabic
                    2 -> ParagraphKind.Translation
                    3 -> ParagraphKind.Note
                    4 -> ParagraphKind.Footnote
                    else -> if (result.isEmpty() && raw.length < 90) ParagraphKind.Heading else ParagraphKind.Body
                }
                val text = if (kind == ParagraphKind.Note) raw.trimStart('«').trimEnd('»').trim() else raw
                result += Paragraph(key, kind, text)
            }
        }
        return result
    }

    private fun loadLines(book: Book, sectionId: Int, title: String): List<Paragraph> {
        val text = db(book).rawQuery("SELECT ttext FROM table3 WHERE tindex = ?", arrayOf(sectionId.toString())).use { c ->
            if (c.moveToFirst()) c.getString(0).orEmpty() else ""
        }
        val normalizedTitle = TextNormalizer.normalize(title)
        val result = mutableListOf<Paragraph>()
        text.split('\n').forEachIndexed { line, rawLine ->
            val raw = rawLine.trim()
            if (raw.isEmpty()) return@forEachIndexed
            val page = pageMarker.matchEntire(raw)
            result += when {
                page != null -> Paragraph(line, ParagraphKind.PageMarker, page.groupValues[1])
                footnote.containsMatchIn(raw) -> Paragraph(line, ParagraphKind.Footnote, raw)
                result.none { it.kind != ParagraphKind.PageMarker } && TextNormalizer.normalize(raw) == normalizedTitle ->
                    Paragraph(line, ParagraphKind.Heading, raw)
                else -> Paragraph(line, ParagraphKind.Body, raw)
            }
        }
        return result
    }

    /**
     * Searches the normalized paragraphs of [books]. The query is folded the same way the index
     * was built, so «علی», «علي» and «عَلِیّ» all match each other.
     */
    suspend fun search(query: String, books: Collection<Book>, limitPerBook: Int = 150): SearchResult =
        withContext(Dispatchers.IO) {
            val needle = TextNormalizer.normalize(query)
            if (needle.length < 2) return@withContext SearchResult(emptyList(), false)
            val pattern = "%" + needle.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"
            var capped = false
            val hits = books.flatMap { book ->
                val toc = tableOfContents(book)
                val keys = mutableListOf<Pair<Int, Int>>()
                db(book).rawQuery(
                    "SELECT tindex, tpart FROM xsearch WHERE norm LIKE ? ESCAPE '\\' ORDER BY tindex, tpart LIMIT ?",
                    arrayOf(pattern, (limitPerBook + 1).toString()),
                ).use { c -> while (c.moveToNext()) keys += c.getInt(0) to c.getInt(1) }
                if (keys.size > limitPerBook) {
                    capped = true
                    keys.removeAt(keys.lastIndex)
                }
                keys.mapNotNull { (sectionId, key) ->
                    val paragraph = section(book, sectionId).firstOrNull { it.key == key } ?: return@mapNotNull null
                    val (snippet, ranges) = snippet(paragraph.text, needle)
                    SearchHit(book, sectionId, key, toc[sectionId]?.title.orEmpty(), snippet, ranges)
                }
            }
            SearchResult(hits, capped)
        }

    /** Cuts a window around the first match so long paragraphs still show the hit. */
    private fun snippet(text: String, needle: String): Pair<String, List<IntRange>> {
        val matches = TextNormalizer.findMatches(text, needle)
        val first = matches.firstOrNull() ?: return text.take(SNIPPET) to emptyList()
        if (text.length <= SNIPPET) return text to matches
        var start = (first.first - SNIPPET / 3).coerceAtLeast(0)
        // Start on a word boundary so the snippet doesn't open mid-word.
        if (start > 0) start = text.indexOf(' ', start).takeIf { it in start until first.first }?.plus(1) ?: start
        val end = (start + SNIPPET).coerceAtMost(text.length)
        val prefix = if (start > 0) "… " else ""
        val suffix = if (end < text.length) " …" else ""
        val shift = prefix.length - start
        val ranges = matches.filter { it.first >= start && it.last < end }.map { (it.first + shift)..(it.last + shift) }
        return prefix + text.substring(start, end) + suffix to ranges
    }

    private companion object {
        const val SNIPPET = 160
        val pageMarker = Regex("""^\[ص\s*([0-9۰-۹]+)\s*]$""")
        val footnote = Regex("""^\(\s*[0-9۰-۹]+\s*\)""")
    }
}
