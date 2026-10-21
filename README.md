# مصباح الصادقین

برنامهٔ مطالعهٔ آثار عالم ربانی آیت‌الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه): «انیس الصادقین» و «سفینة الصادقین».

| پوشه | چیست |
|---|---|
| `Files/` | متن کتاب‌ها (`1.book` … `4.book`) و منابع مشترک؛ هر دو نسخهٔ جدید کتاب‌ها را از همین‌جا می‌خوانند |
| `android/` | اپ اندروید جدید (Kotlin + Jetpack Compose) |
| `web/` | وب‌اپ قابل نصب (PWA) برای آیفون و سایر دستگاه‌ها |
| ریشه (`*.bas`، `*.b4a`) | پروژهٔ قدیمی B4A |

## انتشار

هر push به شاخهٔ `main` با GitHub Actions ([`deploy.yml`](.github/workflows/deploy.yml)) اپ اندروید و وب‌اپ را می‌سازد و روی ساب‌دامین هاست (cPanel، از طریق FTPS) بارگذاری می‌کند؛ فایل APK در نشانی `/download/mesbah-sadeghin.apk` همان سایت قرار می‌گیرد.

تنظیمات لازم در Settings › Secrets and variables › Actions:

- `FTP_SERVER`، `FTP_USERNAME`، `FTP_PASSWORD`: حساب FTP هاست
- `FTP_SERVER_DIR`: پوشهٔ ساب‌دامین، مثلاً `mesbah.esperlos.sbs/` (هرگز `public_html/` — آن پوشهٔ سایت Asperlos است)
- `ANDROID_KEYSTORE_BASE64`، `ANDROID_KEYSTORE_PASSWORD`، `ANDROID_KEY_ALIAS`، `ANDROID_KEY_PASSWORD`: کلید امضای اپ اندروید

تا وقتی این مقادیر تنظیم نشده‌اند، ساخت انجام می‌شود ولی چیزی منتشر نمی‌شود.

## ساخت محلی اندروید

```
cd android
gradlew :app:assembleDebug
```
