package ir.sadeghin.mesbah.ui.reader

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.compose.animation.AnimatedContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.automirrored.outlined.List
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.BookmarkAdd
import androidx.compose.material.icons.outlined.ContentCopy
import androidx.compose.material.icons.outlined.MoreVert
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.Share
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material.icons.outlined.TextFields
import androidx.compose.material.icons.outlined.Translate
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.Paragraph
import ir.sadeghin.mesbah.data.ParagraphKind
import ir.sadeghin.mesbah.data.SectionRef
import ir.sadeghin.mesbah.data.Settings
import ir.sadeghin.mesbah.data.TextNormalizer
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.bookLabel
import ir.sadeghin.mesbah.ui.settings.TextSettingsPanel
import ir.sadeghin.mesbah.ui.theme.BrandGold
import ir.sadeghin.mesbah.ui.theme.LocalReaderColors
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReaderScreen(
    app: MesbahApp,
    settings: Settings,
    book: Book,
    startSection: Int,
    startParagraph: Int?,
    query: String?,
    favoritesMode: Boolean,
    navigate: (String) -> Unit,
    onBack: () -> Unit,
) {
    val vm: ReaderViewModel = viewModel { ReaderViewModel(app, book, startSection, favoritesMode, query) }
    val pages by vm.pages.collectAsStateWithLifecycle()
    KeepScreenOn(settings.keepScreenOn)

    val loaded = pages
    if (loaded == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
        return
    }

    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val snackbar = remember { SnackbarHostState() }
    val pager = rememberPagerState(initialPage = loaded.initialPage) { loaded.refs.size }
    val current = loaded.refs[pager.currentPage]
    val favorites by vm.favorites.collectAsStateWithLifecycle()
    val bookmarks by vm.bookmarks.collectAsStateWithLifecycle()
    val header by produceState<SectionHeader?>(null, current) { value = vm.header(current) }
    val scrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior()

    var showTextSettings by remember { mutableStateOf(false) }
    var paragraphMenu by remember { mutableStateOf<Pair<SectionRef, Paragraph>?>(null) }
    var overflow by remember { mutableStateOf(false) }

    LaunchedEffect(pager) {
        snapshotFlow { pager.settledPage }.collect { vm.onPageShown(loaded.refs[it]) }
    }

    fun toast(text: String) = scope.launch { snackbar.currentSnackbarData?.dismiss(); snackbar.showSnackbar(text) }
    val favAdded = stringResource(R.string.favorite_added)
    val favRemoved = stringResource(R.string.favorite_removed)
    val bookmarkAdded = stringResource(R.string.bookmark_added)
    val bookmarkRemoved = stringResource(R.string.bookmark_removed)
    val copied = stringResource(R.string.reader_copied)
    val shareVia = stringResource(R.string.share_via)
    val appName = stringResource(R.string.app_name)

    suspend fun sectionText(ref: SectionRef): String {
        val h = vm.header(ref)
        val body = vm.paragraphs(ref)
            .filter { it.kind != ParagraphKind.PageMarker && (settings.showTranslation || it.kind != ParagraphKind.Translation) }
            .joinToString("\n\n") { it.text }
        return "${h.title}\n\n$body\n\n— $appName"
    }

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        snackbarHost = { SnackbarHost(snackbar) },
        topBar = {
            TopAppBar(
                scrollBehavior = scrollBehavior,
                navigationIcon = { BackButton(onBack) },
                title = {
                    Column {
                        AnimatedContent(header?.title.orEmpty(), label = "title") { title ->
                            Text(title, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        }
                        Text(
                            if (favoritesMode) stringResource(R.string.favorites) + " · " + bookLabel(current.book) else bookLabel(current.book),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                        )
                    }
                },
                actions = {
                    val isFavorite = current in favorites
                    IconButton(onClick = { toast(if (vm.toggleFavorite(current)) favAdded else favRemoved) }) {
                        Icon(
                            if (isFavorite) Icons.Filled.Star else Icons.Outlined.StarOutline,
                            contentDescription = stringResource(if (isFavorite) R.string.favorite_remove else R.string.favorite_add),
                            tint = if (isFavorite) BrandGold else MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    IconButton(onClick = { showTextSettings = true }) {
                        Icon(Icons.Outlined.TextFields, contentDescription = stringResource(R.string.reader_text_settings))
                    }
                    Box {
                        IconButton(onClick = { overflow = true }) {
                            Icon(Icons.Outlined.MoreVert, contentDescription = stringResource(R.string.more))
                        }
                        DropdownMenu(expanded = overflow, onDismissRequest = { overflow = false }) {
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.toc)) },
                                leadingIcon = { Icon(Icons.AutoMirrored.Outlined.List, null) },
                                onClick = { overflow = false; navigate(Routes.toc(current.book)) },
                            )
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.search_in_book_hint).trimEnd('…')) },
                                leadingIcon = { Icon(Icons.Outlined.Search, null) },
                                onClick = { overflow = false; navigate(Routes.search(current.book)) },
                            )
                            if (current.book == Book.AnisWithTranslation) {
                                DropdownMenuItem(
                                    text = { Text(stringResource(R.string.reader_show_translation)) },
                                    leadingIcon = { Icon(Icons.Outlined.Translate, null) },
                                    trailingIcon = {
                                        Switch(checked = settings.showTranslation, onCheckedChange = null)
                                    },
                                    onClick = { vm.setShowTranslation(!settings.showTranslation) },
                                )
                            }
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.reader_copy_section)) },
                                leadingIcon = { Icon(Icons.Outlined.ContentCopy, null) },
                                onClick = {
                                    overflow = false
                                    scope.launch { copy(context, sectionText(current)); toast(copied) }
                                },
                            )
                            DropdownMenuItem(
                                text = { Text(stringResource(R.string.reader_share_section)) },
                                leadingIcon = { Icon(Icons.Outlined.Share, null) },
                                onClick = {
                                    overflow = false
                                    scope.launch { share(context, sectionText(current), shareVia) }
                                },
                            )
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                    scrolledContainerColor = MaterialTheme.colorScheme.surfaceContainer,
                ),
            )
        },
        bottomBar = {
            ReaderBottomBar(pager, favoritesMode) { target -> scope.launch { pager.animateScrollToPage(target) } }
        },
    ) { padding ->
        HorizontalPager(
            state = pager,
            modifier = Modifier.padding(padding).fillMaxSize(),
            key = { "${loaded.refs[it].book.id}-${loaded.refs[it].sectionId}" },
            beyondViewportPageCount = 1,
        ) { page ->
            val ref = loaded.refs[page]
            val isStart = page == loaded.initialPage
            SectionPage(
                vm = vm,
                ref = ref,
                settings = settings,
                showBookLabel = favoritesMode,
                query = if (isStart) vm.normalizedQuery else null,
                focusKey = if (isStart) startParagraph else null,
                bookmarkedKeys = bookmarks[ref].orEmpty(),
                onLongPress = { paragraphMenu = ref to it },
            )
        }
    }

    if (showTextSettings) {
        ModalBottomSheet(onDismissRequest = { showTextSettings = false }, sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)) {
            TextSettingsPanel(
                settings = settings,
                repo = app.settings,
                showTranslationToggle = current.book == Book.AnisWithTranslation,
                modifier = Modifier.padding(bottom = 24.dp),
            )
        }
    }

    paragraphMenu?.let { (ref, paragraph) ->
        val isBookmarked = bookmarks[ref]?.contains(paragraph.key) == true
        ModalBottomSheet(onDismissRequest = { paragraphMenu = null }) {
            ParagraphActions(
                paragraph = paragraph,
                bookmarked = isBookmarked,
                onCopy = { copy(context, paragraph.text); paragraphMenu = null; toast(copied) },
                onShare = { share(context, paragraph.text + "\n\n— " + appName, shareVia); paragraphMenu = null },
                onBookmark = {
                    toast(if (vm.toggleBookmark(ref, paragraph)) bookmarkAdded else bookmarkRemoved)
                    paragraphMenu = null
                },
            )
        }
    }
}

