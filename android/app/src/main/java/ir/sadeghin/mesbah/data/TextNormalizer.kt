package ir.sadeghin.mesbah.data

/**
 * Folds Persian/Arabic text to a search key: drops diacritics and tatweel, unifies the letter
 * variants people type interchangeably (ی/ي/ى, ک/ك, أ/إ/آ → ا …) and digits, and collapses spacing.
 *
 * Every step maps one input char to at most one output char, so [normalizeWithMap] can report
 * where each folded char came from — that is what lets the reader highlight a match in the
 * original, fully vowelled text.
 */
object TextNormalizer {

    fun normalize(text: String): String = normalizeWithMap(text).first

    fun normalizeWithMap(text: String): Pair<String, IntArray> {
        val out = StringBuilder(text.length)
        val map = IntArray(text.length)
        var lastWasSpace = true
        for (i in text.indices) {
            val folded = fold(text[i]) ?: continue
            if (folded == ' ') {
                if (lastWasSpace) continue
                lastWasSpace = true
            } else {
                lastWasSpace = false
            }
            map[out.length] = i
            out.append(folded)
        }
        if (out.isNotEmpty() && out[out.length - 1] == ' ') out.setLength(out.length - 1)
        return out.toString() to map.copyOf(out.length)
    }

    /** Returns `null` for chars that carry no search meaning. */
    private fun fold(c: Char): Char? = when (c) {
        in 'ً'..'ٟ', 'ٰ', 'ـ', in 'ۖ'..'ۭ' -> null // harakat, superscript alef, tatweel, Quranic marks
        'ي', 'ى', 'ئ' -> 'ی'
        'ك' -> 'ک'
        'أ', 'إ', 'آ', 'ٱ' -> 'ا'
        'ؤ' -> 'و'
        'ة', 'ۀ' -> 'ه'
        '‌', '‏', '‎', '\n', '\t', '\r', ' ' -> ' '
        in '۰'..'۹' -> '0' + (c - '۰')
        in '٠'..'٩' -> '0' + (c - '٠')
        '«', '»', '"', '“', '”' -> null
        else -> c
    }

    /**
     * Finds every occurrence of [query] (already normalized) in [text] and returns the matching
     * ranges in [text]'s own coordinates.
     */
    fun findMatches(text: String, normalizedQuery: String): List<IntRange> {
        if (normalizedQuery.isBlank()) return emptyList()
        val (folded, map) = normalizeWithMap(text)
        val result = mutableListOf<IntRange>()
        var from = 0
        while (true) {
            val at = folded.indexOf(normalizedQuery, from)
            if (at < 0) break
            val end = at + normalizedQuery.length - 1
            result += map[at]..map[end]
            from = at + normalizedQuery.length
        }
        return result
    }
}

private val persianDigits = charArrayOf('۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹')

/** Shows numbers the way the rest of the Persian UI reads. */
fun Int.toPersianDigits(): String = toString().toPersianDigits()

fun String.toPersianDigits(): String = buildString(length) {
    for (c in this@toPersianDigits) append(if (c in '0'..'9') persianDigits[c - '0'] else c)
}
