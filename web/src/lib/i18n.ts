/**
 * The app's own words (menus, buttons, messages) in Persian, Arabic and English; the books stay as
 * they are. Persian is the key, so the code reads as before: t('بازگشت') is «رجوع» or «Back».
 * {0}, {1} … are filled from the arguments.
 *
 * Plain TS without the DOM: books.ts uses it and is shared with the data build script.
 */
export type Language = 'fa' | 'ar' | 'en'

export const LANGUAGES: { id: Language; label: string }[] = [
  { id: 'fa', label: 'فارسی' },
  { id: 'ar', label: 'العربية' },
  { id: 'en', label: 'English' },
]

/** Persian → [Arabic, English]. */
const words = {
  // general
  'مصباح الصادقین': ['مصباح الصادقين', 'Mesbah al-Sadeghin'],
  'آثار و سیرهٔ عالم ربانی آیت‌الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه)': [
    'آثار وسيرة العالم الربّاني آية الله الحاج السيّد حسين يعقوبي قائني (قدّس سرّه)',
    'Works and life of the godly scholar Ayatollah Hajj Sayyid Husayn Ya‘qubi Qa’eni',
  ],
  'بازگشت': ['رجوع', 'Back'],
  'بارگیری ناموفق بود': ['فشل التحميل', 'Couldn’t load'],
  'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.': ['تحقّق من الاتصال بالإنترنت وحاول مرة أخرى.', 'Check your internet connection and try again.'],
  'تلاش دوباره': ['إعادة المحاولة', 'Try again'],
  'در حال بارگیری': ['جارٍ التحميل', 'Loading'],
  'این صفحه پیدا نشد': ['لم يتم العثور على هذه الصفحة', 'Page not found'],
  'صفحهٔ اصلی': ['الصفحة الرئيسية', 'Home'],
  'نسخهٔ {0}': ['الإصدار {0}', 'Version {0}'],
  'تنظیمات': ['الإعدادات', 'Settings'],
  'دربارهٔ برنامه': ['حول التطبيق', 'About'],
  'بستن': ['إغلاق', 'Close'],
  'باز کردن': ['فتح', 'Open'],
  'پاک کردن': ['مسح', 'Clear'],
  'حذف': ['حذف', 'Delete'],
  'بازگردانی': ['تراجع', 'Undo'],
  'انصراف': ['إلغاء', 'Cancel'],
  'ذخیره': ['حفظ', 'Save'],
  'همهٔ کتاب‌ها': ['كل الكتب', 'All books'],
  'کپی': ['نسخ', 'Copy'],
  'کپی شد': ['تم النسخ', 'Copied'],
  'کپی نشد': ['تعذّر النسخ', 'Couldn’t copy'],
  'متن کپی شد': ['تم نسخ النص', 'Text copied'],
  'پیوند کپی شد': ['تم نسخ الرابط', 'Link copied'],
  'اشتراک‌گذاری': ['مشاركة', 'Share'],
  'زبان برنامه': ['لغة التطبيق', 'App language'],

  // books
  'انیس الصادقین': ['أنيس الصادقين', 'Anis al-Sadeghin'],
  'سفینة الصادقین': ['سفينة الصادقين', 'Safinat al-Sadeghin'],
  'توصیه‌هایی از عالم ربانی آیت الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه) در زمینه ادعیه و اذکار': ['توصيات من العالم الرباني آية الله الحاج السيد حسين اليعقوبي القائني (قدّس سرّه) في الأدعية والأذكار', 'Recommendations from the godly scholar Ayatollah Hajj Sayyid Husayn Ya‘qubi Qa’eni (may God sanctify his soul) on supplications and remembrances'],
  'شرح حال عالم ربانی آیت الله حاج سیّد حسین یعقوبی قائنی (قدّس‌سرّه)': ['شرح حال العالم الرباني آية الله الحاج السيد حسين اليعقوبي القائني (قدّس سرّه)', 'Biography of the godly scholar Ayatollah Hajj Sayyid Husayn Ya‘qubi Qa’eni (may God sanctify his soul)'],
  'فارسی': ['الفارسية', 'Persian'],
  'عربی': ['العربية', 'Arabic'],
  'نسخه‌های {0}': ['نسخ {0}', '{0} editions'],

  // home
  'جستجو در متن کتاب‌ها…': ['البحث في نصوص الكتب…', 'Search the books…'],
  'ادامهٔ مطالعه': ['متابعة القراءة', 'Continue reading'],
  'شروع مطالعه': ['بدء القراءة', 'Start reading'],
  'پرکاربرد': ['الأكثر قراءة', 'Most read'],
  '{0} بار': ['{0} مرة', '{0}×'],
  'کتابخانه': ['المكتبة', 'Library'],
  'نشانه‌ها': ['العلامات', 'Bookmarks'],
  'کانال صادقین در ایتا': ['قناة الصادقين في إيتا', 'Eitaa channel'],
  'دانلود نسخهٔ اندروید': ['تنزيل نسخة أندرويد', 'Download the Android app'],
  'منتخب من': ['مختاراتي', 'My selection'],
  'همه و ترتیب': ['الكل والترتيب', 'All & order'],
  'دعاهای روزانه‌تان را با ستاره ☆ منتخب کنید تا همیشه یک لمس فاصله داشته باشند.': [
    'اختر أدعيتك اليومية بالنجمة ☆ لتكون دائمًا على بُعد لمسة واحدة.',
    'Star ☆ your daily supplications to keep them one tap away.',
  ],
  'خواندن پشت‌سرهم': ['القراءة المتتابعة', 'Read one after another'],
  'فهرست کتاب': ['فهرس الكتاب', 'Contents'],

  // contents
  'فهرست مطالب': ['فهرس المحتويات', 'Contents'],
  'بستن همه': ['طيّ الكل', 'Collapse all'],
  'باز کردن همه': ['توسيع الكل', 'Expand all'],
  'جستجو در این کتاب': ['البحث في هذا الكتاب', 'Search this book'],
  'جستجو در عناوین…': ['البحث في العناوين…', 'Search titles…'],
  'عنوانی با این عبارت نیست': ['لا يوجد عنوان بهذه العبارة', 'No title matches'],
  'حذف از منتخب': ['إزالة من المختارات', 'Remove from My selection'],
  'افزودن به منتخب': ['إضافة إلى المختارات', 'Add to My selection'],

  // favourites
  'هنوز چیزی منتخب نکرده‌اید': ['لم تختر شيئًا بعد', 'Nothing selected yet'],
  'هنگام مطالعهٔ هر دعا، ستارهٔ بالای صفحه را بزنید تا اینجا بیاید؛ مثلاً دعاهایی که هر روز می‌خوانید.': [
    'عند قراءة أي دعاء، اضغط النجمة أعلى الصفحة ليظهر هنا؛ كالأدعية التي تقرؤها كل يوم.',
    'While reading, tap the star at the top to add a supplication here — for example the ones you read every day.',
  ],
  'دعاها و بخش‌هایی که همیشه دم دستتان است': ['الأدعية والأقسام التي تريدها دائمًا في متناول يدك', 'Supplications and sections you keep at hand'],
  'بالاتر': ['للأعلى', 'Move up'],
  'پایین‌تر': ['للأسفل', 'Move down'],
  'از «منتخب من» حذف شد': ['حُذف من «مختاراتي»', 'Removed from My selection'],
  'به «منتخب من» اضافه شد': ['أُضيف إلى «مختاراتي»', 'Added to My selection'],

  // settings
  'متن': ['النص', 'Text'],
  'مطالعه': ['القراءة', 'Reading'],
  'روشن ماندن صفحه هنگام مطالعه': ['إبقاء الشاشة مضاءة أثناء القراءة', 'Keep the screen on while reading'],
  'فهرست پرکاربردها پاک شد': ['مُسحت قائمة الأكثر قراءة', 'Most-read list cleared'],
  'پاک کردن فهرست پرکاربردها': ['مسح قائمة الأكثر قراءة', 'Clear the most-read list'],
  'پشتیبان‌گیری از داده‌های من': ['النسخ الاحتياطي لبياناتي', 'Back up my data'],
  'منتخب‌ها، نشانه‌ها و یادداشت‌ها، جای مطالعه و تنظیمات را در یک فایل ذخیره کنید تا در گوشی یا مرورگر دیگری، یا پس از پاک شدن داده‌های مرورگر، بازگردانید. بازیابی، داده‌های فعلی را پاک نمی‌کند و فقط موارد تازه را می‌افزاید.':
    [
      'احفظ مختاراتك وعلاماتك وملاحظاتك وموضع قراءتك وإعداداتك في ملف، لتستعيدها في هاتف أو متصفح آخر أو بعد مسح بيانات المتصفح. الاستعادة لا تحذف البيانات الحالية، بل تضيف الجديد فقط.',
      'Save your selection, bookmarks and notes, reading positions and settings to a file, to restore them on another phone or browser, or after the browser’s data is cleared. Restoring deletes nothing; it only adds what is new.',
    ],
  'ذخیرهٔ فایل پشتیبان': ['حفظ ملف احتياطي', 'Save a backup file'],
  'داده‌ها بازیابی شد': ['تمت استعادة البيانات', 'Data restored'],
  'این فایل پشتیبانِ مصباح الصادقین نیست': ['هذا الملف ليس نسخة احتياطية من مصباح الصادقين', 'This is not a Mesbah al-Sadeghin backup file'],
  'بازیابی از فایل پشتیبان': ['الاستعادة من ملف احتياطي', 'Restore from a backup file'],
  'استفاده بدون اینترنت': ['الاستخدام دون إنترنت', 'Offline use'],
  'نسخهٔ اندروید': ['نسخة أندرويد', 'Android app'],
  'برنامهٔ اندروید مصباح الصادقین را می‌توانید مستقیم نصب کنید.': ['يمكنك تثبيت تطبيق مصباح الصادقين لأندرويد مباشرة.', 'You can install the Mesbah al-Sadeghin Android app directly.'],

  // about
  'راه‌های ارتباطی': ['طرق التواصل', 'Contact'],
  'مدیر کانال': ['مدير القناة', 'Channel administrator'],
  'برنامه‌نویس': ['المبرمج', 'Developer'],

  // bookmarks
  'هنوز نشانه‌ای ندارید': ['ليست لديك علامات بعد', 'No bookmarks yet'],
  'در صفحهٔ مطالعه، انگشت را روی یک بند نگه دارید و «نشانه‌گذاری این بند» را انتخاب کنید.': [
    'في صفحة القراءة، اضغط مطوّلًا على فقرة واختر «وضع علامة على هذه الفقرة».',
    'In the reader, press and hold a paragraph and choose “Bookmark this paragraph”.',
  ],
  'برای نشانه‌گذاری، کپی یا اشتراک یک بند، انگشت را روی آن نگه دارید': [
    'لوضع علامة على فقرة أو نسخها أو مشاركتها، اضغط عليها مطوّلًا',
    'To bookmark, copy or share a paragraph, press and hold it',
  ],
  'یادداشت': ['ملاحظة', 'Note'],
  'یادداشت شما دربارهٔ این بند…': ['ملاحظتك حول هذه الفقرة…', 'Your note on this paragraph…'],
  'نشانه حذف شد': ['حُذفت العلامة', 'Bookmark removed'],
  'نشانه اضافه شد': ['أُضيفت العلامة', 'Bookmark added'],

  // reader
  'جستجو در متن جاری': ['البحث في النص الحالي', 'Find in this text'],
  'کپی کل این بخش': ['نسخ هذا القسم كاملًا', 'Copy this whole section'],
  'اشتراک‌گذاری این بخش': ['مشاركة هذا القسم', 'Share this section'],
  'اشتراک‌گذاری پیوند این بخش': ['مشاركة رابط هذا القسم', 'Share a link to this section'],
  'پنهان کردن ترجمه': ['إخفاء الترجمة', 'Hide the translation'],
  'نمایش ترجمه': ['إظهار الترجمة', 'Show the translation'],
  'بدون ترجمه': ['بدون ترجمة', 'Without translation'],
  'با ترجمه': ['مع الترجمة', 'With translation'],
  'ترجمه': ['الترجمة', 'Translation'],
  'تنظیمات متن': ['إعدادات النص', 'Text settings'],
  'بیشتر': ['المزيد', 'More'],
  'منتخب من · {0}': ['مختاراتي · {0}', 'My selection · {0}'],
  'این بخش پیدا نشد': ['لم يتم العثور على هذا القسم', 'Section not found'],
  'این بخش متنی ندارد': ['لا نص في هذا القسم', 'This section has no text'],
  'پیمایش بخش‌ها': ['التنقّل بين الأقسام', 'Section navigation'],
  'قبلی': ['السابق', 'Previous'],
  'بعدی': ['التالي', 'Next'],
  'صفحهٔ {0}': ['صفحة {0}', 'Page {0}'],
  'بند': ['فقرة', 'Paragraph'],
  'حذف نشانه': ['حذف العلامة', 'Remove bookmark'],
  'نشانه‌گذاری این بند': ['وضع علامة على هذه الفقرة', 'Bookmark this paragraph'],
  'دست‌کم دو حرف بنویسید': ['اكتب حرفين على الأقل', 'Type at least two letters'],
  'واژه‌ای از همین بخش را بنویسید': ['اكتب كلمة من هذا القسم', 'Type a word from this section'],
  'در این بخش پیدا نشد': ['لم يوجد في هذا القسم', 'Not found in this section'],
  '{0} از {1}': ['{0} من {1}', '{0} of {1}'],
  'بستن جستجو': ['إغلاق البحث', 'Close search'],
  'جستجو در متن جاری…': ['البحث في النص الحالي…', 'Find in this text…'],
  'مورد قبلی': ['النتيجة السابقة', 'Previous match'],
  'مورد بعدی': ['النتيجة التالية', 'Next match'],
  'کلمهٔ کامل': ['كلمة كاملة', 'Whole word'],
  'فهرست و نتایج جستجو': ['الفهرس ونتائج البحث', 'Contents and search results'],
  'قلم': ['الخط', 'Font'],
  'اندازه': ['الحجم', 'Size'],
  'اسکرول خودکار': ['التمرير التلقائي', 'Auto-scroll'],
  'آهسته‌تر': ['أبطأ', 'Slower'],
  'تندتر': ['أسرع', 'Faster'],
  'توقف': ['إيقاف مؤقت', 'Pause'],
  'ادامه': ['متابعة', 'Resume'],
  'بستن اسکرول خودکار': ['إيقاف التمرير التلقائي', 'Stop auto-scroll'],
  'سرعت {0}': ['السرعة {0}', 'Speed {0}'],
  'به پایان این بخش رسید': ['وصل إلى نهاية هذا القسم', 'Reached the end of this section'],

  // search
  'جستجو در این کتاب…': ['البحث في هذا الكتاب…', 'Search this book…'],
  'جستجوی پیشرفته': ['بحث متقدّم', 'Advanced search'],
  'کلمه‌ها': ['الكلمات', 'Words'],
  'عین عبارت': ['العبارة كما هي', 'Exact phrase'],
  'همهٔ کلمه‌ها، به هر ترتیب': ['كل الكلمات، بأي ترتيب', 'All words, any order'],
  'جستجو در': ['البحث في', 'Search in'],
  'همهٔ متن': ['كل النص', 'All text'],
  'متن عربی': ['النص العربي', 'Arabic text'],
  'ترجمه و توضیحات': ['الترجمة والشروح', 'Translation and notes'],
  'عبارتی برای جستجو بنویسید': ['اكتب عبارة للبحث', 'Type something to search for'],
  'اعراب، «ی/ي» و «ک/ك» در جستجو اهمیتی ندارند. با «کلمهٔ کامل»، «الله» دیگر «اللهم» را پیدا نمی‌کند.': [
    'الحركات و«ی/ي» و«ک/ك» لا تؤثّر في البحث. ومع «كلمة كاملة» لا يجد «الله» كلمة «اللهم».',
    'Vowel marks and letter variants (ی/ي, ک/ك) don’t matter. With “Whole word”, «الله» no longer finds «اللهم».',
  ],
  'نتیجه‌ای پیدا نشد': ['لا توجد نتائج', 'No results'],
  'بیش از {0} نتیجه — عبارت دقیق‌تری بنویسید': ['أكثر من {0} نتيجة — اكتب عبارة أدق', 'More than {0} results — try a more specific search'],
  '{0} نتیجه': ['{0} نتيجة', '{0} results'],

  // text settings
  'پوسته': ['المظهر', 'Theme'],
  'خودکار': ['تلقائي', 'Auto'],
  'روشن': ['فاتح', 'Light'],
  'کاغذی': ['ورقي', 'Paper'],
  'شب': ['ليلي', 'Night'],
  'قلم عربی (ادعیه)': ['الخط العربي (الأدعية)', 'Arabic font (supplications)'],
  'متن عربی پررنگ': ['نص عربي عريض', 'Bold Arabic text'],
  'قلم فارسی': ['الخط الفارسي', 'Persian font'],
  'اندازهٔ متن عربی': ['حجم النص العربي', 'Arabic text size'],
  'اندازهٔ ترجمه': ['حجم الترجمة', 'Translation size'],
  'اندازهٔ متن فارسی و توضیحات': ['حجم النص الفارسي والشروح', 'Persian text and notes size'],
  'فاصلهٔ سطرها': ['المسافة بين الأسطر', 'Line spacing'],
  'تراز دوطرفه': ['ضبط النص من الجهتين', 'Justify text'],
  'تنظیمات متن به حالت پیش‌فرض برگشت': ['أُعيدت إعدادات النص إلى الافتراضية', 'Text settings restored to default'],
  'بازگشت به پیش‌فرض': ['الإعدادات الافتراضية', 'Restore defaults'],

  // install, offline, update
  'نصب روی آیفون': ['التثبيت على آيفون', 'Install on iPhone'],
  'نصب «مصباح الصادقین» روی آیفون': ['تثبيت «مصباح الصادقين» على آيفون', 'Install Mesbah al-Sadeghin on iPhone'],
  'در نوار Safari دکمهٔ اشتراک‌گذاری را بزنید': ['في شريط Safari اضغط زر المشاركة', 'In Safari’s toolbar, tap Share'],
  ' (در iOS ۲۶ ابتدا دکمهٔ «⋯»)': [' (في iOS 26 اضغط «⋯» أولًا)', ' (on iOS 26, tap “⋯” first)'],
  'گزینهٔ {0} یا «افزودن به صفحهٔ اصلی» را انتخاب کنید': ['اختر {0} أو «إضافة إلى الشاشة الرئيسية»', 'Choose “{0}”'],
  '«Add / افزودن» را بزنید و برنامه را از صفحهٔ اصلی گوشی باز کنید.': ['اضغط «Add / إضافة» ثم افتح التطبيق من الشاشة الرئيسية.', 'Tap “Add”, then open the app from your home screen.'],
  'بار اول که برنامهٔ نصب‌شده را باز می‌کنید اینترنت وصل باشد تا کتاب‌ها برای استفادهٔ بدون اینترنت ذخیره شوند.': [
    'عند فتح التطبيق المثبَّت أول مرة، ليكن الإنترنت متصلًا حتى تُحفظ الكتب للاستخدام دون إنترنت.',
    'The first time you open the installed app, be online so the books can be saved for offline use.',
  ],
  'برای نصب روی آیفون، این صفحه را در Safari باز کنید': ['للتثبيت على آيفون، افتح هذه الصفحة في Safari', 'To install on iPhone, open this page in Safari'],
  'در مرورگر داخلی برنامه‌ها (مثل ایتا) امکان نصب نیست. از منوی همین صفحه «باز کردن در Safari» را بزنید، یا پیوند را کپی و در Safari باز کنید.':
    [
      'لا يمكن التثبيت من المتصفح الداخلي للتطبيقات (مثل إيتا). اختر «فتح في Safari» من قائمة هذه الصفحة، أو انسخ الرابط وافتحه في Safari.',
      'Apps’ built-in browsers (like Eitaa’s) can’t install it. Choose “Open in Safari” from this page’s menu, or copy the link and open it in Safari.',
    ],
  'کپی پیوند': ['نسخ الرابط', 'Copy link'],
  'نصب نسخهٔ وب': ['تثبيت نسخة الويب', 'Install the web app'],
  'برای گوشی‌های اندروید، برنامهٔ مصباح الصادقین را دانلود و نصب کنید؛ بدون اینترنت هم کار می‌کند.': [
    'لهواتف أندرويد، نزّل تطبيق مصباح الصادقين وثبّته؛ يعمل دون إنترنت أيضًا.',
    'On Android, download and install the Mesbah al-Sadeghin app; it works offline too.',
  ],
  'نصب برنامه': ['تثبيت التطبيق', 'Install the app'],
  '{0} را مثل یک برنامه نصب کنید تا بدون اینترنت هم در دسترس باشد.': ['ثبّت {0} كتطبيق ليبقى متاحًا دون إنترنت.', 'Install {0} as an app to have it offline too.'],
  'ذخیره برای استفادهٔ بدون اینترنت پس از اولین بارگذاری کامل آغاز می‌شود.': ['يبدأ الحفظ للاستخدام دون إنترنت بعد أول تحميل كامل.', 'Saving for offline use starts after the first full load.'],
  'همهٔ کتاب‌ها برای استفادهٔ بدون اینترنت آماده است': ['كل الكتب جاهزة للاستخدام دون إنترنت', 'All books are ready for offline use'],
  'دریافت کامل نشد؛ با اتصال دوباره ادامه می‌یابد': ['لم يكتمل التنزيل؛ سيستمر عند الاتصال مجددًا', 'The download didn’t finish; it resumes when you’re online again'],
  'در حال آماده‌سازی برای استفادهٔ بدون اینترنت…': ['جارٍ التجهيز للاستخدام دون إنترنت…', 'Preparing for offline use…'],
  'نسخهٔ تازهٔ برنامه دریافت شد؛ چند لحظهٔ دیگر بارگذاری می‌شود.': ['وصلت نسخة جديدة من التطبيق؛ ستُحمَّل بعد لحظات.', 'A new version has arrived; it will load in a moment.'],
  'منتخب‌ها و نشانه‌های نسخهٔ قبلی برنامه منتقل شد': ['نُقلت المختارات والعلامات من النسخة السابقة للتطبيق', 'Your selection and bookmarks from the previous app were carried over'],
} as const satisfies Record<string, readonly [string, string]>

export type Phrase = keyof typeof words

let current: Language = 'fa'

export function setLanguage(language: Language) {
  current = language
}

export function language(): Language {
  return current
}

export function t(phrase: Phrase, ...args: (string | number)[]): string {
  const text = current === 'fa' ? phrase : words[phrase][current === 'ar' ? 0 : 1]
  return args.length ? text.replace(/\{(\d)\}/g, (_, i) => String(args[Number(i)])) : text
}

const digits = { fa: '۰۱۲۳۴۵۶۷۸۹', ar: '٠١٢٣٤٥٦٧٨٩' } as const

/** A number in the menus' language: Persian or Arabic digits, or Latin ones in English. */
export function num(value: number | string): string {
  if (current === 'en') return String(value)
  const set = digits[current]
  return String(value).replace(/[0-9]/g, (d) => set[d.charCodeAt(0) - 48])
}

/** A decimal number («1.9»): Persian and Arabic write the point as «٫». */
export function decimal(formatted: string): string {
  return current === 'en' ? formatted : formatted.replace('.', '٫')
}
