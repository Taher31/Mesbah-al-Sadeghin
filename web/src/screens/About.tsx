import { fa } from '../lib/normalize'
import { APP_NAME, CHANNEL_URL, asset } from '../lib/util'
import { Ornament, SectionLabel, TopBar } from '../ui/common'
import { Icon, type IconName } from '../ui/icons'
import aboutText from '../about.txt?raw'

const ADMIN_EMAIL = 'Yaghobi01@gmail.com'
const DEVELOPER_EMAIL = 'Anisbook@iran.ir'

export function About() {
  return (
    <main class="page">
      <TopBar title="دربارهٔ برنامه" />
      <div class="content about">
        <img class="about-logo" src={asset('img/logo.webp')} alt="" width="112" height="112" />
        <h2>{APP_NAME}</h2>
        <p class="muted">نسخهٔ {fa(__APP_VERSION__)}</p>
        <Ornament />
        <div class="about-text">{aboutText.trim()}</div>
        <SectionLabel>راه‌های ارتباطی</SectionLabel>
        <div class="card contacts">
          <Contact icon="campaign" title="کانال صادقین در ایتا" value="eitaa.com/sadeghin_ir" href={CHANNEL_URL} />
          <Contact icon="mail" title="مدیر کانال" value={ADMIN_EMAIL} href={`mailto:${ADMIN_EMAIL}`} />
          <Contact icon="mail" title="برنامه‌نویس" value={DEVELOPER_EMAIL} href={`mailto:${DEVELOPER_EMAIL}`} />
        </div>
      </div>
    </main>
  )
}

function Contact({ icon, title, value, href }: { icon: IconName; title: string; value: string; href: string }) {
  return (
    <a class="contact" href={href} target={href.startsWith('http') ? '_blank' : undefined} rel="noopener">
      <Icon name={icon} />
      <span>
        <b>{title}</b>
        <span dir="ltr">{value}</span>
      </span>
    </a>
  )
}
