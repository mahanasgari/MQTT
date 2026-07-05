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
  /// **'+1234567890'**
  String get phoneHint;

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

  /// No description provided for @provisionWifi.
  ///
  /// In en, this message translates to:
  /// **'Connect via WiFi'**
  String get provisionWifi;

  /// No description provided for @provisionWifiSub.
  ///
  /// In en, this message translates to:
  /// **'For devices in AP mode'**
  String get provisionWifiSub;

  /// No description provided for @provisionClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim with code'**
  String get provisionClaim;

  /// No description provided for @provisionClaimSub.
  ///
  /// In en, this message translates to:
  /// **'Enter pairing token'**
  String get provisionClaimSub;

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

  /// No description provided for @apStepConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get apStepConnect;

  /// No description provided for @apStepWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi'**
  String get apStepWifi;

  /// No description provided for @apStepWait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get apStepWait;

  /// No description provided for @apPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare your device'**
  String get apPrepareTitle;

  /// No description provided for @apPrepare1.
  ///
  /// In en, this message translates to:
  /// **'1. Plug the device into a power outlet.'**
  String get apPrepare1;

  /// No description provided for @apPrepare2.
  ///
  /// In en, this message translates to:
  /// **'2. Press and hold the button for 5 seconds until the LED blinks rapidly.'**
  String get apPrepare2;

  /// No description provided for @apPrepare3.
  ///
  /// In en, this message translates to:
  /// **'3. The device is now in AP mode and ready to be configured.'**
  String get apPrepare3;

  /// No description provided for @apConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to the device'**
  String get apConnectTitle;

  /// No description provided for @apConnectBody.
  ///
  /// In en, this message translates to:
  /// **'1. Go to your phone\'s Wi-Fi settings.\n2. Look for \"SmartPlug-XXXX\".\n3. Connect to this network.\n4. Return to this app.'**
  String get apConnectBody;

  /// No description provided for @apNoPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'No password is needed to connect to the device\'s setup network.'**
  String get apNoPasswordHint;

  /// No description provided for @apConnected.
  ///
  /// In en, this message translates to:
  /// **'I\'m connected'**
  String get apConnected;

  /// No description provided for @apWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Wi-Fi credentials'**
  String get apWifiTitle;

  /// No description provided for @apWifiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your home Wi-Fi details so the device can connect to the internet.'**
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
  /// **'Sending Wi-Fi credentials and registering with cloud.'**
  String get sendingCreds;

  /// No description provided for @waitingForDevice.
  ///
  /// In en, this message translates to:
  /// **'Waiting for device to connect…'**
  String get waitingForDevice;

  /// No description provided for @deviceWillAppear.
  ///
  /// In en, this message translates to:
  /// **'The device will appear here once it connects.'**
  String get deviceWillAppear;

  /// No description provided for @claimInstead.
  ///
  /// In en, this message translates to:
  /// **'Or claim with a code instead'**
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
  /// **'Could not configure the device. Check you are on the SmartPlug Wi-Fi network and try again.'**
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
  /// **'Claim Device'**
  String get claimDevice;

  /// No description provided for @enterDeviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter device details'**
  String get enterDeviceDetails;

  /// No description provided for @claimSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the serial number and pairing token on the device label or packaging.'**
  String get claimSubtitle;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumber;

  /// No description provided for @pairingToken.
  ///
  /// In en, this message translates to:
  /// **'Pairing token / code'**
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
  /// **'Enter the pairing token or code'**
  String get enterToken;

  /// No description provided for @claimDeviceBtn.
  ///
  /// In en, this message translates to:
  /// **'Claim device'**
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
