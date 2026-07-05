// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartPlug';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '+1234567890';

  @override
  String get sendOtp => 'Send code';

  @override
  String get otpLabel => 'Verification code';

  @override
  String get verify => 'Verify';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get devices => 'Devices';

  @override
  String get shares => 'Shares';

  @override
  String get help => 'Help';

  @override
  String get addDevice => 'Add device';

  @override
  String get noDevices => 'No devices yet';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get powerOn => 'ON';

  @override
  String get powerOff => 'OFF';

  @override
  String get powerState => 'Power';

  @override
  String get provisionTitle => 'Add Device';

  @override
  String get provisionWifi => 'Connect via WiFi';

  @override
  String get provisionWifiSub => 'For devices in AP mode';

  @override
  String get provisionClaim => 'Claim with code';

  @override
  String get provisionClaimSub => 'Enter pairing token';

  @override
  String get needHelp => 'Need help?';

  @override
  String get helpTitle => 'SmartPlug guide';

  @override
  String get helpSubtitle =>
      'Follow these steps to set up and use your smart plugs.';

  @override
  String get language => 'Language';

  @override
  String get languageEn => 'English';

  @override
  String get languageFa => 'فارسی';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get edit => 'Edit';

  @override
  String get continueBtn => 'Continue';

  @override
  String get shareAccess => 'Share Access';

  @override
  String get eventHistory => 'Event History';

  @override
  String get rename => 'Rename';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get nameLabel => 'Name';

  @override
  String get infoTab => 'Info';

  @override
  String get controlTab => 'Control';

  @override
  String get readingsTab => 'Readings';

  @override
  String get firmware => 'Firmware';

  @override
  String get connectivity => 'Connectivity';

  @override
  String get lastChanged => 'Last changed';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get connected => 'Connected';

  @override
  String get offlineCannotControl => 'Device is offline — cannot control';

  @override
  String get turnedOn => 'Turned on';

  @override
  String get turnedOff => 'Turned off';

  @override
  String get toggleFailed => 'Failed to toggle device';

  @override
  String get loadDeviceFailed => 'Failed to load device';

  @override
  String get voltage => 'Voltage';

  @override
  String get current => 'Current';

  @override
  String get powerConsumption => 'Power Consumption';

  @override
  String get noSharesYet => 'No shares yet';

  @override
  String get tapToShare => 'Tap + to share this device';

  @override
  String get permission => 'Permission';

  @override
  String get permView => 'View';

  @override
  String get permControl => 'Control';

  @override
  String get permAdmin => 'Admin';

  @override
  String get addShare => 'Add share';

  @override
  String get revoke => 'Revoke';

  @override
  String get revokeShareTitle => 'Revoke share?';

  @override
  String get revokeShareBody => 'This user will lose access immediately.';

  @override
  String get incomingShares => 'Incoming Shares';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String accessLabel(String scope) {
    return '$scope access';
  }

  @override
  String scopeId(String id) {
    return 'Scope: $id…';
  }

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String sharedAgo(String time) {
    return 'Shared $time';
  }

  @override
  String get wifiSetup => 'WiFi Setup';

  @override
  String get apStepPrepare => 'Prepare';

  @override
  String get apStepConnect => 'Connect';

  @override
  String get apStepWifi => 'WiFi';

  @override
  String get apStepWait => 'Wait';

  @override
  String get apPrepareTitle => 'Prepare your device';

  @override
  String get apPrepare1 => '1. Plug the device into a power outlet.';

  @override
  String get apPrepare2 =>
      '2. Press and hold the button for 5 seconds until the LED blinks rapidly.';

  @override
  String get apPrepare3 =>
      '3. The device is now in AP mode and ready to be configured.';

  @override
  String get apConnectTitle => 'Connect to the device';

  @override
  String get apConnectBody =>
      '1. Go to your phone\'s Wi-Fi settings.\n2. Look for \"SmartPlug-XXXX\".\n3. Connect to this network.\n4. Return to this app.';

  @override
  String get apNoPasswordHint =>
      'No password is needed to connect to the device\'s setup network.';

  @override
  String get apConnected => 'I\'m connected';

  @override
  String get apWifiTitle => 'Home Wi-Fi credentials';

  @override
  String get apWifiSubtitle =>
      'Enter your home Wi-Fi details so the device can connect to the internet.';

  @override
  String get wifiSsid => 'Wi-Fi name (SSID)';

  @override
  String get wifiPassword => 'Password';

  @override
  String get deviceSerial => 'Device serial number';

  @override
  String get deviceNameOptional => 'Device name (optional)';

  @override
  String get deviceNameHint => 'e.g. Living Room';

  @override
  String get apCredsHint =>
      'Credentials are sent directly to your device. They are never stored on our servers.';

  @override
  String get sendToDevice => 'Send to device';

  @override
  String get configuringDevice => 'Configuring device…';

  @override
  String get sendingCreds =>
      'Sending Wi-Fi credentials and registering with cloud.';

  @override
  String get waitingForDevice => 'Waiting for device to connect…';

  @override
  String get deviceWillAppear =>
      'The device will appear here once it connects.';

  @override
  String get claimInstead => 'Or claim with a code instead';

  @override
  String get deviceConnected => 'Device connected!';

  @override
  String get redirectingLink => 'Redirecting to link your device…';

  @override
  String get setupFailed => 'Setup failed';

  @override
  String get setupFailedDefault =>
      'Could not configure the device. Check you are on the SmartPlug Wi-Fi network and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get usePairingCode => 'Use a pairing code instead';

  @override
  String get claimDevice => 'Claim Device';

  @override
  String get enterDeviceDetails => 'Enter device details';

  @override
  String get claimSubtitle =>
      'Find the serial number and pairing token on the device label or packaging.';

  @override
  String get serialNumber => 'Serial number';

  @override
  String get pairingToken => 'Pairing token / code';

  @override
  String get pairingTokenHint => 'Enter the 6-character code';

  @override
  String get getToken => 'Get token';

  @override
  String get enterSerialFirst => 'Enter the device serial number first';

  @override
  String get tokenGenerated => 'Pairing token generated';

  @override
  String get enterSerial => 'Enter the device serial number';

  @override
  String get enterToken => 'Enter the pairing token or code';

  @override
  String get claimDeviceBtn => 'Claim device';

  @override
  String get linkDevice => 'Link Device';

  @override
  String get selectHouseholdFirst => 'Select or create a household first';

  @override
  String get deviceLinked => 'Device linked! Setup complete.';

  @override
  String get linkToHousehold => 'Link to a household';

  @override
  String get household => 'Household';

  @override
  String get selectHousehold => 'Select a household';

  @override
  String get newHousehold => 'New household';

  @override
  String get newHouseholdName => 'New household name';

  @override
  String get newHouseholdHint => 'e.g. Home, Office';

  @override
  String get selectExisting => 'Select existing';

  @override
  String get linkAndDone => 'Link & Done';

  @override
  String get loadHouseholdsFailed => 'Failed to load households';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String eventCount(int count) {
    return '$count events';
  }

  @override
  String get byDevice => 'By device';

  @override
  String get byUser => 'By user';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }
}
