package ir.sadeghin.mesbah.ui.reader

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.outlined.Lightbulb
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.Paragraph
import ir.sadeghin.mesbah.data.ParagraphKind
import ir.sadeghin.mesbah.data.Settings
import ir.sadeghin.mesbah.data.TextNormalizer
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.theme.LocalReaderColors
import ir.sadeghin.mesbah.ui.theme.ReaderColors
import ir.sadeghin.mesbah.ui.theme.Vazirmatn
import ir.sadeghin.mesbah.ui.theme.family

/** Text styles for one book under the current settings; built once per settings change. */
class ReaderStyles(book: Book, s: Settings, private val colors: ReaderColors) {
    private val persian = s.persianFont.family
    private val arabic = s.arabicFont.family

    /** In the with-translation edition each Arabic line is a short phrase paired with its meaning. */
    private val paired = book == Book.AnisWithTranslation
    private val prose = if (s.justify) TextAlign.Justify else TextAlign.Start

    val body = TextStyle(
        fontFamily = if (book.arabicBody) arabic else persian,
        fontSize = (if (book.arabicBody) s.textSize + 3 else s.textSize).sp,
        lineHeight = s.lineHeight.em,
        textAlign = prose,
        textDirection = TextDirection.Rtl,
    )
    val arabicText = TextStyle(
        fontFamily = arabic,
        fontSize = s.arabicSize.sp,
        lineHeight = (s.lineHeight * 1.02f).em,
        textAlign = if (paired) TextAlign.Center else prose,
        textDirection = TextDirection.Rtl,
        color = colors.arabic,
    )
    val translation = TextStyle(
        fontFamily = persian,
        fontSize = (s.textSize - 1.5f).sp,
        lineHeight = (s.lineHeight * 0.95f).em,
        textAlign = if (paired) TextAlign.Center else prose,
        textDirection = TextDirection.Rtl,
        color = colors.translation,
    )
    val note = body.copy(fontSize = (s.textSize - 1f).sp, color = colors.onNoteContainer)
    val footnote = TextStyle(
        fontFamily = persian,
        fontSize = (s.textSize * 0.74f).coerceAtLeast(12f).sp,
        lineHeight = 1.6.em,
        textAlign = TextAlign.Start,
        textDirection = TextDirection.Rtl,
        color = colors.footnote,
    )
    val heading = TextStyle(
        fontFamily = Vazirmatn,
        fontWeight = FontWeight.SemiBold,
        fontSize = (s.textSize + 1f).sp,
        lineHeight = 1.6.em,
        textAlign = TextAlign.Center,
        color = colors.heading,
    )
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ParagraphView(
    paragraph: Paragraph,
    previous: Paragraph?,
    styles: ReaderStyles,
    query: String?,
    bookmarked: Boolean,
    focused: Boolean,
    onLongPress: () -> Unit,
) {
    val colors = LocalReaderColors.current
    val text = rememberHighlighted(paragraph.text, query, colors.searchHighlight)
    val top = when (paragraph.kind) {
        ParagraphKind.Translation -> 2.dp
        ParagraphKind.Arabic -> if (previous?.kind == ParagraphKind.Translation || previous?.kind == ParagraphKind.Arabic) 14.dp else 10.dp
        ParagraphKind.Footnote -> if (previous?.kind == ParagraphKind.Footnote) 2.dp else 20.dp
        ParagraphKind.Note, ParagraphKind.PageMarker, ParagraphKind.Heading -> 16.dp
        ParagraphKind.Body -> 10.dp
    }
    Column(Modifier.padding(top = top)) {
        if (paragraph.kind == ParagraphKind.Footnote && previous?.kind != ParagraphKind.Footnote) {
            HorizontalDivider(Modifier.width(72.dp).padding(bottom = 8.dp), color = colors.footnote.copy(alpha = 0.4f))
        }
        Box(
            Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(if (focused) colors.focusedParagraph else Color.Transparent)
                .combinedClickable(onClick = {}, onLongClick = onLongPress)
                .padding(horizontal = 4.dp, vertical = 2.dp),
        ) {
            when (paragraph.kind) {
                ParagraphKind.Heading -> Text(text, style = styles.heading, modifier = Modifier.fillMaxWidth())
                ParagraphKind.Body -> Text(text, style = styles.body.copy(color = MaterialTheme.colorScheme.onSurface))
                ParagraphKind.Arabic -> Text(text, style = styles.arabicText, modifier = Modifier.fillMaxWidth())
                ParagraphKind.Translation -> Text(text, style = styles.translation, modifier = Modifier.fillMaxWidth())
                ParagraphKind.Footnote -> Text(text, style = styles.footnote)
                ParagraphKind.Note -> NoteCard(text, styles, colors)
                ParagraphKind.PageMarker -> PageMarker(paragraph.text)
            }
            if (bookmarked) {
                Icon(
                    Icons.Filled.Bookmark,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.secondary,
                    modifier = Modifier.align(Alignment.TopEnd).size(16.dp),
                )
            }
        }
    }
}

@Composable
private fun NoteCard(text: AnnotatedString, styles: ReaderStyles, colors: ReaderColors) {
    Surface(shape = RoundedCornerShape(16.dp), color = colors.noteContainer, modifier = Modifier.fillMaxWidth()) {
        Row(Modifier.padding(start = 14.dp, end = 16.dp, top = 14.dp, bottom = 14.dp)) {
            Icon(
                Icons.Outlined.Lightbulb,
                contentDescription = null,
                tint = colors.heading,
                modifier = Modifier.padding(top = 4.dp).size(18.dp),
            )
            Spacer(Modifier.width(10.dp))
            Text(text, style = styles.note)
        }
    }
}

@Composable
private fun PageMarker(number: String) {
    val color = MaterialTheme.colorScheme.outline
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxWidth(),
    ) {
        HorizontalDivider(Modifier.weight(1f), color = color.copy(alpha = 0.3f))
        Text(
            stringResource(R.string.reader_page, number.toPersianDigits()),
            style = MaterialTheme.typography.labelSmall,
            color = color,
            modifier = Modifier.padding(horizontal = 12.dp),
        )
        HorizontalDivider(Modifier.weight(1f), color = color.copy(alpha = 0.3f))
    }
}