@Composable
private fun SectionPage(
    vm: ReaderViewModel,
    ref: SectionRef,
    settings: Settings,
    showBookLabel: Boolean,
    query: String?,
    focusKey: Int?,
    bookmarkedKeys: Set<Int>,
    onLongPress: (Paragraph) -> Unit,
) {
    val paragraphs by produceState<List<Paragraph>?>(null, ref) { value = vm.paragraphs(ref) }
    val header by produceState<SectionHeader?>(null, ref) { value = vm.header(ref) }
    val list = paragraphs
    val head = header
    if (list == null || head == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
        return
    }
    val colors = LocalReaderColors.current
    val styles = remember(ref.book, settings, colors) { ReaderStyles(ref.book, settings, colors) }
    val visible = remember(list, head, settings.showTranslation) {
        // The first line usually repeats the title (or its group) already shown in the header.
        val shown = (head.path + head.title).map(TextNormalizer::normalize).toSet()
        list.filter { p ->
            !(p.kind == ParagraphKind.Translation && !settings.showTranslation) &&
                !(p.kind == ParagraphKind.Heading && TextNormalizer.normalize(p.text) in shown)
        }
    }
    val state = rememberLazyListState()
    var focused by remember { mutableStateOf(focusKey) }

    LaunchedEffect(visible) {
        val key = focusKey ?: return@LaunchedEffect
        val index = visible.indexOfFirst { it.key >= key }
        if (index >= 0) state.scrollToItem(index + 1, -120)
        kotlinx.coroutines.delay(2500)
        focused = null
    }
    LaunchedEffect(state, visible) {
        snapshotFlow { state.firstVisibleItemIndex }.collect { index ->
            val paragraph = visible.getOrNull((index - 1).coerceAtLeast(0)) ?: return@collect
            vm.onPosition(ref, paragraph.key)
        }
    }

    val bookLabelText = if (showBookLabel) bookLabel(ref.book) else null
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.TopCenter) {
        LazyColumn(
            state = state,
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 8.dp, bottom = 48.dp),
            modifier = Modifier.fillMaxSize().widthIn(max = 720.dp),
        ) {
            item(key = "header") { SectionTitle(head.title, head.path, bookLabelText) }
            if (visible.isEmpty()) {
                item {
                    Text(
                        stringResource(R.string.reader_empty_section),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.fillMaxWidth().padding(32.dp),
                    )
                }
            }
            itemsIndexed(visible, key = { _, p -> p.key }) { i, p ->
                ParagraphView(
                    paragraph = p,
                    previous = visible.getOrNull(i - 1),
                    styles = styles,
                    query = query,
                    bookmarked = p.key in bookmarkedKeys,
                    focused = p.key == focused,
                    onLongPress = { onLongPress(p) },
                )
            }
            item(key = "end") {
                Box(Modifier.fillMaxWidth().padding(top = 32.dp), contentAlignment = Alignment.Center) {
                    Ornament(colors.heading.copy(alpha = 0.6f))
                }
            }
        }
    }
}

