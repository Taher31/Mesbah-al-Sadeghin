# مصباح الصادقین

برنامهٔ مطالعهٔ آثار عالم ربانی آیت‌الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه): «انیس الصادقین» و «سفینة الصادقین».

## دانلود و نصب

- **اندروید (نسخهٔ آزمایشی):** [دانلود فایل APK](https://github.com/Taher31/Mesbah-al-Sadeghin/releases/download/android-test-3.0.0/mesbah-sadeghin-test.apk) — [صفحهٔ انتشار](https://github.com/Taher31/Mesbah-al-Sadeghin/releases/tag/android-test-3.0.0). کنار برنامهٔ فعلی نصب می‌شود و جایگزین آن نمی‌شود؛ اندروید ۵ به بالا.
- **آیفون و سایر دستگاه‌ها (وب‌اپ):** [taher31.github.io/Mesbah-al-Sadeghin](https://taher31.github.io/Mesbah-al-Sadeghin/) — در Safari باز کنید و «Add to Home Screen» را بزنید.

| پوشه | چیست |
|---|---|
| `Files/` | متن کتاب‌ها (`1.book` … `4.book`) و منابع مشترک؛ هر دو نسخهٔ جدید کتاب‌ها را از همین‌جا می‌خوانند |
| `web/` | خود برنامه: وب‌اپ قابل نصب (PWA) برای آیفون و سایر دستگاه‌ها |
| `android/` | اپ اندروید: همان وب‌اپ با همهٔ کتاب‌ها داخل APK (بدون اینترنت)، در یک پوستهٔ کوچک Kotlin برای دکمهٔ بازگشت، اشتراک‌گذاری، روشن ماندن صفحه، ذخیرهٔ فایل پشتیبان و انتقال داده‌های نسخه‌های قبلی |
| ریشه (`*.bas`، `*.b4a`) | پروژهٔ قدیمی B4A |

## نسخهٔ آزمایشی وب

[taher31.github.io/Mesbah-al-Sadeghin](https://taher31.github.io/Mesbah-al-Sadeghin/) — با هر تغییر در `web/` یا فایل‌های `.book` از طریق [`pages.yml`](.github/workflows/pages.yml) به‌روز می‌شود. این نشانی فقط برای آزمایش است؛ برنامه‌ای که از آن نصب شود جدا از سایت اصلی است و داده‌هایش (منتخب‌ها، نشانه‌ها) به آن منتقل نمی‌شود، مگر با «پشتیبان‌گیری از داده‌های من».

## انتشار

هر push به شاخهٔ `main` با GitHub Actions ([`deploy.yml`](.github/workflows/deploy.yml)) اپ اندروید و وب‌اپ را می‌سازد و روی ساب‌دامین هاست (cPanel، از طریق FTPS) بارگذاری می‌کند؛ فایل APK در نشانی `/download/mesbah-sadeghin.apk` همان سایت قرار می‌گیرد.

تنظیمات لازم در Settings › Secrets and variables › Actions:

- `FTP_SERVER`، `FTP_USERNAME`، `FTP_PASSWORD`: حساب FTP هاست
- `FTP_SERVER_DIR`: پوشهٔ ساب‌دامین، مثلاً `mesbah.esperlos.sbs/` (هرگز `public_html/` — آن پوشهٔ سایت Asperlos است)
- `ANDROID_KEYSTORE_BASE64`، `ANDROID_KEYSTORE_PASSWORD`، `ANDROID_KEY_ALIAS`، `ANDROID_KEY_PASSWORD`: کلید امضای اپ اندروید

تا وقتی این مقادیر تنظیم نشده‌اند، ساخت انجام می‌شود ولی چیزی منتشر نمی‌شود.

## ساخت محلی اندروید

اپ اندروید خروجی ساخت وب‌اپ (`web/dist`) را در خود می‌گذارد، پس اول وب‌اپ را بسازید (بدون `BASE_PATH`):

```
cd web
npm ci
npm run build
cd ../android
gradlew :app:assembleDebug
```

هر تغییری در برنامه فقط در `web/` انجام می‌شود و با ساختن دوبارهٔ APK به اندروید هم می‌رسد.
