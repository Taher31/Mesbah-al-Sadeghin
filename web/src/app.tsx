import { useEffect, useLayoutEffect, useState } from 'preact/hooks'
import { bookById } from './lib/books'
import { initialScroll, navigate, routeStore, routes, type Route } from './lib/router'
import { settingsStore, useStore, type ThemeMode } from './lib/store'
import { About } from './screens/About'
import { Bookmarks } from './screens/Bookmarks'
import { Favorites } from './screens/Favorites'
import { Home } from './screens/Home'
import { Reader } from './screens/Reader'
import { Search } from './screens/Search'
import { SettingsScreen } from './screens/Settings'
import { Toc } from './screens/Toc'
import { EmptyState, Snackbar } from './ui/common'
import { UpdateBanner } from './ui/PwaUi'

const darkQuery = window.matchMedia('(prefers-color-scheme: dark)')

/** Status-bar colour per theme, matching each theme's background. */
const themeColors = { light: '#FBF8F2', sepia: '#F2E8D3', dark: '#051916' } as const

function useTheme(mode: ThemeMode, onHome: boolean) {
  const [systemDark, setSystemDark] = useState(darkQuery.matches)
  useEffect(() => {
    const onChange = () => setSystemDark(darkQuery.matches)
    darkQuery.addEventListener('change', onChange)
    return () => darkQuery.removeEventListener('change', onChange)
  }, [])
  const theme = mode === 'system' ? (systemDark ? 'dark' : 'light') : mode
  useEffect(() => {
    document.documentElement.dataset.theme = theme
    // The home screen opens on the dark portrait hero.
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', onHome ? '#04201C' : themeColors[theme])
  }, [theme, onHome])
}

function screen(route: Route) {
  const [name, a, b] = route.path
  switch (name) {
    case undefined:
      return <Home />
    case 'toc': {
      const book = bookById(Number(a))
      return book ? <Toc route={route} book={book} /> : null
    }
    case 'r': {
      const book = bookById(Number(a))
      const section = Number(b)
      return book && Number.isInteger(section) ? <Reader route={route} book={book} section={section} /> : null
    }
    case 'search':
      return <Search route={route} />
    case 'favorites':
      return <Favorites />
    case 'bookmarks':
      return <Bookmarks />
    case 'settings':
      return <SettingsScreen />
    case 'about':
      return <About />
    default:
      return null
  }
}

export function App() {
  const route = useStore(routeStore)
  const settings = useStore(settingsStore)
  useTheme(settings.theme, route.path.length === 0)
  // A new screen starts at the top, or where it was when coming back. The reader positions itself
  // (at a paragraph), and its own effects run before this one.
  useLayoutEffect(() => {
    if (route.path[0] !== 'r') window.scrollTo(0, initialScroll(route))
  }, [route.depth, route.raw])
  const content = screen(route) ?? (
    <main class="page">
      <EmptyState icon="search" title="این صفحه پیدا نشد">
        <button type="button" class="btn btn-tonal" onClick={() => navigate(routes.home(), { replace: true })}>
          صفحهٔ اصلی
        </button>
      </EmptyState>
    </main>
  )
  return (
    <>
      <div key={route.depth + '|' + route.raw} class="screen">
        {content}
      </div>
      <Snackbar />
      <UpdateBanner />
    </>
  )
}
