import './lib/polyfills'
import { render } from 'preact'
import { App } from './app'
import { connectAndroid } from './lib/android-app'
import { registerServiceWorker } from './lib/pwa'
import './styles/fonts.css'
import './styles/app.css'

render(<App />, document.getElementById('app')!)
registerServiceWorker()
connectAndroid()
