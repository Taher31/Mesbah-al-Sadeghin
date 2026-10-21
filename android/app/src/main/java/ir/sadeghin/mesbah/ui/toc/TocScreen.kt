package ir.sadeghin.mesbah.ui.toc

import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Close
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material.icons.outlined.UnfoldLess
import androidx.compose.material.icons.outlined.UnfoldMore
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.BookCover
import ir.sadeghin.mesbah.ui.components.EmptyState
import ir.sadeghin.mesbah.ui.theme.BrandGold
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TocScreen(app: MesbahApp, book: Book, navigate: (String) -> Unit, onBack: () -> Unit) {
    val vm: TocViewModel = viewModel(key = "toc-${book.id}") { TocViewModel(app, book) }
    val rows by vm.rows.collectAsStateWithLifecycle()
    val filter by vm.filter.collectAsStateWithLifecycle()
    val progress by vm.progress.collectAsStateWithLifecycle()
    val scope = rememberCoroutineScope()
    val scrollBehavior = TopAppBarDefaults.pinnedScrollBehavior()
    var allOpen by remember { mutableStateOf(false) }
    val listState = rememberLazyListState()

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.toc)) },
                navigationIcon = { BackButton(onBack) },
                actions = {
                    IconButton(onClick = { allOpen = !allOpen; vm.expandAll(allOpen) }) {
                        Icon(if (allOpen) Icons.Outlined.UnfoldLess else Icons.Outlined.UnfoldMore, contentDescription = null)
                    }
                    IconButton(onClick = { navigate(Routes.search(book)) }) {
                        Icon(Icons.Outlined.Search, contentDescription = stringResource(R.string.search))
                    }
                },
                scrollBehavior = scrollBehavior,
            )
        },
    ) { padding ->
        LazyColumn(
            state = listState,
            modifier = Modifier.padding(padding).fillMaxSize(),
            contentPadding = PaddingValues(bottom = 24.dp + WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()),
        ) {
            item(key = "header") {
                BookHeader(
                    book = book,
                    started = progress != null,
                    onContinue = {
                        val p = progress
                        if (p != null) {
                            navigate(Routes.reader(book, p.sectionId, p.paragraphKey))
                        } else {
                            scope.launch { navigate(Routes.reader(book, vm.firstSection())) }
                        }
                    },
                )
            }
            item(key = "filter") {
                OutlinedTextField(
                    value = filter,
                    onValueChange = { vm.filter.value = it },
                    placeholder = { Text(stringResource(R.string.toc_filter_hint)) },
                    leadingIcon = { Icon(Icons.Outlined.Search, contentDescription = null) },
                    trailingIcon = {
                        if (filter.isNotEmpty()) {
                            IconButton(onClick = { vm.filter.value = "" }) {
                                Icon(Icons.Outlined.Close, contentDescription = stringResource(R.string.clear))
                            }
                        }
                    },
                    singleLine = true,
                    shape = CircleShape,
                    colors = OutlinedTextFieldDefaults.colors(
                        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceContainerLow,
                        focusedContainerColor = MaterialTheme.colorScheme.surfaceContainerLow,
                        unfocusedBorderColor = MaterialTheme.colorScheme.outlineVariant,
                    ),
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                )
            }
            val list = rows
            if (list != null && list.isEmpty()) {
                item { EmptyState(Icons.Outlined.Search, stringResource(R.string.toc_no_match), null) }
            }
            items(list.orEmpty(), key = { it.entry.id }) { row ->
                TocRowView(
                    row = row,
                    onClick = {
                        if (row.entry.hasContent) navigate(Routes.reader(book, row.entry.id)) else vm.toggle(row.entry)
                    },
                    onToggle = { vm.toggle(row.entry) },
                    onFavorite = { vm.toggleFavorite(row) },
                )
            }
        }
    }
}

@Composable
private fun BookHeader(book: Book, started: Boolean, onContinue: () -> Unit) {
    Row(Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 12.dp), verticalAlignment = Alignment.CenterVertically) {
        BookCover(book, 88.dp)
        Spacer(Modifier.width(18.dp))
        Column(Modifier.weight(1f)) {
            Text(stringResource(book.work.title), style = MaterialTheme.typography.headlineSmall)
            Text(
                stringResource(book.edition),
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.secondary,
            )
            Spacer(Modifier.height(12.dp))
            if (started) {
                Button(onClick = onContinue) { Text(stringResource(R.string.continue_reading)) }
            } else {
                FilledTonalButton(onClick = onContinue) { Text(stringResource(R.string.start_reading)) }
            }
        }
    }
}

@Composable
private fun TocRowView(row: TocRow, onClick: () -> Unit, onToggle: () -> Unit, onFavorite: () -> Unit) {
    val e = row.entry
    val depth = if (row.path != null) 0 else e.level - 1
    val isGroup = !e.hasContent
    val rotation by animateFloatAsState(if (row.expanded) 90f else 0f, label = "chevron")
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .background(if (row.current) MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.45f) else MaterialTheme.colorScheme.surface)
            .padding(start = 8.dp + (depth * 18).dp, end = 4.dp),
    ) {
        Box(Modifier.size(40.dp), contentAlignment = Alignment.Center) {
            if (e.hasChildren && row.path == null) {
                IconButton(onClick = onToggle) {
                    Icon(
                        Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        // 90° turns the RTL-mirrored «‹» into «⌄» when open.
                        modifier = Modifier.rotate(-rotation),
                        tint = MaterialTheme.colorScheme.primary,
                    )
                }
            } else {
                Box(
                    Modifier
                        .size(if (depth == 0) 7.dp else 5.dp)
                        .background(MaterialTheme.colorScheme.outline.copy(alpha = 0.6f), RoundedCornerShape(50)),
                )
            }
        }
        Column(Modifier.weight(1f).padding(vertical = 12.dp)) {
            if (row.path != null) {
                Text(row.path, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
            Text(
                e.title,
                style = if (depth == 0) MaterialTheme.typography.titleMedium else MaterialTheme.typography.bodyLarge,
                fontWeight = if (isGroup) FontWeight.Bold else null,
                color = if (isGroup) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
            )
        }
        if (e.hasContent) {
            IconButton(onClick = onFavorite) {
                Icon(
                    if (row.favorite) Icons.Filled.Star else Icons.Outlined.StarOutline,
                    contentDescription = stringResource(if (row.favorite) R.string.favorite_remove else R.string.favorite_add),
                    tint = if (row.favorite) BrandGold else MaterialTheme.colorScheme.outlineVariant,
                    modifier = Modifier.size(22.dp),
                )
            }
        }
    }
}
