package ir.sadeghin.mesbah.ui.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.SearchResult
import ir.sadeghin.mesbah.data.TextNormalizer
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn

sealed interface SearchUi {
    data object Idle : SearchUi
    data object Loading : SearchUi
    data class Done(val result: SearchResult) : SearchUi
}

@OptIn(FlowPreview::class, ExperimentalCoroutinesApi::class)
class SearchViewModel(private val app: MesbahApp, initialBook: Book?) : ViewModel() {

    val query = MutableStateFlow("")

    /** `null` searches every edition. */
    val bookFilter = MutableStateFlow(initialBook)

    val state: StateFlow<SearchUi> = combine(query.debounce(250), bookFilter) { q, b -> q to b }
        .flatMapLatest { (q, b) ->
            flow {
                if (TextNormalizer.normalize(q).length < 2) {
                    emit(SearchUi.Idle)
                    return@flow
                }
                emit(SearchUi.Loading)
                emit(SearchUi.Done(app.books.search(q, listOfNotNull(b).ifEmpty { Book.entries })))
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SearchUi.Idle)
}
