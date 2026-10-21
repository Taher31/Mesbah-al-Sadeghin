package ir.sadeghin.mesbah.data

import android.content.Context
import androidx.annotation.StringRes
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import ir.sadeghin.mesbah.R
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

enum class ThemeMode(@StringRes val label: Int) {
    System(R.string.theme_system),
    Light(R.string.theme_light),
    Sepia(R.string.theme_sepia),
    Dark(R.string.theme_dark),
}

enum class PersianFont(val label: String) { Vazirmatn("وزیرمتن"), Nazanin("نازنین"), Lotus("لوتوس"), Mitra("میترا"), Zar("زر") }

enum class ArabicFont(val label: String) { NaskhQurani("نسخ قرآنی"), UthmanTaha("عثمان طه"), Badr("بدر") }

data class Settings(
    val themeMode: ThemeMode = ThemeMode.System,
    val persianFont: PersianFont = PersianFont.Vazirmatn,
    val arabicFont: ArabicFont = ArabicFont.NaskhQurani,
    val textSize: Float = 18f,
    val arabicSize: Float = 23f,
    val lineHeight: Float = 1.9f,
    val justify: Boolean = true,
    val keepScreenOn: Boolean = true,
    val showTranslation: Boolean = true,
    val anisEdition: Book = Book.AnisWithTranslation,
    val safinehEdition: Book = Book.SafinehPersian,
) {
    fun editionOf(work: Work): Book = when (work) {
        Work.Anis -> anisEdition
        Work.Safineh -> safinehEdition
    }

    companion object {
        val TextSizes = 14f..30f
        val ArabicSizes = 16f..36f
        val LineHeights = 1.4f..2.6f
    }
}

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class SettingsRepository(private val context: Context) {

    private object Keys {
        val theme = stringPreferencesKey("theme")
        val persianFont = stringPreferencesKey("persian_font")
        val arabicFont = stringPreferencesKey("arabic_font")
        val textSize = floatPreferencesKey("text_size")
        val arabicSize = floatPreferencesKey("arabic_size")
        val lineHeight = floatPreferencesKey("line_height")
        val justify = booleanPreferencesKey("justify")
        val keepScreenOn = booleanPreferencesKey("keep_screen_on")
        val showTranslation = booleanPreferencesKey("show_translation")
        val anisEdition = intPreferencesKey("anis_edition")
        val safinehEdition = intPreferencesKey("safineh_edition")
    }

    val settings: Flow<Settings> = context.dataStore.data.map { p ->
        val d = Settings()
        Settings(
            themeMode = p[Keys.theme].toEnum(d.themeMode),
            persianFont = p[Keys.persianFont].toEnum(d.persianFont),
            arabicFont = p[Keys.arabicFont].toEnum(d.arabicFont),
            textSize = p[Keys.textSize] ?: d.textSize,
            arabicSize = p[Keys.arabicSize] ?: d.arabicSize,
            lineHeight = p[Keys.lineHeight] ?: d.lineHeight,
            justify = p[Keys.justify] ?: d.justify,
            keepScreenOn = p[Keys.keepScreenOn] ?: d.keepScreenOn,
            showTranslation = p[Keys.showTranslation] ?: d.showTranslation,
            anisEdition = p[Keys.anisEdition]?.let(::bookOrNull)?.takeIf { it.work == Work.Anis } ?: d.anisEdition,
            safinehEdition = p[Keys.safinehEdition]?.let(::bookOrNull)?.takeIf { it.work == Work.Safineh } ?: d.safinehEdition,
        )
    }

    suspend fun setTheme(value: ThemeMode) = set(Keys.theme, value.name)
    suspend fun setPersianFont(value: PersianFont) = set(Keys.persianFont, value.name)
    suspend fun setArabicFont(value: ArabicFont) = set(Keys.arabicFont, value.name)
    suspend fun setTextSize(value: Float) = set(Keys.textSize, value)
    suspend fun setArabicSize(value: Float) = set(Keys.arabicSize, value)
    suspend fun setLineHeight(value: Float) = set(Keys.lineHeight, value)
    suspend fun setJustify(value: Boolean) = set(Keys.justify, value)
    suspend fun setKeepScreenOn(value: Boolean) = set(Keys.keepScreenOn, value)
    suspend fun setShowTranslation(value: Boolean) = set(Keys.showTranslation, value)

    suspend fun setEdition(book: Book) = set(
        if (book.work == Work.Anis) Keys.anisEdition else Keys.safinehEdition,
        book.id,
    )

    /** Restores text appearance only; theme and chosen editions are left alone. */
    suspend fun resetText() {
        context.dataStore.edit { p ->
            listOf(Keys.persianFont, Keys.arabicFont, Keys.textSize, Keys.arabicSize, Keys.lineHeight, Keys.justify)
                .forEach { p.remove(it) }
        }
    }

    private suspend fun <T> set(key: Preferences.Key<T>, value: T) {
        context.dataStore.edit { it[key] = value }
    }

    private fun bookOrNull(id: Int) = Book.entries.firstOrNull { it.id == id }

    private inline fun <reified E : Enum<E>> String?.toEnum(default: E): E =
        this?.let { name -> enumValues<E>().firstOrNull { it.name == name } } ?: default
}
