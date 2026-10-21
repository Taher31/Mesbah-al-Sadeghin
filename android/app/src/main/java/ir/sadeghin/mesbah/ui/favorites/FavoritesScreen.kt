package ir.sadeghin.mesbah.ui.favorites

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
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.PlaylistPlay
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.KeyboardArrowDown
import androidx.compose.material.icons.outlined.KeyboardArrowUp
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SnackbarResult
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
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
import ir.sadeghin.mesbah.data.SectionRef
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.EmptyState
import ir.sadeghin.mesbah.ui.components.bookLabel
import ir.sadeghin.mesbah.ui.home.ShelfItem
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class FavoritesViewModel(private val app: MesbahApp) : ViewModel() {

    val items: StateFlow<List<ShelfItem>?> = app.user.favorites
        .map { list ->
            list.mapNotNull { f ->
                val toc = app.books.tableOfContents(f.book)
                val entry = toc[f.sectionId] ?: return@mapNotNull null
                ShelfItem(SectionRef(f.book, f.sectionId), entry.title, toc.pathTo(f.sectionId).lastOrNull()?.title)
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun move(from: Int, to: Int) {
        val list = items.value?.map { it.ref }?.toMutableList() ?: return
        if (to !in list.indices) return
        list.add(to, list.removeAt(from))
        viewModelScope.launch { app.user.reorderFavorites(list) }
    }

    fun remove(ref: SectionRef) {
        viewModelScope.launch { app.user.removeFavorite(ref.book, ref.sectionId) }
    }

    /** Re-adds at the old position after an undo. */
    fun restore(ref: SectionRef, index: Int) {
        viewModelScope.launch {
            app.user.addFavorite(ref.book, ref.sectionId)
            val list = items.value?.map { it.ref }?.filter { it != ref }?.toMutableList() ?: return@launch
            list.add(index.coerceIn(0, list.size), ref)
            app.user.reorderFavorites(list)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FavoritesScreen(app: MesbahApp, navigate: (String) -> Unit, onBack: () -> Unit) {
    val vm: FavoritesViewModel = viewModel { FavoritesViewModel(app) }
    val items by vm.items.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val removed = stringResource(R.string.favorite_removed)
    val undo = stringResource(R.string.undo)

    Scaffold(
        topBar = { TopAppBar(title = { Text(stringResource(R.string.favorites)) }, navigationIcon = { BackButton(onBack) }) },
        snackbarHost = { SnackbarHost(snackbar) },
        floatingActionButton = {
            val first = items?.firstOrNull()
            if (first != null) {
                ExtendedFloatingActionButton(
                    onClick = { navigate(Routes.reader(first.ref.book, first.ref.sectionId, favoritesMode = true)) },
                    icon = { Icon(Icons.AutoMirrored.Filled.PlaylistPlay, contentDescription = null) },
                    text = { Text(stringResource(R.string.favorites_read_all)) },
                )
            }
        },
    ) { padding ->
        val list = items ?: return@Scaffold
        if (list.isEmpty()) {
            EmptyState(
                Icons.Outlined.StarOutline,
                stringResource(R.string.favorites_empty_title),
                stringResource(R.string.favorites_empty_body),
                Modifier.padding(padding),
            )
            return@Scaffold
        }
        LazyColumn(
            modifier = Modifier.padding(padding).fillMaxSize(),
            contentPadding = PaddingValues(
                start = 16.dp,
                end = 16.dp,
                top = 4.dp,
                bottom = 96.dp + WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding(),
            ),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            item {
                Text(
                    stringResource(R.string.favorites_subtitle),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 4.dp),
                )
            }
            itemsIndexed(list, key = { _, it -> "${it.ref.book.id}-${it.ref.sectionId}" }) { index, item ->
                Card(
                    onClick = { navigate(Routes.reader(item.ref.book, item.ref.sectionId, favoritesMode = true)) },
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
                    modifier = Modifier.fillMaxWidth().animateItem(),
                ) {
                    Row(Modifier.padding(start = 14.dp, top = 8.dp, bottom = 8.dp, end = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                        Surface(shape = CircleShape, color = MaterialTheme.colorScheme.secondaryContainer, modifier = Modifier.size(32.dp)) {
                            Box(contentAlignment = Alignment.Center) {
                                Text(
                                    (index + 1).toPersianDigits(),
                                    style = MaterialTheme.typography.labelLarge,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer,
                                )
                            }
                        }
                        Spacer(Modifier.width(14.dp))
                        Column(Modifier.weight(1f)) {
                            Text(item.title, style = MaterialTheme.typography.titleSmall, maxLines = 2, overflow = TextOverflow.Ellipsis)
                            Text(
                                listOfNotNull(item.group, bookLabel(item.ref.book)).joinToString(" · "),
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis,
                            )
                        }
                        Column {
                            IconButton(onClick = { vm.move(index, index - 1) }, enabled = index > 0, modifier = Modifier.size(36.dp)) {
                                Icon(Icons.Outlined.KeyboardArrowUp, contentDescription = stringResource(R.string.move_up))
                            }
                            IconButton(onClick = { vm.move(index, index + 1) }, enabled = index < list.lastIndex, modifier = Modifier.size(36.dp)) {
                                Icon(Icons.Outlined.KeyboardArrowDown, contentDescription = stringResource(R.string.move_down))
                            }
                        }
                        IconButton(onClick = {
                            vm.remove(item.ref)
                            scope.launch {
                                snackbar.currentSnackbarData?.dismiss()
                                if (snackbar.showSnackbar(removed, undo, withDismissAction = true) == SnackbarResult.ActionPerformed) {
                                    vm.restore(item.ref, index)
                                }
                            }
                        }) {
                            Icon(Icons.Outlined.Delete, contentDescription = stringResource(R.string.delete), tint = MaterialTheme.colorScheme.outline)
                        }
                    }
                }
            }
        }
    }
}
