import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// Product name. Never translated.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro'**
  String get appName;

  /// Settings > Appearance: title of the language picker row/group.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language picker option: follow the operating system language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// Footer under the language picker explaining that names are not translated.
  ///
  /// In en, this message translates to:
  /// **'Language names are shown in their own language.'**
  String get languagePickerHint;

  /// Generic Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic Save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic Delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Generic Close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Generic OK button.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Generic Retry button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// Generic Done button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Generic Add button.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Generic Edit action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Generic Rename action.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// Generic Clear action.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Back button / tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Generic Copy action.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Generic Share action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Generic Import action.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Generic Export action.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// Button/snackbar action that opens more details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// Overflow / more-options tooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// Link or button that opens Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionSettings;

  /// Generic Search label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// Generic Refresh action.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// Generic Continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Generic Yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// Generic No.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// Switch/state value: enabled.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// Switch/state value: disabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// Value when nothing is selected.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Value: the default option.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get commonDefault;

  /// Value: follow the system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get commonSystem;

  /// Value: chosen automatically.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get commonAutomatic;

  /// Value: unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// Value: no value configured.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// Generic title for an error dialog.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Generic loading indicator text.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// Presence status: available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// Presence status / call setting: do not disturb.
  ///
  /// In en, this message translates to:
  /// **'Do not disturb'**
  String get statusDoNotDisturb;

  /// Presence status: offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// Presence status: currently on a call.
  ///
  /// In en, this message translates to:
  /// **'On a call'**
  String get statusOnACall;

  /// Settings hub: title of the "Accounts" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsEntryAccounts;

  /// Settings hub: subtitle of the "Accounts" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'SIP accounts and registration'**
  String get settingsEntryAccountsSub;

  /// Settings hub: title of the "Audio" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get settingsEntryAudio;

  /// Settings hub: subtitle of the "Audio" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'Devices, levels, echo cancellation'**
  String get settingsEntryAudioSub;

  /// Settings hub: title of the "Codecs" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Codecs'**
  String get settingsEntryCodecs;

  /// Settings hub: subtitle of the "Codecs" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'Order, availability, Opus'**
  String get settingsEntryCodecsSub;

  /// Settings hub: title of the "Calls" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get settingsEntryCalls;

  /// Settings hub: subtitle of the "Calls" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'DND, waiting, auto-answer, dial rules'**
  String get settingsEntryCallsSub;

  /// Settings hub: title of the "Network" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get settingsEntryNetwork;

  /// Settings hub: subtitle of the "Network" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'Transports, STUN, TLS, DNS'**
  String get settingsEntryNetworkSub;

  /// Settings hub: title of the "Recording" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get settingsEntryRecording;

  /// Settings hub: title of the "Notifications and ringtones" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Notifications and ringtones'**
  String get settingsEntryNotifications;

  /// Settings hub: title of the "Shortcuts" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get settingsEntryShortcuts;

  /// Settings hub: subtitle of the "Shortcuts" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'Global hotkeys, in-app keys'**
  String get settingsEntryShortcutsSub;

  /// Settings hub: title of the "Appearance" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsEntryAppearance;

  /// Settings hub: title of the "Privacy and security" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Privacy and security'**
  String get settingsEntryPrivacy;

  /// Settings hub: title of the "LAN Link" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'LAN Link'**
  String get settingsEntryLan;

  /// Settings hub: title of the "Provisioning" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Provisioning'**
  String get settingsEntryProvisioning;

  /// Settings hub: subtitle of the "Provisioning" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'Import, export, QR'**
  String get settingsEntryProvisioningSub;

  /// Settings hub: title of the "Diagnostics" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsEntryDiagnostics;

  /// Settings hub: subtitle of the "Diagnostics" entry in the compact list.
  ///
  /// In en, this message translates to:
  /// **'SIP trace, network checks'**
  String get settingsEntryDiagnosticsSub;

  /// Settings hub: title of the "Advanced" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsEntryAdvanced;

  /// Settings hub: title of the "About" section entry (list row and page header).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsEntryAbout;

  /// Settings > Accounts: empty state title.
  ///
  /// In en, this message translates to:
  /// **'Add your first account'**
  String get settingsAccountsEmptyTitle;

  /// Settings > Accounts: empty state explanation.
  ///
  /// In en, this message translates to:
  /// **'Connect to your PBX or SIP provider to start calling.'**
  String get settingsAccountsEmptySubtitle;

  /// Settings > Accounts: button that opens the account wizard.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get settingsAccountsAdd;

  /// Settings > Accounts: section header above the account list.
  ///
  /// In en, this message translates to:
  /// **'Your accounts'**
  String get settingsAccountsYourAccounts;

  /// Settings > Accounts: subtitle of an account row: SIP address and registration status.
  ///
  /// In en, this message translates to:
  /// **'{address}  ·  {status}'**
  String settingsAccountSubtitle(String address, String status);

  /// Settings > Accounts: subtitle of an account row when registered via the backup server.
  ///
  /// In en, this message translates to:
  /// **'{address}  ·  {status}  ·  using backup server'**
  String settingsAccountSubtitleBackup(String address, String status);

  /// Settings > Audio: group title.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get settingsAudioDevices;

  /// Settings > Audio: microphone device selector title.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get settingsAudioMicrophone;

  /// Settings > Audio: speaker device selector title.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get settingsAudioSpeaker;

  /// Settings > Audio: ringer device selector title.
  ///
  /// In en, this message translates to:
  /// **'Ringer'**
  String get settingsAudioRinger;

  /// Settings > Audio: subtitle of the ringer device selector.
  ///
  /// In en, this message translates to:
  /// **'Play the ringtone on a separate device'**
  String get settingsAudioRingerSub;

  /// Settings > Audio: row that rescans audio devices.
  ///
  /// In en, this message translates to:
  /// **'Refresh devices'**
  String get settingsAudioRefreshDevices;

  /// Settings > Audio: group title.
  ///
  /// In en, this message translates to:
  /// **'Levels and test'**
  String get settingsAudioLevelsAndTest;

  /// Settings > Audio: slider title.
  ///
  /// In en, this message translates to:
  /// **'Microphone volume'**
  String get settingsAudioMicVolume;

  /// Settings > Audio: accessibility label of the live microphone level meter.
  ///
  /// In en, this message translates to:
  /// **'Mic level'**
  String get settingsAudioMicLevel;

  /// Settings > Audio: slider title.
  ///
  /// In en, this message translates to:
  /// **'Speaker volume'**
  String get settingsAudioSpeakerVolume;

  /// Settings > Audio: accessibility label of the live speaker level meter.
  ///
  /// In en, this message translates to:
  /// **'Speaker level'**
  String get settingsAudioSpeakerLevel;

  /// Settings > Audio: row that plays a test tone.
  ///
  /// In en, this message translates to:
  /// **'Test speaker'**
  String get settingsAudioTestSpeaker;

  /// Settings > Audio: subtitle of the Test speaker row.
  ///
  /// In en, this message translates to:
  /// **'Plays a short tone through the selected speaker'**
  String get settingsAudioTestSpeakerSub;

  /// Settings > Audio: error notice title when the test tone fails.
  ///
  /// In en, this message translates to:
  /// **'Could not play the test tone'**
  String get settingsAudioTestToneFailed;

  /// Settings > Audio: error notice title when the echo test fails.
  ///
  /// In en, this message translates to:
  /// **'Echo test failed'**
  String get settingsAudioEchoTestFailed;

  /// Settings > Audio: switch title.
  ///
  /// In en, this message translates to:
  /// **'Echo test'**
  String get settingsAudioEchoTest;

  /// Settings > Audio: subtitle of the echo test switch.
  ///
  /// In en, this message translates to:
  /// **'Plays your microphone back through the speaker. Use headphones to avoid feedback.'**
  String get settingsAudioEchoTestSub;

  /// Settings > Audio: group title.
  ///
  /// In en, this message translates to:
  /// **'Voice and files'**
  String get settingsAudioVoiceAndFiles;

  /// Settings > Audio: row that opens voice isolation settings.
  ///
  /// In en, this message translates to:
  /// **'Voice isolation (AI noise cancellation)'**
  String get settingsAudioVoiceIsolation;

  /// Settings > Audio: row that opens the audio files manager.
  ///
  /// In en, this message translates to:
  /// **'Audio files'**
  String get settingsAudioAudioFiles;

  /// Settings > Audio: subtitle of the Audio files row.
  ///
  /// In en, this message translates to:
  /// **'Hold music and announcements'**
  String get settingsAudioAudioFilesSub;

  /// Settings > Audio: group title.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get settingsAudioProcessing;

  /// Settings > Audio: algorithm selector title.
  ///
  /// In en, this message translates to:
  /// **'Echo cancellation'**
  String get settingsAudioEchoCancellation;

  /// Settings > Audio: echo cancellation algorithm option (simple).
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get settingsAudioEcSimple;

  /// Settings > Audio: echo cancellation algorithm option (use the operating system implementation).
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get settingsAudioEcPlatform;

  /// Settings > Audio: echo tail length selector title.
  ///
  /// In en, this message translates to:
  /// **'Echo tail'**
  String get settingsAudioEchoTail;

  /// Settings > Audio: switch title.
  ///
  /// In en, this message translates to:
  /// **'Noise suppression'**
  String get settingsAudioNoiseSuppression;

  /// Settings > Audio: switch title.
  ///
  /// In en, this message translates to:
  /// **'Automatic gain control'**
  String get settingsAudioAgc;

  /// Settings > Audio: switch title.
  ///
  /// In en, this message translates to:
  /// **'Voice activity detection'**
  String get settingsAudioVad;

  /// Settings > Audio: subtitle of the voice activity detection switch.
  ///
  /// In en, this message translates to:
  /// **'Saves bandwidth during silence'**
  String get settingsAudioVadSub;

  /// Settings > Audio: group title.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAudioAdvanced;

  /// Settings > Audio > Advanced: footer text.
  ///
  /// In en, this message translates to:
  /// **'Jitter buffer values are in milliseconds; -1 uses the engine default. Changing these restarts the call engine.'**
  String get settingsAudioAdvancedFooter;

  /// Settings > Audio: packet time selector title.
  ///
  /// In en, this message translates to:
  /// **'Packet time (ptime)'**
  String get settingsAudioPtime;

  /// Settings > Audio: text field title.
  ///
  /// In en, this message translates to:
  /// **'Jitter buffer: initial'**
  String get settingsAudioJbInitial;

  /// Settings > Audio: text field title.
  ///
  /// In en, this message translates to:
  /// **'Jitter buffer: minimum prefetch'**
  String get settingsAudioJbMinPrefetch;

  /// Settings > Audio: text field title.
  ///
  /// In en, this message translates to:
  /// **'Jitter buffer: maximum prefetch'**
  String get settingsAudioJbMaxPrefetch;

  /// Settings > Audio: text field title.
  ///
  /// In en, this message translates to:
  /// **'Jitter buffer: maximum size'**
  String get settingsAudioJbMaxSize;

  /// Settings > Audio: voice isolation summary part, strength for the microphone (strength is Low/Medium/High/Max).
  ///
  /// In en, this message translates to:
  /// **'Microphone {strength}'**
  String settingsAudioVoiceIsolationMic(String strength);

  /// Settings > Audio: voice isolation summary part, strength for incoming audio from other parties.
  ///
  /// In en, this message translates to:
  /// **'Others {strength}'**
  String settingsAudioVoiceIsolationOthers(String strength);

  /// Accessibility value of a level meter, e.g. 40 percent.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String settingsAudioPercentValue(int percent);

  /// Value with unit milliseconds.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String settingsUnitMs(int value);

  /// Value with unit kilobits per second.
  ///
  /// In en, this message translates to:
  /// **'{value} kbps'**
  String settingsUnitKbps(int value);

  /// Duration in seconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String settingsUnitSeconds(int count);

  /// Settings > Codecs: section header above the codec list.
  ///
  /// In en, this message translates to:
  /// **'Order and availability'**
  String get settingsCodecsOrder;

  /// Settings > Codecs: hint under the codec list.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Accounts can override this list in their own settings.'**
  String get settingsCodecsDragHint;

  /// Settings > Codecs > Opus: bitrate selector title.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get settingsCodecsBitrate;

  /// Settings > Codecs > Opus: switch title (forward error correction).
  ///
  /// In en, this message translates to:
  /// **'In-band FEC'**
  String get settingsCodecsFec;

  /// Settings > Codecs > Opus: subtitle of the FEC switch.
  ///
  /// In en, this message translates to:
  /// **'Recovers from packet loss'**
  String get settingsCodecsFecSub;

  /// Settings > Codecs > Opus: subtitle of the DTX switch.
  ///
  /// In en, this message translates to:
  /// **'Stop sending during silence'**
  String get settingsCodecsDtxSub;

  /// Settings > Codecs > Opus: switch title.
  ///
  /// In en, this message translates to:
  /// **'Constant bitrate'**
  String get settingsCodecsCbr;

  /// Settings > Codecs > Opus: slider title.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get settingsCodecsComplexity;

  /// Settings > Calls: group title.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get settingsCallsIncoming;

  /// Settings > Calls: subtitle of the Do not disturb switch.
  ///
  /// In en, this message translates to:
  /// **'Reject all incoming calls'**
  String get settingsCallsDndSub;

  /// Settings > Calls: selector title for the SIP response used when rejecting in Do not disturb.
  ///
  /// In en, this message translates to:
  /// **'Reject with'**
  String get settingsCallsRejectWith;

  /// Settings > Calls: reject response option; keep the numeric code.
  ///
  /// In en, this message translates to:
  /// **'Busy Here (486)'**
  String get settingsCallsReasonBusy;

  /// Settings > Calls: reject response option; keep the numeric code.
  ///
  /// In en, this message translates to:
  /// **'Temporarily Unavailable (480)'**
  String get settingsCallsReasonUnavailable;

  /// Settings > Calls: reject response option; keep the numeric code.
  ///
  /// In en, this message translates to:
  /// **'Decline (603)'**
  String get settingsCallsReasonDecline;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Call waiting'**
  String get settingsCallsWaiting;

  /// Settings > Calls: subtitle of the call waiting switch.
  ///
  /// In en, this message translates to:
  /// **'Allow a second incoming call during a call'**
  String get settingsCallsWaitingSub;

  /// Settings > Calls: selector title for the response when busy.
  ///
  /// In en, this message translates to:
  /// **'When busy and waiting is off'**
  String get settingsCallsWhenBusy;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Reject anonymous calls'**
  String get settingsCallsRejectAnonymous;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Call links immediately'**
  String get settingsCallsLinksImmediately;

  /// Settings > Calls: subtitle explaining link handling; keep the URI schemes.
  ///
  /// In en, this message translates to:
  /// **'tel:, sip: and callto: links place the call without waiting in the dialer'**
  String get settingsCallsLinksImmediatelySub;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Sync DND / forwarding to PBX via feature codes'**
  String get settingsCallsSyncFeatureCodes;

  /// Settings > Calls: subtitle of the feature codes switch.
  ///
  /// In en, this message translates to:
  /// **'Dials the account\'\'s star codes (for example *78) briefly when you change DND or forwarding'**
  String get settingsCallsSyncFeatureCodesSub;

  /// Settings > Calls: group title.
  ///
  /// In en, this message translates to:
  /// **'Auto-answer'**
  String get settingsCallsAutoAnswerGroup;

  /// Settings > Calls > Auto-answer: footer.
  ///
  /// In en, this message translates to:
  /// **'Call forwarding and per-account auto-answer are set in each account.'**
  String get settingsCallsAutoAnswerFooter;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Auto-answer all calls'**
  String get settingsCallsAutoAnswerAll;

  /// Settings > Calls: auto-answer delay selector title.
  ///
  /// In en, this message translates to:
  /// **'Answer after'**
  String get settingsCallsAnswerAfter;

  /// Settings > Calls: auto-answer delay option, no delay.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsCallsAnswerImmediately;

  /// Settings > Calls: switch title.
  ///
  /// In en, this message translates to:
  /// **'Honour intercom headers'**
  String get settingsCallsIntercomHeaders;

  /// Settings > Calls: subtitle; keep SIP header names.
  ///
  /// In en, this message translates to:
  /// **'Call-Info, Alert-Info and Answer-Mode auto-answer hints'**
  String get settingsCallsIntercomHeadersSub;

  /// Settings > Calls: group title.
  ///
  /// In en, this message translates to:
  /// **'Blocked numbers'**
  String get settingsCallsBlocked;

  /// Settings > Calls: row that adds a blocked number.
  ///
  /// In en, this message translates to:
  /// **'Block a number'**
  String get settingsCallsBlockNumber;

  /// Settings > Calls: dialog title for adding a blocked number.
  ///
  /// In en, this message translates to:
  /// **'Block number'**
  String get settingsCallsBlockNumberTitle;

  /// Settings > Calls: hint of the block number field.
  ///
  /// In en, this message translates to:
  /// **'Number or SIP address'**
  String get settingsCallsBlockNumberHint;

  /// Settings > Calls: group title and row title.
  ///
  /// In en, this message translates to:
  /// **'Speed dial'**
  String get settingsCallsSpeedDial;

  /// Settings > Calls: group title.
  ///
  /// In en, this message translates to:
  /// **'Dial plan'**
  String get settingsCallsDialPlan;

  /// Settings > Calls: row title and title of the dial rules page.
  ///
  /// In en, this message translates to:
  /// **'Dial rules'**
  String get settingsCallsDialRules;

  /// Settings > Calls: text field title.
  ///
  /// In en, this message translates to:
  /// **'Outside-line prefix to strip'**
  String get settingsCallsStripPrefix;

  /// Settings > Calls: helper of the prefix field.
  ///
  /// In en, this message translates to:
  /// **'For example 9, removed from the start of dialled numbers'**
  String get settingsCallsStripPrefixSub;

  /// Settings > Calls: text field title.
  ///
  /// In en, this message translates to:
  /// **'Replace leading + with'**
  String get settingsCallsPlusReplacement;

  /// Settings > Calls: helper of the plus replacement field.
  ///
  /// In en, this message translates to:
  /// **'For example 00 for international access'**
  String get settingsCallsPlusReplacementSub;

  /// Settings > Calls: hint shown when no replacement is configured.
  ///
  /// In en, this message translates to:
  /// **'Keep +'**
  String get settingsCallsPlusReplacementHint;

  /// Settings > Calls: text field title.
  ///
  /// In en, this message translates to:
  /// **'Default country prefix'**
  String get settingsCallsCountryPrefix;

  /// Settings > Calls: helper of the country prefix field.
  ///
  /// In en, this message translates to:
  /// **'National numbers starting with 0 get this prefix, for example +44'**
  String get settingsCallsCountryPrefixSub;

  /// Settings > Calls: text field title.
  ///
  /// In en, this message translates to:
  /// **'Emergency numbers'**
  String get settingsCallsEmergency;

  /// Settings > Calls: helper of the emergency numbers field.
  ///
  /// In en, this message translates to:
  /// **'Comma separated. These bypass dial rules.'**
  String get settingsCallsEmergencySub;

  /// Tooltip of the button that removes a number from the blocklist.
  ///
  /// In en, this message translates to:
  /// **'Unblock {number}'**
  String settingsCallsUnblock(String number);

  /// Settings > Calls > Speed dial: subtitle showing how many of the 9 slots are assigned.
  ///
  /// In en, this message translates to:
  /// **'{count} of 9 assigned'**
  String settingsCallsSpeedDialAssigned(int count);

  /// Settings > Calls: number of configured dial rules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule} other{{count} rules}}'**
  String settingsCallsDialRulesCount(int count);

  /// Dial rule editor dialog title when creating.
  ///
  /// In en, this message translates to:
  /// **'New dial rule'**
  String get settingsDialRulesNew;

  /// Dial rule editor dialog title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit dial rule'**
  String get settingsDialRulesEdit;

  /// Dial rule editor: name field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsDialRulesName;

  /// Dial rule editor: pattern field label.
  ///
  /// In en, this message translates to:
  /// **'Pattern (regex)'**
  String get settingsDialRulesPattern;

  /// Dial rule editor: replacement field label.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get settingsDialRulesReplacement;

  /// Dial rule editor: helper under the replacement field; keep the $1, $2 tokens.
  ///
  /// In en, this message translates to:
  /// **'Use \$1, \$2 for groups'**
  String get settingsDialRulesReplacementHelp;

  /// Dial rule editor: account selector label.
  ///
  /// In en, this message translates to:
  /// **'Route through account'**
  String get settingsDialRulesRoute;

  /// Dial rules page: tooltip of the add button.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get settingsDialRulesAdd;

  /// Dial rules page: card title for the live test.
  ///
  /// In en, this message translates to:
  /// **'Live test'**
  String get settingsDialRulesLiveTest;

  /// Dial rules page: label of the test number field.
  ///
  /// In en, this message translates to:
  /// **'Typed number'**
  String get settingsDialRulesTyped;

  /// Dial rules page: shown when the test result is empty.
  ///
  /// In en, this message translates to:
  /// **'(nothing)'**
  String get settingsDialRulesNothing;

  /// Dial rules page: note that an emergency number bypasses rules.
  ///
  /// In en, this message translates to:
  /// **'Emergency number: dialled as typed'**
  String get settingsDialRulesEmergency;

  /// Dial rules page: generic word used when the routed account name is unknown (completes "via account").
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get settingsDialRulesAccountFallback;

  /// Dial rules page: empty state text.
  ///
  /// In en, this message translates to:
  /// **'No rules. Numbers are cleaned (spaces, dashes, brackets removed) and dialled as typed. Rules run top to bottom; the first match wins.'**
  String get settingsDialRulesEmpty;

  /// Dial rules page: tooltip of the delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get settingsDialRulesDelete;

  /// Dial rules page: confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete rule?'**
  String get settingsDialRulesDeleteTitle;

  /// Dial rules page: shows which account the test number would be routed through.
  ///
  /// In en, this message translates to:
  /// **'via {account}'**
  String settingsDialRulesVia(String account);

  /// Settings > Network: group title.
  ///
  /// In en, this message translates to:
  /// **'Transports'**
  String get settingsNetworkTransports;

  /// Settings > Network > Transports: footer.
  ///
  /// In en, this message translates to:
  /// **'Port 0 picks a random free port. Changing transports restarts the call engine.'**
  String get settingsNetworkTransportsFooter;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'UDP port'**
  String get settingsNetworkUdpPort;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'TCP port'**
  String get settingsNetworkTcpPort;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'TLS port'**
  String get settingsNetworkTlsPort;

  /// Settings > Network: switch title.
  ///
  /// In en, this message translates to:
  /// **'Verify server certificates'**
  String get settingsNetworkVerifyCerts;

  /// Settings > Network: subtitle of the verify certificates switch.
  ///
  /// In en, this message translates to:
  /// **'Turn off only for self-signed PBXs, or pin the certificate below'**
  String get settingsNetworkVerifyCertsSub;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'Custom CA file'**
  String get settingsNetworkCustomCa;

  /// Settings > Network: helper of the custom CA field.
  ///
  /// In en, this message translates to:
  /// **'PEM bundle used instead of the built-in list (private PBX CA)'**
  String get settingsNetworkCustomCaSub;

  /// Settings > Network: hint shown when no custom CA file is set.
  ///
  /// In en, this message translates to:
  /// **'Built-in Mozilla list'**
  String get settingsNetworkCustomCaHint;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'Pinned certificates'**
  String get settingsNetworkPins;

  /// Settings > Network: helper of the pinned certificates field.
  ///
  /// In en, this message translates to:
  /// **'host=SHA256 fingerprint, comma separated'**
  String get settingsNetworkPinsSub;

  /// Settings > Network: group title.
  ///
  /// In en, this message translates to:
  /// **'NAT traversal'**
  String get settingsNetworkNat;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'STUN servers'**
  String get settingsNetworkStun;

  /// Settings > Network: helper of the STUN servers field.
  ///
  /// In en, this message translates to:
  /// **'host:port, comma separated'**
  String get settingsNetworkStunSub;

  /// Settings > Network: info row title.
  ///
  /// In en, this message translates to:
  /// **'ICE and TURN'**
  String get settingsNetworkIceTurn;

  /// Settings > Network: info row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configured per account under NAT'**
  String get settingsNetworkIceTurnSub;

  /// Settings > Network: group title.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsNetworkAdvanced;

  /// Settings > Network: switch title.
  ///
  /// In en, this message translates to:
  /// **'QoS (DSCP marking)'**
  String get settingsNetworkQos;

  /// Settings > Network: subtitle of the QoS switch.
  ///
  /// In en, this message translates to:
  /// **'Mark SIP and voice packets for priority'**
  String get settingsNetworkQosSub;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'DNS servers'**
  String get settingsNetworkDns;

  /// Settings > Network: helper of the DNS servers field.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for automatic'**
  String get settingsNetworkDnsSub;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'RTP port start'**
  String get settingsNetworkRtpStart;

  /// Settings > Network: text field title.
  ///
  /// In en, this message translates to:
  /// **'RTP port range'**
  String get settingsNetworkRtpRange;

  /// Settings > Network: helper of the RTP port range field.
  ///
  /// In en, this message translates to:
  /// **'0 uses the default'**
  String get settingsNetworkRtpRangeSub;

  /// Settings > Notifications: group title.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get settingsNotifRingtone;

  /// Settings > Notifications: ringtone selector title.
  ///
  /// In en, this message translates to:
  /// **'Default ringtone'**
  String get settingsNotifDefaultRingtone;

  /// Settings > Notifications: switch title.
  ///
  /// In en, this message translates to:
  /// **'Call progress tones'**
  String get settingsNotifProgressTones;

  /// Settings > Notifications: subtitle of the progress tones switch.
  ///
  /// In en, this message translates to:
  /// **'Ringback, busy and congestion tones while dialling'**
  String get settingsNotifProgressTonesSub;

  /// Settings > Notifications: slider title.
  ///
  /// In en, this message translates to:
  /// **'Ringer volume'**
  String get settingsNotifRingerVolume;

  /// Settings > Notifications: text field title.
  ///
  /// In en, this message translates to:
  /// **'Custom ringtone file'**
  String get settingsNotifCustomRingtone;

  /// Settings > Notifications: helper of the custom ringtone field.
  ///
  /// In en, this message translates to:
  /// **'Path to a WAV file (desktop)'**
  String get settingsNotifCustomRingtoneSub;

  /// Settings > Notifications: group title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifGroup;

  /// Settings > Notifications: row title.
  ///
  /// In en, this message translates to:
  /// **'Request permissions'**
  String get settingsNotifRequestPermissions;

  /// Settings > Notifications: subtitle of the request permissions row.
  ///
  /// In en, this message translates to:
  /// **'Microphone and notifications'**
  String get settingsNotifRequestPermissionsSub;

  /// Settings > Notifications: switch title.
  ///
  /// In en, this message translates to:
  /// **'Send typing indicators'**
  String get settingsNotifTyping;

  /// Settings > Appearance: group title.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsAppearanceTheme;

  /// Settings > Appearance: light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsAppearanceLight;

  /// Settings > Appearance: dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsAppearanceDark;

  /// Settings > Appearance: label above the colour swatches.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAppearanceAccent;

  /// Settings > Appearance: accessibility label of each colour swatch.
  ///
  /// In en, this message translates to:
  /// **'Accent colour option'**
  String get settingsAppearanceAccentOption;

  /// Settings > Appearance: switch title.
  ///
  /// In en, this message translates to:
  /// **'Compact density'**
  String get settingsAppearanceCompact;

  /// Notice after requesting permissions; the values are technical permission state names.
  ///
  /// In en, this message translates to:
  /// **'Microphone: {microphone}, notifications: {notifications}'**
  String settingsNotifPermissionResult(String microphone, String notifications);

  /// Settings > Privacy: group title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsPrivacySecurity;

  /// Settings > Privacy: info row title.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get settingsPrivacyPasswords;

  /// Settings > Privacy: info row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Stored in the system keychain / keystore (encrypted file fallback)'**
  String get settingsPrivacyPasswordsSub;

  /// Settings > Privacy: group title.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyGroup;

  /// Settings > Privacy: info row title.
  ///
  /// In en, this message translates to:
  /// **'No telemetry'**
  String get settingsPrivacyNoTelemetry;

  /// Settings > Privacy: info row subtitle.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro sends no analytics. Network traffic goes only to your SIP servers.'**
  String get settingsPrivacyNoTelemetrySub;

  /// Settings > Privacy: group title.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsPrivacyYourData;

  /// Settings > Privacy: row that deletes call history.
  ///
  /// In en, this message translates to:
  /// **'Clear call history'**
  String get settingsPrivacyClearHistory;

  /// Settings > Privacy: row that deletes all contacts.
  ///
  /// In en, this message translates to:
  /// **'Delete all contacts'**
  String get settingsPrivacyDeleteContacts;

  /// Settings > Privacy: row that deletes all messages.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages'**
  String get settingsPrivacyDeleteMessages;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete call history?'**
  String get settingsPrivacyConfirmHistory;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete all contacts?'**
  String get settingsPrivacyConfirmContacts;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages?'**
  String get settingsPrivacyConfirmMessages;

  /// Confirmation dialog message for deleting data.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get settingsPrivacyCannotUndo;

  /// Notice after call history was deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted call history'**
  String get settingsPrivacyDeletedHistory;

  /// Notice after all contacts were deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted all contacts'**
  String get settingsPrivacyDeletedContacts;

  /// Notice after all messages were deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted all messages'**
  String get settingsPrivacyDeletedMessages;

  /// Settings > LAN Link: group title.
  ///
  /// In en, this message translates to:
  /// **'LAN Link'**
  String get settingsLanGroup;

  /// Settings > LAN Link: footer.
  ///
  /// In en, this message translates to:
  /// **'Devices on the same network find each other, pair with a 6-digit code and talk directly, without any server.'**
  String get settingsLanFooter;

  /// Settings > LAN Link: switch title.
  ///
  /// In en, this message translates to:
  /// **'Enable LAN Link'**
  String get settingsLanEnable;

  /// Settings > LAN Link: text field title.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get settingsLanDeviceName;

  /// Settings > LAN Link: hint of the device name field.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get settingsLanDeviceNameHint;

  /// Settings > LAN Link: switch title.
  ///
  /// In en, this message translates to:
  /// **'Allow intercom'**
  String get settingsLanAllowIntercom;

  /// Settings > LAN Link: subtitle of the intercom switch.
  ///
  /// In en, this message translates to:
  /// **'Let paired devices call you and be auto-answered'**
  String get settingsLanAllowIntercomSub;

  /// Settings > LAN Link: switch title.
  ///
  /// In en, this message translates to:
  /// **'Ask before allowing intercom'**
  String get settingsLanAskIntercom;

  /// Settings > LAN Link: subtitle of the ask-before-intercom switch.
  ///
  /// In en, this message translates to:
  /// **'Otherwise paired devices are auto-answered for 30 s after they ask'**
  String get settingsLanAskIntercomSub;

  /// Settings > LAN Link: switch title.
  ///
  /// In en, this message translates to:
  /// **'Auto-accept files from paired devices'**
  String get settingsLanAutoAcceptFiles;

  /// Settings > LAN Link: subtitle of the auto-accept files switch.
  ///
  /// In en, this message translates to:
  /// **'Otherwise you are asked for every file'**
  String get settingsLanAutoAcceptFilesSub;

  /// Settings > LAN Link: switch title.
  ///
  /// In en, this message translates to:
  /// **'Let paired devices pull my calls'**
  String get settingsLanAllowPull;

  /// Settings > LAN Link: subtitle of the pull calls switch.
  ///
  /// In en, this message translates to:
  /// **'A paired device can take over a call that is active here'**
  String get settingsLanAllowPullSub;

  /// Settings > LAN Link: text field title.
  ///
  /// In en, this message translates to:
  /// **'Downloads folder'**
  String get settingsLanDownloads;

  /// Settings > LAN Link: hint of the downloads folder field.
  ///
  /// In en, this message translates to:
  /// **'Default (Downloads/SoftphonePro)'**
  String get settingsLanDownloadsHint;

  /// Settings > LAN Link: text field title.
  ///
  /// In en, this message translates to:
  /// **'Link port'**
  String get settingsLanPort;

  /// Settings > LAN Link: group title.
  ///
  /// In en, this message translates to:
  /// **'Accounts shared with paired devices'**
  String get settingsLanSharedAccounts;

  /// Settings > LAN Link: footer of the shared accounts group.
  ///
  /// In en, this message translates to:
  /// **'Sharing a registered account lets a paired device on the same server receive your calls directly (call transfer) instead of relaying them.'**
  String get settingsLanSharedAccountsFooter;

  /// Settings > Advanced: group title.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get settingsAdvEngine;

  /// Settings > Advanced: switch title.
  ///
  /// In en, this message translates to:
  /// **'Use simulator'**
  String get settingsAdvSimulator;

  /// Settings > Advanced: subtitle of the simulator switch.
  ///
  /// In en, this message translates to:
  /// **'Run without the native engine. Calls are simulated.'**
  String get settingsAdvSimulatorSub;

  /// Settings > Advanced: selector title.
  ///
  /// In en, this message translates to:
  /// **'Log level'**
  String get settingsAdvLogLevel;

  /// Settings > Advanced: log level option.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get settingsAdvLogErrors;

  /// Settings > Advanced: log level option.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsAdvLogInfo;

  /// Settings > Advanced: log level option.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsAdvLogDebug;

  /// Settings > Advanced: log level option.
  ///
  /// In en, this message translates to:
  /// **'Verbose'**
  String get settingsAdvLogVerbose;

  /// Settings > Advanced: switch title.
  ///
  /// In en, this message translates to:
  /// **'SIP trace'**
  String get settingsAdvSipTrace;

  /// Settings > Advanced: row that restarts the call engine.
  ///
  /// In en, this message translates to:
  /// **'Restart engine'**
  String get settingsAdvRestartEngine;

  /// Settings > Advanced: group title for desktop-only options.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get settingsAdvDesktop;

  /// Settings > Advanced: switch title.
  ///
  /// In en, this message translates to:
  /// **'Start at login'**
  String get settingsAdvStartAtLogin;

  /// Settings > Advanced: switch title.
  ///
  /// In en, this message translates to:
  /// **'Close to tray'**
  String get settingsAdvCloseToTray;

  /// Settings > Advanced: subtitle of the close to tray switch.
  ///
  /// In en, this message translates to:
  /// **'Closing the window keeps SoftphonePro running so calls can still ring. Quit from the tray / menu bar icon.'**
  String get settingsAdvCloseToTraySub;

  /// Settings > About: group title.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get settingsAboutLicence;

  /// Settings > About: licence notice.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 or later. It is distributed WITHOUT ANY WARRANTY.'**
  String get settingsAboutLicenceFooter;

  /// Settings > About: licence row title.
  ///
  /// In en, this message translates to:
  /// **'GNU GPL v3 or later'**
  String get settingsAboutGpl;

  /// Settings > About: licence row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Source code available in the project repository'**
  String get settingsAboutGplSub;

  /// Settings > About: group title.
  ///
  /// In en, this message translates to:
  /// **'Third-party notices'**
  String get settingsAboutThirdParty;

  /// Settings > About: row title.
  ///
  /// In en, this message translates to:
  /// **'Flutter and Dart packages'**
  String get settingsAboutPackages;

  /// Settings > About: row subtitle.
  ///
  /// In en, this message translates to:
  /// **'BSD 3-clause, MIT and Apache 2.0. See the licence page.'**
  String get settingsAboutPackagesSub;

  /// Settings > About: app version line.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAboutVersion(String version);

  /// Settings > About: subtitle of a third-party component (licence and purpose).
  ///
  /// In en, this message translates to:
  /// **'{license}. {purpose}.'**
  String settingsAboutNotice(String license, String purpose);

  /// Settings > About: subtitle of a third-party component with version.
  ///
  /// In en, this message translates to:
  /// **'{license}. {purpose}. Version {version}.'**
  String settingsAboutNoticeVersion(
    String license,
    String purpose,
    String version,
  );

  /// Updates settings: status line while checking GitHub for a new version.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get updatesChecking;

  /// Update status / banner text when a newer release exists. {version} is e.g. 1.2.3.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro {version} is available'**
  String updatesAvailable(String version);

  /// Updates settings: status line when the installed version is the latest.
  ///
  /// In en, this message translates to:
  /// **'You are up to date'**
  String get updatesUpToDate;

  /// Updates settings: generic failure status line.
  ///
  /// In en, this message translates to:
  /// **'Could not check'**
  String get updatesCouldNotCheck;

  /// Updates settings: status line before the first check.
  ///
  /// In en, this message translates to:
  /// **'Not checked yet'**
  String get updatesNotCheckedYet;

  /// Updates settings: status line showing when the last check happened.
  ///
  /// In en, this message translates to:
  /// **'Last checked {date}'**
  String updatesLastChecked(DateTime date);

  /// Settings group title for update checking (desktop).
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesTitle;

  /// Footer under the Updates settings group; privacy explanation.
  ///
  /// In en, this message translates to:
  /// **'Checking contacts api.github.com only (once a week) and sends nothing but the request itself: no identifier, no account or call data. SoftphonePro never downloads or installs anything by itself.'**
  String get updatesFooter;

  /// Switch title to enable weekly update checks.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updatesCheckSwitch;

  /// List tile title that starts an update check immediately.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get updatesCheckNow;

  /// Updates settings: shows which version the user chose to skip.
  ///
  /// In en, this message translates to:
  /// **'Skipping version {version}'**
  String updatesSkippingVersion(String version);

  /// Button to stop skipping the ignored update version.
  ///
  /// In en, this message translates to:
  /// **'Stop skipping'**
  String get updatesStopSkipping;

  /// Update banner button opening the release notes web page.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get updatesReleaseNotes;

  /// Update banner button opening the download page.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updatesDownload;

  /// Update banner button to ignore this release.
  ///
  /// In en, this message translates to:
  /// **'Skip this version'**
  String get updatesSkipVersion;

  /// Tooltip of the close button on the update banner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get updatesDismiss;

  /// Error shown when the update server throttled the request.
  ///
  /// In en, this message translates to:
  /// **'GitHub rate limit reached, try again later'**
  String get updatesRateLimited;

  /// Error shown when the update server returned an unexpected HTTP status.
  ///
  /// In en, this message translates to:
  /// **'GitHub answered {status}'**
  String updatesServerAnswered(int status);

  /// Error shown when the update server reply cannot be understood.
  ///
  /// In en, this message translates to:
  /// **'Unexpected reply'**
  String get updatesUnexpectedReply;

  /// Error shown when the update check took too long.
  ///
  /// In en, this message translates to:
  /// **'Timed out'**
  String get updatesTimedOut;

  /// Error returned when a check is requested while another is running.
  ///
  /// In en, this message translates to:
  /// **'Already checking'**
  String get updatesAlreadyChecking;

  /// Settings group title for database encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryptionTitle;

  /// Footer explaining local database encryption.
  ///
  /// In en, this message translates to:
  /// **'Encrypts the local database with AES-256-GCM. The key is kept in the system keychain / keystore; if it is lost the data cannot be recovered. Call recordings and exported files are not encrypted. The change takes effect the next time SoftphonePro starts (quit it completely first); the previous file is overwritten and deleted as soon as the new database has been opened and verified.'**
  String get encryptionFooter;

  /// Switch title for local database encryption.
  ///
  /// In en, this message translates to:
  /// **'Encrypt call history, contacts and messages on this device'**
  String get encryptionSwitchTitle;

  /// Subtitle shown when encryption is scheduled.
  ///
  /// In en, this message translates to:
  /// **'Will be encrypted at the next start'**
  String get encryptionWillEncrypt;

  /// Subtitle shown when decryption is scheduled.
  ///
  /// In en, this message translates to:
  /// **'Will be decrypted at the next start'**
  String get encryptionWillDecrypt;

  /// Snackbar after enabling database encryption.
  ///
  /// In en, this message translates to:
  /// **'Quit and restart SoftphonePro to encrypt your data.'**
  String get encryptionRestartToEncrypt;

  /// Snackbar after disabling database encryption.
  ///
  /// In en, this message translates to:
  /// **'Quit and restart SoftphonePro to decrypt your data.'**
  String get encryptionRestartToDecrypt;

  /// Dialog title when editing speed dial slot number {slot} (1-9).
  ///
  /// In en, this message translates to:
  /// **'Speed dial {slot}'**
  String speedDialSlotTitle(int slot);

  /// Text field label in the speed dial editor.
  ///
  /// In en, this message translates to:
  /// **'Number or SIP address'**
  String get speedDialNumberLabel;

  /// Text field label in the speed dial editor.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get speedDialLabelOptional;

  /// Dropdown label: which account to call from.
  ///
  /// In en, this message translates to:
  /// **'Call from'**
  String get speedDialCallFrom;

  /// Dropdown option: use the account currently selected in the app.
  ///
  /// In en, this message translates to:
  /// **'Selected account'**
  String get speedDialSelectedAccount;

  /// Page title of the speed dial settings.
  ///
  /// In en, this message translates to:
  /// **'Speed dial'**
  String get speedDialTitle;

  /// Explanation at the top of the speed dial page.
  ///
  /// In en, this message translates to:
  /// **'Long-press a digit (1-9) on the empty keypad to call its number.'**
  String get speedDialHint;

  /// Speed dial slot with no number.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get speedDialNotAssigned;

  /// Error when imported configuration text is not valid JSON. {detail} is a technical parser message.
  ///
  /// In en, this message translates to:
  /// **'Not valid JSON: {detail}'**
  String provisioningNotValidJson(String detail);

  /// Error when imported configuration JSON is not an object.
  ///
  /// In en, this message translates to:
  /// **'Expected a JSON object'**
  String get provisioningExpectedObject;

  /// Error when the imported configuration uses a newer format version than supported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported config version {version}'**
  String provisioningUnsupportedVersion(String version);

  /// Warning shown in the import dialog.
  ///
  /// In en, this message translates to:
  /// **'Skipped a non-object account entry'**
  String get provisioningSkippedAccountEntry;

  /// Warning shown in the import dialog.
  ///
  /// In en, this message translates to:
  /// **'The file contains no accounts or settings'**
  String get provisioningNothingToImport;

  /// Warning shown in the import dialog when an account entry lacks required fields.
  ///
  /// In en, this message translates to:
  /// **'Account \"{name}\" needs username and domain'**
  String provisioningAccountNeedsUserDomain(String name);

  /// Error when the provisioning URL returned an HTTP error status.
  ///
  /// In en, this message translates to:
  /// **'Server answered {status}'**
  String provisioningServerAnswered(int status);

  /// Error when downloading a provisioning file failed. {error} is a technical message.
  ///
  /// In en, this message translates to:
  /// **'Could not download the configuration: {error}'**
  String provisioningDownloadFailed(String error);

  /// Error when a local provisioning file cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Could not read {path}'**
  String provisioningCouldNotRead(String path);

  /// Snackbar after importing a configuration.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 account} other{Imported {count} accounts}}'**
  String provisioningImportedAccounts(int count);

  /// Confirmation dialog title before applying imported accounts and settings.
  ///
  /// In en, this message translates to:
  /// **'Import configuration'**
  String get provisioningImportTitle;

  /// Import confirmation dialog summary line.
  ///
  /// In en, this message translates to:
  /// **'{accounts, plural, =1{1 account} other{{accounts} accounts}}, {settings, plural, =1{1 setting} other{{settings} settings}}'**
  String provisioningSummary(int accounts, int settings);

  /// Prompt dialog title.
  ///
  /// In en, this message translates to:
  /// **'Import from URL or JSON'**
  String get provisioningImportFromUrlTitle;

  /// Hint text of the prompt dialog text field.
  ///
  /// In en, this message translates to:
  /// **'https://... or paste JSON'**
  String get provisioningImportFromUrlHint;

  /// Error snackbar when the import source is not understood.
  ///
  /// In en, this message translates to:
  /// **'That is not a valid URL, link or JSON'**
  String get provisioningInvalidSource;

  /// Title of the QR scanner sheet used to import a configuration.
  ///
  /// In en, this message translates to:
  /// **'Scan provisioning QR'**
  String get provisioningScanTitle;

  /// Hint of the paste fallback field in the QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON, a link or a URL'**
  String get provisioningPasteHint;

  /// Settings group title for importing configuration.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get provisioningImportGroup;

  /// Footer under the import group. Keep the ${VAR} syntax literally.
  ///
  /// In en, this message translates to:
  /// **'Supports JSON with accounts and settings. \$\'{\'VAR\'}\' placeholders are filled with empty values unless a default is given as \$\'{\'VAR:-default\'}\'.'**
  String get provisioningImportFooter;

  /// Settings tile.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get provisioningScanQr;

  /// Settings tile.
  ///
  /// In en, this message translates to:
  /// **'From URL or pasted JSON'**
  String get provisioningFromUrl;

  /// Settings tile.
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get provisioningFromFile;

  /// Settings tile.
  ///
  /// In en, this message translates to:
  /// **'From clipboard'**
  String get provisioningFromClipboard;

  /// Settings group title for exporting configuration.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get provisioningExportGroup;

  /// Switch title for exporting the configuration with passwords.
  ///
  /// In en, this message translates to:
  /// **'Include passwords'**
  String get provisioningIncludePasswords;

  /// Subtitle warning for the include passwords switch.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the file can use your accounts'**
  String get provisioningIncludePasswordsHint;

  /// Settings tile that copies the configuration to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy configuration (JSON)'**
  String get provisioningCopyConfig;

  /// Snackbar after copying the configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration copied'**
  String get provisioningConfigCopied;

  /// Settings group title for sharing an account as QR code.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get provisioningQrGroup;

  /// Footer under the QR code group.
  ///
  /// In en, this message translates to:
  /// **'Scan this code on another device to copy an account. Treat it like a password if it includes one.'**
  String get provisioningQrFooter;

  /// Dropdown title to choose which account to show as QR code.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get provisioningQrAccount;

  /// Dropdown placeholder option.
  ///
  /// In en, this message translates to:
  /// **'Choose...'**
  String get provisioningChoose;

  /// Message shown instead of a QR code when the data is too large.
  ///
  /// In en, this message translates to:
  /// **'Too much data for a QR code'**
  String get provisioningQrTooMuchData;

  /// Tooltip of the clear button next to a certificate/key file row; {field} is the row title (e.g. Certificate file).
  ///
  /// In en, this message translates to:
  /// **'Clear {field}'**
  String tlsClearField(String field);

  /// Button to pick a file when none is set.
  ///
  /// In en, this message translates to:
  /// **'Choose...'**
  String get tlsChoose;

  /// Button to pick a different file.
  ///
  /// In en, this message translates to:
  /// **'Change...'**
  String get tlsChange;

  /// Account editor group title.
  ///
  /// In en, this message translates to:
  /// **'Client certificate (mutual TLS)'**
  String get tlsClientCertTitle;

  /// Footer shown when only one of certificate/key is set.
  ///
  /// In en, this message translates to:
  /// **'Choose both a certificate and its private key. The certificate is only presented once both are set.'**
  String get tlsIncomplete;

  /// Footer under the client certificate group.
  ///
  /// In en, this message translates to:
  /// **'For servers that ask the app to identify itself with a certificate. PEM files. Used for TLS and secure WebSocket.'**
  String get tlsFooter;

  /// Row title and file picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Certificate file'**
  String get tlsCertFile;

  /// Row title and file picker dialog title.
  ///
  /// In en, this message translates to:
  /// **'Private key file'**
  String get tlsKeyFile;

  /// Text field title.
  ///
  /// In en, this message translates to:
  /// **'Key password'**
  String get tlsKeyPassword;

  /// Subtitle of the key password field.
  ///
  /// In en, this message translates to:
  /// **'Only if the key is encrypted'**
  String get tlsKeyPasswordHint;

  /// Settings group title for call hold options.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get callSettingsHoldGroupTitle;

  /// Footer under the hold group. "PBX default" refers to the option label.
  ///
  /// In en, this message translates to:
  /// **'With \"PBX default\" the call is simply put on hold and your phone system may play its own music. Any other choice is played to the caller by this app.'**
  String get callSettingsHoldFooter;

  /// Tile title to choose the hold music.
  ///
  /// In en, this message translates to:
  /// **'Hold music'**
  String get callSettingsHoldMusic;

  /// Hold music option: let the phone system handle it.
  ///
  /// In en, this message translates to:
  /// **'PBX default'**
  String get callSettingsHoldPbxDefault;

  /// Slider title.
  ///
  /// In en, this message translates to:
  /// **'Hold music volume'**
  String get callSettingsHoldMusicVolume;

  /// Navigation tile title opening the audio file library.
  ///
  /// In en, this message translates to:
  /// **'Audio files'**
  String get callSettingsHoldAudioFiles;

  /// Subtitle of the audio files tile.
  ///
  /// In en, this message translates to:
  /// **'Import or record hold music'**
  String get callSettingsHoldAudioFilesHint;

  /// Settings group title.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get callSettingsAnnounceTitle;

  /// Footer under the announcements group.
  ///
  /// In en, this message translates to:
  /// **'Announcements are played to the other party. Everything is skipped silently if the file is missing.'**
  String get callSettingsAnnounceFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Opening announcement'**
  String get callSettingsAnnounceOpening;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a message when a call connects'**
  String get callSettingsAnnounceOpeningHint;

  /// Tile title to pick the announcement audio file.
  ///
  /// In en, this message translates to:
  /// **'Announcement file'**
  String get callSettingsAnnounceFile;

  /// Option shown when no announcement file is chosen.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get callSettingsAnnounceChooseFile;

  /// Select title: which call directions get the announcement.
  ///
  /// In en, this message translates to:
  /// **'Play for'**
  String get callSettingsAnnouncePlayFor;

  /// Option for the announcement direction.
  ///
  /// In en, this message translates to:
  /// **'Incoming and outgoing'**
  String get callSettingsAnnounceBoth;

  /// Option for the announcement direction.
  ///
  /// In en, this message translates to:
  /// **'Incoming calls'**
  String get callSettingsAnnounceIncoming;

  /// Option for the announcement direction.
  ///
  /// In en, this message translates to:
  /// **'Outgoing calls'**
  String get callSettingsAnnounceOutgoing;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Mute my microphone while it plays'**
  String get callSettingsAnnounceMuteMic;

  /// Switch title: play the announcement locally too.
  ///
  /// In en, this message translates to:
  /// **'Also let me hear it'**
  String get callSettingsAnnounceMonitor;

  /// Audio file tile title.
  ///
  /// In en, this message translates to:
  /// **'Before recording starts, play'**
  String get callSettingsAnnounceBeforeRecording;

  /// Audio file tile title.
  ///
  /// In en, this message translates to:
  /// **'Before transferring a caller, play'**
  String get callSettingsAnnounceBeforeTransfer;

  /// Page header of the More menu on compact layouts.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get morePageTitle;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get morePresence;

  /// Subtitle of the Presence entry (BLF).
  ///
  /// In en, this message translates to:
  /// **'Busy lamp field'**
  String get morePresenceHint;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'Retrieve parked call'**
  String get moreRetrieveParked;

  /// Subtitle of the retrieve parked call entry.
  ///
  /// In en, this message translates to:
  /// **'Dial a park slot'**
  String get moreRetrieveParkedHint;

  /// More menu entry (feature name for local network chat).
  ///
  /// In en, this message translates to:
  /// **'LAN Link'**
  String get moreLanLink;

  /// Subtitle of the LAN Link entry.
  ///
  /// In en, this message translates to:
  /// **'Nearby devices, chat and file drop'**
  String get moreLanLinkHint;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get moreRecordings;

  /// Subtitle of the Recordings entry.
  ///
  /// In en, this message translates to:
  /// **'Listen to, share and manage call recordings'**
  String get moreRecordingsHint;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'Voicemail'**
  String get moreVoicemail;

  /// Subtitle of the Voicemail entry with unread voicemail count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new message} other{{count} new messages}}'**
  String moreVoicemailNew(int count);

  /// Subtitle of the Voicemail entry without new messages.
  ///
  /// In en, this message translates to:
  /// **'Dial your voicemail'**
  String get moreVoicemailDial;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get moreDiagnostics;

  /// Subtitle of the Diagnostics entry.
  ///
  /// In en, this message translates to:
  /// **'SIP trace and network checks'**
  String get moreDiagnosticsHint;

  /// More menu entry.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get moreAbout;

  /// Snackbar when dialing voicemail without a configured number.
  ///
  /// In en, this message translates to:
  /// **'No voicemail number is set. Add one in the account settings.'**
  String get moreNoVoicemailNumber;

  /// Hint of the global search field.
  ///
  /// In en, this message translates to:
  /// **'Search contacts, history or type a number'**
  String get moreSearchHint;

  /// Global search result that dials the typed text.
  ///
  /// In en, this message translates to:
  /// **'Call {number}'**
  String moreCallNumber(String number);

  /// Global search recent call subtitle: day label (e.g. Today) and time of day.
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String moreRecentWhen(String day, String time);

  /// Settings group title (Privacy & Security).
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLockTitle;

  /// Footer under the app lock group.
  ///
  /// In en, this message translates to:
  /// **'Calls still ring and can be answered while the app is locked.'**
  String get appLockFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to open the app'**
  String get appLockRequirePin;

  /// Switch subtitle when app lock is on.
  ///
  /// In en, this message translates to:
  /// **'History, contacts, messages and settings are locked'**
  String get appLockOnHint;

  /// Snackbar after enabling app lock.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get appLockIsOn;

  /// Snackbar after disabling app lock.
  ///
  /// In en, this message translates to:
  /// **'App lock is off'**
  String get appLockIsOff;

  /// Title of the PIN verification dialog when disabling the lock.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get appLockTurnOff;

  /// Navigation tile title.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get appLockChangePin;

  /// Title of the PIN verification dialog when changing the PIN.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get appLockEnterCurrent;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get appLockPinChanged;

  /// Select title: delay before the app locks.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get appLockLockAfter;

  /// Subtitle of the Lock after select.
  ///
  /// In en, this message translates to:
  /// **'Time in the background before the PIN is needed again'**
  String get appLockLockAfterHint;

  /// Lock delay option.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get appLockImmediately;

  /// Lock delay option.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String appLockMinutes(int count);

  /// Lock delay option.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get appLockHour;

  /// Switch title (Face ID, fingerprint, etc.).
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get appLockBiometrics;

  /// Navigation tile that locks the app immediately.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get appLockNow;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get appLockSetPin;

  /// Text field label.
  ///
  /// In en, this message translates to:
  /// **'PIN (4-8 digits)'**
  String get appLockPinDigits;

  /// Text field label.
  ///
  /// In en, this message translates to:
  /// **'Repeat PIN'**
  String get appLockRepeatPin;

  /// Validation error under the PIN field.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 8 digits'**
  String get appLockUseDigits;

  /// Validation error under the repeat PIN field.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get appLockMismatch;

  /// Text field label.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockPin;

  /// Error in the PIN dialog after too many wrong attempts. {seconds} is a number of seconds.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s'**
  String appLockTooManyTryIn(int seconds);

  /// Error after entering an incorrect PIN.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get appLockWrongPin;

  /// Error on the lock screen after too many wrong attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get appLockTooMany;

  /// Headline of the lock screen.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro is locked'**
  String get appLockIsLocked;

  /// Lock screen instruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get appLockEnterPin;

  /// Lock screen countdown; {time} is a formatted duration such as 1m 30s.
  ///
  /// In en, this message translates to:
  /// **'Try again in {time}'**
  String appLockTryAgainIn(String time);

  /// Compact duration with minutes and seconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String appLockDurationMinSec(int minutes, int seconds);

  /// Compact duration in seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String appLockDurationSec(int seconds);

  /// Lock screen button.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// Label on the lock screen for a ringing call.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get appLockIncomingCall;

  /// Tooltip of the decline call button on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get appLockDecline;

  /// Tooltip of the answer call button on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get appLockAnswer;

  /// Tooltip of the hang up button on the lock screen.
  ///
  /// In en, this message translates to:
  /// **'Hang up'**
  String get appLockHangUp;

  /// Reason text shown by the operating system biometric prompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock SoftphonePro'**
  String get appLockBiometricReason;

  /// Error status of the local automation API when no token exists.
  ///
  /// In en, this message translates to:
  /// **'No access token set. Generate one in Settings > Advanced.'**
  String get automationNoToken;

  /// Error status of the local automation API.
  ///
  /// In en, this message translates to:
  /// **'Invalid port {port}'**
  String automationInvalidPort(int port);

  /// Error status of the local automation API; {error} is a system message.
  ///
  /// In en, this message translates to:
  /// **'Could not start: {error}'**
  String automationCouldNotStart(String error);

  /// Error status when the TCP port is in use; {error} is a system message.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is not available ({error}). Choose another port.'**
  String automationPortUnavailable(int port, String error);

  /// Placeholder shown instead of the access token before one exists.
  ///
  /// In en, this message translates to:
  /// **'Created when you turn the API on'**
  String get automationTokenPlaceholder;

  /// Status subtitle when the local API runs; {address} is a URL.
  ///
  /// In en, this message translates to:
  /// **'Listening on {address}'**
  String automationListening(String address);

  /// Status subtitle while the local API starts.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get automationStarting;

  /// Settings group title (Advanced).
  ///
  /// In en, this message translates to:
  /// **'Local automation API'**
  String get automationTitle;

  /// Footer under the local automation API group.
  ///
  /// In en, this message translates to:
  /// **'For CRM and helpdesk integrations on this computer. It listens on 127.0.0.1 only and every request needs the access token. See docs/AUTOMATION_API.md.'**
  String get automationFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Enable local automation API'**
  String get automationEnable;

  /// Text field title for the TCP port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get automationPort;

  /// Subtitle of the port field.
  ///
  /// In en, this message translates to:
  /// **'Default 7771. Choose a free port between 1024 and 65535.'**
  String get automationPortHint;

  /// Validation error of the port field.
  ///
  /// In en, this message translates to:
  /// **'Enter a port from 1024 to 65535'**
  String get automationPortInvalid;

  /// List tile title for the API access token.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get automationAccessToken;

  /// Tooltip of the reveal button when the token is visible.
  ///
  /// In en, this message translates to:
  /// **'Hide token'**
  String get automationHideToken;

  /// Tooltip of the reveal button when the token is hidden.
  ///
  /// In en, this message translates to:
  /// **'Show token'**
  String get automationShowToken;

  /// Tooltip of the copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get automationCopyToken;

  /// Snackbar after copying the token.
  ///
  /// In en, this message translates to:
  /// **'Token copied'**
  String get automationTokenCopied;

  /// Tooltip of the regenerate button.
  ///
  /// In en, this message translates to:
  /// **'Generate a new token'**
  String get automationGenerateToken;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Generate a new token?'**
  String get automationGenerateTitle;

  /// Confirmation dialog body.
  ///
  /// In en, this message translates to:
  /// **'Programs using the old token stop working until you give them the new one.'**
  String get automationGenerateBody;

  /// Confirm button in the regenerate token dialog.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get automationGenerate;

  /// Text field title.
  ///
  /// In en, this message translates to:
  /// **'Allowed browser origins'**
  String get automationOrigins;

  /// Subtitle of the allowed origins field.
  ///
  /// In en, this message translates to:
  /// **'Comma separated, for example https://crm.example.com. Programs without a browser (curl, scripts) do not need this.'**
  String get automationOriginsHint;

  /// Validation error for an invalid origin.
  ///
  /// In en, this message translates to:
  /// **'Not an http(s) origin: {origin}'**
  String automationNotOrigin(String origin);

  /// Button on the desktop incoming call notification.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get trayNotificationAnswer;

  /// Button on the desktop incoming call notification.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get trayNotificationDecline;

  /// Tray icon tooltip while a call is active.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro - in a call'**
  String get trayTooltipInCall;

  /// Tray icon tooltip: base tooltip followed by the number of new missed calls and messages.
  ///
  /// In en, this message translates to:
  /// **'{tooltip} - {count} new'**
  String trayTooltipWithNew(String tooltip, int count);

  /// Tray icon tooltip when no accounts exist. status is the presence status (away, dnd or available).
  ///
  /// In en, this message translates to:
  /// **'{status, select, away{SoftphonePro - no accounts (Away)} dnd{SoftphonePro - no accounts (Do not disturb)} other{SoftphonePro - no accounts}}'**
  String trayTooltipNoAccounts(String status);

  /// Tray icon tooltip with the number of registered accounts out of all enabled accounts. status is the presence status (away, dnd or available).
  ///
  /// In en, this message translates to:
  /// **'{status, select, away{SoftphonePro - {online}/{total} online (Away)} dnd{SoftphonePro - {online}/{total} online (Do not disturb)} other{SoftphonePro - {online}/{total} online}}'**
  String trayTooltipOnline(int online, int total, String status);

  /// Tray menu item that hides the app window.
  ///
  /// In en, this message translates to:
  /// **'Hide SoftphonePro'**
  String get trayHideApp;

  /// Tray menu item that shows the app window.
  ///
  /// In en, this message translates to:
  /// **'Show SoftphonePro'**
  String get trayShowApp;

  /// Tray menu item shown when there are new missed calls or messages.
  ///
  /// In en, this message translates to:
  /// **'{count} new - open Recents'**
  String trayNewOpenRecents(int count);

  /// Tray menu submenu title for the presence status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get trayStatus;

  /// Tray menu presence status option.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get trayStatusAway;

  /// Tray menu submenu title listing accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get trayAccounts;

  /// Tray menu item that quits the app.
  ///
  /// In en, this message translates to:
  /// **'Quit SoftphonePro'**
  String get trayQuit;

  /// Name of the global hotkey action that answers a call.
  ///
  /// In en, this message translates to:
  /// **'Answer call'**
  String get hotkeyAnswerCall;

  /// Name of the global hotkey action that ends a call.
  ///
  /// In en, this message translates to:
  /// **'Hang up'**
  String get hotkeyHangUp;

  /// Name of a hotkey/shortcut action that toggles the microphone mute.
  ///
  /// In en, this message translates to:
  /// **'Mute / unmute'**
  String get hotkeyMute;

  /// Name of the global hotkey action that brings the dialer to front.
  ///
  /// In en, this message translates to:
  /// **'Focus dialer'**
  String get hotkeyFocusDialer;

  /// Settings group title for system-wide hotkeys (desktop).
  ///
  /// In en, this message translates to:
  /// **'Global hotkeys'**
  String get shortcutsGlobalTitle;

  /// Footer under the global hotkeys group.
  ///
  /// In en, this message translates to:
  /// **'Work from any application. Another program that already uses a combination may prevent it from registering.'**
  String get shortcutsGlobalFooter;

  /// Tooltip of the edit button of a hotkey row.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get shortcutsChange;

  /// List tile that resets all hotkeys to defaults.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get shortcutsRestoreDefaults;

  /// Settings group title.
  ///
  /// In en, this message translates to:
  /// **'Headset and media keys'**
  String get shortcutsMediaTitle;

  /// Footer under the headset and media keys group.
  ///
  /// In en, this message translates to:
  /// **'The play/pause button of a headset or keyboard is claimed only while a call is ringing or active, so music players keep it the rest of the time.'**
  String get shortcutsMediaFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Answer and hang up with the headset/media play-pause button'**
  String get shortcutsMediaSwitch;

  /// Select title; the options complete the sentence (Hangs up / Mutes / unmutes).
  ///
  /// In en, this message translates to:
  /// **'During a call the button'**
  String get shortcutsMediaDuringCall;

  /// Select option completing "During a call the button".
  ///
  /// In en, this message translates to:
  /// **'Hangs up'**
  String get shortcutsMediaHangsUp;

  /// Select option completing "During a call the button".
  ///
  /// In en, this message translates to:
  /// **'Mutes / unmutes'**
  String get shortcutsMediaMutes;

  /// Settings group title listing in-app keyboard shortcuts.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get shortcutsInApp;

  /// Description of an in-app keyboard shortcut.
  ///
  /// In en, this message translates to:
  /// **'Focus the dialer'**
  String get shortcutsFocusDialer;

  /// Description of an in-app keyboard shortcut.
  ///
  /// In en, this message translates to:
  /// **'Hold / resume'**
  String get shortcutsHoldResume;

  /// Description of an in-app keyboard shortcut.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get shortcutsTransfer;

  /// Description of an in-app keyboard shortcut.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get shortcutsEndCall;

  /// Shown instead of the global hotkeys on Linux Wayland sessions.
  ///
  /// In en, this message translates to:
  /// **'Global shortcuts need an X11 session. Wayland does not allow apps to grab keys system-wide.'**
  String get shortcutsNeedX11;

  /// Hint in the hotkey capture dialog; {key} is Cmd (macOS) or Win.
  ///
  /// In en, this message translates to:
  /// **'Add Ctrl, Alt, Shift or {key} to a letter or digit'**
  String shortcutsNeedModifier(String key);

  /// Instruction in the hotkey capture dialog.
  ///
  /// In en, this message translates to:
  /// **'Press the new key combination'**
  String get shortcutsPressNew;

  /// Snackbar on Windows after opening system settings.
  ///
  /// In en, this message translates to:
  /// **'Choose SoftphonePro for SIP, TEL and CALLTO in Default apps'**
  String get defaultHandlerChooseInSettings;

  /// Snackbar after becoming the default handler.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro now opens sip:, tel: and callto: links'**
  String get defaultHandlerNowOpens;

  /// Snackbar; {schemes} is a list such as sip, tel.
  ///
  /// In en, this message translates to:
  /// **'Could not change the default for {schemes}'**
  String defaultHandlerCouldNotChange(String schemes);

  /// Subtitle of the default handler tile.
  ///
  /// In en, this message translates to:
  /// **'Opens sip:, tel: and callto: links from browsers and other apps'**
  String get defaultHandlerIntro;

  /// Subtitle when the app is already the default.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro handles sip:, tel: and callto: links'**
  String get defaultHandlerIsSelf;

  /// Subtitle listing the current handler per scheme.
  ///
  /// In en, this message translates to:
  /// **'Now: {handlers}'**
  String defaultHandlerNow(String handlers);

  /// Title of the default handler tile.
  ///
  /// In en, this message translates to:
  /// **'Make SoftphonePro the default app for sip:, tel: and callto: links'**
  String get defaultHandlerTitle;

  /// Android settings group title.
  ///
  /// In en, this message translates to:
  /// **'Background reliability'**
  String get reliabilityTitle;

  /// Android reliability row title.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get reliabilityMicrophone;

  /// Android reliability row subtitle when a permission is granted.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get reliabilityAllowed;

  /// Android reliability row subtitle when microphone permission is missing.
  ///
  /// In en, this message translates to:
  /// **'Needed to talk in calls'**
  String get reliabilityMicNeeded;

  /// Android reliability row title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reliabilityNotifications;

  /// Android reliability row subtitle when notification permission is missing.
  ///
  /// In en, this message translates to:
  /// **'Needed to show incoming calls and keep the service visible'**
  String get reliabilityNotifNeeded;

  /// Android reliability row title.
  ///
  /// In en, this message translates to:
  /// **'Full-screen incoming calls'**
  String get reliabilityFullScreen;

  /// Android reliability row subtitle when full-screen intent is not allowed.
  ///
  /// In en, this message translates to:
  /// **'Allow so calls appear over the lock screen'**
  String get reliabilityFullScreenNeeded;

  /// Android reliability row title.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted battery use'**
  String get reliabilityBattery;

  /// Android reliability row subtitle when the app is exempt.
  ///
  /// In en, this message translates to:
  /// **'Exempt from battery optimisation'**
  String get reliabilityBatteryExempt;

  /// Android reliability row subtitle when battery optimisation is active.
  ///
  /// In en, this message translates to:
  /// **'Android may suspend the app and miss calls to save power. Tap to exempt SoftphonePro.'**
  String get reliabilityBatteryNeeded;

  /// Android row title; {manufacturer} is the phone vendor name.
  ///
  /// In en, this message translates to:
  /// **'{manufacturer} autostart / protected apps'**
  String reliabilityAutostart(String manufacturer);

  /// Android row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone vendor may kill background apps. Allow SoftphonePro to auto-start.'**
  String get reliabilityAutostartHint;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Start at boot'**
  String get reliabilityBoot;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Register accounts after the phone restarts'**
  String get reliabilityBootHint;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Keep CPU awake while idle'**
  String get reliabilityWake;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'More reliable on strict devices; uses more battery'**
  String get reliabilityWakeHint;

  /// Account editor: title of the delete-account confirmation; name is the account name.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String acctEditorDeleteTitle(String name);

  /// Tooltip of the button that removes a codec from the account's list; codec is the codec name.
  ///
  /// In en, this message translates to:
  /// **'Remove {codec}'**
  String acctCodecRemove(String codec);

  /// Account editor: last registration error text at the bottom; error is a message.
  ///
  /// In en, this message translates to:
  /// **'Last error: {error}'**
  String acctEditorLastError(String error);

  /// Default helper text under numeric fields; min and max are integers.
  ///
  /// In en, this message translates to:
  /// **'Allowed range {min} to {max}'**
  String acctRangeAllowed(int min, int max);

  /// Validation error for numeric fields; min is an integer.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min}'**
  String acctValidateMin(int min);

  /// Validation error for numeric fields; max is an integer.
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max}'**
  String acctValidateMax(int max);

  /// Account editor: title of the confirmation dialog when leaving with unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get acctEditorDiscardTitle;

  /// Account editor: body of the discard-changes dialog.
  ///
  /// In en, this message translates to:
  /// **'Your edits to this account are not saved.'**
  String get acctEditorDiscardMessage;

  /// Account editor: confirm button of the discard-changes dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get acctEditorDiscardConfirm;

  /// Account editor: body of the delete-account confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'The account and its saved password will be removed from this device.'**
  String get acctEditorDeleteMessage;

  /// Account editor: overflow menu item that deletes the account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get acctEditorMenuDelete;

  /// Account editor: settings group title (label, username, password, server).
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get acctGroupBasic;

  /// Account editor: text field title for the account label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get acctFieldLabel;

  /// Account editor: hint for the account label field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Office'**
  String get acctFieldLabelHint;

  /// Account editor: text field title for the caller display name.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get acctFieldDisplayName;

  /// Account editor: text field title for the SIP/IAX2 username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get acctFieldUsername;

  /// Account editor: row title showing the account protocol (SIP or IAX2).
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get acctFieldProtocol;

  /// Account editor: subtitle of the protocol row; the protocol cannot be changed later.
  ///
  /// In en, this message translates to:
  /// **'Fixed when the account is created'**
  String get acctFieldProtocolSub;

  /// Account editor: text field title for the digest authorization user name.
  ///
  /// In en, this message translates to:
  /// **'Authorization user'**
  String get acctFieldAuthUser;

  /// Account editor: hint of the authorization user field when empty.
  ///
  /// In en, this message translates to:
  /// **'Same as username'**
  String get acctFieldAuthUserHint;

  /// Account editor: explanation under the authorization user field.
  ///
  /// In en, this message translates to:
  /// **'Only if the provider uses a different login name than the username'**
  String get acctFieldAuthUserSub;

  /// Password field title.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get acctFieldPassword;

  /// IAX2 server host field title.
  ///
  /// In en, this message translates to:
  /// **'Server host'**
  String get acctFieldServerHost;

  /// Port field title.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get acctFieldPort;

  /// Helper text under the IAX2 port field.
  ///
  /// In en, this message translates to:
  /// **'IAX2 default is 4569'**
  String get acctFieldIaxPortSub;

  /// Account editor: IAX2 context field title.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get acctFieldIaxContext;

  /// Account editor: explanation under the IAX2 context field.
  ///
  /// In en, this message translates to:
  /// **'Optional. Sent to the PBX as the called context'**
  String get acctFieldIaxContextSub;

  /// Server or domain field title for SIP accounts.
  ///
  /// In en, this message translates to:
  /// **'Server / domain'**
  String get acctFieldServerDomain;

  /// Account editor: format hint under the server/domain field.
  ///
  /// In en, this message translates to:
  /// **'host or host:port'**
  String get acctFieldServerDomainSub;

  /// Switch title: account enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get acctFieldEnabled;

  /// Account editor: switch title marking the default account.
  ///
  /// In en, this message translates to:
  /// **'Default account for outgoing calls'**
  String get acctFieldDefault;

  /// Account editor: title of the account colour picker row.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get acctFieldColour;

  /// Account editor: settings group title for IAX2 registration.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get acctGroupRegistration;

  /// Switch title / button: register the account with the server.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get acctFieldRegister;

  /// Account editor: explanation under the Register switch for IAX2.
  ///
  /// In en, this message translates to:
  /// **'Turn off for peers that need no registration'**
  String get acctFieldRegisterSubIax;

  /// Numeric field title: registration expiry in seconds.
  ///
  /// In en, this message translates to:
  /// **'Registration expiry (s)'**
  String get acctFieldRegExpiry;

  /// Account editor: explanation under the IAX2 registration expiry field.
  ///
  /// In en, this message translates to:
  /// **'Asterisk usually forces 60 s. Range 10 to 86400'**
  String get acctFieldRegExpirySubIax;

  /// Numeric field title: retry interval in seconds.
  ///
  /// In en, this message translates to:
  /// **'Retry interval (s)'**
  String get acctFieldRetryInterval;

  /// Numeric field title: delay before the first registration retry in seconds.
  ///
  /// In en, this message translates to:
  /// **'First retry (s)'**
  String get acctFieldFirstRetry;

  /// Settings group title for the account codecs.
  ///
  /// In en, this message translates to:
  /// **'Codecs'**
  String get acctGroupCodecs;

  /// Footer of the IAX2 codecs group.
  ///
  /// In en, this message translates to:
  /// **'IAX2 supports G.711 and GSM. Drag to set the preference order.'**
  String get acctGroupCodecsFooterIax;

  /// List item that opens a picker to add a codec.
  ///
  /// In en, this message translates to:
  /// **'Add codec'**
  String get acctCodecAdd;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Server and transport'**
  String get acctGroupServerTransport;

  /// Account editor: text field title for an alternative registrar URI.
  ///
  /// In en, this message translates to:
  /// **'Registrar override'**
  String get acctFieldRegistrar;

  /// Account editor: text field title for the fail-over registrar.
  ///
  /// In en, this message translates to:
  /// **'Backup registrar'**
  String get acctFieldBackupRegistrar;

  /// Account editor: explanation under the backup registrar field.
  ///
  /// In en, this message translates to:
  /// **'Used after 3 failed attempts; the primary is retried every 5 minutes'**
  String get acctFieldBackupRegistrarSub;

  /// Account editor: text field title for outbound SIP proxies.
  ///
  /// In en, this message translates to:
  /// **'Outbound proxies'**
  String get acctFieldProxies;

  /// Transport label.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get acctFieldTransport;

  /// Account editor: explanation shown when the transport is Automatic.
  ///
  /// In en, this message translates to:
  /// **'Looks up the server\'\'s DNS SRV records and picks TLS, TCP or UDP'**
  String get acctFieldTransportAutoSub;

  /// Account editor: transport option that selects the transport via DNS SRV.
  ///
  /// In en, this message translates to:
  /// **'Automatic (DNS SRV)'**
  String get acctTransportAuto;

  /// Account editor: text field title for the WebSocket path.
  ///
  /// In en, this message translates to:
  /// **'WebSocket path'**
  String get acctFieldWsPath;

  /// Account editor: explanation under the WebSocket path field.
  ///
  /// In en, this message translates to:
  /// **'HTTP path of the WebSocket upgrade, e.g. /ws. Must start with \"/\"'**
  String get acctFieldWsPathSub;

  /// Account editor: explanation under the SIP registration expiry field.
  ///
  /// In en, this message translates to:
  /// **'300 to 3600 is typical. Range 10 to 86400'**
  String get acctFieldRegExpirySubSip;

  /// Account editor: numeric field title for the UDP keep-alive in seconds.
  ///
  /// In en, this message translates to:
  /// **'Keep-alive (s)'**
  String get acctFieldKeepAlive;

  /// Account editor: explanation under the keep-alive field.
  ///
  /// In en, this message translates to:
  /// **'UDP keep-alive interval. 0 turns it off. Range 0 to 3600'**
  String get acctFieldKeepAliveSub;

  /// Account editor: numeric field title for a dedicated local SIP port.
  ///
  /// In en, this message translates to:
  /// **'Local SIP port'**
  String get acctFieldLocalPort;

  /// Account editor: explanation under the local SIP port field.
  ///
  /// In en, this message translates to:
  /// **'0 uses the shared transport. Range 0 to 65535'**
  String get acctFieldLocalPortSub;

  /// Account editor: explanation under the Register switch for SIP.
  ///
  /// In en, this message translates to:
  /// **'Turn off for trunks without registration'**
  String get acctFieldRegisterSubSip;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'SIP Outbound (RFC 5626)'**
  String get acctFieldSipOutbound;

  /// Account editor: explanation under the SIP Outbound switch.
  ///
  /// In en, this message translates to:
  /// **'Keeps a persistent flow through NAT. Needs server support'**
  String get acctFieldSipOutboundSub;

  /// Account editor: settings group title for NAT traversal.
  ///
  /// In en, this message translates to:
  /// **'NAT'**
  String get acctGroupNat;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Use STUN'**
  String get acctFieldUseStun;

  /// Account editor: switch title enabling a TURN relay.
  ///
  /// In en, this message translates to:
  /// **'TURN relay'**
  String get acctFieldTurn;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'TURN server'**
  String get acctFieldTurnServer;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'TURN username'**
  String get acctFieldTurnUsername;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'TURN password'**
  String get acctFieldTurnPassword;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Rewrite Contact header'**
  String get acctFieldContactRewrite;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Rewrite Via header'**
  String get acctFieldViaRewrite;

  /// Account editor: explanation under the Contact/Via rewrite switches.
  ///
  /// In en, this message translates to:
  /// **'Use the address the server sees. Keep on behind NAT'**
  String get acctFieldRewriteSub;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Rewrite SDP address'**
  String get acctFieldSdpRewrite;

  /// Account editor: explanation under the SDP rewrite switch.
  ///
  /// In en, this message translates to:
  /// **'Replace the media address in SDP with the public one'**
  String get acctFieldSdpRewriteSub;

  /// Account editor: selector title (IPv6 mode for SIP signalling).
  ///
  /// In en, this message translates to:
  /// **'IPv6 signalling'**
  String get acctFieldIpv6Sip;

  /// Account editor: selector title (IPv6 mode for media).
  ///
  /// In en, this message translates to:
  /// **'IPv6 media'**
  String get acctFieldIpv6Media;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Advanced media'**
  String get acctGroupAdvancedMedia;

  /// Account editor: footer of the Advanced media group.
  ///
  /// In en, this message translates to:
  /// **'WebRTC gateways need RTCP multiplexing and RTCP feedback.'**
  String get acctGroupAdvancedMediaFooter;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'RTCP multiplexing'**
  String get acctFieldRtcpMux;

  /// Account editor: explanation under the RTCP multiplexing switch.
  ///
  /// In en, this message translates to:
  /// **'Send RTP and RTCP on one port (rtcp-mux)'**
  String get acctFieldRtcpMuxSub;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'RTCP feedback (AVPF)'**
  String get acctFieldRtcpFb;

  /// Account editor: explanation under the RTCP feedback switch.
  ///
  /// In en, this message translates to:
  /// **'Offer RTP/AVPF with NACK. Needed for WebRTC servers'**
  String get acctFieldRtcpFbSub;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get acctGroupSecurity;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Media encryption (SRTP)'**
  String get acctFieldSrtp;

  /// Option: feature used when available but not required.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get acctOptOptional;

  /// Option: feature is mandatory.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get acctOptRequired;

  /// Account editor: selector title for the SRTP key exchange method.
  ///
  /// In en, this message translates to:
  /// **'Key exchange'**
  String get acctFieldKeyExchange;

  /// Account editor: selector title for the required signalling security.
  ///
  /// In en, this message translates to:
  /// **'Secure signalling'**
  String get acctFieldSecureSignaling;

  /// Option: no secure signalling required.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get acctOptNotRequired;

  /// Option: secure signalling only between hops.
  ///
  /// In en, this message translates to:
  /// **'TLS hop-by-hop'**
  String get acctOptTlsHop;

  /// Option: secure signalling end to end (sips).
  ///
  /// In en, this message translates to:
  /// **'TLS end-to-end (sips)'**
  String get acctOptTlsE2e;

  /// Account editor: selector title for the digest algorithm.
  ///
  /// In en, this message translates to:
  /// **'Auth algorithm'**
  String get acctFieldAuthAlgorithm;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Hide caller ID (privacy)'**
  String get acctFieldPrivacy;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Incoming transfers (REFER)'**
  String get acctFieldReferPolicy;

  /// Account editor: selector title: accept or reject presence subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Presence watchers'**
  String get acctFieldWatcherPolicy;

  /// Option: accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acctOptAccept;

  /// Option: reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get acctOptReject;

  /// Account editor: footer of the codecs group.
  ///
  /// In en, this message translates to:
  /// **'Overrides the global codec list for this account.'**
  String get acctGroupCodecsFooter;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Use global codec order'**
  String get acctFieldUseGlobalCodecs;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get acctGroupFeatures;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'Voicemail number'**
  String get acctFieldVoicemailNumber;

  /// Account editor: switch title (message waiting indicator).
  ///
  /// In en, this message translates to:
  /// **'Voicemail indicator (MWI)'**
  String get acctFieldMwi;

  /// Account editor: explanation under the MWI switch.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to message-waiting notifications'**
  String get acctFieldMwiSub;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Publish my presence'**
  String get acctFieldPublishPresence;

  /// Account editor: explanation under the publish-presence switch.
  ///
  /// In en, this message translates to:
  /// **'Let the server share your online status'**
  String get acctFieldPublishPresenceSub;

  /// Switch title: do not disturb for the account.
  ///
  /// In en, this message translates to:
  /// **'Do not disturb'**
  String get acctFieldDnd;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Call forwarding'**
  String get acctFieldForwarding;

  /// Call forwarding option: forward every call.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get acctOptForwardAlways;

  /// Call forwarding option: forward when the line is busy.
  ///
  /// In en, this message translates to:
  /// **'When busy'**
  String get acctOptForwardBusy;

  /// Call forwarding option: forward when nobody answers.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get acctOptForwardNoAnswer;

  /// Account editor: text field title for the forwarding target.
  ///
  /// In en, this message translates to:
  /// **'Forward to'**
  String get acctFieldForwardTo;

  /// Account editor: hint of the forward-to field.
  ///
  /// In en, this message translates to:
  /// **'Number or SIP address'**
  String get acctFieldForwardToHint;

  /// Account editor: numeric field title: seconds to ring before forwarding.
  ///
  /// In en, this message translates to:
  /// **'Ring for (s)'**
  String get acctFieldRingFor;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Auto-answer'**
  String get acctFieldAutoAnswer;

  /// Account editor: numeric field title: seconds before auto-answering.
  ///
  /// In en, this message translates to:
  /// **'Answer after (s)'**
  String get acctFieldAnswerAfter;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Only for intercom calls'**
  String get acctFieldIntercomOnly;

  /// Account editor: explanation under the intercom-only switch.
  ///
  /// In en, this message translates to:
  /// **'Needs an auto-answer header from the PBX'**
  String get acctFieldIntercomOnlySub;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get acctFieldRingtone;

  /// Ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get acctRingtoneClassic;

  /// Ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get acctRingtoneSoft;

  /// Ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get acctRingtoneDigital;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Record calls'**
  String get acctFieldRecordCalls;

  /// Account editor: audio picker title.
  ///
  /// In en, this message translates to:
  /// **'Hold music'**
  String get acctFieldHoldMusic;

  /// Option: inherit the global setting.
  ///
  /// In en, this message translates to:
  /// **'Use global setting'**
  String get acctOptUseGlobal;

  /// Option: use the PBX default.
  ///
  /// In en, this message translates to:
  /// **'PBX default'**
  String get acctOptPbxDefault;

  /// Account editor: audio picker title for the announcement played when a call is answered.
  ///
  /// In en, this message translates to:
  /// **'Opening announcement'**
  String get acctFieldOpeningAnnouncement;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Feature codes'**
  String get acctGroupFeatureCodes;

  /// Account editor: footer of the feature codes group.
  ///
  /// In en, this message translates to:
  /// **'Dialled for park, pickup, DND and forwarding on your PBX.'**
  String get acctGroupFeatureCodesFooter;

  /// Account editor: feature code field title.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get acctFieldPark;

  /// Account editor: feature code field title.
  ///
  /// In en, this message translates to:
  /// **'Group pickup'**
  String get acctFieldGroupPickup;

  /// Account editor: feature code field title.
  ///
  /// In en, this message translates to:
  /// **'Directed pickup prefix'**
  String get acctFieldDirectedPickup;

  /// Account editor: feature code field title.
  ///
  /// In en, this message translates to:
  /// **'Park retrieve prefix'**
  String get acctFieldParkRetrieve;

  /// Account editor: hint of the park retrieve prefix field.
  ///
  /// In en, this message translates to:
  /// **'Dial the slot number'**
  String get acctFieldParkRetrieveHint;

  /// Account editor: explanation under the park retrieve field.
  ///
  /// In en, this message translates to:
  /// **'Prefix dialled before the park slot to pick a parked call back up'**
  String get acctFieldParkRetrieveSub;

  /// Account editor: feature code field title: code that turns do-not-disturb on.
  ///
  /// In en, this message translates to:
  /// **'DND on'**
  String get acctFieldDndOn;

  /// Account editor: feature code field title: code that turns do-not-disturb off.
  ///
  /// In en, this message translates to:
  /// **'DND off'**
  String get acctFieldDndOff;

  /// Account editor: feature code field title: code that turns forwarding on.
  ///
  /// In en, this message translates to:
  /// **'Forward on'**
  String get acctFieldForwardOn;

  /// Account editor: feature code field title: code that turns forwarding off.
  ///
  /// In en, this message translates to:
  /// **'Forward off'**
  String get acctFieldForwardOff;

  /// Account editor: settings group title.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get acctGroupAdvanced;

  /// Account editor: footer of the IAX2 Advanced group.
  ///
  /// In en, this message translates to:
  /// **'DTMF is sent as native IAX2 frames.'**
  String get acctGroupAdvancedFooterIax;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'Caller ID override'**
  String get acctFieldCallerIdOverride;

  /// Account editor: hint of the caller ID override field.
  ///
  /// In en, this message translates to:
  /// **'Use account default'**
  String get acctFieldCallerIdHint;

  /// Account editor: explanation under the caller ID field.
  ///
  /// In en, this message translates to:
  /// **'Caller ID name or number sent to the PBX'**
  String get acctFieldCallerIdSub;

  /// Account editor: selector title (SIP session timers).
  ///
  /// In en, this message translates to:
  /// **'Session timers'**
  String get acctFieldSessionTimers;

  /// Account editor: numeric field title in seconds.
  ///
  /// In en, this message translates to:
  /// **'Session expires (s)'**
  String get acctFieldSessionExpires;

  /// Account editor: range hint.
  ///
  /// In en, this message translates to:
  /// **'Range 90 to 86400'**
  String get acctFieldSessionExpiresSub;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'100rel (reliable provisional)'**
  String get acctField100rel;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Hold method'**
  String get acctFieldHoldMethod;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'DTMF method'**
  String get acctFieldDtmfMethod;

  /// DTMF method option: tones sent in the audio stream.
  ///
  /// In en, this message translates to:
  /// **'In-band'**
  String get acctOptDtmfInband;

  /// Account editor: selector title.
  ///
  /// In en, this message translates to:
  /// **'Redirects (3xx)'**
  String get acctFieldRedirects;

  /// Redirect option: follow automatically (also redirect prompt button).
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get acctOptRedirectFollow;

  /// Redirect option: ask before following.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get acctOptRedirectAsk;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Lock codec after answer'**
  String get acctFieldLockCodec;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Media keep-alive'**
  String get acctFieldMediaKeepAlive;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Drop calls when registration fails'**
  String get acctFieldDropCalls;

  /// Account editor: text field title.
  ///
  /// In en, this message translates to:
  /// **'Extra SIP headers'**
  String get acctFieldExtraHeaders;

  /// Account editor: hint of the extra headers field.
  ///
  /// In en, this message translates to:
  /// **'X-Header: value (one per line)'**
  String get acctFieldExtraHeadersHint;

  /// Account editor: explanation under the retry interval field.
  ///
  /// In en, this message translates to:
  /// **'Wait before retrying a failed registration. Range 0 to 86400'**
  String get acctFieldRetryIntervalSub;

  /// Account editor: numeric field title in milliseconds.
  ///
  /// In en, this message translates to:
  /// **'Unregister timeout (ms)'**
  String get acctFieldUnregTimeout;

  /// Account editor: explanation under the unregister timeout field.
  ///
  /// In en, this message translates to:
  /// **'How long to wait for the unregister reply. Range 0 to 60000'**
  String get acctFieldUnregTimeoutSub;

  /// Account editor: numeric field title in seconds.
  ///
  /// In en, this message translates to:
  /// **'MWI subscription expiry (s)'**
  String get acctFieldMwiExpiry;

  /// Account editor: numeric field title (QoS marking of signalling).
  ///
  /// In en, this message translates to:
  /// **'DSCP for SIP'**
  String get acctFieldDscpSip;

  /// Account editor: explanation.
  ///
  /// In en, this message translates to:
  /// **'QoS marking of signalling. 24 (CS3) is typical'**
  String get acctFieldDscpSipSub;

  /// Account editor: numeric field title (QoS marking of media).
  ///
  /// In en, this message translates to:
  /// **'DSCP for RTP'**
  String get acctFieldDscpRtp;

  /// Account editor: explanation.
  ///
  /// In en, this message translates to:
  /// **'QoS marking of media. 46 (EF) is typical'**
  String get acctFieldDscpRtpSub;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Re-INVITE after network change'**
  String get acctFieldReinvite;

  /// Account editor: switch title.
  ///
  /// In en, this message translates to:
  /// **'Hang up calls on network change'**
  String get acctFieldHangupOnIpChange;

  /// Validation error: the field needs an integer.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get acctValidateInt;

  /// Validation error: server field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a server host name or address'**
  String get acctValidateHostEmpty;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'The server cannot contain spaces'**
  String get acctValidateHostSpaces;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter only host or host:port'**
  String get acctValidateHostFormat;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1 and 65535'**
  String get acctValidatePortRange;

  /// Validation error for the WebSocket path.
  ///
  /// In en, this message translates to:
  /// **'The path must start with \"/\"'**
  String get acctValidateWsStart;

  /// Validation error for the WebSocket path.
  ///
  /// In en, this message translates to:
  /// **'Use at most 120 characters'**
  String get acctValidateWsLength;

  /// Validation error for the WebSocket path.
  ///
  /// In en, this message translates to:
  /// **'The path cannot contain spaces'**
  String get acctValidateWsSpaces;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Extension on your own PBX. UDP 5060, STUN on.'**
  String get acctTplAsteriskDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Use the PJSIP/SIP extension number and its secret. For TLS or WebRTC change the transport later in the account settings.'**
  String get acctTplAsteriskNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'Extension (e.g. 1001)'**
  String get acctTplAsteriskUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Use the extension, auth ID and password from the 3CX portal.'**
  String get acctTpl3cxDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'In 3CX open the extension, then \"Phones > Provisioning\" for the Authentication ID (set it as Authorization user) and password. The FQDN is the one in your 3CX URL.'**
  String get acctTpl3cxNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get acctTpl3cxUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Directory user on a FreeSWITCH server.'**
  String get acctTplFreeswitchDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Use the user id and password from the directory. The default internal profile listens on UDP/TCP 5060.'**
  String get acctTplFreeswitchNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get acctTplFreeswitchUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'SIP proxy registrar. TCP recommended behind NAT.'**
  String get acctTplKamailioDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Use the SIP domain served by your registrar. Add an outbound proxy in the account settings if the registrar is reached through a different host.'**
  String get acctTplKamailioNotes;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Programmable Voice SIP Domain credentials. TLS and SRTP.'**
  String get acctTplTwilioDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Create a SIP Domain in the Twilio console, add a Credential List and enable SIP Registration. Enter the full domain (name.sip.twilio.com) as the server and the credential list user and password. TLS uses port 5061. Twilio supports G.711 only.'**
  String get acctTplTwilioNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'Credential list username'**
  String get acctTplTwilioUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Credential connection. UDP, G.711 / Opus.'**
  String get acctTplTelnyxDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Create a Credential Connection in the Telnyx portal and copy its SIP username and password (not your portal login). Assign a number or outbound voice profile to the connection to place and receive calls.'**
  String get acctTplTelnyxNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'SIP username (credential connection)'**
  String get acctTplTelnyxUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Sub-account username and password. Pick the POP closest to you.'**
  String get acctTplVoipmsDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Use a sub-account created under Sub Accounts, not your main account. Choose the server (POP) closest to you from the VoIP.ms server list and allow it for your IP if required.'**
  String get acctTplVoipmsNotes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'Sub-account (e.g. 123456_phone)'**
  String get acctTplVoipmsUsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'SIP registration with TLS.'**
  String get acctTplVonageDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Vonage Business only offers SIP registration on some plans. Enter the SIP server, user and password shown in the Vonage admin portal for the device.'**
  String get acctTplVonageNotes;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Inter-Asterisk eXchange over UDP 4569. No NAT or SRTP settings.'**
  String get acctTplIax2Description;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'Needs a peer/user in iax.conf (type=friend or user+peer) with the same secret. Asterisk renews IAX2 registrations every 60 s by default. The context is optional and is sent as the called context.'**
  String get acctTplIax2Notes;

  /// Add-account form: label of the username field for this provider.
  ///
  /// In en, this message translates to:
  /// **'IAX2 username'**
  String get acctTplIax2UsernameHint;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'SIP over secure WebSocket with DTLS-SRTP, ICE and RTCP-mux.'**
  String get acctTplWebrtcDescription;

  /// Add-account form: provider-specific setup hint shown above the fields. Provider and product names stay untranslated.
  ///
  /// In en, this message translates to:
  /// **'For Asterisk (webrtc=yes, http.conf TLS on 8089), FreeSWITCH or Kamailio WebSocket endpoints. The server needs a valid TLS certificate. Change the WebSocket path in the account settings if your gateway does not use /ws.'**
  String get acctTplWebrtcNotes;

  /// Add-account provider list: one-line description of the provider template.
  ///
  /// In en, this message translates to:
  /// **'Any SIP registrar. Fill in the details yourself.'**
  String get acctTplGenericDescription;

  /// Add-account form: default label of the username field.
  ///
  /// In en, this message translates to:
  /// **'Extension / username'**
  String get acctTplDefaultUsernameHint;

  /// Blocking engine failure screen: explanation under the title.
  ///
  /// In en, this message translates to:
  /// **'Calls and registration will not work until this is fixed. A bad network or certificate setting is the usual cause.'**
  String get appEngineFailedBody;

  /// Blocking engine failure screen: title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'\'t start the calling engine'**
  String get appEngineFailedTitle;

  /// Banner shown at the top of the app when the calling engine is not running but the user dismissed the failure screen.
  ///
  /// In en, this message translates to:
  /// **'The calling engine is not running'**
  String get appEngineNotRunning;

  /// Shown when the engine failure has no message.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get appUnknownError;

  /// Engine failure screen: button that opens the network settings.
  ///
  /// In en, this message translates to:
  /// **'Open network settings'**
  String get appEngineOpenNetworkSettings;

  /// Engine failure screen: button that starts the built-in simulator (demo mode) instead of the real engine.
  ///
  /// In en, this message translates to:
  /// **'Use simulator (demo)'**
  String get appEngineUseSimulator;

  /// Database recovery screen title when the encryption key is missing.
  ///
  /// In en, this message translates to:
  /// **'Your data is locked'**
  String get appDbLockedTitle;

  /// Database recovery screen title when the database cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Your data cannot be opened'**
  String get appDbUnreadableTitle;

  /// Database recovery screen body when the encryption key is missing.
  ///
  /// In en, this message translates to:
  /// **'Call history, contacts and messages are encrypted on this device, but the encryption key is no longer in the system keychain / keystore (for example after a keychain reset or a restore to a new device).'**
  String get appDbLockedBody;

  /// Database recovery screen body when the database cannot be read.
  ///
  /// In en, this message translates to:
  /// **'The local database could not be read. It may be damaged, or the encryption key does not match.'**
  String get appDbUnreadableBody;

  /// Database recovery screen: explains the choice between Try again and Start fresh.
  ///
  /// In en, this message translates to:
  /// **'Try again if you expect the key to come back (unlock the keychain, sign in to the right user). Starting fresh keeps the old file next to the app data but begins with an empty history, contacts and messages; you will need to add your accounts again.'**
  String get appDbRecoveryAdvice;

  /// Tooltip of the button that copies the technical error details.
  ///
  /// In en, this message translates to:
  /// **'Copy details'**
  String get appDbCopyDetails;

  /// Database recovery screen: button that retries opening the database.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appDbTryAgain;

  /// Database recovery screen: button that discards the old data and starts with an empty database.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get appDbStartFresh;

  /// Dialog title: the server redirected (3xx) the outgoing call.
  ///
  /// In en, this message translates to:
  /// **'Call redirected'**
  String get appRedirectTitle;

  /// Dialog body asking whether to follow a call redirect; target is the new destination address.
  ///
  /// In en, this message translates to:
  /// **'Call redirected to {target} - follow?'**
  String appRedirectMessage(String target);

  /// Redirect dialog: button that cancels the call instead of following the redirect.
  ///
  /// In en, this message translates to:
  /// **'Cancel call'**
  String get appRedirectCancelCall;

  /// Snackbar at start-up: switching database encryption on or off failed; mode is 'encrypt' or 'decrypt', error is the technical reason.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, encrypt{Could not encrypt your data ({error}). Nothing was changed.} other{Could not decrypt your data ({error}). Nothing was changed.}}'**
  String appDbConversionFailed(String mode, String error);

  /// Demo-mode banner note: the native calling engine could not be loaded; error is the technical reason.
  ///
  /// In en, this message translates to:
  /// **'Native engine not available ({error})'**
  String appEngineNativeUnavailable(String error);

  /// Account sheet: shown under a registration error; time is the time of the next automatic retry.
  ///
  /// In en, this message translates to:
  /// **'Retrying at {time}'**
  String acctRetryingAt(String time);

  /// Account sheet: title of the details dialog for a registration failure.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get acctRegistrationError;

  /// Details text in the registration error dialog: SIP response code, reason phrase, status text and transport name.
  ///
  /// In en, this message translates to:
  /// **'SIP {code} {reason}\n{status}\nTransport: {transport}'**
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  );

  /// Accessibility label of the account selector when calling directly without an account.
  ///
  /// In en, this message translates to:
  /// **'Calling from direct, no account'**
  String get acctCallingFromDirect;

  /// Accessibility label of the account selector; name is the selected account.
  ///
  /// In en, this message translates to:
  /// **'Calling from {name}'**
  String acctCallingFromAccount(String name);

  /// Accessibility label of the account selector when no account exists.
  ///
  /// In en, this message translates to:
  /// **'Calling from no account'**
  String get acctCallingFromNone;

  /// Account selector label when there is no account.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get acctNoAccount;

  /// Short duration in seconds, e.g. '60 s'.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String acctSecondsShort(int seconds);

  /// Account sheet: voicemail message counts; both are integers.
  ///
  /// In en, this message translates to:
  /// **'{newCount} new, {oldCount} old'**
  String acctVoicemailCounts(int newCount, int oldCount);

  /// Add-account button / page title / chip.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get acctAddAccount;

  /// Account sheet button: unregister the account from the server.
  ///
  /// In en, this message translates to:
  /// **'Unregister'**
  String get acctUnregister;

  /// Account sheet: explanation under the do-not-disturb switch.
  ///
  /// In en, this message translates to:
  /// **'Reject incoming calls on this account'**
  String get acctSheetDndSub;

  /// Account sheet: label of the server row.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get acctKvServer;

  /// Account sheet: label of the server address the DNS lookup resolved to.
  ///
  /// In en, this message translates to:
  /// **'Resolved server'**
  String get acctKvResolvedServer;

  /// Account sheet: label of the TLS client certificate row.
  ///
  /// In en, this message translates to:
  /// **'Client cert'**
  String get acctKvClientCert;

  /// Account sheet: value of the client certificate row.
  ///
  /// In en, this message translates to:
  /// **'Presented to the server (mutual TLS)'**
  String get acctKvClientCertValue;

  /// Account sheet: label of the SIP Contact row.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get acctKvContact;

  /// Account sheet: label of the registration expiry row.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get acctKvExpiresIn;

  /// Account sheet: label of the voicemail row.
  ///
  /// In en, this message translates to:
  /// **'Voicemail'**
  String get acctKvVoicemail;

  /// Error dialog button that opens the SIP trace in diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Open SIP trace'**
  String get acctOpenSipTrace;

  /// Dialler: button shown when no account exists.
  ///
  /// In en, this message translates to:
  /// **'Add an account'**
  String get acctAddAnAccount;

  /// Tooltip of the account selector in the dialler.
  ///
  /// In en, this message translates to:
  /// **'Choose the account to call from'**
  String get acctChooseAccountTooltip;

  /// Account selector entry for calling a SIP address directly without an account.
  ///
  /// In en, this message translates to:
  /// **'Direct (no account)'**
  String get acctDirectNoAccount;

  /// Add-account form: error when username or server is empty.
  ///
  /// In en, this message translates to:
  /// **'Username and server are required'**
  String get onboardingRequired;

  /// Add-account form: helper text under the server field; port is an integer.
  ///
  /// In en, this message translates to:
  /// **'Port {port} is used unless you add :port'**
  String onboardingDefaultPortHelper(int port);

  /// Add-account form footer for IAX2 accounts.
  ///
  /// In en, this message translates to:
  /// **'You can fine-tune codecs and registration later in Settings.'**
  String get onboardingFineTuneIax;

  /// Add-account form footer for SIP accounts.
  ///
  /// In en, this message translates to:
  /// **'You can fine-tune transport, NAT, security and codecs later in Settings.'**
  String get onboardingFineTuneSip;

  /// Display name given to the demo account created by 'Skip for now'.
  ///
  /// In en, this message translates to:
  /// **'Demo user'**
  String get onboardingDemoUser;

  /// Label of the demo account created by 'Skip for now'.
  ///
  /// In en, this message translates to:
  /// **'Demo account'**
  String get onboardingDemoAccount;

  /// Onboarding first page title. SoftphonePro is the product name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SoftphonePro'**
  String get onboardingWelcomeTitle;

  /// Onboarding first page body text.
  ///
  /// In en, this message translates to:
  /// **'Professional calling for every platform - free and open source. No ads, no tracking.'**
  String get onboardingWelcomeText;

  /// Onboarding first page button.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Onboarding second page title.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get onboardingPermissionsTitle;

  /// Onboarding second page body explaining why microphone and notification permissions are requested.
  ///
  /// In en, this message translates to:
  /// **'SoftphonePro needs the microphone to carry your voice, and notifications to tell you about incoming calls and messages. Nothing leaves your device except your calls.'**
  String get onboardingPermissionsText;

  /// Add-account flow: heading above the provider list.
  ///
  /// In en, this message translates to:
  /// **'Choose your provider'**
  String get onboardingChooseProvider;

  /// Add-account flow: sub-heading under 'Choose your provider'.
  ///
  /// In en, this message translates to:
  /// **'We prefill transport, ports and NAT settings for you.'**
  String get onboardingChooseProviderSub;

  /// Button that scans a provisioning QR code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get onboardingScanQr;

  /// Button that imports a provisioning configuration from a URL.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get onboardingImportUrl;

  /// Onboarding button that skips account setup and creates a demo account.
  ///
  /// In en, this message translates to:
  /// **'Skip for now (demo mode)'**
  String get onboardingSkip;

  /// Tooltip of the visibility toggle on the password field (password is currently visible).
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get onboardingHidePassword;

  /// Tooltip of the visibility toggle on the password field (password is currently hidden).
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get onboardingShowPassword;

  /// Add-account form: IAX2 context field label.
  ///
  /// In en, this message translates to:
  /// **'Context (optional)'**
  String get onboardingContextOptional;

  /// Add-account form: display name field label.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get onboardingDisplayNameOptional;

  /// Add-account form: account label field label.
  ///
  /// In en, this message translates to:
  /// **'Account label (optional)'**
  String get onboardingLabelOptional;

  /// Add-account form: IAX2 caller ID field label.
  ///
  /// In en, this message translates to:
  /// **'Caller ID (optional)'**
  String get onboardingCallerIdOptional;

  /// Add-account form: authorization user field label.
  ///
  /// In en, this message translates to:
  /// **'Authorization user (if different)'**
  String get onboardingAuthUserOptional;

  /// Registration failure reason for SIP 401/403; code is the SIP status code.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password ({code})'**
  String acctRegWrongCredentials(int code);

  /// Registration failure reason for SIP 404.
  ///
  /// In en, this message translates to:
  /// **'Account not found on the server (404)'**
  String get acctRegNotFound;

  /// Registration failure reason for SIP 408.
  ///
  /// In en, this message translates to:
  /// **'Server did not answer (408)'**
  String get acctRegNoAnswer;

  /// Registration failure reason for SIP 423.
  ///
  /// In en, this message translates to:
  /// **'Registration interval too short (423)'**
  String get acctRegIntervalTooShort;

  /// Registration failure reason for SIP 480.
  ///
  /// In en, this message translates to:
  /// **'Server temporarily unavailable (480)'**
  String get acctRegTemporarilyUnavailable;

  /// Registration failure reason for SIP 503.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable (503)'**
  String get acctRegServiceUnavailable;

  /// Generic registration failure message.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get acctRegFailed;

  /// Registration failure message with the SIP status code.
  ///
  /// In en, this message translates to:
  /// **'Registration failed ({code})'**
  String acctRegFailedWithCode(int code);

  /// Snackbar: switching an account's registration on/off failed.
  ///
  /// In en, this message translates to:
  /// **'Could not change registration'**
  String get acctNoticeRegistrationChange;

  /// Snackbar: the engine rejected an account's configuration; name is the account name.
  ///
  /// In en, this message translates to:
  /// **'Could not apply account \"{name}\"'**
  String acctNoticeApplyFailed(String name);

  /// Snackbar: an account returned from its backup registrar to the primary one.
  ///
  /// In en, this message translates to:
  /// **'Back on the primary server for {name}'**
  String acctNoticeBackOnPrimary(String name);

  /// Snackbar: an account failed over to its backup registrar.
  ///
  /// In en, this message translates to:
  /// **'Using backup server for {name}'**
  String acctNoticeUsingBackup(String name);

  /// Status message while waiting to place a link/CLI call: account is registered.
  ///
  /// In en, this message translates to:
  /// **'Account {name} is registered'**
  String callDialAccountRegistered(String name);

  /// Status while waiting to place a call: account still registering.
  ///
  /// In en, this message translates to:
  /// **'Account {name} is still registering'**
  String callDialAccountRegistering(String name);

  /// Status while waiting to place a call: account not registered yet.
  ///
  /// In en, this message translates to:
  /// **'Account {name} is not registered yet'**
  String callDialAccountOffline(String name);

  /// Status while waiting to place a call: registration failed.
  ///
  /// In en, this message translates to:
  /// **'Account {name} is not registered (registration failed)'**
  String callDialAccountFailed(String name);

  /// Status while waiting to place a call: account disabled.
  ///
  /// In en, this message translates to:
  /// **'Account {name} is disabled'**
  String callDialAccountDisabled(String name);

  /// Error: SIP engine failed to start (no detail).
  ///
  /// In en, this message translates to:
  /// **'The call engine failed to start'**
  String get callDialEngineFailed;

  /// Error: SIP engine failed to start, with technical reason.
  ///
  /// In en, this message translates to:
  /// **'The call engine failed to start: {reason}'**
  String callDialEngineFailedWithReason(String reason);

  /// Status: waiting for the SIP engine to start before dialling.
  ///
  /// In en, this message translates to:
  /// **'The call engine is still starting'**
  String get callDialEngineStarting;

  /// Account status message followed by the failure reason.
  ///
  /// In en, this message translates to:
  /// **'{status}: {reason}'**
  String callDialBlockedWithReason(String status, String reason);

  /// Shown when a call from a link or command line could not be placed in time. status is a sentence like "Account X is still registering".
  ///
  /// In en, this message translates to:
  /// **'{status} after {seconds} s; the call was not placed'**
  String callDialTimedOut(String status, int seconds);

  /// Call history reason for a call that was cut off because the app was closed or crashed.
  ///
  /// In en, this message translates to:
  /// **'The app was closed during the call'**
  String get callJournalInterrupted;

  /// Error notice: a command-line link had no argument.
  ///
  /// In en, this message translates to:
  /// **'Missing argument'**
  String get callLinkMissingArgument;

  /// Error notice: provisioning link rejected because it is not https.
  ///
  /// In en, this message translates to:
  /// **'Configuration links must use https'**
  String get callLinkHttpsRequired;

  /// Error notice: LAN Link URL is invalid.
  ///
  /// In en, this message translates to:
  /// **'That LAN link is not valid'**
  String get callLinkInvalidLan;

  /// Notice after connecting to a LAN peer from a link.
  ///
  /// In en, this message translates to:
  /// **'Connected to {name}'**
  String callLinkConnectedTo(String name);

  /// Error notice: LAN link connection failed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to that device'**
  String get callLinkConnectFailed;

  /// Error notice title: a link/CLI call could not be placed; details follow.
  ///
  /// In en, this message translates to:
  /// **'Could not place the call to {target}'**
  String callLinkCallFailed(String target);

  /// Confirmation dialog title for importing a provisioning configuration from a link.
  ///
  /// In en, this message translates to:
  /// **'Import configuration'**
  String get callLinkImportTitle;

  /// Confirmation dialog body for a provisioning link without settings.
  ///
  /// In en, this message translates to:
  /// **'Import configuration from {host}? It will add {accounts, plural, =1{1 account} other{{accounts} accounts}}.'**
  String callLinkImportBody(String host, int accounts);

  /// Confirmation dialog body for a provisioning link that also changes settings.
  ///
  /// In en, this message translates to:
  /// **'Import configuration from {host}? It will add {accounts, plural, =1{1 account} other{{accounts} accounts}} and {settings} setting(s).'**
  String callLinkImportBodyWithSettings(
    String host,
    int accounts,
    int settings,
  );

  /// Incoming call tag: call was forwarded from this number.
  ///
  /// In en, this message translates to:
  /// **'Forwarded from {number}'**
  String callIdentityForwardedFrom(String number);

  /// Incoming call tag: forwarded from number with the diversion reason (e.g. no-answer).
  ///
  /// In en, this message translates to:
  /// **'Forwarded from {number} ({reason})'**
  String callIdentityForwardedFromReason(String number, String reason);

  /// Incoming call tag: call was transferred by this party.
  ///
  /// In en, this message translates to:
  /// **'Transferred by {number}'**
  String callIdentityTransferredBy(String number);

  /// Ringtone picker option: OS default ringtone.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get callRingtoneSystemDefault;

  /// Built-in ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get callRingtoneClassic;

  /// Built-in ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get callRingtoneSoft;

  /// Built-in ringtone name.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get callRingtoneDigital;

  /// Incoming call: the SIP From number when it differs from the asserted caller number.
  ///
  /// In en, this message translates to:
  /// **'From {number}'**
  String callIdentityFrom(String number);

  /// Call detail line: caller ID asserted by the network.
  ///
  /// In en, this message translates to:
  /// **'Caller ID {number}'**
  String callIdentityCallerId(String number);

  /// Call detail line: caller ID asserted by the network, with a name.
  ///
  /// In en, this message translates to:
  /// **'Caller ID {name} {number}'**
  String callIdentityCallerIdWithName(String name, String number);

  /// Shown while a blind transfer is in progress.
  ///
  /// In en, this message translates to:
  /// **'Transferring...'**
  String get callTransferring;

  /// Banner title when the server did not confirm a call transfer in time.
  ///
  /// In en, this message translates to:
  /// **'Transfer not confirmed by the server'**
  String get callTransferNotConfirmed;

  /// Banner body under "Transfer not confirmed by the server".
  ///
  /// In en, this message translates to:
  /// **'The call is still up. Keep it, or send the transfer again.'**
  String get callTransferStalledHint;

  /// Button on the stalled-transfer banner: keep the call and stop the transfer.
  ///
  /// In en, this message translates to:
  /// **'Keep call'**
  String get callTransferKeepCall;

  /// Chip shown while an opening announcement is played into the call.
  ///
  /// In en, this message translates to:
  /// **'Playing announcement…'**
  String get callAnnouncementOpening;

  /// Chip shown while a transfer announcement is played into the call.
  ///
  /// In en, this message translates to:
  /// **'Playing transfer notice…'**
  String get callAnnouncementTransfer;

  /// Chip shown while a call-recording notice is played into the call.
  ///
  /// In en, this message translates to:
  /// **'Playing recording notice…'**
  String get callAnnouncementRecording;

  /// Button on the announcement chip: skip the playing announcement.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get callAnnouncementSkip;

  /// Tooltip of the in-call noise cancellation chip when only the microphone side is on.
  ///
  /// In en, this message translates to:
  /// **'AI noise cancellation: your microphone'**
  String get callNoiseTooltipMic;

  /// Tooltip of the in-call noise cancellation chip when only the incoming side is on.
  ///
  /// In en, this message translates to:
  /// **'AI noise cancellation: other participants'**
  String get callNoiseTooltipIncoming;

  /// Tooltip of the in-call noise cancellation chip when both sides are on.
  ///
  /// In en, this message translates to:
  /// **'AI noise cancellation: your microphone and other participants'**
  String get callNoiseTooltipBoth;

  /// Small in-call indicator that noise cancellation is active.
  ///
  /// In en, this message translates to:
  /// **'Noise cancellation on'**
  String get callNoiseOn;

  /// In-call More sheet: title of the noise cancellation switch.
  ///
  /// In en, this message translates to:
  /// **'Noise cancellation'**
  String get callNoiseTitle;

  /// In-call More sheet subtitle when noise cancellation is on; strength is like "High (80%)".
  ///
  /// In en, this message translates to:
  /// **'My microphone: {strength}'**
  String callNoiseMicStrength(String strength);

  /// In-call More sheet subtitle when noise cancellation is off.
  ///
  /// In en, this message translates to:
  /// **'Remove background noise from my microphone'**
  String get callNoiseMicOffHint;

  /// Call history: outcome label of a call (Answered).
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get callResultAnswered;

  /// Call history: outcome label of a call (Missed).
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get callResultMissed;

  /// Call history: outcome label of a call (Declined).
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get callResultRejected;

  /// Call history: outcome label of a call (Failed).
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get callResultFailed;

  /// Call history: outcome label of a call (Busy).
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get callResultBusy;

  /// Call history: outcome label of a call (Forwarded).
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get callResultForwarded;

  /// Call history: outcome label of a call (Transferred).
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get callResultTransferred;

  /// Call history: outcome label of a call (Handed off).
  ///
  /// In en, this message translates to:
  /// **'Handed off'**
  String get callResultHandedOff;

  /// Call history: outcome label of a call (Interrupted).
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
  String get callResultInterrupted;

  /// Label/tooltip of the green call button on the dial pad and elsewhere.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get keypadCall;

  /// Notice when long-pressing 1 on the dial pad and the account has no voicemail number.
  ///
  /// In en, this message translates to:
  /// **'No voicemail number configured for this account'**
  String get keypadNoVoicemail;

  /// Hint under the call button: the call will be placed directly to an IP/URI without an account.
  ///
  /// In en, this message translates to:
  /// **'Call directly (no account)'**
  String get keypadCallDirectly;

  /// Hint under the call button when no account exists.
  ///
  /// In en, this message translates to:
  /// **'Add an account to place calls'**
  String get keypadAddAccount;

  /// Hint under the call button: which account will place the call.
  ///
  /// In en, this message translates to:
  /// **'Call from {account}'**
  String keypadCallFrom(String account);

  /// Heading of the quick list of recently dialled numbers above the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get keypadRecent;

  /// Heading of the quick list of contact suggestions above the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get keypadSuggestions;

  /// Accessibility label of the number entry field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get keypadPhoneNumber;

  /// Tooltip of the paste button next to the number field.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get keypadPaste;

  /// Hint text of the number field on the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Enter number'**
  String get keypadEnterNumber;

  /// Tooltip of the backspace button on the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Backspace (long press to clear)'**
  String get keypadBackspace;

  /// Empty state of the suggestions panel (no input yet).
  ///
  /// In en, this message translates to:
  /// **'Type a name or number'**
  String get keypadTypeNameOrNumber;

  /// Empty state of the suggestions panel (input has no matches).
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get keypadNoMatches;

  /// Explanation under the empty suggestions panel.
  ///
  /// In en, this message translates to:
  /// **'Suggestions come from contacts and recent calls'**
  String get keypadSuggestionsHint;

  /// Tooltip of the call button on a suggestion row.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String keypadCallPerson(String name);

  /// Accessibility label of the * key on the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get dialKeyStar;

  /// Accessibility label of the # key on the dial pad.
  ///
  /// In en, this message translates to:
  /// **'Pound'**
  String get dialKeyPound;

  /// Accessibility hint of the 0 key.
  ///
  /// In en, this message translates to:
  /// **'Long press for plus'**
  String get dialKeyLongPressPlus;

  /// Accessibility hint of dial pad keys 1-9 with speed dial.
  ///
  /// In en, this message translates to:
  /// **'Long press for speed dial'**
  String get dialKeyLongPressSpeedDial;

  /// Accessibility hint of the 1 key.
  ///
  /// In en, this message translates to:
  /// **'Long press for voicemail'**
  String get dialKeyLongPressVoicemail;

  /// Tooltip of the minimise button on the in-call page.
  ///
  /// In en, this message translates to:
  /// **'Back to app (call stays active)'**
  String get callBackToApp;

  /// Small red badge shown while the call is being recorded.
  ///
  /// In en, this message translates to:
  /// **'REC'**
  String get callRecBadge;

  /// Button on the in-call page that hides the in-call dial pad.
  ///
  /// In en, this message translates to:
  /// **'Hide keypad'**
  String get callHideKeypad;

  /// In-call action button: mute the microphone.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMute;

  /// In-call action button: show the dial pad for DTMF.
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get callKeypad;

  /// In-call action button / audio route name: loudspeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get callSpeaker;

  /// In-call audio route name.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get callRouteBluetooth;

  /// In-call audio route name (wired headset).
  ///
  /// In en, this message translates to:
  /// **'Headset'**
  String get callRouteHeadset;

  /// In-call action button: take the call off hold.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get callResume;

  /// In-call action button: put the call on hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get callHold;

  /// In-call action button: start a second call.
  ///
  /// In en, this message translates to:
  /// **'Add call'**
  String get callAddCall;

  /// In-call action button: transfer the call.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get callTransfer;

  /// In-call action button label: stop recording.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get callStop;

  /// In-call action button label: start recording.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get callRecord;

  /// In-call action button: split a conference into separate calls.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get callSplit;

  /// In-call action button: merge calls into a conference.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get callMerge;

  /// Button on a stacked call card: swap active and held calls.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get callSwap;

  /// Label/tooltip of the red hang-up button.
  ///
  /// In en, this message translates to:
  /// **'End call'**
  String get callEndCall;

  /// Tooltip of the hang-up button on a stacked call card.
  ///
  /// In en, this message translates to:
  /// **'End call with {name}'**
  String callEndCallWith(String name);

  /// Banner shown during an attended transfer consultation call.
  ///
  /// In en, this message translates to:
  /// **'Attended transfer. The original caller is on hold.'**
  String get callAttendedTransferHint;

  /// Button on the attended-transfer banner.
  ///
  /// In en, this message translates to:
  /// **'Complete transfer'**
  String get callCompleteTransfer;

  /// Label of the banner for a second incoming call while on a call.
  ///
  /// In en, this message translates to:
  /// **'Call waiting'**
  String get callWaiting;

  /// Tooltip of the answer button on the call waiting banner.
  ///
  /// In en, this message translates to:
  /// **'Hold current call and answer'**
  String get callHoldAndAnswer;

  /// Button/tooltip: reject an incoming call.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get callDecline;

  /// Button: answer an incoming call.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get callAnswer;

  /// Title of the full-screen incoming call page.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get callIncomingCall;

  /// Incoming call button: decline and reply with a text message.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get callReply;

  /// Incoming call button: send the caller to voicemail.
  ///
  /// In en, this message translates to:
  /// **'Voicemail'**
  String get callVoicemail;

  /// Incoming call button: forward the ringing call to another device on the LAN.
  ///
  /// In en, this message translates to:
  /// **'To device'**
  String get callToDevice;

  /// Quick reply text message offered when declining a call.
  ///
  /// In en, this message translates to:
  /// **'Can\'\'t talk now, I\'\'ll call you back.'**
  String get callQuickReplyBusy;

  /// Quick reply text message offered when declining a call.
  ///
  /// In en, this message translates to:
  /// **'I\'\'m in a meeting. Text me?'**
  String get callQuickReplyMeeting;

  /// Quick reply text message offered when declining a call.
  ///
  /// In en, this message translates to:
  /// **'On my way.'**
  String get callQuickReplyOnMyWay;

  /// Accessibility label of the green call bar.
  ///
  /// In en, this message translates to:
  /// **'Return to call with {name}'**
  String callReturnToCallWith(String name);

  /// Text of the green call bar when a call is ringing.
  ///
  /// In en, this message translates to:
  /// **'Incoming: {name}'**
  String callBarIncoming(String name);

  /// Text of the green call bar during a call.
  ///
  /// In en, this message translates to:
  /// **'In call with {name}'**
  String callBarInCallWith(String name);

  /// Call quality stats label (also call info row).
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get callStatsCodec;

  /// Call quality stats label: network jitter.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get callStatsJitter;

  /// Call quality stats label.
  ///
  /// In en, this message translates to:
  /// **'Packet loss'**
  String get callStatsPacketLoss;

  /// Call quality stats label: round-trip time.
  ///
  /// In en, this message translates to:
  /// **'Round trip'**
  String get callStatsRoundTrip;

  /// Call quality stats label: media encryption kind (SRTP or RTP).
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get callStatsMedia;

  /// Label above the MOS (call quality score) sparkline.
  ///
  /// In en, this message translates to:
  /// **'MOS history'**
  String get callStatsMosHistory;

  /// Title of the call quality sheet and More-sheet row.
  ///
  /// In en, this message translates to:
  /// **'Call quality'**
  String get callQualityTitle;

  /// Title of the transfer sheet.
  ///
  /// In en, this message translates to:
  /// **'Transfer call'**
  String get callTransferTitle;

  /// Transfer mode segment: blind transfer.
  ///
  /// In en, this message translates to:
  /// **'Blind'**
  String get callTransferModeBlind;

  /// Transfer mode segment: attended (consult first) transfer.
  ///
  /// In en, this message translates to:
  /// **'Attended'**
  String get callTransferModeAttended;

  /// Transfer mode segment: hand the call to a device on the local network.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get callTransferModeLan;

  /// Tooltip of the LAN transfer mode segment.
  ///
  /// In en, this message translates to:
  /// **'LAN device'**
  String get callTransferModeLanTooltip;

  /// Transfer sheet, LAN mode: LAN Link on but no devices.
  ///
  /// In en, this message translates to:
  /// **'No paired SoftphonePro devices found on your network. Pair one on the LAN page.'**
  String get callTransferNoLanDevices;

  /// Transfer sheet, LAN mode: LAN Link is switched off.
  ///
  /// In en, this message translates to:
  /// **'Turn on LAN Link (Settings, LAN Link) to hand this call to another device on your network.'**
  String get callTransferLanDisabled;

  /// Button on a LAN device row: consult the device before handing over the call.
  ///
  /// In en, this message translates to:
  /// **'Talk first'**
  String get callTransferTalkFirst;

  /// Explanation under the transfer mode selector for blind transfer.
  ///
  /// In en, this message translates to:
  /// **'Hands the caller over immediately. You are disconnected.'**
  String get callTransferBlindHint;

  /// Explanation under the transfer mode selector for attended transfer.
  ///
  /// In en, this message translates to:
  /// **'Puts the caller on hold and calls the target first. Complete the transfer once they answer.'**
  String get callTransferAttendedHint;

  /// Label of the transfer target text field.
  ///
  /// In en, this message translates to:
  /// **'Number or SIP address'**
  String get callTransferNumberLabel;

  /// Button: perform blind transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer now'**
  String get callTransferNow;

  /// Button: start attended transfer consultation call.
  ///
  /// In en, this message translates to:
  /// **'Call and consult'**
  String get callTransferCallAndConsult;

  /// Dialog title and More-sheet row title for retrieving a parked call.
  ///
  /// In en, this message translates to:
  /// **'Retrieve parked call'**
  String get callRetrieveParkedTitle;

  /// Hint text of the park slot field.
  ///
  /// In en, this message translates to:
  /// **'Park slot, e.g. 701'**
  String get callRetrieveParkedHint;

  /// More sheet row title on mobile.
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get callMoreAudioOutput;

  /// More sheet row title on desktop.
  ///
  /// In en, this message translates to:
  /// **'Audio devices'**
  String get callMoreAudioDevices;

  /// More sheet row subtitle on mobile.
  ///
  /// In en, this message translates to:
  /// **'Phone, speaker, Bluetooth, headset'**
  String get callMoreAudioOutputSubtitle;

  /// More sheet row subtitle on desktop.
  ///
  /// In en, this message translates to:
  /// **'Choose microphone and speaker'**
  String get callMoreAudioDevicesSubtitle;

  /// More sheet row title: park the call.
  ///
  /// In en, this message translates to:
  /// **'Park call'**
  String get callMoreParkCall;

  /// More sheet row subtitle for parking.
  ///
  /// In en, this message translates to:
  /// **'Transfer to the park feature code'**
  String get callMoreParkCallSubtitle;

  /// More sheet row subtitle for retrieving a parked call.
  ///
  /// In en, this message translates to:
  /// **'Dial a park slot'**
  String get callMoreRetrieveParkedSubtitle;

  /// More sheet row title: send a sequence of tones.
  ///
  /// In en, this message translates to:
  /// **'Send DTMF digits'**
  String get callMoreSendDtmf;

  /// More sheet row subtitle for sending DTMF.
  ///
  /// In en, this message translates to:
  /// **'Type a whole sequence, e.g. a PIN'**
  String get callMoreSendDtmfSubtitle;

  /// Dialog title for sending DTMF tones.
  ///
  /// In en, this message translates to:
  /// **'Send DTMF'**
  String get callSendDtmfTitle;

  /// More sheet row title and dialog title: technical call information.
  ///
  /// In en, this message translates to:
  /// **'Call info'**
  String get callMoreCallInfo;

  /// More sheet row subtitle for live call quality.
  ///
  /// In en, this message translates to:
  /// **'Live MOS, jitter, loss and round-trip time'**
  String get callMoreQualitySubtitle;

  /// More sheet row title: open SIP trace.
  ///
  /// In en, this message translates to:
  /// **'SIP trace'**
  String get callMoreSipTrace;

  /// More sheet row subtitle for SIP trace.
  ///
  /// In en, this message translates to:
  /// **'Ladder diagram of this call'**
  String get callMoreSipTraceSubtitle;

  /// Call info dialog row label: the remote party URI.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get callInfoRemote;

  /// Call info dialog row label: local account URI.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get callInfoAccount;

  /// Call info dialog row label: call state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get callInfoState;

  /// Call info dialog row label: encryption of media and signalling.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get callInfoSecure;

  /// Call info dialog: signalling is not encrypted (shown after "RTP / ").
  ///
  /// In en, this message translates to:
  /// **'plain signalling'**
  String get callInfoPlainSignalling;

  /// Audio route name: phone earpiece.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get callRoutePhone;

  /// Audio route name.
  ///
  /// In en, this message translates to:
  /// **'Wired headset'**
  String get callRouteWiredHeadset;

  /// Audio sheet section header.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get callAudioMicrophone;

  /// Accessibility label of a call card; state is e.g. Connected.
  ///
  /// In en, this message translates to:
  /// **'Call with {name}, {state}'**
  String callCardSemantics(String name, String state);

  /// Tooltip of the mute button while muted.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get callUnmute;

  /// Tooltip of the record button while recording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get callStopRecording;

  /// Tooltip of the split button.
  ///
  /// In en, this message translates to:
  /// **'Split conference'**
  String get callSplitConference;

  /// Tooltip of the merge calls button.
  ///
  /// In en, this message translates to:
  /// **'Merge calls'**
  String get callMergeCalls;

  /// Tooltip of the swap calls button.
  ///
  /// In en, this message translates to:
  /// **'Swap calls'**
  String get callSwapCalls;

  /// Banner on a call card during an attended transfer.
  ///
  /// In en, this message translates to:
  /// **'Attended transfer: the original caller is on hold.'**
  String get callAttendedTransferBanner;

  /// Header of the desktop panel listing active calls.
  ///
  /// In en, this message translates to:
  /// **'Active calls'**
  String get callActiveCalls;

  /// Title of the conference volume sliders box.
  ///
  /// In en, this message translates to:
  /// **'Conference levels'**
  String get callConferenceLevels;

  /// Conference slider label: volume of a participant.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get callLevelVolume;

  /// Conference slider label: microphone level sent to a participant.
  ///
  /// In en, this message translates to:
  /// **'Mic to party'**
  String get callLevelMicToParty;

  /// Accessibility value of a slider.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String callPercentSemantics(int percent);

  /// Call failure explanation shown as an error notice (SIP 400).
  ///
  /// In en, this message translates to:
  /// **'Invalid number (400)'**
  String get callFailInvalidNumber;

  /// Call failure explanation (SIP 401/403).
  ///
  /// In en, this message translates to:
  /// **'Call not authorised ({code})'**
  String callFailNotAuthorised(String code);

  /// Call failure explanation (SIP 404).
  ///
  /// In en, this message translates to:
  /// **'Number not found (404)'**
  String get callFailNumberNotFound;

  /// Call failure explanation (SIP 408).
  ///
  /// In en, this message translates to:
  /// **'No answer from server (408)'**
  String get callFailNoAnswerFromServer;

  /// Call failure explanation (SIP 480).
  ///
  /// In en, this message translates to:
  /// **'Temporarily unavailable (480)'**
  String get callFailTemporarilyUnavailable;

  /// Call failure explanation (SIP 484).
  ///
  /// In en, this message translates to:
  /// **'Incomplete number (484)'**
  String get callFailIncompleteNumber;

  /// Call failure explanation (SIP 486/600).
  ///
  /// In en, this message translates to:
  /// **'Busy ({code})'**
  String callFailBusy(String code);

  /// Call failure explanation (SIP 487).
  ///
  /// In en, this message translates to:
  /// **'Call cancelled (487)'**
  String get callFailCancelled;

  /// Call failure explanation (SIP 488/606).
  ///
  /// In en, this message translates to:
  /// **'No compatible codec ({code})'**
  String callFailNoCompatibleCodec(String code);

  /// Call failure explanation (SIP 503).
  ///
  /// In en, this message translates to:
  /// **'Service unavailable (503)'**
  String get callFailServiceUnavailable;

  /// Call failure explanation (SIP 603).
  ///
  /// In en, this message translates to:
  /// **'Call declined (603)'**
  String get callFailDeclined;

  /// Generic call failure with no further detail.
  ///
  /// In en, this message translates to:
  /// **'Call failed'**
  String get callFailGeneric;

  /// Generic call failure with SIP status code.
  ///
  /// In en, this message translates to:
  /// **'Call failed ({code})'**
  String callFailGenericWithCode(String code);

  /// Call failure: server-provided reason followed by SIP status code.
  ///
  /// In en, this message translates to:
  /// **'{reason} ({code})'**
  String callFailReasonWithCode(String reason, String code);

  /// Android foreground service notification text while a call is active.
  ///
  /// In en, this message translates to:
  /// **'Call in progress'**
  String get callForegroundServiceText;

  /// Tray icon tooltip while in a call.
  ///
  /// In en, this message translates to:
  /// **'In a call'**
  String get callTrayInCall;

  /// Call history reason: the caller is on the blocklist.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get callHistoryBlocked;

  /// Call history reason: anonymous callers are rejected.
  ///
  /// In en, this message translates to:
  /// **'Anonymity disallowed'**
  String get callHistoryAnonymityDisallowed;

  /// Call history reason: rejected because Do Not Disturb is on.
  ///
  /// In en, this message translates to:
  /// **'Do not disturb'**
  String get callHistoryDoNotDisturb;

  /// Call history reason: rejected because already on a call.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get callHistoryBusy;

  /// Call history reason: forwarded by the "always forward" rule.
  ///
  /// In en, this message translates to:
  /// **'Forwarded (always)'**
  String get callHistoryForwardedAlways;

  /// Call history reason: forwarded by the "forward when busy" rule.
  ///
  /// In en, this message translates to:
  /// **'Forwarded (busy)'**
  String get callHistoryForwardedBusy;

  /// Call history reason: the user sent the ringing call to voicemail.
  ///
  /// In en, this message translates to:
  /// **'Sent to voicemail'**
  String get callHistorySentToVoicemail;

  /// Call history reason: the user redirected the ringing call.
  ///
  /// In en, this message translates to:
  /// **'Redirected'**
  String get callHistoryRedirected;

  /// Incoming call notification body.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get callIncomingNotificationBody;

  /// Incoming call notification body naming the account that receives the call.
  ///
  /// In en, this message translates to:
  /// **'Incoming call on {account}'**
  String callIncomingNotificationBodyOnAccount(String account);

  /// Title of the missed call notification.
  ///
  /// In en, this message translates to:
  /// **'Missed call'**
  String get callMissedNotificationTitle;

  /// Error notice when a call is attempted before the SIP engine has started.
  ///
  /// In en, this message translates to:
  /// **'The call engine is not running yet'**
  String get callErrEngineNotRunning;

  /// Error notice when dialling without any account.
  ///
  /// In en, this message translates to:
  /// **'Add an account to place calls'**
  String get callErrAddAccount;

  /// Error notice title when placing a call failed; details follow.
  ///
  /// In en, this message translates to:
  /// **'Could not place the call'**
  String get callErrCouldNotPlace;

  /// Error notice when dialling through an account whose registration failed or is disabled.
  ///
  /// In en, this message translates to:
  /// **'{account} is not registered'**
  String callErrAccountNotRegistered(String account);

  /// Error notice title when answering failed.
  ///
  /// In en, this message translates to:
  /// **'Could not answer'**
  String get callErrCouldNotAnswer;

  /// Error notice when sending a call to voicemail without a configured number.
  ///
  /// In en, this message translates to:
  /// **'No voicemail number set for this account'**
  String get callErrNoVoicemailNumber;

  /// Error notice title when a call transfer failed; details follow.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get callErrTransferFailed;

  /// Error notice when the server rejected a call transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed: {reason} ({code})'**
  String callErrTransferFailedWithReason(String reason, int code);

  /// Error notice title when creating a conference failed.
  ///
  /// In en, this message translates to:
  /// **'Could not merge calls'**
  String get callErrCouldNotMerge;

  /// Error notice title.
  ///
  /// In en, this message translates to:
  /// **'Could not start recording'**
  String get callErrCouldNotStartRecording;

  /// Error notice title.
  ///
  /// In en, this message translates to:
  /// **'Could not stop recording'**
  String get callErrCouldNotStopRecording;

  /// Notice shown when a call is being parked; code is the park feature code.
  ///
  /// In en, this message translates to:
  /// **'Parking call (dial {code})'**
  String callParkingNotice(String code);

  /// Error notice title when parking a call failed.
  ///
  /// In en, this message translates to:
  /// **'Park failed'**
  String get callErrParkFailed;

  /// Error notice title when handing a call to another LAN device failed.
  ///
  /// In en, this message translates to:
  /// **'Hand-off failed'**
  String get callErrHandoffFailed;

  /// Error notice title when forwarding a ringing call to a LAN device failed.
  ///
  /// In en, this message translates to:
  /// **'Could not send to device'**
  String get callErrCouldNotSendToDevice;

  /// Call history reason: forwarded by the "forward on no answer" rule.
  ///
  /// In en, this message translates to:
  /// **'Forwarded (no answer)'**
  String get callHistoryForwardedNoAnswer;

  /// Navigation tab / sidebar label for the dial pad screen.
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get shellTabKeypad;

  /// Navigation tab label and page title for call history.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get shellTabRecents;

  /// Navigation tab label and page title for the contact list.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get shellTabContacts;

  /// Navigation tab label and page title for messaging.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get shellTabMessages;

  /// Sidebar label and page title for the presence (busy lamp field) board.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get shellTabPresence;

  /// Sidebar label for local network (LAN) pairing and calling. Keep short.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get shellTabLan;

  /// Sidebar label for the call recordings screen.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get shellTabRecordings;

  /// Accessibility label of the search/dial box in the desktop top bar.
  ///
  /// In en, this message translates to:
  /// **'Search contacts, history or dial a number'**
  String get shellSearchSemantics;

  /// Placeholder text of the global search box in the desktop top bar.
  ///
  /// In en, this message translates to:
  /// **'Search or dial'**
  String get shellSearchHint;

  /// Tooltip of the voicemail button in the top bar when there are no new voicemails.
  ///
  /// In en, this message translates to:
  /// **'Voicemail'**
  String get shellVoicemailTooltip;

  /// Tooltip of the voicemail button in the top bar when there are new voicemails.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new voicemail. Click to call voicemail} other{{count} new voicemails. Click to call voicemail}}'**
  String shellVoicemailNewTooltip(int count);

  /// Presence status option: user is away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get shellStatusAway;

  /// Tooltip of the own-presence status selector in the desktop sidebar.
  ///
  /// In en, this message translates to:
  /// **'Your status'**
  String get shellStatusTooltip;

  /// Banner shown at the top of the app while running in demo (simulated) mode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: calls are simulated, nothing reaches a real network.'**
  String get shellDemoBanner;

  /// Relative day label in lists and day separators.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get uiToday;

  /// Relative day label in lists and day separators.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get uiYesterday;

  /// Fallback title of a call when neither a name nor a number is known.
  ///
  /// In en, this message translates to:
  /// **'Unknown caller'**
  String get uiUnknownCaller;

  /// Call state text.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get uiCallEnded;

  /// Call state text: the remote side did not confirm the transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer not confirmed'**
  String get uiCallTransferNotConfirmed;

  /// Call state text while a transfer is in progress.
  ///
  /// In en, this message translates to:
  /// **'Transferring...'**
  String get uiCallTransferring;

  /// Call state text for a conference call.
  ///
  /// In en, this message translates to:
  /// **'Conference'**
  String get uiCallConference;

  /// Call state text: the call is on hold locally.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get uiCallOnHold;

  /// Call state text: the other party put the call on hold.
  ///
  /// In en, this message translates to:
  /// **'Held by remote'**
  String get uiCallHeldByRemote;

  /// Call state text for an outgoing call being set up.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get uiCallCalling;

  /// Call state text: the remote phone is ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get uiCallRinging;

  /// Call state text while the call is connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get uiCallConnecting;

  /// Call state text for an incoming call.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get uiCallIncoming;

  /// Call state text for an established call.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get uiCallConnected;

  /// Default title of the QR code scanner sheet.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get uiQrScanTitle;

  /// Default hint of the paste field in the QR scanner sheet.
  ///
  /// In en, this message translates to:
  /// **'Paste the code text'**
  String get uiQrPasteHint;

  /// Shown in the QR scanner sheet when no camera scanning is available.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is not available on this device. Paste the code text instead.'**
  String get uiQrNoCamera;

  /// Button in the QR scanner sheet that pastes the clipboard text.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get uiQrPaste;

  /// Button in the QR scanner sheet that uses the pasted text.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get uiQrUse;

  /// Shown in the QR scanner when camera permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. Allow it in system settings, or paste the code text below.'**
  String get uiQrCameraDenied;

  /// Shown in the QR scanner when the camera cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'The camera is not available. Paste the code text below.'**
  String get uiQrCameraUnavailable;

  /// Presence lamp state: the watched extension is ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing'**
  String get presenceLampRinging;

  /// Subtitle of the Presence page (BLF = busy lamp field).
  ///
  /// In en, this message translates to:
  /// **'Busy lamp field'**
  String get presenceHeader;

  /// Tooltip of the button that opens contacts to pick extensions to watch.
  ///
  /// In en, this message translates to:
  /// **'Choose contacts to watch'**
  String get presenceChooseTooltip;

  /// Empty state title on the Presence page.
  ///
  /// In en, this message translates to:
  /// **'No extensions on the board'**
  String get presenceEmptyTitle;

  /// Empty state text on the Presence page; the quoted text is the label of a switch in the contact editor.
  ///
  /// In en, this message translates to:
  /// **'Turn on \"Show on BLF board\" for a contact to see when they are free, ringing or busy.'**
  String get presenceEmptySubtitle;

  /// Button in the Presence empty state.
  ///
  /// In en, this message translates to:
  /// **'Open contacts'**
  String get presenceOpenContacts;

  /// Accessibility label of a tile on the BLF board.
  ///
  /// In en, this message translates to:
  /// **'{name}, {status}. Tap to call, long press for more'**
  String presenceTileSemantics(String name, String status);

  /// Bottom sheet action to call a contact (also used as tooltip).
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String presenceCallName(String name);

  /// Bottom sheet action: directed call pickup.
  ///
  /// In en, this message translates to:
  /// **'Pick up this extension'**
  String get presencePickup;

  /// Subtitle of the pickup action.
  ///
  /// In en, this message translates to:
  /// **'Answer their ringing call (directed pickup)'**
  String get presencePickupSub;

  /// Bottom sheet action: blind-transfer the active call to this contact.
  ///
  /// In en, this message translates to:
  /// **'Transfer current call here'**
  String get presenceTransferHere;

  /// Bottom sheet action: stop showing the contact on the BLF board.
  ///
  /// In en, this message translates to:
  /// **'Remove from board'**
  String get presenceRemove;

  /// Label of the Call action button (contact and call details).
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get uiCall;

  /// Label of the Message action button (contact and call details).
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get uiMessage;

  /// Tooltip of the search toggle in the Recents header.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get recentsSearchTooltip;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Clear call history?'**
  String get recentsClearTitle;

  /// Confirmation dialog message for clearing call history.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry will be deleted.} other{All {count} entries will be deleted.}}'**
  String recentsClearMessage(int count);

  /// Snackbar after copying call history as CSV.
  ///
  /// In en, this message translates to:
  /// **'History copied to clipboard as CSV'**
  String get recentsCopiedCsv;

  /// Menu item in Recents: copy call history to clipboard as CSV.
  ///
  /// In en, this message translates to:
  /// **'Copy as CSV'**
  String get recentsMenuCopyCsv;

  /// Menu item in Recents: delete all call history.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get recentsMenuClear;

  /// Hint of the Recents search field.
  ///
  /// In en, this message translates to:
  /// **'Search name or number'**
  String get recentsSearchHint;

  /// Filter chip: all calls.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recentsFilterAll;

  /// Filter chip: missed calls.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get recentsFilterMissed;

  /// Filter chip: incoming calls; also direction label of a call.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get recentsFilterIncoming;

  /// Filter chip: outgoing calls; also direction label of a call.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get recentsFilterOutgoing;

  /// Tooltip of the account filter menu in Recents.
  ///
  /// In en, this message translates to:
  /// **'Filter by account'**
  String get recentsFilterAccount;

  /// Account filter option / chip label meaning no account filter.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get recentsAllAccounts;

  /// Chip label when the filtered account no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get recentsAccountFallback;

  /// Empty state title in Recents.
  ///
  /// In en, this message translates to:
  /// **'No calls yet'**
  String get recentsEmptyNone;

  /// Empty state title when filters match nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching calls'**
  String get recentsEmptyNoMatch;

  /// Empty state text in Recents.
  ///
  /// In en, this message translates to:
  /// **'Your calls will show up here.'**
  String get recentsEmptyNoneSub;

  /// Empty state text when filters match nothing.
  ///
  /// In en, this message translates to:
  /// **'Try another filter.'**
  String get recentsEmptyNoMatchSub;

  /// Empty state button in Recents.
  ///
  /// In en, this message translates to:
  /// **'Open keypad'**
  String get recentsOpenKeypad;

  /// Empty state button that resets the history filter.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get recentsShowAll;

  /// Placeholder in the desktop detail pane of Recents.
  ///
  /// In en, this message translates to:
  /// **'Select a call'**
  String get recentsSelectCall;

  /// Placeholder text in the desktop detail pane of Recents.
  ///
  /// In en, this message translates to:
  /// **'Details, quality and recordings appear here.'**
  String get recentsSelectCallSub;

  /// Accessibility label of a call history row.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, missed{Missed call} incoming{Incoming call} other{Outgoing call}} {name}, {number}, {time}'**
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  );

  /// Tooltip of the call button in a history row.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String recentsCallTooltip(String name);

  /// Error snackbar when messaging without any account.
  ///
  /// In en, this message translates to:
  /// **'Add an account to send messages'**
  String get recentsAddAccountToMessage;

  /// Action button in call details for a number that is not a contact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get recentsAddContact;

  /// Action button in call details that opens the contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get recentsContact;

  /// Action button / dialog confirm: block a number.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get recentsBlock;

  /// Action button: unblock a number.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get recentsUnblock;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Block {number}?'**
  String recentsBlockTitle(String number);

  /// Confirmation dialog message for blocking.
  ///
  /// In en, this message translates to:
  /// **'Calls from this number will be rejected automatically.'**
  String get recentsBlockMessage;

  /// Section header in call details.
  ///
  /// In en, this message translates to:
  /// **'Call quality'**
  String get recentsQualityHeader;

  /// Summary of worst call quality values (MOS = mean opinion score).
  ///
  /// In en, this message translates to:
  /// **'Worst MOS {mos}   ·   Jitter {jitter} ms   ·   Loss {loss} %'**
  String recentsQualitySummary(String mos, String jitter, String loss);

  /// Section header in call details.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get recentsRecordingsHeader;

  /// Button that opens a recording in the Recordings screen.
  ///
  /// In en, this message translates to:
  /// **'Open in Recordings'**
  String get recentsOpenInRecordings;

  /// Chip linking to a related recorded call.
  ///
  /// In en, this message translates to:
  /// **'Related call: {title}'**
  String recentsRelatedCall(String title);

  /// Section header in call details listing the calls.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get recentsHistoryHeader;

  /// Title of a call in call details: direction (Incoming/Outgoing) and result.
  ///
  /// In en, this message translates to:
  /// **'{direction}  ·  {result}'**
  String recentsDirectionResult(String direction, String result);

  /// Empty text in call details.
  ///
  /// In en, this message translates to:
  /// **'No calls with this number'**
  String get recentsNoCallsWithNumber;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete these calls?'**
  String get recentsDeleteTitle;

  /// Confirmation dialog message for deleting calls with one number.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removes 1 entry for {name}.} other{Removes {count} entries for {name}.}}'**
  String recentsDeleteMessage(int count, String name);

  /// Button in call details.
  ///
  /// In en, this message translates to:
  /// **'Delete from history'**
  String get recentsDeleteFromHistory;

  /// App bar title of the call details page.
  ///
  /// In en, this message translates to:
  /// **'Call details'**
  String get recentsCallDetails;

  /// Section header above favourite contacts in the list.
  ///
  /// In en, this message translates to:
  /// **'★ Favorites'**
  String get contactsFavoritesHeader;

  /// Tooltip of the star toggle: show only favourite contacts.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get contactsFavoritesOnly;

  /// Tooltip of the star toggle when only favourites are shown.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get contactsShowAll;

  /// Tooltip of the import/export menu in Contacts.
  ///
  /// In en, this message translates to:
  /// **'Import and export'**
  String get contactsImportExportTooltip;

  /// Menu item: import contacts from the phone's address book.
  ///
  /// In en, this message translates to:
  /// **'Import from device'**
  String get contactsMenuDevice;

  /// Menu item: import contacts from a file.
  ///
  /// In en, this message translates to:
  /// **'Import vCard / CSV file'**
  String get contactsMenuFile;

  /// Menu item: import contacts from clipboard text.
  ///
  /// In en, this message translates to:
  /// **'Import from clipboard'**
  String get contactsMenuClipboard;

  /// Menu item: copy all contacts to the clipboard as vCard.
  ///
  /// In en, this message translates to:
  /// **'Copy as vCard'**
  String get contactsMenuCopyVcard;

  /// Menu item: copy all contacts to the clipboard as CSV.
  ///
  /// In en, this message translates to:
  /// **'Copy as CSV'**
  String get contactsMenuCopyCsv;

  /// Tooltip / editor title for creating a contact.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get contactsNewTooltip;

  /// Hint of the contact search field.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get contactsSearchHint;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get contactsEmptyTitle;

  /// Empty state text.
  ///
  /// In en, this message translates to:
  /// **'Add people you call often, or import a vCard or CSV file.'**
  String get contactsEmptySubtitle;

  /// Empty state button.
  ///
  /// In en, this message translates to:
  /// **'Add a contact'**
  String get contactsEmptyAction;

  /// Empty search result title.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get contactsNoMatches;

  /// Tooltip of a call button next to a contact or number.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String contactsCallName(String name);

  /// Placeholder in the desktop detail pane.
  ///
  /// In en, this message translates to:
  /// **'Select a contact'**
  String get contactsSelect;

  /// Snackbar after copying contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts copied as vCard'**
  String get contactsCopiedVcard;

  /// Snackbar after copying contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts copied as CSV'**
  String get contactsCopiedCsv;

  /// Error snackbar when address book permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Contacts access was denied. Allow it in system settings to import.'**
  String get contactsDeviceDenied;

  /// Snackbar when the device address book is empty.
  ///
  /// In en, this message translates to:
  /// **'No contacts found on this device'**
  String get contactsDeviceNone;

  /// Snackbar when all device contacts already exist.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to import ({count} already present)'**
  String contactsNothingNew(int count);

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Import from device?'**
  String get contactsImportDeviceTitle;

  /// Line of the import confirmation: number of new contacts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new contact} other{{count} new contacts}}'**
  String contactsImportNew(int count);

  /// Line of the import confirmation: existing contacts that get extra numbers.
  ///
  /// In en, this message translates to:
  /// **'{count} updated with extra numbers'**
  String contactsImportUpdated(int count);

  /// Line of the import confirmation: skipped entries.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped (duplicates or no phone number)'**
  String contactsImportSkipped(int count);

  /// Snackbar after importing contacts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 contact} other{Imported {count} contacts}}'**
  String contactsImportedCount(int count);

  /// Snackbar when the imported data has no contacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts found in that data'**
  String get contactsImportNone;

  /// Label of a phone number type.
  ///
  /// In en, this message translates to:
  /// **'mobile'**
  String get contactsLabelMobile;

  /// Label of a phone number type.
  ///
  /// In en, this message translates to:
  /// **'work'**
  String get contactsLabelWork;

  /// Label of a phone number type.
  ///
  /// In en, this message translates to:
  /// **'home'**
  String get contactsLabelHome;

  /// Label of a phone number type.
  ///
  /// In en, this message translates to:
  /// **'other'**
  String get contactsLabelOther;

  /// Subtitle of a SIP address entry (protocol name).
  ///
  /// In en, this message translates to:
  /// **'SIP'**
  String get contactsSip;

  /// Empty state in contact details.
  ///
  /// In en, this message translates to:
  /// **'Contact not found'**
  String get contactsNotFound;

  /// Action button label to toggle favourite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get contactsActionFavorite;

  /// Section header (phone numbers).
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get contactsNumbersHeader;

  /// Subtitle of a SIP address entry.
  ///
  /// In en, this message translates to:
  /// **'SIP address'**
  String get contactsSipAddress;

  /// Section header of extra contact details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get contactsDetailsHeader;

  /// Detail line: contact is on the busy lamp field board.
  ///
  /// In en, this message translates to:
  /// **'Shown on the BLF board'**
  String get contactsOnBlf;

  /// Detail line: contact has automatic recording on.
  ///
  /// In en, this message translates to:
  /// **'Calls are always recorded'**
  String get contactsAlwaysRecorded;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String contactsDeleteTitle(String name);

  /// Confirmation dialog message.
  ///
  /// In en, this message translates to:
  /// **'This contact will be removed from this device.'**
  String get contactsDeleteMessage;

  /// Button to delete the contact.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get contactsDeleteButton;

  /// App bar title of contact details.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactsDetailTitle;

  /// Validation error when saving an empty contact.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or a number'**
  String get contactsErrorNameOrNumber;

  /// App bar title of the contact editor.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get contactsEditTitle;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactsFieldName;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get contactsFieldCompany;

  /// Field label (phone number).
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get contactsFieldNumber;

  /// Tooltip of a remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove number'**
  String get contactsRemoveNumber;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Add number'**
  String get contactsAddNumber;

  /// Section header in the contact editor.
  ///
  /// In en, this message translates to:
  /// **'SIP addresses'**
  String get contactsSipHeader;

  /// Tooltip of a remove button.
  ///
  /// In en, this message translates to:
  /// **'Remove address'**
  String get contactsRemoveAddress;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Add SIP address'**
  String get contactsAddSip;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactsFieldEmail;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get contactsFieldNotes;

  /// Switch title in the editor.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get contactsFieldFavorite;

  /// Switch title: show contact on the busy lamp field board.
  ///
  /// In en, this message translates to:
  /// **'Show on BLF board'**
  String get contactsShowOnBlf;

  /// Switch subtitle for the BLF board option.
  ///
  /// In en, this message translates to:
  /// **'Watch this extension\'\'s presence and busy lamp'**
  String get contactsShowOnBlfSub;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Always record calls with this contact'**
  String get contactsAlwaysRecordTitle;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Overrides the automatic recording rules'**
  String get contactsAlwaysRecordSub;

  /// Setting title for the contact-specific ringtone.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get contactsRingtone;

  /// Setting title: account used for presence subscription.
  ///
  /// In en, this message translates to:
  /// **'Presence via account'**
  String get contactsPresenceVia;

  /// Dropdown option: use the default account.
  ///
  /// In en, this message translates to:
  /// **'Default account'**
  String get contactsDefaultAccount;

  /// Confirmation dialog title in the editor.
  ///
  /// In en, this message translates to:
  /// **'Delete contact?'**
  String get contactsDeleteContactTitle;

  /// Confirmation dialog message.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get contactsCannotUndo;

  /// Tooltip of the compose button, dialog title and empty-state button.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get messagesNewMessage;

  /// Hint of the recipient field in the New message dialog.
  ///
  /// In en, this message translates to:
  /// **'Number or SIP address'**
  String get messagesNumberOrSip;

  /// Empty state title in Messages.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get messagesNoConversations;

  /// Empty state text in Messages.
  ///
  /// In en, this message translates to:
  /// **'Send a SIP message to any extension or address on your accounts.'**
  String get messagesEmptySubtitle;

  /// Shown instead of the last message while the other side is typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get messagesTyping;

  /// Prefix of the last-message preview when you sent it. Keep the trailing space.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get messagesYouPrefix;

  /// Placeholder in the desktop detail pane of Messages.
  ///
  /// In en, this message translates to:
  /// **'Select a conversation'**
  String get messagesSelect;

  /// Status of a LAN chat peer.
  ///
  /// In en, this message translates to:
  /// **'Online on your network'**
  String get messagesLanOnline;

  /// Status of a LAN chat peer that is offline.
  ///
  /// In en, this message translates to:
  /// **'Offline. Messages are sent when it is back.'**
  String get messagesLanOffline;

  /// Tooltip of the attach file button in a LAN chat.
  ///
  /// In en, this message translates to:
  /// **'Send a file to {name}'**
  String messagesSendFileTo(String name);

  /// Tooltip of the call button in a chat header.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String messagesCallName(String name);

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get messagesDeleteTitle;

  /// Confirmation dialog message.
  ///
  /// In en, this message translates to:
  /// **'All messages with {name} will be removed.'**
  String messagesDeleteMessage(String name);

  /// Menu item in the chat header.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get messagesDeleteMenu;

  /// Empty state title of a new chat.
  ///
  /// In en, this message translates to:
  /// **'Say hello'**
  String get messagesSayHello;

  /// Empty state text of a LAN chat.
  ///
  /// In en, this message translates to:
  /// **'Messages go straight to this device over your network, end-to-end encrypted.'**
  String get messagesLanEmptySub;

  /// Empty state text of a SIP chat.
  ///
  /// In en, this message translates to:
  /// **'Messages are sent with SIP MESSAGE through your account.'**
  String get messagesSipEmptySub;

  /// Hint of the message input field.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messagesInputHint;

  /// Tooltip of the send button.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get messagesSend;

  /// Accessibility label of a message status icon.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get messagesStatusSending;

  /// Accessibility label of a message status icon.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messagesStatusSent;

  /// Accessibility label of a message status icon.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get messagesStatusDelivered;

  /// Accessibility label of a message status icon.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messagesStatusRead;

  /// Accessibility label of a message status icon.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get messagesStatusFailed;

  /// Shown under a message that failed to send.
  ///
  /// In en, this message translates to:
  /// **'Not delivered. Tap to retry'**
  String get messagesNotDelivered;

  /// Account registration status.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get uiStatusRegistered;

  /// Account registration status while registering.
  ///
  /// In en, this message translates to:
  /// **'Registering'**
  String get uiStatusRegistering;

  /// Account registration status after a failure.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get uiStatusRegFailed;

  /// Account status: account is switched off.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get uiStatusDisabled;

  /// Call quality rating when no measurement exists yet.
  ///
  /// In en, this message translates to:
  /// **'Measuring'**
  String get uiQualityMeasuring;

  /// Call quality rating.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get uiQualityExcellent;

  /// Call quality rating.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get uiQualityGood;

  /// Call quality rating.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get uiQualityFair;

  /// Call quality rating.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get uiQualityPoor;

  /// Call quality rating.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get uiQualityBad;

  /// Accessibility label of the call quality indicator.
  ///
  /// In en, this message translates to:
  /// **'Call quality {label}'**
  String uiQualitySemantics(String label);

  /// Accessibility label of the call quality indicator with MOS (mean opinion score) value.
  ///
  /// In en, this message translates to:
  /// **'Call quality {label}, MOS {mos}'**
  String uiQualitySemanticsMos(String label, String mos);

  /// Tooltip of the call quality indicator.
  ///
  /// In en, this message translates to:
  /// **'Call quality: {label}'**
  String uiQualityTooltip(String label);

  /// Badge: both media and signalling are encrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get uiSecureFull;

  /// Badge: only media (SRTP) is encrypted.
  ///
  /// In en, this message translates to:
  /// **'Media encrypted'**
  String get uiSecureMedia;

  /// Badge: only signalling (TLS) is encrypted.
  ///
  /// In en, this message translates to:
  /// **'Signalling encrypted'**
  String get uiSecureSignalling;

  /// Badge: the call is not encrypted.
  ///
  /// In en, this message translates to:
  /// **'Not encrypted'**
  String get uiSecureNone;

  /// Tooltip line explaining media encryption.
  ///
  /// In en, this message translates to:
  /// **'SRTP media'**
  String get uiSecureSrtpLine;

  /// Tooltip line explaining signalling encryption.
  ///
  /// In en, this message translates to:
  /// **'TLS signalling'**
  String get uiSecureTlsLine;

  /// In-call label while this device hands the call to a paired device.
  ///
  /// In en, this message translates to:
  /// **'Handing over to {name}'**
  String lanCallHandingOver(String name);

  /// In-call label: outgoing intercom call to a paired device.
  ///
  /// In en, this message translates to:
  /// **'Intercom to {name}'**
  String lanCallIntercomToNamed(String name);

  /// In-call label: outgoing intercom call, device name unknown.
  ///
  /// In en, this message translates to:
  /// **'Intercom to a nearby device'**
  String get lanCallIntercomToUnnamed;

  /// In-call label: incoming intercom call from a device.
  ///
  /// In en, this message translates to:
  /// **'Intercom from {name}'**
  String lanCallIntercomFromNamed(String name);

  /// In-call label: incoming intercom call, device name unknown.
  ///
  /// In en, this message translates to:
  /// **'Intercom from a nearby device'**
  String get lanCallIntercomFromUnnamed;

  /// In-call label: outgoing direct LAN call.
  ///
  /// In en, this message translates to:
  /// **'LAN call to {name}'**
  String lanCallToNamed(String name);

  /// In-call label: outgoing LAN call, device unknown.
  ///
  /// In en, this message translates to:
  /// **'LAN call to an unpaired device'**
  String get lanCallToUnpaired;

  /// In-call label: incoming direct LAN call.
  ///
  /// In en, this message translates to:
  /// **'LAN call from {name}'**
  String lanCallFromNamed(String name);

  /// In-call label: incoming LAN call from an unknown device.
  ///
  /// In en, this message translates to:
  /// **'LAN call from an unpaired device'**
  String get lanCallFromUnpaired;

  /// Label for a call another device handed to this one (no caller known). Placeholder is the device name.
  ///
  /// In en, this message translates to:
  /// **'Transferred call from {device}'**
  String lanHandoffTransferredFrom(String device);

  /// Label for a call another device handed to this one. Placeholders: device name, original caller name or number.
  ///
  /// In en, this message translates to:
  /// **'Transferred call from {device}: {caller}'**
  String lanHandoffTransferredFromCaller(String device, String caller);

  /// Fallback device name inside "Transferred call from ..." when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'another device'**
  String get lanHandoffAnotherDevice;

  /// Banner title: call is now relayed to a paired device.
  ///
  /// In en, this message translates to:
  /// **'Relayed to {name}'**
  String lanRelayedTitle(String name);

  /// Banner text for a relayed call.
  ///
  /// In en, this message translates to:
  /// **'The caller is talking to {name}. You are not on the call.'**
  String lanRelayedSubtitle(String name);

  /// Banner title while dialing the paired device to hand the call over.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}...'**
  String lanRelayDialingTitle(String name);

  /// Banner text while dialing the paired device.
  ///
  /// In en, this message translates to:
  /// **'The caller stays connected while {name} answers.'**
  String lanRelayDialingSubtitle(String name);

  /// Banner title while asking the paired device to accept the call.
  ///
  /// In en, this message translates to:
  /// **'Asking {name}...'**
  String lanRelayOfferingTitle(String name);

  /// Banner text while waiting for the other device to accept.
  ///
  /// In en, this message translates to:
  /// **'Waiting for them to accept the call.'**
  String get lanRelayOfferingSubtitle;

  /// Banner title during an attended hand-off (consultation with the other device).
  ///
  /// In en, this message translates to:
  /// **'Talking to {name}'**
  String lanRelayConsultingTitle(String name);

  /// Banner text during an attended hand-off.
  ///
  /// In en, this message translates to:
  /// **'The caller is on hold. Complete the hand-off when ready.'**
  String get lanRelayConsultingSubtitle;

  /// Banner title while taking a relayed call back.
  ///
  /// In en, this message translates to:
  /// **'Taking the call back...'**
  String get lanRelayTakingBack;

  /// Button: take a relayed call back to this device.
  ///
  /// In en, this message translates to:
  /// **'Take back'**
  String get lanRelayTakeBack;

  /// Button: end a relayed call (both legs).
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get lanRelayEnd;

  /// Bottom sheet title: choose which paired device receives the call.
  ///
  /// In en, this message translates to:
  /// **'Send to device'**
  String get lanSendToDevice;

  /// Peer status label: device is busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get lanBusy;

  /// Notice shown when forwarding a ringing call but no paired device is online.
  ///
  /// In en, this message translates to:
  /// **'No paired device is online'**
  String get lanNoPairedOnline;

  /// Pairing dialog failure: the other device rejected.
  ///
  /// In en, this message translates to:
  /// **'{name} rejected the pairing.'**
  String lanPairRejectedBy(String name);

  /// Pairing dialog failure: rejected.
  ///
  /// In en, this message translates to:
  /// **'Pairing rejected.'**
  String get lanPairRejected;

  /// Pairing dialog failure: cancelled.
  ///
  /// In en, this message translates to:
  /// **'Pairing cancelled.'**
  String get lanPairCancelled;

  /// Pairing dialog failure: timeout.
  ///
  /// In en, this message translates to:
  /// **'Pairing timed out. Try again.'**
  String get lanPairTimedOut;

  /// Pairing dialog failure without details.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed'**
  String get lanPairFailed;

  /// Pairing dialog failure with technical reason.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed: {reason}'**
  String lanPairFailedReason(String reason);

  /// Fallback device name used inside pairing sentences when the other device has no name (for example "Pair with this device").
  ///
  /// In en, this message translates to:
  /// **'this device'**
  String get lanPairThisDevice;

  /// Pairing dialog: connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting securely...'**
  String get lanPairConnecting;

  /// Pairing dialog: incoming pairing request.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to pair with this device.'**
  String lanPairWantsToPair(String name);

  /// Pairing dialog: outgoing pairing.
  ///
  /// In en, this message translates to:
  /// **'Pairing with {name}.'**
  String lanPairPairingWith(String name);

  /// Pairing dialog: instruction to compare the 6-digit code.
  ///
  /// In en, this message translates to:
  /// **'Check that this code is the same on both screens.'**
  String get lanPairCheckCode;

  /// Screen reader label for the pairing code.
  ///
  /// In en, this message translates to:
  /// **'Pairing code {code}'**
  String lanPairCodeSemantics(String code);

  /// Pairing dialog: waiting for the other device.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to confirm...'**
  String lanPairWaitingConfirm(String name);

  /// Pairing dialog: the other device confirmed the code.
  ///
  /// In en, this message translates to:
  /// **'{name} has confirmed.'**
  String lanPairRemoteConfirmed(String name);

  /// Pairing dialog button: reject the pairing.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get lanPairReject;

  /// Pairing dialog button: confirm both screens show the same code.
  ///
  /// In en, this message translates to:
  /// **'Codes match'**
  String get lanPairCodesMatch;

  /// Pairing dialog: success.
  ///
  /// In en, this message translates to:
  /// **'Paired with {name}.'**
  String lanPairPairedWith(String name);

  /// Pairing dialog title for an incoming request.
  ///
  /// In en, this message translates to:
  /// **'Pairing request'**
  String get lanPairRequestTitle;

  /// Pairing dialog title for an outgoing pairing.
  ///
  /// In en, this message translates to:
  /// **'Pair with {name}'**
  String lanPairTitle(String name);

  /// Button: decline a file or call hand-off offer.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get lanActionDecline;

  /// Button: accept an incoming file.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get lanActionAccept;

  /// Dialog title: a paired device wants to send a file.
  ///
  /// In en, this message translates to:
  /// **'Incoming file'**
  String get lanFileIncomingTitle;

  /// Incoming file dialog: file size and sender name.
  ///
  /// In en, this message translates to:
  /// **'{size} from {name}'**
  String lanFileSizeFrom(String size, String name);

  /// Dialog title: another device offers to hand a call to this device.
  ///
  /// In en, this message translates to:
  /// **'Transfer a call here?'**
  String get lanHandoffOfferTitle;

  /// Dialog text: another device offers a call. caller is the caller name/number or "none", account is the account name or "none".
  ///
  /// In en, this message translates to:
  /// **'{device} wants to hand you a call{caller, select, none{} other{ from {caller}}}{account, select, none{} other{ on {account}}}.'**
  String lanHandoffOfferBody(String device, String caller, String account);

  /// Appended to the hand-off offer text when the other device wants to consult first.
  ///
  /// In en, this message translates to:
  /// **'They will talk to you first.'**
  String get lanHandoffOfferAttended;

  /// Button: accept a call handed over from another device.
  ///
  /// In en, this message translates to:
  /// **'Take call'**
  String get lanHandoffTakeCall;

  /// Dialog title: a paired device requests intercom.
  ///
  /// In en, this message translates to:
  /// **'Allow intercom from {name}?'**
  String lanIntercomRequestTitle(String name);

  /// Dialog text for an intercom request.
  ///
  /// In en, this message translates to:
  /// **'Their call will be answered automatically on speaker.'**
  String get lanIntercomRequestBody;

  /// Button: deny an intercom request.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get lanIntercomDeny;

  /// Button: allow an intercom request.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get lanIntercomAllow;

  /// Notice: the other device unpaired this one.
  ///
  /// In en, this message translates to:
  /// **'{name} removed this device from its paired list'**
  String lanNoticeUnpairedByPeer(String name);

  /// Small badge on chat threads and conversation rows marking LAN Link messages.
  ///
  /// In en, this message translates to:
  /// **'LAN'**
  String get lanBadge;

  /// Notice when starting to send files to a paired device. name is the file name when count is 1.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sending {name}...} other{Sending {count} files...}}'**
  String lanSendingFiles(String name, int count);

  /// Bottom sheet title: choose where a new message goes.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get lanNewMessage;

  /// New message sheet: send over a SIP account.
  ///
  /// In en, this message translates to:
  /// **'SIP message'**
  String get lanSipMessage;

  /// New message sheet: description of the SIP message option.
  ///
  /// In en, this message translates to:
  /// **'To a number or address through your account'**
  String get lanSipMessageSub;

  /// New message sheet: paired device is online.
  ///
  /// In en, this message translates to:
  /// **'LAN chat, online'**
  String get lanChatOnline;

  /// New message sheet: paired device is offline.
  ///
  /// In en, this message translates to:
  /// **'LAN chat, offline'**
  String get lanChatOffline;

  /// Notice when a received file cannot be opened: shows where it was saved.
  ///
  /// In en, this message translates to:
  /// **'Saved at {path} (path copied)'**
  String lanSavedAt(String path);

  /// Page title of the LAN Link screen.
  ///
  /// In en, this message translates to:
  /// **'LAN Link'**
  String get lanPageTitle;

  /// Subtitle of the LAN Link screen.
  ///
  /// In en, this message translates to:
  /// **'Your devices, talking directly'**
  String get lanPageSubtitle;

  /// Tooltip and dialog title: connect to a device by host:port.
  ///
  /// In en, this message translates to:
  /// **'Connect by address'**
  String get lanConnectByAddress;

  /// Tooltip: open LAN Link settings.
  ///
  /// In en, this message translates to:
  /// **'LAN settings'**
  String get lanSettingsTooltip;

  /// Empty state title when LAN Link is disabled.
  ///
  /// In en, this message translates to:
  /// **'LAN Link is off'**
  String get lanOffTitle;

  /// Empty state text when LAN Link is disabled.
  ///
  /// In en, this message translates to:
  /// **'Find your other SoftphonePro devices, chat, drop files and hand calls over, without any server.'**
  String get lanOffSubtitle;

  /// Empty state button.
  ///
  /// In en, this message translates to:
  /// **'Turn on LAN Link'**
  String get lanTurnOn;

  /// Error banner when LAN Link fails to start.
  ///
  /// In en, this message translates to:
  /// **'LAN Link could not start: {error}'**
  String lanCouldNotStart(String error);

  /// Connect by address dialog help text.
  ///
  /// In en, this message translates to:
  /// **'Type host:port, or paste the text of the QR code shown on the other device.'**
  String get lanConnectHelp;

  /// Title of the QR scanner sheet.
  ///
  /// In en, this message translates to:
  /// **'Scan LAN pairing QR'**
  String get lanScanTitle;

  /// Button: scan a pairing QR code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get lanScanQr;

  /// Button: paste connection text from the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get lanPaste;

  /// Button: connect to the typed address.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get lanConnect;

  /// Notice after connecting to an already paired device.
  ///
  /// In en, this message translates to:
  /// **'Connected to {name}'**
  String lanConnectedTo(String name);

  /// Error notice title when a manual connection fails.
  ///
  /// In en, this message translates to:
  /// **'Could not connect'**
  String get lanCouldNotConnect;

  /// Error notice title when pairing fails to start.
  ///
  /// In en, this message translates to:
  /// **'Could not start pairing'**
  String get lanCouldNotStartPairing;

  /// Label above the name of this device (also hint of the rename field).
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get lanThisDevice;

  /// Dialog title: rename this device.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get lanDeviceNameTitle;

  /// Status pill: LAN Link is starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get lanStarting;

  /// Status pill: LAN Link is running.
  ///
  /// In en, this message translates to:
  /// **'Visible on your network'**
  String get lanVisible;

  /// Status pill: LAN Link is not running.
  ///
  /// In en, this message translates to:
  /// **'Not running'**
  String get lanNotRunning;

  /// Status pill: number of SIP accounts shared with paired devices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account shared} other{{count} accounts shared}}'**
  String lanAccountsShared(int count);

  /// Label above the device fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get lanFingerprint;

  /// Button: hide the QR code.
  ///
  /// In en, this message translates to:
  /// **'Hide QR code'**
  String get lanHideQr;

  /// Button: show the QR code.
  ///
  /// In en, this message translates to:
  /// **'Show QR code to connect another device'**
  String get lanShowQr;

  /// Button: copy the text form of the QR code.
  ///
  /// In en, this message translates to:
  /// **'Copy connection text'**
  String get lanCopyConnectionText;

  /// Notice after copying the connection text.
  ///
  /// In en, this message translates to:
  /// **'Connection text copied'**
  String get lanConnectionTextCopied;

  /// Section header: calls running on paired devices.
  ///
  /// In en, this message translates to:
  /// **'Active on your other devices'**
  String get lanActiveOnOthers;

  /// Section header.
  ///
  /// In en, this message translates to:
  /// **'Paired devices'**
  String get lanPairedDevices;

  /// Empty hint for paired devices.
  ///
  /// In en, this message translates to:
  /// **'No paired devices yet. Pair a nearby device to chat, send files and hand calls over.'**
  String get lanNoPaired;

  /// Section header: devices discovered on the network.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get lanNearby;

  /// Empty hint for nearby devices.
  ///
  /// In en, this message translates to:
  /// **'Looking for SoftphonePro on your network. Other devices need LAN Link turned on. You can also connect by address with the link button above.'**
  String get lanNearbyHint;

  /// Section header: running file transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get lanTransfers;

  /// Section header: finished file transfers.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get lanFiles;

  /// Small badge on a paired device.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get lanPairedBadge;

  /// Device status line while the peer is typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get lanTyping;

  /// Button: start pairing with a nearby device.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get lanPair;

  /// Menu item and confirm button: remove a paired device.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get lanUnpair;

  /// Confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Unpair {name}?'**
  String lanUnpairTitle(String name);

  /// Confirm dialog text.
  ///
  /// In en, this message translates to:
  /// **'You will have to pair again to chat, send files or hand over calls.'**
  String get lanUnpairMessage;

  /// Tooltip: chat with a paired device.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get lanActionMessage;

  /// Tooltip: send a file to a paired device.
  ///
  /// In en, this message translates to:
  /// **'Send file'**
  String get lanActionSendFile;

  /// Tooltip: call a paired device.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get lanActionCall;

  /// Tooltip: intercom call to a paired device.
  ///
  /// In en, this message translates to:
  /// **'Intercom'**
  String get lanActionIntercom;

  /// Subtitle of a call running on another device.
  ///
  /// In en, this message translates to:
  /// **'Active on {device}'**
  String lanRemoteActiveOn(String device);

  /// Subtitle of a call running on another device, with its account name.
  ///
  /// In en, this message translates to:
  /// **'Active on {device}  ·  {account}'**
  String lanRemoteActiveOnAccount(String device, String account);

  /// Button: pull a call from another device to this one.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get lanPull;

  /// File transfer status.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get lanTransferPreparing;

  /// File transfer status: incoming offer awaiting a decision.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get lanTransferWaitingYou;

  /// File transfer status: outgoing offer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to accept'**
  String lanTransferWaitingPeer(String name);

  /// File transfer progress, sizes like 1.5 MB.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String lanTransferProgress(String done, String total);

  /// File transfer status.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get lanTransferVerifying;

  /// Transfer subtitle for an incoming file.
  ///
  /// In en, this message translates to:
  /// **'From {name}  ·  {status}'**
  String lanTransferFrom(String name, String status);

  /// Transfer subtitle for an outgoing file.
  ///
  /// In en, this message translates to:
  /// **'To {name}  ·  {status}'**
  String lanTransferTo(String name, String status);

  /// Finished file subtitle: received.
  ///
  /// In en, this message translates to:
  /// **'{size}  ·  from {name}'**
  String lanFileFromPeer(String size, String name);

  /// Finished file subtitle: sent.
  ///
  /// In en, this message translates to:
  /// **'{size}  ·  to {name}'**
  String lanFileToPeer(String size, String name);

  /// Finished file subtitle: failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String lanFileFailed(String error);

  /// Tooltip of the menu on a received file.
  ///
  /// In en, this message translates to:
  /// **'File actions'**
  String get lanFileActions;

  /// Notice after copying a file path.
  ///
  /// In en, this message translates to:
  /// **'Path copied'**
  String get lanPathCopied;

  /// Menu item: open the received file.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get lanFileOpen;

  /// Menu item: reveal the file in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get lanFileShowInFolder;

  /// Menu item: copy the file path.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get lanFileCopyPath;

  /// LAN Link start error for a socket failure.
  ///
  /// In en, this message translates to:
  /// **'Network error: {message}'**
  String lanNetworkError(String message);

  /// Error when connecting while LAN Link is off.
  ///
  /// In en, this message translates to:
  /// **'Turn on LAN Link first'**
  String get lanErrNotRunning;

  /// Error for an unparsable address.
  ///
  /// In en, this message translates to:
  /// **'Enter an address like 192.168.1.20:4711 or paste the QR code text'**
  String get lanErrBadAddress;

  /// Error when the device behind the address differs from the QR code.
  ///
  /// In en, this message translates to:
  /// **'That device does not match the scanned code. Did the QR code come from another device?'**
  String get lanErrFingerprint;

  /// Notice: file received.
  ///
  /// In en, this message translates to:
  /// **'Received {file} from {name}'**
  String lanNoticeReceived(String file, String name);

  /// Notice: file sent.
  ///
  /// In en, this message translates to:
  /// **'Sent {file} to {name}'**
  String lanNoticeSent(String file, String name);

  /// Error notice: the other device declined the file.
  ///
  /// In en, this message translates to:
  /// **'{name} declined {file}'**
  String lanNoticeDeclined(String name, String file);

  /// Error notice.
  ///
  /// In en, this message translates to:
  /// **'File transfer failed: {error}'**
  String lanNoticeTransferFailed(String error);

  /// Error notice when calling while LAN Link is off.
  ///
  /// In en, this message translates to:
  /// **'Turn on LAN Link to call nearby devices'**
  String get lanNoticeNeedLanOn;

  /// Error notice when calling an unpaired device.
  ///
  /// In en, this message translates to:
  /// **'Pair with this device first'**
  String get lanNoticePairFirst;

  /// Error notice.
  ///
  /// In en, this message translates to:
  /// **'{name} is not reachable for calls right now'**
  String lanNoticeNotReachable(String name);

  /// Notice while waiting for an intercom permission.
  ///
  /// In en, this message translates to:
  /// **'Asking {name}…'**
  String lanNoticeAsking(String name);

  /// Error notice.
  ///
  /// In en, this message translates to:
  /// **'{name} did not allow intercom (or did not answer)'**
  String lanNoticeIntercomDenied(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'LAN Link is turned off'**
  String get lanHoOff;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Pair with that device first'**
  String get lanHoPairFirst;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} is offline'**
  String lanHoOffline(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'This call is already being handed off'**
  String get lanHoAlready;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'The call has already ended'**
  String get lanHoEnded;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Wait until the call is connected'**
  String get lanHoWaitConnected;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'LAN calls cannot be handed off'**
  String get lanHoLanCall;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} cannot take calls over the network (LAN calling is off there)'**
  String lanHoPeerNoLan(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'LAN calling is not available on this device'**
  String get lanHoNoLanHere;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} declined the call. It stays with you.'**
  String lanHoDeclined(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} did not respond. The call stays with you.'**
  String lanHoTimeout(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'The hand-off was cancelled. The call stays with you.'**
  String get lanHoCancelled;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Could not reach {name}. The call stays with you.'**
  String lanHoUnreachable(String name);

  /// Hand-off error with technical reason.
  ///
  /// In en, this message translates to:
  /// **'Could not reach {name} ({reason}). The call stays with you.'**
  String lanHoUnreachableReason(String name, String reason);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'The call ended before it could be handed off'**
  String get lanHoEndedBefore;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'The phone system refused the transfer and {name} cannot take LAN calls'**
  String lanHoPbxRefused(String name);

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'Transfer through the phone system failed. Relaying over the network instead.'**
  String get lanHoPbxFailedRelaying;

  /// Notice: ringing call redirected.
  ///
  /// In en, this message translates to:
  /// **'Call sent to {name}'**
  String lanHoSentTo(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Could not call the other device through the phone system'**
  String get lanHoConsultFailed;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} is no longer reachable'**
  String lanHoNoLongerReachable(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Could not answer the call to hand it over'**
  String get lanHoCouldNotAnswer;

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'Could not call {name} over the network. The call stays with you.'**
  String lanHoCouldNotCall(String name);

  /// Hand-off error.
  ///
  /// In en, this message translates to:
  /// **'{name} did not answer. The call stays with you.'**
  String lanHoNoAnswer(String name);

  /// Call history reason for a call handed to another device.
  ///
  /// In en, this message translates to:
  /// **'Handed off to {name}'**
  String lanHoHandedOffReason(String name);

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'Call relayed to {name}'**
  String lanHoRelayed(String name);

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'Wait for {name} to answer first'**
  String lanHoWaitAnswer(String name);

  /// Error notice title.
  ///
  /// In en, this message translates to:
  /// **'Hand-off failed'**
  String get lanHoFailed;

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'Call taken back from {name}'**
  String lanHoTakenBack(String name);

  /// Notice.
  ///
  /// In en, this message translates to:
  /// **'{name} ended the consultation. The call is back with you.'**
  String lanHoConsultEnded(String name);

  /// Error notice title.
  ///
  /// In en, this message translates to:
  /// **'Could not hand the call to {name}'**
  String lanHoCouldNotHand(String name);

  /// Explanation of SIP response 400 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server could not understand the request.'**
  String get diagSip400Explain;

  /// Suggested fix for SIP response 400 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the account settings (domain, username, proxy). If it persists, send a SIP trace to your provider.'**
  String get diagSip400Fix;

  /// Explanation of SIP response 401 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server rejected the credentials (or is asking for them).'**
  String get diagSip401Explain;

  /// Suggested fix for SIP response 401 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the username, authentication username and password. Some providers use a separate \"auth ID\".'**
  String get diagSip401Fix;

  /// Explanation of SIP response 403 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server understood the request but refuses it: wrong password, account disabled, or your IP is not allowed.'**
  String get diagSip403Explain;

  /// Suggested fix for SIP response 403 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the password, check the account is active, and confirm your public IP is not blocked (fail2ban/ACL).'**
  String get diagSip403Fix;

  /// Explanation of SIP response 404 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server does not know this user or number.'**
  String get diagSip404Explain;

  /// Suggested fix for SIP response 404 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the username and domain; for calls, check the dialled number and dial rules.'**
  String get diagSip404Fix;

  /// Explanation of SIP response 405 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server does not support this request.'**
  String get diagSip405Explain;

  /// Suggested fix for SIP response 405 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Usually harmless for OPTIONS pings. For REGISTER, check you are talking to a SIP registrar.'**
  String get diagSip405Fix;

  /// Explanation of SIP response 407 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The outbound proxy needs credentials.'**
  String get diagSip407Explain;

  /// Suggested fix for SIP response 407 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the account password and outbound proxy settings.'**
  String get diagSip407Fix;

  /// Explanation of SIP response 408 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'No answer from the server in time.'**
  String get diagSip408Explain;

  /// Suggested fix for SIP response 408 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the server address and port, firewalls, and try TCP or TLS. Repeated timeouts on UDP only can point to SIP ALG on the router.'**
  String get diagSip408Fix;

  /// Explanation of SIP response 410 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The number no longer exists.'**
  String get diagSip410Explain;

  /// Suggested fix for SIP response 410 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the dialled number.'**
  String get diagSip410Fix;

  /// Explanation of SIP response 415 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The other side does not accept the content type or codecs offered.'**
  String get diagSip415Explain;

  /// Suggested fix for SIP response 415 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Enable more codecs (e.g. PCMU/PCMA) in Settings > Codecs.'**
  String get diagSip415Fix;

  /// Explanation of SIP response 421 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server requires a SIP extension this client did not offer.'**
  String get diagSip421Explain;

  /// Suggested fix for SIP response 421 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the account NAT/ICE/100rel/timers options.'**
  String get diagSip421Fix;

  /// Explanation of SIP response 423 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The registration expiry is shorter than the server allows.'**
  String get diagSip423Explain;

  /// Suggested fix for SIP response 423 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Increase the registration expiry in the account settings.'**
  String get diagSip423Fix;

  /// Explanation of SIP response 480 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The user is not registered or cannot be reached right now.'**
  String get diagSip480Explain;

  /// Suggested fix for SIP response 480 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the other party is registered; on registration, the server may be overloaded: retry later.'**
  String get diagSip480Fix;

  /// Explanation of SIP response 481 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server lost the dialog state (e.g. after a restart or network change).'**
  String get diagSip481Explain;

  /// Suggested fix for SIP response 481 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Hang up and retry. If frequent, enable session timers.'**
  String get diagSip481Fix;

  /// Explanation of SIP response 483 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The request circled between servers.'**
  String get diagSip483Explain;

  /// Suggested fix for SIP response 483 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check forwarding and routing configuration on the PBX.'**
  String get diagSip483Fix;

  /// Explanation of SIP response 484 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The dialled number is too short.'**
  String get diagSip484Explain;

  /// Suggested fix for SIP response 484 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Dial the full number or check dial rules.'**
  String get diagSip484Fix;

  /// Explanation of SIP response 486 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The other party is busy.'**
  String get diagSip486Explain;

  /// Suggested fix for SIP response 486 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Try again later.'**
  String get diagSip486Fix;

  /// Explanation of SIP response 487 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The call was cancelled before it was answered.'**
  String get diagSip487Explain;

  /// Suggested fix for SIP response 487 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Normal when the caller hangs up while it rings.'**
  String get diagSip487Fix;

  /// Explanation of SIP response 488 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'No common codec or encryption setting with the other side.'**
  String get diagSip488Explain;

  /// Suggested fix for SIP response 488 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check codecs and SRTP (a mandatory-SRTP account cannot call a plain-RTP endpoint).'**
  String get diagSip488Fix;

  /// Explanation of SIP response 491 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'Two re-INVITEs collided.'**
  String get diagSip491Explain;

  /// Suggested fix for SIP response 491 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Normally retried automatically.'**
  String get diagSip491Fix;

  /// Explanation of SIP response 500 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server failed internally.'**
  String get diagSip500Explain;

  /// Suggested fix for SIP response 500 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Retry later and contact the provider if it continues.'**
  String get diagSip500Fix;

  /// Explanation of SIP response 502 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'An upstream server returned an invalid answer.'**
  String get diagSip502Explain;

  /// Suggested fix for SIP response 502 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Retry later; contact the provider if it continues.'**
  String get diagSip502Fix;

  /// Explanation of SIP response 503 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The server is overloaded, down, or rejecting this client (rate limit).'**
  String get diagSip503Explain;

  /// Suggested fix for SIP response 503 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Wait and retry, check the provider status page, or try another server/port.'**
  String get diagSip503Fix;

  /// Explanation of SIP response 504 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'An upstream server did not answer in time.'**
  String get diagSip504Explain;

  /// Suggested fix for SIP response 504 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Retry later.'**
  String get diagSip504Fix;

  /// Explanation of SIP response 600 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'All destinations are busy.'**
  String get diagSip600Explain;

  /// Suggested fix for SIP response 600 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Try again later.'**
  String get diagSip600Fix;

  /// Explanation of SIP response 603 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The other party rejected the call.'**
  String get diagSip603Explain;

  /// Suggested fix for SIP response 603 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Nothing to fix: the call was declined.'**
  String get diagSip603Fix;

  /// Explanation of SIP response 604 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The number does not exist.'**
  String get diagSip604Explain;

  /// Suggested fix for SIP response 604 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check the dialled number.'**
  String get diagSip604Fix;

  /// Explanation of SIP response 606 shown in the network check wizard (the number is the SIP status code).
  ///
  /// In en, this message translates to:
  /// **'The other party cannot accept the session as offered.'**
  String get diagSip606Explain;

  /// Suggested fix for SIP response 606 shown in the network check wizard.
  ///
  /// In en, this message translates to:
  /// **'Check codecs and encryption settings.'**
  String get diagSip606Fix;

  /// Title for an unlisted 1xx SIP response in the network wizard.
  ///
  /// In en, this message translates to:
  /// **'Provisional ({code})'**
  String diagSipProvisionalTitle(int code);

  /// Explanation of a generic 1xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The request is being processed.'**
  String get diagSipProvisionalExplain;

  /// Title for a 2xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Success ({code})'**
  String diagSipSuccessTitle(int code);

  /// Explanation of a generic 2xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The request succeeded.'**
  String get diagSipSuccessExplain;

  /// Title for a 3xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Redirected ({code})'**
  String diagSipRedirectedTitle(int code);

  /// Explanation of a generic 3xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The destination moved.'**
  String get diagSipRedirectedExplain;

  /// Suggested fix for a generic 3xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Check forwarding settings.'**
  String get diagSipRedirectedFix;

  /// Title for a generic 4xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Client error ({code})'**
  String diagSipClientErrorTitle(int code);

  /// Explanation of a generic 4xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The server rejected the request.'**
  String get diagSipClientErrorExplain;

  /// Suggested fix for a generic 4xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Check the account and dialled number.'**
  String get diagSipClientErrorFix;

  /// Title for a generic 5xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code})'**
  String diagSipServerErrorTitle(int code);

  /// Explanation of a generic 5xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The server failed to process the request.'**
  String get diagSipServerErrorExplain;

  /// Suggested fix for a generic 5xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Retry later or contact the provider.'**
  String get diagSipServerErrorFix;

  /// Title for a 6xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'Global failure ({code})'**
  String diagSipGlobalFailureTitle(int code);

  /// Explanation of a generic 6xx SIP response.
  ///
  /// In en, this message translates to:
  /// **'The request cannot be fulfilled anywhere.'**
  String get diagSipGlobalFailureExplain;

  /// Title when no SIP response was received.
  ///
  /// In en, this message translates to:
  /// **'No response'**
  String get diagSipNoResponseTitle;

  /// Explanation when no SIP response was received.
  ///
  /// In en, this message translates to:
  /// **'No SIP response was received.'**
  String get diagSipNoResponseExplain;

  /// Suggested fix when no SIP response was received.
  ///
  /// In en, this message translates to:
  /// **'Check the network connection and server address.'**
  String get diagSipNoResponseFix;

  /// Title of a network check step.
  ///
  /// In en, this message translates to:
  /// **'Network connectivity'**
  String get diagWizStepNet;

  /// Title of the DNS check step for an account.
  ///
  /// In en, this message translates to:
  /// **'DNS and SRV: {account}'**
  String diagWizStepDns(String account);

  /// Title of the NAT check step.
  ///
  /// In en, this message translates to:
  /// **'NAT type'**
  String get diagWizStepNat;

  /// Title of the server reachability check step for an account.
  ///
  /// In en, this message translates to:
  /// **'Server reachability: {account}'**
  String diagWizStepOptions(String account);

  /// Title of the TLS certificate check step for an account.
  ///
  /// In en, this message translates to:
  /// **'TLS certificate: {account}'**
  String diagWizStepTls(String account);

  /// Title of the registration check step for an account.
  ///
  /// In en, this message translates to:
  /// **'Registration: {account}'**
  String diagWizStepReg(String account);

  /// Title of the SIP ALG check step (ALG = application layer gateway in routers).
  ///
  /// In en, this message translates to:
  /// **'SIP ALG check'**
  String get diagWizStepAlg;

  /// Summary shown while a network check step is running.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get diagWizChecking;

  /// Network check failed because the SIP engine reported an error.
  ///
  /// In en, this message translates to:
  /// **'Engine error: {message}'**
  String diagWizEngineError(String message);

  /// Network check step failed with an unexpected error.
  ///
  /// In en, this message translates to:
  /// **'Check failed: {error}'**
  String diagWizCheckFailed(String error);

  /// Network check skipped because the SIP engine is not running.
  ///
  /// In en, this message translates to:
  /// **'The SIP engine is not running'**
  String get diagWizNoEngine;

  /// Suggested fix when the SIP engine is not running.
  ///
  /// In en, this message translates to:
  /// **'Wait for the engine to start (or restart the app), then run the checks again.'**
  String get diagWizNoEngineFix;

  /// Detail line of the connectivity check: network interface name and its private IP address.
  ///
  /// In en, this message translates to:
  /// **'{interface}: {address} (private)'**
  String diagWizNetAddrPrivate(String interface, String address);

  /// Connectivity check failure.
  ///
  /// In en, this message translates to:
  /// **'No active network interface with an IP address'**
  String get diagWizNetNone;

  /// Suggested fix when no network interface is active.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi, Ethernet or mobile data, then run the checks again.'**
  String get diagWizNetNoneFix;

  /// Connectivity check warning.
  ///
  /// In en, this message translates to:
  /// **'Only IPv6 addresses found'**
  String get diagWizNetIpv6Only;

  /// Suggested fix for IPv6-only networks.
  ///
  /// In en, this message translates to:
  /// **'Many SIP providers are IPv4 only. Enable IPv4 on this network or use a provider with IPv6 support.'**
  String get diagWizNetIpv6OnlyFix;

  /// Connectivity check result: number of IPv4 addresses and network interfaces.
  ///
  /// In en, this message translates to:
  /// **'{v4, plural, =1{1 IPv4 address} other{{v4} IPv4 addresses}} on {ifaces, plural, =1{1 interface} other{{ifaces} interfaces}}'**
  String diagWizNetSummary(int v4, int ifaces);

  /// Warning about an active VPN interface.
  ///
  /// In en, this message translates to:
  /// **'A VPN-style interface is active. VPNs can add latency or block UDP; disable it if calls misbehave.'**
  String get diagWizNetVpnFix;

  /// DNS check failure.
  ///
  /// In en, this message translates to:
  /// **'The account has no server address'**
  String get diagWizDnsNoServer;

  /// Suggested fix when an account has no server.
  ///
  /// In en, this message translates to:
  /// **'Edit the account and enter the SIP domain.'**
  String get diagWizDnsNoServerFix;

  /// DNS check result when the server is an IP address.
  ///
  /// In en, this message translates to:
  /// **'{host} is an IP address, no DNS needed'**
  String diagWizDnsIpLiteral(String host);

  /// DNS detail line: no address records found.
  ///
  /// In en, this message translates to:
  /// **'A/AAAA: none'**
  String get diagWizDnsANone;

  /// DNS detail line: no address records, with the lookup error.
  ///
  /// In en, this message translates to:
  /// **'A/AAAA: none ({error})'**
  String diagWizDnsANoneError(String error);

  /// DNS detail line: no SRV records for the given record name (technical).
  ///
  /// In en, this message translates to:
  /// **'SRV {name}: none'**
  String diagWizDnsSrvNone(String name);

  /// DNS detail line describing one SRV record (technical).
  ///
  /// In en, this message translates to:
  /// **'SRV {name}: {target}:{port} (priority {priority}, weight {weight})'**
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  );

  /// DNS detail line: SRV lookup failed for a transport (udp, tcp or tls).
  ///
  /// In en, this message translates to:
  /// **'SRV {transport}: lookup failed ({error})'**
  String diagWizDnsSrvFailed(String transport, String error);

  /// DNS check failure.
  ///
  /// In en, this message translates to:
  /// **'{host} does not resolve'**
  String diagWizDnsNotResolved(String host);

  /// Suggested fix when the domain does not resolve.
  ///
  /// In en, this message translates to:
  /// **'Check the domain for typos, and that your DNS server works. You can set a custom DNS server in Settings > Network (e.g. 8.8.8.8).'**
  String get diagWizDnsNotResolvedFix;

  /// DNS check warning.
  ///
  /// In en, this message translates to:
  /// **'{host} has SRV records but no address record'**
  String diagWizDnsSrvOnly(String host);

  /// Suggested fix for SRV-only hosts.
  ///
  /// In en, this message translates to:
  /// **'SRV targets will be used. If calls fail, ask the provider to check the A record.'**
  String get diagWizDnsSrvOnlyFix;

  /// DNS check success: first address, number of additional addresses and number of SRV records.
  ///
  /// In en, this message translates to:
  /// **'{host} resolves to {address}{more, plural, =0{} other{ (+{more})}}{srv, plural, =0{} =1{, 1 SRV record} other{, {srv} SRV records}}'**
  String diagWizDnsResolves(String host, String address, int more, int srv);

  /// NAT check warning.
  ///
  /// In en, this message translates to:
  /// **'NAT detection timed out'**
  String get diagWizNatTimeout;

  /// Suggested fix for NAT detection timeout.
  ///
  /// In en, this message translates to:
  /// **'The STUN server may be unreachable (UDP blocked?). Check Settings > Network > STUN servers.'**
  String get diagWizNatTimeoutFix;

  /// NAT check detail line.
  ///
  /// In en, this message translates to:
  /// **'STUN server: {server}'**
  String diagWizNatStun(String server);

  /// NAT check result.
  ///
  /// In en, this message translates to:
  /// **'No NAT: this device has a public address'**
  String get diagWizNatOpen;

  /// NAT check result.
  ///
  /// In en, this message translates to:
  /// **'Full cone NAT: friendly to VoIP'**
  String get diagWizNatFullCone;

  /// NAT check result.
  ///
  /// In en, this message translates to:
  /// **'Restricted cone NAT: works with STUN and keep-alives'**
  String get diagWizNatRestricted;

  /// NAT check result.
  ///
  /// In en, this message translates to:
  /// **'Port-restricted cone NAT: works with STUN and keep-alives'**
  String get diagWizNatPortRestricted;

  /// NAT check warning.
  ///
  /// In en, this message translates to:
  /// **'Symmetric NAT: STUN alone cannot predict the media port'**
  String get diagWizNatSymmetric;

  /// Suggested fix for symmetric NAT.
  ///
  /// In en, this message translates to:
  /// **'One-way audio or no audio is likely on some calls. Enable ICE and a TURN relay in the account settings (Account > NAT), or use a provider/PBX with media relay (rtpengine).'**
  String get diagWizNatSymmetricFix;

  /// NAT check failure.
  ///
  /// In en, this message translates to:
  /// **'UDP appears to be blocked'**
  String get diagWizNatBlocked;

  /// Suggested fix when UDP is blocked.
  ///
  /// In en, this message translates to:
  /// **'Use TCP or TLS transport for the account. If the network filters all but web traffic, try TLS on port 443 if your provider supports it.'**
  String get diagWizNatBlockedFix;

  /// NAT check warning.
  ///
  /// In en, this message translates to:
  /// **'NAT type could not be determined'**
  String get diagWizNatUnknown;

  /// Suggested fix when the NAT type is unknown.
  ///
  /// In en, this message translates to:
  /// **'The STUN server did not answer. Try another STUN server in Settings > Network.'**
  String get diagWizNatUnknownFix;

  /// Plain-language NAT detection detail when the engine reported an error.
  ///
  /// In en, this message translates to:
  /// **'The STUN server did not answer, so the NAT type could not be determined.'**
  String get diagWizNatErr;

  /// Plain-language NAT detection detail when the engine reported unknown.
  ///
  /// In en, this message translates to:
  /// **'The NAT type could not be determined.'**
  String get diagWizNatUnknownRaw;

  /// Reachability check skipped.
  ///
  /// In en, this message translates to:
  /// **'The account is not loaded in the engine'**
  String get diagWizOptionsNotLoaded;

  /// Reachability failure. OPTIONS is a SIP request; s = seconds; transport is a protocol name.
  ///
  /// In en, this message translates to:
  /// **'No answer to OPTIONS within {seconds} s (transport: {transport})'**
  String diagWizOptionsNoAnswer(int seconds, String transport);

  /// Suggested fix when the server does not answer.
  ///
  /// In en, this message translates to:
  /// **'The server is not reachable. Check the address and port, that a firewall is not dropping SIP, and try another transport (TCP/TLS).'**
  String get diagWizOptionsNoAnswerFix;

  /// Reachability failure with SIP status code and reason phrase.
  ///
  /// In en, this message translates to:
  /// **'Request timed out ({code} {reason})'**
  String diagWizOptionsTimedOut(int code, String reason);

  /// Reachability warning: SIP server error response with round-trip time.
  ///
  /// In en, this message translates to:
  /// **'Server answered {code} {reason} after {ms} ms'**
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms);

  /// Reachability result: SIP response with round-trip time.
  ///
  /// In en, this message translates to:
  /// **'Server answered {code} {reason} in {ms} ms'**
  String diagWizOptionsAnsweredIn(int code, String reason, int ms);

  /// Reachability detail explaining a 4xx reply to the OPTIONS probe.
  ///
  /// In en, this message translates to:
  /// **'A {code} to OPTIONS is normal: the server is reachable but does not allow anonymous probes.'**
  String diagWizOptionsNormalError(int code);

  /// Suggested fix for high latency.
  ///
  /// In en, this message translates to:
  /// **'Round-trip time above 300 ms adds noticeable delay to conversations. A closer server or wired connection helps.'**
  String get diagWizOptionsSlowFix;

  /// TLS check failure.
  ///
  /// In en, this message translates to:
  /// **'The server certificate was rejected'**
  String get diagWizTlsRejected;

  /// Certificate detail: subject name.
  ///
  /// In en, this message translates to:
  /// **'Subject: {value}'**
  String diagWizTlsSubject(String value);

  /// Certificate detail: issuer name.
  ///
  /// In en, this message translates to:
  /// **'Issuer: {value}'**
  String diagWizTlsIssuer(String value);

  /// Certificate detail: list of verification problems.
  ///
  /// In en, this message translates to:
  /// **'Problems: {value}'**
  String diagWizTlsProblems(String value);

  /// Certificate detail: expiry date.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String diagWizTlsExpires(String date);

  /// TLS detail: cipher suite.
  ///
  /// In en, this message translates to:
  /// **'Cipher: {cipher}'**
  String diagWizTlsCipher(String cipher);

  /// Suggested fix for a rejected certificate.
  ///
  /// In en, this message translates to:
  /// **'If this is your own PBX with a self-signed certificate and the fingerprint above matches, you can trust it. Otherwise ask the provider for a certificate from a public CA.'**
  String get diagWizTlsRejectedFix;

  /// Button in the TLS check step to pin the rejected certificate.
  ///
  /// In en, this message translates to:
  /// **'Trust this certificate'**
  String get diagWizTlsTrust;

  /// TLS check failure.
  ///
  /// In en, this message translates to:
  /// **'The certificate expired on {date}'**
  String diagWizTlsExpired(String date);

  /// Suggested fix for an expired certificate.
  ///
  /// In en, this message translates to:
  /// **'Ask the server administrator to renew the certificate.'**
  String get diagWizTlsExpiredFix;

  /// TLS check warning.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{The certificate expires in 1 day} other{The certificate expires in {days} days}}'**
  String diagWizTlsExpiresSoon(int days);

  /// Suggested fix for a soon-to-expire certificate.
  ///
  /// In en, this message translates to:
  /// **'Tell the server administrator to renew it soon.'**
  String get diagWizTlsExpiresSoonFix;

  /// TLS check warning.
  ///
  /// In en, this message translates to:
  /// **'Connected, but verification reported: {problems}'**
  String diagWizTlsVerifyReported(String problems);

  /// TLS check success.
  ///
  /// In en, this message translates to:
  /// **'TLS connection established, certificate valid'**
  String get diagWizTlsOk;

  /// TLS check success.
  ///
  /// In en, this message translates to:
  /// **'Registered over TLS (no certificate details reported)'**
  String get diagWizTlsRegistered;

  /// TLS check warning.
  ///
  /// In en, this message translates to:
  /// **'No TLS connection has been observed yet'**
  String get diagWizTlsNone;

  /// Suggested fix when no TLS connection was seen.
  ///
  /// In en, this message translates to:
  /// **'Check the TLS port (usually 5061) and that the server accepts TLS 1.2 or newer.'**
  String get diagWizTlsNoneFix;

  /// Registration check result.
  ///
  /// In en, this message translates to:
  /// **'Registration is disabled for this account (peer-to-peer use)'**
  String get diagWizRegDisabledByConfig;

  /// Registration check success.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get diagWizRegRegistered;

  /// Registration check success with expiry in seconds.
  ///
  /// In en, this message translates to:
  /// **'Registered (expires in {seconds} s)'**
  String diagWizRegRegisteredExpires(int seconds);

  /// Registration detail line.
  ///
  /// In en, this message translates to:
  /// **'Transport: {transport}'**
  String diagWizRegTransport(String transport);

  /// Registration check warning.
  ///
  /// In en, this message translates to:
  /// **'Registration is still in progress'**
  String get diagWizRegInProgress;

  /// Suggested fix while registration is in progress.
  ///
  /// In en, this message translates to:
  /// **'Wait a few seconds. If it never completes, the server is not answering; see the reachability check above.'**
  String get diagWizRegInProgressFix;

  /// Registration check failure.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get diagWizRegFailed;

  /// Registration check warning.
  ///
  /// In en, this message translates to:
  /// **'The account is offline'**
  String get diagWizRegOffline;

  /// Suggested fix for an offline account.
  ///
  /// In en, this message translates to:
  /// **'Check the network connection. The app retries automatically.'**
  String get diagWizRegOfflineFix;

  /// Registration check skipped.
  ///
  /// In en, this message translates to:
  /// **'The account is disabled'**
  String get diagWizRegDisabled;

  /// SIP ALG check skipped.
  ///
  /// In en, this message translates to:
  /// **'No account uses UDP, so SIP ALG is not a concern'**
  String get diagWizAlgNoUdp;

  /// SIP ALG detail line.
  ///
  /// In en, this message translates to:
  /// **'{account}: no answer over UDP, but TCP answered ({code}, {ms} ms)'**
  String diagWizAlgTcpOnly(String account, int code, int ms);

  /// SIP ALG detail line.
  ///
  /// In en, this message translates to:
  /// **'{account}: no answer over UDP or TCP (server or firewall problem rather than ALG)'**
  String diagWizAlgNoAnswer(String account);

  /// SIP ALG detail line.
  ///
  /// In en, this message translates to:
  /// **'{account}: OPTIONS is answered but REGISTER times out, which is typical of a router rewriting SIP'**
  String diagWizAlgRegisterTimeout(String account);

  /// SIP ALG check failure.
  ///
  /// In en, this message translates to:
  /// **'SIP ALG suspected on your router'**
  String get diagWizAlgSuspected;

  /// Suggested fix for SIP ALG.
  ///
  /// In en, this message translates to:
  /// **'Disable \"SIP ALG\" / \"SIP helper\" in the router settings, or switch the account to TCP or TLS, or change the SIP port (e.g. 5080) so the router stops mangling packets.'**
  String get diagWizAlgSuspectedFix;

  /// SIP ALG check warning.
  ///
  /// In en, this message translates to:
  /// **'The Contact address changed between request and reply'**
  String get diagWizAlgContactChanged;

  /// Suggested fix when the Contact address changed.
  ///
  /// In en, this message translates to:
  /// **'This can be a SIP ALG or a server that rewrites contacts. If calls ring but have no audio or drop after a while, disable SIP ALG on the router or use TCP/TLS or port 5080.'**
  String get diagWizAlgContactChangedFix;

  /// SIP ALG check success.
  ///
  /// In en, this message translates to:
  /// **'No sign of SIP ALG interference'**
  String get diagWizAlgOk;

  /// SIP ALG detail line comparing contact addresses.
  ///
  /// In en, this message translates to:
  /// **'REGISTER Contact {sent} came back as {received}'**
  String diagWizAlgContactRewritten(String sent, String received);

  /// Title of the system save-file dialog for a diagnostics export.
  ///
  /// In en, this message translates to:
  /// **'Save {fileName}'**
  String diagSaveDialogTitle(String fileName);

  /// Notice after a diagnostics file was saved.
  ///
  /// In en, this message translates to:
  /// **'Saved {fileName}'**
  String diagSavedFile(String fileName);

  /// Error notice when saving a diagnostics file failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the file'**
  String get diagSaveFailed;

  /// Notice after copying text in diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Text copied to the clipboard'**
  String get diagCopiedText;

  /// Notice after copying the network check report.
  ///
  /// In en, this message translates to:
  /// **'Report copied to the clipboard'**
  String get diagCopiedReport;

  /// Notice after copying the diagnostic bundle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic bundle copied to the clipboard'**
  String get diagCopiedBundle;

  /// Notice after copying engine logs.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to the clipboard'**
  String get diagCopiedLogs;

  /// Notice after copying the SIP trace.
  ///
  /// In en, this message translates to:
  /// **'Trace copied to the clipboard'**
  String get diagCopiedTrace;

  /// Notice after copying one SIP dialog.
  ///
  /// In en, this message translates to:
  /// **'Dialog copied to the clipboard'**
  String get diagCopiedDialog;

  /// Menu item: save as a .log text file (keep the extension).
  ///
  /// In en, this message translates to:
  /// **'Save as .log'**
  String get diagSaveAsLog;

  /// Row label in the System tab.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get diagSysAppVersion;

  /// Row label in the System tab (operating system).
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get diagSysPlatform;

  /// Row label in the System tab (SIP engine).
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get diagSysEngine;

  /// Row label in the System tab.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get diagSysAccounts;

  /// Value in the System tab: how many accounts are registered.
  ///
  /// In en, this message translates to:
  /// **'{registered} of {total} registered'**
  String diagSysAccountsRegistered(int registered, int total);

  /// Row label in the System tab for the LAN Link feature.
  ///
  /// In en, this message translates to:
  /// **'LAN Link'**
  String get diagSysLanLink;

  /// Error text in the System tab.
  ///
  /// In en, this message translates to:
  /// **'Could not read system information: {error}'**
  String diagSysReadError(String error);

  /// Group title in the System tab.
  ///
  /// In en, this message translates to:
  /// **'Transports'**
  String get diagSysTransports;

  /// Empty state for the transports list.
  ///
  /// In en, this message translates to:
  /// **'None reported'**
  String get diagSysNoneReported;

  /// Group title in the System tab.
  ///
  /// In en, this message translates to:
  /// **'Codecs'**
  String get diagSysCodecs;

  /// Footer below the codec list.
  ///
  /// In en, this message translates to:
  /// **'Enabled codecs, highest priority first.'**
  String get diagSysCodecsFooter;

  /// Empty state for the codec list.
  ///
  /// In en, this message translates to:
  /// **'Engine not running'**
  String get diagSysEngineNotRunning;

  /// Trailing text of an enabled codec row.
  ///
  /// In en, this message translates to:
  /// **'priority {priority}'**
  String diagSysCodecPriority(int priority);

  /// Trailing text of a disabled codec row.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get diagSysCodecDisabled;

  /// Group title in the System tab.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get diagSysExport;

  /// Footer below the export buttons.
  ///
  /// In en, this message translates to:
  /// **'The bundle holds system info, network check results, recent logs and the SIP trace, with credentials redacted.'**
  String get diagSysExportFooter;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostic bundle'**
  String get diagSysCopyBundle;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Save diagnostic bundle'**
  String get diagSysSaveBundle;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'SIP trace'**
  String get diagTabSipTrace;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get diagTabNetwork;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get diagTabQuality;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'Audio test'**
  String get diagTabAudioTest;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get diagTabLogs;

  /// Tab label of the Diagnostics page.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get diagTabSystem;

  /// Raw message header: outgoing message destination.
  ///
  /// In en, this message translates to:
  /// **'sent to {remote}'**
  String diagRawSentTo(String remote);

  /// Raw message header: incoming message source.
  ///
  /// In en, this message translates to:
  /// **'received from {remote}'**
  String diagRawReceivedFrom(String remote);

  /// Snackbar after copying a raw SIP message.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get diagRawCopied;

  /// Button / segment: show the SIP ladder diagram.
  ///
  /// In en, this message translates to:
  /// **'Ladder'**
  String get diagRawLadder;

  /// Filter chip: hide credentials in the raw message.
  ///
  /// In en, this message translates to:
  /// **'Redact credentials'**
  String get diagRawRedact;

  /// Marker at the end of a raw message that was too long to show.
  ///
  /// In en, this message translates to:
  /// **'... truncated ({count} chars)'**
  String diagRawTruncated(int count);

  /// Intro text of the Network tab.
  ///
  /// In en, this message translates to:
  /// **'Checks your connection, DNS, NAT, server reachability, TLS and registration, and explains what to fix.'**
  String get diagWizIntro;

  /// Button / tooltip: stop the running checks or tone.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get diagWizStop;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Run checks'**
  String get diagWizRunChecks;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Run again'**
  String get diagWizRunAgain;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get diagWizCopyReport;

  /// Button label.
  ///
  /// In en, this message translates to:
  /// **'Save report'**
  String get diagWizSaveReport;

  /// Chip: number of passed checks.
  ///
  /// In en, this message translates to:
  /// **'Passed {count}'**
  String diagWizCountPassed(int count);

  /// Chip: number of checks with warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings {count}'**
  String diagWizCountWarnings(int count);

  /// Chip: number of failed checks.
  ///
  /// In en, this message translates to:
  /// **'Failed {count}'**
  String diagWizCountFailed(int count);

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get diagWizStatusPass;

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get diagWizStatusWarn;

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get diagWizStatusFail;

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get diagWizStatusSkipped;

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get diagWizStatusRunning;

  /// Screen-reader label of the status icon of a check step.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get diagWizStatusPending;

  /// Title of the call quality sheet.
  ///
  /// In en, this message translates to:
  /// **'Call quality'**
  String get diagQualityTitle;

  /// Empty state in the call quality sheet.
  ///
  /// In en, this message translates to:
  /// **'No quality data was recorded for this call.'**
  String get diagQualityNoData;

  /// Button: open the SIP trace of the call.
  ///
  /// In en, this message translates to:
  /// **'SIP trace for this call'**
  String get diagQualityTraceForCall;

  /// Disabled button label.
  ///
  /// In en, this message translates to:
  /// **'SIP trace not captured for this call'**
  String get diagQualityTraceNotCaptured;

  /// Section header in the Quality tab.
  ///
  /// In en, this message translates to:
  /// **'Live call'**
  String get diagQualityLiveCall;

  /// Empty state in the Quality tab. MOS = mean opinion score.
  ///
  /// In en, this message translates to:
  /// **'No active call. Start a call and MOS, jitter, loss and round-trip time are plotted here live.'**
  String get diagQualityNoActiveCall;

  /// Section header in the Quality tab.
  ///
  /// In en, this message translates to:
  /// **'Recent calls'**
  String get diagQualityRecentCalls;

  /// Empty state in the Quality tab.
  ///
  /// In en, this message translates to:
  /// **'No finished calls with quality data yet.'**
  String get diagQualityNoFinished;

  /// Shown in the live quality sheet when the call is gone.
  ///
  /// In en, this message translates to:
  /// **'The call has ended.'**
  String get diagQualityCallEnded;

  /// Used in the MOS gauge screen-reader label while no score is available.
  ///
  /// In en, this message translates to:
  /// **'measuring'**
  String get diagQualityMeasuring;

  /// Screen-reader label of the MOS gauge: score (or "measuring") and quality word.
  ///
  /// In en, this message translates to:
  /// **'MOS {value}, {quality}'**
  String diagQualityMosSemantics(String value, String quality);

  /// Screen-reader label of a quality chart without data.
  ///
  /// In en, this message translates to:
  /// **'{title} chart'**
  String diagQualityChartSemantics(String title);

  /// Screen-reader label of a quality chart; value includes the unit.
  ///
  /// In en, this message translates to:
  /// **'{title} chart, latest {value}'**
  String diagQualityChartSemanticsLatest(String title, String value);

  /// Chart header: latest value with unit, and maximum.
  ///
  /// In en, this message translates to:
  /// **'{latest}   max {max}'**
  String diagQualityLatestMax(String latest, String max);

  /// Summary under the MOS gauge of a finished call.
  ///
  /// In en, this message translates to:
  /// **'Average {avg}  ·  worst {worst}'**
  String diagQualityAvgWorst(String avg, String worst);

  /// Stat chip label.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get diagQualityCodec;

  /// Stat chip label (packet loss).
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get diagQualityLoss;

  /// Stat chip label and chart title.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get diagQualityJitter;

  /// Stat chip value: packet count.
  ///
  /// In en, this message translates to:
  /// **'{count} pkts'**
  String diagQualityPackets(int count);

  /// Stat chip label (media protocol).
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get diagQualityMedia;

  /// Empty state under the gauge.
  ///
  /// In en, this message translates to:
  /// **'No time series was recorded for this call.'**
  String get diagQualityNoSeries;

  /// Chart title.
  ///
  /// In en, this message translates to:
  /// **'Packet loss'**
  String get diagQualityPacketLoss;

  /// Chart title.
  ///
  /// In en, this message translates to:
  /// **'Round-trip time'**
  String get diagQualityRtt;

  /// Switch title in the Logs tab.
  ///
  /// In en, this message translates to:
  /// **'Forward engine logs'**
  String get diagLogsForward;

  /// Switch subtitle in the Logs tab.
  ///
  /// In en, this message translates to:
  /// **'Send pjsip log lines to this viewer'**
  String get diagLogsForwardSub;

  /// Dropdown item: log level number and its technical name (not translated).
  ///
  /// In en, this message translates to:
  /// **'Level {level} ({name})'**
  String diagLogsLevel(int level, String name);

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Redact on export'**
  String get diagLogsRedact;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search logs'**
  String get diagLogsSearch;

  /// Empty state in the Logs tab.
  ///
  /// In en, this message translates to:
  /// **'No log lines yet.'**
  String get diagLogsEmpty;

  /// Empty state in the Logs tab.
  ///
  /// In en, this message translates to:
  /// **'Log forwarding is off. Turn it on to capture engine logs.'**
  String get diagLogsForwardingOff;

  /// Empty state when the search matches nothing.
  ///
  /// In en, this message translates to:
  /// **'No lines match the search.'**
  String get diagLogsNoMatch;

  /// Error in the Audio test tab.
  ///
  /// In en, this message translates to:
  /// **'The SIP engine is not running.'**
  String get diagAudioEngineNotRunning;

  /// Group title in the Audio test tab.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get diagAudioMicrophone;

  /// Footer of the microphone group.
  ///
  /// In en, this message translates to:
  /// **'The level meter reads the audio device, which the engine opens during a call or the echo test.'**
  String get diagAudioMicFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Level meter'**
  String get diagAudioLevelMeter;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak and watch the bar move'**
  String get diagAudioLevelMeterSub;

  /// Label of the microphone level bar.
  ///
  /// In en, this message translates to:
  /// **'Mic'**
  String get diagAudioMic;

  /// Label of the speaker level bar.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get diagAudioSpeaker;

  /// Group title and switch title.
  ///
  /// In en, this message translates to:
  /// **'Echo test'**
  String get diagAudioEchoTest;

  /// Footer of the echo test group.
  ///
  /// In en, this message translates to:
  /// **'Plays your voice back through the speaker. Use headphones to avoid feedback.'**
  String get diagAudioEchoFooter;

  /// Subtitle while the echo test is on.
  ///
  /// In en, this message translates to:
  /// **'Active: speak now'**
  String get diagAudioEchoActive;

  /// Subtitle while the echo test is off.
  ///
  /// In en, this message translates to:
  /// **'Mic to speaker loopback'**
  String get diagAudioEchoIdle;

  /// Group title.
  ///
  /// In en, this message translates to:
  /// **'Speaker test'**
  String get diagAudioSpeakerTest;

  /// List tile title.
  ///
  /// In en, this message translates to:
  /// **'Play test tone'**
  String get diagAudioPlayTone;

  /// List tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Plays through the selected speaker'**
  String get diagAudioPlayToneSub;

  /// Subtitle while the DTMF test tone plays.
  ///
  /// In en, this message translates to:
  /// **'Playing DTMF'**
  String get diagAudioPlayingDtmf;

  /// Subtitle while the ringback test tone plays.
  ///
  /// In en, this message translates to:
  /// **'Playing ringback'**
  String get diagAudioPlayingRingback;

  /// Button: play the ringback tone (the sound heard while the other phone rings).
  ///
  /// In en, this message translates to:
  /// **'Ringback'**
  String get diagAudioRingback;

  /// Group title.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get diagAudioDevices;

  /// Navigation tile title.
  ///
  /// In en, this message translates to:
  /// **'Choose microphone and speaker'**
  String get diagAudioChooseDevices;

  /// Navigation tile subtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens Settings > Audio'**
  String get diagAudioChooseDevicesSub;

  /// Screen-reader label of a level bar.
  ///
  /// In en, this message translates to:
  /// **'{label} level {percent} percent'**
  String diagAudioLevelSemantics(String label, int percent);

  /// Header of the local lane in the SIP ladder diagram.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get diagLadderLocal;

  /// Screen-reader label of a ladder arrow for an outgoing SIP message.
  ///
  /// In en, this message translates to:
  /// **'Sent {message}'**
  String diagLadderSent(String message);

  /// Screen-reader label of a ladder arrow for an incoming SIP message.
  ///
  /// In en, this message translates to:
  /// **'Received {message}'**
  String diagLadderReceived(String message);

  /// Switch title in the SIP trace tab.
  ///
  /// In en, this message translates to:
  /// **'Capture SIP messages'**
  String get diagTraceCapture;

  /// Switch subtitle: captured message count and size.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}  ·  {size}'**
  String diagTraceStats(int count, String size);

  /// Switch subtitle with number of dropped old messages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}  ·  {size}  ·  {dropped} older dropped'**
  String diagTraceStatsDropped(int count, String size, int dropped);

  /// Switch subtitle when capture is off.
  ///
  /// In en, this message translates to:
  /// **'Off. Turn on, then register or make a call.'**
  String get diagTraceOffHint;

  /// Tooltip of the trace menu button.
  ///
  /// In en, this message translates to:
  /// **'Export or clear'**
  String get diagTraceExportOrClear;

  /// Menu item (keep the extension).
  ///
  /// In en, this message translates to:
  /// **'Save as .pcap'**
  String get diagTraceSaveAsPcap;

  /// Menu item.
  ///
  /// In en, this message translates to:
  /// **'Copy as text'**
  String get diagTraceCopyAsText;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search text, number or Call-ID'**
  String get diagTraceSearchHint;

  /// Filter chip.
  ///
  /// In en, this message translates to:
  /// **'Errors only'**
  String get diagTraceErrorsOnly;

  /// Tooltip of the SIP method filter.
  ///
  /// In en, this message translates to:
  /// **'Filter by method'**
  String get diagTraceFilterMethod;

  /// Menu item clearing the method filter.
  ///
  /// In en, this message translates to:
  /// **'All methods'**
  String get diagTraceAllMethods;

  /// Chip label of the SIP method filter when none is chosen.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get diagTraceMethod;

  /// Tooltip of the account filter.
  ///
  /// In en, this message translates to:
  /// **'Filter by account'**
  String get diagTraceFilterAccount;

  /// Menu item clearing the account filter.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get diagTraceAllAccounts;

  /// Chip label of the account filter when none is chosen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get diagTraceAccount;

  /// Filter chip: hide credentials.
  ///
  /// In en, this message translates to:
  /// **'Redact'**
  String get diagTraceRedact;

  /// Segment label: list view of messages.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get diagTraceList;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'Waiting for SIP traffic'**
  String get diagTraceWaiting;

  /// Empty state text.
  ///
  /// In en, this message translates to:
  /// **'Register an account or make a call and the messages appear here.'**
  String get diagTraceWaitingSub;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'SIP trace is off'**
  String get diagTraceOff;

  /// Empty state text.
  ///
  /// In en, this message translates to:
  /// **'Turn on capture to see every SIP request and response, as a list or a ladder diagram.'**
  String get diagTraceOffSub;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No messages match the filters'**
  String get diagTraceNoMatch;

  /// Tooltip of the back button in the ladder view.
  ///
  /// In en, this message translates to:
  /// **'All dialogs'**
  String get diagTraceAllDialogs;

  /// Tooltip of the copy button in the ladder view.
  ///
  /// In en, this message translates to:
  /// **'Copy this dialog'**
  String get diagTraceCopyDialog;

  /// Dialog summary when no SIP response was captured.
  ///
  /// In en, this message translates to:
  /// **'no response'**
  String get diagTraceNoResponse;

  /// Shown when a dialog has no Call-ID header.
  ///
  /// In en, this message translates to:
  /// **'no Call-ID'**
  String get diagTraceNoCallId;

  /// Number of SIP messages in a dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String diagTraceMessageCount(int count);

  /// Fallback title of a recording that has no name, contact or number.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recTitleFallback;

  /// Recording settings: radio option label for the mono WAV format.
  ///
  /// In en, this message translates to:
  /// **'Standard (WAV)'**
  String get recFormatWav;

  /// Recording settings: radio option label for the stereo WAV format.
  ///
  /// In en, this message translates to:
  /// **'Stereo, you and the caller on separate channels (WAV)'**
  String get recFormatWavStereo;

  /// Recording settings: radio option label for the compressed Opus format.
  ///
  /// In en, this message translates to:
  /// **'Compressed (Opus)'**
  String get recFormatOpus;

  /// Recording settings: footer explaining the mono WAV format.
  ///
  /// In en, this message translates to:
  /// **'Mono, about 2 MB per minute. Plays everywhere.'**
  String get recFormatWavHint;

  /// Recording settings: footer explaining the stereo WAV format.
  ///
  /// In en, this message translates to:
  /// **'Two channels, about 4 MB per minute. You on the left, the caller on the right.'**
  String get recFormatWavStereoHint;

  /// Recording settings: footer explaining the Opus format.
  ///
  /// In en, this message translates to:
  /// **'About 0.2 MB per minute. Ogg Opus; some players on iPhone, Mac and Windows cannot open it.'**
  String get recFormatOpusHint;

  /// Per-account automatic recording choice: follow the global rule.
  ///
  /// In en, this message translates to:
  /// **'Use global setting'**
  String get recOptionInherit;

  /// Per-account automatic recording choice.
  ///
  /// In en, this message translates to:
  /// **'Record all calls'**
  String get recOptionAlways;

  /// Per-account automatic recording choice.
  ///
  /// In en, this message translates to:
  /// **'Record incoming calls only'**
  String get recOptionIncoming;

  /// Per-account automatic recording choice.
  ///
  /// In en, this message translates to:
  /// **'Record outgoing calls only'**
  String get recOptionOutgoing;

  /// Per-account automatic recording choice.
  ///
  /// In en, this message translates to:
  /// **'Never record'**
  String get recOptionNever;

  /// Global automatic recording rule: record every call.
  ///
  /// In en, this message translates to:
  /// **'All calls'**
  String get recRuleAll;

  /// Global automatic recording rule.
  ///
  /// In en, this message translates to:
  /// **'Incoming calls only'**
  String get recRuleIncoming;

  /// Global automatic recording rule.
  ///
  /// In en, this message translates to:
  /// **'Outgoing calls only'**
  String get recRuleOutgoing;

  /// Auto-delete option: old recordings are never deleted.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recAutoDeleteNever;

  /// Auto-delete option: delete recordings older than the given number of days.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{After 1 day} other{After {days} days}}'**
  String recAutoDeleteAfterDays(int days);

  /// Auto-delete option: delete recordings older than one year.
  ///
  /// In en, this message translates to:
  /// **'After 1 year'**
  String get recAutoDeleteAfterYear;

  /// Number of recordings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording} other{{count} recordings}}'**
  String recCount(int count);

  /// Recordings storage summary: number of recordings and total size (e.g. 1.4 MB).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording} other{{count} recordings}}  ·  {size}'**
  String recUsageSummary(int count, String size);

  /// Recordings page summary line: number, total size and the auto-delete period.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recording} other{{count} recordings}}  ·  {size}  ·  auto-delete after {days, plural, =1{1 day} other{{days} days}}'**
  String recUsageSummaryAutoDelete(int count, String size, int days);

  /// Recording settings: group title for the recording format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get recSettingsFormat;

  /// Recording settings: group title.
  ///
  /// In en, this message translates to:
  /// **'Automatic recording'**
  String get recSettingsAutoGroup;

  /// Recording settings: footer under the automatic recording group. The quoted text is the name of a switch in the contact editor.
  ///
  /// In en, this message translates to:
  /// **'Check your local laws before recording calls. Turn on \"Always record calls with this contact\" in a contact to record them whatever these rules say.'**
  String get recSettingsAutoFooter;

  /// Recording settings: title of the global automatic recording choice.
  ///
  /// In en, this message translates to:
  /// **'Record calls automatically'**
  String get recSettingsAutoRule;

  /// Recording settings: subtitle of a per-account recording choice.
  ///
  /// In en, this message translates to:
  /// **'Override for this account'**
  String get recSettingsAccountOverride;

  /// Recording settings: group title.
  ///
  /// In en, this message translates to:
  /// **'Notices'**
  String get recSettingsNoticesGroup;

  /// Recording settings: switch title.
  ///
  /// In en, this message translates to:
  /// **'Play a notice before recording'**
  String get recSettingsNoticeSwitch;

  /// Recording settings: switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Plays a notice to the other party first. The notice file is chosen in Settings > Calls > Announcements.'**
  String get recSettingsNoticeSwitchHint;

  /// Recording settings: list item that opens the announcements settings.
  ///
  /// In en, this message translates to:
  /// **'Choose the notice file'**
  String get recSettingsNoticeFile;

  /// Recording settings: subtitle of the list item that opens the announcements settings.
  ///
  /// In en, this message translates to:
  /// **'Opens Settings > Calls > Announcements'**
  String get recSettingsNoticeFileHint;

  /// Recording settings: switch title.
  ///
  /// In en, this message translates to:
  /// **'Recording beep'**
  String get recSettingsBeep;

  /// Recording settings: switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn the other party periodically'**
  String get recSettingsBeepHint;

  /// Recording settings: group title.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get recSettingsTransfersGroup;

  /// Recording settings: switch title.
  ///
  /// In en, this message translates to:
  /// **'Continue recording through transfers'**
  String get recSettingsContinue;

  /// Recording settings: switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Record the consultation call of an attended transfer and the call handed to us by a transfer, and link the recordings'**
  String get recSettingsContinueHint;

  /// Recording settings: group title.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get recSettingsStorageGroup;

  /// Recording settings: text field title for the recordings folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get recSettingsFolder;

  /// Recording settings: subtitle of the folder field.
  ///
  /// In en, this message translates to:
  /// **'Where recordings are saved'**
  String get recSettingsFolderHint;

  /// Recording settings: placeholder shown when no custom folder is set.
  ///
  /// In en, this message translates to:
  /// **'App documents / Recordings'**
  String get recSettingsFolderPlaceholder;

  /// Recording settings: list item that opens a folder picker.
  ///
  /// In en, this message translates to:
  /// **'Choose folder...'**
  String get recSettingsChooseFolder;

  /// Title of the system folder picker dialog.
  ///
  /// In en, this message translates to:
  /// **'Recordings folder'**
  String get recSettingsFolderPickerTitle;

  /// Recording settings: title of the auto-delete choice.
  ///
  /// In en, this message translates to:
  /// **'Delete old recordings'**
  String get recSettingsAutoDelete;

  /// Recording settings: subtitle of the auto-delete choice.
  ///
  /// In en, this message translates to:
  /// **'Checked at startup and once a day'**
  String get recSettingsAutoDeleteHint;

  /// Recording settings: list item that opens the recordings page.
  ///
  /// In en, this message translates to:
  /// **'Manage recordings'**
  String get recSettingsManage;

  /// List item / menu item that opens the recordings folder in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Open recordings folder'**
  String get recSettingsOpenFolder;

  /// Title of the recordings page.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get recPageTitle;

  /// Recordings page title while selecting items.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String recSelectedCount(int count);

  /// Tooltip of the button that leaves selection mode.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get recCancelSelection;

  /// Tooltip of the select-all button.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get recSelectAll;

  /// Tooltip of the button that shares the selected recordings.
  ///
  /// In en, this message translates to:
  /// **'Share selected'**
  String get recShareSelected;

  /// Tooltip of the button that deletes the selected recordings.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get recDeleteSelected;

  /// Tooltip of the search toggle button.
  ///
  /// In en, this message translates to:
  /// **'Search recordings'**
  String get recSearchTooltip;

  /// Tooltip of the button that enters selection mode.
  ///
  /// In en, this message translates to:
  /// **'Select recordings'**
  String get recSelectTooltip;

  /// Menu item and empty-state button that open the recording settings.
  ///
  /// In en, this message translates to:
  /// **'Recording settings'**
  String get recMenuSettings;

  /// Hint text of the recordings search field.
  ///
  /// In en, this message translates to:
  /// **'Search name or number'**
  String get recSearchHint;

  /// Empty state title when there are no recordings.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get recEmptyNone;

  /// Empty state subtitle when there are no recordings.
  ///
  /// In en, this message translates to:
  /// **'Record a call with the Record button, or turn on automatic recording in Settings.'**
  String get recEmptyNoneHint;

  /// Empty state title when filters match nothing.
  ///
  /// In en, this message translates to:
  /// **'No matching recordings'**
  String get recEmptyNoMatch;

  /// Empty state subtitle when filters match nothing.
  ///
  /// In en, this message translates to:
  /// **'Try another search or filter.'**
  String get recEmptyNoMatchHint;

  /// Empty state button that resets the recording filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get recClearFilters;

  /// Confirmation dialog title for deleting the selected recordings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 recording?} other{Delete {count} recordings?}}'**
  String recDeleteManyTitle(int count);

  /// Confirmation dialog text for deleting several recordings.
  ///
  /// In en, this message translates to:
  /// **'The audio files are removed from this device. This cannot be undone.'**
  String get recDeleteManyMessage;

  /// Confirmation dialog title for deleting one recording.
  ///
  /// In en, this message translates to:
  /// **'Delete this recording?'**
  String get recDeleteOneTitle;

  /// Confirmation dialog text for deleting one recording.
  ///
  /// In en, this message translates to:
  /// **'The audio file is removed from this device. This cannot be undone.'**
  String get recDeleteOneMessage;

  /// Recordings filter chip: all call directions.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recFilterAll;

  /// Recordings filter chip: incoming calls.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get recFilterIncoming;

  /// Recordings filter chip: outgoing calls.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get recFilterOutgoing;

  /// Tooltip of the account filter chip.
  ///
  /// In en, this message translates to:
  /// **'Filter by account'**
  String get recFilterByAccount;

  /// Account filter: no account selected.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get recFilterAllAccounts;

  /// Account filter chip label when the selected account no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get recFilterAccountFallback;

  /// Date filter chip label when no range is set.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get recFilterAnyDate;

  /// Date filter chip label showing the selected date range.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String recFilterDateRange(String start, String end);

  /// Chip that removes the date filter.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get recFilterClearDates;

  /// Shown in an expanded recording whose file no longer exists.
  ///
  /// In en, this message translates to:
  /// **'The audio file is missing from this device.'**
  String get recMissingFile;

  /// Chip linking to a related recording (e.g. transfer leg).
  ///
  /// In en, this message translates to:
  /// **'Related: {title}'**
  String recRelated(String title);

  /// Dialog title for renaming a recording.
  ///
  /// In en, this message translates to:
  /// **'Rename recording'**
  String get recRenameTitle;

  /// Hint of the recording name text field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get recRenameHint;

  /// Button that saves a copy of the recording to a chosen location.
  ///
  /// In en, this message translates to:
  /// **'Save as...'**
  String get recSaveAs;

  /// Button that reveals the recording file in Finder (macOS).
  ///
  /// In en, this message translates to:
  /// **'Show in Finder'**
  String get recShowInFinder;

  /// Button that reveals the recording file in the file manager.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get recShowInFolder;

  /// Button that opens the call history for this recording.
  ///
  /// In en, this message translates to:
  /// **'View call'**
  String get recViewCall;

  /// Notice after saving a copy of a recording.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String recSavedTo(String path);

  /// Error notice when saving a recording copy failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the recording'**
  String get recSaveFailed;

  /// Error notice when sharing a recording failed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the recording'**
  String get recShareFailed;

  /// Title of the system save-file dialog.
  ///
  /// In en, this message translates to:
  /// **'Save recording'**
  String get recSaveDialogTitle;

  /// Subject used when sharing several recordings.
  ///
  /// In en, this message translates to:
  /// **'Call recordings'**
  String get recShareSubject;

  /// Recording player message when the format cannot be played in-app.
  ///
  /// In en, this message translates to:
  /// **'This device cannot play Opus recordings here.'**
  String get recPlayerUnsupported;

  /// Button that opens the recording with another app.
  ///
  /// In en, this message translates to:
  /// **'Open with...'**
  String get recPlayerOpenWith;

  /// Recording player error.
  ///
  /// In en, this message translates to:
  /// **'The recording file was not found'**
  String get recPlayerNotFound;

  /// Recording player error with technical reason.
  ///
  /// In en, this message translates to:
  /// **'Cannot play this recording: {error}'**
  String recPlayerCannotPlay(String error);

  /// Tooltip of the play button.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get recPlayerPlay;

  /// Tooltip of the pause button.
  ///
  /// In en, this message translates to:
  /// **'Pause recording'**
  String get recPlayerPause;

  /// Title of the audio files page (hold music and announcements).
  ///
  /// In en, this message translates to:
  /// **'Audio files'**
  String get audioFilesTitle;

  /// Notice after importing an audio file.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\"'**
  String audioAdded(String name);

  /// Error notice when an audio file cannot be played.
  ///
  /// In en, this message translates to:
  /// **'That file is not available.'**
  String get audioFileUnavailable;

  /// Validation error for an empty name.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get audioNameRequired;

  /// Confirmation dialog title for deleting an audio file.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String audioDeleteTitle(String name);

  /// Confirmation dialog text for deleting an audio file.
  ///
  /// In en, this message translates to:
  /// **'Settings that use this file go back to the default.'**
  String get audioDeleteMessage;

  /// Group title on the audio files page.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get audioGroupAdd;

  /// Footer under the Add group.
  ///
  /// In en, this message translates to:
  /// **'WAV (PCM, mu-law, A-law) and MP3 files work. Files are copied into the app, so the original can move.'**
  String get audioAddFooter;

  /// List item that imports an audio file.
  ///
  /// In en, this message translates to:
  /// **'Import a WAV or MP3…'**
  String get audioImport;

  /// Group title for the user's audio files.
  ///
  /// In en, this message translates to:
  /// **'My files'**
  String get audioGroupMine;

  /// Empty state title in the user's audio files list.
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get audioEmptyTitle;

  /// Empty state subtitle in the user's audio files list.
  ///
  /// In en, this message translates to:
  /// **'Import a file or record your own announcement.'**
  String get audioEmptyHint;

  /// Group title for built-in sounds.
  ///
  /// In en, this message translates to:
  /// **'Built in'**
  String get audioGroupBuiltIn;

  /// Footer under the built-in sounds group.
  ///
  /// In en, this message translates to:
  /// **'Generated for SoftphonePro, free to use.'**
  String get audioBuiltInFooter;

  /// Tooltip of the stop button while previewing a sound.
  ///
  /// In en, this message translates to:
  /// **'Stop preview'**
  String get audioPreviewStop;

  /// Tooltip of the preview button of an audio file.
  ///
  /// In en, this message translates to:
  /// **'Preview {name}'**
  String audioPreviewPlay(String name);

  /// Dialog title when saving a new recording.
  ///
  /// In en, this message translates to:
  /// **'Name this recording'**
  String get audioRecordedName;

  /// Default name proposed for a new announcement recording.
  ///
  /// In en, this message translates to:
  /// **'My announcement'**
  String get audioRecordedDefaultName;

  /// Notice after saving a new audio recording.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\"'**
  String audioSaved(String name);

  /// Button that stops recording the microphone.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get audioRecorderStop;

  /// Tooltip of the button that plays back the new recording.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get audioRecorderPlay;

  /// Label of the new recording with its duration.
  ///
  /// In en, this message translates to:
  /// **'New recording  ·  {duration}'**
  String audioRecorderNew(String duration);

  /// Button that discards the new recording.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get audioRecorderDiscard;

  /// List item that starts recording an announcement.
  ///
  /// In en, this message translates to:
  /// **'Record your own…'**
  String get audioRecordOwn;

  /// Subtitle of the record-your-own list item.
  ///
  /// In en, this message translates to:
  /// **'Uses the microphone selected in Audio settings'**
  String get audioRecordOwnHint;

  /// Option label when the chosen audio file no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Missing file'**
  String get audioMissingFile;

  /// Name of the built-in hold music Calm.
  ///
  /// In en, this message translates to:
  /// **'Calm (built-in)'**
  String get audioBuiltInCalm;

  /// Name of the built-in hold music Breeze.
  ///
  /// In en, this message translates to:
  /// **'Breeze (built-in)'**
  String get audioBuiltInBreeze;

  /// Name of the built-in notice chime sound.
  ///
  /// In en, this message translates to:
  /// **'Notice chime (built-in)'**
  String get audioBuiltInChime;

  /// Error when importing an unsupported audio file type.
  ///
  /// In en, this message translates to:
  /// **'Only WAV and MP3 files can be used.'**
  String get audioErrOnlyWavMp3;

  /// Error when the file to import does not exist.
  ///
  /// In en, this message translates to:
  /// **'That file could not be found.'**
  String get audioErrNotFound;

  /// Error when the new recording file is missing.
  ///
  /// In en, this message translates to:
  /// **'The recording was not saved.'**
  String get audioErrNotSaved;

  /// Error when the imported audio file is empty.
  ///
  /// In en, this message translates to:
  /// **'This audio file is empty or unreadable.'**
  String get audioErrEmpty;

  /// Error when the call engine rejects an imported audio file.
  ///
  /// In en, this message translates to:
  /// **'This audio file cannot be used ({reason}). Use PCM, mu-law or A-law WAV, or MP3.'**
  String audioErrUnusable(String reason);

  /// Recorder error.
  ///
  /// In en, this message translates to:
  /// **'The call engine is not running.'**
  String get audioRecEngineOff;

  /// Recorder error.
  ///
  /// In en, this message translates to:
  /// **'This version of the call engine cannot record the microphone.'**
  String get audioRecUnsupported;

  /// Recorder error.
  ///
  /// In en, this message translates to:
  /// **'Could not start recording: {reason}'**
  String audioRecStartFailed(String reason);

  /// Recorder error.
  ///
  /// In en, this message translates to:
  /// **'Recording failed: {reason}'**
  String audioRecFailed(String reason);

  /// Voice isolation strength level.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get audioStrengthLow;

  /// Voice isolation strength level.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get audioStrengthMedium;

  /// Voice isolation strength level.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get audioStrengthHigh;

  /// Voice isolation strength level.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get audioStrengthMax;

  /// Voice isolation strength: level name and percentage, e.g. High (80%).
  ///
  /// In en, this message translates to:
  /// **'{label} ({percent}%)'**
  String audioStrengthText(String label, int percent);

  /// Audio device choice that follows the operating system default.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get audioSystemDefault;

  /// Audio device choice that follows the system default, naming the current device.
  ///
  /// In en, this message translates to:
  /// **'System default ({name})'**
  String audioSystemDefaultNamed(String name);

  /// Title of the voice isolation page.
  ///
  /// In en, this message translates to:
  /// **'Voice isolation'**
  String get voiceTitle;

  /// Banner shown when the engine lacks AI noise cancellation.
  ///
  /// In en, this message translates to:
  /// **'AI noise cancellation is not available in this build of the call engine. The standard noise suppression under Processing still works.'**
  String get voiceUnavailable;

  /// Group title.
  ///
  /// In en, this message translates to:
  /// **'AI noise cancellation'**
  String get voiceGroupAi;

  /// Footer explaining AI noise cancellation.
  ///
  /// In en, this message translates to:
  /// **'Removes keyboard clicks, fans and background voices from the call using an on-device neural network (RNNoise). Nothing leaves your device. Higher strength removes more noise but can clip the start of words.'**
  String get voiceAiFooter;

  /// Switch title: apply noise cancellation to my microphone.
  ///
  /// In en, this message translates to:
  /// **'My microphone'**
  String get voiceMic;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean up what the other person hears'**
  String get voiceMicHint;

  /// Switch title: apply noise cancellation to incoming audio.
  ///
  /// In en, this message translates to:
  /// **'Other participants'**
  String get voiceOthers;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Clean up noisy callers you hear'**
  String get voiceOthersHint;

  /// Slider title; value is a level with percentage, e.g. High (80%).
  ///
  /// In en, this message translates to:
  /// **'Strength: {value}'**
  String voiceStrength(String value);

  /// Group title for testing voice isolation.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get voiceGroupTry;

  /// Footer under the Try it group.
  ///
  /// In en, this message translates to:
  /// **'Use headphones for the echo test, or you will hear feedback.'**
  String get voiceTryFooter;

  /// Switch title.
  ///
  /// In en, this message translates to:
  /// **'Test with echo'**
  String get voiceEchoTest;

  /// Switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Plays your processed microphone back to you'**
  String get voiceEchoTestHint;

  /// Error notice.
  ///
  /// In en, this message translates to:
  /// **'Echo test failed'**
  String get voiceEchoFailed;

  /// Group title for system microphone modes.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get voiceGroupSystem;

  /// Footer under the System group.
  ///
  /// In en, this message translates to:
  /// **'macOS and iOS can also isolate your voice for every app. Choose Voice Isolation in the system microphone mode.'**
  String get voiceSystemFooter;

  /// List item that opens the system microphone mode picker.
  ///
  /// In en, this message translates to:
  /// **'System microphone mode (Voice Isolation)…'**
  String get voiceSystemMode;

  /// Notice when the system microphone mode cannot be shown.
  ///
  /// In en, this message translates to:
  /// **'Microphone modes need macOS 12 or iOS 15 or later.'**
  String get voiceSystemModeUnsupported;

  /// Title and accessibility label of the speech level meter.
  ///
  /// In en, this message translates to:
  /// **'Speech detection'**
  String get voiceSpeechDetection;

  /// Accessibility value of the speech level meter.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String voiceSpeechPercent(int percent);

  /// Percentage shown next to the speech level meter.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String voicePercent(int percent);

  /// Group title.
  ///
  /// In en, this message translates to:
  /// **'Android audio effects'**
  String get voiceGroupAndroid;

  /// Footer under the Android audio effects group.
  ///
  /// In en, this message translates to:
  /// **'The phone may also clean up the microphone itself. These are reported by Android and are separate from the setting above.'**
  String get voiceAndroidFooter;

  /// List item title.
  ///
  /// In en, this message translates to:
  /// **'Noise suppressor'**
  String get voiceAndroidNs;

  /// List item title.
  ///
  /// In en, this message translates to:
  /// **'Echo canceller'**
  String get voiceAndroidAec;

  /// Subtitle when an Android audio effect is not available.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get voiceNotAvailableDevice;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'This link type can only be used from the command line of this computer.'**
  String get callLinkNotLocal;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Connect to device {name}?'**
  String linkLanConnectTitle(String name);

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'A link from another app or web page wants to connect SoftphonePro to this device. Connect only if you expect this.'**
  String get linkLanConnectBody;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get linkLanConnectAction;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Sensitive changes in this configuration:'**
  String get linkImportSensitiveHeader;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Answers incoming calls automatically'**
  String get linkImportFlagAutoAnswer;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Forwards calls to {target}'**
  String linkImportFlagForwarding(String target);

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Changes who may start an intercom or pull a call (LAN)'**
  String get linkImportFlagIntercom;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Rewrites the numbers you dial'**
  String get linkImportFlagDialRewrite;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Calls from web links start immediately, without confirmation'**
  String get linkImportFlagLinksImmediately;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Turns on detailed logging or SIP tracing'**
  String get linkImportFlagDiagnostics;

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Allow auto-answer for the imported account(s)'**
  String get linkImportAllowAutoAnswer;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'This import tries to change \"{setting}\", which can never be set by a link, QR code, pasted text or file. Use the --provision command-line option on this computer instead. Nothing was imported.'**
  String linkImportRefused(String setting);

  /// Security hardening (final review).
  ///
  /// In en, this message translates to:
  /// **'Paired devices can ask to start an intercom call; you will be asked before each one (change this in Settings > LAN).'**
  String get lanPairIntercomNote;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'This kind of link is not supported.'**
  String get callLinkUnsupportedScheme;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Records calls automatically'**
  String get linkImportFlagAutoRecord;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Changes your call blocklist'**
  String get linkImportFlagBlocklist;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Changes your emergency numbers'**
  String get linkImportFlagEmergency;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Sets speed-dial numbers'**
  String get linkImportFlagSpeedDial;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Automatically deletes old recordings'**
  String get linkImportFlagRecordingDelete;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Dials custom PBX feature codes'**
  String get linkImportFlagFeatureCodes;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Allow automatic call recording'**
  String get linkImportAllowAutoRecord;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Ignored (not allowed from imports):'**
  String get importIgnoredHeader;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'{name} ({address}) - server {server}, {transport}'**
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  );

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Proxies: {proxies}'**
  String importAccountProxies(String proxies);

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'TURN relay: {server}'**
  String importAccountTurn(String server);

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Custom SIP headers: {headers}'**
  String importAccountHeaders(String headers);

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Caller ID: {callerId}'**
  String importAccountCallerId(String callerId);

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'No media encryption (SRTP off)'**
  String get importAccountSrtpOff;

  /// Security hardening: untrusted provisioning imports.
  ///
  /// In en, this message translates to:
  /// **'Address: {host}:{port}'**
  String linkLanConnectAddress(String host, String port);

  /// Import confirmation: how many imported accounts update existing ones and how many are new.
  ///
  /// In en, this message translates to:
  /// **'Update {updated} existing, add {added} new'**
  String provisioningUpdateSummary(int updated, int added);

  /// Notice at start-up (Linux): the secret keyring was locked and could not be unlocked, so saved account passwords could not be read this session.
  ///
  /// In en, this message translates to:
  /// **'Your keyring is locked, so saved passwords couldn\'\'t be read. Unlock it and restart SoftphonePro.'**
  String get secretsKeyringLocked;

  /// Title of the audio mixer (microphone, speaker and musicbed meters and sliders).
  ///
  /// In en, this message translates to:
  /// **'Audio mixer'**
  String get mixerTitle;

  /// Mixer row label: the microphone (audio input).
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get mixerMicrophone;

  /// Mixer row label: headphones or speaker (audio output).
  ///
  /// In en, this message translates to:
  /// **'Headphones & speaker'**
  String get mixerSpeaker;

  /// Accessibility label of the microphone gain slider.
  ///
  /// In en, this message translates to:
  /// **'Microphone volume'**
  String get mixerMicVolume;

  /// Accessibility label of the speaker volume slider.
  ///
  /// In en, this message translates to:
  /// **'Speaker volume'**
  String get mixerSpeakerVolume;

  /// Accessibility label of a level meter, e.g. "Microphone level".
  ///
  /// In en, this message translates to:
  /// **'{name} level'**
  String mixerMeterLabel(String name);

  /// Mixer: label of the input (microphone) device picker.
  ///
  /// In en, this message translates to:
  /// **'Input device'**
  String get mixerInputDevice;

  /// Mixer: label of the output (speaker) device picker.
  ///
  /// In en, this message translates to:
  /// **'Output device'**
  String get mixerOutputDevice;

  /// Mobile mixer: label of the audio output route selector (phone, speaker, Bluetooth, headset).
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get mixerOutputRoute;

  /// Mobile mixer: hint under the microphone row; the phone picks the microphone from the audio output.
  ///
  /// In en, this message translates to:
  /// **'The microphone follows the selected audio output.'**
  String get mixerInputFollowsOutput;

  /// Mixer: expand control that reveals device pickers and musicbed options.
  ///
  /// In en, this message translates to:
  /// **'Show devices and musicbed'**
  String get mixerShowMore;

  /// Mixer: collapse control that hides device pickers and musicbed options.
  ///
  /// In en, this message translates to:
  /// **'Show fewer controls'**
  String get mixerShowLess;

  /// Tooltip of the collapsed mixer strip on the keypad and call screens.
  ///
  /// In en, this message translates to:
  /// **'Show audio mixer'**
  String get mixerStripShow;

  /// Tooltip of the expanded mixer strip on the keypad and call screens.
  ///
  /// In en, this message translates to:
  /// **'Hide audio mixer'**
  String get mixerStripHide;

  /// Name of the musicbed feature: a music file that loops under the user's voice for the people on the call.
  ///
  /// In en, this message translates to:
  /// **'Musicbed'**
  String get musicbedTitle;

  /// Switch: play the musicbed into calls.
  ///
  /// In en, this message translates to:
  /// **'Play musicbed'**
  String get musicbedPlay;

  /// Accessibility label of the musicbed volume slider.
  ///
  /// In en, this message translates to:
  /// **'Musicbed volume'**
  String get musicbedVolume;

  /// Musicbed file chip when no file is chosen yet.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get musicbedChooseFile;

  /// Accessibility label of the musicbed file chip; tapping changes the file.
  ///
  /// In en, this message translates to:
  /// **'Musicbed file: {name}. Tap to change.'**
  String musicbedChangeFile(String name);

  /// Switch: also play the musicbed to the user locally.
  ///
  /// In en, this message translates to:
  /// **'Hear it myself'**
  String get musicbedHearIt;

  /// Accessibility label of the slider for how loud the user hears the musicbed.
  ///
  /// In en, this message translates to:
  /// **'Monitor volume'**
  String get musicbedMonitorVolume;

  /// Musicbed file sheet: import a new audio file from the device.
  ///
  /// In en, this message translates to:
  /// **'Add a file…'**
  String get musicbedAddFile;

  /// Title of the sheet that lists the audio library for the musicbed.
  ///
  /// In en, this message translates to:
  /// **'Musicbed file'**
  String get musicbedPickerTitle;

  /// Small in-call indicator that the musicbed is playing.
  ///
  /// In en, this message translates to:
  /// **'Musicbed on'**
  String get musicbedOn;

  /// Tooltip of the in-call musicbed indicator.
  ///
  /// In en, this message translates to:
  /// **'A music file is playing to everyone on your calls.'**
  String get musicbedOnTooltip;

  /// Notice: the musicbed audio file no longer exists, so the feature was switched off.
  ///
  /// In en, this message translates to:
  /// **'The musicbed file is no longer available, so musicbed was turned off.'**
  String get musicbedFileMissing;

  /// Notice: the user turned the musicbed on without choosing a file.
  ///
  /// In en, this message translates to:
  /// **'Choose a musicbed file first.'**
  String get musicbedNeedsFile;

  /// Notice: the engine stopped the musicbed because of an error.
  ///
  /// In en, this message translates to:
  /// **'Musicbed stopped: {message}'**
  String musicbedStopped(String message);

  /// Footer of the Musicbed settings group.
  ///
  /// In en, this message translates to:
  /// **'Loops a music file under your voice for everyone on your calls, even while you are muted. Calls on hold hear the hold music instead.'**
  String get musicbedSettingsFooter;

  /// Settings > Audio > Musicbed: the music file selector.
  ///
  /// In en, this message translates to:
  /// **'Music file'**
  String get musicbedSettingsFile;

  /// Import confirmation: the profile switches music into every call.
  ///
  /// In en, this message translates to:
  /// **'Plays music into your calls'**
  String get linkImportFlagMusicbed;

  /// Hint under the hear-it-myself toggle on iOS, where there is no audio device without a call.
  ///
  /// In en, this message translates to:
  /// **'On iPhone you hear it during calls'**
  String get musicbedMonitorIosHint;

  /// Error notice: switching the musicbed off failed and it may still be playing to the other party.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t stop the music. It may still be playing to your callers.'**
  String get musicbedStopFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'nl',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
