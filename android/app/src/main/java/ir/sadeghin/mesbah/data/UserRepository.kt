package ir.sadeghin.mesbah.data

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext

/** Bookmarks, notes and reading positions — everything the reader creates. */
class UserRepository(context: Context) {

    private val helper = object : SQLiteOpenHelper(context, "user.db", null, 1) {
        override fun onCreate(db: SQLiteDatabase) {
            db.execSQL(
                """CREATE TABLE progress (
                    book INTEGER PRIMARY KEY,
                    section INTEGER NOT NULL,
                    paragraph INTEGER NOT NULL,
                    updated INTEGER NOT NULL)""",
            )
            db.execSQL(
                """CREATE TABLE bookmarks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    book INTEGER NOT NULL,
                    section INTEGER NOT NULL,
                    paragraph INTEGER NOT NULL,
                    excerpt TEXT NOT NULL,
                    note TEXT,
                    created INTEGER NOT NULL,
                    UNIQUE (book, section, paragraph))""",
            )
            db.execSQL(
                """CREATE TABLE favorites (
                    book INTEGER NOT NULL,
                    section INTEGER NOT NULL,
                    position INTEGER NOT NULL,
                    PRIMARY KEY (book, section))""",
            )
            db.execSQL(
                """CREATE TABLE visits (
                    book INTEGER NOT NULL,
                    section INTEGER NOT NULL,
                    count INTEGER NOT NULL,
                    last INTEGER NOT NULL,
                    PRIMARY KEY (book, section))""",
            )
        }

        override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
    }

    /** Bumped after every write; flows re-query on change (the data set is tiny). */
    private val version = MutableStateFlow(0)

    val bookmarks: Flow<List<Bookmark>> = version.map { queryBookmarks() }.flowOn(Dispatchers.IO)

    val progress: Flow<List<ReadingProgress>> = version.map { queryProgress() }.flowOn(Dispatchers.IO)

    /** In the reader's own order (they can rearrange it). */
    val favorites: Flow<List<Favorite>> = version.map { queryFavorites() }.flowOn(Dispatchers.IO)

    /** Most-opened sections first; one-off visits are left out so the shelf shows real habits. */
    val frequent: Flow<List<Visit>> = version.map { queryFrequent() }.flowOn(Dispatchers.IO)

    private fun queryFavorites(): List<Favorite> =
        helper.readableDatabase.rawQuery("SELECT book, section, position FROM favorites ORDER BY position", null).use { c ->
            buildList {
                while (c.moveToNext()) {
                    val book = Book.entries.firstOrNull { it.id == c.getInt(0) } ?: continue
                    add(Favorite(book, c.getInt(1), c.getInt(2)))
                }
            }
        }

    private fun queryFrequent(): List<Visit> =
        helper.readableDatabase.rawQuery(
            "SELECT book, section, count, last FROM visits WHERE count >= 2 ORDER BY count DESC, last DESC LIMIT 12",
            null,
        ).use { c ->
            buildList {
                while (c.moveToNext()) {
                    val book = Book.entries.firstOrNull { it.id == c.getInt(0) } ?: continue
                    add(Visit(book, c.getInt(1), c.getInt(2), c.getLong(3)))
                }
            }
        }

    suspend fun addFavorite(book: Book, sectionId: Int) = write { insertFavorite(book, sectionId) }

    suspend fun removeFavorite(book: Book, sectionId: Int) = write {
        delete("favorites", "book = ? AND section = ?", arrayOf("${book.id}", "$sectionId"))
    }

    /** Persists a new order after the reader drags items around. */
    suspend fun reorderFavorites(ordered: List<SectionRef>) = write {
        beginTransaction()
        try {
            ordered.forEachIndexed { i, ref ->
                update(
                    "favorites",
                    ContentValues().apply { put("position", i) },
                    "book = ? AND section = ?",
                    arrayOf("${ref.book.id}", "${ref.sectionId}"),
                )
            }
            setTransactionSuccessful()
        } finally {
            endTransaction()
        }
    }

    /** Counts an opening of a section; called once per section per reader visit. */
    suspend fun recordVisit(book: Book, sectionId: Int) = write {
        // Plain UPDATE-then-INSERT: UPSERT needs SQLite 3.24, which only ships from Android 11.
        val now = System.currentTimeMillis()
        val args = arrayOf("$now", "${book.id}", "$sectionId")
        val updated = compileStatement("UPDATE visits SET count = count + 1, last = ? WHERE book = ? AND section = ?").use {
            it.bindAllArgsAsStrings(args)
            it.executeUpdateDelete()
        }
        if (updated == 0) {
            insert("visits", null, ContentValues().apply {
                put("book", book.id)
                put("section", sectionId)
                put("count", 1)
                put("last", now)
            })
        }
    }

