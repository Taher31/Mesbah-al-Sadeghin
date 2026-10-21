package ir.sadeghin.mesbah

import android.app.Application
import ir.sadeghin.mesbah.data.BookInstaller
import ir.sadeghin.mesbah.data.BookRepository
import ir.sadeghin.mesbah.data.LegacyImporter
import ir.sadeghin.mesbah.data.SettingsRepository
import ir.sadeghin.mesbah.data.UserRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface InstallState {
    data class Working(val progress: Float) : InstallState
    data object Ready : InstallState
    data class Failed(val error: Throwable) : InstallState
}

/** Holds the app-wide singletons; small enough that a DI framework would be overhead. */
class MesbahApp : Application() {

    val appScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    lateinit var installer: BookInstaller private set
    lateinit var books: BookRepository private set
    lateinit var user: UserRepository private set
    lateinit var settings: SettingsRepository private set

    private val _installState = MutableStateFlow<InstallState>(InstallState.Working(0f))
    val installState: StateFlow<InstallState> = _installState.asStateFlow()

    override fun onCreate() {
        super.onCreate()
        installer = BookInstaller(this)
        books = BookRepository(installer)
        user = UserRepository(this)
        settings = SettingsRepository(this)
        prepareBooks()
    }

    fun prepareBooks() {
        if (installer.isInstalled()) {
            _installState.value = InstallState.Ready
            appScope.launch(Dispatchers.IO) { LegacyImporter(this@MesbahApp, user).importIfPresent() }
            return
        }
        _installState.value = InstallState.Working(0f)
        appScope.launch {
            runCatching {
                LegacyImporter(this@MesbahApp, user).importIfPresent()
                installer.install { _installState.value = InstallState.Working(it) }
            }.onSuccess { _installState.value = InstallState.Ready }
                .onFailure { _installState.value = InstallState.Failed(it) }
        }
    }
}
