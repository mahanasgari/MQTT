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
  String get phoneHint => '09121234567';

  @override
  String get channelLabel => 'Receive code via';

  @override
  String get channelBale => 'Bale (@aalebot)';

  @override
  String get channelSms => 'SMS';

  @override
  String get baleHint => 'Message @aalebot in Bale and share your phone first.';

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
  String get provisionHowTitle => 'How do you want to add your plug?';

  @override
  String get provisionHowSubtitle =>
      'We use your home Wi‑Fi and the cloud (MQTT). SoftAP is only a short step to hand Wi‑Fi to the plug — control is internet/cloud after that.';

  @override
  String get provisionWifi => 'Wi‑Fi + cloud setup';

  @override
  String get provisionWifiSub =>
      'Recommended — send home 2.4 GHz Wi‑Fi to the plug, then control it online';

  @override
  String get provisionClaim => 'I have a pairing code';

  @override
  String get provisionClaimSub => 'Enter the serial and code from the label';

  @override
  String get claimLinkCopied => 'Pairing link copied';

  @override
  String get loginPhoneSubtitle => 'Sign in with your phone number';

  @override
  String get loginOtpSubtitle => 'Enter the verification code';

  @override
  String otpSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get changeNumber => 'Change number';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get failedToSendCode => 'Failed to send code';

  @override
  String get enterVerificationCode => 'Enter the verification code';

  @override
  String get needHelp => 'Need help?';

  @override
  String get helpTitle => 'SmartPlug guide';

  @override
  String get helpSubtitle =>
      'Follow these steps to set up and use your smart plugs.';

  @override
  String get helpLoginTitle => '1. Log in with your phone';

  @override
  String get helpLoginStep1 =>
      'Open SmartPlug and enter your phone number in international format.';

  @override
  String get helpLoginStep2 => 'Enter the one-time code sent to your phone.';

  @override
  String get helpHouseholdTitle => '2. Create households (sections)';

  @override
  String get helpHouseholdStep1 =>
      'Menu → Manage households, or create one when linking a plug.';

  @override
  String get helpHouseholdStep2 =>
      'Use sections like Home / Shop. One account can own many plugs.';

  @override
  String get helpHouseholdStep3 =>
      'Share a whole household so family gets every plug in that section.';

  @override
  String get helpAddTitle => '3. Add a device';

  @override
  String get helpAddStep1 =>
      'Wi‑Fi setup: Add device → Wi‑Fi setup. Enter serial, approve Connect to SmartPlug-XXXX, send home 2.4 GHz Wi‑Fi. No browser.';

  @override
  String get helpAddStep2 =>
      'Pairing code: tap +, choose “I have a pairing code”, enter serial and code from the label.';

  @override
  String get helpAddStep3 =>
      'Use Get token if you only have the serial number.';

  @override
  String get helpControlTitle => '4. Control power (3 ways)';

  @override
  String get helpControlStep1 =>
      'Tap a device → power button. The app tries the plug hotspot, then home Wi‑Fi, then internet.';

  @override
  String get helpControlStep2 =>
      'Same home Wi‑Fi: works even if internet is down.';

  @override
  String get helpControlStep3 =>
      'No router: join SmartPlug-XXXX Wi‑Fi and control the plug directly.';

  @override
  String get helpControlStep4 =>
      'Away from home: uses our cloud servers. You never install extra software on your modem.';

  @override
  String get helpShareTitle => '5. Share access';

  @override
  String get helpShareStep1 =>
      'Open device details → Shares to invite by phone number.';

  @override
  String get helpShareStep2 => 'Choose view, control, or admin permission.';

  @override
  String get helpShareStep3 =>
      'Accept incoming shares from the share icon on the home screen.';

  @override
  String get helpOfflineTitle => '6. No internet?';

  @override
  String get helpOfflineStep1 =>
      'Stay on home Wi‑Fi: local control still works (cached devices appear with Offline banner).';

  @override
  String get helpOfflineStep2 =>
      'No router: join the plug hotspot (SmartPlug-XXXX) and toggle directly.';

  @override
  String get helpOfflineStep3 =>
      'Pairing codes, sharing, and cloud control need internet.';

  @override
  String get helpTroubleTitle => '7. Troubleshooting';

  @override
  String get helpTroubleStep1 =>
      'Offline device: check Wi‑Fi password and that serial matches the label exactly.';

  @override
  String get helpTroubleStep2 =>
      'Registration failed: generate a new pairing token (expires in 24 hours).';

  @override
  String get helpTroubleStep3 =>
      'Setup failed: in the app tap Connect to SmartPlug-XXXX and approve the prompt. Stay in SmartPlug — do not open a browser.';

  @override
  String get helpTroubleStep4 =>
      'These plugs need 2.4 GHz Wi‑Fi, not 5 GHz-only.';

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
  String get backBtn => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardWelcomeTitle => 'Your plug + this app';

  @override
  String get onboardWelcomeBody =>
      'You only need the SmartPlug and this app. No extra apps or modem software — control runs through our servers when you have internet.';

  @override
  String get onboardModesTitle => 'How control works';

  @override
  String get onboardModesBody =>
      '1) Plug hotspot (SmartPlug-XXXX): for setup or direct ON/OFF.\n2) Home Wi‑Fi: same network as the plug — fast local control.\n3) Internet: control from anywhere.\nShare plugs with family by phone number when you are online.';

  @override
  String get onboardReadyTitle => 'You’re ready';

  @override
  String get onboardReadyBody =>
      'Add the plug with Wi‑Fi setup, then tap ON/OFF. The app picks the best path automatically.';

  @override
  String get onboardSetupWifiNow => 'Set up Wi‑Fi now';

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
  String get cloudOfflineTryLocal =>
      'Internet offline — app will try home Wi‑Fi, then the plug hotspot.';

  @override
  String get cloudOfflineTryAp =>
      'Internet offline — join the plug Wi‑Fi (SmartPlug-XXXX) or same home Wi‑Fi, then retry.';

  @override
  String get controlVia => 'Via';

  @override
  String get preferredPath => 'Preferred path';

  @override
  String get pathAuto => 'Auto';

  @override
  String get pathSoftAp => 'Plug hotspot';

  @override
  String get pathLan => 'Home Wi‑Fi';

  @override
  String get pathCloud => 'Internet';

  @override
  String get turnedOn => 'Turned on';

  @override
  String get turnedOff => 'Turned off';

  @override
  String get toggleFailed => 'Failed to toggle device';

  @override
  String get loadDeviceFailed => 'Failed to load device';

  @override
  String get loadDevicesFailed =>
      'Could not load devices. Check your connection and try again.';

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
  String get apStepSerial => 'Serial';

  @override
  String get apStepConnect => 'Connect';

  @override
  String get apStepWifi => 'Wi‑Fi';

  @override
  String get apStepPassword => 'Password';

  @override
  String get apStepWait => 'Finish';

  @override
  String get findPlugHotspot => 'Find plug hotspot';

  @override
  String get scanningPlugHotspots => 'Looking for SmartPlug hotspots…';

  @override
  String get noPlugHotspotFound =>
      'No SmartPlug hotspot found. Power the plug in setup mode, then scan again.';

  @override
  String plugHotspotSelected(String ssid) {
    return 'Selected hotspot: $ssid';
  }

  @override
  String serialMustEndWith(String tail) {
    return 'Serial must end with $tail';
  }

  @override
  String get readingPlugSerial => 'Reading serial from the plug…';

  @override
  String get connectToSendWifi => 'Connect to plug & send Wi‑Fi';

  @override
  String get softApErrorPermission =>
      'Allow location / nearby Wi‑Fi permission, then try again.';

  @override
  String get softApErrorUnavailable =>
      'Could not join the plug hotspot. Approve Connect, or open Wi‑Fi settings.';

  @override
  String get softApErrorUnsupported =>
      'This phone cannot join Wi‑Fi from the app. Open Wi‑Fi settings, join the plug hotspot, then return.';

  @override
  String get softApErrorNotReachable =>
      'Joined the hotspot but the plug did not answer. Stay on this screen and try Connect again.';

  @override
  String get softApErrorSettings => 'Could not open Wi‑Fi settings.';

  @override
  String get softApErrorUnknown =>
      'Could not connect to the plug hotspot. Try again.';

  @override
  String get pickWifiTitle => 'Choose home Wi‑Fi';

  @override
  String get pickWifiSubtitle =>
      'Pick the 2.4 GHz network the plug should join. 5 GHz networks are listed but this plug cannot use them.';

  @override
  String get scanningWifi => 'Scanning nearby Wi‑Fi…';

  @override
  String get noWifiFound =>
      'No networks found. Pull to refresh, or enter a name.';

  @override
  String get otherNetwork => 'Other network…';

  @override
  String get otherNetworkHint => 'Type the Wi‑Fi name';

  @override
  String get band5Ghz => '5 GHz — plug cannot use this';

  @override
  String get thisPhoneWifi => 'This phone';

  @override
  String get refreshWifi => 'Scan again';

  @override
  String get wifiPermissionDenied =>
      'Allow location / nearby Wi‑Fi so the app can list networks. You can still type a name.';

  @override
  String get apPrepareTitle => 'Prepare your device';

  @override
  String get apPrepare1 =>
      '1. Plug the device into a power outlet near your modem/router.';

  @override
  String get apPrepare2 =>
      '2. Keep your phone on mobile data or home Wi‑Fi with internet (cloud pairing happens first).';

  @override
  String get apPrepare3 =>
      '3. Next you briefly join the plug hotspot only to send home Wi‑Fi — then the plug uses internet/MQTT. No local-only control mode.';

  @override
  String get apSerialOnlineTitle => 'Enter serial while online';

  @override
  String get apSerialOnlineBody =>
      'Stay on home Wi‑Fi or mobile data. We fetch a pairing token from the cloud before you join the plug\'s setup network (which has no internet).';

  @override
  String get apSerialContinue => 'Get token & continue';

  @override
  String get preparingToken => 'Getting pairing token…';

  @override
  String get apConnectTitle => 'Connect to the device';

  @override
  String get apConnectBody =>
      'The app joins the plug’s setup Wi‑Fi. Approve the Connect prompt on this screen — stay in SmartPlug. Do not open a browser.';

  @override
  String get apNoPasswordHint =>
      'The plug hotspot has no password. Approve the system Connect prompt; ignore “no internet”.';

  @override
  String get apConnected => 'I\'m connected';

  @override
  String apConnectInApp(String ssid) {
    return 'Connect to $ssid';
  }

  @override
  String get apConnecting =>
      'Waiting for the Connect prompt… stay in this app.';

  @override
  String get apOpenWifiSettings => 'Open Wi‑Fi settings';

  @override
  String get apCheckConnection => 'Plug hotspot already joined — continue';

  @override
  String get changeWifi => 'Change Wi‑Fi';

  @override
  String get changeWifiPassword => 'Change Wi‑Fi password';

  @override
  String get showWifiPassword => 'Show password';

  @override
  String get hideWifiPassword => 'Hide password';

  @override
  String get wrongWifiPasswordHint =>
      'If the plug stays offline, the Wi‑Fi name or password is wrong. You can change them here.';

  @override
  String get changeWifiSub =>
      'Stay in the app. We join the plug hotspot, send a new 2.4 GHz network, then return you to home Wi‑Fi.';

  @override
  String get wifiSent => 'Wi‑Fi sent to the plug';

  @override
  String get wifiSentBody =>
      'Stay on home Wi‑Fi. The plug should come online in about 20 seconds.';

  @override
  String get apWifiTitle => 'Home Wi-Fi credentials';

  @override
  String get apWifiSubtitle =>
      'Enter your home 2.4 GHz Wi‑Fi (ESP plugs cannot use 5 GHz). The app sends this to the plug — no browser.';

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
  String get sendingCreds => 'Sending Wi‑Fi to the plug from this app…';

  @override
  String get waitingForDevice => 'Waiting for the plug on the internet…';

  @override
  String get deviceWillAppear =>
      'The app left the plug hotspot. Stay in this screen — do not open a browser.';

  @override
  String get claimInstead => 'Or use a pairing code instead';

  @override
  String get deviceConnected => 'Device connected!';

  @override
  String get redirectingLink => 'Redirecting to link your device…';

  @override
  String get setupFailed => 'Setup failed';

  @override
  String get setupFailedDefault =>
      'Could not reach the plug. Tap Connect in the app and approve the prompt, then try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get usePairingCode => 'Use a pairing code instead';

  @override
  String get claimDevice => 'Add with pairing code';

  @override
  String get enterDeviceDetails => 'Enter device details';

  @override
  String get claimSubtitle =>
      'Find the serial number and pairing code on the device label or packaging.';

  @override
  String get serialNumber => 'Serial number';

  @override
  String get pairingToken => 'Pairing code';

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
  String get enterToken => 'Enter the pairing code';

  @override
  String get claimDeviceBtn => 'Add device';

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
  String get renameFailed => 'Failed to rename household';

  @override
  String get deleteHouseholdFailed => 'Failed to delete household';

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

  @override
  String get manageHouseholds => 'Manage households';

  @override
  String get householdsTitle => 'Households';

  @override
  String get householdSectionsHint =>
      'Sections group your plugs (Home, Shop…). Share a whole section or one device.';

  @override
  String get createHousehold => 'Create household';

  @override
  String get renameHousehold => 'Rename household';

  @override
  String get deleteHousehold => 'Delete';

  @override
  String get deleteHouseholdConfirm =>
      'Delete this household? It must be empty.';

  @override
  String get householdDeleted => 'Household deleted';

  @override
  String get householdCreated => 'Household created';

  @override
  String get householdRenamed => 'Household renamed';

  @override
  String get noHouseholdsYet => 'No households yet';

  @override
  String get createFirstHousehold =>
      'Create your first section to organize plugs';

  @override
  String get offlineBannerTitle => 'Offline mode';

  @override
  String get offlineBannerBody =>
      'Cached list — toggles still work on home Wi‑Fi or the plug hotspot. Sharing and refresh need internet.';

  @override
  String get offlineBannerHelp => 'How control works';

  @override
  String get deviceSearchHint => 'Search by name or serial';

  @override
  String get deviceSearchEmpty => 'No devices match your search';

  @override
  String get noDevicesOfflineHint =>
      'Last saved list. Reconnect to refresh. Home Wi‑Fi or plug-hotspot control still works on the same network.';

  @override
  String get allDevices => 'All devices';

  @override
  String get controlFailedTips =>
      'Control failed. Try: join SmartPlug-XXXX, same home Wi‑Fi, or check your internet.';

  @override
  String get offlineControlHintHotspot =>
      'Plug is offline. Join SmartPlug-XXXX (plug hotspot) or the same home Wi‑Fi, then retry.';

  @override
  String get offlineControlHintHomeWifi =>
      'Plug is offline. Stay on the same home Wi‑Fi as the plug, then retry. If the password changed, use Change Wi‑Fi.';

  @override
  String get emptyDevicesHint => 'Add your first plug with Wi‑Fi setup.';

  @override
  String get emptySharesHint =>
      'Invite someone by phone number to view or control this plug.';

  @override
  String get emptyHouseholdSharesHint =>
      'Share this whole section so family gets every plug in it.';

  @override
  String get emptyIncomingHint =>
      'When someone shares a plug with you, invitations show up here.';

  @override
  String get shareNow => 'Share now';

  @override
  String devicesCount(int count) {
    return '$count devices';
  }

  @override
  String get unlinkedDevice => 'Not linked yet';

  @override
  String get addAnotherDevice => 'Add another device';

  @override
  String get tapPlusToCreate => 'Tap + to create a household section';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get cannotDeleteNonEmpty =>
      'Move or unlink devices first — household must be empty.';

  @override
  String get confirmDeleteHousehold => 'Delete this household?';

  @override
  String get delete => 'Delete';

  @override
  String get removeDevice => 'Remove device';

  @override
  String get removeDeviceConfirm =>
      'Remove this plug from your account? You can add it again with Wi‑Fi setup.';

  @override
  String get deviceRemoved => 'Device removed';

  @override
  String get removeDeviceFailed =>
      'Could not remove the device. Check your connection and try again.';

  @override
  String get deviceAlreadyRegistered =>
      'This plug is already linked to another home. Remove it there first, or ask the owner to share it.';

  @override
  String get deviceAlreadyLinked => 'This plug is already linked to a home.';

  @override
  String get pairingTokenInvalid =>
      'Pairing code is invalid or expired. Start setup again while online.';

  @override
  String get unknownDeviceSerial =>
      'Unknown serial. Check the label and try again.';

  @override
  String get provisionNetworkError =>
      'No internet. Rejoin home Wi‑Fi and try again.';

  @override
  String get provisionTimeout =>
      'Timed out waiting for the plug on the internet. Stay on home Wi‑Fi and try again.';

  @override
  String get provisionMissingToken =>
      'Missing pairing token. Restart setup while online.';

  @override
  String get provisionMissingSerial =>
      'Missing serial. Enter it while you still have internet.';

  @override
  String get provisionPollTimeout =>
      'Timed out waiting for the plug to come online.';

  @override
  String get sharedWithYou => 'Shared with you';

  @override
  String get uiStyleMist => 'New look (Mist)';

  @override
  String get uiStyleClassic => 'Classic look';

  @override
  String get uiStyleSwitchedMist =>
      'Switched to Mist look. Use the menu to go back to Classic anytime.';

  @override
  String get uiStyleSwitchedClassic => 'Switched to Classic look.';

  @override
  String get phoneRequired => 'Enter your phone number';

  @override
  String get phoneInvalidE164 => 'Use 09xxxxxxxxx (Iran mobile)';

  @override
  String get shareStatusPending => 'Pending';

  @override
  String get shareStatusAccepted => 'Accepted';

  @override
  String get shareStatusRevoked => 'Revoked';

  @override
  String get householdRoleAdmin => 'Admin';

  @override
  String get householdRoleMember => 'Member';
}
