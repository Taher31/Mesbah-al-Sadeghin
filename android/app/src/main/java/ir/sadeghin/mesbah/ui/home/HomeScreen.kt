package ir.sadeghin.mesbah.ui.home

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.animation.Crossfade
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.PlaylistPlay
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material.icons.outlined.Campaign
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.BiasAlignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import ir.sadeghin.mesbah.BuildConfig
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.Settings
import ir.sadeghin.mesbah.data.Work
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BookCover
import ir.sadeghin.mesbah.ui.components.SectionLabel
import ir.sadeghin.mesbah.ui.components.bookLabel
import ir.sadeghin.mesbah.ui.theme.BrandDeep
import ir.sadeghin.mesbah.ui.theme.BrandGold
import ir.sadeghin.mesbah.ui.theme.BrandGoldSoft
import kotlinx.coroutines.launch

const val CHANNEL_URL = "https://eitaa.com/sadeghin_ir"

@Composable
fun HomeScreen(app: MesbahApp, settings: Settings, navigate: (String) -> Unit) {
    val vm: HomeViewModel = viewModel { HomeViewModel(app) }
    val continueItems by vm.continueItems.collectAsStateWithLifecycle()
    val favorites by vm.favorites.collectAsStateWithLifecycle()
    val frequent by vm.frequent.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background),
        contentPadding = PaddingValues(bottom = 24.dp + WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()),
    ) {
        item {
            Hero(onSettings = { navigate(Routes.SETTINGS) }, onAbout = { navigate(Routes.ABOUT) })
        }
        item {
            SearchPill(
                onClick = { navigate(Routes.search()) },
                modifier = Modifier.offset(y = (-28).dp).padding(horizontal = 20.dp),
            )
        }
        favorites?.let { list ->
            item(key = "favorites") {
                FavoritesShelf(
                    items = list,
                    onOpen = { navigate(Routes.reader(it.ref.book, it.ref.sectionId, favoritesMode = true)) },
                    onSeeAll = { navigate(Routes.FAVORITES) },
                    modifier = Modifier.offset(y = (-12).dp),
                )
            }
        }
        if (continueItems.isNotEmpty()) {
            item { SectionLabel(stringResource(R.string.continue_reading)) }
            item {
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    items(continueItems, key = { it.progress.book.id }) { item ->
                        ContinueCard(item) {
                            navigate(Routes.reader(item.progress.book, item.progress.sectionId, item.progress.paragraphKey))
                        }
                    }
                }
            }
        }
        if (frequent.isNotEmpty()) {
            item { SectionLabel(stringResource(R.string.frequent), Modifier.padding(top = 8.dp)) }
            item {
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    items(frequent, key = { "${it.ref.book.id}-${it.ref.sectionId}" }) { item ->
                        FrequentCard(item) { navigate(Routes.reader(item.ref.book, item.ref.sectionId)) }
                    }
                }
            }
        }
        item { SectionLabel(stringResource(R.string.library), Modifier.padding(top = 8.dp)) }
        items(Work.entries, key = { it.name }) { work ->
            val edition = settings.editionOf(work)
            val progress = continueItems.firstOrNull { it.progress.book == edition }
            BookCard(
                work = work,
                selected = edition,
                onSelect = vm::selectEdition,
                onOpen = { navigate(Routes.toc(edition)) },
                onContinue = progress?.let {
                    { navigate(Routes.reader(edition, it.progress.sectionId, it.progress.paragraphKey)) }
                } ?: {
                    scope.launch { navigate(Routes.reader(edition, vm.firstSection(edition))) }
                },
                started = progress != null,
            )
        }
        item {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                QuickLink(Icons.Outlined.BookmarkBorder, stringResource(R.string.bookmarks), Modifier.weight(1f)) {
                    navigate(Routes.BOOKMARKS)
                }
                QuickLink(Icons.Outlined.Campaign, stringResource(R.string.channel), Modifier.weight(1f)) {
                    openUrl(context, CHANNEL_URL)
                }
            }
        }
        item {
            Text(
                stringResource(R.string.about_version, BuildConfig.VERSION_NAME.toPersianDigits()),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.outline,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
            )
        }
    }
}

