import { useEffect, useState } from 'preact/hooks'
import { fa } from '../lib/normalize'
import { ARABIC_FONTS, PERSIAN_FONTS, RANGES, THEMES, resetTextSettings, setSetting, settingsStore, useStore, type Settings } from '../lib/store'
import { toast } from '../lib/util'
import { Chip, Segmented, SwitchRow } from './common'
import { Icon } from './icons'

/** Theme, fonts and sizes with a live preview; used in the reader's sheet and on the settings page. */
export function TextSettingsPanel() {
  const s = useStore(settingsStore)
  return (
    <div class="text-settings">
      <Preview s={s} />

      <p class="field-label">پوسته</p>
      <Segmented label="پوسته" options={THEMES} value={s.theme} onChange={(v) => setSetting('theme', v)} />

      <p class="field-label">قلم عربی (ادعیه)</p>
      <div class="chip-row">
        {ARABIC_FONTS.map((f) => (
          <Chip
            selected={s.arabicFont === f.id}
            onClick={() => setSetting('arabicFont', f.id)}
            style={`font-family:${f.family};font-size:17px;font-weight:${s.arabicBold ? 700 : 400}`}
          >
            {f.label}
          </Chip>
        ))}
      </div>
      <SwitchRow label="متن عربی پررنگ" checked={s.arabicBold} onChange={(v) => setSetting('arabicBold', v)} />

      <p class="field-label">قلم فارسی</p>
      <div class="chip-row">
        {PERSIAN_FONTS.map((f) => (
          <Chip selected={s.persianFont === f.id} onClick={() => setSetting('persianFont', f.id)} style={`font-family:${f.family};font-size:16px`}>
            {f.label}
          </Chip>
        ))}
      </div>

      <SizeSlider label="اندازهٔ متن عربی" value={s.arabicSize} range={RANGES.arabicSize} onChange={(v) => setSetting('arabicSize', v)} />
      <SizeSlider
        label="اندازهٔ ترجمه"
        value={s.translationSize}
        range={RANGES.translationSize}
        onChange={(v) => setSetting('translationSize', v)}
      />
      <SizeSlider
        label="اندازهٔ متن فارسی و توضیحات"
        value={s.textSize}
        range={RANGES.textSize}
        onChange={(v) => setSetting('textSize', v)}
      />
      <SizeSlider label="فاصلهٔ سطرها" value={s.lineHeight} range={RANGES.lineHeight} decimals onChange={(v) => setSetting('lineHeight', v)} />

      <SwitchRow label="تراز دوطرفه" checked={s.justify} onChange={(v) => setSetting('justify', v)} />

      <button
        type="button"
        class="btn btn-outlined btn-block text-settings-reset"
        onClick={() => {
          const before = settingsStore.get()
          resetTextSettings()
          toast('تنظیمات متن به حالت پیش‌فرض برگشت', { label: 'بازگردانی', run: () => settingsStore.set(before) })
        }}
      >
        <Icon name="refresh" size={20} />
        بازگشت به پیش‌فرض
      </button>
    </div>
  )
}

function Preview({ s }: { s: Settings }) {
  const arabic = ARABIC_FONTS.find((f) => f.id === s.arabicFont)!.family
  const persian = PERSIAN_FONTS.find((f) => f.id === s.persianFont)!.family
  return (
    <div class="preview">
      <p
        class="p-arabic is-paired"
        style={`font-family:${arabic};font-size:${s.arabicSize}px;line-height:${s.lineHeight};font-weight:${s.arabicBold ? 700 : 400}`}
      >
        اَللّٰهُمَّ صَلِّ عَلیٰ مُحَمَّدٍ وَ آلِ مُحَمَّدٍ وَ عَجِّلْ فَرَجَهُم.
      </p>
      <p class="p-translation is-paired" style={`font-family:${persian};font-size:${s.translationSize}px;line-height:${s.lineHeight * 0.95}`}>
        خدایا، بر محمد و آل محمد صلوات فرست و فرج آنان را نزدیک گردان.
      </p>
      <p class="p-body" style={`font-family:${persian};font-size:${s.textSize}px;line-height:${s.lineHeight}`}>
        این دعا را پس از هر نماز بخوانید.
      </p>
    </div>
  )
}

/** Updates the preview while dragging but only writes the setting when the finger lifts. */
function SizeSlider(props: { label: string; value: number; range: readonly [number, number]; decimals?: boolean; onChange: (v: number) => void }) {
  const [dragging, setDragging] = useState(props.value)
  useEffect(() => setDragging(props.value), [props.value])
  const step = props.decimals ? 0.1 : 1
  // Persian writes the decimal point as «٫».
  const shown = props.decimals ? dragging.toFixed(1).replace('.', '٫') : String(Math.round(dragging))
  return (
    <div class="slider">
      <div class="slider-head">
        <span>{props.label}</span>
        <b>{fa(shown)}</b>
      </div>
      <input
        type="range"
        min={props.range[0]}
        max={props.range[1]}
        step={step}
        value={dragging}
        aria-label={props.label}
        style={`--fill:${((dragging - props.range[0]) / (props.range[1] - props.range[0])) * 100}%`}
        onInput={(e) => setDragging(Number((e.target as HTMLInputElement).value))}
        onChange={(e) => props.onChange(Number(Number((e.target as HTMLInputElement).value).toFixed(props.decimals ? 1 : 0)))}
      />
    </div>
  )
}
