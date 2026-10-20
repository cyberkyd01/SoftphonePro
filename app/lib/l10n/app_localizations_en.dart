// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languagePickerHint =>
      'Language names are shown in their own language.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionBack => 'Back';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get actionImport => 'Import';

  @override
  String get actionExport => 'Export';

  @override
  String get actionDetails => 'Details';

  @override
  String get actionMore => 'More';

  @override
  String get actionSettings => 'Settings';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get commonOn => 'On';

  @override
  String get commonOff => 'Off';

  @override
  String get commonNone => 'None';

  @override
  String get commonDefault => 'Default';

  @override
  String get commonSystem => 'System';

  @override
  String get commonAutomatic => 'Automatic';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonError => 'Error';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusDoNotDisturb => 'Do not disturb';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'On a call';

  @override
  String get settingsEntryAccounts => 'Accounts';

  @override
  String get settingsEntryAccountsSub => 'SIP accounts and registration';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub => 'Devices, levels, echo cancellation';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Order, availability, Opus';

  @override
  String get settingsEntryCalls => 'Calls';

  @override
  String get settingsEntryCallsSub => 'DND, waiting, auto-answer, dial rules';

  @override
  String get settingsEntryNetwork => 'Network';

  @override
  String get settingsEntryNetworkSub => 'Transports, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Recording';

  @override
  String get settingsEntryNotifications => 'Notifications and ringtones';

  @override
  String get settingsEntryShortcuts => 'Shortcuts';

  @override
  String get settingsEntryShortcutsSub => 'Global hotkeys, in-app keys';

  @override
  String get settingsEntryAppearance => 'Appearance';

  @override
  String get settingsEntryPrivacy => 'Privacy and security';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisioning';

  @override
  String get settingsEntryProvisioningSub => 'Import, export, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnostics';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP trace, network checks';

  @override
  String get settingsEntryAdvanced => 'Advanced';

  @override
  String get settingsEntryAbout => 'About';

  @override
  String get settingsAccountsEmptyTitle => 'Add your first account';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Connect to your PBX or SIP provider to start calling.';

  @override
  String get settingsAccountsAdd => 'Add account';

  @override
  String get settingsAccountsYourAccounts => 'Your accounts';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  using backup server';
  }

  @override
  String get settingsAudioDevices => 'Devices';

  @override
  String get settingsAudioMicrophone => 'Microphone';

  @override
  String get settingsAudioSpeaker => 'Speaker';

  @override
  String get settingsAudioRinger => 'Ringer';

  @override
  String get settingsAudioRingerSub => 'Play the ringtone on a separate device';

  @override
  String get settingsAudioRefreshDevices => 'Refresh devices';

  @override
  String get settingsAudioLevelsAndTest => 'Levels and test';

  @override
  String get settingsAudioMicVolume => 'Microphone volume';

  @override
  String get settingsAudioMicLevel => 'Mic level';

  @override
  String get settingsAudioSpeakerVolume => 'Speaker volume';

  @override
  String get settingsAudioSpeakerLevel => 'Speaker level';

  @override
  String get settingsAudioTestSpeaker => 'Test speaker';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Plays a short tone through the selected speaker';

  @override
  String get settingsAudioTestToneFailed => 'Could not play the test tone';

  @override
  String get settingsAudioEchoTestFailed => 'Echo test failed';

  @override
  String get settingsAudioEchoTest => 'Echo test';

  @override
  String get settingsAudioEchoTestSub =>
      'Plays your microphone back through the speaker. Use headphones to avoid feedback.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voice and files';

  @override
  String get settingsAudioVoiceIsolation =>
      'Voice isolation (AI noise cancellation)';

  @override
  String get settingsAudioAudioFiles => 'Audio files';

  @override
  String get settingsAudioAudioFilesSub => 'Hold music and announcements';

  @override
  String get settingsAudioProcessing => 'Processing';

  @override
  String get settingsAudioEchoCancellation => 'Echo cancellation';

  @override
  String get settingsAudioEcSimple => 'Simple';

  @override
  String get settingsAudioEcPlatform => 'Platform';

  @override
  String get settingsAudioEchoTail => 'Echo tail';

  @override
  String get settingsAudioNoiseSuppression => 'Noise suppression';

  @override
  String get settingsAudioAgc => 'Automatic gain control';

  @override
  String get settingsAudioVad => 'Voice activity detection';

  @override
  String get settingsAudioVadSub => 'Saves bandwidth during silence';

  @override
  String get settingsAudioAdvanced => 'Advanced';

  @override
  String get settingsAudioAdvancedFooter =>
      'Jitter buffer values are in milliseconds; -1 uses the engine default. Changing these restarts the call engine.';

  @override
  String get settingsAudioPtime => 'Packet time (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter buffer: initial';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter buffer: minimum prefetch';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter buffer: maximum prefetch';

  @override
  String get settingsAudioJbMaxSize => 'Jitter buffer: maximum size';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microphone $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Others $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent percent';
  }

  @override
  String settingsUnitMs(int value) {
    return '$value ms';
  }

  @override
  String settingsUnitKbps(int value) {
    return '$value kbps';
  }

  @override
  String settingsUnitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Order and availability';

  @override
  String get settingsCodecsDragHint =>
      'Drag to reorder. Accounts can override this list in their own settings.';

  @override
  String get settingsCodecsBitrate => 'Bitrate';

  @override
  String get settingsCodecsFec => 'In-band FEC';

  @override
  String get settingsCodecsFecSub => 'Recovers from packet loss';

  @override
  String get settingsCodecsDtxSub => 'Stop sending during silence';

  @override
  String get settingsCodecsCbr => 'Constant bitrate';

  @override
  String get settingsCodecsComplexity => 'Complexity';

  @override
  String get settingsCallsIncoming => 'Incoming';

  @override
  String get settingsCallsDndSub => 'Reject all incoming calls';

  @override
  String get settingsCallsRejectWith => 'Reject with';

  @override
  String get settingsCallsReasonBusy => 'Busy Here (486)';

  @override
  String get settingsCallsReasonUnavailable => 'Temporarily Unavailable (480)';

  @override
  String get settingsCallsReasonDecline => 'Decline (603)';

  @override
  String get settingsCallsWaiting => 'Call waiting';

  @override
  String get settingsCallsWaitingSub =>
      'Allow a second incoming call during a call';

  @override
  String get settingsCallsWhenBusy => 'When busy and waiting is off';

  @override
  String get settingsCallsRejectAnonymous => 'Reject anonymous calls';

  @override
  String get settingsCallsLinksImmediately => 'Call links immediately';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'tel:, sip: and callto: links place the call without waiting in the dialer';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Sync DND / forwarding to PBX via feature codes';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Dials the account\'s star codes (for example *78) briefly when you change DND or forwarding';

  @override
  String get settingsCallsAutoAnswerGroup => 'Auto-answer';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Call forwarding and per-account auto-answer are set in each account.';

  @override
  String get settingsCallsAutoAnswerAll => 'Auto-answer all calls';

  @override
  String get settingsCallsAnswerAfter => 'Answer after';

  @override
  String get settingsCallsAnswerImmediately => 'Immediately';

  @override
  String get settingsCallsIntercomHeaders => 'Honour intercom headers';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info, Alert-Info and Answer-Mode auto-answer hints';

  @override
  String get settingsCallsBlocked => 'Blocked numbers';

  @override
  String get settingsCallsBlockNumber => 'Block a number';

  @override
  String get settingsCallsBlockNumberTitle => 'Block number';

  @override
  String get settingsCallsBlockNumberHint => 'Number or SIP address';

  @override
  String get settingsCallsSpeedDial => 'Speed dial';

  @override
  String get settingsCallsDialPlan => 'Dial plan';

  @override
  String get settingsCallsDialRules => 'Dial rules';

  @override
  String get settingsCallsStripPrefix => 'Outside-line prefix to strip';

  @override
  String get settingsCallsStripPrefixSub =>
      'For example 9, removed from the start of dialled numbers';

  @override
  String get settingsCallsPlusReplacement => 'Replace leading + with';

  @override
  String get settingsCallsPlusReplacementSub =>
      'For example 00 for international access';

  @override
  String get settingsCallsPlusReplacementHint => 'Keep +';

  @override
  String get settingsCallsCountryPrefix => 'Default country prefix';

  @override
  String get settingsCallsCountryPrefixSub =>
      'National numbers starting with 0 get this prefix, for example +44';

  @override
  String get settingsCallsEmergency => 'Emergency numbers';

  @override
  String get settingsCallsEmergencySub =>
      'Comma separated. These bypass dial rules.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Unblock $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count of 9 assigned';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'New dial rule';

  @override
  String get settingsDialRulesEdit => 'Edit dial rule';

  @override
  String get settingsDialRulesName => 'Name';

  @override
  String get settingsDialRulesPattern => 'Pattern (regex)';

  @override
  String get settingsDialRulesReplacement => 'Replacement';

  @override
  String get settingsDialRulesReplacementHelp => 'Use \$1, \$2 for groups';

  @override
  String get settingsDialRulesRoute => 'Route through account';

  @override
  String get settingsDialRulesAdd => 'Add rule';

  @override
  String get settingsDialRulesLiveTest => 'Live test';

  @override
  String get settingsDialRulesTyped => 'Typed number';

  @override
  String get settingsDialRulesNothing => '(nothing)';

  @override
  String get settingsDialRulesEmergency => 'Emergency number: dialled as typed';

  @override
  String get settingsDialRulesAccountFallback => 'account';

  @override
  String get settingsDialRulesEmpty =>
      'No rules. Numbers are cleaned (spaces, dashes, brackets removed) and dialled as typed. Rules run top to bottom; the first match wins.';

  @override
  String get settingsDialRulesDelete => 'Delete rule';

  @override
  String get settingsDialRulesDeleteTitle => 'Delete rule?';

  @override
  String settingsDialRulesVia(String account) {
    return 'via $account';
  }

  @override
  String get settingsNetworkTransports => 'Transports';

  @override
  String get settingsNetworkTransportsFooter =>
      'Port 0 picks a random free port. Changing transports restarts the call engine.';

  @override
  String get settingsNetworkUdpPort => 'UDP port';

  @override
  String get settingsNetworkTcpPort => 'TCP port';

  @override
  String get settingsNetworkTlsPort => 'TLS port';

  @override
  String get settingsNetworkVerifyCerts => 'Verify server certificates';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Turn off only for self-signed PBXs, or pin the certificate below';

  @override
  String get settingsNetworkCustomCa => 'Custom CA file';

  @override
  String get settingsNetworkCustomCaSub =>
      'PEM bundle used instead of the built-in list (private PBX CA)';

  @override
  String get settingsNetworkCustomCaHint => 'Built-in Mozilla list';

  @override
  String get settingsNetworkPins => 'Pinned certificates';

  @override
  String get settingsNetworkPinsSub =>
      'host=SHA256 fingerprint, comma separated';

  @override
  String get settingsNetworkNat => 'NAT traversal';

  @override
  String get settingsNetworkStun => 'STUN servers';

  @override
  String get settingsNetworkStunSub => 'host:port, comma separated';

  @override
  String get settingsNetworkIceTurn => 'ICE and TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Configured per account under NAT';

  @override
  String get settingsNetworkAdvanced => 'Advanced';

  @override
  String get settingsNetworkQos => 'QoS (DSCP marking)';

  @override
  String get settingsNetworkQosSub => 'Mark SIP and voice packets for priority';

  @override
  String get settingsNetworkDns => 'DNS servers';

  @override
  String get settingsNetworkDnsSub => 'Leave empty for automatic';

  @override
  String get settingsNetworkRtpStart => 'RTP port start';

  @override
  String get settingsNetworkRtpRange => 'RTP port range';

  @override
  String get settingsNetworkRtpRangeSub => '0 uses the default';

  @override
  String get settingsNotifRingtone => 'Ringtone';

  @override
  String get settingsNotifDefaultRingtone => 'Default ringtone';

  @override
  String get settingsNotifProgressTones => 'Call progress tones';

  @override
  String get settingsNotifProgressTonesSub =>
      'Ringback, busy and congestion tones while dialling';

  @override
  String get settingsNotifRingerVolume => 'Ringer volume';

  @override
  String get settingsNotifCustomRingtone => 'Custom ringtone file';

  @override
  String get settingsNotifCustomRingtoneSub => 'Path to a WAV file (desktop)';

  @override
  String get settingsNotifGroup => 'Notifications';

  @override
  String get settingsNotifRequestPermissions => 'Request permissions';

  @override
  String get settingsNotifRequestPermissionsSub =>
      'Microphone and notifications';

  @override
  String get settingsNotifTyping => 'Send typing indicators';

  @override
  String get settingsAppearanceTheme => 'Theme';

  @override
  String get settingsAppearanceLight => 'Light';

  @override
  String get settingsAppearanceDark => 'Dark';

  @override
  String get settingsAppearanceAccent => 'Accent colour';

  @override
  String get settingsAppearanceAccentOption => 'Accent colour option';

  @override
  String get settingsAppearanceCompact => 'Compact density';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microphone: $microphone, notifications: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Security';

  @override
  String get settingsPrivacyPasswords => 'Passwords';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Stored in the system keychain / keystore (encrypted file fallback)';

  @override
  String get settingsPrivacyGroup => 'Privacy';

  @override
  String get settingsPrivacyNoTelemetry => 'No telemetry';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro sends no analytics. Network traffic goes only to your SIP servers.';

  @override
  String get settingsPrivacyYourData => 'Your data';

  @override
  String get settingsPrivacyClearHistory => 'Clear call history';

  @override
  String get settingsPrivacyDeleteContacts => 'Delete all contacts';

  @override
  String get settingsPrivacyDeleteMessages => 'Delete all messages';

  @override
  String get settingsPrivacyConfirmHistory => 'Delete call history?';

  @override
  String get settingsPrivacyConfirmContacts => 'Delete all contacts?';

  @override
  String get settingsPrivacyConfirmMessages => 'Delete all messages?';

  @override
  String get settingsPrivacyCannotUndo => 'This cannot be undone.';

  @override
  String get settingsPrivacyDeletedHistory => 'Deleted call history';

  @override
  String get settingsPrivacyDeletedContacts => 'Deleted all contacts';

  @override
  String get settingsPrivacyDeletedMessages => 'Deleted all messages';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Devices on the same network find each other, pair with a 6-digit code and talk directly, without any server.';

  @override
  String get settingsLanEnable => 'Enable LAN Link';

  @override
  String get settingsLanDeviceName => 'Device name';

  @override
  String get settingsLanDeviceNameHint => 'This device';

  @override
  String get settingsLanAllowIntercom => 'Allow intercom';

  @override
  String get settingsLanAllowIntercomSub =>
      'Let paired devices call you and be auto-answered';

  @override
  String get settingsLanAskIntercom => 'Ask before allowing intercom';

  @override
  String get settingsLanAskIntercomSub =>
      'Otherwise paired devices are auto-answered for 30 s after they ask';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Auto-accept files from paired devices';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Otherwise you are asked for every file';

  @override
  String get settingsLanAllowPull => 'Let paired devices pull my calls';

  @override
  String get settingsLanAllowPullSub =>
      'A paired device can take over a call that is active here';

  @override
  String get settingsLanDownloads => 'Downloads folder';

  @override
  String get settingsLanDownloadsHint => 'Default (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'Link port';

  @override
  String get settingsLanSharedAccounts => 'Accounts shared with paired devices';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Sharing a registered account lets a paired device on the same server receive your calls directly (call transfer) instead of relaying them.';

  @override
  String get settingsAdvEngine => 'Engine';

  @override
  String get settingsAdvSimulator => 'Use simulator';

  @override
  String get settingsAdvSimulatorSub =>
      'Run without the native engine. Calls are simulated.';

  @override
  String get settingsAdvLogLevel => 'Log level';

  @override
  String get settingsAdvLogErrors => 'Errors';

  @override
  String get settingsAdvLogInfo => 'Info';

  @override
  String get settingsAdvLogDebug => 'Debug';

  @override
  String get settingsAdvLogVerbose => 'Verbose';

  @override
  String get settingsAdvSipTrace => 'SIP trace';

  @override
  String get settingsAdvRestartEngine => 'Restart engine';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Start at login';

  @override
  String get settingsAdvCloseToTray => 'Close to tray';

  @override
  String get settingsAdvCloseToTraySub =>
      'Closing the window keeps SoftphonePro running so calls can still ring. Quit from the tray / menu bar icon.';

  @override
  String get settingsAboutLicence => 'Licence';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 or later. It is distributed WITHOUT ANY WARRANTY.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 or later';

  @override
  String get settingsAboutGplSub =>
      'Source code available in the project repository';

  @override
  String get settingsAboutThirdParty => 'Third-party notices';

  @override
  String get settingsAboutPackages => 'Flutter and Dart packages';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT and Apache 2.0. See the licence page.';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String settingsAboutNotice(String license, String purpose) {
    return '$license. $purpose.';
  }

  @override
  String settingsAboutNoticeVersion(
    String license,
    String purpose,
    String version,
  ) {
    return '$license. $purpose. Version $version.';
  }

  @override
  String get updatesChecking => 'Checking...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version is available';
  }

  @override
  String get updatesUpToDate => 'You are up to date';

  @override
  String get updatesCouldNotCheck => 'Could not check';

  @override
  String get updatesNotCheckedYet => 'Not checked yet';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last checked $dateString';
  }

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesFooter =>
      'Checking contacts api.github.com only (once a week) and sends nothing but the request itself: no identifier, no account or call data. SoftphonePro never downloads or installs anything by itself.';

  @override
  String get updatesCheckSwitch => 'Check for updates';

  @override
  String get updatesCheckNow => 'Check now';

  @override
  String updatesSkippingVersion(String version) {
    return 'Skipping version $version';
  }

  @override
  String get updatesStopSkipping => 'Stop skipping';

  @override
  String get updatesReleaseNotes => 'Release notes';

  @override
  String get updatesDownload => 'Download';

  @override
  String get updatesSkipVersion => 'Skip this version';

  @override
  String get updatesDismiss => 'Dismiss';

  @override
  String get updatesRateLimited => 'GitHub rate limit reached, try again later';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub answered $status';
  }

  @override
  String get updatesUnexpectedReply => 'Unexpected reply';

  @override
  String get updatesTimedOut => 'Timed out';

  @override
  String get updatesAlreadyChecking => 'Already checking';

  @override
  String get encryptionTitle => 'Encryption';

  @override
  String get encryptionFooter =>
      'Encrypts the local database with AES-256-GCM. The key is kept in the system keychain / keystore; if it is lost the data cannot be recovered. Call recordings and exported files are not encrypted. The change takes effect the next time SoftphonePro starts (quit it completely first); the previous file is overwritten and deleted as soon as the new database has been opened and verified.';

  @override
  String get encryptionSwitchTitle =>
      'Encrypt call history, contacts and messages on this device';

  @override
  String get encryptionWillEncrypt => 'Will be encrypted at the next start';

  @override
  String get encryptionWillDecrypt => 'Will be decrypted at the next start';

  @override
  String get encryptionRestartToEncrypt =>
      'Quit and restart SoftphonePro to encrypt your data.';

  @override
  String get encryptionRestartToDecrypt =>
      'Quit and restart SoftphonePro to decrypt your data.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Speed dial $slot';
  }

  @override
  String get speedDialNumberLabel => 'Number or SIP address';

  @override
  String get speedDialLabelOptional => 'Label (optional)';

  @override
  String get speedDialCallFrom => 'Call from';

  @override
  String get speedDialSelectedAccount => 'Selected account';

  @override
  String get speedDialTitle => 'Speed dial';

  @override
  String get speedDialHint =>
      'Long-press a digit (1-9) on the empty keypad to call its number.';

  @override
  String get speedDialNotAssigned => 'Not assigned';

  @override
  String provisioningNotValidJson(String detail) {
    return 'Not valid JSON: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Expected a JSON object';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Unsupported config version $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Skipped a non-object account entry';

  @override
  String get provisioningNothingToImport =>
      'The file contains no accounts or settings';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'Account \"$name\" needs username and domain';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Server answered $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Could not download the configuration: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Could not read $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count accounts',
      one: 'Imported 1 account',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Import configuration';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts accounts',
      one: '1 account',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings settings',
      one: '1 setting',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Import from URL or JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... or paste JSON';

  @override
  String get provisioningInvalidSource =>
      'That is not a valid URL, link or JSON';

  @override
  String get provisioningScanTitle => 'Scan provisioning QR';

  @override
  String get provisioningPasteHint => 'Paste JSON, a link or a URL';

  @override
  String get provisioningImportGroup => 'Import';

  @override
  String get provisioningImportFooter =>
      'Supports JSON with accounts and settings. \${VAR} placeholders are filled with empty values unless a default is given as \${VAR:-default}.';

  @override
  String get provisioningScanQr => 'Scan QR code';

  @override
  String get provisioningFromUrl => 'From URL or pasted JSON';

  @override
  String get provisioningFromFile => 'From file';

  @override
  String get provisioningFromClipboard => 'From clipboard';

  @override
  String get provisioningExportGroup => 'Export';

  @override
  String get provisioningIncludePasswords => 'Include passwords';

  @override
  String get provisioningIncludePasswordsHint =>
      'Anyone with the file can use your accounts';

  @override
  String get provisioningCopyConfig => 'Copy configuration (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuration copied';

  @override
  String get provisioningQrGroup => 'QR code';

  @override
  String get provisioningQrFooter =>
      'Scan this code on another device to copy an account. Treat it like a password if it includes one.';

  @override
  String get provisioningQrAccount => 'Account';

  @override
  String get provisioningChoose => 'Choose...';

  @override
  String get provisioningQrTooMuchData => 'Too much data for a QR code';

  @override
  String tlsClearField(String field) {
    return 'Clear $field';
  }

  @override
  String get tlsChoose => 'Choose...';

  @override
  String get tlsChange => 'Change...';

  @override
  String get tlsClientCertTitle => 'Client certificate (mutual TLS)';

  @override
  String get tlsIncomplete =>
      'Choose both a certificate and its private key. The certificate is only presented once both are set.';

  @override
  String get tlsFooter =>
      'For servers that ask the app to identify itself with a certificate. PEM files. Used for TLS and secure WebSocket.';

  @override
  String get tlsCertFile => 'Certificate file';

  @override
  String get tlsKeyFile => 'Private key file';

  @override
  String get tlsKeyPassword => 'Key password';

  @override
  String get tlsKeyPasswordHint => 'Only if the key is encrypted';

  @override
  String get callSettingsHoldGroupTitle => 'Hold';

  @override
  String get callSettingsHoldFooter =>
      'With \"PBX default\" the call is simply put on hold and your phone system may play its own music. Any other choice is played to the caller by this app.';

  @override
  String get callSettingsHoldMusic => 'Hold music';

  @override
  String get callSettingsHoldPbxDefault => 'PBX default';

  @override
  String get callSettingsHoldMusicVolume => 'Hold music volume';

  @override
  String get callSettingsHoldAudioFiles => 'Audio files';

  @override
  String get callSettingsHoldAudioFilesHint => 'Import or record hold music';

  @override
  String get callSettingsAnnounceTitle => 'Announcements';

  @override
  String get callSettingsAnnounceFooter =>
      'Announcements are played to the other party. Everything is skipped silently if the file is missing.';

  @override
  String get callSettingsAnnounceOpening => 'Opening announcement';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Play a message when a call connects';

  @override
  String get callSettingsAnnounceFile => 'Announcement file';

  @override
  String get callSettingsAnnounceChooseFile => 'Choose a file';

  @override
  String get callSettingsAnnouncePlayFor => 'Play for';

  @override
  String get callSettingsAnnounceBoth => 'Incoming and outgoing';

  @override
  String get callSettingsAnnounceIncoming => 'Incoming calls';

  @override
  String get callSettingsAnnounceOutgoing => 'Outgoing calls';

  @override
  String get callSettingsAnnounceMuteMic => 'Mute my microphone while it plays';

  @override
  String get callSettingsAnnounceMonitor => 'Also let me hear it';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Before recording starts, play';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Before transferring a caller, play';

  @override
  String get morePageTitle => 'More';

  @override
  String get morePresence => 'Presence';

  @override
  String get morePresenceHint => 'Busy lamp field';

  @override
  String get moreRetrieveParked => 'Retrieve parked call';

  @override
  String get moreRetrieveParkedHint => 'Dial a park slot';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Nearby devices, chat and file drop';

  @override
  String get moreRecordings => 'Recordings';

  @override
  String get moreRecordingsHint =>
      'Listen to, share and manage call recordings';

  @override
  String get moreVoicemail => 'Voicemail';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Dial your voicemail';

  @override
  String get moreDiagnostics => 'Diagnostics';

  @override
  String get moreDiagnosticsHint => 'SIP trace and network checks';

  @override
  String get moreAbout => 'About';

  @override
  String get moreNoVoicemailNumber =>
      'No voicemail number is set. Add one in the account settings.';

  @override
  String get moreSearchHint => 'Search contacts, history or type a number';

  @override
  String moreCallNumber(String number) {
    return 'Call $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'App lock';

  @override
  String get appLockFooter =>
      'Calls still ring and can be answered while the app is locked.';

  @override
  String get appLockRequirePin => 'Require PIN to open the app';

  @override
  String get appLockOnHint =>
      'History, contacts, messages and settings are locked';

  @override
  String get appLockIsOn => 'App lock is on';

  @override
  String get appLockIsOff => 'App lock is off';

  @override
  String get appLockTurnOff => 'Turn off app lock';

  @override
  String get appLockChangePin => 'Change PIN';

  @override
  String get appLockEnterCurrent => 'Enter current PIN';

  @override
  String get appLockPinChanged => 'PIN changed';

  @override
  String get appLockLockAfter => 'Lock after';

  @override
  String get appLockLockAfterHint =>
      'Time in the background before the PIN is needed again';

  @override
  String get appLockImmediately => 'Immediately';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 hour';

  @override
  String get appLockBiometrics => 'Unlock with biometrics';

  @override
  String get appLockNow => 'Lock now';

  @override
  String get appLockSetPin => 'Set a PIN';

  @override
  String get appLockPinDigits => 'PIN (4-8 digits)';

  @override
  String get appLockRepeatPin => 'Repeat PIN';

  @override
  String get appLockUseDigits => 'Use 4 to 8 digits';

  @override
  String get appLockMismatch => 'PINs do not match';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s';
  }

  @override
  String get appLockWrongPin => 'Wrong PIN';

  @override
  String get appLockTooMany => 'Too many attempts';

  @override
  String get appLockIsLocked => 'SoftphonePro is locked';

  @override
  String get appLockEnterPin => 'Enter your PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Try again in $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '${seconds}s';
  }

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockIncomingCall => 'Incoming call';

  @override
  String get appLockDecline => 'Decline';

  @override
  String get appLockAnswer => 'Answer';

  @override
  String get appLockHangUp => 'Hang up';

  @override
  String get appLockBiometricReason => 'Unlock SoftphonePro';

  @override
  String get automationNoToken =>
      'No access token set. Generate one in Settings > Advanced.';

  @override
  String automationInvalidPort(int port) {
    return 'Invalid port $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Could not start: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'Port $port is not available ($error). Choose another port.';
  }

  @override
  String get automationTokenPlaceholder => 'Created when you turn the API on';

  @override
  String automationListening(String address) {
    return 'Listening on $address';
  }

  @override
  String get automationStarting => 'Starting...';

  @override
  String get automationTitle => 'Local automation API';

  @override
  String get automationFooter =>
      'For CRM and helpdesk integrations on this computer. It listens on 127.0.0.1 only and every request needs the access token. See docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Enable local automation API';

  @override
  String get automationPort => 'Port';

  @override
  String get automationPortHint =>
      'Default 7771. Choose a free port between 1024 and 65535.';

  @override
  String get automationPortInvalid => 'Enter a port from 1024 to 65535';

  @override
  String get automationAccessToken => 'Access token';

  @override
  String get automationHideToken => 'Hide token';

  @override
  String get automationShowToken => 'Show token';

  @override
  String get automationCopyToken => 'Copy token';

  @override
  String get automationTokenCopied => 'Token copied';

  @override
  String get automationGenerateToken => 'Generate a new token';

  @override
  String get automationGenerateTitle => 'Generate a new token?';

  @override
  String get automationGenerateBody =>
      'Programs using the old token stop working until you give them the new one.';

  @override
  String get automationGenerate => 'Generate';

  @override
  String get automationOrigins => 'Allowed browser origins';

  @override
  String get automationOriginsHint =>
      'Comma separated, for example https://crm.example.com. Programs without a browser (curl, scripts) do not need this.';

  @override
  String automationNotOrigin(String origin) {
    return 'Not an http(s) origin: $origin';
  }

  @override
  String get trayNotificationAnswer => 'Answer';

  @override
  String get trayNotificationDecline => 'Decline';

  @override
  String get trayTooltipInCall => 'SoftphonePro - in a call';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count new';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - no accounts (Away)',
      'dnd': 'SoftphonePro - no accounts (Do not disturb)',
      'other': 'SoftphonePro - no accounts',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Away)',
      'dnd': 'SoftphonePro - $online/$total online (Do not disturb)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Hide SoftphonePro';

  @override
  String get trayShowApp => 'Show SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count new - open Recents';
  }

  @override
  String get trayStatus => 'Status';

  @override
  String get trayStatusAway => 'Away';

  @override
  String get trayAccounts => 'Accounts';

  @override
  String get trayQuit => 'Quit SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Answer call';

  @override
  String get hotkeyHangUp => 'Hang up';

  @override
  String get hotkeyMute => 'Mute / unmute';

  @override
  String get hotkeyFocusDialer => 'Focus dialer';

  @override
  String get shortcutsGlobalTitle => 'Global hotkeys';

  @override
  String get shortcutsGlobalFooter =>
      'Work from any application. Another program that already uses a combination may prevent it from registering.';

  @override
  String get shortcutsChange => 'Change';

  @override
  String get shortcutsRestoreDefaults => 'Restore defaults';

  @override
  String get shortcutsMediaTitle => 'Headset and media keys';

  @override
  String get shortcutsMediaFooter =>
      'The play/pause button of a headset or keyboard is claimed only while a call is ringing or active, so music players keep it the rest of the time.';

  @override
  String get shortcutsMediaSwitch =>
      'Answer and hang up with the headset/media play-pause button';

  @override
  String get shortcutsMediaDuringCall => 'During a call the button';

  @override
  String get shortcutsMediaHangsUp => 'Hangs up';

  @override
  String get shortcutsMediaMutes => 'Mutes / unmutes';

  @override
  String get shortcutsInApp => 'In the app';

  @override
  String get shortcutsFocusDialer => 'Focus the dialer';

  @override
  String get shortcutsHoldResume => 'Hold / resume';

  @override
  String get shortcutsTransfer => 'Transfer';

  @override
  String get shortcutsEndCall => 'End call';

  @override
  String get shortcutsNeedX11 =>
      'Global shortcuts need an X11 session. Wayland does not allow apps to grab keys system-wide.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Add Ctrl, Alt, Shift or $key to a letter or digit';
  }

  @override
  String get shortcutsPressNew => 'Press the new key combination';

  @override
  String get defaultHandlerChooseInSettings =>
      'Choose SoftphonePro for SIP, TEL and CALLTO in Default apps';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro now opens sip:, tel: and callto: links';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Could not change the default for $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Opens sip:, tel: and callto: links from browsers and other apps';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro handles sip:, tel: and callto: links';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Now: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Make SoftphonePro the default app for sip:, tel: and callto: links';

  @override
  String get reliabilityTitle => 'Background reliability';

  @override
  String get reliabilityMicrophone => 'Microphone';

  @override
  String get reliabilityAllowed => 'Allowed';

  @override
  String get reliabilityMicNeeded => 'Needed to talk in calls';

  @override
  String get reliabilityNotifications => 'Notifications';

  @override
  String get reliabilityNotifNeeded =>
      'Needed to show incoming calls and keep the service visible';

  @override
  String get reliabilityFullScreen => 'Full-screen incoming calls';

  @override
  String get reliabilityFullScreenNeeded =>
      'Allow so calls appear over the lock screen';

  @override
  String get reliabilityBattery => 'Unrestricted battery use';

  @override
  String get reliabilityBatteryExempt => 'Exempt from battery optimisation';

  @override
  String get reliabilityBatteryNeeded =>
      'Android may suspend the app and miss calls to save power. Tap to exempt SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer autostart / protected apps';
  }

  @override
  String get reliabilityAutostartHint =>
      'Your phone vendor may kill background apps. Allow SoftphonePro to auto-start.';

  @override
  String get reliabilityBoot => 'Start at boot';

  @override
  String get reliabilityBootHint =>
      'Register accounts after the phone restarts';

  @override
  String get reliabilityWake => 'Keep CPU awake while idle';

  @override
  String get reliabilityWakeHint =>
      'More reliable on strict devices; uses more battery';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Remove $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Last error: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Allowed range $min to $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Must be at least $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Must be at most $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Discard changes?';

  @override
  String get acctEditorDiscardMessage =>
      'Your edits to this account are not saved.';

  @override
  String get acctEditorDiscardConfirm => 'Discard';

  @override
  String get acctEditorDeleteMessage =>
      'The account and its saved password will be removed from this device.';

  @override
  String get acctEditorMenuDelete => 'Delete account';

  @override
  String get acctGroupBasic => 'Basic';

  @override
  String get acctFieldLabel => 'Label';

  @override
  String get acctFieldLabelHint => 'e.g. Office';

  @override
  String get acctFieldDisplayName => 'Display name';

  @override
  String get acctFieldUsername => 'Username';

  @override
  String get acctFieldProtocol => 'Protocol';

  @override
  String get acctFieldProtocolSub => 'Fixed when the account is created';

  @override
  String get acctFieldAuthUser => 'Authorization user';

  @override
  String get acctFieldAuthUserHint => 'Same as username';

  @override
  String get acctFieldAuthUserSub =>
      'Only if the provider uses a different login name than the username';

  @override
  String get acctFieldPassword => 'Password';

  @override
  String get acctFieldServerHost => 'Server host';

  @override
  String get acctFieldPort => 'Port';

  @override
  String get acctFieldIaxPortSub => 'IAX2 default is 4569';

  @override
  String get acctFieldIaxContext => 'Context';

  @override
  String get acctFieldIaxContextSub =>
      'Optional. Sent to the PBX as the called context';

  @override
  String get acctFieldServerDomain => 'Server / domain';

  @override
  String get acctFieldServerDomainSub => 'host or host:port';

  @override
  String get acctFieldEnabled => 'Enabled';

  @override
  String get acctFieldDefault => 'Default account for outgoing calls';

  @override
  String get acctFieldColour => 'Colour';

  @override
  String get acctGroupRegistration => 'Registration';

  @override
  String get acctFieldRegister => 'Register';

  @override
  String get acctFieldRegisterSubIax =>
      'Turn off for peers that need no registration';

  @override
  String get acctFieldRegExpiry => 'Registration expiry (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk usually forces 60 s. Range 10 to 86400';

  @override
  String get acctFieldRetryInterval => 'Retry interval (s)';

  @override
  String get acctFieldFirstRetry => 'First retry (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 supports G.711 and GSM. Drag to set the preference order.';

  @override
  String get acctCodecAdd => 'Add codec';

  @override
  String get acctGroupServerTransport => 'Server and transport';

  @override
  String get acctFieldRegistrar => 'Registrar override';

  @override
  String get acctFieldBackupRegistrar => 'Backup registrar';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Used after 3 failed attempts; the primary is retried every 5 minutes';

  @override
  String get acctFieldProxies => 'Outbound proxies';

  @override
  String get acctFieldTransport => 'Transport';

  @override
  String get acctFieldTransportAutoSub =>
      'Looks up the server\'s DNS SRV records and picks TLS, TCP or UDP';

  @override
  String get acctTransportAuto => 'Automatic (DNS SRV)';

  @override
  String get acctFieldWsPath => 'WebSocket path';

  @override
  String get acctFieldWsPathSub =>
      'HTTP path of the WebSocket upgrade, e.g. /ws. Must start with \"/\"';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 to 3600 is typical. Range 10 to 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'UDP keep-alive interval. 0 turns it off. Range 0 to 3600';

  @override
  String get acctFieldLocalPort => 'Local SIP port';

  @override
  String get acctFieldLocalPortSub =>
      '0 uses the shared transport. Range 0 to 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Turn off for trunks without registration';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Keeps a persistent flow through NAT. Needs server support';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Use STUN';

  @override
  String get acctFieldTurn => 'TURN relay';

  @override
  String get acctFieldTurnServer => 'TURN server';

  @override
  String get acctFieldTurnUsername => 'TURN username';

  @override
  String get acctFieldTurnPassword => 'TURN password';

  @override
  String get acctFieldContactRewrite => 'Rewrite Contact header';

  @override
  String get acctFieldViaRewrite => 'Rewrite Via header';

  @override
  String get acctFieldRewriteSub =>
      'Use the address the server sees. Keep on behind NAT';

  @override
  String get acctFieldSdpRewrite => 'Rewrite SDP address';

  @override
  String get acctFieldSdpRewriteSub =>
      'Replace the media address in SDP with the public one';

  @override
  String get acctFieldIpv6Sip => 'IPv6 signalling';

  @override
  String get acctFieldIpv6Media => 'IPv6 media';

  @override
  String get acctGroupAdvancedMedia => 'Advanced media';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTC gateways need RTCP multiplexing and RTCP feedback.';

  @override
  String get acctFieldRtcpMux => 'RTCP multiplexing';

  @override
  String get acctFieldRtcpMuxSub => 'Send RTP and RTCP on one port (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'RTCP feedback (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Offer RTP/AVPF with NACK. Needed for WebRTC servers';

  @override
  String get acctGroupSecurity => 'Security';

  @override
  String get acctFieldSrtp => 'Media encryption (SRTP)';

  @override
  String get acctOptOptional => 'Optional';

  @override
  String get acctOptRequired => 'Required';

  @override
  String get acctFieldKeyExchange => 'Key exchange';

  @override
  String get acctFieldSecureSignaling => 'Secure signalling';

  @override
  String get acctOptNotRequired => 'Not required';

  @override
  String get acctOptTlsHop => 'TLS hop-by-hop';

  @override
  String get acctOptTlsE2e => 'TLS end-to-end (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Auth algorithm';

  @override
  String get acctFieldPrivacy => 'Hide caller ID (privacy)';

  @override
  String get acctFieldReferPolicy => 'Incoming transfers (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Presence watchers';

  @override
  String get acctOptAccept => 'Accept';

  @override
  String get acctOptReject => 'Reject';

  @override
  String get acctGroupCodecsFooter =>
      'Overrides the global codec list for this account.';

  @override
  String get acctFieldUseGlobalCodecs => 'Use global codec order';

  @override
  String get acctGroupFeatures => 'Features';

  @override
  String get acctFieldVoicemailNumber => 'Voicemail number';

  @override
  String get acctFieldMwi => 'Voicemail indicator (MWI)';

  @override
  String get acctFieldMwiSub => 'Subscribe to message-waiting notifications';

  @override
  String get acctFieldPublishPresence => 'Publish my presence';

  @override
  String get acctFieldPublishPresenceSub =>
      'Let the server share your online status';

  @override
  String get acctFieldDnd => 'Do not disturb';

  @override
  String get acctFieldForwarding => 'Call forwarding';

  @override
  String get acctOptForwardAlways => 'Always';

  @override
  String get acctOptForwardBusy => 'When busy';

  @override
  String get acctOptForwardNoAnswer => 'No answer';

  @override
  String get acctFieldForwardTo => 'Forward to';

  @override
  String get acctFieldForwardToHint => 'Number or SIP address';

  @override
  String get acctFieldRingFor => 'Ring for (s)';

  @override
  String get acctFieldAutoAnswer => 'Auto-answer';

  @override
  String get acctFieldAnswerAfter => 'Answer after (s)';

  @override
  String get acctFieldIntercomOnly => 'Only for intercom calls';

  @override
  String get acctFieldIntercomOnlySub =>
      'Needs an auto-answer header from the PBX';

  @override
  String get acctFieldRingtone => 'Ringtone';

  @override
  String get acctRingtoneClassic => 'Classic';

  @override
  String get acctRingtoneSoft => 'Soft';

  @override
  String get acctRingtoneDigital => 'Digital';

  @override
  String get acctFieldRecordCalls => 'Record calls';

  @override
  String get acctFieldHoldMusic => 'Hold music';

  @override
  String get acctOptUseGlobal => 'Use global setting';

  @override
  String get acctOptPbxDefault => 'PBX default';

  @override
  String get acctFieldOpeningAnnouncement => 'Opening announcement';

  @override
  String get acctGroupFeatureCodes => 'Feature codes';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Dialled for park, pickup, DND and forwarding on your PBX.';

  @override
  String get acctFieldPark => 'Park';

  @override
  String get acctFieldGroupPickup => 'Group pickup';

  @override
  String get acctFieldDirectedPickup => 'Directed pickup prefix';

  @override
  String get acctFieldParkRetrieve => 'Park retrieve prefix';

  @override
  String get acctFieldParkRetrieveHint => 'Dial the slot number';

  @override
  String get acctFieldParkRetrieveSub =>
      'Prefix dialled before the park slot to pick a parked call back up';

  @override
  String get acctFieldDndOn => 'DND on';

  @override
  String get acctFieldDndOff => 'DND off';

  @override
  String get acctFieldForwardOn => 'Forward on';

  @override
  String get acctFieldForwardOff => 'Forward off';

  @override
  String get acctGroupAdvanced => 'Advanced';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF is sent as native IAX2 frames.';

  @override
  String get acctFieldCallerIdOverride => 'Caller ID override';

  @override
  String get acctFieldCallerIdHint => 'Use account default';

  @override
  String get acctFieldCallerIdSub => 'Caller ID name or number sent to the PBX';

  @override
  String get acctFieldSessionTimers => 'Session timers';

  @override
  String get acctFieldSessionExpires => 'Session expires (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Range 90 to 86400';

  @override
  String get acctField100rel => '100rel (reliable provisional)';

  @override
  String get acctFieldHoldMethod => 'Hold method';

  @override
  String get acctFieldDtmfMethod => 'DTMF method';

  @override
  String get acctOptDtmfInband => 'In-band';

  @override
  String get acctFieldRedirects => 'Redirects (3xx)';

  @override
  String get acctOptRedirectFollow => 'Follow';

  @override
  String get acctOptRedirectAsk => 'Ask';

  @override
  String get acctFieldLockCodec => 'Lock codec after answer';

  @override
  String get acctFieldMediaKeepAlive => 'Media keep-alive';

  @override
  String get acctFieldDropCalls => 'Drop calls when registration fails';

  @override
  String get acctFieldExtraHeaders => 'Extra SIP headers';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: value (one per line)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Wait before retrying a failed registration. Range 0 to 86400';

  @override
  String get acctFieldUnregTimeout => 'Unregister timeout (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'How long to wait for the unregister reply. Range 0 to 60000';

  @override
  String get acctFieldMwiExpiry => 'MWI subscription expiry (s)';

  @override
  String get acctFieldDscpSip => 'DSCP for SIP';

  @override
  String get acctFieldDscpSipSub =>
      'QoS marking of signalling. 24 (CS3) is typical';

  @override
  String get acctFieldDscpRtp => 'DSCP for RTP';

  @override
  String get acctFieldDscpRtpSub => 'QoS marking of media. 46 (EF) is typical';

  @override
  String get acctFieldReinvite => 'Re-INVITE after network change';

  @override
  String get acctFieldHangupOnIpChange => 'Hang up calls on network change';

  @override
  String get acctValidateInt => 'Enter a whole number';

  @override
  String get acctValidateHostEmpty => 'Enter a server host name or address';

  @override
  String get acctValidateHostSpaces => 'The server cannot contain spaces';

  @override
  String get acctValidateHostFormat => 'Enter only host or host:port';

  @override
  String get acctValidatePortRange => 'Port must be between 1 and 65535';

  @override
  String get acctValidateWsStart => 'The path must start with \"/\"';

  @override
  String get acctValidateWsLength => 'Use at most 120 characters';

  @override
  String get acctValidateWsSpaces => 'The path cannot contain spaces';

  @override
  String get acctTplAsteriskDescription =>
      'Extension on your own PBX. UDP 5060, STUN on.';

  @override
  String get acctTplAsteriskNotes =>
      'Use the PJSIP/SIP extension number and its secret. For TLS or WebRTC change the transport later in the account settings.';

  @override
  String get acctTplAsteriskUsernameHint => 'Extension (e.g. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Use the extension, auth ID and password from the 3CX portal.';

  @override
  String get acctTpl3cxNotes =>
      'In 3CX open the extension, then \"Phones > Provisioning\" for the Authentication ID (set it as Authorization user) and password. The FQDN is the one in your 3CX URL.';

  @override
  String get acctTpl3cxUsernameHint => 'Extension';

  @override
  String get acctTplFreeswitchDescription =>
      'Directory user on a FreeSWITCH server.';

  @override
  String get acctTplFreeswitchNotes =>
      'Use the user id and password from the directory. The default internal profile listens on UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'User ID';

  @override
  String get acctTplKamailioDescription =>
      'SIP proxy registrar. TCP recommended behind NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Use the SIP domain served by your registrar. Add an outbound proxy in the account settings if the registrar is reached through a different host.';

  @override
  String get acctTplTwilioDescription =>
      'Programmable Voice SIP Domain credentials. TLS and SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Create a SIP Domain in the Twilio console, add a Credential List and enable SIP Registration. Enter the full domain (name.sip.twilio.com) as the server and the credential list user and password. TLS uses port 5061. Twilio supports G.711 only.';

  @override
  String get acctTplTwilioUsernameHint => 'Credential list username';

  @override
  String get acctTplTelnyxDescription =>
      'Credential connection. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Create a Credential Connection in the Telnyx portal and copy its SIP username and password (not your portal login). Assign a number or outbound voice profile to the connection to place and receive calls.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP username (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Sub-account username and password. Pick the POP closest to you.';

  @override
  String get acctTplVoipmsNotes =>
      'Use a sub-account created under Sub Accounts, not your main account. Choose the server (POP) closest to you from the VoIP.ms server list and allow it for your IP if required.';

  @override
  String get acctTplVoipmsUsernameHint => 'Sub-account (e.g. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'SIP registration with TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business only offers SIP registration on some plans. Enter the SIP server, user and password shown in the Vonage admin portal for the device.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange over UDP 4569. No NAT or SRTP settings.';

  @override
  String get acctTplIax2Notes =>
      'Needs a peer/user in iax.conf (type=friend or user+peer) with the same secret. Asterisk renews IAX2 registrations every 60 s by default. The context is optional and is sent as the called context.';

  @override
  String get acctTplIax2UsernameHint => 'IAX2 username';

  @override
  String get acctTplWebrtcDescription =>
      'SIP over secure WebSocket with DTLS-SRTP, ICE and RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'For Asterisk (webrtc=yes, http.conf TLS on 8089), FreeSWITCH or Kamailio WebSocket endpoints. The server needs a valid TLS certificate. Change the WebSocket path in the account settings if your gateway does not use /ws.';

  @override
  String get acctTplGenericDescription =>
      'Any SIP registrar. Fill in the details yourself.';

  @override
  String get acctTplDefaultUsernameHint => 'Extension / username';

  @override
  String get appEngineFailedBody =>
      'Calls and registration will not work until this is fixed. A bad network or certificate setting is the usual cause.';

  @override
  String get appEngineFailedTitle => 'Couldn\'t start the calling engine';

  @override
  String get appEngineNotRunning => 'The calling engine is not running';

  @override
  String get appUnknownError => 'Unknown error';

  @override
  String get appEngineOpenNetworkSettings => 'Open network settings';

  @override
  String get appEngineUseSimulator => 'Use simulator (demo)';

  @override
  String get appDbLockedTitle => 'Your data is locked';

  @override
  String get appDbUnreadableTitle => 'Your data cannot be opened';

  @override
  String get appDbLockedBody =>
      'Call history, contacts and messages are encrypted on this device, but the encryption key is no longer in the system keychain / keystore (for example after a keychain reset or a restore to a new device).';

  @override
  String get appDbUnreadableBody =>
      'The local database could not be read. It may be damaged, or the encryption key does not match.';

  @override
  String get appDbRecoveryAdvice =>
      'Try again if you expect the key to come back (unlock the keychain, sign in to the right user). Starting fresh keeps the old file next to the app data but begins with an empty history, contacts and messages; you will need to add your accounts again.';

  @override
  String get appDbCopyDetails => 'Copy details';

  @override
  String get appDbTryAgain => 'Try again';

  @override
  String get appDbStartFresh => 'Start fresh';

  @override
  String get appRedirectTitle => 'Call redirected';

  @override
  String appRedirectMessage(String target) {
    return 'Call redirected to $target - follow?';
  }

  @override
  String get appRedirectCancelCall => 'Cancel call';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': 'Could not encrypt your data ($error). Nothing was changed.',
      'other': 'Could not decrypt your data ($error). Nothing was changed.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Native engine not available ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Retrying at $time';
  }

  @override
  String get acctRegistrationError => 'Registration error';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nTransport: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Calling from direct, no account';

  @override
  String acctCallingFromAccount(String name) {
    return 'Calling from $name';
  }

  @override
  String get acctCallingFromNone => 'Calling from no account';

  @override
  String get acctNoAccount => 'No account';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount new, $oldCount old';
  }

  @override
  String get acctAddAccount => 'Add account';

  @override
  String get acctUnregister => 'Unregister';

  @override
  String get acctSheetDndSub => 'Reject incoming calls on this account';

  @override
  String get acctKvServer => 'Server';

  @override
  String get acctKvResolvedServer => 'Resolved server';

  @override
  String get acctKvClientCert => 'Client cert';

  @override
  String get acctKvClientCertValue => 'Presented to the server (mutual TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Expires in';

  @override
  String get acctKvVoicemail => 'Voicemail';

  @override
  String get acctOpenSipTrace => 'Open SIP trace';

  @override
  String get acctAddAnAccount => 'Add an account';

  @override
  String get acctChooseAccountTooltip => 'Choose the account to call from';

  @override
  String get acctDirectNoAccount => 'Direct (no account)';

  @override
  String get onboardingRequired => 'Username and server are required';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Port $port is used unless you add :port';
  }

  @override
  String get onboardingFineTuneIax =>
      'You can fine-tune codecs and registration later in Settings.';

  @override
  String get onboardingFineTuneSip =>
      'You can fine-tune transport, NAT, security and codecs later in Settings.';

  @override
  String get onboardingDemoUser => 'Demo user';

  @override
  String get onboardingDemoAccount => 'Demo account';

  @override
  String get onboardingWelcomeTitle => 'Welcome to SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Professional calling for every platform - free and open source. No ads, no tracking.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingPermissionsTitle => 'Permissions';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro needs the microphone to carry your voice, and notifications to tell you about incoming calls and messages. Nothing leaves your device except your calls.';

  @override
  String get onboardingChooseProvider => 'Choose your provider';

  @override
  String get onboardingChooseProviderSub =>
      'We prefill transport, ports and NAT settings for you.';

  @override
  String get onboardingScanQr => 'Scan QR';

  @override
  String get onboardingImportUrl => 'Import from URL';

  @override
  String get onboardingSkip => 'Skip for now (demo mode)';

  @override
  String get onboardingHidePassword => 'Hide password';

  @override
  String get onboardingShowPassword => 'Show password';

  @override
  String get onboardingContextOptional => 'Context (optional)';

  @override
  String get onboardingDisplayNameOptional => 'Display name (optional)';

  @override
  String get onboardingLabelOptional => 'Account label (optional)';

  @override
  String get onboardingCallerIdOptional => 'Caller ID (optional)';

  @override
  String get onboardingAuthUserOptional => 'Authorization user (if different)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Wrong username or password ($code)';
  }

  @override
  String get acctRegNotFound => 'Account not found on the server (404)';

  @override
  String get acctRegNoAnswer => 'Server did not answer (408)';

  @override
  String get acctRegIntervalTooShort => 'Registration interval too short (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Server temporarily unavailable (480)';

  @override
  String get acctRegServiceUnavailable => 'Service unavailable (503)';

  @override
  String get acctRegFailed => 'Registration failed';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Registration failed ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'Could not change registration';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Could not apply account \"$name\"';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Back on the primary server for $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Using backup server for $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'Account $name is registered';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'Account $name is still registering';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'Account $name is not registered yet';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'Account $name is not registered (registration failed)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'Account $name is disabled';
  }

  @override
  String get callDialEngineFailed => 'The call engine failed to start';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'The call engine failed to start: $reason';
  }

  @override
  String get callDialEngineStarting => 'The call engine is still starting';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status after $seconds s; the call was not placed';
  }

  @override
  String get callJournalInterrupted => 'The app was closed during the call';

  @override
  String get callLinkMissingArgument => 'Missing argument';

  @override
  String get callLinkHttpsRequired => 'Configuration links must use https';

  @override
  String get callLinkInvalidLan => 'That LAN link is not valid';

  @override
  String callLinkConnectedTo(String name) {
    return 'Connected to $name';
  }

  @override
  String get callLinkConnectFailed => 'Could not connect to that device';

  @override
  String callLinkCallFailed(String target) {
    return 'Could not place the call to $target';
  }

  @override
  String get callLinkImportTitle => 'Import configuration';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts accounts',
      one: '1 account',
    );
    return 'Import configuration from $host? It will add $_temp0.';
  }

  @override
  String callLinkImportBodyWithSettings(
    String host,
    int accounts,
    int settings,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts accounts',
      one: '1 account',
    );
    return 'Import configuration from $host? It will add $_temp0 and $settings setting(s).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Forwarded from $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Forwarded from $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Transferred by $number';
  }

  @override
  String get callRingtoneSystemDefault => 'System default';

  @override
  String get callRingtoneClassic => 'Classic';

  @override
  String get callRingtoneSoft => 'Soft';

  @override
  String get callRingtoneDigital => 'Digital';

  @override
  String callIdentityFrom(String number) {
    return 'From $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Caller ID $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Caller ID $name $number';
  }

  @override
  String get callTransferring => 'Transferring...';

  @override
  String get callTransferNotConfirmed => 'Transfer not confirmed by the server';

  @override
  String get callTransferStalledHint =>
      'The call is still up. Keep it, or send the transfer again.';

  @override
  String get callTransferKeepCall => 'Keep call';

  @override
  String get callAnnouncementOpening => 'Playing announcement…';

  @override
  String get callAnnouncementTransfer => 'Playing transfer notice…';

  @override
  String get callAnnouncementRecording => 'Playing recording notice…';

  @override
  String get callAnnouncementSkip => 'Skip';

  @override
  String get callNoiseTooltipMic => 'AI noise cancellation: your microphone';

  @override
  String get callNoiseTooltipIncoming =>
      'AI noise cancellation: other participants';

  @override
  String get callNoiseTooltipBoth =>
      'AI noise cancellation: your microphone and other participants';

  @override
  String get callNoiseOn => 'Noise cancellation on';

  @override
  String get callNoiseTitle => 'Noise cancellation';

  @override
  String callNoiseMicStrength(String strength) {
    return 'My microphone: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Remove background noise from my microphone';

  @override
  String get callResultAnswered => 'Answered';

  @override
  String get callResultMissed => 'Missed';

  @override
  String get callResultRejected => 'Declined';

  @override
  String get callResultFailed => 'Failed';

  @override
  String get callResultBusy => 'Busy';

  @override
  String get callResultForwarded => 'Forwarded';

  @override
  String get callResultTransferred => 'Transferred';

  @override
  String get callResultHandedOff => 'Handed off';

  @override
  String get callResultInterrupted => 'Interrupted';

  @override
  String get keypadCall => 'Call';

  @override
  String get keypadNoVoicemail =>
      'No voicemail number configured for this account';

  @override
  String get keypadCallDirectly => 'Call directly (no account)';

  @override
  String get keypadAddAccount => 'Add an account to place calls';

  @override
  String keypadCallFrom(String account) {
    return 'Call from $account';
  }

  @override
  String get keypadRecent => 'Recent';

  @override
  String get keypadSuggestions => 'Suggestions';

  @override
  String get keypadPhoneNumber => 'Phone number';

  @override
  String get keypadPaste => 'Paste';

  @override
  String get keypadEnterNumber => 'Enter number';

  @override
  String get keypadBackspace => 'Backspace (long press to clear)';

  @override
  String get keypadTypeNameOrNumber => 'Type a name or number';

  @override
  String get keypadNoMatches => 'No matches';

  @override
  String get keypadSuggestionsHint =>
      'Suggestions come from contacts and recent calls';

  @override
  String keypadCallPerson(String name) {
    return 'Call $name';
  }

  @override
  String get dialKeyStar => 'Star';

  @override
  String get dialKeyPound => 'Pound';

  @override
  String get dialKeyLongPressPlus => 'Long press for plus';

  @override
  String get dialKeyLongPressSpeedDial => 'Long press for speed dial';

  @override
  String get dialKeyLongPressVoicemail => 'Long press for voicemail';

  @override
  String get callBackToApp => 'Back to app (call stays active)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Hide keypad';

  @override
  String get callMute => 'Mute';

  @override
  String get callKeypad => 'Keypad';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Headset';

  @override
  String get callResume => 'Resume';

  @override
  String get callHold => 'Hold';

  @override
  String get callAddCall => 'Add call';

  @override
  String get callTransfer => 'Transfer';

  @override
  String get callStop => 'Stop';

  @override
  String get callRecord => 'Record';

  @override
  String get callSplit => 'Split';

  @override
  String get callMerge => 'Merge';

  @override
  String get callSwap => 'Swap';

  @override
  String get callEndCall => 'End call';

  @override
  String callEndCallWith(String name) {
    return 'End call with $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Attended transfer. The original caller is on hold.';

  @override
  String get callCompleteTransfer => 'Complete transfer';

  @override
  String get callWaiting => 'Call waiting';

  @override
  String get callHoldAndAnswer => 'Hold current call and answer';

  @override
  String get callDecline => 'Decline';

  @override
  String get callAnswer => 'Answer';

  @override
  String get callIncomingCall => 'Incoming call';

  @override
  String get callReply => 'Reply';

  @override
  String get callVoicemail => 'Voicemail';

  @override
  String get callToDevice => 'To device';

  @override
  String get callQuickReplyBusy => 'Can\'t talk now, I\'ll call you back.';

  @override
  String get callQuickReplyMeeting => 'I\'m in a meeting. Text me?';

  @override
  String get callQuickReplyOnMyWay => 'On my way.';

  @override
  String callReturnToCallWith(String name) {
    return 'Return to call with $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Incoming: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'In call with $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Packet loss';

  @override
  String get callStatsRoundTrip => 'Round trip';

  @override
  String get callStatsMedia => 'Media';

  @override
  String get callStatsMosHistory => 'MOS history';

  @override
  String get callQualityTitle => 'Call quality';

  @override
  String get callTransferTitle => 'Transfer call';

  @override
  String get callTransferModeBlind => 'Blind';

  @override
  String get callTransferModeAttended => 'Attended';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN device';

  @override
  String get callTransferNoLanDevices =>
      'No paired SoftphonePro devices found on your network. Pair one on the LAN page.';

  @override
  String get callTransferLanDisabled =>
      'Turn on LAN Link (Settings, LAN Link) to hand this call to another device on your network.';

  @override
  String get callTransferTalkFirst => 'Talk first';

  @override
  String get callTransferBlindHint =>
      'Hands the caller over immediately. You are disconnected.';

  @override
  String get callTransferAttendedHint =>
      'Puts the caller on hold and calls the target first. Complete the transfer once they answer.';

  @override
  String get callTransferNumberLabel => 'Number or SIP address';

  @override
  String get callTransferNow => 'Transfer now';

  @override
  String get callTransferCallAndConsult => 'Call and consult';

  @override
  String get callRetrieveParkedTitle => 'Retrieve parked call';

  @override
  String get callRetrieveParkedHint => 'Park slot, e.g. 701';

  @override
  String get callMoreAudioOutput => 'Audio output';

  @override
  String get callMoreAudioDevices => 'Audio devices';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Phone, speaker, Bluetooth, headset';

  @override
  String get callMoreAudioDevicesSubtitle => 'Choose microphone and speaker';

  @override
  String get callMoreParkCall => 'Park call';

  @override
  String get callMoreParkCallSubtitle => 'Transfer to the park feature code';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Dial a park slot';

  @override
  String get callMoreSendDtmf => 'Send DTMF digits';

  @override
  String get callMoreSendDtmfSubtitle => 'Type a whole sequence, e.g. a PIN';

  @override
  String get callSendDtmfTitle => 'Send DTMF';

  @override
  String get callMoreCallInfo => 'Call info';

  @override
  String get callMoreQualitySubtitle =>
      'Live MOS, jitter, loss and round-trip time';

  @override
  String get callMoreSipTrace => 'SIP trace';

  @override
  String get callMoreSipTraceSubtitle => 'Ladder diagram of this call';

  @override
  String get callInfoRemote => 'Remote';

  @override
  String get callInfoAccount => 'Account';

  @override
  String get callInfoState => 'State';

  @override
  String get callInfoSecure => 'Secure';

  @override
  String get callInfoPlainSignalling => 'plain signalling';

  @override
  String get callRoutePhone => 'Phone';

  @override
  String get callRouteWiredHeadset => 'Wired headset';

  @override
  String get callAudioMicrophone => 'Microphone';

  @override
  String callCardSemantics(String name, String state) {
    return 'Call with $name, $state';
  }

  @override
  String get callUnmute => 'Unmute';

  @override
  String get callStopRecording => 'Stop recording';

  @override
  String get callSplitConference => 'Split conference';

  @override
  String get callMergeCalls => 'Merge calls';

  @override
  String get callSwapCalls => 'Swap calls';

  @override
  String get callAttendedTransferBanner =>
      'Attended transfer: the original caller is on hold.';

  @override
  String get callActiveCalls => 'Active calls';

  @override
  String get callConferenceLevels => 'Conference levels';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Mic to party';

  @override
  String callPercentSemantics(int percent) {
    return '$percent percent';
  }

  @override
  String get callFailInvalidNumber => 'Invalid number (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Call not authorised ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Number not found (404)';

  @override
  String get callFailNoAnswerFromServer => 'No answer from server (408)';

  @override
  String get callFailTemporarilyUnavailable => 'Temporarily unavailable (480)';

  @override
  String get callFailIncompleteNumber => 'Incomplete number (484)';

  @override
  String callFailBusy(String code) {
    return 'Busy ($code)';
  }

  @override
  String get callFailCancelled => 'Call cancelled (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'No compatible codec ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Service unavailable (503)';

  @override
  String get callFailDeclined => 'Call declined (603)';

  @override
  String get callFailGeneric => 'Call failed';

  @override
  String callFailGenericWithCode(String code) {
    return 'Call failed ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Call in progress';

  @override
  String get callTrayInCall => 'In a call';

  @override
  String get callHistoryBlocked => 'Blocked';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonymity disallowed';

  @override
  String get callHistoryDoNotDisturb => 'Do not disturb';

  @override
  String get callHistoryBusy => 'Busy';

  @override
  String get callHistoryForwardedAlways => 'Forwarded (always)';

  @override
  String get callHistoryForwardedBusy => 'Forwarded (busy)';

  @override
  String get callHistorySentToVoicemail => 'Sent to voicemail';

  @override
  String get callHistoryRedirected => 'Redirected';

  @override
  String get callIncomingNotificationBody => 'Incoming call';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Incoming call on $account';
  }

  @override
  String get callMissedNotificationTitle => 'Missed call';

  @override
  String get callErrEngineNotRunning => 'The call engine is not running yet';

  @override
  String get callErrAddAccount => 'Add an account to place calls';

  @override
  String get callErrCouldNotPlace => 'Could not place the call';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account is not registered';
  }

  @override
  String get callErrCouldNotAnswer => 'Could not answer';

  @override
  String get callErrNoVoicemailNumber =>
      'No voicemail number set for this account';

  @override
  String get callErrTransferFailed => 'Transfer failed';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Transfer failed: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Could not merge calls';

  @override
  String get callErrCouldNotStartRecording => 'Could not start recording';

  @override
  String get callErrCouldNotStopRecording => 'Could not stop recording';

  @override
  String callParkingNotice(String code) {
    return 'Parking call (dial $code)';
  }

  @override
  String get callErrParkFailed => 'Park failed';

  @override
  String get callErrHandoffFailed => 'Hand-off failed';

  @override
  String get callErrCouldNotSendToDevice => 'Could not send to device';

  @override
  String get callHistoryForwardedNoAnswer => 'Forwarded (no answer)';

  @override
  String get shellTabKeypad => 'Keypad';

  @override
  String get shellTabRecents => 'Recents';

  @override
  String get shellTabContacts => 'Contacts';

  @override
  String get shellTabMessages => 'Messages';

  @override
  String get shellTabPresence => 'Presence';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Recordings';

  @override
  String get shellSearchSemantics =>
      'Search contacts, history or dial a number';

  @override
  String get shellSearchHint => 'Search or dial';

  @override
  String get shellVoicemailTooltip => 'Voicemail';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new voicemails. Click to call voicemail',
      one: '1 new voicemail. Click to call voicemail',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Away';

  @override
  String get shellStatusTooltip => 'Your status';

  @override
  String get shellDemoBanner =>
      'Demo mode: calls are simulated, nothing reaches a real network.';

  @override
  String get uiToday => 'Today';

  @override
  String get uiYesterday => 'Yesterday';

  @override
  String get uiUnknownCaller => 'Unknown caller';

  @override
  String get uiCallEnded => 'Call ended';

  @override
  String get uiCallTransferNotConfirmed => 'Transfer not confirmed';

  @override
  String get uiCallTransferring => 'Transferring...';

  @override
  String get uiCallConference => 'Conference';

  @override
  String get uiCallOnHold => 'On hold';

  @override
  String get uiCallHeldByRemote => 'Held by remote';

  @override
  String get uiCallCalling => 'Calling...';

  @override
  String get uiCallRinging => 'Ringing...';

  @override
  String get uiCallConnecting => 'Connecting...';

  @override
  String get uiCallIncoming => 'Incoming call';

  @override
  String get uiCallConnected => 'Connected';

  @override
  String get uiQrScanTitle => 'Scan QR code';

  @override
  String get uiQrPasteHint => 'Paste the code text';

  @override
  String get uiQrNoCamera =>
      'Camera scanning is not available on this device. Paste the code text instead.';

  @override
  String get uiQrPaste => 'Paste';

  @override
  String get uiQrUse => 'Use';

  @override
  String get uiQrCameraDenied =>
      'Camera access is off. Allow it in system settings, or paste the code text below.';

  @override
  String get uiQrCameraUnavailable =>
      'The camera is not available. Paste the code text below.';

  @override
  String get presenceLampRinging => 'Ringing';

  @override
  String get presenceHeader => 'Busy lamp field';

  @override
  String get presenceChooseTooltip => 'Choose contacts to watch';

  @override
  String get presenceEmptyTitle => 'No extensions on the board';

  @override
  String get presenceEmptySubtitle =>
      'Turn on \"Show on BLF board\" for a contact to see when they are free, ringing or busy.';

  @override
  String get presenceOpenContacts => 'Open contacts';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Tap to call, long press for more';
  }

  @override
  String presenceCallName(String name) {
    return 'Call $name';
  }

  @override
  String get presencePickup => 'Pick up this extension';

  @override
  String get presencePickupSub => 'Answer their ringing call (directed pickup)';

  @override
  String get presenceTransferHere => 'Transfer current call here';

  @override
  String get presenceRemove => 'Remove from board';

  @override
  String get uiCall => 'Call';

  @override
  String get uiMessage => 'Message';

  @override
  String get recentsSearchTooltip => 'Search history';

  @override
  String get recentsClearTitle => 'Clear call history?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count entries will be deleted.',
      one: '1 entry will be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => 'History copied to clipboard as CSV';

  @override
  String get recentsMenuCopyCsv => 'Copy as CSV';

  @override
  String get recentsMenuClear => 'Clear history';

  @override
  String get recentsSearchHint => 'Search name or number';

  @override
  String get recentsFilterAll => 'All';

  @override
  String get recentsFilterMissed => 'Missed';

  @override
  String get recentsFilterIncoming => 'Incoming';

  @override
  String get recentsFilterOutgoing => 'Outgoing';

  @override
  String get recentsFilterAccount => 'Filter by account';

  @override
  String get recentsAllAccounts => 'All accounts';

  @override
  String get recentsAccountFallback => 'Account';

  @override
  String get recentsEmptyNone => 'No calls yet';

  @override
  String get recentsEmptyNoMatch => 'No matching calls';

  @override
  String get recentsEmptyNoneSub => 'Your calls will show up here.';

  @override
  String get recentsEmptyNoMatchSub => 'Try another filter.';

  @override
  String get recentsOpenKeypad => 'Open keypad';

  @override
  String get recentsShowAll => 'Show all';

  @override
  String get recentsSelectCall => 'Select a call';

  @override
  String get recentsSelectCallSub =>
      'Details, quality and recordings appear here.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Missed call',
      'incoming': 'Incoming call',
      'other': 'Outgoing call',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Call $name';
  }

  @override
  String get recentsAddAccountToMessage => 'Add an account to send messages';

  @override
  String get recentsAddContact => 'Add contact';

  @override
  String get recentsContact => 'Contact';

  @override
  String get recentsBlock => 'Block';

  @override
  String get recentsUnblock => 'Unblock';

  @override
  String recentsBlockTitle(String number) {
    return 'Block $number?';
  }

  @override
  String get recentsBlockMessage =>
      'Calls from this number will be rejected automatically.';

  @override
  String get recentsQualityHeader => 'Call quality';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Worst MOS $mos   ·   Jitter $jitter ms   ·   Loss $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Recordings';

  @override
  String get recentsOpenInRecordings => 'Open in Recordings';

  @override
  String recentsRelatedCall(String title) {
    return 'Related call: $title';
  }

  @override
  String get recentsHistoryHeader => 'History';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'No calls with this number';

  @override
  String get recentsDeleteTitle => 'Delete these calls?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removes $count entries for $name.',
      one: 'Removes 1 entry for $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Delete from history';

  @override
  String get recentsCallDetails => 'Call details';

  @override
  String get contactsFavoritesHeader => '★ Favorites';

  @override
  String get contactsFavoritesOnly => 'Favorites only';

  @override
  String get contactsShowAll => 'Show all';

  @override
  String get contactsImportExportTooltip => 'Import and export';

  @override
  String get contactsMenuDevice => 'Import from device';

  @override
  String get contactsMenuFile => 'Import vCard / CSV file';

  @override
  String get contactsMenuClipboard => 'Import from clipboard';

  @override
  String get contactsMenuCopyVcard => 'Copy as vCard';

  @override
  String get contactsMenuCopyCsv => 'Copy as CSV';

  @override
  String get contactsNewTooltip => 'New contact';

  @override
  String get contactsSearchHint => 'Search contacts';

  @override
  String get contactsEmptyTitle => 'No contacts yet';

  @override
  String get contactsEmptySubtitle =>
      'Add people you call often, or import a vCard or CSV file.';

  @override
  String get contactsEmptyAction => 'Add a contact';

  @override
  String get contactsNoMatches => 'No matches';

  @override
  String contactsCallName(String name) {
    return 'Call $name';
  }

  @override
  String get contactsSelect => 'Select a contact';

  @override
  String get contactsCopiedVcard => 'Contacts copied as vCard';

  @override
  String get contactsCopiedCsv => 'Contacts copied as CSV';

  @override
  String get contactsDeviceDenied =>
      'Contacts access was denied. Allow it in system settings to import.';

  @override
  String get contactsDeviceNone => 'No contacts found on this device';

  @override
  String contactsNothingNew(int count) {
    return 'Nothing new to import ($count already present)';
  }

  @override
  String get contactsImportDeviceTitle => 'Import from device?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new contacts',
      one: '1 new contact',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count updated with extra numbers';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count skipped (duplicates or no phone number)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count contacts',
      one: 'Imported 1 contact',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'No contacts found in that data';

  @override
  String get contactsLabelMobile => 'mobile';

  @override
  String get contactsLabelWork => 'work';

  @override
  String get contactsLabelHome => 'home';

  @override
  String get contactsLabelOther => 'other';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contact not found';

  @override
  String get contactsActionFavorite => 'Favorite';

  @override
  String get contactsNumbersHeader => 'Numbers';

  @override
  String get contactsSipAddress => 'SIP address';

  @override
  String get contactsDetailsHeader => 'Details';

  @override
  String get contactsOnBlf => 'Shown on the BLF board';

  @override
  String get contactsAlwaysRecorded => 'Calls are always recorded';

  @override
  String contactsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get contactsDeleteMessage =>
      'This contact will be removed from this device.';

  @override
  String get contactsDeleteButton => 'Delete contact';

  @override
  String get contactsDetailTitle => 'Contact';

  @override
  String get contactsErrorNameOrNumber => 'Enter a name or a number';

  @override
  String get contactsEditTitle => 'Edit contact';

  @override
  String get contactsFieldName => 'Name';

  @override
  String get contactsFieldCompany => 'Company';

  @override
  String get contactsFieldNumber => 'Number';

  @override
  String get contactsRemoveNumber => 'Remove number';

  @override
  String get contactsAddNumber => 'Add number';

  @override
  String get contactsSipHeader => 'SIP addresses';

  @override
  String get contactsRemoveAddress => 'Remove address';

  @override
  String get contactsAddSip => 'Add SIP address';

  @override
  String get contactsFieldEmail => 'Email';

  @override
  String get contactsFieldNotes => 'Notes';

  @override
  String get contactsFieldFavorite => 'Favorite';

  @override
  String get contactsShowOnBlf => 'Show on BLF board';

  @override
  String get contactsShowOnBlfSub =>
      'Watch this extension\'s presence and busy lamp';

  @override
  String get contactsAlwaysRecordTitle =>
      'Always record calls with this contact';

  @override
  String get contactsAlwaysRecordSub =>
      'Overrides the automatic recording rules';

  @override
  String get contactsRingtone => 'Ringtone';

  @override
  String get contactsPresenceVia => 'Presence via account';

  @override
  String get contactsDefaultAccount => 'Default account';

  @override
  String get contactsDeleteContactTitle => 'Delete contact?';

  @override
  String get contactsCannotUndo => 'This cannot be undone.';

  @override
  String get messagesNewMessage => 'New message';

  @override
  String get messagesNumberOrSip => 'Number or SIP address';

  @override
  String get messagesNoConversations => 'No conversations';

  @override
  String get messagesEmptySubtitle =>
      'Send a SIP message to any extension or address on your accounts.';

  @override
  String get messagesTyping => 'typing...';

  @override
  String get messagesYouPrefix => 'You: ';

  @override
  String get messagesSelect => 'Select a conversation';

  @override
  String get messagesLanOnline => 'Online on your network';

  @override
  String get messagesLanOffline =>
      'Offline. Messages are sent when it is back.';

  @override
  String messagesSendFileTo(String name) {
    return 'Send a file to $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Call $name';
  }

  @override
  String get messagesDeleteTitle => 'Delete conversation?';

  @override
  String messagesDeleteMessage(String name) {
    return 'All messages with $name will be removed.';
  }

  @override
  String get messagesDeleteMenu => 'Delete conversation';

  @override
  String get messagesSayHello => 'Say hello';

  @override
  String get messagesLanEmptySub =>
      'Messages go straight to this device over your network, end-to-end encrypted.';

  @override
  String get messagesSipEmptySub =>
      'Messages are sent with SIP MESSAGE through your account.';

  @override
  String get messagesInputHint => 'Message';

  @override
  String get messagesSend => 'Send';

  @override
  String get messagesStatusSending => 'Sending';

  @override
  String get messagesStatusSent => 'Sent';

  @override
  String get messagesStatusDelivered => 'Delivered';

  @override
  String get messagesStatusRead => 'Read';

  @override
  String get messagesStatusFailed => 'Failed';

  @override
  String get messagesNotDelivered => 'Not delivered. Tap to retry';

  @override
  String get uiStatusRegistered => 'Registered';

  @override
  String get uiStatusRegistering => 'Registering';

  @override
  String get uiStatusRegFailed => 'Registration failed';

  @override
  String get uiStatusDisabled => 'Disabled';

  @override
  String get uiQualityMeasuring => 'Measuring';

  @override
  String get uiQualityExcellent => 'Excellent';

  @override
  String get uiQualityGood => 'Good';

  @override
  String get uiQualityFair => 'Fair';

  @override
  String get uiQualityPoor => 'Poor';

  @override
  String get uiQualityBad => 'Bad';

  @override
  String uiQualitySemantics(String label) {
    return 'Call quality $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Call quality $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Call quality: $label';
  }

  @override
  String get uiSecureFull => 'Encrypted';

  @override
  String get uiSecureMedia => 'Media encrypted';

  @override
  String get uiSecureSignalling => 'Signalling encrypted';

  @override
  String get uiSecureNone => 'Not encrypted';

  @override
  String get uiSecureSrtpLine => 'SRTP media';

  @override
  String get uiSecureTlsLine => 'TLS signalling';

  @override
  String lanCallHandingOver(String name) {
    return 'Handing over to $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Intercom to $name';
  }

  @override
  String get lanCallIntercomToUnnamed => 'Intercom to a nearby device';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Intercom from $name';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'Intercom from a nearby device';

  @override
  String lanCallToNamed(String name) {
    return 'LAN call to $name';
  }

  @override
  String get lanCallToUnpaired => 'LAN call to an unpaired device';

  @override
  String lanCallFromNamed(String name) {
    return 'LAN call from $name';
  }

  @override
  String get lanCallFromUnpaired => 'LAN call from an unpaired device';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Transferred call from $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Transferred call from $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'another device';

  @override
  String lanRelayedTitle(String name) {
    return 'Relayed to $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'The caller is talking to $name. You are not on the call.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Calling $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'The caller stays connected while $name answers.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Asking $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Waiting for them to accept the call.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Talking to $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'The caller is on hold. Complete the hand-off when ready.';

  @override
  String get lanRelayTakingBack => 'Taking the call back...';

  @override
  String get lanRelayTakeBack => 'Take back';

  @override
  String get lanRelayEnd => 'End';

  @override
  String get lanSendToDevice => 'Send to device';

  @override
  String get lanBusy => 'Busy';

  @override
  String get lanNoPairedOnline => 'No paired device is online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name rejected the pairing.';
  }

  @override
  String get lanPairRejected => 'Pairing rejected.';

  @override
  String get lanPairCancelled => 'Pairing cancelled.';

  @override
  String get lanPairTimedOut => 'Pairing timed out. Try again.';

  @override
  String get lanPairFailed => 'Pairing failed';

  @override
  String lanPairFailedReason(String reason) {
    return 'Pairing failed: $reason';
  }

  @override
  String get lanPairThisDevice => 'this device';

  @override
  String get lanPairConnecting => 'Connecting securely...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name wants to pair with this device.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Pairing with $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Check that this code is the same on both screens.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Pairing code $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Waiting for $name to confirm...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name has confirmed.';
  }

  @override
  String get lanPairReject => 'Reject';

  @override
  String get lanPairCodesMatch => 'Codes match';

  @override
  String lanPairPairedWith(String name) {
    return 'Paired with $name.';
  }

  @override
  String get lanPairRequestTitle => 'Pairing request';

  @override
  String lanPairTitle(String name) {
    return 'Pair with $name';
  }

  @override
  String get lanActionDecline => 'Decline';

  @override
  String get lanActionAccept => 'Accept';

  @override
  String get lanFileIncomingTitle => 'Incoming file';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size from $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Transfer a call here?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' from $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' on $account',
    });
    return '$device wants to hand you a call$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'They will talk to you first.';

  @override
  String get lanHandoffTakeCall => 'Take call';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Allow intercom from $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Their call will be answered automatically on speaker.';

  @override
  String get lanIntercomDeny => 'Deny';

  @override
  String get lanIntercomAllow => 'Allow';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name removed this device from its paired list';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sending $count files...',
      one: 'Sending $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'New message';

  @override
  String get lanSipMessage => 'SIP message';

  @override
  String get lanSipMessageSub => 'To a number or address through your account';

  @override
  String get lanChatOnline => 'LAN chat, online';

  @override
  String get lanChatOffline => 'LAN chat, offline';

  @override
  String lanSavedAt(String path) {
    return 'Saved at $path (path copied)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Your devices, talking directly';

  @override
  String get lanConnectByAddress => 'Connect by address';

  @override
  String get lanSettingsTooltip => 'LAN settings';

  @override
  String get lanOffTitle => 'LAN Link is off';

  @override
  String get lanOffSubtitle =>
      'Find your other SoftphonePro devices, chat, drop files and hand calls over, without any server.';

  @override
  String get lanTurnOn => 'Turn on LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link could not start: $error';
  }

  @override
  String get lanConnectHelp =>
      'Type host:port, or paste the text of the QR code shown on the other device.';

  @override
  String get lanScanTitle => 'Scan LAN pairing QR';

  @override
  String get lanScanQr => 'Scan QR';

  @override
  String get lanPaste => 'Paste';

  @override
  String get lanConnect => 'Connect';

  @override
  String lanConnectedTo(String name) {
    return 'Connected to $name';
  }

  @override
  String get lanCouldNotConnect => 'Could not connect';

  @override
  String get lanCouldNotStartPairing => 'Could not start pairing';

  @override
  String get lanThisDevice => 'This device';

  @override
  String get lanDeviceNameTitle => 'Device name';

  @override
  String get lanStarting => 'Starting...';

  @override
  String get lanVisible => 'Visible on your network';

  @override
  String get lanNotRunning => 'Not running';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts shared',
      one: '1 account shared',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Fingerprint';

  @override
  String get lanHideQr => 'Hide QR code';

  @override
  String get lanShowQr => 'Show QR code to connect another device';

  @override
  String get lanCopyConnectionText => 'Copy connection text';

  @override
  String get lanConnectionTextCopied => 'Connection text copied';

  @override
  String get lanActiveOnOthers => 'Active on your other devices';

  @override
  String get lanPairedDevices => 'Paired devices';

  @override
  String get lanNoPaired =>
      'No paired devices yet. Pair a nearby device to chat, send files and hand calls over.';

  @override
  String get lanNearby => 'Nearby';

  @override
  String get lanNearbyHint =>
      'Looking for SoftphonePro on your network. Other devices need LAN Link turned on. You can also connect by address with the link button above.';

  @override
  String get lanTransfers => 'Transfers';

  @override
  String get lanFiles => 'Files';

  @override
  String get lanPairedBadge => 'Paired';

  @override
  String get lanTyping => 'typing...';

  @override
  String get lanPair => 'Pair';

  @override
  String get lanUnpair => 'Unpair';

  @override
  String lanUnpairTitle(String name) {
    return 'Unpair $name?';
  }

  @override
  String get lanUnpairMessage =>
      'You will have to pair again to chat, send files or hand over calls.';

  @override
  String get lanActionMessage => 'Message';

  @override
  String get lanActionSendFile => 'Send file';

  @override
  String get lanActionCall => 'Call';

  @override
  String get lanActionIntercom => 'Intercom';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Active on $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Active on $device  ·  $account';
  }

  @override
  String get lanPull => 'Pull';

  @override
  String get lanTransferPreparing => 'Preparing...';

  @override
  String get lanTransferWaitingYou => 'Waiting for you';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Waiting for $name to accept';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String get lanTransferVerifying => 'Verifying...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'From $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'To $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  from $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  to $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get lanFileActions => 'File actions';

  @override
  String get lanPathCopied => 'Path copied';

  @override
  String get lanFileOpen => 'Open';

  @override
  String get lanFileShowInFolder => 'Show in folder';

  @override
  String get lanFileCopyPath => 'Copy path';

  @override
  String lanNetworkError(String message) {
    return 'Network error: $message';
  }

  @override
  String get lanErrNotRunning => 'Turn on LAN Link first';

  @override
  String get lanErrBadAddress =>
      'Enter an address like 192.168.1.20:4711 or paste the QR code text';

  @override
  String get lanErrFingerprint =>
      'That device does not match the scanned code. Did the QR code come from another device?';

  @override
  String lanNoticeReceived(String file, String name) {
    return 'Received $file from $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return 'Sent $file to $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name declined $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'File transfer failed: $error';
  }

  @override
  String get lanNoticeNeedLanOn => 'Turn on LAN Link to call nearby devices';

  @override
  String get lanNoticePairFirst => 'Pair with this device first';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name is not reachable for calls right now';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Asking $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name did not allow intercom (or did not answer)';
  }

  @override
  String get lanHoOff => 'LAN Link is turned off';

  @override
  String get lanHoPairFirst => 'Pair with that device first';

  @override
  String lanHoOffline(String name) {
    return '$name is offline';
  }

  @override
  String get lanHoAlready => 'This call is already being handed off';

  @override
  String get lanHoEnded => 'The call has already ended';

  @override
  String get lanHoWaitConnected => 'Wait until the call is connected';

  @override
  String get lanHoLanCall => 'LAN calls cannot be handed off';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name cannot take calls over the network (LAN calling is off there)';
  }

  @override
  String get lanHoNoLanHere => 'LAN calling is not available on this device';

  @override
  String lanHoDeclined(String name) {
    return '$name declined the call. It stays with you.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name did not respond. The call stays with you.';
  }

  @override
  String get lanHoCancelled =>
      'The hand-off was cancelled. The call stays with you.';

  @override
  String lanHoUnreachable(String name) {
    return 'Could not reach $name. The call stays with you.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Could not reach $name ($reason). The call stays with you.';
  }

  @override
  String get lanHoEndedBefore => 'The call ended before it could be handed off';

  @override
  String lanHoPbxRefused(String name) {
    return 'The phone system refused the transfer and $name cannot take LAN calls';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Transfer through the phone system failed. Relaying over the network instead.';

  @override
  String lanHoSentTo(String name) {
    return 'Call sent to $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Could not call the other device through the phone system';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name is no longer reachable';
  }

  @override
  String get lanHoCouldNotAnswer => 'Could not answer the call to hand it over';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Could not call $name over the network. The call stays with you.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name did not answer. The call stays with you.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Handed off to $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Call relayed to $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Wait for $name to answer first';
  }

  @override
  String get lanHoFailed => 'Hand-off failed';

  @override
  String lanHoTakenBack(String name) {
    return 'Call taken back from $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name ended the consultation. The call is back with you.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Could not hand the call to $name';
  }

  @override
  String get diagSip400Explain =>
      'The server could not understand the request.';

  @override
  String get diagSip400Fix =>
      'Check the account settings (domain, username, proxy). If it persists, send a SIP trace to your provider.';

  @override
  String get diagSip401Explain =>
      'The server rejected the credentials (or is asking for them).';

  @override
  String get diagSip401Fix =>
      'Check the username, authentication username and password. Some providers use a separate \"auth ID\".';

  @override
  String get diagSip403Explain =>
      'The server understood the request but refuses it: wrong password, account disabled, or your IP is not allowed.';

  @override
  String get diagSip403Fix =>
      'Re-enter the password, check the account is active, and confirm your public IP is not blocked (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'The server does not know this user or number.';

  @override
  String get diagSip404Fix =>
      'Check the username and domain; for calls, check the dialled number and dial rules.';

  @override
  String get diagSip405Explain => 'The server does not support this request.';

  @override
  String get diagSip405Fix =>
      'Usually harmless for OPTIONS pings. For REGISTER, check you are talking to a SIP registrar.';

  @override
  String get diagSip407Explain => 'The outbound proxy needs credentials.';

  @override
  String get diagSip407Fix =>
      'Check the account password and outbound proxy settings.';

  @override
  String get diagSip408Explain => 'No answer from the server in time.';

  @override
  String get diagSip408Fix =>
      'Check the server address and port, firewalls, and try TCP or TLS. Repeated timeouts on UDP only can point to SIP ALG on the router.';

  @override
  String get diagSip410Explain => 'The number no longer exists.';

  @override
  String get diagSip410Fix => 'Check the dialled number.';

  @override
  String get diagSip415Explain =>
      'The other side does not accept the content type or codecs offered.';

  @override
  String get diagSip415Fix =>
      'Enable more codecs (e.g. PCMU/PCMA) in Settings > Codecs.';

  @override
  String get diagSip421Explain =>
      'The server requires a SIP extension this client did not offer.';

  @override
  String get diagSip421Fix =>
      'Check the account NAT/ICE/100rel/timers options.';

  @override
  String get diagSip423Explain =>
      'The registration expiry is shorter than the server allows.';

  @override
  String get diagSip423Fix =>
      'Increase the registration expiry in the account settings.';

  @override
  String get diagSip480Explain =>
      'The user is not registered or cannot be reached right now.';

  @override
  String get diagSip480Fix =>
      'Check the other party is registered; on registration, the server may be overloaded: retry later.';

  @override
  String get diagSip481Explain =>
      'The server lost the dialog state (e.g. after a restart or network change).';

  @override
  String get diagSip481Fix =>
      'Hang up and retry. If frequent, enable session timers.';

  @override
  String get diagSip483Explain => 'The request circled between servers.';

  @override
  String get diagSip483Fix =>
      'Check forwarding and routing configuration on the PBX.';

  @override
  String get diagSip484Explain => 'The dialled number is too short.';

  @override
  String get diagSip484Fix => 'Dial the full number or check dial rules.';

  @override
  String get diagSip486Explain => 'The other party is busy.';

  @override
  String get diagSip486Fix => 'Try again later.';

  @override
  String get diagSip487Explain =>
      'The call was cancelled before it was answered.';

  @override
  String get diagSip487Fix => 'Normal when the caller hangs up while it rings.';

  @override
  String get diagSip488Explain =>
      'No common codec or encryption setting with the other side.';

  @override
  String get diagSip488Fix =>
      'Check codecs and SRTP (a mandatory-SRTP account cannot call a plain-RTP endpoint).';

  @override
  String get diagSip491Explain => 'Two re-INVITEs collided.';

  @override
  String get diagSip491Fix => 'Normally retried automatically.';

  @override
  String get diagSip500Explain => 'The server failed internally.';

  @override
  String get diagSip500Fix =>
      'Retry later and contact the provider if it continues.';

  @override
  String get diagSip502Explain =>
      'An upstream server returned an invalid answer.';

  @override
  String get diagSip502Fix =>
      'Retry later; contact the provider if it continues.';

  @override
  String get diagSip503Explain =>
      'The server is overloaded, down, or rejecting this client (rate limit).';

  @override
  String get diagSip503Fix =>
      'Wait and retry, check the provider status page, or try another server/port.';

  @override
  String get diagSip504Explain => 'An upstream server did not answer in time.';

  @override
  String get diagSip504Fix => 'Retry later.';

  @override
  String get diagSip600Explain => 'All destinations are busy.';

  @override
  String get diagSip600Fix => 'Try again later.';

  @override
  String get diagSip603Explain => 'The other party rejected the call.';

  @override
  String get diagSip603Fix => 'Nothing to fix: the call was declined.';

  @override
  String get diagSip604Explain => 'The number does not exist.';

  @override
  String get diagSip604Fix => 'Check the dialled number.';

  @override
  String get diagSip606Explain =>
      'The other party cannot accept the session as offered.';

  @override
  String get diagSip606Fix => 'Check codecs and encryption settings.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provisional ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'The request is being processed.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Success ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'The request succeeded.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Redirected ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'The destination moved.';

  @override
  String get diagSipRedirectedFix => 'Check forwarding settings.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Client error ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'The server rejected the request.';

  @override
  String get diagSipClientErrorFix => 'Check the account and dialled number.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Server error ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'The server failed to process the request.';

  @override
  String get diagSipServerErrorFix => 'Retry later or contact the provider.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Global failure ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'The request cannot be fulfilled anywhere.';

  @override
  String get diagSipNoResponseTitle => 'No response';

  @override
  String get diagSipNoResponseExplain => 'No SIP response was received.';

  @override
  String get diagSipNoResponseFix =>
      'Check the network connection and server address.';

  @override
  String get diagWizStepNet => 'Network connectivity';

  @override
  String diagWizStepDns(String account) {
    return 'DNS and SRV: $account';
  }

  @override
  String get diagWizStepNat => 'NAT type';

  @override
  String diagWizStepOptions(String account) {
    return 'Server reachability: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS certificate: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registration: $account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALG check';

  @override
  String get diagWizChecking => 'Checking...';

  @override
  String diagWizEngineError(String message) {
    return 'Engine error: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Check failed: $error';
  }

  @override
  String get diagWizNoEngine => 'The SIP engine is not running';

  @override
  String get diagWizNoEngineFix =>
      'Wait for the engine to start (or restart the app), then run the checks again.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (private)';
  }

  @override
  String get diagWizNetNone => 'No active network interface with an IP address';

  @override
  String get diagWizNetNoneFix =>
      'Connect to Wi-Fi, Ethernet or mobile data, then run the checks again.';

  @override
  String get diagWizNetIpv6Only => 'Only IPv6 addresses found';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Many SIP providers are IPv4 only. Enable IPv4 on this network or use a provider with IPv6 support.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 IPv4 addresses',
      one: '1 IPv4 address',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interface',
    );
    return '$_temp0 on $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'A VPN-style interface is active. VPNs can add latency or block UDP; disable it if calls misbehave.';

  @override
  String get diagWizDnsNoServer => 'The account has no server address';

  @override
  String get diagWizDnsNoServerFix =>
      'Edit the account and enter the SIP domain.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host is an IP address, no DNS needed';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: none';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: none ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: none';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (priority $priority, weight $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: lookup failed ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host does not resolve';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Check the domain for typos, and that your DNS server works. You can set a custom DNS server in Settings > Network (e.g. 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host has SRV records but no address record';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'SRV targets will be used. If calls fail, ask the provider to check the A record.';

  @override
  String diagWizDnsResolves(String host, String address, int more, int srv) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: ' (+$more)',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      srv,
      locale: localeName,
      other: ', $srv SRV records',
      one: ', 1 SRV record',
      zero: '',
    );
    return '$host resolves to $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'NAT detection timed out';

  @override
  String get diagWizNatTimeoutFix =>
      'The STUN server may be unreachable (UDP blocked?). Check Settings > Network > STUN servers.';

  @override
  String diagWizNatStun(String server) {
    return 'STUN server: $server';
  }

  @override
  String get diagWizNatOpen => 'No NAT: this device has a public address';

  @override
  String get diagWizNatFullCone => 'Full cone NAT: friendly to VoIP';

  @override
  String get diagWizNatRestricted =>
      'Restricted cone NAT: works with STUN and keep-alives';

  @override
  String get diagWizNatPortRestricted =>
      'Port-restricted cone NAT: works with STUN and keep-alives';

  @override
  String get diagWizNatSymmetric =>
      'Symmetric NAT: STUN alone cannot predict the media port';

  @override
  String get diagWizNatSymmetricFix =>
      'One-way audio or no audio is likely on some calls. Enable ICE and a TURN relay in the account settings (Account > NAT), or use a provider/PBX with media relay (rtpengine).';

  @override
  String get diagWizNatBlocked => 'UDP appears to be blocked';

  @override
  String get diagWizNatBlockedFix =>
      'Use TCP or TLS transport for the account. If the network filters all but web traffic, try TLS on port 443 if your provider supports it.';

  @override
  String get diagWizNatUnknown => 'NAT type could not be determined';

  @override
  String get diagWizNatUnknownFix =>
      'The STUN server did not answer. Try another STUN server in Settings > Network.';

  @override
  String get diagWizNatErr =>
      'The STUN server did not answer, so the NAT type could not be determined.';

  @override
  String get diagWizNatUnknownRaw => 'The NAT type could not be determined.';

  @override
  String get diagWizOptionsNotLoaded =>
      'The account is not loaded in the engine';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'No answer to OPTIONS within $seconds s (transport: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'The server is not reachable. Check the address and port, that a firewall is not dropping SIP, and try another transport (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Request timed out ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Server answered $code $reason after $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Server answered $code $reason in $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'A $code to OPTIONS is normal: the server is reachable but does not allow anonymous probes.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Round-trip time above 300 ms adds noticeable delay to conversations. A closer server or wired connection helps.';

  @override
  String get diagWizTlsRejected => 'The server certificate was rejected';

  @override
  String diagWizTlsSubject(String value) {
    return 'Subject: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Issuer: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problems: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cipher: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'If this is your own PBX with a self-signed certificate and the fingerprint above matches, you can trust it. Otherwise ask the provider for a certificate from a public CA.';

  @override
  String get diagWizTlsTrust => 'Trust this certificate';

  @override
  String diagWizTlsExpired(String date) {
    return 'The certificate expired on $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Ask the server administrator to renew the certificate.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'The certificate expires in $days days',
      one: 'The certificate expires in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Tell the server administrator to renew it soon.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Connected, but verification reported: $problems';
  }

  @override
  String get diagWizTlsOk => 'TLS connection established, certificate valid';

  @override
  String get diagWizTlsRegistered =>
      'Registered over TLS (no certificate details reported)';

  @override
  String get diagWizTlsNone => 'No TLS connection has been observed yet';

  @override
  String get diagWizTlsNoneFix =>
      'Check the TLS port (usually 5061) and that the server accepts TLS 1.2 or newer.';

  @override
  String get diagWizRegDisabledByConfig =>
      'Registration is disabled for this account (peer-to-peer use)';

  @override
  String get diagWizRegRegistered => 'Registered';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registered (expires in $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transport: $transport';
  }

  @override
  String get diagWizRegInProgress => 'Registration is still in progress';

  @override
  String get diagWizRegInProgressFix =>
      'Wait a few seconds. If it never completes, the server is not answering; see the reachability check above.';

  @override
  String get diagWizRegFailed => 'Registration failed';

  @override
  String get diagWizRegOffline => 'The account is offline';

  @override
  String get diagWizRegOfflineFix =>
      'Check the network connection. The app retries automatically.';

  @override
  String get diagWizRegDisabled => 'The account is disabled';

  @override
  String get diagWizAlgNoUdp =>
      'No account uses UDP, so SIP ALG is not a concern';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: no answer over UDP, but TCP answered ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: no answer over UDP or TCP (server or firewall problem rather than ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS is answered but REGISTER times out, which is typical of a router rewriting SIP';
  }

  @override
  String get diagWizAlgSuspected => 'SIP ALG suspected on your router';

  @override
  String get diagWizAlgSuspectedFix =>
      'Disable \"SIP ALG\" / \"SIP helper\" in the router settings, or switch the account to TCP or TLS, or change the SIP port (e.g. 5080) so the router stops mangling packets.';

  @override
  String get diagWizAlgContactChanged =>
      'The Contact address changed between request and reply';

  @override
  String get diagWizAlgContactChangedFix =>
      'This can be a SIP ALG or a server that rewrites contacts. If calls ring but have no audio or drop after a while, disable SIP ALG on the router or use TCP/TLS or port 5080.';

  @override
  String get diagWizAlgOk => 'No sign of SIP ALG interference';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER Contact $sent came back as $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Save $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return 'Saved $fileName';
  }

  @override
  String get diagSaveFailed => 'Could not save the file';

  @override
  String get diagCopiedText => 'Text copied to the clipboard';

  @override
  String get diagCopiedReport => 'Report copied to the clipboard';

  @override
  String get diagCopiedBundle => 'Diagnostic bundle copied to the clipboard';

  @override
  String get diagCopiedLogs => 'Logs copied to the clipboard';

  @override
  String get diagCopiedTrace => 'Trace copied to the clipboard';

  @override
  String get diagCopiedDialog => 'Dialog copied to the clipboard';

  @override
  String get diagSaveAsLog => 'Save as .log';

  @override
  String get diagSysAppVersion => 'App version';

  @override
  String get diagSysPlatform => 'Platform';

  @override
  String get diagSysEngine => 'Engine';

  @override
  String get diagSysAccounts => 'Accounts';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered of $total registered';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Could not read system information: $error';
  }

  @override
  String get diagSysTransports => 'Transports';

  @override
  String get diagSysNoneReported => 'None reported';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter => 'Enabled codecs, highest priority first.';

  @override
  String get diagSysEngineNotRunning => 'Engine not running';

  @override
  String diagSysCodecPriority(int priority) {
    return 'priority $priority';
  }

  @override
  String get diagSysCodecDisabled => 'disabled';

  @override
  String get diagSysExport => 'Export';

  @override
  String get diagSysExportFooter =>
      'The bundle holds system info, network check results, recent logs and the SIP trace, with credentials redacted.';

  @override
  String get diagSysCopyBundle => 'Copy diagnostic bundle';

  @override
  String get diagSysSaveBundle => 'Save diagnostic bundle';

  @override
  String get diagTabSipTrace => 'SIP trace';

  @override
  String get diagTabNetwork => 'Network';

  @override
  String get diagTabQuality => 'Quality';

  @override
  String get diagTabAudioTest => 'Audio test';

  @override
  String get diagTabLogs => 'Logs';

  @override
  String get diagTabSystem => 'System';

  @override
  String diagRawSentTo(String remote) {
    return 'sent to $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'received from $remote';
  }

  @override
  String get diagRawCopied => 'Message copied';

  @override
  String get diagRawLadder => 'Ladder';

  @override
  String get diagRawRedact => 'Redact credentials';

  @override
  String diagRawTruncated(int count) {
    return '... truncated ($count chars)';
  }

  @override
  String get diagWizIntro =>
      'Checks your connection, DNS, NAT, server reachability, TLS and registration, and explains what to fix.';

  @override
  String get diagWizStop => 'Stop';

  @override
  String get diagWizRunChecks => 'Run checks';

  @override
  String get diagWizRunAgain => 'Run again';

  @override
  String get diagWizCopyReport => 'Copy report';

  @override
  String get diagWizSaveReport => 'Save report';

  @override
  String diagWizCountPassed(int count) {
    return 'Passed $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Warnings $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Failed $count';
  }

  @override
  String get diagWizStatusPass => 'Passed';

  @override
  String get diagWizStatusWarn => 'Warning';

  @override
  String get diagWizStatusFail => 'Failed';

  @override
  String get diagWizStatusSkipped => 'Skipped';

  @override
  String get diagWizStatusRunning => 'Running';

  @override
  String get diagWizStatusPending => 'Pending';

  @override
  String get diagQualityTitle => 'Call quality';

  @override
  String get diagQualityNoData => 'No quality data was recorded for this call.';

  @override
  String get diagQualityTraceForCall => 'SIP trace for this call';

  @override
  String get diagQualityTraceNotCaptured =>
      'SIP trace not captured for this call';

  @override
  String get diagQualityLiveCall => 'Live call';

  @override
  String get diagQualityNoActiveCall =>
      'No active call. Start a call and MOS, jitter, loss and round-trip time are plotted here live.';

  @override
  String get diagQualityRecentCalls => 'Recent calls';

  @override
  String get diagQualityNoFinished =>
      'No finished calls with quality data yet.';

  @override
  String get diagQualityCallEnded => 'The call has ended.';

  @override
  String get diagQualityMeasuring => 'measuring';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return '$title chart';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return '$title chart, latest $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   max $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Average $avg  ·  worst $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Loss';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count pkts';
  }

  @override
  String get diagQualityMedia => 'Media';

  @override
  String get diagQualityNoSeries =>
      'No time series was recorded for this call.';

  @override
  String get diagQualityPacketLoss => 'Packet loss';

  @override
  String get diagQualityRtt => 'Round-trip time';

  @override
  String get diagLogsForward => 'Forward engine logs';

  @override
  String get diagLogsForwardSub => 'Send pjsip log lines to this viewer';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Level $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Redact on export';

  @override
  String get diagLogsSearch => 'Search logs';

  @override
  String get diagLogsEmpty => 'No log lines yet.';

  @override
  String get diagLogsForwardingOff =>
      'Log forwarding is off. Turn it on to capture engine logs.';

  @override
  String get diagLogsNoMatch => 'No lines match the search.';

  @override
  String get diagAudioEngineNotRunning => 'The SIP engine is not running.';

  @override
  String get diagAudioMicrophone => 'Microphone';

  @override
  String get diagAudioMicFooter =>
      'The level meter reads the audio device, which the engine opens during a call or the echo test.';

  @override
  String get diagAudioLevelMeter => 'Level meter';

  @override
  String get diagAudioLevelMeterSub => 'Speak and watch the bar move';

  @override
  String get diagAudioMic => 'Mic';

  @override
  String get diagAudioSpeaker => 'Speaker';

  @override
  String get diagAudioEchoTest => 'Echo test';

  @override
  String get diagAudioEchoFooter =>
      'Plays your voice back through the speaker. Use headphones to avoid feedback.';

  @override
  String get diagAudioEchoActive => 'Active: speak now';

  @override
  String get diagAudioEchoIdle => 'Mic to speaker loopback';

  @override
  String get diagAudioSpeakerTest => 'Speaker test';

  @override
  String get diagAudioPlayTone => 'Play test tone';

  @override
  String get diagAudioPlayToneSub => 'Plays through the selected speaker';

  @override
  String get diagAudioPlayingDtmf => 'Playing DTMF';

  @override
  String get diagAudioPlayingRingback => 'Playing ringback';

  @override
  String get diagAudioRingback => 'Ringback';

  @override
  String get diagAudioDevices => 'Devices';

  @override
  String get diagAudioChooseDevices => 'Choose microphone and speaker';

  @override
  String get diagAudioChooseDevicesSub => 'Opens Settings > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label level $percent percent';
  }

  @override
  String get diagLadderLocal => 'Local';

  @override
  String diagLadderSent(String message) {
    return 'Sent $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Received $message';
  }

  @override
  String get diagTraceCapture => 'Capture SIP messages';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0  ·  $size  ·  $dropped older dropped';
  }

  @override
  String get diagTraceOffHint => 'Off. Turn on, then register or make a call.';

  @override
  String get diagTraceExportOrClear => 'Export or clear';

  @override
  String get diagTraceSaveAsPcap => 'Save as .pcap';

  @override
  String get diagTraceCopyAsText => 'Copy as text';

  @override
  String get diagTraceSearchHint => 'Search text, number or Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Errors only';

  @override
  String get diagTraceFilterMethod => 'Filter by method';

  @override
  String get diagTraceAllMethods => 'All methods';

  @override
  String get diagTraceMethod => 'Method';

  @override
  String get diagTraceFilterAccount => 'Filter by account';

  @override
  String get diagTraceAllAccounts => 'All accounts';

  @override
  String get diagTraceAccount => 'Account';

  @override
  String get diagTraceRedact => 'Redact';

  @override
  String get diagTraceList => 'List';

  @override
  String get diagTraceWaiting => 'Waiting for SIP traffic';

  @override
  String get diagTraceWaitingSub =>
      'Register an account or make a call and the messages appear here.';

  @override
  String get diagTraceOff => 'SIP trace is off';

  @override
  String get diagTraceOffSub =>
      'Turn on capture to see every SIP request and response, as a list or a ladder diagram.';

  @override
  String get diagTraceNoMatch => 'No messages match the filters';

  @override
  String get diagTraceAllDialogs => 'All dialogs';

  @override
  String get diagTraceCopyDialog => 'Copy this dialog';

  @override
  String get diagTraceNoResponse => 'no response';

  @override
  String get diagTraceNoCallId => 'no Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Recording';

  @override
  String get recFormatWav => 'Standard (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stereo, you and the caller on separate channels (WAV)';

  @override
  String get recFormatOpus => 'Compressed (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, about 2 MB per minute. Plays everywhere.';

  @override
  String get recFormatWavStereoHint =>
      'Two channels, about 4 MB per minute. You on the left, the caller on the right.';

  @override
  String get recFormatOpusHint =>
      'About 0.2 MB per minute. Ogg Opus; some players on iPhone, Mac and Windows cannot open it.';

  @override
  String get recOptionInherit => 'Use global setting';

  @override
  String get recOptionAlways => 'Record all calls';

  @override
  String get recOptionIncoming => 'Record incoming calls only';

  @override
  String get recOptionOutgoing => 'Record outgoing calls only';

  @override
  String get recOptionNever => 'Never record';

  @override
  String get recRuleAll => 'All calls';

  @override
  String get recRuleIncoming => 'Incoming calls only';

  @override
  String get recRuleOutgoing => 'Outgoing calls only';

  @override
  String get recAutoDeleteNever => 'Never';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'After $days days',
      one: 'After 1 day',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'After 1 year';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0  ·  $size  ·  auto-delete after $_temp1';
  }

  @override
  String get recSettingsFormat => 'Format';

  @override
  String get recSettingsAutoGroup => 'Automatic recording';

  @override
  String get recSettingsAutoFooter =>
      'Check your local laws before recording calls. Turn on \"Always record calls with this contact\" in a contact to record them whatever these rules say.';

  @override
  String get recSettingsAutoRule => 'Record calls automatically';

  @override
  String get recSettingsAccountOverride => 'Override for this account';

  @override
  String get recSettingsNoticesGroup => 'Notices';

  @override
  String get recSettingsNoticeSwitch => 'Play a notice before recording';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Plays a notice to the other party first. The notice file is chosen in Settings > Calls > Announcements.';

  @override
  String get recSettingsNoticeFile => 'Choose the notice file';

  @override
  String get recSettingsNoticeFileHint =>
      'Opens Settings > Calls > Announcements';

  @override
  String get recSettingsBeep => 'Recording beep';

  @override
  String get recSettingsBeepHint => 'Warn the other party periodically';

  @override
  String get recSettingsTransfersGroup => 'Transfers';

  @override
  String get recSettingsContinue => 'Continue recording through transfers';

  @override
  String get recSettingsContinueHint =>
      'Record the consultation call of an attended transfer and the call handed to us by a transfer, and link the recordings';

  @override
  String get recSettingsStorageGroup => 'Storage';

  @override
  String get recSettingsFolder => 'Folder';

  @override
  String get recSettingsFolderHint => 'Where recordings are saved';

  @override
  String get recSettingsFolderPlaceholder => 'App documents / Recordings';

  @override
  String get recSettingsChooseFolder => 'Choose folder...';

  @override
  String get recSettingsFolderPickerTitle => 'Recordings folder';

  @override
  String get recSettingsAutoDelete => 'Delete old recordings';

  @override
  String get recSettingsAutoDeleteHint => 'Checked at startup and once a day';

  @override
  String get recSettingsManage => 'Manage recordings';

  @override
  String get recSettingsOpenFolder => 'Open recordings folder';

  @override
  String get recPageTitle => 'Recordings';

  @override
  String recSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get recCancelSelection => 'Cancel selection';

  @override
  String get recSelectAll => 'Select all';

  @override
  String get recShareSelected => 'Share selected';

  @override
  String get recDeleteSelected => 'Delete selected';

  @override
  String get recSearchTooltip => 'Search recordings';

  @override
  String get recSelectTooltip => 'Select recordings';

  @override
  String get recMenuSettings => 'Recording settings';

  @override
  String get recSearchHint => 'Search name or number';

  @override
  String get recEmptyNone => 'No recordings yet';

  @override
  String get recEmptyNoneHint =>
      'Record a call with the Record button, or turn on automatic recording in Settings.';

  @override
  String get recEmptyNoMatch => 'No matching recordings';

  @override
  String get recEmptyNoMatchHint => 'Try another search or filter.';

  @override
  String get recClearFilters => 'Clear filters';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count recordings?',
      one: 'Delete 1 recording?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'The audio files are removed from this device. This cannot be undone.';

  @override
  String get recDeleteOneTitle => 'Delete this recording?';

  @override
  String get recDeleteOneMessage =>
      'The audio file is removed from this device. This cannot be undone.';

  @override
  String get recFilterAll => 'All';

  @override
  String get recFilterIncoming => 'Incoming';

  @override
  String get recFilterOutgoing => 'Outgoing';

  @override
  String get recFilterByAccount => 'Filter by account';

  @override
  String get recFilterAllAccounts => 'All accounts';

  @override
  String get recFilterAccountFallback => 'Account';

  @override
  String get recFilterAnyDate => 'Any date';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Clear dates';

  @override
  String get recMissingFile => 'The audio file is missing from this device.';

  @override
  String recRelated(String title) {
    return 'Related: $title';
  }

  @override
  String get recRenameTitle => 'Rename recording';

  @override
  String get recRenameHint => 'Name';

  @override
  String get recSaveAs => 'Save as...';

  @override
  String get recShowInFinder => 'Show in Finder';

  @override
  String get recShowInFolder => 'Show in folder';

  @override
  String get recViewCall => 'View call';

  @override
  String recSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get recSaveFailed => 'Could not save the recording';

  @override
  String get recShareFailed => 'Could not share the recording';

  @override
  String get recSaveDialogTitle => 'Save recording';

  @override
  String get recShareSubject => 'Call recordings';

  @override
  String get recPlayerUnsupported =>
      'This device cannot play Opus recordings here.';

  @override
  String get recPlayerOpenWith => 'Open with...';

  @override
  String get recPlayerNotFound => 'The recording file was not found';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Cannot play this recording: $error';
  }

  @override
  String get recPlayerPlay => 'Play recording';

  @override
  String get recPlayerPause => 'Pause recording';

  @override
  String get audioFilesTitle => 'Audio files';

  @override
  String audioAdded(String name) {
    return 'Added \"$name\"';
  }

  @override
  String get audioFileUnavailable => 'That file is not available.';

  @override
  String get audioNameRequired => 'Enter a name';

  @override
  String audioDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get audioDeleteMessage =>
      'Settings that use this file go back to the default.';

  @override
  String get audioGroupAdd => 'Add';

  @override
  String get audioAddFooter =>
      'WAV (PCM, mu-law, A-law) and MP3 files work. Files are copied into the app, so the original can move.';

  @override
  String get audioImport => 'Import a WAV or MP3…';

  @override
  String get audioGroupMine => 'My files';

  @override
  String get audioEmptyTitle => 'No files yet';

  @override
  String get audioEmptyHint => 'Import a file or record your own announcement.';

  @override
  String get audioGroupBuiltIn => 'Built in';

  @override
  String get audioBuiltInFooter => 'Generated for SoftphonePro, free to use.';

  @override
  String get audioPreviewStop => 'Stop preview';

  @override
  String audioPreviewPlay(String name) {
    return 'Preview $name';
  }

  @override
  String get audioRecordedName => 'Name this recording';

  @override
  String get audioRecordedDefaultName => 'My announcement';

  @override
  String audioSaved(String name) {
    return 'Saved \"$name\"';
  }

  @override
  String get audioRecorderStop => 'Stop';

  @override
  String get audioRecorderPlay => 'Play recording';

  @override
  String audioRecorderNew(String duration) {
    return 'New recording  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Discard';

  @override
  String get audioRecordOwn => 'Record your own…';

  @override
  String get audioRecordOwnHint =>
      'Uses the microphone selected in Audio settings';

  @override
  String get audioMissingFile => 'Missing file';

  @override
  String get audioBuiltInCalm => 'Calm (built-in)';

  @override
  String get audioBuiltInBreeze => 'Breeze (built-in)';

  @override
  String get audioBuiltInChime => 'Notice chime (built-in)';

  @override
  String get audioErrOnlyWavMp3 => 'Only WAV and MP3 files can be used.';

  @override
  String get audioErrNotFound => 'That file could not be found.';

  @override
  String get audioErrNotSaved => 'The recording was not saved.';

  @override
  String get audioErrEmpty => 'This audio file is empty or unreadable.';

  @override
  String audioErrUnusable(String reason) {
    return 'This audio file cannot be used ($reason). Use PCM, mu-law or A-law WAV, or MP3.';
  }

  @override
  String get audioRecEngineOff => 'The call engine is not running.';

  @override
  String get audioRecUnsupported =>
      'This version of the call engine cannot record the microphone.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Could not start recording: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Recording failed: $reason';
  }

  @override
  String get audioStrengthLow => 'Low';

  @override
  String get audioStrengthMedium => 'Medium';

  @override
  String get audioStrengthHigh => 'High';

  @override
  String get audioStrengthMax => 'Max';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'System default';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'System default ($name)';
  }

  @override
  String get voiceTitle => 'Voice isolation';

  @override
  String get voiceUnavailable =>
      'AI noise cancellation is not available in this build of the call engine. The standard noise suppression under Processing still works.';

  @override
  String get voiceGroupAi => 'AI noise cancellation';

  @override
  String get voiceAiFooter =>
      'Removes keyboard clicks, fans and background voices from the call using an on-device neural network (RNNoise). Nothing leaves your device. Higher strength removes more noise but can clip the start of words.';

  @override
  String get voiceMic => 'My microphone';

  @override
  String get voiceMicHint => 'Clean up what the other person hears';

  @override
  String get voiceOthers => 'Other participants';

  @override
  String get voiceOthersHint => 'Clean up noisy callers you hear';

  @override
  String voiceStrength(String value) {
    return 'Strength: $value';
  }

  @override
  String get voiceGroupTry => 'Try it';

  @override
  String get voiceTryFooter =>
      'Use headphones for the echo test, or you will hear feedback.';

  @override
  String get voiceEchoTest => 'Test with echo';

  @override
  String get voiceEchoTestHint => 'Plays your processed microphone back to you';

  @override
  String get voiceEchoFailed => 'Echo test failed';

  @override
  String get voiceGroupSystem => 'System';

  @override
  String get voiceSystemFooter =>
      'macOS and iOS can also isolate your voice for every app. Choose Voice Isolation in the system microphone mode.';

  @override
  String get voiceSystemMode => 'System microphone mode (Voice Isolation)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Microphone modes need macOS 12 or iOS 15 or later.';

  @override
  String get voiceSpeechDetection => 'Speech detection';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent percent';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Android audio effects';

  @override
  String get voiceAndroidFooter =>
      'The phone may also clean up the microphone itself. These are reported by Android and are separate from the setting above.';

  @override
  String get voiceAndroidNs => 'Noise suppressor';

  @override
  String get voiceAndroidAec => 'Echo canceller';

  @override
  String get voiceNotAvailableDevice => 'Not available on this device';

  @override
  String get callLinkNotLocal =>
      'This link type can only be used from the command line of this computer.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Connect to device $name?';
  }

  @override
  String get linkLanConnectBody =>
      'A link from another app or web page wants to connect SoftphonePro to this device. Connect only if you expect this.';

  @override
  String get linkLanConnectAction => 'Connect';

  @override
  String get linkImportSensitiveHeader =>
      'Sensitive changes in this configuration:';

  @override
  String get linkImportFlagAutoAnswer => 'Answers incoming calls automatically';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Forwards calls to $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Changes who may start an intercom or pull a call (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Rewrites the numbers you dial';

  @override
  String get linkImportFlagLinksImmediately =>
      'Calls from web links start immediately, without confirmation';

  @override
  String get linkImportFlagDiagnostics =>
      'Turns on detailed logging or SIP tracing';

  @override
  String get linkImportAllowAutoAnswer =>
      'Allow auto-answer for the imported account(s)';

  @override
  String linkImportRefused(String setting) {
    return 'This import tries to change \"$setting\", which can never be set by a link, QR code, pasted text or file. Use the --provision command-line option on this computer instead. Nothing was imported.';
  }

  @override
  String get lanPairIntercomNote =>
      'Paired devices can ask to start an intercom call; you will be asked before each one (change this in Settings > LAN).';

  @override
  String get callLinkUnsupportedScheme => 'This kind of link is not supported.';

  @override
  String get linkImportFlagAutoRecord => 'Records calls automatically';

  @override
  String get linkImportFlagBlocklist => 'Changes your call blocklist';

  @override
  String get linkImportFlagEmergency => 'Changes your emergency numbers';

  @override
  String get linkImportFlagSpeedDial => 'Sets speed-dial numbers';

  @override
  String get linkImportFlagRecordingDelete =>
      'Automatically deletes old recordings';

  @override
  String get linkImportFlagFeatureCodes => 'Dials custom PBX feature codes';

  @override
  String get linkImportAllowAutoRecord => 'Allow automatic call recording';

  @override
  String get importIgnoredHeader => 'Ignored (not allowed from imports):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - server $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Proxies: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN relay: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Custom SIP headers: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'Caller ID: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'No media encryption (SRTP off)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Address: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Update $updated existing, add $added new';
  }

  @override
  String get secretsKeyringLocked =>
      'Your keyring couldn\'t be opened (locked or not responding), so saved passwords couldn\'t be read. Unlock it and restart SoftphonePro.';

  @override
  String get mixerTitle => 'Audio mixer';

  @override
  String get mixerMicrophone => 'Microphone';

  @override
  String get mixerSpeaker => 'Headphones & speaker';

  @override
  String get mixerMicVolume => 'Microphone volume';

  @override
  String get mixerSpeakerVolume => 'Speaker volume';

  @override
  String mixerMeterLabel(String name) {
    return '$name level';
  }

  @override
  String get mixerInputDevice => 'Input device';

  @override
  String get mixerOutputDevice => 'Output device';

  @override
  String get mixerOutputRoute => 'Audio output';

  @override
  String get mixerInputFollowsOutput =>
      'The microphone follows the selected audio output.';

  @override
  String get mixerShowMore => 'Show devices and musicbed';

  @override
  String get mixerShowLess => 'Show fewer controls';

  @override
  String get mixerStripShow => 'Show audio mixer';

  @override
  String get mixerStripHide => 'Hide audio mixer';

  @override
  String get musicbedTitle => 'Musicbed';

  @override
  String get musicbedPlay => 'Play musicbed';

  @override
  String get musicbedVolume => 'Musicbed volume';

  @override
  String get musicbedChooseFile => 'Choose a file';

  @override
  String musicbedChangeFile(String name) {
    return 'Musicbed file: $name. Tap to change.';
  }

  @override
  String get musicbedHearIt => 'Hear it myself';

  @override
  String get musicbedMonitorVolume => 'Monitor volume';

  @override
  String get musicbedAddFile => 'Add a file…';

  @override
  String get musicbedPickerTitle => 'Musicbed file';

  @override
  String get musicbedOn => 'Musicbed on';

  @override
  String get musicbedPausedOnHold => 'Musicbed paused (on hold)';

  @override
  String get musicbedOnTooltip =>
      'A music file is playing to everyone on your calls.';

  @override
  String get musicbedFileMissing =>
      'The musicbed file is no longer available, so musicbed was turned off.';

  @override
  String get musicbedNeedsFile => 'Choose a musicbed file first.';

  @override
  String musicbedStopped(String message) {
    return 'Musicbed stopped: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Loops a music file under your voice for everyone on your calls, even while you are muted. Calls on hold hear the hold music instead.';

  @override
  String get musicbedSettingsFile => 'Music file';

  @override
  String get linkImportFlagMusicbed => 'Plays music into your calls';

  @override
  String get musicbedMonitorIosHint => 'On iPhone you hear it during calls';

  @override
  String get musicbedStopFailed =>
      'Couldn’t stop the music. It may still be playing to your callers.';
}
