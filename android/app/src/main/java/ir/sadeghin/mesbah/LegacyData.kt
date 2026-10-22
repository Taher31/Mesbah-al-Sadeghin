package ir.sadeghin.mesbah

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Reader data left by the app this one updates, handed to the page as a backup file (the web app's
 * format, web/src/lib/store.ts) which it merges into its own storage; the old files are deleted
 * only once the page confirms.
 *
 * Two predecessors installed under the same id:
 * - the B4A app kept each book as a plain database in `files/ASSAR/N.book`, with the last position
 *   (`Edameh`), selected sections (`markTable`, now favourites) and bookmarks (`NeshanehTable`);
 * - the first Kotlin version kept them in `databases/user.db`.
 * Book ids are the same in all three (4, the retired Anis edition, is mapped to 1 by the page).
 */
class LegacyData(private val context: Context) {

    private val b4a = File(context.filesDir, "ASSAR")
    private val userDb = context.getDatabasePath("user.db")

    fun export(): String {
        if (!b4a.isDirectory && !userDb.exists()) return ""
        val data = Collected()
        if (userDb.exists()) runCatching { readKotlin(data) }.onFailure { Log.w(TAG, "user.db not readable", it) }
        if (b4a.isDirectory) {
            for (id in 1..4) {
                val file = File(b4a, "$id.book")
                if (file.exists()) runCatching { readB4a(data, id, file) }.onFailure { Log.w(TAG, "$file not readable", it) }
            }
        }
        return JSONObject()
            .put("app", "mesbah-al-sadeqin")
            .put("format", 1)
            .put("progress", data.progress)
            .put("favorites", data.favorites)
            .put("visits", data.visits)
            .put("bookmarks", data.bookmarks)
            .toString()
    }

    fun delete() {
        b4a.deleteRecursively()
        context.deleteDatabase("user.db")
        File(context.filesDir, "datastore").deleteRecursively()
    }

    private class Collected {
        val progress = JSONArray()
        val favorites = JSONArray()
        val visits = JSONArray()
        val bookmarks = JSONArray()
    }

    private fun readKotlin(data: Collected) = open(userDb).use { db ->
        db.rawQuery("SELECT book, section, paragraph, updated FROM progress", null).use { c ->
            while (c.moveToNext()) {
                data.progress.put(JSONObject().put("book", c.getInt(0)).put("section", c.getInt(1)).put("paragraph", c.getInt(2)).put("updated", c.getLong(3)))
            }
        }
        db.rawQuery("SELECT book, section FROM favorites ORDER BY position", null).use { c ->
            while (c.moveToNext()) data.favorites.put(JSONObject().put("book", c.getInt(0)).put("section", c.getInt(1)))
        }
        db.rawQuery("SELECT book, section, count, last FROM visits", null).use { c ->
            while (c.moveToNext()) {
                data.visits.put(JSONObject().put("book", c.getInt(0)).put("section", c.getInt(1)).put("count", c.getInt(2)).put("last", c.getLong(3)))
            }
        }
        db.rawQuery("SELECT id, book, section, paragraph, excerpt, note, created FROM bookmarks", null).use { c ->
            while (c.moveToNext()) {
                data.bookmarks.put(
                    JSONObject()
                        .put("id", c.getLong(0))
                        .put("book", c.getInt(1))
                        .put("section", c.getInt(2))
                        .put("paragraph", c.getInt(3))
                        .put("excerpt", c.getString(4).orEmpty())
                        .put("note", if (c.isNull(5)) JSONObject.NULL else c.getString(5))
                        .put("created", c.getLong(6)),
                )
            }
        }
    }

    private fun readB4a(data: Collected, book: Int, file: File) = open(file).use { db ->
        // The old app kept no dates; these count as older than anything the reader does from now on.
        val then = file.lastModified()
        runCatching {
            db.rawQuery("SELECT idonvan, ItemNumber FROM Edameh LIMIT 1", null).use { c ->
                if (c.moveToFirst()) {
                    data.progress.put(JSONObject().put("book", book).put("section", c.getInt(0)).put("paragraph", c.getInt(1)).put("updated", then))
                }
            }
        }
        runCatching {
            db.rawQuery("SELECT tindex FROM markTable", null).use { c ->
                while (c.moveToNext()) data.favorites.put(JSONObject().put("book", book).put("section", c.getInt(0)))
            }
        }
        runCatching {
            db.rawQuery("SELECT idonvan, ItemText, ItemNumber FROM NeshanehTable", null).use { c ->
                while (c.moveToNext()) {
                    data.bookmarks.put(
                        JSONObject()
                            .put("book", book)
                            .put("section", c.getInt(0))
                            .put("paragraph", c.getInt(2))
                            .put("excerpt", c.getString(1).orEmpty())
                            .put("created", then),
                    )
                }
            }
        }
    }

    private fun open(file: File) = SQLiteDatabase.openDatabase(file.path, null, SQLiteDatabase.OPEN_READONLY)

    private companion object {
        const val TAG = "LegacyData"
    }
}
