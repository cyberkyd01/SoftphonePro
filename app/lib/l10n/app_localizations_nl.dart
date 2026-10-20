// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get languageSystemDefault => 'Systeemstandaard';

  @override
  String get languagePickerHint =>
      'Taalnamen worden in hun eigen taal weergegeven.';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get actionDone => 'Gereed';

  @override
  String get actionAdd => 'Toevoegen';

  @override
  String get actionEdit => 'Bewerken';

  @override
  String get actionRename => 'Hernoemen';

  @override
  String get actionClear => 'Wissen';

  @override
  String get actionBack => 'Terug';

  @override
  String get actionCopy => 'Kopiëren';

  @override
  String get actionShare => 'Delen';

  @override
  String get actionImport => 'Importeren';

  @override
  String get actionExport => 'Exporteren';

  @override
  String get actionDetails => 'Details';

  @override
  String get actionMore => 'Meer';

  @override
  String get actionSettings => 'Instellingen';

  @override
  String get actionSearch => 'Zoeken';

  @override
  String get actionRefresh => 'Vernieuwen';

  @override
  String get actionContinue => 'Doorgaan';

  @override
  String get actionYes => 'Ja';

  @override
  String get actionNo => 'Nee';

  @override
  String get commonOn => 'Aan';

  @override
  String get commonOff => 'Uit';

  @override
  String get commonNone => 'Geen';

  @override
  String get commonDefault => 'Standaard';

  @override
  String get commonSystem => 'Systeem';

  @override
  String get commonAutomatic => 'Automatisch';

  @override
  String get commonUnknown => 'Onbekend';

  @override
  String get commonNotSet => 'Niet ingesteld';

  @override
  String get commonError => 'Fout';

  @override
  String get commonLoading => 'Laden…';

  @override
  String get statusAvailable => 'Beschikbaar';

  @override
  String get statusDoNotDisturb => 'Niet storen';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'In gesprek';

  @override
  String get settingsEntryAccounts => 'Accounts';

  @override
  String get settingsEntryAccountsSub => 'SIP-accounts en registratie';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub => 'Apparaten, niveaus, echoonderdrukking';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Volgorde, beschikbaarheid, Opus';

  @override
  String get settingsEntryCalls => 'Gesprekken';

  @override
  String get settingsEntryCallsSub =>
      'Niet storen, wachtstand, automatisch opnemen, kiesregels';

  @override
  String get settingsEntryNetwork => 'Netwerk';

  @override
  String get settingsEntryNetworkSub => 'Transporten, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Opnemen';

  @override
  String get settingsEntryNotifications => 'Meldingen en beltonen';

  @override
  String get settingsEntryShortcuts => 'Sneltoetsen';

  @override
  String get settingsEntryShortcutsSub =>
      'Globale sneltoetsen, toetsen in de app';

  @override
  String get settingsEntryAppearance => 'Weergave';

  @override
  String get settingsEntryPrivacy => 'Privacy en beveiliging';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisioning';

  @override
  String get settingsEntryProvisioningSub => 'Importeren, exporteren, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnose';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP-trace, netwerkcontroles';

  @override
  String get settingsEntryAdvanced => 'Geavanceerd';

  @override
  String get settingsEntryAbout => 'Info';

  @override
  String get settingsAccountsEmptyTitle => 'Voeg je eerste account toe';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Maak verbinding met je telefooncentrale of SIP-provider om te kunnen bellen.';

  @override
  String get settingsAccountsAdd => 'Account toevoegen';

  @override
  String get settingsAccountsYourAccounts => 'Jouw accounts';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  via back-upserver';
  }

  @override
  String get settingsAudioDevices => 'Apparaten';

  @override
  String get settingsAudioMicrophone => 'Microfoon';

  @override
  String get settingsAudioSpeaker => 'Luidspreker';

  @override
  String get settingsAudioRinger => 'Beltoonapparaat';

  @override
  String get settingsAudioRingerSub =>
      'Speel de beltoon af op een apart apparaat';

  @override
  String get settingsAudioRefreshDevices => 'Apparaten vernieuwen';

  @override
  String get settingsAudioLevelsAndTest => 'Niveaus en test';

  @override
  String get settingsAudioMicVolume => 'Microfoonvolume';

  @override
  String get settingsAudioMicLevel => 'Microfoonniveau';

  @override
  String get settingsAudioSpeakerVolume => 'Luidsprekervolume';

  @override
  String get settingsAudioSpeakerLevel => 'Luidsprekerniveau';

  @override
  String get settingsAudioTestSpeaker => 'Luidspreker testen';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Speelt een korte toon af via de geselecteerde luidspreker';

  @override
  String get settingsAudioTestToneFailed =>
      'Testtoon kon niet worden afgespeeld';

  @override
  String get settingsAudioEchoTestFailed => 'Echotest mislukt';

  @override
  String get settingsAudioEchoTest => 'Echotest';

  @override
  String get settingsAudioEchoTestSub =>
      'Speelt je microfoon terug via de luidspreker. Gebruik een koptelefoon om rondzingen te voorkomen.';

  @override
  String get settingsAudioVoiceAndFiles => 'Stem en bestanden';

  @override
  String get settingsAudioVoiceIsolation =>
      'Stemisolatie (AI-ruisonderdrukking)';

  @override
  String get settingsAudioAudioFiles => 'Audiobestanden';

  @override
  String get settingsAudioAudioFilesSub => 'Wachtmuziek en aankondigingen';

  @override
  String get settingsAudioProcessing => 'Verwerking';

  @override
  String get settingsAudioEchoCancellation => 'Echoonderdrukking';

  @override
  String get settingsAudioEcSimple => 'Eenvoudig';

  @override
  String get settingsAudioEcPlatform => 'Platform';

  @override
  String get settingsAudioEchoTail => 'Echostaart';

  @override
  String get settingsAudioNoiseSuppression => 'Ruisonderdrukking';

  @override
  String get settingsAudioAgc => 'Automatische versterkingsregeling';

  @override
  String get settingsAudioVad => 'Spraakactiviteitsdetectie';

  @override
  String get settingsAudioVadSub => 'Bespaart bandbreedte tijdens stiltes';

  @override
  String get settingsAudioAdvanced => 'Geavanceerd';

  @override
  String get settingsAudioAdvancedFooter =>
      'Jitterbufferwaarden zijn in milliseconden; -1 gebruikt de standaardwaarde van de engine. Als je deze wijzigt, wordt de gespreksengine opnieuw gestart.';

  @override
  String get settingsAudioPtime => 'Pakkettijd (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitterbuffer: initieel';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitterbuffer: minimale prefetch';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitterbuffer: maximale prefetch';

  @override
  String get settingsAudioJbMaxSize => 'Jitterbuffer: maximale grootte';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microfoon $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Anderen $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent procent';
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
      other: '$count seconden',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Volgorde en beschikbaarheid';

  @override
  String get settingsCodecsDragHint =>
      'Sleep om de volgorde te wijzigen. Accounts kunnen deze lijst overschrijven in hun eigen instellingen.';

  @override
  String get settingsCodecsBitrate => 'Bitrate';

  @override
  String get settingsCodecsFec => 'In-band FEC';

  @override
  String get settingsCodecsFecSub => 'Herstelt na pakketverlies';

  @override
  String get settingsCodecsDtxSub => 'Niet verzenden tijdens stiltes';

  @override
  String get settingsCodecsCbr => 'Constante bitrate';

  @override
  String get settingsCodecsComplexity => 'Complexiteit';

  @override
  String get settingsCallsIncoming => 'Inkomend';

  @override
  String get settingsCallsDndSub => 'Alle inkomende gesprekken weigeren';

  @override
  String get settingsCallsRejectWith => 'Weigeren met';

  @override
  String get settingsCallsReasonBusy => 'Bezet (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Tijdelijk niet beschikbaar (480)';

  @override
  String get settingsCallsReasonDecline => 'Geweigerd (603)';

  @override
  String get settingsCallsWaiting => 'Wachtstand';

  @override
  String get settingsCallsWaitingSub =>
      'Een tweede inkomend gesprek toestaan tijdens een gesprek';

  @override
  String get settingsCallsWhenBusy => 'Bij bezet en wachtstand uit';

  @override
  String get settingsCallsRejectAnonymous => 'Anonieme gesprekken weigeren';

  @override
  String get settingsCallsLinksImmediately => 'Links direct bellen';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Links met tel:, sip: en callto: starten het gesprek zonder te wachten in het toetsenbord';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'DND/doorschakelen met telefooncentrale synchroniseren via servicecodes';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Kiest kort de sterretjescodes van het account (bijvoorbeeld *78) wanneer je Niet storen of doorschakelen wijzigt';

  @override
  String get settingsCallsAutoAnswerGroup => 'Automatisch opnemen';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Doorschakelen en automatisch opnemen per account stel je in bij elk account.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Alle gesprekken automatisch opnemen';

  @override
  String get settingsCallsAnswerAfter => 'Opnemen na';

  @override
  String get settingsCallsAnswerImmediately => 'Direct';

  @override
  String get settingsCallsIntercomHeaders => 'Intercomheaders respecteren';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Aanwijzingen voor automatisch opnemen via Call-Info, Alert-Info en Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Geblokkeerde nummers';

  @override
  String get settingsCallsBlockNumber => 'Een nummer blokkeren';

  @override
  String get settingsCallsBlockNumberTitle => 'Nummer blokkeren';

  @override
  String get settingsCallsBlockNumberHint => 'Nummer of SIP-adres';

  @override
  String get settingsCallsSpeedDial => 'Snelkiezen';

  @override
  String get settingsCallsDialPlan => 'Kiesplan';

  @override
  String get settingsCallsDialRules => 'Kiesregels';

  @override
  String get settingsCallsStripPrefix =>
      'Voorvoegsel voor buitenlijn om te verwijderen';

  @override
  String get settingsCallsStripPrefixSub =>
      'Bijvoorbeeld 9, wordt verwijderd aan het begin van gekozen nummers';

  @override
  String get settingsCallsPlusReplacement => 'Voorafgaande + vervangen door';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Bijvoorbeeld 00 voor internationaal bellen';

  @override
  String get settingsCallsPlusReplacementHint => '+ behouden';

  @override
  String get settingsCallsCountryPrefix => 'Standaard landnummer';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Nationale nummers die met 0 beginnen krijgen dit voorvoegsel, bijvoorbeeld +31';

  @override
  String get settingsCallsEmergency => 'Alarmnummers';

  @override
  String get settingsCallsEmergencySub =>
      'Gescheiden door komma\'s. Deze omzeilen de kiesregels.';

  @override
  String settingsCallsUnblock(String number) {
    return '$number deblokkeren';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count van 9 toegewezen';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regels',
      one: '1 regel',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nieuwe kiesregel';

  @override
  String get settingsDialRulesEdit => 'Kiesregel bewerken';

  @override
  String get settingsDialRulesName => 'Naam';

  @override
  String get settingsDialRulesPattern => 'Patroon (regex)';

  @override
  String get settingsDialRulesReplacement => 'Vervanging';

  @override
  String get settingsDialRulesReplacementHelp =>
      'Gebruik \$1, \$2 voor groepen';

  @override
  String get settingsDialRulesRoute => 'Routeren via account';

  @override
  String get settingsDialRulesAdd => 'Regel toevoegen';

  @override
  String get settingsDialRulesLiveTest => 'Livetest';

  @override
  String get settingsDialRulesTyped => 'Ingevoerd nummer';

  @override
  String get settingsDialRulesNothing => '(niets)';

  @override
  String get settingsDialRulesEmergency =>
      'Alarmnummer: gekozen zoals ingevoerd';

  @override
  String get settingsDialRulesAccountFallback => 'account';

  @override
  String get settingsDialRulesEmpty =>
      'Geen regels. Nummers worden opgeschoond (spaties, streepjes en haakjes verwijderd) en gekozen zoals ingevoerd. Regels worden van boven naar beneden uitgevoerd; de eerste overeenkomst wint.';

  @override
  String get settingsDialRulesDelete => 'Regel verwijderen';

  @override
  String get settingsDialRulesDeleteTitle => 'Regel verwijderen?';

  @override
  String settingsDialRulesVia(String account) {
    return 'via $account';
  }

  @override
  String get settingsNetworkTransports => 'Transporten';

  @override
  String get settingsNetworkTransportsFooter =>
      'Poort 0 kiest een willekeurige vrije poort. Als je transporten wijzigt, wordt de gespreksengine opnieuw gestart.';

  @override
  String get settingsNetworkUdpPort => 'UDP-poort';

  @override
  String get settingsNetworkTcpPort => 'TCP-poort';

  @override
  String get settingsNetworkTlsPort => 'TLS-poort';

  @override
  String get settingsNetworkVerifyCerts => 'Servercertificaten verifiëren';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Zet dit alleen uit voor telefooncentrales met zelfondertekende certificaten, of pin het certificaat hieronder';

  @override
  String get settingsNetworkCustomCa => 'Eigen CA-bestand';

  @override
  String get settingsNetworkCustomCaSub =>
      'PEM-bundel die wordt gebruikt in plaats van de ingebouwde lijst (CA van een privécentrale)';

  @override
  String get settingsNetworkCustomCaHint => 'Ingebouwde Mozilla-lijst';

  @override
  String get settingsNetworkPins => 'Vastgezette certificaten';

  @override
  String get settingsNetworkPinsSub =>
      'host=SHA256-vingerafdruk, gescheiden door komma\'s';

  @override
  String get settingsNetworkNat => 'NAT traversal';

  @override
  String get settingsNetworkStun => 'STUN-servers';

  @override
  String get settingsNetworkStunSub => 'host:poort, gescheiden door komma\'s';

  @override
  String get settingsNetworkIceTurn => 'ICE en TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Per account ingesteld onder NAT';

  @override
  String get settingsNetworkAdvanced => 'Geavanceerd';

  @override
  String get settingsNetworkQos => 'QoS (DSCP-markering)';

  @override
  String get settingsNetworkQosSub =>
      'SIP- en spraakpakketten markeren voor prioriteit';

  @override
  String get settingsNetworkDns => 'DNS-servers';

  @override
  String get settingsNetworkDnsSub => 'Leeg laten voor automatisch';

  @override
  String get settingsNetworkRtpStart => 'Begin RTP-poortbereik';

  @override
  String get settingsNetworkRtpRange => 'RTP-poortbereik';

  @override
  String get settingsNetworkRtpRangeSub => '0 gebruikt de standaardwaarde';

  @override
  String get settingsNotifRingtone => 'Beltoon';

  @override
  String get settingsNotifDefaultRingtone => 'Standaardbeltoon';

  @override
  String get settingsNotifProgressTones => 'Voortgangstonen';

  @override
  String get settingsNotifProgressTonesSub =>
      'Wachttoon, bezettoon en congestietoon tijdens het kiezen';

  @override
  String get settingsNotifRingerVolume => 'Beltoonvolume';

  @override
  String get settingsNotifCustomRingtone => 'Eigen beltoonbestand';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Pad naar een WAV-bestand (desktop)';

  @override
  String get settingsNotifGroup => 'Meldingen';

  @override
  String get settingsNotifRequestPermissions => 'Toestemmingen aanvragen';

  @override
  String get settingsNotifRequestPermissionsSub => 'Microfoon en meldingen';

  @override
  String get settingsNotifTyping => 'Typindicatoren verzenden';

  @override
  String get settingsAppearanceTheme => 'Thema';

  @override
  String get settingsAppearanceLight => 'Licht';

  @override
  String get settingsAppearanceDark => 'Donker';

  @override
  String get settingsAppearanceAccent => 'Accentkleur';

  @override
  String get settingsAppearanceAccentOption => 'Accentkleuroptie';

  @override
  String get settingsAppearanceCompact => 'Compacte weergave';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microfoon: $microphone, meldingen: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Beveiliging';

  @override
  String get settingsPrivacyPasswords => 'Wachtwoorden';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Opgeslagen in de systeemsleutelhanger/keystore (versleuteld bestand als terugval)';

  @override
  String get settingsPrivacyGroup => 'Privacy';

  @override
  String get settingsPrivacyNoTelemetry => 'Geen telemetrie';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro verstuurt geen analysegegevens. Netwerkverkeer gaat alleen naar je SIP-servers.';

  @override
  String get settingsPrivacyYourData => 'Jouw gegevens';

  @override
  String get settingsPrivacyClearHistory => 'Gespreksgeschiedenis wissen';

  @override
  String get settingsPrivacyDeleteContacts => 'Alle contacten verwijderen';

  @override
  String get settingsPrivacyDeleteMessages => 'Alle berichten verwijderen';

  @override
  String get settingsPrivacyConfirmHistory =>
      'Gespreksgeschiedenis verwijderen?';

  @override
  String get settingsPrivacyConfirmContacts => 'Alle contacten verwijderen?';

  @override
  String get settingsPrivacyConfirmMessages => 'Alle berichten verwijderen?';

  @override
  String get settingsPrivacyCannotUndo =>
      'Dit kan niet ongedaan worden gemaakt.';

  @override
  String get settingsPrivacyDeletedHistory => 'Gespreksgeschiedenis verwijderd';

  @override
  String get settingsPrivacyDeletedContacts => 'Alle contacten verwijderd';

  @override
  String get settingsPrivacyDeletedMessages => 'Alle berichten verwijderd';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Apparaten op hetzelfde netwerk vinden elkaar, koppelen met een code van 6 cijfers en praten rechtstreeks, zonder server.';

  @override
  String get settingsLanEnable => 'LAN Link inschakelen';

  @override
  String get settingsLanDeviceName => 'Apparaatnaam';

  @override
  String get settingsLanDeviceNameHint => 'Dit apparaat';

  @override
  String get settingsLanAllowIntercom => 'Intercom toestaan';

  @override
  String get settingsLanAllowIntercomSub =>
      'Laat gekoppelde apparaten je bellen en automatisch opnemen';

  @override
  String get settingsLanAskIntercom =>
      'Vragen voordat intercom wordt toegestaan';

  @override
  String get settingsLanAskIntercomSub =>
      'Anders wordt er na hun verzoek 30 s lang automatisch opgenomen voor gekoppelde apparaten';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Bestanden van gekoppelde apparaten automatisch accepteren';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Anders word je bij elk bestand om bevestiging gevraagd';

  @override
  String get settingsLanAllowPull =>
      'Gekoppelde apparaten mijn gesprekken laten overnemen';

  @override
  String get settingsLanAllowPullSub =>
      'Een gekoppeld apparaat kan een gesprek overnemen dat hier actief is';

  @override
  String get settingsLanDownloads => 'Downloadmap';

  @override
  String get settingsLanDownloadsHint => 'Standaard (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'Linkpoort';

  @override
  String get settingsLanSharedAccounts =>
      'Accounts gedeeld met gekoppelde apparaten';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Als je een geregistreerd account deelt, kan een gekoppeld apparaat op dezelfde server je gesprekken rechtstreeks ontvangen (doorverbinden) in plaats van ze door te sturen.';

  @override
  String get settingsAdvEngine => 'Engine';

  @override
  String get settingsAdvSimulator => 'Simulator gebruiken';

  @override
  String get settingsAdvSimulatorSub =>
      'Draai zonder de native engine. Gesprekken worden gesimuleerd.';

  @override
  String get settingsAdvLogLevel => 'Logniveau';

  @override
  String get settingsAdvLogErrors => 'Fouten';

  @override
  String get settingsAdvLogInfo => 'Info';

  @override
  String get settingsAdvLogDebug => 'Debug';

  @override
  String get settingsAdvLogVerbose => 'Uitgebreid';

  @override
  String get settingsAdvSipTrace => 'SIP-trace';

  @override
  String get settingsAdvRestartEngine => 'Engine opnieuw starten';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Starten bij inloggen';

  @override
  String get settingsAdvCloseToTray => 'Sluiten naar systeemvak';

  @override
  String get settingsAdvCloseToTraySub =>
      'Als je het venster sluit, blijft SoftphonePro actief zodat gesprekken nog kunnen overgaan. Afsluiten doe je via het pictogram in het systeemvak/de menubalk.';

  @override
  String get settingsAboutLicence => 'Licentie';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro is vrije software: je mag het herdistribueren en/of wijzigen onder de voorwaarden van de GNU General Public License zoals gepubliceerd door de Free Software Foundation, versie 3 of later. Het wordt verspreid ZONDER ENIGE GARANTIE.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 of later';

  @override
  String get settingsAboutGplSub =>
      'Broncode beschikbaar in de projectrepository';

  @override
  String get settingsAboutThirdParty => 'Vermeldingen van derden';

  @override
  String get settingsAboutPackages => 'Flutter- en Dart-pakketten';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT en Apache 2.0. Zie de licentiepagina.';

  @override
  String settingsAboutVersion(String version) {
    return 'Versie $version';
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
    return '$license. $purpose. Versie $version.';
  }

  @override
  String get updatesChecking => 'Controleren...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version is beschikbaar';
  }

  @override
  String get updatesUpToDate => 'Je bent up-to-date';

  @override
  String get updatesCouldNotCheck => 'Controle mislukt';

  @override
  String get updatesNotCheckedYet => 'Nog niet gecontroleerd';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Laatst gecontroleerd $dateString';
  }

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesFooter =>
      'Bij de controle wordt alleen api.github.com benaderd (eenmaal per week) en wordt niets anders verzonden dan het verzoek zelf: geen identificatiegegevens, geen account- of gespreksgegevens. SoftphonePro downloadt of installeert nooit zelf iets.';

  @override
  String get updatesCheckSwitch => 'Op updates controleren';

  @override
  String get updatesCheckNow => 'Nu controleren';

  @override
  String updatesSkippingVersion(String version) {
    return 'Versie $version wordt overgeslagen';
  }

  @override
  String get updatesStopSkipping => 'Niet meer overslaan';

  @override
  String get updatesReleaseNotes => 'Release-opmerkingen';

  @override
  String get updatesDownload => 'Downloaden';

  @override
  String get updatesSkipVersion => 'Deze versie overslaan';

  @override
  String get updatesDismiss => 'Negeren';

  @override
  String get updatesRateLimited =>
      'Aanvraaglimiet van GitHub bereikt, probeer het later opnieuw';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub antwoordde $status';
  }

  @override
  String get updatesUnexpectedReply => 'Onverwacht antwoord';

  @override
  String get updatesTimedOut => 'Time-out';

  @override
  String get updatesAlreadyChecking => 'Controle is al bezig';

  @override
  String get encryptionTitle => 'Versleuteling';

  @override
  String get encryptionFooter =>
      'Versleutelt de lokale database met AES-256-GCM. De sleutel wordt bewaard in de systeemsleutelhanger/keystore; als die verloren gaat, kunnen de gegevens niet worden hersteld. Gespreksopnamen en geëxporteerde bestanden worden niet versleuteld. De wijziging gaat in bij de volgende start van SoftphonePro (sluit de app eerst volledig af); het vorige bestand wordt overschreven en verwijderd zodra de nieuwe database is geopend en gecontroleerd.';

  @override
  String get encryptionSwitchTitle =>
      'Gespreksgeschiedenis, contacten en berichten op dit apparaat versleutelen';

  @override
  String get encryptionWillEncrypt => 'Wordt bij de volgende start versleuteld';

  @override
  String get encryptionWillDecrypt => 'Wordt bij de volgende start ontsleuteld';

  @override
  String get encryptionRestartToEncrypt =>
      'Sluit SoftphonePro af en start het opnieuw om je gegevens te versleutelen.';

  @override
  String get encryptionRestartToDecrypt =>
      'Sluit SoftphonePro af en start het opnieuw om je gegevens te ontsleutelen.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Snelkiezen $slot';
  }

  @override
  String get speedDialNumberLabel => 'Nummer of SIP-adres';

  @override
  String get speedDialLabelOptional => 'Label (optioneel)';

  @override
  String get speedDialCallFrom => 'Bellen vanaf';

  @override
  String get speedDialSelectedAccount => 'Geselecteerd account';

  @override
  String get speedDialTitle => 'Snelkiezen';

  @override
  String get speedDialHint =>
      'Houd een cijfer (1-9) ingedrukt op het lege toetsenbord om het nummer te bellen.';

  @override
  String get speedDialNotAssigned => 'Niet toegewezen';

  @override
  String provisioningNotValidJson(String detail) {
    return 'Geen geldige JSON: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Een JSON-object werd verwacht';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Niet-ondersteunde configuratieversie $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Een accountvermelding zonder object is overgeslagen';

  @override
  String get provisioningNothingToImport =>
      'Het bestand bevat geen accounts of instellingen';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'Account \"$name\" heeft een gebruikersnaam en domein nodig';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Server antwoordde $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Configuratie kon niet worden gedownload: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '$path kon niet worden gelezen';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts geïmporteerd',
      one: '1 account geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Configuratie importeren';

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
      other: '$settings instellingen',
      one: '1 instelling',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Importeren via URL of JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... of plak JSON';

  @override
  String get provisioningInvalidSource =>
      'Dit is geen geldige URL, link of JSON';

  @override
  String get provisioningScanTitle => 'Provisioning-QR scannen';

  @override
  String get provisioningPasteHint => 'Plak JSON, een link of een URL';

  @override
  String get provisioningImportGroup => 'Importeren';

  @override
  String get provisioningImportFooter =>
      'Ondersteunt JSON met accounts en instellingen. Plaatshouders \${VAR} worden met lege waarden gevuld, tenzij een standaardwaarde is opgegeven als \${VAR:-standaard}.';

  @override
  String get provisioningScanQr => 'QR-code scannen';

  @override
  String get provisioningFromUrl => 'Via URL of geplakte JSON';

  @override
  String get provisioningFromFile => 'Uit bestand';

  @override
  String get provisioningFromClipboard => 'Van klembord';

  @override
  String get provisioningExportGroup => 'Exporteren';

  @override
  String get provisioningIncludePasswords => 'Wachtwoorden opnemen';

  @override
  String get provisioningIncludePasswordsHint =>
      'Iedereen met het bestand kan je accounts gebruiken';

  @override
  String get provisioningCopyConfig => 'Configuratie kopiëren (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuratie gekopieerd';

  @override
  String get provisioningQrGroup => 'QR-code';

  @override
  String get provisioningQrFooter =>
      'Scan deze code op een ander apparaat om een account te kopiëren. Behandel de code als een wachtwoord als er een in zit.';

  @override
  String get provisioningQrAccount => 'Account';

  @override
  String get provisioningChoose => 'Kiezen...';

  @override
  String get provisioningQrTooMuchData => 'Te veel gegevens voor een QR-code';

  @override
  String tlsClearField(String field) {
    return '$field wissen';
  }

  @override
  String get tlsChoose => 'Kiezen...';

  @override
  String get tlsChange => 'Wijzigen...';

  @override
  String get tlsClientCertTitle => 'Clientcertificaat (wederzijdse TLS)';

  @override
  String get tlsIncomplete =>
      'Kies zowel een certificaat als de bijbehorende privésleutel. Het certificaat wordt pas aangeboden als beide zijn ingesteld.';

  @override
  String get tlsFooter =>
      'Voor servers die vragen dat de app zich met een certificaat identificeert. PEM-bestanden. Wordt gebruikt voor TLS en beveiligde WebSocket.';

  @override
  String get tlsCertFile => 'Certificaatbestand';

  @override
  String get tlsKeyFile => 'Privésleutelbestand';

  @override
  String get tlsKeyPassword => 'Sleutelwachtwoord';

  @override
  String get tlsKeyPasswordHint => 'Alleen als de sleutel versleuteld is';

  @override
  String get callSettingsHoldGroupTitle => 'In de wacht';

  @override
  String get callSettingsHoldFooter =>
      'Bij \"Standaard van centrale\" wordt het gesprek gewoon in de wacht gezet en kan je telefooncentrale eigen muziek afspelen. Elke andere keuze wordt door deze app aan de beller afgespeeld.';

  @override
  String get callSettingsHoldMusic => 'Wachtmuziek';

  @override
  String get callSettingsHoldPbxDefault => 'Standaard van centrale';

  @override
  String get callSettingsHoldMusicVolume => 'Volume wachtmuziek';

  @override
  String get callSettingsHoldAudioFiles => 'Audiobestanden';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Wachtmuziek importeren of opnemen';

  @override
  String get callSettingsAnnounceTitle => 'Aankondigingen';

  @override
  String get callSettingsAnnounceFooter =>
      'Aankondigingen worden aan de andere partij afgespeeld. Alles wordt stilzwijgend overgeslagen als het bestand ontbreekt.';

  @override
  String get callSettingsAnnounceOpening => 'Openingsaankondiging';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Een bericht afspelen wanneer een gesprek tot stand komt';

  @override
  String get callSettingsAnnounceFile => 'Aankondigingsbestand';

  @override
  String get callSettingsAnnounceChooseFile => 'Kies een bestand';

  @override
  String get callSettingsAnnouncePlayFor => 'Afspelen voor';

  @override
  String get callSettingsAnnounceBoth => 'Inkomend en uitgaand';

  @override
  String get callSettingsAnnounceIncoming => 'Inkomende gesprekken';

  @override
  String get callSettingsAnnounceOutgoing => 'Uitgaande gesprekken';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Mijn microfoon dempen tijdens het afspelen';

  @override
  String get callSettingsAnnounceMonitor => 'Laat het mij ook horen';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Afspelen voordat de opname begint';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Afspelen voordat een beller wordt doorverbonden';

  @override
  String get morePageTitle => 'Meer';

  @override
  String get morePresence => 'Aanwezigheid';

  @override
  String get morePresenceHint => 'Busy lamp field';

  @override
  String get moreRetrieveParked => 'Geparkeerd gesprek ophalen';

  @override
  String get moreRetrieveParkedHint => 'Een parkeerplek kiezen';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Apparaten in de buurt, chat en bestandsdeling';

  @override
  String get moreRecordings => 'Opnamen';

  @override
  String get moreRecordingsHint =>
      'Gespreksopnamen beluisteren, delen en beheren';

  @override
  String get moreVoicemail => 'Voicemail';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe berichten',
      one: '1 nieuw bericht',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Bel je voicemail';

  @override
  String get moreDiagnostics => 'Diagnose';

  @override
  String get moreDiagnosticsHint => 'SIP-trace en netwerkcontroles';

  @override
  String get moreAbout => 'Info';

  @override
  String get moreNoVoicemailNumber =>
      'Er is geen voicemailnummer ingesteld. Voeg er een toe in de accountinstellingen.';

  @override
  String get moreSearchHint =>
      'Zoek contacten of geschiedenis, of typ een nummer';

  @override
  String moreCallNumber(String number) {
    return '$number bellen';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'App-vergrendeling';

  @override
  String get appLockFooter =>
      'Gesprekken gaan nog steeds over en kunnen worden beantwoord terwijl de app is vergrendeld.';

  @override
  String get appLockRequirePin => 'Pincode vereisen om de app te openen';

  @override
  String get appLockOnHint =>
      'Geschiedenis, contacten, berichten en instellingen zijn vergrendeld';

  @override
  String get appLockIsOn => 'App-vergrendeling staat aan';

  @override
  String get appLockIsOff => 'App-vergrendeling staat uit';

  @override
  String get appLockTurnOff => 'App-vergrendeling uitschakelen';

  @override
  String get appLockChangePin => 'Pincode wijzigen';

  @override
  String get appLockEnterCurrent => 'Voer je huidige pincode in';

  @override
  String get appLockPinChanged => 'Pincode gewijzigd';

  @override
  String get appLockLockAfter => 'Vergrendelen na';

  @override
  String get appLockLockAfterHint =>
      'Tijd op de achtergrond voordat de pincode weer nodig is';

  @override
  String get appLockImmediately => 'Direct';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten',
      one: '1 minuut',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 uur';

  @override
  String get appLockBiometrics => 'Ontgrendelen met biometrie';

  @override
  String get appLockNow => 'Nu vergrendelen';

  @override
  String get appLockSetPin => 'Stel een pincode in';

  @override
  String get appLockPinDigits => 'Pincode (4-8 cijfers)';

  @override
  String get appLockRepeatPin => 'Pincode herhalen';

  @override
  String get appLockUseDigits => 'Gebruik 4 tot 8 cijfers';

  @override
  String get appLockMismatch => 'Pincodes komen niet overeen';

  @override
  String get appLockPin => 'Pincode';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Te veel pogingen. Probeer het over $seconds s opnieuw';
  }

  @override
  String get appLockWrongPin => 'Onjuiste pincode';

  @override
  String get appLockTooMany => 'Te veel pogingen';

  @override
  String get appLockIsLocked => 'SoftphonePro is vergrendeld';

  @override
  String get appLockEnterPin => 'Voer je pincode in';

  @override
  String appLockTryAgainIn(String time) {
    return 'Probeer het over $time opnieuw';
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
  String get appLockUnlock => 'Ontgrendelen';

  @override
  String get appLockIncomingCall => 'Inkomend gesprek';

  @override
  String get appLockDecline => 'Weigeren';

  @override
  String get appLockAnswer => 'Opnemen';

  @override
  String get appLockHangUp => 'Ophangen';

  @override
  String get appLockBiometricReason => 'SoftphonePro ontgrendelen';

  @override
  String get automationNoToken =>
      'Geen toegangstoken ingesteld. Genereer er een via Instellingen > Geavanceerd.';

  @override
  String automationInvalidPort(int port) {
    return 'Ongeldige poort $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Starten mislukt: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'Poort $port is niet beschikbaar ($error). Kies een andere poort.';
  }

  @override
  String get automationTokenPlaceholder =>
      'Wordt aangemaakt wanneer je de API inschakelt';

  @override
  String automationListening(String address) {
    return 'Luistert op $address';
  }

  @override
  String get automationStarting => 'Starten...';

  @override
  String get automationTitle => 'Lokale automatiserings-API';

  @override
  String get automationFooter =>
      'Voor CRM- en helpdeskintegraties op deze computer. Luistert alleen op 127.0.0.1 en elk verzoek vereist het toegangstoken. Zie docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Lokale automatiserings-API inschakelen';

  @override
  String get automationPort => 'Poort';

  @override
  String get automationPortHint =>
      'Standaard 7771. Kies een vrije poort tussen 1024 en 65535.';

  @override
  String get automationPortInvalid => 'Voer een poort in van 1024 tot 65535';

  @override
  String get automationAccessToken => 'Toegangstoken';

  @override
  String get automationHideToken => 'Token verbergen';

  @override
  String get automationShowToken => 'Token tonen';

  @override
  String get automationCopyToken => 'Token kopiëren';

  @override
  String get automationTokenCopied => 'Token gekopieerd';

  @override
  String get automationGenerateToken => 'Nieuw token genereren';

  @override
  String get automationGenerateTitle => 'Nieuw token genereren?';

  @override
  String get automationGenerateBody =>
      'Programma\'s die het oude token gebruiken, werken niet meer totdat je ze het nieuwe token geeft.';

  @override
  String get automationGenerate => 'Genereren';

  @override
  String get automationOrigins => 'Toegestane browseroorsprongen';

  @override
  String get automationOriginsHint =>
      'Gescheiden door komma\'s, bijvoorbeeld https://crm.example.com. Programma\'s zonder browser (curl, scripts) hebben dit niet nodig.';

  @override
  String automationNotOrigin(String origin) {
    return 'Geen http(s)-oorsprong: $origin';
  }

  @override
  String get trayNotificationAnswer => 'Opnemen';

  @override
  String get trayNotificationDecline => 'Weigeren';

  @override
  String get trayTooltipInCall => 'SoftphonePro - in gesprek';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nieuw';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - geen accounts (Afwezig)',
      'dnd': 'SoftphonePro - geen accounts (Niet storen)',
      'other': 'SoftphonePro - geen accounts',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Afwezig)',
      'dnd': 'SoftphonePro - $online/$total online (Niet storen)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'SoftphonePro verbergen';

  @override
  String get trayShowApp => 'SoftphonePro tonen';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nieuw - Recente gesprekken openen';
  }

  @override
  String get trayStatus => 'Status';

  @override
  String get trayStatusAway => 'Afwezig';

  @override
  String get trayAccounts => 'Accounts';

  @override
  String get trayQuit => 'SoftphonePro afsluiten';

  @override
  String get hotkeyAnswerCall => 'Gesprek opnemen';

  @override
  String get hotkeyHangUp => 'Ophangen';

  @override
  String get hotkeyMute => 'Dempen / dempen opheffen';

  @override
  String get hotkeyFocusDialer => 'Toetsenbord activeren';

  @override
  String get shortcutsGlobalTitle => 'Globale sneltoetsen';

  @override
  String get shortcutsGlobalFooter =>
      'Werken vanuit elke toepassing. Een ander programma dat een combinatie al gebruikt, kan voorkomen dat deze wordt geregistreerd.';

  @override
  String get shortcutsChange => 'Wijzigen';

  @override
  String get shortcutsRestoreDefaults => 'Standaardwaarden herstellen';

  @override
  String get shortcutsMediaTitle => 'Headset- en mediatoetsen';

  @override
  String get shortcutsMediaFooter =>
      'De afspeel-/pauzeknop van een headset of toetsenbord wordt alleen geclaimd terwijl een gesprek overgaat of actief is, zodat muziekspelers de knop de rest van de tijd behouden.';

  @override
  String get shortcutsMediaSwitch =>
      'Opnemen en ophangen met de afspeel-/pauzeknop van headset of media';

  @override
  String get shortcutsMediaDuringCall => 'Tijdens een gesprek de knop';

  @override
  String get shortcutsMediaHangsUp => 'Hangt op';

  @override
  String get shortcutsMediaMutes => 'Dempt / heft demping op';

  @override
  String get shortcutsInApp => 'In de app';

  @override
  String get shortcutsFocusDialer => 'Toetsenbord activeren';

  @override
  String get shortcutsHoldResume => 'In de wacht / hervatten';

  @override
  String get shortcutsTransfer => 'Doorverbinden';

  @override
  String get shortcutsEndCall => 'Gesprek beëindigen';

  @override
  String get shortcutsNeedX11 =>
      'Globale sneltoetsen vereisen een X11-sessie. Wayland staat niet toe dat apps systeembreed toetsen onderscheppen.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Voeg Ctrl, Alt, Shift of $key toe aan een letter of cijfer';
  }

  @override
  String get shortcutsPressNew => 'Druk op de nieuwe toetscombinatie';

  @override
  String get defaultHandlerChooseInSettings =>
      'Kies SoftphonePro voor SIP, TEL en CALLTO bij Standaard-apps';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro opent nu sip:-, tel:- en callto:-links';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'De standaard voor $schemes kon niet worden gewijzigd';
  }

  @override
  String get defaultHandlerIntro =>
      'Opent sip:-, tel:- en callto:-links vanuit browsers en andere apps';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro verwerkt sip:-, tel:- en callto:-links';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Nu: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'SoftphonePro de standaard-app maken voor sip:-, tel:- en callto:-links';

  @override
  String get reliabilityTitle => 'Betrouwbaarheid op de achtergrond';

  @override
  String get reliabilityMicrophone => 'Microfoon';

  @override
  String get reliabilityAllowed => 'Toegestaan';

  @override
  String get reliabilityMicNeeded => 'Nodig om te praten tijdens gesprekken';

  @override
  String get reliabilityNotifications => 'Meldingen';

  @override
  String get reliabilityNotifNeeded =>
      'Nodig om inkomende gesprekken te tonen en de service zichtbaar te houden';

  @override
  String get reliabilityFullScreen => 'Inkomende gesprekken op volledig scherm';

  @override
  String get reliabilityFullScreenNeeded =>
      'Toestaan zodat gesprekken boven het vergrendelscherm verschijnen';

  @override
  String get reliabilityBattery => 'Onbeperkt batterijgebruik';

  @override
  String get reliabilityBatteryExempt =>
      'Uitgezonderd van batterijoptimalisatie';

  @override
  String get reliabilityBatteryNeeded =>
      'Android kan de app onderbreken om stroom te besparen en gesprekken missen. Tik om SoftphonePro uit te zonderen.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer automatisch starten / beveiligde apps';
  }

  @override
  String get reliabilityAutostartHint =>
      'Je telefoonfabrikant kan apps op de achtergrond afsluiten. Sta toe dat SoftphonePro automatisch start.';

  @override
  String get reliabilityBoot => 'Starten bij opstarten';

  @override
  String get reliabilityBootHint =>
      'Accounts registreren nadat de telefoon opnieuw is gestart';

  @override
  String get reliabilityWake => 'Processor actief houden in rust';

  @override
  String get reliabilityWakeHint =>
      'Betrouwbaarder op strenge apparaten; verbruikt meer batterij';

  @override
  String acctEditorDeleteTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String acctCodecRemove(String codec) {
    return '$codec verwijderen';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Laatste fout: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Toegestaan bereik $min tot $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Moet minimaal $min zijn';
  }

  @override
  String acctValidateMax(int max) {
    return 'Mag maximaal $max zijn';
  }

  @override
  String get acctEditorDiscardTitle => 'Wijzigingen negeren?';

  @override
  String get acctEditorDiscardMessage =>
      'Je wijzigingen aan dit account zijn niet opgeslagen.';

  @override
  String get acctEditorDiscardConfirm => 'Negeren';

  @override
  String get acctEditorDeleteMessage =>
      'Het account en het opgeslagen wachtwoord worden van dit apparaat verwijderd.';

  @override
  String get acctEditorMenuDelete => 'Account verwijderen';

  @override
  String get acctGroupBasic => 'Basis';

  @override
  String get acctFieldLabel => 'Label';

  @override
  String get acctFieldLabelHint => 'bijv. Kantoor';

  @override
  String get acctFieldDisplayName => 'Weergavenaam';

  @override
  String get acctFieldUsername => 'Gebruikersnaam';

  @override
  String get acctFieldProtocol => 'Protocol';

  @override
  String get acctFieldProtocolSub => 'Vast bij het aanmaken van het account';

  @override
  String get acctFieldAuthUser => 'Autorisatiegebruiker';

  @override
  String get acctFieldAuthUserHint => 'Zelfde als gebruikersnaam';

  @override
  String get acctFieldAuthUserSub =>
      'Alleen als de provider een andere inlognaam gebruikt dan de gebruikersnaam';

  @override
  String get acctFieldPassword => 'Wachtwoord';

  @override
  String get acctFieldServerHost => 'Serverhost';

  @override
  String get acctFieldPort => 'Poort';

  @override
  String get acctFieldIaxPortSub => 'Standaard voor IAX2 is 4569';

  @override
  String get acctFieldIaxContext => 'Context';

  @override
  String get acctFieldIaxContextSub =>
      'Optioneel. Wordt als aangeroepen context naar de centrale gestuurd';

  @override
  String get acctFieldServerDomain => 'Server / domein';

  @override
  String get acctFieldServerDomainSub => 'host of host:poort';

  @override
  String get acctFieldEnabled => 'Ingeschakeld';

  @override
  String get acctFieldDefault => 'Standaardaccount voor uitgaande gesprekken';

  @override
  String get acctFieldColour => 'Kleur';

  @override
  String get acctGroupRegistration => 'Registratie';

  @override
  String get acctFieldRegister => 'Registreren';

  @override
  String get acctFieldRegisterSubIax =>
      'Zet uit voor peers die geen registratie nodig hebben';

  @override
  String get acctFieldRegExpiry => 'Verlooptijd registratie (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk dwingt meestal 60 s af. Bereik 10 tot 86400';

  @override
  String get acctFieldRetryInterval => 'Herhaalinterval (s)';

  @override
  String get acctFieldFirstRetry => 'Eerste nieuwe poging (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 ondersteunt G.711 en GSM. Sleep om de voorkeursvolgorde in te stellen.';

  @override
  String get acctCodecAdd => 'Codec toevoegen';

  @override
  String get acctGroupServerTransport => 'Server en transport';

  @override
  String get acctFieldRegistrar => 'Registrar overschrijven';

  @override
  String get acctFieldBackupRegistrar => 'Back-upregistrar';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Wordt gebruikt na 3 mislukte pogingen; de primaire wordt elke 5 minuten opnieuw geprobeerd';

  @override
  String get acctFieldProxies => 'Uitgaande proxy\'s';

  @override
  String get acctFieldTransport => 'Transport';

  @override
  String get acctFieldTransportAutoSub =>
      'Zoekt de DNS SRV-records van de server op en kiest TLS, TCP of UDP';

  @override
  String get acctTransportAuto => 'Automatisch (DNS SRV)';

  @override
  String get acctFieldWsPath => 'WebSocket-pad';

  @override
  String get acctFieldWsPathSub =>
      'HTTP-pad van de WebSocket-upgrade, bijv. /ws. Moet met \"/\" beginnen';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 tot 3600 is gebruikelijk. Bereik 10 tot 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'UDP-keep-alive-interval. 0 schakelt uit. Bereik 0 tot 3600';

  @override
  String get acctFieldLocalPort => 'Lokale SIP-poort';

  @override
  String get acctFieldLocalPortSub =>
      '0 gebruikt het gedeelde transport. Bereik 0 tot 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Zet uit voor trunks zonder registratie';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Houdt een permanente verbinding open via NAT. Vereist ondersteuning door de server';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'STUN gebruiken';

  @override
  String get acctFieldTurn => 'TURN-relay';

  @override
  String get acctFieldTurnServer => 'TURN-server';

  @override
  String get acctFieldTurnUsername => 'TURN-gebruikersnaam';

  @override
  String get acctFieldTurnPassword => 'TURN-wachtwoord';

  @override
  String get acctFieldContactRewrite => 'Contact-header herschrijven';

  @override
  String get acctFieldViaRewrite => 'Via-header herschrijven';

  @override
  String get acctFieldRewriteSub =>
      'Gebruik het adres dat de server ziet. Laat aan achter NAT';

  @override
  String get acctFieldSdpRewrite => 'SDP-adres herschrijven';

  @override
  String get acctFieldSdpRewriteSub =>
      'Vervang het media-adres in SDP door het openbare adres';

  @override
  String get acctFieldIpv6Sip => 'IPv6-signalering';

  @override
  String get acctFieldIpv6Media => 'IPv6-media';

  @override
  String get acctGroupAdvancedMedia => 'Geavanceerde media';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTC-gateways vereisen RTCP-multiplexing en RTCP-feedback.';

  @override
  String get acctFieldRtcpMux => 'RTCP-multiplexing';

  @override
  String get acctFieldRtcpMuxSub =>
      'RTP en RTCP via één poort verzenden (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'RTCP-feedback (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'RTP/AVPF met NACK aanbieden. Vereist voor WebRTC-servers';

  @override
  String get acctGroupSecurity => 'Beveiliging';

  @override
  String get acctFieldSrtp => 'Media-versleuteling (SRTP)';

  @override
  String get acctOptOptional => 'Optioneel';

  @override
  String get acctOptRequired => 'Vereist';

  @override
  String get acctFieldKeyExchange => 'Sleuteluitwisseling';

  @override
  String get acctFieldSecureSignaling => 'Beveiligde signalering';

  @override
  String get acctOptNotRequired => 'Niet vereist';

  @override
  String get acctOptTlsHop => 'TLS hop-by-hop';

  @override
  String get acctOptTlsE2e => 'TLS end-to-end (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Authenticatie-algoritme';

  @override
  String get acctFieldPrivacy => 'Nummerweergave verbergen (privacy)';

  @override
  String get acctFieldReferPolicy => 'Inkomend doorverbinden (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Aanwezigheidsvolgers';

  @override
  String get acctOptAccept => 'Accepteren';

  @override
  String get acctOptReject => 'Weigeren';

  @override
  String get acctGroupCodecsFooter =>
      'Overschrijft de globale codeclijst voor dit account.';

  @override
  String get acctFieldUseGlobalCodecs => 'Globale codecvolgorde gebruiken';

  @override
  String get acctGroupFeatures => 'Functies';

  @override
  String get acctFieldVoicemailNumber => 'Voicemailnummer';

  @override
  String get acctFieldMwi => 'Voicemailindicator (MWI)';

  @override
  String get acctFieldMwiSub => 'Meldingen over wachtende berichten ontvangen';

  @override
  String get acctFieldPublishPresence => 'Mijn aanwezigheid publiceren';

  @override
  String get acctFieldPublishPresenceSub =>
      'Laat de server je onlinestatus delen';

  @override
  String get acctFieldDnd => 'Niet storen';

  @override
  String get acctFieldForwarding => 'Doorschakelen';

  @override
  String get acctOptForwardAlways => 'Altijd';

  @override
  String get acctOptForwardBusy => 'Bij bezet';

  @override
  String get acctOptForwardNoAnswer => 'Bij geen gehoor';

  @override
  String get acctFieldForwardTo => 'Doorschakelen naar';

  @override
  String get acctFieldForwardToHint => 'Nummer of SIP-adres';

  @override
  String get acctFieldRingFor => 'Overgaan gedurende (s)';

  @override
  String get acctFieldAutoAnswer => 'Automatisch opnemen';

  @override
  String get acctFieldAnswerAfter => 'Opnemen na (s)';

  @override
  String get acctFieldIntercomOnly => 'Alleen voor intercomgesprekken';

  @override
  String get acctFieldIntercomOnlySub =>
      'Vereist een header voor automatisch opnemen van de centrale';

  @override
  String get acctFieldRingtone => 'Beltoon';

  @override
  String get acctRingtoneClassic => 'Klassiek';

  @override
  String get acctRingtoneSoft => 'Zacht';

  @override
  String get acctRingtoneDigital => 'Digitaal';

  @override
  String get acctFieldRecordCalls => 'Gesprekken opnemen';

  @override
  String get acctFieldHoldMusic => 'Wachtmuziek';

  @override
  String get acctOptUseGlobal => 'Globale instelling gebruiken';

  @override
  String get acctOptPbxDefault => 'Standaard van centrale';

  @override
  String get acctFieldOpeningAnnouncement => 'Openingsaankondiging';

  @override
  String get acctGroupFeatureCodes => 'Servicecodes';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Gekozen voor parkeren, overnemen, Niet storen en doorschakelen op je telefooncentrale.';

  @override
  String get acctFieldPark => 'Parkeren';

  @override
  String get acctFieldGroupPickup => 'Groepsovername';

  @override
  String get acctFieldDirectedPickup => 'Voorvoegsel gerichte overname';

  @override
  String get acctFieldParkRetrieve => 'Voorvoegsel parkeerplek ophalen';

  @override
  String get acctFieldParkRetrieveHint => 'Kies het plekkennummer';

  @override
  String get acctFieldParkRetrieveSub =>
      'Voorvoegsel dat vóór de parkeerplek wordt gekozen om een geparkeerd gesprek terug te nemen';

  @override
  String get acctFieldDndOn => 'DND aan';

  @override
  String get acctFieldDndOff => 'DND uit';

  @override
  String get acctFieldForwardOn => 'Doorschakelen aan';

  @override
  String get acctFieldForwardOff => 'Doorschakelen uit';

  @override
  String get acctGroupAdvanced => 'Geavanceerd';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF wordt als native IAX2-frames verzonden.';

  @override
  String get acctFieldCallerIdOverride => 'Beller-ID overschrijven';

  @override
  String get acctFieldCallerIdHint => 'Accountstandaard gebruiken';

  @override
  String get acctFieldCallerIdSub =>
      'Naam of nummer van de beller dat naar de centrale wordt gestuurd';

  @override
  String get acctFieldSessionTimers => 'Sessietimers';

  @override
  String get acctFieldSessionExpires => 'Sessie verloopt (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Bereik 90 tot 86400';

  @override
  String get acctField100rel => '100rel (betrouwbare tussentijdse respons)';

  @override
  String get acctFieldHoldMethod => 'Wachtmethode';

  @override
  String get acctFieldDtmfMethod => 'DTMF-methode';

  @override
  String get acctOptDtmfInband => 'In-band';

  @override
  String get acctFieldRedirects => 'Omleidingen (3xx)';

  @override
  String get acctOptRedirectFollow => 'Volgen';

  @override
  String get acctOptRedirectAsk => 'Vragen';

  @override
  String get acctFieldLockCodec => 'Codec vergrendelen na opnemen';

  @override
  String get acctFieldMediaKeepAlive => 'Media-keep-alive';

  @override
  String get acctFieldDropCalls =>
      'Gesprekken verbreken als registratie mislukt';

  @override
  String get acctFieldExtraHeaders => 'Extra SIP-headers';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: waarde (één per regel)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Wachttijd voordat een mislukte registratie opnieuw wordt geprobeerd. Bereik 0 tot 86400';

  @override
  String get acctFieldUnregTimeout => 'Time-out afmelden (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Hoe lang wordt gewacht op het antwoord op het afmelden. Bereik 0 tot 60000';

  @override
  String get acctFieldMwiExpiry => 'Verlooptijd MWI-abonnement (s)';

  @override
  String get acctFieldDscpSip => 'DSCP voor SIP';

  @override
  String get acctFieldDscpSipSub =>
      'QoS-markering van signalering. 24 (CS3) is gebruikelijk';

  @override
  String get acctFieldDscpRtp => 'DSCP voor RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'QoS-markering van media. 46 (EF) is gebruikelijk';

  @override
  String get acctFieldReinvite => 'Re-INVITE na netwerkwijziging';

  @override
  String get acctFieldHangupOnIpChange =>
      'Gesprekken beëindigen bij netwerkwijziging';

  @override
  String get acctValidateInt => 'Voer een geheel getal in';

  @override
  String get acctValidateHostEmpty =>
      'Voer een hostnaam of adres van de server in';

  @override
  String get acctValidateHostSpaces => 'De server mag geen spaties bevatten';

  @override
  String get acctValidateHostFormat => 'Voer alleen host of host:poort in';

  @override
  String get acctValidatePortRange => 'De poort moet tussen 1 en 65535 liggen';

  @override
  String get acctValidateWsStart => 'Het pad moet met \"/\" beginnen';

  @override
  String get acctValidateWsLength => 'Gebruik maximaal 120 tekens';

  @override
  String get acctValidateWsSpaces => 'Het pad mag geen spaties bevatten';

  @override
  String get acctTplAsteriskDescription =>
      'Toestel op je eigen telefooncentrale. UDP 5060, STUN aan.';

  @override
  String get acctTplAsteriskNotes =>
      'Gebruik het PJSIP/SIP-toestelnummer en het bijbehorende secret. Voor TLS of WebRTC wijzig je het transport later in de accountinstellingen.';

  @override
  String get acctTplAsteriskUsernameHint => 'Toestel (bijv. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Gebruik het toestel, de auth-ID en het wachtwoord uit het 3CX-portaal.';

  @override
  String get acctTpl3cxNotes =>
      'Open in 3CX het toestel en ga naar \"Phones > Provisioning\" voor de Authentication ID (stel die in als Autorisatiegebruiker) en het wachtwoord. De FQDN is die in je 3CX-URL.';

  @override
  String get acctTpl3cxUsernameHint => 'Toestel';

  @override
  String get acctTplFreeswitchDescription =>
      'Directorygebruiker op een FreeSWITCH-server.';

  @override
  String get acctTplFreeswitchNotes =>
      'Gebruik de gebruikers-ID en het wachtwoord uit de directory. Het standaard interne profiel luistert op UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'Gebruikers-ID';

  @override
  String get acctTplKamailioDescription =>
      'SIP-proxyregistrar. TCP aanbevolen achter NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Gebruik het SIP-domein dat je registrar bedient. Voeg in de accountinstellingen een uitgaande proxy toe als de registrar via een andere host wordt bereikt.';

  @override
  String get acctTplTwilioDescription =>
      'Inloggegevens van een Programmable Voice SIP Domain. TLS en SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Maak een SIP Domain aan in de Twilio-console, voeg een Credential List toe en schakel SIP Registration in. Voer het volledige domein (name.sip.twilio.com) in als server en de gebruiker en het wachtwoord van de credential list. TLS gebruikt poort 5061. Twilio ondersteunt alleen G.711.';

  @override
  String get acctTplTwilioUsernameHint => 'Gebruikersnaam van credential list';

  @override
  String get acctTplTelnyxDescription =>
      'Credential connection. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Maak een Credential Connection aan in het Telnyx-portaal en kopieer de SIP-gebruikersnaam en het wachtwoord (niet je portaalinlog). Wijs een nummer of uitgaand spraakprofiel aan de verbinding toe om te kunnen bellen en gebeld te worden.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP-gebruikersnaam (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Gebruikersnaam en wachtwoord van subaccount. Kies de POP die het dichtst bij je is.';

  @override
  String get acctTplVoipmsNotes =>
      'Gebruik een subaccount dat onder Sub Accounts is aangemaakt, niet je hoofdaccount. Kies de server (POP) die het dichtst bij je is uit de VoIP.ms-serverlijst en sta deze indien nodig toe voor je IP-adres.';

  @override
  String get acctTplVoipmsUsernameHint => 'Subaccount (bijv. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'SIP-registratie met TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business biedt SIP-registratie alleen bij sommige abonnementen. Voer de SIP-server, gebruiker en het wachtwoord in die in het Vonage-beheerportaal voor het toestel worden getoond.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange via UDP 4569. Geen NAT- of SRTP-instellingen.';

  @override
  String get acctTplIax2Notes =>
      'Vereist een peer/user in iax.conf (type=friend of user+peer) met hetzelfde secret. Asterisk vernieuwt IAX2-registraties standaard elke 60 s. De context is optioneel en wordt als aangeroepen context verzonden.';

  @override
  String get acctTplIax2UsernameHint => 'IAX2-gebruikersnaam';

  @override
  String get acctTplWebrtcDescription =>
      'SIP via beveiligde WebSocket met DTLS-SRTP, ICE en RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Voor Asterisk (webrtc=yes, http.conf TLS op 8089), FreeSWITCH of Kamailio WebSocket-endpoints. De server heeft een geldig TLS-certificaat nodig. Wijzig het WebSocket-pad in de accountinstellingen als je gateway geen /ws gebruikt.';

  @override
  String get acctTplGenericDescription =>
      'Elke SIP-registrar. Vul de gegevens zelf in.';

  @override
  String get acctTplDefaultUsernameHint => 'Toestel / gebruikersnaam';

  @override
  String get appEngineFailedBody =>
      'Bellen en registratie werken pas weer als dit is opgelost. Meestal ligt een onjuiste netwerk- of certificaatinstelling aan de oorzaak.';

  @override
  String get appEngineFailedTitle =>
      'De gespreksengine kon niet worden gestart';

  @override
  String get appEngineNotRunning => 'De gespreksengine draait niet';

  @override
  String get appUnknownError => 'Onbekende fout';

  @override
  String get appEngineOpenNetworkSettings => 'Netwerkinstellingen openen';

  @override
  String get appEngineUseSimulator => 'Simulator gebruiken (demo)';

  @override
  String get appDbLockedTitle => 'Je gegevens zijn vergrendeld';

  @override
  String get appDbUnreadableTitle => 'Je gegevens kunnen niet worden geopend';

  @override
  String get appDbLockedBody =>
      'Gespreksgeschiedenis, contacten en berichten zijn op dit apparaat versleuteld, maar de versleutelingssleutel staat niet meer in de systeemsleutelhanger/keystore (bijvoorbeeld na het resetten van de sleutelhanger of een herstel op een nieuw apparaat).';

  @override
  String get appDbUnreadableBody =>
      'De lokale database kon niet worden gelezen. Mogelijk is deze beschadigd of komt de versleutelingssleutel niet overeen.';

  @override
  String get appDbRecoveryAdvice =>
      'Probeer het opnieuw als je verwacht dat de sleutel terugkomt (ontgrendel de sleutelhanger, meld je aan bij de juiste gebruiker). Opnieuw beginnen bewaart het oude bestand naast de appgegevens, maar start met een lege geschiedenis, lege contacten en berichten; je moet je accounts dan opnieuw toevoegen.';

  @override
  String get appDbCopyDetails => 'Details kopiëren';

  @override
  String get appDbTryAgain => 'Opnieuw proberen';

  @override
  String get appDbStartFresh => 'Opnieuw beginnen';

  @override
  String get appRedirectTitle => 'Gesprek omgeleid';

  @override
  String appRedirectMessage(String target) {
    return 'Gesprek omgeleid naar $target - volgen?';
  }

  @override
  String get appRedirectCancelCall => 'Gesprek annuleren';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Je gegevens konden niet worden versleuteld ($error). Er is niets gewijzigd.',
      'other':
          'Je gegevens konden niet worden ontsleuteld ($error). Er is niets gewijzigd.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Native engine niet beschikbaar ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Nieuwe poging om $time';
  }

  @override
  String get acctRegistrationError => 'Registratiefout';

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
  String get acctCallingFromDirect => 'Bellen zonder account, rechtstreeks';

  @override
  String acctCallingFromAccount(String name) {
    return 'Bellen vanaf $name';
  }

  @override
  String get acctCallingFromNone => 'Bellen zonder account';

  @override
  String get acctNoAccount => 'Geen account';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nieuw, $oldCount oud';
  }

  @override
  String get acctAddAccount => 'Account toevoegen';

  @override
  String get acctUnregister => 'Afmelden';

  @override
  String get acctSheetDndSub => 'Inkomende gesprekken op dit account weigeren';

  @override
  String get acctKvServer => 'Server';

  @override
  String get acctKvResolvedServer => 'Opgeloste server';

  @override
  String get acctKvClientCert => 'Clientcert.';

  @override
  String get acctKvClientCertValue =>
      'Aan de server aangeboden (wederzijdse TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Verloopt over';

  @override
  String get acctKvVoicemail => 'Voicemail';

  @override
  String get acctOpenSipTrace => 'SIP-trace openen';

  @override
  String get acctAddAnAccount => 'Een account toevoegen';

  @override
  String get acctChooseAccountTooltip => 'Kies het account om mee te bellen';

  @override
  String get acctDirectNoAccount => 'Rechtstreeks (geen account)';

  @override
  String get onboardingRequired => 'Gebruikersnaam en server zijn vereist';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Poort $port wordt gebruikt tenzij je :poort toevoegt';
  }

  @override
  String get onboardingFineTuneIax =>
      'Je kunt codecs en registratie later afstemmen in Instellingen.';

  @override
  String get onboardingFineTuneSip =>
      'Je kunt transport, NAT, beveiliging en codecs later afstemmen in Instellingen.';

  @override
  String get onboardingDemoUser => 'Demogebruiker';

  @override
  String get onboardingDemoAccount => 'Demoaccount';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Professioneel bellen voor elk platform - gratis en open source. Geen advertenties, geen tracking.';

  @override
  String get onboardingGetStarted => 'Aan de slag';

  @override
  String get onboardingPermissionsTitle => 'Toestemmingen';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro heeft de microfoon nodig om je stem door te geven en meldingen om je te waarschuwen voor inkomende gesprekken en berichten. Er verlaat niets je apparaat behalve je gesprekken.';

  @override
  String get onboardingChooseProvider => 'Kies je provider';

  @override
  String get onboardingChooseProviderSub =>
      'We vullen transport, poorten en NAT-instellingen alvast voor je in.';

  @override
  String get onboardingScanQr => 'QR scannen';

  @override
  String get onboardingImportUrl => 'Importeren via URL';

  @override
  String get onboardingSkip => 'Nu overslaan (demomodus)';

  @override
  String get onboardingHidePassword => 'Wachtwoord verbergen';

  @override
  String get onboardingShowPassword => 'Wachtwoord tonen';

  @override
  String get onboardingContextOptional => 'Context (optioneel)';

  @override
  String get onboardingDisplayNameOptional => 'Weergavenaam (optioneel)';

  @override
  String get onboardingLabelOptional => 'Accountlabel (optioneel)';

  @override
  String get onboardingCallerIdOptional => 'Beller-ID (optioneel)';

  @override
  String get onboardingAuthUserOptional =>
      'Autorisatiegebruiker (indien anders)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Onjuiste gebruikersnaam of wachtwoord ($code)';
  }

  @override
  String get acctRegNotFound => 'Account niet gevonden op de server (404)';

  @override
  String get acctRegNoAnswer => 'Server antwoordde niet (408)';

  @override
  String get acctRegIntervalTooShort => 'Registratie-interval te kort (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Server tijdelijk niet beschikbaar (480)';

  @override
  String get acctRegServiceUnavailable => 'Dienst niet beschikbaar (503)';

  @override
  String get acctRegFailed => 'Registratie mislukt';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Registratie mislukt ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Registratie kon niet worden gewijzigd';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Account \"$name\" kon niet worden toegepast';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Terug op de primaire server voor $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Back-upserver wordt gebruikt voor $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'Account $name is geregistreerd';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'Account $name wordt nog geregistreerd';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'Account $name is nog niet geregistreerd';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'Account $name is niet geregistreerd (registratie mislukt)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'Account $name is uitgeschakeld';
  }

  @override
  String get callDialEngineFailed =>
      'De gespreksengine kon niet worden gestart';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'De gespreksengine kon niet worden gestart: $reason';
  }

  @override
  String get callDialEngineStarting => 'De gespreksengine wordt nog gestart';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status na $seconds s; het gesprek is niet tot stand gebracht';
  }

  @override
  String get callJournalInterrupted =>
      'De app werd tijdens het gesprek gesloten';

  @override
  String get callLinkMissingArgument => 'Argument ontbreekt';

  @override
  String get callLinkHttpsRequired =>
      'Configuratielinks moeten https gebruiken';

  @override
  String get callLinkInvalidLan => 'Die LAN-link is ongeldig';

  @override
  String callLinkConnectedTo(String name) {
    return 'Verbonden met $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Kon geen verbinding maken met dat apparaat';

  @override
  String callLinkCallFailed(String target) {
    return 'Het gesprek naar $target kon niet worden gestart';
  }

  @override
  String get callLinkImportTitle => 'Configuratie importeren';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts accounts',
      one: '1 account',
    );
    return 'Configuratie van $host importeren? Er worden $_temp0 toegevoegd.';
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
    return 'Configuratie van $host importeren? Er worden $_temp0 en $settings instelling(en) toegevoegd.';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Doorgeschakeld van $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Doorgeschakeld van $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Doorverbonden door $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Systeemstandaard';

  @override
  String get callRingtoneClassic => 'Klassiek';

  @override
  String get callRingtoneSoft => 'Zacht';

  @override
  String get callRingtoneDigital => 'Digitaal';

  @override
  String callIdentityFrom(String number) {
    return 'Van $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Beller-ID $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Beller-ID $name $number';
  }

  @override
  String get callTransferring => 'Doorverbinden...';

  @override
  String get callTransferNotConfirmed =>
      'Doorverbinding niet bevestigd door de server';

  @override
  String get callTransferStalledHint =>
      'Het gesprek is nog actief. Houd het vast of verstuur de doorverbinding opnieuw.';

  @override
  String get callTransferKeepCall => 'Gesprek houden';

  @override
  String get callAnnouncementOpening => 'Aankondiging wordt afgespeeld…';

  @override
  String get callAnnouncementTransfer => 'Doorverbindmelding wordt afgespeeld…';

  @override
  String get callAnnouncementRecording => 'Opnamemelding wordt afgespeeld…';

  @override
  String get callAnnouncementSkip => 'Overslaan';

  @override
  String get callNoiseTooltipMic => 'AI-ruisonderdrukking: je microfoon';

  @override
  String get callNoiseTooltipIncoming =>
      'AI-ruisonderdrukking: andere deelnemers';

  @override
  String get callNoiseTooltipBoth =>
      'AI-ruisonderdrukking: je microfoon en andere deelnemers';

  @override
  String get callNoiseOn => 'Ruisonderdrukking aan';

  @override
  String get callNoiseTitle => 'Ruisonderdrukking';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Mijn microfoon: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Achtergrondruis uit mijn microfoon verwijderen';

  @override
  String get callResultAnswered => 'Beantwoord';

  @override
  String get callResultMissed => 'Gemist';

  @override
  String get callResultRejected => 'Geweigerd';

  @override
  String get callResultFailed => 'Mislukt';

  @override
  String get callResultBusy => 'Bezet';

  @override
  String get callResultForwarded => 'Doorgeschakeld';

  @override
  String get callResultTransferred => 'Doorverbonden';

  @override
  String get callResultHandedOff => 'Overgedragen';

  @override
  String get callResultInterrupted => 'Onderbroken';

  @override
  String get keypadCall => 'Bellen';

  @override
  String get keypadNoVoicemail =>
      'Geen voicemailnummer ingesteld voor dit account';

  @override
  String get keypadCallDirectly => 'Rechtstreeks bellen (geen account)';

  @override
  String get keypadAddAccount => 'Voeg een account toe om te kunnen bellen';

  @override
  String keypadCallFrom(String account) {
    return 'Bellen vanaf $account';
  }

  @override
  String get keypadRecent => 'Recent';

  @override
  String get keypadSuggestions => 'Suggesties';

  @override
  String get keypadPhoneNumber => 'Telefoonnummer';

  @override
  String get keypadPaste => 'Plakken';

  @override
  String get keypadEnterNumber => 'Nummer invoeren';

  @override
  String get keypadBackspace => 'Backspace (lang indrukken om te wissen)';

  @override
  String get keypadTypeNameOrNumber => 'Typ een naam of nummer';

  @override
  String get keypadNoMatches => 'Geen resultaten';

  @override
  String get keypadSuggestionsHint =>
      'Suggesties komen uit contacten en recente gesprekken';

  @override
  String keypadCallPerson(String name) {
    return '$name bellen';
  }

  @override
  String get dialKeyStar => 'Sterretje';

  @override
  String get dialKeyPound => 'Hekje';

  @override
  String get dialKeyLongPressPlus => 'Lang indrukken voor plus';

  @override
  String get dialKeyLongPressSpeedDial => 'Lang indrukken voor snelkiezen';

  @override
  String get dialKeyLongPressVoicemail => 'Lang indrukken voor voicemail';

  @override
  String get callBackToApp => 'Terug naar app (gesprek blijft actief)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Toetsen verbergen';

  @override
  String get callMute => 'Dempen';

  @override
  String get callKeypad => 'Toetsen';

  @override
  String get callSpeaker => 'Speaker';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Headset';

  @override
  String get callResume => 'Hervatten';

  @override
  String get callHold => 'In wacht';

  @override
  String get callAddCall => 'Gesprek toevoegen';

  @override
  String get callTransfer => 'Doorverbinden';

  @override
  String get callStop => 'Stoppen';

  @override
  String get callRecord => 'Opnemen';

  @override
  String get callSplit => 'Splitsen';

  @override
  String get callMerge => 'Samenvoegen';

  @override
  String get callSwap => 'Wisselen';

  @override
  String get callEndCall => 'Gesprek beëindigen';

  @override
  String callEndCallWith(String name) {
    return 'Gesprek met $name beëindigen';
  }

  @override
  String get callAttendedTransferHint =>
      'Begeleid doorverbinden. De oorspronkelijke beller staat in de wacht.';

  @override
  String get callCompleteTransfer => 'Doorverbinden voltooien';

  @override
  String get callWaiting => 'Wachtend gesprek';

  @override
  String get callHoldAndAnswer =>
      'Huidig gesprek in de wacht zetten en opnemen';

  @override
  String get callDecline => 'Weigeren';

  @override
  String get callAnswer => 'Opnemen';

  @override
  String get callIncomingCall => 'Inkomend gesprek';

  @override
  String get callReply => 'Antwoord';

  @override
  String get callVoicemail => 'Voicemail';

  @override
  String get callToDevice => 'Naar apparaat';

  @override
  String get callQuickReplyBusy => 'Ik kan nu niet praten, ik bel je terug.';

  @override
  String get callQuickReplyMeeting =>
      'Ik zit in een vergadering. Stuur me een bericht?';

  @override
  String get callQuickReplyOnMyWay => 'Ik ben onderweg.';

  @override
  String callReturnToCallWith(String name) {
    return 'Terug naar gesprek met $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Inkomend: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'In gesprek met $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Pakketverlies';

  @override
  String get callStatsRoundTrip => 'Retourtijd';

  @override
  String get callStatsMedia => 'Media';

  @override
  String get callStatsMosHistory => 'MOS-verloop';

  @override
  String get callQualityTitle => 'Gesprekskwaliteit';

  @override
  String get callTransferTitle => 'Gesprek doorverbinden';

  @override
  String get callTransferModeBlind => 'Direct';

  @override
  String get callTransferModeAttended => 'Begeleid';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN-apparaat';

  @override
  String get callTransferNoLanDevices =>
      'Geen gekoppelde SoftphonePro-apparaten gevonden op je netwerk. Koppel er een op de LAN-pagina.';

  @override
  String get callTransferLanDisabled =>
      'Schakel LAN Link in (Instellingen, LAN Link) om dit gesprek over te dragen aan een ander apparaat op je netwerk.';

  @override
  String get callTransferTalkFirst => 'Eerst spreken';

  @override
  String get callTransferBlindHint =>
      'Geeft de beller direct over. Jouw verbinding wordt verbroken.';

  @override
  String get callTransferAttendedHint =>
      'Zet de beller in de wacht en belt eerst de bestemming. Voltooi het doorverbinden zodra die opneemt.';

  @override
  String get callTransferNumberLabel => 'Nummer of SIP-adres';

  @override
  String get callTransferNow => 'Nu doorverbinden';

  @override
  String get callTransferCallAndConsult => 'Bellen en overleggen';

  @override
  String get callRetrieveParkedTitle => 'Geparkeerd gesprek ophalen';

  @override
  String get callRetrieveParkedHint => 'Parkeerplek, bijv. 701';

  @override
  String get callMoreAudioOutput => 'Audio-uitvoer';

  @override
  String get callMoreAudioDevices => 'Audioapparaten';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefoon, speaker, Bluetooth, headset';

  @override
  String get callMoreAudioDevicesSubtitle => 'Kies microfoon en luidspreker';

  @override
  String get callMoreParkCall => 'Gesprek parkeren';

  @override
  String get callMoreParkCallSubtitle =>
      'Doorverbinden naar de servicecode voor parkeren';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Een parkeerplek kiezen';

  @override
  String get callMoreSendDtmf => 'DTMF-cijfers verzenden';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Typ een hele reeks, bijv. een pincode';

  @override
  String get callSendDtmfTitle => 'DTMF verzenden';

  @override
  String get callMoreCallInfo => 'Gespreksinfo';

  @override
  String get callMoreQualitySubtitle =>
      'Live MOS, jitter, verlies en retourtijd';

  @override
  String get callMoreSipTrace => 'SIP-trace';

  @override
  String get callMoreSipTraceSubtitle => 'Ladderdiagram van dit gesprek';

  @override
  String get callInfoRemote => 'Tegenpartij';

  @override
  String get callInfoAccount => 'Account';

  @override
  String get callInfoState => 'Status';

  @override
  String get callInfoSecure => 'Beveiligd';

  @override
  String get callInfoPlainSignalling => 'onbeveiligde signalering';

  @override
  String get callRoutePhone => 'Telefoon';

  @override
  String get callRouteWiredHeadset => 'Bedrade headset';

  @override
  String get callAudioMicrophone => 'Microfoon';

  @override
  String callCardSemantics(String name, String state) {
    return 'Gesprek met $name, $state';
  }

  @override
  String get callUnmute => 'Dempen opheffen';

  @override
  String get callStopRecording => 'Opname stoppen';

  @override
  String get callSplitConference => 'Conferentie splitsen';

  @override
  String get callMergeCalls => 'Gesprekken samenvoegen';

  @override
  String get callSwapCalls => 'Gesprekken wisselen';

  @override
  String get callAttendedTransferBanner =>
      'Begeleid doorverbinden: de oorspronkelijke beller staat in de wacht.';

  @override
  String get callActiveCalls => 'Actieve gesprekken';

  @override
  String get callConferenceLevels => 'Conferentieniveaus';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Microfoon naar deelnemer';

  @override
  String callPercentSemantics(int percent) {
    return '$percent procent';
  }

  @override
  String get callFailInvalidNumber => 'Ongeldig nummer (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Gesprek niet geautoriseerd ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Nummer niet gevonden (404)';

  @override
  String get callFailNoAnswerFromServer => 'Geen antwoord van server (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Tijdelijk niet beschikbaar (480)';

  @override
  String get callFailIncompleteNumber => 'Onvolledig nummer (484)';

  @override
  String callFailBusy(String code) {
    return 'Bezet ($code)';
  }

  @override
  String get callFailCancelled => 'Gesprek geannuleerd (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Geen compatibele codec ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Dienst niet beschikbaar (503)';

  @override
  String get callFailDeclined => 'Gesprek geweigerd (603)';

  @override
  String get callFailGeneric => 'Gesprek mislukt';

  @override
  String callFailGenericWithCode(String code) {
    return 'Gesprek mislukt ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Gesprek bezig';

  @override
  String get callTrayInCall => 'In gesprek';

  @override
  String get callHistoryBlocked => 'Geblokkeerd';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimiteit niet toegestaan';

  @override
  String get callHistoryDoNotDisturb => 'Niet storen';

  @override
  String get callHistoryBusy => 'Bezet';

  @override
  String get callHistoryForwardedAlways => 'Doorgeschakeld (altijd)';

  @override
  String get callHistoryForwardedBusy => 'Doorgeschakeld (bezet)';

  @override
  String get callHistorySentToVoicemail => 'Naar voicemail gestuurd';

  @override
  String get callHistoryRedirected => 'Omgeleid';

  @override
  String get callIncomingNotificationBody => 'Inkomend gesprek';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Inkomend gesprek op $account';
  }

  @override
  String get callMissedNotificationTitle => 'Gemist gesprek';

  @override
  String get callErrEngineNotRunning => 'De gespreksengine draait nog niet';

  @override
  String get callErrAddAccount => 'Voeg een account toe om te kunnen bellen';

  @override
  String get callErrCouldNotPlace => 'Het gesprek kon niet worden gestart';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account is niet geregistreerd';
  }

  @override
  String get callErrCouldNotAnswer => 'Kon niet opnemen';

  @override
  String get callErrNoVoicemailNumber =>
      'Geen voicemailnummer ingesteld voor dit account';

  @override
  String get callErrTransferFailed => 'Doorverbinden mislukt';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Doorverbinden mislukt: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge =>
      'Gesprekken konden niet worden samengevoegd';

  @override
  String get callErrCouldNotStartRecording => 'Opname kon niet worden gestart';

  @override
  String get callErrCouldNotStopRecording => 'Opname kon niet worden gestopt';

  @override
  String callParkingNotice(String code) {
    return 'Gesprek wordt geparkeerd (kies $code)';
  }

  @override
  String get callErrParkFailed => 'Parkeren mislukt';

  @override
  String get callErrHandoffFailed => 'Overdracht mislukt';

  @override
  String get callErrCouldNotSendToDevice => 'Kon niet naar het apparaat sturen';

  @override
  String get callHistoryForwardedNoAnswer => 'Doorgeschakeld (geen gehoor)';

  @override
  String get shellTabKeypad => 'Toetsen';

  @override
  String get shellTabRecents => 'Recent';

  @override
  String get shellTabContacts => 'Contacten';

  @override
  String get shellTabMessages => 'Berichten';

  @override
  String get shellTabPresence => 'Aanwezigheid';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Opnamen';

  @override
  String get shellSearchSemantics =>
      'Zoek contacten of geschiedenis, of kies een nummer';

  @override
  String get shellSearchHint => 'Zoeken of bellen';

  @override
  String get shellVoicemailTooltip => 'Voicemail';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe voicemails. Klik om voicemail te bellen',
      one: '1 nieuwe voicemail. Klik om voicemail te bellen',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Afwezig';

  @override
  String get shellStatusTooltip => 'Jouw status';

  @override
  String get shellDemoBanner =>
      'Demomodus: gesprekken worden gesimuleerd, er bereikt niets een echt netwerk.';

  @override
  String get uiToday => 'Vandaag';

  @override
  String get uiYesterday => 'Gisteren';

  @override
  String get uiUnknownCaller => 'Onbekende beller';

  @override
  String get uiCallEnded => 'Gesprek beëindigd';

  @override
  String get uiCallTransferNotConfirmed => 'Doorverbinding niet bevestigd';

  @override
  String get uiCallTransferring => 'Doorverbinden...';

  @override
  String get uiCallConference => 'Conferentie';

  @override
  String get uiCallOnHold => 'In de wacht';

  @override
  String get uiCallHeldByRemote => 'Door tegenpartij in de wacht gezet';

  @override
  String get uiCallCalling => 'Bellen...';

  @override
  String get uiCallRinging => 'Overgaan...';

  @override
  String get uiCallConnecting => 'Verbinden...';

  @override
  String get uiCallIncoming => 'Inkomend gesprek';

  @override
  String get uiCallConnected => 'Verbonden';

  @override
  String get uiQrScanTitle => 'QR-code scannen';

  @override
  String get uiQrPasteHint => 'Plak de codetekst';

  @override
  String get uiQrNoCamera =>
      'Scannen met de camera is niet beschikbaar op dit apparaat. Plak in plaats daarvan de codetekst.';

  @override
  String get uiQrPaste => 'Plakken';

  @override
  String get uiQrUse => 'Gebruiken';

  @override
  String get uiQrCameraDenied =>
      'Cameratoegang staat uit. Sta deze toe in de systeeminstellingen of plak hieronder de codetekst.';

  @override
  String get uiQrCameraUnavailable =>
      'De camera is niet beschikbaar. Plak hieronder de codetekst.';

  @override
  String get presenceLampRinging => 'Overgaan';

  @override
  String get presenceHeader => 'Busy lamp field';

  @override
  String get presenceChooseTooltip => 'Kies contacten om te volgen';

  @override
  String get presenceEmptyTitle => 'Geen toestellen op het bord';

  @override
  String get presenceEmptySubtitle =>
      'Schakel \"Tonen op BLF-bord\" in voor een contact om te zien wanneer die vrij is, overgaat of bezet is.';

  @override
  String get presenceOpenContacts => 'Contacten openen';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Tik om te bellen, lang indrukken voor meer';
  }

  @override
  String presenceCallName(String name) {
    return '$name bellen';
  }

  @override
  String get presencePickup => 'Dit toestel overnemen';

  @override
  String get presencePickupSub =>
      'Het overgaande gesprek opnemen (gerichte overname)';

  @override
  String get presenceTransferHere => 'Huidig gesprek hierheen doorverbinden';

  @override
  String get presenceRemove => 'Van bord verwijderen';

  @override
  String get uiCall => 'Bellen';

  @override
  String get uiMessage => 'Bericht';

  @override
  String get recentsSearchTooltip => 'Geschiedenis doorzoeken';

  @override
  String get recentsClearTitle => 'Gespreksgeschiedenis wissen?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count items worden verwijderd.',
      one: '1 item wordt verwijderd.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'Geschiedenis als CSV naar klembord gekopieerd';

  @override
  String get recentsMenuCopyCsv => 'Kopiëren als CSV';

  @override
  String get recentsMenuClear => 'Geschiedenis wissen';

  @override
  String get recentsSearchHint => 'Zoek op naam of nummer';

  @override
  String get recentsFilterAll => 'Alle';

  @override
  String get recentsFilterMissed => 'Gemist';

  @override
  String get recentsFilterIncoming => 'Inkomend';

  @override
  String get recentsFilterOutgoing => 'Uitgaand';

  @override
  String get recentsFilterAccount => 'Filteren op account';

  @override
  String get recentsAllAccounts => 'Alle accounts';

  @override
  String get recentsAccountFallback => 'Account';

  @override
  String get recentsEmptyNone => 'Nog geen gesprekken';

  @override
  String get recentsEmptyNoMatch => 'Geen overeenkomende gesprekken';

  @override
  String get recentsEmptyNoneSub => 'Je gesprekken verschijnen hier.';

  @override
  String get recentsEmptyNoMatchSub => 'Probeer een ander filter.';

  @override
  String get recentsOpenKeypad => 'Toetsen openen';

  @override
  String get recentsShowAll => 'Alles tonen';

  @override
  String get recentsSelectCall => 'Selecteer een gesprek';

  @override
  String get recentsSelectCallSub =>
      'Details, kwaliteit en opnamen verschijnen hier.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Gemist gesprek',
      'incoming': 'Inkomend gesprek',
      'other': 'Uitgaand gesprek',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '$name bellen';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Voeg een account toe om berichten te versturen';

  @override
  String get recentsAddContact => 'Contact toevoegen';

  @override
  String get recentsContact => 'Contact';

  @override
  String get recentsBlock => 'Blokkeren';

  @override
  String get recentsUnblock => 'Deblokkeren';

  @override
  String recentsBlockTitle(String number) {
    return '$number blokkeren?';
  }

  @override
  String get recentsBlockMessage =>
      'Gesprekken van dit nummer worden automatisch geweigerd.';

  @override
  String get recentsQualityHeader => 'Gesprekskwaliteit';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Slechtste MOS $mos   ·   Jitter $jitter ms   ·   Verlies $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Opnamen';

  @override
  String get recentsOpenInRecordings => 'Openen in Opnamen';

  @override
  String recentsRelatedCall(String title) {
    return 'Gerelateerd gesprek: $title';
  }

  @override
  String get recentsHistoryHeader => 'Geschiedenis';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Geen gesprekken met dit nummer';

  @override
  String get recentsDeleteTitle => 'Deze gesprekken verwijderen?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verwijdert $count items voor $name.',
      one: 'Verwijdert 1 item voor $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Uit geschiedenis verwijderen';

  @override
  String get recentsCallDetails => 'Gespreksdetails';

  @override
  String get contactsFavoritesHeader => '★ Favorieten';

  @override
  String get contactsFavoritesOnly => 'Alleen favorieten';

  @override
  String get contactsShowAll => 'Alles tonen';

  @override
  String get contactsImportExportTooltip => 'Importeren en exporteren';

  @override
  String get contactsMenuDevice => 'Importeren van apparaat';

  @override
  String get contactsMenuFile => 'vCard-/CSV-bestand importeren';

  @override
  String get contactsMenuClipboard => 'Importeren van klembord';

  @override
  String get contactsMenuCopyVcard => 'Kopiëren als vCard';

  @override
  String get contactsMenuCopyCsv => 'Kopiëren als CSV';

  @override
  String get contactsNewTooltip => 'Nieuw contact';

  @override
  String get contactsSearchHint => 'Contacten zoeken';

  @override
  String get contactsEmptyTitle => 'Nog geen contacten';

  @override
  String get contactsEmptySubtitle =>
      'Voeg mensen toe die je vaak belt, of importeer een vCard- of CSV-bestand.';

  @override
  String get contactsEmptyAction => 'Contact toevoegen';

  @override
  String get contactsNoMatches => 'Geen resultaten';

  @override
  String contactsCallName(String name) {
    return '$name bellen';
  }

  @override
  String get contactsSelect => 'Selecteer een contact';

  @override
  String get contactsCopiedVcard => 'Contacten gekopieerd als vCard';

  @override
  String get contactsCopiedCsv => 'Contacten gekopieerd als CSV';

  @override
  String get contactsDeviceDenied =>
      'Toegang tot contacten is geweigerd. Sta deze toe in de systeeminstellingen om te importeren.';

  @override
  String get contactsDeviceNone => 'Geen contacten gevonden op dit apparaat';

  @override
  String contactsNothingNew(int count) {
    return 'Niets nieuws om te importeren ($count al aanwezig)';
  }

  @override
  String get contactsImportDeviceTitle => 'Importeren van apparaat?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe contacten',
      one: '1 nieuw contact',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count bijgewerkt met extra nummers';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count overgeslagen (dubbel of geen telefoonnummer)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacten geïmporteerd',
      one: '1 contact geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Geen contacten gevonden in die gegevens';

  @override
  String get contactsLabelMobile => 'mobiel';

  @override
  String get contactsLabelWork => 'werk';

  @override
  String get contactsLabelHome => 'thuis';

  @override
  String get contactsLabelOther => 'overig';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contact niet gevonden';

  @override
  String get contactsActionFavorite => 'Favoriet';

  @override
  String get contactsNumbersHeader => 'Nummers';

  @override
  String get contactsSipAddress => 'SIP-adres';

  @override
  String get contactsDetailsHeader => 'Details';

  @override
  String get contactsOnBlf => 'Getoond op het BLF-bord';

  @override
  String get contactsAlwaysRecorded => 'Gesprekken worden altijd opgenomen';

  @override
  String contactsDeleteTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String get contactsDeleteMessage =>
      'Dit contact wordt van dit apparaat verwijderd.';

  @override
  String get contactsDeleteButton => 'Contact verwijderen';

  @override
  String get contactsDetailTitle => 'Contact';

  @override
  String get contactsErrorNameOrNumber => 'Voer een naam of nummer in';

  @override
  String get contactsEditTitle => 'Contact bewerken';

  @override
  String get contactsFieldName => 'Naam';

  @override
  String get contactsFieldCompany => 'Bedrijf';

  @override
  String get contactsFieldNumber => 'Nummer';

  @override
  String get contactsRemoveNumber => 'Nummer verwijderen';

  @override
  String get contactsAddNumber => 'Nummer toevoegen';

  @override
  String get contactsSipHeader => 'SIP-adressen';

  @override
  String get contactsRemoveAddress => 'Adres verwijderen';

  @override
  String get contactsAddSip => 'SIP-adres toevoegen';

  @override
  String get contactsFieldEmail => 'E-mail';

  @override
  String get contactsFieldNotes => 'Notities';

  @override
  String get contactsFieldFavorite => 'Favoriet';

  @override
  String get contactsShowOnBlf => 'Tonen op BLF-bord';

  @override
  String get contactsShowOnBlfSub =>
      'Volg de aanwezigheid en het bezetlampje van dit toestel';

  @override
  String get contactsAlwaysRecordTitle =>
      'Gesprekken met dit contact altijd opnemen';

  @override
  String get contactsAlwaysRecordSub =>
      'Overschrijft de regels voor automatisch opnemen';

  @override
  String get contactsRingtone => 'Beltoon';

  @override
  String get contactsPresenceVia => 'Aanwezigheid via account';

  @override
  String get contactsDefaultAccount => 'Standaardaccount';

  @override
  String get contactsDeleteContactTitle => 'Contact verwijderen?';

  @override
  String get contactsCannotUndo => 'Dit kan niet ongedaan worden gemaakt.';

  @override
  String get messagesNewMessage => 'Nieuw bericht';

  @override
  String get messagesNumberOrSip => 'Nummer of SIP-adres';

  @override
  String get messagesNoConversations => 'Geen gesprekken';

  @override
  String get messagesEmptySubtitle =>
      'Stuur een SIP-bericht naar elk toestel of adres op je accounts.';

  @override
  String get messagesTyping => 'typt...';

  @override
  String get messagesYouPrefix => 'Jij: ';

  @override
  String get messagesSelect => 'Selecteer een gesprek';

  @override
  String get messagesLanOnline => 'Online op je netwerk';

  @override
  String get messagesLanOffline =>
      'Offline. Berichten worden verzonden zodra het apparaat terug is.';

  @override
  String messagesSendFileTo(String name) {
    return 'Een bestand naar $name sturen';
  }

  @override
  String messagesCallName(String name) {
    return '$name bellen';
  }

  @override
  String get messagesDeleteTitle => 'Gesprek verwijderen?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Alle berichten met $name worden verwijderd.';
  }

  @override
  String get messagesDeleteMenu => 'Gesprek verwijderen';

  @override
  String get messagesSayHello => 'Zeg hallo';

  @override
  String get messagesLanEmptySub =>
      'Berichten gaan via je netwerk rechtstreeks naar dit apparaat, end-to-end versleuteld.';

  @override
  String get messagesSipEmptySub =>
      'Berichten worden via je account verzonden met SIP MESSAGE.';

  @override
  String get messagesInputHint => 'Bericht';

  @override
  String get messagesSend => 'Verzenden';

  @override
  String get messagesStatusSending => 'Verzenden';

  @override
  String get messagesStatusSent => 'Verzonden';

  @override
  String get messagesStatusDelivered => 'Bezorgd';

  @override
  String get messagesStatusRead => 'Gelezen';

  @override
  String get messagesStatusFailed => 'Mislukt';

  @override
  String get messagesNotDelivered => 'Niet bezorgd. Tik om opnieuw te proberen';

  @override
  String get uiStatusRegistered => 'Geregistreerd';

  @override
  String get uiStatusRegistering => 'Registreren';

  @override
  String get uiStatusRegFailed => 'Registratie mislukt';

  @override
  String get uiStatusDisabled => 'Uitgeschakeld';

  @override
  String get uiQualityMeasuring => 'Meten';

  @override
  String get uiQualityExcellent => 'Uitstekend';

  @override
  String get uiQualityGood => 'Goed';

  @override
  String get uiQualityFair => 'Redelijk';

  @override
  String get uiQualityPoor => 'Matig';

  @override
  String get uiQualityBad => 'Slecht';

  @override
  String uiQualitySemantics(String label) {
    return 'Gesprekskwaliteit $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Gesprekskwaliteit $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Gesprekskwaliteit: $label';
  }

  @override
  String get uiSecureFull => 'Versleuteld';

  @override
  String get uiSecureMedia => 'Media versleuteld';

  @override
  String get uiSecureSignalling => 'Signalering versleuteld';

  @override
  String get uiSecureNone => 'Niet versleuteld';

  @override
  String get uiSecureSrtpLine => 'SRTP-media';

  @override
  String get uiSecureTlsLine => 'TLS-signalering';

  @override
  String lanCallHandingOver(String name) {
    return 'Overdragen aan $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Intercom naar $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Intercom naar een apparaat in de buurt';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Intercom van $name';
  }

  @override
  String get lanCallIntercomFromUnnamed =>
      'Intercom van een apparaat in de buurt';

  @override
  String lanCallToNamed(String name) {
    return 'LAN-gesprek naar $name';
  }

  @override
  String get lanCallToUnpaired =>
      'LAN-gesprek naar een niet-gekoppeld apparaat';

  @override
  String lanCallFromNamed(String name) {
    return 'LAN-gesprek van $name';
  }

  @override
  String get lanCallFromUnpaired =>
      'LAN-gesprek van een niet-gekoppeld apparaat';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Doorverbonden gesprek van $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Doorverbonden gesprek van $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'een ander apparaat';

  @override
  String lanRelayedTitle(String name) {
    return 'Doorgestuurd naar $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'De beller spreekt met $name. Jij zit niet in het gesprek.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '$name bellen...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'De beller blijft verbonden terwijl $name opneemt.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '$name vragen...';
  }

  @override
  String get lanRelayOfferingSubtitle =>
      'Wachten tot het gesprek wordt geaccepteerd.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Spreken met $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'De beller staat in de wacht. Voltooi de overdracht wanneer je klaar bent.';

  @override
  String get lanRelayTakingBack => 'Gesprek terugnemen...';

  @override
  String get lanRelayTakeBack => 'Terugnemen';

  @override
  String get lanRelayEnd => 'Beëindigen';

  @override
  String get lanSendToDevice => 'Naar apparaat sturen';

  @override
  String get lanBusy => 'Bezet';

  @override
  String get lanNoPairedOnline => 'Geen gekoppeld apparaat is online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name heeft het koppelen geweigerd.';
  }

  @override
  String get lanPairRejected => 'Koppelen geweigerd.';

  @override
  String get lanPairCancelled => 'Koppelen geannuleerd.';

  @override
  String get lanPairTimedOut => 'Time-out bij koppelen. Probeer het opnieuw.';

  @override
  String get lanPairFailed => 'Koppelen mislukt';

  @override
  String lanPairFailedReason(String reason) {
    return 'Koppelen mislukt: $reason';
  }

  @override
  String get lanPairThisDevice => 'dit apparaat';

  @override
  String get lanPairConnecting => 'Beveiligd verbinden...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name wil koppelen met dit apparaat.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Koppelen met $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Controleer of deze code op beide schermen hetzelfde is.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Koppelcode $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Wachten tot $name bevestigt...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name heeft bevestigd.';
  }

  @override
  String get lanPairReject => 'Weigeren';

  @override
  String get lanPairCodesMatch => 'Codes komen overeen';

  @override
  String lanPairPairedWith(String name) {
    return 'Gekoppeld met $name.';
  }

  @override
  String get lanPairRequestTitle => 'Koppelverzoek';

  @override
  String lanPairTitle(String name) {
    return 'Koppelen met $name';
  }

  @override
  String get lanActionDecline => 'Weigeren';

  @override
  String get lanActionAccept => 'Accepteren';

  @override
  String get lanFileIncomingTitle => 'Binnenkomend bestand';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size van $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Gesprek hierheen overdragen?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' van $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' op $account',
    });
    return '$device wil je een gesprek overdragen$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Er wordt eerst met je gesproken.';

  @override
  String get lanHandoffTakeCall => 'Gesprek overnemen';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Intercom van $name toestaan?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Hun gesprek wordt automatisch beantwoord via de speaker.';

  @override
  String get lanIntercomDeny => 'Weigeren';

  @override
  String get lanIntercomAllow => 'Toestaan';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name heeft dit apparaat uit de lijst met gekoppelde apparaten verwijderd';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden worden verzonden...',
      one: '$name wordt verzonden...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nieuw bericht';

  @override
  String get lanSipMessage => 'SIP-bericht';

  @override
  String get lanSipMessageSub => 'Naar een nummer of adres via je account';

  @override
  String get lanChatOnline => 'LAN-chat, online';

  @override
  String get lanChatOffline => 'LAN-chat, offline';

  @override
  String lanSavedAt(String path) {
    return 'Opgeslagen in $path (pad gekopieerd)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Je apparaten, rechtstreeks in gesprek';

  @override
  String get lanConnectByAddress => 'Verbinden via adres';

  @override
  String get lanSettingsTooltip => 'LAN-instellingen';

  @override
  String get lanOffTitle => 'LAN Link staat uit';

  @override
  String get lanOffSubtitle =>
      'Vind je andere SoftphonePro-apparaten, chat, deel bestanden en draag gesprekken over, zonder server.';

  @override
  String get lanTurnOn => 'LAN Link inschakelen';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link kon niet starten: $error';
  }

  @override
  String get lanConnectHelp =>
      'Typ host:poort of plak de tekst van de QR-code op het andere apparaat.';

  @override
  String get lanScanTitle => 'LAN-koppel-QR scannen';

  @override
  String get lanScanQr => 'QR scannen';

  @override
  String get lanPaste => 'Plakken';

  @override
  String get lanConnect => 'Verbinden';

  @override
  String lanConnectedTo(String name) {
    return 'Verbonden met $name';
  }

  @override
  String get lanCouldNotConnect => 'Verbinden mislukt';

  @override
  String get lanCouldNotStartPairing => 'Koppelen kon niet worden gestart';

  @override
  String get lanThisDevice => 'Dit apparaat';

  @override
  String get lanDeviceNameTitle => 'Apparaatnaam';

  @override
  String get lanStarting => 'Starten...';

  @override
  String get lanVisible => 'Zichtbaar op je netwerk';

  @override
  String get lanNotRunning => 'Niet actief';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts gedeeld',
      one: '1 account gedeeld',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Vingerafdruk';

  @override
  String get lanHideQr => 'QR-code verbergen';

  @override
  String get lanShowQr => 'QR-code tonen om een ander apparaat te verbinden';

  @override
  String get lanCopyConnectionText => 'Verbindingstekst kopiëren';

  @override
  String get lanConnectionTextCopied => 'Verbindingstekst gekopieerd';

  @override
  String get lanActiveOnOthers => 'Actief op je andere apparaten';

  @override
  String get lanPairedDevices => 'Gekoppelde apparaten';

  @override
  String get lanNoPaired =>
      'Nog geen gekoppelde apparaten. Koppel een apparaat in de buurt om te chatten, bestanden te sturen en gesprekken over te dragen.';

  @override
  String get lanNearby => 'In de buurt';

  @override
  String get lanNearbyHint =>
      'Zoeken naar SoftphonePro op je netwerk. Op andere apparaten moet LAN Link aan staan. Je kunt ook verbinden via adres met de linkknop hierboven.';

  @override
  String get lanTransfers => 'Overdrachten';

  @override
  String get lanFiles => 'Bestanden';

  @override
  String get lanPairedBadge => 'Gekoppeld';

  @override
  String get lanTyping => 'typt...';

  @override
  String get lanPair => 'Koppelen';

  @override
  String get lanUnpair => 'Ontkoppelen';

  @override
  String lanUnpairTitle(String name) {
    return '$name ontkoppelen?';
  }

  @override
  String get lanUnpairMessage =>
      'Je moet opnieuw koppelen om te chatten, bestanden te sturen of gesprekken over te dragen.';

  @override
  String get lanActionMessage => 'Bericht';

  @override
  String get lanActionSendFile => 'Bestand sturen';

  @override
  String get lanActionCall => 'Bellen';

  @override
  String get lanActionIntercom => 'Intercom';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Actief op $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Actief op $device  ·  $account';
  }

  @override
  String get lanPull => 'Ophalen';

  @override
  String get lanTransferPreparing => 'Voorbereiden...';

  @override
  String get lanTransferWaitingYou => 'Wacht op jou';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Wachten tot $name accepteert';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done van $total';
  }

  @override
  String get lanTransferVerifying => 'Verifiëren...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'Van $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'Naar $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  van $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  naar $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Mislukt: $error';
  }

  @override
  String get lanFileActions => 'Bestandsacties';

  @override
  String get lanPathCopied => 'Pad gekopieerd';

  @override
  String get lanFileOpen => 'Openen';

  @override
  String get lanFileShowInFolder => 'Tonen in map';

  @override
  String get lanFileCopyPath => 'Pad kopiëren';

  @override
  String lanNetworkError(String message) {
    return 'Netwerkfout: $message';
  }

  @override
  String get lanErrNotRunning => 'Schakel eerst LAN Link in';

  @override
  String get lanErrBadAddress =>
      'Voer een adres in zoals 192.168.1.20:4711 of plak de QR-codetekst';

  @override
  String get lanErrFingerprint =>
      'Dat apparaat komt niet overeen met de gescande code. Kwam de QR-code van een ander apparaat?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$file ontvangen van $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file verzonden naar $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name heeft $file geweigerd';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Bestandsoverdracht mislukt: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Schakel LAN Link in om apparaten in de buurt te bellen';

  @override
  String get lanNoticePairFirst => 'Koppel eerst met dit apparaat';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name is nu niet bereikbaar voor gesprekken';
  }

  @override
  String lanNoticeAsking(String name) {
    return '$name vragen…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name heeft intercom niet toegestaan (of antwoordde niet)';
  }

  @override
  String get lanHoOff => 'LAN Link staat uit';

  @override
  String get lanHoPairFirst => 'Koppel eerst met dat apparaat';

  @override
  String lanHoOffline(String name) {
    return '$name is offline';
  }

  @override
  String get lanHoAlready => 'Dit gesprek wordt al overgedragen';

  @override
  String get lanHoEnded => 'Het gesprek is al beëindigd';

  @override
  String get lanHoWaitConnected => 'Wacht tot het gesprek is verbonden';

  @override
  String get lanHoLanCall => 'LAN-gesprekken kunnen niet worden overgedragen';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name kan geen gesprekken via het netwerk aannemen (LAN-bellen staat daar uit)';
  }

  @override
  String get lanHoNoLanHere => 'LAN-bellen is niet beschikbaar op dit apparaat';

  @override
  String lanHoDeclined(String name) {
    return '$name heeft het gesprek geweigerd. Het blijft bij jou.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name reageerde niet. Het gesprek blijft bij jou.';
  }

  @override
  String get lanHoCancelled =>
      'De overdracht is geannuleerd. Het gesprek blijft bij jou.';

  @override
  String lanHoUnreachable(String name) {
    return '$name kon niet worden bereikt. Het gesprek blijft bij jou.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '$name kon niet worden bereikt ($reason). Het gesprek blijft bij jou.';
  }

  @override
  String get lanHoEndedBefore =>
      'Het gesprek eindigde voordat het kon worden overgedragen';

  @override
  String lanHoPbxRefused(String name) {
    return 'De telefooncentrale weigerde het doorverbinden en $name kan geen LAN-gesprekken aannemen';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Doorverbinden via de telefooncentrale mislukt. In plaats daarvan wordt het via het netwerk doorgestuurd.';

  @override
  String lanHoSentTo(String name) {
    return 'Gesprek naar $name gestuurd';
  }

  @override
  String get lanHoConsultFailed =>
      'Het andere apparaat kon niet via de telefooncentrale worden gebeld';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name is niet meer bereikbaar';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Het gesprek kon niet worden opgenomen om het over te dragen';

  @override
  String lanHoCouldNotCall(String name) {
    return '$name kon niet via het netwerk worden gebeld. Het gesprek blijft bij jou.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name nam niet op. Het gesprek blijft bij jou.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Overgedragen aan $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Gesprek doorgestuurd naar $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Wacht eerst tot $name opneemt';
  }

  @override
  String get lanHoFailed => 'Overdracht mislukt';

  @override
  String lanHoTakenBack(String name) {
    return 'Gesprek teruggenomen van $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name beëindigde het overleg. Het gesprek is weer bij jou.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Het gesprek kon niet aan $name worden overgedragen';
  }

  @override
  String get diagSip400Explain => 'De server kon het verzoek niet begrijpen.';

  @override
  String get diagSip400Fix =>
      'Controleer de accountinstellingen (domein, gebruikersnaam, proxy). Als het blijft optreden, stuur een SIP-trace naar je provider.';

  @override
  String get diagSip401Explain =>
      'De server heeft de inloggegevens afgewezen (of vraagt erom).';

  @override
  String get diagSip401Fix =>
      'Controleer de gebruikersnaam, de authenticatiegebruikersnaam en het wachtwoord. Sommige providers gebruiken een aparte \"auth-ID\".';

  @override
  String get diagSip403Explain =>
      'De server begrijpt het verzoek maar weigert het: onjuist wachtwoord, uitgeschakeld account of je IP-adres is niet toegestaan.';

  @override
  String get diagSip403Fix =>
      'Voer het wachtwoord opnieuw in, controleer of het account actief is en controleer of je openbare IP-adres niet is geblokkeerd (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'De server kent deze gebruiker of dit nummer niet.';

  @override
  String get diagSip404Fix =>
      'Controleer de gebruikersnaam en het domein; controleer bij gesprekken het gekozen nummer en de kiesregels.';

  @override
  String get diagSip405Explain => 'De server ondersteunt dit verzoek niet.';

  @override
  String get diagSip405Fix =>
      'Meestal onschuldig bij OPTIONS-pings. Controleer bij REGISTER of je met een SIP-registrar praat.';

  @override
  String get diagSip407Explain => 'De uitgaande proxy vereist inloggegevens.';

  @override
  String get diagSip407Fix =>
      'Controleer het accountwachtwoord en de instellingen van de uitgaande proxy.';

  @override
  String get diagSip408Explain => 'Geen tijdig antwoord van de server.';

  @override
  String get diagSip408Fix =>
      'Controleer het serveradres en de poort, firewalls en probeer TCP of TLS. Herhaalde time-outs alleen via UDP kunnen wijzen op SIP ALG op de router.';

  @override
  String get diagSip410Explain => 'Het nummer bestaat niet meer.';

  @override
  String get diagSip410Fix => 'Controleer het gekozen nummer.';

  @override
  String get diagSip415Explain =>
      'De andere kant accepteert het aangeboden inhoudstype of de aangeboden codecs niet.';

  @override
  String get diagSip415Fix =>
      'Schakel meer codecs in (bijv. PCMU/PCMA) via Instellingen > Codecs.';

  @override
  String get diagSip421Explain =>
      'De server vereist een SIP-extensie die deze client niet heeft aangeboden.';

  @override
  String get diagSip421Fix =>
      'Controleer de opties voor NAT/ICE/100rel/timers van het account.';

  @override
  String get diagSip423Explain =>
      'De verlooptijd van de registratie is korter dan de server toestaat.';

  @override
  String get diagSip423Fix =>
      'Verhoog de verlooptijd van de registratie in de accountinstellingen.';

  @override
  String get diagSip480Explain =>
      'De gebruiker is niet geregistreerd of is nu niet bereikbaar.';

  @override
  String get diagSip480Fix =>
      'Controleer of de andere partij is geregistreerd; bij registratie kan de server overbelast zijn: probeer het later opnieuw.';

  @override
  String get diagSip481Explain =>
      'De server is de dialoogstatus kwijtgeraakt (bijv. na een herstart of netwerkwijziging).';

  @override
  String get diagSip481Fix =>
      'Hang op en probeer het opnieuw. Schakel sessietimers in als het vaak gebeurt.';

  @override
  String get diagSip483Explain => 'Het verzoek liep rond tussen servers.';

  @override
  String get diagSip483Fix =>
      'Controleer de configuratie voor doorschakelen en routering op de telefooncentrale.';

  @override
  String get diagSip484Explain => 'Het gekozen nummer is te kort.';

  @override
  String get diagSip484Fix =>
      'Kies het volledige nummer of controleer de kiesregels.';

  @override
  String get diagSip486Explain => 'De andere partij is bezet.';

  @override
  String get diagSip486Fix => 'Probeer het later opnieuw.';

  @override
  String get diagSip487Explain =>
      'Het gesprek werd geannuleerd voordat het werd opgenomen.';

  @override
  String get diagSip487Fix =>
      'Normaal wanneer de beller ophangt terwijl het overgaat.';

  @override
  String get diagSip488Explain =>
      'Geen gemeenschappelijke codec of versleutelingsinstelling met de andere kant.';

  @override
  String get diagSip488Fix =>
      'Controleer codecs en SRTP (een account met verplichte SRTP kan geen eindpunt met gewone RTP bellen).';

  @override
  String get diagSip491Explain =>
      'Twee re-INVITEs kwamen met elkaar in conflict.';

  @override
  String get diagSip491Fix => 'Wordt normaal automatisch opnieuw geprobeerd.';

  @override
  String get diagSip500Explain => 'De server is intern mislukt.';

  @override
  String get diagSip500Fix =>
      'Probeer het later opnieuw en neem contact op met de provider als het aanhoudt.';

  @override
  String get diagSip502Explain =>
      'Een upstream-server gaf een ongeldig antwoord.';

  @override
  String get diagSip502Fix =>
      'Probeer het later opnieuw; neem contact op met de provider als het aanhoudt.';

  @override
  String get diagSip503Explain =>
      'De server is overbelast, buiten gebruik of weigert deze client (aanvraaglimiet).';

  @override
  String get diagSip503Fix =>
      'Wacht en probeer opnieuw, bekijk de statuspagina van de provider of probeer een andere server/poort.';

  @override
  String get diagSip504Explain =>
      'Een upstream-server antwoordde niet op tijd.';

  @override
  String get diagSip504Fix => 'Probeer het later opnieuw.';

  @override
  String get diagSip600Explain => 'Alle bestemmingen zijn bezet.';

  @override
  String get diagSip600Fix => 'Probeer het later opnieuw.';

  @override
  String get diagSip603Explain =>
      'De andere partij heeft het gesprek geweigerd.';

  @override
  String get diagSip603Fix => 'Niets op te lossen: het gesprek is geweigerd.';

  @override
  String get diagSip604Explain => 'Het nummer bestaat niet.';

  @override
  String get diagSip604Fix => 'Controleer het gekozen nummer.';

  @override
  String get diagSip606Explain =>
      'De andere partij kan de sessie niet accepteren zoals aangeboden.';

  @override
  String get diagSip606Fix =>
      'Controleer de codec- en versleutelingsinstellingen.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Voorlopig ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'Het verzoek wordt verwerkt.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Gelukt ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'Het verzoek is gelukt.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Omgeleid ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'De bestemming is verplaatst.';

  @override
  String get diagSipRedirectedFix =>
      'Controleer de instellingen voor doorschakelen.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Clientfout ($code)';
  }

  @override
  String get diagSipClientErrorExplain =>
      'De server heeft het verzoek geweigerd.';

  @override
  String get diagSipClientErrorFix =>
      'Controleer het account en het gekozen nummer.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Serverfout ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'De server kon het verzoek niet verwerken.';

  @override
  String get diagSipServerErrorFix =>
      'Probeer het later opnieuw of neem contact op met de provider.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Algemene storing ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'Het verzoek kan nergens worden uitgevoerd.';

  @override
  String get diagSipNoResponseTitle => 'Geen respons';

  @override
  String get diagSipNoResponseExplain => 'Er is geen SIP-respons ontvangen.';

  @override
  String get diagSipNoResponseFix =>
      'Controleer de netwerkverbinding en het serveradres.';

  @override
  String get diagWizStepNet => 'Netwerkverbinding';

  @override
  String diagWizStepDns(String account) {
    return 'DNS en SRV: $account';
  }

  @override
  String get diagWizStepNat => 'NAT-type';

  @override
  String diagWizStepOptions(String account) {
    return 'Bereikbaarheid van server: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS-certificaat: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registratie: $account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALG-controle';

  @override
  String get diagWizChecking => 'Controleren...';

  @override
  String diagWizEngineError(String message) {
    return 'Enginefout: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Controle mislukt: $error';
  }

  @override
  String get diagWizNoEngine => 'De SIP-engine draait niet';

  @override
  String get diagWizNoEngineFix =>
      'Wacht tot de engine is gestart (of start de app opnieuw) en voer de controles daarna opnieuw uit.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privé)';
  }

  @override
  String get diagWizNetNone => 'Geen actieve netwerkinterface met een IP-adres';

  @override
  String get diagWizNetNoneFix =>
      'Maak verbinding met wifi, ethernet of mobiele data en voer de controles daarna opnieuw uit.';

  @override
  String get diagWizNetIpv6Only => 'Alleen IPv6-adressen gevonden';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Veel SIP-providers ondersteunen alleen IPv4. Schakel IPv4 in op dit netwerk of gebruik een provider met IPv6-ondersteuning.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 IPv4-adressen',
      one: '1 IPv4-adres',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interface',
    );
    return '$_temp0 op $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Er is een VPN-achtige interface actief. VPN\'s kunnen vertraging toevoegen of UDP blokkeren; schakel de VPN uit als gesprekken slecht werken.';

  @override
  String get diagWizDnsNoServer => 'Het account heeft geen serveradres';

  @override
  String get diagWizDnsNoServerFix =>
      'Bewerk het account en voer het SIP-domein in.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host is een IP-adres, DNS is niet nodig';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: geen';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: geen ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: geen';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (prioriteit $priority, gewicht $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: opzoeken mislukt ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host wordt niet omgezet';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Controleer het domein op typfouten en of je DNS-server werkt. Je kunt een eigen DNS-server instellen via Instellingen > Netwerk (bijv. 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host heeft SRV-records maar geen adresrecord';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'SRV-doelen worden gebruikt. Als gesprekken mislukken, vraag de provider het A-record te controleren.';

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
      other: ', $srv SRV-records',
      one: ', 1 SRV-record',
      zero: '',
    );
    return '$host wordt omgezet naar $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Time-out bij NAT-detectie';

  @override
  String get diagWizNatTimeoutFix =>
      'De STUN-server is mogelijk onbereikbaar (UDP geblokkeerd?). Controleer Instellingen > Netwerk > STUN-servers.';

  @override
  String diagWizNatStun(String server) {
    return 'STUN-server: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Geen NAT: dit apparaat heeft een openbaar adres';

  @override
  String get diagWizNatFullCone => 'Full cone NAT: VoIP-vriendelijk';

  @override
  String get diagWizNatRestricted =>
      'Restricted cone NAT: werkt met STUN en keep-alives';

  @override
  String get diagWizNatPortRestricted =>
      'Port-restricted cone NAT: werkt met STUN en keep-alives';

  @override
  String get diagWizNatSymmetric =>
      'Symmetrische NAT: STUN alleen kan de mediapoort niet voorspellen';

  @override
  String get diagWizNatSymmetricFix =>
      'Bij sommige gesprekken is eenrichtingsaudio of geen audio waarschijnlijk. Schakel ICE en een TURN-relay in bij de accountinstellingen (Account > NAT) of gebruik een provider/centrale met mediarelay (rtpengine).';

  @override
  String get diagWizNatBlocked => 'UDP lijkt geblokkeerd';

  @override
  String get diagWizNatBlockedFix =>
      'Gebruik TCP- of TLS-transport voor het account. Als het netwerk alles behalve webverkeer filtert, probeer dan TLS op poort 443 als je provider dat ondersteunt.';

  @override
  String get diagWizNatUnknown => 'NAT-type kon niet worden bepaald';

  @override
  String get diagWizNatUnknownFix =>
      'De STUN-server antwoordde niet. Probeer een andere STUN-server in Instellingen > Netwerk.';

  @override
  String get diagWizNatErr =>
      'De STUN-server antwoordde niet, dus het NAT-type kon niet worden bepaald.';

  @override
  String get diagWizNatUnknownRaw => 'Het NAT-type kon niet worden bepaald.';

  @override
  String get diagWizOptionsNotLoaded =>
      'Het account is niet geladen in de engine';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Geen antwoord op OPTIONS binnen $seconds s (transport: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'De server is niet bereikbaar. Controleer het adres en de poort, of een firewall SIP niet blokkeert, en probeer een ander transport (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Time-out van verzoek ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Server antwoordde $code $reason na $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Server antwoordde $code $reason in $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Een $code op OPTIONS is normaal: de server is bereikbaar maar staat geen anonieme tests toe.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Een retourtijd boven 300 ms zorgt voor merkbare vertraging in gesprekken. Een dichterbij gelegen server of een bedrade verbinding helpt.';

  @override
  String get diagWizTlsRejected => 'Het servercertificaat is afgewezen';

  @override
  String diagWizTlsSubject(String value) {
    return 'Onderwerp: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Uitgever: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problemen: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Verloopt: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cipher: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Als dit je eigen telefooncentrale is met een zelfondertekend certificaat en de vingerafdruk hierboven overeenkomt, kun je het vertrouwen. Vraag anders de provider om een certificaat van een openbare CA.';

  @override
  String get diagWizTlsTrust => 'Dit certificaat vertrouwen';

  @override
  String diagWizTlsExpired(String date) {
    return 'Het certificaat is verlopen op $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Vraag de serverbeheerder het certificaat te vernieuwen.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Het certificaat verloopt over $days dagen',
      one: 'Het certificaat verloopt over 1 dag',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Vraag de serverbeheerder het binnenkort te vernieuwen.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Verbonden, maar verificatie meldde: $problems';
  }

  @override
  String get diagWizTlsOk =>
      'TLS-verbinding tot stand gebracht, certificaat geldig';

  @override
  String get diagWizTlsRegistered =>
      'Geregistreerd via TLS (geen certificaatdetails gemeld)';

  @override
  String get diagWizTlsNone => 'Er is nog geen TLS-verbinding waargenomen';

  @override
  String get diagWizTlsNoneFix =>
      'Controleer de TLS-poort (meestal 5061) en of de server TLS 1.2 of nieuwer accepteert.';

  @override
  String get diagWizRegDisabledByConfig =>
      'Registratie is uitgeschakeld voor dit account (peer-to-peer-gebruik)';

  @override
  String get diagWizRegRegistered => 'Geregistreerd';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Geregistreerd (verloopt over $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transport: $transport';
  }

  @override
  String get diagWizRegInProgress => 'Registratie is nog bezig';

  @override
  String get diagWizRegInProgressFix =>
      'Wacht een paar seconden. Als het nooit voltooid wordt, antwoordt de server niet; zie de bereikbaarheidscontrole hierboven.';

  @override
  String get diagWizRegFailed => 'Registratie mislukt';

  @override
  String get diagWizRegOffline => 'Het account is offline';

  @override
  String get diagWizRegOfflineFix =>
      'Controleer de netwerkverbinding. De app probeert het automatisch opnieuw.';

  @override
  String get diagWizRegDisabled => 'Het account is uitgeschakeld';

  @override
  String get diagWizAlgNoUdp =>
      'Geen enkel account gebruikt UDP, dus SIP ALG is geen probleem';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: geen antwoord via UDP, maar TCP antwoordde ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: geen antwoord via UDP of TCP (probleem met server of firewall in plaats van ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS wordt beantwoord maar REGISTER loopt op een time-out, wat typisch is voor een router die SIP herschrijft';
  }

  @override
  String get diagWizAlgSuspected => 'SIP ALG vermoed op je router';

  @override
  String get diagWizAlgSuspectedFix =>
      'Schakel \"SIP ALG\" / \"SIP helper\" uit in de routerinstellingen, schakel het account over naar TCP of TLS, of wijzig de SIP-poort (bijv. 5080) zodat de router pakketten niet meer verminkt.';

  @override
  String get diagWizAlgContactChanged =>
      'Het Contact-adres is gewijzigd tussen verzoek en antwoord';

  @override
  String get diagWizAlgContactChangedFix =>
      'Dit kan een SIP ALG zijn of een server die contacten herschrijft. Als gesprekken overgaan maar geen audio hebben of na een tijdje wegvallen, schakel dan SIP ALG op de router uit of gebruik TCP/TLS of poort 5080.';

  @override
  String get diagWizAlgOk => 'Geen teken van SIP ALG-interferentie';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER-Contact $sent kwam terug als $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '$fileName opslaan';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName opgeslagen';
  }

  @override
  String get diagSaveFailed => 'Het bestand kon niet worden opgeslagen';

  @override
  String get diagCopiedText => 'Tekst naar het klembord gekopieerd';

  @override
  String get diagCopiedReport => 'Rapport naar het klembord gekopieerd';

  @override
  String get diagCopiedBundle => 'Diagnosepakket naar het klembord gekopieerd';

  @override
  String get diagCopiedLogs => 'Logs naar het klembord gekopieerd';

  @override
  String get diagCopiedTrace => 'Trace naar het klembord gekopieerd';

  @override
  String get diagCopiedDialog => 'Dialoog naar het klembord gekopieerd';

  @override
  String get diagSaveAsLog => 'Opslaan als .log';

  @override
  String get diagSysAppVersion => 'App-versie';

  @override
  String get diagSysPlatform => 'Platform';

  @override
  String get diagSysEngine => 'Engine';

  @override
  String get diagSysAccounts => 'Accounts';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered van $total geregistreerd';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Systeeminformatie kon niet worden gelezen: $error';
  }

  @override
  String get diagSysTransports => 'Transporten';

  @override
  String get diagSysNoneReported => 'Geen gemeld';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter =>
      'Ingeschakelde codecs, hoogste prioriteit eerst.';

  @override
  String get diagSysEngineNotRunning => 'Engine draait niet';

  @override
  String diagSysCodecPriority(int priority) {
    return 'prioriteit $priority';
  }

  @override
  String get diagSysCodecDisabled => 'uitgeschakeld';

  @override
  String get diagSysExport => 'Exporteren';

  @override
  String get diagSysExportFooter =>
      'Het pakket bevat systeeminformatie, resultaten van netwerkcontroles, recente logs en de SIP-trace, met onkenbaar gemaakte inloggegevens.';

  @override
  String get diagSysCopyBundle => 'Diagnosepakket kopiëren';

  @override
  String get diagSysSaveBundle => 'Diagnosepakket opslaan';

  @override
  String get diagTabSipTrace => 'SIP-trace';

  @override
  String get diagTabNetwork => 'Netwerk';

  @override
  String get diagTabQuality => 'Kwaliteit';

  @override
  String get diagTabAudioTest => 'Audiotest';

  @override
  String get diagTabLogs => 'Logs';

  @override
  String get diagTabSystem => 'Systeem';

  @override
  String diagRawSentTo(String remote) {
    return 'verzonden naar $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'ontvangen van $remote';
  }

  @override
  String get diagRawCopied => 'Bericht gekopieerd';

  @override
  String get diagRawLadder => 'Ladder';

  @override
  String get diagRawRedact => 'Inloggegevens maskeren';

  @override
  String diagRawTruncated(int count) {
    return '... afgekapt ($count tekens)';
  }

  @override
  String get diagWizIntro =>
      'Controleert je verbinding, DNS, NAT, bereikbaarheid van de server, TLS en registratie, en legt uit wat je moet oplossen.';

  @override
  String get diagWizStop => 'Stoppen';

  @override
  String get diagWizRunChecks => 'Controles uitvoeren';

  @override
  String get diagWizRunAgain => 'Opnieuw uitvoeren';

  @override
  String get diagWizCopyReport => 'Rapport kopiëren';

  @override
  String get diagWizSaveReport => 'Rapport opslaan';

  @override
  String diagWizCountPassed(int count) {
    return 'Geslaagd $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Waarschuwingen $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Mislukt $count';
  }

  @override
  String get diagWizStatusPass => 'Geslaagd';

  @override
  String get diagWizStatusWarn => 'Waarschuwing';

  @override
  String get diagWizStatusFail => 'Mislukt';

  @override
  String get diagWizStatusSkipped => 'Overgeslagen';

  @override
  String get diagWizStatusRunning => 'Bezig';

  @override
  String get diagWizStatusPending => 'In afwachting';

  @override
  String get diagQualityTitle => 'Gesprekskwaliteit';

  @override
  String get diagQualityNoData =>
      'Voor dit gesprek zijn geen kwaliteitsgegevens vastgelegd.';

  @override
  String get diagQualityTraceForCall => 'SIP-trace voor dit gesprek';

  @override
  String get diagQualityTraceNotCaptured =>
      'SIP-trace niet vastgelegd voor dit gesprek';

  @override
  String get diagQualityLiveCall => 'Live gesprek';

  @override
  String get diagQualityNoActiveCall =>
      'Geen actief gesprek. Start een gesprek en MOS, jitter, verlies en retourtijd worden hier live weergegeven.';

  @override
  String get diagQualityRecentCalls => 'Recente gesprekken';

  @override
  String get diagQualityNoFinished =>
      'Nog geen beëindigde gesprekken met kwaliteitsgegevens.';

  @override
  String get diagQualityCallEnded => 'Het gesprek is beëindigd.';

  @override
  String get diagQualityMeasuring => 'meten';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Grafiek $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Grafiek $title, laatste $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   max $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Gemiddeld $avg  ·  slechtste $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Verlies';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count pakketten';
  }

  @override
  String get diagQualityMedia => 'Media';

  @override
  String get diagQualityNoSeries =>
      'Voor dit gesprek is geen tijdreeks vastgelegd.';

  @override
  String get diagQualityPacketLoss => 'Pakketverlies';

  @override
  String get diagQualityRtt => 'Retourtijd';

  @override
  String get diagLogsForward => 'Enginelogs doorsturen';

  @override
  String get diagLogsForwardSub => 'pjsip-logregels naar deze viewer sturen';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Niveau $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Maskeren bij exporteren';

  @override
  String get diagLogsSearch => 'Logs doorzoeken';

  @override
  String get diagLogsEmpty => 'Nog geen logregels.';

  @override
  String get diagLogsForwardingOff =>
      'Logdoorsturing staat uit. Schakel in om enginelogs vast te leggen.';

  @override
  String get diagLogsNoMatch =>
      'Geen regels komen overeen met de zoekopdracht.';

  @override
  String get diagAudioEngineNotRunning => 'De SIP-engine draait niet.';

  @override
  String get diagAudioMicrophone => 'Microfoon';

  @override
  String get diagAudioMicFooter =>
      'De niveaumeter leest het audioapparaat dat de engine opent tijdens een gesprek of de echotest.';

  @override
  String get diagAudioLevelMeter => 'Niveaumeter';

  @override
  String get diagAudioLevelMeterSub => 'Spreek en kijk hoe de balk beweegt';

  @override
  String get diagAudioMic => 'Microfoon';

  @override
  String get diagAudioSpeaker => 'Luidspreker';

  @override
  String get diagAudioEchoTest => 'Echotest';

  @override
  String get diagAudioEchoFooter =>
      'Speelt je stem terug via de luidspreker. Gebruik een koptelefoon om rondzingen te voorkomen.';

  @override
  String get diagAudioEchoActive => 'Actief: spreek nu';

  @override
  String get diagAudioEchoIdle => 'Microfoon naar luidspreker teruglussen';

  @override
  String get diagAudioSpeakerTest => 'Luidsprekertest';

  @override
  String get diagAudioPlayTone => 'Testtoon afspelen';

  @override
  String get diagAudioPlayToneSub =>
      'Wordt afgespeeld via de geselecteerde luidspreker';

  @override
  String get diagAudioPlayingDtmf => 'DTMF wordt afgespeeld';

  @override
  String get diagAudioPlayingRingback => 'Wachttoon wordt afgespeeld';

  @override
  String get diagAudioRingback => 'Wachttoon';

  @override
  String get diagAudioDevices => 'Apparaten';

  @override
  String get diagAudioChooseDevices => 'Kies microfoon en luidspreker';

  @override
  String get diagAudioChooseDevicesSub => 'Opent Instellingen > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label-niveau $percent procent';
  }

  @override
  String get diagLadderLocal => 'Lokaal';

  @override
  String diagLadderSent(String message) {
    return '$message verzonden';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message ontvangen';
  }

  @override
  String get diagTraceCapture => 'SIP-berichten vastleggen';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$_temp0  ·  $size  ·  $dropped oudere verwijderd';
  }

  @override
  String get diagTraceOffHint => 'Uit. Schakel in en registreer of bel daarna.';

  @override
  String get diagTraceExportOrClear => 'Exporteren of wissen';

  @override
  String get diagTraceSaveAsPcap => 'Opslaan als .pcap';

  @override
  String get diagTraceCopyAsText => 'Kopiëren als tekst';

  @override
  String get diagTraceSearchHint => 'Zoek tekst, nummer of Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Alleen fouten';

  @override
  String get diagTraceFilterMethod => 'Filteren op methode';

  @override
  String get diagTraceAllMethods => 'Alle methoden';

  @override
  String get diagTraceMethod => 'Methode';

  @override
  String get diagTraceFilterAccount => 'Filteren op account';

  @override
  String get diagTraceAllAccounts => 'Alle accounts';

  @override
  String get diagTraceAccount => 'Account';

  @override
  String get diagTraceRedact => 'Maskeren';

  @override
  String get diagTraceList => 'Lijst';

  @override
  String get diagTraceWaiting => 'Wachten op SIP-verkeer';

  @override
  String get diagTraceWaitingSub =>
      'Registreer een account of bel, dan verschijnen de berichten hier.';

  @override
  String get diagTraceOff => 'SIP-trace staat uit';

  @override
  String get diagTraceOffSub =>
      'Schakel vastleggen in om elk SIP-verzoek en elke respons te zien, als lijst of ladderdiagram.';

  @override
  String get diagTraceNoMatch => 'Geen berichten komen overeen met de filters';

  @override
  String get diagTraceAllDialogs => 'Alle dialogen';

  @override
  String get diagTraceCopyDialog => 'Deze dialoog kopiëren';

  @override
  String get diagTraceNoResponse => 'geen respons';

  @override
  String get diagTraceNoCallId => 'geen Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Opname';

  @override
  String get recFormatWav => 'Standaard (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stereo, jij en de beller op aparte kanalen (WAV)';

  @override
  String get recFormatOpus => 'Gecomprimeerd (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, ongeveer 2 MB per minuut. Speelt overal af.';

  @override
  String get recFormatWavStereoHint =>
      'Twee kanalen, ongeveer 4 MB per minuut. Jij links, de beller rechts.';

  @override
  String get recFormatOpusHint =>
      'Ongeveer 0,2 MB per minuut. Ogg Opus; sommige spelers op iPhone, Mac en Windows kunnen het niet openen.';

  @override
  String get recOptionInherit => 'Globale instelling gebruiken';

  @override
  String get recOptionAlways => 'Alle gesprekken opnemen';

  @override
  String get recOptionIncoming => 'Alleen inkomende gesprekken opnemen';

  @override
  String get recOptionOutgoing => 'Alleen uitgaande gesprekken opnemen';

  @override
  String get recOptionNever => 'Nooit opnemen';

  @override
  String get recRuleAll => 'Alle gesprekken';

  @override
  String get recRuleIncoming => 'Alleen inkomende gesprekken';

  @override
  String get recRuleOutgoing => 'Alleen uitgaande gesprekken';

  @override
  String get recAutoDeleteNever => 'Nooit';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Na $days dagen',
      one: 'Na 1 dag',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Na 1 jaar';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opnamen',
      one: '1 opname',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opnamen',
      one: '1 opname',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opnamen',
      one: '1 opname',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dagen',
      one: '1 dag',
    );
    return '$_temp0  ·  $size  ·  automatisch verwijderen na $_temp1';
  }

  @override
  String get recSettingsFormat => 'Indeling';

  @override
  String get recSettingsAutoGroup => 'Automatisch opnemen';

  @override
  String get recSettingsAutoFooter =>
      'Controleer de lokale wetgeving voordat je gesprekken opneemt. Schakel \"Gesprekken met dit contact altijd opnemen\" in bij een contact om gesprekken op te nemen ongeacht deze regels.';

  @override
  String get recSettingsAutoRule => 'Gesprekken automatisch opnemen';

  @override
  String get recSettingsAccountOverride => 'Overschrijven voor dit account';

  @override
  String get recSettingsNoticesGroup => 'Meldingen';

  @override
  String get recSettingsNoticeSwitch => 'Een melding afspelen voor het opnemen';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Speelt eerst een melding af aan de andere partij. Het meldingsbestand kies je in Instellingen > Gesprekken > Aankondigingen.';

  @override
  String get recSettingsNoticeFile => 'Kies het meldingsbestand';

  @override
  String get recSettingsNoticeFileHint =>
      'Opent Instellingen > Gesprekken > Aankondigingen';

  @override
  String get recSettingsBeep => 'Opnametoon';

  @override
  String get recSettingsBeepHint => 'De andere partij regelmatig waarschuwen';

  @override
  String get recSettingsTransfersGroup => 'Doorverbindingen';

  @override
  String get recSettingsContinue => 'Opname voortzetten bij doorverbinden';

  @override
  String get recSettingsContinueHint =>
      'Het overlegsgesprek bij begeleid doorverbinden en het gesprek dat ons wordt doorverbonden opnemen, en de opnamen koppelen';

  @override
  String get recSettingsStorageGroup => 'Opslag';

  @override
  String get recSettingsFolder => 'Map';

  @override
  String get recSettingsFolderHint => 'Waar opnamen worden opgeslagen';

  @override
  String get recSettingsFolderPlaceholder => 'App-documenten / Opnamen';

  @override
  String get recSettingsChooseFolder => 'Map kiezen...';

  @override
  String get recSettingsFolderPickerTitle => 'Opnamemap';

  @override
  String get recSettingsAutoDelete => 'Oude opnamen verwijderen';

  @override
  String get recSettingsAutoDeleteHint =>
      'Gecontroleerd bij het opstarten en eenmaal per dag';

  @override
  String get recSettingsManage => 'Opnamen beheren';

  @override
  String get recSettingsOpenFolder => 'Opnamemap openen';

  @override
  String get recPageTitle => 'Opnamen';

  @override
  String recSelectedCount(int count) {
    return '$count geselecteerd';
  }

  @override
  String get recCancelSelection => 'Selectie annuleren';

  @override
  String get recSelectAll => 'Alles selecteren';

  @override
  String get recShareSelected => 'Selectie delen';

  @override
  String get recDeleteSelected => 'Selectie verwijderen';

  @override
  String get recSearchTooltip => 'Opnamen doorzoeken';

  @override
  String get recSelectTooltip => 'Opnamen selecteren';

  @override
  String get recMenuSettings => 'Opname-instellingen';

  @override
  String get recSearchHint => 'Zoek op naam of nummer';

  @override
  String get recEmptyNone => 'Nog geen opnamen';

  @override
  String get recEmptyNoneHint =>
      'Neem een gesprek op met de knop Opnemen of schakel automatisch opnemen in via Instellingen.';

  @override
  String get recEmptyNoMatch => 'Geen overeenkomende opnamen';

  @override
  String get recEmptyNoMatchHint =>
      'Probeer een andere zoekopdracht of een ander filter.';

  @override
  String get recClearFilters => 'Filters wissen';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opnamen verwijderen?',
      one: '1 opname verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'De audiobestanden worden van dit apparaat verwijderd. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get recDeleteOneTitle => 'Deze opname verwijderen?';

  @override
  String get recDeleteOneMessage =>
      'Het audiobestand wordt van dit apparaat verwijderd. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get recFilterAll => 'Alle';

  @override
  String get recFilterIncoming => 'Inkomend';

  @override
  String get recFilterOutgoing => 'Uitgaand';

  @override
  String get recFilterByAccount => 'Filteren op account';

  @override
  String get recFilterAllAccounts => 'Alle accounts';

  @override
  String get recFilterAccountFallback => 'Account';

  @override
  String get recFilterAnyDate => 'Elke datum';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Datums wissen';

  @override
  String get recMissingFile => 'Het audiobestand ontbreekt op dit apparaat.';

  @override
  String recRelated(String title) {
    return 'Gerelateerd: $title';
  }

  @override
  String get recRenameTitle => 'Opname hernoemen';

  @override
  String get recRenameHint => 'Naam';

  @override
  String get recSaveAs => 'Opslaan als...';

  @override
  String get recShowInFinder => 'Tonen in Finder';

  @override
  String get recShowInFolder => 'Tonen in map';

  @override
  String get recViewCall => 'Gesprek bekijken';

  @override
  String recSavedTo(String path) {
    return 'Opgeslagen in $path';
  }

  @override
  String get recSaveFailed => 'De opname kon niet worden opgeslagen';

  @override
  String get recShareFailed => 'De opname kon niet worden gedeeld';

  @override
  String get recSaveDialogTitle => 'Opname opslaan';

  @override
  String get recShareSubject => 'Gespreksopnamen';

  @override
  String get recPlayerUnsupported =>
      'Dit apparaat kan Opus-opnamen hier niet afspelen.';

  @override
  String get recPlayerOpenWith => 'Openen met...';

  @override
  String get recPlayerNotFound => 'Het opnamebestand is niet gevonden';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Deze opname kan niet worden afgespeeld: $error';
  }

  @override
  String get recPlayerPlay => 'Opname afspelen';

  @override
  String get recPlayerPause => 'Opname pauzeren';

  @override
  String get audioFilesTitle => 'Audiobestanden';

  @override
  String audioAdded(String name) {
    return '\"$name\" toegevoegd';
  }

  @override
  String get audioFileUnavailable => 'Dat bestand is niet beschikbaar.';

  @override
  String get audioNameRequired => 'Voer een naam in';

  @override
  String audioDeleteTitle(String name) {
    return '\"$name\" verwijderen?';
  }

  @override
  String get audioDeleteMessage =>
      'Instellingen die dit bestand gebruiken, gaan terug naar de standaard.';

  @override
  String get audioGroupAdd => 'Toevoegen';

  @override
  String get audioAddFooter =>
      'WAV-bestanden (PCM, mu-law, A-law) en MP3-bestanden werken. Bestanden worden naar de app gekopieerd, dus het origineel mag worden verplaatst.';

  @override
  String get audioImport => 'Een WAV of MP3 importeren…';

  @override
  String get audioGroupMine => 'Mijn bestanden';

  @override
  String get audioEmptyTitle => 'Nog geen bestanden';

  @override
  String get audioEmptyHint =>
      'Importeer een bestand of neem je eigen aankondiging op.';

  @override
  String get audioGroupBuiltIn => 'Ingebouwd';

  @override
  String get audioBuiltInFooter =>
      'Gemaakt voor SoftphonePro, vrij te gebruiken.';

  @override
  String get audioPreviewStop => 'Voorbeeld stoppen';

  @override
  String audioPreviewPlay(String name) {
    return 'Voorbeeld van $name';
  }

  @override
  String get audioRecordedName => 'Geef deze opname een naam';

  @override
  String get audioRecordedDefaultName => 'Mijn aankondiging';

  @override
  String audioSaved(String name) {
    return '\"$name\" opgeslagen';
  }

  @override
  String get audioRecorderStop => 'Stoppen';

  @override
  String get audioRecorderPlay => 'Opname afspelen';

  @override
  String audioRecorderNew(String duration) {
    return 'Nieuwe opname  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Negeren';

  @override
  String get audioRecordOwn => 'Eigen opname maken…';

  @override
  String get audioRecordOwnHint =>
      'Gebruikt de microfoon die is geselecteerd in de audio-instellingen';

  @override
  String get audioMissingFile => 'Ontbrekend bestand';

  @override
  String get audioBuiltInCalm => 'Rustig (ingebouwd)';

  @override
  String get audioBuiltInBreeze => 'Briesje (ingebouwd)';

  @override
  String get audioBuiltInChime => 'Meldingsgeluid (ingebouwd)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Alleen WAV- en MP3-bestanden kunnen worden gebruikt.';

  @override
  String get audioErrNotFound => 'Dat bestand is niet gevonden.';

  @override
  String get audioErrNotSaved => 'De opname is niet opgeslagen.';

  @override
  String get audioErrEmpty => 'Dit audiobestand is leeg of onleesbaar.';

  @override
  String audioErrUnusable(String reason) {
    return 'Dit audiobestand kan niet worden gebruikt ($reason). Gebruik PCM-, mu-law- of A-law-WAV, of MP3.';
  }

  @override
  String get audioRecEngineOff => 'De gespreksengine draait niet.';

  @override
  String get audioRecUnsupported =>
      'Deze versie van de gespreksengine kan de microfoon niet opnemen.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Opname kon niet worden gestart: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Opname mislukt: $reason';
  }

  @override
  String get audioStrengthLow => 'Laag';

  @override
  String get audioStrengthMedium => 'Gemiddeld';

  @override
  String get audioStrengthHigh => 'Hoog';

  @override
  String get audioStrengthMax => 'Max';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Systeemstandaard';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Systeemstandaard ($name)';
  }

  @override
  String get voiceTitle => 'Stemisolatie';

  @override
  String get voiceUnavailable =>
      'AI-ruisonderdrukking is niet beschikbaar in deze build van de gespreksengine. De standaard ruisonderdrukking onder Verwerking werkt nog wel.';

  @override
  String get voiceGroupAi => 'AI-ruisonderdrukking';

  @override
  String get voiceAiFooter =>
      'Verwijdert toetsenbordgeklik, ventilatoren en achtergrondstemmen uit het gesprek met een neuraal netwerk op het apparaat (RNNoise). Er verlaat niets je apparaat. Een hogere sterkte verwijdert meer ruis, maar kan het begin van woorden afknippen.';

  @override
  String get voiceMic => 'Mijn microfoon';

  @override
  String get voiceMicHint => 'Verbeter wat de ander hoort';

  @override
  String get voiceOthers => 'Andere deelnemers';

  @override
  String get voiceOthersHint => 'Verbeter de storende beller die je hoort';

  @override
  String voiceStrength(String value) {
    return 'Sterkte: $value';
  }

  @override
  String get voiceGroupTry => 'Uitproberen';

  @override
  String get voiceTryFooter =>
      'Gebruik een koptelefoon voor de echotest, anders hoor je rondzingen.';

  @override
  String get voiceEchoTest => 'Testen met echo';

  @override
  String get voiceEchoTestHint => 'Speelt je verwerkte microfoon naar je terug';

  @override
  String get voiceEchoFailed => 'Echotest mislukt';

  @override
  String get voiceGroupSystem => 'Systeem';

  @override
  String get voiceSystemFooter =>
      'macOS en iOS kunnen je stem ook voor elke app isoleren. Kies Stemisolatie in de systeemmicrofoonmodus.';

  @override
  String get voiceSystemMode => 'Systeemmicrofoonmodus (Stemisolatie)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Microfoonmodi vereisen macOS 12 of iOS 15 of nieuwer.';

  @override
  String get voiceSpeechDetection => 'Spraakdetectie';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent procent';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Android-audio-effecten';

  @override
  String get voiceAndroidFooter =>
      'De telefoon kan de microfoon ook zelf verbeteren. Deze worden door Android gemeld en staan los van de instelling hierboven.';

  @override
  String get voiceAndroidNs => 'Ruisonderdrukker';

  @override
  String get voiceAndroidAec => 'Echo-onderdrukker';

  @override
  String get voiceNotAvailableDevice => 'Niet beschikbaar op dit apparaat';

  @override
  String get callLinkNotLocal =>
      'Dit linktype kan alleen vanaf de opdrachtregel van deze computer worden gebruikt.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Verbinden met apparaat $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Een link uit een andere app of van een webpagina wil SoftphonePro met dit apparaat verbinden. Verbind alleen als u dit verwacht.';

  @override
  String get linkLanConnectAction => 'Verbinden';

  @override
  String get linkImportSensitiveHeader =>
      'Gevoelige wijzigingen in deze configuratie:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Beantwoordt inkomende gesprekken automatisch';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Stuurt gesprekken door naar $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Wijzigt wie een intercom mag starten of een gesprek mag overnemen (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Herschrijft de nummers die u kiest';

  @override
  String get linkImportFlagLinksImmediately =>
      'Gesprekken vanuit weblinks starten direct, zonder bevestiging';

  @override
  String get linkImportFlagDiagnostics =>
      'Schakelt uitgebreide logging of SIP-tracing in';

  @override
  String get linkImportAllowAutoAnswer =>
      'Automatisch beantwoorden toestaan voor de geïmporteerde account(s)';

  @override
  String linkImportRefused(String setting) {
    return 'Deze import probeert \"$setting\" te wijzigen, wat nooit via een link, QR-code, geplakte tekst of bestand kan worden ingesteld. Gebruik in plaats daarvan de opdrachtregeloptie --provision op deze computer. Er is niets geïmporteerd.';
  }

  @override
  String get lanPairIntercomNote =>
      'Gekoppelde apparaten kunnen een intercomgesprek aanvragen; u wordt eerst gevraagd (te wijzigen onder Instellingen > LAN).';

  @override
  String get callLinkUnsupportedScheme =>
      'Dit soort link wordt niet ondersteund.';

  @override
  String get linkImportFlagAutoRecord => 'Neemt gesprekken automatisch op';

  @override
  String get linkImportFlagBlocklist =>
      'Wijzigt uw blokkeerlijst voor gesprekken';

  @override
  String get linkImportFlagEmergency => 'Wijzigt uw alarmnummers';

  @override
  String get linkImportFlagSpeedDial => 'Stelt snelkiesnummers in';

  @override
  String get linkImportFlagRecordingDelete =>
      'Verwijdert oude opnames automatisch';

  @override
  String get linkImportFlagFeatureCodes => 'Kiest eigen PBX-functiecodes';

  @override
  String get linkImportAllowAutoRecord =>
      'Automatisch opnemen van gesprekken toestaan';

  @override
  String get importIgnoredHeader => 'Genegeerd (niet toegestaan bij import):';

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
    return 'Proxy\'s: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN-relay: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Eigen SIP-headers: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'Beller-ID: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'Geen mediaversleuteling (SRTP uit)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Adres: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return '$updated bestaande bijwerken, $added nieuwe toevoegen';
  }

  @override
  String get mixerTitle => 'Audiomixer';

  @override
  String get mixerMicrophone => 'Microfoon';

  @override
  String get mixerSpeaker => 'Koptelefoon en luidspreker';

  @override
  String get mixerMicVolume => 'Microfoonvolume';

  @override
  String get mixerSpeakerVolume => 'Luidsprekervolume';

  @override
  String mixerMeterLabel(String name) {
    return 'Niveau: $name';
  }

  @override
  String get mixerInputDevice => 'Invoerapparaat';

  @override
  String get mixerOutputDevice => 'Uitvoerapparaat';

  @override
  String get mixerOutputRoute => 'Audio-uitvoer';

  @override
  String get mixerInputFollowsOutput =>
      'De microfoon volgt de gekozen audio-uitvoer.';

  @override
  String get mixerShowMore => 'Apparaten en achtergrondmuziek tonen';

  @override
  String get mixerShowLess => 'Minder opties tonen';

  @override
  String get mixerStripShow => 'Audiomixer tonen';

  @override
  String get mixerStripHide => 'Audiomixer verbergen';

  @override
  String get musicbedTitle => 'Achtergrondmuziek';

  @override
  String get musicbedPlay => 'Achtergrondmuziek afspelen';

  @override
  String get musicbedVolume => 'Volume achtergrondmuziek';

  @override
  String get musicbedChooseFile => 'Bestand kiezen';

  @override
  String musicbedChangeFile(String name) {
    return 'Bestand achtergrondmuziek: $name. Tik om te wijzigen.';
  }

  @override
  String get musicbedHearIt => 'Zelf meeluisteren';

  @override
  String get musicbedMonitorVolume => 'Meeluistervolume';

  @override
  String get musicbedAddFile => 'Bestand toevoegen…';

  @override
  String get musicbedPickerTitle => 'Bestand achtergrondmuziek';

  @override
  String get musicbedOn => 'Achtergrondmuziek aan';

  @override
  String get musicbedOnTooltip =>
      'Een muziekbestand wordt afgespeeld voor iedereen in je gesprekken.';

  @override
  String get musicbedFileMissing =>
      'Het bestand voor de achtergrondmuziek is niet meer beschikbaar; de achtergrondmuziek is uitgezet.';

  @override
  String get musicbedNeedsFile =>
      'Kies eerst een bestand voor de achtergrondmuziek.';

  @override
  String musicbedStopped(String message) {
    return 'Achtergrondmuziek gestopt: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Speelt een muziekbestand in een lus onder je stem af voor iedereen in je gesprekken, ook als je gedempt bent. Gesprekken in de wacht horen in plaats daarvan de wachtmuziek.';

  @override
  String get musicbedSettingsFile => 'Muziekbestand';

  @override
  String get linkImportFlagMusicbed => 'Speelt muziek af in je gesprekken';

  @override
  String get musicbedMonitorIosHint =>
      'Op de iPhone hoor je het tijdens gesprekken';

  @override
  String get musicbedStopFailed =>
      'De muziek kon niet worden gestopt. Je gesprekspartners horen haar mogelijk nog.';
}
