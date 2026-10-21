package ir.sadeghin.mesbah.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.ArabicFont
import ir.sadeghin.mesbah.data.PersianFont

val Vazirmatn = FontFamily(
    Font(R.font.vazirmatn_light, FontWeight.Light),
    Font(R.font.vazirmatn_regular, FontWeight.Normal),
    Font(R.font.vazirmatn_semibold, FontWeight.SemiBold),
    Font(R.font.vazirmatn_bold, FontWeight.Bold),
)

private val Nazanin = FontFamily(Font(R.font.nazanin), Font(R.font.nazanin_bold, FontWeight.Bold))
private val Lotus = FontFamily(Font(R.font.lotus), Font(R.font.lotus_bold, FontWeight.Bold))
private val Mitra = FontFamily(Font(R.font.mitra))
private val Zar = FontFamily(Font(R.font.zar))
private val NaskhQurani = FontFamily(Font(R.font.naskh_qurani))
private val UthmanTaha = FontFamily(Font(R.font.uthman_taha))
private val Badr = FontFamily(Font(R.font.badr))

val PersianFont.family: FontFamily
    get() = when (this) {
        PersianFont.Vazirmatn -> Vazirmatn
        PersianFont.Nazanin -> Nazanin
        PersianFont.Lotus -> Lotus
        PersianFont.Mitra -> Mitra
        PersianFont.Zar -> Zar
    }

val ArabicFont.family: FontFamily
    get() = when (this) {
        ArabicFont.NaskhQurani -> NaskhQurani
        ArabicFont.UthmanTaha -> UthmanTaha
        ArabicFont.Badr -> Badr
    }

private fun style(size: Int, line: Int, weight: FontWeight = FontWeight.Normal) =
    TextStyle(fontFamily = Vazirmatn, fontWeight = weight, fontSize = size.sp, lineHeight = line.sp)

// Persian glyphs sit taller than Latin ones, so line heights are a notch above Material's defaults.
internal val MesbahTypography = Typography(
    displayLarge = style(52, 68, FontWeight.Bold),
    displayMedium = style(42, 56, FontWeight.Bold),
    displaySmall = style(34, 46, FontWeight.Bold),
    headlineLarge = style(30, 42, FontWeight.Bold),
    headlineMedium = style(26, 38, FontWeight.Bold),
    headlineSmall = style(22, 34, FontWeight.SemiBold),
    titleLarge = style(20, 30, FontWeight.SemiBold),
    titleMedium = style(16, 26, FontWeight.SemiBold),
    titleSmall = style(14, 22, FontWeight.SemiBold),
    bodyLarge = style(16, 28),
    bodyMedium = style(14, 24),
    bodySmall = style(12, 20),
    labelLarge = style(14, 20, FontWeight.SemiBold),
    labelMedium = style(12, 18, FontWeight.SemiBold),
    labelSmall = style(11, 16, FontWeight.SemiBold),
)
