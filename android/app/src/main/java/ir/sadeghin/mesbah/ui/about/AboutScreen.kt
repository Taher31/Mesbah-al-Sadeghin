package ir.sadeghin.mesbah.ui.about

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Campaign
import androidx.compose.material.icons.outlined.Email
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDirection
import androidx.compose.ui.unit.dp
import ir.sadeghin.mesbah.BuildConfig
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.SectionLabel
import ir.sadeghin.mesbah.ui.home.CHANNEL_URL
import ir.sadeghin.mesbah.ui.home.openUrl
import ir.sadeghin.mesbah.ui.reader.Ornament
import ir.sadeghin.mesbah.ui.theme.LocalReaderColors

private const val ADMIN_EMAIL = "Yaghobi01@gmail.com"
private const val DEVELOPER_EMAIL = "Anisbook@iran.ir"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val about = remember { context.resources.openRawResource(R.raw.about).bufferedReader().use { it.readText() } }
    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.about)) }, navigationIcon = { BackButton(onBack) }) },
    ) { padding ->
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .navigationBarsPadding()
                .padding(bottom = 24.dp),
        ) {
            Image(
                painterResource(R.drawable.app_logo),
                contentDescription = null,
                modifier = Modifier.padding(top = 12.dp).size(112.dp).clip(RoundedCornerShape(26.dp)),
            )
            Spacer(Modifier.height(14.dp))
            Text(stringResource(R.string.app_name), style = MaterialTheme.typography.headlineSmall, color = LocalReaderColors.current.heading)
            Text(
                stringResource(R.string.about_version, BuildConfig.VERSION_NAME.toPersianDigits()),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(16.dp))
            Ornament(LocalReaderColors.current.heading)
            Text(
                about,
                style = MaterialTheme.typography.bodyLarge.copy(textDirection = TextDirection.Rtl),
                textAlign = TextAlign.Justify,
                modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 16.dp),
            )
            SectionLabel(stringResource(R.string.about_contact), Modifier.fillMaxWidth())
            Card(
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            ) {
                Contact(Icons.Outlined.Campaign, stringResource(R.string.channel), "eitaa.com/sadeghin_ir") { openUrl(context, CHANNEL_URL) }
                Contact(Icons.Outlined.Email, stringResource(R.string.about_channel_admin), ADMIN_EMAIL) { email(context, ADMIN_EMAIL) }
                Contact(Icons.Outlined.Email, stringResource(R.string.about_developer), DEVELOPER_EMAIL) { email(context, DEVELOPER_EMAIL) }
            }
        }
    }
}

@Composable
private fun Contact(icon: ImageVector, title: String, value: String, onClick: () -> Unit) {
    ListItem(
        headlineContent = { Text(title) },
        supportingContent = { Text(value, style = MaterialTheme.typography.bodyMedium.copy(textDirection = TextDirection.Ltr)) },
        leadingContent = { Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary) },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        modifier = Modifier.clickable(onClick = onClick),
    )
}

private fun email(context: android.content.Context, address: String) {
    runCatching { context.startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$address"))) }
}
