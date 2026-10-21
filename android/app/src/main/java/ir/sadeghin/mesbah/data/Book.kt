package ir.sadeghin.mesbah.data

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import ir.sadeghin.mesbah.R

/** The two works, each shipped in two editions. */
enum class Work(@StringRes val title: Int, @StringRes val description: Int) {
    Anis(R.string.book_anis, R.string.book_anis_desc),
    Safineh(R.string.book_safineh, R.string.book_safineh_desc),
}

/**
 * One edition = one bundled database. [assetNumber] is the `N.book` file in assets; [id] is what
 * user data and navigation routes store, so it must never change.
 */
enum class Book(
    val id: Int,
    val assetNumber: Int,
    val work: Work,
    @StringRes val edition: Int,
    @DrawableRes val cover: Int,
    /** Anis editions store their text paragraph-by-paragraph in `Ntable3`; Safineh only has `table3`. */
    val hasParagraphTable: Boolean,
    /** Body language decides the default font and the direction of the body text. */
    val arabicBody: Boolean,
) {
    AnisWithTranslation(1, 1, Work.Anis, R.string.edition_with_translation, R.drawable.cover_anis_tr, true, false),
    AnisWithoutTranslation(4, 4, Work.Anis, R.string.edition_without_translation, R.drawable.cover_anis, true, false),
    SafinehPersian(3, 3, Work.Safineh, R.string.edition_persian, R.drawable.cover_safineh_fa, false, false),
    SafinehArabic(2, 2, Work.Safineh, R.string.edition_arabic, R.drawable.cover_safineh_ar, false, true);

    companion object {
        fun fromId(id: Int): Book = entries.first { it.id == id }
        fun editionsOf(work: Work): List<Book> = entries.filter { it.work == work }
    }
}
