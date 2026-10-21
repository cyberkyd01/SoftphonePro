// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystemDefault => 'افتراضي النظام';

  @override
  String get languagePickerHint => 'تُعرض أسماء اللغات بلغاتها الخاصة.';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionOk => 'حسنًا';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionDone => 'تم';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionRename => 'إعادة تسمية';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionImport => 'استيراد';

  @override
  String get actionExport => 'تصدير';

  @override
  String get actionDetails => 'التفاصيل';

  @override
  String get actionMore => 'المزيد';

  @override
  String get actionSettings => 'الإعدادات';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionYes => 'نعم';

  @override
  String get actionNo => 'لا';

  @override
  String get commonOn => 'مفعّل';

  @override
  String get commonOff => 'معطّل';

  @override
  String get commonNone => 'لا شيء';

  @override
  String get commonDefault => 'افتراضي';

  @override
  String get commonSystem => 'النظام';

  @override
  String get commonAutomatic => 'تلقائي';

  @override
  String get commonUnknown => 'غير معروف';

  @override
  String get commonNotSet => 'غير محدد';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get statusAvailable => 'متاح';

  @override
  String get statusDoNotDisturb => 'عدم الإزعاج';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get statusOnACall => 'في مكالمة';

  @override
  String get settingsEntryAccounts => 'الحسابات';

  @override
  String get settingsEntryAccountsSub => 'حسابات SIP والتسجيل';

  @override
  String get settingsEntryAudio => 'الصوت';

  @override
  String get settingsEntryAudioSub => 'الأجهزة والمستويات وإلغاء الصدى';

  @override
  String get settingsEntryCodecs => 'الترميزات';

  @override
  String get settingsEntryCodecsSub => 'الترتيب والتوفر وOpus';

  @override
  String get settingsEntryCalls => 'المكالمات';

  @override
  String get settingsEntryCallsSub =>
      'عدم الإزعاج والانتظار والرد التلقائي وقواعد الطلب';

  @override
  String get settingsEntryNetwork => 'الشبكة';

  @override
  String get settingsEntryNetworkSub => 'النقل وSTUN وTLS وDNS';

  @override
  String get settingsEntryRecording => 'التسجيل';

  @override
  String get settingsEntryNotifications => 'الإشعارات ونغمات الرنين';

  @override
  String get settingsEntryShortcuts => 'الاختصارات';

  @override
  String get settingsEntryShortcutsSub => 'مفاتيح عامة ومفاتيح داخل التطبيق';

  @override
  String get settingsEntryAppearance => 'المظهر';

  @override
  String get settingsEntryPrivacy => 'الخصوصية والأمان';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'التهيئة التلقائية';

  @override
  String get settingsEntryProvisioningSub => 'استيراد وتصدير ورمز QR';

  @override
  String get settingsEntryDiagnostics => 'التشخيص';

  @override
  String get settingsEntryDiagnosticsSub => 'تتبع SIP وفحوصات الشبكة';

  @override
  String get settingsEntryAdvanced => 'متقدم';

  @override
  String get settingsEntryAbout => 'حول';

  @override
  String get settingsAccountsEmptyTitle => 'أضف حسابك الأول';

  @override
  String get settingsAccountsEmptySubtitle =>
      'اتصل بمقسم PBX أو مزوّد SIP لبدء إجراء المكالمات.';

  @override
  String get settingsAccountsAdd => 'إضافة حساب';

  @override
  String get settingsAccountsYourAccounts => 'حساباتك';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  عبر الخادم الاحتياطي';
  }

  @override
  String get settingsAudioDevices => 'الأجهزة';

  @override
  String get settingsAudioMicrophone => 'الميكروفون';

  @override
  String get settingsAudioSpeaker => 'مكبّر الصوت';

  @override
  String get settingsAudioRinger => 'جهاز الرنين';

  @override
  String get settingsAudioRingerSub => 'تشغيل نغمة الرنين على جهاز منفصل';

  @override
  String get settingsAudioRefreshDevices => 'تحديث الأجهزة';

  @override
  String get settingsAudioLevelsAndTest => 'المستويات والاختبار';

  @override
  String get settingsAudioMicVolume => 'مستوى الميكروفون';

  @override
  String get settingsAudioMicLevel => 'مستوى الميكروفون';

  @override
  String get settingsAudioSpeakerVolume => 'مستوى مكبّر الصوت';

  @override
  String get settingsAudioSpeakerLevel => 'مستوى مكبّر الصوت';

  @override
  String get settingsAudioTestSpeaker => 'اختبار مكبّر الصوت';

  @override
  String get settingsAudioTestSpeakerSub =>
      'يشغّل نغمة قصيرة عبر مكبّر الصوت المحدد';

  @override
  String get settingsAudioTestToneFailed => 'تعذّر تشغيل نغمة الاختبار';

  @override
  String get settingsAudioEchoTestFailed => 'فشل اختبار الصدى';

  @override
  String get settingsAudioEchoTest => 'اختبار الصدى';

  @override
  String get settingsAudioEchoTestSub =>
      'يعيد تشغيل صوت الميكروفون عبر مكبّر الصوت. استخدم سماعات الرأس لتجنب الصفير.';

  @override
  String get settingsAudioVoiceAndFiles => 'الصوت والملفات';

  @override
  String get settingsAudioVoiceIsolation =>
      'عزل الصوت (إلغاء الضوضاء بالذكاء الاصطناعي)';

  @override
  String get settingsAudioAudioFiles => 'الملفات الصوتية';

  @override
  String get settingsAudioAudioFilesSub => 'موسيقى الانتظار والإعلانات';

  @override
  String get settingsAudioProcessing => 'المعالجة';

  @override
  String get settingsAudioEchoCancellation => 'إلغاء الصدى';

  @override
  String get settingsAudioEcSimple => 'بسيط';

  @override
  String get settingsAudioEcPlatform => 'النظام';

  @override
  String get settingsAudioEchoTail => 'ذيل الصدى';

  @override
  String get settingsAudioNoiseSuppression => 'كتم الضوضاء';

  @override
  String get settingsAudioAgc => 'التحكم التلقائي في الكسب';

  @override
  String get settingsAudioVad => 'اكتشاف النشاط الصوتي';

  @override
  String get settingsAudioVadSub => 'يوفّر عرض النطاق أثناء الصمت';

  @override
  String get settingsAudioAdvanced => 'متقدم';

  @override
  String get settingsAudioAdvancedFooter =>
      'قيم مخزن الارتجاف بالميلي ثانية؛ القيمة -1 تستخدم الافتراضي للمحرك. يؤدي تغييرها إلى إعادة تشغيل محرك المكالمات.';

  @override
  String get settingsAudioPtime => 'زمن الحزمة (ptime)';

  @override
  String get settingsAudioJbInitial => 'مخزن الارتجاف: الأولي';

  @override
  String get settingsAudioJbMinPrefetch => 'مخزن الارتجاف: أدنى جلب مسبق';

  @override
  String get settingsAudioJbMaxPrefetch => 'مخزن الارتجاف: أقصى جلب مسبق';

  @override
  String get settingsAudioJbMaxSize => 'مخزن الارتجاف: الحجم الأقصى';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'الميكروفون $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'الآخرون $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent بالمئة';
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
      other: '$count ثانية',
      many: '$count ثانية',
      few: '$count ثوانٍ',
      two: 'ثانيتان',
      one: 'ثانية واحدة',
      zero: '0 ثانية',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'الترتيب والتوفر';

  @override
  String get settingsCodecsDragHint =>
      'اسحب لإعادة الترتيب. يمكن للحسابات تجاوز هذه القائمة في إعداداتها الخاصة.';

  @override
  String get settingsCodecsBitrate => 'معدل البت';

  @override
  String get settingsCodecsFec => 'FEC داخل النطاق';

  @override
  String get settingsCodecsFecSub => 'يعوّض فقدان الحزم';

  @override
  String get settingsCodecsDtxSub => 'إيقاف الإرسال أثناء الصمت';

  @override
  String get settingsCodecsCbr => 'معدل بت ثابت';

  @override
  String get settingsCodecsComplexity => 'التعقيد';

  @override
  String get settingsCallsIncoming => 'الواردة';

  @override
  String get settingsCallsDndSub => 'رفض جميع المكالمات الواردة';

  @override
  String get settingsCallsRejectWith => 'الرفض بالرد';

  @override
  String get settingsCallsReasonBusy => 'مشغول هنا (486)';

  @override
  String get settingsCallsReasonUnavailable => 'غير متاح مؤقتًا (480)';

  @override
  String get settingsCallsReasonDecline => 'رفض (603)';

  @override
  String get settingsCallsWaiting => 'انتظار المكالمات';

  @override
  String get settingsCallsWaitingSub =>
      'السماح بمكالمة واردة ثانية أثناء المكالمة';

  @override
  String get settingsCallsWhenBusy => 'عند الانشغال مع إيقاف الانتظار';

  @override
  String get settingsCallsRejectAnonymous => 'رفض المكالمات المجهولة';

  @override
  String get settingsCallsLinksImmediately => 'الاتصال الفوري عبر الروابط';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'روابط tel: وsip: وcallto: تُجري المكالمة دون التوقف في لوحة الطلب';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'مزامنة عدم الإزعاج وإعادة التوجيه مع PBX عبر رموز الخدمات';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'يطلب رموز النجمة الخاصة بالحساب (مثل *78) لحظيًا عند تغيير عدم الإزعاج أو إعادة التوجيه';

  @override
  String get settingsCallsAutoAnswerGroup => 'الرد التلقائي';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'إعادة توجيه المكالمات والرد التلقائي لكل حساب يُضبطان في إعدادات كل حساب.';

  @override
  String get settingsCallsAutoAnswerAll => 'الرد التلقائي على كل المكالمات';

  @override
  String get settingsCallsAnswerAfter => 'الرد بعد';

  @override
  String get settingsCallsAnswerImmediately => 'فورًا';

  @override
  String get settingsCallsIntercomHeaders => 'احترام ترويسات الإنتركم';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'تلميحات الرد التلقائي في Call-Info وAlert-Info وAnswer-Mode';

  @override
  String get settingsCallsBlocked => 'الأرقام المحظورة';

  @override
  String get settingsCallsBlockNumber => 'حظر رقم';

  @override
  String get settingsCallsBlockNumberTitle => 'حظر الرقم';

  @override
  String get settingsCallsBlockNumberHint => 'رقم أو عنوان SIP';

  @override
  String get settingsCallsSpeedDial => 'الطلب السريع';

  @override
  String get settingsCallsDialPlan => 'خطة الطلب';

  @override
  String get settingsCallsDialRules => 'قواعد الطلب';

  @override
  String get settingsCallsStripPrefix => 'بادئة الخط الخارجي المراد حذفها';

  @override
  String get settingsCallsStripPrefixSub =>
      'مثل 9، تُحذف من بداية الأرقام المطلوبة';

  @override
  String get settingsCallsPlusReplacement => 'استبدال + في البداية بـ';

  @override
  String get settingsCallsPlusReplacementSub => 'مثل 00 للاتصال الدولي';

  @override
  String get settingsCallsPlusReplacementHint => 'إبقاء +';

  @override
  String get settingsCallsCountryPrefix => 'رمز الدولة الافتراضي';

  @override
  String get settingsCallsCountryPrefixSub =>
      'تُضاف هذه البادئة إلى الأرقام المحلية التي تبدأ بـ 0، مثل 44+';

  @override
  String get settingsCallsEmergency => 'أرقام الطوارئ';

  @override
  String get settingsCallsEmergencySub =>
      'مفصولة بفواصل. لا تخضع لقواعد الطلب.';

  @override
  String settingsCallsUnblock(String number) {
    return 'إلغاء حظر $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count من 9 معيّنة';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قاعدة',
      many: '$count قاعدة',
      few: '$count قواعد',
      two: 'قاعدتان',
      one: 'قاعدة واحدة',
      zero: 'لا قواعد',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'قاعدة طلب جديدة';

  @override
  String get settingsDialRulesEdit => 'تعديل قاعدة الطلب';

  @override
  String get settingsDialRulesName => 'الاسم';

  @override
  String get settingsDialRulesPattern => 'النمط (regex)';

  @override
  String get settingsDialRulesReplacement => 'الاستبدال';

  @override
  String get settingsDialRulesReplacementHelp => 'استخدم \$1 و\$2 للمجموعات';

  @override
  String get settingsDialRulesRoute => 'التوجيه عبر الحساب';

  @override
  String get settingsDialRulesAdd => 'إضافة قاعدة';

  @override
  String get settingsDialRulesLiveTest => 'اختبار مباشر';

  @override
  String get settingsDialRulesTyped => 'الرقم المدخل';

  @override
  String get settingsDialRulesNothing => '(لا شيء)';

  @override
  String get settingsDialRulesEmergency => 'رقم طوارئ: يُطلب كما أُدخل';

  @override
  String get settingsDialRulesAccountFallback => 'حساب';

  @override
  String get settingsDialRulesEmpty =>
      'لا توجد قواعد. تُنظَّف الأرقام (تُحذف المسافات والشرطات والأقواس) وتُطلب كما أُدخلت. تُنفَّذ القواعد من الأعلى إلى الأسفل، وتفوز أول قاعدة مطابقة.';

  @override
  String get settingsDialRulesDelete => 'حذف القاعدة';

  @override
  String get settingsDialRulesDeleteTitle => 'حذف القاعدة؟';

  @override
  String settingsDialRulesVia(String account) {
    return 'عبر $account';
  }

  @override
  String get settingsNetworkTransports => 'النقل';

  @override
  String get settingsNetworkTransportsFooter =>
      'المنفذ 0 يختار منفذًا حرًا عشوائيًا. يؤدي تغيير وسائل النقل إلى إعادة تشغيل محرك المكالمات.';

  @override
  String get settingsNetworkUdpPort => 'منفذ UDP';

  @override
  String get settingsNetworkTcpPort => 'منفذ TCP';

  @override
  String get settingsNetworkTlsPort => 'منفذ TLS';

  @override
  String get settingsNetworkVerifyCerts => 'التحقق من شهادات الخادم';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'عطّله فقط لمقسمات PBX ذات الشهادات الموقّعة ذاتيًا، أو ثبّت الشهادة أدناه';

  @override
  String get settingsNetworkCustomCa => 'ملف CA مخصص';

  @override
  String get settingsNetworkCustomCaSub =>
      'حزمة PEM تُستخدم بدل القائمة المدمجة (CA لمقسم PBX خاص)';

  @override
  String get settingsNetworkCustomCaHint => 'قائمة Mozilla المدمجة';

  @override
  String get settingsNetworkPins => 'الشهادات المثبّتة';

  @override
  String get settingsNetworkPinsSub => 'المضيف=بصمة SHA256، مفصولة بفواصل';

  @override
  String get settingsNetworkNat => 'اجتياز NAT';

  @override
  String get settingsNetworkStun => 'خوادم STUN';

  @override
  String get settingsNetworkStunSub => 'المضيف:المنفذ، مفصولة بفواصل';

  @override
  String get settingsNetworkIceTurn => 'ICE وTURN';

  @override
  String get settingsNetworkIceTurnSub => 'يُضبطان لكل حساب ضمن NAT';

  @override
  String get settingsNetworkAdvanced => 'متقدم';

  @override
  String get settingsNetworkQos => 'QoS (وسم DSCP)';

  @override
  String get settingsNetworkQosSub => 'وسم حزم SIP والصوت لمنحها الأولوية';

  @override
  String get settingsNetworkDns => 'خوادم DNS';

  @override
  String get settingsNetworkDnsSub => 'اتركه فارغًا للوضع التلقائي';

  @override
  String get settingsNetworkRtpStart => 'بداية منافذ RTP';

  @override
  String get settingsNetworkRtpRange => 'نطاق منافذ RTP';

  @override
  String get settingsNetworkRtpRangeSub => 'القيمة 0 تستخدم الافتراضي';

  @override
  String get settingsNotifRingtone => 'نغمة الرنين';

  @override
  String get settingsNotifDefaultRingtone => 'نغمة الرنين الافتراضية';

  @override
  String get settingsNotifProgressTones => 'نغمات سير المكالمة';

  @override
  String get settingsNotifProgressTonesSub =>
      'نغمات الرنين والانشغال والازدحام أثناء الطلب';

  @override
  String get settingsNotifRingerVolume => 'مستوى صوت الرنين';

  @override
  String get settingsNotifCustomRingtone => 'ملف نغمة رنين مخصص';

  @override
  String get settingsNotifCustomRingtoneSub => 'مسار ملف WAV (سطح المكتب)';

  @override
  String get settingsNotifGroup => 'الإشعارات';

  @override
  String get settingsNotifRequestPermissions => 'طلب الأذونات';

  @override
  String get settingsNotifRequestPermissionsSub => 'الميكروفون والإشعارات';

  @override
  String get settingsNotifTyping => 'إرسال مؤشرات الكتابة';

  @override
  String get settingsAppearanceTheme => 'السمة';

  @override
  String get settingsAppearanceLight => 'فاتح';

  @override
  String get settingsAppearanceDark => 'داكن';

  @override
  String get settingsAppearanceAccent => 'لون التمييز';

  @override
  String get settingsAppearanceAccentOption => 'خيار لون التمييز';

  @override
  String get settingsAppearanceCompact => 'كثافة مضغوطة';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'الميكروفون: $microphone، الإشعارات: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'الأمان';

  @override
  String get settingsPrivacyPasswords => 'كلمات المرور';

  @override
  String get settingsPrivacyPasswordsSub =>
      'تُخزَّن في سلسلة مفاتيح النظام / مخزن المفاتيح (مع ملف مشفّر بديل)';

  @override
  String get settingsPrivacyGroup => 'الخصوصية';

  @override
  String get settingsPrivacyNoTelemetry => 'بلا تتبّع';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'لا يرسل SoftphonePro أي بيانات تحليلية. تذهب حركة الشبكة إلى خوادم SIP الخاصة بك فقط.';

  @override
  String get settingsPrivacyYourData => 'بياناتك';

  @override
  String get settingsPrivacyClearHistory => 'مسح سجل المكالمات';

  @override
  String get settingsPrivacyDeleteContacts => 'حذف كل جهات الاتصال';

  @override
  String get settingsPrivacyDeleteMessages => 'حذف كل الرسائل';

  @override
  String get settingsPrivacyConfirmHistory => 'حذف سجل المكالمات؟';

  @override
  String get settingsPrivacyConfirmContacts => 'حذف كل جهات الاتصال؟';

  @override
  String get settingsPrivacyConfirmMessages => 'حذف كل الرسائل؟';

  @override
  String get settingsPrivacyCannotUndo => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsPrivacyDeletedHistory => 'تم حذف سجل المكالمات';

  @override
  String get settingsPrivacyDeletedContacts => 'تم حذف كل جهات الاتصال';

  @override
  String get settingsPrivacyDeletedMessages => 'تم حذف كل الرسائل';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'تكتشف الأجهزة على الشبكة نفسها بعضها بعضًا، وتقترن برمز من 6 أرقام، وتتحدث مباشرةً دون أي خادم.';

  @override
  String get settingsLanEnable => 'تفعيل LAN Link';

  @override
  String get settingsLanDeviceName => 'اسم الجهاز';

  @override
  String get settingsLanDeviceNameHint => 'هذا الجهاز';

  @override
  String get settingsLanAllowIntercom => 'السماح بالإنتركم';

  @override
  String get settingsLanAllowIntercomSub =>
      'السماح للأجهزة المقترنة بالاتصال بك مع الرد التلقائي';

  @override
  String get settingsLanAskIntercom => 'السؤال قبل السماح بالإنتركم';

  @override
  String get settingsLanAskIntercomSub =>
      'وإلا يُردّ تلقائيًا على الأجهزة المقترنة لمدة 30 ثانية بعد طلبها';

  @override
  String get settingsLanAutoAcceptFiles =>
      'قبول الملفات تلقائيًا من الأجهزة المقترنة';

  @override
  String get settingsLanAutoAcceptFilesSub => 'وإلا يُطلب إذنك لكل ملف';

  @override
  String get settingsLanAllowPull => 'السماح للأجهزة المقترنة بسحب مكالماتي';

  @override
  String get settingsLanAllowPullSub =>
      'يمكن لجهاز مقترن تولّي مكالمة جارية هنا';

  @override
  String get settingsLanDownloads => 'مجلد التنزيلات';

  @override
  String get settingsLanDownloadsHint => 'الافتراضي (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'منفذ الربط';

  @override
  String get settingsLanSharedAccounts =>
      'الحسابات المشتركة مع الأجهزة المقترنة';

  @override
  String get settingsLanSharedAccountsFooter =>
      'مشاركة حساب مسجّل تتيح لجهاز مقترن على الخادم نفسه استقبال مكالماتك مباشرةً (تحويل المكالمة) بدل تمريرها عبر هذا الجهاز.';

  @override
  String get settingsAdvEngine => 'المحرك';

  @override
  String get settingsAdvSimulator => 'استخدام المحاكي';

  @override
  String get settingsAdvSimulatorSub =>
      'التشغيل دون المحرك الأصلي. تكون المكالمات محاكاة.';

  @override
  String get settingsAdvLogLevel => 'مستوى السجل';

  @override
  String get settingsAdvLogErrors => 'الأخطاء';

  @override
  String get settingsAdvLogInfo => 'معلومات';

  @override
  String get settingsAdvLogDebug => 'تصحيح';

  @override
  String get settingsAdvLogVerbose => 'تفصيلي';

  @override
  String get settingsAdvSipTrace => 'تتبع SIP';

  @override
  String get settingsAdvRestartEngine => 'إعادة تشغيل المحرك';

  @override
  String get settingsAdvDesktop => 'سطح المكتب';

  @override
  String get settingsAdvStartAtLogin => 'التشغيل عند تسجيل الدخول';

  @override
  String get settingsAdvCloseToTray => 'الإغلاق إلى شريط النظام';

  @override
  String get settingsAdvCloseToTraySub =>
      'إغلاق النافذة يُبقي SoftphonePro قيد التشغيل لتستمر المكالمات في الرنين. للخروج استخدم أيقونة شريط النظام / شريط القوائم.';

  @override
  String get settingsAboutLicence => 'الترخيص';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro برنامج حر: يمكنك إعادة توزيعه و/أو تعديله وفق شروط رخصة جنو العامة (GNU General Public License) كما نشرتها مؤسسة البرمجيات الحرة، الإصدار 3 أو أحدث. يُوزَّع دون أي ضمان.';

  @override
  String get settingsAboutGpl => 'GNU GPL الإصدار 3 أو أحدث';

  @override
  String get settingsAboutGplSub => 'الشيفرة المصدرية متاحة في مستودع المشروع';

  @override
  String get settingsAboutThirdParty => 'إشعارات الأطراف الثالثة';

  @override
  String get settingsAboutPackages => 'حزم Flutter وDart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause وMIT وApache 2.0. راجع صفحة التراخيص.';

  @override
  String settingsAboutVersion(String version) {
    return 'الإصدار $version';
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
    return '$license. $purpose. الإصدار $version.';
  }

  @override
  String get updatesChecking => 'جارٍ التحقق...';

  @override
  String updatesAvailable(String version) {
    return 'الإصدار $version من SoftphonePro متاح';
  }

  @override
  String get updatesUpToDate => 'أنت على أحدث إصدار';

  @override
  String get updatesCouldNotCheck => 'تعذّر التحقق';

  @override
  String get updatesNotCheckedYet => 'لم يتم التحقق بعد';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'آخر تحقق: $dateString';
  }

  @override
  String get updatesTitle => 'التحديثات';

  @override
  String get updatesFooter =>
      'يتصل التحقق بـ api.github.com فقط (مرة في الأسبوع) ولا يرسل سوى الطلب نفسه: لا معرّف ولا بيانات حساب أو مكالمات. لا يقوم SoftphonePro بتنزيل أو تثبيت أي شيء من تلقاء نفسه.';

  @override
  String get updatesCheckSwitch => 'التحقق من التحديثات';

  @override
  String get updatesCheckNow => 'تحقق الآن';

  @override
  String updatesSkippingVersion(String version) {
    return 'تخطّي الإصدار $version';
  }

  @override
  String get updatesStopSkipping => 'إيقاف التخطّي';

  @override
  String get updatesReleaseNotes => 'ملاحظات الإصدار';

  @override
  String get updatesDownload => 'تنزيل';

  @override
  String get updatesSkipVersion => 'تخطّي هذا الإصدار';

  @override
  String get updatesDismiss => 'تجاهل';

  @override
  String get updatesRateLimited => 'تم بلوغ حد الطلبات في GitHub، حاول لاحقًا';

  @override
  String updatesServerAnswered(int status) {
    return 'ردّ GitHub بالحالة $status';
  }

  @override
  String get updatesUnexpectedReply => 'ردّ غير متوقع';

  @override
  String get updatesTimedOut => 'انتهت المهلة';

  @override
  String get updatesAlreadyChecking => 'التحقق جارٍ بالفعل';

  @override
  String get encryptionTitle => 'التشفير';

  @override
  String get encryptionFooter =>
      'يشفّر قاعدة البيانات المحلية باستخدام AES-256-GCM. يُحفظ المفتاح في سلسلة مفاتيح النظام / مخزن المفاتيح؛ وإذا فُقد فلا يمكن استرداد البيانات. تسجيلات المكالمات والملفات المصدّرة غير مشفّرة. يسري التغيير عند التشغيل التالي لـ SoftphonePro (أغلقه تمامًا أولًا)؛ ويُستبدل الملف السابق ويُحذف فور فتح قاعدة البيانات الجديدة والتحقق منها.';

  @override
  String get encryptionSwitchTitle =>
      'تشفير سجل المكالمات وجهات الاتصال والرسائل على هذا الجهاز';

  @override
  String get encryptionWillEncrypt => 'سيتم التشفير عند التشغيل التالي';

  @override
  String get encryptionWillDecrypt => 'سيتم فك التشفير عند التشغيل التالي';

  @override
  String get encryptionRestartToEncrypt =>
      'أغلق SoftphonePro ثم أعد تشغيله لتشفير بياناتك.';

  @override
  String get encryptionRestartToDecrypt =>
      'أغلق SoftphonePro ثم أعد تشغيله لفك تشفير بياناتك.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'الطلب السريع $slot';
  }

  @override
  String get speedDialNumberLabel => 'رقم أو عنوان SIP';

  @override
  String get speedDialLabelOptional => 'التسمية (اختياري)';

  @override
  String get speedDialCallFrom => 'الاتصال من';

  @override
  String get speedDialSelectedAccount => 'الحساب المحدد';

  @override
  String get speedDialTitle => 'الطلب السريع';

  @override
  String get speedDialHint =>
      'اضغط مطولًا على رقم (1-9) في لوحة المفاتيح الفارغة للاتصال برقمه.';

  @override
  String get speedDialNotAssigned => 'غير معيّن';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON غير صالح: $detail';
  }

  @override
  String get provisioningExpectedObject => 'كان المتوقع كائن JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'إصدار الإعدادات $version غير مدعوم';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'تم تخطّي إدخال حساب ليس كائنًا';

  @override
  String get provisioningNothingToImport =>
      'لا يحتوي الملف على حسابات أو إعدادات';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'الحساب \"$name\" يحتاج إلى اسم مستخدم ونطاق';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'ردّ الخادم بالحالة $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'تعذّر تنزيل الإعدادات: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'تعذّرت قراءة $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count حساب',
      many: 'تم استيراد $count حسابًا',
      few: 'تم استيراد $count حسابات',
      two: 'تم استيراد حسابين',
      one: 'تم استيراد حساب واحد',
      zero: 'لم يُستورد أي حساب',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'استيراد الإعدادات';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts حساب',
      many: '$accounts حسابًا',
      few: '$accounts حسابات',
      two: 'حسابان',
      one: 'حساب واحد',
      zero: 'لا حسابات',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings إعداد',
      many: '$settings إعدادًا',
      few: '$settings إعدادات',
      two: 'إعدادان',
      one: 'إعداد واحد',
      zero: 'لا إعدادات',
    );
    return '$_temp0، $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'استيراد من رابط أو JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... أو الصق JSON';

  @override
  String get provisioningInvalidSource => 'هذا ليس رابطًا أو JSON صالحًا';

  @override
  String get provisioningScanTitle => 'مسح رمز QR للتهيئة';

  @override
  String get provisioningPasteHint => 'الصق JSON أو رابطًا أو عنوان URL';

  @override
  String get provisioningImportGroup => 'استيراد';

  @override
  String get provisioningImportFooter =>
      'يدعم JSON الذي يحتوي على حسابات وإعدادات. تُملأ العناصر النائبة \${VAR} بقيم فارغة ما لم تُحدَّد قيمة افتراضية بالصيغة \${VAR:-default}.';

  @override
  String get provisioningScanQr => 'مسح رمز QR';

  @override
  String get provisioningFromUrl => 'من رابط أو JSON ملصوق';

  @override
  String get provisioningFromFile => 'من ملف';

  @override
  String get provisioningFromClipboard => 'من الحافظة';

  @override
  String get provisioningExportGroup => 'تصدير';

  @override
  String get provisioningIncludePasswords => 'تضمين كلمات المرور';

  @override
  String get provisioningIncludePasswordsHint =>
      'يمكن لأي شخص يملك الملف استخدام حساباتك';

  @override
  String get provisioningCopyConfig => 'نسخ الإعدادات (JSON)';

  @override
  String get provisioningConfigCopied => 'تم نسخ الإعدادات';

  @override
  String get provisioningQrGroup => 'رمز QR';

  @override
  String get provisioningQrFooter =>
      'امسح هذا الرمز على جهاز آخر لنسخ حساب. تعامل معه كما تتعامل مع كلمة المرور إن كان يتضمنها.';

  @override
  String get provisioningQrAccount => 'الحساب';

  @override
  String get provisioningChoose => 'اختيار...';

  @override
  String get provisioningQrTooMuchData => 'البيانات أكبر من أن يستوعبها رمز QR';

  @override
  String tlsClearField(String field) {
    return 'مسح $field';
  }

  @override
  String get tlsChoose => 'اختيار...';

  @override
  String get tlsChange => 'تغيير...';

  @override
  String get tlsClientCertTitle => 'شهادة العميل (TLS المتبادل)';

  @override
  String get tlsIncomplete =>
      'اختر الشهادة ومفتاحها الخاص معًا. لا تُقدَّم الشهادة إلا بعد تحديد الاثنين.';

  @override
  String get tlsFooter =>
      'للخوادم التي تطلب من التطبيق تعريف نفسه بشهادة. ملفات PEM. تُستخدم مع TLS وWebSocket الآمن.';

  @override
  String get tlsCertFile => 'ملف الشهادة';

  @override
  String get tlsKeyFile => 'ملف المفتاح الخاص';

  @override
  String get tlsKeyPassword => 'كلمة مرور المفتاح';

  @override
  String get tlsKeyPasswordHint => 'فقط إذا كان المفتاح مشفّرًا';

  @override
  String get callSettingsHoldGroupTitle => 'الانتظار';

  @override
  String get callSettingsHoldFooter =>
      'مع \"افتراضي PBX\" توضع المكالمة قيد الانتظار فقط وقد يشغّل نظام الهاتف موسيقاه الخاصة. أي خيار آخر يشغّله هذا التطبيق للمتصل.';

  @override
  String get callSettingsHoldMusic => 'موسيقى الانتظار';

  @override
  String get callSettingsHoldPbxDefault => 'افتراضي PBX';

  @override
  String get callSettingsHoldMusicVolume => 'مستوى صوت موسيقى الانتظار';

  @override
  String get callSettingsHoldAudioFiles => 'الملفات الصوتية';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'استيراد موسيقى الانتظار أو تسجيلها';

  @override
  String get callSettingsAnnounceTitle => 'الإعلانات';

  @override
  String get callSettingsAnnounceFooter =>
      'تُشغَّل الإعلانات للطرف الآخر. يُتخطى كل شيء بصمت إذا كان الملف مفقودًا.';

  @override
  String get callSettingsAnnounceOpening => 'إعلان الافتتاح';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'تشغيل رسالة عند اتصال المكالمة';

  @override
  String get callSettingsAnnounceFile => 'ملف الإعلان';

  @override
  String get callSettingsAnnounceChooseFile => 'اختر ملفًا';

  @override
  String get callSettingsAnnouncePlayFor => 'التشغيل لـ';

  @override
  String get callSettingsAnnounceBoth => 'الواردة والصادرة';

  @override
  String get callSettingsAnnounceIncoming => 'المكالمات الواردة';

  @override
  String get callSettingsAnnounceOutgoing => 'المكالمات الصادرة';

  @override
  String get callSettingsAnnounceMuteMic => 'كتم الميكروفون أثناء التشغيل';

  @override
  String get callSettingsAnnounceMonitor => 'اجعلني أسمعه أيضًا';

  @override
  String get callSettingsAnnounceBeforeRecording => 'قبل بدء التسجيل، شغّل';

  @override
  String get callSettingsAnnounceBeforeTransfer => 'قبل تحويل المتصل، شغّل';

  @override
  String get morePageTitle => 'المزيد';

  @override
  String get morePresence => 'الحضور';

  @override
  String get morePresenceHint => 'حقل مصباح الانشغال';

  @override
  String get moreRetrieveParked => 'استرجاع مكالمة مركونة';

  @override
  String get moreRetrieveParkedHint => 'اطلب خانة ركن';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'الأجهزة القريبة والدردشة وإسقاط الملفات';

  @override
  String get moreRecordings => 'التسجيلات';

  @override
  String get moreRecordingsHint => 'استمع إلى تسجيلات المكالمات وشاركها وأدرها';

  @override
  String get moreVoicemail => 'البريد الصوتي';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة جديدة',
      many: '$count رسالة جديدة',
      few: '$count رسائل جديدة',
      two: 'رسالتان جديدتان',
      one: 'رسالة جديدة واحدة',
      zero: 'لا رسائل جديدة',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'اتصل ببريدك الصوتي';

  @override
  String get moreDiagnostics => 'التشخيص';

  @override
  String get moreDiagnosticsHint => 'تتبع SIP وفحوصات الشبكة';

  @override
  String get moreAbout => 'حول';

  @override
  String get moreNoVoicemailNumber =>
      'لم يُحدَّد رقم للبريد الصوتي. أضف واحدًا في إعدادات الحساب.';

  @override
  String get moreSearchHint => 'ابحث في جهات الاتصال أو السجل أو اكتب رقمًا';

  @override
  String moreCallNumber(String number) {
    return 'اتصال بـ $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day، $time';
  }

  @override
  String get appLockTitle => 'قفل التطبيق';

  @override
  String get appLockFooter =>
      'تستمر المكالمات في الرنين ويمكن الرد عليها أثناء قفل التطبيق.';

  @override
  String get appLockRequirePin => 'طلب رمز PIN لفتح التطبيق';

  @override
  String get appLockOnHint => 'السجل وجهات الاتصال والرسائل والإعدادات مقفلة';

  @override
  String get appLockIsOn => 'قفل التطبيق مفعّل';

  @override
  String get appLockIsOff => 'قفل التطبيق معطّل';

  @override
  String get appLockTurnOff => 'إيقاف قفل التطبيق';

  @override
  String get appLockChangePin => 'تغيير رمز PIN';

  @override
  String get appLockEnterCurrent => 'أدخل رمز PIN الحالي';

  @override
  String get appLockPinChanged => 'تم تغيير رمز PIN';

  @override
  String get appLockLockAfter => 'القفل بعد';

  @override
  String get appLockLockAfterHint => 'المدة في الخلفية قبل طلب رمز PIN مجددًا';

  @override
  String get appLockImmediately => 'فورًا';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: '0 دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => 'ساعة واحدة';

  @override
  String get appLockBiometrics => 'الفتح بالقياسات الحيوية';

  @override
  String get appLockNow => 'القفل الآن';

  @override
  String get appLockSetPin => 'تعيين رمز PIN';

  @override
  String get appLockPinDigits => 'رمز PIN (من 4 إلى 8 أرقام)';

  @override
  String get appLockRepeatPin => 'أعد إدخال رمز PIN';

  @override
  String get appLockUseDigits => 'استخدم من 4 إلى 8 أرقام';

  @override
  String get appLockMismatch => 'رمزا PIN غير متطابقين';

  @override
  String get appLockPin => 'رمز PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'محاولات كثيرة جدًا. حاول مجددًا بعد $seconds ث';
  }

  @override
  String get appLockWrongPin => 'رمز PIN خاطئ';

  @override
  String get appLockTooMany => 'محاولات كثيرة جدًا';

  @override
  String get appLockIsLocked => 'SoftphonePro مقفل';

  @override
  String get appLockEnterPin => 'أدخل رمز PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'حاول مجددًا بعد $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes د $seconds ث';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds ث';
  }

  @override
  String get appLockUnlock => 'فتح القفل';

  @override
  String get appLockIncomingCall => 'مكالمة واردة';

  @override
  String get appLockDecline => 'رفض';

  @override
  String get appLockAnswer => 'رد';

  @override
  String get appLockHangUp => 'إنهاء المكالمة';

  @override
  String get appLockBiometricReason => 'فتح قفل SoftphonePro';

  @override
  String get automationNoToken =>
      'لم يُعيَّن رمز وصول. أنشئ واحدًا من الإعدادات > متقدم.';

  @override
  String automationInvalidPort(int port) {
    return 'المنفذ $port غير صالح';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'تعذّر البدء: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'المنفذ $port غير متاح ($error). اختر منفذًا آخر.';
  }

  @override
  String get automationTokenPlaceholder => 'يُنشأ عند تشغيل واجهة API';

  @override
  String automationListening(String address) {
    return 'يستمع على $address';
  }

  @override
  String get automationStarting => 'جارٍ البدء...';

  @override
  String get automationTitle => 'واجهة الأتمتة المحلية API';

  @override
  String get automationFooter =>
      'لتكاملات CRM ومكاتب المساعدة على هذا الحاسوب. تستمع على 127.0.0.1 فقط ويحتاج كل طلب إلى رمز الوصول. راجع docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'تفعيل واجهة الأتمتة المحلية API';

  @override
  String get automationPort => 'المنفذ';

  @override
  String get automationPortHint =>
      'الافتراضي 7771. اختر منفذًا حرًا بين 1024 و65535.';

  @override
  String get automationPortInvalid => 'أدخل منفذًا من 1024 إلى 65535';

  @override
  String get automationAccessToken => 'رمز الوصول';

  @override
  String get automationHideToken => 'إخفاء الرمز';

  @override
  String get automationShowToken => 'إظهار الرمز';

  @override
  String get automationCopyToken => 'نسخ الرمز';

  @override
  String get automationTokenCopied => 'تم نسخ الرمز';

  @override
  String get automationGenerateToken => 'إنشاء رمز جديد';

  @override
  String get automationGenerateTitle => 'إنشاء رمز جديد؟';

  @override
  String get automationGenerateBody =>
      'تتوقف البرامج التي تستخدم الرمز القديم عن العمل إلى أن تزوّدها بالرمز الجديد.';

  @override
  String get automationGenerate => 'إنشاء';

  @override
  String get automationOrigins => 'أصول المتصفح المسموح بها';

  @override
  String get automationOriginsHint =>
      'مفصولة بفواصل، مثل https://crm.example.com. البرامج التي لا تعمل داخل متصفح (curl والنصوص البرمجية) لا تحتاج إلى هذا.';

  @override
  String automationNotOrigin(String origin) {
    return 'ليس أصل http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'رد';

  @override
  String get trayNotificationDecline => 'رفض';

  @override
  String get trayTooltipInCall => 'SoftphonePro - في مكالمة';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count جديد';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - لا حسابات (بعيد)',
      'dnd': 'SoftphonePro - لا حسابات (عدم الإزعاج)',
      'other': 'SoftphonePro - لا حسابات',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total متصل (بعيد)',
      'dnd': 'SoftphonePro - $online/$total متصل (عدم الإزعاج)',
      'other': 'SoftphonePro - $online/$total متصل',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'إخفاء SoftphonePro';

  @override
  String get trayShowApp => 'إظهار SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count جديد - افتح الأحدث';
  }

  @override
  String get trayStatus => 'الحالة';

  @override
  String get trayStatusAway => 'بعيد';

  @override
  String get trayAccounts => 'الحسابات';

  @override
  String get trayQuit => 'إنهاء SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'الرد على المكالمة';

  @override
  String get hotkeyHangUp => 'إنهاء المكالمة';

  @override
  String get hotkeyMute => 'كتم / إلغاء الكتم';

  @override
  String get hotkeyFocusDialer => 'التركيز على لوحة الطلب';

  @override
  String get shortcutsGlobalTitle => 'مفاتيح الاختصار العامة';

  @override
  String get shortcutsGlobalFooter =>
      'تعمل من أي تطبيق. قد يمنع برنامج آخر يستخدم التركيبة نفسها تسجيلها.';

  @override
  String get shortcutsChange => 'تغيير';

  @override
  String get shortcutsRestoreDefaults => 'استعادة الافتراضيات';

  @override
  String get shortcutsMediaTitle => 'سماعة الرأس ومفاتيح الوسائط';

  @override
  String get shortcutsMediaFooter =>
      'زر التشغيل/الإيقاف المؤقت في سماعة الرأس أو لوحة المفاتيح لا يُستحوَذ عليه إلا أثناء رنين مكالمة أو أثناء إجرائها، فتحتفظ به مشغلات الموسيقى في بقية الوقت.';

  @override
  String get shortcutsMediaSwitch =>
      'الرد وإنهاء المكالمة بزر التشغيل/الإيقاف المؤقت في سماعة الرأس/الوسائط';

  @override
  String get shortcutsMediaDuringCall => 'أثناء المكالمة يقوم الزر بـ';

  @override
  String get shortcutsMediaHangsUp => 'إنهاء المكالمة';

  @override
  String get shortcutsMediaMutes => 'الكتم / إلغاء الكتم';

  @override
  String get shortcutsInApp => 'داخل التطبيق';

  @override
  String get shortcutsFocusDialer => 'التركيز على لوحة الطلب';

  @override
  String get shortcutsHoldResume => 'انتظار / استئناف';

  @override
  String get shortcutsTransfer => 'تحويل';

  @override
  String get shortcutsEndCall => 'إنهاء المكالمة';

  @override
  String get shortcutsNeedX11 =>
      'تتطلب الاختصارات العامة جلسة X11. لا يسمح Wayland للتطبيقات بالتقاط المفاتيح على مستوى النظام.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'أضف Ctrl أو Alt أو Shift أو $key إلى حرف أو رقم';
  }

  @override
  String get shortcutsPressNew => 'اضغط تركيبة المفاتيح الجديدة';

  @override
  String get defaultHandlerChooseInSettings =>
      'اختر SoftphonePro لروابط SIP وTEL وCALLTO في التطبيقات الافتراضية';

  @override
  String get defaultHandlerNowOpens =>
      'يفتح SoftphonePro الآن روابط sip: وtel: وcallto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'تعذّر تغيير الافتراضي لـ $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'يفتح روابط sip: وtel: وcallto: من المتصفحات والتطبيقات الأخرى';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro يتعامل مع روابط sip: وtel: وcallto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'الحالي: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'جعل SoftphonePro التطبيق الافتراضي لروابط sip: وtel: وcallto:';

  @override
  String get reliabilityTitle => 'الموثوقية في الخلفية';

  @override
  String get reliabilityMicrophone => 'الميكروفون';

  @override
  String get reliabilityAllowed => 'مسموح';

  @override
  String get reliabilityMicNeeded => 'مطلوب للتحدث في المكالمات';

  @override
  String get reliabilityNotifications => 'الإشعارات';

  @override
  String get reliabilityNotifNeeded =>
      'مطلوب لعرض المكالمات الواردة وإبقاء الخدمة ظاهرة';

  @override
  String get reliabilityFullScreen => 'المكالمات الواردة بملء الشاشة';

  @override
  String get reliabilityFullScreenNeeded =>
      'اسمح بها لتظهر المكالمات فوق شاشة القفل';

  @override
  String get reliabilityBattery => 'استخدام البطارية دون قيود';

  @override
  String get reliabilityBatteryExempt => 'مستثنى من تحسين البطارية';

  @override
  String get reliabilityBatteryNeeded =>
      'قد يعلّق Android التطبيق ويفوّت المكالمات لتوفير الطاقة. اضغط لاستثناء SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'التشغيل التلقائي / التطبيقات المحمية في $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'قد تُنهي الشركة المصنّعة لهاتفك التطبيقات في الخلفية. اسمح لـ SoftphonePro بالتشغيل التلقائي.';

  @override
  String get reliabilityBoot => 'التشغيل عند إقلاع الجهاز';

  @override
  String get reliabilityBootHint => 'تسجيل الحسابات بعد إعادة تشغيل الهاتف';

  @override
  String get reliabilityWake => 'إبقاء المعالج مستيقظًا أثناء الخمول';

  @override
  String get reliabilityWakeHint =>
      'أكثر موثوقية على الأجهزة المتشددة؛ يستهلك بطارية أكثر';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'إزالة $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'آخر خطأ: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'النطاق المسموح من $min إلى $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'يجب ألا تقل القيمة عن $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'يجب ألا تزيد القيمة عن $max';
  }

  @override
  String get acctEditorDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get acctEditorDiscardMessage => 'تعديلاتك على هذا الحساب غير محفوظة.';

  @override
  String get acctEditorDiscardConfirm => 'تجاهل';

  @override
  String get acctEditorDeleteMessage =>
      'سيُزال الحساب وكلمة مروره المحفوظة من هذا الجهاز.';

  @override
  String get acctEditorMenuDelete => 'حذف الحساب';

  @override
  String get acctGroupBasic => 'أساسي';

  @override
  String get acctFieldLabel => 'التسمية';

  @override
  String get acctFieldLabelHint => 'مثل: المكتب';

  @override
  String get acctFieldDisplayName => 'الاسم المعروض';

  @override
  String get acctFieldUsername => 'اسم المستخدم';

  @override
  String get acctFieldProtocol => 'البروتوكول';

  @override
  String get acctFieldProtocolSub => 'يُحدَّد عند إنشاء الحساب ولا يتغير';

  @override
  String get acctFieldAuthUser => 'مستخدم التفويض';

  @override
  String get acctFieldAuthUserHint => 'مثل اسم المستخدم';

  @override
  String get acctFieldAuthUserSub =>
      'فقط إذا كان المزوّد يستخدم اسم دخول مختلفًا عن اسم المستخدم';

  @override
  String get acctFieldPassword => 'كلمة المرور';

  @override
  String get acctFieldServerHost => 'مضيف الخادم';

  @override
  String get acctFieldPort => 'المنفذ';

  @override
  String get acctFieldIaxPortSub => 'الافتراضي في IAX2 هو 4569';

  @override
  String get acctFieldIaxContext => 'السياق';

  @override
  String get acctFieldIaxContextSub =>
      'اختياري. يُرسل إلى PBX بصفته سياق الاتصال';

  @override
  String get acctFieldServerDomain => 'الخادم / النطاق';

  @override
  String get acctFieldServerDomainSub => 'مضيف أو مضيف:منفذ';

  @override
  String get acctFieldEnabled => 'مفعّل';

  @override
  String get acctFieldDefault => 'الحساب الافتراضي للمكالمات الصادرة';

  @override
  String get acctFieldColour => 'اللون';

  @override
  String get acctGroupRegistration => 'التسجيل';

  @override
  String get acctFieldRegister => 'تسجيل';

  @override
  String get acctFieldRegisterSubIax => 'عطّله للأطراف التي لا تحتاج إلى تسجيل';

  @override
  String get acctFieldRegExpiry => 'انتهاء التسجيل (ث)';

  @override
  String get acctFieldRegExpirySubIax =>
      'يفرض Asterisk عادةً 60 ث. النطاق من 10 إلى 86400';

  @override
  String get acctFieldRetryInterval => 'فاصل إعادة المحاولة (ث)';

  @override
  String get acctFieldFirstRetry => 'أول إعادة محاولة (ث)';

  @override
  String get acctGroupCodecs => 'الترميزات';

  @override
  String get acctGroupCodecsFooterIax =>
      'يدعم IAX2 الترميزين G.711 وGSM. اسحب لتحديد ترتيب الأفضلية.';

  @override
  String get acctCodecAdd => 'إضافة ترميز';

  @override
  String get acctGroupServerTransport => 'الخادم والنقل';

  @override
  String get acctFieldRegistrar => 'تجاوز خادم التسجيل';

  @override
  String get acctFieldBackupRegistrar => 'خادم تسجيل احتياطي';

  @override
  String get acctFieldBackupRegistrarSub =>
      'يُستخدم بعد 3 محاولات فاشلة؛ وتُعاد محاولة الخادم الأساسي كل 5 دقائق';

  @override
  String get acctFieldProxies => 'وكلاء الصادر';

  @override
  String get acctFieldTransport => 'النقل';

  @override
  String get acctFieldTransportAutoSub =>
      'يبحث في سجلات DNS SRV للخادم ويختار TLS أو TCP أو UDP';

  @override
  String get acctTransportAuto => 'تلقائي (DNS SRV)';

  @override
  String get acctFieldWsPath => 'مسار WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'مسار HTTP لترقية WebSocket، مثل /ws. يجب أن يبدأ بـ \"/\"';

  @override
  String get acctFieldRegExpirySubSip =>
      'من 300 إلى 3600 قيمة معتادة. النطاق من 10 إلى 86400';

  @override
  String get acctFieldKeepAlive => 'إبقاء الاتصال (ث)';

  @override
  String get acctFieldKeepAliveSub =>
      'فاصل إبقاء اتصال UDP. القيمة 0 تعطّله. النطاق من 0 إلى 3600';

  @override
  String get acctFieldLocalPort => 'منفذ SIP المحلي';

  @override
  String get acctFieldLocalPortSub =>
      'القيمة 0 تستخدم النقل المشترك. النطاق من 0 إلى 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'عطّله لخطوط الربط التي لا تتطلب تسجيلًا';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'يحافظ على مسار دائم عبر NAT. يتطلب دعمًا من الخادم';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'استخدام STUN';

  @override
  String get acctFieldTurn => 'مرحّل TURN';

  @override
  String get acctFieldTurnServer => 'خادم TURN';

  @override
  String get acctFieldTurnUsername => 'اسم مستخدم TURN';

  @override
  String get acctFieldTurnPassword => 'كلمة مرور TURN';

  @override
  String get acctFieldContactRewrite => 'إعادة كتابة ترويسة Contact';

  @override
  String get acctFieldViaRewrite => 'إعادة كتابة ترويسة Via';

  @override
  String get acctFieldRewriteSub =>
      'استخدم العنوان الذي يراه الخادم. أبقِه مفعّلًا خلف NAT';

  @override
  String get acctFieldSdpRewrite => 'إعادة كتابة عنوان SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'استبدال عنوان الوسائط في SDP بالعنوان العام';

  @override
  String get acctFieldIpv6Sip => 'إشارات IPv6';

  @override
  String get acctFieldIpv6Media => 'وسائط IPv6';

  @override
  String get acctGroupAdvancedMedia => 'وسائط متقدمة';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'تحتاج بوابات WebRTC إلى تعدد إرسال RTCP وتغذية RTCP الراجعة.';

  @override
  String get acctFieldRtcpMux => 'تعدد إرسال RTCP';

  @override
  String get acctFieldRtcpMuxSub => 'إرسال RTP وRTCP على منفذ واحد (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'تغذية RTCP الراجعة (AVPF)';

  @override
  String get acctFieldRtcpFbSub => 'عرض RTP/AVPF مع NACK. مطلوب لخوادم WebRTC';

  @override
  String get acctGroupSecurity => 'الأمان';

  @override
  String get acctFieldSrtp => 'تشفير الوسائط (SRTP)';

  @override
  String get acctOptOptional => 'اختياري';

  @override
  String get acctOptRequired => 'مطلوب';

  @override
  String get acctFieldKeyExchange => 'تبادل المفاتيح';

  @override
  String get acctFieldSecureSignaling => 'إشارات آمنة';

  @override
  String get acctOptNotRequired => 'غير مطلوب';

  @override
  String get acctOptTlsHop => 'TLS بين العقد';

  @override
  String get acctOptTlsE2e => 'TLS من طرف إلى طرف (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'خوارزمية المصادقة';

  @override
  String get acctFieldPrivacy => 'إخفاء هوية المتصل (الخصوصية)';

  @override
  String get acctFieldReferPolicy => 'التحويلات الواردة (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'مراقبو الحضور';

  @override
  String get acctOptAccept => 'قبول';

  @override
  String get acctOptReject => 'رفض';

  @override
  String get acctGroupCodecsFooter =>
      'يتجاوز قائمة الترميزات العامة لهذا الحساب.';

  @override
  String get acctFieldUseGlobalCodecs => 'استخدام ترتيب الترميزات العام';

  @override
  String get acctGroupFeatures => 'الميزات';

  @override
  String get acctFieldVoicemailNumber => 'رقم البريد الصوتي';

  @override
  String get acctFieldMwi => 'مؤشر البريد الصوتي (MWI)';

  @override
  String get acctFieldMwiSub => 'الاشتراك في إشعارات وجود رسائل';

  @override
  String get acctFieldPublishPresence => 'نشر حضوري';

  @override
  String get acctFieldPublishPresenceSub =>
      'السماح للخادم بمشاركة حالتك المتصلة';

  @override
  String get acctFieldDnd => 'عدم الإزعاج';

  @override
  String get acctFieldForwarding => 'إعادة توجيه المكالمات';

  @override
  String get acctOptForwardAlways => 'دائمًا';

  @override
  String get acctOptForwardBusy => 'عند الانشغال';

  @override
  String get acctOptForwardNoAnswer => 'عند عدم الرد';

  @override
  String get acctFieldForwardTo => 'إعادة التوجيه إلى';

  @override
  String get acctFieldForwardToHint => 'رقم أو عنوان SIP';

  @override
  String get acctFieldRingFor => 'الرنين لمدة (ث)';

  @override
  String get acctFieldAutoAnswer => 'الرد التلقائي';

  @override
  String get acctFieldAnswerAfter => 'الرد بعد (ث)';

  @override
  String get acctFieldIntercomOnly => 'لمكالمات الإنتركم فقط';

  @override
  String get acctFieldIntercomOnlySub => 'يتطلب ترويسة رد تلقائي من PBX';

  @override
  String get acctFieldRingtone => 'نغمة الرنين';

  @override
  String get acctRingtoneClassic => 'كلاسيكية';

  @override
  String get acctRingtoneSoft => 'هادئة';

  @override
  String get acctRingtoneDigital => 'رقمية';

  @override
  String get acctFieldRecordCalls => 'تسجيل المكالمات';

  @override
  String get acctFieldHoldMusic => 'موسيقى الانتظار';

  @override
  String get acctOptUseGlobal => 'استخدام الإعداد العام';

  @override
  String get acctOptPbxDefault => 'افتراضي PBX';

  @override
  String get acctFieldOpeningAnnouncement => 'إعلان الافتتاح';

  @override
  String get acctGroupFeatureCodes => 'رموز الخدمات';

  @override
  String get acctGroupFeatureCodesFooter =>
      'تُطلب للركن والالتقاط وعدم الإزعاج وإعادة التوجيه على PBX الخاص بك.';

  @override
  String get acctFieldPark => 'ركن';

  @override
  String get acctFieldGroupPickup => 'التقاط جماعي';

  @override
  String get acctFieldDirectedPickup => 'بادئة الالتقاط الموجّه';

  @override
  String get acctFieldParkRetrieve => 'بادئة استرجاع المركونة';

  @override
  String get acctFieldParkRetrieveHint => 'اطلب رقم الخانة';

  @override
  String get acctFieldParkRetrieveSub =>
      'بادئة تُطلب قبل خانة الركن لاسترجاع مكالمة مركونة';

  @override
  String get acctFieldDndOn => 'تفعيل عدم الإزعاج';

  @override
  String get acctFieldDndOff => 'إيقاف عدم الإزعاج';

  @override
  String get acctFieldForwardOn => 'تفعيل إعادة التوجيه';

  @override
  String get acctFieldForwardOff => 'إيقاف إعادة التوجيه';

  @override
  String get acctGroupAdvanced => 'متقدم';

  @override
  String get acctGroupAdvancedFooterIax =>
      'تُرسل نغمات DTMF كإطارات IAX2 أصلية.';

  @override
  String get acctFieldCallerIdOverride => 'تجاوز هوية المتصل';

  @override
  String get acctFieldCallerIdHint => 'استخدام الافتراضي للحساب';

  @override
  String get acctFieldCallerIdSub => 'اسم أو رقم هوية المتصل المرسل إلى PBX';

  @override
  String get acctFieldSessionTimers => 'مؤقتات الجلسة';

  @override
  String get acctFieldSessionExpires => 'انتهاء الجلسة (ث)';

  @override
  String get acctFieldSessionExpiresSub => 'النطاق من 90 إلى 86400';

  @override
  String get acctField100rel => '100rel (مؤقتة موثوقة)';

  @override
  String get acctFieldHoldMethod => 'طريقة الانتظار';

  @override
  String get acctFieldDtmfMethod => 'طريقة DTMF';

  @override
  String get acctOptDtmfInband => 'داخل النطاق';

  @override
  String get acctFieldRedirects => 'إعادة التوجيه (3xx)';

  @override
  String get acctOptRedirectFollow => 'اتباع';

  @override
  String get acctOptRedirectAsk => 'سؤال';

  @override
  String get acctFieldLockCodec => 'تثبيت الترميز بعد الرد';

  @override
  String get acctFieldMediaKeepAlive => 'إبقاء اتصال الوسائط';

  @override
  String get acctFieldDropCalls => 'إسقاط المكالمات عند فشل التسجيل';

  @override
  String get acctFieldExtraHeaders => 'ترويسات SIP إضافية';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: القيمة (واحدة في كل سطر)';

  @override
  String get acctFieldRetryIntervalSub =>
      'مدة الانتظار قبل إعادة محاولة تسجيل فاشل. النطاق من 0 إلى 86400';

  @override
  String get acctFieldUnregTimeout => 'مهلة إلغاء التسجيل (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'مدة انتظار ردّ إلغاء التسجيل. النطاق من 0 إلى 60000';

  @override
  String get acctFieldMwiExpiry => 'انتهاء اشتراك MWI (ث)';

  @override
  String get acctFieldDscpSip => 'DSCP لـ SIP';

  @override
  String get acctFieldDscpSipSub => 'وسم QoS للإشارات. القيمة 24 (CS3) معتادة';

  @override
  String get acctFieldDscpRtp => 'DSCP لـ RTP';

  @override
  String get acctFieldDscpRtpSub => 'وسم QoS للوسائط. القيمة 46 (EF) معتادة';

  @override
  String get acctFieldReinvite => 'Re-INVITE بعد تغيّر الشبكة';

  @override
  String get acctFieldHangupOnIpChange => 'إنهاء المكالمات عند تغيّر الشبكة';

  @override
  String get acctValidateInt => 'أدخل عددًا صحيحًا';

  @override
  String get acctValidateHostEmpty => 'أدخل اسم مضيف الخادم أو عنوانه';

  @override
  String get acctValidateHostSpaces => 'لا يمكن أن يحتوي الخادم على مسافات';

  @override
  String get acctValidateHostFormat => 'أدخل المضيف أو المضيف:المنفذ فقط';

  @override
  String get acctValidatePortRange => 'يجب أن يكون المنفذ بين 1 و65535';

  @override
  String get acctValidateWsStart => 'يجب أن يبدأ المسار بـ \"/\"';

  @override
  String get acctValidateWsLength => 'استخدم 120 حرفًا على الأكثر';

  @override
  String get acctValidateWsSpaces => 'لا يمكن أن يحتوي المسار على مسافات';

  @override
  String get acctTplAsteriskDescription =>
      'امتداد على PBX الخاص بك. UDP 5060 مع تفعيل STUN.';

  @override
  String get acctTplAsteriskNotes =>
      'استخدم رقم امتداد PJSIP/SIP وكلمة سرّه. لاستخدام TLS أو WebRTC غيّر النقل لاحقًا في إعدادات الحساب.';

  @override
  String get acctTplAsteriskUsernameHint => 'الامتداد (مثل 1001)';

  @override
  String get acctTpl3cxDescription =>
      'استخدم الامتداد ومعرّف المصادقة وكلمة المرور من بوابة 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'في 3CX افتح الامتداد، ثم \"Phones > Provisioning\" للحصول على معرّف المصادقة (عيّنه كمستخدم التفويض) وكلمة المرور. اسم FQDN هو الموجود في عنوان 3CX الخاص بك.';

  @override
  String get acctTpl3cxUsernameHint => 'الامتداد';

  @override
  String get acctTplFreeswitchDescription => 'مستخدم دليل على خادم FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'استخدم معرّف المستخدم وكلمة المرور من الدليل. الملف الداخلي الافتراضي يستمع على UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'معرّف المستخدم';

  @override
  String get acctTplKamailioDescription =>
      'خادم تسجيل وكيل SIP. يُوصى بـ TCP خلف NAT.';

  @override
  String get acctTplKamailioNotes =>
      'استخدم نطاق SIP الذي يخدمه خادم التسجيل. أضف وكيل صادر في إعدادات الحساب إذا كان الوصول إلى خادم التسجيل يتم عبر مضيف مختلف.';

  @override
  String get acctTplTwilioDescription =>
      'بيانات اعتماد نطاق SIP لـ Programmable Voice. TLS وSRTP.';

  @override
  String get acctTplTwilioNotes =>
      'أنشئ نطاق SIP في وحدة تحكم Twilio، وأضف قائمة اعتماد وفعّل تسجيل SIP. أدخل النطاق الكامل (name.sip.twilio.com) كخادم، واسم مستخدم قائمة الاعتماد وكلمة مرورها. يستخدم TLS المنفذ 5061. يدعم Twilio الترميز G.711 فقط.';

  @override
  String get acctTplTwilioUsernameHint => 'اسم مستخدم قائمة الاعتماد';

  @override
  String get acctTplTelnyxDescription => 'اتصال بالاعتماد. UDP وG.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'أنشئ Credential Connection في بوابة Telnyx وانسخ اسم مستخدم SIP وكلمة المرور الخاصين به (وليس بيانات دخولك إلى البوابة). عيّن رقمًا أو ملف صوت صادر للاتصال لإجراء المكالمات واستقبالها.';

  @override
  String get acctTplTelnyxUsernameHint => 'اسم مستخدم SIP (اتصال بالاعتماد)';

  @override
  String get acctTplVoipmsDescription =>
      'اسم مستخدم وكلمة مرور حساب فرعي. اختر أقرب POP إليك.';

  @override
  String get acctTplVoipmsNotes =>
      'استخدم حسابًا فرعيًا أُنشئ ضمن Sub Accounts، وليس حسابك الرئيسي. اختر أقرب خادم (POP) إليك من قائمة خوادم VoIP.ms واسمح له بعنوان IP الخاص بك إذا لزم.';

  @override
  String get acctTplVoipmsUsernameHint => 'الحساب الفرعي (مثل 123456_phone)';

  @override
  String get acctTplVonageDescription => 'تسجيل SIP مع TLS.';

  @override
  String get acctTplVonageNotes =>
      'لا يوفّر Vonage Business تسجيل SIP إلا في بعض الباقات. أدخل خادم SIP والمستخدم وكلمة المرور الظاهرة في بوابة إدارة Vonage للجهاز.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange عبر UDP 4569. بلا إعدادات NAT أو SRTP.';

  @override
  String get acctTplIax2Notes =>
      'يتطلب peer/user في iax.conf (type=friend أو user+peer) بكلمة السر نفسها. يجدد Asterisk تسجيلات IAX2 كل 60 ث افتراضيًا. السياق اختياري ويُرسل بصفته سياق الاتصال.';

  @override
  String get acctTplIax2UsernameHint => 'اسم مستخدم IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP عبر WebSocket آمن مع DTLS-SRTP وICE وRTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'لنقاط نهاية WebSocket في Asterisk (webrtc=yes، وTLS في http.conf على المنفذ 8089) أو FreeSWITCH أو Kamailio. يحتاج الخادم إلى شهادة TLS صالحة. غيّر مسار WebSocket في إعدادات الحساب إذا كانت البوابة لا تستخدم /ws.';

  @override
  String get acctTplGenericDescription =>
      'أي خادم تسجيل SIP. أدخل التفاصيل بنفسك.';

  @override
  String get acctTplDefaultUsernameHint => 'الامتداد / اسم المستخدم';

  @override
  String get appEngineFailedBody =>
      'لن تعمل المكالمات والتسجيل حتى تُحَل هذه المشكلة. السبب المعتاد هو إعداد شبكة أو شهادة غير صحيح.';

  @override
  String get appEngineFailedTitle => 'تعذّر تشغيل محرك المكالمات';

  @override
  String get appEngineNotRunning => 'محرك المكالمات لا يعمل';

  @override
  String get appUnknownError => 'خطأ غير معروف';

  @override
  String get appEngineOpenNetworkSettings => 'فتح إعدادات الشبكة';

  @override
  String get appEngineUseSimulator => 'استخدام المحاكي (عرض تجريبي)';

  @override
  String get appDbLockedTitle => 'بياناتك مقفلة';

  @override
  String get appDbUnreadableTitle => 'تعذّر فتح بياناتك';

  @override
  String get appDbLockedBody =>
      'سجل المكالمات وجهات الاتصال والرسائل مشفّرة على هذا الجهاز، لكن مفتاح التشفير لم يعد موجودًا في سلسلة مفاتيح النظام / مخزن المفاتيح (مثلًا بعد إعادة ضبط سلسلة المفاتيح أو الاستعادة على جهاز جديد).';

  @override
  String get appDbUnreadableBody =>
      'تعذّرت قراءة قاعدة البيانات المحلية. قد تكون تالفة، أو أن مفتاح التشفير غير مطابق.';

  @override
  String get appDbRecoveryAdvice =>
      'أعد المحاولة إذا كنت تتوقع عودة المفتاح (افتح قفل سلسلة المفاتيح، أو سجّل الدخول بالمستخدم الصحيح). البدء من جديد يُبقي الملف القديم بجانب بيانات التطبيق لكنه يبدأ بسجل وجهات اتصال ورسائل فارغة؛ وستحتاج إلى إضافة حساباتك من جديد.';

  @override
  String get appDbCopyDetails => 'نسخ التفاصيل';

  @override
  String get appDbTryAgain => 'إعادة المحاولة';

  @override
  String get appDbStartFresh => 'البدء من جديد';

  @override
  String get appRedirectTitle => 'تمت إعادة توجيه المكالمة';

  @override
  String appRedirectMessage(String target) {
    return 'أُعيد توجيه المكالمة إلى $target - هل تريد المتابعة؟';
  }

  @override
  String get appRedirectCancelCall => 'إلغاء المكالمة';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': 'تعذّر تشفير بياناتك ($error). لم يتغير شيء.',
      'other': 'تعذّر فك تشفير بياناتك ($error). لم يتغير شيء.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'المحرك الأصلي غير متاح ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'إعادة المحاولة في $time';
  }

  @override
  String get acctRegistrationError => 'خطأ في التسجيل';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nالنقل: $transport';
  }

  @override
  String get acctCallingFromDirect => 'الاتصال مباشرةً، بلا حساب';

  @override
  String acctCallingFromAccount(String name) {
    return 'الاتصال من $name';
  }

  @override
  String get acctCallingFromNone => 'الاتصال بلا أي حساب';

  @override
  String get acctNoAccount => 'لا حساب';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds ث';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount جديدة، $oldCount قديمة';
  }

  @override
  String get acctAddAccount => 'إضافة حساب';

  @override
  String get acctUnregister => 'إلغاء التسجيل';

  @override
  String get acctSheetDndSub => 'رفض المكالمات الواردة على هذا الحساب';

  @override
  String get acctKvServer => 'الخادم';

  @override
  String get acctKvResolvedServer => 'الخادم المحلَّل';

  @override
  String get acctKvClientCert => 'شهادة العميل';

  @override
  String get acctKvClientCertValue => 'تُقدَّم للخادم (TLS المتبادل)';

  @override
  String get acctKvContact => 'جهة الاتصال';

  @override
  String get acctKvExpiresIn => 'تنتهي خلال';

  @override
  String get acctKvVoicemail => 'البريد الصوتي';

  @override
  String get acctOpenSipTrace => 'فتح تتبع SIP';

  @override
  String get acctAddAnAccount => 'إضافة حساب';

  @override
  String get acctChooseAccountTooltip => 'اختر الحساب الذي ستتصل منه';

  @override
  String get acctDirectNoAccount => 'مباشر (بلا حساب)';

  @override
  String get onboardingRequired => 'اسم المستخدم والخادم مطلوبان';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'يُستخدم المنفذ $port ما لم تضف :المنفذ';
  }

  @override
  String get onboardingFineTuneIax =>
      'يمكنك ضبط الترميزات والتسجيل بدقة لاحقًا من الإعدادات.';

  @override
  String get onboardingFineTuneSip =>
      'يمكنك ضبط النقل وNAT والأمان والترميزات بدقة لاحقًا من الإعدادات.';

  @override
  String get onboardingDemoUser => 'مستخدم تجريبي';

  @override
  String get onboardingDemoAccount => 'حساب تجريبي';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'اتصالات احترافية لكل المنصات - مجانية ومفتوحة المصدر. بلا إعلانات وبلا تتبّع.';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingPermissionsTitle => 'الأذونات';

  @override
  String get onboardingPermissionsText =>
      'يحتاج SoftphonePro إلى الميكروفون لنقل صوتك، وإلى الإشعارات لإعلامك بالمكالمات والرسائل الواردة. لا يغادر جهازك شيء سوى مكالماتك.';

  @override
  String get onboardingChooseProvider => 'اختر مزوّدك';

  @override
  String get onboardingChooseProviderSub =>
      'نملأ لك إعدادات النقل والمنافذ وNAT مسبقًا.';

  @override
  String get onboardingScanQr => 'مسح QR';

  @override
  String get onboardingImportUrl => 'استيراد من رابط';

  @override
  String get onboardingSkip => 'تخطّي الآن (وضع تجريبي)';

  @override
  String get onboardingHidePassword => 'إخفاء كلمة المرور';

  @override
  String get onboardingShowPassword => 'إظهار كلمة المرور';

  @override
  String get onboardingContextOptional => 'السياق (اختياري)';

  @override
  String get onboardingDisplayNameOptional => 'الاسم المعروض (اختياري)';

  @override
  String get onboardingLabelOptional => 'تسمية الحساب (اختياري)';

  @override
  String get onboardingCallerIdOptional => 'هوية المتصل (اختياري)';

  @override
  String get onboardingAuthUserOptional => 'مستخدم التفويض (إن اختلف)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'اسم المستخدم أو كلمة المرور غير صحيحة ($code)';
  }

  @override
  String get acctRegNotFound => 'الحساب غير موجود على الخادم (404)';

  @override
  String get acctRegNoAnswer => 'لم يردّ الخادم (408)';

  @override
  String get acctRegIntervalTooShort => 'فاصل التسجيل قصير جدًا (423)';

  @override
  String get acctRegTemporarilyUnavailable => 'الخادم غير متاح مؤقتًا (480)';

  @override
  String get acctRegServiceUnavailable => 'الخدمة غير متاحة (503)';

  @override
  String get acctRegFailed => 'فشل التسجيل';

  @override
  String acctRegFailedWithCode(int code) {
    return 'فشل التسجيل ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'تعذّر تغيير التسجيل';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'تعذّر تطبيق الحساب \"$name\"';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'العودة إلى الخادم الأساسي للحساب $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'استخدام الخادم الاحتياطي للحساب $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'الحساب $name مسجّل';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'الحساب $name ما زال قيد التسجيل';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'الحساب $name لم يُسجَّل بعد';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'الحساب $name غير مسجّل (فشل التسجيل)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'الحساب $name معطّل';
  }

  @override
  String get callDialEngineFailed => 'فشل تشغيل محرك المكالمات';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'فشل تشغيل محرك المكالمات: $reason';
  }

  @override
  String get callDialEngineStarting => 'محرك المكالمات ما زال قيد التشغيل';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status بعد $seconds ث؛ لم تُجرَ المكالمة';
  }

  @override
  String get callJournalInterrupted => 'أُغلق التطبيق أثناء المكالمة';

  @override
  String get callLinkMissingArgument => 'وسيط مفقود';

  @override
  String get callLinkHttpsRequired => 'يجب أن تستخدم روابط الإعدادات https';

  @override
  String get callLinkInvalidLan => 'رابط LAN هذا غير صالح';

  @override
  String callLinkConnectedTo(String name) {
    return 'تم الاتصال بـ $name';
  }

  @override
  String get callLinkConnectFailed => 'تعذّر الاتصال بذلك الجهاز';

  @override
  String callLinkCallFailed(String target) {
    return 'تعذّر إجراء المكالمة إلى $target';
  }

  @override
  String get callLinkImportTitle => 'استيراد الإعدادات';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts حساب',
      many: '$accounts حسابًا',
      few: '$accounts حسابات',
      two: 'حسابين',
      one: 'حسابًا واحدًا',
      zero: 'أي حساب',
    );
    return 'استيراد الإعدادات من $host؟ ستضيف $_temp0.';
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
      other: '$accounts حساب',
      many: '$accounts حسابًا',
      few: '$accounts حسابات',
      two: 'حسابين',
      one: 'حسابًا واحدًا',
      zero: 'أي حساب',
    );
    return 'استيراد الإعدادات من $host؟ ستضيف $_temp0 و$settings إعداد(ات).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'أُعيد توجيهها من $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'أُعيد توجيهها من $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'حوّلها $number';
  }

  @override
  String get callRingtoneSystemDefault => 'افتراضي النظام';

  @override
  String get callRingtoneClassic => 'كلاسيكية';

  @override
  String get callRingtoneSoft => 'هادئة';

  @override
  String get callRingtoneDigital => 'رقمية';

  @override
  String callIdentityFrom(String number) {
    return 'من $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'هوية المتصل $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'هوية المتصل $name $number';
  }

  @override
  String get callTransferring => 'جارٍ التحويل...';

  @override
  String get callTransferNotConfirmed => 'لم يؤكد الخادم التحويل';

  @override
  String get callTransferStalledHint =>
      'المكالمة ما زالت قائمة. أبقِها، أو أعد إرسال التحويل.';

  @override
  String get callTransferKeepCall => 'إبقاء المكالمة';

  @override
  String get callAnnouncementOpening => 'جارٍ تشغيل الإعلان…';

  @override
  String get callAnnouncementTransfer => 'جارٍ تشغيل إشعار التحويل…';

  @override
  String get callAnnouncementRecording => 'جارٍ تشغيل إشعار التسجيل…';

  @override
  String get callAnnouncementSkip => 'تخطّي';

  @override
  String get callNoiseTooltipMic =>
      'إلغاء الضوضاء بالذكاء الاصطناعي: ميكروفونك';

  @override
  String get callNoiseTooltipIncoming =>
      'إلغاء الضوضاء بالذكاء الاصطناعي: المشاركون الآخرون';

  @override
  String get callNoiseTooltipBoth =>
      'إلغاء الضوضاء بالذكاء الاصطناعي: ميكروفونك والمشاركون الآخرون';

  @override
  String get callNoiseOn => 'إلغاء الضوضاء مفعّل';

  @override
  String get callNoiseTitle => 'إلغاء الضوضاء';

  @override
  String callNoiseMicStrength(String strength) {
    return 'ميكروفوني: $strength';
  }

  @override
  String get callNoiseMicOffHint => 'إزالة ضوضاء الخلفية من ميكروفوني';

  @override
  String get callResultAnswered => 'تم الرد';

  @override
  String get callResultMissed => 'فائتة';

  @override
  String get callResultRejected => 'مرفوضة';

  @override
  String get callResultFailed => 'فاشلة';

  @override
  String get callResultBusy => 'مشغول';

  @override
  String get callResultForwarded => 'أُعيد توجيهها';

  @override
  String get callResultTransferred => 'مُحوَّلة';

  @override
  String get callResultHandedOff => 'سُلّمت لجهاز آخر';

  @override
  String get callResultInterrupted => 'منقطعة';

  @override
  String get keypadCall => 'اتصال';

  @override
  String get keypadNoVoicemail => 'لا يوجد رقم بريد صوتي مهيأ لهذا الحساب';

  @override
  String get keypadCallDirectly => 'اتصال مباشر (بلا حساب)';

  @override
  String get keypadAddAccount => 'أضف حسابًا لإجراء المكالمات';

  @override
  String keypadCallFrom(String account) {
    return 'الاتصال من $account';
  }

  @override
  String get keypadRecent => 'الأخيرة';

  @override
  String get keypadSuggestions => 'اقتراحات';

  @override
  String get keypadPhoneNumber => 'رقم الهاتف';

  @override
  String get keypadPaste => 'لصق';

  @override
  String get keypadEnterNumber => 'أدخل الرقم';

  @override
  String get keypadBackspace => 'حذف (اضغط مطولًا للمسح)';

  @override
  String get keypadTypeNameOrNumber => 'اكتب اسمًا أو رقمًا';

  @override
  String get keypadNoMatches => 'لا نتائج مطابقة';

  @override
  String get keypadSuggestionsHint =>
      'تأتي الاقتراحات من جهات الاتصال والمكالمات الأخيرة';

  @override
  String keypadCallPerson(String name) {
    return 'اتصال بـ $name';
  }

  @override
  String get dialKeyStar => 'نجمة';

  @override
  String get dialKeyPound => 'مربّع';

  @override
  String get dialKeyLongPressPlus => 'اضغط مطولًا للحصول على علامة الجمع';

  @override
  String get dialKeyLongPressSpeedDial => 'اضغط مطولًا للطلب السريع';

  @override
  String get dialKeyLongPressVoicemail => 'اضغط مطولًا للبريد الصوتي';

  @override
  String get callBackToApp => 'العودة إلى التطبيق (تبقى المكالمة قائمة)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'إخفاء لوحة المفاتيح';

  @override
  String get callMute => 'كتم';

  @override
  String get callKeypad => 'لوحة المفاتيح';

  @override
  String get callSpeaker => 'مكبّر الصوت';

  @override
  String get callRouteBluetooth => 'بلوتوث';

  @override
  String get callRouteHeadset => 'سماعة رأس';

  @override
  String get callResume => 'استئناف';

  @override
  String get callHold => 'انتظار';

  @override
  String get callAddCall => 'إضافة مكالمة';

  @override
  String get callTransfer => 'تحويل';

  @override
  String get callStop => 'إيقاف';

  @override
  String get callRecord => 'تسجيل';

  @override
  String get callSplit => 'فصل';

  @override
  String get callMerge => 'دمج';

  @override
  String get callSwap => 'تبديل';

  @override
  String get callEndCall => 'إنهاء المكالمة';

  @override
  String callEndCallWith(String name) {
    return 'إنهاء المكالمة مع $name';
  }

  @override
  String get callAttendedTransferHint =>
      'تحويل باستشارة. المتصل الأصلي قيد الانتظار.';

  @override
  String get callCompleteTransfer => 'إتمام التحويل';

  @override
  String get callWaiting => 'مكالمة في الانتظار';

  @override
  String get callHoldAndAnswer => 'وضع المكالمة الحالية قيد الانتظار والرد';

  @override
  String get callDecline => 'رفض';

  @override
  String get callAnswer => 'رد';

  @override
  String get callIncomingCall => 'مكالمة واردة';

  @override
  String get callReply => 'ردّ برسالة';

  @override
  String get callVoicemail => 'البريد الصوتي';

  @override
  String get callToDevice => 'إلى جهاز';

  @override
  String get callQuickReplyBusy => 'لا أستطيع التحدث الآن، سأعاود الاتصال بك.';

  @override
  String get callQuickReplyMeeting => 'أنا في اجتماع. هل يمكنك مراسلتي؟';

  @override
  String get callQuickReplyOnMyWay => 'أنا في الطريق.';

  @override
  String callReturnToCallWith(String name) {
    return 'العودة إلى المكالمة مع $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'واردة: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'في مكالمة مع $name';
  }

  @override
  String get callStatsCodec => 'الترميز';

  @override
  String get callStatsJitter => 'الارتجاف';

  @override
  String get callStatsPacketLoss => 'فقدان الحزم';

  @override
  String get callStatsRoundTrip => 'زمن الذهاب والإياب';

  @override
  String get callStatsMedia => 'الوسائط';

  @override
  String get callStatsMosHistory => 'سجل MOS';

  @override
  String get callQualityTitle => 'جودة المكالمة';

  @override
  String get callTransferTitle => 'تحويل المكالمة';

  @override
  String get callTransferModeBlind => 'مباشر';

  @override
  String get callTransferModeAttended => 'باستشارة';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'جهاز LAN';

  @override
  String get callTransferNoLanDevices =>
      'لم يُعثر على أجهزة SoftphonePro مقترنة على شبكتك. اقرن جهازًا من صفحة LAN.';

  @override
  String get callTransferLanDisabled =>
      'فعّل LAN Link (الإعدادات، LAN Link) لتسليم هذه المكالمة إلى جهاز آخر على شبكتك.';

  @override
  String get callTransferTalkFirst => 'تحدّث أولًا';

  @override
  String get callTransferBlindHint => 'يسلّم المتصل فورًا. ينقطع اتصالك.';

  @override
  String get callTransferAttendedHint =>
      'يضع المتصل قيد الانتظار ويتصل بالمستلم أولًا. أتمم التحويل بعد أن يرد.';

  @override
  String get callTransferNumberLabel => 'رقم أو عنوان SIP';

  @override
  String get callTransferNow => 'حوّل الآن';

  @override
  String get callTransferCallAndConsult => 'اتصال واستشارة';

  @override
  String get callRetrieveParkedTitle => 'استرجاع مكالمة مركونة';

  @override
  String get callRetrieveParkedHint => 'خانة الركن، مثل 701';

  @override
  String get callMoreAudioOutput => 'مخرج الصوت';

  @override
  String get callMoreAudioDevices => 'أجهزة الصوت';

  @override
  String get callMoreAudioOutputSubtitle =>
      'الهاتف، مكبّر الصوت، بلوتوث، سماعة الرأس';

  @override
  String get callMoreAudioDevicesSubtitle => 'اختر الميكروفون ومكبّر الصوت';

  @override
  String get callMoreParkCall => 'ركن المكالمة';

  @override
  String get callMoreParkCallSubtitle => 'تحويل إلى رمز خدمة الركن';

  @override
  String get callMoreRetrieveParkedSubtitle => 'اطلب خانة ركن';

  @override
  String get callMoreSendDtmf => 'إرسال أرقام DTMF';

  @override
  String get callMoreSendDtmfSubtitle => 'اكتب تسلسلًا كاملًا، مثل رمز PIN';

  @override
  String get callSendDtmfTitle => 'إرسال DTMF';

  @override
  String get callMoreCallInfo => 'معلومات المكالمة';

  @override
  String get callMoreQualitySubtitle =>
      'MOS والارتجاف والفقد وزمن الذهاب والإياب المباشرة';

  @override
  String get callMoreSipTrace => 'تتبع SIP';

  @override
  String get callMoreSipTraceSubtitle => 'مخطط تسلسلي لهذه المكالمة';

  @override
  String get callInfoRemote => 'الطرف الآخر';

  @override
  String get callInfoAccount => 'الحساب';

  @override
  String get callInfoState => 'الحالة';

  @override
  String get callInfoSecure => 'الأمان';

  @override
  String get callInfoPlainSignalling => 'إشارات غير مشفّرة';

  @override
  String get callRoutePhone => 'الهاتف';

  @override
  String get callRouteWiredHeadset => 'سماعة رأس سلكية';

  @override
  String get callAudioMicrophone => 'الميكروفون';

  @override
  String callCardSemantics(String name, String state) {
    return 'مكالمة مع $name، $state';
  }

  @override
  String get callUnmute => 'إلغاء الكتم';

  @override
  String get callStopRecording => 'إيقاف التسجيل';

  @override
  String get callSplitConference => 'فصل المؤتمر';

  @override
  String get callMergeCalls => 'دمج المكالمات';

  @override
  String get callSwapCalls => 'تبديل المكالمات';

  @override
  String get callAttendedTransferBanner =>
      'تحويل باستشارة: المتصل الأصلي قيد الانتظار.';

  @override
  String get callActiveCalls => 'المكالمات النشطة';

  @override
  String get callConferenceLevels => 'مستويات المؤتمر';

  @override
  String get callLevelVolume => 'مستوى الصوت';

  @override
  String get callLevelMicToParty => 'الميكروفون إلى الطرف';

  @override
  String callPercentSemantics(int percent) {
    return '$percent بالمئة';
  }

  @override
  String get callFailInvalidNumber => 'رقم غير صالح (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'المكالمة غير مصرّح بها ($code)';
  }

  @override
  String get callFailNumberNotFound => 'الرقم غير موجود (404)';

  @override
  String get callFailNoAnswerFromServer => 'لا ردّ من الخادم (408)';

  @override
  String get callFailTemporarilyUnavailable => 'غير متاح مؤقتًا (480)';

  @override
  String get callFailIncompleteNumber => 'رقم غير مكتمل (484)';

  @override
  String callFailBusy(String code) {
    return 'مشغول ($code)';
  }

  @override
  String get callFailCancelled => 'أُلغيت المكالمة (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'لا يوجد ترميز متوافق ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'الخدمة غير متاحة (503)';

  @override
  String get callFailDeclined => 'رُفضت المكالمة (603)';

  @override
  String get callFailGeneric => 'فشلت المكالمة';

  @override
  String callFailGenericWithCode(String code) {
    return 'فشلت المكالمة ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'مكالمة جارية';

  @override
  String get callTrayInCall => 'في مكالمة';

  @override
  String get callHistoryBlocked => 'محظور';

  @override
  String get callHistoryAnonymityDisallowed => 'المكالمات المجهولة غير مسموحة';

  @override
  String get callHistoryDoNotDisturb => 'عدم الإزعاج';

  @override
  String get callHistoryBusy => 'مشغول';

  @override
  String get callHistoryForwardedAlways => 'أُعيد توجيهها (دائمًا)';

  @override
  String get callHistoryForwardedBusy => 'أُعيد توجيهها (مشغول)';

  @override
  String get callHistorySentToVoicemail => 'أُرسلت إلى البريد الصوتي';

  @override
  String get callHistoryRedirected => 'أُعيد تحويل مسارها';

  @override
  String get callIncomingNotificationBody => 'مكالمة واردة';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'مكالمة واردة على $account';
  }

  @override
  String get callMissedNotificationTitle => 'مكالمة فائتة';

  @override
  String get callErrEngineNotRunning => 'محرك المكالمات لم يعمل بعد';

  @override
  String get callErrAddAccount => 'أضف حسابًا لإجراء المكالمات';

  @override
  String get callErrCouldNotPlace => 'تعذّر إجراء المكالمة';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account غير مسجّل';
  }

  @override
  String get callErrCouldNotAnswer => 'تعذّر الرد';

  @override
  String get callErrNoVoicemailNumber => 'لم يُحدَّد رقم بريد صوتي لهذا الحساب';

  @override
  String get callErrTransferFailed => 'فشل التحويل';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'فشل التحويل: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'تعذّر دمج المكالمات';

  @override
  String get callErrCouldNotStartRecording => 'تعذّر بدء التسجيل';

  @override
  String get callErrCouldNotStopRecording => 'تعذّر إيقاف التسجيل';

  @override
  String callParkingNotice(String code) {
    return 'جارٍ ركن المكالمة (اطلب $code)';
  }

  @override
  String get callErrParkFailed => 'فشل الركن';

  @override
  String get callErrHandoffFailed => 'فشل التسليم';

  @override
  String get callErrCouldNotSendToDevice => 'تعذّر الإرسال إلى الجهاز';

  @override
  String get callHistoryForwardedNoAnswer => 'أُعيد توجيهها (لا ردّ)';

  @override
  String get shellTabKeypad => 'لوحة المفاتيح';

  @override
  String get shellTabRecents => 'الأخيرة';

  @override
  String get shellTabContacts => 'جهات الاتصال';

  @override
  String get shellTabMessages => 'الرسائل';

  @override
  String get shellTabPresence => 'الحضور';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'التسجيلات';

  @override
  String get shellSearchSemantics =>
      'ابحث في جهات الاتصال أو السجل أو اطلب رقمًا';

  @override
  String get shellSearchHint => 'بحث أو اتصال';

  @override
  String get shellVoicemailTooltip => 'البريد الصوتي';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة صوتية جديدة. انقر للاتصال بالبريد الصوتي',
      many: '$count رسالة صوتية جديدة. انقر للاتصال بالبريد الصوتي',
      few: '$count رسائل صوتية جديدة. انقر للاتصال بالبريد الصوتي',
      two: 'رسالتان صوتيتان جديدتان. انقر للاتصال بالبريد الصوتي',
      one: 'رسالة صوتية جديدة واحدة. انقر للاتصال بالبريد الصوتي',
      zero: 'لا رسائل صوتية جديدة. انقر للاتصال بالبريد الصوتي',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'بعيد';

  @override
  String get shellStatusTooltip => 'حالتك';

  @override
  String get shellDemoBanner =>
      'الوضع التجريبي: المكالمات محاكاة ولا شيء يصل إلى شبكة حقيقية.';

  @override
  String get uiToday => 'اليوم';

  @override
  String get uiYesterday => 'أمس';

  @override
  String get uiUnknownCaller => 'متصل مجهول';

  @override
  String get uiCallEnded => 'انتهت المكالمة';

  @override
  String get uiCallTransferNotConfirmed => 'لم يتأكد التحويل';

  @override
  String get uiCallTransferring => 'جارٍ التحويل...';

  @override
  String get uiCallConference => 'مؤتمر';

  @override
  String get uiCallOnHold => 'قيد الانتظار';

  @override
  String get uiCallHeldByRemote => 'قيد الانتظار لدى الطرف الآخر';

  @override
  String get uiCallCalling => 'جارٍ الاتصال...';

  @override
  String get uiCallRinging => 'يرنّ...';

  @override
  String get uiCallConnecting => 'جارٍ الاتصال بالخادم...';

  @override
  String get uiCallIncoming => 'مكالمة واردة';

  @override
  String get uiCallConnected => 'متصل';

  @override
  String get uiQrScanTitle => 'مسح رمز QR';

  @override
  String get uiQrPasteHint => 'الصق نص الرمز';

  @override
  String get uiQrNoCamera =>
      'المسح بالكاميرا غير متاح على هذا الجهاز. الصق نص الرمز بدلًا من ذلك.';

  @override
  String get uiQrPaste => 'لصق';

  @override
  String get uiQrUse => 'استخدام';

  @override
  String get uiQrCameraDenied =>
      'الوصول إلى الكاميرا معطّل. اسمح به من إعدادات النظام، أو الصق نص الرمز أدناه.';

  @override
  String get uiQrCameraUnavailable =>
      'الكاميرا غير متاحة. الصق نص الرمز أدناه.';

  @override
  String get presenceLampRinging => 'يرنّ';

  @override
  String get presenceHeader => 'حقل مصباح الانشغال';

  @override
  String get presenceChooseTooltip => 'اختر جهات الاتصال لمراقبتها';

  @override
  String get presenceEmptyTitle => 'لا امتدادات على اللوحة';

  @override
  String get presenceEmptySubtitle =>
      'فعّل \"إظهار على لوحة BLF\" لجهة اتصال لترى متى تكون متاحة أو يرنّ هاتفها أو مشغولة.';

  @override
  String get presenceOpenContacts => 'فتح جهات الاتصال';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name، $status. اضغط للاتصال، واضغط مطولًا للمزيد';
  }

  @override
  String presenceCallName(String name) {
    return 'اتصال بـ $name';
  }

  @override
  String get presencePickup => 'التقاط مكالمة هذا الامتداد';

  @override
  String get presencePickupSub => 'الرد على مكالمته الرانّة (التقاط موجّه)';

  @override
  String get presenceTransferHere => 'تحويل المكالمة الحالية إلى هنا';

  @override
  String get presenceRemove => 'إزالة من اللوحة';

  @override
  String get uiCall => 'اتصال';

  @override
  String get uiMessage => 'رسالة';

  @override
  String get recentsSearchTooltip => 'بحث في السجل';

  @override
  String get recentsClearTitle => 'مسح سجل المكالمات؟';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم حذف كل الإدخالات الـ $count.',
      many: 'سيتم حذف كل الإدخالات الـ $count.',
      few: 'سيتم حذف كل الإدخالات الـ $count.',
      two: 'سيُحذف الإدخالان.',
      one: 'سيُحذف إدخال واحد.',
      zero: 'لا إدخالات للحذف.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => 'نُسخ السجل إلى الحافظة بصيغة CSV';

  @override
  String get recentsMenuCopyCsv => 'نسخ بصيغة CSV';

  @override
  String get recentsMenuClear => 'مسح السجل';

  @override
  String get recentsSearchHint => 'ابحث بالاسم أو الرقم';

  @override
  String get recentsFilterAll => 'الكل';

  @override
  String get recentsFilterMissed => 'الفائتة';

  @override
  String get recentsFilterIncoming => 'الواردة';

  @override
  String get recentsFilterOutgoing => 'الصادرة';

  @override
  String get recentsFilterAccount => 'التصفية حسب الحساب';

  @override
  String get recentsAllAccounts => 'كل الحسابات';

  @override
  String get recentsAccountFallback => 'الحساب';

  @override
  String get recentsEmptyNone => 'لا مكالمات بعد';

  @override
  String get recentsEmptyNoMatch => 'لا مكالمات مطابقة';

  @override
  String get recentsEmptyNoneSub => 'ستظهر مكالماتك هنا.';

  @override
  String get recentsEmptyNoMatchSub => 'جرّب مرشحًا آخر.';

  @override
  String get recentsOpenKeypad => 'فتح لوحة المفاتيح';

  @override
  String get recentsShowAll => 'إظهار الكل';

  @override
  String get recentsSelectCall => 'اختر مكالمة';

  @override
  String get recentsSelectCallSub => 'تظهر هنا التفاصيل والجودة والتسجيلات.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'مكالمة فائتة',
      'incoming': 'مكالمة واردة',
      'other': 'مكالمة صادرة',
    });
    return '$_temp0 $name، $number، $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'اتصال بـ $name';
  }

  @override
  String get recentsAddAccountToMessage => 'أضف حسابًا لإرسال الرسائل';

  @override
  String get recentsAddContact => 'إضافة جهة اتصال';

  @override
  String get recentsContact => 'جهة الاتصال';

  @override
  String get recentsBlock => 'حظر';

  @override
  String get recentsUnblock => 'إلغاء الحظر';

  @override
  String recentsBlockTitle(String number) {
    return 'حظر $number؟';
  }

  @override
  String get recentsBlockMessage => 'سيتم رفض المكالمات من هذا الرقم تلقائيًا.';

  @override
  String get recentsQualityHeader => 'جودة المكالمة';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'أسوأ MOS $mos   ·   الارتجاف $jitter ms   ·   الفقد $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'التسجيلات';

  @override
  String get recentsOpenInRecordings => 'فتح في التسجيلات';

  @override
  String recentsRelatedCall(String title) {
    return 'مكالمة ذات صلة: $title';
  }

  @override
  String get recentsHistoryHeader => 'السجل';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'لا مكالمات مع هذا الرقم';

  @override
  String get recentsDeleteTitle => 'حذف هذه المكالمات؟';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُحذف $count إدخال لـ $name.',
      many: 'سيُحذف $count إدخالًا لـ $name.',
      few: 'سيُحذف $count إدخالات لـ $name.',
      two: 'سيُحذف إدخالان لـ $name.',
      one: 'سيُحذف إدخال واحد لـ $name.',
      zero: 'لا إدخالات للحذف لـ $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'حذف من السجل';

  @override
  String get recentsCallDetails => 'تفاصيل المكالمة';

  @override
  String get contactsFavoritesHeader => '★ المفضلة';

  @override
  String get contactsFavoritesOnly => 'المفضلة فقط';

  @override
  String get contactsShowAll => 'إظهار الكل';

  @override
  String get contactsImportExportTooltip => 'استيراد وتصدير';

  @override
  String get contactsMenuDevice => 'استيراد من الجهاز';

  @override
  String get contactsMenuFile => 'استيراد ملف vCard / CSV';

  @override
  String get contactsMenuClipboard => 'استيراد من الحافظة';

  @override
  String get contactsMenuCopyVcard => 'نسخ بصيغة vCard';

  @override
  String get contactsMenuCopyCsv => 'نسخ بصيغة CSV';

  @override
  String get contactsNewTooltip => 'جهة اتصال جديدة';

  @override
  String get contactsSearchHint => 'بحث في جهات الاتصال';

  @override
  String get contactsEmptyTitle => 'لا جهات اتصال بعد';

  @override
  String get contactsEmptySubtitle =>
      'أضف الأشخاص الذين تتصل بهم كثيرًا، أو استورد ملف vCard أو CSV.';

  @override
  String get contactsEmptyAction => 'إضافة جهة اتصال';

  @override
  String get contactsNoMatches => 'لا نتائج مطابقة';

  @override
  String contactsCallName(String name) {
    return 'اتصال بـ $name';
  }

  @override
  String get contactsSelect => 'اختر جهة اتصال';

  @override
  String get contactsCopiedVcard => 'نُسخت جهات الاتصال بصيغة vCard';

  @override
  String get contactsCopiedCsv => 'نُسخت جهات الاتصال بصيغة CSV';

  @override
  String get contactsDeviceDenied =>
      'رُفض الوصول إلى جهات الاتصال. اسمح به من إعدادات النظام للاستيراد.';

  @override
  String get contactsDeviceNone => 'لم يُعثر على جهات اتصال على هذا الجهاز';

  @override
  String contactsNothingNew(int count) {
    return 'لا جديد للاستيراد ($count موجودة مسبقًا)';
  }

  @override
  String get contactsImportDeviceTitle => 'الاستيراد من الجهاز؟';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهة اتصال جديدة',
      many: '$count جهة اتصال جديدة',
      few: '$count جهات اتصال جديدة',
      two: 'جهتا اتصال جديدتان',
      one: 'جهة اتصال جديدة واحدة',
      zero: 'لا جهات اتصال جديدة',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count حُدّثت بأرقام إضافية';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count تم تخطّيها (مكررة أو بلا رقم هاتف)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم استيراد $count جهة اتصال',
      many: 'تم استيراد $count جهة اتصال',
      few: 'تم استيراد $count جهات اتصال',
      two: 'تم استيراد جهتي اتصال',
      one: 'تم استيراد جهة اتصال واحدة',
      zero: 'لم تُستورد أي جهة اتصال',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'لم يُعثر على جهات اتصال في تلك البيانات';

  @override
  String get contactsLabelMobile => 'جوال';

  @override
  String get contactsLabelWork => 'عمل';

  @override
  String get contactsLabelHome => 'منزل';

  @override
  String get contactsLabelOther => 'أخرى';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'جهة الاتصال غير موجودة';

  @override
  String get contactsActionFavorite => 'المفضلة';

  @override
  String get contactsNumbersHeader => 'الأرقام';

  @override
  String get contactsSipAddress => 'عنوان SIP';

  @override
  String get contactsDetailsHeader => 'التفاصيل';

  @override
  String get contactsOnBlf => 'ظاهرة على لوحة BLF';

  @override
  String get contactsAlwaysRecorded => 'تُسجَّل المكالمات دائمًا';

  @override
  String contactsDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get contactsDeleteMessage => 'ستُزال جهة الاتصال هذه من هذا الجهاز.';

  @override
  String get contactsDeleteButton => 'حذف جهة الاتصال';

  @override
  String get contactsDetailTitle => 'جهة اتصال';

  @override
  String get contactsErrorNameOrNumber => 'أدخل اسمًا أو رقمًا';

  @override
  String get contactsEditTitle => 'تعديل جهة الاتصال';

  @override
  String get contactsFieldName => 'الاسم';

  @override
  String get contactsFieldCompany => 'الشركة';

  @override
  String get contactsFieldNumber => 'الرقم';

  @override
  String get contactsRemoveNumber => 'إزالة الرقم';

  @override
  String get contactsAddNumber => 'إضافة رقم';

  @override
  String get contactsSipHeader => 'عناوين SIP';

  @override
  String get contactsRemoveAddress => 'إزالة العنوان';

  @override
  String get contactsAddSip => 'إضافة عنوان SIP';

  @override
  String get contactsFieldEmail => 'البريد الإلكتروني';

  @override
  String get contactsFieldNotes => 'ملاحظات';

  @override
  String get contactsFieldFavorite => 'مفضلة';

  @override
  String get contactsShowOnBlf => 'إظهار على لوحة BLF';

  @override
  String get contactsShowOnBlfSub => 'مراقبة حضور هذا الامتداد ومصباح انشغاله';

  @override
  String get contactsAlwaysRecordTitle =>
      'تسجيل المكالمات مع جهة الاتصال هذه دائمًا';

  @override
  String get contactsAlwaysRecordSub => 'يتجاوز قواعد التسجيل التلقائي';

  @override
  String get contactsRingtone => 'نغمة الرنين';

  @override
  String get contactsPresenceVia => 'الحضور عبر الحساب';

  @override
  String get contactsDefaultAccount => 'الحساب الافتراضي';

  @override
  String get contactsDeleteContactTitle => 'حذف جهة الاتصال؟';

  @override
  String get contactsCannotUndo => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get messagesNewMessage => 'رسالة جديدة';

  @override
  String get messagesNumberOrSip => 'رقم أو عنوان SIP';

  @override
  String get messagesNoConversations => 'لا محادثات';

  @override
  String get messagesEmptySubtitle =>
      'أرسل رسالة SIP إلى أي امتداد أو عنوان من حساباتك.';

  @override
  String get messagesTyping => 'يكتب...';

  @override
  String get messagesYouPrefix => 'أنت: ';

  @override
  String get messagesSelect => 'اختر محادثة';

  @override
  String get messagesLanOnline => 'متصل على شبكتك';

  @override
  String get messagesLanOffline => 'غير متصل. ستُرسل الرسائل عند عودته.';

  @override
  String messagesSendFileTo(String name) {
    return 'إرسال ملف إلى $name';
  }

  @override
  String messagesCallName(String name) {
    return 'اتصال بـ $name';
  }

  @override
  String get messagesDeleteTitle => 'حذف المحادثة؟';

  @override
  String messagesDeleteMessage(String name) {
    return 'ستُزال كل الرسائل مع $name.';
  }

  @override
  String get messagesDeleteMenu => 'حذف المحادثة';

  @override
  String get messagesSayHello => 'ألقِ التحية';

  @override
  String get messagesLanEmptySub =>
      'تصل الرسائل مباشرةً إلى هذا الجهاز عبر شبكتك، بتشفير من طرف إلى طرف.';

  @override
  String get messagesSipEmptySub =>
      'تُرسل الرسائل عبر SIP MESSAGE من خلال حسابك.';

  @override
  String get messagesInputHint => 'رسالة';

  @override
  String get messagesSend => 'إرسال';

  @override
  String get messagesStatusSending => 'جارٍ الإرسال';

  @override
  String get messagesStatusSent => 'أُرسلت';

  @override
  String get messagesStatusDelivered => 'سُلّمت';

  @override
  String get messagesStatusRead => 'قُرئت';

  @override
  String get messagesStatusFailed => 'فشلت';

  @override
  String get messagesNotDelivered => 'لم تُسلَّم. اضغط لإعادة المحاولة';

  @override
  String get uiStatusRegistered => 'مسجّل';

  @override
  String get uiStatusRegistering => 'جارٍ التسجيل';

  @override
  String get uiStatusRegFailed => 'فشل التسجيل';

  @override
  String get uiStatusDisabled => 'معطّل';

  @override
  String get uiQualityMeasuring => 'جارٍ القياس';

  @override
  String get uiQualityExcellent => 'ممتازة';

  @override
  String get uiQualityGood => 'جيدة';

  @override
  String get uiQualityFair => 'مقبولة';

  @override
  String get uiQualityPoor => 'ضعيفة';

  @override
  String get uiQualityBad => 'سيئة';

  @override
  String uiQualitySemantics(String label) {
    return 'جودة المكالمة $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'جودة المكالمة $label، MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'جودة المكالمة: $label';
  }

  @override
  String get uiSecureFull => 'مشفّرة';

  @override
  String get uiSecureMedia => 'الوسائط مشفّرة';

  @override
  String get uiSecureSignalling => 'الإشارات مشفّرة';

  @override
  String get uiSecureNone => 'غير مشفّرة';

  @override
  String get uiSecureSrtpLine => 'وسائط SRTP';

  @override
  String get uiSecureTlsLine => 'إشارات TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'جارٍ التسليم إلى $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'إنتركم إلى $name';
  }

  @override
  String get lanCallIntercomToUnnamed => 'إنتركم إلى جهاز قريب';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'إنتركم من $name';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'إنتركم من جهاز قريب';

  @override
  String lanCallToNamed(String name) {
    return 'مكالمة LAN إلى $name';
  }

  @override
  String get lanCallToUnpaired => 'مكالمة LAN إلى جهاز غير مقترن';

  @override
  String lanCallFromNamed(String name) {
    return 'مكالمة LAN من $name';
  }

  @override
  String get lanCallFromUnpaired => 'مكالمة LAN من جهاز غير مقترن';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'مكالمة محوّلة من $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'مكالمة محوّلة من $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'جهاز آخر';

  @override
  String lanRelayedTitle(String name) {
    return 'مُمرَّرة إلى $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'المتصل يتحدث مع $name. أنت لست في المكالمة.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'جارٍ الاتصال بـ $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'يبقى المتصل متصلًا إلى أن يرد $name.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'جارٍ سؤال $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'في انتظار قبوله المكالمة.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'تتحدث مع $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'المتصل قيد الانتظار. أتمم التسليم عندما تكون جاهزًا.';

  @override
  String get lanRelayTakingBack => 'جارٍ استعادة المكالمة...';

  @override
  String get lanRelayTakeBack => 'استعادة';

  @override
  String get lanRelayEnd => 'إنهاء';

  @override
  String get lanSendToDevice => 'إرسال إلى جهاز';

  @override
  String get lanBusy => 'مشغول';

  @override
  String get lanNoPairedOnline => 'لا يوجد جهاز مقترن متصل';

  @override
  String lanPairRejectedBy(String name) {
    return 'رفض $name الاقتران.';
  }

  @override
  String get lanPairRejected => 'رُفض الاقتران.';

  @override
  String get lanPairCancelled => 'أُلغي الاقتران.';

  @override
  String get lanPairTimedOut => 'انتهت مهلة الاقتران. حاول مجددًا.';

  @override
  String get lanPairFailed => 'فشل الاقتران';

  @override
  String lanPairFailedReason(String reason) {
    return 'فشل الاقتران: $reason';
  }

  @override
  String get lanPairThisDevice => 'هذا الجهاز';

  @override
  String get lanPairConnecting => 'جارٍ الاتصال بأمان...';

  @override
  String lanPairWantsToPair(String name) {
    return 'يريد $name الاقتران بهذا الجهاز.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'الاقتران مع $name.';
  }

  @override
  String get lanPairCheckCode => 'تأكد من أن هذا الرمز هو نفسه على الشاشتين.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'رمز الاقتران $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'في انتظار تأكيد $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return 'أكّد $name.';
  }

  @override
  String get lanPairReject => 'رفض';

  @override
  String get lanPairCodesMatch => 'الرمزان متطابقان';

  @override
  String lanPairPairedWith(String name) {
    return 'تم الاقتران مع $name.';
  }

  @override
  String get lanPairRequestTitle => 'طلب اقتران';

  @override
  String lanPairTitle(String name) {
    return 'الاقتران مع $name';
  }

  @override
  String get lanActionDecline => 'رفض';

  @override
  String get lanActionAccept => 'قبول';

  @override
  String get lanFileIncomingTitle => 'ملف وارد';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size من $name';
  }

  @override
  String get lanHandoffOfferTitle => 'تحويل مكالمة إلى هنا؟';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' من $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' على $account',
    });
    return '$device يريد تسليمك مكالمة$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'سيتحدث معك أولًا.';

  @override
  String get lanHandoffTakeCall => 'تولّي المكالمة';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'السماح بالإنتركم من $name؟';
  }

  @override
  String get lanIntercomRequestBody =>
      'سيُردّ على مكالمته تلقائيًا عبر مكبّر الصوت.';

  @override
  String get lanIntercomDeny => 'منع';

  @override
  String get lanIntercomAllow => 'سماح';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return 'أزال $name هذا الجهاز من قائمة أجهزته المقترنة';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جارٍ إرسال $count ملف...',
      many: 'جارٍ إرسال $count ملفًا...',
      few: 'جارٍ إرسال $count ملفات...',
      two: 'جارٍ إرسال ملفين...',
      one: 'جارٍ إرسال $name...',
      zero: 'لا ملفات للإرسال',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'رسالة جديدة';

  @override
  String get lanSipMessage => 'رسالة SIP';

  @override
  String get lanSipMessageSub => 'إلى رقم أو عنوان عبر حسابك';

  @override
  String get lanChatOnline => 'دردشة LAN، متصل';

  @override
  String get lanChatOffline => 'دردشة LAN، غير متصل';

  @override
  String lanSavedAt(String path) {
    return 'حُفظ في $path (نُسخ المسار)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'أجهزتك تتحدث مباشرةً';

  @override
  String get lanConnectByAddress => 'الاتصال بالعنوان';

  @override
  String get lanSettingsTooltip => 'إعدادات LAN';

  @override
  String get lanOffTitle => 'LAN Link معطّل';

  @override
  String get lanOffSubtitle =>
      'اعثر على أجهزة SoftphonePro الأخرى لديك، وتراسل، وأسقط الملفات، وسلّم المكالمات، دون أي خادم.';

  @override
  String get lanTurnOn => 'تفعيل LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'تعذّر تشغيل LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'اكتب المضيف:المنفذ، أو الصق نص رمز QR المعروض على الجهاز الآخر.';

  @override
  String get lanScanTitle => 'مسح رمز QR لاقتران LAN';

  @override
  String get lanScanQr => 'مسح QR';

  @override
  String get lanPaste => 'لصق';

  @override
  String get lanConnect => 'اتصال';

  @override
  String lanConnectedTo(String name) {
    return 'تم الاتصال بـ $name';
  }

  @override
  String get lanCouldNotConnect => 'تعذّر الاتصال';

  @override
  String get lanCouldNotStartPairing => 'تعذّر بدء الاقتران';

  @override
  String get lanThisDevice => 'هذا الجهاز';

  @override
  String get lanDeviceNameTitle => 'اسم الجهاز';

  @override
  String get lanStarting => 'جارٍ البدء...';

  @override
  String get lanVisible => 'ظاهر على شبكتك';

  @override
  String get lanNotRunning => 'لا يعمل';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حساب مشترك',
      many: '$count حسابًا مشتركًا',
      few: '$count حسابات مشتركة',
      two: 'حسابان مشتركان',
      one: 'حساب واحد مشترك',
      zero: 'لا حسابات مشتركة',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'البصمة';

  @override
  String get lanHideQr => 'إخفاء رمز QR';

  @override
  String get lanShowQr => 'إظهار رمز QR لربط جهاز آخر';

  @override
  String get lanCopyConnectionText => 'نسخ نص الاتصال';

  @override
  String get lanConnectionTextCopied => 'نُسخ نص الاتصال';

  @override
  String get lanActiveOnOthers => 'نشطة على أجهزتك الأخرى';

  @override
  String get lanPairedDevices => 'الأجهزة المقترنة';

  @override
  String get lanNoPaired =>
      'لا أجهزة مقترنة بعد. اقرن جهازًا قريبًا للتراسل وإرسال الملفات وتسليم المكالمات.';

  @override
  String get lanNearby => 'القريبة';

  @override
  String get lanNearbyHint =>
      'جارٍ البحث عن SoftphonePro على شبكتك. يجب تفعيل LAN Link على الأجهزة الأخرى. يمكنك أيضًا الاتصال بالعنوان عبر زر الرابط أعلاه.';

  @override
  String get lanTransfers => 'عمليات النقل';

  @override
  String get lanFiles => 'الملفات';

  @override
  String get lanPairedBadge => 'مقترن';

  @override
  String get lanTyping => 'يكتب...';

  @override
  String get lanPair => 'اقتران';

  @override
  String get lanUnpair => 'إلغاء الاقتران';

  @override
  String lanUnpairTitle(String name) {
    return 'إلغاء الاقتران مع $name؟';
  }

  @override
  String get lanUnpairMessage =>
      'ستحتاج إلى الاقتران مجددًا للتراسل أو إرسال الملفات أو تسليم المكالمات.';

  @override
  String get lanActionMessage => 'رسالة';

  @override
  String get lanActionSendFile => 'إرسال ملف';

  @override
  String get lanActionCall => 'اتصال';

  @override
  String get lanActionIntercom => 'إنتركم';

  @override
  String lanRemoteActiveOn(String device) {
    return 'نشطة على $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'نشطة على $device  ·  $account';
  }

  @override
  String get lanPull => 'سحب';

  @override
  String get lanTransferPreparing => 'جارٍ التحضير...';

  @override
  String get lanTransferWaitingYou => 'في انتظارك';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'في انتظار قبول $name';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done من $total';
  }

  @override
  String get lanTransferVerifying => 'جارٍ التحقق...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'من $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'إلى $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  من $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  إلى $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get lanFileActions => 'إجراءات الملف';

  @override
  String get lanPathCopied => 'نُسخ المسار';

  @override
  String get lanFileOpen => 'فتح';

  @override
  String get lanFileShowInFolder => 'إظهار في المجلد';

  @override
  String get lanFileCopyPath => 'نسخ المسار';

  @override
  String lanNetworkError(String message) {
    return 'خطأ في الشبكة: $message';
  }

  @override
  String get lanErrNotRunning => 'فعّل LAN Link أولًا';

  @override
  String get lanErrBadAddress =>
      'أدخل عنوانًا مثل 192.168.1.20:4711 أو الصق نص رمز QR';

  @override
  String get lanErrFingerprint =>
      'ذلك الجهاز لا يطابق الرمز الممسوح. هل جاء رمز QR من جهاز آخر؟';

  @override
  String lanNoticeReceived(String file, String name) {
    return 'تم استلام $file من $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return 'تم إرسال $file إلى $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return 'رفض $name الملف $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'فشل نقل الملف: $error';
  }

  @override
  String get lanNoticeNeedLanOn => 'فعّل LAN Link للاتصال بالأجهزة القريبة';

  @override
  String get lanNoticePairFirst => 'اقرن هذا الجهاز أولًا';

  @override
  String lanNoticeNotReachable(String name) {
    return 'لا يمكن الوصول إلى $name للمكالمات حاليًا';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'جارٍ سؤال $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name لم يسمح بالإنتركم (أو لم يردّ)';
  }

  @override
  String get lanHoOff => 'LAN Link معطّل';

  @override
  String get lanHoPairFirst => 'اقرن ذلك الجهاز أولًا';

  @override
  String lanHoOffline(String name) {
    return '$name غير متصل';
  }

  @override
  String get lanHoAlready => 'هذه المكالمة قيد التسليم بالفعل';

  @override
  String get lanHoEnded => 'انتهت المكالمة بالفعل';

  @override
  String get lanHoWaitConnected => 'انتظر حتى تتصل المكالمة';

  @override
  String get lanHoLanCall => 'لا يمكن تسليم مكالمات LAN';

  @override
  String lanHoPeerNoLan(String name) {
    return 'لا يستطيع $name تلقي المكالمات عبر الشبكة (الاتصال عبر LAN معطّل هناك)';
  }

  @override
  String get lanHoNoLanHere => 'الاتصال عبر LAN غير متاح على هذا الجهاز';

  @override
  String lanHoDeclined(String name) {
    return 'رفض $name المكالمة. تبقى معك.';
  }

  @override
  String lanHoTimeout(String name) {
    return 'لم يستجب $name. تبقى المكالمة معك.';
  }

  @override
  String get lanHoCancelled => 'أُلغي التسليم. تبقى المكالمة معك.';

  @override
  String lanHoUnreachable(String name) {
    return 'تعذّر الوصول إلى $name. تبقى المكالمة معك.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'تعذّر الوصول إلى $name ($reason). تبقى المكالمة معك.';
  }

  @override
  String get lanHoEndedBefore => 'انتهت المكالمة قبل أن يمكن تسليمها';

  @override
  String lanHoPbxRefused(String name) {
    return 'رفض نظام الهاتف التحويل ولا يستطيع $name تلقي مكالمات LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'فشل التحويل عبر نظام الهاتف. جارٍ التمرير عبر الشبكة بدلًا من ذلك.';

  @override
  String lanHoSentTo(String name) {
    return 'أُرسلت المكالمة إلى $name';
  }

  @override
  String get lanHoConsultFailed =>
      'تعذّر الاتصال بالجهاز الآخر عبر نظام الهاتف';

  @override
  String lanHoNoLongerReachable(String name) {
    return 'لم يعد $name متاحًا';
  }

  @override
  String get lanHoCouldNotAnswer => 'تعذّر الرد على المكالمة لتسليمها';

  @override
  String lanHoCouldNotCall(String name) {
    return 'تعذّر الاتصال بـ $name عبر الشبكة. تبقى المكالمة معك.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return 'لم يردّ $name. تبقى المكالمة معك.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'سُلّمت إلى $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'مُمرَّرة المكالمة إلى $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'انتظر ردّ $name أولًا';
  }

  @override
  String get lanHoFailed => 'فشل التسليم';

  @override
  String lanHoTakenBack(String name) {
    return 'استُعيدت المكالمة من $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return 'أنهى $name الاستشارة. عادت المكالمة إليك.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'تعذّر تسليم المكالمة إلى $name';
  }

  @override
  String get diagSip400Explain => 'تعذّر على الخادم فهم الطلب.';

  @override
  String get diagSip400Fix =>
      'تحقق من إعدادات الحساب (النطاق واسم المستخدم والوكيل). إذا استمرت المشكلة فأرسل تتبع SIP إلى مزوّدك.';

  @override
  String get diagSip401Explain => 'رفض الخادم بيانات الاعتماد (أو يطلبها).';

  @override
  String get diagSip401Fix =>
      'تحقق من اسم المستخدم واسم مستخدم المصادقة وكلمة المرور. بعض المزوّدين يستخدمون \"auth ID\" منفصلًا.';

  @override
  String get diagSip403Explain =>
      'فهم الخادم الطلب لكنه يرفضه: كلمة مرور خاطئة، أو حساب معطّل، أو عنوان IP الخاص بك غير مسموح.';

  @override
  String get diagSip403Fix =>
      'أعد إدخال كلمة المرور، وتأكد من أن الحساب نشط، وتحقق من أن عنوان IP العام الخاص بك غير محظور (fail2ban/ACL).';

  @override
  String get diagSip404Explain => 'الخادم لا يعرف هذا المستخدم أو الرقم.';

  @override
  String get diagSip404Fix =>
      'تحقق من اسم المستخدم والنطاق؛ وللمكالمات تحقق من الرقم المطلوب وقواعد الطلب.';

  @override
  String get diagSip405Explain => 'الخادم لا يدعم هذا الطلب.';

  @override
  String get diagSip405Fix =>
      'غالبًا غير ضار لفحوصات OPTIONS. أما لـ REGISTER فتأكد من أنك تتحدث إلى خادم تسجيل SIP.';

  @override
  String get diagSip407Explain => 'يحتاج وكيل الصادر إلى بيانات اعتماد.';

  @override
  String get diagSip407Fix => 'تحقق من كلمة مرور الحساب وإعدادات وكيل الصادر.';

  @override
  String get diagSip408Explain => 'لا ردّ من الخادم في الوقت المحدد.';

  @override
  String get diagSip408Fix =>
      'تحقق من عنوان الخادم ومنفذه والجدران النارية، وجرّب TCP أو TLS. تكرار انتهاء المهلة على UDP فقط قد يشير إلى SIP ALG في الموجّه.';

  @override
  String get diagSip410Explain => 'الرقم لم يعد موجودًا.';

  @override
  String get diagSip410Fix => 'تحقق من الرقم المطلوب.';

  @override
  String get diagSip415Explain =>
      'الطرف الآخر لا يقبل نوع المحتوى أو الترميزات المعروضة.';

  @override
  String get diagSip415Fix =>
      'فعّل المزيد من الترميزات (مثل PCMU/PCMA) في الإعدادات > الترميزات.';

  @override
  String get diagSip421Explain =>
      'يتطلب الخادم امتداد SIP لم يعرضه هذا العميل.';

  @override
  String get diagSip421Fix => 'تحقق من خيارات NAT/ICE/100rel/المؤقتات للحساب.';

  @override
  String get diagSip423Explain => 'مدة انتهاء التسجيل أقصر مما يسمح به الخادم.';

  @override
  String get diagSip423Fix => 'زِد مدة انتهاء التسجيل في إعدادات الحساب.';

  @override
  String get diagSip480Explain =>
      'المستخدم غير مسجّل أو لا يمكن الوصول إليه حاليًا.';

  @override
  String get diagSip480Fix =>
      'تحقق من أن الطرف الآخر مسجّل؛ وعند التسجيل قد يكون الخادم مثقلًا: أعد المحاولة لاحقًا.';

  @override
  String get diagSip481Explain =>
      'فقد الخادم حالة الحوار (مثلًا بعد إعادة تشغيل أو تغيّر في الشبكة).';

  @override
  String get diagSip481Fix =>
      'أنهِ المكالمة وأعد المحاولة. إن تكرر ذلك ففعّل مؤقتات الجلسة.';

  @override
  String get diagSip483Explain => 'دار الطلب في حلقة بين الخوادم.';

  @override
  String get diagSip483Fix => 'تحقق من إعدادات إعادة التوجيه والتوجيه في PBX.';

  @override
  String get diagSip484Explain => 'الرقم المطلوب قصير جدًا.';

  @override
  String get diagSip484Fix => 'اطلب الرقم كاملًا أو تحقق من قواعد الطلب.';

  @override
  String get diagSip486Explain => 'الطرف الآخر مشغول.';

  @override
  String get diagSip486Fix => 'حاول مجددًا لاحقًا.';

  @override
  String get diagSip487Explain => 'أُلغيت المكالمة قبل الرد عليها.';

  @override
  String get diagSip487Fix =>
      'أمر طبيعي عندما ينهي المتصل المكالمة أثناء الرنين.';

  @override
  String get diagSip488Explain =>
      'لا يوجد ترميز أو إعداد تشفير مشترك مع الطرف الآخر.';

  @override
  String get diagSip488Fix =>
      'تحقق من الترميزات وSRTP (لا يمكن لحساب يشترط SRTP أن يتصل بنقطة نهاية RTP عادية).';

  @override
  String get diagSip491Explain => 'تعارض اثنان من re-INVITE.';

  @override
  String get diagSip491Fix => 'تُعاد المحاولة عادةً تلقائيًا.';

  @override
  String get diagSip500Explain => 'حدث عطل داخلي في الخادم.';

  @override
  String get diagSip500Fix =>
      'أعد المحاولة لاحقًا واتصل بالمزوّد إن استمرت المشكلة.';

  @override
  String get diagSip502Explain => 'أعاد خادم أعلى ردًا غير صالح.';

  @override
  String get diagSip502Fix =>
      'أعد المحاولة لاحقًا؛ واتصل بالمزوّد إن استمرت المشكلة.';

  @override
  String get diagSip503Explain =>
      'الخادم مثقل أو متوقف أو يرفض هذا العميل (حد المعدل).';

  @override
  String get diagSip503Fix =>
      'انتظر ثم أعد المحاولة، أو راجع صفحة حالة المزوّد، أو جرّب خادمًا/منفذًا آخر.';

  @override
  String get diagSip504Explain => 'لم يردّ خادم أعلى في الوقت المحدد.';

  @override
  String get diagSip504Fix => 'أعد المحاولة لاحقًا.';

  @override
  String get diagSip600Explain => 'جميع الوجهات مشغولة.';

  @override
  String get diagSip600Fix => 'حاول مجددًا لاحقًا.';

  @override
  String get diagSip603Explain => 'رفض الطرف الآخر المكالمة.';

  @override
  String get diagSip603Fix => 'لا شيء لإصلاحه: رُفضت المكالمة.';

  @override
  String get diagSip604Explain => 'الرقم غير موجود.';

  @override
  String get diagSip604Fix => 'تحقق من الرقم المطلوب.';

  @override
  String get diagSip606Explain =>
      'لا يستطيع الطرف الآخر قبول الجلسة كما عُرضت.';

  @override
  String get diagSip606Fix => 'تحقق من إعدادات الترميزات والتشفير.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'مؤقت ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'الطلب قيد المعالجة.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'نجاح ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'نجح الطلب.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'إعادة توجيه ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'انتقلت الوجهة.';

  @override
  String get diagSipRedirectedFix => 'تحقق من إعدادات إعادة التوجيه.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'خطأ في العميل ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'رفض الخادم الطلب.';

  @override
  String get diagSipClientErrorFix => 'تحقق من الحساب والرقم المطلوب.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'خطأ في الخادم ($code)';
  }

  @override
  String get diagSipServerErrorExplain => 'فشل الخادم في معالجة الطلب.';

  @override
  String get diagSipServerErrorFix => 'أعد المحاولة لاحقًا أو اتصل بالمزوّد.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'فشل شامل ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain => 'لا يمكن تلبية الطلب في أي مكان.';

  @override
  String get diagSipNoResponseTitle => 'لا استجابة';

  @override
  String get diagSipNoResponseExplain => 'لم يُستلم أي ردّ SIP.';

  @override
  String get diagSipNoResponseFix => 'تحقق من اتصال الشبكة وعنوان الخادم.';

  @override
  String get diagWizStepNet => 'اتصال الشبكة';

  @override
  String diagWizStepDns(String account) {
    return 'DNS وSRV: $account';
  }

  @override
  String get diagWizStepNat => 'نوع NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'إمكانية الوصول إلى الخادم: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'شهادة TLS: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'التسجيل: $account';
  }

  @override
  String get diagWizStepAlg => 'فحص SIP ALG';

  @override
  String get diagWizChecking => 'جارٍ الفحص...';

  @override
  String diagWizEngineError(String message) {
    return 'خطأ في المحرك: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'فشل الفحص: $error';
  }

  @override
  String get diagWizNoEngine => 'محرك SIP لا يعمل';

  @override
  String get diagWizNoEngineFix =>
      'انتظر حتى يبدأ المحرك (أو أعد تشغيل التطبيق)، ثم شغّل الفحوصات مجددًا.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (خاص)';
  }

  @override
  String get diagWizNetNone => 'لا توجد واجهة شبكة نشطة بعنوان IP';

  @override
  String get diagWizNetNoneFix =>
      'اتصل بشبكة Wi-Fi أو Ethernet أو بيانات الجوال، ثم شغّل الفحوصات مجددًا.';

  @override
  String get diagWizNetIpv6Only => 'عُثر على عناوين IPv6 فقط';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'كثير من مزوّدي SIP يدعمون IPv4 فقط. فعّل IPv4 على هذه الشبكة أو استخدم مزوّدًا يدعم IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 عنوان IPv4',
      many: '$v4 عنوان IPv4',
      few: '$v4 عناوين IPv4',
      two: 'عنوانا IPv4',
      one: 'عنوان IPv4 واحد',
      zero: 'لا عناوين IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces واجهة',
      many: '$ifaces واجهة',
      few: '$ifaces واجهات',
      two: 'واجهتين',
      one: 'واجهة واحدة',
      zero: 'لا واجهات',
    );
    return '$_temp0 على $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'واجهة من نوع VPN نشطة. قد تضيف شبكات VPN تأخيرًا أو تحجب UDP؛ عطّلها إذا ساءت المكالمات.';

  @override
  String get diagWizDnsNoServer => 'الحساب بلا عنوان خادم';

  @override
  String get diagWizDnsNoServerFix => 'عدّل الحساب وأدخل نطاق SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host عنوان IP، لا حاجة إلى DNS';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: لا شيء';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: لا شيء ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: لا شيء';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (الأولوية $priority، الوزن $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: فشل البحث ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return 'تعذّر تحليل $host';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'تحقق من النطاق بحثًا عن أخطاء إملائية، ومن عمل خادم DNS لديك. يمكنك تعيين خادم DNS مخصص في الإعدادات > الشبكة (مثل 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host له سجلات SRV لكن بلا سجل عنوان';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'ستُستخدم أهداف SRV. إذا فشلت المكالمات فاطلب من المزوّد التحقق من سجل A.';

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
      other: '، $srv سجل SRV',
      many: '، $srv سجل SRV',
      few: '، $srv سجلات SRV',
      two: '، سجلا SRV',
      one: '، سجل SRV واحد',
      zero: '',
    );
    return '$host يُحلَّل إلى $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'انتهت مهلة اكتشاف NAT';

  @override
  String get diagWizNatTimeoutFix =>
      'قد يكون خادم STUN غير متاح (UDP محجوب؟). تحقق من الإعدادات > الشبكة > خوادم STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'خادم STUN: $server';
  }

  @override
  String get diagWizNatOpen => 'بلا NAT: لهذا الجهاز عنوان عام';

  @override
  String get diagWizNatFullCone => 'NAT مخروطي كامل: ملائم لـ VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT مخروطي مقيّد: يعمل مع STUN وإبقاء الاتصال';

  @override
  String get diagWizNatPortRestricted =>
      'NAT مخروطي مقيّد المنفذ: يعمل مع STUN وإبقاء الاتصال';

  @override
  String get diagWizNatSymmetric =>
      'NAT متماثل: لا يستطيع STUN وحده التنبؤ بمنفذ الوسائط';

  @override
  String get diagWizNatSymmetricFix =>
      'يُرجَّح حدوث صوت أحادي الاتجاه أو انعدام الصوت في بعض المكالمات. فعّل ICE ومرحّل TURN في إعدادات الحساب (الحساب > NAT)، أو استخدم مزوّدًا/PBX مع ترحيل وسائط (rtpengine).';

  @override
  String get diagWizNatBlocked => 'يبدو أن UDP محجوب';

  @override
  String get diagWizNatBlockedFix =>
      'استخدم نقل TCP أو TLS للحساب. إذا كانت الشبكة تحجب كل شيء عدا حركة الويب فجرّب TLS على المنفذ 443 إن كان مزوّدك يدعمه.';

  @override
  String get diagWizNatUnknown => 'تعذّر تحديد نوع NAT';

  @override
  String get diagWizNatUnknownFix =>
      'لم يردّ خادم STUN. جرّب خادم STUN آخر في الإعدادات > الشبكة.';

  @override
  String get diagWizNatErr => 'لم يردّ خادم STUN، لذا تعذّر تحديد نوع NAT.';

  @override
  String get diagWizNatUnknownRaw => 'تعذّر تحديد نوع NAT.';

  @override
  String get diagWizOptionsNotLoaded => 'الحساب غير محمّل في المحرك';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'لا ردّ على OPTIONS خلال $seconds ث (النقل: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'لا يمكن الوصول إلى الخادم. تحقق من العنوان والمنفذ، ومن أن جدارًا ناريًا لا يُسقط SIP، وجرّب وسيلة نقل أخرى (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'انتهت مهلة الطلب ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'ردّ الخادم $code $reason بعد $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'ردّ الخادم $code $reason خلال $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'الرد $code على OPTIONS أمر طبيعي: الخادم متاح لكنه لا يسمح بالفحوص المجهولة.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'زمن الذهاب والإياب الأعلى من 300 ms يضيف تأخيرًا ملحوظًا للمحادثات. خادم أقرب أو اتصال سلكي يساعد.';

  @override
  String get diagWizTlsRejected => 'رُفضت شهادة الخادم';

  @override
  String diagWizTlsSubject(String value) {
    return 'الموضوع: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'المُصدِر: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'المشكلات: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'تنتهي: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'التشفير: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'إذا كان هذا PBX خاصًا بك بشهادة موقّعة ذاتيًا وتطابقت البصمة أعلاه فيمكنك الوثوق بها. وإلا فاطلب من المزوّد شهادة من CA عامة.';

  @override
  String get diagWizTlsTrust => 'الوثوق بهذه الشهادة';

  @override
  String diagWizTlsExpired(String date) {
    return 'انتهت صلاحية الشهادة في $date';
  }

  @override
  String get diagWizTlsExpiredFix => 'اطلب من مسؤول الخادم تجديد الشهادة.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'تنتهي الشهادة خلال $days يوم',
      many: 'تنتهي الشهادة خلال $days يومًا',
      few: 'تنتهي الشهادة خلال $days أيام',
      two: 'تنتهي الشهادة خلال يومين',
      one: 'تنتهي الشهادة خلال يوم واحد',
      zero: 'تنتهي الشهادة اليوم',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix => 'أخبر مسؤول الخادم بتجديدها قريبًا.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'تم الاتصال، لكن التحقق أبلغ عن: $problems';
  }

  @override
  String get diagWizTlsOk => 'تم إنشاء اتصال TLS، والشهادة صالحة';

  @override
  String get diagWizTlsRegistered =>
      'تم التسجيل عبر TLS (دون تفاصيل عن الشهادة)';

  @override
  String get diagWizTlsNone => 'لم يُرصد أي اتصال TLS بعد';

  @override
  String get diagWizTlsNoneFix =>
      'تحقق من منفذ TLS (عادةً 5061) ومن أن الخادم يقبل TLS 1.2 أو أحدث.';

  @override
  String get diagWizRegDisabledByConfig =>
      'التسجيل معطّل لهذا الحساب (استخدام نظير إلى نظير)';

  @override
  String get diagWizRegRegistered => 'مسجّل';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'مسجّل (ينتهي خلال $seconds ث)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'النقل: $transport';
  }

  @override
  String get diagWizRegInProgress => 'التسجيل ما زال جاريًا';

  @override
  String get diagWizRegInProgressFix =>
      'انتظر بضع ثوانٍ. إذا لم يكتمل أبدًا فالخادم لا يردّ؛ راجع فحص إمكانية الوصول أعلاه.';

  @override
  String get diagWizRegFailed => 'فشل التسجيل';

  @override
  String get diagWizRegOffline => 'الحساب غير متصل';

  @override
  String get diagWizRegOfflineFix =>
      'تحقق من اتصال الشبكة. يعيد التطبيق المحاولة تلقائيًا.';

  @override
  String get diagWizRegDisabled => 'الحساب معطّل';

  @override
  String get diagWizAlgNoUdp =>
      'لا يستخدم أي حساب UDP، فلا داعي للقلق من SIP ALG';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: لا ردّ عبر UDP، لكن TCP ردّ ($code، $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: لا ردّ عبر UDP أو TCP (مشكلة في الخادم أو الجدار الناري وليست ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: يُردّ على OPTIONS لكن REGISTER تنتهي مهلته، وهذا نمطي لموجّه يعيد كتابة SIP';
  }

  @override
  String get diagWizAlgSuspected => 'يُشتبه بوجود SIP ALG في الموجّه';

  @override
  String get diagWizAlgSuspectedFix =>
      'عطّل \"SIP ALG\" / \"SIP helper\" في إعدادات الموجّه، أو حوّل الحساب إلى TCP أو TLS، أو غيّر منفذ SIP (مثل 5080) كي يتوقف الموجّه عن العبث بالحزم.';

  @override
  String get diagWizAlgContactChanged => 'تغيّر عنوان Contact بين الطلب والرد';

  @override
  String get diagWizAlgContactChangedFix =>
      'قد يكون السبب SIP ALG أو خادمًا يعيد كتابة جهات الاتصال. إذا كانت المكالمات ترنّ لكن بلا صوت أو تنقطع بعد فترة، فعطّل SIP ALG في الموجّه أو استخدم TCP/TLS أو المنفذ 5080.';

  @override
  String get diagWizAlgOk => 'لا مؤشر على تدخل SIP ALG';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'عنوان Contact في REGISTER $sent عاد بصيغة $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'حفظ $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return 'تم حفظ $fileName';
  }

  @override
  String get diagSaveFailed => 'تعذّر حفظ الملف';

  @override
  String get diagCopiedText => 'نُسخ النص إلى الحافظة';

  @override
  String get diagCopiedReport => 'نُسخ التقرير إلى الحافظة';

  @override
  String get diagCopiedBundle => 'نُسخت حزمة التشخيص إلى الحافظة';

  @override
  String get diagCopiedLogs => 'نُسخت السجلات إلى الحافظة';

  @override
  String get diagCopiedTrace => 'نُسخ التتبع إلى الحافظة';

  @override
  String get diagCopiedDialog => 'نُسخ الحوار إلى الحافظة';

  @override
  String get diagSaveAsLog => 'حفظ بصيغة .log';

  @override
  String get diagSysAppVersion => 'إصدار التطبيق';

  @override
  String get diagSysPlatform => 'المنصة';

  @override
  String get diagSysEngine => 'المحرك';

  @override
  String get diagSysAccounts => 'الحسابات';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered من $total مسجّلة';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'تعذّرت قراءة معلومات النظام: $error';
  }

  @override
  String get diagSysTransports => 'النقل';

  @override
  String get diagSysNoneReported => 'لا شيء مُبلَّغ عنه';

  @override
  String get diagSysCodecs => 'الترميزات';

  @override
  String get diagSysCodecsFooter => 'الترميزات المفعّلة، الأعلى أولوية أولًا.';

  @override
  String get diagSysEngineNotRunning => 'المحرك لا يعمل';

  @override
  String diagSysCodecPriority(int priority) {
    return 'الأولوية $priority';
  }

  @override
  String get diagSysCodecDisabled => 'معطّل';

  @override
  String get diagSysExport => 'تصدير';

  @override
  String get diagSysExportFooter =>
      'تحتوي الحزمة على معلومات النظام ونتائج فحص الشبكة وأحدث السجلات وتتبع SIP، مع حجب بيانات الاعتماد.';

  @override
  String get diagSysCopyBundle => 'نسخ حزمة التشخيص';

  @override
  String get diagSysSaveBundle => 'حفظ حزمة التشخيص';

  @override
  String get diagTabSipTrace => 'تتبع SIP';

  @override
  String get diagTabNetwork => 'الشبكة';

  @override
  String get diagTabQuality => 'الجودة';

  @override
  String get diagTabAudioTest => 'اختبار الصوت';

  @override
  String get diagTabLogs => 'السجلات';

  @override
  String get diagTabSystem => 'النظام';

  @override
  String diagRawSentTo(String remote) {
    return 'أُرسلت إلى $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'استُلمت من $remote';
  }

  @override
  String get diagRawCopied => 'نُسخت الرسالة';

  @override
  String get diagRawLadder => 'مخطط تسلسلي';

  @override
  String get diagRawRedact => 'حجب بيانات الاعتماد';

  @override
  String diagRawTruncated(int count) {
    return '... اقتُطع ($count حرفًا)';
  }

  @override
  String get diagWizIntro =>
      'يفحص اتصالك وDNS وNAT وإمكانية الوصول إلى الخادم وTLS والتسجيل، ويشرح ما ينبغي إصلاحه.';

  @override
  String get diagWizStop => 'إيقاف';

  @override
  String get diagWizRunChecks => 'تشغيل الفحوصات';

  @override
  String get diagWizRunAgain => 'تشغيل مجددًا';

  @override
  String get diagWizCopyReport => 'نسخ التقرير';

  @override
  String get diagWizSaveReport => 'حفظ التقرير';

  @override
  String diagWizCountPassed(int count) {
    return 'نجح $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'تحذيرات $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'فشل $count';
  }

  @override
  String get diagWizStatusPass => 'نجح';

  @override
  String get diagWizStatusWarn => 'تحذير';

  @override
  String get diagWizStatusFail => 'فشل';

  @override
  String get diagWizStatusSkipped => 'تم تخطّيه';

  @override
  String get diagWizStatusRunning => 'قيد التشغيل';

  @override
  String get diagWizStatusPending => 'قيد الانتظار';

  @override
  String get diagQualityTitle => 'جودة المكالمة';

  @override
  String get diagQualityNoData => 'لم تُسجَّل بيانات جودة لهذه المكالمة.';

  @override
  String get diagQualityTraceForCall => 'تتبع SIP لهذه المكالمة';

  @override
  String get diagQualityTraceNotCaptured => 'لم يُلتقط تتبع SIP لهذه المكالمة';

  @override
  String get diagQualityLiveCall => 'المكالمة المباشرة';

  @override
  String get diagQualityNoActiveCall =>
      'لا مكالمة نشطة. ابدأ مكالمة وسيُرسم هنا MOS والارتجاف والفقد وزمن الذهاب والإياب مباشرةً.';

  @override
  String get diagQualityRecentCalls => 'المكالمات الأخيرة';

  @override
  String get diagQualityNoFinished => 'لا مكالمات منتهية ببيانات جودة بعد.';

  @override
  String get diagQualityCallEnded => 'انتهت المكالمة.';

  @override
  String get diagQualityMeasuring => 'جارٍ القياس';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value، $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'مخطط $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'مخطط $title، الأحدث $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   الأقصى $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'المتوسط $avg  ·  الأسوأ $worst';
  }

  @override
  String get diagQualityCodec => 'الترميز';

  @override
  String get diagQualityLoss => 'الفقد';

  @override
  String get diagQualityJitter => 'الارتجاف';

  @override
  String diagQualityPackets(int count) {
    return '$count حزمة';
  }

  @override
  String get diagQualityMedia => 'الوسائط';

  @override
  String get diagQualityNoSeries => 'لم تُسجَّل سلسلة زمنية لهذه المكالمة.';

  @override
  String get diagQualityPacketLoss => 'فقدان الحزم';

  @override
  String get diagQualityRtt => 'زمن الذهاب والإياب';

  @override
  String get diagLogsForward => 'تمرير سجلات المحرك';

  @override
  String get diagLogsForwardSub => 'إرسال أسطر سجل pjsip إلى هذا العارض';

  @override
  String diagLogsLevel(int level, String name) {
    return 'المستوى $level ($name)';
  }

  @override
  String get diagLogsRedact => 'حجب عند التصدير';

  @override
  String get diagLogsSearch => 'بحث في السجلات';

  @override
  String get diagLogsEmpty => 'لا أسطر في السجل بعد.';

  @override
  String get diagLogsForwardingOff =>
      'تمرير السجلات معطّل. فعّله لالتقاط سجلات المحرك.';

  @override
  String get diagLogsNoMatch => 'لا أسطر تطابق البحث.';

  @override
  String get diagAudioEngineNotRunning => 'محرك SIP لا يعمل.';

  @override
  String get diagAudioMicrophone => 'الميكروفون';

  @override
  String get diagAudioMicFooter =>
      'يقرأ مقياس المستوى جهاز الصوت، الذي يفتحه المحرك أثناء المكالمة أو اختبار الصدى.';

  @override
  String get diagAudioLevelMeter => 'مقياس المستوى';

  @override
  String get diagAudioLevelMeterSub => 'تحدّث وراقب حركة الشريط';

  @override
  String get diagAudioMic => 'الميكروفون';

  @override
  String get diagAudioSpeaker => 'مكبّر الصوت';

  @override
  String get diagAudioEchoTest => 'اختبار الصدى';

  @override
  String get diagAudioEchoFooter =>
      'يعيد تشغيل صوتك عبر مكبّر الصوت. استخدم سماعات الرأس لتجنب الصفير.';

  @override
  String get diagAudioEchoActive => 'نشط: تحدّث الآن';

  @override
  String get diagAudioEchoIdle => 'حلقة من الميكروفون إلى مكبّر الصوت';

  @override
  String get diagAudioSpeakerTest => 'اختبار مكبّر الصوت';

  @override
  String get diagAudioPlayTone => 'تشغيل نغمة اختبار';

  @override
  String get diagAudioPlayToneSub => 'تُشغَّل عبر مكبّر الصوت المحدد';

  @override
  String get diagAudioPlayingDtmf => 'جارٍ تشغيل DTMF';

  @override
  String get diagAudioPlayingRingback => 'جارٍ تشغيل نغمة الرنين المرتد';

  @override
  String get diagAudioRingback => 'الرنين المرتد';

  @override
  String get diagAudioDevices => 'الأجهزة';

  @override
  String get diagAudioChooseDevices => 'اختر الميكروفون ومكبّر الصوت';

  @override
  String get diagAudioChooseDevicesSub => 'يفتح الإعدادات > الصوت';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'مستوى $label $percent بالمئة';
  }

  @override
  String get diagLadderLocal => 'محلي';

  @override
  String diagLadderSent(String message) {
    return 'أُرسلت $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'استُلمت $message';
  }

  @override
  String get diagTraceCapture => 'التقاط رسائل SIP';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة',
      many: '$count رسالة',
      few: '$count رسائل',
      two: 'رسالتان',
      one: 'رسالة واحدة',
      zero: 'لا رسائل',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة',
      many: '$count رسالة',
      few: '$count رسائل',
      two: 'رسالتان',
      one: 'رسالة واحدة',
      zero: 'لا رسائل',
    );
    return '$_temp0  ·  $size  ·  أُسقطت $dropped أقدم';
  }

  @override
  String get diagTraceOffHint => 'معطّل. فعّله ثم سجّل أو أجرِ مكالمة.';

  @override
  String get diagTraceExportOrClear => 'تصدير أو مسح';

  @override
  String get diagTraceSaveAsPcap => 'حفظ بصيغة .pcap';

  @override
  String get diagTraceCopyAsText => 'نسخ كنص';

  @override
  String get diagTraceSearchHint => 'ابحث بنص أو رقم أو Call-ID';

  @override
  String get diagTraceErrorsOnly => 'الأخطاء فقط';

  @override
  String get diagTraceFilterMethod => 'التصفية حسب الطريقة';

  @override
  String get diagTraceAllMethods => 'كل الطرق';

  @override
  String get diagTraceMethod => 'الطريقة';

  @override
  String get diagTraceFilterAccount => 'التصفية حسب الحساب';

  @override
  String get diagTraceAllAccounts => 'كل الحسابات';

  @override
  String get diagTraceAccount => 'الحساب';

  @override
  String get diagTraceRedact => 'حجب';

  @override
  String get diagTraceList => 'قائمة';

  @override
  String get diagTraceWaiting => 'في انتظار حركة SIP';

  @override
  String get diagTraceWaitingSub =>
      'سجّل حسابًا أو أجرِ مكالمة وستظهر الرسائل هنا.';

  @override
  String get diagTraceOff => 'تتبع SIP معطّل';

  @override
  String get diagTraceOffSub =>
      'فعّل الالتقاط لرؤية كل طلب وردّ SIP، كقائمة أو كمخطط تسلسلي.';

  @override
  String get diagTraceNoMatch => 'لا رسائل تطابق عوامل التصفية';

  @override
  String get diagTraceAllDialogs => 'كل الحوارات';

  @override
  String get diagTraceCopyDialog => 'نسخ هذا الحوار';

  @override
  String get diagTraceNoResponse => 'لا ردّ';

  @override
  String get diagTraceNoCallId => 'بلا Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة',
      many: '$count رسالة',
      few: '$count رسائل',
      two: 'رسالتان',
      one: 'رسالة واحدة',
      zero: 'لا رسائل',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'تسجيل';

  @override
  String get recFormatWav => 'قياسي (WAV)';

  @override
  String get recFormatWavStereo =>
      'ستيريو، أنت والمتصل على قناتين منفصلتين (WAV)';

  @override
  String get recFormatOpus => 'مضغوط (Opus)';

  @override
  String get recFormatWavHint =>
      'أحادي، نحو 2 ميغابايت في الدقيقة. يعمل في كل مكان.';

  @override
  String get recFormatWavStereoHint =>
      'قناتان، نحو 4 ميغابايت في الدقيقة. أنت على اليسار والمتصل على اليمين.';

  @override
  String get recFormatOpusHint =>
      'نحو 0.2 ميغابايت في الدقيقة. Ogg Opus؛ بعض المشغلات على iPhone وMac وWindows لا تستطيع فتحه.';

  @override
  String get recOptionInherit => 'استخدام الإعداد العام';

  @override
  String get recOptionAlways => 'تسجيل كل المكالمات';

  @override
  String get recOptionIncoming => 'تسجيل المكالمات الواردة فقط';

  @override
  String get recOptionOutgoing => 'تسجيل المكالمات الصادرة فقط';

  @override
  String get recOptionNever => 'عدم التسجيل أبدًا';

  @override
  String get recRuleAll => 'كل المكالمات';

  @override
  String get recRuleIncoming => 'المكالمات الواردة فقط';

  @override
  String get recRuleOutgoing => 'المكالمات الصادرة فقط';

  @override
  String get recAutoDeleteNever => 'أبدًا';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بعد $days يوم',
      many: 'بعد $days يومًا',
      few: 'بعد $days أيام',
      two: 'بعد يومين',
      one: 'بعد يوم واحد',
      zero: 'بعد 0 يوم',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'بعد سنة واحدة';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل',
      many: '$count تسجيلًا',
      few: '$count تسجيلات',
      two: 'تسجيلان',
      one: 'تسجيل واحد',
      zero: 'لا تسجيلات',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل',
      many: '$count تسجيلًا',
      few: '$count تسجيلات',
      two: 'تسجيلان',
      one: 'تسجيل واحد',
      zero: 'لا تسجيلات',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل',
      many: '$count تسجيلًا',
      few: '$count تسجيلات',
      two: 'تسجيلان',
      one: 'تسجيل واحد',
      zero: 'لا تسجيلات',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days يوم',
      many: '$days يومًا',
      few: '$days أيام',
      two: 'يومين',
      one: 'يوم واحد',
      zero: '0 يوم',
    );
    return '$_temp0  ·  $size  ·  حذف تلقائي بعد $_temp1';
  }

  @override
  String get recSettingsFormat => 'الصيغة';

  @override
  String get recSettingsAutoGroup => 'التسجيل التلقائي';

  @override
  String get recSettingsAutoFooter =>
      'راجع القوانين المحلية قبل تسجيل المكالمات. فعّل \"تسجيل المكالمات مع جهة الاتصال هذه دائمًا\" في جهة اتصال لتسجيل مكالماتها مهما قالت هذه القواعد.';

  @override
  String get recSettingsAutoRule => 'تسجيل المكالمات تلقائيًا';

  @override
  String get recSettingsAccountOverride => 'تجاوز لهذا الحساب';

  @override
  String get recSettingsNoticesGroup => 'الإشعارات';

  @override
  String get recSettingsNoticeSwitch => 'تشغيل إشعار قبل التسجيل';

  @override
  String get recSettingsNoticeSwitchHint =>
      'يشغّل إشعارًا للطرف الآخر أولًا. يُختار ملف الإشعار في الإعدادات > المكالمات > الإعلانات.';

  @override
  String get recSettingsNoticeFile => 'اختر ملف الإشعار';

  @override
  String get recSettingsNoticeFileHint =>
      'يفتح الإعدادات > المكالمات > الإعلانات';

  @override
  String get recSettingsBeep => 'صفير التسجيل';

  @override
  String get recSettingsBeepHint => 'تنبيه الطرف الآخر بشكل دوري';

  @override
  String get recSettingsTransfersGroup => 'التحويلات';

  @override
  String get recSettingsContinue => 'متابعة التسجيل عبر التحويلات';

  @override
  String get recSettingsContinueHint =>
      'تسجيل مكالمة الاستشارة في التحويل بالاستشارة والمكالمة المحوّلة إلينا، وربط التسجيلات';

  @override
  String get recSettingsStorageGroup => 'التخزين';

  @override
  String get recSettingsFolder => 'المجلد';

  @override
  String get recSettingsFolderHint => 'مكان حفظ التسجيلات';

  @override
  String get recSettingsFolderPlaceholder => 'مستندات التطبيق / التسجيلات';

  @override
  String get recSettingsChooseFolder => 'اختيار مجلد...';

  @override
  String get recSettingsFolderPickerTitle => 'مجلد التسجيلات';

  @override
  String get recSettingsAutoDelete => 'حذف التسجيلات القديمة';

  @override
  String get recSettingsAutoDeleteHint => 'يُفحص عند التشغيل ومرة كل يوم';

  @override
  String get recSettingsManage => 'إدارة التسجيلات';

  @override
  String get recSettingsOpenFolder => 'فتح مجلد التسجيلات';

  @override
  String get recPageTitle => 'التسجيلات';

  @override
  String recSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get recCancelSelection => 'إلغاء التحديد';

  @override
  String get recSelectAll => 'تحديد الكل';

  @override
  String get recShareSelected => 'مشاركة المحدد';

  @override
  String get recDeleteSelected => 'حذف المحدد';

  @override
  String get recSearchTooltip => 'بحث في التسجيلات';

  @override
  String get recSelectTooltip => 'تحديد التسجيلات';

  @override
  String get recMenuSettings => 'إعدادات التسجيل';

  @override
  String get recSearchHint => 'ابحث بالاسم أو الرقم';

  @override
  String get recEmptyNone => 'لا تسجيلات بعد';

  @override
  String get recEmptyNoneHint =>
      'سجّل مكالمة بزر التسجيل، أو فعّل التسجيل التلقائي من الإعدادات.';

  @override
  String get recEmptyNoMatch => 'لا تسجيلات مطابقة';

  @override
  String get recEmptyNoMatchHint => 'جرّب بحثًا أو مرشحًا آخر.';

  @override
  String get recClearFilters => 'مسح المرشحات';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف $count تسجيل؟',
      many: 'حذف $count تسجيلًا؟',
      few: 'حذف $count تسجيلات؟',
      two: 'حذف تسجيلين؟',
      one: 'حذف تسجيل واحد؟',
      zero: 'حذف 0 تسجيل؟',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'ستُزال الملفات الصوتية من هذا الجهاز. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get recDeleteOneTitle => 'حذف هذا التسجيل؟';

  @override
  String get recDeleteOneMessage =>
      'سيُزال الملف الصوتي من هذا الجهاز. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get recFilterAll => 'الكل';

  @override
  String get recFilterIncoming => 'الواردة';

  @override
  String get recFilterOutgoing => 'الصادرة';

  @override
  String get recFilterByAccount => 'التصفية حسب الحساب';

  @override
  String get recFilterAllAccounts => 'كل الحسابات';

  @override
  String get recFilterAccountFallback => 'الحساب';

  @override
  String get recFilterAnyDate => 'أي تاريخ';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'مسح التواريخ';

  @override
  String get recMissingFile => 'الملف الصوتي مفقود من هذا الجهاز.';

  @override
  String recRelated(String title) {
    return 'ذو صلة: $title';
  }

  @override
  String get recRenameTitle => 'إعادة تسمية التسجيل';

  @override
  String get recRenameHint => 'الاسم';

  @override
  String get recSaveAs => 'حفظ باسم...';

  @override
  String get recShowInFinder => 'إظهار في Finder';

  @override
  String get recShowInFolder => 'إظهار في المجلد';

  @override
  String get recViewCall => 'عرض المكالمة';

  @override
  String recSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get recSaveFailed => 'تعذّر حفظ التسجيل';

  @override
  String get recShareFailed => 'تعذّرت مشاركة التسجيل';

  @override
  String get recSaveDialogTitle => 'حفظ التسجيل';

  @override
  String get recShareSubject => 'تسجيلات المكالمات';

  @override
  String get recPlayerUnsupported =>
      'لا يستطيع هذا الجهاز تشغيل تسجيلات Opus هنا.';

  @override
  String get recPlayerOpenWith => 'فتح باستخدام...';

  @override
  String get recPlayerNotFound => 'لم يُعثر على ملف التسجيل';

  @override
  String recPlayerCannotPlay(String error) {
    return 'تعذّر تشغيل هذا التسجيل: $error';
  }

  @override
  String get recPlayerPlay => 'تشغيل التسجيل';

  @override
  String get recPlayerPause => 'إيقاف التسجيل مؤقتًا';

  @override
  String get audioFilesTitle => 'الملفات الصوتية';

  @override
  String audioAdded(String name) {
    return 'أُضيف \"$name\"';
  }

  @override
  String get audioFileUnavailable => 'ذلك الملف غير متاح.';

  @override
  String get audioNameRequired => 'أدخل اسمًا';

  @override
  String audioDeleteTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get audioDeleteMessage =>
      'تعود الإعدادات التي تستخدم هذا الملف إلى الافتراضي.';

  @override
  String get audioGroupAdd => 'إضافة';

  @override
  String get audioAddFooter =>
      'تعمل ملفات WAV (PCM وmu-law وA-law) وMP3. تُنسخ الملفات إلى التطبيق، لذا يمكن نقل الأصل.';

  @override
  String get audioImport => 'استيراد ملف WAV أو MP3…';

  @override
  String get audioGroupMine => 'ملفاتي';

  @override
  String get audioEmptyTitle => 'لا ملفات بعد';

  @override
  String get audioEmptyHint => 'استورد ملفًا أو سجّل إعلانك الخاص.';

  @override
  String get audioGroupBuiltIn => 'مدمجة';

  @override
  String get audioBuiltInFooter => 'أُنتجت لـ SoftphonePro، ومجانية الاستخدام.';

  @override
  String get audioPreviewStop => 'إيقاف المعاينة';

  @override
  String audioPreviewPlay(String name) {
    return 'معاينة $name';
  }

  @override
  String get audioRecordedName => 'سمِّ هذا التسجيل';

  @override
  String get audioRecordedDefaultName => 'إعلاني';

  @override
  String audioSaved(String name) {
    return 'حُفظ \"$name\"';
  }

  @override
  String get audioRecorderStop => 'إيقاف';

  @override
  String get audioRecorderPlay => 'تشغيل التسجيل';

  @override
  String audioRecorderNew(String duration) {
    return 'تسجيل جديد  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'تجاهل';

  @override
  String get audioRecordOwn => 'سجّل إعلانك الخاص…';

  @override
  String get audioRecordOwnHint => 'يستخدم الميكروفون المحدد في إعدادات الصوت';

  @override
  String get audioMissingFile => 'ملف مفقود';

  @override
  String get audioBuiltInCalm => 'هادئة (مدمجة)';

  @override
  String get audioBuiltInBreeze => 'نسيم (مدمجة)';

  @override
  String get audioBuiltInChime => 'رنّة إشعار (مدمجة)';

  @override
  String get audioErrOnlyWavMp3 => 'لا يمكن استخدام سوى ملفات WAV وMP3.';

  @override
  String get audioErrNotFound => 'تعذّر العثور على ذلك الملف.';

  @override
  String get audioErrNotSaved => 'لم يُحفظ التسجيل.';

  @override
  String get audioErrEmpty => 'هذا الملف الصوتي فارغ أو غير قابل للقراءة.';

  @override
  String audioErrUnusable(String reason) {
    return 'لا يمكن استخدام هذا الملف الصوتي ($reason). استخدم WAV بصيغة PCM أو mu-law أو A-law، أو MP3.';
  }

  @override
  String get audioRecEngineOff => 'محرك المكالمات لا يعمل.';

  @override
  String get audioRecUnsupported =>
      'هذا الإصدار من محرك المكالمات لا يستطيع تسجيل الميكروفون.';

  @override
  String audioRecStartFailed(String reason) {
    return 'تعذّر بدء التسجيل: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'فشل التسجيل: $reason';
  }

  @override
  String get audioStrengthLow => 'منخفضة';

  @override
  String get audioStrengthMedium => 'متوسطة';

  @override
  String get audioStrengthHigh => 'عالية';

  @override
  String get audioStrengthMax => 'قصوى';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'افتراضي النظام';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'افتراضي النظام ($name)';
  }

  @override
  String get voiceTitle => 'عزل الصوت';

  @override
  String get voiceUnavailable =>
      'إلغاء الضوضاء بالذكاء الاصطناعي غير متاح في هذا الإصدار من محرك المكالمات. لا يزال كتم الضوضاء القياسي ضمن المعالجة يعمل.';

  @override
  String get voiceGroupAi => 'إلغاء الضوضاء بالذكاء الاصطناعي';

  @override
  String get voiceAiFooter =>
      'يزيل نقرات لوحة المفاتيح والمراوح والأصوات في الخلفية من المكالمة باستخدام شبكة عصبية على الجهاز (RNNoise). لا يغادر شيء جهازك. القوة الأعلى تزيل ضوضاء أكثر لكنها قد تقتطع بداية الكلمات.';

  @override
  String get voiceMic => 'ميكروفوني';

  @override
  String get voiceMicHint => 'تنقية ما يسمعه الطرف الآخر';

  @override
  String get voiceOthers => 'المشاركون الآخرون';

  @override
  String get voiceOthersHint => 'تنقية صوت المتصلين الذين تسمعهم وفيهم ضوضاء';

  @override
  String voiceStrength(String value) {
    return 'القوة: $value';
  }

  @override
  String get voiceGroupTry => 'جرّبه';

  @override
  String get voiceTryFooter =>
      'استخدم سماعات الرأس لاختبار الصدى، وإلا سمعت صفيرًا.';

  @override
  String get voiceEchoTest => 'اختبار بالصدى';

  @override
  String get voiceEchoTestHint => 'يعيد تشغيل صوت الميكروفون بعد معالجته';

  @override
  String get voiceEchoFailed => 'فشل اختبار الصدى';

  @override
  String get voiceGroupSystem => 'النظام';

  @override
  String get voiceSystemFooter =>
      'يمكن لـ macOS وiOS أيضًا عزل صوتك لكل التطبيقات. اختر عزل الصوت في وضع ميكروفون النظام.';

  @override
  String get voiceSystemMode => 'وضع ميكروفون النظام (عزل الصوت)…';

  @override
  String get voiceSystemModeUnsupported =>
      'تتطلب أوضاع الميكروفون macOS 12 أو iOS 15 أو أحدث.';

  @override
  String get voiceSpeechDetection => 'اكتشاف الكلام';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent بالمئة';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'مؤثرات صوت Android';

  @override
  String get voiceAndroidFooter =>
      'قد ينقّي الهاتف الميكروفون بنفسه أيضًا. يُبلَّغ عن هذه من Android وهي منفصلة عن الإعداد أعلاه.';

  @override
  String get voiceAndroidNs => 'كاتم الضوضاء';

  @override
  String get voiceAndroidAec => 'ملغي الصدى';

  @override
  String get voiceNotAvailableDevice => 'غير متاح على هذا الجهاز';

  @override
  String get callLinkNotLocal =>
      'لا يمكن استخدام هذا النوع من الروابط إلا من سطر الأوامر في هذا الكمبيوتر.';

  @override
  String linkLanConnectTitle(String name) {
    return 'الاتصال بالجهاز $name؟';
  }

  @override
  String get linkLanConnectBody =>
      'يريد رابط من تطبيق آخر أو صفحة ويب ربط SoftphonePro بهذا الجهاز. اتصل فقط إذا كنت تتوقع ذلك.';

  @override
  String get linkLanConnectAction => 'اتصال';

  @override
  String get linkImportSensitiveHeader => 'تغييرات حساسة في هذا الإعداد:';

  @override
  String get linkImportFlagAutoAnswer => 'يرد على المكالمات الواردة تلقائيًا';

  @override
  String linkImportFlagForwarding(String target) {
    return 'يحوّل المكالمات إلى $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'يغيّر من يمكنه بدء اتصال داخلي أو سحب مكالمة (الشبكة المحلية)';

  @override
  String get linkImportFlagDialRewrite => 'يعيد كتابة الأرقام التي تطلبها';

  @override
  String get linkImportFlagLinksImmediately =>
      'تبدأ المكالمات من روابط الويب فورًا دون تأكيد';

  @override
  String get linkImportFlagDiagnostics => 'يشغّل التسجيل المفصّل أو تتبّع SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'السماح بالرد التلقائي للحسابات المستوردة';

  @override
  String linkImportRefused(String setting) {
    return 'يحاول هذا الاستيراد تغيير \"$setting\"، وهو إعداد لا يمكن ضبطه أبدًا عبر رابط أو رمز QR أو نص ملصق أو ملف. استخدم بدلًا من ذلك خيار سطر الأوامر --provision على هذا الكمبيوتر. لم يتم استيراد أي شيء.';
  }

  @override
  String get lanPairIntercomNote =>
      'يمكن للأجهزة المقترنة طلب مكالمة داخلية؛ سيُطلب منك الإذن قبل كل واحدة (غيّر ذلك من الإعدادات > الشبكة المحلية).';

  @override
  String get callLinkUnsupportedScheme => 'هذا النوع من الروابط غير مدعوم.';

  @override
  String get linkImportFlagAutoRecord => 'يسجّل المكالمات تلقائيًا';

  @override
  String get linkImportFlagBlocklist => 'يغيّر قائمة حظر المكالمات لديك';

  @override
  String get linkImportFlagEmergency => 'يغيّر أرقام الطوارئ لديك';

  @override
  String get linkImportFlagSpeedDial => 'يضبط أرقام الاتصال السريع';

  @override
  String get linkImportFlagRecordingDelete => 'يحذف التسجيلات القديمة تلقائيًا';

  @override
  String get linkImportFlagFeatureCodes => 'يطلب رموز ميزات PBX مخصصة';

  @override
  String get linkImportAllowAutoRecord => 'السماح بتسجيل المكالمات تلقائيًا';

  @override
  String get importIgnoredHeader => 'تم التجاهل (غير مسموح في الاستيراد):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - الخادم $server، $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'الوكلاء: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'مرحّل TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'ترويسات SIP مخصصة: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'معرّف المتصل: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'بدون تشفير الوسائط (SRTP متوقف)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'العنوان: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'تحديث $updated موجودة، وإضافة $added جديدة';
  }

  @override
  String get secretsKeyringLocked =>
      'تعذّر فتح سلسلة المفاتيح (مقفلة أو لا تستجيب)، لذا تعذّرت قراءة كلمات المرور المحفوظة. افتحها ثم أعد تشغيل SoftphonePro.';

  @override
  String get mixerTitle => 'خلاط الصوت';

  @override
  String get mixerMicrophone => 'الميكروفون';

  @override
  String get mixerSpeaker => 'سماعات الرأس والمكبر';

  @override
  String get mixerMicVolume => 'مستوى الميكروفون';

  @override
  String get mixerSpeakerVolume => 'مستوى السماعة';

  @override
  String mixerMeterLabel(String name) {
    return 'مستوى $name';
  }

  @override
  String get mixerInputDevice => 'جهاز الإدخال';

  @override
  String get mixerOutputDevice => 'جهاز الإخراج';

  @override
  String get mixerOutputRoute => 'مخرج الصوت';

  @override
  String get mixerInputFollowsOutput => 'يتبع الميكروفون مخرج الصوت المحدد.';

  @override
  String get mixerShowMore => 'عرض الأجهزة والموسيقى الخلفية';

  @override
  String get mixerShowLess => 'عرض عناصر تحكم أقل';

  @override
  String get mixerStripShow => 'عرض خلاط الصوت';

  @override
  String get mixerStripHide => 'إخفاء خلاط الصوت';

  @override
  String get musicbedTitle => 'الموسيقى الخلفية';

  @override
  String get musicbedPlay => 'تشغيل الموسيقى الخلفية';

  @override
  String get musicbedVolume => 'مستوى الموسيقى الخلفية';

  @override
  String get musicbedChooseFile => 'اختر ملفًا';

  @override
  String musicbedChangeFile(String name) {
    return 'ملف الموسيقى الخلفية: $name. اضغط للتغيير.';
  }

  @override
  String get musicbedHearIt => 'الاستماع إليها بنفسي';

  @override
  String get musicbedMonitorVolume => 'مستوى المراقبة';

  @override
  String get musicbedAddFile => 'إضافة ملف…';

  @override
  String get musicbedPickerTitle => 'ملف الموسيقى الخلفية';

  @override
  String get musicbedOn => 'الموسيقى الخلفية قيد التشغيل';

  @override
  String get musicbedPausedOnHold =>
      'الموسيقى الخلفية متوقفة (المكالمة معلّقة)';

  @override
  String get musicbedOnTooltip =>
      'يتم تشغيل ملف موسيقي لجميع المشاركين في مكالماتك.';

  @override
  String get musicbedFileMissing =>
      'ملف الموسيقى الخلفية لم يعد متاحًا، لذلك تم إيقاف الميزة.';

  @override
  String get musicbedNeedsFile => 'اختر ملف الموسيقى الخلفية أولًا.';

  @override
  String musicbedStopped(String message) {
    return 'توقفت الموسيقى الخلفية: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'يكرر ملفًا موسيقيًا خلف صوتك لجميع المشاركين في مكالماتك، حتى أثناء كتم الميكروفون. المكالمات قيد الانتظار تسمع موسيقى الانتظار بدلًا منه.';

  @override
  String get musicbedSettingsFile => 'ملف الموسيقى';

  @override
  String get linkImportFlagMusicbed => 'يشغّل الموسيقى في مكالماتك';

  @override
  String get musicbedMonitorIosHint => 'على iPhone تسمعها أثناء المكالمات';

  @override
  String get musicbedStopFailed =>
      'تعذّر إيقاف الموسيقى. قد تكون لا تزال تُسمَع للطرف الآخر في المكالمة.';

  @override
  String get audioTestTitle => 'اختبار الصوت';

  @override
  String get audioTestEntry => 'اختبار الميكروفون ومكبرات الصوت';

  @override
  String get audioTestEntrySub =>
      'افحص أجهزتك واسمع صوتك وعدّل مستوى الموسيقى الخلفية';

  @override
  String get audioTestInCall => 'أنهِ مكالمتك لإجراء اختبار الصوت';

  @override
  String get audioTestIosNote =>
      'على iPhone لا يكون الميكروفون ومكبر الصوت مفتوحين إلا أثناء المكالمة';

  @override
  String get audioTestStepDevices => 'الأجهزة';

  @override
  String get audioTestStepMic => 'الميكروفون';

  @override
  String get audioTestStepSpeaker => 'مكبر الصوت أو سماعات الأذن';

  @override
  String get audioTestStepRecord => 'التسجيل والتشغيل';

  @override
  String get audioTestStepEcho => 'اسمع صوتك';

  @override
  String get audioTestStepMusic => 'الموسيقى الخلفية';

  @override
  String get audioTestStepSummary => 'الملخص';

  @override
  String audioTestOpened(String name) {
    return 'قيد الاستخدام: $name';
  }

  @override
  String get audioTestNoDevice => 'تعذّر فتح أي جهاز صوت';

  @override
  String get audioTestMicOk => 'نسمعك';

  @override
  String get audioTestMicWaiting => 'قل شيئًا…';

  @override
  String get audioTestMicQuiet =>
      'الصوت منخفض جدًا: اقترب أو ارفع مستوى حساسية الميكروفون';

  @override
  String get audioTestMicClipping =>
      'الصوت مرتفع جدًا: خفّض مستوى حساسية الميكروفون';

  @override
  String get audioTestMicSilent =>
      'لا يصل أي صوت. تحقق من: اختيار الميكروفون الصحيح، وأنه غير مكتوم في النظام، وأن التطبيق مسموح له باستخدام الميكروفون (إعدادات الخصوصية)، وأن أي تطبيق آخر لا يستخدمه.';

  @override
  String get audioTestOpenSoundSettings => 'فتح إعدادات الصوت';

  @override
  String get audioTestOpenPrivacySettings => 'فتح إعدادات خصوصية الميكروفون';

  @override
  String get audioTestPlaySound => 'تشغيل صوت اختبار';

  @override
  String get audioTestDidYouHear => 'هل سمعته؟';

  @override
  String get audioTestDidYouHearVoice => 'هل سمعت صوتك؟';

  @override
  String get audioTestNoOutputLevel =>
      'أرسل التطبيق صوتًا لكن مؤشر مستوى الإخراج لم يتحرك';

  @override
  String get audioTestSpeakerHints =>
      'تحقق من مستوى الصوت وجهاز الإخراج المحدد وإخراج النظام (بلوتوث، HDMI)';

  @override
  String get audioTestRecord5s => 'تسجيل 5 ثوانٍ';

  @override
  String audioTestRecording(int seconds) {
    return 'جارٍ التسجيل… $seconds ث';
  }

  @override
  String get audioTestPlayingBack => 'جارٍ التشغيل…';

  @override
  String get audioTestPlayAgain => 'تشغيل مرة أخرى';

  @override
  String get audioTestRecEmpty => 'التسجيل فارغ';

  @override
  String get audioTestEchoHeadphones =>
      'استخدم سماعات الرأس: مع مكبرات الصوت ستسمع صفيرًا مرتدًا.';

  @override
  String audioTestEchoSecondsLeft(int seconds) {
    return 'يتوقف خلال $seconds ث';
  }

  @override
  String audioTestEchoEnded(String reason) {
    return 'انتهى اختبار الصدى ($reason)';
  }

  @override
  String get audioTestPreview => 'معاينة ما يسمعه المتصلون';

  @override
  String get audioTestPreviewSub =>
      'صوتك والموسيقى الخلفية، ممزوجان كما يُرسلان';

  @override
  String get audioTestSendLevel => 'المُرسَل إلى المتصلين';

  @override
  String get audioTestEcNotPreviewed =>
      'لا يُطبَّق إلغاء الصدى في هذه المعاينة';

  @override
  String get audioTestPass => 'سليم';

  @override
  String get audioTestFail => 'مشكلة';

  @override
  String get audioTestNotRun => 'لم يُختبر';

  @override
  String get audioTestSkipped => 'تم التخطي';

  @override
  String get audioTestRunning => 'جارٍ الاختبار…';

  @override
  String get audioTestCopyDiagnostics => 'نسخ التشخيصات';

  @override
  String get audioTestCopied => 'تم نسخ التشخيصات';

  @override
  String audioDeviceErrorNotice(String message) {
    return 'مشكلة في جهاز الصوت: $message';
  }

  @override
  String get mixerMicUnavailable =>
      'الميكروفون غير متاح: يتم استخدام جهاز صامت';

  @override
  String get audioTestMusicSilentHint =>
      'تُرسَل الموسيقى إلى المتصلين؛ فعّل \"أسمعها بنفسي\" أو المعاينة لتسمعها';

  @override
  String get audioTestEchoEndedTimeout => 'توقف بعد 60 ثانية';

  @override
  String get audioTestEchoEndedCall => 'بدأت مكالمة';

  @override
  String get audioTestEchoEndedShutdown => 'أُعيد تشغيل المحرك';
}