/** Title block at the top of each section: breadcrumb, title and a small ornament. */
@Composable
fun SectionTitle(title: String, path: List<String>, bookLabel: String?) {
    val colors = LocalReaderColors.current
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.fillMaxWidth().padding(top = 8.dp, bottom = 12.dp),
    ) {
        val crumbs = listOfNotNull(bookLabel) + path
        if (crumbs.isNotEmpty()) {
            Text(
                crumbs.joinToString("  ›  "),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(6.dp))
        }
        Text(
            title,
            style = MaterialTheme.typography.headlineSmall,
            color = colors.heading,
            textAlign = TextAlign.Center,
        )
        Spacer(Modifier.height(14.dp))
        Ornament(colors.heading)
    }
}

@Composable
fun Ornament(color: Color, modifier: Modifier = Modifier) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = modifier) {
        HorizontalDivider(Modifier.width(48.dp), color = color.copy(alpha = 0.5f))
        Box(
            Modifier
                .padding(horizontal = 8.dp)
                .size(7.dp)
                .rotate(45f)
                .background(color.copy(alpha = 0.8f)),
        )
        HorizontalDivider(Modifier.width(48.dp), color = color.copy(alpha = 0.5f))
    }
}

@Composable
private fun rememberHighlighted(text: String, query: String?, color: Color): AnnotatedString =
    remember(text, query, color) {
        if (query == null) return@remember AnnotatedString(text)
        val ranges = TextNormalizer.findMatches(text, query)
        buildAnnotatedString {
            append(text)
            ranges.forEach { addStyle(SpanStyle(background = color), it.first, it.last + 1) }
        }
    }