@Composable
private fun Hero(onSettings: () -> Unit, onAbout: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(360.dp)
            .background(BrandDeep),
    ) {
        Image(
            painter = painterResource(R.drawable.portrait),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            alignment = BiasAlignment(0f, -0.25f),
            modifier = Modifier.fillMaxSize(),
        )
        Box(
            Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        0f to BrandDeep.copy(alpha = 0.55f),
                        0.22f to Color.Transparent,
                        0.55f to Color.Transparent,
                        0.86f to BrandDeep.copy(alpha = 0.92f),
                        1f to BrandDeep,
                    ),
                ),
        )
        Row(
            modifier = Modifier.align(Alignment.TopEnd).statusBarsPadding().padding(8.dp),
        ) {
            HeroIcon(Icons.Outlined.Settings, stringResource(R.string.settings), onSettings)
            HeroIcon(Icons.Outlined.Info, stringResource(R.string.about), onAbout)
        }
        Column(
            modifier = Modifier.align(Alignment.BottomCenter).padding(start = 24.dp, end = 24.dp, bottom = 44.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                stringResource(R.string.app_name),
                style = MaterialTheme.typography.headlineLarge,
                color = BrandGold,
            )
            Spacer(Modifier.height(4.dp))
            Text(
                stringResource(R.string.app_tagline),
                style = MaterialTheme.typography.bodySmall,
                color = BrandGoldSoft.copy(alpha = 0.85f),
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun HeroIcon(icon: ImageVector, label: String, onClick: () -> Unit) {
    IconButton(
        onClick = onClick,
        colors = IconButtonDefaults.iconButtonColors(
            containerColor = BrandDeep.copy(alpha = 0.45f),
            contentColor = BrandGoldSoft,
        ),
        modifier = Modifier.padding(4.dp),
    ) {
        Icon(icon, contentDescription = label)
    }
}

@Composable
private fun SearchPill(onClick: () -> Unit, modifier: Modifier = Modifier) {
    Surface(
        onClick = onClick,
        shape = CircleShape,
        color = MaterialTheme.colorScheme.surfaceContainerLowest,
        shadowElevation = 6.dp,
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.6f)),
        modifier = modifier.fillMaxWidth().height(56.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(horizontal = 20.dp)) {
            Icon(Icons.Outlined.Search, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
            Spacer(Modifier.width(12.dp))
            Text(
                stringResource(R.string.search_hint),
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun ContinueCard(item: ContinueItem, onClick: () -> Unit) {
    Card(
        onClick = onClick,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
        modifier = Modifier.width(300.dp),
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            BookCover(item.progress.book, 52.dp)
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text(
                    bookLabel(item.progress.book),
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.75f),
                )
                Text(
                    item.sectionTitle,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(Modifier.height(8.dp))
                LinearProgressIndicator(
                    progress = { item.fraction },
                    modifier = Modifier.fillMaxWidth(),
                    drawStopIndicator = {},
                )
            }
        }
    }
}

@Composable
private fun BookCard(
    work: Work,
    selected: Book,
    onSelect: (Book) -> Unit,
    onOpen: () -> Unit,
    onContinue: () -> Unit,
    started: Boolean,
) {
    val editions = Book.editionsOf(work)
    ElevatedCard(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
        colors = CardDefaults.elevatedCardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
    ) {
        Row(Modifier.padding(16.dp)) {
            Crossfade(targetState = selected, label = "cover") { book ->
                BookCover(book, 104.dp, Modifier.clickable(onClick = onOpen))
            }
            Spacer(Modifier.width(16.dp))
            Column(Modifier.weight(1f)) {
                Text(stringResource(work.title), style = MaterialTheme.typography.titleLarge)
                Spacer(Modifier.height(2.dp))
                Text(
                    stringResource(work.description),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(Modifier.height(12.dp))
                SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth()) {
                    editions.forEachIndexed { i, book ->
                        SegmentedButton(
                            selected = book == selected,
                            onClick = { onSelect(book) },
                            shape = SegmentedButtonDefaults.itemShape(i, editions.size),
                            icon = {},
                        ) {
                            Text(stringResource(book.edition), style = MaterialTheme.typography.labelMedium, maxLines = 1)
                        }
                    }
                }
            }
        }
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            Button(onClick = onOpen, modifier = Modifier.weight(1f)) {
                Icon(Icons.AutoMirrored.Outlined.MenuBook, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text(stringResource(R.string.open_book))
            }
            OutlinedButton(onClick = onContinue, modifier = Modifier.weight(1f)) {
                Text(stringResource(if (started) R.string.continue_reading else R.string.start_reading))
            }
        }
    }
}

@Composable
private fun QuickLink(icon: ImageVector, label: String, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(20.dp),
        color = MaterialTheme.colorScheme.secondaryContainer,
        modifier = modifier.widthIn(min = 0.dp),
    ) {
        Row(Modifier.padding(horizontal = 16.dp, vertical = 18.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.onSecondaryContainer)
            Spacer(Modifier.width(10.dp))
            Text(
                label,
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSecondaryContainer,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

/**
 * «منتخب من»: the sections the reader starred — typically the supplications they recite daily —
 * one tap away, plus a button to read them all in a row.
 */
@Composable
private fun FavoritesShelf(
    items: List<ShelfItem>,
    onOpen: (ShelfItem) -> Unit,
    onSeeAll: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth().padding(end = 8.dp),
        ) {
            SectionLabel(stringResource(R.string.favorites), Modifier.weight(1f))
            if (items.isNotEmpty()) {
                TextButton(onClick = onSeeAll) { Text(stringResource(R.string.favorites_see_all)) }
            }
        }
        if (items.isEmpty()) {
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.6f),
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            ) {
                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Outlined.StarOutline, contentDescription = null, tint = MaterialTheme.colorScheme.secondary)
                    Spacer(Modifier.width(12.dp))
                    Text(
                        stringResource(R.string.favorites_hint_card),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                    )
                }
            }
            return@Column
        }
        Card(
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
        ) {
            items.take(HOME_FAVORITES).forEachIndexed { i, item ->
                if (i > 0) HorizontalDivider(Modifier.padding(start = 56.dp), color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { onOpen(item) }
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Filled.Star, contentDescription = null, tint = BrandGold, modifier = Modifier.size(22.dp))
                    Spacer(Modifier.width(18.dp))
                    Column(Modifier.weight(1f)) {
                        Text(item.title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        Text(
                            listOfNotNull(item.group, stringResource(item.ref.book.work.title)).joinToString(" · "),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                    Icon(
                        Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.outline,
                    )
                }
            }
            FilledTonalButton(
                onClick = { onOpen(items.first()) },
                modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 4.dp, bottom = 14.dp),
            ) {
                Icon(Icons.AutoMirrored.Filled.PlaylistPlay, contentDescription = null, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Text(stringResource(R.string.favorites_read_all))
            }
        }
    }
}

@Composable
private fun FrequentCard(item: ShelfItem, onClick: () -> Unit) {
    Surface(
        onClick = onClick,
        shape = RoundedCornerShape(18.dp),
        color = MaterialTheme.colorScheme.surfaceContainerHigh,
        modifier = Modifier.width(196.dp),
    ) {
        Column(Modifier.padding(14.dp)) {
            Text(
                item.title,
                style = MaterialTheme.typography.titleSmall,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.height(44.dp),
            )
            Spacer(Modifier.height(6.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    stringResource(item.ref.book.work.title),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f),
                    maxLines = 1,
                )
                Text(
                    stringResource(R.string.frequent_count, item.visits.toPersianDigits()),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.secondary,
                )
            }
        }
    }
}

private const val HOME_FAVORITES = 6

fun openUrl(context: Context, url: String) {
    runCatching { context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) }
}
