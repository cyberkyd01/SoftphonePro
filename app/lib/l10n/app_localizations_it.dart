// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinita di sistema';

  @override
  String get languagePickerHint =>
      'I nomi delle lingue sono mostrati nella lingua corrispondente.';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionDone => 'Fine';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionRename => 'Rinomina';

  @override
  String get actionClear => 'Cancella';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionCopy => 'Copia';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionImport => 'Importa';

  @override
  String get actionExport => 'Esporta';

  @override
  String get actionDetails => 'Dettagli';

  @override
  String get actionMore => 'Altro';

  @override
  String get actionSettings => 'Impostazioni';

  @override
  String get actionSearch => 'Cerca';

  @override
  String get actionRefresh => 'Aggiorna';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionYes => 'Sì';

  @override
  String get actionNo => 'No';

  @override
  String get commonOn => 'Attivo';

  @override
  String get commonOff => 'Disattivo';

  @override
  String get commonNone => 'Nessuno';

  @override
  String get commonDefault => 'Predefinito';

  @override
  String get commonSystem => 'Sistema';

  @override
  String get commonAutomatic => 'Automatico';

  @override
  String get commonUnknown => 'Sconosciuto';

  @override
  String get commonNotSet => 'Non impostato';

  @override
  String get commonError => 'Errore';

  @override
  String get commonLoading => 'Caricamento…';

  @override
  String get statusAvailable => 'Disponibile';

  @override
  String get statusDoNotDisturb => 'Non disturbare';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'In chiamata';

  @override
  String get settingsEntryAccounts => 'Account';

  @override
  String get settingsEntryAccountsSub => 'Account SIP e registrazione';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub =>
      'Dispositivi, livelli, cancellazione dell’eco';

  @override
  String get settingsEntryCodecs => 'Codec';

  @override
  String get settingsEntryCodecsSub => 'Ordine, disponibilità, Opus';

  @override
  String get settingsEntryCalls => 'Chiamate';

  @override
  String get settingsEntryCallsSub =>
      'Non disturbare, avviso, risposta automatica, regole di chiamata';

  @override
  String get settingsEntryNetwork => 'Rete';

  @override
  String get settingsEntryNetworkSub => 'Trasporti, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Registrazione';

  @override
  String get settingsEntryNotifications => 'Notifiche e suonerie';

  @override
  String get settingsEntryShortcuts => 'Scorciatoie';

  @override
  String get settingsEntryShortcutsSub => 'Tasti globali, tasti nell’app';

  @override
  String get settingsEntryAppearance => 'Aspetto';

  @override
  String get settingsEntryPrivacy => 'Privacy e sicurezza';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisioning';

  @override
  String get settingsEntryProvisioningSub => 'Importa, esporta, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnostica';

  @override
  String get settingsEntryDiagnosticsSub => 'Traccia SIP, controlli di rete';

  @override
  String get settingsEntryAdvanced => 'Avanzate';

  @override
  String get settingsEntryAbout => 'Informazioni';

  @override
  String get settingsAccountsEmptyTitle => 'Aggiungi il tuo primo account';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Collegati al tuo centralino o provider SIP per iniziare a chiamare.';

  @override
  String get settingsAccountsAdd => 'Aggiungi account';

  @override
  String get settingsAccountsYourAccounts => 'I tuoi account';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  server di backup in uso';
  }

  @override
  String get settingsAudioDevices => 'Dispositivi';

  @override
  String get settingsAudioMicrophone => 'Microfono';

  @override
  String get settingsAudioSpeaker => 'Altoparlante';

  @override
  String get settingsAudioRinger => 'Suoneria';

  @override
  String get settingsAudioRingerSub =>
      'Riproduci la suoneria su un dispositivo separato';

  @override
  String get settingsAudioRefreshDevices => 'Aggiorna dispositivi';

  @override
  String get settingsAudioLevelsAndTest => 'Livelli e test';

  @override
  String get settingsAudioMicVolume => 'Volume del microfono';

  @override
  String get settingsAudioMicLevel => 'Livello microfono';

  @override
  String get settingsAudioSpeakerVolume => 'Volume dell’altoparlante';

  @override
  String get settingsAudioSpeakerLevel => 'Livello altoparlante';

  @override
  String get settingsAudioTestSpeaker => 'Prova altoparlante';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Riproduce un breve tono dall’altoparlante selezionato';

  @override
  String get settingsAudioTestToneFailed =>
      'Impossibile riprodurre il tono di prova';

  @override
  String get settingsAudioEchoTestFailed => 'Test dell’eco non riuscito';

  @override
  String get settingsAudioEchoTest => 'Test dell’eco';

  @override
  String get settingsAudioEchoTestSub =>
      'Riproduce il microfono attraverso l’altoparlante. Usa le cuffie per evitare il feedback.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voce e file';

  @override
  String get settingsAudioVoiceIsolation =>
      'Isolamento vocale (riduzione del rumore con IA)';

  @override
  String get settingsAudioAudioFiles => 'File audio';

  @override
  String get settingsAudioAudioFilesSub => 'Musica d’attesa e annunci';

  @override
  String get settingsAudioProcessing => 'Elaborazione';

  @override
  String get settingsAudioEchoCancellation => 'Cancellazione dell’eco';

  @override
  String get settingsAudioEcSimple => 'Semplice';

  @override
  String get settingsAudioEcPlatform => 'Piattaforma';

  @override
  String get settingsAudioEchoTail => 'Coda dell’eco';

  @override
  String get settingsAudioNoiseSuppression => 'Soppressione del rumore';

  @override
  String get settingsAudioAgc => 'Controllo automatico del guadagno';

  @override
  String get settingsAudioVad => 'Rilevamento dell’attività vocale';

  @override
  String get settingsAudioVadSub => 'Risparmia banda durante il silenzio';

  @override
  String get settingsAudioAdvanced => 'Avanzate';

  @override
  String get settingsAudioAdvancedFooter =>
      'I valori del jitter buffer sono in millisecondi; -1 usa il valore predefinito del motore. Modificarli riavvia il motore di chiamata.';

  @override
  String get settingsAudioPtime => 'Tempo di pacchetto (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter buffer: iniziale';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter buffer: prefetch minimo';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter buffer: prefetch massimo';

  @override
  String get settingsAudioJbMaxSize => 'Jitter buffer: dimensione massima';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microfono $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Altri $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent percento';
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
      other: '$count secondi',
      one: '1 secondo',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Ordine e disponibilità';

  @override
  String get settingsCodecsDragHint =>
      'Trascina per riordinare. Gli account possono sostituire questo elenco nelle proprie impostazioni.';

  @override
  String get settingsCodecsBitrate => 'Bitrate';

  @override
  String get settingsCodecsFec => 'FEC in banda';

  @override
  String get settingsCodecsFecSub => 'Recupera i pacchetti persi';

  @override
  String get settingsCodecsDtxSub => 'Interrompe l’invio durante il silenzio';

  @override
  String get settingsCodecsCbr => 'Bitrate costante';

  @override
  String get settingsCodecsComplexity => 'Complessità';

  @override
  String get settingsCallsIncoming => 'In arrivo';

  @override
  String get settingsCallsDndSub => 'Rifiuta tutte le chiamate in arrivo';

  @override
  String get settingsCallsRejectWith => 'Rifiuta con';

  @override
  String get settingsCallsReasonBusy => 'Occupato (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Temporaneamente non disponibile (480)';

  @override
  String get settingsCallsReasonDecline => 'Rifiutata (603)';

  @override
  String get settingsCallsWaiting => 'Avviso di chiamata';

  @override
  String get settingsCallsWaitingSub =>
      'Consenti una seconda chiamata in arrivo durante una chiamata';

  @override
  String get settingsCallsWhenBusy => 'Se occupato e l’avviso è disattivato';

  @override
  String get settingsCallsRejectAnonymous => 'Rifiuta chiamate anonime';

  @override
  String get settingsCallsLinksImmediately => 'Chiama subito dai link';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'I link tel:, sip: e callto: avviano la chiamata senza attendere nel tastierino';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Sincronizza Non disturbare / inoltro con il centralino tramite codici di servizio';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Compone brevemente i codici con asterisco dell’account (ad esempio *78) quando modifichi Non disturbare o l’inoltro';

  @override
  String get settingsCallsAutoAnswerGroup => 'Risposta automatica';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'L’inoltro di chiamata e la risposta automatica per account si impostano in ciascun account.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Rispondi automaticamente a tutte le chiamate';

  @override
  String get settingsCallsAnswerAfter => 'Rispondi dopo';

  @override
  String get settingsCallsAnswerImmediately => 'Subito';

  @override
  String get settingsCallsIntercomHeaders =>
      'Rispetta le intestazioni interfono';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Indicazioni di risposta automatica Call-Info, Alert-Info e Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Numeri bloccati';

  @override
  String get settingsCallsBlockNumber => 'Blocca un numero';

  @override
  String get settingsCallsBlockNumberTitle => 'Blocca numero';

  @override
  String get settingsCallsBlockNumberHint => 'Numero o indirizzo SIP';

  @override
  String get settingsCallsSpeedDial => 'Chiamata rapida';

  @override
  String get settingsCallsDialPlan => 'Piano di numerazione';

  @override
  String get settingsCallsDialRules => 'Regole di chiamata';

  @override
  String get settingsCallsStripPrefix =>
      'Prefisso di linea esterna da rimuovere';

  @override
  String get settingsCallsStripPrefixSub =>
      'Ad esempio 9, rimosso all’inizio dei numeri composti';

  @override
  String get settingsCallsPlusReplacement => 'Sostituisci il + iniziale con';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Ad esempio 00 per l’accesso internazionale';

  @override
  String get settingsCallsPlusReplacementHint => 'Mantieni +';

  @override
  String get settingsCallsCountryPrefix => 'Prefisso nazionale predefinito';

  @override
  String get settingsCallsCountryPrefixSub =>
      'I numeri nazionali che iniziano con 0 ricevono questo prefisso, ad esempio +39';

  @override
  String get settingsCallsEmergency => 'Numeri di emergenza';

  @override
  String get settingsCallsEmergencySub =>
      'Separati da virgola. Ignorano le regole di chiamata.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Sblocca $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count di 9 assegnati';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regole',
      one: '1 regola',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nuova regola di chiamata';

  @override
  String get settingsDialRulesEdit => 'Modifica regola di chiamata';

  @override
  String get settingsDialRulesName => 'Nome';

  @override
  String get settingsDialRulesPattern => 'Modello (regex)';

  @override
  String get settingsDialRulesReplacement => 'Sostituzione';

  @override
  String get settingsDialRulesReplacementHelp => 'Usa \$1, \$2 per i gruppi';

  @override
  String get settingsDialRulesRoute => 'Instrada tramite account';

  @override
  String get settingsDialRulesAdd => 'Aggiungi regola';

  @override
  String get settingsDialRulesLiveTest => 'Test dal vivo';

  @override
  String get settingsDialRulesTyped => 'Numero digitato';

  @override
  String get settingsDialRulesNothing => '(niente)';

  @override
  String get settingsDialRulesEmergency =>
      'Numero di emergenza: composto come digitato';

  @override
  String get settingsDialRulesAccountFallback => 'account';

  @override
  String get settingsDialRulesEmpty =>
      'Nessuna regola. I numeri vengono ripuliti (spazi, trattini e parentesi rimossi) e composti come digitati. Le regole vengono applicate dall’alto in basso; vale la prima corrispondenza.';

  @override
  String get settingsDialRulesDelete => 'Elimina regola';

  @override
  String get settingsDialRulesDeleteTitle => 'Eliminare la regola?';

  @override
  String settingsDialRulesVia(String account) {
    return 'tramite $account';
  }

  @override
  String get settingsNetworkTransports => 'Trasporti';

  @override
  String get settingsNetworkTransportsFooter =>
      'La porta 0 sceglie una porta libera casuale. Modificare i trasporti riavvia il motore di chiamata.';

  @override
  String get settingsNetworkUdpPort => 'Porta UDP';

  @override
  String get settingsNetworkTcpPort => 'Porta TCP';

  @override
  String get settingsNetworkTlsPort => 'Porta TLS';

  @override
  String get settingsNetworkVerifyCerts => 'Verifica i certificati del server';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Disattiva solo per centralini con certificato autofirmato, oppure blocca il certificato qui sotto';

  @override
  String get settingsNetworkCustomCa => 'File CA personalizzato';

  @override
  String get settingsNetworkCustomCaSub =>
      'Bundle PEM usato al posto dell’elenco integrato (CA del centralino privato)';

  @override
  String get settingsNetworkCustomCaHint => 'Elenco Mozilla integrato';

  @override
  String get settingsNetworkPins => 'Certificati bloccati';

  @override
  String get settingsNetworkPinsSub =>
      'host=impronta SHA256, separati da virgola';

  @override
  String get settingsNetworkNat => 'Attraversamento NAT';

  @override
  String get settingsNetworkStun => 'Server STUN';

  @override
  String get settingsNetworkStunSub => 'host:porta, separati da virgola';

  @override
  String get settingsNetworkIceTurn => 'ICE e TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Configurati per account in NAT';

  @override
  String get settingsNetworkAdvanced => 'Avanzate';

  @override
  String get settingsNetworkQos => 'QoS (marcatura DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Contrassegna i pacchetti SIP e voce come prioritari';

  @override
  String get settingsNetworkDns => 'Server DNS';

  @override
  String get settingsNetworkDnsSub => 'Lascia vuoto per automatico';

  @override
  String get settingsNetworkRtpStart => 'Porta RTP iniziale';

  @override
  String get settingsNetworkRtpRange => 'Intervallo porte RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 usa il valore predefinito';

  @override
  String get settingsNotifRingtone => 'Suoneria';

  @override
  String get settingsNotifDefaultRingtone => 'Suoneria predefinita';

  @override
  String get settingsNotifProgressTones => 'Toni di avanzamento chiamata';

  @override
  String get settingsNotifProgressTonesSub =>
      'Toni di libero, occupato e congestione durante la composizione';

  @override
  String get settingsNotifRingerVolume => 'Volume della suoneria';

  @override
  String get settingsNotifCustomRingtone => 'File suoneria personalizzata';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Percorso di un file WAV (desktop)';

  @override
  String get settingsNotifGroup => 'Notifiche';

  @override
  String get settingsNotifRequestPermissions => 'Richiedi autorizzazioni';

  @override
  String get settingsNotifRequestPermissionsSub => 'Microfono e notifiche';

  @override
  String get settingsNotifTyping => 'Invia indicatori di scrittura';

  @override
  String get settingsAppearanceTheme => 'Tema';

  @override
  String get settingsAppearanceLight => 'Chiaro';

  @override
  String get settingsAppearanceDark => 'Scuro';

  @override
  String get settingsAppearanceAccent => 'Colore di accento';

  @override
  String get settingsAppearanceAccentOption => 'Opzione colore di accento';

  @override
  String get settingsAppearanceCompact => 'Densità compatta';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microfono: $microphone, notifiche: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Sicurezza';

  @override
  String get settingsPrivacyPasswords => 'Password';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Archiviate nel portachiavi / keystore di sistema (file cifrato come alternativa)';

  @override
  String get settingsPrivacyGroup => 'Privacy';

  @override
  String get settingsPrivacyNoTelemetry => 'Nessuna telemetria';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro non invia dati analitici. Il traffico di rete va solo ai tuoi server SIP.';

  @override
  String get settingsPrivacyYourData => 'I tuoi dati';

  @override
  String get settingsPrivacyClearHistory => 'Cancella cronologia chiamate';

  @override
  String get settingsPrivacyDeleteContacts => 'Elimina tutti i contatti';

  @override
  String get settingsPrivacyDeleteMessages => 'Elimina tutti i messaggi';

  @override
  String get settingsPrivacyConfirmHistory =>
      'Eliminare la cronologia chiamate?';

  @override
  String get settingsPrivacyConfirmContacts => 'Eliminare tutti i contatti?';

  @override
  String get settingsPrivacyConfirmMessages => 'Eliminare tutti i messaggi?';

  @override
  String get settingsPrivacyCannotUndo =>
      'L’operazione non può essere annullata.';

  @override
  String get settingsPrivacyDeletedHistory => 'Cronologia chiamate eliminata';

  @override
  String get settingsPrivacyDeletedContacts => 'Tutti i contatti eliminati';

  @override
  String get settingsPrivacyDeletedMessages => 'Tutti i messaggi eliminati';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'I dispositivi sulla stessa rete si trovano a vicenda, si associano con un codice di 6 cifre e comunicano direttamente, senza alcun server.';

  @override
  String get settingsLanEnable => 'Attiva LAN Link';

  @override
  String get settingsLanDeviceName => 'Nome del dispositivo';

  @override
  String get settingsLanDeviceNameHint => 'Questo dispositivo';

  @override
  String get settingsLanAllowIntercom => 'Consenti interfono';

  @override
  String get settingsLanAllowIntercomSub =>
      'I dispositivi associati possono chiamarti e ricevere risposta automatica';

  @override
  String get settingsLanAskIntercom => 'Chiedi prima di consentire l’interfono';

  @override
  String get settingsLanAskIntercomSub =>
      'Altrimenti i dispositivi associati ricevono risposta automatica per 30 s dopo la richiesta';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Accetta automaticamente i file dai dispositivi associati';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Altrimenti ti viene chiesto per ogni file';

  @override
  String get settingsLanAllowPull =>
      'Consenti ai dispositivi associati di prelevare le mie chiamate';

  @override
  String get settingsLanAllowPullSub =>
      'Un dispositivo associato può rilevare una chiamata attiva qui';

  @override
  String get settingsLanDownloads => 'Cartella dei download';

  @override
  String get settingsLanDownloadsHint => 'Predefinita (Download/SoftphonePro)';

  @override
  String get settingsLanPort => 'Porta del collegamento';

  @override
  String get settingsLanSharedAccounts =>
      'Account condivisi con i dispositivi associati';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Condividere un account registrato permette a un dispositivo associato sullo stesso server di ricevere direttamente le tue chiamate (trasferimento di chiamata) invece di inoltrarle.';

  @override
  String get settingsAdvEngine => 'Motore';

  @override
  String get settingsAdvSimulator => 'Usa simulatore';

  @override
  String get settingsAdvSimulatorSub =>
      'Funziona senza il motore nativo. Le chiamate sono simulate.';

  @override
  String get settingsAdvLogLevel => 'Livello di log';

  @override
  String get settingsAdvLogErrors => 'Errori';

  @override
  String get settingsAdvLogInfo => 'Info';

  @override
  String get settingsAdvLogDebug => 'Debug';

  @override
  String get settingsAdvLogVerbose => 'Dettagliato';

  @override
  String get settingsAdvSipTrace => 'Traccia SIP';

  @override
  String get settingsAdvRestartEngine => 'Riavvia motore';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Avvia all’accesso';

  @override
  String get settingsAdvCloseToTray =>
      'Riduci nell’area di notifica alla chiusura';

  @override
  String get settingsAdvCloseToTraySub =>
      'Chiudendo la finestra SoftphonePro resta in esecuzione, così le chiamate possono ancora squillare. Esci dall’icona nell’area di notifica / barra dei menu.';

  @override
  String get settingsAboutLicence => 'Licenza';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro è software libero: puoi ridistribuirlo e/o modificarlo secondo i termini della GNU General Public License pubblicata dalla Free Software Foundation, versione 3 o successiva. È distribuito SENZA ALCUNA GARANZIA.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 o successiva';

  @override
  String get settingsAboutGplSub =>
      'Codice sorgente disponibile nel repository del progetto';

  @override
  String get settingsAboutThirdParty => 'Avvisi di terze parti';

  @override
  String get settingsAboutPackages => 'Pacchetti Flutter e Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT e Apache 2.0. Vedi la pagina delle licenze.';

  @override
  String settingsAboutVersion(String version) {
    return 'Versione $version';
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
    return '$license. $purpose. Versione $version.';
  }

  @override
  String get updatesChecking => 'Controllo in corso...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version è disponibile';
  }

  @override
  String get updatesUpToDate => 'Sei aggiornato';

  @override
  String get updatesCouldNotCheck => 'Controllo non riuscito';

  @override
  String get updatesNotCheckedYet => 'Non ancora controllato';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Ultimo controllo $dateString';
  }

  @override
  String get updatesTitle => 'Aggiornamenti';

  @override
  String get updatesFooter =>
      'Il controllo contatta solo api.github.com (una volta a settimana) e non invia nulla oltre alla richiesta stessa: nessun identificativo, nessun dato di account o chiamate. SoftphonePro non scarica né installa mai nulla da solo.';

  @override
  String get updatesCheckSwitch => 'Cerca aggiornamenti';

  @override
  String get updatesCheckNow => 'Controlla ora';

  @override
  String updatesSkippingVersion(String version) {
    return 'Versione $version ignorata';
  }

  @override
  String get updatesStopSkipping => 'Non ignorare più';

  @override
  String get updatesReleaseNotes => 'Note di rilascio';

  @override
  String get updatesDownload => 'Scarica';

  @override
  String get updatesSkipVersion => 'Ignora questa versione';

  @override
  String get updatesDismiss => 'Chiudi';

  @override
  String get updatesRateLimited =>
      'Limite di richieste GitHub raggiunto, riprova più tardi';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub ha risposto $status';
  }

  @override
  String get updatesUnexpectedReply => 'Risposta imprevista';

  @override
  String get updatesTimedOut => 'Tempo scaduto';

  @override
  String get updatesAlreadyChecking => 'Controllo già in corso';

  @override
  String get encryptionTitle => 'Crittografia';

  @override
  String get encryptionFooter =>
      'Cifra il database locale con AES-256-GCM. La chiave è conservata nel portachiavi / keystore di sistema; se viene persa i dati non possono essere recuperati. Le registrazioni delle chiamate e i file esportati non sono cifrati. La modifica ha effetto al prossimo avvio di SoftphonePro (chiudilo prima completamente); il file precedente viene sovrascritto ed eliminato non appena il nuovo database è stato aperto e verificato.';

  @override
  String get encryptionSwitchTitle =>
      'Cifra cronologia chiamate, contatti e messaggi su questo dispositivo';

  @override
  String get encryptionWillEncrypt => 'Sarà cifrato al prossimo avvio';

  @override
  String get encryptionWillDecrypt => 'Sarà decifrato al prossimo avvio';

  @override
  String get encryptionRestartToEncrypt =>
      'Esci e riavvia SoftphonePro per cifrare i tuoi dati.';

  @override
  String get encryptionRestartToDecrypt =>
      'Esci e riavvia SoftphonePro per decifrare i tuoi dati.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Chiamata rapida $slot';
  }

  @override
  String get speedDialNumberLabel => 'Numero o indirizzo SIP';

  @override
  String get speedDialLabelOptional => 'Etichetta (facoltativa)';

  @override
  String get speedDialCallFrom => 'Chiama da';

  @override
  String get speedDialSelectedAccount => 'Account selezionato';

  @override
  String get speedDialTitle => 'Chiamata rapida';

  @override
  String get speedDialHint =>
      'Tieni premuta una cifra (1-9) sul tastierino vuoto per chiamare il suo numero.';

  @override
  String get speedDialNotAssigned => 'Non assegnato';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON non valido: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Era previsto un oggetto JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Versione di configurazione $version non supportata';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Voce di account non oggetto ignorata';

  @override
  String get provisioningNothingToImport =>
      'Il file non contiene account né impostazioni';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'L’account “$name” richiede nome utente e dominio';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Il server ha risposto $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Impossibile scaricare la configurazione: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Impossibile leggere $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importati $count account',
      one: 'Importato 1 account',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Importa configurazione';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts account',
      one: '1 account',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings impostazioni',
      one: '1 impostazione',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Importa da URL o JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... oppure incolla JSON';

  @override
  String get provisioningInvalidSource =>
      'Non è un URL, un link o un JSON valido';

  @override
  String get provisioningScanTitle => 'Scansiona QR di provisioning';

  @override
  String get provisioningPasteHint => 'Incolla JSON, un link o un URL';

  @override
  String get provisioningImportGroup => 'Importa';

  @override
  String get provisioningImportFooter =>
      'Supporta JSON con account e impostazioni. I segnaposto \${VAR} vengono sostituiti con valori vuoti, a meno che sia indicato un valore predefinito come \${VAR:-default}.';

  @override
  String get provisioningScanQr => 'Scansiona codice QR';

  @override
  String get provisioningFromUrl => 'Da URL o JSON incollato';

  @override
  String get provisioningFromFile => 'Da file';

  @override
  String get provisioningFromClipboard => 'Dagli appunti';

  @override
  String get provisioningExportGroup => 'Esporta';

  @override
  String get provisioningIncludePasswords => 'Includi le password';

  @override
  String get provisioningIncludePasswordsHint =>
      'Chiunque abbia il file può usare i tuoi account';

  @override
  String get provisioningCopyConfig => 'Copia configurazione (JSON)';

  @override
  String get provisioningConfigCopied => 'Configurazione copiata';

  @override
  String get provisioningQrGroup => 'Codice QR';

  @override
  String get provisioningQrFooter =>
      'Scansiona questo codice su un altro dispositivo per copiare un account. Trattalo come una password se ne contiene una.';

  @override
  String get provisioningQrAccount => 'Account';

  @override
  String get provisioningChoose => 'Scegli...';

  @override
  String get provisioningQrTooMuchData => 'Troppi dati per un codice QR';

  @override
  String tlsClearField(String field) {
    return 'Cancella $field';
  }

  @override
  String get tlsChoose => 'Scegli...';

  @override
  String get tlsChange => 'Cambia...';

  @override
  String get tlsClientCertTitle => 'Certificato client (TLS reciproco)';

  @override
  String get tlsIncomplete =>
      'Scegli sia un certificato sia la relativa chiave privata. Il certificato viene presentato solo quando sono impostati entrambi.';

  @override
  String get tlsFooter =>
      'Per i server che richiedono all’app di identificarsi con un certificato. File PEM. Usato per TLS e WebSocket sicuro.';

  @override
  String get tlsCertFile => 'File del certificato';

  @override
  String get tlsKeyFile => 'File della chiave privata';

  @override
  String get tlsKeyPassword => 'Password della chiave';

  @override
  String get tlsKeyPasswordHint => 'Solo se la chiave è cifrata';

  @override
  String get callSettingsHoldGroupTitle => 'Attesa';

  @override
  String get callSettingsHoldFooter =>
      'Con “Predefinito del centralino” la chiamata viene semplicemente messa in attesa e il sistema telefonico può riprodurre la propria musica. Qualsiasi altra scelta viene riprodotta a chi chiama da questa app.';

  @override
  String get callSettingsHoldMusic => 'Musica d’attesa';

  @override
  String get callSettingsHoldPbxDefault => 'Predefinito del centralino';

  @override
  String get callSettingsHoldMusicVolume => 'Volume musica d’attesa';

  @override
  String get callSettingsHoldAudioFiles => 'File audio';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Importa o registra musica d’attesa';

  @override
  String get callSettingsAnnounceTitle => 'Annunci';

  @override
  String get callSettingsAnnounceFooter =>
      'Gli annunci vengono riprodotti all’altra parte. Se il file manca, tutto viene saltato senza avvisi.';

  @override
  String get callSettingsAnnounceOpening => 'Annuncio di apertura';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Riproduci un messaggio quando la chiamata si connette';

  @override
  String get callSettingsAnnounceFile => 'File dell’annuncio';

  @override
  String get callSettingsAnnounceChooseFile => 'Scegli un file';

  @override
  String get callSettingsAnnouncePlayFor => 'Riproduci per';

  @override
  String get callSettingsAnnounceBoth => 'In arrivo e in uscita';

  @override
  String get callSettingsAnnounceIncoming => 'Chiamate in arrivo';

  @override
  String get callSettingsAnnounceOutgoing => 'Chiamate in uscita';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Silenzia il mio microfono durante la riproduzione';

  @override
  String get callSettingsAnnounceMonitor => 'Fammelo ascoltare anche a me';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Prima dell’avvio della registrazione, riproduci';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Prima di trasferire un chiamante, riproduci';

  @override
  String get morePageTitle => 'Altro';

  @override
  String get morePresence => 'Presenza';

  @override
  String get morePresenceHint => 'Campo lampada occupato';

  @override
  String get moreRetrieveParked => 'Recupera chiamata parcheggiata';

  @override
  String get moreRetrieveParkedHint => 'Componi uno slot di parcheggio';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Dispositivi vicini, chat e scambio file';

  @override
  String get moreRecordings => 'Registrazioni';

  @override
  String get moreRecordingsHint =>
      'Ascolta, condividi e gestisci le registrazioni delle chiamate';

  @override
  String get moreVoicemail => 'Segreteria';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi messaggi',
      one: '1 nuovo messaggio',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Chiama la tua segreteria';

  @override
  String get moreDiagnostics => 'Diagnostica';

  @override
  String get moreDiagnosticsHint => 'Traccia SIP e controlli di rete';

  @override
  String get moreAbout => 'Informazioni';

  @override
  String get moreNoVoicemailNumber =>
      'Nessun numero di segreteria impostato. Aggiungilo nelle impostazioni dell’account.';

  @override
  String get moreSearchHint => 'Cerca contatti, cronologia o digita un numero';

  @override
  String moreCallNumber(String number) {
    return 'Chiama $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Blocco app';

  @override
  String get appLockFooter =>
      'Le chiamate squillano e possono ricevere risposta anche con l’app bloccata.';

  @override
  String get appLockRequirePin => 'Richiedi il PIN per aprire l’app';

  @override
  String get appLockOnHint =>
      'Cronologia, contatti, messaggi e impostazioni sono bloccati';

  @override
  String get appLockIsOn => 'Blocco app attivo';

  @override
  String get appLockIsOff => 'Blocco app disattivato';

  @override
  String get appLockTurnOff => 'Disattiva blocco app';

  @override
  String get appLockChangePin => 'Cambia PIN';

  @override
  String get appLockEnterCurrent => 'Inserisci il PIN attuale';

  @override
  String get appLockPinChanged => 'PIN modificato';

  @override
  String get appLockLockAfter => 'Blocca dopo';

  @override
  String get appLockLockAfterHint =>
      'Tempo in background prima che serva di nuovo il PIN';

  @override
  String get appLockImmediately => 'Subito';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 ora';

  @override
  String get appLockBiometrics => 'Sblocca con biometria';

  @override
  String get appLockNow => 'Blocca ora';

  @override
  String get appLockSetPin => 'Imposta un PIN';

  @override
  String get appLockPinDigits => 'PIN (4-8 cifre)';

  @override
  String get appLockRepeatPin => 'Ripeti PIN';

  @override
  String get appLockUseDigits => 'Usa da 4 a 8 cifre';

  @override
  String get appLockMismatch => 'I PIN non corrispondono';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Troppi tentativi. Riprova tra $seconds s';
  }

  @override
  String get appLockWrongPin => 'PIN errato';

  @override
  String get appLockTooMany => 'Troppi tentativi';

  @override
  String get appLockIsLocked => 'SoftphonePro è bloccato';

  @override
  String get appLockEnterPin => 'Inserisci il tuo PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Riprova tra $time';
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
  String get appLockUnlock => 'Sblocca';

  @override
  String get appLockIncomingCall => 'Chiamata in arrivo';

  @override
  String get appLockDecline => 'Rifiuta';

  @override
  String get appLockAnswer => 'Rispondi';

  @override
  String get appLockHangUp => 'Termina';

  @override
  String get appLockBiometricReason => 'Sblocca SoftphonePro';

  @override
  String get automationNoToken =>
      'Nessun token di accesso impostato. Generane uno in Impostazioni > Avanzate.';

  @override
  String automationInvalidPort(int port) {
    return 'Porta $port non valida';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Avvio non riuscito: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'La porta $port non è disponibile ($error). Scegli un’altra porta.';
  }

  @override
  String get automationTokenPlaceholder => 'Creato quando attivi l’API';

  @override
  String automationListening(String address) {
    return 'In ascolto su $address';
  }

  @override
  String get automationStarting => 'Avvio in corso...';

  @override
  String get automationTitle => 'API di automazione locale';

  @override
  String get automationFooter =>
      'Per integrazioni CRM e helpdesk su questo computer. Ascolta solo su 127.0.0.1 e ogni richiesta richiede il token di accesso. Vedi docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Attiva API di automazione locale';

  @override
  String get automationPort => 'Porta';

  @override
  String get automationPortHint =>
      'Predefinita 7771. Scegli una porta libera tra 1024 e 65535.';

  @override
  String get automationPortInvalid => 'Inserisci una porta da 1024 a 65535';

  @override
  String get automationAccessToken => 'Token di accesso';

  @override
  String get automationHideToken => 'Nascondi token';

  @override
  String get automationShowToken => 'Mostra token';

  @override
  String get automationCopyToken => 'Copia token';

  @override
  String get automationTokenCopied => 'Token copiato';

  @override
  String get automationGenerateToken => 'Genera un nuovo token';

  @override
  String get automationGenerateTitle => 'Generare un nuovo token?';

  @override
  String get automationGenerateBody =>
      'I programmi che usano il vecchio token smettono di funzionare finché non fornisci loro quello nuovo.';

  @override
  String get automationGenerate => 'Genera';

  @override
  String get automationOrigins => 'Origini browser consentite';

  @override
  String get automationOriginsHint =>
      'Separate da virgola, ad esempio https://crm.example.com. I programmi senza browser (curl, script) non ne hanno bisogno.';

  @override
  String automationNotOrigin(String origin) {
    return 'Non è un’origine http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'Rispondi';

  @override
  String get trayNotificationDecline => 'Rifiuta';

  @override
  String get trayTooltipInCall => 'SoftphonePro - in chiamata';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nuovi';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - nessun account (Assente)',
      'dnd': 'SoftphonePro - nessun account (Non disturbare)',
      'other': 'SoftphonePro - nessun account',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Assente)',
      'dnd': 'SoftphonePro - $online/$total online (Non disturbare)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Nascondi SoftphonePro';

  @override
  String get trayShowApp => 'Mostra SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nuovi - apri Recenti';
  }

  @override
  String get trayStatus => 'Stato';

  @override
  String get trayStatusAway => 'Assente';

  @override
  String get trayAccounts => 'Account';

  @override
  String get trayQuit => 'Esci da SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Rispondi alla chiamata';

  @override
  String get hotkeyHangUp => 'Termina chiamata';

  @override
  String get hotkeyMute => 'Silenzia / riattiva audio';

  @override
  String get hotkeyFocusDialer => 'Vai al tastierino';

  @override
  String get shortcutsGlobalTitle => 'Tasti di scelta rapida globali';

  @override
  String get shortcutsGlobalFooter =>
      'Funzionano da qualsiasi applicazione. Un altro programma che usa già una combinazione può impedirne la registrazione.';

  @override
  String get shortcutsChange => 'Cambia';

  @override
  String get shortcutsRestoreDefaults => 'Ripristina predefiniti';

  @override
  String get shortcutsMediaTitle => 'Cuffie e tasti multimediali';

  @override
  String get shortcutsMediaFooter =>
      'Il pulsante play/pausa di cuffie o tastiera viene assegnato all’app solo mentre una chiamata squilla o è attiva, così i lettori musicali lo mantengono il resto del tempo.';

  @override
  String get shortcutsMediaSwitch =>
      'Rispondi e termina con il pulsante play/pausa di cuffie/multimediale';

  @override
  String get shortcutsMediaDuringCall => 'Durante una chiamata il pulsante';

  @override
  String get shortcutsMediaHangsUp => 'Termina la chiamata';

  @override
  String get shortcutsMediaMutes => 'Silenzia / riattiva audio';

  @override
  String get shortcutsInApp => 'Nell’app';

  @override
  String get shortcutsFocusDialer => 'Vai al tastierino';

  @override
  String get shortcutsHoldResume => 'Attesa / riprendi';

  @override
  String get shortcutsTransfer => 'Trasferisci';

  @override
  String get shortcutsEndCall => 'Termina chiamata';

  @override
  String get shortcutsNeedX11 =>
      'Le scorciatoie globali richiedono una sessione X11. Wayland non consente alle app di intercettare i tasti a livello di sistema.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Aggiungi Ctrl, Alt, Maiusc o $key a una lettera o cifra';
  }

  @override
  String get shortcutsPressNew => 'Premi la nuova combinazione di tasti';

  @override
  String get defaultHandlerChooseInSettings =>
      'Scegli SoftphonePro per SIP, TEL e CALLTO in App predefinite';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro ora apre i link sip:, tel: e callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Impossibile cambiare l’app predefinita per $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Apre i link sip:, tel: e callto: da browser e altre app';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro gestisce i link sip:, tel: e callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Ora: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Imposta SoftphonePro come app predefinita per i link sip:, tel: e callto:';

  @override
  String get reliabilityTitle => 'Affidabilità in background';

  @override
  String get reliabilityMicrophone => 'Microfono';

  @override
  String get reliabilityAllowed => 'Consentito';

  @override
  String get reliabilityMicNeeded =>
      'Necessario per parlare durante le chiamate';

  @override
  String get reliabilityNotifications => 'Notifiche';

  @override
  String get reliabilityNotifNeeded =>
      'Necessarie per mostrare le chiamate in arrivo e mantenere visibile il servizio';

  @override
  String get reliabilityFullScreen => 'Chiamate in arrivo a schermo intero';

  @override
  String get reliabilityFullScreenNeeded =>
      'Consenti per mostrare le chiamate sopra la schermata di blocco';

  @override
  String get reliabilityBattery => 'Uso batteria senza restrizioni';

  @override
  String get reliabilityBatteryExempt =>
      'Escluso dall’ottimizzazione della batteria';

  @override
  String get reliabilityBatteryNeeded =>
      'Android può sospendere l’app e perdere chiamate per risparmiare energia. Tocca per escludere SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'Avvio automatico / app protette di $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'Il produttore del telefono potrebbe chiudere le app in background. Consenti l’avvio automatico di SoftphonePro.';

  @override
  String get reliabilityBoot => 'Avvia all’accensione';

  @override
  String get reliabilityBootHint =>
      'Registra gli account dopo il riavvio del telefono';

  @override
  String get reliabilityWake => 'Mantieni la CPU attiva in standby';

  @override
  String get reliabilityWakeHint =>
      'Più affidabile sui dispositivi restrittivi; consuma più batteria';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Rimuovi $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Ultimo errore: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Intervallo consentito da $min a $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Deve essere almeno $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Deve essere al massimo $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Scartare le modifiche?';

  @override
  String get acctEditorDiscardMessage =>
      'Le modifiche a questo account non sono salvate.';

  @override
  String get acctEditorDiscardConfirm => 'Scarta';

  @override
  String get acctEditorDeleteMessage =>
      'L’account e la sua password salvata verranno rimossi da questo dispositivo.';

  @override
  String get acctEditorMenuDelete => 'Elimina account';

  @override
  String get acctGroupBasic => 'Base';

  @override
  String get acctFieldLabel => 'Etichetta';

  @override
  String get acctFieldLabelHint => 'es. Ufficio';

  @override
  String get acctFieldDisplayName => 'Nome visualizzato';

  @override
  String get acctFieldUsername => 'Nome utente';

  @override
  String get acctFieldProtocol => 'Protocollo';

  @override
  String get acctFieldProtocolSub => 'Fisso dopo la creazione dell’account';

  @override
  String get acctFieldAuthUser => 'Utente di autorizzazione';

  @override
  String get acctFieldAuthUserHint => 'Uguale al nome utente';

  @override
  String get acctFieldAuthUserSub =>
      'Solo se il provider usa un nome di accesso diverso dal nome utente';

  @override
  String get acctFieldPassword => 'Password';

  @override
  String get acctFieldServerHost => 'Host del server';

  @override
  String get acctFieldPort => 'Porta';

  @override
  String get acctFieldIaxPortSub => 'Il valore predefinito di IAX2 è 4569';

  @override
  String get acctFieldIaxContext => 'Contesto';

  @override
  String get acctFieldIaxContextSub =>
      'Facoltativo. Inviato al centralino come contesto chiamato';

  @override
  String get acctFieldServerDomain => 'Server / dominio';

  @override
  String get acctFieldServerDomainSub => 'host oppure host:porta';

  @override
  String get acctFieldEnabled => 'Attivo';

  @override
  String get acctFieldDefault =>
      'Account predefinito per le chiamate in uscita';

  @override
  String get acctFieldColour => 'Colore';

  @override
  String get acctGroupRegistration => 'Registrazione';

  @override
  String get acctFieldRegister => 'Registra';

  @override
  String get acctFieldRegisterSubIax =>
      'Disattiva per i peer che non richiedono registrazione';

  @override
  String get acctFieldRegExpiry => 'Scadenza registrazione (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk di solito impone 60 s. Intervallo da 10 a 86400';

  @override
  String get acctFieldRetryInterval => 'Intervallo di nuovo tentativo (s)';

  @override
  String get acctFieldFirstRetry => 'Primo nuovo tentativo (s)';

  @override
  String get acctGroupCodecs => 'Codec';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 supporta G.711 e GSM. Trascina per impostare l’ordine di preferenza.';

  @override
  String get acctCodecAdd => 'Aggiungi codec';

  @override
  String get acctGroupServerTransport => 'Server e trasporto';

  @override
  String get acctFieldRegistrar => 'Registrar alternativo';

  @override
  String get acctFieldBackupRegistrar => 'Registrar di backup';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Usato dopo 3 tentativi falliti; il principale viene riprovato ogni 5 minuti';

  @override
  String get acctFieldProxies => 'Proxy in uscita';

  @override
  String get acctFieldTransport => 'Trasporto';

  @override
  String get acctFieldTransportAutoSub =>
      'Cerca i record DNS SRV del server e sceglie TLS, TCP o UDP';

  @override
  String get acctTransportAuto => 'Automatico (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Percorso WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'Percorso HTTP dell’upgrade WebSocket, ad es. /ws. Deve iniziare con “/”';

  @override
  String get acctFieldRegExpirySubSip =>
      'Da 300 a 3600 è tipico. Intervallo da 10 a 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'Intervallo keep-alive UDP. 0 lo disattiva. Intervallo da 0 a 3600';

  @override
  String get acctFieldLocalPort => 'Porta SIP locale';

  @override
  String get acctFieldLocalPortSub =>
      '0 usa il trasporto condiviso. Intervallo da 0 a 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Disattiva per i trunk senza registrazione';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Mantiene un flusso persistente attraverso il NAT. Richiede il supporto del server';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Usa STUN';

  @override
  String get acctFieldTurn => 'Relay TURN';

  @override
  String get acctFieldTurnServer => 'Server TURN';

  @override
  String get acctFieldTurnUsername => 'Nome utente TURN';

  @override
  String get acctFieldTurnPassword => 'Password TURN';

  @override
  String get acctFieldContactRewrite => 'Riscrivi intestazione Contact';

  @override
  String get acctFieldViaRewrite => 'Riscrivi intestazione Via';

  @override
  String get acctFieldRewriteSub =>
      'Usa l’indirizzo visto dal server. Mantieni attivo dietro NAT';

  @override
  String get acctFieldSdpRewrite => 'Riscrivi indirizzo SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'Sostituisce l’indirizzo multimediale nell’SDP con quello pubblico';

  @override
  String get acctFieldIpv6Sip => 'Segnalazione IPv6';

  @override
  String get acctFieldIpv6Media => 'Media IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Media avanzati';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'I gateway WebRTC richiedono multiplexing RTCP e feedback RTCP.';

  @override
  String get acctFieldRtcpMux => 'Multiplexing RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Invia RTP e RTCP su una sola porta (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Feedback RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Offre RTP/AVPF con NACK. Necessario per i server WebRTC';

  @override
  String get acctGroupSecurity => 'Sicurezza';

  @override
  String get acctFieldSrtp => 'Crittografia media (SRTP)';

  @override
  String get acctOptOptional => 'Facoltativa';

  @override
  String get acctOptRequired => 'Obbligatoria';

  @override
  String get acctFieldKeyExchange => 'Scambio chiavi';

  @override
  String get acctFieldSecureSignaling => 'Segnalazione sicura';

  @override
  String get acctOptNotRequired => 'Non richiesta';

  @override
  String get acctOptTlsHop => 'TLS hop-by-hop';

  @override
  String get acctOptTlsE2e => 'TLS end-to-end (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Algoritmo di autenticazione';

  @override
  String get acctFieldPrivacy => 'Nascondi ID chiamante (privacy)';

  @override
  String get acctFieldReferPolicy => 'Trasferimenti in arrivo (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Osservatori di presenza';

  @override
  String get acctOptAccept => 'Accetta';

  @override
  String get acctOptReject => 'Rifiuta';

  @override
  String get acctGroupCodecsFooter =>
      'Sostituisce l’elenco globale dei codec per questo account.';

  @override
  String get acctFieldUseGlobalCodecs => 'Usa l’ordine globale dei codec';

  @override
  String get acctGroupFeatures => 'Funzioni';

  @override
  String get acctFieldVoicemailNumber => 'Numero della segreteria';

  @override
  String get acctFieldMwi => 'Indicatore segreteria (MWI)';

  @override
  String get acctFieldMwiSub =>
      'Sottoscrivi le notifiche di messaggi in attesa';

  @override
  String get acctFieldPublishPresence => 'Pubblica la mia presenza';

  @override
  String get acctFieldPublishPresenceSub =>
      'Consenti al server di condividere il tuo stato online';

  @override
  String get acctFieldDnd => 'Non disturbare';

  @override
  String get acctFieldForwarding => 'Inoltro di chiamata';

  @override
  String get acctOptForwardAlways => 'Sempre';

  @override
  String get acctOptForwardBusy => 'Se occupato';

  @override
  String get acctOptForwardNoAnswer => 'Senza risposta';

  @override
  String get acctFieldForwardTo => 'Inoltra a';

  @override
  String get acctFieldForwardToHint => 'Numero o indirizzo SIP';

  @override
  String get acctFieldRingFor => 'Squilla per (s)';

  @override
  String get acctFieldAutoAnswer => 'Risposta automatica';

  @override
  String get acctFieldAnswerAfter => 'Rispondi dopo (s)';

  @override
  String get acctFieldIntercomOnly => 'Solo per chiamate interfono';

  @override
  String get acctFieldIntercomOnlySub =>
      'Richiede un’intestazione di risposta automatica dal centralino';

  @override
  String get acctFieldRingtone => 'Suoneria';

  @override
  String get acctRingtoneClassic => 'Classica';

  @override
  String get acctRingtoneSoft => 'Morbida';

  @override
  String get acctRingtoneDigital => 'Digitale';

  @override
  String get acctFieldRecordCalls => 'Registra chiamate';

  @override
  String get acctFieldHoldMusic => 'Musica d’attesa';

  @override
  String get acctOptUseGlobal => 'Usa impostazione globale';

  @override
  String get acctOptPbxDefault => 'Predefinito del centralino';

  @override
  String get acctFieldOpeningAnnouncement => 'Annuncio di apertura';

  @override
  String get acctGroupFeatureCodes => 'Codici di servizio';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Composti per parcheggio, risposta per assente, Non disturbare e inoltro sul tuo centralino.';

  @override
  String get acctFieldPark => 'Parcheggio';

  @override
  String get acctFieldGroupPickup => 'Risposta per gruppo';

  @override
  String get acctFieldDirectedPickup => 'Prefisso risposta diretta';

  @override
  String get acctFieldParkRetrieve => 'Prefisso recupero parcheggio';

  @override
  String get acctFieldParkRetrieveHint => 'Componi il numero dello slot';

  @override
  String get acctFieldParkRetrieveSub =>
      'Prefisso composto prima dello slot di parcheggio per riprendere una chiamata parcheggiata';

  @override
  String get acctFieldDndOn => 'Non disturbare sì';

  @override
  String get acctFieldDndOff => 'Non disturbare no';

  @override
  String get acctFieldForwardOn => 'Inoltro sì';

  @override
  String get acctFieldForwardOff => 'Inoltro no';

  @override
  String get acctGroupAdvanced => 'Avanzate';

  @override
  String get acctGroupAdvancedFooterIax =>
      'Il DTMF viene inviato come frame IAX2 nativi.';

  @override
  String get acctFieldCallerIdOverride => 'ID chiamante personalizzato';

  @override
  String get acctFieldCallerIdHint => 'Usa il predefinito dell’account';

  @override
  String get acctFieldCallerIdSub =>
      'Nome o numero ID chiamante inviato al centralino';

  @override
  String get acctFieldSessionTimers => 'Timer di sessione';

  @override
  String get acctFieldSessionExpires => 'Scadenza sessione (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Intervallo da 90 a 86400';

  @override
  String get acctField100rel => '100rel (provvisorie affidabili)';

  @override
  String get acctFieldHoldMethod => 'Metodo di attesa';

  @override
  String get acctFieldDtmfMethod => 'Metodo DTMF';

  @override
  String get acctOptDtmfInband => 'In banda';

  @override
  String get acctFieldRedirects => 'Reindirizzamenti (3xx)';

  @override
  String get acctOptRedirectFollow => 'Segui';

  @override
  String get acctOptRedirectAsk => 'Chiedi';

  @override
  String get acctFieldLockCodec => 'Blocca codec dopo la risposta';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive dei media';

  @override
  String get acctFieldDropCalls =>
      'Termina le chiamate se la registrazione fallisce';

  @override
  String get acctFieldExtraHeaders => 'Intestazioni SIP aggiuntive';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: valore (uno per riga)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Attesa prima di riprovare una registrazione fallita. Intervallo da 0 a 86400';

  @override
  String get acctFieldUnregTimeout => 'Timeout annullamento registrazione (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Quanto attendere la risposta all’annullamento della registrazione. Intervallo da 0 a 60000';

  @override
  String get acctFieldMwiExpiry => 'Scadenza sottoscrizione MWI (s)';

  @override
  String get acctFieldDscpSip => 'DSCP per SIP';

  @override
  String get acctFieldDscpSipSub =>
      'Marcatura QoS della segnalazione. 24 (CS3) è tipico';

  @override
  String get acctFieldDscpRtp => 'DSCP per RTP';

  @override
  String get acctFieldDscpRtpSub => 'Marcatura QoS dei media. 46 (EF) è tipico';

  @override
  String get acctFieldReinvite => 'Re-INVITE dopo cambio di rete';

  @override
  String get acctFieldHangupOnIpChange =>
      'Termina le chiamate al cambio di rete';

  @override
  String get acctValidateInt => 'Inserisci un numero intero';

  @override
  String get acctValidateHostEmpty =>
      'Inserisci il nome host o l’indirizzo del server';

  @override
  String get acctValidateHostSpaces => 'Il server non può contenere spazi';

  @override
  String get acctValidateHostFormat => 'Inserisci solo host o host:porta';

  @override
  String get acctValidatePortRange =>
      'La porta deve essere compresa tra 1 e 65535';

  @override
  String get acctValidateWsStart => 'Il percorso deve iniziare con “/”';

  @override
  String get acctValidateWsLength => 'Usa al massimo 120 caratteri';

  @override
  String get acctValidateWsSpaces => 'Il percorso non può contenere spazi';

  @override
  String get acctTplAsteriskDescription =>
      'Interno sul tuo centralino. UDP 5060, STUN attivo.';

  @override
  String get acctTplAsteriskNotes =>
      'Usa il numero di interno PJSIP/SIP e il relativo secret. Per TLS o WebRTC cambia il trasporto più tardi nelle impostazioni dell’account.';

  @override
  String get acctTplAsteriskUsernameHint => 'Interno (es. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Usa interno, ID di autenticazione e password dal portale 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'In 3CX apri l’interno, poi “Telefoni > Provisioning” per l’ID di autenticazione (impostalo come utente di autorizzazione) e la password. L’FQDN è quello presente nell’URL di 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Interno';

  @override
  String get acctTplFreeswitchDescription =>
      'Utente della directory su un server FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Usa l’ID utente e la password della directory. Il profilo interno predefinito è in ascolto su UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID utente';

  @override
  String get acctTplKamailioDescription =>
      'Registrar proxy SIP. TCP consigliato dietro NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Usa il dominio SIP gestito dal tuo registrar. Aggiungi un proxy in uscita nelle impostazioni dell’account se il registrar si raggiunge tramite un host diverso.';

  @override
  String get acctTplTwilioDescription =>
      'Credenziali del dominio SIP di Programmable Voice. TLS e SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Crea un dominio SIP nella console Twilio, aggiungi un elenco di credenziali e attiva la registrazione SIP. Inserisci il dominio completo (name.sip.twilio.com) come server e utente e password dell’elenco di credenziali. TLS usa la porta 5061. Twilio supporta solo G.711.';

  @override
  String get acctTplTwilioUsernameHint =>
      'Nome utente dell’elenco di credenziali';

  @override
  String get acctTplTelnyxDescription =>
      'Connessione con credenziali. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Crea una Credential Connection nel portale Telnyx e copia il relativo nome utente e password SIP (non il login del portale). Assegna alla connessione un numero o un profilo vocale in uscita per effettuare e ricevere chiamate.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'Nome utente SIP (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Nome utente e password del sub-account. Scegli il POP più vicino a te.';

  @override
  String get acctTplVoipmsNotes =>
      'Usa un sub-account creato in Sub Accounts, non il tuo account principale. Scegli il server (POP) più vicino a te dall’elenco dei server VoIP.ms e autorizzalo per il tuo IP se necessario.';

  @override
  String get acctTplVoipmsUsernameHint => 'Sub-account (es. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'Registrazione SIP con TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business offre la registrazione SIP solo su alcuni piani. Inserisci il server SIP, l’utente e la password mostrati per il dispositivo nel portale di amministrazione Vonage.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange su UDP 4569. Nessuna impostazione NAT o SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Richiede un peer/user in iax.conf (type=friend oppure user+peer) con lo stesso secret. Asterisk rinnova le registrazioni IAX2 ogni 60 s per impostazione predefinita. Il contesto è facoltativo e viene inviato come contesto chiamato.';

  @override
  String get acctTplIax2UsernameHint => 'Nome utente IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP su WebSocket sicuro con DTLS-SRTP, ICE e RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Per endpoint WebSocket di Asterisk (webrtc=yes, TLS in http.conf su 8089), FreeSWITCH o Kamailio. Il server richiede un certificato TLS valido. Cambia il percorso WebSocket nelle impostazioni dell’account se il tuo gateway non usa /ws.';

  @override
  String get acctTplGenericDescription =>
      'Qualsiasi registrar SIP. Compila tu i dettagli.';

  @override
  String get acctTplDefaultUsernameHint => 'Interno / nome utente';

  @override
  String get appEngineFailedBody =>
      'Le chiamate e la registrazione non funzioneranno finché il problema non è risolto. La causa più comune è un’impostazione di rete o di certificato errata.';

  @override
  String get appEngineFailedTitle =>
      'Impossibile avviare il motore di chiamata';

  @override
  String get appEngineNotRunning => 'Il motore di chiamata non è in esecuzione';

  @override
  String get appUnknownError => 'Errore sconosciuto';

  @override
  String get appEngineOpenNetworkSettings => 'Apri impostazioni di rete';

  @override
  String get appEngineUseSimulator => 'Usa simulatore (demo)';

  @override
  String get appDbLockedTitle => 'I tuoi dati sono bloccati';

  @override
  String get appDbUnreadableTitle => 'Impossibile aprire i tuoi dati';

  @override
  String get appDbLockedBody =>
      'Cronologia chiamate, contatti e messaggi sono cifrati su questo dispositivo, ma la chiave di cifratura non è più nel portachiavi / keystore di sistema (ad esempio dopo un reset del portachiavi o un ripristino su un nuovo dispositivo).';

  @override
  String get appDbUnreadableBody =>
      'Impossibile leggere il database locale. Potrebbe essere danneggiato oppure la chiave di cifratura non corrisponde.';

  @override
  String get appDbRecoveryAdvice =>
      'Riprova se prevedi che la chiave tornerà disponibile (sblocca il portachiavi, accedi con l’utente giusto). Ricominciare da zero conserva il vecchio file accanto ai dati dell’app, ma parte con cronologia, contatti e messaggi vuoti; dovrai aggiungere di nuovo i tuoi account.';

  @override
  String get appDbCopyDetails => 'Copia dettagli';

  @override
  String get appDbTryAgain => 'Riprova';

  @override
  String get appDbStartFresh => 'Ricomincia da zero';

  @override
  String get appRedirectTitle => 'Chiamata reindirizzata';

  @override
  String appRedirectMessage(String target) {
    return 'Chiamata reindirizzata a $target: seguire?';
  }

  @override
  String get appRedirectCancelCall => 'Annulla chiamata';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Impossibile cifrare i tuoi dati ($error). Non è stato modificato nulla.',
      'other':
          'Impossibile decifrare i tuoi dati ($error). Non è stato modificato nulla.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Motore nativo non disponibile ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Nuovo tentativo alle $time';
  }

  @override
  String get acctRegistrationError => 'Errore di registrazione';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nTrasporto: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Chiamata diretta, senza account';

  @override
  String acctCallingFromAccount(String name) {
    return 'Chiamata da $name';
  }

  @override
  String get acctCallingFromNone => 'Chiamata senza account';

  @override
  String get acctNoAccount => 'Nessun account';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nuovi, $oldCount vecchi';
  }

  @override
  String get acctAddAccount => 'Aggiungi account';

  @override
  String get acctUnregister => 'Annulla registrazione';

  @override
  String get acctSheetDndSub =>
      'Rifiuta le chiamate in arrivo su questo account';

  @override
  String get acctKvServer => 'Server';

  @override
  String get acctKvResolvedServer => 'Server risolto';

  @override
  String get acctKvClientCert => 'Cert. client';

  @override
  String get acctKvClientCertValue => 'Presentato al server (TLS reciproco)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Scade tra';

  @override
  String get acctKvVoicemail => 'Segreteria';

  @override
  String get acctOpenSipTrace => 'Apri traccia SIP';

  @override
  String get acctAddAnAccount => 'Aggiungi un account';

  @override
  String get acctChooseAccountTooltip => 'Scegli l’account da cui chiamare';

  @override
  String get acctDirectNoAccount => 'Diretta (senza account)';

  @override
  String get onboardingRequired => 'Nome utente e server sono obbligatori';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Viene usata la porta $port a meno che tu non aggiunga :porta';
  }

  @override
  String get onboardingFineTuneIax =>
      'Potrai perfezionare codec e registrazione più tardi nelle Impostazioni.';

  @override
  String get onboardingFineTuneSip =>
      'Potrai perfezionare trasporto, NAT, sicurezza e codec più tardi nelle Impostazioni.';

  @override
  String get onboardingDemoUser => 'Utente demo';

  @override
  String get onboardingDemoAccount => 'Account demo';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Telefonia professionale per ogni piattaforma, gratuita e open source. Niente pubblicità, niente tracciamento.';

  @override
  String get onboardingGetStarted => 'Inizia';

  @override
  String get onboardingPermissionsTitle => 'Autorizzazioni';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro ha bisogno del microfono per trasmettere la tua voce e delle notifiche per avvisarti di chiamate e messaggi in arrivo. Nulla lascia il tuo dispositivo tranne le tue chiamate.';

  @override
  String get onboardingChooseProvider => 'Scegli il tuo provider';

  @override
  String get onboardingChooseProviderSub =>
      'Precompiliamo per te trasporto, porte e impostazioni NAT.';

  @override
  String get onboardingScanQr => 'Scansiona QR';

  @override
  String get onboardingImportUrl => 'Importa da URL';

  @override
  String get onboardingSkip => 'Salta per ora (modalità demo)';

  @override
  String get onboardingHidePassword => 'Nascondi password';

  @override
  String get onboardingShowPassword => 'Mostra password';

  @override
  String get onboardingContextOptional => 'Contesto (facoltativo)';

  @override
  String get onboardingDisplayNameOptional => 'Nome visualizzato (facoltativo)';

  @override
  String get onboardingLabelOptional => 'Etichetta account (facoltativa)';

  @override
  String get onboardingCallerIdOptional => 'ID chiamante (facoltativo)';

  @override
  String get onboardingAuthUserOptional =>
      'Utente di autorizzazione (se diverso)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Nome utente o password errati ($code)';
  }

  @override
  String get acctRegNotFound => 'Account non trovato sul server (404)';

  @override
  String get acctRegNoAnswer => 'Il server non ha risposto (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Intervallo di registrazione troppo breve (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Server temporaneamente non disponibile (480)';

  @override
  String get acctRegServiceUnavailable => 'Servizio non disponibile (503)';

  @override
  String get acctRegFailed => 'Registrazione non riuscita';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Registrazione non riuscita ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Impossibile modificare la registrazione';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Impossibile applicare l’account “$name”';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Di nuovo sul server principale per $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Server di backup in uso per $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'L’account $name è registrato';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'L’account $name si sta ancora registrando';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'L’account $name non è ancora registrato';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'L’account $name non è registrato (registrazione non riuscita)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'L’account $name è disattivato';
  }

  @override
  String get callDialEngineFailed =>
      'Avvio del motore di chiamata non riuscito';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'Avvio del motore di chiamata non riuscito: $reason';
  }

  @override
  String get callDialEngineStarting =>
      'Il motore di chiamata è ancora in avvio';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status dopo $seconds s; la chiamata non è stata effettuata';
  }

  @override
  String get callJournalInterrupted =>
      'L’app è stata chiusa durante la chiamata';

  @override
  String get callLinkMissingArgument => 'Argomento mancante';

  @override
  String get callLinkHttpsRequired =>
      'I link di configurazione devono usare https';

  @override
  String get callLinkInvalidLan => 'Questo link LAN non è valido';

  @override
  String callLinkConnectedTo(String name) {
    return 'Connesso a $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Impossibile connettersi a quel dispositivo';

  @override
  String callLinkCallFailed(String target) {
    return 'Impossibile effettuare la chiamata a $target';
  }

  @override
  String get callLinkImportTitle => 'Importa configurazione';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts account',
      one: '1 account',
    );
    return 'Importare la configurazione da $host? Aggiungerà $_temp0.';
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
      other: '$accounts account',
      one: '1 account',
    );
    return 'Importare la configurazione da $host? Aggiungerà $_temp0 e $settings impostazione/i.';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Inoltrata da $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Inoltrata da $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Trasferita da $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Predefinita di sistema';

  @override
  String get callRingtoneClassic => 'Classica';

  @override
  String get callRingtoneSoft => 'Morbida';

  @override
  String get callRingtoneDigital => 'Digitale';

  @override
  String callIdentityFrom(String number) {
    return 'Da $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'ID chiamante $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'ID chiamante $name $number';
  }

  @override
  String get callTransferring => 'Trasferimento...';

  @override
  String get callTransferNotConfirmed =>
      'Trasferimento non confermato dal server';

  @override
  String get callTransferStalledHint =>
      'La chiamata è ancora attiva. Mantienila oppure invia di nuovo il trasferimento.';

  @override
  String get callTransferKeepCall => 'Mantieni chiamata';

  @override
  String get callAnnouncementOpening => 'Riproduzione annuncio…';

  @override
  String get callAnnouncementTransfer =>
      'Riproduzione avviso di trasferimento…';

  @override
  String get callAnnouncementRecording =>
      'Riproduzione avviso di registrazione…';

  @override
  String get callAnnouncementSkip => 'Salta';

  @override
  String get callNoiseTooltipMic =>
      'Riduzione del rumore con IA: il tuo microfono';

  @override
  String get callNoiseTooltipIncoming =>
      'Riduzione del rumore con IA: altri partecipanti';

  @override
  String get callNoiseTooltipBoth =>
      'Riduzione del rumore con IA: il tuo microfono e gli altri partecipanti';

  @override
  String get callNoiseOn => 'Riduzione rumore attiva';

  @override
  String get callNoiseTitle => 'Riduzione del rumore';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Il mio microfono: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Rimuove il rumore di fondo dal mio microfono';

  @override
  String get callResultAnswered => 'Risposta';

  @override
  String get callResultMissed => 'Persa';

  @override
  String get callResultRejected => 'Rifiutata';

  @override
  String get callResultFailed => 'Non riuscita';

  @override
  String get callResultBusy => 'Occupato';

  @override
  String get callResultForwarded => 'Inoltrata';

  @override
  String get callResultTransferred => 'Trasferita';

  @override
  String get callResultHandedOff => 'Passata';

  @override
  String get callResultInterrupted => 'Interrotta';

  @override
  String get keypadCall => 'Chiama';

  @override
  String get keypadNoVoicemail =>
      'Nessun numero di segreteria configurato per questo account';

  @override
  String get keypadCallDirectly => 'Chiama direttamente (senza account)';

  @override
  String get keypadAddAccount => 'Aggiungi un account per effettuare chiamate';

  @override
  String keypadCallFrom(String account) {
    return 'Chiama da $account';
  }

  @override
  String get keypadRecent => 'Recenti';

  @override
  String get keypadSuggestions => 'Suggerimenti';

  @override
  String get keypadPhoneNumber => 'Numero di telefono';

  @override
  String get keypadPaste => 'Incolla';

  @override
  String get keypadEnterNumber => 'Inserisci numero';

  @override
  String get keypadBackspace => 'Cancella (tieni premuto per svuotare)';

  @override
  String get keypadTypeNameOrNumber => 'Digita un nome o un numero';

  @override
  String get keypadNoMatches => 'Nessun risultato';

  @override
  String get keypadSuggestionsHint =>
      'I suggerimenti provengono da contatti e chiamate recenti';

  @override
  String keypadCallPerson(String name) {
    return 'Chiama $name';
  }

  @override
  String get dialKeyStar => 'Asterisco';

  @override
  String get dialKeyPound => 'Cancelletto';

  @override
  String get dialKeyLongPressPlus => 'Tieni premuto per il più';

  @override
  String get dialKeyLongPressSpeedDial =>
      'Tieni premuto per la chiamata rapida';

  @override
  String get dialKeyLongPressVoicemail => 'Tieni premuto per la segreteria';

  @override
  String get callBackToApp => 'Torna all’app (la chiamata resta attiva)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Nascondi tastierino';

  @override
  String get callMute => 'Muto';

  @override
  String get callKeypad => 'Tastierino';

  @override
  String get callSpeaker => 'Vivavoce';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Cuffie';

  @override
  String get callResume => 'Riprendi';

  @override
  String get callHold => 'Attesa';

  @override
  String get callAddCall => 'Aggiungi';

  @override
  String get callTransfer => 'Trasferisci';

  @override
  String get callStop => 'Stop';

  @override
  String get callRecord => 'Registra';

  @override
  String get callSplit => 'Dividi';

  @override
  String get callMerge => 'Unisci';

  @override
  String get callSwap => 'Scambia';

  @override
  String get callEndCall => 'Termina';

  @override
  String callEndCallWith(String name) {
    return 'Termina chiamata con $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Trasferimento assistito. Il chiamante originale è in attesa.';

  @override
  String get callCompleteTransfer => 'Completa trasferimento';

  @override
  String get callWaiting => 'Avviso di chiamata';

  @override
  String get callHoldAndAnswer =>
      'Metti in attesa la chiamata corrente e rispondi';

  @override
  String get callDecline => 'Rifiuta';

  @override
  String get callAnswer => 'Rispondi';

  @override
  String get callIncomingCall => 'Chiamata in arrivo';

  @override
  String get callReply => 'Rispondi con SMS';

  @override
  String get callVoicemail => 'Segreteria';

  @override
  String get callToDevice => 'A dispositivo';

  @override
  String get callQuickReplyBusy => 'Non posso parlare ora, ti richiamo.';

  @override
  String get callQuickReplyMeeting => 'Sono in riunione. Mi scrivi?';

  @override
  String get callQuickReplyOnMyWay => 'Sto arrivando.';

  @override
  String callReturnToCallWith(String name) {
    return 'Torna alla chiamata con $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'In arrivo: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'In chiamata con $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Perdita pacchetti';

  @override
  String get callStatsRoundTrip => 'Andata e ritorno';

  @override
  String get callStatsMedia => 'Media';

  @override
  String get callStatsMosHistory => 'Storico MOS';

  @override
  String get callQualityTitle => 'Qualità chiamata';

  @override
  String get callTransferTitle => 'Trasferisci chiamata';

  @override
  String get callTransferModeBlind => 'Cieco';

  @override
  String get callTransferModeAttended => 'Assistito';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Dispositivo LAN';

  @override
  String get callTransferNoLanDevices =>
      'Nessun dispositivo SoftphonePro associato trovato nella tua rete. Associane uno nella pagina LAN.';

  @override
  String get callTransferLanDisabled =>
      'Attiva LAN Link (Impostazioni, LAN Link) per passare questa chiamata a un altro dispositivo della tua rete.';

  @override
  String get callTransferTalkFirst => 'Parla prima';

  @override
  String get callTransferBlindHint =>
      'Passa subito il chiamante. Tu vieni disconnesso.';

  @override
  String get callTransferAttendedHint =>
      'Mette in attesa il chiamante e chiama prima la destinazione. Completa il trasferimento quando risponde.';

  @override
  String get callTransferNumberLabel => 'Numero o indirizzo SIP';

  @override
  String get callTransferNow => 'Trasferisci ora';

  @override
  String get callTransferCallAndConsult => 'Chiama e consulta';

  @override
  String get callRetrieveParkedTitle => 'Recupera chiamata parcheggiata';

  @override
  String get callRetrieveParkedHint => 'Slot di parcheggio, es. 701';

  @override
  String get callMoreAudioOutput => 'Uscita audio';

  @override
  String get callMoreAudioDevices => 'Dispositivi audio';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefono, altoparlante, Bluetooth, cuffie';

  @override
  String get callMoreAudioDevicesSubtitle => 'Scegli microfono e altoparlante';

  @override
  String get callMoreParkCall => 'Parcheggia chiamata';

  @override
  String get callMoreParkCallSubtitle =>
      'Trasferisci al codice di servizio di parcheggio';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Componi uno slot di parcheggio';

  @override
  String get callMoreSendDtmf => 'Invia cifre DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Digita un’intera sequenza, ad es. un PIN';

  @override
  String get callSendDtmfTitle => 'Invia DTMF';

  @override
  String get callMoreCallInfo => 'Info chiamata';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, jitter, perdita e tempo di andata e ritorno in tempo reale';

  @override
  String get callMoreSipTrace => 'Traccia SIP';

  @override
  String get callMoreSipTraceSubtitle => 'Diagramma a scala di questa chiamata';

  @override
  String get callInfoRemote => 'Remoto';

  @override
  String get callInfoAccount => 'Account';

  @override
  String get callInfoState => 'Stato';

  @override
  String get callInfoSecure => 'Sicura';

  @override
  String get callInfoPlainSignalling => 'segnalazione in chiaro';

  @override
  String get callRoutePhone => 'Telefono';

  @override
  String get callRouteWiredHeadset => 'Cuffie cablate';

  @override
  String get callAudioMicrophone => 'Microfono';

  @override
  String callCardSemantics(String name, String state) {
    return 'Chiamata con $name, $state';
  }

  @override
  String get callUnmute => 'Riattiva audio';

  @override
  String get callStopRecording => 'Interrompi registrazione';

  @override
  String get callSplitConference => 'Dividi conferenza';

  @override
  String get callMergeCalls => 'Unisci chiamate';

  @override
  String get callSwapCalls => 'Scambia chiamate';

  @override
  String get callAttendedTransferBanner =>
      'Trasferimento assistito: il chiamante originale è in attesa.';

  @override
  String get callActiveCalls => 'Chiamate attive';

  @override
  String get callConferenceLevels => 'Livelli conferenza';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Microfono verso interlocutore';

  @override
  String callPercentSemantics(int percent) {
    return '$percent percento';
  }

  @override
  String get callFailInvalidNumber => 'Numero non valido (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Chiamata non autorizzata ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Numero non trovato (404)';

  @override
  String get callFailNoAnswerFromServer => 'Nessuna risposta dal server (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Temporaneamente non disponibile (480)';

  @override
  String get callFailIncompleteNumber => 'Numero incompleto (484)';

  @override
  String callFailBusy(String code) {
    return 'Occupato ($code)';
  }

  @override
  String get callFailCancelled => 'Chiamata annullata (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Nessun codec compatibile ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Servizio non disponibile (503)';

  @override
  String get callFailDeclined => 'Chiamata rifiutata (603)';

  @override
  String get callFailGeneric => 'Chiamata non riuscita';

  @override
  String callFailGenericWithCode(String code) {
    return 'Chiamata non riuscita ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Chiamata in corso';

  @override
  String get callTrayInCall => 'In chiamata';

  @override
  String get callHistoryBlocked => 'Bloccata';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimato non consentito';

  @override
  String get callHistoryDoNotDisturb => 'Non disturbare';

  @override
  String get callHistoryBusy => 'Occupato';

  @override
  String get callHistoryForwardedAlways => 'Inoltrata (sempre)';

  @override
  String get callHistoryForwardedBusy => 'Inoltrata (occupato)';

  @override
  String get callHistorySentToVoicemail => 'Inviata alla segreteria';

  @override
  String get callHistoryRedirected => 'Reindirizzata';

  @override
  String get callIncomingNotificationBody => 'Chiamata in arrivo';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Chiamata in arrivo su $account';
  }

  @override
  String get callMissedNotificationTitle => 'Chiamata persa';

  @override
  String get callErrEngineNotRunning =>
      'Il motore di chiamata non è ancora in esecuzione';

  @override
  String get callErrAddAccount => 'Aggiungi un account per effettuare chiamate';

  @override
  String get callErrCouldNotPlace => 'Impossibile effettuare la chiamata';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account non è registrato';
  }

  @override
  String get callErrCouldNotAnswer => 'Impossibile rispondere';

  @override
  String get callErrNoVoicemailNumber =>
      'Nessun numero di segreteria impostato per questo account';

  @override
  String get callErrTransferFailed => 'Trasferimento non riuscito';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Trasferimento non riuscito: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Impossibile unire le chiamate';

  @override
  String get callErrCouldNotStartRecording =>
      'Impossibile avviare la registrazione';

  @override
  String get callErrCouldNotStopRecording =>
      'Impossibile interrompere la registrazione';

  @override
  String callParkingNotice(String code) {
    return 'Parcheggio della chiamata (componi $code)';
  }

  @override
  String get callErrParkFailed => 'Parcheggio non riuscito';

  @override
  String get callErrHandoffFailed => 'Passaggio non riuscito';

  @override
  String get callErrCouldNotSendToDevice =>
      'Impossibile inviare al dispositivo';

  @override
  String get callHistoryForwardedNoAnswer => 'Inoltrata (senza risposta)';

  @override
  String get shellTabKeypad => 'Tastierino';

  @override
  String get shellTabRecents => 'Recenti';

  @override
  String get shellTabContacts => 'Contatti';

  @override
  String get shellTabMessages => 'Messaggi';

  @override
  String get shellTabPresence => 'Presenza';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Registrazioni';

  @override
  String get shellSearchSemantics =>
      'Cerca contatti, cronologia o componi un numero';

  @override
  String get shellSearchHint => 'Cerca o componi';

  @override
  String get shellVoicemailTooltip => 'Segreteria';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count nuovi messaggi in segreteria. Clicca per chiamare la segreteria',
      one: '1 nuovo messaggio in segreteria. Clicca per chiamare la segreteria',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Assente';

  @override
  String get shellStatusTooltip => 'Il tuo stato';

  @override
  String get shellDemoBanner =>
      'Modalità demo: le chiamate sono simulate, nulla raggiunge una rete reale.';

  @override
  String get uiToday => 'Oggi';

  @override
  String get uiYesterday => 'Ieri';

  @override
  String get uiUnknownCaller => 'Chiamante sconosciuto';

  @override
  String get uiCallEnded => 'Chiamata terminata';

  @override
  String get uiCallTransferNotConfirmed => 'Trasferimento non confermato';

  @override
  String get uiCallTransferring => 'Trasferimento...';

  @override
  String get uiCallConference => 'Conferenza';

  @override
  String get uiCallOnHold => 'In attesa';

  @override
  String get uiCallHeldByRemote => 'In attesa dall’altra parte';

  @override
  String get uiCallCalling => 'Chiamata in corso...';

  @override
  String get uiCallRinging => 'Squilla...';

  @override
  String get uiCallConnecting => 'Connessione...';

  @override
  String get uiCallIncoming => 'Chiamata in arrivo';

  @override
  String get uiCallConnected => 'Connesso';

  @override
  String get uiQrScanTitle => 'Scansiona codice QR';

  @override
  String get uiQrPasteHint => 'Incolla il testo del codice';

  @override
  String get uiQrNoCamera =>
      'La scansione con la fotocamera non è disponibile su questo dispositivo. Incolla invece il testo del codice.';

  @override
  String get uiQrPaste => 'Incolla';

  @override
  String get uiQrUse => 'Usa';

  @override
  String get uiQrCameraDenied =>
      'L’accesso alla fotocamera è disattivato. Consentilo nelle impostazioni di sistema oppure incolla qui sotto il testo del codice.';

  @override
  String get uiQrCameraUnavailable =>
      'La fotocamera non è disponibile. Incolla qui sotto il testo del codice.';

  @override
  String get presenceLampRinging => 'Squilla';

  @override
  String get presenceHeader => 'Campo lampada occupato';

  @override
  String get presenceChooseTooltip => 'Scegli i contatti da monitorare';

  @override
  String get presenceEmptyTitle => 'Nessun interno nella lavagna';

  @override
  String get presenceEmptySubtitle =>
      'Attiva “Mostra nella lavagna BLF” per un contatto per vedere quando è libero, squilla o è occupato.';

  @override
  String get presenceOpenContacts => 'Apri contatti';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Tocca per chiamare, tieni premuto per altro';
  }

  @override
  String presenceCallName(String name) {
    return 'Chiama $name';
  }

  @override
  String get presencePickup => 'Rispondi per questo interno';

  @override
  String get presencePickupSub =>
      'Rispondi alla sua chiamata in arrivo (risposta diretta)';

  @override
  String get presenceTransferHere => 'Trasferisci qui la chiamata corrente';

  @override
  String get presenceRemove => 'Rimuovi dalla lavagna';

  @override
  String get uiCall => 'Chiama';

  @override
  String get uiMessage => 'Messaggio';

  @override
  String get recentsSearchTooltip => 'Cerca nella cronologia';

  @override
  String get recentsClearTitle => 'Cancellare la cronologia chiamate?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tutte le $count voci verranno eliminate.',
      one: '1 voce verrà eliminata.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => 'Cronologia copiata negli appunti come CSV';

  @override
  String get recentsMenuCopyCsv => 'Copia come CSV';

  @override
  String get recentsMenuClear => 'Cancella cronologia';

  @override
  String get recentsSearchHint => 'Cerca nome o numero';

  @override
  String get recentsFilterAll => 'Tutte';

  @override
  String get recentsFilterMissed => 'Perse';

  @override
  String get recentsFilterIncoming => 'In arrivo';

  @override
  String get recentsFilterOutgoing => 'In uscita';

  @override
  String get recentsFilterAccount => 'Filtra per account';

  @override
  String get recentsAllAccounts => 'Tutti gli account';

  @override
  String get recentsAccountFallback => 'Account';

  @override
  String get recentsEmptyNone => 'Nessuna chiamata';

  @override
  String get recentsEmptyNoMatch => 'Nessuna chiamata corrispondente';

  @override
  String get recentsEmptyNoneSub => 'Le tue chiamate appariranno qui.';

  @override
  String get recentsEmptyNoMatchSub => 'Prova un altro filtro.';

  @override
  String get recentsOpenKeypad => 'Apri tastierino';

  @override
  String get recentsShowAll => 'Mostra tutte';

  @override
  String get recentsSelectCall => 'Seleziona una chiamata';

  @override
  String get recentsSelectCallSub =>
      'Dettagli, qualità e registrazioni appaiono qui.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Chiamata persa',
      'incoming': 'Chiamata in arrivo',
      'other': 'Chiamata in uscita',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Chiama $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Aggiungi un account per inviare messaggi';

  @override
  String get recentsAddContact => 'Aggiungi contatto';

  @override
  String get recentsContact => 'Contatto';

  @override
  String get recentsBlock => 'Blocca';

  @override
  String get recentsUnblock => 'Sblocca';

  @override
  String recentsBlockTitle(String number) {
    return 'Bloccare $number?';
  }

  @override
  String get recentsBlockMessage =>
      'Le chiamate da questo numero verranno rifiutate automaticamente.';

  @override
  String get recentsQualityHeader => 'Qualità chiamata';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'MOS peggiore $mos   ·   Jitter $jitter ms   ·   Perdita $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Registrazioni';

  @override
  String get recentsOpenInRecordings => 'Apri in Registrazioni';

  @override
  String recentsRelatedCall(String title) {
    return 'Chiamata correlata: $title';
  }

  @override
  String get recentsHistoryHeader => 'Cronologia';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Nessuna chiamata con questo numero';

  @override
  String get recentsDeleteTitle => 'Eliminare queste chiamate?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rimuove $count voci per $name.',
      one: 'Rimuove 1 voce per $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Elimina dalla cronologia';

  @override
  String get recentsCallDetails => 'Dettagli chiamata';

  @override
  String get contactsFavoritesHeader => '★ Preferiti';

  @override
  String get contactsFavoritesOnly => 'Solo preferiti';

  @override
  String get contactsShowAll => 'Mostra tutti';

  @override
  String get contactsImportExportTooltip => 'Importa ed esporta';

  @override
  String get contactsMenuDevice => 'Importa dal dispositivo';

  @override
  String get contactsMenuFile => 'Importa file vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Importa dagli appunti';

  @override
  String get contactsMenuCopyVcard => 'Copia come vCard';

  @override
  String get contactsMenuCopyCsv => 'Copia come CSV';

  @override
  String get contactsNewTooltip => 'Nuovo contatto';

  @override
  String get contactsSearchHint => 'Cerca contatti';

  @override
  String get contactsEmptyTitle => 'Ancora nessun contatto';

  @override
  String get contactsEmptySubtitle =>
      'Aggiungi le persone che chiami spesso oppure importa un file vCard o CSV.';

  @override
  String get contactsEmptyAction => 'Aggiungi un contatto';

  @override
  String get contactsNoMatches => 'Nessun risultato';

  @override
  String contactsCallName(String name) {
    return 'Chiama $name';
  }

  @override
  String get contactsSelect => 'Seleziona un contatto';

  @override
  String get contactsCopiedVcard => 'Contatti copiati come vCard';

  @override
  String get contactsCopiedCsv => 'Contatti copiati come CSV';

  @override
  String get contactsDeviceDenied =>
      'L’accesso ai contatti è stato negato. Consentilo nelle impostazioni di sistema per importare.';

  @override
  String get contactsDeviceNone =>
      'Nessun contatto trovato su questo dispositivo';

  @override
  String contactsNothingNew(int count) {
    return 'Niente di nuovo da importare ($count già presenti)';
  }

  @override
  String get contactsImportDeviceTitle => 'Importare dal dispositivo?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi contatti',
      one: '1 nuovo contatto',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count aggiornati con numeri aggiuntivi';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count ignorati (duplicati o senza numero di telefono)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importati $count contatti',
      one: 'Importato 1 contatto',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Nessun contatto trovato in quei dati';

  @override
  String get contactsLabelMobile => 'cellulare';

  @override
  String get contactsLabelWork => 'lavoro';

  @override
  String get contactsLabelHome => 'casa';

  @override
  String get contactsLabelOther => 'altro';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contatto non trovato';

  @override
  String get contactsActionFavorite => 'Preferito';

  @override
  String get contactsNumbersHeader => 'Numeri';

  @override
  String get contactsSipAddress => 'Indirizzo SIP';

  @override
  String get contactsDetailsHeader => 'Dettagli';

  @override
  String get contactsOnBlf => 'Mostrato nella lavagna BLF';

  @override
  String get contactsAlwaysRecorded => 'Le chiamate vengono sempre registrate';

  @override
  String contactsDeleteTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get contactsDeleteMessage =>
      'Questo contatto verrà rimosso da questo dispositivo.';

  @override
  String get contactsDeleteButton => 'Elimina contatto';

  @override
  String get contactsDetailTitle => 'Contatto';

  @override
  String get contactsErrorNameOrNumber => 'Inserisci un nome o un numero';

  @override
  String get contactsEditTitle => 'Modifica contatto';

  @override
  String get contactsFieldName => 'Nome';

  @override
  String get contactsFieldCompany => 'Azienda';

  @override
  String get contactsFieldNumber => 'Numero';

  @override
  String get contactsRemoveNumber => 'Rimuovi numero';

  @override
  String get contactsAddNumber => 'Aggiungi numero';

  @override
  String get contactsSipHeader => 'Indirizzi SIP';

  @override
  String get contactsRemoveAddress => 'Rimuovi indirizzo';

  @override
  String get contactsAddSip => 'Aggiungi indirizzo SIP';

  @override
  String get contactsFieldEmail => 'Email';

  @override
  String get contactsFieldNotes => 'Note';

  @override
  String get contactsFieldFavorite => 'Preferito';

  @override
  String get contactsShowOnBlf => 'Mostra nella lavagna BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Monitora la presenza e la lampada di occupato di questo interno';

  @override
  String get contactsAlwaysRecordTitle =>
      'Registra sempre le chiamate con questo contatto';

  @override
  String get contactsAlwaysRecordSub =>
      'Ha la precedenza sulle regole di registrazione automatica';

  @override
  String get contactsRingtone => 'Suoneria';

  @override
  String get contactsPresenceVia => 'Presenza tramite account';

  @override
  String get contactsDefaultAccount => 'Account predefinito';

  @override
  String get contactsDeleteContactTitle => 'Eliminare il contatto?';

  @override
  String get contactsCannotUndo => 'L’operazione non può essere annullata.';

  @override
  String get messagesNewMessage => 'Nuovo messaggio';

  @override
  String get messagesNumberOrSip => 'Numero o indirizzo SIP';

  @override
  String get messagesNoConversations => 'Nessuna conversazione';

  @override
  String get messagesEmptySubtitle =>
      'Invia un messaggio SIP a qualsiasi interno o indirizzo dei tuoi account.';

  @override
  String get messagesTyping => 'sta scrivendo...';

  @override
  String get messagesYouPrefix => 'Tu: ';

  @override
  String get messagesSelect => 'Seleziona una conversazione';

  @override
  String get messagesLanOnline => 'Online nella tua rete';

  @override
  String get messagesLanOffline =>
      'Offline. I messaggi vengono inviati quando torna online.';

  @override
  String messagesSendFileTo(String name) {
    return 'Invia un file a $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Chiama $name';
  }

  @override
  String get messagesDeleteTitle => 'Eliminare la conversazione?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Tutti i messaggi con $name verranno rimossi.';
  }

  @override
  String get messagesDeleteMenu => 'Elimina conversazione';

  @override
  String get messagesSayHello => 'Saluta';

  @override
  String get messagesLanEmptySub =>
      'I messaggi vanno direttamente a questo dispositivo attraverso la tua rete, con cifratura end-to-end.';

  @override
  String get messagesSipEmptySub =>
      'I messaggi vengono inviati con SIP MESSAGE tramite il tuo account.';

  @override
  String get messagesInputHint => 'Messaggio';

  @override
  String get messagesSend => 'Invia';

  @override
  String get messagesStatusSending => 'Invio in corso';

  @override
  String get messagesStatusSent => 'Inviato';

  @override
  String get messagesStatusDelivered => 'Consegnato';

  @override
  String get messagesStatusRead => 'Letto';

  @override
  String get messagesStatusFailed => 'Non riuscito';

  @override
  String get messagesNotDelivered => 'Non consegnato. Tocca per riprovare';

  @override
  String get uiStatusRegistered => 'Registrato';

  @override
  String get uiStatusRegistering => 'Registrazione in corso';

  @override
  String get uiStatusRegFailed => 'Registrazione non riuscita';

  @override
  String get uiStatusDisabled => 'Disattivato';

  @override
  String get uiQualityMeasuring => 'Misurazione';

  @override
  String get uiQualityExcellent => 'Eccellente';

  @override
  String get uiQualityGood => 'Buona';

  @override
  String get uiQualityFair => 'Discreta';

  @override
  String get uiQualityPoor => 'Scarsa';

  @override
  String get uiQualityBad => 'Pessima';

  @override
  String uiQualitySemantics(String label) {
    return 'Qualità chiamata $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Qualità chiamata $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Qualità chiamata: $label';
  }

  @override
  String get uiSecureFull => 'Cifrata';

  @override
  String get uiSecureMedia => 'Media cifrati';

  @override
  String get uiSecureSignalling => 'Segnalazione cifrata';

  @override
  String get uiSecureNone => 'Non cifrata';

  @override
  String get uiSecureSrtpLine => 'Media SRTP';

  @override
  String get uiSecureTlsLine => 'Segnalazione TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Passaggio a $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Interfono verso $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Interfono verso un dispositivo vicino';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Interfono da $name';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'Interfono da un dispositivo vicino';

  @override
  String lanCallToNamed(String name) {
    return 'Chiamata LAN verso $name';
  }

  @override
  String get lanCallToUnpaired =>
      'Chiamata LAN verso un dispositivo non associato';

  @override
  String lanCallFromNamed(String name) {
    return 'Chiamata LAN da $name';
  }

  @override
  String get lanCallFromUnpaired =>
      'Chiamata LAN da un dispositivo non associato';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Chiamata trasferita da $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Chiamata trasferita da $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'un altro dispositivo';

  @override
  String lanRelayedTitle(String name) {
    return 'Inoltrata a $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Il chiamante sta parlando con $name. Tu non sei in chiamata.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Chiamata a $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Il chiamante resta connesso mentre $name risponde.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Richiesta a $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'In attesa che accetti la chiamata.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'In conversazione con $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Il chiamante è in attesa. Completa il passaggio quando sei pronto.';

  @override
  String get lanRelayTakingBack => 'Recupero della chiamata...';

  @override
  String get lanRelayTakeBack => 'Riprendi';

  @override
  String get lanRelayEnd => 'Termina';

  @override
  String get lanSendToDevice => 'Invia a dispositivo';

  @override
  String get lanBusy => 'Occupato';

  @override
  String get lanNoPairedOnline => 'Nessun dispositivo associato è online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name ha rifiutato l’associazione.';
  }

  @override
  String get lanPairRejected => 'Associazione rifiutata.';

  @override
  String get lanPairCancelled => 'Associazione annullata.';

  @override
  String get lanPairTimedOut => 'Associazione scaduta. Riprova.';

  @override
  String get lanPairFailed => 'Associazione non riuscita';

  @override
  String lanPairFailedReason(String reason) {
    return 'Associazione non riuscita: $reason';
  }

  @override
  String get lanPairThisDevice => 'questo dispositivo';

  @override
  String get lanPairConnecting => 'Connessione sicura in corso...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name vuole associarsi a questo dispositivo.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Associazione con $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Verifica che questo codice sia uguale su entrambi gli schermi.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Codice di associazione $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'In attesa della conferma di $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name ha confermato.';
  }

  @override
  String get lanPairReject => 'Rifiuta';

  @override
  String get lanPairCodesMatch => 'I codici coincidono';

  @override
  String lanPairPairedWith(String name) {
    return 'Associato a $name.';
  }

  @override
  String get lanPairRequestTitle => 'Richiesta di associazione';

  @override
  String lanPairTitle(String name) {
    return 'Associa a $name';
  }

  @override
  String get lanActionDecline => 'Rifiuta';

  @override
  String get lanActionAccept => 'Accetta';

  @override
  String get lanFileIncomingTitle => 'File in arrivo';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size da $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Trasferire una chiamata qui?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' da $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' su $account',
    });
    return '$device vuole passarti una chiamata$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Parlerà prima con te.';

  @override
  String get lanHandoffTakeCall => 'Prendi chiamata';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Consentire l’interfono da $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'La sua chiamata riceverà risposta automatica in vivavoce.';

  @override
  String get lanIntercomDeny => 'Nega';

  @override
  String get lanIntercomAllow => 'Consenti';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name ha rimosso questo dispositivo dall’elenco dei dispositivi associati';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Invio di $count file...',
      one: 'Invio di $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nuovo messaggio';

  @override
  String get lanSipMessage => 'Messaggio SIP';

  @override
  String get lanSipMessageSub =>
      'A un numero o indirizzo tramite il tuo account';

  @override
  String get lanChatOnline => 'Chat LAN, online';

  @override
  String get lanChatOffline => 'Chat LAN, offline';

  @override
  String lanSavedAt(String path) {
    return 'Salvato in $path (percorso copiato)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'I tuoi dispositivi, in comunicazione diretta';

  @override
  String get lanConnectByAddress => 'Connetti tramite indirizzo';

  @override
  String get lanSettingsTooltip => 'Impostazioni LAN';

  @override
  String get lanOffTitle => 'LAN Link è disattivato';

  @override
  String get lanOffSubtitle =>
      'Trova i tuoi altri dispositivi SoftphonePro, chatta, scambia file e passa le chiamate, senza alcun server.';

  @override
  String get lanTurnOn => 'Attiva LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'Impossibile avviare LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'Digita host:porta oppure incolla il testo del codice QR mostrato sull’altro dispositivo.';

  @override
  String get lanScanTitle => 'Scansiona QR di associazione LAN';

  @override
  String get lanScanQr => 'Scansiona QR';

  @override
  String get lanPaste => 'Incolla';

  @override
  String get lanConnect => 'Connetti';

  @override
  String lanConnectedTo(String name) {
    return 'Connesso a $name';
  }

  @override
  String get lanCouldNotConnect => 'Impossibile connettersi';

  @override
  String get lanCouldNotStartPairing => 'Impossibile avviare l’associazione';

  @override
  String get lanThisDevice => 'Questo dispositivo';

  @override
  String get lanDeviceNameTitle => 'Nome del dispositivo';

  @override
  String get lanStarting => 'Avvio in corso...';

  @override
  String get lanVisible => 'Visibile nella tua rete';

  @override
  String get lanNotRunning => 'Non in esecuzione';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count account condivisi',
      one: '1 account condiviso',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Impronta';

  @override
  String get lanHideQr => 'Nascondi codice QR';

  @override
  String get lanShowQr =>
      'Mostra il codice QR per connettere un altro dispositivo';

  @override
  String get lanCopyConnectionText => 'Copia testo di connessione';

  @override
  String get lanConnectionTextCopied => 'Testo di connessione copiato';

  @override
  String get lanActiveOnOthers => 'Attive sugli altri tuoi dispositivi';

  @override
  String get lanPairedDevices => 'Dispositivi associati';

  @override
  String get lanNoPaired =>
      'Ancora nessun dispositivo associato. Associa un dispositivo vicino per chattare, inviare file e passare chiamate.';

  @override
  String get lanNearby => 'Nelle vicinanze';

  @override
  String get lanNearbyHint =>
      'Ricerca di SoftphonePro nella tua rete. Gli altri dispositivi devono avere LAN Link attivo. Puoi anche connetterti tramite indirizzo con il pulsante del link qui sopra.';

  @override
  String get lanTransfers => 'Trasferimenti';

  @override
  String get lanFiles => 'File';

  @override
  String get lanPairedBadge => 'Associato';

  @override
  String get lanTyping => 'sta scrivendo...';

  @override
  String get lanPair => 'Associa';

  @override
  String get lanUnpair => 'Dissocia';

  @override
  String lanUnpairTitle(String name) {
    return 'Dissociare $name?';
  }

  @override
  String get lanUnpairMessage =>
      'Dovrai associarlo di nuovo per chattare, inviare file o passare chiamate.';

  @override
  String get lanActionMessage => 'Messaggio';

  @override
  String get lanActionSendFile => 'Invia file';

  @override
  String get lanActionCall => 'Chiama';

  @override
  String get lanActionIntercom => 'Interfono';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Attiva su $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Attiva su $device  ·  $account';
  }

  @override
  String get lanPull => 'Preleva';

  @override
  String get lanTransferPreparing => 'Preparazione...';

  @override
  String get lanTransferWaitingYou => 'In attesa di te';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'In attesa che $name accetti';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done di $total';
  }

  @override
  String get lanTransferVerifying => 'Verifica in corso...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'Da $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'A $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  da $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  a $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Non riuscito: $error';
  }

  @override
  String get lanFileActions => 'Azioni sul file';

  @override
  String get lanPathCopied => 'Percorso copiato';

  @override
  String get lanFileOpen => 'Apri';

  @override
  String get lanFileShowInFolder => 'Mostra nella cartella';

  @override
  String get lanFileCopyPath => 'Copia percorso';

  @override
  String lanNetworkError(String message) {
    return 'Errore di rete: $message';
  }

  @override
  String get lanErrNotRunning => 'Attiva prima LAN Link';

  @override
  String get lanErrBadAddress =>
      'Inserisci un indirizzo come 192.168.1.20:4711 oppure incolla il testo del codice QR';

  @override
  String get lanErrFingerprint =>
      'Quel dispositivo non corrisponde al codice scansionato. Il codice QR proviene da un altro dispositivo?';

  @override
  String lanNoticeReceived(String file, String name) {
    return 'Ricevuto $file da $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return 'Inviato $file a $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name ha rifiutato $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Trasferimento del file non riuscito: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Attiva LAN Link per chiamare i dispositivi vicini';

  @override
  String get lanNoticePairFirst => 'Associa prima questo dispositivo';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name al momento non è raggiungibile per le chiamate';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Richiesta a $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name non ha consentito l’interfono (o non ha risposto)';
  }

  @override
  String get lanHoOff => 'LAN Link è disattivato';

  @override
  String get lanHoPairFirst => 'Associa prima quel dispositivo';

  @override
  String lanHoOffline(String name) {
    return '$name è offline';
  }

  @override
  String get lanHoAlready => 'Questa chiamata è già in fase di passaggio';

  @override
  String get lanHoEnded => 'La chiamata è già terminata';

  @override
  String get lanHoWaitConnected => 'Attendi che la chiamata sia connessa';

  @override
  String get lanHoLanCall => 'Le chiamate LAN non possono essere passate';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name non può ricevere chiamate in rete (le chiamate LAN sono disattivate su quel dispositivo)';
  }

  @override
  String get lanHoNoLanHere =>
      'Le chiamate LAN non sono disponibili su questo dispositivo';

  @override
  String lanHoDeclined(String name) {
    return '$name ha rifiutato la chiamata. Resta con te.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name non ha risposto. La chiamata resta con te.';
  }

  @override
  String get lanHoCancelled =>
      'Il passaggio è stato annullato. La chiamata resta con te.';

  @override
  String lanHoUnreachable(String name) {
    return 'Impossibile raggiungere $name. La chiamata resta con te.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Impossibile raggiungere $name ($reason). La chiamata resta con te.';
  }

  @override
  String get lanHoEndedBefore =>
      'La chiamata è terminata prima di poter essere passata';

  @override
  String lanHoPbxRefused(String name) {
    return 'Il sistema telefonico ha rifiutato il trasferimento e $name non può ricevere chiamate LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Trasferimento tramite il sistema telefonico non riuscito. Inoltro in rete al suo posto.';

  @override
  String lanHoSentTo(String name) {
    return 'Chiamata inviata a $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Impossibile chiamare l’altro dispositivo tramite il sistema telefonico';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name non è più raggiungibile';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Impossibile rispondere alla chiamata per passarla';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Impossibile chiamare $name in rete. La chiamata resta con te.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name non ha risposto. La chiamata resta con te.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Passata a $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Chiamata inoltrata a $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Attendi prima la risposta di $name';
  }

  @override
  String get lanHoFailed => 'Passaggio non riuscito';

  @override
  String lanHoTakenBack(String name) {
    return 'Chiamata ripresa da $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name ha terminato la consultazione. La chiamata è di nuovo con te.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Impossibile passare la chiamata a $name';
  }

  @override
  String get diagSip400Explain => 'Il server non ha capito la richiesta.';

  @override
  String get diagSip400Fix =>
      'Controlla le impostazioni dell’account (dominio, nome utente, proxy). Se il problema persiste, invia una traccia SIP al tuo provider.';

  @override
  String get diagSip401Explain =>
      'Il server ha rifiutato le credenziali (oppure le sta richiedendo).';

  @override
  String get diagSip401Fix =>
      'Controlla nome utente, nome utente di autenticazione e password. Alcuni provider usano un “ID di autenticazione” separato.';

  @override
  String get diagSip403Explain =>
      'Il server ha capito la richiesta ma la rifiuta: password errata, account disattivato o il tuo IP non è consentito.';

  @override
  String get diagSip403Fix =>
      'Reinserisci la password, verifica che l’account sia attivo e controlla che il tuo IP pubblico non sia bloccato (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'Il server non conosce questo utente o numero.';

  @override
  String get diagSip404Fix =>
      'Controlla nome utente e dominio; per le chiamate controlla il numero composto e le regole di chiamata.';

  @override
  String get diagSip405Explain => 'Il server non supporta questa richiesta.';

  @override
  String get diagSip405Fix =>
      'Di solito è innocuo per i ping OPTIONS. Per REGISTER, verifica di comunicare con un registrar SIP.';

  @override
  String get diagSip407Explain => 'Il proxy in uscita richiede credenziali.';

  @override
  String get diagSip407Fix =>
      'Controlla la password dell’account e le impostazioni del proxy in uscita.';

  @override
  String get diagSip408Explain =>
      'Nessuna risposta dal server entro il tempo previsto.';

  @override
  String get diagSip408Fix =>
      'Controlla indirizzo e porta del server, i firewall e prova TCP o TLS. Timeout ripetuti solo su UDP possono indicare un SIP ALG sul router.';

  @override
  String get diagSip410Explain => 'Il numero non esiste più.';

  @override
  String get diagSip410Fix => 'Controlla il numero composto.';

  @override
  String get diagSip415Explain =>
      'L’altra parte non accetta il tipo di contenuto o i codec offerti.';

  @override
  String get diagSip415Fix =>
      'Attiva altri codec (ad es. PCMU/PCMA) in Impostazioni > Codec.';

  @override
  String get diagSip421Explain =>
      'Il server richiede un’estensione SIP che questo client non ha offerto.';

  @override
  String get diagSip421Fix =>
      'Controlla le opzioni NAT/ICE/100rel/timer dell’account.';

  @override
  String get diagSip423Explain =>
      'La scadenza della registrazione è inferiore a quella consentita dal server.';

  @override
  String get diagSip423Fix =>
      'Aumenta la scadenza della registrazione nelle impostazioni dell’account.';

  @override
  String get diagSip480Explain =>
      'L’utente non è registrato o al momento non è raggiungibile.';

  @override
  String get diagSip480Fix =>
      'Verifica che l’altra parte sia registrata; durante la registrazione il server potrebbe essere sovraccarico: riprova più tardi.';

  @override
  String get diagSip481Explain =>
      'Il server ha perso lo stato del dialogo (ad es. dopo un riavvio o un cambio di rete).';

  @override
  String get diagSip481Fix =>
      'Termina e riprova. Se accade spesso, attiva i timer di sessione.';

  @override
  String get diagSip483Explain =>
      'La richiesta è passata in loop tra i server.';

  @override
  String get diagSip483Fix =>
      'Controlla la configurazione di inoltro e instradamento sul centralino.';

  @override
  String get diagSip484Explain => 'Il numero composto è troppo corto.';

  @override
  String get diagSip484Fix =>
      'Componi il numero completo o controlla le regole di chiamata.';

  @override
  String get diagSip486Explain => 'L’altra parte è occupata.';

  @override
  String get diagSip486Fix => 'Riprova più tardi.';

  @override
  String get diagSip487Explain =>
      'La chiamata è stata annullata prima della risposta.';

  @override
  String get diagSip487Fix =>
      'Normale quando il chiamante riaggancia mentre squilla.';

  @override
  String get diagSip488Explain =>
      'Nessun codec o impostazione di cifratura in comune con l’altra parte.';

  @override
  String get diagSip488Fix =>
      'Controlla codec e SRTP (un account con SRTP obbligatorio non può chiamare un endpoint RTP in chiaro).';

  @override
  String get diagSip491Explain => 'Due re-INVITE sono entrati in collisione.';

  @override
  String get diagSip491Fix => 'Di norma viene riprovato automaticamente.';

  @override
  String get diagSip500Explain => 'Il server ha avuto un errore interno.';

  @override
  String get diagSip500Fix =>
      'Riprova più tardi e contatta il provider se continua.';

  @override
  String get diagSip502Explain =>
      'Un server a monte ha restituito una risposta non valida.';

  @override
  String get diagSip502Fix =>
      'Riprova più tardi; contatta il provider se continua.';

  @override
  String get diagSip503Explain =>
      'Il server è sovraccarico, non attivo o sta rifiutando questo client (limite di richieste).';

  @override
  String get diagSip503Fix =>
      'Attendi e riprova, controlla la pagina di stato del provider oppure prova un altro server/porta.';

  @override
  String get diagSip504Explain => 'Un server a monte non ha risposto in tempo.';

  @override
  String get diagSip504Fix => 'Riprova più tardi.';

  @override
  String get diagSip600Explain => 'Tutte le destinazioni sono occupate.';

  @override
  String get diagSip600Fix => 'Riprova più tardi.';

  @override
  String get diagSip603Explain => 'L’altra parte ha rifiutato la chiamata.';

  @override
  String get diagSip603Fix =>
      'Nulla da correggere: la chiamata è stata rifiutata.';

  @override
  String get diagSip604Explain => 'Il numero non esiste.';

  @override
  String get diagSip604Fix => 'Controlla il numero composto.';

  @override
  String get diagSip606Explain =>
      'L’altra parte non può accettare la sessione come offerta.';

  @override
  String get diagSip606Fix => 'Controlla le impostazioni di codec e cifratura.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provvisoria ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'La richiesta è in elaborazione.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Riuscita ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'La richiesta è riuscita.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Reindirizzata ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'La destinazione è stata spostata.';

  @override
  String get diagSipRedirectedFix => 'Controlla le impostazioni di inoltro.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Errore del client ($code)';
  }

  @override
  String get diagSipClientErrorExplain =>
      'Il server ha rifiutato la richiesta.';

  @override
  String get diagSipClientErrorFix =>
      'Controlla l’account e il numero composto.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Errore del server ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'Il server non è riuscito a elaborare la richiesta.';

  @override
  String get diagSipServerErrorFix =>
      'Riprova più tardi o contatta il provider.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Errore globale ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'La richiesta non può essere soddisfatta da nessuna parte.';

  @override
  String get diagSipNoResponseTitle => 'Nessuna risposta';

  @override
  String get diagSipNoResponseExplain =>
      'Non è stata ricevuta alcuna risposta SIP.';

  @override
  String get diagSipNoResponseFix =>
      'Controlla la connessione di rete e l’indirizzo del server.';

  @override
  String get diagWizStepNet => 'Connettività di rete';

  @override
  String diagWizStepDns(String account) {
    return 'DNS e SRV: $account';
  }

  @override
  String get diagWizStepNat => 'Tipo di NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Raggiungibilità del server: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'Certificato TLS: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registrazione: $account';
  }

  @override
  String get diagWizStepAlg => 'Controllo SIP ALG';

  @override
  String get diagWizChecking => 'Controllo in corso...';

  @override
  String diagWizEngineError(String message) {
    return 'Errore del motore: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Controllo non riuscito: $error';
  }

  @override
  String get diagWizNoEngine => 'Il motore SIP non è in esecuzione';

  @override
  String get diagWizNoEngineFix =>
      'Attendi l’avvio del motore (o riavvia l’app), poi esegui di nuovo i controlli.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privato)';
  }

  @override
  String get diagWizNetNone =>
      'Nessuna interfaccia di rete attiva con un indirizzo IP';

  @override
  String get diagWizNetNoneFix =>
      'Connettiti a Wi-Fi, Ethernet o dati mobili, poi esegui di nuovo i controlli.';

  @override
  String get diagWizNetIpv6Only => 'Trovati solo indirizzi IPv6';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Molti provider SIP supportano solo IPv4. Attiva IPv4 su questa rete o usa un provider con supporto IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 indirizzi IPv4',
      one: '1 indirizzo IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfacce',
      one: '1 interfaccia',
    );
    return '$_temp0 su $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'È attiva un’interfaccia di tipo VPN. Le VPN possono aggiungere latenza o bloccare UDP; disattivala se le chiamate non funzionano bene.';

  @override
  String get diagWizDnsNoServer => 'L’account non ha un indirizzo server';

  @override
  String get diagWizDnsNoServerFix =>
      'Modifica l’account e inserisci il dominio SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host è un indirizzo IP, DNS non necessario';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: nessuno';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: nessuno ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: nessuno';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (priorità $priority, peso $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: ricerca non riuscita ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host non viene risolto';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Controlla che il dominio non abbia errori di battitura e che il tuo server DNS funzioni. Puoi impostare un server DNS personalizzato in Impostazioni > Rete (ad es. 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host ha record SRV ma nessun record di indirizzo';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Verranno usate le destinazioni SRV. Se le chiamate falliscono, chiedi al provider di controllare il record A.';

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
      other: ', $srv record SRV',
      one: ', 1 record SRV',
      zero: '',
    );
    return '$host viene risolto in $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Rilevamento NAT scaduto';

  @override
  String get diagWizNatTimeoutFix =>
      'Il server STUN potrebbe non essere raggiungibile (UDP bloccato?). Controlla Impostazioni > Rete > Server STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'Server STUN: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Nessun NAT: questo dispositivo ha un indirizzo pubblico';

  @override
  String get diagWizNatFullCone => 'NAT full cone: adatto al VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT restricted cone: funziona con STUN e keep-alive';

  @override
  String get diagWizNatPortRestricted =>
      'NAT port-restricted cone: funziona con STUN e keep-alive';

  @override
  String get diagWizNatSymmetric =>
      'NAT simmetrico: STUN da solo non può prevedere la porta dei media';

  @override
  String get diagWizNatSymmetricFix =>
      'È probabile audio unidirezionale o assente in alcune chiamate. Attiva ICE e un relay TURN nelle impostazioni dell’account (Account > NAT), oppure usa un provider/centralino con relay dei media (rtpengine).';

  @override
  String get diagWizNatBlocked => 'UDP sembra bloccato';

  @override
  String get diagWizNatBlockedFix =>
      'Usa il trasporto TCP o TLS per l’account. Se la rete filtra tutto tranne il traffico web, prova TLS sulla porta 443 se il tuo provider lo supporta.';

  @override
  String get diagWizNatUnknown => 'Impossibile determinare il tipo di NAT';

  @override
  String get diagWizNatUnknownFix =>
      'Il server STUN non ha risposto. Prova un altro server STUN in Impostazioni > Rete.';

  @override
  String get diagWizNatErr =>
      'Il server STUN non ha risposto, quindi non è stato possibile determinare il tipo di NAT.';

  @override
  String get diagWizNatUnknownRaw => 'Impossibile determinare il tipo di NAT.';

  @override
  String get diagWizOptionsNotLoaded => 'L’account non è caricato nel motore';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Nessuna risposta a OPTIONS entro $seconds s (trasporto: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'Il server non è raggiungibile. Controlla indirizzo e porta, che un firewall non scarti il traffico SIP e prova un altro trasporto (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Richiesta scaduta ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Il server ha risposto $code $reason dopo $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Il server ha risposto $code $reason in $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Un $code in risposta a OPTIONS è normale: il server è raggiungibile ma non consente sonde anonime.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Un tempo di andata e ritorno superiore a 300 ms aggiunge un ritardo percepibile alle conversazioni. Un server più vicino o una connessione cablata aiutano.';

  @override
  String get diagWizTlsRejected =>
      'Il certificato del server è stato rifiutato';

  @override
  String diagWizTlsSubject(String value) {
    return 'Soggetto: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Emittente: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problemi: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Scadenza: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cifrario: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Se è il tuo centralino con certificato autofirmato e l’impronta qui sopra corrisponde, puoi considerarlo attendibile. Altrimenti chiedi al provider un certificato di una CA pubblica.';

  @override
  String get diagWizTlsTrust => 'Considera attendibile questo certificato';

  @override
  String diagWizTlsExpired(String date) {
    return 'Il certificato è scaduto il $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Chiedi all’amministratore del server di rinnovare il certificato.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Il certificato scade tra $days giorni',
      one: 'Il certificato scade tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Chiedi all’amministratore del server di rinnovarlo presto.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Connesso, ma la verifica ha segnalato: $problems';
  }

  @override
  String get diagWizTlsOk => 'Connessione TLS stabilita, certificato valido';

  @override
  String get diagWizTlsRegistered =>
      'Registrato tramite TLS (nessun dettaglio sul certificato)';

  @override
  String get diagWizTlsNone => 'Nessuna connessione TLS osservata finora';

  @override
  String get diagWizTlsNoneFix =>
      'Controlla la porta TLS (di solito 5061) e che il server accetti TLS 1.2 o successivo.';

  @override
  String get diagWizRegDisabledByConfig =>
      'La registrazione è disattivata per questo account (uso peer-to-peer)';

  @override
  String get diagWizRegRegistered => 'Registrato';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registrato (scade tra $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Trasporto: $transport';
  }

  @override
  String get diagWizRegInProgress => 'La registrazione è ancora in corso';

  @override
  String get diagWizRegInProgressFix =>
      'Attendi qualche secondo. Se non si completa mai, il server non risponde; vedi il controllo di raggiungibilità qui sopra.';

  @override
  String get diagWizRegFailed => 'Registrazione non riuscita';

  @override
  String get diagWizRegOffline => 'L’account è offline';

  @override
  String get diagWizRegOfflineFix =>
      'Controlla la connessione di rete. L’app riprova automaticamente.';

  @override
  String get diagWizRegDisabled => 'L’account è disattivato';

  @override
  String get diagWizAlgNoUdp =>
      'Nessun account usa UDP, quindi SIP ALG non è un problema';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: nessuna risposta su UDP, ma TCP ha risposto ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: nessuna risposta su UDP né TCP (problema di server o firewall piuttosto che ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS riceve risposta ma REGISTER va in timeout, tipico di un router che riscrive il SIP';
  }

  @override
  String get diagWizAlgSuspected => 'Sospetto SIP ALG sul tuo router';

  @override
  String get diagWizAlgSuspectedFix =>
      'Disattiva “SIP ALG” / “SIP helper” nelle impostazioni del router, oppure passa l’account a TCP o TLS, o cambia la porta SIP (ad es. 5080) in modo che il router smetta di alterare i pacchetti.';

  @override
  String get diagWizAlgContactChanged =>
      'L’indirizzo Contact è cambiato tra richiesta e risposta';

  @override
  String get diagWizAlgContactChangedFix =>
      'Può dipendere da un SIP ALG o da un server che riscrive i contact. Se le chiamate squillano ma non hanno audio o cadono dopo un po’, disattiva SIP ALG sul router o usa TCP/TLS o la porta 5080.';

  @override
  String get diagWizAlgOk => 'Nessun segno di interferenza SIP ALG';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'Il Contact di REGISTER $sent è tornato come $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Salva $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return 'Salvato $fileName';
  }

  @override
  String get diagSaveFailed => 'Impossibile salvare il file';

  @override
  String get diagCopiedText => 'Testo copiato negli appunti';

  @override
  String get diagCopiedReport => 'Report copiato negli appunti';

  @override
  String get diagCopiedBundle => 'Pacchetto diagnostico copiato negli appunti';

  @override
  String get diagCopiedLogs => 'Log copiati negli appunti';

  @override
  String get diagCopiedTrace => 'Traccia copiata negli appunti';

  @override
  String get diagCopiedDialog => 'Dialogo copiato negli appunti';

  @override
  String get diagSaveAsLog => 'Salva come .log';

  @override
  String get diagSysAppVersion => 'Versione app';

  @override
  String get diagSysPlatform => 'Piattaforma';

  @override
  String get diagSysEngine => 'Motore';

  @override
  String get diagSysAccounts => 'Account';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered di $total registrati';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Impossibile leggere le informazioni di sistema: $error';
  }

  @override
  String get diagSysTransports => 'Trasporti';

  @override
  String get diagSysNoneReported => 'Nessuno segnalato';

  @override
  String get diagSysCodecs => 'Codec';

  @override
  String get diagSysCodecsFooter => 'Codec attivi, dalla priorità più alta.';

  @override
  String get diagSysEngineNotRunning => 'Motore non in esecuzione';

  @override
  String diagSysCodecPriority(int priority) {
    return 'priorità $priority';
  }

  @override
  String get diagSysCodecDisabled => 'disattivato';

  @override
  String get diagSysExport => 'Esporta';

  @override
  String get diagSysExportFooter =>
      'Il pacchetto contiene informazioni di sistema, risultati dei controlli di rete, log recenti e la traccia SIP, con le credenziali oscurate.';

  @override
  String get diagSysCopyBundle => 'Copia pacchetto diagnostico';

  @override
  String get diagSysSaveBundle => 'Salva pacchetto diagnostico';

  @override
  String get diagTabSipTrace => 'Traccia SIP';

  @override
  String get diagTabNetwork => 'Rete';

  @override
  String get diagTabQuality => 'Qualità';

  @override
  String get diagTabAudioTest => 'Test audio';

  @override
  String get diagTabLogs => 'Log';

  @override
  String get diagTabSystem => 'Sistema';

  @override
  String diagRawSentTo(String remote) {
    return 'inviato a $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'ricevuto da $remote';
  }

  @override
  String get diagRawCopied => 'Messaggio copiato';

  @override
  String get diagRawLadder => 'Scala';

  @override
  String get diagRawRedact => 'Oscura credenziali';

  @override
  String diagRawTruncated(int count) {
    return '... troncato ($count caratteri)';
  }

  @override
  String get diagWizIntro =>
      'Controlla connessione, DNS, NAT, raggiungibilità del server, TLS e registrazione, e spiega cosa correggere.';

  @override
  String get diagWizStop => 'Stop';

  @override
  String get diagWizRunChecks => 'Esegui controlli';

  @override
  String get diagWizRunAgain => 'Esegui di nuovo';

  @override
  String get diagWizCopyReport => 'Copia report';

  @override
  String get diagWizSaveReport => 'Salva report';

  @override
  String diagWizCountPassed(int count) {
    return 'Superati $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Avvisi $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Falliti $count';
  }

  @override
  String get diagWizStatusPass => 'Superato';

  @override
  String get diagWizStatusWarn => 'Avviso';

  @override
  String get diagWizStatusFail => 'Fallito';

  @override
  String get diagWizStatusSkipped => 'Saltato';

  @override
  String get diagWizStatusRunning => 'In corso';

  @override
  String get diagWizStatusPending => 'In attesa';

  @override
  String get diagQualityTitle => 'Qualità chiamata';

  @override
  String get diagQualityNoData =>
      'Nessun dato di qualità registrato per questa chiamata.';

  @override
  String get diagQualityTraceForCall => 'Traccia SIP di questa chiamata';

  @override
  String get diagQualityTraceNotCaptured =>
      'Traccia SIP non acquisita per questa chiamata';

  @override
  String get diagQualityLiveCall => 'Chiamata in corso';

  @override
  String get diagQualityNoActiveCall =>
      'Nessuna chiamata attiva. Avvia una chiamata e qui verranno tracciati in tempo reale MOS, jitter, perdita e tempo di andata e ritorno.';

  @override
  String get diagQualityRecentCalls => 'Chiamate recenti';

  @override
  String get diagQualityNoFinished =>
      'Ancora nessuna chiamata terminata con dati di qualità.';

  @override
  String get diagQualityCallEnded => 'La chiamata è terminata.';

  @override
  String get diagQualityMeasuring => 'misurazione';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Grafico $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Grafico $title, ultimo valore $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   max $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Media $avg  ·  peggiore $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Perdita';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count pacch.';
  }

  @override
  String get diagQualityMedia => 'Media';

  @override
  String get diagQualityNoSeries =>
      'Nessuna serie temporale registrata per questa chiamata.';

  @override
  String get diagQualityPacketLoss => 'Perdita pacchetti';

  @override
  String get diagQualityRtt => 'Tempo di andata e ritorno';

  @override
  String get diagLogsForward => 'Inoltra i log del motore';

  @override
  String get diagLogsForwardSub =>
      'Invia le righe di log di pjsip a questo visualizzatore';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Livello $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Oscura all’esportazione';

  @override
  String get diagLogsSearch => 'Cerca nei log';

  @override
  String get diagLogsEmpty => 'Ancora nessuna riga di log.';

  @override
  String get diagLogsForwardingOff =>
      'L’inoltro dei log è disattivato. Attivalo per acquisire i log del motore.';

  @override
  String get diagLogsNoMatch => 'Nessuna riga corrisponde alla ricerca.';

  @override
  String get diagAudioEngineNotRunning => 'Il motore SIP non è in esecuzione.';

  @override
  String get diagAudioMicrophone => 'Microfono';

  @override
  String get diagAudioMicFooter =>
      'Il misuratore di livello legge il dispositivo audio, che il motore apre durante una chiamata o il test dell’eco.';

  @override
  String get diagAudioLevelMeter => 'Misuratore di livello';

  @override
  String get diagAudioLevelMeterSub => 'Parla e osserva la barra muoversi';

  @override
  String get diagAudioMic => 'Mic';

  @override
  String get diagAudioSpeaker => 'Altoparlante';

  @override
  String get diagAudioEchoTest => 'Test dell’eco';

  @override
  String get diagAudioEchoFooter =>
      'Riproduce la tua voce attraverso l’altoparlante. Usa le cuffie per evitare il feedback.';

  @override
  String get diagAudioEchoActive => 'Attivo: parla ora';

  @override
  String get diagAudioEchoIdle => 'Loopback dal microfono all’altoparlante';

  @override
  String get diagAudioSpeakerTest => 'Test dell’altoparlante';

  @override
  String get diagAudioPlayTone => 'Riproduci tono di prova';

  @override
  String get diagAudioPlayToneSub => 'Riprodotto dall’altoparlante selezionato';

  @override
  String get diagAudioPlayingDtmf => 'Riproduzione DTMF';

  @override
  String get diagAudioPlayingRingback => 'Riproduzione tono di libero';

  @override
  String get diagAudioRingback => 'Tono di libero';

  @override
  String get diagAudioDevices => 'Dispositivi';

  @override
  String get diagAudioChooseDevices => 'Scegli microfono e altoparlante';

  @override
  String get diagAudioChooseDevicesSub => 'Apre Impostazioni > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'Livello $label $percent percento';
  }

  @override
  String get diagLadderLocal => 'Locale';

  @override
  String diagLadderSent(String message) {
    return 'Inviato $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Ricevuto $message';
  }

  @override
  String get diagTraceCapture => 'Acquisisci messaggi SIP';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi',
      one: '1 messaggio',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi',
      one: '1 messaggio',
    );
    return '$_temp0  ·  $size  ·  $dropped più vecchi scartati';
  }

  @override
  String get diagTraceOffHint =>
      'Disattivato. Attivalo, poi registrati o effettua una chiamata.';

  @override
  String get diagTraceExportOrClear => 'Esporta o cancella';

  @override
  String get diagTraceSaveAsPcap => 'Salva come .pcap';

  @override
  String get diagTraceCopyAsText => 'Copia come testo';

  @override
  String get diagTraceSearchHint => 'Cerca testo, numero o Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Solo errori';

  @override
  String get diagTraceFilterMethod => 'Filtra per metodo';

  @override
  String get diagTraceAllMethods => 'Tutti i metodi';

  @override
  String get diagTraceMethod => 'Metodo';

  @override
  String get diagTraceFilterAccount => 'Filtra per account';

  @override
  String get diagTraceAllAccounts => 'Tutti gli account';

  @override
  String get diagTraceAccount => 'Account';

  @override
  String get diagTraceRedact => 'Oscura';

  @override
  String get diagTraceList => 'Elenco';

  @override
  String get diagTraceWaiting => 'In attesa di traffico SIP';

  @override
  String get diagTraceWaitingSub =>
      'Registra un account o effettua una chiamata e i messaggi appariranno qui.';

  @override
  String get diagTraceOff => 'La traccia SIP è disattivata';

  @override
  String get diagTraceOffSub =>
      'Attiva l’acquisizione per vedere ogni richiesta e risposta SIP, come elenco o diagramma a scala.';

  @override
  String get diagTraceNoMatch => 'Nessun messaggio corrisponde ai filtri';

  @override
  String get diagTraceAllDialogs => 'Tutti i dialoghi';

  @override
  String get diagTraceCopyDialog => 'Copia questo dialogo';

  @override
  String get diagTraceNoResponse => 'nessuna risposta';

  @override
  String get diagTraceNoCallId => 'nessun Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi',
      one: '1 messaggio',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Registrazione';

  @override
  String get recFormatWav => 'Standard (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stereo, tu e il chiamante su canali separati (WAV)';

  @override
  String get recFormatOpus => 'Compresso (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, circa 2 MB al minuto. Si riproduce ovunque.';

  @override
  String get recFormatWavStereoHint =>
      'Due canali, circa 4 MB al minuto. Tu a sinistra, il chiamante a destra.';

  @override
  String get recFormatOpusHint =>
      'Circa 0,2 MB al minuto. Ogg Opus; alcuni lettori su iPhone, Mac e Windows non riescono ad aprirlo.';

  @override
  String get recOptionInherit => 'Usa impostazione globale';

  @override
  String get recOptionAlways => 'Registra tutte le chiamate';

  @override
  String get recOptionIncoming => 'Registra solo le chiamate in arrivo';

  @override
  String get recOptionOutgoing => 'Registra solo le chiamate in uscita';

  @override
  String get recOptionNever => 'Non registrare mai';

  @override
  String get recRuleAll => 'Tutte le chiamate';

  @override
  String get recRuleIncoming => 'Solo chiamate in arrivo';

  @override
  String get recRuleOutgoing => 'Solo chiamate in uscita';

  @override
  String get recAutoDeleteNever => 'Mai';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dopo $days giorni',
      one: 'Dopo 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Dopo 1 anno';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registrazioni',
      one: '1 registrazione',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registrazioni',
      one: '1 registrazione',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registrazioni',
      one: '1 registrazione',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0  ·  $size  ·  eliminazione automatica dopo $_temp1';
  }

  @override
  String get recSettingsFormat => 'Formato';

  @override
  String get recSettingsAutoGroup => 'Registrazione automatica';

  @override
  String get recSettingsAutoFooter =>
      'Verifica le leggi locali prima di registrare le chiamate. Attiva “Registra sempre le chiamate con questo contatto” in un contatto per registrarle indipendentemente da queste regole.';

  @override
  String get recSettingsAutoRule => 'Registra le chiamate automaticamente';

  @override
  String get recSettingsAccountOverride => 'Sostituisci per questo account';

  @override
  String get recSettingsNoticesGroup => 'Avvisi';

  @override
  String get recSettingsNoticeSwitch =>
      'Riproduci un avviso prima della registrazione';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Riproduce prima un avviso all’altra parte. Il file dell’avviso si sceglie in Impostazioni > Chiamate > Annunci.';

  @override
  String get recSettingsNoticeFile => 'Scegli il file dell’avviso';

  @override
  String get recSettingsNoticeFileHint =>
      'Apre Impostazioni > Chiamate > Annunci';

  @override
  String get recSettingsBeep => 'Segnale acustico di registrazione';

  @override
  String get recSettingsBeepHint => 'Avvisa periodicamente l’altra parte';

  @override
  String get recSettingsTransfersGroup => 'Trasferimenti';

  @override
  String get recSettingsContinue =>
      'Continua a registrare durante i trasferimenti';

  @override
  String get recSettingsContinueHint =>
      'Registra la chiamata di consultazione di un trasferimento assistito e la chiamata che ci viene passata da un trasferimento, e collega le registrazioni';

  @override
  String get recSettingsStorageGroup => 'Archiviazione';

  @override
  String get recSettingsFolder => 'Cartella';

  @override
  String get recSettingsFolderHint => 'Dove vengono salvate le registrazioni';

  @override
  String get recSettingsFolderPlaceholder =>
      'Documenti dell’app / Registrazioni';

  @override
  String get recSettingsChooseFolder => 'Scegli cartella...';

  @override
  String get recSettingsFolderPickerTitle => 'Cartella delle registrazioni';

  @override
  String get recSettingsAutoDelete => 'Elimina le registrazioni vecchie';

  @override
  String get recSettingsAutoDeleteHint =>
      'Controllato all’avvio e una volta al giorno';

  @override
  String get recSettingsManage => 'Gestisci registrazioni';

  @override
  String get recSettingsOpenFolder => 'Apri cartella delle registrazioni';

  @override
  String get recPageTitle => 'Registrazioni';

  @override
  String recSelectedCount(int count) {
    return '$count selezionate';
  }

  @override
  String get recCancelSelection => 'Annulla selezione';

  @override
  String get recSelectAll => 'Seleziona tutto';

  @override
  String get recShareSelected => 'Condividi selezionate';

  @override
  String get recDeleteSelected => 'Elimina selezionate';

  @override
  String get recSearchTooltip => 'Cerca registrazioni';

  @override
  String get recSelectTooltip => 'Seleziona registrazioni';

  @override
  String get recMenuSettings => 'Impostazioni di registrazione';

  @override
  String get recSearchHint => 'Cerca nome o numero';

  @override
  String get recEmptyNone => 'Ancora nessuna registrazione';

  @override
  String get recEmptyNoneHint =>
      'Registra una chiamata con il pulsante Registra, oppure attiva la registrazione automatica nelle Impostazioni.';

  @override
  String get recEmptyNoMatch => 'Nessuna registrazione corrispondente';

  @override
  String get recEmptyNoMatchHint => 'Prova un’altra ricerca o un altro filtro.';

  @override
  String get recClearFilters => 'Cancella filtri';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminare $count registrazioni?',
      one: 'Eliminare 1 registrazione?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'I file audio vengono rimossi da questo dispositivo. L’operazione non può essere annullata.';

  @override
  String get recDeleteOneTitle => 'Eliminare questa registrazione?';

  @override
  String get recDeleteOneMessage =>
      'Il file audio viene rimosso da questo dispositivo. L’operazione non può essere annullata.';

  @override
  String get recFilterAll => 'Tutte';

  @override
  String get recFilterIncoming => 'In arrivo';

  @override
  String get recFilterOutgoing => 'In uscita';

  @override
  String get recFilterByAccount => 'Filtra per account';

  @override
  String get recFilterAllAccounts => 'Tutti gli account';

  @override
  String get recFilterAccountFallback => 'Account';

  @override
  String get recFilterAnyDate => 'Qualsiasi data';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Cancella date';

  @override
  String get recMissingFile => 'Il file audio manca da questo dispositivo.';

  @override
  String recRelated(String title) {
    return 'Correlata: $title';
  }

  @override
  String get recRenameTitle => 'Rinomina registrazione';

  @override
  String get recRenameHint => 'Nome';

  @override
  String get recSaveAs => 'Salva come...';

  @override
  String get recShowInFinder => 'Mostra nel Finder';

  @override
  String get recShowInFolder => 'Mostra nella cartella';

  @override
  String get recViewCall => 'Vedi chiamata';

  @override
  String recSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String get recSaveFailed => 'Impossibile salvare la registrazione';

  @override
  String get recShareFailed => 'Impossibile condividere la registrazione';

  @override
  String get recSaveDialogTitle => 'Salva registrazione';

  @override
  String get recShareSubject => 'Registrazioni di chiamate';

  @override
  String get recPlayerUnsupported =>
      'Questo dispositivo non può riprodurre qui le registrazioni Opus.';

  @override
  String get recPlayerOpenWith => 'Apri con...';

  @override
  String get recPlayerNotFound => 'File della registrazione non trovato';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Impossibile riprodurre questa registrazione: $error';
  }

  @override
  String get recPlayerPlay => 'Riproduci registrazione';

  @override
  String get recPlayerPause => 'Metti in pausa registrazione';

  @override
  String get audioFilesTitle => 'File audio';

  @override
  String audioAdded(String name) {
    return 'Aggiunto “$name”';
  }

  @override
  String get audioFileUnavailable => 'Quel file non è disponibile.';

  @override
  String get audioNameRequired => 'Inserisci un nome';

  @override
  String audioDeleteTitle(String name) {
    return 'Eliminare “$name”?';
  }

  @override
  String get audioDeleteMessage =>
      'Le impostazioni che usano questo file tornano al valore predefinito.';

  @override
  String get audioGroupAdd => 'Aggiungi';

  @override
  String get audioAddFooter =>
      'Funzionano file WAV (PCM, mu-law, A-law) e MP3. I file vengono copiati nell’app, quindi l’originale può essere spostato.';

  @override
  String get audioImport => 'Importa un WAV o MP3…';

  @override
  String get audioGroupMine => 'I miei file';

  @override
  String get audioEmptyTitle => 'Ancora nessun file';

  @override
  String get audioEmptyHint => 'Importa un file o registra il tuo annuncio.';

  @override
  String get audioGroupBuiltIn => 'Integrati';

  @override
  String get audioBuiltInFooter =>
      'Generati per SoftphonePro, liberi da usare.';

  @override
  String get audioPreviewStop => 'Interrompi anteprima';

  @override
  String audioPreviewPlay(String name) {
    return 'Anteprima di $name';
  }

  @override
  String get audioRecordedName => 'Dai un nome a questa registrazione';

  @override
  String get audioRecordedDefaultName => 'Il mio annuncio';

  @override
  String audioSaved(String name) {
    return 'Salvato “$name”';
  }

  @override
  String get audioRecorderStop => 'Stop';

  @override
  String get audioRecorderPlay => 'Riproduci registrazione';

  @override
  String audioRecorderNew(String duration) {
    return 'Nuova registrazione  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Scarta';

  @override
  String get audioRecordOwn => 'Registra il tuo…';

  @override
  String get audioRecordOwnHint =>
      'Usa il microfono selezionato nelle impostazioni Audio';

  @override
  String get audioMissingFile => 'File mancante';

  @override
  String get audioBuiltInCalm => 'Calma (integrata)';

  @override
  String get audioBuiltInBreeze => 'Brezza (integrata)';

  @override
  String get audioBuiltInChime => 'Segnale di avviso (integrato)';

  @override
  String get audioErrOnlyWavMp3 => 'Si possono usare solo file WAV e MP3.';

  @override
  String get audioErrNotFound => 'Impossibile trovare quel file.';

  @override
  String get audioErrNotSaved => 'La registrazione non è stata salvata.';

  @override
  String get audioErrEmpty => 'Questo file audio è vuoto o illeggibile.';

  @override
  String audioErrUnusable(String reason) {
    return 'Questo file audio non può essere usato ($reason). Usa un WAV PCM, mu-law o A-law, oppure un MP3.';
  }

  @override
  String get audioRecEngineOff => 'Il motore di chiamata non è in esecuzione.';

  @override
  String get audioRecUnsupported =>
      'Questa versione del motore di chiamata non può registrare il microfono.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Impossibile avviare la registrazione: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Registrazione non riuscita: $reason';
  }

  @override
  String get audioStrengthLow => 'Bassa';

  @override
  String get audioStrengthMedium => 'Media';

  @override
  String get audioStrengthHigh => 'Alta';

  @override
  String get audioStrengthMax => 'Massima';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Predefinito di sistema';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Predefinito di sistema ($name)';
  }

  @override
  String get voiceTitle => 'Isolamento vocale';

  @override
  String get voiceUnavailable =>
      'La riduzione del rumore con IA non è disponibile in questa versione del motore di chiamata. La soppressione del rumore standard in Elaborazione continua a funzionare.';

  @override
  String get voiceGroupAi => 'Riduzione del rumore con IA';

  @override
  String get voiceAiFooter =>
      'Rimuove clic della tastiera, ventole e voci di sottofondo dalla chiamata usando una rete neurale sul dispositivo (RNNoise). Nulla lascia il tuo dispositivo. Un’intensità maggiore rimuove più rumore ma può tagliare l’inizio delle parole.';

  @override
  String get voiceMic => 'Il mio microfono';

  @override
  String get voiceMicHint => 'Ripulisce ciò che sente l’altra persona';

  @override
  String get voiceOthers => 'Altri partecipanti';

  @override
  String get voiceOthersHint => 'Ripulisce i chiamanti rumorosi che ascolti';

  @override
  String voiceStrength(String value) {
    return 'Intensità: $value';
  }

  @override
  String get voiceGroupTry => 'Provalo';

  @override
  String get voiceTryFooter =>
      'Usa le cuffie per il test dell’eco, altrimenti sentirai il feedback.';

  @override
  String get voiceEchoTest => 'Prova con l’eco';

  @override
  String get voiceEchoTestHint => 'Ti riproduce il microfono elaborato';

  @override
  String get voiceEchoFailed => 'Test dell’eco non riuscito';

  @override
  String get voiceGroupSystem => 'Sistema';

  @override
  String get voiceSystemFooter =>
      'macOS e iOS possono anche isolare la tua voce per ogni app. Scegli Isolamento vocale nella modalità microfono di sistema.';

  @override
  String get voiceSystemMode =>
      'Modalità microfono di sistema (Isolamento vocale)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Le modalità microfono richiedono macOS 12 o iOS 15 o successivi.';

  @override
  String get voiceSpeechDetection => 'Rilevamento del parlato';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent percento';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Effetti audio di Android';

  @override
  String get voiceAndroidFooter =>
      'Il telefono può anche ripulire il microfono da solo. Questi dati sono riportati da Android e sono separati dall’impostazione qui sopra.';

  @override
  String get voiceAndroidNs => 'Soppressore di rumore';

  @override
  String get voiceAndroidAec => 'Cancellatore di eco';

  @override
  String get voiceNotAvailableDevice => 'Non disponibile su questo dispositivo';

  @override
  String get callLinkNotLocal =>
      'Questo tipo di link può essere usato solo dalla riga di comando di questo computer.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Connettersi al dispositivo $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Un link di un’altra app o di una pagina web vuole collegare SoftphonePro a questo dispositivo. Connettiti solo se te lo aspetti.';

  @override
  String get linkLanConnectAction => 'Connetti';

  @override
  String get linkImportSensitiveHeader =>
      'Modifiche sensibili in questa configurazione:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Risponde automaticamente alle chiamate in arrivo';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Inoltra le chiamate a $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Cambia chi può avviare un interfono o prelevare una chiamata (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Riscrive i numeri che componi';

  @override
  String get linkImportFlagLinksImmediately =>
      'Le chiamate dai link web partono subito, senza conferma';

  @override
  String get linkImportFlagDiagnostics =>
      'Attiva la registrazione dettagliata o la traccia SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Consenti la risposta automatica per gli account importati';

  @override
  String linkImportRefused(String setting) {
    return 'Questa importazione tenta di modificare «$setting», che non può mai essere impostato tramite link, codice QR, testo incollato o file. Usa invece l\'opzione da riga di comando --provision su questo computer. Non è stato importato nulla.';
  }

  @override
  String get lanPairIntercomNote =>
      'I dispositivi associati possono chiedere una chiamata interfono; ti verrà chiesto prima di ognuna (modificabile in Impostazioni > LAN).';

  @override
  String get callLinkUnsupportedScheme =>
      'Questo tipo di link non è supportato.';

  @override
  String get linkImportFlagAutoRecord => 'Registra le chiamate automaticamente';

  @override
  String get linkImportFlagBlocklist =>
      'Modifica la tua lista di blocco chiamate';

  @override
  String get linkImportFlagEmergency => 'Modifica i tuoi numeri di emergenza';

  @override
  String get linkImportFlagSpeedDial => 'Imposta numeri di chiamata rapida';

  @override
  String get linkImportFlagRecordingDelete =>
      'Elimina automaticamente le vecchie registrazioni';

  @override
  String get linkImportFlagFeatureCodes =>
      'Compone codici funzione PBX personalizzati';

  @override
  String get linkImportAllowAutoRecord =>
      'Consenti la registrazione automatica delle chiamate';

  @override
  String get importIgnoredHeader =>
      'Ignorato (non consentito nelle importazioni):';

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
    return 'Proxy: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'Relay TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Intestazioni SIP personalizzate: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'ID chiamante: $callerId';
  }

  @override
  String get importAccountSrtpOff =>
      'Nessuna cifratura dei media (SRTP disattivato)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Indirizzo: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Aggiorna $updated esistenti, aggiungi $added nuovi';
  }

  @override
  String get mixerTitle => 'Mixer audio';

  @override
  String get mixerMicrophone => 'Microfono';

  @override
  String get mixerSpeaker => 'Cuffie e altoparlante';

  @override
  String get mixerMicVolume => 'Volume del microfono';

  @override
  String get mixerSpeakerVolume => 'Volume dell\'altoparlante';

  @override
  String mixerMeterLabel(String name) {
    return 'Livello: $name';
  }

  @override
  String get mixerInputDevice => 'Dispositivo di ingresso';

  @override
  String get mixerOutputDevice => 'Dispositivo di uscita';

  @override
  String get mixerOutputRoute => 'Uscita audio';

  @override
  String get mixerInputFollowsOutput =>
      'Il microfono segue l\'uscita audio selezionata.';

  @override
  String get mixerShowMore => 'Mostra dispositivi e musica di sottofondo';

  @override
  String get mixerShowLess => 'Mostra meno controlli';

  @override
  String get mixerStripShow => 'Mostra il mixer audio';

  @override
  String get mixerStripHide => 'Nascondi il mixer audio';

  @override
  String get musicbedTitle => 'Musica di sottofondo';

  @override
  String get musicbedPlay => 'Riproduci musica di sottofondo';

  @override
  String get musicbedVolume => 'Volume della musica di sottofondo';

  @override
  String get musicbedChooseFile => 'Scegli un file';

  @override
  String musicbedChangeFile(String name) {
    return 'File della musica di sottofondo: $name. Tocca per cambiare.';
  }

  @override
  String get musicbedHearIt => 'Ascoltala anch\'io';

  @override
  String get musicbedMonitorVolume => 'Volume di ascolto';

  @override
  String get musicbedAddFile => 'Aggiungi un file…';

  @override
  String get musicbedPickerTitle => 'File della musica di sottofondo';

  @override
  String get musicbedOn => 'Musica di sottofondo attiva';

  @override
  String get musicbedOnTooltip =>
      'Un file musicale viene riprodotto per tutti nelle tue chiamate.';

  @override
  String get musicbedFileMissing =>
      'Il file della musica di sottofondo non è più disponibile, quindi è stata disattivata.';

  @override
  String get musicbedNeedsFile =>
      'Scegli prima un file per la musica di sottofondo.';

  @override
  String musicbedStopped(String message) {
    return 'Musica di sottofondo interrotta: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Riproduce in loop un file musicale sotto la tua voce per tutti nelle tue chiamate, anche se sei in muto. Le chiamate in attesa sentono la musica di attesa.';

  @override
  String get musicbedSettingsFile => 'File musicale';

  @override
  String get linkImportFlagMusicbed => 'Riproduce musica nelle tue chiamate';

  @override
  String get musicbedMonitorIosHint => 'Su iPhone la senti durante le chiamate';

  @override
  String get musicbedStopFailed =>
      'Impossibile fermare la musica. Potrebbe essere ancora udibile dai tuoi interlocutori.';
}
