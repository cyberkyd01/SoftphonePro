// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get languagePickerHint =>
      'Les noms de langues sont affichés dans leur propre langue.';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionImport => 'Importer';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionDetails => 'Détails';

  @override
  String get actionMore => 'Plus';

  @override
  String get actionSettings => 'Réglages';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionYes => 'Oui';

  @override
  String get actionNo => 'Non';

  @override
  String get commonOn => 'Activé';

  @override
  String get commonOff => 'Désactivé';

  @override
  String get commonNone => 'Aucun';

  @override
  String get commonDefault => 'Par défaut';

  @override
  String get commonSystem => 'Système';

  @override
  String get commonAutomatic => 'Automatique';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get commonNotSet => 'Non défini';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusDoNotDisturb => 'Ne pas déranger';

  @override
  String get statusOffline => 'Hors ligne';

  @override
  String get statusOnACall => 'En appel';

  @override
  String get settingsEntryAccounts => 'Comptes';

  @override
  String get settingsEntryAccountsSub => 'Comptes SIP et enregistrement';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub =>
      'Périphériques, niveaux, annulation d’écho';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Ordre, disponibilité, Opus';

  @override
  String get settingsEntryCalls => 'Appels';

  @override
  String get settingsEntryCallsSub =>
      'NPD, double appel, réponse auto, plan de numérotation';

  @override
  String get settingsEntryNetwork => 'Réseau';

  @override
  String get settingsEntryNetworkSub => 'Transports, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Enregistrement';

  @override
  String get settingsEntryNotifications => 'Notifications et sonneries';

  @override
  String get settingsEntryShortcuts => 'Raccourcis';

  @override
  String get settingsEntryShortcutsSub =>
      'Raccourcis globaux, touches de l’appli';

  @override
  String get settingsEntryAppearance => 'Apparence';

  @override
  String get settingsEntryPrivacy => 'Confidentialité et sécurité';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisionnement';

  @override
  String get settingsEntryProvisioningSub => 'Import, export, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnostics';

  @override
  String get settingsEntryDiagnosticsSub => 'Trace SIP, tests réseau';

  @override
  String get settingsEntryAdvanced => 'Avancé';

  @override
  String get settingsEntryAbout => 'À propos';

  @override
  String get settingsAccountsEmptyTitle => 'Ajoutez votre premier compte';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Connectez-vous à votre PBX ou fournisseur SIP pour commencer à appeler.';

  @override
  String get settingsAccountsAdd => 'Ajouter un compte';

  @override
  String get settingsAccountsYourAccounts => 'Vos comptes';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  serveur de secours utilisé';
  }

  @override
  String get settingsAudioDevices => 'Périphériques';

  @override
  String get settingsAudioMicrophone => 'Microphone';

  @override
  String get settingsAudioSpeaker => 'Haut-parleur';

  @override
  String get settingsAudioRinger => 'Sonnerie';

  @override
  String get settingsAudioRingerSub =>
      'Jouer la sonnerie sur un périphérique distinct';

  @override
  String get settingsAudioRefreshDevices => 'Actualiser les périphériques';

  @override
  String get settingsAudioLevelsAndTest => 'Niveaux et test';

  @override
  String get settingsAudioMicVolume => 'Volume du microphone';

  @override
  String get settingsAudioMicLevel => 'Niveau du micro';

  @override
  String get settingsAudioSpeakerVolume => 'Volume du haut-parleur';

  @override
  String get settingsAudioSpeakerLevel => 'Niveau du haut-parleur';

  @override
  String get settingsAudioTestSpeaker => 'Tester le haut-parleur';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Joue une courte tonalité sur le haut-parleur sélectionné';

  @override
  String get settingsAudioTestToneFailed =>
      'Impossible de jouer la tonalité de test';

  @override
  String get settingsAudioEchoTestFailed => 'Échec du test d’écho';

  @override
  String get settingsAudioEchoTest => 'Test d’écho';

  @override
  String get settingsAudioEchoTestSub =>
      'Renvoie votre microphone sur le haut-parleur. Utilisez un casque pour éviter le larsen.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voix et fichiers';

  @override
  String get settingsAudioVoiceIsolation =>
      'Isolation vocale (réduction de bruit par IA)';

  @override
  String get settingsAudioAudioFiles => 'Fichiers audio';

  @override
  String get settingsAudioAudioFilesSub => 'Musique d’attente et annonces';

  @override
  String get settingsAudioProcessing => 'Traitement';

  @override
  String get settingsAudioEchoCancellation => 'Annulation d’écho';

  @override
  String get settingsAudioEcSimple => 'Simple';

  @override
  String get settingsAudioEcPlatform => 'Plateforme';

  @override
  String get settingsAudioEchoTail => 'Queue d’écho';

  @override
  String get settingsAudioNoiseSuppression => 'Suppression du bruit';

  @override
  String get settingsAudioAgc => 'Contrôle automatique du gain';

  @override
  String get settingsAudioVad => 'Détection d’activité vocale';

  @override
  String get settingsAudioVadSub =>
      'Économise la bande passante pendant les silences';

  @override
  String get settingsAudioAdvanced => 'Avancé';

  @override
  String get settingsAudioAdvancedFooter =>
      'Les valeurs du tampon de gigue sont en millisecondes ; -1 utilise la valeur par défaut du moteur. Leur modification redémarre le moteur d’appel.';

  @override
  String get settingsAudioPtime => 'Durée de paquet (ptime)';

  @override
  String get settingsAudioJbInitial => 'Tampon de gigue : initial';

  @override
  String get settingsAudioJbMinPrefetch =>
      'Tampon de gigue : préchargement minimal';

  @override
  String get settingsAudioJbMaxPrefetch =>
      'Tampon de gigue : préchargement maximal';

  @override
  String get settingsAudioJbMaxSize => 'Tampon de gigue : taille maximale';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microphone $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Autres $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent pour cent';
  }

  @override
  String settingsUnitMs(int value) {
    return '$value ms';
  }

  @override
  String settingsUnitKbps(int value) {
    return '$value kbit/s';
  }

  @override
  String settingsUnitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Ordre et disponibilité';

  @override
  String get settingsCodecsDragHint =>
      'Faites glisser pour réorganiser. Les comptes peuvent remplacer cette liste dans leurs propres réglages.';

  @override
  String get settingsCodecsBitrate => 'Débit';

  @override
  String get settingsCodecsFec => 'FEC intégré';

  @override
  String get settingsCodecsFecSub => 'Compense la perte de paquets';

  @override
  String get settingsCodecsDtxSub => 'Arrêter l’envoi pendant les silences';

  @override
  String get settingsCodecsCbr => 'Débit constant';

  @override
  String get settingsCodecsComplexity => 'Complexité';

  @override
  String get settingsCallsIncoming => 'Entrants';

  @override
  String get settingsCallsDndSub => 'Rejeter tous les appels entrants';

  @override
  String get settingsCallsRejectWith => 'Rejeter avec';

  @override
  String get settingsCallsReasonBusy => 'Occupé (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Temporairement indisponible (480)';

  @override
  String get settingsCallsReasonDecline => 'Refusé (603)';

  @override
  String get settingsCallsWaiting => 'Double appel';

  @override
  String get settingsCallsWaitingSub =>
      'Autoriser un second appel entrant pendant un appel';

  @override
  String get settingsCallsWhenBusy => 'Si occupé et double appel désactivé';

  @override
  String get settingsCallsRejectAnonymous => 'Rejeter les appels anonymes';

  @override
  String get settingsCallsLinksImmediately =>
      'Appeler immédiatement via les liens';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Les liens tel:, sip: et callto: lancent l’appel sans attendre dans le clavier';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Synchroniser NPD / renvoi avec le PBX via codes service';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Compose brièvement les codes en étoile du compte (par exemple *78) lorsque vous modifiez NPD ou le renvoi';

  @override
  String get settingsCallsAutoAnswerGroup => 'Réponse automatique';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Le renvoi d’appel et la réponse automatique par compte se règlent dans chaque compte.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Répondre automatiquement à tous les appels';

  @override
  String get settingsCallsAnswerAfter => 'Répondre après';

  @override
  String get settingsCallsAnswerImmediately => 'Immédiatement';

  @override
  String get settingsCallsIntercomHeaders =>
      'Respecter les en-têtes d’interphone';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Indications de réponse automatique Call-Info, Alert-Info et Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Numéros bloqués';

  @override
  String get settingsCallsBlockNumber => 'Bloquer un numéro';

  @override
  String get settingsCallsBlockNumberTitle => 'Bloquer le numéro';

  @override
  String get settingsCallsBlockNumberHint => 'Numéro ou adresse SIP';

  @override
  String get settingsCallsSpeedDial => 'Numérotation abrégée';

  @override
  String get settingsCallsDialPlan => 'Plan de numérotation';

  @override
  String get settingsCallsDialRules => 'Règles de numérotation';

  @override
  String get settingsCallsStripPrefix => 'Préfixe de ligne externe à retirer';

  @override
  String get settingsCallsStripPrefixSub =>
      'Par exemple 9, retiré au début des numéros composés';

  @override
  String get settingsCallsPlusReplacement => 'Remplacer le + initial par';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Par exemple 00 pour l’accès international';

  @override
  String get settingsCallsPlusReplacementHint => 'Conserver le +';

  @override
  String get settingsCallsCountryPrefix => 'Indicatif pays par défaut';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Les numéros nationaux commençant par 0 reçoivent cet indicatif, par exemple +33';

  @override
  String get settingsCallsEmergency => 'Numéros d’urgence';

  @override
  String get settingsCallsEmergencySub =>
      'Séparés par des virgules. Ils ignorent les règles de numérotation.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Débloquer $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count sur 9 attribués';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count règles',
      one: '1 règle',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nouvelle règle de numérotation';

  @override
  String get settingsDialRulesEdit => 'Modifier la règle de numérotation';

  @override
  String get settingsDialRulesName => 'Nom';

  @override
  String get settingsDialRulesPattern => 'Motif (regex)';

  @override
  String get settingsDialRulesReplacement => 'Remplacement';

  @override
  String get settingsDialRulesReplacementHelp =>
      'Utilisez \$1, \$2 pour les groupes';

  @override
  String get settingsDialRulesRoute => 'Router via le compte';

  @override
  String get settingsDialRulesAdd => 'Ajouter une règle';

  @override
  String get settingsDialRulesLiveTest => 'Test en direct';

  @override
  String get settingsDialRulesTyped => 'Numéro saisi';

  @override
  String get settingsDialRulesNothing => '(rien)';

  @override
  String get settingsDialRulesEmergency =>
      'Numéro d’urgence : composé tel que saisi';

  @override
  String get settingsDialRulesAccountFallback => 'compte';

  @override
  String get settingsDialRulesEmpty =>
      'Aucune règle. Les numéros sont nettoyés (espaces, tirets et parenthèses supprimés) et composés tels que saisis. Les règles s’appliquent de haut en bas ; la première correspondance l’emporte.';

  @override
  String get settingsDialRulesDelete => 'Supprimer la règle';

  @override
  String get settingsDialRulesDeleteTitle => 'Supprimer la règle ?';

  @override
  String settingsDialRulesVia(String account) {
    return 'via $account';
  }

  @override
  String get settingsNetworkTransports => 'Transports';

  @override
  String get settingsNetworkTransportsFooter =>
      'Le port 0 choisit un port libre aléatoire. La modification des transports redémarre le moteur d’appel.';

  @override
  String get settingsNetworkUdpPort => 'Port UDP';

  @override
  String get settingsNetworkTcpPort => 'Port TCP';

  @override
  String get settingsNetworkTlsPort => 'Port TLS';

  @override
  String get settingsNetworkVerifyCerts =>
      'Vérifier les certificats du serveur';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Ne désactivez que pour les PBX à certificat auto-signé, ou épinglez le certificat ci-dessous';

  @override
  String get settingsNetworkCustomCa => 'Fichier CA personnalisé';

  @override
  String get settingsNetworkCustomCaSub =>
      'Bundle PEM utilisé à la place de la liste intégrée (AC d’un PBX privé)';

  @override
  String get settingsNetworkCustomCaHint => 'Liste Mozilla intégrée';

  @override
  String get settingsNetworkPins => 'Certificats épinglés';

  @override
  String get settingsNetworkPinsSub =>
      'hôte=empreinte SHA256, séparés par des virgules';

  @override
  String get settingsNetworkNat => 'Traversée NAT';

  @override
  String get settingsNetworkStun => 'Serveurs STUN';

  @override
  String get settingsNetworkStunSub => 'hôte:port, séparés par des virgules';

  @override
  String get settingsNetworkIceTurn => 'ICE et TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Configurés par compte sous NAT';

  @override
  String get settingsNetworkAdvanced => 'Avancé';

  @override
  String get settingsNetworkQos => 'QoS (marquage DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Marquer les paquets SIP et voix en priorité';

  @override
  String get settingsNetworkDns => 'Serveurs DNS';

  @override
  String get settingsNetworkDnsSub => 'Laisser vide pour automatique';

  @override
  String get settingsNetworkRtpStart => 'Début des ports RTP';

  @override
  String get settingsNetworkRtpRange => 'Plage de ports RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 utilise la valeur par défaut';

  @override
  String get settingsNotifRingtone => 'Sonnerie';

  @override
  String get settingsNotifDefaultRingtone => 'Sonnerie par défaut';

  @override
  String get settingsNotifProgressTones => 'Tonalités d’appel';

  @override
  String get settingsNotifProgressTonesSub =>
      'Retour d’appel, occupation et saturation pendant la numérotation';

  @override
  String get settingsNotifRingerVolume => 'Volume de la sonnerie';

  @override
  String get settingsNotifCustomRingtone => 'Fichier de sonnerie personnalisé';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Chemin d’un fichier WAV (ordinateur)';

  @override
  String get settingsNotifGroup => 'Notifications';

  @override
  String get settingsNotifRequestPermissions => 'Demander les autorisations';

  @override
  String get settingsNotifRequestPermissionsSub =>
      'Microphone et notifications';

  @override
  String get settingsNotifTyping => 'Envoyer les indicateurs de saisie';

  @override
  String get settingsAppearanceTheme => 'Thème';

  @override
  String get settingsAppearanceLight => 'Clair';

  @override
  String get settingsAppearanceDark => 'Sombre';

  @override
  String get settingsAppearanceAccent => 'Couleur d’accentuation';

  @override
  String get settingsAppearanceAccentOption =>
      'Option de couleur d’accentuation';

  @override
  String get settingsAppearanceCompact => 'Densité compacte';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microphone : $microphone, notifications : $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Sécurité';

  @override
  String get settingsPrivacyPasswords => 'Mots de passe';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Stockés dans le trousseau / coffre du système (repli sur un fichier chiffré)';

  @override
  String get settingsPrivacyGroup => 'Confidentialité';

  @override
  String get settingsPrivacyNoTelemetry => 'Aucune télémétrie';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro n’envoie aucune donnée d’analyse. Le trafic réseau ne va que vers vos serveurs SIP.';

  @override
  String get settingsPrivacyYourData => 'Vos données';

  @override
  String get settingsPrivacyClearHistory => 'Effacer l’historique des appels';

  @override
  String get settingsPrivacyDeleteContacts => 'Supprimer tous les contacts';

  @override
  String get settingsPrivacyDeleteMessages => 'Supprimer tous les messages';

  @override
  String get settingsPrivacyConfirmHistory =>
      'Supprimer l’historique des appels ?';

  @override
  String get settingsPrivacyConfirmContacts => 'Supprimer tous les contacts ?';

  @override
  String get settingsPrivacyConfirmMessages => 'Supprimer tous les messages ?';

  @override
  String get settingsPrivacyCannotUndo => 'Cette action est irréversible.';

  @override
  String get settingsPrivacyDeletedHistory => 'Historique des appels supprimé';

  @override
  String get settingsPrivacyDeletedContacts =>
      'Tous les contacts ont été supprimés';

  @override
  String get settingsPrivacyDeletedMessages =>
      'Tous les messages ont été supprimés';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Les appareils d’un même réseau se trouvent, s’associent avec un code à 6 chiffres et communiquent directement, sans aucun serveur.';

  @override
  String get settingsLanEnable => 'Activer LAN Link';

  @override
  String get settingsLanDeviceName => 'Nom de l’appareil';

  @override
  String get settingsLanDeviceNameHint => 'Cet appareil';

  @override
  String get settingsLanAllowIntercom => 'Autoriser l’interphone';

  @override
  String get settingsLanAllowIntercomSub =>
      'Laisser les appareils associés vous appeler avec réponse automatique';

  @override
  String get settingsLanAskIntercom =>
      'Demander avant d’autoriser l’interphone';

  @override
  String get settingsLanAskIntercomSub =>
      'Sinon, les appareils associés obtiennent une réponse automatique pendant 30 s après leur demande';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Accepter automatiquement les fichiers des appareils associés';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Sinon, une confirmation est demandée pour chaque fichier';

  @override
  String get settingsLanAllowPull =>
      'Laisser les appareils associés récupérer mes appels';

  @override
  String get settingsLanAllowPullSub =>
      'Un appareil associé peut reprendre un appel actif ici';

  @override
  String get settingsLanDownloads => 'Dossier de téléchargements';

  @override
  String get settingsLanDownloadsHint =>
      'Par défaut (Téléchargements/SoftphonePro)';

  @override
  String get settingsLanPort => 'Port de liaison';

  @override
  String get settingsLanSharedAccounts =>
      'Comptes partagés avec les appareils associés';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Partager un compte enregistré permet à un appareil associé sur le même serveur de recevoir directement vos appels (transfert d’appel) au lieu de les relayer.';

  @override
  String get settingsAdvEngine => 'Moteur';

  @override
  String get settingsAdvSimulator => 'Utiliser le simulateur';

  @override
  String get settingsAdvSimulatorSub =>
      'Fonctionne sans le moteur natif. Les appels sont simulés.';

  @override
  String get settingsAdvLogLevel => 'Niveau de journalisation';

  @override
  String get settingsAdvLogErrors => 'Erreurs';

  @override
  String get settingsAdvLogInfo => 'Infos';

  @override
  String get settingsAdvLogDebug => 'Débogage';

  @override
  String get settingsAdvLogVerbose => 'Détaillé';

  @override
  String get settingsAdvSipTrace => 'Trace SIP';

  @override
  String get settingsAdvRestartEngine => 'Redémarrer le moteur';

  @override
  String get settingsAdvDesktop => 'Ordinateur';

  @override
  String get settingsAdvStartAtLogin => 'Lancer à l’ouverture de session';

  @override
  String get settingsAdvCloseToTray => 'Réduire dans la zone de notification';

  @override
  String get settingsAdvCloseToTraySub =>
      'Fermer la fenêtre laisse SoftphonePro actif pour que les appels sonnent toujours. Quittez via l’icône de la zone de notification / barre des menus.';

  @override
  String get settingsAboutLicence => 'Licence';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro est un logiciel libre : vous pouvez le redistribuer et/ou le modifier selon les termes de la licence publique générale GNU publiée par la Free Software Foundation, version 3 ou ultérieure. Il est distribué SANS AUCUNE GARANTIE.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 ou ultérieure';

  @override
  String get settingsAboutGplSub =>
      'Code source disponible dans le dépôt du projet';

  @override
  String get settingsAboutThirdParty => 'Mentions tierces';

  @override
  String get settingsAboutPackages => 'Paquets Flutter et Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT et Apache 2.0. Voir la page des licences.';

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
  String get updatesChecking => 'Vérification…';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version est disponible';
  }

  @override
  String get updatesUpToDate => 'Vous êtes à jour';

  @override
  String get updatesCouldNotCheck => 'Vérification impossible';

  @override
  String get updatesNotCheckedYet => 'Pas encore vérifié';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Dernière vérification : $dateString';
  }

  @override
  String get updatesTitle => 'Mises à jour';

  @override
  String get updatesFooter =>
      'La vérification contacte uniquement api.github.com (une fois par semaine) et n’envoie rien d’autre que la requête elle-même : aucun identifiant, aucune donnée de compte ou d’appel. SoftphonePro ne télécharge et n’installe jamais rien de lui-même.';

  @override
  String get updatesCheckSwitch => 'Rechercher les mises à jour';

  @override
  String get updatesCheckNow => 'Vérifier maintenant';

  @override
  String updatesSkippingVersion(String version) {
    return 'Version $version ignorée';
  }

  @override
  String get updatesStopSkipping => 'Ne plus ignorer';

  @override
  String get updatesReleaseNotes => 'Notes de version';

  @override
  String get updatesDownload => 'Télécharger';

  @override
  String get updatesSkipVersion => 'Ignorer cette version';

  @override
  String get updatesDismiss => 'Masquer';

  @override
  String get updatesRateLimited =>
      'Limite de requêtes GitHub atteinte, réessayez plus tard';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub a répondu $status';
  }

  @override
  String get updatesUnexpectedReply => 'Réponse inattendue';

  @override
  String get updatesTimedOut => 'Délai dépassé';

  @override
  String get updatesAlreadyChecking => 'Vérification déjà en cours';

  @override
  String get encryptionTitle => 'Chiffrement';

  @override
  String get encryptionFooter =>
      'Chiffre la base de données locale avec AES-256-GCM. La clé est conservée dans le trousseau / coffre du système ; si elle est perdue, les données sont irrécupérables. Les enregistrements d’appels et les fichiers exportés ne sont pas chiffrés. La modification prend effet au prochain démarrage de SoftphonePro (quittez-le complètement d’abord) ; l’ancien fichier est écrasé puis supprimé dès que la nouvelle base est ouverte et vérifiée.';

  @override
  String get encryptionSwitchTitle =>
      'Chiffrer l’historique des appels, les contacts et les messages sur cet appareil';

  @override
  String get encryptionWillEncrypt => 'Sera chiffré au prochain démarrage';

  @override
  String get encryptionWillDecrypt => 'Sera déchiffré au prochain démarrage';

  @override
  String get encryptionRestartToEncrypt =>
      'Quittez et relancez SoftphonePro pour chiffrer vos données.';

  @override
  String get encryptionRestartToDecrypt =>
      'Quittez et relancez SoftphonePro pour déchiffrer vos données.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Numérotation abrégée $slot';
  }

  @override
  String get speedDialNumberLabel => 'Numéro ou adresse SIP';

  @override
  String get speedDialLabelOptional => 'Libellé (facultatif)';

  @override
  String get speedDialCallFrom => 'Appeler depuis';

  @override
  String get speedDialSelectedAccount => 'Compte sélectionné';

  @override
  String get speedDialTitle => 'Numérotation abrégée';

  @override
  String get speedDialHint =>
      'Appuyez longuement sur un chiffre (1-9) du clavier vide pour appeler son numéro.';

  @override
  String get speedDialNotAssigned => 'Non attribué';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON non valide : $detail';
  }

  @override
  String get provisioningExpectedObject => 'Un objet JSON était attendu';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Version de configuration $version non prise en charge';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Entrée de compte ignorée (pas un objet)';

  @override
  String get provisioningNothingToImport =>
      'Le fichier ne contient ni compte ni réglage';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'Le compte « $name » nécessite un nom d’utilisateur et un domaine';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Le serveur a répondu $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Impossible de télécharger la configuration : $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Impossible de lire $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes importés',
      one: '1 compte importé',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Importer la configuration';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts comptes',
      one: '1 compte',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings réglages',
      one: '1 réglage',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle =>
      'Importer depuis une URL ou du JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://… ou collez du JSON';

  @override
  String get provisioningInvalidSource =>
      'Ce n’est ni une URL, ni un lien, ni du JSON valide';

  @override
  String get provisioningScanTitle => 'Scanner le QR de provisionnement';

  @override
  String get provisioningPasteHint => 'Collez du JSON, un lien ou une URL';

  @override
  String get provisioningImportGroup => 'Importer';

  @override
  String get provisioningImportFooter =>
      'Prend en charge le JSON avec comptes et réglages. Les espaces réservés \${VAR} sont remplacés par des valeurs vides sauf si une valeur par défaut est donnée sous la forme \${VAR:-défaut}.';

  @override
  String get provisioningScanQr => 'Scanner un code QR';

  @override
  String get provisioningFromUrl => 'Depuis une URL ou du JSON collé';

  @override
  String get provisioningFromFile => 'Depuis un fichier';

  @override
  String get provisioningFromClipboard => 'Depuis le presse-papiers';

  @override
  String get provisioningExportGroup => 'Exporter';

  @override
  String get provisioningIncludePasswords => 'Inclure les mots de passe';

  @override
  String get provisioningIncludePasswordsHint =>
      'Quiconque possède le fichier peut utiliser vos comptes';

  @override
  String get provisioningCopyConfig => 'Copier la configuration (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuration copiée';

  @override
  String get provisioningQrGroup => 'Code QR';

  @override
  String get provisioningQrFooter =>
      'Scannez ce code sur un autre appareil pour copier un compte. Traitez-le comme un mot de passe s’il en contient un.';

  @override
  String get provisioningQrAccount => 'Compte';

  @override
  String get provisioningChoose => 'Choisir…';

  @override
  String get provisioningQrTooMuchData => 'Trop de données pour un code QR';

  @override
  String tlsClearField(String field) {
    return 'Effacer $field';
  }

  @override
  String get tlsChoose => 'Choisir…';

  @override
  String get tlsChange => 'Changer…';

  @override
  String get tlsClientCertTitle => 'Certificat client (TLS mutuel)';

  @override
  String get tlsIncomplete =>
      'Choisissez un certificat et sa clé privée. Le certificat n’est présenté que lorsque les deux sont définis.';

  @override
  String get tlsFooter =>
      'Pour les serveurs qui demandent à l’appli de s’identifier par un certificat. Fichiers PEM. Utilisé pour TLS et WebSocket sécurisé.';

  @override
  String get tlsCertFile => 'Fichier de certificat';

  @override
  String get tlsKeyFile => 'Fichier de clé privée';

  @override
  String get tlsKeyPassword => 'Mot de passe de la clé';

  @override
  String get tlsKeyPasswordHint => 'Uniquement si la clé est chiffrée';

  @override
  String get callSettingsHoldGroupTitle => 'Mise en attente';

  @override
  String get callSettingsHoldFooter =>
      'Avec « Défaut du PBX », l’appel est simplement mis en attente et votre système téléphonique peut jouer sa propre musique. Tout autre choix est joué à l’appelant par cette appli.';

  @override
  String get callSettingsHoldMusic => 'Musique d’attente';

  @override
  String get callSettingsHoldPbxDefault => 'Défaut du PBX';

  @override
  String get callSettingsHoldMusicVolume => 'Volume de la musique d’attente';

  @override
  String get callSettingsHoldAudioFiles => 'Fichiers audio';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Importer ou enregistrer une musique d’attente';

  @override
  String get callSettingsAnnounceTitle => 'Annonces';

  @override
  String get callSettingsAnnounceFooter =>
      'Les annonces sont jouées à l’interlocuteur. Tout est ignoré silencieusement si le fichier est absent.';

  @override
  String get callSettingsAnnounceOpening => 'Annonce d’accueil';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Jouer un message à la connexion d’un appel';

  @override
  String get callSettingsAnnounceFile => 'Fichier d’annonce';

  @override
  String get callSettingsAnnounceChooseFile => 'Choisir un fichier';

  @override
  String get callSettingsAnnouncePlayFor => 'Jouer pour';

  @override
  String get callSettingsAnnounceBoth => 'Entrants et sortants';

  @override
  String get callSettingsAnnounceIncoming => 'Appels entrants';

  @override
  String get callSettingsAnnounceOutgoing => 'Appels sortants';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Couper mon micro pendant la lecture';

  @override
  String get callSettingsAnnounceMonitor => 'Me la faire aussi entendre';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Avant le début de l’enregistrement, jouer';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Avant de transférer un appelant, jouer';

  @override
  String get morePageTitle => 'Plus';

  @override
  String get morePresence => 'Présence';

  @override
  String get morePresenceHint => 'Voyant d’occupation (BLF)';

  @override
  String get moreRetrieveParked => 'Récupérer un appel parqué';

  @override
  String get moreRetrieveParkedHint => 'Composer un emplacement de parcage';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint =>
      'Appareils à proximité, chat et dépôt de fichiers';

  @override
  String get moreRecordings => 'Enregistrements';

  @override
  String get moreRecordingsHint =>
      'Écouter, partager et gérer les enregistrements d’appels';

  @override
  String get moreVoicemail => 'Messagerie vocale';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux messages',
      one: '1 nouveau message',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Appeler votre messagerie vocale';

  @override
  String get moreDiagnostics => 'Diagnostics';

  @override
  String get moreDiagnosticsHint => 'Trace SIP et tests réseau';

  @override
  String get moreAbout => 'À propos';

  @override
  String get moreNoVoicemailNumber =>
      'Aucun numéro de messagerie vocale n’est défini. Ajoutez-en un dans les réglages du compte.';

  @override
  String get moreSearchHint =>
      'Rechercher un contact, l’historique ou saisir un numéro';

  @override
  String moreCallNumber(String number) {
    return 'Appeler $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Verrouillage de l’appli';

  @override
  String get appLockFooter =>
      'Les appels sonnent toujours et peuvent être décrochés lorsque l’appli est verrouillée.';

  @override
  String get appLockRequirePin => 'Exiger un code PIN pour ouvrir l’appli';

  @override
  String get appLockOnHint =>
      'L’historique, les contacts, les messages et les réglages sont verrouillés';

  @override
  String get appLockIsOn => 'Verrouillage de l’appli activé';

  @override
  String get appLockIsOff => 'Verrouillage de l’appli désactivé';

  @override
  String get appLockTurnOff => 'Désactiver le verrouillage';

  @override
  String get appLockChangePin => 'Changer le code PIN';

  @override
  String get appLockEnterCurrent => 'Saisissez le code PIN actuel';

  @override
  String get appLockPinChanged => 'Code PIN modifié';

  @override
  String get appLockLockAfter => 'Verrouiller après';

  @override
  String get appLockLockAfterHint =>
      'Durée en arrière-plan avant que le code PIN soit à nouveau demandé';

  @override
  String get appLockImmediately => 'Immédiatement';

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
  String get appLockHour => '1 heure';

  @override
  String get appLockBiometrics => 'Déverrouiller par biométrie';

  @override
  String get appLockNow => 'Verrouiller maintenant';

  @override
  String get appLockSetPin => 'Définir un code PIN';

  @override
  String get appLockPinDigits => 'Code PIN (4 à 8 chiffres)';

  @override
  String get appLockRepeatPin => 'Répéter le code PIN';

  @override
  String get appLockUseDigits => 'Utilisez 4 à 8 chiffres';

  @override
  String get appLockMismatch => 'Les codes PIN ne correspondent pas';

  @override
  String get appLockPin => 'Code PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Trop de tentatives. Réessayez dans $seconds s';
  }

  @override
  String get appLockWrongPin => 'Code PIN incorrect';

  @override
  String get appLockTooMany => 'Trop de tentatives';

  @override
  String get appLockIsLocked => 'SoftphonePro est verrouillé';

  @override
  String get appLockEnterPin => 'Saisissez votre code PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Réessayez dans $time';
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
  String get appLockUnlock => 'Déverrouiller';

  @override
  String get appLockIncomingCall => 'Appel entrant';

  @override
  String get appLockDecline => 'Refuser';

  @override
  String get appLockAnswer => 'Répondre';

  @override
  String get appLockHangUp => 'Raccrocher';

  @override
  String get appLockBiometricReason => 'Déverrouiller SoftphonePro';

  @override
  String get automationNoToken =>
      'Aucun jeton d’accès défini. Générez-en un dans Réglages > Avancé.';

  @override
  String automationInvalidPort(int port) {
    return 'Port $port non valide';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Démarrage impossible : $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'Le port $port n’est pas disponible ($error). Choisissez un autre port.';
  }

  @override
  String get automationTokenPlaceholder => 'Créé à l’activation de l’API';

  @override
  String automationListening(String address) {
    return 'À l’écoute sur $address';
  }

  @override
  String get automationStarting => 'Démarrage…';

  @override
  String get automationTitle => 'API d’automatisation locale';

  @override
  String get automationFooter =>
      'Pour les intégrations CRM et helpdesk sur cet ordinateur. Elle n’écoute que sur 127.0.0.1 et chaque requête nécessite le jeton d’accès. Voir docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Activer l’API d’automatisation locale';

  @override
  String get automationPort => 'Port';

  @override
  String get automationPortHint =>
      '7771 par défaut. Choisissez un port libre entre 1024 et 65535.';

  @override
  String get automationPortInvalid => 'Saisissez un port de 1024 à 65535';

  @override
  String get automationAccessToken => 'Jeton d’accès';

  @override
  String get automationHideToken => 'Masquer le jeton';

  @override
  String get automationShowToken => 'Afficher le jeton';

  @override
  String get automationCopyToken => 'Copier le jeton';

  @override
  String get automationTokenCopied => 'Jeton copié';

  @override
  String get automationGenerateToken => 'Générer un nouveau jeton';

  @override
  String get automationGenerateTitle => 'Générer un nouveau jeton ?';

  @override
  String get automationGenerateBody =>
      'Les programmes utilisant l’ancien jeton cessent de fonctionner tant que vous ne leur donnez pas le nouveau.';

  @override
  String get automationGenerate => 'Générer';

  @override
  String get automationOrigins => 'Origines de navigateur autorisées';

  @override
  String get automationOriginsHint =>
      'Séparées par des virgules, par exemple https://crm.example.com. Les programmes sans navigateur (curl, scripts) n’en ont pas besoin.';

  @override
  String automationNotOrigin(String origin) {
    return 'Ce n’est pas une origine http(s) : $origin';
  }

  @override
  String get trayNotificationAnswer => 'Répondre';

  @override
  String get trayNotificationDecline => 'Refuser';

  @override
  String get trayTooltipInCall => 'SoftphonePro - en appel';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nouveau(x)';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - aucun compte (Absent)',
      'dnd': 'SoftphonePro - aucun compte (Ne pas déranger)',
      'other': 'SoftphonePro - aucun compte',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total en ligne (Absent)',
      'dnd': 'SoftphonePro - $online/$total en ligne (Ne pas déranger)',
      'other': 'SoftphonePro - $online/$total en ligne',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Masquer SoftphonePro';

  @override
  String get trayShowApp => 'Afficher SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nouveau(x) - ouvrir les récents';
  }

  @override
  String get trayStatus => 'Statut';

  @override
  String get trayStatusAway => 'Absent';

  @override
  String get trayAccounts => 'Comptes';

  @override
  String get trayQuit => 'Quitter SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Répondre à l’appel';

  @override
  String get hotkeyHangUp => 'Raccrocher';

  @override
  String get hotkeyMute => 'Muet / réactiver le son';

  @override
  String get hotkeyFocusDialer => 'Activer le clavier';

  @override
  String get shortcutsGlobalTitle => 'Raccourcis globaux';

  @override
  String get shortcutsGlobalFooter =>
      'Fonctionnent depuis n’importe quelle application. Un autre programme utilisant déjà une combinaison peut empêcher son enregistrement.';

  @override
  String get shortcutsChange => 'Modifier';

  @override
  String get shortcutsRestoreDefaults => 'Rétablir les valeurs par défaut';

  @override
  String get shortcutsMediaTitle => 'Casque et touches multimédia';

  @override
  String get shortcutsMediaFooter =>
      'Le bouton lecture/pause d’un casque ou d’un clavier n’est capté que lorsqu’un appel sonne ou est en cours, afin que les lecteurs de musique le conservent le reste du temps.';

  @override
  String get shortcutsMediaSwitch =>
      'Répondre et raccrocher avec le bouton lecture/pause du casque ou multimédia';

  @override
  String get shortcutsMediaDuringCall => 'Pendant un appel, le bouton';

  @override
  String get shortcutsMediaHangsUp => 'Raccroche';

  @override
  String get shortcutsMediaMutes => 'Coupe / réactive le micro';

  @override
  String get shortcutsInApp => 'Dans l’appli';

  @override
  String get shortcutsFocusDialer => 'Activer le clavier';

  @override
  String get shortcutsHoldResume => 'Attente / reprise';

  @override
  String get shortcutsTransfer => 'Transférer';

  @override
  String get shortcutsEndCall => 'Terminer l’appel';

  @override
  String get shortcutsNeedX11 =>
      'Les raccourcis globaux nécessitent une session X11. Wayland nautorise pas les applications à capter les touches à léchelle du système.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Ajoutez Ctrl, Alt, Maj ou $key à une lettre ou un chiffre';
  }

  @override
  String get shortcutsPressNew =>
      'Appuyez sur la nouvelle combinaison de touches';

  @override
  String get defaultHandlerChooseInSettings =>
      'Choisissez SoftphonePro pour SIP, TEL et CALLTO dans Applications par défaut';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro ouvre désormais les liens sip:, tel: et callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Impossible de modifier l’application par défaut pour $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Ouvre les liens sip:, tel: et callto: depuis les navigateurs et autres applis';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro gère les liens sip:, tel: et callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Actuellement : $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Définir SoftphonePro comme appli par défaut pour les liens sip:, tel: et callto:';

  @override
  String get reliabilityTitle => 'Fiabilité en arrière-plan';

  @override
  String get reliabilityMicrophone => 'Microphone';

  @override
  String get reliabilityAllowed => 'Autorisé';

  @override
  String get reliabilityMicNeeded =>
      'Nécessaire pour parler pendant les appels';

  @override
  String get reliabilityNotifications => 'Notifications';

  @override
  String get reliabilityNotifNeeded =>
      'Nécessaires pour afficher les appels entrants et garder le service visible';

  @override
  String get reliabilityFullScreen => 'Appels entrants en plein écran';

  @override
  String get reliabilityFullScreenNeeded =>
      'Autorisez pour que les appels s’affichent sur l’écran de verrouillage';

  @override
  String get reliabilityBattery =>
      'Utilisation de la batterie sans restriction';

  @override
  String get reliabilityBatteryExempt =>
      'Exclu de l’optimisation de la batterie';

  @override
  String get reliabilityBatteryNeeded =>
      'Android peut suspendre l’appli et manquer des appels pour économiser l’énergie. Touchez pour exclure SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'Démarrage automatique / applis protégées $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'Le fabricant de votre téléphone peut fermer les applis en arrière-plan. Autorisez le démarrage automatique de SoftphonePro.';

  @override
  String get reliabilityBoot => 'Démarrer au lancement du téléphone';

  @override
  String get reliabilityBootHint =>
      'Enregistrer les comptes après le redémarrage du téléphone';

  @override
  String get reliabilityWake => 'Garder le processeur actif en veille';

  @override
  String get reliabilityWakeHint =>
      'Plus fiable sur les appareils restrictifs ; consomme plus de batterie';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Retirer $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Dernière erreur : $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Plage autorisée : $min à $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Doit être au moins $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Doit être au plus $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Abandonner les modifications ?';

  @override
  String get acctEditorDiscardMessage =>
      'Vos modifications de ce compte ne sont pas enregistrées.';

  @override
  String get acctEditorDiscardConfirm => 'Abandonner';

  @override
  String get acctEditorDeleteMessage =>
      'Le compte et son mot de passe enregistré seront supprimés de cet appareil.';

  @override
  String get acctEditorMenuDelete => 'Supprimer le compte';

  @override
  String get acctGroupBasic => 'Général';

  @override
  String get acctFieldLabel => 'Libellé';

  @override
  String get acctFieldLabelHint => 'p. ex. Bureau';

  @override
  String get acctFieldDisplayName => 'Nom affiché';

  @override
  String get acctFieldUsername => 'Nom d’utilisateur';

  @override
  String get acctFieldProtocol => 'Protocole';

  @override
  String get acctFieldProtocolSub => 'Fixé à la création du compte';

  @override
  String get acctFieldAuthUser => 'Utilisateur d’autorisation';

  @override
  String get acctFieldAuthUserHint => 'Identique au nom d’utilisateur';

  @override
  String get acctFieldAuthUserSub =>
      'Uniquement si le fournisseur utilise un identifiant différent du nom d’utilisateur';

  @override
  String get acctFieldPassword => 'Mot de passe';

  @override
  String get acctFieldServerHost => 'Hôte du serveur';

  @override
  String get acctFieldPort => 'Port';

  @override
  String get acctFieldIaxPortSub => 'Valeur par défaut IAX2 : 4569';

  @override
  String get acctFieldIaxContext => 'Contexte';

  @override
  String get acctFieldIaxContextSub =>
      'Facultatif. Envoyé au PBX comme contexte appelé';

  @override
  String get acctFieldServerDomain => 'Serveur / domaine';

  @override
  String get acctFieldServerDomainSub => 'hôte ou hôte:port';

  @override
  String get acctFieldEnabled => 'Activé';

  @override
  String get acctFieldDefault => 'Compte par défaut pour les appels sortants';

  @override
  String get acctFieldColour => 'Couleur';

  @override
  String get acctGroupRegistration => 'Enregistrement';

  @override
  String get acctFieldRegister => 'S’enregistrer';

  @override
  String get acctFieldRegisterSubIax =>
      'Désactivez pour les pairs qui n’exigent pas d’enregistrement';

  @override
  String get acctFieldRegExpiry => 'Expiration de l’enregistrement (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk impose généralement 60 s. Plage de 10 à 86400';

  @override
  String get acctFieldRetryInterval => 'Intervalle de nouvelle tentative (s)';

  @override
  String get acctFieldFirstRetry => 'Première nouvelle tentative (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 prend en charge G.711 et GSM. Faites glisser pour définir l’ordre de préférence.';

  @override
  String get acctCodecAdd => 'Ajouter un codec';

  @override
  String get acctGroupServerTransport => 'Serveur et transport';

  @override
  String get acctFieldRegistrar => 'Registrar spécifique';

  @override
  String get acctFieldBackupRegistrar => 'Registrar de secours';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Utilisé après 3 échecs ; le principal est retenté toutes les 5 minutes';

  @override
  String get acctFieldProxies => 'Proxys sortants';

  @override
  String get acctFieldTransport => 'Transport';

  @override
  String get acctFieldTransportAutoSub =>
      'Interroge les enregistrements DNS SRV du serveur et choisit TLS, TCP ou UDP';

  @override
  String get acctTransportAuto => 'Automatique (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Chemin WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'Chemin HTTP de la mise à niveau WebSocket, p. ex. /ws. Doit commencer par « / »';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 à 3600 est courant. Plage de 10 à 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'Intervalle de keep-alive UDP. 0 le désactive. Plage de 0 à 3600';

  @override
  String get acctFieldLocalPort => 'Port SIP local';

  @override
  String get acctFieldLocalPortSub =>
      '0 utilise le transport partagé. Plage de 0 à 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Désactivez pour les trunks sans enregistrement';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Maintient un flux persistant à travers le NAT. Nécessite la prise en charge du serveur';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Utiliser STUN';

  @override
  String get acctFieldTurn => 'Relais TURN';

  @override
  String get acctFieldTurnServer => 'Serveur TURN';

  @override
  String get acctFieldTurnUsername => 'Nom d’utilisateur TURN';

  @override
  String get acctFieldTurnPassword => 'Mot de passe TURN';

  @override
  String get acctFieldContactRewrite => 'Réécrire l’en-tête Contact';

  @override
  String get acctFieldViaRewrite => 'Réécrire l’en-tête Via';

  @override
  String get acctFieldRewriteSub =>
      'Utilise l’adresse vue par le serveur. À laisser activé derrière un NAT';

  @override
  String get acctFieldSdpRewrite => 'Réécrire l’adresse SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'Remplace l’adresse média du SDP par l’adresse publique';

  @override
  String get acctFieldIpv6Sip => 'Signalisation IPv6';

  @override
  String get acctFieldIpv6Media => 'Média IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Média avancé';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'Les passerelles WebRTC nécessitent le multiplexage RTCP et le retour RTCP.';

  @override
  String get acctFieldRtcpMux => 'Multiplexage RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Envoyer RTP et RTCP sur un seul port (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Retour RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Proposer RTP/AVPF avec NACK. Nécessaire pour les serveurs WebRTC';

  @override
  String get acctGroupSecurity => 'Sécurité';

  @override
  String get acctFieldSrtp => 'Chiffrement des médias (SRTP)';

  @override
  String get acctOptOptional => 'Facultatif';

  @override
  String get acctOptRequired => 'Obligatoire';

  @override
  String get acctFieldKeyExchange => 'Échange de clés';

  @override
  String get acctFieldSecureSignaling => 'Signalisation sécurisée';

  @override
  String get acctOptNotRequired => 'Non requise';

  @override
  String get acctOptTlsHop => 'TLS saut par saut';

  @override
  String get acctOptTlsE2e => 'TLS de bout en bout (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Algorithme d’authentification';

  @override
  String get acctFieldPrivacy => 'Masquer mon numéro (confidentialité)';

  @override
  String get acctFieldReferPolicy => 'Transferts entrants (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Observateurs de présence';

  @override
  String get acctOptAccept => 'Accepter';

  @override
  String get acctOptReject => 'Rejeter';

  @override
  String get acctGroupCodecsFooter =>
      'Remplace la liste globale des codecs pour ce compte.';

  @override
  String get acctFieldUseGlobalCodecs => 'Utiliser l’ordre global des codecs';

  @override
  String get acctGroupFeatures => 'Fonctionnalités';

  @override
  String get acctFieldVoicemailNumber => 'Numéro de messagerie vocale';

  @override
  String get acctFieldMwi => 'Indicateur de messagerie vocale (MWI)';

  @override
  String get acctFieldMwiSub =>
      'S’abonner aux notifications de message en attente';

  @override
  String get acctFieldPublishPresence => 'Publier ma présence';

  @override
  String get acctFieldPublishPresenceSub =>
      'Laisser le serveur partager votre statut en ligne';

  @override
  String get acctFieldDnd => 'Ne pas déranger';

  @override
  String get acctFieldForwarding => 'Renvoi d’appel';

  @override
  String get acctOptForwardAlways => 'Toujours';

  @override
  String get acctOptForwardBusy => 'Si occupé';

  @override
  String get acctOptForwardNoAnswer => 'Sans réponse';

  @override
  String get acctFieldForwardTo => 'Renvoyer vers';

  @override
  String get acctFieldForwardToHint => 'Numéro ou adresse SIP';

  @override
  String get acctFieldRingFor => 'Sonner pendant (s)';

  @override
  String get acctFieldAutoAnswer => 'Réponse automatique';

  @override
  String get acctFieldAnswerAfter => 'Répondre après (s)';

  @override
  String get acctFieldIntercomOnly => 'Uniquement pour les appels interphone';

  @override
  String get acctFieldIntercomOnlySub =>
      'Nécessite un en-tête de réponse automatique du PBX';

  @override
  String get acctFieldRingtone => 'Sonnerie';

  @override
  String get acctRingtoneClassic => 'Classique';

  @override
  String get acctRingtoneSoft => 'Douce';

  @override
  String get acctRingtoneDigital => 'Numérique';

  @override
  String get acctFieldRecordCalls => 'Enregistrer les appels';

  @override
  String get acctFieldHoldMusic => 'Musique d’attente';

  @override
  String get acctOptUseGlobal => 'Utiliser le réglage global';

  @override
  String get acctOptPbxDefault => 'Défaut du PBX';

  @override
  String get acctFieldOpeningAnnouncement => 'Annonce d’accueil';

  @override
  String get acctGroupFeatureCodes => 'Codes service';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Composés pour le parcage, l’interception, NPD et le renvoi sur votre PBX.';

  @override
  String get acctFieldPark => 'Parcage';

  @override
  String get acctFieldGroupPickup => 'Interception de groupe';

  @override
  String get acctFieldDirectedPickup => 'Préfixe d’interception ciblée';

  @override
  String get acctFieldParkRetrieve => 'Préfixe de récupération de parcage';

  @override
  String get acctFieldParkRetrieveHint => 'Composez le numéro d’emplacement';

  @override
  String get acctFieldParkRetrieveSub =>
      'Préfixe composé avant l’emplacement de parcage pour reprendre un appel parqué';

  @override
  String get acctFieldDndOn => 'NPD activé';

  @override
  String get acctFieldDndOff => 'NPD désactivé';

  @override
  String get acctFieldForwardOn => 'Renvoi activé';

  @override
  String get acctFieldForwardOff => 'Renvoi désactivé';

  @override
  String get acctGroupAdvanced => 'Avancé';

  @override
  String get acctGroupAdvancedFooterIax =>
      'Les DTMF sont envoyés sous forme de trames IAX2 natives.';

  @override
  String get acctFieldCallerIdOverride => 'Identifiant appelant spécifique';

  @override
  String get acctFieldCallerIdHint => 'Utiliser le défaut du compte';

  @override
  String get acctFieldCallerIdSub =>
      'Nom ou numéro d’identification de l’appelant envoyé au PBX';

  @override
  String get acctFieldSessionTimers => 'Temporisateurs de session';

  @override
  String get acctFieldSessionExpires => 'Expiration de session (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Plage de 90 à 86400';

  @override
  String get acctField100rel => '100rel (provisoire fiable)';

  @override
  String get acctFieldHoldMethod => 'Méthode de mise en attente';

  @override
  String get acctFieldDtmfMethod => 'Méthode DTMF';

  @override
  String get acctOptDtmfInband => 'Dans la bande';

  @override
  String get acctFieldRedirects => 'Redirections (3xx)';

  @override
  String get acctOptRedirectFollow => 'Suivre';

  @override
  String get acctOptRedirectAsk => 'Demander';

  @override
  String get acctFieldLockCodec => 'Verrouiller le codec après réponse';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive média';

  @override
  String get acctFieldDropCalls =>
      'Interrompre les appels si l’enregistrement échoue';

  @override
  String get acctFieldExtraHeaders => 'En-têtes SIP supplémentaires';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: valeur (un par ligne)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Délai avant de retenter un enregistrement échoué. Plage de 0 à 86400';

  @override
  String get acctFieldUnregTimeout => 'Délai de désenregistrement (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Durée d’attente de la réponse de désenregistrement. Plage de 0 à 60000';

  @override
  String get acctFieldMwiExpiry => 'Expiration de l’abonnement MWI (s)';

  @override
  String get acctFieldDscpSip => 'DSCP pour SIP';

  @override
  String get acctFieldDscpSipSub =>
      'Marquage QoS de la signalisation. 24 (CS3) est courant';

  @override
  String get acctFieldDscpRtp => 'DSCP pour RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'Marquage QoS des médias. 46 (EF) est courant';

  @override
  String get acctFieldReinvite => 'Re-INVITE après changement de réseau';

  @override
  String get acctFieldHangupOnIpChange =>
      'Raccrocher les appels lors d’un changement de réseau';

  @override
  String get acctValidateInt => 'Saisissez un nombre entier';

  @override
  String get acctValidateHostEmpty =>
      'Saisissez un nom d’hôte ou une adresse de serveur';

  @override
  String get acctValidateHostSpaces =>
      'Le serveur ne peut pas contenir d’espaces';

  @override
  String get acctValidateHostFormat => 'Saisissez uniquement hôte ou hôte:port';

  @override
  String get acctValidatePortRange =>
      'Le port doit être compris entre 1 et 65535';

  @override
  String get acctValidateWsStart => 'Le chemin doit commencer par « / »';

  @override
  String get acctValidateWsLength => 'Utilisez 120 caractères au maximum';

  @override
  String get acctValidateWsSpaces => 'Le chemin ne peut pas contenir d’espaces';

  @override
  String get acctTplAsteriskDescription =>
      'Poste sur votre propre PBX. UDP 5060, STUN activé.';

  @override
  String get acctTplAsteriskNotes =>
      'Utilisez le numéro de poste PJSIP/SIP et son secret. Pour TLS ou WebRTC, modifiez le transport plus tard dans les réglages du compte.';

  @override
  String get acctTplAsteriskUsernameHint => 'Poste (p. ex. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Utilisez le poste, l’ID d’authentification et le mot de passe du portail 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'Dans 3CX, ouvrez le poste, puis « Téléphones > Provisionnement » pour l’ID d’authentification (à saisir comme utilisateur d’autorisation) et le mot de passe. Le FQDN est celui de votre URL 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Poste';

  @override
  String get acctTplFreeswitchDescription =>
      'Utilisateur de l’annuaire d’un serveur FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Utilisez l’identifiant utilisateur et le mot de passe de l’annuaire. Le profil interne par défaut écoute sur UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID utilisateur';

  @override
  String get acctTplKamailioDescription =>
      'Registrar proxy SIP. TCP recommandé derrière un NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Utilisez le domaine SIP desservi par votre registrar. Ajoutez un proxy sortant dans les réglages du compte si le registrar est joint via un autre hôte.';

  @override
  String get acctTplTwilioDescription =>
      'Identifiants du domaine SIP Programmable Voice. TLS et SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Créez un domaine SIP dans la console Twilio, ajoutez une liste d’identifiants et activez l’enregistrement SIP. Saisissez le domaine complet (name.sip.twilio.com) comme serveur, et l’utilisateur et le mot de passe de la liste d’identifiants. TLS utilise le port 5061. Twilio ne prend en charge que G.711.';

  @override
  String get acctTplTwilioUsernameHint =>
      'Utilisateur de la liste d’identifiants';

  @override
  String get acctTplTelnyxDescription =>
      'Connexion par identifiants. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Créez une Credential Connection dans le portail Telnyx et copiez son nom d’utilisateur SIP et son mot de passe (pas vos identifiants du portail). Associez un numéro ou un profil vocal sortant à la connexion pour passer et recevoir des appels.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'Nom d’utilisateur SIP (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Nom d’utilisateur et mot de passe du sous-compte. Choisissez le POP le plus proche.';

  @override
  String get acctTplVoipmsNotes =>
      'Utilisez un sous-compte créé sous Sub Accounts, pas votre compte principal. Choisissez le serveur (POP) le plus proche dans la liste des serveurs VoIP.ms et autorisez-le pour votre IP si nécessaire.';

  @override
  String get acctTplVoipmsUsernameHint => 'Sous-compte (p. ex. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'Enregistrement SIP avec TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business ne propose l’enregistrement SIP que sur certaines offres. Saisissez le serveur SIP, l’utilisateur et le mot de passe indiqués dans le portail d’administration Vonage pour l’appareil.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange sur UDP 4569. Pas de réglages NAT ni SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Nécessite un pair/utilisateur dans iax.conf (type=friend ou user+peer) avec le même secret. Asterisk renouvelle les enregistrements IAX2 toutes les 60 s par défaut. Le contexte est facultatif et envoyé comme contexte appelé.';

  @override
  String get acctTplIax2UsernameHint => 'Nom d’utilisateur IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP sur WebSocket sécurisé avec DTLS-SRTP, ICE et RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Pour les points de terminaison WebSocket Asterisk (webrtc=yes, TLS http.conf sur 8089), FreeSWITCH ou Kamailio. Le serveur nécessite un certificat TLS valide. Modifiez le chemin WebSocket dans les réglages du compte si votre passerelle n’utilise pas /ws.';

  @override
  String get acctTplGenericDescription =>
      'N’importe quel registrar SIP. Renseignez les détails vous-même.';

  @override
  String get acctTplDefaultUsernameHint => 'Poste / nom d’utilisateur';

  @override
  String get appEngineFailedBody =>
      'Les appels et l’enregistrement ne fonctionneront pas tant que ce problème n’est pas résolu. Un réglage réseau ou de certificat erroné en est la cause habituelle.';

  @override
  String get appEngineFailedTitle => 'Impossible de démarrer le moteur d’appel';

  @override
  String get appEngineNotRunning =>
      'Le moteur d’appel n’est pas en cours d’exécution';

  @override
  String get appUnknownError => 'Erreur inconnue';

  @override
  String get appEngineOpenNetworkSettings => 'Ouvrir les réglages réseau';

  @override
  String get appEngineUseSimulator => 'Utiliser le simulateur (démo)';

  @override
  String get appDbLockedTitle => 'Vos données sont verrouillées';

  @override
  String get appDbUnreadableTitle => 'Impossible d’ouvrir vos données';

  @override
  String get appDbLockedBody =>
      'L’historique des appels, les contacts et les messages sont chiffrés sur cet appareil, mais la clé de chiffrement n’est plus dans le trousseau / coffre du système (par exemple après une réinitialisation du trousseau ou une restauration sur un nouvel appareil).';

  @override
  String get appDbUnreadableBody =>
      'La base de données locale n’a pas pu être lue. Elle est peut-être endommagée, ou la clé de chiffrement ne correspond pas.';

  @override
  String get appDbRecoveryAdvice =>
      'Réessayez si vous pensez que la clé va revenir (déverrouillez le trousseau, connectez-vous au bon utilisateur). Repartir de zéro conserve l’ancien fichier à côté des données de l’appli, mais démarre avec un historique, des contacts et des messages vides ; vous devrez rajouter vos comptes.';

  @override
  String get appDbCopyDetails => 'Copier les détails';

  @override
  String get appDbTryAgain => 'Réessayer';

  @override
  String get appDbStartFresh => 'Repartir de zéro';

  @override
  String get appRedirectTitle => 'Appel redirigé';

  @override
  String appRedirectMessage(String target) {
    return 'Appel redirigé vers $target - suivre ?';
  }

  @override
  String get appRedirectCancelCall => 'Annuler l’appel';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Impossible de chiffrer vos données ($error). Rien n’a été modifié.',
      'other':
          'Impossible de déchiffrer vos données ($error). Rien n’a été modifié.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Moteur natif indisponible ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Nouvelle tentative à $time';
  }

  @override
  String get acctRegistrationError => 'Erreur d’enregistrement';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nTransport : $transport';
  }

  @override
  String get acctCallingFromDirect => 'Appel direct, sans compte';

  @override
  String acctCallingFromAccount(String name) {
    return 'Appel depuis $name';
  }

  @override
  String get acctCallingFromNone => 'Appel depuis aucun compte';

  @override
  String get acctNoAccount => 'Aucun compte';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nouveau(x), $oldCount ancien(s)';
  }

  @override
  String get acctAddAccount => 'Ajouter un compte';

  @override
  String get acctUnregister => 'Se désenregistrer';

  @override
  String get acctSheetDndSub => 'Rejeter les appels entrants sur ce compte';

  @override
  String get acctKvServer => 'Serveur';

  @override
  String get acctKvResolvedServer => 'Serveur résolu';

  @override
  String get acctKvClientCert => 'Certificat client';

  @override
  String get acctKvClientCertValue => 'Présenté au serveur (TLS mutuel)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Expire dans';

  @override
  String get acctKvVoicemail => 'Messagerie vocale';

  @override
  String get acctOpenSipTrace => 'Ouvrir la trace SIP';

  @override
  String get acctAddAnAccount => 'Ajouter un compte';

  @override
  String get acctChooseAccountTooltip => 'Choisir le compte d’où appeler';

  @override
  String get acctDirectNoAccount => 'Direct (sans compte)';

  @override
  String get onboardingRequired =>
      'Le nom d’utilisateur et le serveur sont obligatoires';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Le port $port est utilisé sauf si vous ajoutez :port';
  }

  @override
  String get onboardingFineTuneIax =>
      'Vous pourrez affiner les codecs et l’enregistrement plus tard dans les Réglages.';

  @override
  String get onboardingFineTuneSip =>
      'Vous pourrez affiner le transport, le NAT, la sécurité et les codecs plus tard dans les Réglages.';

  @override
  String get onboardingDemoUser => 'Utilisateur démo';

  @override
  String get onboardingDemoAccount => 'Compte démo';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'La téléphonie professionnelle pour toutes les plateformes - gratuite et open source. Sans publicité, sans suivi.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingPermissionsTitle => 'Autorisations';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro a besoin du microphone pour transmettre votre voix, et des notifications pour vous signaler les appels et messages entrants. Rien ne quitte votre appareil, à part vos appels.';

  @override
  String get onboardingChooseProvider => 'Choisissez votre fournisseur';

  @override
  String get onboardingChooseProviderSub =>
      'Nous préremplissons le transport, les ports et les réglages NAT pour vous.';

  @override
  String get onboardingScanQr => 'Scanner un QR';

  @override
  String get onboardingImportUrl => 'Importer depuis une URL';

  @override
  String get onboardingSkip => 'Passer pour l’instant (mode démo)';

  @override
  String get onboardingHidePassword => 'Masquer le mot de passe';

  @override
  String get onboardingShowPassword => 'Afficher le mot de passe';

  @override
  String get onboardingContextOptional => 'Contexte (facultatif)';

  @override
  String get onboardingDisplayNameOptional => 'Nom affiché (facultatif)';

  @override
  String get onboardingLabelOptional => 'Libellé du compte (facultatif)';

  @override
  String get onboardingCallerIdOptional => 'Identifiant appelant (facultatif)';

  @override
  String get onboardingAuthUserOptional =>
      'Utilisateur d’autorisation (si différent)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Nom d’utilisateur ou mot de passe incorrect ($code)';
  }

  @override
  String get acctRegNotFound => 'Compte introuvable sur le serveur (404)';

  @override
  String get acctRegNoAnswer => 'Le serveur n’a pas répondu (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Intervalle d’enregistrement trop court (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Serveur temporairement indisponible (480)';

  @override
  String get acctRegServiceUnavailable => 'Service indisponible (503)';

  @override
  String get acctRegFailed => 'Échec de l’enregistrement';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Échec de l’enregistrement ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Impossible de modifier l’enregistrement';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Impossible d’appliquer le compte « $name »';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Retour sur le serveur principal pour $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Serveur de secours utilisé pour $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'Le compte $name est enregistré';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'Le compte $name est encore en cours d’enregistrement';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'Le compte $name n’est pas encore enregistré';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'Le compte $name n’est pas enregistré (échec de l’enregistrement)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'Le compte $name est désactivé';
  }

  @override
  String get callDialEngineFailed => 'Le moteur d’appel n’a pas pu démarrer';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'Le moteur d’appel n’a pas pu démarrer : $reason';
  }

  @override
  String get callDialEngineStarting =>
      'Le moteur d’appel est encore en cours de démarrage';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status : $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status après $seconds s ; l’appel n’a pas été passé';
  }

  @override
  String get callJournalInterrupted => 'L’appli a été fermée pendant l’appel';

  @override
  String get callLinkMissingArgument => 'Argument manquant';

  @override
  String get callLinkHttpsRequired =>
      'Les liens de configuration doivent utiliser https';

  @override
  String get callLinkInvalidLan => 'Ce lien LAN n’est pas valide';

  @override
  String callLinkConnectedTo(String name) {
    return 'Connecté à $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Impossible de se connecter à cet appareil';

  @override
  String callLinkCallFailed(String target) {
    return 'Impossible de passer l’appel vers $target';
  }

  @override
  String get callLinkImportTitle => 'Importer la configuration';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts comptes',
      one: '1 compte',
    );
    return 'Importer la configuration depuis $host ? Cela ajoutera $_temp0.';
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
      other: '$accounts comptes',
      one: '1 compte',
    );
    return 'Importer la configuration depuis $host ? Cela ajoutera $_temp0 et $settings réglage(s).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Renvoyé depuis $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Renvoyé depuis $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Transféré par $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Par défaut du système';

  @override
  String get callRingtoneClassic => 'Classique';

  @override
  String get callRingtoneSoft => 'Douce';

  @override
  String get callRingtoneDigital => 'Numérique';

  @override
  String callIdentityFrom(String number) {
    return 'De $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Appelant $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Appelant $name $number';
  }

  @override
  String get callTransferring => 'Transfert en cours…';

  @override
  String get callTransferNotConfirmed =>
      'Transfert non confirmé par le serveur';

  @override
  String get callTransferStalledHint =>
      'L’appel est toujours en cours. Conservez-le ou renvoyez le transfert.';

  @override
  String get callTransferKeepCall => 'Garder l’appel';

  @override
  String get callAnnouncementOpening => 'Lecture de l’annonce…';

  @override
  String get callAnnouncementTransfer => 'Lecture de l’avis de transfert…';

  @override
  String get callAnnouncementRecording => 'Lecture de l’avis d’enregistrement…';

  @override
  String get callAnnouncementSkip => 'Passer';

  @override
  String get callNoiseTooltipMic =>
      'Réduction de bruit par IA : votre microphone';

  @override
  String get callNoiseTooltipIncoming =>
      'Réduction de bruit par IA : les autres participants';

  @override
  String get callNoiseTooltipBoth =>
      'Réduction de bruit par IA : votre microphone et les autres participants';

  @override
  String get callNoiseOn => 'Réduction de bruit active';

  @override
  String get callNoiseTitle => 'Réduction de bruit';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Mon microphone : $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Supprimer le bruit de fond de mon microphone';

  @override
  String get callResultAnswered => 'Répondu';

  @override
  String get callResultMissed => 'Manqué';

  @override
  String get callResultRejected => 'Refusé';

  @override
  String get callResultFailed => 'Échoué';

  @override
  String get callResultBusy => 'Occupé';

  @override
  String get callResultForwarded => 'Renvoyé';

  @override
  String get callResultTransferred => 'Transféré';

  @override
  String get callResultHandedOff => 'Basculé';

  @override
  String get callResultInterrupted => 'Interrompu';

  @override
  String get keypadCall => 'Appeler';

  @override
  String get keypadNoVoicemail =>
      'Aucun numéro de messagerie vocale configuré pour ce compte';

  @override
  String get keypadCallDirectly => 'Appel direct (sans compte)';

  @override
  String get keypadAddAccount => 'Ajoutez un compte pour passer des appels';

  @override
  String keypadCallFrom(String account) {
    return 'Appeler depuis $account';
  }

  @override
  String get keypadRecent => 'Récents';

  @override
  String get keypadSuggestions => 'Suggestions';

  @override
  String get keypadPhoneNumber => 'Numéro de téléphone';

  @override
  String get keypadPaste => 'Coller';

  @override
  String get keypadEnterNumber => 'Saisir un numéro';

  @override
  String get keypadBackspace => 'Effacer (appui long pour tout effacer)';

  @override
  String get keypadTypeNameOrNumber => 'Saisissez un nom ou un numéro';

  @override
  String get keypadNoMatches => 'Aucun résultat';

  @override
  String get keypadSuggestionsHint =>
      'Les suggestions proviennent des contacts et des appels récents';

  @override
  String keypadCallPerson(String name) {
    return 'Appeler $name';
  }

  @override
  String get dialKeyStar => 'Étoile';

  @override
  String get dialKeyPound => 'Dièse';

  @override
  String get dialKeyLongPressPlus => 'Appui long pour le signe plus';

  @override
  String get dialKeyLongPressSpeedDial =>
      'Appui long pour la numérotation abrégée';

  @override
  String get dialKeyLongPressVoicemail =>
      'Appui long pour la messagerie vocale';

  @override
  String get callBackToApp => 'Retour à l’appli (l’appel reste actif)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Masquer le clavier';

  @override
  String get callMute => 'Muet';

  @override
  String get callKeypad => 'Clavier';

  @override
  String get callSpeaker => 'Haut-parleur';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Casque';

  @override
  String get callResume => 'Reprendre';

  @override
  String get callHold => 'Attente';

  @override
  String get callAddCall => 'Ajouter un appel';

  @override
  String get callTransfer => 'Transférer';

  @override
  String get callStop => 'Arrêter';

  @override
  String get callRecord => 'Enregistrer';

  @override
  String get callSplit => 'Séparer';

  @override
  String get callMerge => 'Fusionner';

  @override
  String get callSwap => 'Alterner';

  @override
  String get callEndCall => 'Terminer l’appel';

  @override
  String callEndCallWith(String name) {
    return 'Terminer l’appel avec $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Transfert supervisé. L’appelant initial est en attente.';

  @override
  String get callCompleteTransfer => 'Finaliser le transfert';

  @override
  String get callWaiting => 'Double appel';

  @override
  String get callHoldAndAnswer =>
      'Mettre l’appel en cours en attente et répondre';

  @override
  String get callDecline => 'Refuser';

  @override
  String get callAnswer => 'Répondre';

  @override
  String get callIncomingCall => 'Appel entrant';

  @override
  String get callReply => 'Message';

  @override
  String get callVoicemail => 'Messagerie';

  @override
  String get callToDevice => 'Vers appareil';

  @override
  String get callQuickReplyBusy => 'Je ne peux pas parler, je vous rappelle.';

  @override
  String get callQuickReplyMeeting => 'Je suis en réunion. Un SMS ?';

  @override
  String get callQuickReplyOnMyWay => 'J’arrive.';

  @override
  String callReturnToCallWith(String name) {
    return 'Revenir à l’appel avec $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Entrant : $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'En appel avec $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Gigue';

  @override
  String get callStatsPacketLoss => 'Perte de paquets';

  @override
  String get callStatsRoundTrip => 'Aller-retour';

  @override
  String get callStatsMedia => 'Média';

  @override
  String get callStatsMosHistory => 'Historique MOS';

  @override
  String get callQualityTitle => 'Qualité de l’appel';

  @override
  String get callTransferTitle => 'Transférer l’appel';

  @override
  String get callTransferModeBlind => 'À l’aveugle';

  @override
  String get callTransferModeAttended => 'Supervisé';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Appareil LAN';

  @override
  String get callTransferNoLanDevices =>
      'Aucun appareil SoftphonePro associé trouvé sur votre réseau. Associez-en un depuis la page LAN.';

  @override
  String get callTransferLanDisabled =>
      'Activez LAN Link (Réglages, LAN Link) pour transférer cet appel vers un autre appareil de votre réseau.';

  @override
  String get callTransferTalkFirst => 'Parler d’abord';

  @override
  String get callTransferBlindHint =>
      'Transfère immédiatement l’appelant. Vous êtes déconnecté.';

  @override
  String get callTransferAttendedHint =>
      'Met l’appelant en attente et appelle d’abord la cible. Finalisez le transfert une fois qu’elle a répondu.';

  @override
  String get callTransferNumberLabel => 'Numéro ou adresse SIP';

  @override
  String get callTransferNow => 'Transférer maintenant';

  @override
  String get callTransferCallAndConsult => 'Appeler et consulter';

  @override
  String get callRetrieveParkedTitle => 'Récupérer un appel parqué';

  @override
  String get callRetrieveParkedHint => 'Emplacement de parcage, p. ex. 701';

  @override
  String get callMoreAudioOutput => 'Sortie audio';

  @override
  String get callMoreAudioDevices => 'Périphériques audio';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Téléphone, haut-parleur, Bluetooth, casque';

  @override
  String get callMoreAudioDevicesSubtitle =>
      'Choisir le microphone et le haut-parleur';

  @override
  String get callMoreParkCall => 'Parquer l’appel';

  @override
  String get callMoreParkCallSubtitle =>
      'Transférer vers le code service de parcage';

  @override
  String get callMoreRetrieveParkedSubtitle =>
      'Composer un emplacement de parcage';

  @override
  String get callMoreSendDtmf => 'Envoyer des chiffres DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Saisir toute une séquence, p. ex. un code PIN';

  @override
  String get callSendDtmfTitle => 'Envoyer des DTMF';

  @override
  String get callMoreCallInfo => 'Infos sur l’appel';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, gigue, pertes et temps d’aller-retour en direct';

  @override
  String get callMoreSipTrace => 'Trace SIP';

  @override
  String get callMoreSipTraceSubtitle => 'Diagramme en échelle de cet appel';

  @override
  String get callInfoRemote => 'Distant';

  @override
  String get callInfoAccount => 'Compte';

  @override
  String get callInfoState => 'État';

  @override
  String get callInfoSecure => 'Sécurisé';

  @override
  String get callInfoPlainSignalling => 'signalisation en clair';

  @override
  String get callRoutePhone => 'Téléphone';

  @override
  String get callRouteWiredHeadset => 'Casque filaire';

  @override
  String get callAudioMicrophone => 'Microphone';

  @override
  String callCardSemantics(String name, String state) {
    return 'Appel avec $name, $state';
  }

  @override
  String get callUnmute => 'Réactiver le micro';

  @override
  String get callStopRecording => 'Arrêter l’enregistrement';

  @override
  String get callSplitConference => 'Séparer la conférence';

  @override
  String get callMergeCalls => 'Fusionner les appels';

  @override
  String get callSwapCalls => 'Alterner les appels';

  @override
  String get callAttendedTransferBanner =>
      'Transfert supervisé : l’appelant initial est en attente.';

  @override
  String get callActiveCalls => 'Appels en cours';

  @override
  String get callConferenceLevels => 'Niveaux de la conférence';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Micro vers participant';

  @override
  String callPercentSemantics(int percent) {
    return '$percent pour cent';
  }

  @override
  String get callFailInvalidNumber => 'Numéro invalide (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Appel non autorisé ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Numéro introuvable (404)';

  @override
  String get callFailNoAnswerFromServer => 'Pas de réponse du serveur (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Temporairement indisponible (480)';

  @override
  String get callFailIncompleteNumber => 'Numéro incomplet (484)';

  @override
  String callFailBusy(String code) {
    return 'Occupé ($code)';
  }

  @override
  String get callFailCancelled => 'Appel annulé (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Aucun codec compatible ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Service indisponible (503)';

  @override
  String get callFailDeclined => 'Appel refusé (603)';

  @override
  String get callFailGeneric => 'Échec de l’appel';

  @override
  String callFailGenericWithCode(String code) {
    return 'Échec de l’appel ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Appel en cours';

  @override
  String get callTrayInCall => 'En appel';

  @override
  String get callHistoryBlocked => 'Bloqué';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonymat refusé';

  @override
  String get callHistoryDoNotDisturb => 'Ne pas déranger';

  @override
  String get callHistoryBusy => 'Occupé';

  @override
  String get callHistoryForwardedAlways => 'Renvoyé (toujours)';

  @override
  String get callHistoryForwardedBusy => 'Renvoyé (occupé)';

  @override
  String get callHistorySentToVoicemail => 'Envoyé à la messagerie vocale';

  @override
  String get callHistoryRedirected => 'Redirigé';

  @override
  String get callIncomingNotificationBody => 'Appel entrant';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Appel entrant sur $account';
  }

  @override
  String get callMissedNotificationTitle => 'Appel manqué';

  @override
  String get callErrEngineNotRunning =>
      'Le moteur d’appel n’est pas encore démarré';

  @override
  String get callErrAddAccount => 'Ajoutez un compte pour passer des appels';

  @override
  String get callErrCouldNotPlace => 'Impossible de passer l’appel';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account n’est pas enregistré';
  }

  @override
  String get callErrCouldNotAnswer => 'Impossible de répondre';

  @override
  String get callErrNoVoicemailNumber =>
      'Aucun numéro de messagerie vocale défini pour ce compte';

  @override
  String get callErrTransferFailed => 'Échec du transfert';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Échec du transfert : $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Impossible de fusionner les appels';

  @override
  String get callErrCouldNotStartRecording =>
      'Impossible de démarrer l’enregistrement';

  @override
  String get callErrCouldNotStopRecording =>
      'Impossible d’arrêter l’enregistrement';

  @override
  String callParkingNotice(String code) {
    return 'Parcage de l’appel (composez $code)';
  }

  @override
  String get callErrParkFailed => 'Échec du parcage';

  @override
  String get callErrHandoffFailed => 'Échec du basculement';

  @override
  String get callErrCouldNotSendToDevice => 'Impossible d’envoyer à l’appareil';

  @override
  String get callHistoryForwardedNoAnswer => 'Renvoyé (sans réponse)';

  @override
  String get shellTabKeypad => 'Clavier';

  @override
  String get shellTabRecents => 'Récents';

  @override
  String get shellTabContacts => 'Contacts';

  @override
  String get shellTabMessages => 'Messages';

  @override
  String get shellTabPresence => 'Présence';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Enregistr.';

  @override
  String get shellSearchSemantics =>
      'Rechercher un contact, l’historique ou composer un numéro';

  @override
  String get shellSearchHint => 'Rechercher ou composer';

  @override
  String get shellVoicemailTooltip => 'Messagerie vocale';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count nouveaux messages vocaux. Cliquez pour appeler la messagerie',
      one: '1 nouveau message vocal. Cliquez pour appeler la messagerie',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Absent';

  @override
  String get shellStatusTooltip => 'Votre statut';

  @override
  String get shellDemoBanner =>
      'Mode démo : les appels sont simulés, rien n’atteint un vrai réseau.';

  @override
  String get uiToday => 'Aujourd’hui';

  @override
  String get uiYesterday => 'Hier';

  @override
  String get uiUnknownCaller => 'Appelant inconnu';

  @override
  String get uiCallEnded => 'Appel terminé';

  @override
  String get uiCallTransferNotConfirmed => 'Transfert non confirmé';

  @override
  String get uiCallTransferring => 'Transfert en cours…';

  @override
  String get uiCallConference => 'Conférence';

  @override
  String get uiCallOnHold => 'En attente';

  @override
  String get uiCallHeldByRemote => 'Mis en attente par l’interlocuteur';

  @override
  String get uiCallCalling => 'Appel en cours…';

  @override
  String get uiCallRinging => 'Sonnerie…';

  @override
  String get uiCallConnecting => 'Connexion…';

  @override
  String get uiCallIncoming => 'Appel entrant';

  @override
  String get uiCallConnected => 'Connecté';

  @override
  String get uiQrScanTitle => 'Scanner un code QR';

  @override
  String get uiQrPasteHint => 'Collez le texte du code';

  @override
  String get uiQrNoCamera =>
      'Le scan par caméra n’est pas disponible sur cet appareil. Collez plutôt le texte du code.';

  @override
  String get uiQrPaste => 'Coller';

  @override
  String get uiQrUse => 'Utiliser';

  @override
  String get uiQrCameraDenied =>
      'L’accès à la caméra est désactivé. Autorisez-le dans les réglages système, ou collez le texte du code ci-dessous.';

  @override
  String get uiQrCameraUnavailable =>
      'La caméra n’est pas disponible. Collez le texte du code ci-dessous.';

  @override
  String get presenceLampRinging => 'Sonne';

  @override
  String get presenceHeader => 'Voyants d’occupation (BLF)';

  @override
  String get presenceChooseTooltip => 'Choisir les contacts à surveiller';

  @override
  String get presenceEmptyTitle => 'Aucun poste sur le tableau';

  @override
  String get presenceEmptySubtitle =>
      'Activez « Afficher sur le tableau BLF » pour un contact afin de voir s’il est libre, en sonnerie ou occupé.';

  @override
  String get presenceOpenContacts => 'Ouvrir les contacts';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Touchez pour appeler, appui long pour plus d’options';
  }

  @override
  String presenceCallName(String name) {
    return 'Appeler $name';
  }

  @override
  String get presencePickup => 'Intercepter ce poste';

  @override
  String get presencePickupSub =>
      'Répondre à son appel en sonnerie (interception ciblée)';

  @override
  String get presenceTransferHere => 'Transférer l’appel en cours ici';

  @override
  String get presenceRemove => 'Retirer du tableau';

  @override
  String get uiCall => 'Appeler';

  @override
  String get uiMessage => 'Message';

  @override
  String get recentsSearchTooltip => 'Rechercher dans l’historique';

  @override
  String get recentsClearTitle => 'Effacer l’historique des appels ?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count entrées seront supprimées.',
      one: '1 entrée sera supprimée.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'Historique copié dans le presse-papiers au format CSV';

  @override
  String get recentsMenuCopyCsv => 'Copier au format CSV';

  @override
  String get recentsMenuClear => 'Effacer l’historique';

  @override
  String get recentsSearchHint => 'Rechercher un nom ou un numéro';

  @override
  String get recentsFilterAll => 'Tous';

  @override
  String get recentsFilterMissed => 'Manqués';

  @override
  String get recentsFilterIncoming => 'Entrants';

  @override
  String get recentsFilterOutgoing => 'Sortants';

  @override
  String get recentsFilterAccount => 'Filtrer par compte';

  @override
  String get recentsAllAccounts => 'Tous les comptes';

  @override
  String get recentsAccountFallback => 'Compte';

  @override
  String get recentsEmptyNone => 'Aucun appel pour l’instant';

  @override
  String get recentsEmptyNoMatch => 'Aucun appel correspondant';

  @override
  String get recentsEmptyNoneSub => 'Vos appels apparaîtront ici.';

  @override
  String get recentsEmptyNoMatchSub => 'Essayez un autre filtre.';

  @override
  String get recentsOpenKeypad => 'Ouvrir le clavier';

  @override
  String get recentsShowAll => 'Tout afficher';

  @override
  String get recentsSelectCall => 'Sélectionnez un appel';

  @override
  String get recentsSelectCallSub =>
      'Les détails, la qualité et les enregistrements apparaissent ici.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Appel manqué',
      'incoming': 'Appel entrant',
      'other': 'Appel sortant',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Appeler $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Ajoutez un compte pour envoyer des messages';

  @override
  String get recentsAddContact => 'Ajouter un contact';

  @override
  String get recentsContact => 'Contact';

  @override
  String get recentsBlock => 'Bloquer';

  @override
  String get recentsUnblock => 'Débloquer';

  @override
  String recentsBlockTitle(String number) {
    return 'Bloquer $number ?';
  }

  @override
  String get recentsBlockMessage =>
      'Les appels de ce numéro seront rejetés automatiquement.';

  @override
  String get recentsQualityHeader => 'Qualité de l’appel';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'MOS min. $mos   ·   Gigue $jitter ms   ·   Perte $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Enregistrements';

  @override
  String get recentsOpenInRecordings => 'Ouvrir dans Enregistrements';

  @override
  String recentsRelatedCall(String title) {
    return 'Appel associé : $title';
  }

  @override
  String get recentsHistoryHeader => 'Historique';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Aucun appel avec ce numéro';

  @override
  String get recentsDeleteTitle => 'Supprimer ces appels ?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprime $count entrées pour $name.',
      one: 'Supprime 1 entrée pour $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Supprimer de l’historique';

  @override
  String get recentsCallDetails => 'Détails de l’appel';

  @override
  String get contactsFavoritesHeader => '★ Favoris';

  @override
  String get contactsFavoritesOnly => 'Favoris uniquement';

  @override
  String get contactsShowAll => 'Tout afficher';

  @override
  String get contactsImportExportTooltip => 'Importer et exporter';

  @override
  String get contactsMenuDevice => 'Importer depuis l’appareil';

  @override
  String get contactsMenuFile => 'Importer un fichier vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Importer depuis le presse-papiers';

  @override
  String get contactsMenuCopyVcard => 'Copier au format vCard';

  @override
  String get contactsMenuCopyCsv => 'Copier au format CSV';

  @override
  String get contactsNewTooltip => 'Nouveau contact';

  @override
  String get contactsSearchHint => 'Rechercher des contacts';

  @override
  String get contactsEmptyTitle => 'Aucun contact pour l’instant';

  @override
  String get contactsEmptySubtitle =>
      'Ajoutez les personnes que vous appelez souvent, ou importez un fichier vCard ou CSV.';

  @override
  String get contactsEmptyAction => 'Ajouter un contact';

  @override
  String get contactsNoMatches => 'Aucun résultat';

  @override
  String contactsCallName(String name) {
    return 'Appeler $name';
  }

  @override
  String get contactsSelect => 'Sélectionnez un contact';

  @override
  String get contactsCopiedVcard => 'Contacts copiés au format vCard';

  @override
  String get contactsCopiedCsv => 'Contacts copiés au format CSV';

  @override
  String get contactsDeviceDenied =>
      'L’accès aux contacts a été refusé. Autorisez-le dans les réglages système pour importer.';

  @override
  String get contactsDeviceNone => 'Aucun contact trouvé sur cet appareil';

  @override
  String contactsNothingNew(int count) {
    return 'Rien de nouveau à importer ($count déjà présent(s))';
  }

  @override
  String get contactsImportDeviceTitle => 'Importer depuis l’appareil ?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux contacts',
      one: '1 nouveau contact',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count mis à jour avec des numéros supplémentaires';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count ignoré(s) (doublons ou sans numéro de téléphone)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts importés',
      one: '1 contact importé',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Aucun contact trouvé dans ces données';

  @override
  String get contactsLabelMobile => 'mobile';

  @override
  String get contactsLabelWork => 'travail';

  @override
  String get contactsLabelHome => 'domicile';

  @override
  String get contactsLabelOther => 'autre';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contact introuvable';

  @override
  String get contactsActionFavorite => 'Favori';

  @override
  String get contactsNumbersHeader => 'Numéros';

  @override
  String get contactsSipAddress => 'Adresse SIP';

  @override
  String get contactsDetailsHeader => 'Détails';

  @override
  String get contactsOnBlf => 'Affiché sur le tableau BLF';

  @override
  String get contactsAlwaysRecorded => 'Les appels sont toujours enregistrés';

  @override
  String contactsDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get contactsDeleteMessage =>
      'Ce contact sera supprimé de cet appareil.';

  @override
  String get contactsDeleteButton => 'Supprimer le contact';

  @override
  String get contactsDetailTitle => 'Contact';

  @override
  String get contactsErrorNameOrNumber => 'Saisissez un nom ou un numéro';

  @override
  String get contactsEditTitle => 'Modifier le contact';

  @override
  String get contactsFieldName => 'Nom';

  @override
  String get contactsFieldCompany => 'Société';

  @override
  String get contactsFieldNumber => 'Numéro';

  @override
  String get contactsRemoveNumber => 'Retirer le numéro';

  @override
  String get contactsAddNumber => 'Ajouter un numéro';

  @override
  String get contactsSipHeader => 'Adresses SIP';

  @override
  String get contactsRemoveAddress => 'Retirer l’adresse';

  @override
  String get contactsAddSip => 'Ajouter une adresse SIP';

  @override
  String get contactsFieldEmail => 'E-mail';

  @override
  String get contactsFieldNotes => 'Notes';

  @override
  String get contactsFieldFavorite => 'Favori';

  @override
  String get contactsShowOnBlf => 'Afficher sur le tableau BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Surveiller la présence et le voyant d’occupation de ce poste';

  @override
  String get contactsAlwaysRecordTitle =>
      'Toujours enregistrer les appels avec ce contact';

  @override
  String get contactsAlwaysRecordSub =>
      'Remplace les règles d’enregistrement automatique';

  @override
  String get contactsRingtone => 'Sonnerie';

  @override
  String get contactsPresenceVia => 'Présence via le compte';

  @override
  String get contactsDefaultAccount => 'Compte par défaut';

  @override
  String get contactsDeleteContactTitle => 'Supprimer le contact ?';

  @override
  String get contactsCannotUndo => 'Cette action est irréversible.';

  @override
  String get messagesNewMessage => 'Nouveau message';

  @override
  String get messagesNumberOrSip => 'Numéro ou adresse SIP';

  @override
  String get messagesNoConversations => 'Aucune conversation';

  @override
  String get messagesEmptySubtitle =>
      'Envoyez un message SIP à n’importe quel poste ou adresse depuis vos comptes.';

  @override
  String get messagesTyping => 'écrit…';

  @override
  String get messagesYouPrefix => 'Vous : ';

  @override
  String get messagesSelect => 'Sélectionnez une conversation';

  @override
  String get messagesLanOnline => 'En ligne sur votre réseau';

  @override
  String get messagesLanOffline =>
      'Hors ligne. Les messages sont envoyés à son retour.';

  @override
  String messagesSendFileTo(String name) {
    return 'Envoyer un fichier à $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Appeler $name';
  }

  @override
  String get messagesDeleteTitle => 'Supprimer la conversation ?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Tous les messages avec $name seront supprimés.';
  }

  @override
  String get messagesDeleteMenu => 'Supprimer la conversation';

  @override
  String get messagesSayHello => 'Dites bonjour';

  @override
  String get messagesLanEmptySub =>
      'Les messages vont directement à cet appareil via votre réseau, chiffrés de bout en bout.';

  @override
  String get messagesSipEmptySub =>
      'Les messages sont envoyés en SIP MESSAGE via votre compte.';

  @override
  String get messagesInputHint => 'Message';

  @override
  String get messagesSend => 'Envoyer';

  @override
  String get messagesStatusSending => 'Envoi en cours';

  @override
  String get messagesStatusSent => 'Envoyé';

  @override
  String get messagesStatusDelivered => 'Remis';

  @override
  String get messagesStatusRead => 'Lu';

  @override
  String get messagesStatusFailed => 'Échec';

  @override
  String get messagesNotDelivered => 'Non remis. Touchez pour réessayer';

  @override
  String get uiStatusRegistered => 'Enregistré';

  @override
  String get uiStatusRegistering => 'Enregistrement';

  @override
  String get uiStatusRegFailed => 'Échec de l’enregistrement';

  @override
  String get uiStatusDisabled => 'Désactivé';

  @override
  String get uiQualityMeasuring => 'Mesure en cours';

  @override
  String get uiQualityExcellent => 'Excellente';

  @override
  String get uiQualityGood => 'Bonne';

  @override
  String get uiQualityFair => 'Correcte';

  @override
  String get uiQualityPoor => 'Médiocre';

  @override
  String get uiQualityBad => 'Mauvaise';

  @override
  String uiQualitySemantics(String label) {
    return 'Qualité de l’appel : $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Qualité de l’appel : $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Qualité de l’appel : $label';
  }

  @override
  String get uiSecureFull => 'Chiffré';

  @override
  String get uiSecureMedia => 'Média chiffré';

  @override
  String get uiSecureSignalling => 'Signalisation chiffrée';

  @override
  String get uiSecureNone => 'Non chiffré';

  @override
  String get uiSecureSrtpLine => 'Média SRTP';

  @override
  String get uiSecureTlsLine => 'Signalisation TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Transfert vers $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Interphone vers $name';
  }

  @override
  String get lanCallIntercomToUnnamed => 'Interphone vers un appareil proche';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Interphone de $name';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'Interphone d’un appareil proche';

  @override
  String lanCallToNamed(String name) {
    return 'Appel LAN vers $name';
  }

  @override
  String get lanCallToUnpaired => 'Appel LAN vers un appareil non associé';

  @override
  String lanCallFromNamed(String name) {
    return 'Appel LAN de $name';
  }

  @override
  String get lanCallFromUnpaired => 'Appel LAN d’un appareil non associé';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Appel transféré depuis $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Appel transféré depuis $device : $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'un autre appareil';

  @override
  String lanRelayedTitle(String name) {
    return 'Relayé vers $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'L’appelant parle à $name. Vous n’êtes pas dans l’appel.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Appel de $name…';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'L’appelant reste connecté pendant que $name répond.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Demande à $name…';
  }

  @override
  String get lanRelayOfferingSubtitle =>
      'En attente de l’acceptation de l’appel.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Conversation avec $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'L’appelant est en attente. Finalisez le transfert quand vous êtes prêt.';

  @override
  String get lanRelayTakingBack => 'Reprise de l’appel…';

  @override
  String get lanRelayTakeBack => 'Reprendre';

  @override
  String get lanRelayEnd => 'Terminer';

  @override
  String get lanSendToDevice => 'Envoyer vers un appareil';

  @override
  String get lanBusy => 'Occupé';

  @override
  String get lanNoPairedOnline => 'Aucun appareil associé n’est en ligne';

  @override
  String lanPairRejectedBy(String name) {
    return '$name a refusé l’association.';
  }

  @override
  String get lanPairRejected => 'Association refusée.';

  @override
  String get lanPairCancelled => 'Association annulée.';

  @override
  String get lanPairTimedOut => 'Délai d’association dépassé. Réessayez.';

  @override
  String get lanPairFailed => 'Échec de l’association';

  @override
  String lanPairFailedReason(String reason) {
    return 'Échec de l’association : $reason';
  }

  @override
  String get lanPairThisDevice => 'cet appareil';

  @override
  String get lanPairConnecting => 'Connexion sécurisée…';

  @override
  String lanPairWantsToPair(String name) {
    return '$name souhaite s’associer à cet appareil.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Association avec $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Vérifiez que ce code est identique sur les deux écrans.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Code d’association $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'En attente de la confirmation de $name…';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name a confirmé.';
  }

  @override
  String get lanPairReject => 'Refuser';

  @override
  String get lanPairCodesMatch => 'Les codes correspondent';

  @override
  String lanPairPairedWith(String name) {
    return 'Associé à $name.';
  }

  @override
  String get lanPairRequestTitle => 'Demande d’association';

  @override
  String lanPairTitle(String name) {
    return 'Associer à $name';
  }

  @override
  String get lanActionDecline => 'Refuser';

  @override
  String get lanActionAccept => 'Accepter';

  @override
  String get lanFileIncomingTitle => 'Fichier entrant';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size de $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Transférer un appel ici ?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' de $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' sur $account',
    });
    return '$device souhaite vous transférer un appel$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Il vous parlera d’abord.';

  @override
  String get lanHandoffTakeCall => 'Prendre l’appel';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Autoriser l’interphone de $name ?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Son appel sera décroché automatiquement sur haut-parleur.';

  @override
  String get lanIntercomDeny => 'Refuser';

  @override
  String get lanIntercomAllow => 'Autoriser';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name a retiré cet appareil de sa liste d’appareils associés';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoi de $count fichiers…',
      one: 'Envoi de $name…',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nouveau message';

  @override
  String get lanSipMessage => 'Message SIP';

  @override
  String get lanSipMessageSub =>
      'Vers un numéro ou une adresse via votre compte';

  @override
  String get lanChatOnline => 'Chat LAN, en ligne';

  @override
  String get lanChatOffline => 'Chat LAN, hors ligne';

  @override
  String lanSavedAt(String path) {
    return 'Enregistré dans $path (chemin copié)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Vos appareils, en direct';

  @override
  String get lanConnectByAddress => 'Connexion par adresse';

  @override
  String get lanSettingsTooltip => 'Réglages LAN';

  @override
  String get lanOffTitle => 'LAN Link est désactivé';

  @override
  String get lanOffSubtitle =>
      'Retrouvez vos autres appareils SoftphonePro, discutez, déposez des fichiers et transférez des appels, sans aucun serveur.';

  @override
  String get lanTurnOn => 'Activer LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link n’a pas pu démarrer : $error';
  }

  @override
  String get lanConnectHelp =>
      'Saisissez hôte:port, ou collez le texte du code QR affiché sur l’autre appareil.';

  @override
  String get lanScanTitle => 'Scanner le QR d’association LAN';

  @override
  String get lanScanQr => 'Scanner un QR';

  @override
  String get lanPaste => 'Coller';

  @override
  String get lanConnect => 'Connecter';

  @override
  String lanConnectedTo(String name) {
    return 'Connecté à $name';
  }

  @override
  String get lanCouldNotConnect => 'Connexion impossible';

  @override
  String get lanCouldNotStartPairing => 'Impossible de démarrer l’association';

  @override
  String get lanThisDevice => 'Cet appareil';

  @override
  String get lanDeviceNameTitle => 'Nom de l’appareil';

  @override
  String get lanStarting => 'Démarrage…';

  @override
  String get lanVisible => 'Visible sur votre réseau';

  @override
  String get lanNotRunning => 'Arrêté';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comptes partagés',
      one: '1 compte partagé',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Empreinte';

  @override
  String get lanHideQr => 'Masquer le code QR';

  @override
  String get lanShowQr =>
      'Afficher le code QR pour connecter un autre appareil';

  @override
  String get lanCopyConnectionText => 'Copier le texte de connexion';

  @override
  String get lanConnectionTextCopied => 'Texte de connexion copié';

  @override
  String get lanActiveOnOthers => 'Actifs sur vos autres appareils';

  @override
  String get lanPairedDevices => 'Appareils associés';

  @override
  String get lanNoPaired =>
      'Aucun appareil associé pour l’instant. Associez un appareil proche pour discuter, envoyer des fichiers et transférer des appels.';

  @override
  String get lanNearby => 'À proximité';

  @override
  String get lanNearbyHint =>
      'Recherche de SoftphonePro sur votre réseau. Les autres appareils doivent avoir activé LAN Link. Vous pouvez aussi vous connecter par adresse avec le bouton de lien ci-dessus.';

  @override
  String get lanTransfers => 'Transferts';

  @override
  String get lanFiles => 'Fichiers';

  @override
  String get lanPairedBadge => 'Associé';

  @override
  String get lanTyping => 'écrit…';

  @override
  String get lanPair => 'Associer';

  @override
  String get lanUnpair => 'Dissocier';

  @override
  String lanUnpairTitle(String name) {
    return 'Dissocier $name ?';
  }

  @override
  String get lanUnpairMessage =>
      'Vous devrez l’associer à nouveau pour discuter, envoyer des fichiers ou transférer des appels.';

  @override
  String get lanActionMessage => 'Message';

  @override
  String get lanActionSendFile => 'Envoyer un fichier';

  @override
  String get lanActionCall => 'Appeler';

  @override
  String get lanActionIntercom => 'Interphone';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Actif sur $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Actif sur $device  ·  $account';
  }

  @override
  String get lanPull => 'Récupérer';

  @override
  String get lanTransferPreparing => 'Préparation…';

  @override
  String get lanTransferWaitingYou => 'En attente de votre réponse';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'En attente de l’acceptation de $name';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done sur $total';
  }

  @override
  String get lanTransferVerifying => 'Vérification…';

  @override
  String lanTransferFrom(String name, String status) {
    return 'De $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'À $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  de $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  à $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Échec : $error';
  }

  @override
  String get lanFileActions => 'Actions sur le fichier';

  @override
  String get lanPathCopied => 'Chemin copié';

  @override
  String get lanFileOpen => 'Ouvrir';

  @override
  String get lanFileShowInFolder => 'Afficher dans le dossier';

  @override
  String get lanFileCopyPath => 'Copier le chemin';

  @override
  String lanNetworkError(String message) {
    return 'Erreur réseau : $message';
  }

  @override
  String get lanErrNotRunning => 'Activez d’abord LAN Link';

  @override
  String get lanErrBadAddress =>
      'Saisissez une adresse comme 192.168.1.20:4711 ou collez le texte du code QR';

  @override
  String get lanErrFingerprint =>
      'Cet appareil ne correspond pas au code scanné. Le code QR vient-il d’un autre appareil ?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$file reçu de $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file envoyé à $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name a refusé $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Échec du transfert de fichier : $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Activez LAN Link pour appeler les appareils proches';

  @override
  String get lanNoticePairFirst => 'Associez d’abord cet appareil';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name n’est pas joignable pour les appels pour le moment';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Demande à $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name n’a pas autorisé l’interphone (ou n’a pas répondu)';
  }

  @override
  String get lanHoOff => 'LAN Link est désactivé';

  @override
  String get lanHoPairFirst => 'Associez d’abord cet appareil';

  @override
  String lanHoOffline(String name) {
    return '$name est hors ligne';
  }

  @override
  String get lanHoAlready => 'Cet appel est déjà en cours de transfert';

  @override
  String get lanHoEnded => 'L’appel est déjà terminé';

  @override
  String get lanHoWaitConnected => 'Attendez que l’appel soit connecté';

  @override
  String get lanHoLanCall => 'Les appels LAN ne peuvent pas être transférés';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name ne peut pas prendre d’appels via le réseau (les appels LAN y sont désactivés)';
  }

  @override
  String get lanHoNoLanHere =>
      'Les appels LAN ne sont pas disponibles sur cet appareil';

  @override
  String lanHoDeclined(String name) {
    return '$name a refusé l’appel. Il reste chez vous.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name n’a pas répondu. L’appel reste chez vous.';
  }

  @override
  String get lanHoCancelled =>
      'Le transfert a été annulé. L’appel reste chez vous.';

  @override
  String lanHoUnreachable(String name) {
    return 'Impossible de joindre $name. L’appel reste chez vous.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Impossible de joindre $name ($reason). L’appel reste chez vous.';
  }

  @override
  String get lanHoEndedBefore =>
      'L’appel s’est terminé avant de pouvoir être transféré';

  @override
  String lanHoPbxRefused(String name) {
    return 'Le système téléphonique a refusé le transfert et $name ne peut pas prendre d’appels LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Échec du transfert via le système téléphonique. Relais par le réseau à la place.';

  @override
  String lanHoSentTo(String name) {
    return 'Appel envoyé à $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Impossible d’appeler l’autre appareil via le système téléphonique';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name n’est plus joignable';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Impossible de répondre à l’appel pour le transférer';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Impossible d’appeler $name via le réseau. L’appel reste chez vous.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name n’a pas répondu. L’appel reste chez vous.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Transféré à $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Appel relayé vers $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Attendez d’abord que $name réponde';
  }

  @override
  String get lanHoFailed => 'Échec du transfert';

  @override
  String lanHoTakenBack(String name) {
    return 'Appel repris de $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name a mis fin à la consultation. L’appel vous est revenu.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Impossible de transférer l’appel à $name';
  }

  @override
  String get diagSip400Explain =>
      'Le serveur n’a pas pu comprendre la requête.';

  @override
  String get diagSip400Fix =>
      'Vérifiez les réglages du compte (domaine, nom d’utilisateur, proxy). Si le problème persiste, envoyez une trace SIP à votre fournisseur.';

  @override
  String get diagSip401Explain =>
      'Le serveur a rejeté les identifiants (ou les réclame).';

  @override
  String get diagSip401Fix =>
      'Vérifiez le nom d’utilisateur, le nom d’authentification et le mot de passe. Certains fournisseurs utilisent un « ID d’authentification » distinct.';

  @override
  String get diagSip403Explain =>
      'Le serveur a compris la requête mais la refuse : mot de passe erroné, compte désactivé ou votre IP n’est pas autorisée.';

  @override
  String get diagSip403Fix =>
      'Saisissez à nouveau le mot de passe, vérifiez que le compte est actif et que votre IP publique n’est pas bloquée (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'Le serveur ne connaît pas cet utilisateur ou ce numéro.';

  @override
  String get diagSip404Fix =>
      'Vérifiez le nom d’utilisateur et le domaine ; pour les appels, vérifiez le numéro composé et les règles de numérotation.';

  @override
  String get diagSip405Explain =>
      'Le serveur ne prend pas en charge cette requête.';

  @override
  String get diagSip405Fix =>
      'Généralement sans conséquence pour les pings OPTIONS. Pour REGISTER, vérifiez que vous contactez bien un registrar SIP.';

  @override
  String get diagSip407Explain =>
      'Le proxy sortant nécessite des identifiants.';

  @override
  String get diagSip407Fix =>
      'Vérifiez le mot de passe du compte et les réglages du proxy sortant.';

  @override
  String get diagSip408Explain => 'Pas de réponse du serveur dans le délai.';

  @override
  String get diagSip408Fix =>
      'Vérifiez l’adresse et le port du serveur, les pare-feu, et essayez TCP ou TLS. Des délais dépassés répétés uniquement en UDP peuvent indiquer un ALG SIP sur le routeur.';

  @override
  String get diagSip410Explain => 'Le numéro n’existe plus.';

  @override
  String get diagSip410Fix => 'Vérifiez le numéro composé.';

  @override
  String get diagSip415Explain =>
      'L’autre partie n’accepte pas le type de contenu ou les codecs proposés.';

  @override
  String get diagSip415Fix =>
      'Activez davantage de codecs (p. ex. PCMU/PCMA) dans Réglages > Codecs.';

  @override
  String get diagSip421Explain =>
      'Le serveur exige une extension SIP que ce client n’a pas proposée.';

  @override
  String get diagSip421Fix =>
      'Vérifiez les options NAT/ICE/100rel/temporisateurs du compte.';

  @override
  String get diagSip423Explain =>
      'L’expiration de l’enregistrement est plus courte que ce que le serveur autorise.';

  @override
  String get diagSip423Fix =>
      'Augmentez l’expiration de l’enregistrement dans les réglages du compte.';

  @override
  String get diagSip480Explain =>
      'L’utilisateur n’est pas enregistré ou est injoignable pour le moment.';

  @override
  String get diagSip480Fix =>
      'Vérifiez que l’autre partie est enregistrée ; lors de l’enregistrement, le serveur est peut-être surchargé : réessayez plus tard.';

  @override
  String get diagSip481Explain =>
      'Le serveur a perdu l’état du dialogue (p. ex. après un redémarrage ou un changement de réseau).';

  @override
  String get diagSip481Fix =>
      'Raccrochez et réessayez. Si cela arrive souvent, activez les temporisateurs de session.';

  @override
  String get diagSip483Explain =>
      'La requête a tourné en boucle entre serveurs.';

  @override
  String get diagSip483Fix =>
      'Vérifiez la configuration de renvoi et de routage sur le PBX.';

  @override
  String get diagSip484Explain => 'Le numéro composé est trop court.';

  @override
  String get diagSip484Fix =>
      'Composez le numéro complet ou vérifiez les règles de numérotation.';

  @override
  String get diagSip486Explain => 'L’interlocuteur est occupé.';

  @override
  String get diagSip486Fix => 'Réessayez plus tard.';

  @override
  String get diagSip487Explain =>
      'L’appel a été annulé avant qu’il soit décroché.';

  @override
  String get diagSip487Fix =>
      'Normal lorsque l’appelant raccroche pendant la sonnerie.';

  @override
  String get diagSip488Explain =>
      'Aucun codec ni réglage de chiffrement commun avec l’autre partie.';

  @override
  String get diagSip488Fix =>
      'Vérifiez les codecs et SRTP (un compte avec SRTP obligatoire ne peut pas appeler un terminal en RTP non chiffré).';

  @override
  String get diagSip491Explain => 'Deux re-INVITE sont entrés en collision.';

  @override
  String get diagSip491Fix => 'Normalement retenté automatiquement.';

  @override
  String get diagSip500Explain => 'Le serveur a rencontré une erreur interne.';

  @override
  String get diagSip500Fix =>
      'Réessayez plus tard et contactez le fournisseur si cela continue.';

  @override
  String get diagSip502Explain =>
      'Un serveur en amont a renvoyé une réponse invalide.';

  @override
  String get diagSip502Fix =>
      'Réessayez plus tard ; contactez le fournisseur si cela continue.';

  @override
  String get diagSip503Explain =>
      'Le serveur est surchargé, hors service ou rejette ce client (limitation de débit).';

  @override
  String get diagSip503Fix =>
      'Patientez et réessayez, consultez la page d’état du fournisseur, ou essayez un autre serveur/port.';

  @override
  String get diagSip504Explain =>
      'Un serveur en amont n’a pas répondu dans le délai.';

  @override
  String get diagSip504Fix => 'Réessayez plus tard.';

  @override
  String get diagSip600Explain => 'Toutes les destinations sont occupées.';

  @override
  String get diagSip600Fix => 'Réessayez plus tard.';

  @override
  String get diagSip603Explain => 'L’interlocuteur a rejeté l’appel.';

  @override
  String get diagSip603Fix => 'Rien à corriger : l’appel a été refusé.';

  @override
  String get diagSip604Explain => 'Le numéro n’existe pas.';

  @override
  String get diagSip604Fix => 'Vérifiez le numéro composé.';

  @override
  String get diagSip606Explain =>
      'L’interlocuteur ne peut pas accepter la session telle que proposée.';

  @override
  String get diagSip606Fix =>
      'Vérifiez les codecs et les réglages de chiffrement.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provisoire ($code)';
  }

  @override
  String get diagSipProvisionalExplain =>
      'La requête est en cours de traitement.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Succès ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'La requête a abouti.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Redirigé ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'La destination a changé.';

  @override
  String get diagSipRedirectedFix => 'Vérifiez les réglages de renvoi.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Erreur client ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'Le serveur a rejeté la requête.';

  @override
  String get diagSipClientErrorFix =>
      'Vérifiez le compte et le numéro composé.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Erreur serveur ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'Le serveur n’a pas pu traiter la requête.';

  @override
  String get diagSipServerErrorFix =>
      'Réessayez plus tard ou contactez le fournisseur.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Échec global ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'La requête ne peut être satisfaite nulle part.';

  @override
  String get diagSipNoResponseTitle => 'Aucune réponse';

  @override
  String get diagSipNoResponseExplain => 'Aucune réponse SIP n’a été reçue.';

  @override
  String get diagSipNoResponseFix =>
      'Vérifiez la connexion réseau et l’adresse du serveur.';

  @override
  String get diagWizStepNet => 'Connectivité réseau';

  @override
  String diagWizStepDns(String account) {
    return 'DNS et SRV : $account';
  }

  @override
  String get diagWizStepNat => 'Type de NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Joignabilité du serveur : $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'Certificat TLS : $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Enregistrement : $account';
  }

  @override
  String get diagWizStepAlg => 'Test ALG SIP';

  @override
  String get diagWizChecking => 'Vérification…';

  @override
  String diagWizEngineError(String message) {
    return 'Erreur du moteur : $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Échec du test : $error';
  }

  @override
  String get diagWizNoEngine => 'Le moteur SIP n’est pas en cours d’exécution';

  @override
  String get diagWizNoEngineFix =>
      'Attendez le démarrage du moteur (ou redémarrez l’appli), puis relancez les tests.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface : $address (privée)';
  }

  @override
  String get diagWizNetNone =>
      'Aucune interface réseau active avec une adresse IP';

  @override
  String get diagWizNetNoneFix =>
      'Connectez-vous au Wi-Fi, à l’Ethernet ou aux données mobiles, puis relancez les tests.';

  @override
  String get diagWizNetIpv6Only => 'Seules des adresses IPv6 ont été trouvées';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'De nombreux fournisseurs SIP n’acceptent que l’IPv4. Activez l’IPv4 sur ce réseau ou utilisez un fournisseur compatible IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 adresses IPv4',
      one: '1 adresse IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interface',
    );
    return '$_temp0 sur $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Une interface de type VPN est active. Les VPN peuvent ajouter de la latence ou bloquer l’UDP ; désactivez-le si les appels se comportent mal.';

  @override
  String get diagWizDnsNoServer => 'Le compte n’a pas d’adresse de serveur';

  @override
  String get diagWizDnsNoServerFix =>
      'Modifiez le compte et saisissez le domaine SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host est une adresse IP, DNS inutile';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA : aucun';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA : aucun ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name : aucun';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name : $target:$port (priorité $priority, poids $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport : échec de la recherche ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host ne se résout pas';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Vérifiez l’orthographe du domaine et le bon fonctionnement de votre serveur DNS. Vous pouvez définir un serveur DNS personnalisé dans Réglages > Réseau (p. ex. 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host a des enregistrements SRV mais pas d’enregistrement d’adresse';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Les cibles SRV seront utilisées. Si les appels échouent, demandez au fournisseur de vérifier l’enregistrement A.';

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
      other: ', $srv enregistrements SRV',
      one: ', 1 enregistrement SRV',
      zero: '',
    );
    return '$host se résout en $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Délai dépassé pour la détection du NAT';

  @override
  String get diagWizNatTimeoutFix =>
      'Le serveur STUN est peut-être injoignable (UDP bloqué ?). Vérifiez Réglages > Réseau > Serveurs STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'Serveur STUN : $server';
  }

  @override
  String get diagWizNatOpen =>
      'Pas de NAT : cet appareil a une adresse publique';

  @override
  String get diagWizNatFullCone => 'NAT full cone : compatible avec la VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT restricted cone : fonctionne avec STUN et keep-alive';

  @override
  String get diagWizNatPortRestricted =>
      'NAT port-restricted cone : fonctionne avec STUN et keep-alive';

  @override
  String get diagWizNatSymmetric =>
      'NAT symétrique : STUN seul ne peut pas prédire le port média';

  @override
  String get diagWizNatSymmetricFix =>
      'Un son à sens unique ou l’absence de son est probable sur certains appels. Activez ICE et un relais TURN dans les réglages du compte (Compte > NAT), ou utilisez un fournisseur/PBX avec relais média (rtpengine).';

  @override
  String get diagWizNatBlocked => 'L’UDP semble bloqué';

  @override
  String get diagWizNatBlockedFix =>
      'Utilisez le transport TCP ou TLS pour le compte. Si le réseau filtre tout sauf le trafic web, essayez TLS sur le port 443 si votre fournisseur le permet.';

  @override
  String get diagWizNatUnknown => 'Le type de NAT n’a pas pu être déterminé';

  @override
  String get diagWizNatUnknownFix =>
      'Le serveur STUN n’a pas répondu. Essayez un autre serveur STUN dans Réglages > Réseau.';

  @override
  String get diagWizNatErr =>
      'Le serveur STUN n’a pas répondu, le type de NAT n’a donc pas pu être déterminé.';

  @override
  String get diagWizNatUnknownRaw =>
      'Le type de NAT n’a pas pu être déterminé.';

  @override
  String get diagWizOptionsNotLoaded =>
      'Le compte n’est pas chargé dans le moteur';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Pas de réponse à OPTIONS en $seconds s (transport : $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'Le serveur est injoignable. Vérifiez l’adresse et le port, qu’aucun pare-feu ne bloque le SIP, et essayez un autre transport (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Délai de la requête dépassé ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Le serveur a répondu $code $reason après $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Le serveur a répondu $code $reason en $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Un $code en réponse à OPTIONS est normal : le serveur est joignable mais n’autorise pas les sondes anonymes.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Un temps d’aller-retour supérieur à 300 ms ajoute un retard perceptible aux conversations. Un serveur plus proche ou une connexion filaire aide.';

  @override
  String get diagWizTlsRejected => 'Le certificat du serveur a été rejeté';

  @override
  String diagWizTlsSubject(String value) {
    return 'Sujet : $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Émetteur : $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problèmes : $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Expiration : $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Chiffrement : $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'S’il s’agit de votre propre PBX avec un certificat auto-signé et que l’empreinte ci-dessus correspond, vous pouvez lui faire confiance. Sinon, demandez au fournisseur un certificat d’une AC publique.';

  @override
  String get diagWizTlsTrust => 'Faire confiance à ce certificat';

  @override
  String diagWizTlsExpired(String date) {
    return 'Le certificat a expiré le $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Demandez à l’administrateur du serveur de renouveler le certificat.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Le certificat expire dans $days jours',
      one: 'Le certificat expire dans 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Demandez à l’administrateur du serveur de le renouveler bientôt.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Connecté, mais la vérification a signalé : $problems';
  }

  @override
  String get diagWizTlsOk => 'Connexion TLS établie, certificat valide';

  @override
  String get diagWizTlsRegistered =>
      'Enregistré via TLS (aucun détail de certificat signalé)';

  @override
  String get diagWizTlsNone => 'Aucune connexion TLS n’a encore été observée';

  @override
  String get diagWizTlsNoneFix =>
      'Vérifiez le port TLS (généralement 5061) et que le serveur accepte TLS 1.2 ou ultérieur.';

  @override
  String get diagWizRegDisabledByConfig =>
      'L’enregistrement est désactivé pour ce compte (usage pair à pair)';

  @override
  String get diagWizRegRegistered => 'Enregistré';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Enregistré (expire dans $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transport : $transport';
  }

  @override
  String get diagWizRegInProgress => 'L’enregistrement est encore en cours';

  @override
  String get diagWizRegInProgressFix =>
      'Patientez quelques secondes. S’il n’aboutit jamais, le serveur ne répond pas ; voir le test de joignabilité ci-dessus.';

  @override
  String get diagWizRegFailed => 'Échec de l’enregistrement';

  @override
  String get diagWizRegOffline => 'Le compte est hors ligne';

  @override
  String get diagWizRegOfflineFix =>
      'Vérifiez la connexion réseau. L’appli réessaie automatiquement.';

  @override
  String get diagWizRegDisabled => 'Le compte est désactivé';

  @override
  String get diagWizAlgNoUdp =>
      'Aucun compte n’utilise l’UDP, l’ALG SIP n’est donc pas un souci';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account : pas de réponse en UDP, mais TCP a répondu ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account : pas de réponse en UDP ni en TCP (problème de serveur ou de pare-feu plutôt que d’ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account : OPTIONS reçoit une réponse mais REGISTER expire, ce qui est typique d’un routeur qui réécrit le SIP';
  }

  @override
  String get diagWizAlgSuspected => 'ALG SIP suspecté sur votre routeur';

  @override
  String get diagWizAlgSuspectedFix =>
      'Désactivez « ALG SIP » / « SIP helper » dans les réglages du routeur, ou passez le compte en TCP ou TLS, ou changez le port SIP (p. ex. 5080) pour que le routeur cesse d’altérer les paquets.';

  @override
  String get diagWizAlgContactChanged =>
      'L’adresse Contact a changé entre la requête et la réponse';

  @override
  String get diagWizAlgContactChangedFix =>
      'Il peut s’agir d’un ALG SIP ou d’un serveur qui réécrit les contacts. Si les appels sonnent mais sans son ou se coupent après un moment, désactivez l’ALG SIP sur le routeur ou utilisez TCP/TLS ou le port 5080.';

  @override
  String get diagWizAlgOk => 'Aucun signe d’interférence d’un ALG SIP';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'Le Contact REGISTER $sent est revenu comme $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Enregistrer $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName enregistré';
  }

  @override
  String get diagSaveFailed => 'Impossible d’enregistrer le fichier';

  @override
  String get diagCopiedText => 'Texte copié dans le presse-papiers';

  @override
  String get diagCopiedReport => 'Rapport copié dans le presse-papiers';

  @override
  String get diagCopiedBundle =>
      'Lot de diagnostic copié dans le presse-papiers';

  @override
  String get diagCopiedLogs => 'Journaux copiés dans le presse-papiers';

  @override
  String get diagCopiedTrace => 'Trace copiée dans le presse-papiers';

  @override
  String get diagCopiedDialog => 'Dialogue copié dans le presse-papiers';

  @override
  String get diagSaveAsLog => 'Enregistrer en .log';

  @override
  String get diagSysAppVersion => 'Version de l’appli';

  @override
  String get diagSysPlatform => 'Plateforme';

  @override
  String get diagSysEngine => 'Moteur';

  @override
  String get diagSysAccounts => 'Comptes';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered sur $total enregistrés';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Impossible de lire les informations système : $error';
  }

  @override
  String get diagSysTransports => 'Transports';

  @override
  String get diagSysNoneReported => 'Aucun signalé';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter =>
      'Codecs activés, par priorité décroissante.';

  @override
  String get diagSysEngineNotRunning => 'Moteur arrêté';

  @override
  String diagSysCodecPriority(int priority) {
    return 'priorité $priority';
  }

  @override
  String get diagSysCodecDisabled => 'désactivé';

  @override
  String get diagSysExport => 'Exporter';

  @override
  String get diagSysExportFooter =>
      'Le lot contient les infos système, les résultats des tests réseau, les journaux récents et la trace SIP, avec les identifiants masqués.';

  @override
  String get diagSysCopyBundle => 'Copier le lot de diagnostic';

  @override
  String get diagSysSaveBundle => 'Enregistrer le lot de diagnostic';

  @override
  String get diagTabSipTrace => 'Trace SIP';

  @override
  String get diagTabNetwork => 'Réseau';

  @override
  String get diagTabQuality => 'Qualité';

  @override
  String get diagTabAudioTest => 'Test audio';

  @override
  String get diagTabLogs => 'Journaux';

  @override
  String get diagTabSystem => 'Système';

  @override
  String diagRawSentTo(String remote) {
    return 'envoyé à $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'reçu de $remote';
  }

  @override
  String get diagRawCopied => 'Message copié';

  @override
  String get diagRawLadder => 'Échelle';

  @override
  String get diagRawRedact => 'Masquer les identifiants';

  @override
  String diagRawTruncated(int count) {
    return '… tronqué ($count car.)';
  }

  @override
  String get diagWizIntro =>
      'Vérifie votre connexion, le DNS, le NAT, la joignabilité du serveur, TLS et l’enregistrement, et explique quoi corriger.';

  @override
  String get diagWizStop => 'Arrêter';

  @override
  String get diagWizRunChecks => 'Lancer les tests';

  @override
  String get diagWizRunAgain => 'Relancer';

  @override
  String get diagWizCopyReport => 'Copier le rapport';

  @override
  String get diagWizSaveReport => 'Enregistrer le rapport';

  @override
  String diagWizCountPassed(int count) {
    return 'Réussis $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Alertes $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Échecs $count';
  }

  @override
  String get diagWizStatusPass => 'Réussi';

  @override
  String get diagWizStatusWarn => 'Alerte';

  @override
  String get diagWizStatusFail => 'Échec';

  @override
  String get diagWizStatusSkipped => 'Ignoré';

  @override
  String get diagWizStatusRunning => 'En cours';

  @override
  String get diagWizStatusPending => 'En attente';

  @override
  String get diagQualityTitle => 'Qualité de l’appel';

  @override
  String get diagQualityNoData =>
      'Aucune donnée de qualité n’a été enregistrée pour cet appel.';

  @override
  String get diagQualityTraceForCall => 'Trace SIP de cet appel';

  @override
  String get diagQualityTraceNotCaptured =>
      'Trace SIP non capturée pour cet appel';

  @override
  String get diagQualityLiveCall => 'Appel en direct';

  @override
  String get diagQualityNoActiveCall =>
      'Aucun appel actif. Passez un appel et le MOS, la gigue, les pertes et le temps d’aller-retour sont tracés ici en direct.';

  @override
  String get diagQualityRecentCalls => 'Appels récents';

  @override
  String get diagQualityNoFinished =>
      'Aucun appel terminé avec des données de qualité pour l’instant.';

  @override
  String get diagQualityCallEnded => 'L’appel est terminé.';

  @override
  String get diagQualityMeasuring => 'mesure en cours';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Graphique $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Graphique $title, dernière valeur $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   max $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Moyenne $avg  ·  pire $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Perte';

  @override
  String get diagQualityJitter => 'Gigue';

  @override
  String diagQualityPackets(int count) {
    return '$count paq.';
  }

  @override
  String get diagQualityMedia => 'Média';

  @override
  String get diagQualityNoSeries =>
      'Aucune série temporelle n’a été enregistrée pour cet appel.';

  @override
  String get diagQualityPacketLoss => 'Perte de paquets';

  @override
  String get diagQualityRtt => 'Temps d’aller-retour';

  @override
  String get diagLogsForward => 'Transférer les journaux du moteur';

  @override
  String get diagLogsForwardSub =>
      'Envoyer les lignes de journal pjsip à cet afficheur';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Niveau $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Masquer à l’export';

  @override
  String get diagLogsSearch => 'Rechercher dans les journaux';

  @override
  String get diagLogsEmpty => 'Aucune ligne de journal pour l’instant.';

  @override
  String get diagLogsForwardingOff =>
      'Le transfert des journaux est désactivé. Activez-le pour capturer les journaux du moteur.';

  @override
  String get diagLogsNoMatch => 'Aucune ligne ne correspond à la recherche.';

  @override
  String get diagAudioEngineNotRunning =>
      'Le moteur SIP n’est pas en cours d’exécution.';

  @override
  String get diagAudioMicrophone => 'Microphone';

  @override
  String get diagAudioMicFooter =>
      'L’indicateur de niveau lit le périphérique audio, que le moteur ouvre pendant un appel ou le test d’écho.';

  @override
  String get diagAudioLevelMeter => 'Indicateur de niveau';

  @override
  String get diagAudioLevelMeterSub => 'Parlez et regardez la barre bouger';

  @override
  String get diagAudioMic => 'Micro';

  @override
  String get diagAudioSpeaker => 'Haut-parleur';

  @override
  String get diagAudioEchoTest => 'Test d’écho';

  @override
  String get diagAudioEchoFooter =>
      'Renvoie votre voix sur le haut-parleur. Utilisez un casque pour éviter le larsen.';

  @override
  String get diagAudioEchoActive => 'Actif : parlez maintenant';

  @override
  String get diagAudioEchoIdle => 'Bouclage micro vers haut-parleur';

  @override
  String get diagAudioSpeakerTest => 'Test du haut-parleur';

  @override
  String get diagAudioPlayTone => 'Jouer la tonalité de test';

  @override
  String get diagAudioPlayToneSub => 'Jouée sur le haut-parleur sélectionné';

  @override
  String get diagAudioPlayingDtmf => 'Lecture de DTMF';

  @override
  String get diagAudioPlayingRingback => 'Lecture du retour d’appel';

  @override
  String get diagAudioRingback => 'Retour d’appel';

  @override
  String get diagAudioDevices => 'Périphériques';

  @override
  String get diagAudioChooseDevices =>
      'Choisir le microphone et le haut-parleur';

  @override
  String get diagAudioChooseDevicesSub => 'Ouvre Réglages > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'Niveau $label $percent pour cent';
  }

  @override
  String get diagLadderLocal => 'Local';

  @override
  String diagLadderSent(String message) {
    return '$message envoyé';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message reçu';
  }

  @override
  String get diagTraceCapture => 'Capturer les messages SIP';

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
    return '$_temp0  ·  $size  ·  $dropped plus anciens supprimés';
  }

  @override
  String get diagTraceOffHint =>
      'Désactivé. Activez, puis enregistrez-vous ou passez un appel.';

  @override
  String get diagTraceExportOrClear => 'Exporter ou effacer';

  @override
  String get diagTraceSaveAsPcap => 'Enregistrer en .pcap';

  @override
  String get diagTraceCopyAsText => 'Copier en texte';

  @override
  String get diagTraceSearchHint => 'Rechercher texte, numéro ou Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Erreurs uniquement';

  @override
  String get diagTraceFilterMethod => 'Filtrer par méthode';

  @override
  String get diagTraceAllMethods => 'Toutes les méthodes';

  @override
  String get diagTraceMethod => 'Méthode';

  @override
  String get diagTraceFilterAccount => 'Filtrer par compte';

  @override
  String get diagTraceAllAccounts => 'Tous les comptes';

  @override
  String get diagTraceAccount => 'Compte';

  @override
  String get diagTraceRedact => 'Masquer';

  @override
  String get diagTraceList => 'Liste';

  @override
  String get diagTraceWaiting => 'En attente de trafic SIP';

  @override
  String get diagTraceWaitingSub =>
      'Enregistrez un compte ou passez un appel et les messages apparaîtront ici.';

  @override
  String get diagTraceOff => 'La trace SIP est désactivée';

  @override
  String get diagTraceOffSub =>
      'Activez la capture pour voir chaque requête et réponse SIP, sous forme de liste ou de diagramme en échelle.';

  @override
  String get diagTraceNoMatch => 'Aucun message ne correspond aux filtres';

  @override
  String get diagTraceAllDialogs => 'Tous les dialogues';

  @override
  String get diagTraceCopyDialog => 'Copier ce dialogue';

  @override
  String get diagTraceNoResponse => 'aucune réponse';

  @override
  String get diagTraceNoCallId => 'pas de Call-ID';

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
  String get recTitleFallback => 'Enregistrement';

  @override
  String get recFormatWav => 'Standard (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stéréo, vous et l’appelant sur des canaux séparés (WAV)';

  @override
  String get recFormatOpus => 'Compressé (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, environ 2 Mo par minute. Lisible partout.';

  @override
  String get recFormatWavStereoHint =>
      'Deux canaux, environ 4 Mo par minute. Vous à gauche, l’appelant à droite.';

  @override
  String get recFormatOpusHint =>
      'Environ 0,2 Mo par minute. Ogg Opus ; certains lecteurs sur iPhone, Mac et Windows ne peuvent pas l’ouvrir.';

  @override
  String get recOptionInherit => 'Utiliser le réglage global';

  @override
  String get recOptionAlways => 'Enregistrer tous les appels';

  @override
  String get recOptionIncoming => 'Enregistrer uniquement les appels entrants';

  @override
  String get recOptionOutgoing => 'Enregistrer uniquement les appels sortants';

  @override
  String get recOptionNever => 'Ne jamais enregistrer';

  @override
  String get recRuleAll => 'Tous les appels';

  @override
  String get recRuleIncoming => 'Appels entrants uniquement';

  @override
  String get recRuleOutgoing => 'Appels sortants uniquement';

  @override
  String get recAutoDeleteNever => 'Jamais';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Après $days jours',
      one: 'Après 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Après 1 an';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements',
      one: '1 enregistrement',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements',
      one: '1 enregistrement',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements',
      one: '1 enregistrement',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0  ·  $size  ·  suppression auto après $_temp1';
  }

  @override
  String get recSettingsFormat => 'Format';

  @override
  String get recSettingsAutoGroup => 'Enregistrement automatique';

  @override
  String get recSettingsAutoFooter =>
      'Vérifiez la législation locale avant d’enregistrer des appels. Activez « Toujours enregistrer les appels avec ce contact » dans un contact pour les enregistrer quelles que soient ces règles.';

  @override
  String get recSettingsAutoRule => 'Enregistrer automatiquement les appels';

  @override
  String get recSettingsAccountOverride => 'Remplacement pour ce compte';

  @override
  String get recSettingsNoticesGroup => 'Avis';

  @override
  String get recSettingsNoticeSwitch => 'Jouer un avis avant l’enregistrement';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Joue d’abord un avis à l’interlocuteur. Le fichier d’avis se choisit dans Réglages > Appels > Annonces.';

  @override
  String get recSettingsNoticeFile => 'Choisir le fichier d’avis';

  @override
  String get recSettingsNoticeFileHint => 'Ouvre Réglages > Appels > Annonces';

  @override
  String get recSettingsBeep => 'Bip d’enregistrement';

  @override
  String get recSettingsBeepHint => 'Avertir l’interlocuteur périodiquement';

  @override
  String get recSettingsTransfersGroup => 'Transferts';

  @override
  String get recSettingsContinue =>
      'Continuer l’enregistrement pendant les transferts';

  @override
  String get recSettingsContinueHint =>
      'Enregistrer l’appel de consultation d’un transfert supervisé et l’appel qui nous est transféré, et lier les enregistrements';

  @override
  String get recSettingsStorageGroup => 'Stockage';

  @override
  String get recSettingsFolder => 'Dossier';

  @override
  String get recSettingsFolderHint => 'Emplacement des enregistrements';

  @override
  String get recSettingsFolderPlaceholder =>
      'Documents de l’appli / Enregistrements';

  @override
  String get recSettingsChooseFolder => 'Choisir un dossier…';

  @override
  String get recSettingsFolderPickerTitle => 'Dossier des enregistrements';

  @override
  String get recSettingsAutoDelete => 'Supprimer les anciens enregistrements';

  @override
  String get recSettingsAutoDeleteHint =>
      'Vérifié au démarrage et une fois par jour';

  @override
  String get recSettingsManage => 'Gérer les enregistrements';

  @override
  String get recSettingsOpenFolder => 'Ouvrir le dossier des enregistrements';

  @override
  String get recPageTitle => 'Enregistrements';

  @override
  String recSelectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get recCancelSelection => 'Annuler la sélection';

  @override
  String get recSelectAll => 'Tout sélectionner';

  @override
  String get recShareSelected => 'Partager la sélection';

  @override
  String get recDeleteSelected => 'Supprimer la sélection';

  @override
  String get recSearchTooltip => 'Rechercher des enregistrements';

  @override
  String get recSelectTooltip => 'Sélectionner des enregistrements';

  @override
  String get recMenuSettings => 'Réglages d’enregistrement';

  @override
  String get recSearchHint => 'Rechercher un nom ou un numéro';

  @override
  String get recEmptyNone => 'Aucun enregistrement pour l’instant';

  @override
  String get recEmptyNoneHint =>
      'Enregistrez un appel avec le bouton Enregistrer, ou activez l’enregistrement automatique dans les Réglages.';

  @override
  String get recEmptyNoMatch => 'Aucun enregistrement correspondant';

  @override
  String get recEmptyNoMatchHint =>
      'Essayez une autre recherche ou un autre filtre.';

  @override
  String get recClearFilters => 'Effacer les filtres';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count enregistrements ?',
      one: 'Supprimer 1 enregistrement ?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Les fichiers audio sont supprimés de cet appareil. Cette action est irréversible.';

  @override
  String get recDeleteOneTitle => 'Supprimer cet enregistrement ?';

  @override
  String get recDeleteOneMessage =>
      'Le fichier audio est supprimé de cet appareil. Cette action est irréversible.';

  @override
  String get recFilterAll => 'Tous';

  @override
  String get recFilterIncoming => 'Entrants';

  @override
  String get recFilterOutgoing => 'Sortants';

  @override
  String get recFilterByAccount => 'Filtrer par compte';

  @override
  String get recFilterAllAccounts => 'Tous les comptes';

  @override
  String get recFilterAccountFallback => 'Compte';

  @override
  String get recFilterAnyDate => 'Toute date';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Effacer les dates';

  @override
  String get recMissingFile => 'Le fichier audio est absent de cet appareil.';

  @override
  String recRelated(String title) {
    return 'Associé : $title';
  }

  @override
  String get recRenameTitle => 'Renommer l’enregistrement';

  @override
  String get recRenameHint => 'Nom';

  @override
  String get recSaveAs => 'Enregistrer sous…';

  @override
  String get recShowInFinder => 'Afficher dans le Finder';

  @override
  String get recShowInFolder => 'Afficher dans le dossier';

  @override
  String get recViewCall => 'Voir l’appel';

  @override
  String recSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String get recSaveFailed => 'Impossible d’enregistrer l’enregistrement';

  @override
  String get recShareFailed => 'Impossible de partager l’enregistrement';

  @override
  String get recSaveDialogTitle => 'Enregistrer l’enregistrement';

  @override
  String get recShareSubject => 'Enregistrements d’appels';

  @override
  String get recPlayerUnsupported =>
      'Cet appareil ne peut pas lire les enregistrements Opus ici.';

  @override
  String get recPlayerOpenWith => 'Ouvrir avec…';

  @override
  String get recPlayerNotFound => 'Le fichier d’enregistrement est introuvable';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Impossible de lire cet enregistrement : $error';
  }

  @override
  String get recPlayerPlay => 'Lire l’enregistrement';

  @override
  String get recPlayerPause => 'Mettre l’enregistrement en pause';

  @override
  String get audioFilesTitle => 'Fichiers audio';

  @override
  String audioAdded(String name) {
    return '« $name » ajouté';
  }

  @override
  String get audioFileUnavailable => 'Ce fichier n’est pas disponible.';

  @override
  String get audioNameRequired => 'Saisissez un nom';

  @override
  String audioDeleteTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get audioDeleteMessage =>
      'Les réglages qui utilisent ce fichier reviennent à la valeur par défaut.';

  @override
  String get audioGroupAdd => 'Ajouter';

  @override
  String get audioAddFooter =>
      'Les fichiers WAV (PCM, loi µ, loi A) et MP3 fonctionnent. Les fichiers sont copiés dans l’appli, l’original peut donc être déplacé.';

  @override
  String get audioImport => 'Importer un WAV ou un MP3…';

  @override
  String get audioGroupMine => 'Mes fichiers';

  @override
  String get audioEmptyTitle => 'Aucun fichier pour l’instant';

  @override
  String get audioEmptyHint =>
      'Importez un fichier ou enregistrez votre propre annonce.';

  @override
  String get audioGroupBuiltIn => 'Intégrés';

  @override
  String get audioBuiltInFooter =>
      'Générés pour SoftphonePro, libres d’utilisation.';

  @override
  String get audioPreviewStop => 'Arrêter l’aperçu';

  @override
  String audioPreviewPlay(String name) {
    return 'Aperçu de $name';
  }

  @override
  String get audioRecordedName => 'Nommer cet enregistrement';

  @override
  String get audioRecordedDefaultName => 'Mon annonce';

  @override
  String audioSaved(String name) {
    return '« $name » enregistré';
  }

  @override
  String get audioRecorderStop => 'Arrêter';

  @override
  String get audioRecorderPlay => 'Lire l’enregistrement';

  @override
  String audioRecorderNew(String duration) {
    return 'Nouvel enregistrement  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Abandonner';

  @override
  String get audioRecordOwn => 'Enregistrer la vôtre…';

  @override
  String get audioRecordOwnHint =>
      'Utilise le microphone sélectionné dans les réglages Audio';

  @override
  String get audioMissingFile => 'Fichier manquant';

  @override
  String get audioBuiltInCalm => 'Calme (intégré)';

  @override
  String get audioBuiltInBreeze => 'Brise (intégré)';

  @override
  String get audioBuiltInChime => 'Carillon d’avis (intégré)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Seuls les fichiers WAV et MP3 peuvent être utilisés.';

  @override
  String get audioErrNotFound => 'Ce fichier est introuvable.';

  @override
  String get audioErrNotSaved => 'L’enregistrement n’a pas été sauvegardé.';

  @override
  String get audioErrEmpty => 'Ce fichier audio est vide ou illisible.';

  @override
  String audioErrUnusable(String reason) {
    return 'Ce fichier audio ne peut pas être utilisé ($reason). Utilisez un WAV PCM, loi µ ou loi A, ou un MP3.';
  }

  @override
  String get audioRecEngineOff =>
      'Le moteur d’appel n’est pas en cours d’exécution.';

  @override
  String get audioRecUnsupported =>
      'Cette version du moteur d’appel ne peut pas enregistrer le microphone.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Impossible de démarrer l’enregistrement : $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Échec de l’enregistrement : $reason';
  }

  @override
  String get audioStrengthLow => 'Faible';

  @override
  String get audioStrengthMedium => 'Moyen';

  @override
  String get audioStrengthHigh => 'Élevé';

  @override
  String get audioStrengthMax => 'Max';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent %)';
  }

  @override
  String get audioSystemDefault => 'Par défaut du système';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Par défaut du système ($name)';
  }

  @override
  String get voiceTitle => 'Isolation vocale';

  @override
  String get voiceUnavailable =>
      'La réduction de bruit par IA n’est pas disponible dans cette version du moteur d’appel. La suppression du bruit standard sous Traitement fonctionne toujours.';

  @override
  String get voiceGroupAi => 'Réduction de bruit par IA';

  @override
  String get voiceAiFooter =>
      'Supprime les clics de clavier, les ventilateurs et les voix en arrière-plan de l’appel grâce à un réseau de neurones embarqué (RNNoise). Rien ne quitte votre appareil. Une intensité plus élevée supprime plus de bruit mais peut couper le début des mots.';

  @override
  String get voiceMic => 'Mon microphone';

  @override
  String get voiceMicHint => 'Nettoyer ce que l’autre personne entend';

  @override
  String get voiceOthers => 'Autres participants';

  @override
  String get voiceOthersHint =>
      'Nettoyer les appelants bruyants que vous entendez';

  @override
  String voiceStrength(String value) {
    return 'Intensité : $value';
  }

  @override
  String get voiceGroupTry => 'Essayer';

  @override
  String get voiceTryFooter =>
      'Utilisez un casque pour le test d’écho, sinon vous entendrez du larsen.';

  @override
  String get voiceEchoTest => 'Tester avec écho';

  @override
  String get voiceEchoTestHint => 'Vous renvoie votre microphone traité';

  @override
  String get voiceEchoFailed => 'Échec du test d’écho';

  @override
  String get voiceGroupSystem => 'Système';

  @override
  String get voiceSystemFooter =>
      'macOS et iOS peuvent aussi isoler votre voix pour toutes les applis. Choisissez Isolation vocale dans le mode microphone du système.';

  @override
  String get voiceSystemMode =>
      'Mode microphone du système (Isolation vocale)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Les modes microphone nécessitent macOS 12 ou iOS 15 ou ultérieur.';

  @override
  String get voiceSpeechDetection => 'Détection de la parole';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent pour cent';
  }

  @override
  String voicePercent(int percent) {
    return '$percent %';
  }

  @override
  String get voiceGroupAndroid => 'Effets audio Android';

  @override
  String get voiceAndroidFooter =>
      'Le téléphone peut aussi nettoyer lui-même le microphone. Ces effets sont signalés par Android et distincts du réglage ci-dessus.';

  @override
  String get voiceAndroidNs => 'Suppresseur de bruit';

  @override
  String get voiceAndroidAec => 'Annulateur d’écho';

  @override
  String get voiceNotAvailableDevice => 'Non disponible sur cet appareil';

  @override
  String get callLinkNotLocal =>
      'Ce type de lien ne peut être utilisé que depuis la ligne de commande de cet ordinateur.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Se connecter à l’appareil $name ?';
  }

  @override
  String get linkLanConnectBody =>
      'Un lien provenant d’une autre application ou d’une page web veut connecter SoftphonePro à cet appareil. Ne continuez que si vous vous y attendiez.';

  @override
  String get linkLanConnectAction => 'Se connecter';

  @override
  String get linkImportSensitiveHeader =>
      'Modifications sensibles dans cette configuration :';

  @override
  String get linkImportFlagAutoAnswer =>
      'Répond automatiquement aux appels entrants';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Renvoie les appels vers $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Modifie qui peut lancer un interphone ou récupérer un appel (réseau local)';

  @override
  String get linkImportFlagDialRewrite =>
      'Réécrit les numéros que vous composez';

  @override
  String get linkImportFlagLinksImmediately =>
      'Les appels depuis des liens web démarrent immédiatement, sans confirmation';

  @override
  String get linkImportFlagDiagnostics =>
      'Active la journalisation détaillée ou la trace SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Autoriser la réponse automatique pour les comptes importés';

  @override
  String linkImportRefused(String setting) {
    return 'Cet import tente de modifier « $setting », qui ne peut jamais être défini par un lien, un code QR, un texte collé ou un fichier. Utilisez plutôt l\'option de ligne de commande --provision sur cet ordinateur. Rien n\'a été importé.';
  }

  @override
  String get lanPairIntercomNote =>
      'Les appareils appairés peuvent demander un appel interphone ; une confirmation vous sera demandée à chaque fois (à modifier dans Réglages > Réseau local).';

  @override
  String get callLinkUnsupportedScheme =>
      'Ce type de lien n\'est pas pris en charge.';

  @override
  String get linkImportFlagAutoRecord =>
      'Enregistre les appels automatiquement';

  @override
  String get linkImportFlagBlocklist =>
      'Modifie votre liste de blocage d\'appels';

  @override
  String get linkImportFlagEmergency => 'Modifie vos numéros d\'urgence';

  @override
  String get linkImportFlagSpeedDial => 'Définit des numéros abrégés';

  @override
  String get linkImportFlagRecordingDelete =>
      'Supprime automatiquement les anciens enregistrements';

  @override
  String get linkImportFlagFeatureCodes =>
      'Compose des codes de fonction PBX personnalisés';

  @override
  String get linkImportAllowAutoRecord =>
      'Autoriser l\'enregistrement automatique des appels';

  @override
  String get importIgnoredHeader => 'Ignoré (non autorisé lors d\'un import) :';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - serveur $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Proxys : $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'Relais TURN : $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'En-têtes SIP personnalisés : $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'Identifiant d\'appelant : $callerId';
  }

  @override
  String get importAccountSrtpOff =>
      'Pas de chiffrement des médias (SRTP désactivé)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Adresse : $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Mettre à jour $updated existants, ajouter $added nouveaux';
  }

  @override
  String get secretsKeyringLocked =>
      'Votre trousseau est verrouillé : les mots de passe enregistrés n\'ont pas pu être lus. Déverrouillez-le et redémarrez SoftphonePro.';

  @override
  String get mixerTitle => 'Mixeur audio';

  @override
  String get mixerMicrophone => 'Microphone';

  @override
  String get mixerSpeaker => 'Casque et haut-parleur';

  @override
  String get mixerMicVolume => 'Volume du microphone';

  @override
  String get mixerSpeakerVolume => 'Volume du haut-parleur';

  @override
  String mixerMeterLabel(String name) {
    return 'Niveau : $name';
  }

  @override
  String get mixerInputDevice => 'Périphérique d\'entrée';

  @override
  String get mixerOutputDevice => 'Périphérique de sortie';

  @override
  String get mixerOutputRoute => 'Sortie audio';

  @override
  String get mixerInputFollowsOutput =>
      'Le microphone suit la sortie audio sélectionnée.';

  @override
  String get mixerShowMore =>
      'Afficher les périphériques et la musique de fond';

  @override
  String get mixerShowLess => 'Afficher moins de commandes';

  @override
  String get mixerStripShow => 'Afficher le mixeur audio';

  @override
  String get mixerStripHide => 'Masquer le mixeur audio';

  @override
  String get musicbedTitle => 'Musique de fond';

  @override
  String get musicbedPlay => 'Lire la musique de fond';

  @override
  String get musicbedVolume => 'Volume de la musique de fond';

  @override
  String get musicbedChooseFile => 'Choisir un fichier';

  @override
  String musicbedChangeFile(String name) {
    return 'Fichier de musique de fond : $name. Touchez pour changer.';
  }

  @override
  String get musicbedHearIt => 'L\'écouter moi-même';

  @override
  String get musicbedMonitorVolume => 'Volume d\'écoute';

  @override
  String get musicbedAddFile => 'Ajouter un fichier…';

  @override
  String get musicbedPickerTitle => 'Fichier de musique de fond';

  @override
  String get musicbedOn => 'Musique de fond active';

  @override
  String get musicbedOnTooltip =>
      'Un fichier musical est diffusé à tous les participants de vos appels.';

  @override
  String get musicbedFileMissing =>
      'Le fichier de musique de fond n\'est plus disponible ; la musique de fond a été désactivée.';

  @override
  String get musicbedNeedsFile =>
      'Choisissez d\'abord un fichier de musique de fond.';

  @override
  String musicbedStopped(String message) {
    return 'Musique de fond arrêtée : $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Diffuse en boucle un fichier musical sous votre voix pour tous les participants de vos appels, même lorsque vous êtes en sourdine. Les appels en attente entendent la musique d\'attente.';

  @override
  String get musicbedSettingsFile => 'Fichier musical';

  @override
  String get linkImportFlagMusicbed => 'Diffuse de la musique dans vos appels';

  @override
  String get musicbedMonitorIosHint =>
      'Sur iPhone, vous l’entendez pendant les appels';

  @override
  String get musicbedStopFailed =>
      'Impossible d’arrêter la musique. Elle est peut-être encore diffusée à vos interlocuteurs.';
}
