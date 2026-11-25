import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SmartPlug'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'09121234567'**
  String get phoneHint;

  /// No description provided for @channelLabel.
  ///
  /// In en, this message translates to:
  /// **'Receive code via'**
  String get channelLabel;

  /// No description provided for @channelBale.
  ///
  /// In en, this message translates to:
  /// **'Bale (@aalebot)'**
  String get channelBale;

  /// No description provided for @channelSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get channelSms;

  /// No description provided for @baleHint.
  ///
  /// In en, this message translates to:
  /// **'Message @aalebot in Bale and share your phone first.'**
  String get baleHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpLabel;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @shares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get shares;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get addDevice;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get noDevices;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @powerOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get powerOn;

  /// No description provided for @powerOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get powerOff;

  /// No description provided for @powerState.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get powerState;

  /// No description provided for @provisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get provisionTitle;

  /// No description provided for @provisionHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to add your plug?'**
  String get provisionHowTitle;

  /// No description provided for @provisionHowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We use your home Wi‑Fi and the cloud (MQTT). SoftAP is only a short step to hand Wi‑Fi to the plug — control is internet/cloud after that.'**
  String get provisionHowSubtitle;

  /// No description provided for @provisionWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi + cloud setup'**
  String get provisionWifi;

  /// No description provided for @provisionWifiSub.
  ///
  /// In en, this message translates to:
  /// **'Recommended — send home 2.4 GHz Wi‑Fi to the plug, then control it online'**
  String get provisionWifiSub;

  /// No description provided for @provisionClaim.
  ///
  /// In en, this message translates to:
  /// **'I have a pairing code'**
  String get provisionClaim;

  /// No description provided for @provisionClaimSub.
  ///
  /// In en, this message translates to:
  /// **'Enter the serial and code from the label'**
  String get provisionClaimSub;

  /// No description provided for @claimLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Pairing link copied'**
  String get claimLinkCopied;

  /// No description provided for @loginPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number'**
  String get loginPhoneSubtitle;

  /// No description provided for @loginOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get loginOtpSubtitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @failedToSendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code'**
  String get failedToSendCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'SmartPlug guide'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to set up and use your smart plugs.'**
  String get helpSubtitle;

  /// No description provided for @helpLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Log in with your phone'**
  String get helpLoginTitle;

  /// No description provided for @helpLoginStep1.
  ///
  /// In en, this message translates to:
  /// **'Open SmartPlug and enter your phone number in international format.'**
  String get helpLoginStep1;

  /// No description provided for @helpLoginStep2.
  ///
  /// In en, this message translates to:
  /// **'Enter the one-time code sent to your phone.'**
  String get helpLoginStep2;

  /// No description provided for @helpHouseholdTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Create households (sections)'**
  String get helpHouseholdTitle;

  /// No description provided for @helpHouseholdStep1.
  ///
  /// In en, this message translates to:
  /// **'Menu → Manage households, or create one when linking a plug.'**
  String get helpHouseholdStep1;

  /// No description provided for @helpHouseholdStep2.
  ///
  /// In en, this message translates to:
  /// **'Use sections like Home / Shop. One account can own many plugs.'**
  String get helpHouseholdStep2;

  /// No description provided for @helpHouseholdStep3.
  ///
  /// In en, this message translates to:
  /// **'Share a whole household so family gets every plug in that section.'**
  String get helpHouseholdStep3;

  /// No description provided for @helpAddTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Add a device'**
  String get helpAddTitle;

  /// No description provided for @helpAddStep1.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi setup: Add device → Wi‑Fi setup. Enter serial, approve Connect to SmartPlug-XXXX, send home 2.4 GHz Wi‑Fi. No browser.'**
  String get helpAddStep1;

  /// No description provided for @helpAddStep2.
  ///
  /// In en, this message translates to:
  /// **'Pairing code: tap +, choose “I have a pairing code”, enter serial and code from the label.'**
  String get helpAddStep2;

  /// No description provided for @helpAddStep3.
  ///
  /// In en, this message translates to:
  /// **'Use Get token if you only have the serial number.'**
  String get helpAddStep3;

  /// No description provided for @helpControlTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Control power (3 ways)'**
  String get helpControlTitle;

  /// No description provided for @helpControlStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap a device → power button. The app tries the plug hotspot, then home Wi‑Fi, then internet.'**
  String get helpControlStep1;

  /// No description provided for @helpControlStep2.
  ///
  /// In en, this message translates to:
  /// **'Same home Wi‑Fi: works even if internet is down.'**
  String get helpControlStep2;

  /// No description provided for @helpControlStep3.
  ///
  /// In en, this message translates to:
  /// **'No router: join SmartPlug-XXXX Wi‑Fi and control the plug directly.'**
  String get helpControlStep3;

  /// No description provided for @helpControlStep4.
  ///
  /// In en, this message translates to:
  /// **'Away from home: uses our cloud servers. You never install extra software on your modem.'**
  String get helpControlStep4;

  /// No description provided for @helpShareTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Share access'**
  String get helpShareTitle;

  /// No description provided for @helpShareStep1.
  ///
  /// In en, this message translates to:
  /// **'Open device details → Shares to invite by phone number.'**
  String get helpShareStep1;

  /// No description provided for @helpShareStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose view, control, or admin permission.'**
  String get helpShareStep2;

  /// No description provided for @helpShareStep3.
  ///
  /// In en, this message translates to:
  /// **'Accept incoming shares from the share icon on the home screen.'**
  String get helpShareStep3;

  /// No description provided for @helpOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'6. No internet?'**
  String get helpOfflineTitle;

  /// No description provided for @helpOfflineStep1.
  ///
  /// In en, this message translates to:
  /// **'Stay on home Wi‑Fi: local control still works (cached devices appear with Offline banner).'**
  String get helpOfflineStep1;

  /// No description provided for @helpOfflineStep2.
  ///
  /// In en, this message translates to:
  /// **'No router: join the plug hotspot (SmartPlug-XXXX) and toggle directly.'**
  String get helpOfflineStep2;

  /// No description provided for @helpOfflineStep3.
  ///
  /// In en, this message translates to:
  /// **'Pairing codes, sharing, and cloud control need internet.'**
  String get helpOfflineStep3;

  /// No description provided for @helpTroubleTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Troubleshooting'**
  String get helpTroubleTitle;

  /// No description provided for @helpTroubleStep1.
  ///
  /// In en, this message translates to:
  /// **'Offline device: check Wi‑Fi password and that serial matches the label exactly.'**
  String get helpTroubleStep1;

  /// No description provided for @helpTroubleStep2.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: generate a new pairing token (expires in 24 hours).'**
  String get helpTroubleStep2;

  /// No description provided for @helpTroubleStep3.
  ///
  /// In en, this message translates to:
  /// **'Setup failed: in the app tap Connect to SmartPlug-XXXX and approve the prompt. Stay in SmartPlug — do not open a browser.'**
  String get helpTroubleStep3;

  /// No description provided for @helpTroubleStep4.
  ///
  /// In en, this message translates to:
  /// **'These plugs need 2.4 GHz Wi‑Fi, not 5 GHz-only.'**
  String get helpTroubleStep4;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageFa.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languageFa;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @backBtn.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your plug + this app'**
  String get onboardWelcomeTitle;

  /// No description provided for @onboardWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'You only need the SmartPlug and this app. No extra apps or modem software — control runs through our servers when you have internet.'**
  String get onboardWelcomeBody;

  /// No description provided for @onboardModesTitle.
  ///
  /// In en, this message translates to:
  /// **'How control works'**
  String get onboardModesTitle;

  /// No description provided for @onboardModesBody.
  ///
  /// In en, this message translates to:
  /// **'1) Plug hotspot (SmartPlug-XXXX): for setup or direct ON/OFF.\n2) Home Wi‑Fi: same network as the plug — fast local control.\n3) Internet: control from anywhere.\nShare plugs with family by phone number when you are online.'**
  String get onboardModesBody;

  /// No description provided for @onboardReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re ready'**
  String get onboardReadyTitle;

  /// No description provided for @onboardReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the plug with Wi‑Fi setup, then tap ON/OFF. The app picks the best path automatically.'**
  String get onboardReadyBody;

  /// No description provided for @onboardSetupWifiNow.
  ///
  /// In en, this message translates to:
  /// **'Set up Wi‑Fi now'**
  String get onboardSetupWifiNow;

  /// No description provided for @shareAccess.
  ///
  /// In en, this message translates to:
  /// **'Share Access'**
  String get shareAccess;

  /// No description provided for @eventHistory.
  ///
  /// In en, this message translates to:
  /// **'Event History'**
  String get eventHistory;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @infoTab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTab;

  /// No description provided for @controlTab.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get controlTab;

  /// No description provided for @readingsTab.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readingsTab;

  /// No description provided for @firmware.
  ///
  /// In en, this message translates to:
  /// **'Firmware'**
  String get firmware;

  /// No description provided for @connectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity;

  /// No description provided for @lastChanged.
  ///
  /// In en, this message translates to:
  /// **'Last changed'**
  String get lastChanged;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @offlineCannotControl.
  ///
  /// In en, this message translates to:
  /// **'Device is offline — cannot control'**
  String get offlineCannotControl;

  /// No description provided for @cloudOfflineTryLocal.
  ///
  /// In en, this message translates to:
  /// **'Internet offline — app will try home Wi‑Fi, then the plug hotspot.'**
  String get cloudOfflineTryLocal;

  /// No description provided for @cloudOfflineTryAp.
  ///
  /// In en, this message translates to:
  /// **'Internet offline — join the plug Wi‑Fi (SmartPlug-XXXX) or same home Wi‑Fi, then retry.'**
  String get cloudOfflineTryAp;

  /// No description provided for @controlVia.
  ///
  /// In en, this message translates to:
  /// **'Via'**
  String get controlVia;

  /// No description provided for @preferredPath.
  ///
  /// In en, this message translates to:
  /// **'Preferred path'**
  String get preferredPath;

  /// No description provided for @pathAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get pathAuto;

  /// No description provided for @pathSoftAp.
  ///
  /// In en, this message translates to:
  /// **'Plug hotspot'**
  String get pathSoftAp;

  /// No description provided for @pathLan.
  ///
  /// In en, this message translates to:
  /// **'Home Wi‑Fi'**
  String get pathLan;

  /// No description provided for @pathCloud.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get pathCloud;

  /// No description provided for @turnedOn.
  ///
  /// In en, this message translates to:
  /// **'Turned on'**
  String get turnedOn;

  /// No description provided for @turnedOff.
  ///
  /// In en, this message translates to:
  /// **'Turned off'**
  String get turnedOff;

  /// No description provided for @toggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle device'**
  String get toggleFailed;

  /// No description provided for @loadDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load device'**
  String get loadDeviceFailed;

  /// No description provided for @loadDevicesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load devices. Check your connection and try again.'**
  String get loadDevicesFailed;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @powerConsumption.
  ///
  /// In en, this message translates to:
  /// **'Power Consumption'**
  String get powerConsumption;

  /// No description provided for @noSharesYet.
  ///
  /// In en, this message translates to:
  /// **'No shares yet'**
  String get noSharesYet;

  /// No description provided for @tapToShare.
  ///
  /// In en, this message translates to:
  /// **'Tap + to share this device'**
  String get tapToShare;

  /// No description provided for @permission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// No description provided for @permView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get permView;

  /// No description provided for @permControl.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get permControl;

  /// No description provided for @permAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get permAdmin;

  /// No description provided for @addShare.
  ///
  /// In en, this message translates to:
  /// **'Add share'**
  String get addShare;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @revokeShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke share?'**
  String get revokeShareTitle;

  /// No description provided for @revokeShareBody.
  ///
  /// In en, this message translates to:
  /// **'This user will lose access immediately.'**
  String get revokeShareBody;

  /// No description provided for @incomingShares.
  ///
  /// In en, this message translates to:
  /// **'Incoming Shares'**
  String get incomingShares;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @accessLabel.
  ///
  /// In en, this message translates to:
  /// **'{scope} access'**
  String accessLabel(String scope);

  /// No description provided for @scopeId.
  ///
  /// In en, this message translates to:
  /// **'Scope: {id}…'**
  String scopeId(String id);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @sharedAgo.
  ///
  /// In en, this message translates to:
  /// **'Shared {time}'**
  String sharedAgo(String time);

  /// No description provided for @wifiSetup.
  ///
  /// In en, this message translates to:
  /// **'WiFi Setup'**
  String get wifiSetup;

  /// No description provided for @apStepPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get apStepPrepare;

  /// No description provided for @apStepSerial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get apStepSerial;

  /// No description provided for @apStepConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get apStepConnect;

  /// No description provided for @apStepWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi'**
  String get apStepWifi;

  /// No description provided for @apStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get apStepPassword;

  /// No description provided for @apStepWait.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get apStepWait;

  /// No description provided for @findPlugHotspot.
  ///
  /// In en, this message translates to:
  /// **'Find plug hotspot'**
  String get findPlugHotspot;

  /// No description provided for @scanningPlugHotspots.
  ///
  /// In en, this message translates to:
  /// **'Looking for SmartPlug hotspots…'**
  String get scanningPlugHotspots;

  /// No description provided for @noPlugHotspotFound.
  ///
  /// In en, this message translates to:
  /// **'No SmartPlug hotspot found. Power the plug in setup mode, then scan again.'**
  String get noPlugHotspotFound;

  /// No description provided for @plugHotspotSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected hotspot: {ssid}'**
  String plugHotspotSelected(String ssid);

  /// No description provided for @serialMustEndWith.
  ///
  /// In en, this message translates to:
  /// **'Serial must end with {tail}'**
  String serialMustEndWith(String tail);

  /// No description provided for @readingPlugSerial.
  ///
  /// In en, this message translates to:
  /// **'Reading serial from the plug…'**
  String get readingPlugSerial;

  /// No description provided for @connectToSendWifi.
  ///
  /// In en, this message translates to:
  /// **'Connect to plug & send Wi‑Fi'**
  String get connectToSendWifi;

  /// No description provided for @softApErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow location / nearby Wi‑Fi permission, then try again.'**
  String get softApErrorPermission;

  /// No description provided for @softApErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not join the plug hotspot. Approve Connect, or open Wi‑Fi settings.'**
  String get softApErrorUnavailable;

  /// No description provided for @softApErrorUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot join Wi‑Fi from the app. Open Wi‑Fi settings, join the plug hotspot, then return.'**
  String get softApErrorUnsupported;

  /// No description provided for @softApErrorNotReachable.
  ///
  /// In en, this message translates to:
  /// **'Joined the hotspot but the plug did not answer. Stay on this screen and try Connect again.'**
  String get softApErrorNotReachable;

  /// No description provided for @softApErrorSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not open Wi‑Fi settings.'**
  String get softApErrorSettings;

  /// No description provided for @softApErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the plug hotspot. Try again.'**
  String get softApErrorUnknown;

  /// No description provided for @pickWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose home Wi‑Fi'**
  String get pickWifiTitle;

  /// No description provided for @pickWifiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the 2.4 GHz network the plug should join. 5 GHz networks are listed but this plug cannot use them.'**
  String get pickWifiSubtitle;

  /// No description provided for @scanningWifi.
  ///
  /// In en, this message translates to:
  /// **'Scanning nearby Wi‑Fi…'**
  String get scanningWifi;

  /// No description provided for @noWifiFound.
  ///
  /// In en, this message translates to:
  /// **'No networks found. Pull to refresh, or enter a name.'**
  String get noWifiFound;

  /// No description provided for @otherNetwork.
  ///
  /// In en, this message translates to:
  /// **'Other network…'**
  String get otherNetwork;

  /// No description provided for @otherNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'Type the Wi‑Fi name'**
  String get otherNetworkHint;

  /// No description provided for @band5Ghz.
  ///
  /// In en, this message translates to:
  /// **'5 GHz — plug cannot use this'**
  String get band5Ghz;

  /// No description provided for @thisPhoneWifi.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisPhoneWifi;

  /// No description provided for @refreshWifi.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get refreshWifi;

  /// No description provided for @wifiPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow location / nearby Wi‑Fi so the app can list networks. You can still type a name.'**
  String get wifiPermissionDenied;

  /// No description provided for @apPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare your device'**
  String get apPrepareTitle;

  /// No description provided for @apPrepare1.
  ///
  /// In en, this message translates to:
  /// **'1. Plug the device into a power outlet near your modem/router.'**
  String get apPrepare1;

  /// No description provided for @apPrepare2.
  ///
  /// In en, this message translates to:
  /// **'2. Keep your phone on mobile data or home Wi‑Fi with internet (cloud pairing happens first).'**
  String get apPrepare2;

  /// No description provided for @apPrepare3.
  ///
  /// In en, this message translates to:
  /// **'3. Next you briefly join the plug hotspot only to send home Wi‑Fi — then the plug uses internet/MQTT. No local-only control mode.'**
  String get apPrepare3;

  /// No description provided for @apSerialOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter serial while online'**
  String get apSerialOnlineTitle;

  /// No description provided for @apSerialOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Stay on home Wi‑Fi or mobile data. We fetch a pairing token from the cloud before you join the plug\'s setup network (which has no internet).'**
  String get apSerialOnlineBody;

  /// No description provided for @apSerialContinue.
  ///
  /// In en, this message translates to:
  /// **'Get token & continue'**
  String get apSerialContinue;

  /// No description provided for @preparingToken.
  ///
  /// In en, this message translates to:
  /// **'Getting pairing token…'**
  String get preparingToken;

  /// No description provided for @apConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to the device'**
  String get apConnectTitle;

  /// No description provided for @apConnectBody.
  ///
  /// In en, this message translates to:
  /// **'The app joins the plug’s setup Wi‑Fi. Approve the Connect prompt on this screen — stay in SmartPlug. Do not open a browser.'**
  String get apConnectBody;

  /// No description provided for @apNoPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'The plug hotspot has no password. Approve the system Connect prompt; ignore “no internet”.'**
  String get apNoPasswordHint;

  /// No description provided for @apConnected.
  ///
  /// In en, this message translates to:
  /// **'I\'m connected'**
  String get apConnected;

  /// No description provided for @apConnectInApp.
  ///
  /// In en, this message translates to:
  /// **'Connect to {ssid}'**
  String apConnectInApp(String ssid);

  /// No description provided for @apConnecting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the Connect prompt… stay in this app.'**
  String get apConnecting;

  /// No description provided for @apOpenWifiSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Wi‑Fi settings'**
  String get apOpenWifiSettings;

  /// No description provided for @apCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Plug hotspot already joined — continue'**
  String get apCheckConnection;

  /// No description provided for @changeWifi.
  ///
  /// In en, this message translates to:
  /// **'Change Wi‑Fi'**
  String get changeWifi;

  /// No description provided for @changeWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Wi‑Fi password'**
  String get changeWifiPassword;

  /// No description provided for @showWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showWifiPassword;

  /// No description provided for @hideWifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hideWifiPassword;

  /// No description provided for @wrongWifiPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'If the plug stays offline, the Wi‑Fi name or password is wrong. You can change them here.'**
  String get wrongWifiPasswordHint;

  /// No description provided for @changeWifiSub.
  ///
  /// In en, this message translates to:
  /// **'Stay in the app. We join the plug hotspot, send a new 2.4 GHz network, then return you to home Wi‑Fi.'**
  String get changeWifiSub;

  /// No description provided for @wifiSent.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi sent to the plug'**
  String get wifiSent;

  /// No description provided for @wifiSentBody.
  ///
  /// In en, this message translates to:
  /// **'Stay on home Wi‑Fi. The plug should come online in about 20 seconds.'**
  String get wifiSentBody;

  /// No description provided for @apWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Wi-Fi credentials'**
  String get apWifiTitle;

  /// No description provided for @apWifiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your home 2.4 GHz Wi‑Fi (ESP plugs cannot use 5 GHz). The app sends this to the plug — no browser.'**
  String get apWifiSubtitle;

  /// No description provided for @wifiSsid.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi name (SSID)'**
  String get wifiSsid;

  /// No description provided for @wifiPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get wifiPassword;

  /// No description provided for @deviceSerial.
  ///
  /// In en, this message translates to:
  /// **'Device serial number'**
  String get deviceSerial;

  /// No description provided for @deviceNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Device name (optional)'**
  String get deviceNameOptional;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Living Room'**
  String get deviceNameHint;

  /// No description provided for @apCredsHint.
  ///
  /// In en, this message translates to:
  /// **'Credentials are sent directly to your device. They are never stored on our servers.'**
  String get apCredsHint;

  /// No description provided for @sendToDevice.
  ///
  /// In en, this message translates to:
  /// **'Send to device'**
  String get sendToDevice;

  /// No description provided for @configuringDevice.
  ///
  /// In en, this message translates to:
  /// **'Configuring device…'**
  String get configuringDevice;

  /// No description provided for @sendingCreds.
  ///
  /// In en, this message translates to:
  /// **'Sending Wi‑Fi to the plug from this app…'**
  String get sendingCreds;

  /// No description provided for @waitingForDevice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the plug on the internet…'**
  String get waitingForDevice;

  /// No description provided for @deviceWillAppear.
  ///
  /// In en, this message translates to:
  /// **'The app left the plug hotspot. Stay in this screen — do not open a browser.'**
  String get deviceWillAppear;

  /// No description provided for @claimInstead.
  ///
  /// In en, this message translates to:
  /// **'Or use a pairing code instead'**
  String get claimInstead;

  /// No description provided for @deviceConnected.
  ///
  /// In en, this message translates to:
  /// **'Device connected!'**
  String get deviceConnected;

  /// No description provided for @redirectingLink.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to link your device…'**
  String get redirectingLink;

  /// No description provided for @setupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup failed'**
  String get setupFailed;

  /// No description provided for @setupFailedDefault.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the plug. Tap Connect in the app and approve the prompt, then try again.'**
  String get setupFailedDefault;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @usePairingCode.
  ///
  /// In en, this message translates to:
  /// **'Use a pairing code instead'**
  String get usePairingCode;

  /// No description provided for @claimDevice.
  ///
  /// In en, this message translates to:
  /// **'Add with pairing code'**
  String get claimDevice;

  /// No description provided for @enterDeviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter device details'**
  String get enterDeviceDetails;

  /// No description provided for @claimSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the serial number and pairing code on the device label or packaging.'**
  String get claimSubtitle;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumber;

  /// No description provided for @pairingToken.
  ///
  /// In en, this message translates to:
  /// **'Pairing code'**
  String get pairingToken;

  /// No description provided for @pairingTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character code'**
  String get pairingTokenHint;

  /// No description provided for @getToken.
  ///
  /// In en, this message translates to:
  /// **'Get token'**
  String get getToken;

  /// No description provided for @enterSerialFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the device serial number first'**
  String get enterSerialFirst;

  /// No description provided for @tokenGenerated.
  ///
  /// In en, this message translates to:
  /// **'Pairing token generated'**
  String get tokenGenerated;

  /// No description provided for @enterSerial.
  ///
  /// In en, this message translates to:
  /// **'Enter the device serial number'**
  String get enterSerial;

  /// No description provided for @enterToken.
  ///
  /// In en, this message translates to:
  /// **'Enter the pairing code'**
  String get enterToken;

  /// No description provided for @claimDeviceBtn.
  ///
  /// In en, this message translates to:
  /// **'Add device'**
  String get claimDeviceBtn;

  /// No description provided for @linkDevice.
  ///
  /// In en, this message translates to:
  /// **'Link Device'**
  String get linkDevice;

  /// No description provided for @selectHouseholdFirst.
  ///
  /// In en, this message translates to:
  /// **'Select or create a household first'**
  String get selectHouseholdFirst;

  /// No description provided for @deviceLinked.
  ///
  /// In en, this message translates to:
  /// **'Device linked! Setup complete.'**
  String get deviceLinked;

  /// No description provided for @linkToHousehold.
  ///
  /// In en, this message translates to:
  /// **'Link to a household'**
  String get linkToHousehold;

  /// No description provided for @household.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get household;

  /// No description provided for @selectHousehold.
  ///
  /// In en, this message translates to:
  /// **'Select a household'**
  String get selectHousehold;

  /// No description provided for @newHousehold.
  ///
  /// In en, this message translates to:
  /// **'New household'**
  String get newHousehold;

  /// No description provided for @newHouseholdName.
  ///
  /// In en, this message translates to:
  /// **'New household name'**
  String get newHouseholdName;

  /// No description provided for @newHouseholdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Office'**
  String get newHouseholdHint;

  /// No description provided for @selectExisting.
  ///
  /// In en, this message translates to:
  /// **'Select existing'**
  String get selectExisting;

  /// No description provided for @linkAndDone.
  ///
  /// In en, this message translates to:
  /// **'Link & Done'**
  String get linkAndDone;

  /// No description provided for @loadHouseholdsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load households'**
  String get loadHouseholdsFailed;

  /// No description provided for @renameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename household'**
  String get renameFailed;

  /// No description provided for @deleteHouseholdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete household'**
  String get deleteHouseholdFailed;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @eventCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String eventCount(int count);

  /// No description provided for @byDevice.
  ///
  /// In en, this message translates to:
  /// **'By device'**
  String get byDevice;

  /// No description provided for @byUser.
  ///
  /// In en, this message translates to:
  /// **'By user'**
  String get byUser;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @manageHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Manage households'**
  String get manageHouseholds;

  /// No description provided for @householdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Households'**
  String get householdsTitle;

  /// No description provided for @householdSectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Sections group your plugs (Home, Shop…). Share a whole section or one device.'**
  String get householdSectionsHint;

  /// No description provided for @createHousehold.
  ///
  /// In en, this message translates to:
  /// **'Create household'**
  String get createHousehold;

  /// No description provided for @renameHousehold.
  ///
  /// In en, this message translates to:
  /// **'Rename household'**
  String get renameHousehold;

  /// No description provided for @deleteHousehold.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteHousehold;

  /// No description provided for @deleteHouseholdConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this household? It must be empty.'**
  String get deleteHouseholdConfirm;

  /// No description provided for @householdDeleted.
  ///
  /// In en, this message translates to:
  /// **'Household deleted'**
  String get householdDeleted;

  /// No description provided for @householdCreated.
  ///
  /// In en, this message translates to:
  /// **'Household created'**
  String get householdCreated;

  /// No description provided for @householdRenamed.
  ///
  /// In en, this message translates to:
  /// **'Household renamed'**
  String get householdRenamed;

  /// No description provided for @noHouseholdsYet.
  ///
  /// In en, this message translates to:
  /// **'No households yet'**
  String get noHouseholdsYet;

  /// No description provided for @createFirstHousehold.
  ///
  /// In en, this message translates to:
  /// **'Create your first section to organize plugs'**
  String get createFirstHousehold;

  /// No description provided for @offlineBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineBannerTitle;

  /// No description provided for @offlineBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Cached list — toggles still work on home Wi‑Fi or the plug hotspot. Sharing and refresh need internet.'**
  String get offlineBannerBody;

  /// No description provided for @offlineBannerHelp.
  ///
  /// In en, this message translates to:
  /// **'How control works'**
  String get offlineBannerHelp;

  /// No description provided for @deviceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or serial'**
  String get deviceSearchHint;

  /// No description provided for @deviceSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No devices match your search'**
  String get deviceSearchEmpty;

  /// No description provided for @noDevicesOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Last saved list. Reconnect to refresh. Home Wi‑Fi or plug-hotspot control still works on the same network.'**
  String get noDevicesOfflineHint;

  /// No description provided for @allDevices.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get allDevices;

  /// No description provided for @controlFailedTips.
  ///
  /// In en, this message translates to:
  /// **'Control failed. Try: join SmartPlug-XXXX, same home Wi‑Fi, or check your internet.'**
  String get controlFailedTips;

  /// No description provided for @offlineControlHintHotspot.
  ///
  /// In en, this message translates to:
  /// **'Plug is offline. Join SmartPlug-XXXX (plug hotspot) or the same home Wi‑Fi, then retry.'**
  String get offlineControlHintHotspot;

  /// No description provided for @offlineControlHintHomeWifi.
  ///
  /// In en, this message translates to:
  /// **'Plug is offline. Stay on the same home Wi‑Fi as the plug, then retry. If the password changed, use Change Wi‑Fi.'**
  String get offlineControlHintHomeWifi;

  /// No description provided for @emptyDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first plug with Wi‑Fi setup.'**
  String get emptyDevicesHint;

  /// No description provided for @emptySharesHint.
  ///
  /// In en, this message translates to:
  /// **'Invite someone by phone number to view or control this plug.'**
  String get emptySharesHint;

  /// No description provided for @emptyHouseholdSharesHint.
  ///
  /// In en, this message translates to:
  /// **'Share this whole section so family gets every plug in it.'**
  String get emptyHouseholdSharesHint;

  /// No description provided for @emptyIncomingHint.
  ///
  /// In en, this message translates to:
  /// **'When someone shares a plug with you, invitations show up here.'**
  String get emptyIncomingHint;

  /// No description provided for @shareNow.
  ///
  /// In en, this message translates to:
  /// **'Share now'**
  String get shareNow;

  /// No description provided for @devicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} devices'**
  String devicesCount(int count);

  /// No description provided for @unlinkedDevice.
  ///
  /// In en, this message translates to:
  /// **'Not linked yet'**
  String get unlinkedDevice;

  /// No description provided for @addAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Add another device'**
  String get addAnotherDevice;

  /// No description provided for @tapPlusToCreate.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create a household section'**
  String get tapPlusToCreate;

  /// No description provided for @householdNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Household name'**
  String get householdNameLabel;

  /// No description provided for @cannotDeleteNonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Move or unlink devices first — household must be empty.'**
  String get cannotDeleteNonEmpty;

  /// No description provided for @confirmDeleteHousehold.
  ///
  /// In en, this message translates to:
  /// **'Delete this household?'**
  String get confirmDeleteHousehold;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @removeDevice.
  ///
  /// In en, this message translates to:
  /// **'Remove device'**
  String get removeDevice;

  /// No description provided for @removeDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this plug from your account? You can add it again with Wi‑Fi setup.'**
  String get removeDeviceConfirm;

  /// No description provided for @deviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Device removed'**
  String get deviceRemoved;

  /// No description provided for @removeDeviceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the device. Check your connection and try again.'**
  String get removeDeviceFailed;

  /// No description provided for @deviceAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This plug is already linked to another home. Remove it there first, or ask the owner to share it.'**
  String get deviceAlreadyRegistered;

  /// No description provided for @deviceAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This plug is already linked to a home.'**
  String get deviceAlreadyLinked;

  /// No description provided for @pairingTokenInvalid.
  ///
  /// In en, this message translates to:
  /// **'Pairing code is invalid or expired. Start setup again while online.'**
  String get pairingTokenInvalid;

  /// No description provided for @unknownDeviceSerial.
  ///
  /// In en, this message translates to:
  /// **'Unknown serial. Check the label and try again.'**
  String get unknownDeviceSerial;

  /// No description provided for @provisionNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No internet. Rejoin home Wi‑Fi and try again.'**
  String get provisionNetworkError;

  /// No description provided for @provisionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timed out waiting for the plug on the internet. Stay on home Wi‑Fi and try again.'**
  String get provisionTimeout;

  /// No description provided for @provisionMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Missing pairing token. Restart setup while online.'**
  String get provisionMissingToken;

  /// No description provided for @provisionMissingSerial.
  ///
  /// In en, this message translates to:
  /// **'Missing serial. Enter it while you still have internet.'**
  String get provisionMissingSerial;

  /// No description provided for @provisionPollTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timed out waiting for the plug to come online.'**
  String get provisionPollTimeout;

  /// No description provided for @sharedWithYou.
  ///
  /// In en, this message translates to:
  /// **'Shared with you'**
  String get sharedWithYou;

  /// No description provided for @uiStyleMist.
  ///
  /// In en, this message translates to:
  /// **'New look (Mist)'**
  String get uiStyleMist;

  /// No description provided for @uiStyleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic look'**
  String get uiStyleClassic;

  /// No description provided for @uiStyleSwitchedMist.
  ///
  /// In en, this message translates to:
  /// **'Switched to Mist look. Use the menu to go back to Classic anytime.'**
  String get uiStyleSwitchedMist;

  /// No description provided for @uiStyleSwitchedClassic.
  ///
  /// In en, this message translates to:
  /// **'Switched to Classic look.'**
  String get uiStyleSwitchedClassic;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneRequired;

  /// No description provided for @phoneInvalidE164.
  ///
  /// In en, this message translates to:
  /// **'Use 09xxxxxxxxx (Iran mobile)'**
  String get phoneInvalidE164;

  /// No description provided for @shareStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get shareStatusPending;

  /// No description provided for @shareStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get shareStatusAccepted;

  /// No description provided for @shareStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get shareStatusRevoked;

  /// No description provided for @householdRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get householdRoleAdmin;

  /// No description provided for @householdRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get householdRoleMember;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
