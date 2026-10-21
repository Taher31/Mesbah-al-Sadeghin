package ir.sadeghin.mesbah.ui.bookmarks

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.EditNote
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Bookmark
import ir.sadeghin.mesbah.data.Work
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.EmptyState
import ir.sadeghin.mesbah.ui.components.bookLabel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class BookmarkRow(val bookmark: Bookmark, val sectionTitle: String)

class BookmarksViewModel(private val app: MesbahApp) : ViewModel() {
    val rows: StateFlow<List<BookmarkRow>?> = app.user.bookmarks
        .map { list -> list.map { BookmarkRow(it, app.books.tableOfContents(it.book)[it.sectionId]?.title.orEmpty()) } }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun remove(b: Bookmark) = viewModelScope.launch { app.user.removeBookmark(b.id) }
    fun restore(b: Bookmark) = viewModelScope.launch { app.user.restoreBookmark(b) }
    fun saveNote(b: Bookmark, note: String) = viewModelScope.launch { app.user.updateNote(b.id, note) }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookmarksScreen(app: MesbahApp, navigate: (String) -> Unit, onBack: () -> Unit) {
    val vm: BookmarksViewModel = viewModel { BookmarksViewModel(app) }
    val rows by vm.rows.collectAsStateWithLifecycle()
    var workFilter by remember { mutableStateOf<Work?>(null) }
    var editing by remember { mutableStateOf<Bookmark?>(null) }
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val removed = stringResource(R.string.bookmark_removed)
    val undo = stringResource(R.string.undo)

    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.bookmarks)) }, navigationIcon = { BackButton(onBack) }) },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        val all = rows ?: return@Scaffold
        if (all.isEmpty()) {
            EmptyState(
                Icons.Outlined.BookmarkBorder,
                stringResource(R.string.bookmarks_empty_title),
                stringResource(R.string.bookmarks_empty_body),
                Modifier.padding(padding),
            )
            return@Scaffold
        }
        val shown = all.filter { workFilter == null || it.bookmark.book.work == workFilter }
        LazyColumn(
            modifier = Modifier.padding(padding).fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                bottom = 16.dp + WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding(),
            ),
            verticalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            item {
                Row(Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    FilterChip(selected = workFilter == null, onClick = { workFilter = null }, label = { Text(stringResource(R.string.search_all_books)) })
                    Work.entries.forEach { w ->
                        FilterChip(selected = workFilter == w, onClick = { workFilter = w }, label = { Text(stringResource(w.title)) })
                    }
                }
            }
            items(shown, key = { it.bookmark.id }) { row ->
                val b = row.bookmark
                Card(
                    onClick = {
                        navigate(Routes.reader(b.book, b.sectionId, b.paragraphKey.takeIf { it != Bookmark.SECTION_LEVEL }))
                    },
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
                    modifier = Modifier.fillMaxWidth().animateItem(),
                ) {
                    Column(Modifier.padding(start = 16.dp, top = 14.dp, end = 6.dp, bottom = 6.dp)) {
                        Text(bookLabel(b.book), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.secondary)
                        Text(row.sectionTitle, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        if (b.excerpt.isNotBlank()) {
                            Spacer(Modifier.height(6.dp))
                            Text(
                                b.excerpt,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 3,
                                overflow = TextOverflow.Ellipsis,
                                modifier = Modifier.padding(end = 10.dp),
                            )
                        }
                        if (!b.note.isNullOrBlank()) {
                            Spacer(Modifier.height(8.dp))
                            Surface(
                                shape = RoundedCornerShape(12.dp),
                                color = MaterialTheme.colorScheme.secondaryContainer,
                                modifier = Modifier.padding(end = 10.dp),
                            ) {
                                Text(
                                    b.note,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                                )
                            }
                        }
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End, verticalAlignment = Alignment.CenterVertically) {
                            IconButton(onClick = { editing = b }) {
                                Icon(Icons.Outlined.EditNote, contentDescription = stringResource(R.string.edit_note), modifier = Modifier.size(22.dp))
                            }
                            IconButton(onClick = {
                                vm.remove(b)
                                scope.launch {
                                    snackbar.currentSnackbarData?.dismiss()
                                    if (snackbar.showSnackbar(removed, undo, withDismissAction = true) == SnackbarResult.ActionPerformed) vm.restore(b)
                                }
                            }) {
                                Icon(Icons.Outlined.Delete, contentDescription = stringResource(R.string.delete), modifier = Modifier.size(22.dp), tint = MaterialTheme.colorScheme.outline)
                            }
                        }
                    }
                }
            }
        }
    }

    editing?.let { b ->
        var text by remember(b.id) { mutableStateOf(b.note.orEmpty()) }
        AlertDialog(
            onDismissRequest = { editing = null },
            title = { Text(stringResource(R.string.edit_note)) },
            text = {
                OutlinedTextField(
                    value = text,
                    onValueChange = { text = it },
                    placeholder = { Text(stringResource(R.string.note_hint)) },
                    minLines = 3,
                    modifier = Modifier.fillMaxWidth(),
                )
            },
            confirmButton = { TextButton(onClick = { vm.saveNote(b, text); editing = null }) { Text(stringResource(R.string.save)) } },
            dismissButton = { TextButton(onClick = { editing = null }) { Text(stringResource(R.string.cancel)) } },
        )
    }
}
