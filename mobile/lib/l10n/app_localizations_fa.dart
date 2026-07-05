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
  String get phoneHint => '+989121234567';

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
  String get provisionWifi => 'اتصال با وای‌فای';

  @override
  String get provisionWifiSub => 'برای دستگاه در حالت AP';

  @override
  String get provisionClaim => 'ثبت با کد';

  @override
  String get provisionClaimSub => 'وارد کردن توکن جفت‌سازی';

  @override
  String get needHelp => 'نیاز به راهنما؟';

  @override
  String get helpTitle => 'راهنمای اسمارت‌پلاگ';

  @override
  String get helpSubtitle => 'مراحل راه‌اندازی و استفاده از پریزهای هوشمند.';

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
  String get turnedOn => 'روشن شد';

  @override
  String get turnedOff => 'خاموش شد';

  @override
  String get toggleFailed => 'تغییر وضعیت ناموفق بود';

  @override
  String get loadDeviceFailed => 'بارگذاری دستگاه ناموفق بود';

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
  String get apStepConnect => 'اتصال';

  @override
  String get apStepWifi => 'وای‌فای';

  @override
  String get apStepWait => 'انتظار';

  @override
  String get apPrepareTitle => 'آماده‌سازی دستگاه';

  @override
  String get apPrepare1 => '۱. دستگاه را به پریز برق وصل کنید.';

  @override
  String get apPrepare2 =>
      '۲. دکمه را ۵ ثانیه نگه دارید تا LED سریع چشمک بزند.';

  @override
  String get apPrepare3 => '۳. دستگاه در حالت AP و آماده پیکربندی است.';

  @override
  String get apConnectTitle => 'اتصال به دستگاه';

  @override
  String get apConnectBody =>
      '۱. به تنظیمات وای‌فای گوشی بروید.\n۲. شبکه «SmartPlug-XXXX» را پیدا کنید.\n۳. به این شبکه وصل شوید.\n۴. به این اپ برگردید.';

  @override
  String get apNoPasswordHint =>
      'برای اتصال به شبکه راه‌اندازی دستگاه رمز لازم نیست.';

  @override
  String get apConnected => 'متصل شدم';

  @override
  String get apWifiTitle => 'اطلاعات وای‌فای خانه';

  @override
  String get apWifiSubtitle =>
      'اطلاعات وای‌فای خانه را وارد کنید تا دستگاه به اینترنت متصل شود.';

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
  String get sendingCreds => 'ارسال اطلاعات وای‌فای و ثبت در ابر.';

  @override
  String get waitingForDevice => 'در انتظار اتصال دستگاه…';

  @override
  String get deviceWillAppear => 'پس از اتصال دستگاه اینجا نمایش داده می‌شود.';

  @override
  String get claimInstead => 'یا با کد ثبت کنید';

  @override
  String get deviceConnected => 'دستگاه متصل شد!';

  @override
  String get redirectingLink => 'در حال انتقال برای اتصال به خانه…';

  @override
  String get setupFailed => 'راه‌اندازی ناموفق';

  @override
  String get setupFailedDefault =>
      'پیکربندی دستگاه ممکن نشد. بررسی کنید به وای‌فای SmartPlug متصل هستید.';

  @override
  String get tryAgain => 'تلاش مجدد';

  @override
  String get usePairingCode => 'استفاده از کد جفت‌سازی';

  @override
  String get claimDevice => 'ثبت دستگاه';

  @override
  String get enterDeviceDetails => 'اطلاعات دستگاه';

  @override
  String get claimSubtitle =>
      'سریال و توکن جفت‌سازی را از برچسب دستگاه پیدا کنید.';

  @override
  String get serialNumber => 'شماره سریال';

  @override
  String get pairingToken => 'توکن / کد جفت‌سازی';

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
  String get enterToken => 'توکن یا کد جفت‌سازی را وارد کنید';

  @override
  String get claimDeviceBtn => 'ثبت دستگاه';

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
}
