package ir.sadeghin.mesbah.data

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.io.File

/**
 * Carries reader data over from the B4A app when this build is installed as an update of it.
 *
 * That app kept each book as a plain database in `files/ASSAR/N.book`, with the reader's last
 * position (`Edameh`), selected sections (`markTable`, now favourites) and bookmarked paragraphs
 * (`NeshanehTable`) stored inside the book itself. Those rows are copied into [UserRepository],
 * then the 25 MB of old copies are removed.
 */
class LegacyImporter(private val context: Context, private val user: UserRepository) {

    fun importIfPresent() {
        val dir = File(context.filesDir, "ASSAR")
        if (!dir.isDirectory) return
        val ok = runCatching {
            user.importLegacy {
                for (book in Book.entries) {
                    val file = File(dir, "${book.assetNumber}.book")
                    if (file.exists()) importBook(this, book, file)
                }
            }
        }.onFailure { Log.w(TAG, "Legacy import failed; old files kept", it) }.isSuccess
        if (ok) dir.deleteRecursively()
    }

    private fun importBook(target: SQLiteDatabase, book: Book, file: File) {
        val old = runCatching { SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READONLY) }.getOrNull() ?: return
        old.use { db ->
            val now = System.currentTimeMillis()
            runCatching {
                db.rawQuery("SELECT idonvan, ItemNumber FROM Edameh LIMIT 1", null).use { c ->
                    if (c.moveToFirst()) {
                        target.insertWithOnConflict(
                            "progress",
                            null,
                            ContentValues().apply {
                                put("book", book.id)
                                put("section", c.getInt(0))
                                put("paragraph", c.getInt(1))
                                put("updated", now)
                            },
                            SQLiteDatabase.CONFLICT_IGNORE,
                        )
                    }
                }
            }
            // The old «منتخب» list of sections is what favourites are now.
            runCatching {
                db.rawQuery("SELECT tindex FROM markTable", null).use { c ->
                    with(user) { while (c.moveToNext()) target.insertFavorite(book, c.getInt(0)) }
                }
            }
            runCatching {
                db.rawQuery("SELECT idonvan, ItemText, ItemNumber FROM NeshanehTable", null).use { c ->
                    while (c.moveToNext()) target.insertBookmark(book, c.getInt(0), c.getInt(2), c.getString(1).orEmpty(), now)
                }
            }
        }
    }

    private fun SQLiteDatabase.insertBookmark(book: Book, section: Int, paragraph: Int, excerpt: String, now: Long) {
        insertWithOnConflict(
            "bookmarks",
            null,
            ContentValues().apply {
                put("book", book.id)
                put("section", section)
                put("paragraph", paragraph)
                put("excerpt", excerpt.take(400))
                put("created", now)
            },
            SQLiteDatabase.CONFLICT_IGNORE,
        )
    }

    private companion object {
        const val TAG = "LegacyImporter"
    }
}
