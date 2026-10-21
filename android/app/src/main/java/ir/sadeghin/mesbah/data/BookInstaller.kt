package ir.sadeghin.mesbah.data

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import ir.sadeghin.mesbah.BuildConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Turns the scrambled `assets/books/N.book` files into ready-to-query SQLite databases.
 *
 * The bundled files are SQLite with every byte XOR-ed with 0xFF (kept from the original app so the
 * text isn't trivially extractable from the APK). On install each one is unscrambled, given the
 * indexes the original lacked, and a search table of normalized paragraphs is built so search
 * ignores diacritics and letter variants without scanning raw text.
 *
 * Books are rebuilt whenever the app version changes, and they live in `noBackupFilesDir` —
 * reader data is kept separately in [UserRepository], so replacing a book never loses bookmarks
 * (the B4A app stored bookmarks inside the book files and wiped them on every content update).
 */
class BookInstaller(private val context: Context) {

    private val dir = File(context.noBackupFilesDir, "books")

    fun databaseFile(book: Book) = File(dir, "${book.assetNumber}.db")

    private val stamp get() = File(dir, "ready-$FORMAT_VERSION-${BuildConfig.VERSION_CODE}")

    fun isInstalled(): Boolean = stamp.exists() && Book.entries.all { databaseFile(it).exists() }

    suspend fun install(onProgress: (Float) -> Unit) = withContext(Dispatchers.IO) {
        if (isInstalled()) {
            onProgress(1f)
            return@withContext
        }
        dir.deleteRecursively()
        dir.mkdirs()
        // Weighted by size so the bar moves evenly; the big Anis edition dominates.
        val weights = Book.entries.associateWith { book ->
            context.assets.openFd("books/${book.assetNumber}.book").use { it.length.toFloat() }
        }
        val total = weights.values.sum()
        var done = 0f
        for (book in Book.entries) {
            installOne(book)
            done += weights.getValue(book)
            onProgress(done / total)
        }
        stamp.createNewFile()
    }

    private fun installOne(book: Book) {
        val tmp = File(dir, "${book.assetNumber}.tmp")
        context.assets.open("books/${book.assetNumber}.book").use { input ->
            tmp.outputStream().buffered(1 shl 16).use { output ->
                val buf = ByteArray(1 shl 16)
                while (true) {
                    val n = input.read(buf)
                    if (n < 0) break
                    for (i in 0 until n) buf[i] = (buf[i].toInt() xor 0xFF).toByte()
                    output.write(buf, 0, n)
                }
            }
        }
        val db = SQLiteDatabase.openDatabase(tmp.path, null, SQLiteDatabase.OPEN_READWRITE)
        try {
            db.beginTransaction()
            try {
                db.execSQL("CREATE INDEX IF NOT EXISTS ix_toc ON table2(tindex)")
                db.execSQL("CREATE INDEX IF NOT EXISTS ix_text ON table3(tindex)")
                if (book.hasParagraphTable) db.execSQL("CREATE INDEX IF NOT EXISTS ix_par ON Ntable3(tindex, tpart)")
                buildSearchTable(db, book)
                db.setTransactionSuccessful()
            } finally {
                db.endTransaction()
            }
        } finally {
            db.close()
        }
        File(tmp.path + "-journal").delete()
        check(tmp.renameTo(databaseFile(book))) { "Could not move ${tmp.name} into place" }
    }

    private fun buildSearchTable(db: SQLiteDatabase, book: Book) {
        db.execSQL("DROP TABLE IF EXISTS xsearch")
        db.execSQL("CREATE TABLE xsearch (tindex INTEGER NOT NULL, tpart INTEGER NOT NULL, norm TEXT NOT NULL)")
        val insert = db.compileStatement("INSERT INTO xsearch (tindex, tpart, norm) VALUES (?, ?, ?)")
        fun add(section: Int, key: Int, text: String) {
            val norm = TextNormalizer.normalize(text)
            if (norm.isBlank()) return
            insert.bindLong(1, section.toLong())
            insert.bindLong(2, key.toLong())
            insert.bindString(3, norm)
            insert.executeInsert()
        }
        if (book.hasParagraphTable) {
            db.rawQuery("SELECT tindex, tpart, ttext FROM Ntable3", null).use { c ->
                while (c.moveToNext()) add(c.getInt(0), c.getInt(1), c.getString(2).orEmpty())
            }
        } else {
            db.rawQuery("SELECT tindex, ttext FROM table3", null).use { c ->
                while (c.moveToNext()) {
                    c.getString(1).orEmpty().split('\n').forEachIndexed { line, text -> add(c.getInt(0), line, text) }
                }
            }
        }
        insert.close()
    }

    private companion object {
        /** Bump when the on-disk layout produced here changes, to force a rebuild. */
        const val FORMAT_VERSION = 1
    }
}
