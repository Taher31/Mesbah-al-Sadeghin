package ir.sadeghin.mesbah.ui

import android.net.Uri
import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import ir.sadeghin.mesbah.InstallState
import ir.sadeghin.mesbah.MesbahApp
import ir.sadeghin.mesbah.R
import ir.sadeghin.mesbah.data.Book
import ir.sadeghin.mesbah.data.Settings
import ir.sadeghin.mesbah.ui.about.AboutScreen
import ir.sadeghin.mesbah.ui.bookmarks.BookmarksScreen
import ir.sadeghin.mesbah.ui.favorites.FavoritesScreen
import ir.sadeghin.mesbah.ui.home.HomeScreen
import ir.sadeghin.mesbah.ui.reader.ReaderScreen
import ir.sadeghin.mesbah.ui.search.SearchScreen
import ir.sadeghin.mesbah.ui.settings.SettingsScreen
import ir.sadeghin.mesbah.ui.theme.BrandDeep
import ir.sadeghin.mesbah.ui.theme.BrandGold
import ir.sadeghin.mesbah.ui.theme.BrandGoldSoft
import ir.sadeghin.mesbah.ui.theme.BrandTeal
import ir.sadeghin.mesbah.ui.toc.TocScreen

/** Every way into the reader goes through here, so routes are built in one place. */
object Routes {
    const val HOME = "home"
    const val BOOKMARKS = "bookmarks"
    const val SETTINGS = "settings"
    const val ABOUT = "about"
    const val FAVORITES = "favorites"

    fun toc(book: Book) = "toc/${book.id}"

    /**
     * Opens the reader at a section. With [favoritesMode] the pager walks through the reader's
     * «منتخب» list (across books) instead of the whole book — the daily-routine view.
     */
    fun reader(
        book: Book,
        sectionId: Int,
        paragraphKey: Int? = null,
        query: String? = null,
        favoritesMode: Boolean = false,
    ): String {
        val params = buildList {
            if (paragraphKey != null) add("para=$paragraphKey")
            if (!query.isNullOrBlank()) add("q=${Uri.encode(query)}")
            if (favoritesMode) add("fav=true")
        }
        return "reader/${book.id}/$sectionId" + if (params.isEmpty()) "" else params.joinToString("&", prefix = "?")
    }

    fun search(book: Book? = null) = if (book == null) "search" else "search?book=${book.id}"
}

@Composable
fun MesbahRoot(app: MesbahApp, settings: Settings) {
    val install by app.installState.collectAsStateWithLifecycle()
    when (val state = install) {
        InstallState.Ready -> AppNavHost(app, settings, rememberNavController())
        is InstallState.Working -> PreparingScreen(progress = state.progress, onRetry = null)
        is InstallState.Failed -> PreparingScreen(progress = null, onRetry = app::prepareBooks)
    }
}

@Composable
private fun AppNavHost(app: MesbahApp, settings: Settings, nav: NavHostController) {
    NavHost(
        navController = nav,
        startDestination = Routes.HOME,
        modifier = Modifier.background(MaterialTheme.colorScheme.background),
        enterTransition = { slideIntoContainer(AnimatedContentTransitionScope.SlideDirection.Start, tween(300)) + fadeIn(tween(300)) },
        exitTransition = { fadeOut(tween(200)) },
        popEnterTransition = { fadeIn(tween(200)) },
        popExitTransition = { slideOutOfContainer(AnimatedContentTransitionScope.SlideDirection.End, tween(300)) + fadeOut(tween(300)) },
    ) {
        composable(Routes.HOME) {
            HomeScreen(app = app, settings = settings, navigate = nav::navigate)
        }
        composable(
            "toc/{book}",
            arguments = listOf(navArgument("book") { type = NavType.IntType }),
        ) { entry ->
            TocScreen(
                app = app,
                book = Book.fromId(entry.arguments!!.getInt("book")),
                navigate = nav::navigate,
                onBack = nav::popBackStack,
            )
        }
        composable(
            "reader/{book}/{section}?para={para}&q={q}&fav={fav}",
            arguments = listOf(
                navArgument("book") { type = NavType.IntType },
                navArgument("section") { type = NavType.IntType },
                navArgument("para") { type = NavType.IntType; defaultValue = Int.MIN_VALUE },
                navArgument("q") { type = NavType.StringType; nullable = true; defaultValue = null },
                navArgument("fav") { type = NavType.BoolType; defaultValue = false },
            ),
        ) { entry ->
            val args = entry.arguments!!
            ReaderScreen(
                app = app,
                settings = settings,
                book = Book.fromId(args.getInt("book")),
                startSection = args.getInt("section"),
                startParagraph = args.getInt("para").takeIf { it != Int.MIN_VALUE },
                query = args.getString("q"),
                favoritesMode = args.getBoolean("fav"),
                navigate = nav::navigate,
                onBack = nav::popBackStack,
            )
        }
        composable(Routes.FAVORITES) {
            FavoritesScreen(app = app, navigate = nav::navigate, onBack = nav::popBackStack)
        }
        composable(
            "search?book={book}",
            arguments = listOf(navArgument("book") { type = NavType.IntType; defaultValue = 0 }),
        ) { entry ->
            SearchScreen(
                app = app,
                initialBook = entry.arguments!!.getInt("book").takeIf { it != 0 }?.let(Book::fromId),
                navigate = nav::navigate,
                onBack = nav::popBackStack,
            )
        }
        composable(Routes.BOOKMARKS) {
            BookmarksScreen(app = app, navigate = nav::navigate, onBack = nav::popBackStack)
        }
        composable(Routes.SETTINGS) {
            SettingsScreen(app = app, settings = settings, onBack = nav::popBackStack)
        }
        composable(Routes.ABOUT) {
            AboutScreen(onBack = nav::popBackStack)
        }
    }
}

/** Shown once after install/update while the books are unpacked (a second or two). */
@Composable
private fun PreparingScreen(progress: Float?, onRetry: (() -> Unit)?) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(BrandDeep, BrandTeal)))
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Image(
            painter = painterResource(R.drawable.app_logo),
            contentDescription = null,
            modifier = Modifier.size(132.dp).clip(RoundedCornerShape(28.dp)),
        )
        Spacer(Modifier.height(28.dp))
        Text(
            stringResource(R.string.app_name),
            style = MaterialTheme.typography.headlineMedium,
            color = BrandGold,
        )
        Spacer(Modifier.height(24.dp))
        if (progress != null) {
            Text(stringResource(R.string.preparing_books), color = BrandGoldSoft, style = MaterialTheme.typography.bodyMedium)
            Spacer(Modifier.height(12.dp))
            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier.fillMaxWidth(0.6f).clip(RoundedCornerShape(50)),
                color = BrandGold,
                trackColor = BrandGold.copy(alpha = 0.2f),
            )
        } else {
            Text(
                stringResource(R.string.preparing_failed),
                color = BrandGoldSoft,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(16.dp))
            Button(onClick = { onRetry?.invoke() }) { Text(stringResource(R.string.retry)) }
        }
    }
}
