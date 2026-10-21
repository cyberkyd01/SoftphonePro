// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get languageSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get languagePickerHint =>
      'भाषाओं के नाम उनकी अपनी भाषा में दिखाए जाते हैं।';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionDelete => 'हटाएँ';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionOk => 'ठीक है';

  @override
  String get actionRetry => 'फिर कोशिश करें';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionAdd => 'जोड़ें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionRename => 'नाम बदलें';

  @override
  String get actionClear => 'साफ़ करें';

  @override
  String get actionBack => 'वापस';

  @override
  String get actionCopy => 'कॉपी करें';

  @override
  String get actionShare => 'शेयर करें';

  @override
  String get actionImport => 'इंपोर्ट करें';

  @override
  String get actionExport => 'एक्सपोर्ट करें';

  @override
  String get actionDetails => 'विवरण';

  @override
  String get actionMore => 'और';

  @override
  String get actionSettings => 'सेटिंग';

  @override
  String get actionSearch => 'खोजें';

  @override
  String get actionRefresh => 'रीफ़्रेश करें';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionYes => 'हाँ';

  @override
  String get actionNo => 'नहीं';

  @override
  String get commonOn => 'चालू';

  @override
  String get commonOff => 'बंद';

  @override
  String get commonNone => 'कोई नहीं';

  @override
  String get commonDefault => 'डिफ़ॉल्ट';

  @override
  String get commonSystem => 'सिस्टम';

  @override
  String get commonAutomatic => 'स्वचालित';

  @override
  String get commonUnknown => 'अज्ञात';

  @override
  String get commonNotSet => 'सेट नहीं है';

  @override
  String get commonError => 'त्रुटि';

  @override
  String get commonLoading => 'लोड हो रहा है…';

  @override
  String get statusAvailable => 'उपलब्ध';

  @override
  String get statusDoNotDisturb => 'परेशान न करें';

  @override
  String get statusOffline => 'ऑफ़लाइन';

  @override
  String get statusOnACall => 'कॉल पर';

  @override
  String get settingsEntryAccounts => 'खाते';

  @override
  String get settingsEntryAccountsSub => 'SIP खाते और रजिस्ट्रेशन';

  @override
  String get settingsEntryAudio => 'ऑडियो';

  @override
  String get settingsEntryAudioSub => 'डिवाइस, स्तर, इको कैंसलेशन';

  @override
  String get settingsEntryCodecs => 'कोडेक';

  @override
  String get settingsEntryCodecsSub => 'क्रम, उपलब्धता, Opus';

  @override
  String get settingsEntryCalls => 'कॉल';

  @override
  String get settingsEntryCallsSub => 'DND, कॉल वेटिंग, ऑटो-आंसर, डायल नियम';

  @override
  String get settingsEntryNetwork => 'नेटवर्क';

  @override
  String get settingsEntryNetworkSub => 'ट्रांसपोर्ट, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'रिकॉर्डिंग';

  @override
  String get settingsEntryNotifications => 'नोटिफ़िकेशन और रिंगटोन';

  @override
  String get settingsEntryShortcuts => 'शॉर्टकट';

  @override
  String get settingsEntryShortcutsSub => 'ग्लोबल हॉटकी, ऐप की-बोर्ड कुंजियाँ';

  @override
  String get settingsEntryAppearance => 'दिखावट';

  @override
  String get settingsEntryPrivacy => 'गोपनीयता और सुरक्षा';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'प्रोविज़निंग';

  @override
  String get settingsEntryProvisioningSub => 'इंपोर्ट, एक्सपोर्ट, QR';

  @override
  String get settingsEntryDiagnostics => 'डायग्नोस्टिक्स';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP ट्रेस, नेटवर्क जाँच';

  @override
  String get settingsEntryAdvanced => 'उन्नत';

  @override
  String get settingsEntryAbout => 'परिचय';

  @override
  String get settingsAccountsEmptyTitle => 'अपना पहला खाता जोड़ें';

  @override
  String get settingsAccountsEmptySubtitle =>
      'कॉल करना शुरू करने के लिए अपने PBX या SIP प्रदाता से जुड़ें।';

  @override
  String get settingsAccountsAdd => 'खाता जोड़ें';

  @override
  String get settingsAccountsYourAccounts => 'आपके खाते';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  बैकअप सर्वर का उपयोग हो रहा है';
  }

  @override
  String get settingsAudioDevices => 'डिवाइस';

  @override
  String get settingsAudioMicrophone => 'माइक्रोफ़ोन';

  @override
  String get settingsAudioSpeaker => 'स्पीकर';

  @override
  String get settingsAudioRinger => 'रिंगर';

  @override
  String get settingsAudioRingerSub => 'रिंगटोन अलग डिवाइस पर बजाएँ';

  @override
  String get settingsAudioRefreshDevices => 'डिवाइस रीफ़्रेश करें';

  @override
  String get settingsAudioLevelsAndTest => 'स्तर और परीक्षण';

  @override
  String get settingsAudioMicVolume => 'माइक्रोफ़ोन वॉल्यूम';

  @override
  String get settingsAudioMicLevel => 'माइक स्तर';

  @override
  String get settingsAudioSpeakerVolume => 'स्पीकर वॉल्यूम';

  @override
  String get settingsAudioSpeakerLevel => 'स्पीकर स्तर';

  @override
  String get settingsAudioTestSpeaker => 'स्पीकर जाँचें';

  @override
  String get settingsAudioTestSpeakerSub =>
      'चुने गए स्पीकर पर एक छोटी टोन बजाता है';

  @override
  String get settingsAudioTestToneFailed => 'टेस्ट टोन नहीं बजाई जा सकी';

  @override
  String get settingsAudioEchoTestFailed => 'इको टेस्ट विफल रहा';

  @override
  String get settingsAudioEchoTest => 'इको टेस्ट';

  @override
  String get settingsAudioEchoTestSub =>
      'आपका माइक्रोफ़ोन स्पीकर पर वापस सुनाता है। फ़ीडबैक से बचने के लिए हेडफ़ोन लगाएँ।';

  @override
  String get settingsAudioVoiceAndFiles => 'आवाज़ और फ़ाइलें';

  @override
  String get settingsAudioVoiceIsolation => 'वॉइस आइसोलेशन (AI नॉइज़ कैंसलेशन)';

  @override
  String get settingsAudioAudioFiles => 'ऑडियो फ़ाइलें';

  @override
  String get settingsAudioAudioFilesSub => 'होल्ड म्यूज़िक और घोषणाएँ';

  @override
  String get settingsAudioProcessing => 'प्रोसेसिंग';

  @override
  String get settingsAudioEchoCancellation => 'इको कैंसलेशन';

  @override
  String get settingsAudioEcSimple => 'सरल';

  @override
  String get settingsAudioEcPlatform => 'प्लैटफ़ॉर्म';

  @override
  String get settingsAudioEchoTail => 'इको टेल';

  @override
  String get settingsAudioNoiseSuppression => 'शोर दमन';

  @override
  String get settingsAudioAgc => 'स्वचालित गेन कंट्रोल';

  @override
  String get settingsAudioVad => 'वॉइस एक्टिविटी डिटेक्शन';

  @override
  String get settingsAudioVadSub => 'शांति के दौरान बैंडविड्थ बचाता है';

  @override
  String get settingsAudioAdvanced => 'उन्नत';

  @override
  String get settingsAudioAdvancedFooter =>
      'जिटर बफ़र के मान मिलीसेकंड में हैं; -1 इंजन का डिफ़ॉल्ट उपयोग करता है। इन्हें बदलने पर कॉल इंजन रीस्टार्ट होता है।';

  @override
  String get settingsAudioPtime => 'पैकेट समय (ptime)';

  @override
  String get settingsAudioJbInitial => 'जिटर बफ़र: प्रारंभिक';

  @override
  String get settingsAudioJbMinPrefetch => 'जिटर बफ़र: न्यूनतम प्रीफ़ेच';

  @override
  String get settingsAudioJbMaxPrefetch => 'जिटर बफ़र: अधिकतम प्रीफ़ेच';

  @override
  String get settingsAudioJbMaxSize => 'जिटर बफ़र: अधिकतम आकार';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'माइक्रोफ़ोन $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'अन्य $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent प्रतिशत';
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
      other: '$count सेकंड',
      one: '1 सेकंड',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'क्रम और उपलब्धता';

  @override
  String get settingsCodecsDragHint =>
      'क्रम बदलने के लिए खींचें। खाते अपनी सेटिंग में इस सूची को बदल सकते हैं।';

  @override
  String get settingsCodecsBitrate => 'बिटरेट';

  @override
  String get settingsCodecsFec => 'इन-बैंड FEC';

  @override
  String get settingsCodecsFecSub => 'पैकेट लॉस से उबरता है';

  @override
  String get settingsCodecsDtxSub => 'शांति के दौरान भेजना रोकें';

  @override
  String get settingsCodecsCbr => 'स्थिर बिटरेट';

  @override
  String get settingsCodecsComplexity => 'जटिलता';

  @override
  String get settingsCallsIncoming => 'इनकमिंग';

  @override
  String get settingsCallsDndSub => 'सभी इनकमिंग कॉल अस्वीकार करें';

  @override
  String get settingsCallsRejectWith => 'इस प्रतिक्रिया से अस्वीकार करें';

  @override
  String get settingsCallsReasonBusy => 'व्यस्त (486)';

  @override
  String get settingsCallsReasonUnavailable => 'अस्थायी रूप से अनुपलब्ध (480)';

  @override
  String get settingsCallsReasonDecline => 'अस्वीकार (603)';

  @override
  String get settingsCallsWaiting => 'कॉल वेटिंग';

  @override
  String get settingsCallsWaitingSub =>
      'कॉल के दौरान दूसरी इनकमिंग कॉल की अनुमति दें';

  @override
  String get settingsCallsWhenBusy => 'व्यस्त होने पर और वेटिंग बंद होने पर';

  @override
  String get settingsCallsRejectAnonymous => 'अनाम कॉल अस्वीकार करें';

  @override
  String get settingsCallsLinksImmediately => 'लिंक से तुरंत कॉल करें';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'tel:, sip: और callto: लिंक डायलर में रुके बिना कॉल लगा देते हैं';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'DND / फ़ॉरवर्डिंग को फ़ीचर कोड से PBX के साथ सिंक करें';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'DND या फ़ॉरवर्डिंग बदलने पर खाते के स्टार कोड (जैसे *78) कुछ क्षण के लिए डायल करता है';

  @override
  String get settingsCallsAutoAnswerGroup => 'ऑटो-आंसर';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'कॉल फ़ॉरवर्डिंग और प्रति-खाता ऑटो-आंसर हर खाते में सेट किए जाते हैं।';

  @override
  String get settingsCallsAutoAnswerAll => 'सभी कॉल अपने-आप उठाएँ';

  @override
  String get settingsCallsAnswerAfter => 'इतने समय बाद उठाएँ';

  @override
  String get settingsCallsAnswerImmediately => 'तुरंत';

  @override
  String get settingsCallsIntercomHeaders => 'इंटरकॉम हेडर मानें';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info, Alert-Info और Answer-Mode ऑटो-आंसर संकेत';

  @override
  String get settingsCallsBlocked => 'ब्लॉक किए गए नंबर';

  @override
  String get settingsCallsBlockNumber => 'नंबर ब्लॉक करें';

  @override
  String get settingsCallsBlockNumberTitle => 'नंबर ब्लॉक करें';

  @override
  String get settingsCallsBlockNumberHint => 'नंबर या SIP पता';

  @override
  String get settingsCallsSpeedDial => 'स्पीड डायल';

  @override
  String get settingsCallsDialPlan => 'डायल प्लान';

  @override
  String get settingsCallsDialRules => 'डायल नियम';

  @override
  String get settingsCallsStripPrefix => 'हटाने के लिए बाहरी लाइन उपसर्ग';

  @override
  String get settingsCallsStripPrefixSub =>
      'उदाहरण: 9, जो डायल किए गए नंबरों की शुरुआत से हटा दिया जाता है';

  @override
  String get settingsCallsPlusReplacement => 'शुरुआती + की जगह लगाएँ';

  @override
  String get settingsCallsPlusReplacementSub =>
      'उदाहरण: अंतरराष्ट्रीय कॉल के लिए 00';

  @override
  String get settingsCallsPlusReplacementHint => '+ रखें';

  @override
  String get settingsCallsCountryPrefix => 'डिफ़ॉल्ट देश उपसर्ग';

  @override
  String get settingsCallsCountryPrefixSub =>
      '0 से शुरू होने वाले राष्ट्रीय नंबरों में यह उपसर्ग जुड़ता है, जैसे +44';

  @override
  String get settingsCallsEmergency => 'आपातकालीन नंबर';

  @override
  String get settingsCallsEmergencySub =>
      'अल्पविराम से अलग करें। ये डायल नियमों को छोड़कर सीधे लगते हैं।';

  @override
  String settingsCallsUnblock(String number) {
    return '$number अनब्लॉक करें';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '9 में से $count असाइन किए गए';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नियम',
      one: '1 नियम',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'नया डायल नियम';

  @override
  String get settingsDialRulesEdit => 'डायल नियम संपादित करें';

  @override
  String get settingsDialRulesName => 'नाम';

  @override
  String get settingsDialRulesPattern => 'पैटर्न (regex)';

  @override
  String get settingsDialRulesReplacement => 'प्रतिस्थापन';

  @override
  String get settingsDialRulesReplacementHelp =>
      'समूहों के लिए \$1, \$2 का उपयोग करें';

  @override
  String get settingsDialRulesRoute => 'इस खाते से रूट करें';

  @override
  String get settingsDialRulesAdd => 'नियम जोड़ें';

  @override
  String get settingsDialRulesLiveTest => 'लाइव टेस्ट';

  @override
  String get settingsDialRulesTyped => 'टाइप किया गया नंबर';

  @override
  String get settingsDialRulesNothing => '(कुछ नहीं)';

  @override
  String get settingsDialRulesEmergency =>
      'आपातकालीन नंबर: जैसा टाइप किया वैसा ही डायल होगा';

  @override
  String get settingsDialRulesAccountFallback => 'खाता';

  @override
  String get settingsDialRulesEmpty =>
      'कोई नियम नहीं है। नंबर साफ़ किए जाते हैं (स्पेस, डैश, कोष्ठक हटाए जाते हैं) और जैसा टाइप किया वैसा डायल होते हैं। नियम ऊपर से नीचे चलते हैं; पहला मेल खाने वाला नियम लागू होता है।';

  @override
  String get settingsDialRulesDelete => 'नियम हटाएँ';

  @override
  String get settingsDialRulesDeleteTitle => 'नियम हटाएँ?';

  @override
  String settingsDialRulesVia(String account) {
    return '$account के ज़रिए';
  }

  @override
  String get settingsNetworkTransports => 'ट्रांसपोर्ट';

  @override
  String get settingsNetworkTransportsFooter =>
      'पोर्ट 0 कोई खाली पोर्ट अपने-आप चुनता है। ट्रांसपोर्ट बदलने पर कॉल इंजन रीस्टार्ट होता है।';

  @override
  String get settingsNetworkUdpPort => 'UDP पोर्ट';

  @override
  String get settingsNetworkTcpPort => 'TCP पोर्ट';

  @override
  String get settingsNetworkTlsPort => 'TLS पोर्ट';

  @override
  String get settingsNetworkVerifyCerts => 'सर्वर प्रमाणपत्र सत्यापित करें';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'इसे केवल सेल्फ़-साइन्ड PBX के लिए बंद करें, या नीचे प्रमाणपत्र पिन करें';

  @override
  String get settingsNetworkCustomCa => 'कस्टम CA फ़ाइल';

  @override
  String get settingsNetworkCustomCaSub =>
      'अंतर्निहित सूची की जगह उपयोग होने वाला PEM बंडल (निजी PBX CA)';

  @override
  String get settingsNetworkCustomCaHint => 'अंतर्निहित Mozilla सूची';

  @override
  String get settingsNetworkPins => 'पिन किए गए प्रमाणपत्र';

  @override
  String get settingsNetworkPinsSub =>
      'host=SHA256 फ़िंगरप्रिंट, अल्पविराम से अलग';

  @override
  String get settingsNetworkNat => 'NAT ट्रैवर्सल';

  @override
  String get settingsNetworkStun => 'STUN सर्वर';

  @override
  String get settingsNetworkStunSub => 'host:port, अल्पविराम से अलग';

  @override
  String get settingsNetworkIceTurn => 'ICE और TURN';

  @override
  String get settingsNetworkIceTurnSub =>
      'हर खाते में NAT के अंतर्गत सेट होता है';

  @override
  String get settingsNetworkAdvanced => 'उन्नत';

  @override
  String get settingsNetworkQos => 'QoS (DSCP मार्किंग)';

  @override
  String get settingsNetworkQosSub =>
      'प्राथमिकता के लिए SIP और वॉइस पैकेट चिह्नित करें';

  @override
  String get settingsNetworkDns => 'DNS सर्वर';

  @override
  String get settingsNetworkDnsSub => 'स्वचालित के लिए खाली छोड़ें';

  @override
  String get settingsNetworkRtpStart => 'RTP पोर्ट शुरुआत';

  @override
  String get settingsNetworkRtpRange => 'RTP पोर्ट सीमा';

  @override
  String get settingsNetworkRtpRangeSub => '0 डिफ़ॉल्ट का उपयोग करता है';

  @override
  String get settingsNotifRingtone => 'रिंगटोन';

  @override
  String get settingsNotifDefaultRingtone => 'डिफ़ॉल्ट रिंगटोन';

  @override
  String get settingsNotifProgressTones => 'कॉल प्रोग्रेस टोन';

  @override
  String get settingsNotifProgressTonesSub =>
      'डायल करते समय रिंगबैक, व्यस्त और कंजेशन टोन';

  @override
  String get settingsNotifRingerVolume => 'रिंगर वॉल्यूम';

  @override
  String get settingsNotifCustomRingtone => 'कस्टम रिंगटोन फ़ाइल';

  @override
  String get settingsNotifCustomRingtoneSub => 'WAV फ़ाइल का पाथ (डेस्कटॉप)';

  @override
  String get settingsNotifGroup => 'नोटिफ़िकेशन';

  @override
  String get settingsNotifRequestPermissions => 'अनुमतियाँ माँगें';

  @override
  String get settingsNotifRequestPermissionsSub => 'माइक्रोफ़ोन और नोटिफ़िकेशन';

  @override
  String get settingsNotifTyping => 'टाइपिंग संकेतक भेजें';

  @override
  String get settingsAppearanceTheme => 'थीम';

  @override
  String get settingsAppearanceLight => 'लाइट';

  @override
  String get settingsAppearanceDark => 'डार्क';

  @override
  String get settingsAppearanceAccent => 'एक्सेंट रंग';

  @override
  String get settingsAppearanceAccentOption => 'एक्सेंट रंग विकल्प';

  @override
  String get settingsAppearanceCompact => 'कॉम्पैक्ट घनत्व';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'माइक्रोफ़ोन: $microphone, नोटिफ़िकेशन: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'सुरक्षा';

  @override
  String get settingsPrivacyPasswords => 'पासवर्ड';

  @override
  String get settingsPrivacyPasswordsSub =>
      'सिस्टम कीचेन / कीस्टोर में सहेजे जाते हैं (विकल्प के रूप में एन्क्रिप्टेड फ़ाइल)';

  @override
  String get settingsPrivacyGroup => 'गोपनीयता';

  @override
  String get settingsPrivacyNoTelemetry => 'कोई टेलीमेट्री नहीं';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro कोई एनालिटिक्स नहीं भेजता। नेटवर्क ट्रैफ़िक केवल आपके SIP सर्वरों तक जाता है।';

  @override
  String get settingsPrivacyYourData => 'आपका डेटा';

  @override
  String get settingsPrivacyClearHistory => 'कॉल इतिहास साफ़ करें';

  @override
  String get settingsPrivacyDeleteContacts => 'सभी संपर्क हटाएँ';

  @override
  String get settingsPrivacyDeleteMessages => 'सभी संदेश हटाएँ';

  @override
  String get settingsPrivacyConfirmHistory => 'कॉल इतिहास हटाएँ?';

  @override
  String get settingsPrivacyConfirmContacts => 'सभी संपर्क हटाएँ?';

  @override
  String get settingsPrivacyConfirmMessages => 'सभी संदेश हटाएँ?';

  @override
  String get settingsPrivacyCannotUndo => 'इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get settingsPrivacyDeletedHistory => 'कॉल इतिहास हटा दिया गया';

  @override
  String get settingsPrivacyDeletedContacts => 'सभी संपर्क हटा दिए गए';

  @override
  String get settingsPrivacyDeletedMessages => 'सभी संदेश हटा दिए गए';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'एक ही नेटवर्क के डिवाइस एक-दूसरे को खोज लेते हैं, 6 अंकों के कोड से पेयर होते हैं और बिना किसी सर्वर के सीधे बात करते हैं।';

  @override
  String get settingsLanEnable => 'LAN Link चालू करें';

  @override
  String get settingsLanDeviceName => 'डिवाइस का नाम';

  @override
  String get settingsLanDeviceNameHint => 'यह डिवाइस';

  @override
  String get settingsLanAllowIntercom => 'इंटरकॉम की अनुमति दें';

  @override
  String get settingsLanAllowIntercomSub =>
      'पेयर किए गए डिवाइस आपको कॉल कर सकें और कॉल अपने-आप उठे';

  @override
  String get settingsLanAskIntercom => 'इंटरकॉम की अनुमति देने से पहले पूछें';

  @override
  String get settingsLanAskIntercomSub =>
      'नहीं तो पेयर किए गए डिवाइस के पूछने के बाद 30 सेकंड तक कॉल अपने-आप उठती है';

  @override
  String get settingsLanAutoAcceptFiles =>
      'पेयर किए गए डिवाइस की फ़ाइलें अपने-आप स्वीकारें';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'नहीं तो हर फ़ाइल के लिए आपसे पूछा जाएगा';

  @override
  String get settingsLanAllowPull => 'पेयर किए गए डिवाइस मेरी कॉल खींच सकें';

  @override
  String get settingsLanAllowPullSub =>
      'पेयर किया गया डिवाइस यहाँ चल रही कॉल अपने हाथ में ले सकता है';

  @override
  String get settingsLanDownloads => 'डाउनलोड फ़ोल्डर';

  @override
  String get settingsLanDownloadsHint => 'डिफ़ॉल्ट (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'लिंक पोर्ट';

  @override
  String get settingsLanSharedAccounts => 'पेयर किए गए डिवाइस के साथ साझा खाते';

  @override
  String get settingsLanSharedAccountsFooter =>
      'रजिस्टर्ड खाता साझा करने पर उसी सर्वर पर पेयर किया गया डिवाइस आपकी कॉल रिले किए बिना सीधे (कॉल ट्रांसफ़र) पा सकता है।';

  @override
  String get settingsAdvEngine => 'इंजन';

  @override
  String get settingsAdvSimulator => 'सिम्युलेटर का उपयोग करें';

  @override
  String get settingsAdvSimulatorSub =>
      'नेटिव इंजन के बिना चलाएँ। कॉल सिम्युलेट की जाती हैं।';

  @override
  String get settingsAdvLogLevel => 'लॉग स्तर';

  @override
  String get settingsAdvLogErrors => 'त्रुटियाँ';

  @override
  String get settingsAdvLogInfo => 'जानकारी';

  @override
  String get settingsAdvLogDebug => 'डीबग';

  @override
  String get settingsAdvLogVerbose => 'विस्तृत';

  @override
  String get settingsAdvSipTrace => 'SIP ट्रेस';

  @override
  String get settingsAdvRestartEngine => 'इंजन रीस्टार्ट करें';

  @override
  String get settingsAdvDesktop => 'डेस्कटॉप';

  @override
  String get settingsAdvStartAtLogin => 'लॉगिन पर शुरू करें';

  @override
  String get settingsAdvCloseToTray => 'बंद करने पर ट्रे में रखें';

  @override
  String get settingsAdvCloseToTraySub =>
      'विंडो बंद करने पर भी SoftphonePro चलता रहता है ताकि कॉल की घंटी बजती रहे। ट्रे / मेन्यू बार आइकन से बाहर निकलें।';

  @override
  String get settingsAboutLicence => 'लाइसेंस';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro मुफ़्त सॉफ़्टवेयर है: आप इसे फ़्री सॉफ़्टवेयर फ़ाउंडेशन द्वारा प्रकाशित GNU जनरल पब्लिक लाइसेंस, संस्करण 3 या उसके बाद के संस्करण, की शर्तों के अंतर्गत पुनर्वितरित और/या संशोधित कर सकते हैं। इसे बिना किसी वारंटी के वितरित किया जाता है।';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 या बाद का';

  @override
  String get settingsAboutGplSub =>
      'सोर्स कोड प्रोजेक्ट रिपॉज़िटरी में उपलब्ध है';

  @override
  String get settingsAboutThirdParty => 'तृतीय-पक्ष सूचनाएँ';

  @override
  String get settingsAboutPackages => 'Flutter और Dart पैकेज';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT और Apache 2.0। लाइसेंस पेज देखें।';

  @override
  String settingsAboutVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String settingsAboutNotice(String license, String purpose) {
    return '$license। $purpose।';
  }

  @override
  String settingsAboutNoticeVersion(
    String license,
    String purpose,
    String version,
  ) {
    return '$license। $purpose। संस्करण $version।';
  }

  @override
  String get updatesChecking => 'जाँच हो रही है...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version उपलब्ध है';
  }

  @override
  String get updatesUpToDate => 'आपके पास नवीनतम संस्करण है';

  @override
  String get updatesCouldNotCheck => 'जाँच नहीं हो सकी';

  @override
  String get updatesNotCheckedYet => 'अभी तक जाँच नहीं हुई';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'आखिरी जाँच $dateString';
  }

  @override
  String get updatesTitle => 'अपडेट';

  @override
  String get updatesFooter =>
      'जाँच केवल api.github.com से संपर्क करती है (हफ़्ते में एक बार) और अनुरोध के अलावा कुछ नहीं भेजती: कोई पहचानकर्ता, खाता या कॉल डेटा नहीं। SoftphonePro अपने-आप कुछ भी डाउनलोड या इंस्टॉल नहीं करता।';

  @override
  String get updatesCheckSwitch => 'अपडेट जाँचें';

  @override
  String get updatesCheckNow => 'अभी जाँचें';

  @override
  String updatesSkippingVersion(String version) {
    return 'संस्करण $version छोड़ा जा रहा है';
  }

  @override
  String get updatesStopSkipping => 'छोड़ना बंद करें';

  @override
  String get updatesReleaseNotes => 'रिलीज़ नोट्स';

  @override
  String get updatesDownload => 'डाउनलोड करें';

  @override
  String get updatesSkipVersion => 'यह संस्करण छोड़ें';

  @override
  String get updatesDismiss => 'हटाएँ';

  @override
  String get updatesRateLimited =>
      'GitHub की अनुरोध सीमा पूरी हो गई, बाद में फिर कोशिश करें';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub ने $status लौटाया';
  }

  @override
  String get updatesUnexpectedReply => 'अनपेक्षित उत्तर';

  @override
  String get updatesTimedOut => 'समय समाप्त हो गया';

  @override
  String get updatesAlreadyChecking => 'जाँच पहले से चल रही है';

  @override
  String get encryptionTitle => 'एन्क्रिप्शन';

  @override
  String get encryptionFooter =>
      'स्थानीय डेटाबेस को AES-256-GCM से एन्क्रिप्ट करता है। कुंजी सिस्टम कीचेन / कीस्टोर में रखी जाती है; खो जाने पर डेटा वापस नहीं पाया जा सकता। कॉल रिकॉर्डिंग और एक्सपोर्ट की गई फ़ाइलें एन्क्रिप्ट नहीं होतीं। बदलाव SoftphonePro के अगली बार शुरू होने पर लागू होगा (पहले इसे पूरी तरह बंद करें); नया डेटाबेस खुलने और जाँच लिए जाने के तुरंत बाद पुरानी फ़ाइल ओवरराइट करके हटा दी जाती है।';

  @override
  String get encryptionSwitchTitle =>
      'इस डिवाइस पर कॉल इतिहास, संपर्क और संदेश एन्क्रिप्ट करें';

  @override
  String get encryptionWillEncrypt => 'अगली बार शुरू होने पर एन्क्रिप्ट होगा';

  @override
  String get encryptionWillDecrypt => 'अगली बार शुरू होने पर डिक्रिप्ट होगा';

  @override
  String get encryptionRestartToEncrypt =>
      'अपना डेटा एन्क्रिप्ट करने के लिए SoftphonePro बंद करके फिर शुरू करें।';

  @override
  String get encryptionRestartToDecrypt =>
      'अपना डेटा डिक्रिप्ट करने के लिए SoftphonePro बंद करके फिर शुरू करें।';

  @override
  String speedDialSlotTitle(int slot) {
    return 'स्पीड डायल $slot';
  }

  @override
  String get speedDialNumberLabel => 'नंबर या SIP पता';

  @override
  String get speedDialLabelOptional => 'लेबल (वैकल्पिक)';

  @override
  String get speedDialCallFrom => 'इससे कॉल करें';

  @override
  String get speedDialSelectedAccount => 'चुना गया खाता';

  @override
  String get speedDialTitle => 'स्पीड डायल';

  @override
  String get speedDialHint =>
      'खाली कीपैड पर अंक (1-9) को देर तक दबाएँ और उसके नंबर पर कॉल करें।';

  @override
  String get speedDialNotAssigned => 'असाइन नहीं है';

  @override
  String provisioningNotValidJson(String detail) {
    return 'मान्य JSON नहीं है: $detail';
  }

  @override
  String get provisioningExpectedObject => 'JSON ऑब्जेक्ट अपेक्षित था';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'असमर्थित कॉन्फ़िग संस्करण $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'ऑब्जेक्ट न होने वाली खाता प्रविष्टि छोड़ दी गई';

  @override
  String get provisioningNothingToImport =>
      'फ़ाइल में कोई खाता या सेटिंग नहीं है';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'खाते \"$name\" के लिए उपयोगकर्ता नाम और डोमेन ज़रूरी हैं';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'सर्वर ने $status लौटाया';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'कॉन्फ़िगरेशन डाउनलोड नहीं हो सका: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '$path पढ़ा नहीं जा सका';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाते इंपोर्ट हुए',
      one: '1 खाता इंपोर्ट हुआ',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'कॉन्फ़िगरेशन इंपोर्ट करें';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts खाते',
      one: '1 खाता',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings सेटिंग',
      one: '1 सेटिंग',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'URL या JSON से इंपोर्ट करें';

  @override
  String get provisioningImportFromUrlHint => 'https://... या JSON पेस्ट करें';

  @override
  String get provisioningInvalidSource => 'यह मान्य URL, लिंक या JSON नहीं है';

  @override
  String get provisioningScanTitle => 'प्रोविज़निंग QR स्कैन करें';

  @override
  String get provisioningPasteHint => 'JSON, लिंक या URL पेस्ट करें';

  @override
  String get provisioningImportGroup => 'इंपोर्ट';

  @override
  String get provisioningImportFooter =>
      'खातों और सेटिंग वाला JSON समर्थित है। \${VAR} प्लेसहोल्डर खाली मान से भरे जाते हैं, जब तक \${VAR:-default} के रूप में डिफ़ॉल्ट न दिया गया हो।';

  @override
  String get provisioningScanQr => 'QR कोड स्कैन करें';

  @override
  String get provisioningFromUrl => 'URL या पेस्ट किए JSON से';

  @override
  String get provisioningFromFile => 'फ़ाइल से';

  @override
  String get provisioningFromClipboard => 'क्लिपबोर्ड से';

  @override
  String get provisioningExportGroup => 'एक्सपोर्ट';

  @override
  String get provisioningIncludePasswords => 'पासवर्ड शामिल करें';

  @override
  String get provisioningIncludePasswordsHint =>
      'फ़ाइल जिसके पास भी हो, वह आपके खातों का उपयोग कर सकता है';

  @override
  String get provisioningCopyConfig => 'कॉन्फ़िगरेशन कॉपी करें (JSON)';

  @override
  String get provisioningConfigCopied => 'कॉन्फ़िगरेशन कॉपी हो गया';

  @override
  String get provisioningQrGroup => 'QR कोड';

  @override
  String get provisioningQrFooter =>
      'खाता कॉपी करने के लिए इस कोड को दूसरे डिवाइस पर स्कैन करें। इसमें पासवर्ड हो तो इसे पासवर्ड की तरह सुरक्षित रखें।';

  @override
  String get provisioningQrAccount => 'खाता';

  @override
  String get provisioningChoose => 'चुनें...';

  @override
  String get provisioningQrTooMuchData => 'QR कोड के लिए डेटा बहुत ज़्यादा है';

  @override
  String tlsClearField(String field) {
    return '$field साफ़ करें';
  }

  @override
  String get tlsChoose => 'चुनें...';

  @override
  String get tlsChange => 'बदलें...';

  @override
  String get tlsClientCertTitle => 'क्लाइंट प्रमाणपत्र (म्यूचुअल TLS)';

  @override
  String get tlsIncomplete =>
      'प्रमाणपत्र और उसकी निजी कुंजी, दोनों चुनें। प्रमाणपत्र तभी प्रस्तुत किया जाता है जब दोनों सेट हों।';

  @override
  String get tlsFooter =>
      'उन सर्वरों के लिए जो ऐप से प्रमाणपत्र द्वारा पहचान माँगते हैं। PEM फ़ाइलें। TLS और सुरक्षित WebSocket के लिए उपयोग होता है।';

  @override
  String get tlsCertFile => 'प्रमाणपत्र फ़ाइल';

  @override
  String get tlsKeyFile => 'निजी कुंजी फ़ाइल';

  @override
  String get tlsKeyPassword => 'कुंजी पासवर्ड';

  @override
  String get tlsKeyPasswordHint => 'केवल तब, जब कुंजी एन्क्रिप्टेड हो';

  @override
  String get callSettingsHoldGroupTitle => 'होल्ड';

  @override
  String get callSettingsHoldFooter =>
      '\"PBX डिफ़ॉल्ट\" चुनने पर कॉल को बस होल्ड पर रखा जाता है और आपका फ़ोन सिस्टम अपना संगीत बजा सकता है। कोई और विकल्प चुनने पर वह इस ऐप द्वारा कॉल करने वाले को सुनाया जाता है।';

  @override
  String get callSettingsHoldMusic => 'होल्ड म्यूज़िक';

  @override
  String get callSettingsHoldPbxDefault => 'PBX डिफ़ॉल्ट';

  @override
  String get callSettingsHoldMusicVolume => 'होल्ड म्यूज़िक वॉल्यूम';

  @override
  String get callSettingsHoldAudioFiles => 'ऑडियो फ़ाइलें';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'होल्ड म्यूज़िक इंपोर्ट या रिकॉर्ड करें';

  @override
  String get callSettingsAnnounceTitle => 'घोषणाएँ';

  @override
  String get callSettingsAnnounceFooter =>
      'घोषणाएँ दूसरे पक्ष को सुनाई जाती हैं। फ़ाइल न मिलने पर सब कुछ चुपचाप छोड़ दिया जाता है।';

  @override
  String get callSettingsAnnounceOpening => 'शुरुआती घोषणा';

  @override
  String get callSettingsAnnounceOpeningHint => 'कॉल जुड़ने पर एक संदेश बजाएँ';

  @override
  String get callSettingsAnnounceFile => 'घोषणा फ़ाइल';

  @override
  String get callSettingsAnnounceChooseFile => 'फ़ाइल चुनें';

  @override
  String get callSettingsAnnouncePlayFor => 'इनके लिए बजाएँ';

  @override
  String get callSettingsAnnounceBoth => 'इनकमिंग और आउटगोइंग';

  @override
  String get callSettingsAnnounceIncoming => 'इनकमिंग कॉल';

  @override
  String get callSettingsAnnounceOutgoing => 'आउटगोइंग कॉल';

  @override
  String get callSettingsAnnounceMuteMic =>
      'बजते समय मेरा माइक्रोफ़ोन म्यूट रखें';

  @override
  String get callSettingsAnnounceMonitor => 'मुझे भी सुनाएँ';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'रिकॉर्डिंग शुरू होने से पहले बजाएँ';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'कॉल करने वाले को ट्रांसफ़र करने से पहले बजाएँ';

  @override
  String get morePageTitle => 'और';

  @override
  String get morePresence => 'उपस्थिति';

  @override
  String get morePresenceHint => 'बिज़ी लैंप फ़ील्ड';

  @override
  String get moreRetrieveParked => 'पार्क की गई कॉल वापस लें';

  @override
  String get moreRetrieveParkedHint => 'पार्क स्लॉट डायल करें';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'आस-पास के डिवाइस, चैट और फ़ाइल ड्रॉप';

  @override
  String get moreRecordings => 'रिकॉर्डिंग';

  @override
  String get moreRecordingsHint =>
      'कॉल रिकॉर्डिंग सुनें, शेयर करें और प्रबंधित करें';

  @override
  String get moreVoicemail => 'वॉइसमेल';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नए संदेश',
      one: '1 नया संदेश',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'अपना वॉइसमेल डायल करें';

  @override
  String get moreDiagnostics => 'डायग्नोस्टिक्स';

  @override
  String get moreDiagnosticsHint => 'SIP ट्रेस और नेटवर्क जाँच';

  @override
  String get moreAbout => 'परिचय';

  @override
  String get moreNoVoicemailNumber =>
      'कोई वॉइसमेल नंबर सेट नहीं है। खाता सेटिंग में एक जोड़ें।';

  @override
  String get moreSearchHint => 'संपर्क, इतिहास खोजें या नंबर टाइप करें';

  @override
  String moreCallNumber(String number) {
    return '$number को कॉल करें';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'ऐप लॉक';

  @override
  String get appLockFooter =>
      'ऐप लॉक होने पर भी कॉल की घंटी बजती है और कॉल उठाई जा सकती है।';

  @override
  String get appLockRequirePin => 'ऐप खोलने के लिए PIN ज़रूरी करें';

  @override
  String get appLockOnHint => 'इतिहास, संपर्क, संदेश और सेटिंग लॉक हैं';

  @override
  String get appLockIsOn => 'ऐप लॉक चालू है';

  @override
  String get appLockIsOff => 'ऐप लॉक बंद है';

  @override
  String get appLockTurnOff => 'ऐप लॉक बंद करें';

  @override
  String get appLockChangePin => 'PIN बदलें';

  @override
  String get appLockEnterCurrent => 'मौजूदा PIN दर्ज करें';

  @override
  String get appLockPinChanged => 'PIN बदल गया';

  @override
  String get appLockLockAfter => 'इतने समय बाद लॉक करें';

  @override
  String get appLockLockAfterHint =>
      'PIN दोबारा माँगे जाने से पहले बैकग्राउंड में बिताया समय';

  @override
  String get appLockImmediately => 'तुरंत';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट',
      one: '1 मिनट',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 घंटा';

  @override
  String get appLockBiometrics => 'बायोमेट्रिक से अनलॉक करें';

  @override
  String get appLockNow => 'अभी लॉक करें';

  @override
  String get appLockSetPin => 'PIN सेट करें';

  @override
  String get appLockPinDigits => 'PIN (4-8 अंक)';

  @override
  String get appLockRepeatPin => 'PIN दोबारा दर्ज करें';

  @override
  String get appLockUseDigits => '4 से 8 अंकों का उपयोग करें';

  @override
  String get appLockMismatch => 'PIN मेल नहीं खाते';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'बहुत ज़्यादा प्रयास। $seconds सेकंड में फिर कोशिश करें';
  }

  @override
  String get appLockWrongPin => 'गलत PIN';

  @override
  String get appLockTooMany => 'बहुत ज़्यादा प्रयास';

  @override
  String get appLockIsLocked => 'SoftphonePro लॉक है';

  @override
  String get appLockEnterPin => 'अपना PIN दर्ज करें';

  @override
  String appLockTryAgainIn(String time) {
    return '$time में फिर कोशिश करें';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes मि $seconds से';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds से';
  }

  @override
  String get appLockUnlock => 'अनलॉक करें';

  @override
  String get appLockIncomingCall => 'इनकमिंग कॉल';

  @override
  String get appLockDecline => 'अस्वीकार करें';

  @override
  String get appLockAnswer => 'उठाएँ';

  @override
  String get appLockHangUp => 'कॉल काटें';

  @override
  String get appLockBiometricReason => 'SoftphonePro अनलॉक करें';

  @override
  String get automationNoToken =>
      'कोई एक्सेस टोकन सेट नहीं है। इसे सेटिंग > उन्नत में बनाएँ।';

  @override
  String automationInvalidPort(int port) {
    return 'अमान्य पोर्ट $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'शुरू नहीं हो सका: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'पोर्ट $port उपलब्ध नहीं है ($error)। कोई दूसरा पोर्ट चुनें।';
  }

  @override
  String get automationTokenPlaceholder => 'API चालू करने पर बनाया जाता है';

  @override
  String automationListening(String address) {
    return '$address पर सुन रहा है';
  }

  @override
  String get automationStarting => 'शुरू हो रहा है...';

  @override
  String get automationTitle => 'स्थानीय ऑटोमेशन API';

  @override
  String get automationFooter =>
      'इस कंप्यूटर पर CRM और हेल्पडेस्क इंटीग्रेशन के लिए। यह केवल 127.0.0.1 पर सुनता है और हर अनुरोध के लिए एक्सेस टोकन चाहिए। docs/AUTOMATION_API.md देखें।';

  @override
  String get automationEnable => 'स्थानीय ऑटोमेशन API चालू करें';

  @override
  String get automationPort => 'पोर्ट';

  @override
  String get automationPortHint =>
      'डिफ़ॉल्ट 7771। 1024 से 65535 के बीच कोई खाली पोर्ट चुनें।';

  @override
  String get automationPortInvalid => '1024 से 65535 तक का पोर्ट दर्ज करें';

  @override
  String get automationAccessToken => 'एक्सेस टोकन';

  @override
  String get automationHideToken => 'टोकन छिपाएँ';

  @override
  String get automationShowToken => 'टोकन दिखाएँ';

  @override
  String get automationCopyToken => 'टोकन कॉपी करें';

  @override
  String get automationTokenCopied => 'टोकन कॉपी हो गया';

  @override
  String get automationGenerateToken => 'नया टोकन बनाएँ';

  @override
  String get automationGenerateTitle => 'नया टोकन बनाएँ?';

  @override
  String get automationGenerateBody =>
      'पुराने टोकन का उपयोग करने वाले प्रोग्राम तब तक काम नहीं करेंगे जब तक आप उन्हें नया टोकन न दें।';

  @override
  String get automationGenerate => 'बनाएँ';

  @override
  String get automationOrigins => 'अनुमत ब्राउज़र ऑरिजिन';

  @override
  String get automationOriginsHint =>
      'अल्पविराम से अलग करें, जैसे https://crm.example.com। ब्राउज़र के बिना चलने वाले प्रोग्राम (curl, स्क्रिप्ट) को इसकी ज़रूरत नहीं है।';

  @override
  String automationNotOrigin(String origin) {
    return 'http(s) ऑरिजिन नहीं है: $origin';
  }

  @override
  String get trayNotificationAnswer => 'उठाएँ';

  @override
  String get trayNotificationDecline => 'अस्वीकार करें';

  @override
  String get trayTooltipInCall => 'SoftphonePro - कॉल पर';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count नए';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - कोई खाता नहीं (दूर)',
      'dnd': 'SoftphonePro - कोई खाता नहीं (परेशान न करें)',
      'other': 'SoftphonePro - कोई खाता नहीं',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total ऑनलाइन (दूर)',
      'dnd': 'SoftphonePro - $online/$total ऑनलाइन (परेशान न करें)',
      'other': 'SoftphonePro - $online/$total ऑनलाइन',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'SoftphonePro छिपाएँ';

  @override
  String get trayShowApp => 'SoftphonePro दिखाएँ';

  @override
  String trayNewOpenRecents(int count) {
    return '$count नए - हालिया खोलें';
  }

  @override
  String get trayStatus => 'स्थिति';

  @override
  String get trayStatusAway => 'दूर';

  @override
  String get trayAccounts => 'खाते';

  @override
  String get trayQuit => 'SoftphonePro बंद करें';

  @override
  String get hotkeyAnswerCall => 'कॉल उठाएँ';

  @override
  String get hotkeyHangUp => 'कॉल काटें';

  @override
  String get hotkeyMute => 'म्यूट / अनम्यूट';

  @override
  String get hotkeyFocusDialer => 'डायलर पर फ़ोकस';

  @override
  String get shortcutsGlobalTitle => 'ग्लोबल हॉटकी';

  @override
  String get shortcutsGlobalFooter =>
      'किसी भी ऐप्लिकेशन में काम करती हैं। यदि कोई दूसरा प्रोग्राम पहले से कोई संयोजन उपयोग कर रहा हो, तो वह रजिस्टर नहीं हो पाएगा।';

  @override
  String get shortcutsChange => 'बदलें';

  @override
  String get shortcutsRestoreDefaults => 'डिफ़ॉल्ट बहाल करें';

  @override
  String get shortcutsMediaTitle => 'हेडसेट और मीडिया कुंजियाँ';

  @override
  String get shortcutsMediaFooter =>
      'हेडसेट या कीबोर्ड का प्ले/पॉज़ बटन केवल तब लिया जाता है जब कॉल की घंटी बज रही हो या कॉल चल रही हो, ताकि बाकी समय म्यूज़िक प्लेयर उसका उपयोग कर सकें।';

  @override
  String get shortcutsMediaSwitch =>
      'हेडसेट/मीडिया प्ले-पॉज़ बटन से कॉल उठाएँ और काटें';

  @override
  String get shortcutsMediaDuringCall => 'कॉल के दौरान बटन';

  @override
  String get shortcutsMediaHangsUp => 'कॉल काटता है';

  @override
  String get shortcutsMediaMutes => 'म्यूट / अनम्यूट करता है';

  @override
  String get shortcutsInApp => 'ऐप में';

  @override
  String get shortcutsFocusDialer => 'डायलर पर फ़ोकस करें';

  @override
  String get shortcutsHoldResume => 'होल्ड / फिर शुरू';

  @override
  String get shortcutsTransfer => 'ट्रांसफ़र';

  @override
  String get shortcutsEndCall => 'कॉल समाप्त करें';

  @override
  String get shortcutsNeedX11 =>
      'ग्लोबल शॉर्टकट के लिए X11 सत्र ज़रूरी है। Wayland ऐप्स को पूरे सिस्टम में कुंजियाँ पकड़ने की अनुमति नहीं देता।';

  @override
  String shortcutsNeedModifier(String key) {
    return 'किसी अक्षर या अंक के साथ Ctrl, Alt, Shift या $key जोड़ें';
  }

  @override
  String get shortcutsPressNew => 'नया कुंजी संयोजन दबाएँ';

  @override
  String get defaultHandlerChooseInSettings =>
      'डिफ़ॉल्ट ऐप्स में SIP, TEL और CALLTO के लिए SoftphonePro चुनें';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro अब sip:, tel: और callto: लिंक खोलता है';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return '$schemes के लिए डिफ़ॉल्ट बदला नहीं जा सका';
  }

  @override
  String get defaultHandlerIntro =>
      'ब्राउज़र और अन्य ऐप्स से sip:, tel: और callto: लिंक खोलता है';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro sip:, tel: और callto: लिंक संभालता है';

  @override
  String defaultHandlerNow(String handlers) {
    return 'अभी: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'sip:, tel: और callto: लिंक के लिए SoftphonePro को डिफ़ॉल्ट ऐप बनाएँ';

  @override
  String get reliabilityTitle => 'बैकग्राउंड विश्वसनीयता';

  @override
  String get reliabilityMicrophone => 'माइक्रोफ़ोन';

  @override
  String get reliabilityAllowed => 'अनुमति है';

  @override
  String get reliabilityMicNeeded => 'कॉल में बात करने के लिए ज़रूरी';

  @override
  String get reliabilityNotifications => 'नोटिफ़िकेशन';

  @override
  String get reliabilityNotifNeeded =>
      'इनकमिंग कॉल दिखाने और सेवा को दिखाई देते रखने के लिए ज़रूरी';

  @override
  String get reliabilityFullScreen => 'फ़ुल-स्क्रीन इनकमिंग कॉल';

  @override
  String get reliabilityFullScreenNeeded =>
      'अनुमति दें ताकि कॉल लॉक स्क्रीन के ऊपर दिखें';

  @override
  String get reliabilityBattery => 'बैटरी का अप्रतिबंधित उपयोग';

  @override
  String get reliabilityBatteryExempt => 'बैटरी ऑप्टिमाइज़ेशन से मुक्त';

  @override
  String get reliabilityBatteryNeeded =>
      'बिजली बचाने के लिए Android ऐप को रोक सकता है और कॉल छूट सकती हैं। SoftphonePro को छूट देने के लिए टैप करें।';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer ऑटोस्टार्ट / सुरक्षित ऐप्स';
  }

  @override
  String get reliabilityAutostartHint =>
      'आपके फ़ोन का निर्माता बैकग्राउंड ऐप्स बंद कर सकता है। SoftphonePro को अपने-आप शुरू होने दें।';

  @override
  String get reliabilityBoot => 'बूट पर शुरू करें';

  @override
  String get reliabilityBootHint =>
      'फ़ोन रीस्टार्ट होने के बाद खाते रजिस्टर करें';

  @override
  String get reliabilityWake => 'निष्क्रिय होने पर CPU जागा रखें';

  @override
  String get reliabilityWakeHint =>
      'सख़्त डिवाइस पर अधिक भरोसेमंद; ज़्यादा बैटरी खर्च होती है';

  @override
  String acctEditorDeleteTitle(String name) {
    return '$name हटाएँ?';
  }

  @override
  String acctCodecRemove(String codec) {
    return '$codec हटाएँ';
  }

  @override
  String acctEditorLastError(String error) {
    return 'आखिरी त्रुटि: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'अनुमत सीमा $min से $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'कम से कम $min होना चाहिए';
  }

  @override
  String acctValidateMax(int max) {
    return 'अधिकतम $max होना चाहिए';
  }

  @override
  String get acctEditorDiscardTitle => 'बदलाव छोड़ें?';

  @override
  String get acctEditorDiscardMessage =>
      'इस खाते में किए गए आपके बदलाव सहेजे नहीं गए हैं।';

  @override
  String get acctEditorDiscardConfirm => 'छोड़ें';

  @override
  String get acctEditorDeleteMessage =>
      'खाता और उसका सहेजा गया पासवर्ड इस डिवाइस से हटा दिया जाएगा।';

  @override
  String get acctEditorMenuDelete => 'खाता हटाएँ';

  @override
  String get acctGroupBasic => 'बुनियादी';

  @override
  String get acctFieldLabel => 'लेबल';

  @override
  String get acctFieldLabelHint => 'जैसे ऑफ़िस';

  @override
  String get acctFieldDisplayName => 'प्रदर्शित नाम';

  @override
  String get acctFieldUsername => 'उपयोगकर्ता नाम';

  @override
  String get acctFieldProtocol => 'प्रोटोकॉल';

  @override
  String get acctFieldProtocolSub => 'खाता बनाते समय तय होता है';

  @override
  String get acctFieldAuthUser => 'ऑथराइज़ेशन उपयोगकर्ता';

  @override
  String get acctFieldAuthUserHint => 'उपयोगकर्ता नाम जैसा ही';

  @override
  String get acctFieldAuthUserSub =>
      'केवल तब, जब प्रदाता उपयोगकर्ता नाम से अलग लॉगिन नाम इस्तेमाल करता हो';

  @override
  String get acctFieldPassword => 'पासवर्ड';

  @override
  String get acctFieldServerHost => 'सर्वर होस्ट';

  @override
  String get acctFieldPort => 'पोर्ट';

  @override
  String get acctFieldIaxPortSub => 'IAX2 का डिफ़ॉल्ट 4569 है';

  @override
  String get acctFieldIaxContext => 'कॉन्टेक्स्ट';

  @override
  String get acctFieldIaxContextSub =>
      'वैकल्पिक। PBX को डायल किए गए कॉन्टेक्स्ट के रूप में भेजा जाता है';

  @override
  String get acctFieldServerDomain => 'सर्वर / डोमेन';

  @override
  String get acctFieldServerDomainSub => 'host या host:port';

  @override
  String get acctFieldEnabled => 'सक्षम';

  @override
  String get acctFieldDefault => 'आउटगोइंग कॉल के लिए डिफ़ॉल्ट खाता';

  @override
  String get acctFieldColour => 'रंग';

  @override
  String get acctGroupRegistration => 'रजिस्ट्रेशन';

  @override
  String get acctFieldRegister => 'रजिस्टर करें';

  @override
  String get acctFieldRegisterSubIax =>
      'जिन पीयर को रजिस्ट्रेशन नहीं चाहिए उनके लिए बंद करें';

  @override
  String get acctFieldRegExpiry => 'रजिस्ट्रेशन समाप्ति (से)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk आम तौर पर 60 से लागू करता है। सीमा 10 से 86400';

  @override
  String get acctFieldRetryInterval => 'पुनः प्रयास अंतराल (से)';

  @override
  String get acctFieldFirstRetry => 'पहला पुनः प्रयास (से)';

  @override
  String get acctGroupCodecs => 'कोडेक';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 में G.711 और GSM समर्थित हैं। प्राथमिकता क्रम तय करने के लिए खींचें।';

  @override
  String get acctCodecAdd => 'कोडेक जोड़ें';

  @override
  String get acctGroupServerTransport => 'सर्वर और ट्रांसपोर्ट';

  @override
  String get acctFieldRegistrar => 'रजिस्ट्रार ओवरराइड';

  @override
  String get acctFieldBackupRegistrar => 'बैकअप रजिस्ट्रार';

  @override
  String get acctFieldBackupRegistrarSub =>
      '3 असफल प्रयासों के बाद उपयोग होता है; प्राथमिक को हर 5 मिनट में फिर आज़माया जाता है';

  @override
  String get acctFieldProxies => 'आउटबाउंड प्रॉक्सी';

  @override
  String get acctFieldTransport => 'ट्रांसपोर्ट';

  @override
  String get acctFieldTransportAutoSub =>
      'सर्वर के DNS SRV रिकॉर्ड देखकर TLS, TCP या UDP चुनता है';

  @override
  String get acctTransportAuto => 'स्वचालित (DNS SRV)';

  @override
  String get acctFieldWsPath => 'WebSocket पाथ';

  @override
  String get acctFieldWsPathSub =>
      'WebSocket अपग्रेड का HTTP पाथ, जैसे /ws। \"/\" से शुरू होना चाहिए';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 से 3600 सामान्य है। सीमा 10 से 86400';

  @override
  String get acctFieldKeepAlive => 'कीप-अलाइव (से)';

  @override
  String get acctFieldKeepAliveSub =>
      'UDP कीप-अलाइव अंतराल। 0 से बंद होता है। सीमा 0 से 3600';

  @override
  String get acctFieldLocalPort => 'स्थानीय SIP पोर्ट';

  @override
  String get acctFieldLocalPortSub =>
      '0 साझा ट्रांसपोर्ट का उपयोग करता है। सीमा 0 से 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'बिना रजिस्ट्रेशन वाले ट्रंक के लिए बंद करें';

  @override
  String get acctFieldSipOutbound => 'SIP आउटबाउंड (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'NAT के पार स्थायी फ़्लो बनाए रखता है। सर्वर समर्थन चाहिए';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'STUN उपयोग करें';

  @override
  String get acctFieldTurn => 'TURN रिले';

  @override
  String get acctFieldTurnServer => 'TURN सर्वर';

  @override
  String get acctFieldTurnUsername => 'TURN उपयोगकर्ता नाम';

  @override
  String get acctFieldTurnPassword => 'TURN पासवर्ड';

  @override
  String get acctFieldContactRewrite => 'Contact हेडर फिर से लिखें';

  @override
  String get acctFieldViaRewrite => 'Via हेडर फिर से लिखें';

  @override
  String get acctFieldRewriteSub =>
      'सर्वर को दिखने वाले पते का उपयोग करें। NAT के पीछे चालू रखें';

  @override
  String get acctFieldSdpRewrite => 'SDP पता फिर से लिखें';

  @override
  String get acctFieldSdpRewriteSub =>
      'SDP में मीडिया पते की जगह सार्वजनिक पता लगाएँ';

  @override
  String get acctFieldIpv6Sip => 'IPv6 सिग्नलिंग';

  @override
  String get acctFieldIpv6Media => 'IPv6 मीडिया';

  @override
  String get acctGroupAdvancedMedia => 'उन्नत मीडिया';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTC गेटवे को RTCP मल्टीप्लेक्सिंग और RTCP फ़ीडबैक चाहिए।';

  @override
  String get acctFieldRtcpMux => 'RTCP मल्टीप्लेक्सिंग';

  @override
  String get acctFieldRtcpMuxSub =>
      'RTP और RTCP एक ही पोर्ट पर भेजें (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'RTCP फ़ीडबैक (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'NACK के साथ RTP/AVPF प्रस्तावित करें। WebRTC सर्वरों के लिए ज़रूरी';

  @override
  String get acctGroupSecurity => 'सुरक्षा';

  @override
  String get acctFieldSrtp => 'मीडिया एन्क्रिप्शन (SRTP)';

  @override
  String get acctOptOptional => 'वैकल्पिक';

  @override
  String get acctOptRequired => 'अनिवार्य';

  @override
  String get acctFieldKeyExchange => 'कुंजी विनिमय';

  @override
  String get acctFieldSecureSignaling => 'सुरक्षित सिग्नलिंग';

  @override
  String get acctOptNotRequired => 'ज़रूरी नहीं';

  @override
  String get acctOptTlsHop => 'TLS हॉप-बाय-हॉप';

  @override
  String get acctOptTlsE2e => 'TLS एंड-टू-एंड (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'ऑथ एल्गोरिद्म';

  @override
  String get acctFieldPrivacy => 'कॉलर ID छिपाएँ (गोपनीयता)';

  @override
  String get acctFieldReferPolicy => 'इनकमिंग ट्रांसफ़र (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'उपस्थिति देखने वाले';

  @override
  String get acctOptAccept => 'स्वीकारें';

  @override
  String get acctOptReject => 'अस्वीकार करें';

  @override
  String get acctGroupCodecsFooter =>
      'इस खाते के लिए ग्लोबल कोडेक सूची को ओवरराइड करता है।';

  @override
  String get acctFieldUseGlobalCodecs => 'ग्लोबल कोडेक क्रम उपयोग करें';

  @override
  String get acctGroupFeatures => 'सुविधाएँ';

  @override
  String get acctFieldVoicemailNumber => 'वॉइसमेल नंबर';

  @override
  String get acctFieldMwi => 'वॉइसमेल संकेतक (MWI)';

  @override
  String get acctFieldMwiSub => 'संदेश-प्रतीक्षा सूचनाओं की सदस्यता लें';

  @override
  String get acctFieldPublishPresence => 'मेरी उपस्थिति प्रकाशित करें';

  @override
  String get acctFieldPublishPresenceSub =>
      'सर्वर को आपकी ऑनलाइन स्थिति साझा करने दें';

  @override
  String get acctFieldDnd => 'परेशान न करें';

  @override
  String get acctFieldForwarding => 'कॉल फ़ॉरवर्डिंग';

  @override
  String get acctOptForwardAlways => 'हमेशा';

  @override
  String get acctOptForwardBusy => 'व्यस्त होने पर';

  @override
  String get acctOptForwardNoAnswer => 'जवाब न मिलने पर';

  @override
  String get acctFieldForwardTo => 'यहाँ फ़ॉरवर्ड करें';

  @override
  String get acctFieldForwardToHint => 'नंबर या SIP पता';

  @override
  String get acctFieldRingFor => 'इतनी देर बजाएँ (से)';

  @override
  String get acctFieldAutoAnswer => 'ऑटो-आंसर';

  @override
  String get acctFieldAnswerAfter => 'इतने बाद उठाएँ (से)';

  @override
  String get acctFieldIntercomOnly => 'केवल इंटरकॉम कॉल के लिए';

  @override
  String get acctFieldIntercomOnlySub => 'PBX से ऑटो-आंसर हेडर चाहिए';

  @override
  String get acctFieldRingtone => 'रिंगटोन';

  @override
  String get acctRingtoneClassic => 'क्लासिक';

  @override
  String get acctRingtoneSoft => 'सॉफ़्ट';

  @override
  String get acctRingtoneDigital => 'डिजिटल';

  @override
  String get acctFieldRecordCalls => 'कॉल रिकॉर्ड करें';

  @override
  String get acctFieldHoldMusic => 'होल्ड म्यूज़िक';

  @override
  String get acctOptUseGlobal => 'ग्लोबल सेटिंग उपयोग करें';

  @override
  String get acctOptPbxDefault => 'PBX डिफ़ॉल्ट';

  @override
  String get acctFieldOpeningAnnouncement => 'शुरुआती घोषणा';

  @override
  String get acctGroupFeatureCodes => 'फ़ीचर कोड';

  @override
  String get acctGroupFeatureCodesFooter =>
      'आपके PBX पर पार्क, पिकअप, DND और फ़ॉरवर्डिंग के लिए डायल किए जाते हैं।';

  @override
  String get acctFieldPark => 'पार्क';

  @override
  String get acctFieldGroupPickup => 'ग्रुप पिकअप';

  @override
  String get acctFieldDirectedPickup => 'डायरेक्टेड पिकअप उपसर्ग';

  @override
  String get acctFieldParkRetrieve => 'पार्क रिट्रीव उपसर्ग';

  @override
  String get acctFieldParkRetrieveHint => 'स्लॉट नंबर डायल करें';

  @override
  String get acctFieldParkRetrieveSub =>
      'पार्क की गई कॉल वापस लेने के लिए पार्क स्लॉट से पहले डायल किया जाने वाला उपसर्ग';

  @override
  String get acctFieldDndOn => 'DND चालू';

  @override
  String get acctFieldDndOff => 'DND बंद';

  @override
  String get acctFieldForwardOn => 'फ़ॉरवर्ड चालू';

  @override
  String get acctFieldForwardOff => 'फ़ॉरवर्ड बंद';

  @override
  String get acctGroupAdvanced => 'उन्नत';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF नेटिव IAX2 फ़्रेम के रूप में भेजा जाता है।';

  @override
  String get acctFieldCallerIdOverride => 'कॉलर ID ओवरराइड';

  @override
  String get acctFieldCallerIdHint => 'खाते का डिफ़ॉल्ट उपयोग करें';

  @override
  String get acctFieldCallerIdSub =>
      'PBX को भेजा जाने वाला कॉलर ID नाम या नंबर';

  @override
  String get acctFieldSessionTimers => 'सेशन टाइमर';

  @override
  String get acctFieldSessionExpires => 'सेशन समाप्ति (से)';

  @override
  String get acctFieldSessionExpiresSub => 'सीमा 90 से 86400';

  @override
  String get acctField100rel => '100rel (विश्वसनीय अनंतिम)';

  @override
  String get acctFieldHoldMethod => 'होल्ड तरीका';

  @override
  String get acctFieldDtmfMethod => 'DTMF तरीका';

  @override
  String get acctOptDtmfInband => 'इन-बैंड';

  @override
  String get acctFieldRedirects => 'रीडायरेक्ट (3xx)';

  @override
  String get acctOptRedirectFollow => 'अनुसरण करें';

  @override
  String get acctOptRedirectAsk => 'पूछें';

  @override
  String get acctFieldLockCodec => 'कॉल उठाने के बाद कोडेक लॉक करें';

  @override
  String get acctFieldMediaKeepAlive => 'मीडिया कीप-अलाइव';

  @override
  String get acctFieldDropCalls => 'रजिस्ट्रेशन विफल होने पर कॉल गिराएँ';

  @override
  String get acctFieldExtraHeaders => 'अतिरिक्त SIP हेडर';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: मान (प्रति पंक्ति एक)';

  @override
  String get acctFieldRetryIntervalSub =>
      'विफल रजिस्ट्रेशन को फिर आज़माने से पहले प्रतीक्षा। सीमा 0 से 86400';

  @override
  String get acctFieldUnregTimeout => 'अनरजिस्टर टाइमआउट (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'अनरजिस्टर के उत्तर की कितनी प्रतीक्षा करनी है। सीमा 0 से 60000';

  @override
  String get acctFieldMwiExpiry => 'MWI सदस्यता समाप्ति (से)';

  @override
  String get acctFieldDscpSip => 'SIP के लिए DSCP';

  @override
  String get acctFieldDscpSipSub =>
      'सिग्नलिंग की QoS मार्किंग। 24 (CS3) सामान्य है';

  @override
  String get acctFieldDscpRtp => 'RTP के लिए DSCP';

  @override
  String get acctFieldDscpRtpSub =>
      'मीडिया की QoS मार्किंग। 46 (EF) सामान्य है';

  @override
  String get acctFieldReinvite => 'नेटवर्क बदलने के बाद Re-INVITE';

  @override
  String get acctFieldHangupOnIpChange => 'नेटवर्क बदलने पर कॉल काटें';

  @override
  String get acctValidateInt => 'पूर्ण संख्या दर्ज करें';

  @override
  String get acctValidateHostEmpty => 'सर्वर होस्ट नाम या पता दर्ज करें';

  @override
  String get acctValidateHostSpaces => 'सर्वर में स्पेस नहीं हो सकते';

  @override
  String get acctValidateHostFormat => 'केवल host या host:port दर्ज करें';

  @override
  String get acctValidatePortRange => 'पोर्ट 1 से 65535 के बीच होना चाहिए';

  @override
  String get acctValidateWsStart => 'पाथ \"/\" से शुरू होना चाहिए';

  @override
  String get acctValidateWsLength => 'अधिकतम 120 अक्षर उपयोग करें';

  @override
  String get acctValidateWsSpaces => 'पाथ में स्पेस नहीं हो सकते';

  @override
  String get acctTplAsteriskDescription =>
      'आपके अपने PBX पर एक्सटेंशन। UDP 5060, STUN चालू।';

  @override
  String get acctTplAsteriskNotes =>
      'PJSIP/SIP एक्सटेंशन नंबर और उसका सीक्रेट उपयोग करें। TLS या WebRTC के लिए ट्रांसपोर्ट बाद में खाता सेटिंग में बदलें।';

  @override
  String get acctTplAsteriskUsernameHint => 'एक्सटेंशन (जैसे 1001)';

  @override
  String get acctTpl3cxDescription =>
      '3CX पोर्टल से एक्सटेंशन, ऑथ ID और पासवर्ड उपयोग करें।';

  @override
  String get acctTpl3cxNotes =>
      '3CX में एक्सटेंशन खोलें, फिर ऑथेंटिकेशन ID (इसे ऑथराइज़ेशन उपयोगकर्ता के रूप में सेट करें) और पासवर्ड के लिए \"Phones > Provisioning\" खोलें। FQDN वही है जो आपके 3CX URL में है।';

  @override
  String get acctTpl3cxUsernameHint => 'एक्सटेंशन';

  @override
  String get acctTplFreeswitchDescription =>
      'FreeSWITCH सर्वर पर डायरेक्टरी उपयोगकर्ता।';

  @override
  String get acctTplFreeswitchNotes =>
      'डायरेक्टरी से उपयोगकर्ता ID और पासवर्ड उपयोग करें। डिफ़ॉल्ट internal प्रोफ़ाइल UDP/TCP 5060 पर सुनती है।';

  @override
  String get acctTplFreeswitchUsernameHint => 'उपयोगकर्ता ID';

  @override
  String get acctTplKamailioDescription =>
      'SIP प्रॉक्सी रजिस्ट्रार। NAT के पीछे TCP की सलाह दी जाती है।';

  @override
  String get acctTplKamailioNotes =>
      'अपने रजिस्ट्रार द्वारा सेवा दिया जाने वाला SIP डोमेन उपयोग करें। यदि रजिस्ट्रार किसी दूसरे होस्ट से पहुँचा जाता है, तो खाता सेटिंग में आउटबाउंड प्रॉक्सी जोड़ें।';

  @override
  String get acctTplTwilioDescription =>
      'Programmable Voice SIP Domain क्रेडेंशियल। TLS और SRTP।';

  @override
  String get acctTplTwilioNotes =>
      'Twilio कंसोल में SIP Domain बनाएँ, Credential List जोड़ें और SIP Registration चालू करें। सर्वर के रूप में पूरा डोमेन (name.sip.twilio.com) और क्रेडेंशियल सूची का उपयोगकर्ता और पासवर्ड दर्ज करें। TLS पोर्ट 5061 उपयोग करता है। Twilio केवल G.711 समर्थित करता है।';

  @override
  String get acctTplTwilioUsernameHint => 'क्रेडेंशियल सूची का उपयोगकर्ता नाम';

  @override
  String get acctTplTelnyxDescription =>
      'क्रेडेंशियल कनेक्शन। UDP, G.711 / Opus।';

  @override
  String get acctTplTelnyxNotes =>
      'Telnyx पोर्टल में Credential Connection बनाएँ और उसका SIP उपयोगकर्ता नाम और पासवर्ड कॉपी करें (आपका पोर्टल लॉगिन नहीं)। कॉल करने और पाने के लिए कनेक्शन में कोई नंबर या आउटबाउंड वॉइस प्रोफ़ाइल असाइन करें।';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP उपयोगकर्ता नाम (क्रेडेंशियल कनेक्शन)';

  @override
  String get acctTplVoipmsDescription =>
      'सब-अकाउंट का उपयोगकर्ता नाम और पासवर्ड। अपने सबसे नज़दीकी POP को चुनें।';

  @override
  String get acctTplVoipmsNotes =>
      'Sub Accounts के अंतर्गत बनाया गया सब-अकाउंट उपयोग करें, मुख्य खाता नहीं। VoIP.ms सर्वर सूची से अपने सबसे नज़दीकी सर्वर (POP) को चुनें और ज़रूरत हो तो अपने IP के लिए उसकी अनुमति दें।';

  @override
  String get acctTplVoipmsUsernameHint => 'सब-अकाउंट (जैसे 123456_phone)';

  @override
  String get acctTplVonageDescription => 'TLS के साथ SIP रजिस्ट्रेशन।';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business केवल कुछ प्लान पर SIP रजिस्ट्रेशन देता है। Vonage एडमिन पोर्टल में डिवाइस के लिए दिखाया गया SIP सर्वर, उपयोगकर्ता और पासवर्ड दर्ज करें।';

  @override
  String get acctTplIax2Description =>
      'UDP 4569 पर Inter-Asterisk eXchange। कोई NAT या SRTP सेटिंग नहीं।';

  @override
  String get acctTplIax2Notes =>
      'iax.conf में उसी सीक्रेट के साथ एक पीयर/यूज़र (type=friend या user+peer) चाहिए। Asterisk डिफ़ॉल्ट रूप से IAX2 रजिस्ट्रेशन हर 60 से में नवीनीकृत करता है। कॉन्टेक्स्ट वैकल्पिक है और डायल किए गए कॉन्टेक्स्ट के रूप में भेजा जाता है।';

  @override
  String get acctTplIax2UsernameHint => 'IAX2 उपयोगकर्ता नाम';

  @override
  String get acctTplWebrtcDescription =>
      'DTLS-SRTP, ICE और RTCP-mux के साथ सुरक्षित WebSocket पर SIP।';

  @override
  String get acctTplWebrtcNotes =>
      'Asterisk (webrtc=yes, http.conf में 8089 पर TLS), FreeSWITCH या Kamailio WebSocket एंडपॉइंट के लिए। सर्वर के पास मान्य TLS प्रमाणपत्र होना चाहिए। यदि आपका गेटवे /ws उपयोग नहीं करता, तो खाता सेटिंग में WebSocket पाथ बदलें।';

  @override
  String get acctTplGenericDescription =>
      'कोई भी SIP रजिस्ट्रार। विवरण खुद भरें।';

  @override
  String get acctTplDefaultUsernameHint => 'एक्सटेंशन / उपयोगकर्ता नाम';

  @override
  String get appEngineFailedBody =>
      'इसे ठीक किए जाने तक कॉल और रजिस्ट्रेशन काम नहीं करेंगे। आम तौर पर इसका कारण खराब नेटवर्क या प्रमाणपत्र सेटिंग होती है।';

  @override
  String get appEngineFailedTitle => 'कॉलिंग इंजन शुरू नहीं हो सका';

  @override
  String get appEngineNotRunning => 'कॉलिंग इंजन नहीं चल रहा है';

  @override
  String get appUnknownError => 'अज्ञात त्रुटि';

  @override
  String get appEngineOpenNetworkSettings => 'नेटवर्क सेटिंग खोलें';

  @override
  String get appEngineUseSimulator => 'सिम्युलेटर उपयोग करें (डेमो)';

  @override
  String get appDbLockedTitle => 'आपका डेटा लॉक है';

  @override
  String get appDbUnreadableTitle => 'आपका डेटा खोला नहीं जा सकता';

  @override
  String get appDbLockedBody =>
      'कॉल इतिहास, संपर्क और संदेश इस डिवाइस पर एन्क्रिप्टेड हैं, लेकिन एन्क्रिप्शन कुंजी अब सिस्टम कीचेन / कीस्टोर में नहीं है (उदाहरण के लिए कीचेन रीसेट या नए डिवाइस पर रीस्टोर के बाद)।';

  @override
  String get appDbUnreadableBody =>
      'स्थानीय डेटाबेस पढ़ा नहीं जा सका। वह क्षतिग्रस्त हो सकता है, या एन्क्रिप्शन कुंजी मेल नहीं खाती।';

  @override
  String get appDbRecoveryAdvice =>
      'यदि आपको कुंजी वापस मिलने की उम्मीद है तो फिर कोशिश करें (कीचेन अनलॉक करें, सही उपयोगकर्ता में साइन इन करें)। नए सिरे से शुरू करने पर पुरानी फ़ाइल ऐप डेटा के पास रखी रहती है, लेकिन इतिहास, संपर्क और संदेश खाली से शुरू होते हैं; आपको अपने खाते फिर से जोड़ने होंगे।';

  @override
  String get appDbCopyDetails => 'विवरण कॉपी करें';

  @override
  String get appDbTryAgain => 'फिर कोशिश करें';

  @override
  String get appDbStartFresh => 'नए सिरे से शुरू करें';

  @override
  String get appRedirectTitle => 'कॉल रीडायरेक्ट हुई';

  @override
  String appRedirectMessage(String target) {
    return 'कॉल $target पर रीडायरेक्ट हुई - आगे बढ़ें?';
  }

  @override
  String get appRedirectCancelCall => 'कॉल रद्द करें';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'आपका डेटा एन्क्रिप्ट नहीं हो सका ($error)। कुछ भी नहीं बदला गया।',
      'other':
          'आपका डेटा डिक्रिप्ट नहीं हो सका ($error)। कुछ भी नहीं बदला गया।',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'नेटिव इंजन उपलब्ध नहीं है ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return '$time पर फिर कोशिश होगी';
  }

  @override
  String get acctRegistrationError => 'रजिस्ट्रेशन त्रुटि';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nट्रांसपोर्ट: $transport';
  }

  @override
  String get acctCallingFromDirect => 'सीधे कॉल कर रहे हैं, कोई खाता नहीं';

  @override
  String acctCallingFromAccount(String name) {
    return '$name से कॉल कर रहे हैं';
  }

  @override
  String get acctCallingFromNone => 'किसी खाते से कॉल नहीं हो रही';

  @override
  String get acctNoAccount => 'कोई खाता नहीं';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds से';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount नए, $oldCount पुराने';
  }

  @override
  String get acctAddAccount => 'खाता जोड़ें';

  @override
  String get acctUnregister => 'अनरजिस्टर करें';

  @override
  String get acctSheetDndSub => 'इस खाते पर इनकमिंग कॉल अस्वीकार करें';

  @override
  String get acctKvServer => 'सर्वर';

  @override
  String get acctKvResolvedServer => 'रिज़ॉल्व्ड सर्वर';

  @override
  String get acctKvClientCert => 'क्लाइंट प्रमाणपत्र';

  @override
  String get acctKvClientCertValue =>
      'सर्वर को प्रस्तुत किया गया (म्यूचुअल TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'समाप्ति में';

  @override
  String get acctKvVoicemail => 'वॉइसमेल';

  @override
  String get acctOpenSipTrace => 'SIP ट्रेस खोलें';

  @override
  String get acctAddAnAccount => 'खाता जोड़ें';

  @override
  String get acctChooseAccountTooltip => 'कॉल करने के लिए खाता चुनें';

  @override
  String get acctDirectNoAccount => 'सीधे (कोई खाता नहीं)';

  @override
  String get onboardingRequired => 'उपयोगकर्ता नाम और सर्वर ज़रूरी हैं';

  @override
  String onboardingDefaultPortHelper(int port) {
    return ':port न जोड़ने पर पोर्ट $port उपयोग होता है';
  }

  @override
  String get onboardingFineTuneIax =>
      'कोडेक और रजिस्ट्रेशन को आप बाद में सेटिंग में बारीकी से बदल सकते हैं।';

  @override
  String get onboardingFineTuneSip =>
      'ट्रांसपोर्ट, NAT, सुरक्षा और कोडेक को आप बाद में सेटिंग में बारीकी से बदल सकते हैं।';

  @override
  String get onboardingDemoUser => 'डेमो उपयोगकर्ता';

  @override
  String get onboardingDemoAccount => 'डेमो खाता';

  @override
  String get onboardingWelcomeTitle => 'SoftphonePro में आपका स्वागत है';

  @override
  String get onboardingWelcomeText =>
      'हर प्लैटफ़ॉर्म के लिए पेशेवर कॉलिंग - मुफ़्त और ओपन सोर्स। न विज्ञापन, न ट्रैकिंग।';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingPermissionsTitle => 'अनुमतियाँ';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro को आपकी आवाज़ पहुँचाने के लिए माइक्रोफ़ोन और इनकमिंग कॉल व संदेशों की सूचना देने के लिए नोटिफ़िकेशन चाहिए। आपकी कॉल के अलावा कुछ भी आपके डिवाइस से बाहर नहीं जाता।';

  @override
  String get onboardingChooseProvider => 'अपना प्रदाता चुनें';

  @override
  String get onboardingChooseProviderSub =>
      'हम आपके लिए ट्रांसपोर्ट, पोर्ट और NAT सेटिंग पहले से भर देते हैं।';

  @override
  String get onboardingScanQr => 'QR स्कैन करें';

  @override
  String get onboardingImportUrl => 'URL से इंपोर्ट करें';

  @override
  String get onboardingSkip => 'अभी छोड़ें (डेमो मोड)';

  @override
  String get onboardingHidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get onboardingShowPassword => 'पासवर्ड दिखाएँ';

  @override
  String get onboardingContextOptional => 'कॉन्टेक्स्ट (वैकल्पिक)';

  @override
  String get onboardingDisplayNameOptional => 'प्रदर्शित नाम (वैकल्पिक)';

  @override
  String get onboardingLabelOptional => 'खाता लेबल (वैकल्पिक)';

  @override
  String get onboardingCallerIdOptional => 'कॉलर ID (वैकल्पिक)';

  @override
  String get onboardingAuthUserOptional => 'ऑथराइज़ेशन उपयोगकर्ता (यदि अलग हो)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'गलत उपयोगकर्ता नाम या पासवर्ड ($code)';
  }

  @override
  String get acctRegNotFound => 'सर्वर पर खाता नहीं मिला (404)';

  @override
  String get acctRegNoAnswer => 'सर्वर ने उत्तर नहीं दिया (408)';

  @override
  String get acctRegIntervalTooShort => 'रजिस्ट्रेशन अंतराल बहुत छोटा है (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'सर्वर अस्थायी रूप से अनुपलब्ध है (480)';

  @override
  String get acctRegServiceUnavailable => 'सेवा अनुपलब्ध है (503)';

  @override
  String get acctRegFailed => 'रजिस्ट्रेशन विफल रहा';

  @override
  String acctRegFailedWithCode(int code) {
    return 'रजिस्ट्रेशन विफल रहा ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'रजिस्ट्रेशन बदला नहीं जा सका';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'खाता \"$name\" लागू नहीं किया जा सका';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return '$name के लिए प्राथमिक सर्वर पर वापस';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return '$name के लिए बैकअप सर्वर उपयोग हो रहा है';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'खाता $name रजिस्टर्ड है';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'खाता $name अभी रजिस्टर हो रहा है';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'खाता $name अभी रजिस्टर नहीं हुआ है';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'खाता $name रजिस्टर नहीं है (रजिस्ट्रेशन विफल)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'खाता $name अक्षम है';
  }

  @override
  String get callDialEngineFailed => 'कॉल इंजन शुरू नहीं हो सका';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'कॉल इंजन शुरू नहीं हो सका: $reason';
  }

  @override
  String get callDialEngineStarting => 'कॉल इंजन अभी शुरू हो रहा है';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status, $seconds से बाद भी; कॉल नहीं लगाई गई';
  }

  @override
  String get callJournalInterrupted => 'कॉल के दौरान ऐप बंद हो गया था';

  @override
  String get callLinkMissingArgument => 'आर्ग्युमेंट गायब है';

  @override
  String get callLinkHttpsRequired =>
      'कॉन्फ़िगरेशन लिंक https का उपयोग करने चाहिए';

  @override
  String get callLinkInvalidLan => 'यह LAN लिंक मान्य नहीं है';

  @override
  String callLinkConnectedTo(String name) {
    return '$name से जुड़ गए';
  }

  @override
  String get callLinkConnectFailed => 'उस डिवाइस से जुड़ा नहीं जा सका';

  @override
  String callLinkCallFailed(String target) {
    return '$target को कॉल नहीं लगाई जा सकी';
  }

  @override
  String get callLinkImportTitle => 'कॉन्फ़िगरेशन इंपोर्ट करें';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts खाते',
      one: '1 खाता',
    );
    return '$host से कॉन्फ़िगरेशन इंपोर्ट करें? यह $_temp0 जोड़ेगा।';
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
      other: '$accounts खाते',
      one: '1 खाता',
    );
    return '$host से कॉन्फ़िगरेशन इंपोर्ट करें? यह $_temp0 और $settings सेटिंग जोड़ेगा।';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return '$number से फ़ॉरवर्ड किया गया';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return '$number से फ़ॉरवर्ड किया गया ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return '$number द्वारा ट्रांसफ़र किया गया';
  }

  @override
  String get callRingtoneSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get callRingtoneClassic => 'क्लासिक';

  @override
  String get callRingtoneSoft => 'सॉफ़्ट';

  @override
  String get callRingtoneDigital => 'डिजिटल';

  @override
  String callIdentityFrom(String number) {
    return '$number से';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'कॉलर ID $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'कॉलर ID $name $number';
  }

  @override
  String get callTransferring => 'ट्रांसफ़र हो रहा है...';

  @override
  String get callTransferNotConfirmed => 'सर्वर ने ट्रांसफ़र की पुष्टि नहीं की';

  @override
  String get callTransferStalledHint =>
      'कॉल अभी जारी है। इसे रखें, या ट्रांसफ़र फिर से भेजें।';

  @override
  String get callTransferKeepCall => 'कॉल रखें';

  @override
  String get callAnnouncementOpening => 'घोषणा बज रही है…';

  @override
  String get callAnnouncementTransfer => 'ट्रांसफ़र सूचना बज रही है…';

  @override
  String get callAnnouncementRecording => 'रिकॉर्डिंग सूचना बज रही है…';

  @override
  String get callAnnouncementSkip => 'छोड़ें';

  @override
  String get callNoiseTooltipMic => 'AI नॉइज़ कैंसलेशन: आपका माइक्रोफ़ोन';

  @override
  String get callNoiseTooltipIncoming => 'AI नॉइज़ कैंसलेशन: अन्य प्रतिभागी';

  @override
  String get callNoiseTooltipBoth =>
      'AI नॉइज़ कैंसलेशन: आपका माइक्रोफ़ोन और अन्य प्रतिभागी';

  @override
  String get callNoiseOn => 'नॉइज़ कैंसलेशन चालू';

  @override
  String get callNoiseTitle => 'नॉइज़ कैंसलेशन';

  @override
  String callNoiseMicStrength(String strength) {
    return 'मेरा माइक्रोफ़ोन: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'मेरे माइक्रोफ़ोन से पृष्ठभूमि का शोर हटाएँ';

  @override
  String get callResultAnswered => 'उठाई गई';

  @override
  String get callResultMissed => 'छूटी';

  @override
  String get callResultRejected => 'अस्वीकृत';

  @override
  String get callResultFailed => 'विफल';

  @override
  String get callResultBusy => 'व्यस्त';

  @override
  String get callResultForwarded => 'फ़ॉरवर्ड की गई';

  @override
  String get callResultTransferred => 'ट्रांसफ़र की गई';

  @override
  String get callResultHandedOff => 'सौंपी गई';

  @override
  String get callResultInterrupted => 'बाधित';

  @override
  String get keypadCall => 'कॉल';

  @override
  String get keypadNoVoicemail => 'इस खाते के लिए कोई वॉइसमेल नंबर सेट नहीं है';

  @override
  String get keypadCallDirectly => 'सीधे कॉल करें (कोई खाता नहीं)';

  @override
  String get keypadAddAccount => 'कॉल करने के लिए खाता जोड़ें';

  @override
  String keypadCallFrom(String account) {
    return '$account से कॉल करें';
  }

  @override
  String get keypadRecent => 'हालिया';

  @override
  String get keypadSuggestions => 'सुझाव';

  @override
  String get keypadPhoneNumber => 'फ़ोन नंबर';

  @override
  String get keypadPaste => 'पेस्ट करें';

  @override
  String get keypadEnterNumber => 'नंबर दर्ज करें';

  @override
  String get keypadBackspace => 'बैकस्पेस (साफ़ करने के लिए देर तक दबाएँ)';

  @override
  String get keypadTypeNameOrNumber => 'नाम या नंबर टाइप करें';

  @override
  String get keypadNoMatches => 'कोई मिलान नहीं';

  @override
  String get keypadSuggestionsHint => 'सुझाव संपर्कों और हालिया कॉल से आते हैं';

  @override
  String keypadCallPerson(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get dialKeyStar => 'स्टार';

  @override
  String get dialKeyPound => 'पाउंड';

  @override
  String get dialKeyLongPressPlus => 'प्लस के लिए देर तक दबाएँ';

  @override
  String get dialKeyLongPressSpeedDial => 'स्पीड डायल के लिए देर तक दबाएँ';

  @override
  String get dialKeyLongPressVoicemail => 'वॉइसमेल के लिए देर तक दबाएँ';

  @override
  String get callBackToApp => 'ऐप पर वापस (कॉल जारी रहेगी)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'कीपैड छिपाएँ';

  @override
  String get callMute => 'म्यूट';

  @override
  String get callKeypad => 'कीपैड';

  @override
  String get callSpeaker => 'स्पीकर';

  @override
  String get callRouteBluetooth => 'ब्लूटूथ';

  @override
  String get callRouteHeadset => 'हेडसेट';

  @override
  String get callResume => 'फिर शुरू';

  @override
  String get callHold => 'होल्ड';

  @override
  String get callAddCall => 'कॉल जोड़ें';

  @override
  String get callTransfer => 'ट्रांसफ़र';

  @override
  String get callStop => 'रोकें';

  @override
  String get callRecord => 'रिकॉर्ड';

  @override
  String get callSplit => 'अलग करें';

  @override
  String get callMerge => 'मर्ज करें';

  @override
  String get callSwap => 'अदला-बदली';

  @override
  String get callEndCall => 'कॉल समाप्त करें';

  @override
  String callEndCallWith(String name) {
    return '$name के साथ कॉल समाप्त करें';
  }

  @override
  String get callAttendedTransferHint =>
      'अटेंडेड ट्रांसफ़र। मूल कॉल करने वाला होल्ड पर है।';

  @override
  String get callCompleteTransfer => 'ट्रांसफ़र पूरा करें';

  @override
  String get callWaiting => 'कॉल वेटिंग';

  @override
  String get callHoldAndAnswer => 'मौजूदा कॉल होल्ड करें और उठाएँ';

  @override
  String get callDecline => 'अस्वीकार करें';

  @override
  String get callAnswer => 'उठाएँ';

  @override
  String get callIncomingCall => 'इनकमिंग कॉल';

  @override
  String get callReply => 'जवाब';

  @override
  String get callVoicemail => 'वॉइसमेल';

  @override
  String get callToDevice => 'डिवाइस पर';

  @override
  String get callQuickReplyBusy =>
      'अभी बात नहीं कर सकता, मैं आपको वापस कॉल करूँगा।';

  @override
  String get callQuickReplyMeeting => 'मैं मीटिंग में हूँ। मैसेज करें?';

  @override
  String get callQuickReplyOnMyWay => 'रास्ते में हूँ।';

  @override
  String callReturnToCallWith(String name) {
    return '$name के साथ कॉल पर लौटें';
  }

  @override
  String callBarIncoming(String name) {
    return 'इनकमिंग: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return '$name के साथ कॉल पर';
  }

  @override
  String get callStatsCodec => 'कोडेक';

  @override
  String get callStatsJitter => 'जिटर';

  @override
  String get callStatsPacketLoss => 'पैकेट लॉस';

  @override
  String get callStatsRoundTrip => 'राउंड ट्रिप';

  @override
  String get callStatsMedia => 'मीडिया';

  @override
  String get callStatsMosHistory => 'MOS इतिहास';

  @override
  String get callQualityTitle => 'कॉल की गुणवत्ता';

  @override
  String get callTransferTitle => 'कॉल ट्रांसफ़र करें';

  @override
  String get callTransferModeBlind => 'ब्लाइंड';

  @override
  String get callTransferModeAttended => 'अटेंडेड';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN डिवाइस';

  @override
  String get callTransferNoLanDevices =>
      'आपके नेटवर्क पर कोई पेयर किया गया SoftphonePro डिवाइस नहीं मिला। LAN पेज पर एक पेयर करें।';

  @override
  String get callTransferLanDisabled =>
      'यह कॉल अपने नेटवर्क के किसी दूसरे डिवाइस को सौंपने के लिए LAN Link चालू करें (सेटिंग, LAN Link)।';

  @override
  String get callTransferTalkFirst => 'पहले बात करें';

  @override
  String get callTransferBlindHint =>
      'कॉल करने वाले को तुरंत सौंप देता है। आप डिस्कनेक्ट हो जाते हैं।';

  @override
  String get callTransferAttendedHint =>
      'कॉल करने वाले को होल्ड पर रखकर पहले लक्ष्य को कॉल करता है। उनके उठाने के बाद ट्रांसफ़र पूरा करें।';

  @override
  String get callTransferNumberLabel => 'नंबर या SIP पता';

  @override
  String get callTransferNow => 'अभी ट्रांसफ़र करें';

  @override
  String get callTransferCallAndConsult => 'कॉल करके बात करें';

  @override
  String get callRetrieveParkedTitle => 'पार्क की गई कॉल वापस लें';

  @override
  String get callRetrieveParkedHint => 'पार्क स्लॉट, जैसे 701';

  @override
  String get callMoreAudioOutput => 'ऑडियो आउटपुट';

  @override
  String get callMoreAudioDevices => 'ऑडियो डिवाइस';

  @override
  String get callMoreAudioOutputSubtitle => 'फ़ोन, स्पीकर, ब्लूटूथ, हेडसेट';

  @override
  String get callMoreAudioDevicesSubtitle => 'माइक्रोफ़ोन और स्पीकर चुनें';

  @override
  String get callMoreParkCall => 'कॉल पार्क करें';

  @override
  String get callMoreParkCallSubtitle => 'पार्क फ़ीचर कोड पर ट्रांसफ़र करें';

  @override
  String get callMoreRetrieveParkedSubtitle => 'पार्क स्लॉट डायल करें';

  @override
  String get callMoreSendDtmf => 'DTMF अंक भेजें';

  @override
  String get callMoreSendDtmfSubtitle => 'पूरा क्रम टाइप करें, जैसे PIN';

  @override
  String get callSendDtmfTitle => 'DTMF भेजें';

  @override
  String get callMoreCallInfo => 'कॉल जानकारी';

  @override
  String get callMoreQualitySubtitle =>
      'लाइव MOS, जिटर, लॉस और राउंड-ट्रिप समय';

  @override
  String get callMoreSipTrace => 'SIP ट्रेस';

  @override
  String get callMoreSipTraceSubtitle => 'इस कॉल का लैडर डायग्राम';

  @override
  String get callInfoRemote => 'रिमोट';

  @override
  String get callInfoAccount => 'खाता';

  @override
  String get callInfoState => 'स्थिति';

  @override
  String get callInfoSecure => 'सुरक्षित';

  @override
  String get callInfoPlainSignalling => 'सादी सिग्नलिंग';

  @override
  String get callRoutePhone => 'फ़ोन';

  @override
  String get callRouteWiredHeadset => 'वायर्ड हेडसेट';

  @override
  String get callAudioMicrophone => 'माइक्रोफ़ोन';

  @override
  String callCardSemantics(String name, String state) {
    return '$name के साथ कॉल, $state';
  }

  @override
  String get callUnmute => 'अनम्यूट';

  @override
  String get callStopRecording => 'रिकॉर्डिंग रोकें';

  @override
  String get callSplitConference => 'कॉन्फ़्रेंस अलग करें';

  @override
  String get callMergeCalls => 'कॉल मर्ज करें';

  @override
  String get callSwapCalls => 'कॉल की अदला-बदली';

  @override
  String get callAttendedTransferBanner =>
      'अटेंडेड ट्रांसफ़र: मूल कॉल करने वाला होल्ड पर है।';

  @override
  String get callActiveCalls => 'सक्रिय कॉल';

  @override
  String get callConferenceLevels => 'कॉन्फ़्रेंस स्तर';

  @override
  String get callLevelVolume => 'वॉल्यूम';

  @override
  String get callLevelMicToParty => 'पक्ष को माइक';

  @override
  String callPercentSemantics(int percent) {
    return '$percent प्रतिशत';
  }

  @override
  String get callFailInvalidNumber => 'अमान्य नंबर (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'कॉल की अनुमति नहीं ($code)';
  }

  @override
  String get callFailNumberNotFound => 'नंबर नहीं मिला (404)';

  @override
  String get callFailNoAnswerFromServer => 'सर्वर से कोई उत्तर नहीं (408)';

  @override
  String get callFailTemporarilyUnavailable => 'अस्थायी रूप से अनुपलब्ध (480)';

  @override
  String get callFailIncompleteNumber => 'अधूरा नंबर (484)';

  @override
  String callFailBusy(String code) {
    return 'व्यस्त ($code)';
  }

  @override
  String get callFailCancelled => 'कॉल रद्द हुई (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'कोई संगत कोडेक नहीं ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'सेवा अनुपलब्ध (503)';

  @override
  String get callFailDeclined => 'कॉल अस्वीकार की गई (603)';

  @override
  String get callFailGeneric => 'कॉल विफल रही';

  @override
  String callFailGenericWithCode(String code) {
    return 'कॉल विफल रही ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'कॉल जारी है';

  @override
  String get callTrayInCall => 'कॉल पर';

  @override
  String get callHistoryBlocked => 'ब्लॉक किया गया';

  @override
  String get callHistoryAnonymityDisallowed => 'गुमनामी की अनुमति नहीं';

  @override
  String get callHistoryDoNotDisturb => 'परेशान न करें';

  @override
  String get callHistoryBusy => 'व्यस्त';

  @override
  String get callHistoryForwardedAlways => 'फ़ॉरवर्ड की गई (हमेशा)';

  @override
  String get callHistoryForwardedBusy => 'फ़ॉरवर्ड की गई (व्यस्त)';

  @override
  String get callHistorySentToVoicemail => 'वॉइसमेल पर भेजी गई';

  @override
  String get callHistoryRedirected => 'रीडायरेक्ट की गई';

  @override
  String get callIncomingNotificationBody => 'इनकमिंग कॉल';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return '$account पर इनकमिंग कॉल';
  }

  @override
  String get callMissedNotificationTitle => 'छूटी हुई कॉल';

  @override
  String get callErrEngineNotRunning => 'कॉल इंजन अभी चालू नहीं हुआ है';

  @override
  String get callErrAddAccount => 'कॉल करने के लिए खाता जोड़ें';

  @override
  String get callErrCouldNotPlace => 'कॉल नहीं लगाई जा सकी';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account रजिस्टर्ड नहीं है';
  }

  @override
  String get callErrCouldNotAnswer => 'कॉल उठाई नहीं जा सकी';

  @override
  String get callErrNoVoicemailNumber =>
      'इस खाते के लिए कोई वॉइसमेल नंबर सेट नहीं है';

  @override
  String get callErrTransferFailed => 'ट्रांसफ़र विफल रहा';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'ट्रांसफ़र विफल रहा: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'कॉल मर्ज नहीं हो सकीं';

  @override
  String get callErrCouldNotStartRecording => 'रिकॉर्डिंग शुरू नहीं हो सकी';

  @override
  String get callErrCouldNotStopRecording => 'रिकॉर्डिंग रोकी नहीं जा सकी';

  @override
  String callParkingNotice(String code) {
    return 'कॉल पार्क हो रही है ($code डायल करें)';
  }

  @override
  String get callErrParkFailed => 'पार्क विफल रहा';

  @override
  String get callErrHandoffFailed => 'हैंड-ऑफ़ विफल रहा';

  @override
  String get callErrCouldNotSendToDevice => 'डिवाइस पर नहीं भेजा जा सका';

  @override
  String get callHistoryForwardedNoAnswer => 'फ़ॉरवर्ड की गई (जवाब नहीं मिला)';

  @override
  String get shellTabKeypad => 'कीपैड';

  @override
  String get shellTabRecents => 'हालिया';

  @override
  String get shellTabContacts => 'संपर्क';

  @override
  String get shellTabMessages => 'संदेश';

  @override
  String get shellTabPresence => 'उपस्थिति';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'रिकॉर्डिंग';

  @override
  String get shellSearchSemantics => 'संपर्क, इतिहास खोजें या नंबर डायल करें';

  @override
  String get shellSearchHint => 'खोजें या डायल करें';

  @override
  String get shellVoicemailTooltip => 'वॉइसमेल';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नए वॉइसमेल। वॉइसमेल पर कॉल करने के लिए क्लिक करें',
      one: '1 नया वॉइसमेल। वॉइसमेल पर कॉल करने के लिए क्लिक करें',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'दूर';

  @override
  String get shellStatusTooltip => 'आपकी स्थिति';

  @override
  String get shellDemoBanner =>
      'डेमो मोड: कॉल सिम्युलेट की जाती हैं, कुछ भी असली नेटवर्क तक नहीं पहुँचता।';

  @override
  String get uiToday => 'आज';

  @override
  String get uiYesterday => 'कल';

  @override
  String get uiUnknownCaller => 'अज्ञात कॉलर';

  @override
  String get uiCallEnded => 'कॉल समाप्त';

  @override
  String get uiCallTransferNotConfirmed => 'ट्रांसफ़र की पुष्टि नहीं हुई';

  @override
  String get uiCallTransferring => 'ट्रांसफ़र हो रहा है...';

  @override
  String get uiCallConference => 'कॉन्फ़्रेंस';

  @override
  String get uiCallOnHold => 'होल्ड पर';

  @override
  String get uiCallHeldByRemote => 'सामने वाले ने होल्ड किया';

  @override
  String get uiCallCalling => 'कॉल लग रही है...';

  @override
  String get uiCallRinging => 'घंटी बज रही है...';

  @override
  String get uiCallConnecting => 'जुड़ रही है...';

  @override
  String get uiCallIncoming => 'इनकमिंग कॉल';

  @override
  String get uiCallConnected => 'जुड़ी हुई';

  @override
  String get uiQrScanTitle => 'QR कोड स्कैन करें';

  @override
  String get uiQrPasteHint => 'कोड का टेक्स्ट पेस्ट करें';

  @override
  String get uiQrNoCamera =>
      'इस डिवाइस पर कैमरा स्कैनिंग उपलब्ध नहीं है। इसके बजाय कोड का टेक्स्ट पेस्ट करें।';

  @override
  String get uiQrPaste => 'पेस्ट करें';

  @override
  String get uiQrUse => 'उपयोग करें';

  @override
  String get uiQrCameraDenied =>
      'कैमरा एक्सेस बंद है। सिस्टम सेटिंग में अनुमति दें, या नीचे कोड का टेक्स्ट पेस्ट करें।';

  @override
  String get uiQrCameraUnavailable =>
      'कैमरा उपलब्ध नहीं है। नीचे कोड का टेक्स्ट पेस्ट करें।';

  @override
  String get presenceLampRinging => 'घंटी बज रही है';

  @override
  String get presenceHeader => 'बिज़ी लैंप फ़ील्ड';

  @override
  String get presenceChooseTooltip => 'देखने के लिए संपर्क चुनें';

  @override
  String get presenceEmptyTitle => 'बोर्ड पर कोई एक्सटेंशन नहीं';

  @override
  String get presenceEmptySubtitle =>
      'किसी संपर्क के खाली, घंटी बजते या व्यस्त होने की जानकारी देखने के लिए उसके लिए \"BLF बोर्ड पर दिखाएँ\" चालू करें।';

  @override
  String get presenceOpenContacts => 'संपर्क खोलें';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status। कॉल के लिए टैप करें, और विकल्पों के लिए देर तक दबाएँ';
  }

  @override
  String presenceCallName(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get presencePickup => 'यह एक्सटेंशन पिकअप करें';

  @override
  String get presencePickupSub => 'उनकी बजती कॉल उठाएँ (डायरेक्टेड पिकअप)';

  @override
  String get presenceTransferHere => 'मौजूदा कॉल यहाँ ट्रांसफ़र करें';

  @override
  String get presenceRemove => 'बोर्ड से हटाएँ';

  @override
  String get uiCall => 'कॉल';

  @override
  String get uiMessage => 'संदेश';

  @override
  String get recentsSearchTooltip => 'इतिहास खोजें';

  @override
  String get recentsClearTitle => 'कॉल इतिहास साफ़ करें?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सभी $count प्रविष्टियाँ हटा दी जाएँगी।',
      one: '1 प्रविष्टि हटा दी जाएगी।',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'इतिहास CSV के रूप में क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get recentsMenuCopyCsv => 'CSV के रूप में कॉपी करें';

  @override
  String get recentsMenuClear => 'इतिहास साफ़ करें';

  @override
  String get recentsSearchHint => 'नाम या नंबर खोजें';

  @override
  String get recentsFilterAll => 'सभी';

  @override
  String get recentsFilterMissed => 'छूटी';

  @override
  String get recentsFilterIncoming => 'इनकमिंग';

  @override
  String get recentsFilterOutgoing => 'आउटगोइंग';

  @override
  String get recentsFilterAccount => 'खाते के अनुसार फ़िल्टर करें';

  @override
  String get recentsAllAccounts => 'सभी खाते';

  @override
  String get recentsAccountFallback => 'खाता';

  @override
  String get recentsEmptyNone => 'अभी तक कोई कॉल नहीं';

  @override
  String get recentsEmptyNoMatch => 'कोई मेल खाती कॉल नहीं';

  @override
  String get recentsEmptyNoneSub => 'आपकी कॉल यहाँ दिखाई देंगी।';

  @override
  String get recentsEmptyNoMatchSub => 'कोई दूसरा फ़िल्टर आज़माएँ।';

  @override
  String get recentsOpenKeypad => 'कीपैड खोलें';

  @override
  String get recentsShowAll => 'सभी दिखाएँ';

  @override
  String get recentsSelectCall => 'कोई कॉल चुनें';

  @override
  String get recentsSelectCallSub =>
      'विवरण, गुणवत्ता और रिकॉर्डिंग यहाँ दिखाई देंगे।';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'छूटी हुई कॉल',
      'incoming': 'इनकमिंग कॉल',
      'other': 'आउटगोइंग कॉल',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get recentsAddAccountToMessage => 'संदेश भेजने के लिए खाता जोड़ें';

  @override
  String get recentsAddContact => 'संपर्क जोड़ें';

  @override
  String get recentsContact => 'संपर्क';

  @override
  String get recentsBlock => 'ब्लॉक करें';

  @override
  String get recentsUnblock => 'अनब्लॉक करें';

  @override
  String recentsBlockTitle(String number) {
    return '$number ब्लॉक करें?';
  }

  @override
  String get recentsBlockMessage =>
      'इस नंबर से आने वाली कॉल अपने-आप अस्वीकार कर दी जाएँगी।';

  @override
  String get recentsQualityHeader => 'कॉल की गुणवत्ता';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'सबसे खराब MOS $mos   ·   जिटर $jitter ms   ·   लॉस $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'रिकॉर्डिंग';

  @override
  String get recentsOpenInRecordings => 'रिकॉर्डिंग में खोलें';

  @override
  String recentsRelatedCall(String title) {
    return 'संबंधित कॉल: $title';
  }

  @override
  String get recentsHistoryHeader => 'इतिहास';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'इस नंबर के साथ कोई कॉल नहीं';

  @override
  String get recentsDeleteTitle => 'ये कॉल हटाएँ?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name की $count प्रविष्टियाँ हटाता है।',
      one: '$name की 1 प्रविष्टि हटाता है।',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'इतिहास से हटाएँ';

  @override
  String get recentsCallDetails => 'कॉल विवरण';

  @override
  String get contactsFavoritesHeader => '★ पसंदीदा';

  @override
  String get contactsFavoritesOnly => 'केवल पसंदीदा';

  @override
  String get contactsShowAll => 'सभी दिखाएँ';

  @override
  String get contactsImportExportTooltip => 'इंपोर्ट और एक्सपोर्ट';

  @override
  String get contactsMenuDevice => 'डिवाइस से इंपोर्ट करें';

  @override
  String get contactsMenuFile => 'vCard / CSV फ़ाइल इंपोर्ट करें';

  @override
  String get contactsMenuClipboard => 'क्लिपबोर्ड से इंपोर्ट करें';

  @override
  String get contactsMenuCopyVcard => 'vCard के रूप में कॉपी करें';

  @override
  String get contactsMenuCopyCsv => 'CSV के रूप में कॉपी करें';

  @override
  String get contactsNewTooltip => 'नया संपर्क';

  @override
  String get contactsSearchHint => 'संपर्क खोजें';

  @override
  String get contactsEmptyTitle => 'अभी तक कोई संपर्क नहीं';

  @override
  String get contactsEmptySubtitle =>
      'जिन्हें आप अक्सर कॉल करते हैं उन्हें जोड़ें, या vCard या CSV फ़ाइल इंपोर्ट करें।';

  @override
  String get contactsEmptyAction => 'संपर्क जोड़ें';

  @override
  String get contactsNoMatches => 'कोई मिलान नहीं';

  @override
  String contactsCallName(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get contactsSelect => 'कोई संपर्क चुनें';

  @override
  String get contactsCopiedVcard => 'संपर्क vCard के रूप में कॉपी हो गए';

  @override
  String get contactsCopiedCsv => 'संपर्क CSV के रूप में कॉपी हो गए';

  @override
  String get contactsDeviceDenied =>
      'संपर्कों की अनुमति नहीं मिली। इंपोर्ट के लिए सिस्टम सेटिंग में अनुमति दें।';

  @override
  String get contactsDeviceNone => 'इस डिवाइस पर कोई संपर्क नहीं मिला';

  @override
  String contactsNothingNew(int count) {
    return 'इंपोर्ट करने के लिए कुछ नया नहीं ($count पहले से मौजूद हैं)';
  }

  @override
  String get contactsImportDeviceTitle => 'डिवाइस से इंपोर्ट करें?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नए संपर्क',
      one: '1 नया संपर्क',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count अतिरिक्त नंबरों के साथ अपडेट हुए';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count छोड़े गए (डुप्लिकेट या फ़ोन नंबर नहीं)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संपर्क इंपोर्ट हुए',
      one: '1 संपर्क इंपोर्ट हुआ',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'उस डेटा में कोई संपर्क नहीं मिला';

  @override
  String get contactsLabelMobile => 'मोबाइल';

  @override
  String get contactsLabelWork => 'कार्य';

  @override
  String get contactsLabelHome => 'घर';

  @override
  String get contactsLabelOther => 'अन्य';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'संपर्क नहीं मिला';

  @override
  String get contactsActionFavorite => 'पसंदीदा';

  @override
  String get contactsNumbersHeader => 'नंबर';

  @override
  String get contactsSipAddress => 'SIP पता';

  @override
  String get contactsDetailsHeader => 'विवरण';

  @override
  String get contactsOnBlf => 'BLF बोर्ड पर दिखाया गया';

  @override
  String get contactsAlwaysRecorded => 'कॉल हमेशा रिकॉर्ड होती हैं';

  @override
  String contactsDeleteTitle(String name) {
    return '$name हटाएँ?';
  }

  @override
  String get contactsDeleteMessage => 'यह संपर्क इस डिवाइस से हटा दिया जाएगा।';

  @override
  String get contactsDeleteButton => 'संपर्क हटाएँ';

  @override
  String get contactsDetailTitle => 'संपर्क';

  @override
  String get contactsErrorNameOrNumber => 'नाम या नंबर दर्ज करें';

  @override
  String get contactsEditTitle => 'संपर्क संपादित करें';

  @override
  String get contactsFieldName => 'नाम';

  @override
  String get contactsFieldCompany => 'कंपनी';

  @override
  String get contactsFieldNumber => 'नंबर';

  @override
  String get contactsRemoveNumber => 'नंबर हटाएँ';

  @override
  String get contactsAddNumber => 'नंबर जोड़ें';

  @override
  String get contactsSipHeader => 'SIP पते';

  @override
  String get contactsRemoveAddress => 'पता हटाएँ';

  @override
  String get contactsAddSip => 'SIP पता जोड़ें';

  @override
  String get contactsFieldEmail => 'ईमेल';

  @override
  String get contactsFieldNotes => 'नोट्स';

  @override
  String get contactsFieldFavorite => 'पसंदीदा';

  @override
  String get contactsShowOnBlf => 'BLF बोर्ड पर दिखाएँ';

  @override
  String get contactsShowOnBlfSub =>
      'इस एक्सटेंशन की उपस्थिति और बिज़ी लैंप देखें';

  @override
  String get contactsAlwaysRecordTitle =>
      'इस संपर्क के साथ कॉल हमेशा रिकॉर्ड करें';

  @override
  String get contactsAlwaysRecordSub =>
      'स्वचालित रिकॉर्डिंग नियमों को ओवरराइड करता है';

  @override
  String get contactsRingtone => 'रिंगटोन';

  @override
  String get contactsPresenceVia => 'इस खाते से उपस्थिति';

  @override
  String get contactsDefaultAccount => 'डिफ़ॉल्ट खाता';

  @override
  String get contactsDeleteContactTitle => 'संपर्क हटाएँ?';

  @override
  String get contactsCannotUndo => 'इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get messagesNewMessage => 'नया संदेश';

  @override
  String get messagesNumberOrSip => 'नंबर या SIP पता';

  @override
  String get messagesNoConversations => 'कोई बातचीत नहीं';

  @override
  String get messagesEmptySubtitle =>
      'अपने खातों पर किसी भी एक्सटेंशन या पते पर SIP संदेश भेजें।';

  @override
  String get messagesTyping => 'टाइप कर रहे हैं...';

  @override
  String get messagesYouPrefix => 'आप: ';

  @override
  String get messagesSelect => 'कोई बातचीत चुनें';

  @override
  String get messagesLanOnline => 'आपके नेटवर्क पर ऑनलाइन';

  @override
  String get messagesLanOffline => 'ऑफ़लाइन। वापस आने पर संदेश भेजे जाएँगे।';

  @override
  String messagesSendFileTo(String name) {
    return '$name को फ़ाइल भेजें';
  }

  @override
  String messagesCallName(String name) {
    return '$name को कॉल करें';
  }

  @override
  String get messagesDeleteTitle => 'बातचीत हटाएँ?';

  @override
  String messagesDeleteMessage(String name) {
    return '$name के साथ के सभी संदेश हटा दिए जाएँगे।';
  }

  @override
  String get messagesDeleteMenu => 'बातचीत हटाएँ';

  @override
  String get messagesSayHello => 'नमस्ते कहें';

  @override
  String get messagesLanEmptySub =>
      'संदेश आपके नेटवर्क पर सीधे इस डिवाइस तक जाते हैं, एंड-टू-एंड एन्क्रिप्टेड।';

  @override
  String get messagesSipEmptySub =>
      'संदेश आपके खाते के ज़रिए SIP MESSAGE से भेजे जाते हैं।';

  @override
  String get messagesInputHint => 'संदेश';

  @override
  String get messagesSend => 'भेजें';

  @override
  String get messagesStatusSending => 'भेजा जा रहा है';

  @override
  String get messagesStatusSent => 'भेजा गया';

  @override
  String get messagesStatusDelivered => 'पहुँच गया';

  @override
  String get messagesStatusRead => 'पढ़ लिया';

  @override
  String get messagesStatusFailed => 'विफल';

  @override
  String get messagesNotDelivered => 'नहीं पहुँचा। फिर कोशिश के लिए टैप करें';

  @override
  String get uiStatusRegistered => 'रजिस्टर्ड';

  @override
  String get uiStatusRegistering => 'रजिस्टर हो रहा है';

  @override
  String get uiStatusRegFailed => 'रजिस्ट्रेशन विफल';

  @override
  String get uiStatusDisabled => 'अक्षम';

  @override
  String get uiQualityMeasuring => 'मापा जा रहा है';

  @override
  String get uiQualityExcellent => 'उत्कृष्ट';

  @override
  String get uiQualityGood => 'अच्छी';

  @override
  String get uiQualityFair => 'ठीक-ठाक';

  @override
  String get uiQualityPoor => 'खराब';

  @override
  String get uiQualityBad => 'बहुत खराब';

  @override
  String uiQualitySemantics(String label) {
    return 'कॉल गुणवत्ता $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'कॉल गुणवत्ता $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'कॉल गुणवत्ता: $label';
  }

  @override
  String get uiSecureFull => 'एन्क्रिप्टेड';

  @override
  String get uiSecureMedia => 'मीडिया एन्क्रिप्टेड';

  @override
  String get uiSecureSignalling => 'सिग्नलिंग एन्क्रिप्टेड';

  @override
  String get uiSecureNone => 'एन्क्रिप्टेड नहीं';

  @override
  String get uiSecureSrtpLine => 'SRTP मीडिया';

  @override
  String get uiSecureTlsLine => 'TLS सिग्नलिंग';

  @override
  String lanCallHandingOver(String name) {
    return '$name को सौंपा जा रहा है';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return '$name को इंटरकॉम';
  }

  @override
  String get lanCallIntercomToUnnamed => 'पास के डिवाइस को इंटरकॉम';

  @override
  String lanCallIntercomFromNamed(String name) {
    return '$name से इंटरकॉम';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'पास के डिवाइस से इंटरकॉम';

  @override
  String lanCallToNamed(String name) {
    return '$name को LAN कॉल';
  }

  @override
  String get lanCallToUnpaired => 'अनपेयर्ड डिवाइस को LAN कॉल';

  @override
  String lanCallFromNamed(String name) {
    return '$name से LAN कॉल';
  }

  @override
  String get lanCallFromUnpaired => 'अनपेयर्ड डिवाइस से LAN कॉल';

  @override
  String lanHandoffTransferredFrom(String device) {
    return '$device से ट्रांसफ़र की गई कॉल';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return '$device से ट्रांसफ़र की गई कॉल: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'दूसरा डिवाइस';

  @override
  String lanRelayedTitle(String name) {
    return '$name को रिले की गई';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'कॉल करने वाला $name से बात कर रहा है। आप कॉल पर नहीं हैं।';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '$name को कॉल हो रही है...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return '$name के उठाने तक कॉल करने वाला जुड़ा रहता है।';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '$name से पूछा जा रहा है...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'उनके कॉल स्वीकारने की प्रतीक्षा है।';

  @override
  String lanRelayConsultingTitle(String name) {
    return '$name से बात हो रही है';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'कॉल करने वाला होल्ड पर है। तैयार होने पर हैंड-ऑफ़ पूरा करें।';

  @override
  String get lanRelayTakingBack => 'कॉल वापस ली जा रही है...';

  @override
  String get lanRelayTakeBack => 'वापस लें';

  @override
  String get lanRelayEnd => 'समाप्त करें';

  @override
  String get lanSendToDevice => 'डिवाइस पर भेजें';

  @override
  String get lanBusy => 'व्यस्त';

  @override
  String get lanNoPairedOnline => 'कोई पेयर किया गया डिवाइस ऑनलाइन नहीं है';

  @override
  String lanPairRejectedBy(String name) {
    return '$name ने पेयरिंग अस्वीकार कर दी।';
  }

  @override
  String get lanPairRejected => 'पेयरिंग अस्वीकार की गई।';

  @override
  String get lanPairCancelled => 'पेयरिंग रद्द की गई।';

  @override
  String get lanPairTimedOut => 'पेयरिंग का समय समाप्त हो गया। फिर कोशिश करें।';

  @override
  String get lanPairFailed => 'पेयरिंग विफल रही';

  @override
  String lanPairFailedReason(String reason) {
    return 'पेयरिंग विफल रही: $reason';
  }

  @override
  String get lanPairThisDevice => 'यह डिवाइस';

  @override
  String get lanPairConnecting => 'सुरक्षित रूप से जुड़ रहे हैं...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name इस डिवाइस के साथ पेयर करना चाहता है।';
  }

  @override
  String lanPairPairingWith(String name) {
    return '$name के साथ पेयर हो रहे हैं।';
  }

  @override
  String get lanPairCheckCode =>
      'जाँचें कि यह कोड दोनों स्क्रीन पर एक जैसा है।';

  @override
  String lanPairCodeSemantics(String code) {
    return 'पेयरिंग कोड $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return '$name की पुष्टि की प्रतीक्षा है...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name ने पुष्टि कर दी है।';
  }

  @override
  String get lanPairReject => 'अस्वीकार करें';

  @override
  String get lanPairCodesMatch => 'कोड मेल खाते हैं';

  @override
  String lanPairPairedWith(String name) {
    return '$name के साथ पेयर हो गया।';
  }

  @override
  String get lanPairRequestTitle => 'पेयरिंग अनुरोध';

  @override
  String lanPairTitle(String name) {
    return '$name के साथ पेयर करें';
  }

  @override
  String get lanActionDecline => 'अस्वीकार करें';

  @override
  String get lanActionAccept => 'स्वीकारें';

  @override
  String get lanFileIncomingTitle => 'आने वाली फ़ाइल';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$name से $size';
  }

  @override
  String get lanHandoffOfferTitle => 'कॉल यहाँ ट्रांसफ़र करें?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' $caller की',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' ($account पर)',
    });
    return '$device आपको$_temp0$_temp1 कॉल सौंपना चाहता है।';
  }

  @override
  String get lanHandoffOfferAttended => 'वे पहले आपसे बात करेंगे।';

  @override
  String get lanHandoffTakeCall => 'कॉल लें';

  @override
  String lanIntercomRequestTitle(String name) {
    return '$name से इंटरकॉम की अनुमति दें?';
  }

  @override
  String get lanIntercomRequestBody =>
      'उनकी कॉल स्पीकर पर अपने-आप उठा ली जाएगी।';

  @override
  String get lanIntercomDeny => 'मना करें';

  @override
  String get lanIntercomAllow => 'अनुमति दें';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name ने इस डिवाइस को अपनी पेयर की गई सूची से हटा दिया';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ाइलें भेजी जा रही हैं...',
      one: '$name भेजी जा रही है...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'नया संदेश';

  @override
  String get lanSipMessage => 'SIP संदेश';

  @override
  String get lanSipMessageSub => 'आपके खाते के ज़रिए किसी नंबर या पते पर';

  @override
  String get lanChatOnline => 'LAN चैट, ऑनलाइन';

  @override
  String get lanChatOffline => 'LAN चैट, ऑफ़लाइन';

  @override
  String lanSavedAt(String path) {
    return '$path पर सहेजी गई (पाथ कॉपी हो गया)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'आपके डिवाइस, सीधे बात करते हुए';

  @override
  String get lanConnectByAddress => 'पते से जुड़ें';

  @override
  String get lanSettingsTooltip => 'LAN सेटिंग';

  @override
  String get lanOffTitle => 'LAN Link बंद है';

  @override
  String get lanOffSubtitle =>
      'बिना किसी सर्वर के अपने दूसरे SoftphonePro डिवाइस खोजें, चैट करें, फ़ाइलें भेजें और कॉल सौंपें।';

  @override
  String get lanTurnOn => 'LAN Link चालू करें';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link शुरू नहीं हो सका: $error';
  }

  @override
  String get lanConnectHelp =>
      'host:port टाइप करें, या दूसरे डिवाइस पर दिखाए गए QR कोड का टेक्स्ट पेस्ट करें।';

  @override
  String get lanScanTitle => 'LAN पेयरिंग QR स्कैन करें';

  @override
  String get lanScanQr => 'QR स्कैन करें';

  @override
  String get lanPaste => 'पेस्ट करें';

  @override
  String get lanConnect => 'जुड़ें';

  @override
  String lanConnectedTo(String name) {
    return '$name से जुड़ गए';
  }

  @override
  String get lanCouldNotConnect => 'जुड़ा नहीं जा सका';

  @override
  String get lanCouldNotStartPairing => 'पेयरिंग शुरू नहीं हो सकी';

  @override
  String get lanThisDevice => 'यह डिवाइस';

  @override
  String get lanDeviceNameTitle => 'डिवाइस का नाम';

  @override
  String get lanStarting => 'शुरू हो रहा है...';

  @override
  String get lanVisible => 'आपके नेटवर्क पर दिखाई दे रहा है';

  @override
  String get lanNotRunning => 'चालू नहीं है';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाते साझा',
      one: '1 खाता साझा',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'फ़िंगरप्रिंट';

  @override
  String get lanHideQr => 'QR कोड छिपाएँ';

  @override
  String get lanShowQr => 'दूसरा डिवाइस जोड़ने के लिए QR कोड दिखाएँ';

  @override
  String get lanCopyConnectionText => 'कनेक्शन टेक्स्ट कॉपी करें';

  @override
  String get lanConnectionTextCopied => 'कनेक्शन टेक्स्ट कॉपी हो गया';

  @override
  String get lanActiveOnOthers => 'आपके दूसरे डिवाइस पर सक्रिय';

  @override
  String get lanPairedDevices => 'पेयर किए गए डिवाइस';

  @override
  String get lanNoPaired =>
      'अभी कोई डिवाइस पेयर नहीं है। चैट करने, फ़ाइलें भेजने और कॉल सौंपने के लिए पास का डिवाइस पेयर करें।';

  @override
  String get lanNearby => 'आस-पास';

  @override
  String get lanNearbyHint =>
      'आपके नेटवर्क पर SoftphonePro खोजा जा रहा है। दूसरे डिवाइस पर LAN Link चालू होना चाहिए। ऊपर लिंक बटन से पते द्वारा भी जुड़ सकते हैं।';

  @override
  String get lanTransfers => 'ट्रांसफ़र';

  @override
  String get lanFiles => 'फ़ाइलें';

  @override
  String get lanPairedBadge => 'पेयर्ड';

  @override
  String get lanTyping => 'टाइप कर रहे हैं...';

  @override
  String get lanPair => 'पेयर करें';

  @override
  String get lanUnpair => 'अनपेयर करें';

  @override
  String lanUnpairTitle(String name) {
    return '$name को अनपेयर करें?';
  }

  @override
  String get lanUnpairMessage =>
      'चैट करने, फ़ाइलें भेजने या कॉल सौंपने के लिए आपको फिर से पेयर करना होगा।';

  @override
  String get lanActionMessage => 'संदेश';

  @override
  String get lanActionSendFile => 'फ़ाइल भेजें';

  @override
  String get lanActionCall => 'कॉल';

  @override
  String get lanActionIntercom => 'इंटरकॉम';

  @override
  String lanRemoteActiveOn(String device) {
    return '$device पर सक्रिय';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return '$device पर सक्रिय  ·  $account';
  }

  @override
  String get lanPull => 'खींचें';

  @override
  String get lanTransferPreparing => 'तैयार हो रहा है...';

  @override
  String get lanTransferWaitingYou => 'आपकी प्रतीक्षा है';

  @override
  String lanTransferWaitingPeer(String name) {
    return '$name के स्वीकारने की प्रतीक्षा है';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$total में से $done';
  }

  @override
  String get lanTransferVerifying => 'सत्यापित हो रहा है...';

  @override
  String lanTransferFrom(String name, String status) {
    return '$name से  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return '$name को  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  $name से';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  $name को';
  }

  @override
  String lanFileFailed(String error) {
    return 'विफल: $error';
  }

  @override
  String get lanFileActions => 'फ़ाइल क्रियाएँ';

  @override
  String get lanPathCopied => 'पाथ कॉपी हो गया';

  @override
  String get lanFileOpen => 'खोलें';

  @override
  String get lanFileShowInFolder => 'फ़ोल्डर में दिखाएँ';

  @override
  String get lanFileCopyPath => 'पाथ कॉपी करें';

  @override
  String lanNetworkError(String message) {
    return 'नेटवर्क त्रुटि: $message';
  }

  @override
  String get lanErrNotRunning => 'पहले LAN Link चालू करें';

  @override
  String get lanErrBadAddress =>
      '192.168.1.20:4711 जैसा पता दर्ज करें या QR कोड का टेक्स्ट पेस्ट करें';

  @override
  String get lanErrFingerprint =>
      'वह डिवाइस स्कैन किए गए कोड से मेल नहीं खाता। क्या QR कोड किसी दूसरे डिवाइस का था?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$name से $file मिली';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$name को $file भेजी गई';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name ने $file अस्वीकार कर दी';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'फ़ाइल ट्रांसफ़र विफल रहा: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'पास के डिवाइस को कॉल करने के लिए LAN Link चालू करें';

  @override
  String get lanNoticePairFirst => 'पहले इस डिवाइस के साथ पेयर करें';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name अभी कॉल के लिए उपलब्ध नहीं है';
  }

  @override
  String lanNoticeAsking(String name) {
    return '$name से पूछा जा रहा है…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name ने इंटरकॉम की अनुमति नहीं दी (या उत्तर नहीं दिया)';
  }

  @override
  String get lanHoOff => 'LAN Link बंद है';

  @override
  String get lanHoPairFirst => 'पहले उस डिवाइस के साथ पेयर करें';

  @override
  String lanHoOffline(String name) {
    return '$name ऑफ़लाइन है';
  }

  @override
  String get lanHoAlready => 'यह कॉल पहले से सौंपी जा रही है';

  @override
  String get lanHoEnded => 'कॉल पहले ही समाप्त हो चुकी है';

  @override
  String get lanHoWaitConnected => 'कॉल के जुड़ने तक प्रतीक्षा करें';

  @override
  String get lanHoLanCall => 'LAN कॉल सौंपी नहीं जा सकतीं';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name नेटवर्क पर कॉल नहीं ले सकता (वहाँ LAN कॉलिंग बंद है)';
  }

  @override
  String get lanHoNoLanHere => 'इस डिवाइस पर LAN कॉलिंग उपलब्ध नहीं है';

  @override
  String lanHoDeclined(String name) {
    return '$name ने कॉल अस्वीकार कर दी। यह आपके पास ही रहेगी।';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name ने उत्तर नहीं दिया। कॉल आपके पास ही रहेगी।';
  }

  @override
  String get lanHoCancelled =>
      'हैंड-ऑफ़ रद्द कर दिया गया। कॉल आपके पास ही रहेगी।';

  @override
  String lanHoUnreachable(String name) {
    return '$name तक नहीं पहुँचा जा सका। कॉल आपके पास ही रहेगी।';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '$name तक नहीं पहुँचा जा सका ($reason)। कॉल आपके पास ही रहेगी।';
  }

  @override
  String get lanHoEndedBefore => 'हैंड-ऑफ़ से पहले ही कॉल समाप्त हो गई';

  @override
  String lanHoPbxRefused(String name) {
    return 'फ़ोन सिस्टम ने ट्रांसफ़र अस्वीकार कर दिया और $name LAN कॉल नहीं ले सकता';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'फ़ोन सिस्टम के ज़रिए ट्रांसफ़र विफल रहा। इसके बजाय नेटवर्क पर रिले किया जा रहा है।';

  @override
  String lanHoSentTo(String name) {
    return 'कॉल $name को भेजी गई';
  }

  @override
  String get lanHoConsultFailed =>
      'फ़ोन सिस्टम के ज़रिए दूसरे डिवाइस को कॉल नहीं की जा सकी';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name अब उपलब्ध नहीं है';
  }

  @override
  String get lanHoCouldNotAnswer => 'सौंपने के लिए कॉल उठाई नहीं जा सकी';

  @override
  String lanHoCouldNotCall(String name) {
    return 'नेटवर्क पर $name को कॉल नहीं की जा सकी। कॉल आपके पास ही रहेगी।';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name ने कॉल नहीं उठाई। कॉल आपके पास ही रहेगी।';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return '$name को सौंपी गई';
  }

  @override
  String lanHoRelayed(String name) {
    return 'कॉल $name को रिले की गई';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'पहले $name के उठाने की प्रतीक्षा करें';
  }

  @override
  String get lanHoFailed => 'हैंड-ऑफ़ विफल रहा';

  @override
  String lanHoTakenBack(String name) {
    return 'कॉल $name से वापस ले ली गई';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name ने बातचीत समाप्त कर दी। कॉल वापस आपके पास है।';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'कॉल $name को सौंपी नहीं जा सकी';
  }

  @override
  String get diagSip400Explain => 'सर्वर अनुरोध को समझ नहीं सका।';

  @override
  String get diagSip400Fix =>
      'खाता सेटिंग (डोमेन, उपयोगकर्ता नाम, प्रॉक्सी) जाँचें। समस्या बनी रहे तो अपने प्रदाता को SIP ट्रेस भेजें।';

  @override
  String get diagSip401Explain =>
      'सर्वर ने क्रेडेंशियल अस्वीकार कर दिए (या उन्हें माँग रहा है)।';

  @override
  String get diagSip401Fix =>
      'उपयोगकर्ता नाम, ऑथेंटिकेशन उपयोगकर्ता नाम और पासवर्ड जाँचें। कुछ प्रदाता अलग \"auth ID\" इस्तेमाल करते हैं।';

  @override
  String get diagSip403Explain =>
      'सर्वर ने अनुरोध समझ लिया लेकिन उसे मना कर दिया: गलत पासवर्ड, खाता अक्षम, या आपके IP की अनुमति नहीं है।';

  @override
  String get diagSip403Fix =>
      'पासवर्ड फिर से दर्ज करें, जाँचें कि खाता सक्रिय है, और पक्का करें कि आपका सार्वजनिक IP ब्लॉक नहीं है (fail2ban/ACL)।';

  @override
  String get diagSip404Explain => 'सर्वर इस उपयोगकर्ता या नंबर को नहीं जानता।';

  @override
  String get diagSip404Fix =>
      'उपयोगकर्ता नाम और डोमेन जाँचें; कॉल के लिए डायल किया गया नंबर और डायल नियम जाँचें।';

  @override
  String get diagSip405Explain => 'सर्वर इस अनुरोध का समर्थन नहीं करता।';

  @override
  String get diagSip405Fix =>
      'OPTIONS पिंग के लिए आम तौर पर हानिरहित है। REGISTER के लिए जाँचें कि आप SIP रजिस्ट्रार से ही बात कर रहे हैं।';

  @override
  String get diagSip407Explain => 'आउटबाउंड प्रॉक्सी को क्रेडेंशियल चाहिए।';

  @override
  String get diagSip407Fix =>
      'खाते का पासवर्ड और आउटबाउंड प्रॉक्सी सेटिंग जाँचें।';

  @override
  String get diagSip408Explain => 'सर्वर से समय पर कोई उत्तर नहीं मिला।';

  @override
  String get diagSip408Fix =>
      'सर्वर का पता और पोर्ट, फ़ायरवॉल जाँचें, और TCP या TLS आज़माएँ। केवल UDP पर बार-बार टाइमआउट राउटर के SIP ALG का संकेत हो सकता है।';

  @override
  String get diagSip410Explain => 'यह नंबर अब मौजूद नहीं है।';

  @override
  String get diagSip410Fix => 'डायल किया गया नंबर जाँचें।';

  @override
  String get diagSip415Explain =>
      'दूसरा पक्ष प्रस्तावित कंटेंट टाइप या कोडेक स्वीकार नहीं करता।';

  @override
  String get diagSip415Fix =>
      'सेटिंग > कोडेक में और कोडेक (जैसे PCMU/PCMA) चालू करें।';

  @override
  String get diagSip421Explain =>
      'सर्वर को एक SIP एक्सटेंशन चाहिए जो इस क्लाइंट ने प्रस्तावित नहीं किया।';

  @override
  String get diagSip421Fix => 'खाते के NAT/ICE/100rel/टाइमर विकल्प जाँचें।';

  @override
  String get diagSip423Explain =>
      'रजिस्ट्रेशन समाप्ति सर्वर की अनुमत अवधि से कम है।';

  @override
  String get diagSip423Fix => 'खाता सेटिंग में रजिस्ट्रेशन समाप्ति बढ़ाएँ।';

  @override
  String get diagSip480Explain =>
      'उपयोगकर्ता रजिस्टर्ड नहीं है या अभी उस तक पहुँचा नहीं जा सकता।';

  @override
  String get diagSip480Fix =>
      'जाँचें कि दूसरा पक्ष रजिस्टर्ड है; रजिस्ट्रेशन के समय सर्वर पर अधिक भार हो सकता है: बाद में फिर कोशिश करें।';

  @override
  String get diagSip481Explain =>
      'सर्वर ने डायलॉग की स्थिति खो दी (जैसे रीस्टार्ट या नेटवर्क बदलने के बाद)।';

  @override
  String get diagSip481Fix =>
      'कॉल काटकर फिर कोशिश करें। बार-बार हो तो सेशन टाइमर चालू करें।';

  @override
  String get diagSip483Explain => 'अनुरोध सर्वरों के बीच चक्कर काटता रहा।';

  @override
  String get diagSip483Fix =>
      'PBX पर फ़ॉरवर्डिंग और रूटिंग कॉन्फ़िगरेशन जाँचें।';

  @override
  String get diagSip484Explain => 'डायल किया गया नंबर बहुत छोटा है।';

  @override
  String get diagSip484Fix => 'पूरा नंबर डायल करें या डायल नियम जाँचें।';

  @override
  String get diagSip486Explain => 'दूसरा पक्ष व्यस्त है।';

  @override
  String get diagSip486Fix => 'बाद में फिर कोशिश करें।';

  @override
  String get diagSip487Explain => 'कॉल उठाए जाने से पहले रद्द हो गई।';

  @override
  String get diagSip487Fix =>
      'घंटी बजते समय कॉल करने वाले के कॉल काटने पर यह सामान्य है।';

  @override
  String get diagSip488Explain =>
      'दूसरे पक्ष के साथ कोई साझा कोडेक या एन्क्रिप्शन सेटिंग नहीं है।';

  @override
  String get diagSip488Fix =>
      'कोडेक और SRTP जाँचें (अनिवार्य-SRTP वाला खाता सादे-RTP एंडपॉइंट को कॉल नहीं कर सकता)।';

  @override
  String get diagSip491Explain => 'दो re-INVITE आपस में टकरा गए।';

  @override
  String get diagSip491Fix => 'आम तौर पर अपने-आप फिर कोशिश होती है।';

  @override
  String get diagSip500Explain => 'सर्वर में आंतरिक विफलता हुई।';

  @override
  String get diagSip500Fix =>
      'बाद में फिर कोशिश करें और जारी रहने पर प्रदाता से संपर्क करें।';

  @override
  String get diagSip502Explain => 'अपस्ट्रीम सर्वर ने अमान्य उत्तर लौटाया।';

  @override
  String get diagSip502Fix =>
      'बाद में फिर कोशिश करें; जारी रहने पर प्रदाता से संपर्क करें।';

  @override
  String get diagSip503Explain =>
      'सर्वर पर अधिक भार है, बंद है, या इस क्लाइंट को अस्वीकार कर रहा है (रेट लिमिट)।';

  @override
  String get diagSip503Fix =>
      'प्रतीक्षा करके फिर कोशिश करें, प्रदाता का स्टेटस पेज देखें, या कोई दूसरा सर्वर/पोर्ट आज़माएँ।';

  @override
  String get diagSip504Explain => 'अपस्ट्रीम सर्वर ने समय पर उत्तर नहीं दिया।';

  @override
  String get diagSip504Fix => 'बाद में फिर कोशिश करें।';

  @override
  String get diagSip600Explain => 'सभी गंतव्य व्यस्त हैं।';

  @override
  String get diagSip600Fix => 'बाद में फिर कोशिश करें।';

  @override
  String get diagSip603Explain => 'दूसरे पक्ष ने कॉल अस्वीकार कर दी।';

  @override
  String get diagSip603Fix => 'ठीक करने को कुछ नहीं: कॉल अस्वीकार की गई थी।';

  @override
  String get diagSip604Explain => 'यह नंबर मौजूद नहीं है।';

  @override
  String get diagSip604Fix => 'डायल किया गया नंबर जाँचें।';

  @override
  String get diagSip606Explain =>
      'दूसरा पक्ष प्रस्तावित रूप में सेशन स्वीकार नहीं कर सकता।';

  @override
  String get diagSip606Fix => 'कोडेक और एन्क्रिप्शन सेटिंग जाँचें।';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'अनंतिम ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'अनुरोध पर कार्रवाई चल रही है।';

  @override
  String diagSipSuccessTitle(int code) {
    return 'सफल ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'अनुरोध सफल रहा।';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'रीडायरेक्ट ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'गंतव्य बदल गया है।';

  @override
  String get diagSipRedirectedFix => 'फ़ॉरवर्डिंग सेटिंग जाँचें।';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'क्लाइंट त्रुटि ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'सर्वर ने अनुरोध अस्वीकार कर दिया।';

  @override
  String get diagSipClientErrorFix => 'खाता और डायल किया गया नंबर जाँचें।';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'सर्वर त्रुटि ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'सर्वर अनुरोध को प्रोसेस नहीं कर सका।';

  @override
  String get diagSipServerErrorFix =>
      'बाद में फिर कोशिश करें या प्रदाता से संपर्क करें।';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'वैश्विक विफलता ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'अनुरोध कहीं भी पूरा नहीं किया जा सकता।';

  @override
  String get diagSipNoResponseTitle => 'कोई उत्तर नहीं';

  @override
  String get diagSipNoResponseExplain => 'कोई SIP उत्तर नहीं मिला।';

  @override
  String get diagSipNoResponseFix => 'नेटवर्क कनेक्शन और सर्वर का पता जाँचें।';

  @override
  String get diagWizStepNet => 'नेटवर्क कनेक्टिविटी';

  @override
  String diagWizStepDns(String account) {
    return 'DNS और SRV: $account';
  }

  @override
  String get diagWizStepNat => 'NAT प्रकार';

  @override
  String diagWizStepOptions(String account) {
    return 'सर्वर तक पहुँच: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS प्रमाणपत्र: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'रजिस्ट्रेशन: $account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALG जाँच';

  @override
  String get diagWizChecking => 'जाँच हो रही है...';

  @override
  String diagWizEngineError(String message) {
    return 'इंजन त्रुटि: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'जाँच विफल रही: $error';
  }

  @override
  String get diagWizNoEngine => 'SIP इंजन नहीं चल रहा है';

  @override
  String get diagWizNoEngineFix =>
      'इंजन के शुरू होने की प्रतीक्षा करें (या ऐप रीस्टार्ट करें), फिर जाँच दोबारा चलाएँ।';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (निजी)';
  }

  @override
  String get diagWizNetNone =>
      'IP पते वाला कोई सक्रिय नेटवर्क इंटरफ़ेस नहीं है';

  @override
  String get diagWizNetNoneFix =>
      'Wi-Fi, ईथरनेट या मोबाइल डेटा से जुड़ें, फिर जाँच दोबारा चलाएँ।';

  @override
  String get diagWizNetIpv6Only => 'केवल IPv6 पते मिले';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'कई SIP प्रदाता केवल IPv4 चलाते हैं। इस नेटवर्क पर IPv4 चालू करें या IPv6 समर्थन वाला प्रदाता उपयोग करें।';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces इंटरफ़ेस',
      one: '1 इंटरफ़ेस',
    );
    String _temp1 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 IPv4 पते',
      one: '1 IPv4 पता',
    );
    return '$_temp0 पर $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'VPN जैसा इंटरफ़ेस सक्रिय है। VPN देरी बढ़ा सकता है या UDP रोक सकता है; कॉल में गड़बड़ी हो तो इसे बंद करें।';

  @override
  String get diagWizDnsNoServer => 'खाते में सर्वर का पता नहीं है';

  @override
  String get diagWizDnsNoServerFix =>
      'खाता संपादित करें और SIP डोमेन दर्ज करें।';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host एक IP पता है, DNS की ज़रूरत नहीं';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: कोई नहीं';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: कोई नहीं ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: कोई नहीं';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (प्राथमिकता $priority, भार $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: लुकअप विफल ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host रिज़ॉल्व नहीं होता';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'डोमेन में वर्तनी की गलती और अपने DNS सर्वर का काम करना जाँचें। आप सेटिंग > नेटवर्क में कस्टम DNS सर्वर (जैसे 8.8.8.8) सेट कर सकते हैं।';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host के SRV रिकॉर्ड हैं लेकिन एड्रेस रिकॉर्ड नहीं है';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'SRV टारगेट उपयोग किए जाएँगे। कॉल विफल हों तो प्रदाता से A रिकॉर्ड जाँचने को कहें।';

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
      other: ', $srv SRV रिकॉर्ड',
      one: ', 1 SRV रिकॉर्ड',
      zero: '',
    );
    return '$host का पता $address है$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'NAT पहचान का समय समाप्त हो गया';

  @override
  String get diagWizNatTimeoutFix =>
      'STUN सर्वर तक पहुँचा न जा रहा हो (UDP ब्लॉक है?)। सेटिंग > नेटवर्क > STUN सर्वर जाँचें।';

  @override
  String diagWizNatStun(String server) {
    return 'STUN सर्वर: $server';
  }

  @override
  String get diagWizNatOpen => 'कोई NAT नहीं: इस डिवाइस का सार्वजनिक पता है';

  @override
  String get diagWizNatFullCone => 'Full cone NAT: VoIP के अनुकूल';

  @override
  String get diagWizNatRestricted =>
      'Restricted cone NAT: STUN और कीप-अलाइव के साथ काम करता है';

  @override
  String get diagWizNatPortRestricted =>
      'Port-restricted cone NAT: STUN और कीप-अलाइव के साथ काम करता है';

  @override
  String get diagWizNatSymmetric =>
      'Symmetric NAT: अकेला STUN मीडिया पोर्ट का अनुमान नहीं लगा सकता';

  @override
  String get diagWizNatSymmetricFix =>
      'कुछ कॉल में एकतरफ़ा ऑडियो या बिना ऑडियो की संभावना है। खाता सेटिंग (खाता > NAT) में ICE और TURN रिले चालू करें, या मीडिया रिले (rtpengine) वाला प्रदाता/PBX उपयोग करें।';

  @override
  String get diagWizNatBlocked => 'ऐसा लगता है कि UDP ब्लॉक है';

  @override
  String get diagWizNatBlockedFix =>
      'खाते के लिए TCP या TLS ट्रांसपोर्ट उपयोग करें। यदि नेटवर्क वेब ट्रैफ़िक के अलावा सब फ़िल्टर करता है, तो प्रदाता के समर्थन करने पर पोर्ट 443 पर TLS आज़माएँ।';

  @override
  String get diagWizNatUnknown => 'NAT प्रकार पता नहीं चल सका';

  @override
  String get diagWizNatUnknownFix =>
      'STUN सर्वर ने उत्तर नहीं दिया। सेटिंग > नेटवर्क में दूसरा STUN सर्वर आज़माएँ।';

  @override
  String get diagWizNatErr =>
      'STUN सर्वर ने उत्तर नहीं दिया, इसलिए NAT प्रकार पता नहीं चल सका।';

  @override
  String get diagWizNatUnknownRaw => 'NAT प्रकार पता नहीं चल सका।';

  @override
  String get diagWizOptionsNotLoaded => 'खाता इंजन में लोड नहीं है';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return '$seconds से के भीतर OPTIONS का कोई उत्तर नहीं (ट्रांसपोर्ट: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'सर्वर तक पहुँचा नहीं जा सकता। पता और पोर्ट जाँचें, देखें कि फ़ायरवॉल SIP को रोक तो नहीं रहा, और दूसरा ट्रांसपोर्ट (TCP/TLS) आज़माएँ।';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'अनुरोध का समय समाप्त हो गया ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'सर्वर ने $ms ms बाद $code $reason लौटाया';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'सर्वर ने $ms ms में $code $reason लौटाया';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'OPTIONS पर $code सामान्य है: सर्वर पहुँच में है लेकिन अनाम जाँच की अनुमति नहीं देता।';
  }

  @override
  String get diagWizOptionsSlowFix =>
      '300 ms से अधिक राउंड-ट्रिप समय बातचीत में ध्यान देने योग्य देरी जोड़ता है। नज़दीकी सर्वर या वायर्ड कनेक्शन से मदद मिलती है।';

  @override
  String get diagWizTlsRejected => 'सर्वर प्रमाणपत्र अस्वीकार कर दिया गया';

  @override
  String diagWizTlsSubject(String value) {
    return 'विषय: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'जारीकर्ता: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'समस्याएँ: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'समाप्ति: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'सिफ़र: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'यदि यह आपका अपना PBX है जिसमें सेल्फ़-साइन्ड प्रमाणपत्र है और ऊपर का फ़िंगरप्रिंट मेल खाता है, तो आप उस पर भरोसा कर सकते हैं। नहीं तो प्रदाता से सार्वजनिक CA का प्रमाणपत्र माँगें।';

  @override
  String get diagWizTlsTrust => 'इस प्रमाणपत्र पर भरोसा करें';

  @override
  String diagWizTlsExpired(String date) {
    return 'प्रमाणपत्र $date को समाप्त हो गया';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'सर्वर एडमिनिस्ट्रेटर से प्रमाणपत्र का नवीनीकरण करने को कहें।';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'प्रमाणपत्र $days दिनों में समाप्त हो रहा है',
      one: 'प्रमाणपत्र 1 दिन में समाप्त हो रहा है',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'सर्वर एडमिनिस्ट्रेटर को जल्द नवीनीकरण करने के लिए कहें।';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'जुड़ गया, लेकिन सत्यापन में रिपोर्ट मिली: $problems';
  }

  @override
  String get diagWizTlsOk => 'TLS कनेक्शन स्थापित, प्रमाणपत्र मान्य';

  @override
  String get diagWizTlsRegistered =>
      'TLS पर रजिस्टर्ड (प्रमाणपत्र का कोई विवरण नहीं मिला)';

  @override
  String get diagWizTlsNone => 'अभी तक कोई TLS कनेक्शन नहीं देखा गया';

  @override
  String get diagWizTlsNoneFix =>
      'TLS पोर्ट (आम तौर पर 5061) जाँचें और देखें कि सर्वर TLS 1.2 या नया स्वीकार करता है।';

  @override
  String get diagWizRegDisabledByConfig =>
      'इस खाते के लिए रजिस्ट्रेशन अक्षम है (पीयर-टू-पीयर उपयोग)';

  @override
  String get diagWizRegRegistered => 'रजिस्टर्ड';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'रजिस्टर्ड ($seconds से में समाप्त)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'ट्रांसपोर्ट: $transport';
  }

  @override
  String get diagWizRegInProgress => 'रजिस्ट्रेशन अभी जारी है';

  @override
  String get diagWizRegInProgressFix =>
      'कुछ सेकंड प्रतीक्षा करें। यदि यह पूरा नहीं होता, तो सर्वर उत्तर नहीं दे रहा; ऊपर की पहुँच-जाँच देखें।';

  @override
  String get diagWizRegFailed => 'रजिस्ट्रेशन विफल रहा';

  @override
  String get diagWizRegOffline => 'खाता ऑफ़लाइन है';

  @override
  String get diagWizRegOfflineFix =>
      'नेटवर्क कनेक्शन जाँचें। ऐप अपने-आप फिर कोशिश करता है।';

  @override
  String get diagWizRegDisabled => 'खाता अक्षम है';

  @override
  String get diagWizAlgNoUdp =>
      'कोई खाता UDP का उपयोग नहीं करता, इसलिए SIP ALG चिंता का विषय नहीं है';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: UDP पर कोई उत्तर नहीं, लेकिन TCP पर उत्तर मिला ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: UDP या TCP किसी पर उत्तर नहीं (ALG के बजाय सर्वर या फ़ायरवॉल की समस्या)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS का उत्तर मिलता है लेकिन REGISTER का समय समाप्त हो जाता है, जो SIP बदलने वाले राउटर का विशिष्ट लक्षण है';
  }

  @override
  String get diagWizAlgSuspected => 'आपके राउटर पर SIP ALG का संदेह है';

  @override
  String get diagWizAlgSuspectedFix =>
      'राउटर सेटिंग में \"SIP ALG\" / \"SIP helper\" बंद करें, या खाते को TCP या TLS पर करें, या SIP पोर्ट बदलें (जैसे 5080) ताकि राउटर पैकेट बिगाड़ना बंद कर दे।';

  @override
  String get diagWizAlgContactChanged =>
      'अनुरोध और उत्तर के बीच Contact पता बदल गया';

  @override
  String get diagWizAlgContactChangedFix =>
      'यह SIP ALG या कॉन्टैक्ट बदलने वाला सर्वर हो सकता है। यदि कॉल की घंटी बजती है पर ऑडियो नहीं आता या कुछ देर बाद कट जाती है, तो राउटर पर SIP ALG बंद करें या TCP/TLS या पोर्ट 5080 उपयोग करें।';

  @override
  String get diagWizAlgOk => 'SIP ALG के हस्तक्षेप का कोई संकेत नहीं';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER Contact $sent वापस $received बनकर आया';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '$fileName सहेजें';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName सहेजी गई';
  }

  @override
  String get diagSaveFailed => 'फ़ाइल सहेजी नहीं जा सकी';

  @override
  String get diagCopiedText => 'टेक्स्ट क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get diagCopiedReport => 'रिपोर्ट क्लिपबोर्ड पर कॉपी हो गई';

  @override
  String get diagCopiedBundle => 'डायग्नोस्टिक बंडल क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get diagCopiedLogs => 'लॉग क्लिपबोर्ड पर कॉपी हो गए';

  @override
  String get diagCopiedTrace => 'ट्रेस क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get diagCopiedDialog => 'डायलॉग क्लिपबोर्ड पर कॉपी हो गया';

  @override
  String get diagSaveAsLog => '.log के रूप में सहेजें';

  @override
  String get diagSysAppVersion => 'ऐप संस्करण';

  @override
  String get diagSysPlatform => 'प्लैटफ़ॉर्म';

  @override
  String get diagSysEngine => 'इंजन';

  @override
  String get diagSysAccounts => 'खाते';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$total में से $registered रजिस्टर्ड';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'सिस्टम जानकारी पढ़ी नहीं जा सकी: $error';
  }

  @override
  String get diagSysTransports => 'ट्रांसपोर्ट';

  @override
  String get diagSysNoneReported => 'कोई रिपोर्ट नहीं';

  @override
  String get diagSysCodecs => 'कोडेक';

  @override
  String get diagSysCodecsFooter => 'सक्षम कोडेक, सबसे ऊँची प्राथमिकता पहले।';

  @override
  String get diagSysEngineNotRunning => 'इंजन नहीं चल रहा';

  @override
  String diagSysCodecPriority(int priority) {
    return 'प्राथमिकता $priority';
  }

  @override
  String get diagSysCodecDisabled => 'अक्षम';

  @override
  String get diagSysExport => 'एक्सपोर्ट';

  @override
  String get diagSysExportFooter =>
      'बंडल में सिस्टम जानकारी, नेटवर्क जाँच के नतीजे, हालिया लॉग और SIP ट्रेस होते हैं, क्रेडेंशियल छिपाकर।';

  @override
  String get diagSysCopyBundle => 'डायग्नोस्टिक बंडल कॉपी करें';

  @override
  String get diagSysSaveBundle => 'डायग्नोस्टिक बंडल सहेजें';

  @override
  String get diagTabSipTrace => 'SIP ट्रेस';

  @override
  String get diagTabNetwork => 'नेटवर्क';

  @override
  String get diagTabQuality => 'गुणवत्ता';

  @override
  String get diagTabAudioTest => 'ऑडियो टेस्ट';

  @override
  String get diagTabLogs => 'लॉग';

  @override
  String get diagTabSystem => 'सिस्टम';

  @override
  String diagRawSentTo(String remote) {
    return '$remote को भेजा गया';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return '$remote से प्राप्त';
  }

  @override
  String get diagRawCopied => 'संदेश कॉपी हो गया';

  @override
  String get diagRawLadder => 'लैडर';

  @override
  String get diagRawRedact => 'क्रेडेंशियल छिपाएँ';

  @override
  String diagRawTruncated(int count) {
    return '... छोटा किया गया ($count अक्षर)';
  }

  @override
  String get diagWizIntro =>
      'आपका कनेक्शन, DNS, NAT, सर्वर तक पहुँच, TLS और रजिस्ट्रेशन जाँचता है और बताता है कि क्या ठीक करना है।';

  @override
  String get diagWizStop => 'रोकें';

  @override
  String get diagWizRunChecks => 'जाँच चलाएँ';

  @override
  String get diagWizRunAgain => 'फिर चलाएँ';

  @override
  String get diagWizCopyReport => 'रिपोर्ट कॉपी करें';

  @override
  String get diagWizSaveReport => 'रिपोर्ट सहेजें';

  @override
  String diagWizCountPassed(int count) {
    return 'सफल $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'चेतावनी $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'विफल $count';
  }

  @override
  String get diagWizStatusPass => 'सफल';

  @override
  String get diagWizStatusWarn => 'चेतावनी';

  @override
  String get diagWizStatusFail => 'विफल';

  @override
  String get diagWizStatusSkipped => 'छोड़ा गया';

  @override
  String get diagWizStatusRunning => 'चल रहा है';

  @override
  String get diagWizStatusPending => 'लंबित';

  @override
  String get diagQualityTitle => 'कॉल की गुणवत्ता';

  @override
  String get diagQualityNoData =>
      'इस कॉल के लिए कोई गुणवत्ता डेटा दर्ज नहीं हुआ।';

  @override
  String get diagQualityTraceForCall => 'इस कॉल का SIP ट्रेस';

  @override
  String get diagQualityTraceNotCaptured =>
      'इस कॉल का SIP ट्रेस कैप्चर नहीं हुआ';

  @override
  String get diagQualityLiveCall => 'लाइव कॉल';

  @override
  String get diagQualityNoActiveCall =>
      'कोई सक्रिय कॉल नहीं। कॉल शुरू करें तो MOS, जिटर, लॉस और राउंड-ट्रिप समय यहाँ लाइव प्लॉट होंगे।';

  @override
  String get diagQualityRecentCalls => 'हालिया कॉल';

  @override
  String get diagQualityNoFinished =>
      'अभी तक गुणवत्ता डेटा वाली कोई पूरी हुई कॉल नहीं।';

  @override
  String get diagQualityCallEnded => 'कॉल समाप्त हो चुकी है।';

  @override
  String get diagQualityMeasuring => 'मापा जा रहा है';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return '$title चार्ट';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return '$title चार्ट, नवीनतम $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   अधिकतम $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'औसत $avg  ·  सबसे खराब $worst';
  }

  @override
  String get diagQualityCodec => 'कोडेक';

  @override
  String get diagQualityLoss => 'लॉस';

  @override
  String get diagQualityJitter => 'जिटर';

  @override
  String diagQualityPackets(int count) {
    return '$count पैकेट';
  }

  @override
  String get diagQualityMedia => 'मीडिया';

  @override
  String get diagQualityNoSeries =>
      'इस कॉल के लिए कोई टाइम सीरीज़ दर्ज नहीं हुई।';

  @override
  String get diagQualityPacketLoss => 'पैकेट लॉस';

  @override
  String get diagQualityRtt => 'राउंड-ट्रिप समय';

  @override
  String get diagLogsForward => 'इंजन लॉग फ़ॉरवर्ड करें';

  @override
  String get diagLogsForwardSub => 'pjsip लॉग पंक्तियाँ इस व्यूअर को भेजें';

  @override
  String diagLogsLevel(int level, String name) {
    return 'स्तर $level ($name)';
  }

  @override
  String get diagLogsRedact => 'एक्सपोर्ट पर छिपाएँ';

  @override
  String get diagLogsSearch => 'लॉग खोजें';

  @override
  String get diagLogsEmpty => 'अभी तक कोई लॉग पंक्ति नहीं।';

  @override
  String get diagLogsForwardingOff =>
      'लॉग फ़ॉरवर्डिंग बंद है। इंजन लॉग कैप्चर करने के लिए इसे चालू करें।';

  @override
  String get diagLogsNoMatch => 'कोई पंक्ति खोज से मेल नहीं खाती।';

  @override
  String get diagAudioEngineNotRunning => 'SIP इंजन नहीं चल रहा है।';

  @override
  String get diagAudioMicrophone => 'माइक्रोफ़ोन';

  @override
  String get diagAudioMicFooter =>
      'लेवल मीटर ऑडियो डिवाइस को पढ़ता है, जिसे इंजन कॉल या इको टेस्ट के दौरान खोलता है।';

  @override
  String get diagAudioLevelMeter => 'लेवल मीटर';

  @override
  String get diagAudioLevelMeterSub => 'बोलें और बार को हिलते देखें';

  @override
  String get diagAudioMic => 'माइक';

  @override
  String get diagAudioSpeaker => 'स्पीकर';

  @override
  String get diagAudioEchoTest => 'इको टेस्ट';

  @override
  String get diagAudioEchoFooter =>
      'आपकी आवाज़ स्पीकर पर वापस सुनाता है। फ़ीडबैक से बचने के लिए हेडफ़ोन लगाएँ।';

  @override
  String get diagAudioEchoActive => 'चालू: अब बोलें';

  @override
  String get diagAudioEchoIdle => 'माइक से स्पीकर लूपबैक';

  @override
  String get diagAudioSpeakerTest => 'स्पीकर टेस्ट';

  @override
  String get diagAudioPlayTone => 'टेस्ट टोन बजाएँ';

  @override
  String get diagAudioPlayToneSub => 'चुने गए स्पीकर पर बजता है';

  @override
  String get diagAudioPlayingDtmf => 'DTMF बज रहा है';

  @override
  String get diagAudioPlayingRingback => 'रिंगबैक बज रहा है';

  @override
  String get diagAudioRingback => 'रिंगबैक';

  @override
  String get diagAudioDevices => 'डिवाइस';

  @override
  String get diagAudioChooseDevices => 'माइक्रोफ़ोन और स्पीकर चुनें';

  @override
  String get diagAudioChooseDevicesSub => 'सेटिंग > ऑडियो खोलता है';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label स्तर $percent प्रतिशत';
  }

  @override
  String get diagLadderLocal => 'स्थानीय';

  @override
  String diagLadderSent(String message) {
    return '$message भेजा गया';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message प्राप्त हुआ';
  }

  @override
  String get diagTraceCapture => 'SIP संदेश कैप्चर करें';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संदेश',
      one: '1 संदेश',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संदेश',
      one: '1 संदेश',
    );
    return '$_temp0  ·  $size  ·  $dropped पुराने हटाए गए';
  }

  @override
  String get diagTraceOffHint =>
      'बंद। इसे चालू करें, फिर रजिस्टर करें या कॉल करें।';

  @override
  String get diagTraceExportOrClear => 'एक्सपोर्ट करें या साफ़ करें';

  @override
  String get diagTraceSaveAsPcap => '.pcap के रूप में सहेजें';

  @override
  String get diagTraceCopyAsText => 'टेक्स्ट के रूप में कॉपी करें';

  @override
  String get diagTraceSearchHint => 'टेक्स्ट, नंबर या Call-ID खोजें';

  @override
  String get diagTraceErrorsOnly => 'केवल त्रुटियाँ';

  @override
  String get diagTraceFilterMethod => 'मेथड के अनुसार फ़िल्टर करें';

  @override
  String get diagTraceAllMethods => 'सभी मेथड';

  @override
  String get diagTraceMethod => 'मेथड';

  @override
  String get diagTraceFilterAccount => 'खाते के अनुसार फ़िल्टर करें';

  @override
  String get diagTraceAllAccounts => 'सभी खाते';

  @override
  String get diagTraceAccount => 'खाता';

  @override
  String get diagTraceRedact => 'छिपाएँ';

  @override
  String get diagTraceList => 'सूची';

  @override
  String get diagTraceWaiting => 'SIP ट्रैफ़िक की प्रतीक्षा है';

  @override
  String get diagTraceWaitingSub =>
      'कोई खाता रजिस्टर करें या कॉल करें, संदेश यहाँ दिखाई देंगे।';

  @override
  String get diagTraceOff => 'SIP ट्रेस बंद है';

  @override
  String get diagTraceOffSub =>
      'हर SIP अनुरोध और उत्तर को सूची या लैडर डायग्राम के रूप में देखने के लिए कैप्चर चालू करें।';

  @override
  String get diagTraceNoMatch => 'कोई संदेश फ़िल्टर से मेल नहीं खाता';

  @override
  String get diagTraceAllDialogs => 'सभी डायलॉग';

  @override
  String get diagTraceCopyDialog => 'यह डायलॉग कॉपी करें';

  @override
  String get diagTraceNoResponse => 'कोई उत्तर नहीं';

  @override
  String get diagTraceNoCallId => 'Call-ID नहीं';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count संदेश',
      one: '1 संदेश',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'रिकॉर्डिंग';

  @override
  String get recFormatWav => 'मानक (WAV)';

  @override
  String get recFormatWavStereo =>
      'स्टीरियो, आप और कॉल करने वाला अलग चैनलों पर (WAV)';

  @override
  String get recFormatOpus => 'संपीड़ित (Opus)';

  @override
  String get recFormatWavHint => 'मोनो, लगभग 2 MB प्रति मिनट। हर जगह चलता है।';

  @override
  String get recFormatWavStereoHint =>
      'दो चैनल, लगभग 4 MB प्रति मिनट। आप बाएँ पर, कॉल करने वाला दाएँ पर।';

  @override
  String get recFormatOpusHint =>
      'लगभग 0.2 MB प्रति मिनट। Ogg Opus; iPhone, Mac और Windows के कुछ प्लेयर इसे नहीं खोल पाते।';

  @override
  String get recOptionInherit => 'ग्लोबल सेटिंग उपयोग करें';

  @override
  String get recOptionAlways => 'सभी कॉल रिकॉर्ड करें';

  @override
  String get recOptionIncoming => 'केवल इनकमिंग कॉल रिकॉर्ड करें';

  @override
  String get recOptionOutgoing => 'केवल आउटगोइंग कॉल रिकॉर्ड करें';

  @override
  String get recOptionNever => 'कभी रिकॉर्ड न करें';

  @override
  String get recRuleAll => 'सभी कॉल';

  @override
  String get recRuleIncoming => 'केवल इनकमिंग कॉल';

  @override
  String get recRuleOutgoing => 'केवल आउटगोइंग कॉल';

  @override
  String get recAutoDeleteNever => 'कभी नहीं';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन बाद',
      one: '1 दिन बाद',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => '1 साल बाद';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग',
      one: '1 रिकॉर्डिंग',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग',
      one: '1 रिकॉर्डिंग',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग',
      one: '1 रिकॉर्डिंग',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन',
      one: '1 दिन',
    );
    return '$_temp0  ·  $size  ·  $_temp1 बाद अपने-आप हटेंगी';
  }

  @override
  String get recSettingsFormat => 'फ़ॉर्मैट';

  @override
  String get recSettingsAutoGroup => 'स्वचालित रिकॉर्डिंग';

  @override
  String get recSettingsAutoFooter =>
      'कॉल रिकॉर्ड करने से पहले अपने स्थानीय कानून जाँच लें। इन नियमों से परे किसी संपर्क की कॉल रिकॉर्ड करने के लिए उस संपर्क में \"इस संपर्क के साथ कॉल हमेशा रिकॉर्ड करें\" चालू करें।';

  @override
  String get recSettingsAutoRule => 'कॉल अपने-आप रिकॉर्ड करें';

  @override
  String get recSettingsAccountOverride => 'इस खाते के लिए ओवरराइड';

  @override
  String get recSettingsNoticesGroup => 'सूचनाएँ';

  @override
  String get recSettingsNoticeSwitch => 'रिकॉर्डिंग से पहले सूचना बजाएँ';

  @override
  String get recSettingsNoticeSwitchHint =>
      'पहले दूसरे पक्ष को एक सूचना सुनाता है। सूचना फ़ाइल सेटिंग > कॉल > घोषणाएँ में चुनी जाती है।';

  @override
  String get recSettingsNoticeFile => 'सूचना फ़ाइल चुनें';

  @override
  String get recSettingsNoticeFileHint => 'सेटिंग > कॉल > घोषणाएँ खोलता है';

  @override
  String get recSettingsBeep => 'रिकॉर्डिंग बीप';

  @override
  String get recSettingsBeepHint => 'दूसरे पक्ष को समय-समय पर चेताएँ';

  @override
  String get recSettingsTransfersGroup => 'ट्रांसफ़र';

  @override
  String get recSettingsContinue =>
      'ट्रांसफ़र के दौरान भी रिकॉर्डिंग जारी रखें';

  @override
  String get recSettingsContinueHint =>
      'अटेंडेड ट्रांसफ़र की परामर्श कॉल और ट्रांसफ़र से हमें सौंपी गई कॉल रिकॉर्ड करें, और रिकॉर्डिंग आपस में जोड़ें';

  @override
  String get recSettingsStorageGroup => 'स्टोरेज';

  @override
  String get recSettingsFolder => 'फ़ोल्डर';

  @override
  String get recSettingsFolderHint => 'रिकॉर्डिंग कहाँ सहेजी जाती हैं';

  @override
  String get recSettingsFolderPlaceholder => 'ऐप दस्तावेज़ / Recordings';

  @override
  String get recSettingsChooseFolder => 'फ़ोल्डर चुनें...';

  @override
  String get recSettingsFolderPickerTitle => 'रिकॉर्डिंग फ़ोल्डर';

  @override
  String get recSettingsAutoDelete => 'पुरानी रिकॉर्डिंग हटाएँ';

  @override
  String get recSettingsAutoDeleteHint =>
      'स्टार्टअप पर और दिन में एक बार जाँची जाती है';

  @override
  String get recSettingsManage => 'रिकॉर्डिंग प्रबंधित करें';

  @override
  String get recSettingsOpenFolder => 'रिकॉर्डिंग फ़ोल्डर खोलें';

  @override
  String get recPageTitle => 'रिकॉर्डिंग';

  @override
  String recSelectedCount(int count) {
    return '$count चुनी गईं';
  }

  @override
  String get recCancelSelection => 'चयन रद्द करें';

  @override
  String get recSelectAll => 'सभी चुनें';

  @override
  String get recShareSelected => 'चुनी हुई शेयर करें';

  @override
  String get recDeleteSelected => 'चुनी हुई हटाएँ';

  @override
  String get recSearchTooltip => 'रिकॉर्डिंग खोजें';

  @override
  String get recSelectTooltip => 'रिकॉर्डिंग चुनें';

  @override
  String get recMenuSettings => 'रिकॉर्डिंग सेटिंग';

  @override
  String get recSearchHint => 'नाम या नंबर खोजें';

  @override
  String get recEmptyNone => 'अभी तक कोई रिकॉर्डिंग नहीं';

  @override
  String get recEmptyNoneHint =>
      'रिकॉर्ड बटन से कॉल रिकॉर्ड करें, या सेटिंग में स्वचालित रिकॉर्डिंग चालू करें।';

  @override
  String get recEmptyNoMatch => 'कोई मेल खाती रिकॉर्डिंग नहीं';

  @override
  String get recEmptyNoMatchHint => 'कोई दूसरी खोज या फ़िल्टर आज़माएँ।';

  @override
  String get recClearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिकॉर्डिंग हटाएँ?',
      one: '1 रिकॉर्डिंग हटाएँ?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'ऑडियो फ़ाइलें इस डिवाइस से हटा दी जाती हैं। इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get recDeleteOneTitle => 'यह रिकॉर्डिंग हटाएँ?';

  @override
  String get recDeleteOneMessage =>
      'ऑडियो फ़ाइल इस डिवाइस से हटा दी जाती है। इसे पहले जैसा नहीं किया जा सकता।';

  @override
  String get recFilterAll => 'सभी';

  @override
  String get recFilterIncoming => 'इनकमिंग';

  @override
  String get recFilterOutgoing => 'आउटगोइंग';

  @override
  String get recFilterByAccount => 'खाते के अनुसार फ़िल्टर करें';

  @override
  String get recFilterAllAccounts => 'सभी खाते';

  @override
  String get recFilterAccountFallback => 'खाता';

  @override
  String get recFilterAnyDate => 'कोई भी तारीख़';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'तारीख़ें साफ़ करें';

  @override
  String get recMissingFile => 'ऑडियो फ़ाइल इस डिवाइस पर नहीं मिली।';

  @override
  String recRelated(String title) {
    return 'संबंधित: $title';
  }

  @override
  String get recRenameTitle => 'रिकॉर्डिंग का नाम बदलें';

  @override
  String get recRenameHint => 'नाम';

  @override
  String get recSaveAs => 'इस रूप में सहेजें...';

  @override
  String get recShowInFinder => 'Finder में दिखाएँ';

  @override
  String get recShowInFolder => 'फ़ोल्डर में दिखाएँ';

  @override
  String get recViewCall => 'कॉल देखें';

  @override
  String recSavedTo(String path) {
    return '$path पर सहेजी गई';
  }

  @override
  String get recSaveFailed => 'रिकॉर्डिंग सहेजी नहीं जा सकी';

  @override
  String get recShareFailed => 'रिकॉर्डिंग शेयर नहीं की जा सकी';

  @override
  String get recSaveDialogTitle => 'रिकॉर्डिंग सहेजें';

  @override
  String get recShareSubject => 'कॉल रिकॉर्डिंग';

  @override
  String get recPlayerUnsupported =>
      'यह डिवाइस यहाँ Opus रिकॉर्डिंग नहीं चला सकता।';

  @override
  String get recPlayerOpenWith => 'इससे खोलें...';

  @override
  String get recPlayerNotFound => 'रिकॉर्डिंग फ़ाइल नहीं मिली';

  @override
  String recPlayerCannotPlay(String error) {
    return 'यह रिकॉर्डिंग चलाई नहीं जा सकती: $error';
  }

  @override
  String get recPlayerPlay => 'रिकॉर्डिंग चलाएँ';

  @override
  String get recPlayerPause => 'रिकॉर्डिंग रोकें';

  @override
  String get audioFilesTitle => 'ऑडियो फ़ाइलें';

  @override
  String audioAdded(String name) {
    return '\"$name\" जोड़ी गई';
  }

  @override
  String get audioFileUnavailable => 'वह फ़ाइल उपलब्ध नहीं है।';

  @override
  String get audioNameRequired => 'नाम दर्ज करें';

  @override
  String audioDeleteTitle(String name) {
    return '\"$name\" हटाएँ?';
  }

  @override
  String get audioDeleteMessage =>
      'इस फ़ाइल का उपयोग करने वाली सेटिंग डिफ़ॉल्ट पर लौट जाती हैं।';

  @override
  String get audioGroupAdd => 'जोड़ें';

  @override
  String get audioAddFooter =>
      'WAV (PCM, mu-law, A-law) और MP3 फ़ाइलें काम करती हैं। फ़ाइलें ऐप में कॉपी की जाती हैं, इसलिए मूल फ़ाइल कहीं और ले जाई जा सकती है।';

  @override
  String get audioImport => 'WAV या MP3 इंपोर्ट करें…';

  @override
  String get audioGroupMine => 'मेरी फ़ाइलें';

  @override
  String get audioEmptyTitle => 'अभी तक कोई फ़ाइल नहीं';

  @override
  String get audioEmptyHint => 'फ़ाइल इंपोर्ट करें या अपनी घोषणा रिकॉर्ड करें।';

  @override
  String get audioGroupBuiltIn => 'अंतर्निहित';

  @override
  String get audioBuiltInFooter =>
      'SoftphonePro के लिए बनाई गईं, उपयोग के लिए मुफ़्त।';

  @override
  String get audioPreviewStop => 'पूर्वावलोकन रोकें';

  @override
  String audioPreviewPlay(String name) {
    return '$name का पूर्वावलोकन';
  }

  @override
  String get audioRecordedName => 'इस रिकॉर्डिंग को नाम दें';

  @override
  String get audioRecordedDefaultName => 'मेरी घोषणा';

  @override
  String audioSaved(String name) {
    return '\"$name\" सहेजी गई';
  }

  @override
  String get audioRecorderStop => 'रोकें';

  @override
  String get audioRecorderPlay => 'रिकॉर्डिंग चलाएँ';

  @override
  String audioRecorderNew(String duration) {
    return 'नई रिकॉर्डिंग  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'छोड़ें';

  @override
  String get audioRecordOwn => 'अपनी रिकॉर्ड करें…';

  @override
  String get audioRecordOwnHint =>
      'ऑडियो सेटिंग में चुने गए माइक्रोफ़ोन का उपयोग करता है';

  @override
  String get audioMissingFile => 'फ़ाइल गायब है';

  @override
  String get audioBuiltInCalm => 'शांत (अंतर्निहित)';

  @override
  String get audioBuiltInBreeze => 'ठंडी हवा (अंतर्निहित)';

  @override
  String get audioBuiltInChime => 'सूचना घंटी (अंतर्निहित)';

  @override
  String get audioErrOnlyWavMp3 =>
      'केवल WAV और MP3 फ़ाइलें उपयोग की जा सकती हैं।';

  @override
  String get audioErrNotFound => 'वह फ़ाइल नहीं मिली।';

  @override
  String get audioErrNotSaved => 'रिकॉर्डिंग सहेजी नहीं गई।';

  @override
  String get audioErrEmpty => 'यह ऑडियो फ़ाइल खाली है या पढ़ी नहीं जा सकती।';

  @override
  String audioErrUnusable(String reason) {
    return 'यह ऑडियो फ़ाइल उपयोग नहीं की जा सकती ($reason)। PCM, mu-law या A-law WAV, या MP3 उपयोग करें।';
  }

  @override
  String get audioRecEngineOff => 'कॉल इंजन नहीं चल रहा है।';

  @override
  String get audioRecUnsupported =>
      'कॉल इंजन का यह संस्करण माइक्रोफ़ोन रिकॉर्ड नहीं कर सकता।';

  @override
  String audioRecStartFailed(String reason) {
    return 'रिकॉर्डिंग शुरू नहीं हो सकी: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'रिकॉर्डिंग विफल रही: $reason';
  }

  @override
  String get audioStrengthLow => 'कम';

  @override
  String get audioStrengthMedium => 'मध्यम';

  @override
  String get audioStrengthHigh => 'उच्च';

  @override
  String get audioStrengthMax => 'अधिकतम';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'सिस्टम डिफ़ॉल्ट ($name)';
  }

  @override
  String get voiceTitle => 'वॉइस आइसोलेशन';

  @override
  String get voiceUnavailable =>
      'कॉल इंजन के इस बिल्ड में AI नॉइज़ कैंसलेशन उपलब्ध नहीं है। प्रोसेसिंग के अंतर्गत मानक शोर दमन अब भी काम करता है।';

  @override
  String get voiceGroupAi => 'AI नॉइज़ कैंसलेशन';

  @override
  String get voiceAiFooter =>
      'डिवाइस पर चलने वाले न्यूरल नेटवर्क (RNNoise) से कॉल में कीबोर्ड की खटखट, पंखे और पृष्ठभूमि की आवाज़ें हटाता है। कुछ भी आपके डिवाइस से बाहर नहीं जाता। अधिक तीव्रता ज़्यादा शोर हटाती है लेकिन शब्दों की शुरुआत कट सकती है।';

  @override
  String get voiceMic => 'मेरा माइक्रोफ़ोन';

  @override
  String get voiceMicHint => 'दूसरे व्यक्ति को जो सुनाई देता है उसे साफ़ करें';

  @override
  String get voiceOthers => 'अन्य प्रतिभागी';

  @override
  String get voiceOthersHint =>
      'आपको सुनाई देने वाले शोर भरे कॉलर को साफ़ करें';

  @override
  String voiceStrength(String value) {
    return 'तीव्रता: $value';
  }

  @override
  String get voiceGroupTry => 'आज़माएँ';

  @override
  String get voiceTryFooter =>
      'इको टेस्ट के लिए हेडफ़ोन लगाएँ, नहीं तो फ़ीडबैक सुनाई देगा।';

  @override
  String get voiceEchoTest => 'इको के साथ जाँचें';

  @override
  String get voiceEchoTestHint =>
      'प्रोसेस किया गया आपका माइक्रोफ़ोन आपको वापस सुनाता है';

  @override
  String get voiceEchoFailed => 'इको टेस्ट विफल रहा';

  @override
  String get voiceGroupSystem => 'सिस्टम';

  @override
  String get voiceSystemFooter =>
      'macOS और iOS हर ऐप के लिए आपकी आवाज़ अलग भी कर सकते हैं। सिस्टम माइक्रोफ़ोन मोड में वॉइस आइसोलेशन चुनें।';

  @override
  String get voiceSystemMode => 'सिस्टम माइक्रोफ़ोन मोड (वॉइस आइसोलेशन)…';

  @override
  String get voiceSystemModeUnsupported =>
      'माइक्रोफ़ोन मोड के लिए macOS 12 या iOS 15 या बाद का संस्करण चाहिए।';

  @override
  String get voiceSpeechDetection => 'बोली की पहचान';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent प्रतिशत';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Android ऑडियो इफ़ेक्ट';

  @override
  String get voiceAndroidFooter =>
      'फ़ोन खुद भी माइक्रोफ़ोन को साफ़ कर सकता है। ये Android द्वारा बताए जाते हैं और ऊपर की सेटिंग से अलग हैं।';

  @override
  String get voiceAndroidNs => 'शोर दमनकर्ता';

  @override
  String get voiceAndroidAec => 'इको कैंसलर';

  @override
  String get voiceNotAvailableDevice => 'इस डिवाइस पर उपलब्ध नहीं';

  @override
  String get callLinkNotLocal =>
      'इस प्रकार का लिंक केवल इस कंप्यूटर की कमांड लाइन से इस्तेमाल किया जा सकता है।';

  @override
  String linkLanConnectTitle(String name) {
    return 'डिवाइस $name से कनेक्ट करें?';
  }

  @override
  String get linkLanConnectBody =>
      'किसी दूसरे ऐप या वेब पेज का लिंक SoftphonePro को इस डिवाइस से जोड़ना चाहता है। केवल तभी कनेक्ट करें जब आप इसकी उम्मीद कर रहे हों।';

  @override
  String get linkLanConnectAction => 'कनेक्ट करें';

  @override
  String get linkImportSensitiveHeader =>
      'इस कॉन्फ़िगरेशन में संवेदनशील बदलाव:';

  @override
  String get linkImportFlagAutoAnswer => 'आने वाली कॉल अपने-आप उठाता है';

  @override
  String linkImportFlagForwarding(String target) {
    return 'कॉल को $target पर फ़ॉरवर्ड करता है';
  }

  @override
  String get linkImportFlagIntercom =>
      'बदलता है कि कौन इंटरकॉम शुरू कर सकता है या कॉल खींच सकता है (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'आपके डायल किए नंबर बदल देता है';

  @override
  String get linkImportFlagLinksImmediately =>
      'वेब लिंक से की गई कॉल बिना पुष्टि के तुरंत शुरू हो जाती हैं';

  @override
  String get linkImportFlagDiagnostics =>
      'विस्तृत लॉगिंग या SIP ट्रेस चालू करता है';

  @override
  String get linkImportAllowAutoAnswer =>
      'इम्पोर्ट किए गए खातों के लिए ऑटो-आंसर की अनुमति दें';

  @override
  String linkImportRefused(String setting) {
    return 'यह आयात \"$setting\" बदलने का प्रयास करता है, जिसे लिंक, QR कोड, चिपकाए गए टेक्स्ट या फ़ाइल से कभी सेट नहीं किया जा सकता। इसके बजाय इस कंप्यूटर पर --provision कमांड-लाइन विकल्प का उपयोग करें। कुछ भी आयात नहीं किया गया।';
  }

  @override
  String get lanPairIntercomNote =>
      'पेयर किए गए डिवाइस इंटरकॉम कॉल का अनुरोध कर सकते हैं; हर बार आपसे पूछा जाएगा (सेटिंग > LAN में बदलें)।';

  @override
  String get callLinkUnsupportedScheme => 'इस प्रकार का लिंक समर्थित नहीं है।';

  @override
  String get linkImportFlagAutoRecord => 'कॉल अपने-आप रिकॉर्ड करता है';

  @override
  String get linkImportFlagBlocklist => 'आपकी कॉल ब्लॉकलिस्ट बदलता है';

  @override
  String get linkImportFlagEmergency => 'आपके आपातकालीन नंबर बदलता है';

  @override
  String get linkImportFlagSpeedDial => 'स्पीड-डायल नंबर सेट करता है';

  @override
  String get linkImportFlagRecordingDelete =>
      'पुरानी रिकॉर्डिंग अपने-आप हटाता है';

  @override
  String get linkImportFlagFeatureCodes => 'कस्टम PBX फ़ीचर कोड डायल करता है';

  @override
  String get linkImportAllowAutoRecord =>
      'स्वचालित कॉल रिकॉर्डिंग की अनुमति दें';

  @override
  String get importIgnoredHeader => 'अनदेखा किया गया (आयात में अनुमत नहीं):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - सर्वर $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'प्रॉक्सी: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN रिले: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'कस्टम SIP हेडर: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'कॉलर आईडी: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'मीडिया एन्क्रिप्शन नहीं (SRTP बंद)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'पता: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return '$updated मौजूदा अपडेट करें, $added नए जोड़ें';
  }

  @override
  String get secretsKeyringLocked =>
      'आपकी कीरिंग खोली नहीं जा सकी (लॉक है या जवाब नहीं दे रही), इसलिए सहेजे गए पासवर्ड पढ़े नहीं जा सके। इसे अनलॉक करें और SoftphonePro को पुनः आरंभ करें।';

  @override
  String get mixerTitle => 'ऑडियो मिक्सर';

  @override
  String get mixerMicrophone => 'माइक्रोफ़ोन';

  @override
  String get mixerSpeaker => 'हेडफ़ोन और स्पीकर';

  @override
  String get mixerMicVolume => 'माइक्रोफ़ोन वॉल्यूम';

  @override
  String get mixerSpeakerVolume => 'स्पीकर वॉल्यूम';

  @override
  String mixerMeterLabel(String name) {
    return '$name स्तर';
  }

  @override
  String get mixerInputDevice => 'इनपुट डिवाइस';

  @override
  String get mixerOutputDevice => 'आउटपुट डिवाइस';

  @override
  String get mixerOutputRoute => 'ऑडियो आउटपुट';

  @override
  String get mixerInputFollowsOutput =>
      'माइक्रोफ़ोन चुने गए ऑडियो आउटपुट के अनुसार बदलता है।';

  @override
  String get mixerShowMore => 'डिवाइस और बैकग्राउंड म्यूज़िक दिखाएँ';

  @override
  String get mixerShowLess => 'कम नियंत्रण दिखाएँ';

  @override
  String get mixerStripShow => 'ऑडियो मिक्सर दिखाएँ';

  @override
  String get mixerStripHide => 'ऑडियो मिक्सर छिपाएँ';

  @override
  String get musicbedTitle => 'बैकग्राउंड म्यूज़िक';

  @override
  String get musicbedPlay => 'बैकग्राउंड म्यूज़िक चलाएँ';

  @override
  String get musicbedVolume => 'बैकग्राउंड म्यूज़िक वॉल्यूम';

  @override
  String get musicbedChooseFile => 'फ़ाइल चुनें';

  @override
  String musicbedChangeFile(String name) {
    return 'बैकग्राउंड म्यूज़िक फ़ाइल: $name। बदलने के लिए टैप करें।';
  }

  @override
  String get musicbedHearIt => 'मैं भी सुनूँ';

  @override
  String get musicbedMonitorVolume => 'मॉनिटर वॉल्यूम';

  @override
  String get musicbedAddFile => 'फ़ाइल जोड़ें…';

  @override
  String get musicbedPickerTitle => 'बैकग्राउंड म्यूज़िक फ़ाइल';

  @override
  String get musicbedOn => 'बैकग्राउंड म्यूज़िक चालू';

  @override
  String get musicbedPausedOnHold => 'बैकग्राउंड म्यूज़िक रुका है (होल्ड पर)';

  @override
  String get musicbedOnTooltip =>
      'आपकी कॉल के सभी लोगों को एक म्यूज़िक फ़ाइल सुनाई जा रही है।';

  @override
  String get musicbedFileMissing =>
      'बैकग्राउंड म्यूज़िक फ़ाइल अब उपलब्ध नहीं है, इसलिए इसे बंद कर दिया गया।';

  @override
  String get musicbedNeedsFile => 'पहले बैकग्राउंड म्यूज़िक फ़ाइल चुनें।';

  @override
  String musicbedStopped(String message) {
    return 'बैकग्राउंड म्यूज़िक रुक गया: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'आपकी आवाज़ के नीचे एक म्यूज़िक फ़ाइल लगातार चलती है और आपकी कॉल के सभी लोग उसे सुनते हैं, म्यूट होने पर भी। होल्ड वाली कॉल को इसके बजाय होल्ड म्यूज़िक सुनाई देता है।';

  @override
  String get musicbedSettingsFile => 'म्यूज़िक फ़ाइल';

  @override
  String get linkImportFlagMusicbed => 'आपकी कॉल में संगीत चलाता है';

  @override
  String get musicbedMonitorIosHint =>
      'iPhone पर आप इसे कॉल के दौरान सुनते हैं';

  @override
  String get musicbedStopFailed =>
      'संगीत बंद नहीं हो सका। हो सकता है कि कॉल पर सामने वालों को यह अब भी सुनाई दे रहा हो।';

  @override
  String get audioTestTitle => 'ऑडियो टेस्ट';

  @override
  String get audioTestEntry => 'माइक्रोफ़ोन और स्पीकर जाँचें';

  @override
  String get audioTestEntrySub =>
      'अपने डिवाइस जाँचें, खुद को सुनें और बैकग्राउंड संगीत संतुलित करें';

  @override
  String get audioTestInCall => 'ऑडियो टेस्ट चलाने के लिए अपना कॉल समाप्त करें';

  @override
  String get audioTestIosNote =>
      'iPhone पर माइक्रोफ़ोन और स्पीकर केवल कॉल के दौरान खुले रहते हैं';

  @override
  String get audioTestStepDevices => 'डिवाइस';

  @override
  String get audioTestStepMic => 'माइक्रोफ़ोन';

  @override
  String get audioTestStepSpeaker => 'स्पीकर या ईयरफ़ोन';

  @override
  String get audioTestStepRecord => 'रिकॉर्ड करें और सुनें';

  @override
  String get audioTestStepEcho => 'खुद को सुनें';

  @override
  String get audioTestStepMusic => 'बैकग्राउंड संगीत';

  @override
  String get audioTestStepSummary => 'सारांश';

  @override
  String audioTestOpened(String name) {
    return 'उपयोग में: $name';
  }

  @override
  String get audioTestNoDevice => 'कोई ऑडियो डिवाइस नहीं खुल सका';

  @override
  String get audioTestMicOk => 'हमें आपकी आवाज़ आ रही है';

  @override
  String get audioTestMicWaiting => 'कुछ बोलिए…';

  @override
  String get audioTestMicQuiet =>
      'बहुत धीमा: पास आएँ या माइक्रोफ़ोन गेन बढ़ाएँ';

  @override
  String get audioTestMicClipping => 'बहुत तेज़: माइक्रोफ़ोन गेन घटाएँ';

  @override
  String get audioTestMicSilent =>
      'कुछ भी नहीं आ रहा है। जाँचें: सही माइक्रोफ़ोन चुना गया है, सिस्टम में वह म्यूट नहीं है, ऐप को माइक्रोफ़ोन इस्तेमाल करने की अनुमति है (गोपनीयता सेटिंग), और कोई दूसरा ऐप उसे इस्तेमाल नहीं कर रहा।';

  @override
  String get audioTestOpenSoundSettings => 'साउंड सेटिंग खोलें';

  @override
  String get audioTestOpenPrivacySettings =>
      'माइक्रोफ़ोन गोपनीयता सेटिंग खोलें';

  @override
  String get audioTestPlaySound => 'टेस्ट ध्वनि चलाएँ';

  @override
  String get audioTestDidYouHear => 'क्या आपने इसे सुना?';

  @override
  String get audioTestDidYouHearVoice => 'क्या आपने अपनी आवाज़ सुनी?';

  @override
  String get audioTestNoOutputLevel =>
      'ऐप ने ध्वनि भेजी लेकिन आउटपुट मीटर नहीं हिला';

  @override
  String get audioTestSpeakerHints =>
      'वॉल्यूम, चुना गया आउटपुट डिवाइस और सिस्टम आउटपुट (ब्लूटूथ, HDMI) जाँचें';

  @override
  String get audioTestRecord5s => '5 सेकंड रिकॉर्ड करें';

  @override
  String audioTestRecording(int seconds) {
    return 'रिकॉर्डिंग… $seconds से';
  }

  @override
  String get audioTestPlayingBack => 'चल रहा है…';

  @override
  String get audioTestPlayAgain => 'फिर से चलाएँ';

  @override
  String get audioTestRecEmpty => 'रिकॉर्डिंग खाली है';

  @override
  String get audioTestEchoHeadphones =>
      'हेडफ़ोन लगाएँ: लाउडस्पीकर से फ़ीडबैक की आवाज़ आएगी।';

  @override
  String audioTestEchoSecondsLeft(int seconds) {
    return '$seconds से में रुकेगा';
  }

  @override
  String audioTestEchoEnded(String reason) {
    return 'इको टेस्ट समाप्त ($reason)';
  }

  @override
  String get audioTestPreview => 'पूर्वावलोकन: कॉल करने वाले क्या सुनते हैं';

  @override
  String get audioTestPreviewSub =>
      'आपकी आवाज़ और बैकग्राउंड संगीत, जैसे भेजे जाते हैं वैसे मिले हुए';

  @override
  String get audioTestSendLevel => 'कॉल करने वालों को भेजा गया';

  @override
  String get audioTestEcNotPreviewed =>
      'इस पूर्वावलोकन में इको कैंसलेशन लागू नहीं होता';

  @override
  String get audioTestPass => 'ठीक';

  @override
  String get audioTestFail => 'समस्या';

  @override
  String get audioTestNotRun => 'जाँचा नहीं गया';

  @override
  String get audioTestSkipped => 'छोड़ा गया';

  @override
  String get audioTestRunning => 'जाँच हो रही है…';

  @override
  String get audioTestCopyDiagnostics => 'डायग्नोस्टिक्स कॉपी करें';

  @override
  String get audioTestCopied => 'डायग्नोस्टिक्स कॉपी हो गए';

  @override
  String audioDeviceErrorNotice(String message) {
    return 'ऑडियो डिवाइस की समस्या: $message';
  }

  @override
  String get mixerMicUnavailable =>
      'माइक्रोफ़ोन उपलब्ध नहीं: मौन डिवाइस इस्तेमाल हो रहा है';

  @override
  String get audioTestMusicSilentHint =>
      'संगीत कॉल करने वालों को भेजा जाता है; इसे सुनने के लिए \"खुद सुनें\" या पूर्वावलोकन चालू करें';

  @override
  String get audioTestEchoEndedTimeout => '60 सेकंड बाद रुक गया';

  @override
  String get audioTestEchoEndedCall => 'कॉल शुरू हुआ';

  @override
  String get audioTestEchoEndedShutdown => 'इंजन फिर से शुरू हुआ';
}
