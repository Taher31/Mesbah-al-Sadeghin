package ir.sadeghin.mesbah.ui.search

import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Close
import androidx.compose.material.icons.automirrored.outlined.ManageSearch
import androidx.compose.material.icons.outlined.SearchOff
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.SearchHit
import ir.sadeghin.mesbah.data.toPersianDigits
import ir.sadeghin.mesbah.ui.Routes
import ir.sadeghin.mesbah.ui.components.BackButton
import ir.sadeghin.mesbah.ui.components.EmptyState
import ir.sadeghin.mesbah.ui.components.bookLabel
import ir.sadeghin.mesbah.ui.theme.LocalReaderColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(app: MesbahApp, initialBook: Book?, navigate: (String) -> Unit, onBack: () -> Unit) {
    val vm: SearchViewModel = viewModel { SearchViewModel(app, initialBook) }
    val query by vm.query.collectAsStateWithLifecycle()
    val filter by vm.bookFilter.collectAsStateWithLifecycle()
    val state by vm.state.collectAsStateWithLifecycle()
    val focus = remember { FocusRequester() }
    val keyboard = LocalSoftwareKeyboardController.current
    LaunchedEffect(Unit) { focus.requestFocus() }

    Scaffold(
        topBar = {
            TopAppBar(
                navigationIcon = { BackButton(onBack) },
                title = {
                    TextField(
                        value = query,
                        onValueChange = { vm.query.value = it },
                        placeholder = {
                            Text(stringResource(if (filter == null) R.string.search_hint else R.string.search_in_book_hint))
                        },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                        keyboardActions = KeyboardActions(onSearch = { keyboard?.hide() }),
                        trailingIcon = {
                            if (query.isNotEmpty()) {
                                IconButton(onClick = { vm.query.value = "" }) {
                                    Icon(Icons.Outlined.Close, contentDescription = stringResource(R.string.clear))
                                }
                            }
                        },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent,
                        ),
                        modifier = Modifier.fillMaxWidth().focusRequester(focus),
                    )
                },
            )
        },
    ) { padding ->
        Column(Modifier.padding(padding).fillMaxSize()) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 16.dp),
            ) {
                FilterChip(
                    selected = filter == null,
                    onClick = { vm.bookFilter.value = null },
                    label = { Text(stringResource(R.string.search_all_books)) },
                )
                Book.entries.forEach { book ->
                    FilterChip(
                        selected = filter == book,
                        onClick = { vm.bookFilter.value = book },
                        label = { Text(bookLabel(book)) },
                    )
                }
            }
            when (val s = state) {
                SearchUi.Idle -> EmptyState(
                    Icons.AutoMirrored.Outlined.ManageSearch,
                    stringResource(R.string.search_empty_title),
                    stringResource(R.string.search_empty_body),
                )
                SearchUi.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth().padding(top = 12.dp))
                is SearchUi.Done -> if (s.result.hits.isEmpty()) {
                    EmptyState(Icons.Outlined.SearchOff, stringResource(R.string.search_no_results), null)
                } else {
                    LazyColumn(
                        contentPadding = PaddingValues(
                            start = 16.dp,
                            end = 16.dp,
                            top = 8.dp,
                            bottom = 16.dp + WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding(),
                        ),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        item {
                            val count = s.result.hits.size.toPersianDigits()
                            Text(
                                if (s.result.capped) stringResource(R.string.search_results_capped, count)
                                else stringResource(R.string.search_results_count, count),
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(horizontal = 4.dp),
                            )
                        }
                        items(s.result.hits, key = { "${it.book.id}-${it.sectionId}-${it.paragraphKey}" }) { hit ->
                            HitCard(hit, showBook = filter == null) {
                                keyboard?.hide()
                                navigate(Routes.reader(hit.book, hit.sectionId, hit.paragraphKey, query))
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun HitCard(hit: SearchHit, showBook: Boolean, onClick: () -> Unit) {
    val highlight = LocalReaderColors.current.searchHighlight
    Card(
        onClick = onClick,
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(Modifier.padding(16.dp)) {
            if (showBook) {
                Text(bookLabel(hit.book), style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.secondary)
            }
            Text(
                hit.sectionTitle,
                style = MaterialTheme.typography.titleSmall,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.height(6.dp))
            Text(
                buildAnnotatedString {
                    append(hit.snippet)
                    hit.highlights.forEach {
                        addStyle(SpanStyle(background = highlight, fontWeight = FontWeight.SemiBold), it.first, it.last + 1)
                    }
                },
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 4,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}