    suspend fun clearVisits() = write { delete("visits", null, null) }

    private fun queryBookmarks(): List<Bookmark> =
        helper.readableDatabase.rawQuery(
            "SELECT id, book, section, paragraph, excerpt, note, created FROM bookmarks ORDER BY created DESC",
            null,
        ).use { c ->
            buildList {
                while (c.moveToNext()) {
                    val book = Book.entries.firstOrNull { it.id == c.getInt(1) } ?: continue
                    add(Bookmark(c.getLong(0), book, c.getInt(2), c.getInt(3), c.getString(4), c.getString(5), c.getLong(6)))
                }
            }
        }

    private fun queryProgress(): List<ReadingProgress> =
        helper.readableDatabase.rawQuery("SELECT book, section, paragraph, updated FROM progress ORDER BY updated DESC", null)
            .use { c ->
                buildList {
                    while (c.moveToNext()) {
                        val book = Book.entries.firstOrNull { it.id == c.getInt(0) } ?: continue
                        add(ReadingProgress(book, c.getInt(1), c.getInt(2), c.getLong(3)))
                    }
                }
            }

    suspend fun progressFor(book: Book): ReadingProgress? = withContext(Dispatchers.IO) {
        queryProgress().firstOrNull { it.book == book }
    }

    suspend fun saveProgress(book: Book, sectionId: Int, paragraphKey: Int) = write {
        insertWithOnConflict(
            "progress",
            null,
            ContentValues().apply {
                put("book", book.id)
                put("section", sectionId)
                put("paragraph", paragraphKey)
                put("updated", System.currentTimeMillis())
            },
            SQLiteDatabase.CONFLICT_REPLACE,
        )
    }

    suspend fun addBookmark(book: Book, sectionId: Int, paragraphKey: Int, excerpt: String, note: String? = null) = write {
        insertWithOnConflict(
            "bookmarks",
            null,
            ContentValues().apply {
                put("book", book.id)
                put("section", sectionId)
                put("paragraph", paragraphKey)
                put("excerpt", excerpt.take(MAX_EXCERPT))
                put("note", note)
                put("created", System.currentTimeMillis())
            },
            SQLiteDatabase.CONFLICT_IGNORE,
        )
    }

    /** Puts back a bookmark exactly as it was, for undo. */
    suspend fun restoreBookmark(bookmark: Bookmark) = write {
        insertWithOnConflict(
            "bookmarks",
            null,
            ContentValues().apply {
                put("id", bookmark.id)
                put("book", bookmark.book.id)
                put("section", bookmark.sectionId)
                put("paragraph", bookmark.paragraphKey)
                put("excerpt", bookmark.excerpt)
                put("note", bookmark.note)
                put("created", bookmark.createdAt)
            },
            SQLiteDatabase.CONFLICT_REPLACE,
        )
    }

    suspend fun removeBookmark(book: Book, sectionId: Int, paragraphKey: Int) = write {
        delete("bookmarks", "book = ? AND section = ? AND paragraph = ?", arrayOf("${book.id}", "$sectionId", "$paragraphKey"))
    }

    suspend fun removeBookmark(id: Long) = write { delete("bookmarks", "id = ?", arrayOf("$id")) }

    suspend fun updateNote(id: Long, note: String?) = write {
        update("bookmarks", ContentValues().apply { put("note", note?.takeIf { it.isNotBlank() }) }, "id = ?", arrayOf("$id"))
    }

    private suspend fun write(block: SQLiteDatabase.() -> Unit) = withContext(Dispatchers.IO) {
        helper.writableDatabase.block()
        version.value++
    }

    internal fun SQLiteDatabase.insertFavorite(book: Book, sectionId: Int) {
        execSQL(
            """INSERT OR IGNORE INTO favorites (book, section, position)
               VALUES (?, ?, (SELECT COALESCE(MAX(position), -1) + 1 FROM favorites))""",
            arrayOf<Any>(book.id, sectionId),
        )
    }

    internal fun importLegacy(block: SQLiteDatabase.() -> Unit) {
        helper.writableDatabase.apply {
            beginTransaction()
            try {
                block()
                setTransactionSuccessful()
            } finally {
                endTransaction()
            }
        }
        version.value++
    }

    private companion object {
        const val MAX_EXCERPT = 400
    }
}
