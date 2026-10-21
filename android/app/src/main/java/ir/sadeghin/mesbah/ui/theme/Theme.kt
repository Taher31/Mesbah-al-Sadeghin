package ir.sadeghin.mesbah.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import ir.sadeghin.mesbah.data.ThemeMode

@Composable
fun isDarkTheme(mode: ThemeMode): Boolean = when (mode) {
    ThemeMode.System -> isSystemInDarkTheme()
    ThemeMode.Dark -> true
    ThemeMode.Light, ThemeMode.Sepia -> false
}

private val MesbahShapes = Shapes(
    extraSmall = RoundedCornerShape(6.dp),
    small = RoundedCornerShape(10.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(32.dp),
)

@Composable
fun MesbahTheme(themeMode: ThemeMode, content: @Composable () -> Unit) {
    val dark = isDarkTheme(themeMode)
    val (colors, readerColors) = when {
        dark -> DarkColors to DarkReaderColors
        themeMode == ThemeMode.Sepia -> SepiaColors to SepiaReaderColors
        else -> LightColors to LightReaderColors
    }
    MaterialTheme(colorScheme = colors, typography = MesbahTypography, shapes = MesbahShapes) {
        // The whole UI is Persian, so it reads right-to-left even on a device set to English.
        CompositionLocalProvider(
            LocalLayoutDirection provides LayoutDirection.Rtl,
            LocalReaderColors provides readerColors,
            content = content,
        )
    }
}
