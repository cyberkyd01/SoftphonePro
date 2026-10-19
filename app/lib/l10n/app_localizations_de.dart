// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get languagePickerHint =>
      'Sprachnamen werden in ihrer eigenen Sprache angezeigt.';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionRename => 'Umbenennen';

  @override
  String get actionClear => 'Leeren';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionImport => 'Importieren';

  @override
  String get actionExport => 'Exportieren';

  @override
  String get actionDetails => 'Details';

  @override
  String get actionMore => 'Mehr';

  @override
  String get actionSettings => 'Einstellungen';

  @override
  String get actionSearch => 'Suchen';

  @override
  String get actionRefresh => 'Aktualisieren';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionYes => 'Ja';

  @override
  String get actionNo => 'Nein';

  @override
  String get commonOn => 'Ein';

  @override
  String get commonOff => 'Aus';

  @override
  String get commonNone => 'Keine';

  @override
  String get commonDefault => 'Standard';

  @override
  String get commonSystem => 'System';

  @override
  String get commonAutomatic => 'Automatisch';

  @override
  String get commonUnknown => 'Unbekannt';

  @override
  String get commonNotSet => 'Nicht festgelegt';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonLoading => 'Wird geladen…';

  @override
  String get statusAvailable => 'Verfügbar';

  @override
  String get statusDoNotDisturb => 'Nicht stören';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'Im Gespräch';

  @override
  String get settingsEntryAccounts => 'Konten';

  @override
  String get settingsEntryAccountsSub => 'SIP-Konten und Registrierung';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub => 'Geräte, Pegel, Echounterdrückung';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Reihenfolge, Verfügbarkeit, Opus';

  @override
  String get settingsEntryCalls => 'Anrufe';

  @override
  String get settingsEntryCallsSub =>
      'Nicht stören, Anklopfen, Auto-Annahme, Wählregeln';

  @override
  String get settingsEntryNetwork => 'Netzwerk';

  @override
  String get settingsEntryNetworkSub => 'Transporte, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Aufzeichnung';

  @override
  String get settingsEntryNotifications => 'Benachrichtigungen und Klingeltöne';

  @override
  String get settingsEntryShortcuts => 'Tastenkürzel';

  @override
  String get settingsEntryShortcutsSub => 'Globale Hotkeys, Tasten in der App';

  @override
  String get settingsEntryAppearance => 'Darstellung';

  @override
  String get settingsEntryPrivacy => 'Datenschutz und Sicherheit';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisionierung';

  @override
  String get settingsEntryProvisioningSub => 'Import, Export, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnose';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP-Trace, Netzwerkprüfungen';

  @override
  String get settingsEntryAdvanced => 'Erweitert';

  @override
  String get settingsEntryAbout => 'Info';

  @override
  String get settingsAccountsEmptyTitle => 'Erstes Konto hinzufügen';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Verbinden Sie sich mit Ihrer Telefonanlage oder Ihrem SIP-Anbieter, um zu telefonieren.';

  @override
  String get settingsAccountsAdd => 'Konto hinzufügen';

  @override
  String get settingsAccountsYourAccounts => 'Ihre Konten';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  Ersatzserver in Verwendung';
  }

  @override
  String get settingsAudioDevices => 'Geräte';

  @override
  String get settingsAudioMicrophone => 'Mikrofon';

  @override
  String get settingsAudioSpeaker => 'Lautsprecher';

  @override
  String get settingsAudioRinger => 'Klingelgerät';

  @override
  String get settingsAudioRingerSub =>
      'Klingelton auf einem separaten Gerät wiedergeben';

  @override
  String get settingsAudioRefreshDevices => 'Geräte aktualisieren';

  @override
  String get settingsAudioLevelsAndTest => 'Pegel und Test';

  @override
  String get settingsAudioMicVolume => 'Mikrofonlautstärke';

  @override
  String get settingsAudioMicLevel => 'Mikrofonpegel';

  @override
  String get settingsAudioSpeakerVolume => 'Lautsprecherlautstärke';

  @override
  String get settingsAudioSpeakerLevel => 'Lautsprecherpegel';

  @override
  String get settingsAudioTestSpeaker => 'Lautsprecher testen';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Spielt einen kurzen Ton über den gewählten Lautsprecher ab';

  @override
  String get settingsAudioTestToneFailed =>
      'Testton konnte nicht abgespielt werden';

  @override
  String get settingsAudioEchoTestFailed => 'Echotest fehlgeschlagen';

  @override
  String get settingsAudioEchoTest => 'Echotest';

  @override
  String get settingsAudioEchoTestSub =>
      'Gibt Ihr Mikrofon über den Lautsprecher wieder. Verwenden Sie Kopfhörer, um Rückkopplungen zu vermeiden.';

  @override
  String get settingsAudioVoiceAndFiles => 'Stimme und Dateien';

  @override
  String get settingsAudioVoiceIsolation =>
      'Stimmisolierung (KI-Geräuschunterdrückung)';

  @override
  String get settingsAudioAudioFiles => 'Audiodateien';

  @override
  String get settingsAudioAudioFilesSub => 'Wartemusik und Ansagen';

  @override
  String get settingsAudioProcessing => 'Verarbeitung';

  @override
  String get settingsAudioEchoCancellation => 'Echounterdrückung';

  @override
  String get settingsAudioEcSimple => 'Einfach';

  @override
  String get settingsAudioEcPlatform => 'Plattform';

  @override
  String get settingsAudioEchoTail => 'Echolänge';

  @override
  String get settingsAudioNoiseSuppression => 'Rauschunterdrückung';

  @override
  String get settingsAudioAgc => 'Automatische Verstärkungsregelung';

  @override
  String get settingsAudioVad => 'Sprachaktivitätserkennung';

  @override
  String get settingsAudioVadSub => 'Spart Bandbreite bei Stille';

  @override
  String get settingsAudioAdvanced => 'Erweitert';

  @override
  String get settingsAudioAdvancedFooter =>
      'Jitter-Buffer-Werte sind in Millisekunden; -1 verwendet den Standard der Engine. Eine Änderung startet die Anruf-Engine neu.';

  @override
  String get settingsAudioPtime => 'Paketdauer (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter-Buffer: Anfangswert';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter-Buffer: Mindest-Prefetch';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter-Buffer: Maximal-Prefetch';

  @override
  String get settingsAudioJbMaxSize => 'Jitter-Buffer: Maximalgröße';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Mikrofon $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Andere $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent Prozent';
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
      other: '$count Sekunden',
      one: '1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Reihenfolge und Verfügbarkeit';

  @override
  String get settingsCodecsDragHint =>
      'Zum Ändern der Reihenfolge ziehen. Konten können diese Liste in ihren eigenen Einstellungen überschreiben.';

  @override
  String get settingsCodecsBitrate => 'Bitrate';

  @override
  String get settingsCodecsFec => 'In-Band-FEC';

  @override
  String get settingsCodecsFecSub => 'Gleicht Paketverluste aus';

  @override
  String get settingsCodecsDtxSub => 'Bei Stille nicht senden';

  @override
  String get settingsCodecsCbr => 'Konstante Bitrate';

  @override
  String get settingsCodecsComplexity => 'Komplexität';

  @override
  String get settingsCallsIncoming => 'Eingehend';

  @override
  String get settingsCallsDndSub => 'Alle eingehenden Anrufe abweisen';

  @override
  String get settingsCallsRejectWith => 'Abweisen mit';

  @override
  String get settingsCallsReasonBusy => 'Besetzt (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Vorübergehend nicht erreichbar (480)';

  @override
  String get settingsCallsReasonDecline => 'Abgelehnt (603)';

  @override
  String get settingsCallsWaiting => 'Anklopfen';

  @override
  String get settingsCallsWaitingSub =>
      'Zweiten eingehenden Anruf während eines Gesprächs zulassen';

  @override
  String get settingsCallsWhenBusy => 'Bei Besetzt und deaktiviertem Anklopfen';

  @override
  String get settingsCallsRejectAnonymous => 'Anonyme Anrufe abweisen';

  @override
  String get settingsCallsLinksImmediately => 'Anruf-Links sofort ausführen';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Links mit tel:, sip: und callto: starten den Anruf, ohne im Wähler zu warten';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'DND / Rufumleitung per Kennzahlen mit Telefonanlage abgleichen';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Wählt kurz die Stern-Kennzahlen des Kontos (z. B. *78), wenn Sie Nicht stören oder die Rufumleitung ändern';

  @override
  String get settingsCallsAutoAnswerGroup => 'Automatische Annahme';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Rufumleitung und kontospezifische automatische Annahme werden im jeweiligen Konto festgelegt.';

  @override
  String get settingsCallsAutoAnswerAll => 'Alle Anrufe automatisch annehmen';

  @override
  String get settingsCallsAnswerAfter => 'Annehmen nach';

  @override
  String get settingsCallsAnswerImmediately => 'Sofort';

  @override
  String get settingsCallsIntercomHeaders => 'Intercom-Header beachten';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info-, Alert-Info- und Answer-Mode-Hinweise zur automatischen Annahme';

  @override
  String get settingsCallsBlocked => 'Gesperrte Nummern';

  @override
  String get settingsCallsBlockNumber => 'Nummer sperren';

  @override
  String get settingsCallsBlockNumberTitle => 'Nummer sperren';

  @override
  String get settingsCallsBlockNumberHint => 'Nummer oder SIP-Adresse';

  @override
  String get settingsCallsSpeedDial => 'Kurzwahl';

  @override
  String get settingsCallsDialPlan => 'Wählplan';

  @override
  String get settingsCallsDialRules => 'Wählregeln';

  @override
  String get settingsCallsStripPrefix => 'Amtsholung-Präfix entfernen';

  @override
  String get settingsCallsStripPrefixSub =>
      'Zum Beispiel 9, wird am Anfang gewählter Nummern entfernt';

  @override
  String get settingsCallsPlusReplacement => 'Führendes + ersetzen durch';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Zum Beispiel 00 für internationale Vorwahl';

  @override
  String get settingsCallsPlusReplacementHint => '+ beibehalten';

  @override
  String get settingsCallsCountryPrefix => 'Standard-Landesvorwahl';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Nationale Nummern, die mit 0 beginnen, erhalten diese Vorwahl, zum Beispiel +49';

  @override
  String get settingsCallsEmergency => 'Notrufnummern';

  @override
  String get settingsCallsEmergencySub =>
      'Durch Kommas getrennt. Diese umgehen die Wählregeln.';

  @override
  String settingsCallsUnblock(String number) {
    return '$number entsperren';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count von 9 belegt';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Regeln',
      one: '1 Regel',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Neue Wählregel';

  @override
  String get settingsDialRulesEdit => 'Wählregel bearbeiten';

  @override
  String get settingsDialRulesName => 'Name';

  @override
  String get settingsDialRulesPattern => 'Muster (Regex)';

  @override
  String get settingsDialRulesReplacement => 'Ersetzung';

  @override
  String get settingsDialRulesReplacementHelp =>
      '\$1, \$2 für Gruppen verwenden';

  @override
  String get settingsDialRulesRoute => 'Über Konto leiten';

  @override
  String get settingsDialRulesAdd => 'Regel hinzufügen';

  @override
  String get settingsDialRulesLiveTest => 'Live-Test';

  @override
  String get settingsDialRulesTyped => 'Eingegebene Nummer';

  @override
  String get settingsDialRulesNothing => '(nichts)';

  @override
  String get settingsDialRulesEmergency =>
      'Notrufnummer: wird wie eingegeben gewählt';

  @override
  String get settingsDialRulesAccountFallback => 'Konto';

  @override
  String get settingsDialRulesEmpty =>
      'Keine Regeln. Nummern werden bereinigt (Leerzeichen, Bindestriche und Klammern entfernt) und wie eingegeben gewählt. Regeln werden von oben nach unten geprüft; die erste Übereinstimmung gilt.';

  @override
  String get settingsDialRulesDelete => 'Regel löschen';

  @override
  String get settingsDialRulesDeleteTitle => 'Regel löschen?';

  @override
  String settingsDialRulesVia(String account) {
    return 'über $account';
  }

  @override
  String get settingsNetworkTransports => 'Transporte';

  @override
  String get settingsNetworkTransportsFooter =>
      'Port 0 wählt einen zufälligen freien Port. Eine Änderung der Transporte startet die Anruf-Engine neu.';

  @override
  String get settingsNetworkUdpPort => 'UDP-Port';

  @override
  String get settingsNetworkTcpPort => 'TCP-Port';

  @override
  String get settingsNetworkTlsPort => 'TLS-Port';

  @override
  String get settingsNetworkVerifyCerts => 'Serverzertifikate prüfen';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Nur bei selbstsignierten Telefonanlagen deaktivieren oder das Zertifikat unten fixieren';

  @override
  String get settingsNetworkCustomCa => 'Eigene CA-Datei';

  @override
  String get settingsNetworkCustomCaSub =>
      'PEM-Bundle, das statt der integrierten Liste verwendet wird (private CA der Telefonanlage)';

  @override
  String get settingsNetworkCustomCaHint => 'Integrierte Mozilla-Liste';

  @override
  String get settingsNetworkPins => 'Fixierte Zertifikate';

  @override
  String get settingsNetworkPinsSub =>
      'Host=SHA256-Fingerabdruck, durch Kommas getrennt';

  @override
  String get settingsNetworkNat => 'NAT-Traversal';

  @override
  String get settingsNetworkStun => 'STUN-Server';

  @override
  String get settingsNetworkStunSub => 'Host:Port, durch Kommas getrennt';

  @override
  String get settingsNetworkIceTurn => 'ICE und TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Pro Konto unter NAT konfiguriert';

  @override
  String get settingsNetworkAdvanced => 'Erweitert';

  @override
  String get settingsNetworkQos => 'QoS (DSCP-Markierung)';

  @override
  String get settingsNetworkQosSub =>
      'SIP- und Sprachpakete für Priorisierung markieren';

  @override
  String get settingsNetworkDns => 'DNS-Server';

  @override
  String get settingsNetworkDnsSub => 'Leer lassen für automatisch';

  @override
  String get settingsNetworkRtpStart => 'RTP-Port-Start';

  @override
  String get settingsNetworkRtpRange => 'RTP-Portbereich';

  @override
  String get settingsNetworkRtpRangeSub => '0 verwendet den Standard';

  @override
  String get settingsNotifRingtone => 'Klingelton';

  @override
  String get settingsNotifDefaultRingtone => 'Standard-Klingelton';

  @override
  String get settingsNotifProgressTones => 'Rufzustandstöne';

  @override
  String get settingsNotifProgressTonesSub =>
      'Freiton, Besetztton und Überlastton beim Wählen';

  @override
  String get settingsNotifRingerVolume => 'Klingeltonlautstärke';

  @override
  String get settingsNotifCustomRingtone => 'Eigene Klingeltondatei';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Pfad zu einer WAV-Datei (Desktop)';

  @override
  String get settingsNotifGroup => 'Benachrichtigungen';

  @override
  String get settingsNotifRequestPermissions => 'Berechtigungen anfordern';

  @override
  String get settingsNotifRequestPermissionsSub =>
      'Mikrofon und Benachrichtigungen';

  @override
  String get settingsNotifTyping => 'Tippanzeige senden';

  @override
  String get settingsAppearanceTheme => 'Design';

  @override
  String get settingsAppearanceLight => 'Hell';

  @override
  String get settingsAppearanceDark => 'Dunkel';

  @override
  String get settingsAppearanceAccent => 'Akzentfarbe';

  @override
  String get settingsAppearanceAccentOption => 'Akzentfarbe-Option';

  @override
  String get settingsAppearanceCompact => 'Kompakte Darstellung';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Mikrofon: $microphone, Benachrichtigungen: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Sicherheit';

  @override
  String get settingsPrivacyPasswords => 'Passwörter';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Gespeichert im Schlüsselbund / Keystore des Systems (Ersatz: verschlüsselte Datei)';

  @override
  String get settingsPrivacyGroup => 'Datenschutz';

  @override
  String get settingsPrivacyNoTelemetry => 'Keine Telemetrie';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro sendet keine Analysedaten. Der Netzwerkverkehr geht nur an Ihre SIP-Server.';

  @override
  String get settingsPrivacyYourData => 'Ihre Daten';

  @override
  String get settingsPrivacyClearHistory => 'Anrufverlauf löschen';

  @override
  String get settingsPrivacyDeleteContacts => 'Alle Kontakte löschen';

  @override
  String get settingsPrivacyDeleteMessages => 'Alle Nachrichten löschen';

  @override
  String get settingsPrivacyConfirmHistory => 'Anrufverlauf löschen?';

  @override
  String get settingsPrivacyConfirmContacts => 'Alle Kontakte löschen?';

  @override
  String get settingsPrivacyConfirmMessages => 'Alle Nachrichten löschen?';

  @override
  String get settingsPrivacyCannotUndo =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get settingsPrivacyDeletedHistory => 'Anrufverlauf gelöscht';

  @override
  String get settingsPrivacyDeletedContacts => 'Alle Kontakte gelöscht';

  @override
  String get settingsPrivacyDeletedMessages => 'Alle Nachrichten gelöscht';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Geräte im selben Netzwerk finden sich gegenseitig, koppeln sich mit einem 6-stelligen Code und sprechen direkt miteinander, ganz ohne Server.';

  @override
  String get settingsLanEnable => 'LAN Link aktivieren';

  @override
  String get settingsLanDeviceName => 'Gerätename';

  @override
  String get settingsLanDeviceNameHint => 'Dieses Gerät';

  @override
  String get settingsLanAllowIntercom => 'Gegensprechen erlauben';

  @override
  String get settingsLanAllowIntercomSub =>
      'Gekoppelte Geräte dürfen Sie anrufen und werden automatisch angenommen';

  @override
  String get settingsLanAskIntercom => 'Vor dem Gegensprechen nachfragen';

  @override
  String get settingsLanAskIntercomSub =>
      'Andernfalls werden gekoppelte Geräte 30 s nach ihrer Anfrage automatisch angenommen';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Dateien von gekoppelten Geräten automatisch annehmen';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Andernfalls werden Sie bei jeder Datei gefragt';

  @override
  String get settingsLanAllowPull =>
      'Gekoppelten Geräten das Abholen meiner Anrufe erlauben';

  @override
  String get settingsLanAllowPullSub =>
      'Ein gekoppeltes Gerät kann einen hier aktiven Anruf übernehmen';

  @override
  String get settingsLanDownloads => 'Download-Ordner';

  @override
  String get settingsLanDownloadsHint => 'Standard (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'Link-Port';

  @override
  String get settingsLanSharedAccounts =>
      'Mit gekoppelten Geräten geteilte Konten';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Wenn Sie ein registriertes Konto teilen, kann ein gekoppeltes Gerät am selben Server Ihre Anrufe direkt erhalten (Weiterverbinden), statt sie über Umwege weiterzureichen.';

  @override
  String get settingsAdvEngine => 'Engine';

  @override
  String get settingsAdvSimulator => 'Simulator verwenden';

  @override
  String get settingsAdvSimulatorSub =>
      'Ohne die native Engine ausführen. Anrufe werden simuliert.';

  @override
  String get settingsAdvLogLevel => 'Protokollstufe';

  @override
  String get settingsAdvLogErrors => 'Fehler';

  @override
  String get settingsAdvLogInfo => 'Info';

  @override
  String get settingsAdvLogDebug => 'Debug';

  @override
  String get settingsAdvLogVerbose => 'Ausführlich';

  @override
  String get settingsAdvSipTrace => 'SIP-Trace';

  @override
  String get settingsAdvRestartEngine => 'Engine neu starten';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Beim Anmelden starten';

  @override
  String get settingsAdvCloseToTray => 'In den Infobereich schließen';

  @override
  String get settingsAdvCloseToTraySub =>
      'Beim Schließen des Fensters läuft SoftphonePro weiter, sodass Anrufe weiterhin klingeln. Beenden über das Symbol im Infobereich / in der Menüleiste.';

  @override
  String get settingsAboutLicence => 'Lizenz';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro ist freie Software: Sie können sie unter den Bedingungen der GNU General Public License, wie von der Free Software Foundation veröffentlicht, in Version 3 oder höher weitergeben und/oder ändern. Sie wird OHNE JEDE GEWÄHRLEISTUNG verbreitet.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 oder höher';

  @override
  String get settingsAboutGplSub => 'Quellcode im Projekt-Repository verfügbar';

  @override
  String get settingsAboutThirdParty => 'Hinweise zu Drittanbietern';

  @override
  String get settingsAboutPackages => 'Flutter- und Dart-Pakete';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-Clause, MIT und Apache 2.0. Siehe Lizenzseite.';

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
  String get updatesChecking => 'Wird geprüft...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version ist verfügbar';
  }

  @override
  String get updatesUpToDate => 'Sie sind auf dem neuesten Stand';

  @override
  String get updatesCouldNotCheck => 'Prüfung nicht möglich';

  @override
  String get updatesNotCheckedYet => 'Noch nicht geprüft';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Zuletzt geprüft: $dateString';
  }

  @override
  String get updatesTitle => 'Updates';

  @override
  String get updatesFooter =>
      'Die Prüfung kontaktiert nur api.github.com (einmal pro Woche) und sendet nichts außer der Anfrage selbst: keine Kennung, keine Konto- oder Anrufdaten. SoftphonePro lädt oder installiert von sich aus nie etwas.';

  @override
  String get updatesCheckSwitch => 'Nach Updates suchen';

  @override
  String get updatesCheckNow => 'Jetzt prüfen';

  @override
  String updatesSkippingVersion(String version) {
    return 'Version $version wird übersprungen';
  }

  @override
  String get updatesStopSkipping => 'Nicht mehr überspringen';

  @override
  String get updatesReleaseNotes => 'Versionshinweise';

  @override
  String get updatesDownload => 'Herunterladen';

  @override
  String get updatesSkipVersion => 'Diese Version überspringen';

  @override
  String get updatesDismiss => 'Ausblenden';

  @override
  String get updatesRateLimited =>
      'GitHub-Anfragelimit erreicht, bitte später erneut versuchen';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub antwortete mit $status';
  }

  @override
  String get updatesUnexpectedReply => 'Unerwartete Antwort';

  @override
  String get updatesTimedOut => 'Zeitüberschreitung';

  @override
  String get updatesAlreadyChecking => 'Prüfung läuft bereits';

  @override
  String get encryptionTitle => 'Verschlüsselung';

  @override
  String get encryptionFooter =>
      'Verschlüsselt die lokale Datenbank mit AES-256-GCM. Der Schlüssel liegt im Schlüsselbund / Keystore des Systems; geht er verloren, sind die Daten nicht wiederherstellbar. Anrufaufzeichnungen und exportierte Dateien werden nicht verschlüsselt. Die Änderung wird beim nächsten Start von SoftphonePro wirksam (vorher vollständig beenden); die bisherige Datei wird überschrieben und gelöscht, sobald die neue Datenbank geöffnet und geprüft wurde.';

  @override
  String get encryptionSwitchTitle =>
      'Anrufverlauf, Kontakte und Nachrichten auf diesem Gerät verschlüsseln';

  @override
  String get encryptionWillEncrypt => 'Wird beim nächsten Start verschlüsselt';

  @override
  String get encryptionWillDecrypt => 'Wird beim nächsten Start entschlüsselt';

  @override
  String get encryptionRestartToEncrypt =>
      'Beenden Sie SoftphonePro und starten Sie es neu, um Ihre Daten zu verschlüsseln.';

  @override
  String get encryptionRestartToDecrypt =>
      'Beenden Sie SoftphonePro und starten Sie es neu, um Ihre Daten zu entschlüsseln.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Kurzwahl $slot';
  }

  @override
  String get speedDialNumberLabel => 'Nummer oder SIP-Adresse';

  @override
  String get speedDialLabelOptional => 'Bezeichnung (optional)';

  @override
  String get speedDialCallFrom => 'Anrufen von';

  @override
  String get speedDialSelectedAccount => 'Ausgewähltes Konto';

  @override
  String get speedDialTitle => 'Kurzwahl';

  @override
  String get speedDialHint =>
      'Halten Sie auf der leeren Wähltastatur eine Ziffer (1-9) gedrückt, um die zugehörige Nummer anzurufen.';

  @override
  String get speedDialNotAssigned => 'Nicht belegt';

  @override
  String provisioningNotValidJson(String detail) {
    return 'Kein gültiges JSON: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Ein JSON-Objekt wurde erwartet';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Nicht unterstützte Konfigurationsversion $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Konto-Eintrag ohne Objekt übersprungen';

  @override
  String get provisioningNothingToImport =>
      'Die Datei enthält keine Konten oder Einstellungen';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'Konto \"$name\" benötigt Benutzername und Domain';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Server antwortete mit $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Konfiguration konnte nicht heruntergeladen werden: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '$path konnte nicht gelesen werden';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konten importiert',
      one: '1 Konto importiert',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Konfiguration importieren';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts Konten',
      one: '1 Konto',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings Einstellungen',
      one: '1 Einstellung',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Aus URL oder JSON importieren';

  @override
  String get provisioningImportFromUrlHint => 'https://... oder JSON einfügen';

  @override
  String get provisioningInvalidSource =>
      'Das ist keine gültige URL, kein gültiger Link und kein gültiges JSON';

  @override
  String get provisioningScanTitle => 'Provisionierungs-QR scannen';

  @override
  String get provisioningPasteHint => 'JSON, Link oder URL einfügen';

  @override
  String get provisioningImportGroup => 'Import';

  @override
  String get provisioningImportFooter =>
      'Unterstützt JSON mit Konten und Einstellungen. \${VAR}-Platzhalter werden mit leeren Werten gefüllt, sofern kein Standardwert als \${VAR:-default} angegeben ist.';

  @override
  String get provisioningScanQr => 'QR-Code scannen';

  @override
  String get provisioningFromUrl => 'Aus URL oder eingefügtem JSON';

  @override
  String get provisioningFromFile => 'Aus Datei';

  @override
  String get provisioningFromClipboard => 'Aus Zwischenablage';

  @override
  String get provisioningExportGroup => 'Export';

  @override
  String get provisioningIncludePasswords => 'Passwörter einschließen';

  @override
  String get provisioningIncludePasswordsHint =>
      'Jeder mit der Datei kann Ihre Konten nutzen';

  @override
  String get provisioningCopyConfig => 'Konfiguration kopieren (JSON)';

  @override
  String get provisioningConfigCopied => 'Konfiguration kopiert';

  @override
  String get provisioningQrGroup => 'QR-Code';

  @override
  String get provisioningQrFooter =>
      'Scannen Sie diesen Code auf einem anderen Gerät, um ein Konto zu übernehmen. Behandeln Sie ihn wie ein Passwort, falls er eines enthält.';

  @override
  String get provisioningQrAccount => 'Konto';

  @override
  String get provisioningChoose => 'Auswählen...';

  @override
  String get provisioningQrTooMuchData => 'Zu viele Daten für einen QR-Code';

  @override
  String tlsClearField(String field) {
    return '$field entfernen';
  }

  @override
  String get tlsChoose => 'Auswählen...';

  @override
  String get tlsChange => 'Ändern...';

  @override
  String get tlsClientCertTitle => 'Clientzertifikat (gegenseitiges TLS)';

  @override
  String get tlsIncomplete =>
      'Wählen Sie sowohl ein Zertifikat als auch den zugehörigen privaten Schlüssel. Das Zertifikat wird erst verwendet, wenn beides festgelegt ist.';

  @override
  String get tlsFooter =>
      'Für Server, die verlangen, dass sich die App mit einem Zertifikat ausweist. PEM-Dateien. Wird für TLS und sicheres WebSocket verwendet.';

  @override
  String get tlsCertFile => 'Zertifikatsdatei';

  @override
  String get tlsKeyFile => 'Datei des privaten Schlüssels';

  @override
  String get tlsKeyPassword => 'Schlüsselpasswort';

  @override
  String get tlsKeyPasswordHint => 'Nur bei verschlüsseltem Schlüssel';

  @override
  String get callSettingsHoldGroupTitle => 'Halten';

  @override
  String get callSettingsHoldFooter =>
      'Bei \"Standard der Telefonanlage\" wird der Anruf einfach gehalten, und Ihre Telefonanlage spielt möglicherweise eigene Musik ab. Jede andere Auswahl wird von dieser App für den Anrufer abgespielt.';

  @override
  String get callSettingsHoldMusic => 'Wartemusik';

  @override
  String get callSettingsHoldPbxDefault => 'Standard der Telefonanlage';

  @override
  String get callSettingsHoldMusicVolume => 'Lautstärke der Wartemusik';

  @override
  String get callSettingsHoldAudioFiles => 'Audiodateien';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Wartemusik importieren oder aufnehmen';

  @override
  String get callSettingsAnnounceTitle => 'Ansagen';

  @override
  String get callSettingsAnnounceFooter =>
      'Ansagen werden der Gegenseite vorgespielt. Fehlt die Datei, wird alles stillschweigend übersprungen.';

  @override
  String get callSettingsAnnounceOpening => 'Begrüßungsansage';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Eine Nachricht abspielen, wenn ein Anruf verbunden wird';

  @override
  String get callSettingsAnnounceFile => 'Ansagedatei';

  @override
  String get callSettingsAnnounceChooseFile => 'Datei auswählen';

  @override
  String get callSettingsAnnouncePlayFor => 'Abspielen bei';

  @override
  String get callSettingsAnnounceBoth => 'Ein- und ausgehend';

  @override
  String get callSettingsAnnounceIncoming => 'Eingehende Anrufe';

  @override
  String get callSettingsAnnounceOutgoing => 'Ausgehende Anrufe';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Mein Mikrofon während der Wiedergabe stummschalten';

  @override
  String get callSettingsAnnounceMonitor => 'Auch für mich hörbar';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Vor Aufzeichnungsbeginn abspielen';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Vor dem Weiterverbinden eines Anrufers abspielen';

  @override
  String get morePageTitle => 'Mehr';

  @override
  String get morePresence => 'Präsenz';

  @override
  String get morePresenceHint => 'Besetztlampenfeld';

  @override
  String get moreRetrieveParked => 'Geparkten Anruf abholen';

  @override
  String get moreRetrieveParkedHint => 'Parkplatz wählen';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Geräte in der Nähe, Chat und Dateiablage';

  @override
  String get moreRecordings => 'Aufzeichnungen';

  @override
  String get moreRecordingsHint =>
      'Anrufaufzeichnungen anhören, teilen und verwalten';

  @override
  String get moreVoicemail => 'Mailbox';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Nachrichten',
      one: '1 neue Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Mailbox anrufen';

  @override
  String get moreDiagnostics => 'Diagnose';

  @override
  String get moreDiagnosticsHint => 'SIP-Trace und Netzwerkprüfungen';

  @override
  String get moreAbout => 'Info';

  @override
  String get moreNoVoicemailNumber =>
      'Es ist keine Mailbox-Nummer festgelegt. Fügen Sie in den Kontoeinstellungen eine hinzu.';

  @override
  String get moreSearchHint =>
      'Kontakte, Verlauf durchsuchen oder Nummer eingeben';

  @override
  String moreCallNumber(String number) {
    return '$number anrufen';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'App-Sperre';

  @override
  String get appLockFooter =>
      'Anrufe klingeln weiterhin und können bei gesperrter App angenommen werden.';

  @override
  String get appLockRequirePin => 'PIN zum Öffnen der App verlangen';

  @override
  String get appLockOnHint =>
      'Verlauf, Kontakte, Nachrichten und Einstellungen sind gesperrt';

  @override
  String get appLockIsOn => 'App-Sperre ist aktiviert';

  @override
  String get appLockIsOff => 'App-Sperre ist deaktiviert';

  @override
  String get appLockTurnOff => 'App-Sperre deaktivieren';

  @override
  String get appLockChangePin => 'PIN ändern';

  @override
  String get appLockEnterCurrent => 'Aktuelle PIN eingeben';

  @override
  String get appLockPinChanged => 'PIN geändert';

  @override
  String get appLockLockAfter => 'Sperren nach';

  @override
  String get appLockLockAfterHint =>
      'Zeit im Hintergrund, bevor die PIN erneut benötigt wird';

  @override
  String get appLockImmediately => 'Sofort';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 Stunde';

  @override
  String get appLockBiometrics => 'Mit Biometrie entsperren';

  @override
  String get appLockNow => 'Jetzt sperren';

  @override
  String get appLockSetPin => 'PIN festlegen';

  @override
  String get appLockPinDigits => 'PIN (4-8 Ziffern)';

  @override
  String get appLockRepeatPin => 'PIN wiederholen';

  @override
  String get appLockUseDigits => '4 bis 8 Ziffern verwenden';

  @override
  String get appLockMismatch => 'PINs stimmen nicht überein';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Zu viele Versuche. Erneut versuchen in $seconds s';
  }

  @override
  String get appLockWrongPin => 'Falsche PIN';

  @override
  String get appLockTooMany => 'Zu viele Versuche';

  @override
  String get appLockIsLocked => 'SoftphonePro ist gesperrt';

  @override
  String get appLockEnterPin => 'PIN eingeben';

  @override
  String appLockTryAgainIn(String time) {
    return 'Erneut versuchen in $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds s';
  }

  @override
  String get appLockUnlock => 'Entsperren';

  @override
  String get appLockIncomingCall => 'Eingehender Anruf';

  @override
  String get appLockDecline => 'Ablehnen';

  @override
  String get appLockAnswer => 'Annehmen';

  @override
  String get appLockHangUp => 'Auflegen';

  @override
  String get appLockBiometricReason => 'SoftphonePro entsperren';

  @override
  String get automationNoToken =>
      'Kein Zugriffstoken festgelegt. Erzeugen Sie eines unter Einstellungen > Erweitert.';

  @override
  String automationInvalidPort(int port) {
    return 'Ungültiger Port $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Start nicht möglich: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'Port $port ist nicht verfügbar ($error). Wählen Sie einen anderen Port.';
  }

  @override
  String get automationTokenPlaceholder =>
      'Wird erstellt, wenn Sie die API aktivieren';

  @override
  String automationListening(String address) {
    return 'Lauscht auf $address';
  }

  @override
  String get automationStarting => 'Wird gestartet...';

  @override
  String get automationTitle => 'Lokale Automatisierungs-API';

  @override
  String get automationFooter =>
      'Für CRM- und Helpdesk-Integrationen auf diesem Computer. Sie lauscht nur auf 127.0.0.1, und jede Anfrage benötigt das Zugriffstoken. Siehe docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Lokale Automatisierungs-API aktivieren';

  @override
  String get automationPort => 'Port';

  @override
  String get automationPortHint =>
      'Standard 7771. Wählen Sie einen freien Port zwischen 1024 und 65535.';

  @override
  String get automationPortInvalid =>
      'Geben Sie einen Port von 1024 bis 65535 ein';

  @override
  String get automationAccessToken => 'Zugriffstoken';

  @override
  String get automationHideToken => 'Token ausblenden';

  @override
  String get automationShowToken => 'Token anzeigen';

  @override
  String get automationCopyToken => 'Token kopieren';

  @override
  String get automationTokenCopied => 'Token kopiert';

  @override
  String get automationGenerateToken => 'Neues Token erzeugen';

  @override
  String get automationGenerateTitle => 'Neues Token erzeugen?';

  @override
  String get automationGenerateBody =>
      'Programme, die das alte Token verwenden, funktionieren nicht mehr, bis Sie ihnen das neue geben.';

  @override
  String get automationGenerate => 'Erzeugen';

  @override
  String get automationOrigins => 'Erlaubte Browser-Origins';

  @override
  String get automationOriginsHint =>
      'Durch Kommas getrennt, zum Beispiel https://crm.example.com. Programme ohne Browser (curl, Skripte) benötigen dies nicht.';

  @override
  String automationNotOrigin(String origin) {
    return 'Kein http(s)-Origin: $origin';
  }

  @override
  String get trayNotificationAnswer => 'Annehmen';

  @override
  String get trayNotificationDecline => 'Ablehnen';

  @override
  String get trayTooltipInCall => 'SoftphonePro - im Gespräch';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count neu';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - keine Konten (Abwesend)',
      'dnd': 'SoftphonePro - keine Konten (Nicht stören)',
      'other': 'SoftphonePro - keine Konten',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Abwesend)',
      'dnd': 'SoftphonePro - $online/$total online (Nicht stören)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'SoftphonePro ausblenden';

  @override
  String get trayShowApp => 'SoftphonePro anzeigen';

  @override
  String trayNewOpenRecents(int count) {
    return '$count neu - Anrufliste öffnen';
  }

  @override
  String get trayStatus => 'Status';

  @override
  String get trayStatusAway => 'Abwesend';

  @override
  String get trayAccounts => 'Konten';

  @override
  String get trayQuit => 'SoftphonePro beenden';

  @override
  String get hotkeyAnswerCall => 'Anruf annehmen';

  @override
  String get hotkeyHangUp => 'Auflegen';

  @override
  String get hotkeyMute => 'Stummschalten / Stummschaltung aufheben';

  @override
  String get hotkeyFocusDialer => 'Wähler fokussieren';

  @override
  String get shortcutsGlobalTitle => 'Globale Hotkeys';

  @override
  String get shortcutsGlobalFooter =>
      'Funktionieren in jeder Anwendung. Verwendet ein anderes Programm bereits eine Kombination, kann sie unter Umständen nicht registriert werden.';

  @override
  String get shortcutsChange => 'Ändern';

  @override
  String get shortcutsRestoreDefaults => 'Standardwerte wiederherstellen';

  @override
  String get shortcutsMediaTitle => 'Headset- und Medientasten';

  @override
  String get shortcutsMediaFooter =>
      'Die Wiedergabe-/Pause-Taste eines Headsets oder einer Tastatur wird nur belegt, solange ein Anruf klingelt oder aktiv ist; sonst behalten Musikplayer sie.';

  @override
  String get shortcutsMediaSwitch =>
      'Mit der Wiedergabe-/Pause-Taste von Headset/Medien annehmen und auflegen';

  @override
  String get shortcutsMediaDuringCall =>
      'Während eines Anrufs bewirkt die Taste';

  @override
  String get shortcutsMediaHangsUp => 'Auflegen';

  @override
  String get shortcutsMediaMutes => 'Stummschalten / Stummschaltung aufheben';

  @override
  String get shortcutsInApp => 'In der App';

  @override
  String get shortcutsFocusDialer => 'Wähler fokussieren';

  @override
  String get shortcutsHoldResume => 'Halten / Fortsetzen';

  @override
  String get shortcutsTransfer => 'Vermitteln';

  @override
  String get shortcutsEndCall => 'Anruf beenden';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Fügen Sie einem Buchstaben oder einer Ziffer Ctrl, Alt, Shift oder $key hinzu';
  }

  @override
  String get shortcutsPressNew => 'Neue Tastenkombination drücken';

  @override
  String get defaultHandlerChooseInSettings =>
      'Wählen Sie unter Standard-Apps SoftphonePro für SIP, TEL und CALLTO aus';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro öffnet jetzt sip:-, tel:- und callto:-Links';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Der Standard für $schemes konnte nicht geändert werden';
  }

  @override
  String get defaultHandlerIntro =>
      'Öffnet sip:-, tel:- und callto:-Links aus Browsern und anderen Apps';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro verarbeitet sip:-, tel:- und callto:-Links';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Aktuell: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'SoftphonePro zur Standard-App für sip:-, tel:- und callto:-Links machen';

  @override
  String get reliabilityTitle => 'Zuverlässigkeit im Hintergrund';

  @override
  String get reliabilityMicrophone => 'Mikrofon';

  @override
  String get reliabilityAllowed => 'Erlaubt';

  @override
  String get reliabilityMicNeeded => 'Erforderlich, um in Anrufen zu sprechen';

  @override
  String get reliabilityNotifications => 'Benachrichtigungen';

  @override
  String get reliabilityNotifNeeded =>
      'Erforderlich, um eingehende Anrufe anzuzeigen und den Dienst sichtbar zu halten';

  @override
  String get reliabilityFullScreen => 'Eingehende Anrufe im Vollbild';

  @override
  String get reliabilityFullScreenNeeded =>
      'Erlauben, damit Anrufe über dem Sperrbildschirm erscheinen';

  @override
  String get reliabilityBattery => 'Uneingeschränkte Akkunutzung';

  @override
  String get reliabilityBatteryExempt => 'Von der Akkuoptimierung ausgenommen';

  @override
  String get reliabilityBatteryNeeded =>
      'Android kann die App zum Stromsparen anhalten und Anrufe verpassen. Tippen, um SoftphonePro auszunehmen.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer Autostart / geschützte Apps';
  }

  @override
  String get reliabilityAutostartHint =>
      'Ihr Gerätehersteller beendet möglicherweise Hintergrund-Apps. Erlauben Sie SoftphonePro den automatischen Start.';

  @override
  String get reliabilityBoot => 'Beim Systemstart starten';

  @override
  String get reliabilityBootHint =>
      'Konten nach einem Neustart des Telefons registrieren';

  @override
  String get reliabilityWake => 'CPU im Leerlauf wach halten';

  @override
  String get reliabilityWakeHint =>
      'Zuverlässiger auf restriktiven Geräten; verbraucht mehr Akku';

  @override
  String acctEditorDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String acctCodecRemove(String codec) {
    return '$codec entfernen';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Letzter Fehler: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Zulässiger Bereich: $min bis $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Muss mindestens $min sein';
  }

  @override
  String acctValidateMax(int max) {
    return 'Darf höchstens $max sein';
  }

  @override
  String get acctEditorDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get acctEditorDiscardMessage =>
      'Ihre Änderungen an diesem Konto sind nicht gespeichert.';

  @override
  String get acctEditorDiscardConfirm => 'Verwerfen';

  @override
  String get acctEditorDeleteMessage =>
      'Das Konto und sein gespeichertes Passwort werden von diesem Gerät entfernt.';

  @override
  String get acctEditorMenuDelete => 'Konto löschen';

  @override
  String get acctGroupBasic => 'Grundeinstellungen';

  @override
  String get acctFieldLabel => 'Bezeichnung';

  @override
  String get acctFieldLabelHint => 'z. B. Büro';

  @override
  String get acctFieldDisplayName => 'Anzeigename';

  @override
  String get acctFieldUsername => 'Benutzername';

  @override
  String get acctFieldProtocol => 'Protokoll';

  @override
  String get acctFieldProtocolSub =>
      'Wird beim Erstellen des Kontos festgelegt';

  @override
  String get acctFieldAuthUser => 'Autorisierungsbenutzer';

  @override
  String get acctFieldAuthUserHint => 'Wie Benutzername';

  @override
  String get acctFieldAuthUserSub =>
      'Nur, wenn der Anbieter einen anderen Anmeldenamen als den Benutzernamen verwendet';

  @override
  String get acctFieldPassword => 'Passwort';

  @override
  String get acctFieldServerHost => 'Server-Host';

  @override
  String get acctFieldPort => 'Port';

  @override
  String get acctFieldIaxPortSub => 'IAX2-Standard ist 4569';

  @override
  String get acctFieldIaxContext => 'Kontext';

  @override
  String get acctFieldIaxContextSub =>
      'Optional. Wird als angerufener Kontext an die Telefonanlage gesendet';

  @override
  String get acctFieldServerDomain => 'Server / Domain';

  @override
  String get acctFieldServerDomainSub => 'Host oder Host:Port';

  @override
  String get acctFieldEnabled => 'Aktiviert';

  @override
  String get acctFieldDefault => 'Standardkonto für ausgehende Anrufe';

  @override
  String get acctFieldColour => 'Farbe';

  @override
  String get acctGroupRegistration => 'Registrierung';

  @override
  String get acctFieldRegister => 'Registrieren';

  @override
  String get acctFieldRegisterSubIax =>
      'Für Peers deaktivieren, die keine Registrierung benötigen';

  @override
  String get acctFieldRegExpiry => 'Ablauf der Registrierung (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk erzwingt meist 60 s. Bereich 10 bis 86400';

  @override
  String get acctFieldRetryInterval => 'Wiederholungsintervall (s)';

  @override
  String get acctFieldFirstRetry => 'Erste Wiederholung (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 unterstützt G.711 und GSM. Zum Festlegen der Rangfolge ziehen.';

  @override
  String get acctCodecAdd => 'Codec hinzufügen';

  @override
  String get acctGroupServerTransport => 'Server und Transport';

  @override
  String get acctFieldRegistrar => 'Registrar überschreiben';

  @override
  String get acctFieldBackupRegistrar => 'Ersatz-Registrar';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Wird nach 3 fehlgeschlagenen Versuchen verwendet; der primäre wird alle 5 Minuten erneut versucht';

  @override
  String get acctFieldProxies => 'Outbound-Proxys';

  @override
  String get acctFieldTransport => 'Transport';

  @override
  String get acctFieldTransportAutoSub =>
      'Sucht die DNS-SRV-Einträge des Servers heraus und wählt TLS, TCP oder UDP';

  @override
  String get acctTransportAuto => 'Automatisch (DNS SRV)';

  @override
  String get acctFieldWsPath => 'WebSocket-Pfad';

  @override
  String get acctFieldWsPathSub =>
      'HTTP-Pfad des WebSocket-Upgrades, z. B. /ws. Muss mit \"/\" beginnen';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 bis 3600 ist üblich. Bereich 10 bis 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-Alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'UDP-Keep-Alive-Intervall. 0 schaltet es aus. Bereich 0 bis 3600';

  @override
  String get acctFieldLocalPort => 'Lokaler SIP-Port';

  @override
  String get acctFieldLocalPortSub =>
      '0 verwendet den gemeinsamen Transport. Bereich 0 bis 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Für Trunks ohne Registrierung deaktivieren';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Hält einen dauerhaften Fluss durch NAT aufrecht. Erfordert Serverunterstützung';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'STUN verwenden';

  @override
  String get acctFieldTurn => 'TURN-Relay';

  @override
  String get acctFieldTurnServer => 'TURN-Server';

  @override
  String get acctFieldTurnUsername => 'TURN-Benutzername';

  @override
  String get acctFieldTurnPassword => 'TURN-Passwort';

  @override
  String get acctFieldContactRewrite => 'Contact-Header umschreiben';

  @override
  String get acctFieldViaRewrite => 'Via-Header umschreiben';

  @override
  String get acctFieldRewriteSub =>
      'Die vom Server gesehene Adresse verwenden. Hinter NAT aktiviert lassen';

  @override
  String get acctFieldSdpRewrite => 'SDP-Adresse umschreiben';

  @override
  String get acctFieldSdpRewriteSub =>
      'Die Medienadresse in SDP durch die öffentliche ersetzen';

  @override
  String get acctFieldIpv6Sip => 'IPv6-Signalisierung';

  @override
  String get acctFieldIpv6Media => 'IPv6-Medien';

  @override
  String get acctGroupAdvancedMedia => 'Erweiterte Medien';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTC-Gateways benötigen RTCP-Multiplexing und RTCP-Feedback.';

  @override
  String get acctFieldRtcpMux => 'RTCP-Multiplexing';

  @override
  String get acctFieldRtcpMuxSub =>
      'RTP und RTCP über einen Port senden (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'RTCP-Feedback (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'RTP/AVPF mit NACK anbieten. Für WebRTC-Server erforderlich';

  @override
  String get acctGroupSecurity => 'Sicherheit';

  @override
  String get acctFieldSrtp => 'Medienverschlüsselung (SRTP)';

  @override
  String get acctOptOptional => 'Optional';

  @override
  String get acctOptRequired => 'Erforderlich';

  @override
  String get acctFieldKeyExchange => 'Schlüsselaustausch';

  @override
  String get acctFieldSecureSignaling => 'Sichere Signalisierung';

  @override
  String get acctOptNotRequired => 'Nicht erforderlich';

  @override
  String get acctOptTlsHop => 'TLS Hop-by-Hop';

  @override
  String get acctOptTlsE2e => 'TLS Ende-zu-Ende (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Auth-Algorithmus';

  @override
  String get acctFieldPrivacy => 'Rufnummer unterdrücken (Privatsphäre)';

  @override
  String get acctFieldReferPolicy => 'Eingehende Weiterleitungen (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Präsenz-Beobachter';

  @override
  String get acctOptAccept => 'Annehmen';

  @override
  String get acctOptReject => 'Ablehnen';

  @override
  String get acctGroupCodecsFooter =>
      'Überschreibt die globale Codec-Liste für dieses Konto.';

  @override
  String get acctFieldUseGlobalCodecs => 'Globale Codec-Reihenfolge verwenden';

  @override
  String get acctGroupFeatures => 'Funktionen';

  @override
  String get acctFieldVoicemailNumber => 'Mailbox-Nummer';

  @override
  String get acctFieldMwi => 'Mailbox-Anzeige (MWI)';

  @override
  String get acctFieldMwiSub =>
      'Benachrichtigungen über wartende Nachrichten abonnieren';

  @override
  String get acctFieldPublishPresence => 'Meine Präsenz veröffentlichen';

  @override
  String get acctFieldPublishPresenceSub =>
      'Den Server Ihren Online-Status teilen lassen';

  @override
  String get acctFieldDnd => 'Nicht stören';

  @override
  String get acctFieldForwarding => 'Rufumleitung';

  @override
  String get acctOptForwardAlways => 'Immer';

  @override
  String get acctOptForwardBusy => 'Bei Besetzt';

  @override
  String get acctOptForwardNoAnswer => 'Keine Antwort';

  @override
  String get acctFieldForwardTo => 'Umleiten an';

  @override
  String get acctFieldForwardToHint => 'Nummer oder SIP-Adresse';

  @override
  String get acctFieldRingFor => 'Klingeln für (s)';

  @override
  String get acctFieldAutoAnswer => 'Automatische Annahme';

  @override
  String get acctFieldAnswerAfter => 'Annehmen nach (s)';

  @override
  String get acctFieldIntercomOnly => 'Nur für Intercom-Anrufe';

  @override
  String get acctFieldIntercomOnlySub =>
      'Benötigt einen Auto-Answer-Header der Telefonanlage';

  @override
  String get acctFieldRingtone => 'Klingelton';

  @override
  String get acctRingtoneClassic => 'Klassisch';

  @override
  String get acctRingtoneSoft => 'Sanft';

  @override
  String get acctRingtoneDigital => 'Digital';

  @override
  String get acctFieldRecordCalls => 'Anrufe aufzeichnen';

  @override
  String get acctFieldHoldMusic => 'Wartemusik';

  @override
  String get acctOptUseGlobal => 'Globale Einstellung verwenden';

  @override
  String get acctOptPbxDefault => 'Standard der Telefonanlage';

  @override
  String get acctFieldOpeningAnnouncement => 'Begrüßungsansage';

  @override
  String get acctGroupFeatureCodes => 'Kennzahlen';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Werden für Parken, Heranholen, Nicht stören und Rufumleitung an Ihrer Telefonanlage gewählt.';

  @override
  String get acctFieldPark => 'Parken';

  @override
  String get acctFieldGroupPickup => 'Gruppenheranholung';

  @override
  String get acctFieldDirectedPickup => 'Präfix für gezieltes Heranholen';

  @override
  String get acctFieldParkRetrieve => 'Präfix zum Abholen geparkter Anrufe';

  @override
  String get acctFieldParkRetrieveHint => 'Parkplatznummer wählen';

  @override
  String get acctFieldParkRetrieveSub =>
      'Präfix, das vor dem Parkplatz gewählt wird, um einen geparkten Anruf zurückzuholen';

  @override
  String get acctFieldDndOn => 'Nicht stören ein';

  @override
  String get acctFieldDndOff => 'Nicht stören aus';

  @override
  String get acctFieldForwardOn => 'Umleitung ein';

  @override
  String get acctFieldForwardOff => 'Umleitung aus';

  @override
  String get acctGroupAdvanced => 'Erweitert';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF wird als native IAX2-Frames gesendet.';

  @override
  String get acctFieldCallerIdOverride => 'Anruferkennung überschreiben';

  @override
  String get acctFieldCallerIdHint => 'Kontostandard verwenden';

  @override
  String get acctFieldCallerIdSub =>
      'Name oder Nummer der Anruferkennung, die an die Telefonanlage gesendet wird';

  @override
  String get acctFieldSessionTimers => 'Session-Timer';

  @override
  String get acctFieldSessionExpires => 'Sitzungsablauf (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Bereich 90 bis 86400';

  @override
  String get acctField100rel => '100rel (zuverlässige vorläufige Antworten)';

  @override
  String get acctFieldHoldMethod => 'Halten-Methode';

  @override
  String get acctFieldDtmfMethod => 'DTMF-Methode';

  @override
  String get acctOptDtmfInband => 'In-Band';

  @override
  String get acctFieldRedirects => 'Umleitungen (3xx)';

  @override
  String get acctOptRedirectFollow => 'Folgen';

  @override
  String get acctOptRedirectAsk => 'Nachfragen';

  @override
  String get acctFieldLockCodec => 'Codec nach Annahme fixieren';

  @override
  String get acctFieldMediaKeepAlive => 'Medien-Keep-Alive';

  @override
  String get acctFieldDropCalls =>
      'Anrufe beenden, wenn die Registrierung fehlschlägt';

  @override
  String get acctFieldExtraHeaders => 'Zusätzliche SIP-Header';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: Wert (einer pro Zeile)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Wartezeit vor erneutem Versuch nach fehlgeschlagener Registrierung. Bereich 0 bis 86400';

  @override
  String get acctFieldUnregTimeout => 'Zeitlimit für Abmeldung (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Wie lange auf die Antwort zur Abmeldung gewartet wird. Bereich 0 bis 60000';

  @override
  String get acctFieldMwiExpiry => 'Ablauf des MWI-Abonnements (s)';

  @override
  String get acctFieldDscpSip => 'DSCP für SIP';

  @override
  String get acctFieldDscpSipSub =>
      'QoS-Markierung der Signalisierung. 24 (CS3) ist üblich';

  @override
  String get acctFieldDscpRtp => 'DSCP für RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'QoS-Markierung der Medien. 46 (EF) ist üblich';

  @override
  String get acctFieldReinvite => 'Re-INVITE nach Netzwerkwechsel';

  @override
  String get acctFieldHangupOnIpChange => 'Anrufe bei Netzwerkwechsel beenden';

  @override
  String get acctValidateInt => 'Geben Sie eine ganze Zahl ein';

  @override
  String get acctValidateHostEmpty =>
      'Geben Sie einen Servernamen oder eine Serveradresse ein';

  @override
  String get acctValidateHostSpaces =>
      'Der Server darf keine Leerzeichen enthalten';

  @override
  String get acctValidateHostFormat => 'Nur Host oder Host:Port eingeben';

  @override
  String get acctValidatePortRange =>
      'Der Port muss zwischen 1 und 65535 liegen';

  @override
  String get acctValidateWsStart => 'Der Pfad muss mit \"/\" beginnen';

  @override
  String get acctValidateWsLength => 'Höchstens 120 Zeichen verwenden';

  @override
  String get acctValidateWsSpaces =>
      'Der Pfad darf keine Leerzeichen enthalten';

  @override
  String get acctTplAsteriskDescription =>
      'Nebenstelle an Ihrer eigenen Telefonanlage. UDP 5060, STUN an.';

  @override
  String get acctTplAsteriskNotes =>
      'Verwenden Sie die PJSIP/SIP-Nebenstellennummer und das zugehörige Secret. Für TLS oder WebRTC ändern Sie den Transport später in den Kontoeinstellungen.';

  @override
  String get acctTplAsteriskUsernameHint => 'Nebenstelle (z. B. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Nebenstelle, Auth-ID und Passwort aus dem 3CX-Portal verwenden.';

  @override
  String get acctTpl3cxNotes =>
      'Öffnen Sie in 3CX die Nebenstelle und dann \"Phones > Provisioning\" für die Authentication ID (als Autorisierungsbenutzer eintragen) und das Passwort. Der FQDN ist der aus Ihrer 3CX-URL.';

  @override
  String get acctTpl3cxUsernameHint => 'Nebenstelle';

  @override
  String get acctTplFreeswitchDescription =>
      'Verzeichnisbenutzer auf einem FreeSWITCH-Server.';

  @override
  String get acctTplFreeswitchNotes =>
      'Verwenden Sie die Benutzer-ID und das Passwort aus dem Verzeichnis. Das interne Standardprofil lauscht auf UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'Benutzer-ID';

  @override
  String get acctTplKamailioDescription =>
      'SIP-Proxy-Registrar. Hinter NAT wird TCP empfohlen.';

  @override
  String get acctTplKamailioNotes =>
      'Verwenden Sie die SIP-Domain Ihres Registrars. Fügen Sie in den Kontoeinstellungen einen Outbound-Proxy hinzu, wenn der Registrar über einen anderen Host erreicht wird.';

  @override
  String get acctTplTwilioDescription =>
      'Zugangsdaten einer Programmable-Voice-SIP-Domain. TLS und SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Erstellen Sie in der Twilio-Konsole eine SIP-Domain, fügen Sie eine Credential List hinzu und aktivieren Sie die SIP-Registrierung. Geben Sie die vollständige Domain (name.sip.twilio.com) als Server sowie Benutzer und Passwort der Credential List ein. TLS verwendet Port 5061. Twilio unterstützt nur G.711.';

  @override
  String get acctTplTwilioUsernameHint => 'Benutzername der Credential List';

  @override
  String get acctTplTelnyxDescription =>
      'Credential Connection. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Erstellen Sie im Telnyx-Portal eine Credential Connection und kopieren Sie deren SIP-Benutzernamen und Passwort (nicht Ihre Portal-Anmeldung). Weisen Sie der Verbindung eine Nummer oder ein Outbound Voice Profile zu, um Anrufe zu tätigen und zu empfangen.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP-Benutzername (Credential Connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Benutzername und Passwort eines Unterkontos. Wählen Sie den nächstgelegenen POP.';

  @override
  String get acctTplVoipmsNotes =>
      'Verwenden Sie ein unter Sub Accounts erstelltes Unterkonto, nicht Ihr Hauptkonto. Wählen Sie in der VoIP.ms-Serverliste den nächstgelegenen Server (POP) und geben Sie ihn bei Bedarf für Ihre IP frei.';

  @override
  String get acctTplVoipmsUsernameHint => 'Unterkonto (z. B. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'SIP-Registrierung mit TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business bietet die SIP-Registrierung nur in einigen Tarifen an. Geben Sie den SIP-Server, Benutzer und das Passwort ein, die im Vonage-Admin-Portal für das Gerät angezeigt werden.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange über UDP 4569. Keine NAT- oder SRTP-Einstellungen.';

  @override
  String get acctTplIax2Notes =>
      'Benötigt einen Peer/Benutzer in iax.conf (type=friend oder user+peer) mit demselben Secret. Asterisk erneuert IAX2-Registrierungen standardmäßig alle 60 s. Der Kontext ist optional und wird als angerufener Kontext gesendet.';

  @override
  String get acctTplIax2UsernameHint => 'IAX2-Benutzername';

  @override
  String get acctTplWebrtcDescription =>
      'SIP über sicheres WebSocket mit DTLS-SRTP, ICE und RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Für WebSocket-Endpunkte von Asterisk (webrtc=yes, http.conf TLS auf 8089), FreeSWITCH oder Kamailio. Der Server benötigt ein gültiges TLS-Zertifikat. Ändern Sie den WebSocket-Pfad in den Kontoeinstellungen, wenn Ihr Gateway nicht /ws verwendet.';

  @override
  String get acctTplGenericDescription =>
      'Beliebiger SIP-Registrar. Geben Sie die Daten selbst ein.';

  @override
  String get acctTplDefaultUsernameHint => 'Nebenstelle / Benutzername';

  @override
  String get appEngineFailedBody =>
      'Anrufe und Registrierung funktionieren erst, wenn dies behoben ist. Meist liegt es an einer fehlerhaften Netzwerk- oder Zertifikatseinstellung.';

  @override
  String get appEngineFailedTitle =>
      'Die Anruf-Engine konnte nicht gestartet werden';

  @override
  String get appEngineNotRunning => 'Die Anruf-Engine läuft nicht';

  @override
  String get appUnknownError => 'Unbekannter Fehler';

  @override
  String get appEngineOpenNetworkSettings => 'Netzwerkeinstellungen öffnen';

  @override
  String get appEngineUseSimulator => 'Simulator verwenden (Demo)';

  @override
  String get appDbLockedTitle => 'Ihre Daten sind gesperrt';

  @override
  String get appDbUnreadableTitle => 'Ihre Daten können nicht geöffnet werden';

  @override
  String get appDbLockedBody =>
      'Anrufverlauf, Kontakte und Nachrichten sind auf diesem Gerät verschlüsselt, aber der Schlüssel befindet sich nicht mehr im Schlüsselbund / Keystore des Systems (zum Beispiel nach einem Zurücksetzen des Schlüsselbunds oder einer Wiederherstellung auf einem neuen Gerät).';

  @override
  String get appDbUnreadableBody =>
      'Die lokale Datenbank konnte nicht gelesen werden. Sie ist möglicherweise beschädigt, oder der Schlüssel passt nicht.';

  @override
  String get appDbRecoveryAdvice =>
      'Versuchen Sie es erneut, wenn Sie erwarten, dass der Schlüssel wieder verfügbar wird (Schlüsselbund entsperren, beim richtigen Benutzer anmelden). Bei \"Neu beginnen\" bleibt die alte Datei neben den App-Daten erhalten, aber Verlauf, Kontakte und Nachrichten sind zunächst leer; Ihre Konten müssen Sie erneut hinzufügen.';

  @override
  String get appDbCopyDetails => 'Details kopieren';

  @override
  String get appDbTryAgain => 'Erneut versuchen';

  @override
  String get appDbStartFresh => 'Neu beginnen';

  @override
  String get appRedirectTitle => 'Anruf umgeleitet';

  @override
  String appRedirectMessage(String target) {
    return 'Anruf an $target umgeleitet - folgen?';
  }

  @override
  String get appRedirectCancelCall => 'Anruf abbrechen';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Ihre Daten konnten nicht verschlüsselt werden ($error). Es wurde nichts geändert.',
      'other':
          'Ihre Daten konnten nicht entschlüsselt werden ($error). Es wurde nichts geändert.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Native Engine nicht verfügbar ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Neuer Versuch um $time';
  }

  @override
  String get acctRegistrationError => 'Registrierungsfehler';

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
  String get acctCallingFromDirect => 'Anruf direkt, ohne Konto';

  @override
  String acctCallingFromAccount(String name) {
    return 'Anruf über $name';
  }

  @override
  String get acctCallingFromNone => 'Anruf ohne Konto';

  @override
  String get acctNoAccount => 'Kein Konto';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount neu, $oldCount alt';
  }

  @override
  String get acctAddAccount => 'Konto hinzufügen';

  @override
  String get acctUnregister => 'Abmelden';

  @override
  String get acctSheetDndSub => 'Eingehende Anrufe für dieses Konto abweisen';

  @override
  String get acctKvServer => 'Server';

  @override
  String get acctKvResolvedServer => 'Aufgelöster Server';

  @override
  String get acctKvClientCert => 'Clientzertifikat';

  @override
  String get acctKvClientCertValue =>
      'Wird dem Server vorgelegt (gegenseitiges TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Läuft ab in';

  @override
  String get acctKvVoicemail => 'Mailbox';

  @override
  String get acctOpenSipTrace => 'SIP-Trace öffnen';

  @override
  String get acctAddAnAccount => 'Konto hinzufügen';

  @override
  String get acctChooseAccountTooltip => 'Konto für den Anruf auswählen';

  @override
  String get acctDirectNoAccount => 'Direkt (ohne Konto)';

  @override
  String get onboardingRequired => 'Benutzername und Server sind erforderlich';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Port $port wird verwendet, sofern Sie nicht :Port ergänzen';
  }

  @override
  String get onboardingFineTuneIax =>
      'Codecs und Registrierung können Sie später in den Einstellungen anpassen.';

  @override
  String get onboardingFineTuneSip =>
      'Transport, NAT, Sicherheit und Codecs können Sie später in den Einstellungen anpassen.';

  @override
  String get onboardingDemoUser => 'Demo-Benutzer';

  @override
  String get onboardingDemoAccount => 'Demo-Konto';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Professionelles Telefonieren für jede Plattform - kostenlos und Open Source. Keine Werbung, kein Tracking.';

  @override
  String get onboardingGetStarted => 'Los geht’s';

  @override
  String get onboardingPermissionsTitle => 'Berechtigungen';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro benötigt das Mikrofon, um Ihre Stimme zu übertragen, und Benachrichtigungen, um Sie über eingehende Anrufe und Nachrichten zu informieren. Nichts verlässt Ihr Gerät außer Ihren Anrufen.';

  @override
  String get onboardingChooseProvider => 'Anbieter auswählen';

  @override
  String get onboardingChooseProviderSub =>
      'Transport, Ports und NAT-Einstellungen füllen wir für Sie vor.';

  @override
  String get onboardingScanQr => 'QR scannen';

  @override
  String get onboardingImportUrl => 'Aus URL importieren';

  @override
  String get onboardingSkip => 'Vorerst überspringen (Demomodus)';

  @override
  String get onboardingHidePassword => 'Passwort ausblenden';

  @override
  String get onboardingShowPassword => 'Passwort anzeigen';

  @override
  String get onboardingContextOptional => 'Kontext (optional)';

  @override
  String get onboardingDisplayNameOptional => 'Anzeigename (optional)';

  @override
  String get onboardingLabelOptional => 'Kontobezeichnung (optional)';

  @override
  String get onboardingCallerIdOptional => 'Anruferkennung (optional)';

  @override
  String get onboardingAuthUserOptional =>
      'Autorisierungsbenutzer (falls abweichend)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Falscher Benutzername oder falsches Passwort ($code)';
  }

  @override
  String get acctRegNotFound => 'Konto auf dem Server nicht gefunden (404)';

  @override
  String get acctRegNoAnswer => 'Server hat nicht geantwortet (408)';

  @override
  String get acctRegIntervalTooShort => 'Registrierungsintervall zu kurz (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Server vorübergehend nicht verfügbar (480)';

  @override
  String get acctRegServiceUnavailable => 'Dienst nicht verfügbar (503)';

  @override
  String get acctRegFailed => 'Registrierung fehlgeschlagen';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Registrierung fehlgeschlagen ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Registrierung konnte nicht geändert werden';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Konto \"$name\" konnte nicht angewendet werden';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Wieder auf dem primären Server für $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Ersatzserver für $name in Verwendung';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'Konto $name ist registriert';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'Konto $name wird noch registriert';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'Konto $name ist noch nicht registriert';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'Konto $name ist nicht registriert (Registrierung fehlgeschlagen)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'Konto $name ist deaktiviert';
  }

  @override
  String get callDialEngineFailed =>
      'Die Anruf-Engine konnte nicht gestartet werden';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'Die Anruf-Engine konnte nicht gestartet werden: $reason';
  }

  @override
  String get callDialEngineStarting => 'Die Anruf-Engine startet noch';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status nach $seconds s; der Anruf wurde nicht aufgebaut';
  }

  @override
  String get callJournalInterrupted =>
      'Die App wurde während des Anrufs geschlossen';

  @override
  String get callLinkMissingArgument => 'Argument fehlt';

  @override
  String get callLinkHttpsRequired =>
      'Konfigurationslinks müssen https verwenden';

  @override
  String get callLinkInvalidLan => 'Dieser LAN-Link ist ungültig';

  @override
  String callLinkConnectedTo(String name) {
    return 'Verbunden mit $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Verbindung zu diesem Gerät nicht möglich';

  @override
  String callLinkCallFailed(String target) {
    return 'Anruf an $target konnte nicht aufgebaut werden';
  }

  @override
  String get callLinkImportTitle => 'Konfiguration importieren';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: 'werden $accounts Konten',
      one: 'wird 1 Konto',
    );
    return 'Konfiguration von $host importieren? Es $_temp0 hinzugefügt.';
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
      other: 'werden $accounts Konten',
      one: 'wird 1 Konto',
    );
    return 'Konfiguration von $host importieren? Es $_temp0 und $settings Einstellung(en) hinzugefügt.';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Umgeleitet von $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Umgeleitet von $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Weiterverbunden von $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Systemstandard';

  @override
  String get callRingtoneClassic => 'Klassisch';

  @override
  String get callRingtoneSoft => 'Sanft';

  @override
  String get callRingtoneDigital => 'Digital';

  @override
  String callIdentityFrom(String number) {
    return 'Von $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Anruferkennung $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Anruferkennung $name $number';
  }

  @override
  String get callTransferring => 'Wird weiterverbunden...';

  @override
  String get callTransferNotConfirmed =>
      'Weiterverbinden vom Server nicht bestätigt';

  @override
  String get callTransferStalledHint =>
      'Der Anruf besteht noch. Behalten Sie ihn oder senden Sie das Weiterverbinden erneut.';

  @override
  String get callTransferKeepCall => 'Anruf behalten';

  @override
  String get callAnnouncementOpening => 'Ansage wird abgespielt…';

  @override
  String get callAnnouncementTransfer =>
      'Hinweis zum Weiterverbinden wird abgespielt…';

  @override
  String get callAnnouncementRecording =>
      'Aufzeichnungshinweis wird abgespielt…';

  @override
  String get callAnnouncementSkip => 'Überspringen';

  @override
  String get callNoiseTooltipMic => 'KI-Geräuschunterdrückung: Ihr Mikrofon';

  @override
  String get callNoiseTooltipIncoming =>
      'KI-Geräuschunterdrückung: andere Teilnehmer';

  @override
  String get callNoiseTooltipBoth =>
      'KI-Geräuschunterdrückung: Ihr Mikrofon und andere Teilnehmer';

  @override
  String get callNoiseOn => 'Geräuschunterdrückung an';

  @override
  String get callNoiseTitle => 'Geräuschunterdrückung';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Mein Mikrofon: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Hintergrundgeräusche vom Mikrofon entfernen';

  @override
  String get callResultAnswered => 'Angenommen';

  @override
  String get callResultMissed => 'Verpasst';

  @override
  String get callResultRejected => 'Abgelehnt';

  @override
  String get callResultFailed => 'Fehlgeschlagen';

  @override
  String get callResultBusy => 'Besetzt';

  @override
  String get callResultForwarded => 'Umgeleitet';

  @override
  String get callResultTransferred => 'Weiterverbunden';

  @override
  String get callResultHandedOff => 'Übergeben';

  @override
  String get callResultInterrupted => 'Unterbrochen';

  @override
  String get keypadCall => 'Anrufen';

  @override
  String get keypadNoVoicemail =>
      'Für dieses Konto ist keine Mailbox-Nummer festgelegt';

  @override
  String get keypadCallDirectly => 'Direkt anrufen (ohne Konto)';

  @override
  String get keypadAddAccount => 'Konto hinzufügen, um Anrufe zu tätigen';

  @override
  String keypadCallFrom(String account) {
    return 'Anrufen über $account';
  }

  @override
  String get keypadRecent => 'Zuletzt';

  @override
  String get keypadSuggestions => 'Vorschläge';

  @override
  String get keypadPhoneNumber => 'Telefonnummer';

  @override
  String get keypadPaste => 'Einfügen';

  @override
  String get keypadEnterNumber => 'Nummer eingeben';

  @override
  String get keypadBackspace => 'Löschen (lange drücken zum Leeren)';

  @override
  String get keypadTypeNameOrNumber => 'Namen oder Nummer eingeben';

  @override
  String get keypadNoMatches => 'Keine Treffer';

  @override
  String get keypadSuggestionsHint =>
      'Vorschläge stammen aus Kontakten und letzten Anrufen';

  @override
  String keypadCallPerson(String name) {
    return '$name anrufen';
  }

  @override
  String get dialKeyStar => 'Stern';

  @override
  String get dialKeyPound => 'Raute';

  @override
  String get dialKeyLongPressPlus => 'Lange drücken für Plus';

  @override
  String get dialKeyLongPressSpeedDial => 'Lange drücken für Kurzwahl';

  @override
  String get dialKeyLongPressVoicemail => 'Lange drücken für Mailbox';

  @override
  String get callBackToApp => 'Zurück zur App (Anruf bleibt aktiv)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Tastatur ausblenden';

  @override
  String get callMute => 'Stumm';

  @override
  String get callKeypad => 'Tastatur';

  @override
  String get callSpeaker => 'Lautsprecher';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Headset';

  @override
  String get callResume => 'Fortsetzen';

  @override
  String get callHold => 'Halten';

  @override
  String get callAddCall => 'Anruf hinzufügen';

  @override
  String get callTransfer => 'Vermitteln';

  @override
  String get callStop => 'Stopp';

  @override
  String get callRecord => 'Aufnehmen';

  @override
  String get callSplit => 'Trennen';

  @override
  String get callMerge => 'Verbinden';

  @override
  String get callSwap => 'Wechseln';

  @override
  String get callEndCall => 'Auflegen';

  @override
  String callEndCallWith(String name) {
    return 'Anruf mit $name beenden';
  }

  @override
  String get callAttendedTransferHint =>
      'Weiterverbinden mit Rückfrage. Der ursprüngliche Anrufer ist gehalten.';

  @override
  String get callCompleteTransfer => 'Weiterverbinden abschließen';

  @override
  String get callWaiting => 'Anklopfen';

  @override
  String get callHoldAndAnswer => 'Aktuellen Anruf halten und annehmen';

  @override
  String get callDecline => 'Ablehnen';

  @override
  String get callAnswer => 'Annehmen';

  @override
  String get callIncomingCall => 'Eingehender Anruf';

  @override
  String get callReply => 'Antworten';

  @override
  String get callVoicemail => 'Mailbox';

  @override
  String get callToDevice => 'Zu Gerät';

  @override
  String get callQuickReplyBusy =>
      'Kann gerade nicht sprechen, ich rufe zurück.';

  @override
  String get callQuickReplyMeeting =>
      'Ich bin in einer Besprechung. Bitte per Nachricht melden.';

  @override
  String get callQuickReplyOnMyWay => 'Bin unterwegs.';

  @override
  String callReturnToCallWith(String name) {
    return 'Zurück zum Anruf mit $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Eingehend: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'Im Gespräch mit $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Paketverlust';

  @override
  String get callStatsRoundTrip => 'Laufzeit';

  @override
  String get callStatsMedia => 'Medien';

  @override
  String get callStatsMosHistory => 'MOS-Verlauf';

  @override
  String get callQualityTitle => 'Anrufqualität';

  @override
  String get callTransferTitle => 'Anruf weiterverbinden';

  @override
  String get callTransferModeBlind => 'Direkt';

  @override
  String get callTransferModeAttended => 'Mit Rückfrage';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN-Gerät';

  @override
  String get callTransferNoLanDevices =>
      'Keine gekoppelten SoftphonePro-Geräte in Ihrem Netzwerk gefunden. Koppeln Sie eines auf der LAN-Seite.';

  @override
  String get callTransferLanDisabled =>
      'Aktivieren Sie LAN Link (Einstellungen, LAN Link), um diesen Anruf an ein anderes Gerät in Ihrem Netzwerk zu übergeben.';

  @override
  String get callTransferTalkFirst => 'Erst sprechen';

  @override
  String get callTransferBlindHint =>
      'Übergibt den Anrufer sofort. Ihre Verbindung wird getrennt.';

  @override
  String get callTransferAttendedHint =>
      'Hält den Anrufer und ruft zuerst das Ziel an. Schließen Sie das Weiterverbinden ab, sobald es sich meldet.';

  @override
  String get callTransferNumberLabel => 'Nummer oder SIP-Adresse';

  @override
  String get callTransferNow => 'Jetzt vermitteln';

  @override
  String get callTransferCallAndConsult => 'Anrufen und Rücksprache';

  @override
  String get callRetrieveParkedTitle => 'Geparkten Anruf abholen';

  @override
  String get callRetrieveParkedHint => 'Parkplatz, z. B. 701';

  @override
  String get callMoreAudioOutput => 'Audioausgabe';

  @override
  String get callMoreAudioDevices => 'Audiogeräte';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefon, Lautsprecher, Bluetooth, Headset';

  @override
  String get callMoreAudioDevicesSubtitle => 'Mikrofon und Lautsprecher wählen';

  @override
  String get callMoreParkCall => 'Anruf parken';

  @override
  String get callMoreParkCallSubtitle => 'Zur Parken-Kennzahl vermitteln';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Parkplatz wählen';

  @override
  String get callMoreSendDtmf => 'DTMF-Ziffern senden';

  @override
  String get callMoreSendDtmfSubtitle => 'Ganze Folge eingeben, z. B. eine PIN';

  @override
  String get callSendDtmfTitle => 'DTMF senden';

  @override
  String get callMoreCallInfo => 'Anrufinfo';

  @override
  String get callMoreQualitySubtitle =>
      'Live-MOS, Jitter, Verlust und Laufzeit';

  @override
  String get callMoreSipTrace => 'SIP-Trace';

  @override
  String get callMoreSipTraceSubtitle => 'Ablaufdiagramm dieses Anrufs';

  @override
  String get callInfoRemote => 'Gegenstelle';

  @override
  String get callInfoAccount => 'Konto';

  @override
  String get callInfoState => 'Status';

  @override
  String get callInfoSecure => 'Gesichert';

  @override
  String get callInfoPlainSignalling => 'unverschlüsselte Signalisierung';

  @override
  String get callRoutePhone => 'Telefon';

  @override
  String get callRouteWiredHeadset => 'Kabel-Headset';

  @override
  String get callAudioMicrophone => 'Mikrofon';

  @override
  String callCardSemantics(String name, String state) {
    return 'Anruf mit $name, $state';
  }

  @override
  String get callUnmute => 'Stummschaltung aufheben';

  @override
  String get callStopRecording => 'Aufzeichnung beenden';

  @override
  String get callSplitConference => 'Konferenz trennen';

  @override
  String get callMergeCalls => 'Anrufe zusammenführen';

  @override
  String get callSwapCalls => 'Anrufe wechseln';

  @override
  String get callAttendedTransferBanner =>
      'Weiterverbinden mit Rückfrage: Der ursprüngliche Anrufer ist gehalten.';

  @override
  String get callActiveCalls => 'Aktive Anrufe';

  @override
  String get callConferenceLevels => 'Konferenzpegel';

  @override
  String get callLevelVolume => 'Lautstärke';

  @override
  String get callLevelMicToParty => 'Mikrofon zu Teilnehmer';

  @override
  String callPercentSemantics(int percent) {
    return '$percent Prozent';
  }

  @override
  String get callFailInvalidNumber => 'Ungültige Nummer (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Anruf nicht autorisiert ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Nummer nicht gefunden (404)';

  @override
  String get callFailNoAnswerFromServer => 'Keine Antwort vom Server (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Vorübergehend nicht erreichbar (480)';

  @override
  String get callFailIncompleteNumber => 'Unvollständige Nummer (484)';

  @override
  String callFailBusy(String code) {
    return 'Besetzt ($code)';
  }

  @override
  String get callFailCancelled => 'Anruf abgebrochen (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Kein kompatibler Codec ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Dienst nicht verfügbar (503)';

  @override
  String get callFailDeclined => 'Anruf abgelehnt (603)';

  @override
  String get callFailGeneric => 'Anruf fehlgeschlagen';

  @override
  String callFailGenericWithCode(String code) {
    return 'Anruf fehlgeschlagen ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Anruf läuft';

  @override
  String get callTrayInCall => 'Im Gespräch';

  @override
  String get callHistoryBlocked => 'Gesperrt';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonymität nicht zugelassen';

  @override
  String get callHistoryDoNotDisturb => 'Nicht stören';

  @override
  String get callHistoryBusy => 'Besetzt';

  @override
  String get callHistoryForwardedAlways => 'Umgeleitet (immer)';

  @override
  String get callHistoryForwardedBusy => 'Umgeleitet (besetzt)';

  @override
  String get callHistorySentToVoicemail => 'An Mailbox gesendet';

  @override
  String get callHistoryRedirected => 'Weitergeleitet';

  @override
  String get callIncomingNotificationBody => 'Eingehender Anruf';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Eingehender Anruf auf $account';
  }

  @override
  String get callMissedNotificationTitle => 'Verpasster Anruf';

  @override
  String get callErrEngineNotRunning => 'Die Anruf-Engine läuft noch nicht';

  @override
  String get callErrAddAccount => 'Konto hinzufügen, um Anrufe zu tätigen';

  @override
  String get callErrCouldNotPlace => 'Anruf konnte nicht aufgebaut werden';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account ist nicht registriert';
  }

  @override
  String get callErrCouldNotAnswer => 'Annahme nicht möglich';

  @override
  String get callErrNoVoicemailNumber =>
      'Für dieses Konto ist keine Mailbox-Nummer festgelegt';

  @override
  String get callErrTransferFailed => 'Weiterverbinden fehlgeschlagen';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Weiterverbinden fehlgeschlagen: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge =>
      'Anrufe konnten nicht zusammengeführt werden';

  @override
  String get callErrCouldNotStartRecording =>
      'Aufzeichnung konnte nicht gestartet werden';

  @override
  String get callErrCouldNotStopRecording =>
      'Aufzeichnung konnte nicht beendet werden';

  @override
  String callParkingNotice(String code) {
    return 'Anruf wird geparkt (wählen: $code)';
  }

  @override
  String get callErrParkFailed => 'Parken fehlgeschlagen';

  @override
  String get callErrHandoffFailed => 'Übergabe fehlgeschlagen';

  @override
  String get callErrCouldNotSendToDevice => 'Senden an das Gerät nicht möglich';

  @override
  String get callHistoryForwardedNoAnswer => 'Umgeleitet (keine Antwort)';

  @override
  String get shellTabKeypad => 'Tastatur';

  @override
  String get shellTabRecents => 'Anrufe';

  @override
  String get shellTabContacts => 'Kontakte';

  @override
  String get shellTabMessages => 'Nachrichten';

  @override
  String get shellTabPresence => 'Präsenz';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Aufzeichnungen';

  @override
  String get shellSearchSemantics =>
      'Kontakte und Verlauf durchsuchen oder Nummer wählen';

  @override
  String get shellSearchHint => 'Suchen oder wählen';

  @override
  String get shellVoicemailTooltip => 'Mailbox';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count neue Mailbox-Nachrichten. Klicken, um die Mailbox anzurufen',
      one: '1 neue Mailbox-Nachricht. Klicken, um die Mailbox anzurufen',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Abwesend';

  @override
  String get shellStatusTooltip => 'Ihr Status';

  @override
  String get shellDemoBanner =>
      'Demomodus: Anrufe werden simuliert, nichts erreicht ein echtes Netzwerk.';

  @override
  String get uiToday => 'Heute';

  @override
  String get uiYesterday => 'Gestern';

  @override
  String get uiUnknownCaller => 'Unbekannter Anrufer';

  @override
  String get uiCallEnded => 'Anruf beendet';

  @override
  String get uiCallTransferNotConfirmed => 'Weiterverbinden nicht bestätigt';

  @override
  String get uiCallTransferring => 'Wird weiterverbunden...';

  @override
  String get uiCallConference => 'Konferenz';

  @override
  String get uiCallOnHold => 'Gehalten';

  @override
  String get uiCallHeldByRemote => 'Von Gegenstelle gehalten';

  @override
  String get uiCallCalling => 'Anruf läuft...';

  @override
  String get uiCallRinging => 'Es klingelt...';

  @override
  String get uiCallConnecting => 'Verbindung wird aufgebaut...';

  @override
  String get uiCallIncoming => 'Eingehender Anruf';

  @override
  String get uiCallConnected => 'Verbunden';

  @override
  String get uiQrScanTitle => 'QR-Code scannen';

  @override
  String get uiQrPasteHint => 'Code-Text einfügen';

  @override
  String get uiQrNoCamera =>
      'Das Scannen per Kamera ist auf diesem Gerät nicht verfügbar. Fügen Sie stattdessen den Code-Text ein.';

  @override
  String get uiQrPaste => 'Einfügen';

  @override
  String get uiQrUse => 'Verwenden';

  @override
  String get uiQrCameraDenied =>
      'Der Kamerazugriff ist deaktiviert. Erlauben Sie ihn in den Systemeinstellungen oder fügen Sie unten den Code-Text ein.';

  @override
  String get uiQrCameraUnavailable =>
      'Die Kamera ist nicht verfügbar. Fügen Sie unten den Code-Text ein.';

  @override
  String get presenceLampRinging => 'Klingelt';

  @override
  String get presenceHeader => 'Besetztlampenfeld';

  @override
  String get presenceChooseTooltip => 'Kontakte zur Überwachung auswählen';

  @override
  String get presenceEmptyTitle => 'Keine Nebenstellen im Feld';

  @override
  String get presenceEmptySubtitle =>
      'Aktivieren Sie bei einem Kontakt \"Im BLF-Feld anzeigen\", um zu sehen, ob er frei ist, klingelt oder besetzt ist.';

  @override
  String get presenceOpenContacts => 'Kontakte öffnen';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Tippen zum Anrufen, lange drücken für mehr';
  }

  @override
  String presenceCallName(String name) {
    return '$name anrufen';
  }

  @override
  String get presencePickup => 'Diese Nebenstelle heranholen';

  @override
  String get presencePickupSub =>
      'Den klingelnden Anruf annehmen (gezieltes Heranholen)';

  @override
  String get presenceTransferHere => 'Aktuellen Anruf hierher vermitteln';

  @override
  String get presenceRemove => 'Aus dem Feld entfernen';

  @override
  String get uiCall => 'Anrufen';

  @override
  String get uiMessage => 'Nachricht';

  @override
  String get recentsSearchTooltip => 'Verlauf durchsuchen';

  @override
  String get recentsClearTitle => 'Anrufverlauf löschen?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Einträge werden gelöscht.',
      one: '1 Eintrag wird gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'Verlauf als CSV in die Zwischenablage kopiert';

  @override
  String get recentsMenuCopyCsv => 'Als CSV kopieren';

  @override
  String get recentsMenuClear => 'Verlauf löschen';

  @override
  String get recentsSearchHint => 'Name oder Nummer suchen';

  @override
  String get recentsFilterAll => 'Alle';

  @override
  String get recentsFilterMissed => 'Verpasst';

  @override
  String get recentsFilterIncoming => 'Eingehend';

  @override
  String get recentsFilterOutgoing => 'Ausgehend';

  @override
  String get recentsFilterAccount => 'Nach Konto filtern';

  @override
  String get recentsAllAccounts => 'Alle Konten';

  @override
  String get recentsAccountFallback => 'Konto';

  @override
  String get recentsEmptyNone => 'Noch keine Anrufe';

  @override
  String get recentsEmptyNoMatch => 'Keine passenden Anrufe';

  @override
  String get recentsEmptyNoneSub => 'Ihre Anrufe erscheinen hier.';

  @override
  String get recentsEmptyNoMatchSub => 'Versuchen Sie einen anderen Filter.';

  @override
  String get recentsOpenKeypad => 'Tastatur öffnen';

  @override
  String get recentsShowAll => 'Alle anzeigen';

  @override
  String get recentsSelectCall => 'Anruf auswählen';

  @override
  String get recentsSelectCallSub =>
      'Details, Qualität und Aufzeichnungen erscheinen hier.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Verpasster Anruf',
      'incoming': 'Eingehender Anruf',
      'other': 'Ausgehender Anruf',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '$name anrufen';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Konto hinzufügen, um Nachrichten zu senden';

  @override
  String get recentsAddContact => 'Kontakt hinzufügen';

  @override
  String get recentsContact => 'Kontakt';

  @override
  String get recentsBlock => 'Sperren';

  @override
  String get recentsUnblock => 'Entsperren';

  @override
  String recentsBlockTitle(String number) {
    return '$number sperren?';
  }

  @override
  String get recentsBlockMessage =>
      'Anrufe von dieser Nummer werden automatisch abgewiesen.';

  @override
  String get recentsQualityHeader => 'Anrufqualität';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Schlechtester MOS $mos   ·   Jitter $jitter ms   ·   Verlust $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Aufzeichnungen';

  @override
  String get recentsOpenInRecordings => 'In Aufzeichnungen öffnen';

  @override
  String recentsRelatedCall(String title) {
    return 'Zugehöriger Anruf: $title';
  }

  @override
  String get recentsHistoryHeader => 'Verlauf';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Keine Anrufe mit dieser Nummer';

  @override
  String get recentsDeleteTitle => 'Diese Anrufe löschen?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entfernt $count Einträge für $name.',
      one: 'Entfernt 1 Eintrag für $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Aus dem Verlauf löschen';

  @override
  String get recentsCallDetails => 'Anrufdetails';

  @override
  String get contactsFavoritesHeader => '★ Favoriten';

  @override
  String get contactsFavoritesOnly => 'Nur Favoriten';

  @override
  String get contactsShowAll => 'Alle anzeigen';

  @override
  String get contactsImportExportTooltip => 'Import und Export';

  @override
  String get contactsMenuDevice => 'Vom Gerät importieren';

  @override
  String get contactsMenuFile => 'vCard-/CSV-Datei importieren';

  @override
  String get contactsMenuClipboard => 'Aus Zwischenablage importieren';

  @override
  String get contactsMenuCopyVcard => 'Als vCard kopieren';

  @override
  String get contactsMenuCopyCsv => 'Als CSV kopieren';

  @override
  String get contactsNewTooltip => 'Neuer Kontakt';

  @override
  String get contactsSearchHint => 'Kontakte suchen';

  @override
  String get contactsEmptyTitle => 'Noch keine Kontakte';

  @override
  String get contactsEmptySubtitle =>
      'Fügen Sie Personen hinzu, die Sie oft anrufen, oder importieren Sie eine vCard- oder CSV-Datei.';

  @override
  String get contactsEmptyAction => 'Kontakt hinzufügen';

  @override
  String get contactsNoMatches => 'Keine Treffer';

  @override
  String contactsCallName(String name) {
    return '$name anrufen';
  }

  @override
  String get contactsSelect => 'Kontakt auswählen';

  @override
  String get contactsCopiedVcard => 'Kontakte als vCard kopiert';

  @override
  String get contactsCopiedCsv => 'Kontakte als CSV kopiert';

  @override
  String get contactsDeviceDenied =>
      'Der Zugriff auf Kontakte wurde verweigert. Erlauben Sie ihn für den Import in den Systemeinstellungen.';

  @override
  String get contactsDeviceNone =>
      'Auf diesem Gerät wurden keine Kontakte gefunden';

  @override
  String contactsNothingNew(int count) {
    return 'Nichts Neues zu importieren ($count bereits vorhanden)';
  }

  @override
  String get contactsImportDeviceTitle => 'Vom Gerät importieren?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Kontakte',
      one: '1 neuer Kontakt',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count mit zusätzlichen Nummern aktualisiert';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count übersprungen (Duplikate oder keine Telefonnummer)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte importiert',
      one: '1 Kontakt importiert',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone =>
      'In diesen Daten wurden keine Kontakte gefunden';

  @override
  String get contactsLabelMobile => 'mobil';

  @override
  String get contactsLabelWork => 'geschäftlich';

  @override
  String get contactsLabelHome => 'privat';

  @override
  String get contactsLabelOther => 'sonstige';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Kontakt nicht gefunden';

  @override
  String get contactsActionFavorite => 'Favorit';

  @override
  String get contactsNumbersHeader => 'Nummern';

  @override
  String get contactsSipAddress => 'SIP-Adresse';

  @override
  String get contactsDetailsHeader => 'Details';

  @override
  String get contactsOnBlf => 'Im BLF-Feld angezeigt';

  @override
  String get contactsAlwaysRecorded => 'Anrufe werden immer aufgezeichnet';

  @override
  String contactsDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get contactsDeleteMessage =>
      'Dieser Kontakt wird von diesem Gerät entfernt.';

  @override
  String get contactsDeleteButton => 'Kontakt löschen';

  @override
  String get contactsDetailTitle => 'Kontakt';

  @override
  String get contactsErrorNameOrNumber =>
      'Geben Sie einen Namen oder eine Nummer ein';

  @override
  String get contactsEditTitle => 'Kontakt bearbeiten';

  @override
  String get contactsFieldName => 'Name';

  @override
  String get contactsFieldCompany => 'Firma';

  @override
  String get contactsFieldNumber => 'Nummer';

  @override
  String get contactsRemoveNumber => 'Nummer entfernen';

  @override
  String get contactsAddNumber => 'Nummer hinzufügen';

  @override
  String get contactsSipHeader => 'SIP-Adressen';

  @override
  String get contactsRemoveAddress => 'Adresse entfernen';

  @override
  String get contactsAddSip => 'SIP-Adresse hinzufügen';

  @override
  String get contactsFieldEmail => 'E-Mail';

  @override
  String get contactsFieldNotes => 'Notizen';

  @override
  String get contactsFieldFavorite => 'Favorit';

  @override
  String get contactsShowOnBlf => 'Im BLF-Feld anzeigen';

  @override
  String get contactsShowOnBlfSub =>
      'Präsenz und Besetztlampe dieser Nebenstelle überwachen';

  @override
  String get contactsAlwaysRecordTitle =>
      'Anrufe mit diesem Kontakt immer aufzeichnen';

  @override
  String get contactsAlwaysRecordSub =>
      'Überschreibt die Regeln zur automatischen Aufzeichnung';

  @override
  String get contactsRingtone => 'Klingelton';

  @override
  String get contactsPresenceVia => 'Präsenz über Konto';

  @override
  String get contactsDefaultAccount => 'Standardkonto';

  @override
  String get contactsDeleteContactTitle => 'Kontakt löschen?';

  @override
  String get contactsCannotUndo => 'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get messagesNewMessage => 'Neue Nachricht';

  @override
  String get messagesNumberOrSip => 'Nummer oder SIP-Adresse';

  @override
  String get messagesNoConversations => 'Keine Unterhaltungen';

  @override
  String get messagesEmptySubtitle =>
      'Senden Sie eine SIP-Nachricht an eine beliebige Nebenstelle oder Adresse über Ihre Konten.';

  @override
  String get messagesTyping => 'schreibt...';

  @override
  String get messagesYouPrefix => 'Sie: ';

  @override
  String get messagesSelect => 'Unterhaltung auswählen';

  @override
  String get messagesLanOnline => 'In Ihrem Netzwerk online';

  @override
  String get messagesLanOffline =>
      'Offline. Nachrichten werden gesendet, sobald das Gerät wieder erreichbar ist.';

  @override
  String messagesSendFileTo(String name) {
    return 'Datei an $name senden';
  }

  @override
  String messagesCallName(String name) {
    return '$name anrufen';
  }

  @override
  String get messagesDeleteTitle => 'Unterhaltung löschen?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Alle Nachrichten mit $name werden entfernt.';
  }

  @override
  String get messagesDeleteMenu => 'Unterhaltung löschen';

  @override
  String get messagesSayHello => 'Sagen Sie Hallo';

  @override
  String get messagesLanEmptySub =>
      'Nachrichten gehen direkt über Ihr Netzwerk an dieses Gerät, Ende-zu-Ende-verschlüsselt.';

  @override
  String get messagesSipEmptySub =>
      'Nachrichten werden per SIP MESSAGE über Ihr Konto gesendet.';

  @override
  String get messagesInputHint => 'Nachricht';

  @override
  String get messagesSend => 'Senden';

  @override
  String get messagesStatusSending => 'Wird gesendet';

  @override
  String get messagesStatusSent => 'Gesendet';

  @override
  String get messagesStatusDelivered => 'Zugestellt';

  @override
  String get messagesStatusRead => 'Gelesen';

  @override
  String get messagesStatusFailed => 'Fehlgeschlagen';

  @override
  String get messagesNotDelivered => 'Nicht zugestellt. Zum Wiederholen tippen';

  @override
  String get uiStatusRegistered => 'Registriert';

  @override
  String get uiStatusRegistering => 'Wird registriert';

  @override
  String get uiStatusRegFailed => 'Registrierung fehlgeschlagen';

  @override
  String get uiStatusDisabled => 'Deaktiviert';

  @override
  String get uiQualityMeasuring => 'Wird gemessen';

  @override
  String get uiQualityExcellent => 'Ausgezeichnet';

  @override
  String get uiQualityGood => 'Gut';

  @override
  String get uiQualityFair => 'Befriedigend';

  @override
  String get uiQualityPoor => 'Schwach';

  @override
  String get uiQualityBad => 'Schlecht';

  @override
  String uiQualitySemantics(String label) {
    return 'Anrufqualität $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Anrufqualität $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Anrufqualität: $label';
  }

  @override
  String get uiSecureFull => 'Verschlüsselt';

  @override
  String get uiSecureMedia => 'Medien verschlüsselt';

  @override
  String get uiSecureSignalling => 'Signalisierung verschlüsselt';

  @override
  String get uiSecureNone => 'Nicht verschlüsselt';

  @override
  String get uiSecureSrtpLine => 'SRTP-Medien';

  @override
  String get uiSecureTlsLine => 'TLS-Signalisierung';

  @override
  String lanCallHandingOver(String name) {
    return 'Übergabe an $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Gegensprechen mit $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Gegensprechen mit einem Gerät in der Nähe';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Gegensprechen von $name';
  }

  @override
  String get lanCallIntercomFromUnnamed =>
      'Gegensprechen von einem Gerät in der Nähe';

  @override
  String lanCallToNamed(String name) {
    return 'LAN-Anruf an $name';
  }

  @override
  String get lanCallToUnpaired => 'LAN-Anruf an ein nicht gekoppeltes Gerät';

  @override
  String lanCallFromNamed(String name) {
    return 'LAN-Anruf von $name';
  }

  @override
  String get lanCallFromUnpaired =>
      'LAN-Anruf von einem nicht gekoppelten Gerät';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Übergebener Anruf von $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Übergebener Anruf von $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'einem anderen Gerät';

  @override
  String lanRelayedTitle(String name) {
    return 'An $name weitergeleitet';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Der Anrufer spricht mit $name. Sie sind nicht mehr im Gespräch.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '$name wird angerufen...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Der Anrufer bleibt verbunden, während $name sich meldet.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '$name wird gefragt...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Warten auf die Annahme des Anrufs.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Gespräch mit $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Der Anrufer ist gehalten. Schließen Sie die Übergabe ab, wenn Sie bereit sind.';

  @override
  String get lanRelayTakingBack => 'Anruf wird zurückgeholt...';

  @override
  String get lanRelayTakeBack => 'Zurückholen';

  @override
  String get lanRelayEnd => 'Beenden';

  @override
  String get lanSendToDevice => 'An Gerät senden';

  @override
  String get lanBusy => 'Besetzt';

  @override
  String get lanNoPairedOnline => 'Kein gekoppeltes Gerät ist online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name hat die Kopplung abgelehnt.';
  }

  @override
  String get lanPairRejected => 'Kopplung abgelehnt.';

  @override
  String get lanPairCancelled => 'Kopplung abgebrochen.';

  @override
  String get lanPairTimedOut =>
      'Zeitüberschreitung bei der Kopplung. Bitte erneut versuchen.';

  @override
  String get lanPairFailed => 'Kopplung fehlgeschlagen';

  @override
  String lanPairFailedReason(String reason) {
    return 'Kopplung fehlgeschlagen: $reason';
  }

  @override
  String get lanPairThisDevice => 'diesem Gerät';

  @override
  String get lanPairConnecting => 'Sichere Verbindung wird aufgebaut...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name möchte sich mit diesem Gerät koppeln.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Kopplung mit $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Prüfen Sie, ob dieser Code auf beiden Bildschirmen identisch ist.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Kopplungscode $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Warten auf Bestätigung von $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name hat bestätigt.';
  }

  @override
  String get lanPairReject => 'Ablehnen';

  @override
  String get lanPairCodesMatch => 'Codes stimmen überein';

  @override
  String lanPairPairedWith(String name) {
    return 'Mit $name gekoppelt.';
  }

  @override
  String get lanPairRequestTitle => 'Kopplungsanfrage';

  @override
  String lanPairTitle(String name) {
    return 'Mit $name koppeln';
  }

  @override
  String get lanActionDecline => 'Ablehnen';

  @override
  String get lanActionAccept => 'Annehmen';

  @override
  String get lanFileIncomingTitle => 'Eingehende Datei';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size von $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Anruf hierher übergeben?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' von $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' auf $account',
    });
    return '$device möchte Ihnen einen Anruf$_temp0$_temp1 übergeben.';
  }

  @override
  String get lanHandoffOfferAttended => 'Er oder sie spricht zuerst mit Ihnen.';

  @override
  String get lanHandoffTakeCall => 'Anruf übernehmen';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Gegensprechen von $name erlauben?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Der Anruf wird automatisch auf Lautsprecher angenommen.';

  @override
  String get lanIntercomDeny => 'Verweigern';

  @override
  String get lanIntercomAllow => 'Erlauben';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name hat dieses Gerät aus seiner Liste gekoppelter Geräte entfernt';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien werden gesendet...',
      one: '$name wird gesendet...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Neue Nachricht';

  @override
  String get lanSipMessage => 'SIP-Nachricht';

  @override
  String get lanSipMessageSub => 'An eine Nummer oder Adresse über Ihr Konto';

  @override
  String get lanChatOnline => 'LAN-Chat, online';

  @override
  String get lanChatOffline => 'LAN-Chat, offline';

  @override
  String lanSavedAt(String path) {
    return 'Gespeichert unter $path (Pfad kopiert)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Ihre Geräte, direkt verbunden';

  @override
  String get lanConnectByAddress => 'Per Adresse verbinden';

  @override
  String get lanSettingsTooltip => 'LAN-Einstellungen';

  @override
  String get lanOffTitle => 'LAN Link ist aus';

  @override
  String get lanOffSubtitle =>
      'Finden Sie Ihre anderen SoftphonePro-Geräte, chatten Sie, tauschen Sie Dateien aus und übergeben Sie Anrufe, ganz ohne Server.';

  @override
  String get lanTurnOn => 'LAN Link aktivieren';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link konnte nicht gestartet werden: $error';
  }

  @override
  String get lanConnectHelp =>
      'Geben Sie Host:Port ein oder fügen Sie den Text des QR-Codes ein, der auf dem anderen Gerät angezeigt wird.';

  @override
  String get lanScanTitle => 'LAN-Kopplungs-QR scannen';

  @override
  String get lanScanQr => 'QR scannen';

  @override
  String get lanPaste => 'Einfügen';

  @override
  String get lanConnect => 'Verbinden';

  @override
  String lanConnectedTo(String name) {
    return 'Verbunden mit $name';
  }

  @override
  String get lanCouldNotConnect => 'Verbindung nicht möglich';

  @override
  String get lanCouldNotStartPairing =>
      'Kopplung konnte nicht gestartet werden';

  @override
  String get lanThisDevice => 'Dieses Gerät';

  @override
  String get lanDeviceNameTitle => 'Gerätename';

  @override
  String get lanStarting => 'Wird gestartet...';

  @override
  String get lanVisible => 'In Ihrem Netzwerk sichtbar';

  @override
  String get lanNotRunning => 'Nicht aktiv';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konten geteilt',
      one: '1 Konto geteilt',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Fingerabdruck';

  @override
  String get lanHideQr => 'QR-Code ausblenden';

  @override
  String get lanShowQr =>
      'QR-Code zum Verbinden eines weiteren Geräts anzeigen';

  @override
  String get lanCopyConnectionText => 'Verbindungstext kopieren';

  @override
  String get lanConnectionTextCopied => 'Verbindungstext kopiert';

  @override
  String get lanActiveOnOthers => 'Aktiv auf Ihren anderen Geräten';

  @override
  String get lanPairedDevices => 'Gekoppelte Geräte';

  @override
  String get lanNoPaired =>
      'Noch keine gekoppelten Geräte. Koppeln Sie ein Gerät in der Nähe, um zu chatten, Dateien zu senden und Anrufe zu übergeben.';

  @override
  String get lanNearby => 'In der Nähe';

  @override
  String get lanNearbyHint =>
      'Suche nach SoftphonePro in Ihrem Netzwerk. Auf den anderen Geräten muss LAN Link aktiviert sein. Sie können auch über die Link-Schaltfläche oben per Adresse verbinden.';

  @override
  String get lanTransfers => 'Übertragungen';

  @override
  String get lanFiles => 'Dateien';

  @override
  String get lanPairedBadge => 'Gekoppelt';

  @override
  String get lanTyping => 'schreibt...';

  @override
  String get lanPair => 'Koppeln';

  @override
  String get lanUnpair => 'Entkoppeln';

  @override
  String lanUnpairTitle(String name) {
    return '$name entkoppeln?';
  }

  @override
  String get lanUnpairMessage =>
      'Sie müssen erneut koppeln, um zu chatten, Dateien zu senden oder Anrufe zu übergeben.';

  @override
  String get lanActionMessage => 'Nachricht';

  @override
  String get lanActionSendFile => 'Datei senden';

  @override
  String get lanActionCall => 'Anrufen';

  @override
  String get lanActionIntercom => 'Gegensprechen';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Aktiv auf $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Aktiv auf $device  ·  $account';
  }

  @override
  String get lanPull => 'Holen';

  @override
  String get lanTransferPreparing => 'Wird vorbereitet...';

  @override
  String get lanTransferWaitingYou => 'Wartet auf Sie';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Warten auf Annahme durch $name';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done von $total';
  }

  @override
  String get lanTransferVerifying => 'Wird überprüft...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'Von $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'An $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  von $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  an $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Fehlgeschlagen: $error';
  }

  @override
  String get lanFileActions => 'Dateiaktionen';

  @override
  String get lanPathCopied => 'Pfad kopiert';

  @override
  String get lanFileOpen => 'Öffnen';

  @override
  String get lanFileShowInFolder => 'Im Ordner anzeigen';

  @override
  String get lanFileCopyPath => 'Pfad kopieren';

  @override
  String lanNetworkError(String message) {
    return 'Netzwerkfehler: $message';
  }

  @override
  String get lanErrNotRunning => 'Aktivieren Sie zuerst LAN Link';

  @override
  String get lanErrBadAddress =>
      'Geben Sie eine Adresse wie 192.168.1.20:4711 ein oder fügen Sie den QR-Code-Text ein';

  @override
  String get lanErrFingerprint =>
      'Dieses Gerät stimmt nicht mit dem gescannten Code überein. Stammt der QR-Code von einem anderen Gerät?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$file von $name empfangen';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file an $name gesendet';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name hat $file abgelehnt';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Dateiübertragung fehlgeschlagen: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Aktivieren Sie LAN Link, um Geräte in der Nähe anzurufen';

  @override
  String get lanNoticePairFirst => 'Koppeln Sie zuerst mit diesem Gerät';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name ist für Anrufe derzeit nicht erreichbar';
  }

  @override
  String lanNoticeAsking(String name) {
    return '$name wird gefragt…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name hat das Gegensprechen nicht erlaubt (oder nicht geantwortet)';
  }

  @override
  String get lanHoOff => 'LAN Link ist ausgeschaltet';

  @override
  String get lanHoPairFirst => 'Koppeln Sie zuerst mit diesem Gerät';

  @override
  String lanHoOffline(String name) {
    return '$name ist offline';
  }

  @override
  String get lanHoAlready => 'Dieser Anruf wird bereits übergeben';

  @override
  String get lanHoEnded => 'Der Anruf wurde bereits beendet';

  @override
  String get lanHoWaitConnected => 'Warten Sie, bis der Anruf verbunden ist';

  @override
  String get lanHoLanCall => 'LAN-Anrufe können nicht übergeben werden';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name kann keine Anrufe über das Netzwerk annehmen (LAN-Telefonie ist dort ausgeschaltet)';
  }

  @override
  String get lanHoNoLanHere =>
      'LAN-Telefonie ist auf diesem Gerät nicht verfügbar';

  @override
  String lanHoDeclined(String name) {
    return '$name hat den Anruf abgelehnt. Er bleibt bei Ihnen.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name hat nicht reagiert. Der Anruf bleibt bei Ihnen.';
  }

  @override
  String get lanHoCancelled =>
      'Die Übergabe wurde abgebrochen. Der Anruf bleibt bei Ihnen.';

  @override
  String lanHoUnreachable(String name) {
    return '$name war nicht erreichbar. Der Anruf bleibt bei Ihnen.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '$name war nicht erreichbar ($reason). Der Anruf bleibt bei Ihnen.';
  }

  @override
  String get lanHoEndedBefore =>
      'Der Anruf wurde beendet, bevor er übergeben werden konnte';

  @override
  String lanHoPbxRefused(String name) {
    return 'Die Telefonanlage hat das Weiterverbinden abgelehnt, und $name kann keine LAN-Anrufe annehmen';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Weiterverbinden über die Telefonanlage fehlgeschlagen. Stattdessen wird über das Netzwerk weitergeleitet.';

  @override
  String lanHoSentTo(String name) {
    return 'Anruf an $name gesendet';
  }

  @override
  String get lanHoConsultFailed =>
      'Das andere Gerät konnte nicht über die Telefonanlage angerufen werden';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name ist nicht mehr erreichbar';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Der Anruf konnte zur Übergabe nicht angenommen werden';

  @override
  String lanHoCouldNotCall(String name) {
    return '$name konnte nicht über das Netzwerk angerufen werden. Der Anruf bleibt bei Ihnen.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name hat sich nicht gemeldet. Der Anruf bleibt bei Ihnen.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'An $name übergeben';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Anruf an $name weitergeleitet';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Warten Sie zuerst, bis $name sich meldet';
  }

  @override
  String get lanHoFailed => 'Übergabe fehlgeschlagen';

  @override
  String lanHoTakenBack(String name) {
    return 'Anruf von $name zurückgeholt';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name hat die Rücksprache beendet. Der Anruf ist wieder bei Ihnen.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Anruf konnte nicht an $name übergeben werden';
  }

  @override
  String get diagSip400Explain =>
      'Der Server konnte die Anfrage nicht verstehen.';

  @override
  String get diagSip400Fix =>
      'Prüfen Sie die Kontoeinstellungen (Domain, Benutzername, Proxy). Bleibt das Problem bestehen, senden Sie einen SIP-Trace an Ihren Anbieter.';

  @override
  String get diagSip401Explain =>
      'Der Server hat die Zugangsdaten abgelehnt (oder fordert sie an).';

  @override
  String get diagSip401Fix =>
      'Prüfen Sie Benutzername, Authentifizierungsbenutzer und Passwort. Manche Anbieter verwenden eine separate \"Auth-ID\".';

  @override
  String get diagSip403Explain =>
      'Der Server hat die Anfrage verstanden, verweigert sie aber: falsches Passwort, Konto deaktiviert oder Ihre IP ist nicht zugelassen.';

  @override
  String get diagSip403Fix =>
      'Geben Sie das Passwort erneut ein, prüfen Sie, ob das Konto aktiv ist, und stellen Sie sicher, dass Ihre öffentliche IP nicht gesperrt ist (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'Der Server kennt diesen Benutzer oder diese Nummer nicht.';

  @override
  String get diagSip404Fix =>
      'Prüfen Sie Benutzername und Domain; bei Anrufen die gewählte Nummer und die Wählregeln.';

  @override
  String get diagSip405Explain => 'Der Server unterstützt diese Anfrage nicht.';

  @override
  String get diagSip405Fix =>
      'Bei OPTIONS-Pings meist harmlos. Prüfen Sie bei REGISTER, ob Sie mit einem SIP-Registrar sprechen.';

  @override
  String get diagSip407Explain => 'Der Outbound-Proxy benötigt Zugangsdaten.';

  @override
  String get diagSip407Fix =>
      'Prüfen Sie das Kontopasswort und die Outbound-Proxy-Einstellungen.';

  @override
  String get diagSip408Explain => 'Keine rechtzeitige Antwort vom Server.';

  @override
  String get diagSip408Fix =>
      'Prüfen Sie Serveradresse und Port sowie Firewalls und probieren Sie TCP oder TLS. Wiederholte Zeitüberschreitungen nur bei UDP können auf SIP ALG im Router hinweisen.';

  @override
  String get diagSip410Explain => 'Die Nummer existiert nicht mehr.';

  @override
  String get diagSip410Fix => 'Prüfen Sie die gewählte Nummer.';

  @override
  String get diagSip415Explain =>
      'Die Gegenseite akzeptiert den angebotenen Inhaltstyp oder die Codecs nicht.';

  @override
  String get diagSip415Fix =>
      'Aktivieren Sie unter Einstellungen > Codecs weitere Codecs (z. B. PCMU/PCMA).';

  @override
  String get diagSip421Explain =>
      'Der Server verlangt eine SIP-Erweiterung, die dieser Client nicht angeboten hat.';

  @override
  String get diagSip421Fix =>
      'Prüfen Sie die Optionen des Kontos für NAT/ICE/100rel/Timer.';

  @override
  String get diagSip423Explain =>
      'Der Ablauf der Registrierung ist kürzer, als der Server zulässt.';

  @override
  String get diagSip423Fix =>
      'Erhöhen Sie den Ablauf der Registrierung in den Kontoeinstellungen.';

  @override
  String get diagSip480Explain =>
      'Der Benutzer ist nicht registriert oder derzeit nicht erreichbar.';

  @override
  String get diagSip480Fix =>
      'Prüfen Sie, ob die Gegenseite registriert ist; bei der Registrierung ist der Server möglicherweise überlastet: später erneut versuchen.';

  @override
  String get diagSip481Explain =>
      'Der Server hat den Dialogstatus verloren (z. B. nach einem Neustart oder Netzwerkwechsel).';

  @override
  String get diagSip481Fix =>
      'Auflegen und erneut versuchen. Tritt es häufig auf, aktivieren Sie Session-Timer.';

  @override
  String get diagSip483Explain => 'Die Anfrage kreiste zwischen Servern.';

  @override
  String get diagSip483Fix =>
      'Prüfen Sie die Umleitungs- und Routing-Konfiguration der Telefonanlage.';

  @override
  String get diagSip484Explain => 'Die gewählte Nummer ist zu kurz.';

  @override
  String get diagSip484Fix =>
      'Wählen Sie die vollständige Nummer oder prüfen Sie die Wählregeln.';

  @override
  String get diagSip486Explain => 'Die Gegenseite ist besetzt.';

  @override
  String get diagSip486Fix => 'Versuchen Sie es später erneut.';

  @override
  String get diagSip487Explain =>
      'Der Anruf wurde abgebrochen, bevor er angenommen wurde.';

  @override
  String get diagSip487Fix =>
      'Normal, wenn der Anrufer während des Klingelns auflegt.';

  @override
  String get diagSip488Explain =>
      'Kein gemeinsamer Codec oder keine gemeinsame Verschlüsselungseinstellung mit der Gegenseite.';

  @override
  String get diagSip488Fix =>
      'Prüfen Sie Codecs und SRTP (ein Konto mit zwingendem SRTP kann keinen Endpunkt mit reinem RTP anrufen).';

  @override
  String get diagSip491Explain => 'Zwei Re-INVITEs sind kollidiert.';

  @override
  String get diagSip491Fix => 'Wird normalerweise automatisch wiederholt.';

  @override
  String get diagSip500Explain =>
      'Beim Server ist ein interner Fehler aufgetreten.';

  @override
  String get diagSip500Fix =>
      'Später erneut versuchen und den Anbieter kontaktieren, falls es anhält.';

  @override
  String get diagSip502Explain =>
      'Ein vorgelagerter Server hat eine ungültige Antwort geliefert.';

  @override
  String get diagSip502Fix =>
      'Später erneut versuchen; den Anbieter kontaktieren, falls es anhält.';

  @override
  String get diagSip503Explain =>
      'Der Server ist überlastet, ausgefallen oder weist diesen Client ab (Ratenbegrenzung).';

  @override
  String get diagSip503Fix =>
      'Warten und erneut versuchen, die Statusseite des Anbieters prüfen oder einen anderen Server/Port probieren.';

  @override
  String get diagSip504Explain =>
      'Ein vorgelagerter Server hat nicht rechtzeitig geantwortet.';

  @override
  String get diagSip504Fix => 'Später erneut versuchen.';

  @override
  String get diagSip600Explain => 'Alle Ziele sind besetzt.';

  @override
  String get diagSip600Fix => 'Versuchen Sie es später erneut.';

  @override
  String get diagSip603Explain => 'Die Gegenseite hat den Anruf abgelehnt.';

  @override
  String get diagSip603Fix => 'Nichts zu beheben: Der Anruf wurde abgelehnt.';

  @override
  String get diagSip604Explain => 'Die Nummer existiert nicht.';

  @override
  String get diagSip604Fix => 'Prüfen Sie die gewählte Nummer.';

  @override
  String get diagSip606Explain =>
      'Die Gegenseite kann die Sitzung nicht wie angeboten annehmen.';

  @override
  String get diagSip606Fix =>
      'Prüfen Sie Codecs und Verschlüsselungseinstellungen.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Vorläufig ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'Die Anfrage wird bearbeitet.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Erfolg ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'Die Anfrage war erfolgreich.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Umgeleitet ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'Das Ziel wurde verschoben.';

  @override
  String get diagSipRedirectedFix => 'Prüfen Sie die Umleitungseinstellungen.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Clientfehler ($code)';
  }

  @override
  String get diagSipClientErrorExplain =>
      'Der Server hat die Anfrage abgelehnt.';

  @override
  String get diagSipClientErrorFix =>
      'Prüfen Sie das Konto und die gewählte Nummer.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Serverfehler ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'Der Server konnte die Anfrage nicht verarbeiten.';

  @override
  String get diagSipServerErrorFix =>
      'Später erneut versuchen oder den Anbieter kontaktieren.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Globaler Fehler ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'Die Anfrage kann nirgends erfüllt werden.';

  @override
  String get diagSipNoResponseTitle => 'Keine Antwort';

  @override
  String get diagSipNoResponseExplain =>
      'Es wurde keine SIP-Antwort empfangen.';

  @override
  String get diagSipNoResponseFix =>
      'Prüfen Sie die Netzwerkverbindung und die Serveradresse.';

  @override
  String get diagWizStepNet => 'Netzwerkverbindung';

  @override
  String diagWizStepDns(String account) {
    return 'DNS und SRV: $account';
  }

  @override
  String get diagWizStepNat => 'NAT-Typ';

  @override
  String diagWizStepOptions(String account) {
    return 'Erreichbarkeit des Servers: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS-Zertifikat: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registrierung: $account';
  }

  @override
  String get diagWizStepAlg => 'SIP-ALG-Prüfung';

  @override
  String get diagWizChecking => 'Wird geprüft...';

  @override
  String diagWizEngineError(String message) {
    return 'Engine-Fehler: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Prüfung fehlgeschlagen: $error';
  }

  @override
  String get diagWizNoEngine => 'Die SIP-Engine läuft nicht';

  @override
  String get diagWizNoEngineFix =>
      'Warten Sie, bis die Engine gestartet ist (oder starten Sie die App neu), und führen Sie die Prüfungen erneut aus.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privat)';
  }

  @override
  String get diagWizNetNone =>
      'Keine aktive Netzwerkschnittstelle mit IP-Adresse';

  @override
  String get diagWizNetNoneFix =>
      'Verbinden Sie sich mit WLAN, Ethernet oder mobilen Daten und führen Sie die Prüfungen erneut aus.';

  @override
  String get diagWizNetIpv6Only => 'Nur IPv6-Adressen gefunden';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Viele SIP-Anbieter unterstützen nur IPv4. Aktivieren Sie IPv4 in diesem Netzwerk oder nutzen Sie einen Anbieter mit IPv6-Unterstützung.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 IPv4-Adressen',
      one: '1 IPv4-Adresse',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces Schnittstellen',
      one: '1 Schnittstelle',
    );
    return '$_temp0 auf $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Eine VPN-ähnliche Schnittstelle ist aktiv. VPNs können Latenz verursachen oder UDP blockieren; deaktivieren Sie sie, wenn Anrufe Probleme machen.';

  @override
  String get diagWizDnsNoServer => 'Das Konto hat keine Serveradresse';

  @override
  String get diagWizDnsNoServerFix =>
      'Bearbeiten Sie das Konto und geben Sie die SIP-Domain ein.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host ist eine IP-Adresse, kein DNS nötig';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: keine';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: keine ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: keine';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (Priorität $priority, Gewicht $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: Abfrage fehlgeschlagen ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host wird nicht aufgelöst';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Prüfen Sie die Domain auf Tippfehler und ob Ihr DNS-Server funktioniert. Unter Einstellungen > Netzwerk können Sie einen eigenen DNS-Server festlegen (z. B. 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host hat SRV-Einträge, aber keinen Adresseintrag';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Die SRV-Ziele werden verwendet. Schlagen Anrufe fehl, bitten Sie den Anbieter, den A-Eintrag zu prüfen.';

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
      other: ', $srv SRV-Einträge',
      one: ', 1 SRV-Eintrag',
      zero: '',
    );
    return '$host wird zu $address aufgelöst$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Zeitüberschreitung bei der NAT-Erkennung';

  @override
  String get diagWizNatTimeoutFix =>
      'Der STUN-Server ist möglicherweise nicht erreichbar (UDP blockiert?). Prüfen Sie Einstellungen > Netzwerk > STUN-Server.';

  @override
  String diagWizNatStun(String server) {
    return 'STUN-Server: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Kein NAT: Dieses Gerät hat eine öffentliche Adresse';

  @override
  String get diagWizNatFullCone => 'Full-Cone-NAT: VoIP-freundlich';

  @override
  String get diagWizNatRestricted =>
      'Restricted-Cone-NAT: funktioniert mit STUN und Keep-Alives';

  @override
  String get diagWizNatPortRestricted =>
      'Port-Restricted-Cone-NAT: funktioniert mit STUN und Keep-Alives';

  @override
  String get diagWizNatSymmetric =>
      'Symmetrisches NAT: STUN allein kann den Medienport nicht vorhersagen';

  @override
  String get diagWizNatSymmetricFix =>
      'Bei manchen Anrufen sind einseitiges Audio oder kein Audio wahrscheinlich. Aktivieren Sie ICE und ein TURN-Relay in den Kontoeinstellungen (Konto > NAT) oder nutzen Sie einen Anbieter bzw. eine Telefonanlage mit Medien-Relay (rtpengine).';

  @override
  String get diagWizNatBlocked => 'UDP scheint blockiert zu sein';

  @override
  String get diagWizNatBlockedFix =>
      'Verwenden Sie für das Konto den Transport TCP oder TLS. Filtert das Netzwerk alles außer Webverkehr, probieren Sie TLS auf Port 443, falls Ihr Anbieter dies unterstützt.';

  @override
  String get diagWizNatUnknown => 'Der NAT-Typ konnte nicht ermittelt werden';

  @override
  String get diagWizNatUnknownFix =>
      'Der STUN-Server hat nicht geantwortet. Probieren Sie unter Einstellungen > Netzwerk einen anderen STUN-Server.';

  @override
  String get diagWizNatErr =>
      'Der STUN-Server hat nicht geantwortet, daher konnte der NAT-Typ nicht ermittelt werden.';

  @override
  String get diagWizNatUnknownRaw =>
      'Der NAT-Typ konnte nicht ermittelt werden.';

  @override
  String get diagWizOptionsNotLoaded =>
      'Das Konto ist nicht in der Engine geladen';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Keine Antwort auf OPTIONS innerhalb von $seconds s (Transport: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'Der Server ist nicht erreichbar. Prüfen Sie Adresse und Port, ob eine Firewall SIP verwirft, und probieren Sie einen anderen Transport (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Zeitüberschreitung der Anfrage ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Server antwortete $code $reason nach $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Server antwortete $code $reason in $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Eine $code-Antwort auf OPTIONS ist normal: Der Server ist erreichbar, erlaubt aber keine anonymen Abfragen.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Eine Laufzeit über 300 ms führt zu spürbarer Verzögerung in Gesprächen. Ein näherer Server oder eine kabelgebundene Verbindung hilft.';

  @override
  String get diagWizTlsRejected => 'Das Serverzertifikat wurde abgelehnt';

  @override
  String diagWizTlsSubject(String value) {
    return 'Subjekt: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Aussteller: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Probleme: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Läuft ab: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cipher: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Handelt es sich um Ihre eigene Telefonanlage mit selbstsigniertem Zertifikat und stimmt der Fingerabdruck oben, können Sie ihm vertrauen. Andernfalls bitten Sie den Anbieter um ein Zertifikat einer öffentlichen CA.';

  @override
  String get diagWizTlsTrust => 'Diesem Zertifikat vertrauen';

  @override
  String diagWizTlsExpired(String date) {
    return 'Das Zertifikat ist am $date abgelaufen';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Bitten Sie den Serveradministrator, das Zertifikat zu erneuern.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Das Zertifikat läuft in $days Tagen ab',
      one: 'Das Zertifikat läuft in 1 Tag ab',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Weisen Sie den Serveradministrator darauf hin, es bald zu erneuern.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Verbunden, aber die Überprüfung meldete: $problems';
  }

  @override
  String get diagWizTlsOk => 'TLS-Verbindung hergestellt, Zertifikat gültig';

  @override
  String get diagWizTlsRegistered =>
      'Über TLS registriert (keine Zertifikatsdetails gemeldet)';

  @override
  String get diagWizTlsNone => 'Es wurde noch keine TLS-Verbindung beobachtet';

  @override
  String get diagWizTlsNoneFix =>
      'Prüfen Sie den TLS-Port (meist 5061) und ob der Server TLS 1.2 oder neuer akzeptiert.';

  @override
  String get diagWizRegDisabledByConfig =>
      'Die Registrierung ist für dieses Konto deaktiviert (Peer-to-Peer-Nutzung)';

  @override
  String get diagWizRegRegistered => 'Registriert';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registriert (läuft in $seconds s ab)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transport: $transport';
  }

  @override
  String get diagWizRegInProgress => 'Die Registrierung läuft noch';

  @override
  String get diagWizRegInProgressFix =>
      'Warten Sie einige Sekunden. Wird sie nie abgeschlossen, antwortet der Server nicht; siehe die Erreichbarkeitsprüfung oben.';

  @override
  String get diagWizRegFailed => 'Registrierung fehlgeschlagen';

  @override
  String get diagWizRegOffline => 'Das Konto ist offline';

  @override
  String get diagWizRegOfflineFix =>
      'Prüfen Sie die Netzwerkverbindung. Die App versucht es automatisch erneut.';

  @override
  String get diagWizRegDisabled => 'Das Konto ist deaktiviert';

  @override
  String get diagWizAlgNoUdp =>
      'Kein Konto verwendet UDP, daher ist SIP ALG kein Thema';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: keine Antwort über UDP, aber TCP hat geantwortet ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: keine Antwort über UDP oder TCP (eher ein Server- oder Firewall-Problem als ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS wird beantwortet, aber REGISTER läuft in die Zeitüberschreitung, typisch für einen Router, der SIP umschreibt';
  }

  @override
  String get diagWizAlgSuspected => 'SIP ALG in Ihrem Router vermutet';

  @override
  String get diagWizAlgSuspectedFix =>
      'Deaktivieren Sie \"SIP ALG\" / \"SIP Helper\" in den Router-Einstellungen, stellen Sie das Konto auf TCP oder TLS um oder ändern Sie den SIP-Port (z. B. 5080), damit der Router die Pakete nicht mehr verändert.';

  @override
  String get diagWizAlgContactChanged =>
      'Die Contact-Adresse hat sich zwischen Anfrage und Antwort geändert';

  @override
  String get diagWizAlgContactChangedFix =>
      'Das kann ein SIP ALG oder ein Server sein, der Contacts umschreibt. Klingeln Anrufe, haben aber kein Audio oder brechen nach einer Weile ab, deaktivieren Sie SIP ALG im Router oder verwenden Sie TCP/TLS oder Port 5080.';

  @override
  String get diagWizAlgOk => 'Keine Anzeichen für SIP-ALG-Störungen';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER-Contact $sent kam als $received zurück';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '$fileName speichern';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName gespeichert';
  }

  @override
  String get diagSaveFailed => 'Datei konnte nicht gespeichert werden';

  @override
  String get diagCopiedText => 'Text in die Zwischenablage kopiert';

  @override
  String get diagCopiedReport => 'Bericht in die Zwischenablage kopiert';

  @override
  String get diagCopiedBundle => 'Diagnosepaket in die Zwischenablage kopiert';

  @override
  String get diagCopiedLogs => 'Protokolle in die Zwischenablage kopiert';

  @override
  String get diagCopiedTrace => 'Trace in die Zwischenablage kopiert';

  @override
  String get diagCopiedDialog => 'Dialog in die Zwischenablage kopiert';

  @override
  String get diagSaveAsLog => 'Als .log speichern';

  @override
  String get diagSysAppVersion => 'App-Version';

  @override
  String get diagSysPlatform => 'Plattform';

  @override
  String get diagSysEngine => 'Engine';

  @override
  String get diagSysAccounts => 'Konten';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered von $total registriert';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Systeminformationen konnten nicht gelesen werden: $error';
  }

  @override
  String get diagSysTransports => 'Transporte';

  @override
  String get diagSysNoneReported => 'Keine gemeldet';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter =>
      'Aktivierte Codecs, höchste Priorität zuerst.';

  @override
  String get diagSysEngineNotRunning => 'Engine läuft nicht';

  @override
  String diagSysCodecPriority(int priority) {
    return 'Priorität $priority';
  }

  @override
  String get diagSysCodecDisabled => 'deaktiviert';

  @override
  String get diagSysExport => 'Export';

  @override
  String get diagSysExportFooter =>
      'Das Paket enthält Systeminfos, Ergebnisse der Netzwerkprüfung, aktuelle Protokolle und den SIP-Trace, wobei Zugangsdaten geschwärzt sind.';

  @override
  String get diagSysCopyBundle => 'Diagnosepaket kopieren';

  @override
  String get diagSysSaveBundle => 'Diagnosepaket speichern';

  @override
  String get diagTabSipTrace => 'SIP-Trace';

  @override
  String get diagTabNetwork => 'Netzwerk';

  @override
  String get diagTabQuality => 'Qualität';

  @override
  String get diagTabAudioTest => 'Audiotest';

  @override
  String get diagTabLogs => 'Protokolle';

  @override
  String get diagTabSystem => 'System';

  @override
  String diagRawSentTo(String remote) {
    return 'gesendet an $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'empfangen von $remote';
  }

  @override
  String get diagRawCopied => 'Nachricht kopiert';

  @override
  String get diagRawLadder => 'Ablauf';

  @override
  String get diagRawRedact => 'Zugangsdaten schwärzen';

  @override
  String diagRawTruncated(int count) {
    return '... gekürzt ($count Zeichen)';
  }

  @override
  String get diagWizIntro =>
      'Prüft Ihre Verbindung, DNS, NAT, Servererreichbarkeit, TLS und Registrierung und erklärt, was zu beheben ist.';

  @override
  String get diagWizStop => 'Stopp';

  @override
  String get diagWizRunChecks => 'Prüfungen starten';

  @override
  String get diagWizRunAgain => 'Erneut ausführen';

  @override
  String get diagWizCopyReport => 'Bericht kopieren';

  @override
  String get diagWizSaveReport => 'Bericht speichern';

  @override
  String diagWizCountPassed(int count) {
    return 'Bestanden $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Warnungen $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Fehlgeschlagen $count';
  }

  @override
  String get diagWizStatusPass => 'Bestanden';

  @override
  String get diagWizStatusWarn => 'Warnung';

  @override
  String get diagWizStatusFail => 'Fehlgeschlagen';

  @override
  String get diagWizStatusSkipped => 'Übersprungen';

  @override
  String get diagWizStatusRunning => 'Läuft';

  @override
  String get diagWizStatusPending => 'Ausstehend';

  @override
  String get diagQualityTitle => 'Anrufqualität';

  @override
  String get diagQualityNoData =>
      'Für diesen Anruf wurden keine Qualitätsdaten aufgezeichnet.';

  @override
  String get diagQualityTraceForCall => 'SIP-Trace für diesen Anruf';

  @override
  String get diagQualityTraceNotCaptured =>
      'SIP-Trace für diesen Anruf nicht erfasst';

  @override
  String get diagQualityLiveCall => 'Live-Anruf';

  @override
  String get diagQualityNoActiveCall =>
      'Kein aktiver Anruf. Starten Sie einen Anruf, dann werden MOS, Jitter, Verlust und Laufzeit hier live dargestellt.';

  @override
  String get diagQualityRecentCalls => 'Letzte Anrufe';

  @override
  String get diagQualityNoFinished =>
      'Noch keine beendeten Anrufe mit Qualitätsdaten.';

  @override
  String get diagQualityCallEnded => 'Der Anruf wurde beendet.';

  @override
  String get diagQualityMeasuring => 'wird gemessen';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Diagramm $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Diagramm $title, zuletzt $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   max. $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Durchschnitt $avg  ·  schlechtester $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Verlust';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count Pkt.';
  }

  @override
  String get diagQualityMedia => 'Medien';

  @override
  String get diagQualityNoSeries =>
      'Für diesen Anruf wurde keine Zeitreihe aufgezeichnet.';

  @override
  String get diagQualityPacketLoss => 'Paketverlust';

  @override
  String get diagQualityRtt => 'Laufzeit';

  @override
  String get diagLogsForward => 'Engine-Protokolle weiterleiten';

  @override
  String get diagLogsForwardSub =>
      'pjsip-Protokollzeilen an diese Ansicht senden';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Stufe $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Beim Export schwärzen';

  @override
  String get diagLogsSearch => 'Protokolle durchsuchen';

  @override
  String get diagLogsEmpty => 'Noch keine Protokollzeilen.';

  @override
  String get diagLogsForwardingOff =>
      'Die Protokollweiterleitung ist aus. Aktivieren Sie sie, um Engine-Protokolle zu erfassen.';

  @override
  String get diagLogsNoMatch => 'Keine Zeilen entsprechen der Suche.';

  @override
  String get diagAudioEngineNotRunning => 'Die SIP-Engine läuft nicht.';

  @override
  String get diagAudioMicrophone => 'Mikrofon';

  @override
  String get diagAudioMicFooter =>
      'Die Pegelanzeige liest das Audiogerät, das die Engine während eines Anrufs oder des Echotests öffnet.';

  @override
  String get diagAudioLevelMeter => 'Pegelanzeige';

  @override
  String get diagAudioLevelMeterSub =>
      'Sprechen Sie und beobachten Sie den Balken';

  @override
  String get diagAudioMic => 'Mikro';

  @override
  String get diagAudioSpeaker => 'Lautsprecher';

  @override
  String get diagAudioEchoTest => 'Echotest';

  @override
  String get diagAudioEchoFooter =>
      'Gibt Ihre Stimme über den Lautsprecher wieder. Verwenden Sie Kopfhörer, um Rückkopplungen zu vermeiden.';

  @override
  String get diagAudioEchoActive => 'Aktiv: jetzt sprechen';

  @override
  String get diagAudioEchoIdle => 'Rückführung Mikrofon zu Lautsprecher';

  @override
  String get diagAudioSpeakerTest => 'Lautsprechertest';

  @override
  String get diagAudioPlayTone => 'Testton abspielen';

  @override
  String get diagAudioPlayToneSub =>
      'Wird über den gewählten Lautsprecher abgespielt';

  @override
  String get diagAudioPlayingDtmf => 'DTMF wird abgespielt';

  @override
  String get diagAudioPlayingRingback => 'Freiton wird abgespielt';

  @override
  String get diagAudioRingback => 'Freiton';

  @override
  String get diagAudioDevices => 'Geräte';

  @override
  String get diagAudioChooseDevices => 'Mikrofon und Lautsprecher wählen';

  @override
  String get diagAudioChooseDevicesSub => 'Öffnet Einstellungen > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label-Pegel $percent Prozent';
  }

  @override
  String get diagLadderLocal => 'Lokal';

  @override
  String diagLadderSent(String message) {
    return '$message gesendet';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message empfangen';
  }

  @override
  String get diagTraceCapture => 'SIP-Nachrichten erfassen';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten',
      one: '1 Nachricht',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten',
      one: '1 Nachricht',
    );
    return '$_temp0  ·  $size  ·  $dropped ältere verworfen';
  }

  @override
  String get diagTraceOffHint =>
      'Aus. Aktivieren Sie die Erfassung und registrieren Sie sich oder führen Sie einen Anruf.';

  @override
  String get diagTraceExportOrClear => 'Exportieren oder leeren';

  @override
  String get diagTraceSaveAsPcap => 'Als .pcap speichern';

  @override
  String get diagTraceCopyAsText => 'Als Text kopieren';

  @override
  String get diagTraceSearchHint => 'Text, Nummer oder Call-ID suchen';

  @override
  String get diagTraceErrorsOnly => 'Nur Fehler';

  @override
  String get diagTraceFilterMethod => 'Nach Methode filtern';

  @override
  String get diagTraceAllMethods => 'Alle Methoden';

  @override
  String get diagTraceMethod => 'Methode';

  @override
  String get diagTraceFilterAccount => 'Nach Konto filtern';

  @override
  String get diagTraceAllAccounts => 'Alle Konten';

  @override
  String get diagTraceAccount => 'Konto';

  @override
  String get diagTraceRedact => 'Schwärzen';

  @override
  String get diagTraceList => 'Liste';

  @override
  String get diagTraceWaiting => 'Warten auf SIP-Verkehr';

  @override
  String get diagTraceWaitingSub =>
      'Registrieren Sie ein Konto oder führen Sie einen Anruf, dann erscheinen die Nachrichten hier.';

  @override
  String get diagTraceOff => 'SIP-Trace ist aus';

  @override
  String get diagTraceOffSub =>
      'Aktivieren Sie die Erfassung, um jede SIP-Anfrage und -Antwort zu sehen, als Liste oder als Ablaufdiagramm.';

  @override
  String get diagTraceNoMatch => 'Keine Nachrichten entsprechen den Filtern';

  @override
  String get diagTraceAllDialogs => 'Alle Dialoge';

  @override
  String get diagTraceCopyDialog => 'Diesen Dialog kopieren';

  @override
  String get diagTraceNoResponse => 'keine Antwort';

  @override
  String get diagTraceNoCallId => 'keine Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten',
      one: '1 Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Aufzeichnung';

  @override
  String get recFormatWav => 'Standard (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stereo, Sie und der Anrufer auf getrennten Kanälen (WAV)';

  @override
  String get recFormatOpus => 'Komprimiert (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, etwa 2 MB pro Minute. Wird überall abgespielt.';

  @override
  String get recFormatWavStereoHint =>
      'Zwei Kanäle, etwa 4 MB pro Minute. Sie links, der Anrufer rechts.';

  @override
  String get recFormatOpusHint =>
      'Etwa 0,2 MB pro Minute. Ogg Opus; manche Player auf iPhone, Mac und Windows können es nicht öffnen.';

  @override
  String get recOptionInherit => 'Globale Einstellung verwenden';

  @override
  String get recOptionAlways => 'Alle Anrufe aufzeichnen';

  @override
  String get recOptionIncoming => 'Nur eingehende Anrufe aufzeichnen';

  @override
  String get recOptionOutgoing => 'Nur ausgehende Anrufe aufzeichnen';

  @override
  String get recOptionNever => 'Nie aufzeichnen';

  @override
  String get recRuleAll => 'Alle Anrufe';

  @override
  String get recRuleIncoming => 'Nur eingehende Anrufe';

  @override
  String get recRuleOutgoing => 'Nur ausgehende Anrufe';

  @override
  String get recAutoDeleteNever => 'Nie';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Nach $days Tagen',
      one: 'Nach 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Nach 1 Jahr';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufzeichnungen',
      one: '1 Aufzeichnung',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufzeichnungen',
      one: '1 Aufzeichnung',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufzeichnungen',
      one: '1 Aufzeichnung',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tagen',
      one: '1 Tag',
    );
    return '$_temp0  ·  $size  ·  automatisches Löschen nach $_temp1';
  }

  @override
  String get recSettingsFormat => 'Format';

  @override
  String get recSettingsAutoGroup => 'Automatische Aufzeichnung';

  @override
  String get recSettingsAutoFooter =>
      'Informieren Sie sich über die geltenden Gesetze, bevor Sie Anrufe aufzeichnen. Aktivieren Sie bei einem Kontakt \"Anrufe mit diesem Kontakt immer aufzeichnen\", um sie unabhängig von diesen Regeln aufzuzeichnen.';

  @override
  String get recSettingsAutoRule => 'Anrufe automatisch aufzeichnen';

  @override
  String get recSettingsAccountOverride => 'Für dieses Konto überschreiben';

  @override
  String get recSettingsNoticesGroup => 'Hinweise';

  @override
  String get recSettingsNoticeSwitch =>
      'Vor der Aufzeichnung einen Hinweis abspielen';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Spielt zuerst einen Hinweis für die Gegenseite ab. Die Hinweisdatei wählen Sie unter Einstellungen > Anrufe > Ansagen.';

  @override
  String get recSettingsNoticeFile => 'Hinweisdatei auswählen';

  @override
  String get recSettingsNoticeFileHint =>
      'Öffnet Einstellungen > Anrufe > Ansagen';

  @override
  String get recSettingsBeep => 'Aufzeichnungston';

  @override
  String get recSettingsBeepHint => 'Die Gegenseite regelmäßig warnen';

  @override
  String get recSettingsTransfersGroup => 'Weiterverbinden';

  @override
  String get recSettingsContinue =>
      'Aufzeichnung beim Weiterverbinden fortsetzen';

  @override
  String get recSettingsContinueHint =>
      'Das Rückfragegespräch beim Weiterverbinden mit Rückfrage und den uns durch Weiterverbinden übergebenen Anruf aufzeichnen und die Aufzeichnungen verknüpfen';

  @override
  String get recSettingsStorageGroup => 'Speicher';

  @override
  String get recSettingsFolder => 'Ordner';

  @override
  String get recSettingsFolderHint => 'Speicherort der Aufzeichnungen';

  @override
  String get recSettingsFolderPlaceholder => 'App-Dokumente / Aufzeichnungen';

  @override
  String get recSettingsChooseFolder => 'Ordner auswählen...';

  @override
  String get recSettingsFolderPickerTitle => 'Aufzeichnungsordner';

  @override
  String get recSettingsAutoDelete => 'Alte Aufzeichnungen löschen';

  @override
  String get recSettingsAutoDeleteHint =>
      'Wird beim Start und einmal täglich geprüft';

  @override
  String get recSettingsManage => 'Aufzeichnungen verwalten';

  @override
  String get recSettingsOpenFolder => 'Aufzeichnungsordner öffnen';

  @override
  String get recPageTitle => 'Aufzeichnungen';

  @override
  String recSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get recCancelSelection => 'Auswahl aufheben';

  @override
  String get recSelectAll => 'Alle auswählen';

  @override
  String get recShareSelected => 'Auswahl teilen';

  @override
  String get recDeleteSelected => 'Auswahl löschen';

  @override
  String get recSearchTooltip => 'Aufzeichnungen durchsuchen';

  @override
  String get recSelectTooltip => 'Aufzeichnungen auswählen';

  @override
  String get recMenuSettings => 'Aufzeichnungseinstellungen';

  @override
  String get recSearchHint => 'Name oder Nummer suchen';

  @override
  String get recEmptyNone => 'Noch keine Aufzeichnungen';

  @override
  String get recEmptyNoneHint =>
      'Zeichnen Sie einen Anruf mit der Aufnahmetaste auf oder aktivieren Sie die automatische Aufzeichnung in den Einstellungen.';

  @override
  String get recEmptyNoMatch => 'Keine passenden Aufzeichnungen';

  @override
  String get recEmptyNoMatchHint =>
      'Versuchen Sie eine andere Suche oder einen anderen Filter.';

  @override
  String get recClearFilters => 'Filter zurücksetzen';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufzeichnungen löschen?',
      one: '1 Aufzeichnung löschen?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Die Audiodateien werden von diesem Gerät entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get recDeleteOneTitle => 'Diese Aufzeichnung löschen?';

  @override
  String get recDeleteOneMessage =>
      'Die Audiodatei wird von diesem Gerät entfernt. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get recFilterAll => 'Alle';

  @override
  String get recFilterIncoming => 'Eingehend';

  @override
  String get recFilterOutgoing => 'Ausgehend';

  @override
  String get recFilterByAccount => 'Nach Konto filtern';

  @override
  String get recFilterAllAccounts => 'Alle Konten';

  @override
  String get recFilterAccountFallback => 'Konto';

  @override
  String get recFilterAnyDate => 'Beliebiges Datum';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Datum zurücksetzen';

  @override
  String get recMissingFile => 'Die Audiodatei fehlt auf diesem Gerät.';

  @override
  String recRelated(String title) {
    return 'Verknüpft: $title';
  }

  @override
  String get recRenameTitle => 'Aufzeichnung umbenennen';

  @override
  String get recRenameHint => 'Name';

  @override
  String get recSaveAs => 'Speichern unter...';

  @override
  String get recShowInFinder => 'Im Finder anzeigen';

  @override
  String get recShowInFolder => 'Im Ordner anzeigen';

  @override
  String get recViewCall => 'Anruf anzeigen';

  @override
  String recSavedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String get recSaveFailed => 'Aufzeichnung konnte nicht gespeichert werden';

  @override
  String get recShareFailed => 'Aufzeichnung konnte nicht geteilt werden';

  @override
  String get recSaveDialogTitle => 'Aufzeichnung speichern';

  @override
  String get recShareSubject => 'Anrufaufzeichnungen';

  @override
  String get recPlayerUnsupported =>
      'Dieses Gerät kann Opus-Aufzeichnungen hier nicht abspielen.';

  @override
  String get recPlayerOpenWith => 'Öffnen mit...';

  @override
  String get recPlayerNotFound => 'Die Aufzeichnungsdatei wurde nicht gefunden';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Diese Aufzeichnung kann nicht abgespielt werden: $error';
  }

  @override
  String get recPlayerPlay => 'Aufzeichnung abspielen';

  @override
  String get recPlayerPause => 'Aufzeichnung pausieren';

  @override
  String get audioFilesTitle => 'Audiodateien';

  @override
  String audioAdded(String name) {
    return '\"$name\" hinzugefügt';
  }

  @override
  String get audioFileUnavailable => 'Diese Datei ist nicht verfügbar.';

  @override
  String get audioNameRequired => 'Geben Sie einen Namen ein';

  @override
  String audioDeleteTitle(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get audioDeleteMessage =>
      'Einstellungen, die diese Datei verwenden, kehren zum Standard zurück.';

  @override
  String get audioGroupAdd => 'Hinzufügen';

  @override
  String get audioAddFooter =>
      'WAV- (PCM, µ-law, A-law) und MP3-Dateien funktionieren. Dateien werden in die App kopiert, das Original kann also verschoben werden.';

  @override
  String get audioImport => 'WAV oder MP3 importieren…';

  @override
  String get audioGroupMine => 'Meine Dateien';

  @override
  String get audioEmptyTitle => 'Noch keine Dateien';

  @override
  String get audioEmptyHint =>
      'Importieren Sie eine Datei oder nehmen Sie eine eigene Ansage auf.';

  @override
  String get audioGroupBuiltIn => 'Integriert';

  @override
  String get audioBuiltInFooter => 'Für SoftphonePro erzeugt, frei verwendbar.';

  @override
  String get audioPreviewStop => 'Vorschau beenden';

  @override
  String audioPreviewPlay(String name) {
    return 'Vorschau von $name';
  }

  @override
  String get audioRecordedName => 'Aufnahme benennen';

  @override
  String get audioRecordedDefaultName => 'Meine Ansage';

  @override
  String audioSaved(String name) {
    return '\"$name\" gespeichert';
  }

  @override
  String get audioRecorderStop => 'Stopp';

  @override
  String get audioRecorderPlay => 'Aufnahme abspielen';

  @override
  String audioRecorderNew(String duration) {
    return 'Neue Aufnahme  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Verwerfen';

  @override
  String get audioRecordOwn => 'Eigene aufnehmen…';

  @override
  String get audioRecordOwnHint =>
      'Verwendet das in den Audioeinstellungen gewählte Mikrofon';

  @override
  String get audioMissingFile => 'Datei fehlt';

  @override
  String get audioBuiltInCalm => 'Ruhig (integriert)';

  @override
  String get audioBuiltInBreeze => 'Brise (integriert)';

  @override
  String get audioBuiltInChime => 'Hinweiston (integriert)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Es können nur WAV- und MP3-Dateien verwendet werden.';

  @override
  String get audioErrNotFound => 'Diese Datei wurde nicht gefunden.';

  @override
  String get audioErrNotSaved => 'Die Aufnahme wurde nicht gespeichert.';

  @override
  String get audioErrEmpty => 'Diese Audiodatei ist leer oder nicht lesbar.';

  @override
  String audioErrUnusable(String reason) {
    return 'Diese Audiodatei kann nicht verwendet werden ($reason). Verwenden Sie WAV (PCM, µ-law oder A-law) oder MP3.';
  }

  @override
  String get audioRecEngineOff => 'Die Anruf-Engine läuft nicht.';

  @override
  String get audioRecUnsupported =>
      'Diese Version der Anruf-Engine kann das Mikrofon nicht aufnehmen.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Aufnahme konnte nicht gestartet werden: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Aufnahme fehlgeschlagen: $reason';
  }

  @override
  String get audioStrengthLow => 'Niedrig';

  @override
  String get audioStrengthMedium => 'Mittel';

  @override
  String get audioStrengthHigh => 'Hoch';

  @override
  String get audioStrengthMax => 'Maximal';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent %)';
  }

  @override
  String get audioSystemDefault => 'Systemstandard';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Systemstandard ($name)';
  }

  @override
  String get voiceTitle => 'Stimmisolierung';

  @override
  String get voiceUnavailable =>
      'Die KI-Geräuschunterdrückung ist in dieser Version der Anruf-Engine nicht verfügbar. Die Standard-Rauschunterdrückung unter Verarbeitung funktioniert weiterhin.';

  @override
  String get voiceGroupAi => 'KI-Geräuschunterdrückung';

  @override
  String get voiceAiFooter =>
      'Entfernt Tastaturklicks, Lüfter und Hintergrundstimmen aus dem Anruf mithilfe eines neuronalen Netzes auf dem Gerät (RNNoise). Nichts verlässt Ihr Gerät. Eine höhere Stärke entfernt mehr Geräusche, kann aber Wortanfänge abschneiden.';

  @override
  String get voiceMic => 'Mein Mikrofon';

  @override
  String get voiceMicHint => 'Verbessert, was die andere Person hört';

  @override
  String get voiceOthers => 'Andere Teilnehmer';

  @override
  String get voiceOthersHint => 'Verbessert Anrufer mit Störgeräuschen';

  @override
  String voiceStrength(String value) {
    return 'Stärke: $value';
  }

  @override
  String get voiceGroupTry => 'Ausprobieren';

  @override
  String get voiceTryFooter =>
      'Verwenden Sie für den Echotest Kopfhörer, sonst hören Sie Rückkopplungen.';

  @override
  String get voiceEchoTest => 'Mit Echo testen';

  @override
  String get voiceEchoTestHint =>
      'Gibt Ihr verarbeitetes Mikrofonsignal an Sie zurück';

  @override
  String get voiceEchoFailed => 'Echotest fehlgeschlagen';

  @override
  String get voiceGroupSystem => 'System';

  @override
  String get voiceSystemFooter =>
      'macOS und iOS können Ihre Stimme auch für jede App isolieren. Wählen Sie im Mikrofonmodus des Systems Stimmisolierung.';

  @override
  String get voiceSystemMode => 'Mikrofonmodus des Systems (Stimmisolierung)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Mikrofonmodi erfordern macOS 12 oder iOS 15 oder neuer.';

  @override
  String get voiceSpeechDetection => 'Spracherkennung';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent Prozent';
  }

  @override
  String voicePercent(int percent) {
    return '$percent %';
  }

  @override
  String get voiceGroupAndroid => 'Android-Audioeffekte';

  @override
  String get voiceAndroidFooter =>
      'Das Telefon kann das Mikrofon auch selbst bereinigen. Diese Angaben stammen von Android und sind von der obigen Einstellung unabhängig.';

  @override
  String get voiceAndroidNs => 'Rauschunterdrücker';

  @override
  String get voiceAndroidAec => 'Echounterdrücker';

  @override
  String get voiceNotAvailableDevice => 'Auf diesem Gerät nicht verfügbar';

  @override
  String get callLinkNotLocal =>
      'Dieser Linktyp kann nur über die Befehlszeile dieses Computers verwendet werden.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Mit Gerät $name verbinden?';
  }

  @override
  String get linkLanConnectBody =>
      'Ein Link aus einer anderen App oder von einer Webseite möchte SoftphonePro mit diesem Gerät verbinden. Nur verbinden, wenn Sie das erwarten.';

  @override
  String get linkLanConnectAction => 'Verbinden';

  @override
  String get linkImportSensitiveHeader =>
      'Sicherheitsrelevante Änderungen in dieser Konfiguration:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Nimmt eingehende Anrufe automatisch an';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Leitet Anrufe an $target weiter';
  }

  @override
  String get linkImportFlagIntercom =>
      'Ändert, wer eine Gegensprechverbindung starten oder einen Anruf abholen darf (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Schreibt die gewählten Nummern um';

  @override
  String get linkImportFlagLinksImmediately =>
      'Anrufe aus Weblinks starten sofort, ohne Bestätigung';

  @override
  String get linkImportFlagDiagnostics =>
      'Aktiviert ausführliche Protokollierung oder SIP-Trace';

  @override
  String get linkImportAllowAutoAnswer =>
      'Automatische Annahme für die importierten Konten erlauben';

  @override
  String linkImportRefused(String setting) {
    return 'Dieser Link versucht, „$setting“ zu ändern; das ist nur per Datei oder Befehlszeile möglich. Es wurde nichts importiert.';
  }

  @override
  String get lanPairIntercomNote =>
      'Gekoppelte Geräte können eine Gegensprechverbindung anfragen; vor jeder werden Sie gefragt (änderbar unter Einstellungen > LAN).';
}
