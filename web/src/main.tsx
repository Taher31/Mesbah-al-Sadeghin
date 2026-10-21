import { render } from 'preact'
import { App } from './app'
import { registerServiceWorker } from './lib/pwa'
import './styles/fonts.css'
import './styles/app.css'

render(<App />, document.getElementById('app')!)
registerServiceWorker()