@Composable
private fun ParagraphActions(
    paragraph: Paragraph,
    bookmarked: Boolean,
    onCopy: () -> Unit,
    onShare: () -> Unit,
    onBookmark: () -> Unit,
) {
    Column(Modifier.padding(bottom = 16.dp)) {
        Text(
            paragraph.text,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 3,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
        )
        ActionRow(
            if (bookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkAdd,
            stringResource(if (bookmarked) R.string.reader_remove_bookmark else R.string.reader_bookmark_paragraph),
            onBookmark,
        )
        ActionRow(Icons.Outlined.ContentCopy, stringResource(R.string.reader_copy), onCopy)
        ActionRow(Icons.Outlined.Share, stringResource(R.string.reader_share), onShare)
    }
}

@Composable
private fun ActionRow(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, onClick: () -> Unit) {
    ListItem(
        headlineContent = { Text(label) },
        leadingContent = { Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary) },
        colors = ListItemDefaults.colors(containerColor = Color.Transparent),
        modifier = Modifier.clickable(onClick = onClick).padding(horizontal = 8.dp),
    )
}

@Composable
private fun ReaderBottomBar(pager: PagerState, favoritesMode: Boolean, goTo: (Int) -> Unit) {
    Surface(color = MaterialTheme.colorScheme.surfaceContainer, tonalElevation = 2.dp) {
        Column(Modifier.navigationBarsPadding()) {
            LinearProgressIndicator(
                progress = { (pager.currentPage + 1f) / pager.pageCount.coerceAtLeast(1) },
                modifier = Modifier.fillMaxWidth().height(2.dp),
                drawStopIndicator = {},
                gapSize = 0.dp,
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp, vertical = 2.dp),
            ) {
                TextButton(onClick = { goTo(pager.currentPage - 1) }, enabled = pager.currentPage > 0) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
                    Spacer(Modifier.padding(horizontal = 3.dp))
                    Text(stringResource(R.string.reader_prev))
                }
                Text(
                    (if (favoritesMode) "★ " else "") +
                        "${(pager.currentPage + 1).toPersianDigits()} / ${pager.pageCount.toPersianDigits()}",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                TextButton(onClick = { goTo(pager.currentPage + 1) }, enabled = pager.currentPage < pager.pageCount - 1) {
                    Text(stringResource(R.string.reader_next))
                    Spacer(Modifier.padding(horizontal = 3.dp))
                    Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null)
                }
            }
        }
    }
}

@Composable
private fun KeepScreenOn(enabled: Boolean) {
    val view = LocalView.current
    DisposableEffect(view, enabled) {
        view.keepScreenOn = enabled
        onDispose { view.keepScreenOn = false }
    }
}

private fun copy(context: Context, text: String) {
    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    clipboard.setPrimaryClip(ClipData.newPlainText("text", text))
}

private fun share(context: Context, text: String, title: String) {
    val send = Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, text)
    runCatching { context.startActivity(Intent.createChooser(send, title)) }
        .onFailure { Toast.makeText(context, it.message, Toast.LENGTH_SHORT).show() }
}
