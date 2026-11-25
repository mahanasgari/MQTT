// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'اسمارت‌پلاگ';

  @override
  String get loginTitle => 'ورود';

  @override
  String get phoneLabel => 'شماره موبایل';

  @override
  String get phoneHint => '09121234567';

  @override
  String get channelLabel => 'دریافت کد از';

  @override
  String get channelBale => 'بله (@aalebot)';

  @override
  String get channelSms => 'پیامک';

  @override
  String get baleHint =>
      'اول در بله به @aalebot پیام دهید و شماره را اشتراک بگذارید.';

  @override
  String get sendOtp => 'ارسال کد';

  @override
  String get otpLabel => 'کد تأیید';

  @override
  String get verify => 'تأیید';

  @override
  String get logout => 'خروج';

  @override
  String get dashboard => 'داشبورد';

  @override
  String get devices => 'دستگاه‌ها';

  @override
  String get shares => 'اشتراک‌ها';

  @override
  String get help => 'راهنما';

  @override
  String get addDevice => 'افزودن دستگاه';

  @override
  String get noDevices => 'هنوز دستگاهی ندارید';

  @override
  String get online => 'آنلاین';

  @override
  String get offline => 'آفلاین';

  @override
  String get powerOn => 'روشن';

  @override
  String get powerOff => 'خاموش';

  @override
  String get powerState => 'برق';

  @override
  String get provisionTitle => 'افزودن دستگاه';

  @override
  String get provisionHowTitle => 'چطور می‌خواهید پریز را اضافه کنید؟';

  @override
  String get provisionHowSubtitle =>
      'کنترل از طریق وای‌فای خانه و ابر (MQTT) است. هات‌اسپات دستگاه فقط برای دادن رمز وای‌فای است — بعد از آن کنترل آنلاین است.';

  @override
  String get provisionWifi => 'راه‌اندازی وای‌فای + ابر';

  @override
  String get provisionWifiSub =>
      'پیشنهادی — وای‌فای ۲٫۴ گیگاهرتز خانه را به پریز بدهید، بعد آنلاین کنترل کنید';

  @override
  String get provisionClaim => 'کد جفت‌سازی دارم';

  @override
  String get provisionClaimSub => 'سریال و کد روی برچسب را وارد کنید';

  @override
  String get claimLinkCopied => 'لینک جفت‌سازی کپی شد';

  @override
  String get loginPhoneSubtitle => 'با شماره موبایل وارد شوید';

  @override
  String get loginOtpSubtitle => 'کد تأیید را وارد کنید';

  @override
  String otpSentTo(String phone) {
    return 'کد به $phone ارسال شد';
  }

  @override
  String get changeNumber => 'تغییر شماره';

  @override
  String get resendCode => 'ارسال مجدد کد';

  @override
  String resendInSeconds(int seconds) {
    return 'ارسال مجدد تا $seconds ثانیه';
  }

  @override
  String get failedToSendCode => 'ارسال کد ناموفق بود';

  @override
  String get enterVerificationCode => 'کد تأیید را وارد کنید';

  @override
  String get needHelp => 'نیاز به راهنما؟';

  @override
  String get helpTitle => 'راهنمای اسمارت‌پلاگ';

  @override
  String get helpSubtitle => 'مراحل راه‌اندازی و استفاده از پریزهای هوشمند.';

  @override
  String get helpLoginTitle => '۱. ورود با موبایل';

  @override
  String get helpLoginStep1 =>
      'اسمارت‌پلاگ را باز کنید و شماره را به صورت بین‌المللی وارد کنید.';

  @override
  String get helpLoginStep2 => 'کد یک‌بارمصرف ارسال‌شده به گوشی را وارد کنید.';

  @override
  String get helpHouseholdTitle => '۲. ساخت خانه‌ها (بخش‌ها)';

  @override
  String get helpHouseholdStep1 =>
      'منو → مدیریت خانه‌ها، یا هنگام اتصال پریز یکی بسازید.';

  @override
  String get helpHouseholdStep2 =>
      'بخش‌هایی مثل خانه / مغازه. یک حساب می‌تواند چند پریز داشته باشد.';

  @override
  String get helpHouseholdStep3 =>
      'کل خانه را به اشتراک بگذارید تا خانواده همهٔ پریزهای آن بخش را ببیند.';

  @override
  String get helpAddTitle => '۳. افزودن دستگاه';

  @override
  String get helpAddStep1 =>
      'راه‌اندازی وای‌فای: افزودن دستگاه → راه‌اندازی وای‌فای. سریال را بزنید، اتصال به SmartPlug-XXXX را تأیید کنید، وای‌فای ۲٫۴ گیگاهرتز خانه را بفرستید. مرورگر لازم نیست.';

  @override
  String get helpAddStep2 =>
      'کد جفت‌سازی: روی + بزنید، «کد جفت‌سازی دارم» را انتخاب کنید، سریال و کد برچسب را وارد کنید.';

  @override
  String get helpAddStep3 =>
      'اگر فقط سریال دارید از «دریافت توکن» استفاده کنید.';

  @override
  String get helpControlTitle => '۴. کنترل برق (۳ روش)';

  @override
  String get helpControlStep1 =>
      'روی دستگاه → دکمهٔ برق. اپ اول هات‌اسپات پریز، بعد وای‌فای خانه، بعد اینترنت را امتحان می‌کند.';

  @override
  String get helpControlStep2 =>
      'همان وای‌فای خانه: حتی بدون اینترنت کار می‌کند.';

  @override
  String get helpControlStep3 =>
      'بدون مودم: به وای‌فای SmartPlug-XXXX وصل شوید و مستقیم کنترل کنید.';

  @override
  String get helpControlStep4 =>
      'دور از خانه: از سرور ابری ما استفاده می‌شود. نیازی به نصب نرم‌افزار اضافه روی مودم نیست.';

  @override
  String get helpShareTitle => '۵. اشتراک دسترسی';

  @override
  String get helpShareStep1 =>
      'جزئیات دستگاه → اشتراک‌ها برای دعوت با شماره موبایل.';

  @override
  String get helpShareStep2 => 'سطح مشاهده، کنترل یا مدیر را انتخاب کنید.';

  @override
  String get helpShareStep3 =>
      'اشتراک‌های ورودی را از آیکون اشتراک در صفحهٔ اصلی بپذیرید.';

  @override
  String get helpOfflineTitle => '۶. بدون اینترنت؟';

  @override
  String get helpOfflineStep1 =>
      'روی وای‌فای خانه بمانید: کنترل محلی کار می‌کند (دستگاه‌های ذخیره‌شده با بنر آفلاین).';

  @override
  String get helpOfflineStep2 =>
      'بدون مودم: به هات‌اسپات پریز (SmartPlug-XXXX) وصل شوید و مستقیم روشن/خاموش کنید.';

  @override
  String get helpOfflineStep3 =>
      'کد جفت‌سازی، اشتراک و کنترل ابری به اینترنت نیاز دارند.';

  @override
  String get helpTroubleTitle => '۷. رفع اشکال';

  @override
  String get helpTroubleStep1 =>
      'دستگاه آفلاین: رمز وای‌فای و تطابق دقیق سریال با برچسب را بررسی کنید.';

  @override
  String get helpTroubleStep2 =>
      'ثبت ناموفق: توکن جفت‌سازی جدید بگیرید (۲۴ ساعت اعتبار).';

  @override
  String get helpTroubleStep3 =>
      'راه‌اندازی ناموفق: در اپ Connect به SmartPlug-XXXX را بزنید و تأیید کنید. در اسمارت‌پلاگ بمانید — مرورگر باز نکنید.';

  @override
  String get helpTroubleStep4 =>
      'این پریزها وای‌فای ۲٫۴ گیگاهرتز می‌خواهند، نه فقط ۵ گیگاهرتز.';

  @override
  String get language => 'زبان';

  @override
  String get languageEn => 'English';

  @override
  String get languageFa => 'فارسی';

  @override
  String get cancel => 'لغو';

  @override
  String get save => 'ذخیره';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get edit => 'ویرایش';

  @override
  String get continueBtn => 'ادامه';

  @override
  String get backBtn => 'بازگشت';

  @override
  String get skip => 'رد شدن';

  @override
  String get getStarted => 'شروع';

  @override
  String get onboardWelcomeTitle => 'دوشاخه + همین اپ';

  @override
  String get onboardWelcomeBody =>
      'فقط SmartPlug و این اپ کافی است. نیازی به اپ یا نرم‌افزار اضافه روی مودم نیست — با اینترنت از سرور ما کنترل می‌شود.';

  @override
  String get onboardModesTitle => 'کنترل چگونه کار می‌کند';

  @override
  String get onboardModesBody =>
      '۱) هات‌اسپات پریز (SmartPlug-XXXX): برای راه‌اندازی یا روشن/خاموش مستقیم.\n۲) وای‌فای خانه: همان شبکهٔ پریز — کنترل محلی سریع.\n۳) اینترنت: کنترل از هرجا.\nوقتی آنلاین هستید می‌توانید پریز را با شماره موبایل با خانواده به اشتراک بگذارید.';

  @override
  String get onboardReadyTitle => 'آماده هستید';

  @override
  String get onboardReadyBody =>
      'پریز را با راه‌اندازی وای‌فای اضافه کنید، بعد روشن/خاموش بزنید. اپ خودش بهترین مسیر را انتخاب می‌کند.';

  @override
  String get onboardSetupWifiNow => 'الان وای‌فای را تنظیم کن';

  @override
  String get shareAccess => 'اشتراک دسترسی';

  @override
  String get eventHistory => 'تاریخچه رویداد';

  @override
  String get rename => 'تغییر نام';

  @override
  String get renameDevice => 'تغییر نام دستگاه';

  @override
  String get nameLabel => 'نام';

  @override
  String get infoTab => 'اطلاعات';

  @override
  String get controlTab => 'کنترل';

  @override
  String get readingsTab => 'اندازه‌گیری';

  @override
  String get firmware => 'فریم‌ور';

  @override
  String get connectivity => 'اتصال';

  @override
  String get lastChanged => 'آخرین تغییر';

  @override
  String get lastSeen => 'آخرین اتصال';

  @override
  String get connected => 'متصل';

  @override
  String get offlineCannotControl => 'دستگاه آفلاین است — کنترل ممکن نیست';

  @override
  String get cloudOfflineTryLocal =>
      'اینترنت قطع است — ابتدا وای‌فای خانه، سپس هات‌اسپات پریز امتحان می‌شود.';

  @override
  String get cloudOfflineTryAp =>
      'اینترنت قطع است — به وای‌فای پریز (SmartPlug-XXXX) یا همان وای‌فای خانه وصل شوید و دوباره تلاش کنید.';

  @override
  String get controlVia => 'از طریق';

  @override
  String get preferredPath => 'مسیر ترجیحی';

  @override
  String get pathAuto => 'خودکار';

  @override
  String get pathSoftAp => 'هات‌اسپات پریز';

  @override
  String get pathLan => 'وای‌فای خانه';

  @override
  String get pathCloud => 'اینترنت';

  @override
  String get turnedOn => 'روشن شد';

  @override
  String get turnedOff => 'خاموش شد';

  @override
  String get toggleFailed => 'تغییر وضعیت ناموفق بود';

  @override
  String get loadDeviceFailed => 'بارگذاری دستگاه ناموفق بود';

  @override
  String get loadDevicesFailed =>
      'بارگذاری دستگاه‌ها ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get voltage => 'ولتاژ';

  @override
  String get current => 'جریان';

  @override
  String get powerConsumption => 'مصرف توان';

  @override
  String get noSharesYet => 'هنوز اشتراکی نیست';

  @override
  String get tapToShare => 'برای اشتراک + را بزنید';

  @override
  String get permission => 'سطح دسترسی';

  @override
  String get permView => 'مشاهده';

  @override
  String get permControl => 'کنترل';

  @override
  String get permAdmin => 'مدیر';

  @override
  String get addShare => 'افزودن اشتراک';

  @override
  String get revoke => 'لغو';

  @override
  String get revokeShareTitle => 'لغو اشتراک؟';

  @override
  String get revokeShareBody => 'این کاربر فوراً دسترسی را از دست می‌دهد.';

  @override
  String get incomingShares => 'اشتراک‌های ورودی';

  @override
  String get noPendingInvitations => 'دعوت در انتظاری نیست';

  @override
  String accessLabel(String scope) {
    return 'دسترسی $scope';
  }

  @override
  String scopeId(String id) {
    return 'محدوده: $id…';
  }

  @override
  String get accept => 'پذیرش';

  @override
  String get decline => 'رد';

  @override
  String sharedAgo(String time) {
    return 'اشتراک $time';
  }

  @override
  String get wifiSetup => 'راه‌اندازی وای‌فای';

  @override
  String get apStepPrepare => 'آماده‌سازی';

  @override
  String get apStepSerial => 'سریال';

  @override
  String get apStepConnect => 'اتصال';

  @override
  String get apStepWifi => 'وای‌فای';

  @override
  String get apStepPassword => 'رمز';

  @override
  String get apStepWait => 'پایان';

  @override
  String get findPlugHotspot => 'پیدا کردن هات‌اسپات پریز';

  @override
  String get scanningPlugHotspots => 'در حال جستجوی هات‌اسپات SmartPlug…';

  @override
  String get noPlugHotspotFound =>
      'هات‌اسپات SmartPlug پیدا نشد. پریز را در حالت راه‌اندازی روشن کنید و دوباره اسکن کنید.';

  @override
  String plugHotspotSelected(String ssid) {
    return 'هات‌اسپات انتخاب‌شده: $ssid';
  }

  @override
  String serialMustEndWith(String tail) {
    return 'سریال باید به $tail ختم شود';
  }

  @override
  String get readingPlugSerial => 'در حال خواندن سریال از پریز…';

  @override
  String get connectToSendWifi => 'اتصال به پریز و ارسال وای‌فای';

  @override
  String get softApErrorPermission =>
      'اجازهٔ موقعیت / وای‌فای نزدیک را بدهید و دوباره تلاش کنید.';

  @override
  String get softApErrorUnavailable =>
      'به هات‌اسپات پریز وصل نشد. Connect را تأیید کنید یا تنظیمات وای‌فای را باز کنید.';

  @override
  String get softApErrorUnsupported =>
      'این گوشی نمی‌تواند از داخل اپ به وای‌فای وصل شود. تنظیمات وای‌فای را باز کنید، به هات‌اسپات پریز وصل شوید و برگردید.';

  @override
  String get softApErrorNotReachable =>
      'به هات‌اسپات وصل شدیم ولی پریز پاسخ نداد. در همین صفحه بمانید و دوباره Connect را بزنید.';

  @override
  String get softApErrorSettings => 'تنظیمات وای‌فای باز نشد.';

  @override
  String get softApErrorUnknown =>
      'اتصال به هات‌اسپات پریز ممکن نشد. دوباره تلاش کنید.';

  @override
  String get pickWifiTitle => 'وای‌فای خانه را انتخاب کنید';

  @override
  String get pickWifiSubtitle =>
      'شبکهٔ ۲٫۴ گیگاهرتز را بزنید. شبکه‌های ۵ گیگاهرتز در لیست هستند ولی این پریز آن‌ها را نمی‌بیند.';

  @override
  String get scanningWifi => 'در حال جستجوی وای‌فای…';

  @override
  String get noWifiFound =>
      'شبکه‌ای پیدا نشد. برای تازه‌سازی پایین بکشید یا نام را تایپ کنید.';

  @override
  String get otherNetwork => 'شبکهٔ دیگر…';

  @override
  String get otherNetworkHint => 'نام وای‌فای را بنویسید';

  @override
  String get band5Ghz => '۵ گیگاهرتز — پریز این را ندارد';

  @override
  String get thisPhoneWifi => 'همین گوشی';

  @override
  String get refreshWifi => 'اسکن دوباره';

  @override
  String get wifiPermissionDenied =>
      'اجازهٔ موقعیت / وای‌فای نزدیک را بدهید تا لیست بیاید. می‌توانید نام را هم تایپ کنید.';

  @override
  String get apPrepareTitle => 'آماده‌سازی دستگاه';

  @override
  String get apPrepare1 => '۱. دستگاه را نزدیک مودم/روتر به برق بزنید.';

  @override
  String get apPrepare2 =>
      '۲. گوشی را روی اینترنت نگه دارید (داده موبایل یا وای‌فای خانه) تا جفت‌سازی ابری انجام شود.';

  @override
  String get apPrepare3 =>
      '۳. بعد فقط کوتاه به هات‌اسپات پریز وصل می‌شوید تا وای‌فای خانه را بدهید — سپس کنترل از اینترنت/MQTT است، نه حالت محلی.';

  @override
  String get apSerialOnlineTitle => 'سریال را آنلاین وارد کنید';

  @override
  String get apSerialOnlineBody =>
      'روی وای‌فای خانه یا اینترنت موبایل بمانید. قبل از اتصال به شبکهٔ راه‌اندازی دوشاخه (بدون اینترنت)، توکن جفت‌سازی را از ابر می‌گیریم.';

  @override
  String get apSerialContinue => 'دریافت توکن و ادامه';

  @override
  String get preparingToken => 'در حال دریافت توکن جفت‌سازی…';

  @override
  String get apConnectTitle => 'اتصال به دستگاه';

  @override
  String get apConnectBody =>
      'اپ خودش به وای‌فای راه‌اندازی پریز وصل می‌شود. درخواست Connect را در همین صفحه تأیید کنید — در SmartPlug بمانید. مرورگر باز نکنید.';

  @override
  String get apNoPasswordHint =>
      'هات‌اسپات پریز رمز ندارد. درخواست اتصال سیستم را تأیید کنید؛ پیام «بدون اینترنت» را نادیده بگیرید.';

  @override
  String get apConnected => 'متصل شدم';

  @override
  String apConnectInApp(String ssid) {
    return 'اتصال به $ssid';
  }

  @override
  String get apConnecting => 'منتظر تأیید اتصال… در همین اپ بمانید.';

  @override
  String get apOpenWifiSettings => 'باز کردن تنظیمات وای‌فای';

  @override
  String get apCheckConnection => 'قبلاً به هات‌اسپات پریز وصل شدم — ادامه';

  @override
  String get changeWifi => 'تغییر وای‌فای';

  @override
  String get changeWifiPassword => 'تغییر رمز وای‌فای';

  @override
  String get showWifiPassword => 'نمایش رمز';

  @override
  String get hideWifiPassword => 'پنهان کردن رمز';

  @override
  String get wrongWifiPasswordHint =>
      'اگر پریز آفلاین ماند، نام یا رمز وای‌فای اشتباه است. اینجا عوض کنید.';

  @override
  String get changeWifiSub =>
      'در اپ بمانید. به هات‌اسپات پریز وصل می‌شویم، شبکهٔ ۲٫۴ گیگاهرتز جدید را می‌فرستیم، بعد به وای‌فای خانه برمی‌گردید.';

  @override
  String get wifiSent => 'وای‌فای به پریز ارسال شد';

  @override
  String get wifiSentBody =>
      'روی وای‌فای خانه بمانید. پریز حدود ۲۰ ثانیه دیگر آنلاین می‌شود.';

  @override
  String get apWifiTitle => 'اطلاعات وای‌فای خانه';

  @override
  String get apWifiSubtitle =>
      'وای‌فای ۲٫۴ گیگاهرتز خانه را وارد کنید (دوشاخه ۵ گیگاهرتز را نمی‌بیند). اپ این را به پریز می‌فرستد — مرورگر لازم نیست.';

  @override
  String get wifiSsid => 'نام وای‌فای (SSID)';

  @override
  String get wifiPassword => 'رمز عبور';

  @override
  String get deviceSerial => 'شماره سریال دستگاه';

  @override
  String get deviceNameOptional => 'نام دستگاه (اختیاری)';

  @override
  String get deviceNameHint => 'مثلاً اتاق نشیمن';

  @override
  String get apCredsHint =>
      'اطلاعات مستقیماً به دستگاه ارسال می‌شود و روی سرور ذخیره نمی‌شود.';

  @override
  String get sendToDevice => 'ارسال به دستگاه';

  @override
  String get configuringDevice => 'در حال پیکربندی دستگاه…';

  @override
  String get sendingCreds => 'ارسال وای‌فای به پریز از همین اپ…';

  @override
  String get waitingForDevice => 'منتظر پریز روی اینترنت…';

  @override
  String get deviceWillAppear =>
      'اپ از هات‌اسپات پریز خارج شد. در همین صفحه بمانید — مرورگر باز نکنید.';

  @override
  String get claimInstead => 'یا با کد جفت‌سازی ادامه دهید';

  @override
  String get deviceConnected => 'دستگاه متصل شد!';

  @override
  String get redirectingLink => 'در حال انتقال برای اتصال به خانه…';

  @override
  String get setupFailed => 'راه‌اندازی ناموفق';

  @override
  String get setupFailedDefault =>
      'به پریز نرسید. در اپ Connect را بزنید و درخواست را تأیید کنید، بعد دوباره تلاش کنید.';

  @override
  String get tryAgain => 'تلاش مجدد';

  @override
  String get usePairingCode => 'استفاده از کد جفت‌سازی';

  @override
  String get claimDevice => 'افزودن با کد جفت‌سازی';

  @override
  String get enterDeviceDetails => 'اطلاعات دستگاه';

  @override
  String get claimSubtitle =>
      'سریال و کد جفت‌سازی را از برچسب دستگاه پیدا کنید.';

  @override
  String get serialNumber => 'شماره سریال';

  @override
  String get pairingToken => 'کد جفت‌سازی';

  @override
  String get pairingTokenHint => 'کد ۶ رقمی را وارد کنید';

  @override
  String get getToken => 'دریافت توکن';

  @override
  String get enterSerialFirst => 'ابتدا شماره سریال را وارد کنید';

  @override
  String get tokenGenerated => 'توکن جفت‌سازی ایجاد شد';

  @override
  String get enterSerial => 'شماره سریال را وارد کنید';

  @override
  String get enterToken => 'کد جفت‌سازی را وارد کنید';

  @override
  String get claimDeviceBtn => 'افزودن دستگاه';

  @override
  String get linkDevice => 'اتصال به خانه';

  @override
  String get selectHouseholdFirst => 'ابتدا خانه را انتخاب یا ایجاد کنید';

  @override
  String get deviceLinked => 'دستگاه متصل شد! راه‌اندازی کامل شد.';

  @override
  String get linkToHousehold => 'اتصال به یک خانه';

  @override
  String get household => 'خانه';

  @override
  String get selectHousehold => 'انتخاب خانه';

  @override
  String get newHousehold => 'خانه جدید';

  @override
  String get newHouseholdName => 'نام خانه جدید';

  @override
  String get newHouseholdHint => 'مثلاً خانه، دفتر';

  @override
  String get selectExisting => 'انتخاب موجود';

  @override
  String get linkAndDone => 'اتصال و پایان';

  @override
  String get loadHouseholdsFailed => 'بارگذاری خانه‌ها ناموفق بود';

  @override
  String get renameFailed => 'تغییر نام خانه ناموفق بود';

  @override
  String get deleteHouseholdFailed => 'حذف خانه ناموفق بود';

  @override
  String get noEventsYet => 'رویدادی نیست';

  @override
  String eventCount(int count) {
    return '$count رویداد';
  }

  @override
  String get byDevice => 'توسط دستگاه';

  @override
  String get byUser => 'توسط کاربر';

  @override
  String errorPrefix(String message) {
    return 'خطا: $message';
  }

  @override
  String get manageHouseholds => 'مدیریت خانه‌ها';

  @override
  String get householdsTitle => 'خانه‌ها';

  @override
  String get householdSectionsHint =>
      'بخش‌ها دستگاه‌ها را گروه‌بندی می‌کنند (خانه، مغازه…). کل بخش یا یک دستگاه را به اشتراک بگذارید.';

  @override
  String get createHousehold => 'ایجاد خانه';

  @override
  String get renameHousehold => 'تغییر نام خانه';

  @override
  String get deleteHousehold => 'حذف';

  @override
  String get deleteHouseholdConfirm => 'این خانه حذف شود؟ باید خالی باشد.';

  @override
  String get householdDeleted => 'خانه حذف شد';

  @override
  String get householdCreated => 'خانه ایجاد شد';

  @override
  String get householdRenamed => 'نام خانه تغییر کرد';

  @override
  String get noHouseholdsYet => 'هنوز خانه‌ای نیست';

  @override
  String get createFirstHousehold =>
      'اولین بخش را برای سازمان‌دهی پریزها بسازید';

  @override
  String get offlineBannerTitle => 'حالت آفلاین';

  @override
  String get offlineBannerBody =>
      'لیست ذخیره‌شده — روشن/خاموش روی وای‌فای خانه یا هات‌اسپات پریز کار می‌کند. اشتراک و بروزرسانی به اینترنت نیاز دارند.';

  @override
  String get offlineBannerHelp => 'نحوه کنترل';

  @override
  String get deviceSearchHint => 'جستجو با نام یا سریال';

  @override
  String get deviceSearchEmpty => 'دستگاهی با این جستجو پیدا نشد';

  @override
  String get noDevicesOfflineHint =>
      'آخرین لیست ذخیره‌شده. برای بروزرسانی آنلاین شوید. کنترل با وای‌فای خانه یا هات‌اسپات پریز روی همان شبکه ممکن است.';

  @override
  String get allDevices => 'همه دستگاه‌ها';

  @override
  String get controlFailedTips =>
      'کنترل ناموفق. امتحان کنید: SmartPlug-XXXX، همان وای‌فای خانه، یا اینترنت.';

  @override
  String get offlineControlHintHotspot =>
      'پریز آفلاین است. به SmartPlug-XXXX (هات‌اسپات پریز) یا همان وای‌فای خانه وصل شوید و دوباره تلاش کنید.';

  @override
  String get offlineControlHintHomeWifi =>
      'پریز آفلاین است. روی همان وای‌فای خانه بمانید و دوباره تلاش کنید. اگر رمز عوض شده، «تغییر وای‌فای» را بزنید.';

  @override
  String get emptyDevicesHint =>
      'اولین پریز را با راه‌اندازی وای‌فای اضافه کنید.';

  @override
  String get emptySharesHint =>
      'با شماره موبایل کسی را دعوت کنید تا این پریز را ببیند یا کنترل کند.';

  @override
  String get emptyHouseholdSharesHint =>
      'کل این بخش را به اشتراک بگذارید تا خانواده همهٔ پریزهای آن را داشته باشند.';

  @override
  String get emptyIncomingHint =>
      'وقتی کسی پریزی با شما به اشتراک بگذارد، دعوت‌ها اینجا می‌آیند.';

  @override
  String get shareNow => 'الان اشتراک بگذار';

  @override
  String devicesCount(int count) {
    return '$count دستگاه';
  }

  @override
  String get unlinkedDevice => 'هنوز لینک نشده';

  @override
  String get addAnotherDevice => 'افزودن دستگاه دیگر';

  @override
  String get tapPlusToCreate => 'برای ساخت بخش خانه روی + بزنید';

  @override
  String get householdNameLabel => 'نام خانه';

  @override
  String get cannotDeleteNonEmpty =>
      'ابتدا دستگاه‌ها را منتقل یا جدا کنید — خانه باید خالی باشد.';

  @override
  String get confirmDeleteHousehold => 'این خانه حذف شود؟';

  @override
  String get delete => 'حذف';

  @override
  String get removeDevice => 'حذف دستگاه';

  @override
  String get removeDeviceConfirm =>
      'این پریز از حساب حذف شود؟ بعداً می‌توانید با راه‌اندازی وای‌فای دوباره اضافه کنید.';

  @override
  String get deviceRemoved => 'دستگاه حذف شد';

  @override
  String get removeDeviceFailed =>
      'حذف دستگاه ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get deviceAlreadyRegistered =>
      'این پریز قبلاً به خانهٔ دیگری وصل شده. اول آنجا حذفش کنید یا از صاحب بخواهید اشتراک بدهد.';

  @override
  String get deviceAlreadyLinked => 'این پریز قبلاً به یک خانه وصل شده است.';

  @override
  String get pairingTokenInvalid =>
      'کد جفت‌سازی نامعتبر یا منقضی است. راه‌اندازی را دوباره آنلاین شروع کنید.';

  @override
  String get unknownDeviceSerial =>
      'سریال ناشناخته است. برچسب را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get provisionNetworkError =>
      'اینترنت نیست. به وای‌فای خانه برگردید و دوباره تلاش کنید.';

  @override
  String get provisionTimeout =>
      'زمان انتظار برای پریز روی اینترنت تمام شد. روی وای‌فای خانه بمانید و دوباره تلاش کنید.';

  @override
  String get provisionMissingToken =>
      'توکن جفت‌سازی نیست. راه‌اندازی را دوباره آنلاین شروع کنید.';

  @override
  String get provisionMissingSerial =>
      'سریال نیست. وقتی اینترنت دارید وارد کنید.';

  @override
  String get provisionPollTimeout =>
      'زمان انتظار برای آنلاین شدن پریز تمام شد.';

  @override
  String get sharedWithYou => 'اشتراک‌گذاری شده با شما';

  @override
  String get uiStyleMist => 'ظاهر جدید (مه)';

  @override
  String get uiStyleClassic => 'ظاهر کلاسیک';

  @override
  String get uiStyleSwitchedMist =>
      'ظاهر مه فعال شد. هر وقت بخواهید از منو به کلاسیک برگردید.';

  @override
  String get uiStyleSwitchedClassic => 'ظاهر کلاسیک فعال شد.';

  @override
  String get phoneRequired => 'شماره تلفن را وارد کنید';

  @override
  String get phoneInvalidE164 => 'شماره را به صورت ۰۹xxxxxxxxx وارد کنید';

  @override
  String get shareStatusPending => 'در انتظار';

  @override
  String get shareStatusAccepted => 'پذیرفته‌شده';

  @override
  String get shareStatusRevoked => 'لغو شده';

  @override
  String get householdRoleAdmin => 'مدیر';

  @override
  String get householdRoleMember => 'عضو';
}
