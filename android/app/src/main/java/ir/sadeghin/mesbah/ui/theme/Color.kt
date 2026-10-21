package ir.sadeghin.mesbah.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

// Brand: the deep teal-green and gold of the book covers and the original app.
val BrandDeep = Color(0xFF04201C)
val BrandTeal = Color(0xFF0B3A2E)
val BrandGold = Color(0xFFD9B77E)
val BrandGoldSoft = Color(0xFFE8CFA3)

internal val LightColors: ColorScheme = lightColorScheme(
    primary = Color(0xFF1D5C4E),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFCBE9DE),
    onPrimaryContainer = Color(0xFF002019),
    secondary = Color(0xFF85652B),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFF6E2BC),
    onSecondaryContainer = Color(0xFF2A1C00),
    tertiary = Color(0xFF3F6374),
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFC3E8FB),
    onTertiaryContainer = Color(0xFF001F2A),
    background = Color(0xFFFBF8F2),
    onBackground = Color(0xFF1B1C19),
    surface = Color(0xFFFBF8F2),
    onSurface = Color(0xFF1B1C19),
    surfaceVariant = Color(0xFFE5E1D6),
    onSurfaceVariant = Color(0xFF4A4740),
    surfaceContainerLowest = Color(0xFFFFFFFF),
    surfaceContainerLow = Color(0xFFF6F2EA),
    surfaceContainer = Color(0xFFF0EBE2),
    surfaceContainerHigh = Color(0xFFEAE5DB),
    surfaceContainerHighest = Color(0xFFE4DFD5),
    outline = Color(0xFF7B776E),
    outlineVariant = Color(0xFFCDC7BA),
)

internal val SepiaColors: ColorScheme = LightColors.copy(
    primary = Color(0xFF2E5B4D),
    secondary = Color(0xFF7A5A24),
    secondaryContainer = Color(0xFFEBD6AE),
    background = Color(0xFFF2E8D3),
    onBackground = Color(0xFF3A2F21),
    surface = Color(0xFFF2E8D3),
    onSurface = Color(0xFF3A2F21),
    surfaceVariant = Color(0xFFE2D5BA),
    onSurfaceVariant = Color(0xFF5B4E3B),
    surfaceContainerLowest = Color(0xFFFAF3E4),
    surfaceContainerLow = Color(0xFFEEE3CC),
    surfaceContainer = Color(0xFFE9DDC4),
    surfaceContainerHigh = Color(0xFFE3D6BB),
    surfaceContainerHighest = Color(0xFFDDCFB2),
    outline = Color(0xFF85775F),
    outlineVariant = Color(0xFFD3C4A6),
)

internal val DarkColors: ColorScheme = darkColorScheme(
    primary = BrandGold,
    onPrimary = Color(0xFF3D2A07),
    primaryContainer = Color(0xFF1C463C),
    onPrimaryContainer = Color(0xFFCBE9DE),
    secondary = Color(0xFF93D0BE),
    onSecondary = Color(0xFF00382D),
    secondaryContainer = Color(0xFF5A4520),
    onSecondaryContainer = Color(0xFFF6E2BC),
    tertiary = Color(0xFFA7CCDF),
    onTertiary = Color(0xFF093544),
    tertiaryContainer = Color(0xFF264B5B),
    onTertiaryContainer = Color(0xFFC3E8FB),
    background = Color(0xFF051916),
    onBackground = Color(0xFFE2E5E0),
    surface = Color(0xFF051916),
    onSurface = Color(0xFFE2E5E0),
    surfaceVariant = Color(0xFF283A36),
    onSurfaceVariant = Color(0xFFB8C5BF),
    surfaceContainerLowest = Color(0xFF02110E),
    surfaceContainerLow = Color(0xFF09201C),
    surfaceContainer = Color(0xFF0D2622),
    surfaceContainerHigh = Color(0xFF122E29),
    surfaceContainerHighest = Color(0xFF173631),
    outline = Color(0xFF83918B),
    outlineVariant = Color(0xFF33443F),
)

/** Colours the Material scheme has no slot for: how each kind of book text is set. */
@Immutable
data class ReaderColors(
    val arabic: Color,
    val translation: Color,
    val heading: Color,
    val noteContainer: Color,
    val onNoteContainer: Color,
    val footnote: Color,
    val searchHighlight: Color,
    val focusedParagraph: Color,
)

internal val LightReaderColors = ReaderColors(
    arabic = Color(0xFF0E4536),
    translation = Color(0xFF4F4B43),
    heading = Color(0xFF85652B),
    noteContainer = Color(0xFFF3EBDC),
    onNoteContainer = Color(0xFF3B3427),
    footnote = Color(0xFF6E6A61),
    searchHighlight = Color(0xFFFFE08A),
    focusedParagraph = Color(0x1A1D5C4E),
)

internal val SepiaReaderColors = LightReaderColors.copy(
    arabic = Color(0xFF2D3F1C),
    translation = Color(0xFF5A4C38),
    heading = Color(0xFF7A5A24),
    noteContainer = Color(0xFFE8DABD),
    onNoteContainer = Color(0xFF3A2F21),
    footnote = Color(0xFF6E604A),
    searchHighlight = Color(0xFFF5CF73),
)

internal val DarkReaderColors = ReaderColors(
    arabic = Color(0xFFEBD3A8),
    translation = Color(0xFFB4C2BC),
    heading = BrandGold,
    noteContainer = Color(0xFF102C27),
    onNoteContainer = Color(0xFFCFD8D3),
    footnote = Color(0xFF8E9C96),
    searchHighlight = Color(0xFF725A22),
    focusedParagraph = Color(0x22D9B77E),
)

val LocalReaderColors = staticCompositionLocalOf { LightReaderColors }
