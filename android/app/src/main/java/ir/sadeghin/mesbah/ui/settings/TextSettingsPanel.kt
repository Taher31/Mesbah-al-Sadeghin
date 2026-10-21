package ir.sadeghin.mesbah.ui.settings

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.ArabicFont
import ir.sadeghin.mesbah.data.PersianFont
import ir.sadeghin.mesbah.data.Settings
import ir.sadeghin.mesbah.data.SettingsRepository
import ir.sadeghin.mesbah.data.ThemeMode
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.theme.LocalReaderColors
import ir.sadeghin.mesbah.ui.theme.family
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

/** Theme, fonts and sizes with a live preview; used in the reader's sheet and on the settings page. */
@Composable
fun TextSettingsPanel(
    settings: Settings,
    repo: SettingsRepository,
    showTranslationToggle: Boolean,
    modifier: Modifier = Modifier,
) {
    val scope = rememberCoroutineScope()
    Column(modifier.padding(horizontal = 20.dp)) {
        Preview(settings)
        Spacer(Modifier.height(16.dp))

        Label(stringResource(R.string.settings_theme))
        SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth()) {
            ThemeMode.entries.forEachIndexed { i, mode ->
                SegmentedButton(
                    selected = settings.themeMode == mode,
                    onClick = { scope.launch { repo.setTheme(mode) } },
                    shape = SegmentedButtonDefaults.itemShape(i, ThemeMode.entries.size),
                    icon = {},
                ) { Text(stringResource(mode.label), maxLines = 1) }
            }
        }

        Label(stringResource(R.string.settings_arabic_font))
        ChipRow {
            ArabicFont.entries.forEach { font ->
                FilterChip(
                    selected = settings.arabicFont == font,
                    onClick = { scope.launch { repo.setArabicFont(font) } },
                    label = { Text(font.label, fontFamily = font.family, fontSize = 17.sp) },
                )
            }
        }

        Label(stringResource(R.string.settings_persian_font))
        ChipRow {
            PersianFont.entries.forEach { font ->
                FilterChip(
                    selected = settings.persianFont == font,
                    onClick = { scope.launch { repo.setPersianFont(font) } },
                    label = { Text(font.label, fontFamily = font.family, fontSize = 16.sp) },
                )
            }
        }

        SizeSlider(stringResource(R.string.settings_arabic_size), settings.arabicSize, Settings.ArabicSizes) {
            scope.launch { repo.setArabicSize(it) }
        }
        SizeSlider(stringResource(R.string.settings_text_size), settings.textSize, Settings.TextSizes) {
            scope.launch { repo.setTextSize(it) }
        }
        SizeSlider(stringResource(R.string.settings_line_height), settings.lineHeight, Settings.LineHeights, decimals = true) {
            scope.launch { repo.setLineHeight(it) }
        }

        SwitchRow(stringResource(R.string.settings_justify), settings.justify) { scope.launch { repo.setJustify(it) } }
        if (showTranslationToggle) {
            SwitchRow(stringResource(R.string.reader_show_translation), settings.showTranslation) {
                scope.launch { repo.setShowTranslation(it) }
            }
        }
    }
}

@Composable
private fun Preview(settings: Settings) {
    val colors = LocalReaderColors.current
    Surface(
        shape = RoundedCornerShape(20.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(horizontal = 18.dp, vertical = 14.dp)) {
            Text(
                stringResource(R.string.settings_preview_arabic),
                style = TextStyle(
                    fontFamily = settings.arabicFont.family,
                    fontSize = settings.arabicSize.sp,
                    lineHeight = settings.lineHeight.em,
                    color = colors.arabic,
                    textAlign = TextAlign.Center,
                ),
                modifier = Modifier.fillMaxWidth(),
            )
            Text(
                stringResource(R.string.settings_preview_persian),
                style = TextStyle(
                    fontFamily = settings.persianFont.family,
                    fontSize = (settings.textSize - 1.5f).sp,
                    lineHeight = (settings.lineHeight * 0.95f).em,
                    color = colors.translation,
                    textAlign = TextAlign.Center,
                ),
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}

@Composable
private fun Label(text: String) {
    Text(
        text,
        style = MaterialTheme.typography.labelLarge,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.padding(top = 16.dp, bottom = 8.dp),
    )
}

@Composable
private fun ChipRow(content: @Composable () -> Unit) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()),
    ) { content() }
}

/** Updates the preview while dragging but only writes the setting when the finger lifts. */
@Composable
private fun SizeSlider(
    label: String,
    value: Float,
    range: ClosedFloatingPointRange<Float>,
    decimals: Boolean = false,
    onChange: (Float) -> Unit,
) {
    var dragging by remember(value) { mutableFloatStateOf(value) }
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(top = 12.dp)) {
        Text(label, style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.weight(1f))
        Text(
            (if (decimals) "%.1f".format(java.util.Locale.US, dragging) else dragging.roundToInt().toString()).toPersianDigits(),
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary,
        )
    }
    Slider(
        value = dragging,
        onValueChange = { dragging = if (decimals) (it * 10).roundToInt() / 10f else it.roundToInt().toFloat() },
        onValueChangeFinished = { onChange(dragging) },
        valueRange = range,
    )
}

@Composable
private fun SwitchRow(label: String, checked: Boolean, onChange: (Boolean) -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth().padding(top = 8.dp)) {
        Text(label, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
        Spacer(Modifier.width(12.dp))
        Switch(checked = checked, onCheckedChange = onChange)
    }
}
