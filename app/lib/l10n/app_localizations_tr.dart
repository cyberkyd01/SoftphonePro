// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get languageSystemDefault => 'Sistem varsayılanı';

  @override
  String get languagePickerHint => 'Dil adları kendi dillerinde gösterilir.';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionOk => 'Tamam';

  @override
  String get actionRetry => 'Yeniden dene';

  @override
  String get actionDone => 'Bitti';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionRename => 'Yeniden adlandır';

  @override
  String get actionClear => 'Temizle';

  @override
  String get actionBack => 'Geri';

  @override
  String get actionCopy => 'Kopyala';

  @override
  String get actionShare => 'Paylaş';

  @override
  String get actionImport => 'İçe aktar';

  @override
  String get actionExport => 'Dışa aktar';

  @override
  String get actionDetails => 'Ayrıntılar';

  @override
  String get actionMore => 'Daha fazla';

  @override
  String get actionSettings => 'Ayarlar';

  @override
  String get actionSearch => 'Ara';

  @override
  String get actionRefresh => 'Yenile';

  @override
  String get actionContinue => 'Devam';

  @override
  String get actionYes => 'Evet';

  @override
  String get actionNo => 'Hayır';

  @override
  String get commonOn => 'Açık';

  @override
  String get commonOff => 'Kapalı';

  @override
  String get commonNone => 'Yok';

  @override
  String get commonDefault => 'Varsayılan';

  @override
  String get commonSystem => 'Sistem';

  @override
  String get commonAutomatic => 'Otomatik';

  @override
  String get commonUnknown => 'Bilinmiyor';

  @override
  String get commonNotSet => 'Ayarlanmadı';

  @override
  String get commonError => 'Hata';

  @override
  String get commonLoading => 'Yükleniyor…';

  @override
  String get statusAvailable => 'Müsait';

  @override
  String get statusDoNotDisturb => 'Rahatsız etmeyin';

  @override
  String get statusOffline => 'Çevrimdışı';

  @override
  String get statusOnACall => 'Görüşmede';

  @override
  String get settingsEntryAccounts => 'Hesaplar';

  @override
  String get settingsEntryAccountsSub => 'SIP hesapları ve kayıt';

  @override
  String get settingsEntryAudio => 'Ses';

  @override
  String get settingsEntryAudioSub => 'Cihazlar, seviyeler, yankı engelleme';

  @override
  String get settingsEntryCodecs => 'Codec\'ler';

  @override
  String get settingsEntryCodecsSub => 'Sıra, kullanılabilirlik, Opus';

  @override
  String get settingsEntryCalls => 'Aramalar';

  @override
  String get settingsEntryCallsSub =>
      'Rahatsız etmeyin, çağrı bekletme, otomatik yanıt, arama kuralları';

  @override
  String get settingsEntryNetwork => 'Ağ';

  @override
  String get settingsEntryNetworkSub => 'Aktarım, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Kayıt';

  @override
  String get settingsEntryNotifications => 'Bildirimler ve zil sesleri';

  @override
  String get settingsEntryShortcuts => 'Kısayollar';

  @override
  String get settingsEntryShortcutsSub =>
      'Genel kısayollar, uygulama içi tuşlar';

  @override
  String get settingsEntryAppearance => 'Görünüm';

  @override
  String get settingsEntryPrivacy => 'Gizlilik ve güvenlik';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Otomatik yapılandırma';

  @override
  String get settingsEntryProvisioningSub => 'İçe aktar, dışa aktar, QR';

  @override
  String get settingsEntryDiagnostics => 'Tanılama';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP izi, ağ kontrolleri';

  @override
  String get settingsEntryAdvanced => 'Gelişmiş';

  @override
  String get settingsEntryAbout => 'Hakkında';

  @override
  String get settingsAccountsEmptyTitle => 'İlk hesabınızı ekleyin';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Aramaya başlamak için santralinize veya SIP sağlayıcınıza bağlanın.';

  @override
  String get settingsAccountsAdd => 'Hesap ekle';

  @override
  String get settingsAccountsYourAccounts => 'Hesaplarınız';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  yedek sunucu kullanılıyor';
  }

  @override
  String get settingsAudioDevices => 'Cihazlar';

  @override
  String get settingsAudioMicrophone => 'Mikrofon';

  @override
  String get settingsAudioSpeaker => 'Hoparlör';

  @override
  String get settingsAudioRinger => 'Zil cihazı';

  @override
  String get settingsAudioRingerSub => 'Zil sesini ayrı bir cihazda çal';

  @override
  String get settingsAudioRefreshDevices => 'Cihazları yenile';

  @override
  String get settingsAudioLevelsAndTest => 'Seviyeler ve test';

  @override
  String get settingsAudioMicVolume => 'Mikrofon ses düzeyi';

  @override
  String get settingsAudioMicLevel => 'Mikrofon seviyesi';

  @override
  String get settingsAudioSpeakerVolume => 'Hoparlör ses düzeyi';

  @override
  String get settingsAudioSpeakerLevel => 'Hoparlör seviyesi';

  @override
  String get settingsAudioTestSpeaker => 'Hoparlörü test et';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Seçili hoparlörden kısa bir ton çalar';

  @override
  String get settingsAudioTestToneFailed => 'Test tonu çalınamadı';

  @override
  String get settingsAudioEchoTestFailed => 'Yankı testi başarısız oldu';

  @override
  String get settingsAudioEchoTest => 'Yankı testi';

  @override
  String get settingsAudioEchoTestSub =>
      'Mikrofonunuzu hoparlörden geri çalar. Geri besleme olmaması için kulaklık kullanın.';

  @override
  String get settingsAudioVoiceAndFiles => 'Ses ve dosyalar';

  @override
  String get settingsAudioVoiceIsolation =>
      'Ses yalıtımı (yapay zekâ gürültü engelleme)';

  @override
  String get settingsAudioAudioFiles => 'Ses dosyaları';

  @override
  String get settingsAudioAudioFilesSub => 'Bekleme müziği ve anonslar';

  @override
  String get settingsAudioProcessing => 'İşleme';

  @override
  String get settingsAudioEchoCancellation => 'Yankı engelleme';

  @override
  String get settingsAudioEcSimple => 'Basit';

  @override
  String get settingsAudioEcPlatform => 'Platform';

  @override
  String get settingsAudioEchoTail => 'Yankı kuyruğu';

  @override
  String get settingsAudioNoiseSuppression => 'Gürültü bastırma';

  @override
  String get settingsAudioAgc => 'Otomatik kazanç denetimi';

  @override
  String get settingsAudioVad => 'Ses etkinliği algılama';

  @override
  String get settingsAudioVadSub =>
      'Sessizlik sırasında bant genişliğinden tasarruf sağlar';

  @override
  String get settingsAudioAdvanced => 'Gelişmiş';

  @override
  String get settingsAudioAdvancedFooter =>
      'Jitter tamponu değerleri milisaniye cinsindendir; -1 altyapının varsayılanını kullanır. Bunları değiştirmek arama altyapısını yeniden başlatır.';

  @override
  String get settingsAudioPtime => 'Paket süresi (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter tamponu: başlangıç';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter tamponu: en az ön yükleme';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter tamponu: en çok ön yükleme';

  @override
  String get settingsAudioJbMaxSize => 'Jitter tamponu: en büyük boyut';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Mikrofon $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Diğerleri $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return 'yüzde $percent';
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
      other: '$count saniye',
      one: '1 saniye',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Sıra ve kullanılabilirlik';

  @override
  String get settingsCodecsDragHint =>
      'Sıralamak için sürükleyin. Hesaplar bu listeyi kendi ayarlarında geçersiz kılabilir.';

  @override
  String get settingsCodecsBitrate => 'Bit hızı';

  @override
  String get settingsCodecsFec => 'Bant içi FEC';

  @override
  String get settingsCodecsFecSub => 'Paket kaybını telafi eder';

  @override
  String get settingsCodecsDtxSub => 'Sessizlik sırasında göndermeyi durdur';

  @override
  String get settingsCodecsCbr => 'Sabit bit hızı';

  @override
  String get settingsCodecsComplexity => 'Karmaşıklık';

  @override
  String get settingsCallsIncoming => 'Gelen';

  @override
  String get settingsCallsDndSub => 'Gelen tüm aramaları reddet';

  @override
  String get settingsCallsRejectWith => 'Şununla reddet';

  @override
  String get settingsCallsReasonBusy => 'Meşgul (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Geçici olarak ulaşılamıyor (480)';

  @override
  String get settingsCallsReasonDecline => 'Reddedildi (603)';

  @override
  String get settingsCallsWaiting => 'Çağrı bekletme';

  @override
  String get settingsCallsWaitingSub =>
      'Görüşme sırasında ikinci bir gelen aramaya izin ver';

  @override
  String get settingsCallsWhenBusy => 'Meşgulken ve bekletme kapalıyken';

  @override
  String get settingsCallsRejectAnonymous => 'Anonim aramaları reddet';

  @override
  String get settingsCallsLinksImmediately =>
      'Bağlantıdaki aramayı hemen başlat';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'tel:, sip: ve callto: bağlantıları tuş takımında beklemeden aramayı başlatır';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Rahatsız etmeyin / yönlendirmeyi özellik kodlarıyla santrale eşitle';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Rahatsız etmeyin veya yönlendirmeyi değiştirdiğinizde hesabın yıldız kodlarını (örneğin *78) kısaca arar';

  @override
  String get settingsCallsAutoAnswerGroup => 'Otomatik yanıt';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Çağrı yönlendirme ve hesap bazlı otomatik yanıt her hesabın kendi ayarlarında yapılır.';

  @override
  String get settingsCallsAutoAnswerAll => 'Tüm aramaları otomatik yanıtla';

  @override
  String get settingsCallsAnswerAfter => 'Yanıtlama süresi';

  @override
  String get settingsCallsAnswerImmediately => 'Hemen';

  @override
  String get settingsCallsIntercomHeaders => 'Intercom başlıklarına uy';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info, Alert-Info ve Answer-Mode otomatik yanıt ipuçları';

  @override
  String get settingsCallsBlocked => 'Engellenen numaralar';

  @override
  String get settingsCallsBlockNumber => 'Numara engelle';

  @override
  String get settingsCallsBlockNumberTitle => 'Numarayı engelle';

  @override
  String get settingsCallsBlockNumberHint => 'Numara veya SIP adresi';

  @override
  String get settingsCallsSpeedDial => 'Hızlı arama';

  @override
  String get settingsCallsDialPlan => 'Arama planı';

  @override
  String get settingsCallsDialRules => 'Arama kuralları';

  @override
  String get settingsCallsStripPrefix => 'Çıkarılacak dış hat öneki';

  @override
  String get settingsCallsStripPrefixSub =>
      'Örneğin 9; çevrilen numaraların başından kaldırılır';

  @override
  String get settingsCallsPlusReplacement => 'Baştaki + yerine';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Örneğin uluslararası erişim için 00';

  @override
  String get settingsCallsPlusReplacementHint => '+ kalsın';

  @override
  String get settingsCallsCountryPrefix => 'Varsayılan ülke öneki';

  @override
  String get settingsCallsCountryPrefixSub =>
      '0 ile başlayan ulusal numaralara bu önek eklenir, örneğin +90';

  @override
  String get settingsCallsEmergency => 'Acil durum numaraları';

  @override
  String get settingsCallsEmergencySub =>
      'Virgülle ayrılır. Bunlar arama kurallarını atlar.';

  @override
  String settingsCallsUnblock(String number) {
    return '$number engelini kaldır';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '9 üzerinden $count atandı';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kural',
      one: '1 kural',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Yeni arama kuralı';

  @override
  String get settingsDialRulesEdit => 'Arama kuralını düzenle';

  @override
  String get settingsDialRulesName => 'Ad';

  @override
  String get settingsDialRulesPattern => 'Desen (regex)';

  @override
  String get settingsDialRulesReplacement => 'Yerine konacak';

  @override
  String get settingsDialRulesReplacementHelp =>
      'Gruplar için \$1, \$2 kullanın';

  @override
  String get settingsDialRulesRoute => 'Şu hesap üzerinden yönlendir';

  @override
  String get settingsDialRulesAdd => 'Kural ekle';

  @override
  String get settingsDialRulesLiveTest => 'Canlı test';

  @override
  String get settingsDialRulesTyped => 'Girilen numara';

  @override
  String get settingsDialRulesNothing => '(hiçbir şey)';

  @override
  String get settingsDialRulesEmergency =>
      'Acil durum numarası: girildiği gibi aranır';

  @override
  String get settingsDialRulesAccountFallback => 'hesap';

  @override
  String get settingsDialRulesEmpty =>
      'Kural yok. Numaralar temizlenir (boşluk, tire ve parantezler kaldırılır) ve girildiği gibi aranır. Kurallar yukarıdan aşağıya çalışır; ilk eşleşen geçerli olur.';

  @override
  String get settingsDialRulesDelete => 'Kuralı sil';

  @override
  String get settingsDialRulesDeleteTitle => 'Kural silinsin mi?';

  @override
  String settingsDialRulesVia(String account) {
    return '$account üzerinden';
  }

  @override
  String get settingsNetworkTransports => 'Aktarım';

  @override
  String get settingsNetworkTransportsFooter =>
      'Bağlantı noktası 0, boş bir bağlantı noktasını rastgele seçer. Aktarımı değiştirmek arama altyapısını yeniden başlatır.';

  @override
  String get settingsNetworkUdpPort => 'UDP bağlantı noktası';

  @override
  String get settingsNetworkTcpPort => 'TCP bağlantı noktası';

  @override
  String get settingsNetworkTlsPort => 'TLS bağlantı noktası';

  @override
  String get settingsNetworkVerifyCerts => 'Sunucu sertifikalarını doğrula';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Yalnızca otomatik imzalı santraller için kapatın veya sertifikayı aşağıda sabitleyin';

  @override
  String get settingsNetworkCustomCa => 'Özel CA dosyası';

  @override
  String get settingsNetworkCustomCaSub =>
      'Yerleşik liste yerine kullanılan PEM paketi (özel santral CA\'sı)';

  @override
  String get settingsNetworkCustomCaHint => 'Yerleşik Mozilla listesi';

  @override
  String get settingsNetworkPins => 'Sabitlenmiş sertifikalar';

  @override
  String get settingsNetworkPinsSub =>
      'ana makine=SHA256 parmak izi, virgülle ayrılır';

  @override
  String get settingsNetworkNat => 'NAT geçişi';

  @override
  String get settingsNetworkStun => 'STUN sunucuları';

  @override
  String get settingsNetworkStunSub =>
      'ana makine:bağlantı noktası, virgülle ayrılır';

  @override
  String get settingsNetworkIceTurn => 'ICE ve TURN';

  @override
  String get settingsNetworkIceTurnSub =>
      'Hesap başına NAT altında yapılandırılır';

  @override
  String get settingsNetworkAdvanced => 'Gelişmiş';

  @override
  String get settingsNetworkQos => 'QoS (DSCP işaretleme)';

  @override
  String get settingsNetworkQosSub =>
      'SIP ve ses paketlerini öncelik için işaretle';

  @override
  String get settingsNetworkDns => 'DNS sunucuları';

  @override
  String get settingsNetworkDnsSub => 'Otomatik için boş bırakın';

  @override
  String get settingsNetworkRtpStart => 'RTP bağlantı noktası başlangıcı';

  @override
  String get settingsNetworkRtpRange => 'RTP bağlantı noktası aralığı';

  @override
  String get settingsNetworkRtpRangeSub => '0 varsayılanı kullanır';

  @override
  String get settingsNotifRingtone => 'Zil sesi';

  @override
  String get settingsNotifDefaultRingtone => 'Varsayılan zil sesi';

  @override
  String get settingsNotifProgressTones => 'Arama ilerleme tonları';

  @override
  String get settingsNotifProgressTonesSub =>
      'Arama sırasında çalma, meşgul ve yoğunluk tonları';

  @override
  String get settingsNotifRingerVolume => 'Zil ses düzeyi';

  @override
  String get settingsNotifCustomRingtone => 'Özel zil sesi dosyası';

  @override
  String get settingsNotifCustomRingtoneSub => 'WAV dosyasının yolu (masaüstü)';

  @override
  String get settingsNotifGroup => 'Bildirimler';

  @override
  String get settingsNotifRequestPermissions => 'İzin iste';

  @override
  String get settingsNotifRequestPermissionsSub => 'Mikrofon ve bildirimler';

  @override
  String get settingsNotifTyping => 'Yazıyor göstergelerini gönder';

  @override
  String get settingsAppearanceTheme => 'Tema';

  @override
  String get settingsAppearanceLight => 'Açık';

  @override
  String get settingsAppearanceDark => 'Koyu';

  @override
  String get settingsAppearanceAccent => 'Vurgu rengi';

  @override
  String get settingsAppearanceAccentOption => 'Vurgu rengi seçeneği';

  @override
  String get settingsAppearanceCompact => 'Sıkışık yerleşim';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Mikrofon: $microphone, bildirimler: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Güvenlik';

  @override
  String get settingsPrivacyPasswords => 'Parolalar';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Sistem anahtar zincirinde / anahtar deposunda saklanır (yedek olarak şifreli dosya)';

  @override
  String get settingsPrivacyGroup => 'Gizlilik';

  @override
  String get settingsPrivacyNoTelemetry => 'Telemetri yok';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro hiçbir analiz verisi göndermez. Ağ trafiği yalnızca SIP sunucularınıza gider.';

  @override
  String get settingsPrivacyYourData => 'Verileriniz';

  @override
  String get settingsPrivacyClearHistory => 'Arama geçmişini temizle';

  @override
  String get settingsPrivacyDeleteContacts => 'Tüm kişileri sil';

  @override
  String get settingsPrivacyDeleteMessages => 'Tüm mesajları sil';

  @override
  String get settingsPrivacyConfirmHistory => 'Arama geçmişi silinsin mi?';

  @override
  String get settingsPrivacyConfirmContacts => 'Tüm kişiler silinsin mi?';

  @override
  String get settingsPrivacyConfirmMessages => 'Tüm mesajlar silinsin mi?';

  @override
  String get settingsPrivacyCannotUndo => 'Bu işlem geri alınamaz.';

  @override
  String get settingsPrivacyDeletedHistory => 'Arama geçmişi silindi';

  @override
  String get settingsPrivacyDeletedContacts => 'Tüm kişiler silindi';

  @override
  String get settingsPrivacyDeletedMessages => 'Tüm mesajlar silindi';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Aynı ağdaki cihazlar birbirini bulur, 6 haneli kodla eşleşir ve hiçbir sunucu olmadan doğrudan konuşur.';

  @override
  String get settingsLanEnable => 'LAN Link\'i etkinleştir';

  @override
  String get settingsLanDeviceName => 'Cihaz adı';

  @override
  String get settingsLanDeviceNameHint => 'Bu cihaz';

  @override
  String get settingsLanAllowIntercom => 'Interkoma izin ver';

  @override
  String get settingsLanAllowIntercomSub =>
      'Eşleşmiş cihazlar sizi arasın ve aramalar otomatik yanıtlansın';

  @override
  String get settingsLanAskIntercom => 'Interkoma izin vermeden önce sor';

  @override
  String get settingsLanAskIntercomSub =>
      'Aksi halde eşleşmiş cihazlar istekten sonra 30 sn boyunca otomatik yanıtlanır';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Eşleşmiş cihazlardan gelen dosyaları otomatik kabul et';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Aksi halde her dosya için size sorulur';

  @override
  String get settingsLanAllowPull =>
      'Eşleşmiş cihazlar aramalarımı devralabilsin';

  @override
  String get settingsLanAllowPullSub =>
      'Eşleşmiş bir cihaz burada etkin olan bir aramayı devralabilir';

  @override
  String get settingsLanDownloads => 'İndirilenler klasörü';

  @override
  String get settingsLanDownloadsHint =>
      'Varsayılan (İndirilenler/SoftphonePro)';

  @override
  String get settingsLanPort => 'Link bağlantı noktası';

  @override
  String get settingsLanSharedAccounts =>
      'Eşleşmiş cihazlarla paylaşılan hesaplar';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Kayıtlı bir hesabı paylaşmak, aynı sunucudaki eşleşmiş bir cihazın aramalarınızı aktarmak yerine doğrudan (çağrı aktarma) almasını sağlar.';

  @override
  String get settingsAdvEngine => 'Altyapı';

  @override
  String get settingsAdvSimulator => 'Simülatörü kullan';

  @override
  String get settingsAdvSimulatorSub =>
      'Yerel altyapı olmadan çalışır. Aramalar simüle edilir.';

  @override
  String get settingsAdvLogLevel => 'Günlük düzeyi';

  @override
  String get settingsAdvLogErrors => 'Hatalar';

  @override
  String get settingsAdvLogInfo => 'Bilgi';

  @override
  String get settingsAdvLogDebug => 'Hata ayıklama';

  @override
  String get settingsAdvLogVerbose => 'Ayrıntılı';

  @override
  String get settingsAdvSipTrace => 'SIP izi';

  @override
  String get settingsAdvRestartEngine => 'Altyapıyı yeniden başlat';

  @override
  String get settingsAdvDesktop => 'Masaüstü';

  @override
  String get settingsAdvStartAtLogin => 'Oturum açıldığında başlat';

  @override
  String get settingsAdvCloseToTray => 'Kapatınca tepsiye küçült';

  @override
  String get settingsAdvCloseToTraySub =>
      'Pencereyi kapatmak SoftphonePro\'yu çalışır durumda tutar, böylece aramalar çalmaya devam eder. Tepsi / menü çubuğu simgesinden çıkın.';

  @override
  String get settingsAboutLicence => 'Lisans';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro özgür yazılımdır: Free Software Foundation tarafından yayımlanan GNU Genel Kamu Lisansı\'nın 3. veya sonraki sürümünün koşulları altında dağıtabilir ve/veya değiştirebilirsiniz. HİÇBİR GARANTİ VERİLMEDEN dağıtılır.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 veya üzeri';

  @override
  String get settingsAboutGplSub =>
      'Kaynak koduna proje deposundan ulaşılabilir';

  @override
  String get settingsAboutThirdParty => 'Üçüncü taraf bildirimleri';

  @override
  String get settingsAboutPackages => 'Flutter ve Dart paketleri';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT ve Apache 2.0. Lisans sayfasına bakın.';

  @override
  String settingsAboutVersion(String version) {
    return 'Sürüm $version';
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
    return '$license. $purpose. Sürüm $version.';
  }

  @override
  String get updatesChecking => 'Denetleniyor...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version kullanıma sunuldu';
  }

  @override
  String get updatesUpToDate => 'Güncelsiniz';

  @override
  String get updatesCouldNotCheck => 'Denetlenemedi';

  @override
  String get updatesNotCheckedYet => 'Henüz denetlenmedi';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Son denetim: $dateString';
  }

  @override
  String get updatesTitle => 'Güncellemeler';

  @override
  String get updatesFooter =>
      'Denetim yalnızca api.github.com adresine (haftada bir) bağlanır ve isteğin kendisinden başka hiçbir şey göndermez: tanımlayıcı, hesap veya arama verisi yoktur. SoftphonePro hiçbir şeyi kendiliğinden indirmez veya yüklemez.';

  @override
  String get updatesCheckSwitch => 'Güncellemeleri denetle';

  @override
  String get updatesCheckNow => 'Şimdi denetle';

  @override
  String updatesSkippingVersion(String version) {
    return '$version sürümü atlanıyor';
  }

  @override
  String get updatesStopSkipping => 'Atlamayı bırak';

  @override
  String get updatesReleaseNotes => 'Sürüm notları';

  @override
  String get updatesDownload => 'İndir';

  @override
  String get updatesSkipVersion => 'Bu sürümü atla';

  @override
  String get updatesDismiss => 'Kapat';

  @override
  String get updatesRateLimited =>
      'GitHub istek sınırına ulaşıldı, daha sonra tekrar deneyin';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub şu yanıtı verdi: $status';
  }

  @override
  String get updatesUnexpectedReply => 'Beklenmeyen yanıt';

  @override
  String get updatesTimedOut => 'Zaman aşımı';

  @override
  String get updatesAlreadyChecking => 'Zaten denetleniyor';

  @override
  String get encryptionTitle => 'Şifreleme';

  @override
  String get encryptionFooter =>
      'Yerel veritabanını AES-256-GCM ile şifreler. Anahtar sistem anahtar zincirinde / anahtar deposunda tutulur; kaybolursa veriler kurtarılamaz. Arama kayıtları ve dışa aktarılan dosyalar şifrelenmez. Değişiklik SoftphonePro\'nun bir sonraki başlatılışında geçerli olur (önce tamamen kapatın); önceki dosya, yeni veritabanı açılıp doğrulanır doğrulanmaz üzerine yazılarak silinir.';

  @override
  String get encryptionSwitchTitle =>
      'Arama geçmişini, kişileri ve mesajları bu cihazda şifrele';

  @override
  String get encryptionWillEncrypt => 'Bir sonraki başlatmada şifrelenecek';

  @override
  String get encryptionWillDecrypt =>
      'Bir sonraki başlatmada şifresi çözülecek';

  @override
  String get encryptionRestartToEncrypt =>
      'Verilerinizi şifrelemek için SoftphonePro\'dan çıkıp yeniden başlatın.';

  @override
  String get encryptionRestartToDecrypt =>
      'Verilerinizin şifresini çözmek için SoftphonePro\'dan çıkıp yeniden başlatın.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Hızlı arama $slot';
  }

  @override
  String get speedDialNumberLabel => 'Numara veya SIP adresi';

  @override
  String get speedDialLabelOptional => 'Etiket (isteğe bağlı)';

  @override
  String get speedDialCallFrom => 'Arayan hesap';

  @override
  String get speedDialSelectedAccount => 'Seçili hesap';

  @override
  String get speedDialTitle => 'Hızlı arama';

  @override
  String get speedDialHint =>
      'Numarasını aramak için boş tuş takımında bir rakama (1-9) uzun basın.';

  @override
  String get speedDialNotAssigned => 'Atanmadı';

  @override
  String provisioningNotValidJson(String detail) {
    return 'Geçerli JSON değil: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Bir JSON nesnesi bekleniyordu';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Desteklenmeyen yapılandırma sürümü $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Nesne olmayan bir hesap girdisi atlandı';

  @override
  String get provisioningNothingToImport => 'Dosyada hesap veya ayar yok';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return '\"$name\" hesabı için kullanıcı adı ve alan adı gerekli';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Sunucu şu yanıtı verdi: $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Yapılandırma indirilemedi: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '$path okunamadı';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hesap içe aktarıldı',
      one: '1 hesap içe aktarıldı',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Yapılandırmayı içe aktar';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts hesap',
      one: '1 hesap',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings ayar',
      one: '1 ayar',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'URL veya JSON\'dan içe aktar';

  @override
  String get provisioningImportFromUrlHint =>
      'https://... veya JSON yapıştırın';

  @override
  String get provisioningInvalidSource =>
      'Bu geçerli bir URL, bağlantı veya JSON değil';

  @override
  String get provisioningScanTitle => 'Yapılandırma QR kodunu tara';

  @override
  String get provisioningPasteHint => 'JSON, bağlantı veya URL yapıştırın';

  @override
  String get provisioningImportGroup => 'İçe aktar';

  @override
  String get provisioningImportFooter =>
      'Hesap ve ayar içeren JSON desteklenir. \${VAR} yer tutucuları, varsayılan değer \${VAR:-default} biçiminde verilmedikçe boş değerlerle doldurulur.';

  @override
  String get provisioningScanQr => 'QR kodu tara';

  @override
  String get provisioningFromUrl => 'URL\'den veya yapıştırılan JSON\'dan';

  @override
  String get provisioningFromFile => 'Dosyadan';

  @override
  String get provisioningFromClipboard => 'Panodan';

  @override
  String get provisioningExportGroup => 'Dışa aktar';

  @override
  String get provisioningIncludePasswords => 'Parolaları ekle';

  @override
  String get provisioningIncludePasswordsHint =>
      'Dosyaya sahip olan herkes hesaplarınızı kullanabilir';

  @override
  String get provisioningCopyConfig => 'Yapılandırmayı kopyala (JSON)';

  @override
  String get provisioningConfigCopied => 'Yapılandırma kopyalandı';

  @override
  String get provisioningQrGroup => 'QR kodu';

  @override
  String get provisioningQrFooter =>
      'Bir hesabı kopyalamak için bu kodu başka bir cihazda tarayın. İçinde parola varsa parola gibi koruyun.';

  @override
  String get provisioningQrAccount => 'Hesap';

  @override
  String get provisioningChoose => 'Seçin...';

  @override
  String get provisioningQrTooMuchData => 'QR kodu için çok fazla veri';

  @override
  String tlsClearField(String field) {
    return '$field alanını temizle';
  }

  @override
  String get tlsChoose => 'Seç...';

  @override
  String get tlsChange => 'Değiştir...';

  @override
  String get tlsClientCertTitle => 'İstemci sertifikası (karşılıklı TLS)';

  @override
  String get tlsIncomplete =>
      'Hem bir sertifika hem de özel anahtarını seçin. Sertifika yalnızca ikisi de ayarlandığında sunulur.';

  @override
  String get tlsFooter =>
      'Uygulamadan sertifikayla kimlik doğrulaması isteyen sunucular içindir. PEM dosyaları. TLS ve güvenli WebSocket için kullanılır.';

  @override
  String get tlsCertFile => 'Sertifika dosyası';

  @override
  String get tlsKeyFile => 'Özel anahtar dosyası';

  @override
  String get tlsKeyPassword => 'Anahtar parolası';

  @override
  String get tlsKeyPasswordHint => 'Yalnızca anahtar şifreliyse';

  @override
  String get callSettingsHoldGroupTitle => 'Beklemeye alma';

  @override
  String get callSettingsHoldFooter =>
      '\"Santral varsayılanı\" seçildiğinde arama yalnızca beklemeye alınır ve telefon sisteminiz kendi müziğini çalabilir. Diğer seçimler bu uygulama tarafından arayana çalınır.';

  @override
  String get callSettingsHoldMusic => 'Bekleme müziği';

  @override
  String get callSettingsHoldPbxDefault => 'Santral varsayılanı';

  @override
  String get callSettingsHoldMusicVolume => 'Bekleme müziği ses düzeyi';

  @override
  String get callSettingsHoldAudioFiles => 'Ses dosyaları';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Bekleme müziği içe aktarın veya kaydedin';

  @override
  String get callSettingsAnnounceTitle => 'Anonslar';

  @override
  String get callSettingsAnnounceFooter =>
      'Anonslar karşı tarafa çalınır. Dosya yoksa her şey sessizce atlanır.';

  @override
  String get callSettingsAnnounceOpening => 'Karşılama anonsu';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Arama bağlandığında bir mesaj çal';

  @override
  String get callSettingsAnnounceFile => 'Anons dosyası';

  @override
  String get callSettingsAnnounceChooseFile => 'Dosya seçin';

  @override
  String get callSettingsAnnouncePlayFor => 'Çalınacak aramalar';

  @override
  String get callSettingsAnnounceBoth => 'Gelen ve giden';

  @override
  String get callSettingsAnnounceIncoming => 'Gelen aramalar';

  @override
  String get callSettingsAnnounceOutgoing => 'Giden aramalar';

  @override
  String get callSettingsAnnounceMuteMic => 'Çalarken mikrofonumu sessize al';

  @override
  String get callSettingsAnnounceMonitor => 'Ben de duyayım';

  @override
  String get callSettingsAnnounceBeforeRecording => 'Kayıt başlamadan önce çal';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Arayanı aktarmadan önce çal';

  @override
  String get morePageTitle => 'Daha fazla';

  @override
  String get morePresence => 'Durum';

  @override
  String get morePresenceHint => 'Meşgul lambası alanı';

  @override
  String get moreRetrieveParked => 'Park edilen aramayı al';

  @override
  String get moreRetrieveParkedHint => 'Park yuvasını arayın';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Yakındaki cihazlar, sohbet ve dosya aktarımı';

  @override
  String get moreRecordings => 'Kayıtlar';

  @override
  String get moreRecordingsHint =>
      'Arama kayıtlarını dinleyin, paylaşın ve yönetin';

  @override
  String get moreVoicemail => 'Sesli mesaj';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yeni mesaj',
      one: '1 yeni mesaj',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Sesli mesajınızı arayın';

  @override
  String get moreDiagnostics => 'Tanılama';

  @override
  String get moreDiagnosticsHint => 'SIP izi ve ağ kontrolleri';

  @override
  String get moreAbout => 'Hakkında';

  @override
  String get moreNoVoicemailNumber =>
      'Sesli mesaj numarası ayarlanmadı. Hesap ayarlarından ekleyin.';

  @override
  String get moreSearchHint => 'Kişi, geçmiş arayın veya numara girin';

  @override
  String moreCallNumber(String number) {
    return '$number numarasını ara';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Uygulama kilidi';

  @override
  String get appLockFooter =>
      'Uygulama kilitliyken aramalar yine çalar ve yanıtlanabilir.';

  @override
  String get appLockRequirePin => 'Uygulamayı açmak için PIN iste';

  @override
  String get appLockOnHint => 'Geçmiş, kişiler, mesajlar ve ayarlar kilitlenir';

  @override
  String get appLockIsOn => 'Uygulama kilidi açık';

  @override
  String get appLockIsOff => 'Uygulama kilidi kapalı';

  @override
  String get appLockTurnOff => 'Uygulama kilidini kapat';

  @override
  String get appLockChangePin => 'PIN\'i değiştir';

  @override
  String get appLockEnterCurrent => 'Geçerli PIN\'i girin';

  @override
  String get appLockPinChanged => 'PIN değiştirildi';

  @override
  String get appLockLockAfter => 'Kilitleme süresi';

  @override
  String get appLockLockAfterHint =>
      'PIN yeniden gerekmeden önce arka planda geçen süre';

  @override
  String get appLockImmediately => 'Hemen';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dakika',
      one: '1 dakika',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 saat';

  @override
  String get appLockBiometrics => 'Biyometrik verilerle kilidi aç';

  @override
  String get appLockNow => 'Şimdi kilitle';

  @override
  String get appLockSetPin => 'PIN belirleyin';

  @override
  String get appLockPinDigits => 'PIN (4-8 hane)';

  @override
  String get appLockRepeatPin => 'PIN\'i tekrarlayın';

  @override
  String get appLockUseDigits => '4 ila 8 hane kullanın';

  @override
  String get appLockMismatch => 'PIN\'ler eşleşmiyor';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Çok fazla deneme. $seconds sn sonra tekrar deneyin';
  }

  @override
  String get appLockWrongPin => 'Yanlış PIN';

  @override
  String get appLockTooMany => 'Çok fazla deneme';

  @override
  String get appLockIsLocked => 'SoftphonePro kilitli';

  @override
  String get appLockEnterPin => 'PIN\'inizi girin';

  @override
  String appLockTryAgainIn(String time) {
    return '$time sonra tekrar deneyin';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes dk $seconds sn';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds sn';
  }

  @override
  String get appLockUnlock => 'Kilidi aç';

  @override
  String get appLockIncomingCall => 'Gelen arama';

  @override
  String get appLockDecline => 'Reddet';

  @override
  String get appLockAnswer => 'Yanıtla';

  @override
  String get appLockHangUp => 'Kapat';

  @override
  String get appLockBiometricReason => 'SoftphonePro kilidini aç';

  @override
  String get automationNoToken =>
      'Erişim jetonu ayarlanmadı. Ayarlar > Gelişmiş bölümünden oluşturun.';

  @override
  String automationInvalidPort(int port) {
    return 'Geçersiz bağlantı noktası $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Başlatılamadı: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return '$port bağlantı noktası kullanılamıyor ($error). Başka bir bağlantı noktası seçin.';
  }

  @override
  String get automationTokenPlaceholder => 'API\'yi açtığınızda oluşturulur';

  @override
  String automationListening(String address) {
    return '$address adresinde dinleniyor';
  }

  @override
  String get automationStarting => 'Başlatılıyor...';

  @override
  String get automationTitle => 'Yerel otomasyon API\'si';

  @override
  String get automationFooter =>
      'Bu bilgisayardaki CRM ve yardım masası entegrasyonları içindir. Yalnızca 127.0.0.1 üzerinde dinler ve her istek erişim jetonu gerektirir. Bkz. docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Yerel otomasyon API\'sini etkinleştir';

  @override
  String get automationPort => 'Bağlantı noktası';

  @override
  String get automationPortHint =>
      'Varsayılan 7771. 1024 ile 65535 arasında boş bir bağlantı noktası seçin.';

  @override
  String get automationPortInvalid =>
      '1024 ile 65535 arasında bir bağlantı noktası girin';

  @override
  String get automationAccessToken => 'Erişim jetonu';

  @override
  String get automationHideToken => 'Jetonu gizle';

  @override
  String get automationShowToken => 'Jetonu göster';

  @override
  String get automationCopyToken => 'Jetonu kopyala';

  @override
  String get automationTokenCopied => 'Jeton kopyalandı';

  @override
  String get automationGenerateToken => 'Yeni jeton oluştur';

  @override
  String get automationGenerateTitle => 'Yeni jeton oluşturulsun mu?';

  @override
  String get automationGenerateBody =>
      'Eski jetonu kullanan programlar, yenisini verene kadar çalışmaz.';

  @override
  String get automationGenerate => 'Oluştur';

  @override
  String get automationOrigins => 'İzin verilen tarayıcı kaynakları';

  @override
  String get automationOriginsHint =>
      'Virgülle ayrılır, örneğin https://crm.example.com. Tarayıcısız programların (curl, betikler) buna ihtiyacı yoktur.';

  @override
  String automationNotOrigin(String origin) {
    return 'http(s) kaynağı değil: $origin';
  }

  @override
  String get trayNotificationAnswer => 'Yanıtla';

  @override
  String get trayNotificationDecline => 'Reddet';

  @override
  String get trayTooltipInCall => 'SoftphonePro - görüşmede';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count yeni';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - hesap yok (Uzakta)',
      'dnd': 'SoftphonePro - hesap yok (Rahatsız etmeyin)',
      'other': 'SoftphonePro - hesap yok',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total çevrimiçi (Uzakta)',
      'dnd': 'SoftphonePro - $online/$total çevrimiçi (Rahatsız etmeyin)',
      'other': 'SoftphonePro - $online/$total çevrimiçi',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'SoftphonePro\'yu gizle';

  @override
  String get trayShowApp => 'SoftphonePro\'yu göster';

  @override
  String trayNewOpenRecents(int count) {
    return '$count yeni - Son aramaları aç';
  }

  @override
  String get trayStatus => 'Durum';

  @override
  String get trayStatusAway => 'Uzakta';

  @override
  String get trayAccounts => 'Hesaplar';

  @override
  String get trayQuit => 'SoftphonePro\'dan çık';

  @override
  String get hotkeyAnswerCall => 'Aramayı yanıtla';

  @override
  String get hotkeyHangUp => 'Kapat';

  @override
  String get hotkeyMute => 'Sessize al / sesi aç';

  @override
  String get hotkeyFocusDialer => 'Tuş takımına odaklan';

  @override
  String get shortcutsGlobalTitle => 'Genel kısayollar';

  @override
  String get shortcutsGlobalFooter =>
      'Her uygulamada çalışır. Bir kombinasyonu zaten kullanan başka bir program, kaydedilmesini engelleyebilir.';

  @override
  String get shortcutsChange => 'Değiştir';

  @override
  String get shortcutsRestoreDefaults => 'Varsayılanları geri yükle';

  @override
  String get shortcutsMediaTitle => 'Kulaklık ve medya tuşları';

  @override
  String get shortcutsMediaFooter =>
      'Kulaklığın veya klavyenin oynat/duraklat düğmesi yalnızca arama çalarken ya da etkinken devralınır; diğer zamanlarda müzik çalarlarda kalır.';

  @override
  String get shortcutsMediaSwitch =>
      'Kulaklık/medya oynat-duraklat düğmesiyle yanıtla ve kapat';

  @override
  String get shortcutsMediaDuringCall => 'Görüşme sırasında düğme';

  @override
  String get shortcutsMediaHangsUp => 'Kapatır';

  @override
  String get shortcutsMediaMutes => 'Sessize alır / sesi açar';

  @override
  String get shortcutsInApp => 'Uygulamada';

  @override
  String get shortcutsFocusDialer => 'Tuş takımına odaklan';

  @override
  String get shortcutsHoldResume => 'Beklemeye al / sürdür';

  @override
  String get shortcutsTransfer => 'Aktar';

  @override
  String get shortcutsEndCall => 'Aramayı bitir';

  @override
  String get shortcutsNeedX11 =>
      'Genel kısayollar için X11 oturumu gerekir. Wayland, uygulamaların tuşları sistem genelinde yakalamasına izin vermez.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Bir harfe veya rakama Ctrl, Alt, Shift ya da $key ekleyin';
  }

  @override
  String get shortcutsPressNew => 'Yeni tuş kombinasyonuna basın';

  @override
  String get defaultHandlerChooseInSettings =>
      'Varsayılan uygulamalarda SIP, TEL ve CALLTO için SoftphonePro\'yu seçin';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro artık sip:, tel: ve callto: bağlantılarını açıyor';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return '$schemes için varsayılan değiştirilemedi';
  }

  @override
  String get defaultHandlerIntro =>
      'Tarayıcılardan ve diğer uygulamalardan gelen sip:, tel: ve callto: bağlantılarını açar';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro sip:, tel: ve callto: bağlantılarını işliyor';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Şu an: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'SoftphonePro\'yu sip:, tel: ve callto: bağlantıları için varsayılan uygulama yap';

  @override
  String get reliabilityTitle => 'Arka plan güvenilirliği';

  @override
  String get reliabilityMicrophone => 'Mikrofon';

  @override
  String get reliabilityAllowed => 'İzin verildi';

  @override
  String get reliabilityMicNeeded => 'Aramalarda konuşmak için gerekli';

  @override
  String get reliabilityNotifications => 'Bildirimler';

  @override
  String get reliabilityNotifNeeded =>
      'Gelen aramaları göstermek ve hizmeti görünür tutmak için gerekli';

  @override
  String get reliabilityFullScreen => 'Tam ekran gelen aramalar';

  @override
  String get reliabilityFullScreenNeeded =>
      'Aramaların kilit ekranında görünmesi için izin verin';

  @override
  String get reliabilityBattery => 'Kısıtlanmamış pil kullanımı';

  @override
  String get reliabilityBatteryExempt => 'Pil optimizasyonundan muaf';

  @override
  String get reliabilityBatteryNeeded =>
      'Android, güç tasarrufu için uygulamayı askıya alıp aramaları kaçırabilir. SoftphonePro\'yu muaf tutmak için dokunun.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer otomatik başlatma / korumalı uygulamalar';
  }

  @override
  String get reliabilityAutostartHint =>
      'Telefon üreticiniz arka plan uygulamalarını sonlandırabilir. SoftphonePro\'nun otomatik başlamasına izin verin.';

  @override
  String get reliabilityBoot => 'Açılışta başlat';

  @override
  String get reliabilityBootHint =>
      'Telefon yeniden başlayınca hesapları kaydet';

  @override
  String get reliabilityWake => 'Boştayken CPU\'yu uyanık tut';

  @override
  String get reliabilityWakeHint =>
      'Kısıtlayıcı cihazlarda daha güvenilir; daha fazla pil kullanır';

  @override
  String acctEditorDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String acctCodecRemove(String codec) {
    return '$codec codec\'ini kaldır';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Son hata: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'İzin verilen aralık $min ile $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'En az $min olmalı';
  }

  @override
  String acctValidateMax(int max) {
    return 'En fazla $max olmalı';
  }

  @override
  String get acctEditorDiscardTitle => 'Değişiklikler silinsin mi?';

  @override
  String get acctEditorDiscardMessage =>
      'Bu hesapta yaptığınız düzenlemeler kaydedilmedi.';

  @override
  String get acctEditorDiscardConfirm => 'Sil';

  @override
  String get acctEditorDeleteMessage =>
      'Hesap ve kayıtlı parolası bu cihazdan kaldırılacak.';

  @override
  String get acctEditorMenuDelete => 'Hesabı sil';

  @override
  String get acctGroupBasic => 'Temel';

  @override
  String get acctFieldLabel => 'Etiket';

  @override
  String get acctFieldLabelHint => 'örn. Ofis';

  @override
  String get acctFieldDisplayName => 'Görünen ad';

  @override
  String get acctFieldUsername => 'Kullanıcı adı';

  @override
  String get acctFieldProtocol => 'Protokol';

  @override
  String get acctFieldProtocolSub => 'Hesap oluşturulurken sabitlenir';

  @override
  String get acctFieldAuthUser => 'Yetkilendirme kullanıcısı';

  @override
  String get acctFieldAuthUserHint => 'Kullanıcı adıyla aynı';

  @override
  String get acctFieldAuthUserSub =>
      'Yalnızca sağlayıcı, kullanıcı adından farklı bir oturum adı kullanıyorsa';

  @override
  String get acctFieldPassword => 'Parola';

  @override
  String get acctFieldServerHost => 'Sunucu ana makinesi';

  @override
  String get acctFieldPort => 'Bağlantı noktası';

  @override
  String get acctFieldIaxPortSub => 'IAX2 varsayılanı 4569';

  @override
  String get acctFieldIaxContext => 'Bağlam';

  @override
  String get acctFieldIaxContextSub =>
      'İsteğe bağlı. Santrale aranan bağlam olarak gönderilir';

  @override
  String get acctFieldServerDomain => 'Sunucu / alan adı';

  @override
  String get acctFieldServerDomainSub =>
      'ana makine veya ana makine:bağlantı noktası';

  @override
  String get acctFieldEnabled => 'Etkin';

  @override
  String get acctFieldDefault => 'Giden aramalar için varsayılan hesap';

  @override
  String get acctFieldColour => 'Renk';

  @override
  String get acctGroupRegistration => 'Kayıt';

  @override
  String get acctFieldRegister => 'Kaydol';

  @override
  String get acctFieldRegisterSubIax =>
      'Kayıt gerektirmeyen eşler için kapatın';

  @override
  String get acctFieldRegExpiry => 'Kayıt süresi (sn)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk genellikle 60 sn zorlar. Aralık 10 ile 86400';

  @override
  String get acctFieldRetryInterval => 'Yeniden deneme aralığı (sn)';

  @override
  String get acctFieldFirstRetry => 'İlk yeniden deneme (sn)';

  @override
  String get acctGroupCodecs => 'Codec\'ler';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2, G.711 ve GSM\'i destekler. Tercih sırasını belirlemek için sürükleyin.';

  @override
  String get acctCodecAdd => 'Codec ekle';

  @override
  String get acctGroupServerTransport => 'Sunucu ve aktarım';

  @override
  String get acctFieldRegistrar => 'Kayıt sunucusunu geçersiz kıl';

  @override
  String get acctFieldBackupRegistrar => 'Yedek kayıt sunucusu';

  @override
  String get acctFieldBackupRegistrarSub =>
      '3 başarısız denemeden sonra kullanılır; birincil sunucu her 5 dakikada bir yeniden denenir';

  @override
  String get acctFieldProxies => 'Giden proxy sunucuları';

  @override
  String get acctFieldTransport => 'Aktarım';

  @override
  String get acctFieldTransportAutoSub =>
      'Sunucunun DNS SRV kayıtlarına bakar ve TLS, TCP veya UDP\'yi seçer';

  @override
  String get acctTransportAuto => 'Otomatik (DNS SRV)';

  @override
  String get acctFieldWsPath => 'WebSocket yolu';

  @override
  String get acctFieldWsPathSub =>
      'WebSocket yükseltmesinin HTTP yolu, örn. /ws. \"/\" ile başlamalı';

  @override
  String get acctFieldRegExpirySubSip =>
      '300 ile 3600 arası tipiktir. Aralık 10 ile 86400';

  @override
  String get acctFieldKeepAlive => 'Canlı tutma (sn)';

  @override
  String get acctFieldKeepAliveSub =>
      'UDP canlı tutma aralığı. 0 kapatır. Aralık 0 ile 3600';

  @override
  String get acctFieldLocalPort => 'Yerel SIP bağlantı noktası';

  @override
  String get acctFieldLocalPortSub =>
      '0 paylaşılan aktarımı kullanır. Aralık 0 ile 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Kayıt gerektirmeyen trunk\'lar için kapatın';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'NAT üzerinden kalıcı bir akış sürdürür. Sunucu desteği gerekir';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'STUN kullan';

  @override
  String get acctFieldTurn => 'TURN aktarıcısı';

  @override
  String get acctFieldTurnServer => 'TURN sunucusu';

  @override
  String get acctFieldTurnUsername => 'TURN kullanıcı adı';

  @override
  String get acctFieldTurnPassword => 'TURN parolası';

  @override
  String get acctFieldContactRewrite => 'Contact başlığını yeniden yaz';

  @override
  String get acctFieldViaRewrite => 'Via başlığını yeniden yaz';

  @override
  String get acctFieldRewriteSub =>
      'Sunucunun gördüğü adresi kullan. NAT arkasında açık tutun';

  @override
  String get acctFieldSdpRewrite => 'SDP adresini yeniden yaz';

  @override
  String get acctFieldSdpRewriteSub =>
      'SDP içindeki medya adresini genel adresle değiştir';

  @override
  String get acctFieldIpv6Sip => 'IPv6 sinyalleşme';

  @override
  String get acctFieldIpv6Media => 'IPv6 medya';

  @override
  String get acctGroupAdvancedMedia => 'Gelişmiş medya';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTC ağ geçitleri RTCP çoklamayı ve RTCP geri bildirimini gerektirir.';

  @override
  String get acctFieldRtcpMux => 'RTCP çoklama';

  @override
  String get acctFieldRtcpMuxSub =>
      'RTP ve RTCP\'yi tek bağlantı noktasından gönder (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'RTCP geri bildirimi (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'NACK ile RTP/AVPF öner. WebRTC sunucuları için gerekli';

  @override
  String get acctGroupSecurity => 'Güvenlik';

  @override
  String get acctFieldSrtp => 'Medya şifreleme (SRTP)';

  @override
  String get acctOptOptional => 'İsteğe bağlı';

  @override
  String get acctOptRequired => 'Zorunlu';

  @override
  String get acctFieldKeyExchange => 'Anahtar değişimi';

  @override
  String get acctFieldSecureSignaling => 'Güvenli sinyalleşme';

  @override
  String get acctOptNotRequired => 'Gerekli değil';

  @override
  String get acctOptTlsHop => 'TLS adım adım';

  @override
  String get acctOptTlsE2e => 'TLS uçtan uca (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Kimlik doğrulama algoritması';

  @override
  String get acctFieldPrivacy => 'Arayan kimliğini gizle (gizlilik)';

  @override
  String get acctFieldReferPolicy => 'Gelen aktarmalar (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Durum izleyicileri';

  @override
  String get acctOptAccept => 'Kabul et';

  @override
  String get acctOptReject => 'Reddet';

  @override
  String get acctGroupCodecsFooter =>
      'Bu hesap için genel codec listesini geçersiz kılar.';

  @override
  String get acctFieldUseGlobalCodecs => 'Genel codec sırasını kullan';

  @override
  String get acctGroupFeatures => 'Özellikler';

  @override
  String get acctFieldVoicemailNumber => 'Sesli mesaj numarası';

  @override
  String get acctFieldMwi => 'Sesli mesaj göstergesi (MWI)';

  @override
  String get acctFieldMwiSub => 'Bekleyen mesaj bildirimlerine abone ol';

  @override
  String get acctFieldPublishPresence => 'Durumumu yayınla';

  @override
  String get acctFieldPublishPresenceSub =>
      'Sunucunun çevrimiçi durumunuzu paylaşmasına izin ver';

  @override
  String get acctFieldDnd => 'Rahatsız etmeyin';

  @override
  String get acctFieldForwarding => 'Çağrı yönlendirme';

  @override
  String get acctOptForwardAlways => 'Her zaman';

  @override
  String get acctOptForwardBusy => 'Meşgulken';

  @override
  String get acctOptForwardNoAnswer => 'Yanıt yoksa';

  @override
  String get acctFieldForwardTo => 'Yönlendirilecek yer';

  @override
  String get acctFieldForwardToHint => 'Numara veya SIP adresi';

  @override
  String get acctFieldRingFor => 'Çalma süresi (sn)';

  @override
  String get acctFieldAutoAnswer => 'Otomatik yanıt';

  @override
  String get acctFieldAnswerAfter => 'Yanıtlama süresi (sn)';

  @override
  String get acctFieldIntercomOnly => 'Yalnızca interkom aramaları için';

  @override
  String get acctFieldIntercomOnlySub =>
      'Santralden bir otomatik yanıt başlığı gerekir';

  @override
  String get acctFieldRingtone => 'Zil sesi';

  @override
  String get acctRingtoneClassic => 'Klasik';

  @override
  String get acctRingtoneSoft => 'Yumuşak';

  @override
  String get acctRingtoneDigital => 'Dijital';

  @override
  String get acctFieldRecordCalls => 'Aramaları kaydet';

  @override
  String get acctFieldHoldMusic => 'Bekleme müziği';

  @override
  String get acctOptUseGlobal => 'Genel ayarı kullan';

  @override
  String get acctOptPbxDefault => 'Santral varsayılanı';

  @override
  String get acctFieldOpeningAnnouncement => 'Karşılama anonsu';

  @override
  String get acctGroupFeatureCodes => 'Özellik kodları';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Santralinizde park etme, yanıt alma, Rahatsız etmeyin ve yönlendirme için çevrilir.';

  @override
  String get acctFieldPark => 'Park et';

  @override
  String get acctFieldGroupPickup => 'Grup yanıtlama';

  @override
  String get acctFieldDirectedPickup => 'Hedefli yanıtlama öneki';

  @override
  String get acctFieldParkRetrieve => 'Park aramasını alma öneki';

  @override
  String get acctFieldParkRetrieveHint => 'Yuva numarasını çevirin';

  @override
  String get acctFieldParkRetrieveSub =>
      'Park edilmiş aramayı geri almak için park yuvasından önce çevrilen önek';

  @override
  String get acctFieldDndOn => 'Rahatsız etmeyin açık';

  @override
  String get acctFieldDndOff => 'Rahatsız etmeyin kapalı';

  @override
  String get acctFieldForwardOn => 'Yönlendirme açık';

  @override
  String get acctFieldForwardOff => 'Yönlendirme kapalı';

  @override
  String get acctGroupAdvanced => 'Gelişmiş';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF yerel IAX2 çerçeveleri olarak gönderilir.';

  @override
  String get acctFieldCallerIdOverride => 'Arayan kimliğini geçersiz kıl';

  @override
  String get acctFieldCallerIdHint => 'Hesap varsayılanını kullan';

  @override
  String get acctFieldCallerIdSub =>
      'Santrale gönderilen arayan kimliği adı veya numarası';

  @override
  String get acctFieldSessionTimers => 'Oturum zamanlayıcıları';

  @override
  String get acctFieldSessionExpires => 'Oturum süresi (sn)';

  @override
  String get acctFieldSessionExpiresSub => 'Aralık 90 ile 86400';

  @override
  String get acctField100rel => '100rel (güvenilir geçici yanıt)';

  @override
  String get acctFieldHoldMethod => 'Bekletme yöntemi';

  @override
  String get acctFieldDtmfMethod => 'DTMF yöntemi';

  @override
  String get acctOptDtmfInband => 'Bant içi';

  @override
  String get acctFieldRedirects => 'Yönlendirmeler (3xx)';

  @override
  String get acctOptRedirectFollow => 'Takip et';

  @override
  String get acctOptRedirectAsk => 'Sor';

  @override
  String get acctFieldLockCodec => 'Yanıttan sonra codec\'i kilitle';

  @override
  String get acctFieldMediaKeepAlive => 'Medya canlı tutma';

  @override
  String get acctFieldDropCalls => 'Kayıt başarısız olunca aramaları düşür';

  @override
  String get acctFieldExtraHeaders => 'Ek SIP başlıkları';

  @override
  String get acctFieldExtraHeadersHint =>
      'X-Header: değer (satır başına bir tane)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Başarısız bir kaydı yeniden denemeden önce bekleme. Aralık 0 ile 86400';

  @override
  String get acctFieldUnregTimeout => 'Kayıt silme zaman aşımı (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Kayıt silme yanıtı için ne kadar beklenecek. Aralık 0 ile 60000';

  @override
  String get acctFieldMwiExpiry => 'MWI abonelik süresi (sn)';

  @override
  String get acctFieldDscpSip => 'SIP için DSCP';

  @override
  String get acctFieldDscpSipSub =>
      'Sinyalleşmenin QoS işaretlemesi. 24 (CS3) tipiktir';

  @override
  String get acctFieldDscpRtp => 'RTP için DSCP';

  @override
  String get acctFieldDscpRtpSub =>
      'Medyanın QoS işaretlemesi. 46 (EF) tipiktir';

  @override
  String get acctFieldReinvite => 'Ağ değişince yeniden INVITE';

  @override
  String get acctFieldHangupOnIpChange => 'Ağ değişince aramaları kapat';

  @override
  String get acctValidateInt => 'Tam sayı girin';

  @override
  String get acctValidateHostEmpty => 'Sunucu ana makine adı veya adresi girin';

  @override
  String get acctValidateHostSpaces => 'Sunucu boşluk içeremez';

  @override
  String get acctValidateHostFormat =>
      'Yalnızca ana makine veya ana makine:bağlantı noktası girin';

  @override
  String get acctValidatePortRange =>
      'Bağlantı noktası 1 ile 65535 arasında olmalı';

  @override
  String get acctValidateWsStart => 'Yol \"/\" ile başlamalı';

  @override
  String get acctValidateWsLength => 'En fazla 120 karakter kullanın';

  @override
  String get acctValidateWsSpaces => 'Yol boşluk içeremez';

  @override
  String get acctTplAsteriskDescription =>
      'Kendi santralinizdeki dahili hat. UDP 5060, STUN açık.';

  @override
  String get acctTplAsteriskNotes =>
      'PJSIP/SIP dahili numarasını ve parolasını (secret) kullanın. TLS veya WebRTC için aktarımı sonradan hesap ayarlarından değiştirin.';

  @override
  String get acctTplAsteriskUsernameHint => 'Dahili (örn. 1001)';

  @override
  String get acctTpl3cxDescription =>
      '3CX portalındaki dahili numarayı, kimlik doğrulama kimliğini ve parolayı kullanın.';

  @override
  String get acctTpl3cxNotes =>
      '3CX\'te dahili hattı açın, ardından Kimlik Doğrulama Kimliği (Yetkilendirme kullanıcısı olarak ayarlayın) ve parola için \"Phones > Provisioning\" bölümüne gidin. FQDN, 3CX URL\'nizdeki adrestir.';

  @override
  String get acctTpl3cxUsernameHint => 'Dahili';

  @override
  String get acctTplFreeswitchDescription =>
      'FreeSWITCH sunucusundaki dizin kullanıcısı.';

  @override
  String get acctTplFreeswitchNotes =>
      'Dizindeki kullanıcı kimliğini ve parolayı kullanın. Varsayılan dahili profil UDP/TCP 5060 üzerinde dinler.';

  @override
  String get acctTplFreeswitchUsernameHint => 'Kullanıcı kimliği';

  @override
  String get acctTplKamailioDescription =>
      'SIP proxy kayıt sunucusu. NAT arkasında TCP önerilir.';

  @override
  String get acctTplKamailioNotes =>
      'Kayıt sunucunuzun hizmet verdiği SIP alan adını kullanın. Kayıt sunucusuna farklı bir ana makine üzerinden ulaşılıyorsa hesap ayarlarına bir giden proxy ekleyin.';

  @override
  String get acctTplTwilioDescription =>
      'Programmable Voice SIP Domain kimlik bilgileri. TLS ve SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Twilio konsolunda bir SIP Domain oluşturun, bir Credential List ekleyin ve SIP Registration\'ı etkinleştirin. Sunucu olarak tam alan adını (name.sip.twilio.com), kullanıcı olarak da kimlik listesindeki kullanıcıyı ve parolasını girin. TLS 5061 numaralı bağlantı noktasını kullanır. Twilio yalnızca G.711\'i destekler.';

  @override
  String get acctTplTwilioUsernameHint => 'Kimlik listesi kullanıcı adı';

  @override
  String get acctTplTelnyxDescription =>
      'Kimlik bilgili bağlantı. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Telnyx portalında bir Credential Connection oluşturun ve SIP kullanıcı adını ile parolasını kopyalayın (portal girişiniz değil). Arama yapmak ve almak için bağlantıya bir numara veya giden ses profili atayın.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP kullanıcı adı (kimlik bilgili bağlantı)';

  @override
  String get acctTplVoipmsDescription =>
      'Alt hesap kullanıcı adı ve parolası. Size en yakın POP\'u seçin.';

  @override
  String get acctTplVoipmsNotes =>
      'Ana hesabınızı değil, Sub Accounts altında oluşturulmuş bir alt hesabı kullanın. VoIP.ms sunucu listesinden size en yakın sunucuyu (POP) seçin ve gerekiyorsa IP adresiniz için izin verin.';

  @override
  String get acctTplVoipmsUsernameHint => 'Alt hesap (örn. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'TLS ile SIP kaydı.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business, SIP kaydını yalnızca bazı paketlerde sunar. Vonage yönetim portalında cihaz için gösterilen SIP sunucusunu, kullanıcıyı ve parolayı girin.';

  @override
  String get acctTplIax2Description =>
      'UDP 4569 üzerinden Inter-Asterisk eXchange. NAT veya SRTP ayarı yok.';

  @override
  String get acctTplIax2Notes =>
      'iax.conf içinde aynı parolaya sahip bir eş/kullanıcı gerekir (type=friend veya user+peer). Asterisk, IAX2 kayıtlarını varsayılan olarak her 60 sn\'de bir yeniler. Bağlam isteğe bağlıdır ve aranan bağlam olarak gönderilir.';

  @override
  String get acctTplIax2UsernameHint => 'IAX2 kullanıcı adı';

  @override
  String get acctTplWebrtcDescription =>
      'DTLS-SRTP, ICE ve RTCP-mux ile güvenli WebSocket üzerinden SIP.';

  @override
  String get acctTplWebrtcNotes =>
      'Asterisk (webrtc=yes, http.conf içinde 8089 üzerinde TLS), FreeSWITCH veya Kamailio WebSocket uç noktaları için. Sunucunun geçerli bir TLS sertifikası olmalıdır. Ağ geçidiniz /ws kullanmıyorsa WebSocket yolunu hesap ayarlarından değiştirin.';

  @override
  String get acctTplGenericDescription =>
      'Herhangi bir SIP kayıt sunucusu. Ayrıntıları kendiniz doldurun.';

  @override
  String get acctTplDefaultUsernameHint => 'Dahili / kullanıcı adı';

  @override
  String get appEngineFailedBody =>
      'Bu sorun giderilene kadar aramalar ve kayıt çalışmaz. Genellikle nedeni hatalı bir ağ veya sertifika ayarıdır.';

  @override
  String get appEngineFailedTitle => 'Arama altyapısı başlatılamadı';

  @override
  String get appEngineNotRunning => 'Arama altyapısı çalışmıyor';

  @override
  String get appUnknownError => 'Bilinmeyen hata';

  @override
  String get appEngineOpenNetworkSettings => 'Ağ ayarlarını aç';

  @override
  String get appEngineUseSimulator => 'Simülatörü kullan (demo)';

  @override
  String get appDbLockedTitle => 'Verileriniz kilitli';

  @override
  String get appDbUnreadableTitle => 'Verileriniz açılamıyor';

  @override
  String get appDbLockedBody =>
      'Arama geçmişi, kişiler ve mesajlar bu cihazda şifrelidir, ancak şifreleme anahtarı artık sistem anahtar zincirinde / anahtar deposunda değil (örneğin anahtar zinciri sıfırlandıktan veya yeni bir cihaza geri yüklendikten sonra).';

  @override
  String get appDbUnreadableBody =>
      'Yerel veritabanı okunamadı. Hasarlı olabilir ya da şifreleme anahtarı eşleşmiyor olabilir.';

  @override
  String get appDbRecoveryAdvice =>
      'Anahtarın geri geleceğini düşünüyorsanız yeniden deneyin (anahtar zincirinin kilidini açın, doğru kullanıcıyla oturum açın). Sıfırdan başlamak eski dosyayı uygulama verilerinin yanında tutar ancak boş bir geçmiş, kişiler ve mesajlarla başlar; hesaplarınızı yeniden eklemeniz gerekir.';

  @override
  String get appDbCopyDetails => 'Ayrıntıları kopyala';

  @override
  String get appDbTryAgain => 'Yeniden dene';

  @override
  String get appDbStartFresh => 'Sıfırdan başla';

  @override
  String get appRedirectTitle => 'Arama yönlendirildi';

  @override
  String appRedirectMessage(String target) {
    return 'Arama $target adresine yönlendirildi - takip edilsin mi?';
  }

  @override
  String get appRedirectCancelCall => 'Aramayı iptal et';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Verileriniz şifrelenemedi ($error). Hiçbir şey değiştirilmedi.',
      'other':
          'Verilerinizin şifresi çözülemedi ($error). Hiçbir şey değiştirilmedi.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Yerel altyapı kullanılamıyor ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return '$time saatinde yeniden denenecek';
  }

  @override
  String get acctRegistrationError => 'Kayıt hatası';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nAktarım: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Doğrudan arama, hesapsız';

  @override
  String acctCallingFromAccount(String name) {
    return '$name ile aranıyor';
  }

  @override
  String get acctCallingFromNone => 'Hesapsız aranıyor';

  @override
  String get acctNoAccount => 'Hesap yok';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds sn';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount yeni, $oldCount eski';
  }

  @override
  String get acctAddAccount => 'Hesap ekle';

  @override
  String get acctUnregister => 'Kaydı sil';

  @override
  String get acctSheetDndSub => 'Bu hesaptaki gelen aramaları reddet';

  @override
  String get acctKvServer => 'Sunucu';

  @override
  String get acctKvResolvedServer => 'Çözümlenen sunucu';

  @override
  String get acctKvClientCert => 'İstemci sert.';

  @override
  String get acctKvClientCertValue => 'Sunucuya sunuldu (karşılıklı TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Bitiş süresi';

  @override
  String get acctKvVoicemail => 'Sesli mesaj';

  @override
  String get acctOpenSipTrace => 'SIP izini aç';

  @override
  String get acctAddAnAccount => 'Hesap ekle';

  @override
  String get acctChooseAccountTooltip => 'Arama yapılacak hesabı seçin';

  @override
  String get acctDirectNoAccount => 'Doğrudan (hesapsız)';

  @override
  String get onboardingRequired => 'Kullanıcı adı ve sunucu gerekli';

  @override
  String onboardingDefaultPortHelper(int port) {
    return ':bağlantı noktası eklemezseniz $port kullanılır';
  }

  @override
  String get onboardingFineTuneIax =>
      'Codec\'leri ve kaydı sonradan Ayarlar\'dan ince ayarlayabilirsiniz.';

  @override
  String get onboardingFineTuneSip =>
      'Aktarımı, NAT\'ı, güvenliği ve codec\'leri sonradan Ayarlar\'dan ince ayarlayabilirsiniz.';

  @override
  String get onboardingDemoUser => 'Demo kullanıcı';

  @override
  String get onboardingDemoAccount => 'Demo hesap';

  @override
  String get onboardingWelcomeTitle => 'SoftphonePro\'ya hoş geldiniz';

  @override
  String get onboardingWelcomeText =>
      'Her platform için profesyonel arama - ücretsiz ve açık kaynak. Reklam yok, izleme yok.';

  @override
  String get onboardingGetStarted => 'Başla';

  @override
  String get onboardingPermissionsTitle => 'İzinler';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro, sesinizi iletmek için mikrofona, gelen aramalar ve mesajlar hakkında sizi bilgilendirmek için de bildirimlere ihtiyaç duyar. Aramalarınız dışında hiçbir şey cihazınızdan çıkmaz.';

  @override
  String get onboardingChooseProvider => 'Sağlayıcınızı seçin';

  @override
  String get onboardingChooseProviderSub =>
      'Aktarım, bağlantı noktaları ve NAT ayarlarını sizin için önceden dolduruyoruz.';

  @override
  String get onboardingScanQr => 'QR tara';

  @override
  String get onboardingImportUrl => 'URL\'den içe aktar';

  @override
  String get onboardingSkip => 'Şimdilik atla (demo modu)';

  @override
  String get onboardingHidePassword => 'Parolayı gizle';

  @override
  String get onboardingShowPassword => 'Parolayı göster';

  @override
  String get onboardingContextOptional => 'Bağlam (isteğe bağlı)';

  @override
  String get onboardingDisplayNameOptional => 'Görünen ad (isteğe bağlı)';

  @override
  String get onboardingLabelOptional => 'Hesap etiketi (isteğe bağlı)';

  @override
  String get onboardingCallerIdOptional => 'Arayan kimliği (isteğe bağlı)';

  @override
  String get onboardingAuthUserOptional =>
      'Yetkilendirme kullanıcısı (farklıysa)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Kullanıcı adı veya parola yanlış ($code)';
  }

  @override
  String get acctRegNotFound => 'Hesap sunucuda bulunamadı (404)';

  @override
  String get acctRegNoAnswer => 'Sunucu yanıt vermedi (408)';

  @override
  String get acctRegIntervalTooShort => 'Kayıt aralığı çok kısa (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Sunucu geçici olarak kullanılamıyor (480)';

  @override
  String get acctRegServiceUnavailable => 'Hizmet kullanılamıyor (503)';

  @override
  String get acctRegFailed => 'Kayıt başarısız oldu';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Kayıt başarısız oldu ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'Kayıt değiştirilemedi';

  @override
  String acctNoticeApplyFailed(String name) {
    return '\"$name\" hesabı uygulanamadı';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return '$name için birincil sunucuya dönüldü';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return '$name için yedek sunucu kullanılıyor';
  }

  @override
  String callDialAccountRegistered(String name) {
    return '$name hesabı kayıtlı';
  }

  @override
  String callDialAccountRegistering(String name) {
    return '$name hesabı hâlâ kaydoluyor';
  }

  @override
  String callDialAccountOffline(String name) {
    return '$name hesabı henüz kayıtlı değil';
  }

  @override
  String callDialAccountFailed(String name) {
    return '$name hesabı kayıtlı değil (kayıt başarısız)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return '$name hesabı devre dışı';
  }

  @override
  String get callDialEngineFailed => 'Arama altyapısı başlatılamadı';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'Arama altyapısı başlatılamadı: $reason';
  }

  @override
  String get callDialEngineStarting => 'Arama altyapısı hâlâ başlıyor';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status, $seconds sn sonra; arama yapılmadı';
  }

  @override
  String get callJournalInterrupted => 'Uygulama görüşme sırasında kapatıldı';

  @override
  String get callLinkMissingArgument => 'Eksik bağımsız değişken';

  @override
  String get callLinkHttpsRequired =>
      'Yapılandırma bağlantıları https kullanmalı';

  @override
  String get callLinkInvalidLan => 'Bu LAN bağlantısı geçerli değil';

  @override
  String callLinkConnectedTo(String name) {
    return '$name cihazına bağlanıldı';
  }

  @override
  String get callLinkConnectFailed => 'Bu cihaza bağlanılamadı';

  @override
  String callLinkCallFailed(String target) {
    return '$target aranamadı';
  }

  @override
  String get callLinkImportTitle => 'Yapılandırmayı içe aktar';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts hesap',
      one: '1 hesap',
    );
    return 'Yapılandırma $host kaynağından içe aktarılsın mı? $_temp0 eklenecek.';
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
      other: '$accounts hesap',
      one: '1 hesap',
    );
    return 'Yapılandırma $host kaynağından içe aktarılsın mı? $_temp0 ve $settings ayar eklenecek.';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return '$number numarasından yönlendirildi';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return '$number numarasından yönlendirildi ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return '$number tarafından aktarıldı';
  }

  @override
  String get callRingtoneSystemDefault => 'Sistem varsayılanı';

  @override
  String get callRingtoneClassic => 'Klasik';

  @override
  String get callRingtoneSoft => 'Yumuşak';

  @override
  String get callRingtoneDigital => 'Dijital';

  @override
  String callIdentityFrom(String number) {
    return 'Arayan: $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Arayan kimliği $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Arayan kimliği $name $number';
  }

  @override
  String get callTransferring => 'Aktarılıyor...';

  @override
  String get callTransferNotConfirmed =>
      'Aktarma sunucu tarafından onaylanmadı';

  @override
  String get callTransferStalledHint =>
      'Arama hâlâ sürüyor. Koruyun veya aktarmayı yeniden gönderin.';

  @override
  String get callTransferKeepCall => 'Aramayı koru';

  @override
  String get callAnnouncementOpening => 'Anons çalınıyor…';

  @override
  String get callAnnouncementTransfer => 'Aktarma bildirimi çalınıyor…';

  @override
  String get callAnnouncementRecording => 'Kayıt bildirimi çalınıyor…';

  @override
  String get callAnnouncementSkip => 'Atla';

  @override
  String get callNoiseTooltipMic =>
      'Yapay zekâ gürültü engelleme: mikrofonunuz';

  @override
  String get callNoiseTooltipIncoming =>
      'Yapay zekâ gürültü engelleme: diğer katılımcılar';

  @override
  String get callNoiseTooltipBoth =>
      'Yapay zekâ gürültü engelleme: mikrofonunuz ve diğer katılımcılar';

  @override
  String get callNoiseOn => 'Gürültü engelleme açık';

  @override
  String get callNoiseTitle => 'Gürültü engelleme';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Mikrofonum: $strength';
  }

  @override
  String get callNoiseMicOffHint =>
      'Mikrofonumdaki arka plan gürültüsünü kaldır';

  @override
  String get callResultAnswered => 'Yanıtlandı';

  @override
  String get callResultMissed => 'Cevapsız';

  @override
  String get callResultRejected => 'Reddedildi';

  @override
  String get callResultFailed => 'Başarısız';

  @override
  String get callResultBusy => 'Meşgul';

  @override
  String get callResultForwarded => 'Yönlendirildi';

  @override
  String get callResultTransferred => 'Aktarıldı';

  @override
  String get callResultHandedOff => 'Devredildi';

  @override
  String get callResultInterrupted => 'Kesintiye uğradı';

  @override
  String get keypadCall => 'Ara';

  @override
  String get keypadNoVoicemail =>
      'Bu hesap için sesli mesaj numarası yapılandırılmadı';

  @override
  String get keypadCallDirectly => 'Doğrudan ara (hesapsız)';

  @override
  String get keypadAddAccount => 'Arama yapmak için hesap ekleyin';

  @override
  String keypadCallFrom(String account) {
    return '$account ile ara';
  }

  @override
  String get keypadRecent => 'Son';

  @override
  String get keypadSuggestions => 'Öneriler';

  @override
  String get keypadPhoneNumber => 'Telefon numarası';

  @override
  String get keypadPaste => 'Yapıştır';

  @override
  String get keypadEnterNumber => 'Numara girin';

  @override
  String get keypadBackspace => 'Geri sil (temizlemek için uzun basın)';

  @override
  String get keypadTypeNameOrNumber => 'Ad veya numara yazın';

  @override
  String get keypadNoMatches => 'Eşleşme yok';

  @override
  String get keypadSuggestionsHint =>
      'Öneriler kişilerden ve son aramalardan gelir';

  @override
  String keypadCallPerson(String name) {
    return '$name kişisini ara';
  }

  @override
  String get dialKeyStar => 'Yıldız';

  @override
  String get dialKeyPound => 'Diyez';

  @override
  String get dialKeyLongPressPlus => 'Artı için uzun basın';

  @override
  String get dialKeyLongPressSpeedDial => 'Hızlı arama için uzun basın';

  @override
  String get dialKeyLongPressVoicemail => 'Sesli mesaj için uzun basın';

  @override
  String get callBackToApp => 'Uygulamaya dön (arama sürer)';

  @override
  String get callRecBadge => 'KAYIT';

  @override
  String get callHideKeypad => 'Tuş takımını gizle';

  @override
  String get callMute => 'Sessiz';

  @override
  String get callKeypad => 'Tuş takımı';

  @override
  String get callSpeaker => 'Hoparlör';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Kulaklık';

  @override
  String get callResume => 'Sürdür';

  @override
  String get callHold => 'Beklet';

  @override
  String get callAddCall => 'Arama ekle';

  @override
  String get callTransfer => 'Aktar';

  @override
  String get callStop => 'Durdur';

  @override
  String get callRecord => 'Kaydet';

  @override
  String get callSplit => 'Ayır';

  @override
  String get callMerge => 'Birleştir';

  @override
  String get callSwap => 'Değiştir';

  @override
  String get callEndCall => 'Aramayı bitir';

  @override
  String callEndCallWith(String name) {
    return '$name ile aramayı bitir';
  }

  @override
  String get callAttendedTransferHint =>
      'Danışmalı aktarma. Asıl arayan beklemede.';

  @override
  String get callCompleteTransfer => 'Aktarmayı tamamla';

  @override
  String get callWaiting => 'Çağrı bekletme';

  @override
  String get callHoldAndAnswer => 'Mevcut aramayı beklet ve yanıtla';

  @override
  String get callDecline => 'Reddet';

  @override
  String get callAnswer => 'Yanıtla';

  @override
  String get callIncomingCall => 'Gelen arama';

  @override
  String get callReply => 'Mesajla yanıtla';

  @override
  String get callVoicemail => 'Sesli mesaj';

  @override
  String get callToDevice => 'Cihaza';

  @override
  String get callQuickReplyBusy => 'Şu an konuşamıyorum, sizi sonra ararım.';

  @override
  String get callQuickReplyMeeting => 'Toplantıdayım. Mesaj atar mısınız?';

  @override
  String get callQuickReplyOnMyWay => 'Yoldayım.';

  @override
  String callReturnToCallWith(String name) {
    return '$name ile aramaya dön';
  }

  @override
  String callBarIncoming(String name) {
    return 'Gelen: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return '$name ile görüşmede';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Paket kaybı';

  @override
  String get callStatsRoundTrip => 'Gidiş-dönüş';

  @override
  String get callStatsMedia => 'Medya';

  @override
  String get callStatsMosHistory => 'MOS geçmişi';

  @override
  String get callQualityTitle => 'Arama kalitesi';

  @override
  String get callTransferTitle => 'Aramayı aktar';

  @override
  String get callTransferModeBlind => 'Doğrudan';

  @override
  String get callTransferModeAttended => 'Danışmalı';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN cihazı';

  @override
  String get callTransferNoLanDevices =>
      'Ağınızda eşleşmiş SoftphonePro cihazı bulunamadı. LAN sayfasında bir cihaz eşleştirin.';

  @override
  String get callTransferLanDisabled =>
      'Bu aramayı ağınızdaki başka bir cihaza devretmek için LAN Link\'i açın (Ayarlar, LAN Link).';

  @override
  String get callTransferTalkFirst => 'Önce konuş';

  @override
  String get callTransferBlindHint =>
      'Arayanı hemen devreder. Bağlantınız kesilir.';

  @override
  String get callTransferAttendedHint =>
      'Arayanı beklemeye alır ve önce hedefi arar. Yanıt verdiğinde aktarmayı tamamlayın.';

  @override
  String get callTransferNumberLabel => 'Numara veya SIP adresi';

  @override
  String get callTransferNow => 'Şimdi aktar';

  @override
  String get callTransferCallAndConsult => 'Ara ve danış';

  @override
  String get callRetrieveParkedTitle => 'Park edilen aramayı al';

  @override
  String get callRetrieveParkedHint => 'Park yuvası, örn. 701';

  @override
  String get callMoreAudioOutput => 'Ses çıkışı';

  @override
  String get callMoreAudioDevices => 'Ses cihazları';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefon, hoparlör, Bluetooth, kulaklık';

  @override
  String get callMoreAudioDevicesSubtitle => 'Mikrofon ve hoparlör seçin';

  @override
  String get callMoreParkCall => 'Aramayı park et';

  @override
  String get callMoreParkCallSubtitle => 'Park özellik koduna aktar';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Park yuvasını arayın';

  @override
  String get callMoreSendDtmf => 'DTMF rakamları gönder';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Bir diziyi toptan yazın, örn. bir PIN';

  @override
  String get callSendDtmfTitle => 'DTMF gönder';

  @override
  String get callMoreCallInfo => 'Arama bilgisi';

  @override
  String get callMoreQualitySubtitle =>
      'Canlı MOS, jitter, kayıp ve gidiş-dönüş süresi';

  @override
  String get callMoreSipTrace => 'SIP izi';

  @override
  String get callMoreSipTraceSubtitle => 'Bu aramanın merdiven diyagramı';

  @override
  String get callInfoRemote => 'Karşı taraf';

  @override
  String get callInfoAccount => 'Hesap';

  @override
  String get callInfoState => 'Durum';

  @override
  String get callInfoSecure => 'Güvenli';

  @override
  String get callInfoPlainSignalling => 'düz sinyalleşme';

  @override
  String get callRoutePhone => 'Telefon';

  @override
  String get callRouteWiredHeadset => 'Kablolu kulaklık';

  @override
  String get callAudioMicrophone => 'Mikrofon';

  @override
  String callCardSemantics(String name, String state) {
    return '$name ile arama, $state';
  }

  @override
  String get callUnmute => 'Sesi aç';

  @override
  String get callStopRecording => 'Kaydı durdur';

  @override
  String get callSplitConference => 'Konferansı ayır';

  @override
  String get callMergeCalls => 'Aramaları birleştir';

  @override
  String get callSwapCalls => 'Aramaları değiştir';

  @override
  String get callAttendedTransferBanner =>
      'Danışmalı aktarma: asıl arayan beklemede.';

  @override
  String get callActiveCalls => 'Etkin aramalar';

  @override
  String get callConferenceLevels => 'Konferans seviyeleri';

  @override
  String get callLevelVolume => 'Ses düzeyi';

  @override
  String get callLevelMicToParty => 'Karşıya mikrofon';

  @override
  String callPercentSemantics(int percent) {
    return 'yüzde $percent';
  }

  @override
  String get callFailInvalidNumber => 'Geçersiz numara (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Arama yetkisi yok ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Numara bulunamadı (404)';

  @override
  String get callFailNoAnswerFromServer => 'Sunucudan yanıt yok (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Geçici olarak ulaşılamıyor (480)';

  @override
  String get callFailIncompleteNumber => 'Eksik numara (484)';

  @override
  String callFailBusy(String code) {
    return 'Meşgul ($code)';
  }

  @override
  String get callFailCancelled => 'Arama iptal edildi (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Uyumlu codec yok ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Hizmet kullanılamıyor (503)';

  @override
  String get callFailDeclined => 'Arama reddedildi (603)';

  @override
  String get callFailGeneric => 'Arama başarısız oldu';

  @override
  String callFailGenericWithCode(String code) {
    return 'Arama başarısız oldu ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Arama sürüyor';

  @override
  String get callTrayInCall => 'Görüşmede';

  @override
  String get callHistoryBlocked => 'Engellendi';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimliğe izin verilmiyor';

  @override
  String get callHistoryDoNotDisturb => 'Rahatsız etmeyin';

  @override
  String get callHistoryBusy => 'Meşgul';

  @override
  String get callHistoryForwardedAlways => 'Yönlendirildi (her zaman)';

  @override
  String get callHistoryForwardedBusy => 'Yönlendirildi (meşgul)';

  @override
  String get callHistorySentToVoicemail => 'Sesli mesaja gönderildi';

  @override
  String get callHistoryRedirected => 'Başka yöne çevrildi';

  @override
  String get callIncomingNotificationBody => 'Gelen arama';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return '$account hesabında gelen arama';
  }

  @override
  String get callMissedNotificationTitle => 'Cevapsız arama';

  @override
  String get callErrEngineNotRunning => 'Arama altyapısı henüz çalışmıyor';

  @override
  String get callErrAddAccount => 'Arama yapmak için hesap ekleyin';

  @override
  String get callErrCouldNotPlace => 'Arama yapılamadı';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account kayıtlı değil';
  }

  @override
  String get callErrCouldNotAnswer => 'Yanıtlanamadı';

  @override
  String get callErrNoVoicemailNumber =>
      'Bu hesap için sesli mesaj numarası ayarlanmadı';

  @override
  String get callErrTransferFailed => 'Aktarma başarısız oldu';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Aktarma başarısız oldu: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Aramalar birleştirilemedi';

  @override
  String get callErrCouldNotStartRecording => 'Kayıt başlatılamadı';

  @override
  String get callErrCouldNotStopRecording => 'Kayıt durdurulamadı';

  @override
  String callParkingNotice(String code) {
    return 'Arama park ediliyor ($code çevirin)';
  }

  @override
  String get callErrParkFailed => 'Park etme başarısız oldu';

  @override
  String get callErrHandoffFailed => 'Devretme başarısız oldu';

  @override
  String get callErrCouldNotSendToDevice => 'Cihaza gönderilemedi';

  @override
  String get callHistoryForwardedNoAnswer => 'Yönlendirildi (yanıt yok)';

  @override
  String get shellTabKeypad => 'Tuş takımı';

  @override
  String get shellTabRecents => 'Son aramalar';

  @override
  String get shellTabContacts => 'Kişiler';

  @override
  String get shellTabMessages => 'Mesajlar';

  @override
  String get shellTabPresence => 'Durum';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Kayıtlar';

  @override
  String get shellSearchSemantics => 'Kişi, geçmiş arayın veya numara çevirin';

  @override
  String get shellSearchHint => 'Ara veya çevir';

  @override
  String get shellVoicemailTooltip => 'Sesli mesaj';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yeni sesli mesaj. Sesli mesajı aramak için tıklayın',
      one: '1 yeni sesli mesaj. Sesli mesajı aramak için tıklayın',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Uzakta';

  @override
  String get shellStatusTooltip => 'Durumunuz';

  @override
  String get shellDemoBanner =>
      'Demo modu: aramalar simüle edilir, hiçbir şey gerçek bir ağa ulaşmaz.';

  @override
  String get uiToday => 'Bugün';

  @override
  String get uiYesterday => 'Dün';

  @override
  String get uiUnknownCaller => 'Bilinmeyen arayan';

  @override
  String get uiCallEnded => 'Arama bitti';

  @override
  String get uiCallTransferNotConfirmed => 'Aktarma onaylanmadı';

  @override
  String get uiCallTransferring => 'Aktarılıyor...';

  @override
  String get uiCallConference => 'Konferans';

  @override
  String get uiCallOnHold => 'Beklemede';

  @override
  String get uiCallHeldByRemote => 'Karşı tarafça bekletiliyor';

  @override
  String get uiCallCalling => 'Aranıyor...';

  @override
  String get uiCallRinging => 'Çalıyor...';

  @override
  String get uiCallConnecting => 'Bağlanıyor...';

  @override
  String get uiCallIncoming => 'Gelen arama';

  @override
  String get uiCallConnected => 'Bağlandı';

  @override
  String get uiQrScanTitle => 'QR kodu tara';

  @override
  String get uiQrPasteHint => 'Kod metnini yapıştırın';

  @override
  String get uiQrNoCamera =>
      'Bu cihazda kamerayla tarama kullanılamıyor. Bunun yerine kod metnini yapıştırın.';

  @override
  String get uiQrPaste => 'Yapıştır';

  @override
  String get uiQrUse => 'Kullan';

  @override
  String get uiQrCameraDenied =>
      'Kamera erişimi kapalı. Sistem ayarlarından izin verin veya kod metnini aşağıya yapıştırın.';

  @override
  String get uiQrCameraUnavailable =>
      'Kamera kullanılamıyor. Kod metnini aşağıya yapıştırın.';

  @override
  String get presenceLampRinging => 'Çalıyor';

  @override
  String get presenceHeader => 'Meşgul lambası alanı';

  @override
  String get presenceChooseTooltip => 'İzlenecek kişileri seçin';

  @override
  String get presenceEmptyTitle => 'Panoda dahili hat yok';

  @override
  String get presenceEmptySubtitle =>
      'Bir kişinin ne zaman boş, çalıyor veya meşgul olduğunu görmek için o kişi için \"BLF panosunda göster\" seçeneğini açın.';

  @override
  String get presenceOpenContacts => 'Kişileri aç';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Aramak için dokunun, daha fazlası için uzun basın';
  }

  @override
  String presenceCallName(String name) {
    return '$name kişisini ara';
  }

  @override
  String get presencePickup => 'Bu dahili hattı yanıtla';

  @override
  String get presencePickupSub =>
      'Çalan aramasını yanıtlayın (hedefli yanıtlama)';

  @override
  String get presenceTransferHere => 'Geçerli aramayı buraya aktar';

  @override
  String get presenceRemove => 'Panodan kaldır';

  @override
  String get uiCall => 'Ara';

  @override
  String get uiMessage => 'Mesaj';

  @override
  String get recentsSearchTooltip => 'Geçmişte ara';

  @override
  String get recentsClearTitle => 'Arama geçmişi temizlensin mi?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tüm $count kayıt silinecek.',
      one: '1 kayıt silinecek.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => 'Geçmiş CSV olarak panoya kopyalandı';

  @override
  String get recentsMenuCopyCsv => 'CSV olarak kopyala';

  @override
  String get recentsMenuClear => 'Geçmişi temizle';

  @override
  String get recentsSearchHint => 'Ad veya numara ara';

  @override
  String get recentsFilterAll => 'Tümü';

  @override
  String get recentsFilterMissed => 'Cevapsız';

  @override
  String get recentsFilterIncoming => 'Gelen';

  @override
  String get recentsFilterOutgoing => 'Giden';

  @override
  String get recentsFilterAccount => 'Hesaba göre filtrele';

  @override
  String get recentsAllAccounts => 'Tüm hesaplar';

  @override
  String get recentsAccountFallback => 'Hesap';

  @override
  String get recentsEmptyNone => 'Henüz arama yok';

  @override
  String get recentsEmptyNoMatch => 'Eşleşen arama yok';

  @override
  String get recentsEmptyNoneSub => 'Aramalarınız burada görünecek.';

  @override
  String get recentsEmptyNoMatchSub => 'Başka bir filtre deneyin.';

  @override
  String get recentsOpenKeypad => 'Tuş takımını aç';

  @override
  String get recentsShowAll => 'Tümünü göster';

  @override
  String get recentsSelectCall => 'Bir arama seçin';

  @override
  String get recentsSelectCallSub =>
      'Ayrıntılar, kalite ve kayıtlar burada görünür.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Cevapsız arama',
      'incoming': 'Gelen arama',
      'other': 'Giden arama',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '$name kişisini ara';
  }

  @override
  String get recentsAddAccountToMessage => 'Mesaj göndermek için hesap ekleyin';

  @override
  String get recentsAddContact => 'Kişi ekle';

  @override
  String get recentsContact => 'Kişi';

  @override
  String get recentsBlock => 'Engelle';

  @override
  String get recentsUnblock => 'Engeli kaldır';

  @override
  String recentsBlockTitle(String number) {
    return '$number engellensin mi?';
  }

  @override
  String get recentsBlockMessage =>
      'Bu numaradan gelen aramalar otomatik olarak reddedilecek.';

  @override
  String get recentsQualityHeader => 'Arama kalitesi';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'En kötü MOS $mos   ·   Jitter $jitter ms   ·   Kayıp %$loss';
  }

  @override
  String get recentsRecordingsHeader => 'Kayıtlar';

  @override
  String get recentsOpenInRecordings => 'Kayıtlarda aç';

  @override
  String recentsRelatedCall(String title) {
    return 'İlgili arama: $title';
  }

  @override
  String get recentsHistoryHeader => 'Geçmiş';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Bu numarayla arama yok';

  @override
  String get recentsDeleteTitle => 'Bu aramalar silinsin mi?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name için $count kayıt kaldırılır.',
      one: '$name için 1 kayıt kaldırılır.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Geçmişten sil';

  @override
  String get recentsCallDetails => 'Arama ayrıntıları';

  @override
  String get contactsFavoritesHeader => '★ Favoriler';

  @override
  String get contactsFavoritesOnly => 'Yalnızca favoriler';

  @override
  String get contactsShowAll => 'Tümünü göster';

  @override
  String get contactsImportExportTooltip => 'İçe ve dışa aktar';

  @override
  String get contactsMenuDevice => 'Cihazdan içe aktar';

  @override
  String get contactsMenuFile => 'vCard / CSV dosyasını içe aktar';

  @override
  String get contactsMenuClipboard => 'Panodan içe aktar';

  @override
  String get contactsMenuCopyVcard => 'vCard olarak kopyala';

  @override
  String get contactsMenuCopyCsv => 'CSV olarak kopyala';

  @override
  String get contactsNewTooltip => 'Yeni kişi';

  @override
  String get contactsSearchHint => 'Kişilerde ara';

  @override
  String get contactsEmptyTitle => 'Henüz kişi yok';

  @override
  String get contactsEmptySubtitle =>
      'Sık aradığınız kişileri ekleyin veya bir vCard ya da CSV dosyası içe aktarın.';

  @override
  String get contactsEmptyAction => 'Kişi ekle';

  @override
  String get contactsNoMatches => 'Eşleşme yok';

  @override
  String contactsCallName(String name) {
    return '$name kişisini ara';
  }

  @override
  String get contactsSelect => 'Bir kişi seçin';

  @override
  String get contactsCopiedVcard => 'Kişiler vCard olarak kopyalandı';

  @override
  String get contactsCopiedCsv => 'Kişiler CSV olarak kopyalandı';

  @override
  String get contactsDeviceDenied =>
      'Kişilere erişim reddedildi. İçe aktarmak için sistem ayarlarından izin verin.';

  @override
  String get contactsDeviceNone => 'Bu cihazda kişi bulunamadı';

  @override
  String contactsNothingNew(int count) {
    return 'İçe aktarılacak yeni bir şey yok ($count zaten mevcut)';
  }

  @override
  String get contactsImportDeviceTitle => 'Cihazdan içe aktarılsın mı?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yeni kişi',
      one: '1 yeni kişi',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count kişi ek numaralarla güncellendi';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count atlandı (yinelenen veya telefon numarasız)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi içe aktarıldı',
      one: '1 kişi içe aktarıldı',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Bu verilerde kişi bulunamadı';

  @override
  String get contactsLabelMobile => 'cep';

  @override
  String get contactsLabelWork => 'iş';

  @override
  String get contactsLabelHome => 'ev';

  @override
  String get contactsLabelOther => 'diğer';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Kişi bulunamadı';

  @override
  String get contactsActionFavorite => 'Favori';

  @override
  String get contactsNumbersHeader => 'Numaralar';

  @override
  String get contactsSipAddress => 'SIP adresi';

  @override
  String get contactsDetailsHeader => 'Ayrıntılar';

  @override
  String get contactsOnBlf => 'BLF panosunda gösteriliyor';

  @override
  String get contactsAlwaysRecorded => 'Aramalar her zaman kaydedilir';

  @override
  String contactsDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get contactsDeleteMessage => 'Bu kişi bu cihazdan kaldırılacak.';

  @override
  String get contactsDeleteButton => 'Kişiyi sil';

  @override
  String get contactsDetailTitle => 'Kişi';

  @override
  String get contactsErrorNameOrNumber => 'Bir ad veya numara girin';

  @override
  String get contactsEditTitle => 'Kişiyi düzenle';

  @override
  String get contactsFieldName => 'Ad';

  @override
  String get contactsFieldCompany => 'Şirket';

  @override
  String get contactsFieldNumber => 'Numara';

  @override
  String get contactsRemoveNumber => 'Numarayı kaldır';

  @override
  String get contactsAddNumber => 'Numara ekle';

  @override
  String get contactsSipHeader => 'SIP adresleri';

  @override
  String get contactsRemoveAddress => 'Adresi kaldır';

  @override
  String get contactsAddSip => 'SIP adresi ekle';

  @override
  String get contactsFieldEmail => 'E-posta';

  @override
  String get contactsFieldNotes => 'Notlar';

  @override
  String get contactsFieldFavorite => 'Favori';

  @override
  String get contactsShowOnBlf => 'BLF panosunda göster';

  @override
  String get contactsShowOnBlfSub =>
      'Bu dahili hattın durumunu ve meşgul lambasını izle';

  @override
  String get contactsAlwaysRecordTitle =>
      'Bu kişiyle aramaları her zaman kaydet';

  @override
  String get contactsAlwaysRecordSub =>
      'Otomatik kayıt kurallarını geçersiz kılar';

  @override
  String get contactsRingtone => 'Zil sesi';

  @override
  String get contactsPresenceVia => 'Durum için hesap';

  @override
  String get contactsDefaultAccount => 'Varsayılan hesap';

  @override
  String get contactsDeleteContactTitle => 'Kişi silinsin mi?';

  @override
  String get contactsCannotUndo => 'Bu işlem geri alınamaz.';

  @override
  String get messagesNewMessage => 'Yeni mesaj';

  @override
  String get messagesNumberOrSip => 'Numara veya SIP adresi';

  @override
  String get messagesNoConversations => 'Sohbet yok';

  @override
  String get messagesEmptySubtitle =>
      'Hesaplarınızdaki herhangi bir dahili hatta veya adrese SIP mesajı gönderin.';

  @override
  String get messagesTyping => 'yazıyor...';

  @override
  String get messagesYouPrefix => 'Siz: ';

  @override
  String get messagesSelect => 'Bir sohbet seçin';

  @override
  String get messagesLanOnline => 'Ağınızda çevrimiçi';

  @override
  String get messagesLanOffline =>
      'Çevrimdışı. Mesajlar geri geldiğinde gönderilir.';

  @override
  String messagesSendFileTo(String name) {
    return '$name kişisine dosya gönder';
  }

  @override
  String messagesCallName(String name) {
    return '$name kişisini ara';
  }

  @override
  String get messagesDeleteTitle => 'Sohbet silinsin mi?';

  @override
  String messagesDeleteMessage(String name) {
    return '$name ile olan tüm mesajlar kaldırılacak.';
  }

  @override
  String get messagesDeleteMenu => 'Sohbeti sil';

  @override
  String get messagesSayHello => 'Merhaba deyin';

  @override
  String get messagesLanEmptySub =>
      'Mesajlar ağınız üzerinden doğrudan bu cihaza, uçtan uca şifrelenerek gider.';

  @override
  String get messagesSipEmptySub =>
      'Mesajlar hesabınız üzerinden SIP MESSAGE ile gönderilir.';

  @override
  String get messagesInputHint => 'Mesaj';

  @override
  String get messagesSend => 'Gönder';

  @override
  String get messagesStatusSending => 'Gönderiliyor';

  @override
  String get messagesStatusSent => 'Gönderildi';

  @override
  String get messagesStatusDelivered => 'Teslim edildi';

  @override
  String get messagesStatusRead => 'Okundu';

  @override
  String get messagesStatusFailed => 'Başarısız';

  @override
  String get messagesNotDelivered =>
      'Teslim edilemedi. Yeniden denemek için dokunun';

  @override
  String get uiStatusRegistered => 'Kayıtlı';

  @override
  String get uiStatusRegistering => 'Kaydoluyor';

  @override
  String get uiStatusRegFailed => 'Kayıt başarısız';

  @override
  String get uiStatusDisabled => 'Devre dışı';

  @override
  String get uiQualityMeasuring => 'Ölçülüyor';

  @override
  String get uiQualityExcellent => 'Mükemmel';

  @override
  String get uiQualityGood => 'İyi';

  @override
  String get uiQualityFair => 'Orta';

  @override
  String get uiQualityPoor => 'Zayıf';

  @override
  String get uiQualityBad => 'Kötü';

  @override
  String uiQualitySemantics(String label) {
    return 'Arama kalitesi $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Arama kalitesi $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Arama kalitesi: $label';
  }

  @override
  String get uiSecureFull => 'Şifreli';

  @override
  String get uiSecureMedia => 'Medya şifreli';

  @override
  String get uiSecureSignalling => 'Sinyalleşme şifreli';

  @override
  String get uiSecureNone => 'Şifresiz';

  @override
  String get uiSecureSrtpLine => 'SRTP medya';

  @override
  String get uiSecureTlsLine => 'TLS sinyalleşme';

  @override
  String lanCallHandingOver(String name) {
    return '$name cihazına devrediliyor';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return '$name cihazına interkom';
  }

  @override
  String get lanCallIntercomToUnnamed => 'Yakındaki bir cihaza interkom';

  @override
  String lanCallIntercomFromNamed(String name) {
    return '$name cihazından interkom';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'Yakındaki bir cihazdan interkom';

  @override
  String lanCallToNamed(String name) {
    return '$name cihazına LAN araması';
  }

  @override
  String get lanCallToUnpaired => 'Eşleşmemiş bir cihaza LAN araması';

  @override
  String lanCallFromNamed(String name) {
    return '$name cihazından LAN araması';
  }

  @override
  String get lanCallFromUnpaired => 'Eşleşmemiş bir cihazdan LAN araması';

  @override
  String lanHandoffTransferredFrom(String device) {
    return '$device cihazından aktarılan arama';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return '$device cihazından aktarılan arama: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'başka bir cihaz';

  @override
  String lanRelayedTitle(String name) {
    return '$name cihazına aktarıldı';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Arayan, $name ile konuşuyor. Siz görüşmede değilsiniz.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '$name aranıyor...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return '$name yanıtlarken arayan bağlı kalır.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '$name cihazına soruluyor...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Aramayı kabul etmesi bekleniyor.';

  @override
  String lanRelayConsultingTitle(String name) {
    return '$name ile konuşuluyor';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Arayan beklemede. Hazır olduğunuzda devri tamamlayın.';

  @override
  String get lanRelayTakingBack => 'Arama geri alınıyor...';

  @override
  String get lanRelayTakeBack => 'Geri al';

  @override
  String get lanRelayEnd => 'Bitir';

  @override
  String get lanSendToDevice => 'Cihaza gönder';

  @override
  String get lanBusy => 'Meşgul';

  @override
  String get lanNoPairedOnline => 'Çevrimiçi eşleşmiş cihaz yok';

  @override
  String lanPairRejectedBy(String name) {
    return '$name eşleşmeyi reddetti.';
  }

  @override
  String get lanPairRejected => 'Eşleşme reddedildi.';

  @override
  String get lanPairCancelled => 'Eşleşme iptal edildi.';

  @override
  String get lanPairTimedOut =>
      'Eşleşme zaman aşımına uğradı. Yeniden deneyin.';

  @override
  String get lanPairFailed => 'Eşleşme başarısız oldu';

  @override
  String lanPairFailedReason(String reason) {
    return 'Eşleşme başarısız oldu: $reason';
  }

  @override
  String get lanPairThisDevice => 'bu cihaz';

  @override
  String get lanPairConnecting => 'Güvenli bağlanılıyor...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name, bu cihazla eşleşmek istiyor.';
  }

  @override
  String lanPairPairingWith(String name) {
    return '$name ile eşleşiliyor.';
  }

  @override
  String get lanPairCheckCode =>
      'Bu kodun iki ekranda da aynı olduğundan emin olun.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Eşleşme kodu $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return '$name cihazının onaylaması bekleniyor...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name onayladı.';
  }

  @override
  String get lanPairReject => 'Reddet';

  @override
  String get lanPairCodesMatch => 'Kodlar aynı';

  @override
  String lanPairPairedWith(String name) {
    return '$name ile eşleşildi.';
  }

  @override
  String get lanPairRequestTitle => 'Eşleşme isteği';

  @override
  String lanPairTitle(String name) {
    return '$name ile eşleş';
  }

  @override
  String get lanActionDecline => 'Reddet';

  @override
  String get lanActionAccept => 'Kabul et';

  @override
  String get lanFileIncomingTitle => 'Gelen dosya';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$name cihazından $size';
  }

  @override
  String get lanHandoffOfferTitle => 'Arama buraya aktarılsın mı?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ', arayan: $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ', hesap: $account',
    });
    return '$device size bir arama devretmek istiyor$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Önce sizinle konuşacak.';

  @override
  String get lanHandoffTakeCall => 'Aramayı al';

  @override
  String lanIntercomRequestTitle(String name) {
    return '$name cihazından interkoma izin verilsin mi?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Aramaları hoparlörde otomatik olarak yanıtlanacak.';

  @override
  String get lanIntercomDeny => 'Reddet';

  @override
  String get lanIntercomAllow => 'İzin ver';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name, bu cihazı eşleşmiş listesinden kaldırdı';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dosya gönderiliyor...',
      one: '$name gönderiliyor...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Yeni mesaj';

  @override
  String get lanSipMessage => 'SIP mesajı';

  @override
  String get lanSipMessageSub => 'Hesabınız üzerinden bir numaraya veya adrese';

  @override
  String get lanChatOnline => 'LAN sohbeti, çevrimiçi';

  @override
  String get lanChatOffline => 'LAN sohbeti, çevrimdışı';

  @override
  String lanSavedAt(String path) {
    return '$path konumuna kaydedildi (yol kopyalandı)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Cihazlarınız doğrudan konuşuyor';

  @override
  String get lanConnectByAddress => 'Adresle bağlan';

  @override
  String get lanSettingsTooltip => 'LAN ayarları';

  @override
  String get lanOffTitle => 'LAN Link kapalı';

  @override
  String get lanOffSubtitle =>
      'Diğer SoftphonePro cihazlarınızı bulun, sohbet edin, dosya bırakın ve aramaları devredin, hem de sunucusuz.';

  @override
  String get lanTurnOn => 'LAN Link\'i aç';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link başlatılamadı: $error';
  }

  @override
  String get lanConnectHelp =>
      'ana makine:bağlantı noktası yazın veya diğer cihazda görünen QR kodunun metnini yapıştırın.';

  @override
  String get lanScanTitle => 'LAN eşleşme QR kodunu tara';

  @override
  String get lanScanQr => 'QR tara';

  @override
  String get lanPaste => 'Yapıştır';

  @override
  String get lanConnect => 'Bağlan';

  @override
  String lanConnectedTo(String name) {
    return '$name cihazına bağlanıldı';
  }

  @override
  String get lanCouldNotConnect => 'Bağlanılamadı';

  @override
  String get lanCouldNotStartPairing => 'Eşleşme başlatılamadı';

  @override
  String get lanThisDevice => 'Bu cihaz';

  @override
  String get lanDeviceNameTitle => 'Cihaz adı';

  @override
  String get lanStarting => 'Başlatılıyor...';

  @override
  String get lanVisible => 'Ağınızda görünür';

  @override
  String get lanNotRunning => 'Çalışmıyor';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hesap paylaşıldı',
      one: '1 hesap paylaşıldı',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Parmak izi';

  @override
  String get lanHideQr => 'QR kodunu gizle';

  @override
  String get lanShowQr => 'Başka bir cihazı bağlamak için QR kodunu göster';

  @override
  String get lanCopyConnectionText => 'Bağlantı metnini kopyala';

  @override
  String get lanConnectionTextCopied => 'Bağlantı metni kopyalandı';

  @override
  String get lanActiveOnOthers => 'Diğer cihazlarınızda etkin';

  @override
  String get lanPairedDevices => 'Eşleşmiş cihazlar';

  @override
  String get lanNoPaired =>
      'Henüz eşleşmiş cihaz yok. Sohbet etmek, dosya göndermek ve aramaları devretmek için yakındaki bir cihazı eşleştirin.';

  @override
  String get lanNearby => 'Yakında';

  @override
  String get lanNearbyHint =>
      'Ağınızda SoftphonePro aranıyor. Diğer cihazlarda LAN Link açık olmalıdır. Yukarıdaki bağlantı düğmesiyle adresle de bağlanabilirsiniz.';

  @override
  String get lanTransfers => 'Aktarımlar';

  @override
  String get lanFiles => 'Dosyalar';

  @override
  String get lanPairedBadge => 'Eşleşti';

  @override
  String get lanTyping => 'yazıyor...';

  @override
  String get lanPair => 'Eşleştir';

  @override
  String get lanUnpair => 'Eşleşmeyi kaldır';

  @override
  String lanUnpairTitle(String name) {
    return '$name eşleşmesi kaldırılsın mı?';
  }

  @override
  String get lanUnpairMessage =>
      'Sohbet etmek, dosya göndermek veya aramaları devretmek için yeniden eşleşmeniz gerekir.';

  @override
  String get lanActionMessage => 'Mesaj';

  @override
  String get lanActionSendFile => 'Dosya gönder';

  @override
  String get lanActionCall => 'Ara';

  @override
  String get lanActionIntercom => 'Interkom';

  @override
  String lanRemoteActiveOn(String device) {
    return '$device cihazında etkin';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return '$device cihazında etkin  ·  $account';
  }

  @override
  String get lanPull => 'Çek';

  @override
  String get lanTransferPreparing => 'Hazırlanıyor...';

  @override
  String get lanTransferWaitingYou => 'Sizi bekliyor';

  @override
  String lanTransferWaitingPeer(String name) {
    return '$name cihazının kabul etmesi bekleniyor';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get lanTransferVerifying => 'Doğrulanıyor...';

  @override
  String lanTransferFrom(String name, String status) {
    return '$name cihazından  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return '$name cihazına  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  $name cihazından';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  $name cihazına';
  }

  @override
  String lanFileFailed(String error) {
    return 'Başarısız: $error';
  }

  @override
  String get lanFileActions => 'Dosya işlemleri';

  @override
  String get lanPathCopied => 'Yol kopyalandı';

  @override
  String get lanFileOpen => 'Aç';

  @override
  String get lanFileShowInFolder => 'Klasörde göster';

  @override
  String get lanFileCopyPath => 'Yolu kopyala';

  @override
  String lanNetworkError(String message) {
    return 'Ağ hatası: $message';
  }

  @override
  String get lanErrNotRunning => 'Önce LAN Link\'i açın';

  @override
  String get lanErrBadAddress =>
      '192.168.1.20:4711 gibi bir adres girin veya QR kodu metnini yapıştırın';

  @override
  String get lanErrFingerprint =>
      'Bu cihaz taranan kodla eşleşmiyor. QR kodu başka bir cihazdan mı geldi?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$name cihazından $file alındı';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file, $name cihazına gönderildi';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name, $file dosyasını reddetti';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Dosya aktarımı başarısız oldu: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Yakındaki cihazları aramak için LAN Link\'i açın';

  @override
  String get lanNoticePairFirst => 'Önce bu cihazla eşleşin';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name şu anda aramalar için ulaşılabilir değil';
  }

  @override
  String lanNoticeAsking(String name) {
    return '$name cihazına soruluyor…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name interkoma izin vermedi (veya yanıt vermedi)';
  }

  @override
  String get lanHoOff => 'LAN Link kapalı';

  @override
  String get lanHoPairFirst => 'Önce o cihazla eşleşin';

  @override
  String lanHoOffline(String name) {
    return '$name çevrimdışı';
  }

  @override
  String get lanHoAlready => 'Bu arama zaten devrediliyor';

  @override
  String get lanHoEnded => 'Arama zaten bitti';

  @override
  String get lanHoWaitConnected => 'Arama bağlanana kadar bekleyin';

  @override
  String get lanHoLanCall => 'LAN aramaları devredilemez';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name ağ üzerinden arama alamıyor (orada LAN arama kapalı)';
  }

  @override
  String get lanHoNoLanHere => 'LAN arama bu cihazda kullanılamıyor';

  @override
  String lanHoDeclined(String name) {
    return '$name aramayı reddetti. Arama sizde kalıyor.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name yanıt vermedi. Arama sizde kalıyor.';
  }

  @override
  String get lanHoCancelled => 'Devir iptal edildi. Arama sizde kalıyor.';

  @override
  String lanHoUnreachable(String name) {
    return '$name cihazına ulaşılamadı. Arama sizde kalıyor.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '$name cihazına ulaşılamadı ($reason). Arama sizde kalıyor.';
  }

  @override
  String get lanHoEndedBefore => 'Arama devredilemeden bitti';

  @override
  String lanHoPbxRefused(String name) {
    return 'Telefon sistemi aktarmayı reddetti ve $name LAN aramalarını alamıyor';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Telefon sistemi üzerinden aktarma başarısız oldu. Bunun yerine ağ üzerinden aktarılıyor.';

  @override
  String lanHoSentTo(String name) {
    return 'Arama $name cihazına gönderildi';
  }

  @override
  String get lanHoConsultFailed =>
      'Diğer cihaz telefon sistemi üzerinden aranamadı';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name artık ulaşılabilir değil';
  }

  @override
  String get lanHoCouldNotAnswer => 'Arama devredilmek üzere yanıtlanamadı';

  @override
  String lanHoCouldNotCall(String name) {
    return '$name cihazı ağ üzerinden aranamadı. Arama sizde kalıyor.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name yanıt vermedi. Arama sizde kalıyor.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return '$name cihazına devredildi';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Arama $name cihazına aktarıldı';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Önce $name cihazının yanıtlamasını bekleyin';
  }

  @override
  String get lanHoFailed => 'Devir başarısız oldu';

  @override
  String lanHoTakenBack(String name) {
    return 'Arama $name cihazından geri alındı';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name görüşmeyi bitirdi. Arama yine sizde.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Arama $name cihazına devredilemedi';
  }

  @override
  String get diagSip400Explain => 'Sunucu isteği anlayamadı.';

  @override
  String get diagSip400Fix =>
      'Hesap ayarlarını (alan adı, kullanıcı adı, proxy) kontrol edin. Sorun sürerse sağlayıcınıza bir SIP izi gönderin.';

  @override
  String get diagSip401Explain =>
      'Sunucu kimlik bilgilerini reddetti (veya bunları istiyor).';

  @override
  String get diagSip401Fix =>
      'Kullanıcı adını, kimlik doğrulama kullanıcı adını ve parolayı kontrol edin. Bazı sağlayıcılar ayrı bir \"auth ID\" kullanır.';

  @override
  String get diagSip403Explain =>
      'Sunucu isteği anladı ancak reddediyor: yanlış parola, devre dışı hesap veya IP adresiniz izinli değil.';

  @override
  String get diagSip403Fix =>
      'Parolayı yeniden girin, hesabın etkin olduğunu kontrol edin ve genel IP adresinizin engellenmediğini doğrulayın (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'Sunucu bu kullanıcıyı veya numarayı tanımıyor.';

  @override
  String get diagSip404Fix =>
      'Kullanıcı adını ve alan adını kontrol edin; aramalar için çevrilen numarayı ve arama kurallarını kontrol edin.';

  @override
  String get diagSip405Explain => 'Sunucu bu isteği desteklemiyor.';

  @override
  String get diagSip405Fix =>
      'OPTIONS ping\'leri için genellikle zararsızdır. REGISTER için bir SIP kayıt sunucusuyla konuştuğunuzu kontrol edin.';

  @override
  String get diagSip407Explain => 'Giden proxy kimlik bilgisi istiyor.';

  @override
  String get diagSip407Fix =>
      'Hesap parolasını ve giden proxy ayarlarını kontrol edin.';

  @override
  String get diagSip408Explain => 'Sunucudan zamanında yanıt gelmedi.';

  @override
  String get diagSip408Fix =>
      'Sunucu adresini ve bağlantı noktasını, güvenlik duvarlarını kontrol edin ve TCP veya TLS deneyin. Yalnızca UDP\'de tekrarlanan zaman aşımları, yönlendiricideki SIP ALG\'ye işaret edebilir.';

  @override
  String get diagSip410Explain => 'Numara artık mevcut değil.';

  @override
  String get diagSip410Fix => 'Çevrilen numarayı kontrol edin.';

  @override
  String get diagSip415Explain =>
      'Karşı taraf sunulan içerik türünü veya codec\'leri kabul etmiyor.';

  @override
  String get diagSip415Fix =>
      'Ayarlar > Codec\'ler bölümünde daha fazla codec (örn. PCMU/PCMA) etkinleştirin.';

  @override
  String get diagSip421Explain =>
      'Sunucu, bu istemcinin sunmadığı bir SIP uzantısı gerektiriyor.';

  @override
  String get diagSip421Fix =>
      'Hesabın NAT/ICE/100rel/zamanlayıcı seçeneklerini kontrol edin.';

  @override
  String get diagSip423Explain =>
      'Kayıt süresi, sunucunun izin verdiğinden kısa.';

  @override
  String get diagSip423Fix => 'Hesap ayarlarında kayıt süresini artırın.';

  @override
  String get diagSip480Explain =>
      'Kullanıcı kayıtlı değil veya şu anda ulaşılamıyor.';

  @override
  String get diagSip480Fix =>
      'Karşı tarafın kayıtlı olduğunu kontrol edin; kayıt sırasında sunucu aşırı yüklenmiş olabilir: daha sonra yeniden deneyin.';

  @override
  String get diagSip481Explain =>
      'Sunucu diyalog durumunu kaybetti (örn. yeniden başlatma veya ağ değişikliğinden sonra).';

  @override
  String get diagSip481Fix =>
      'Kapatıp yeniden deneyin. Sık oluyorsa oturum zamanlayıcılarını etkinleştirin.';

  @override
  String get diagSip483Explain => 'İstek sunucular arasında döngüye girdi.';

  @override
  String get diagSip483Fix =>
      'Santraldeki yönlendirme ve rota yapılandırmasını kontrol edin.';

  @override
  String get diagSip484Explain => 'Çevrilen numara çok kısa.';

  @override
  String get diagSip484Fix =>
      'Numaranın tamamını çevirin veya arama kurallarını kontrol edin.';

  @override
  String get diagSip486Explain => 'Karşı taraf meşgul.';

  @override
  String get diagSip486Fix => 'Daha sonra tekrar deneyin.';

  @override
  String get diagSip487Explain => 'Arama yanıtlanmadan iptal edildi.';

  @override
  String get diagSip487Fix => 'Arayan, çalarken kapattığında normaldir.';

  @override
  String get diagSip488Explain =>
      'Karşı tarafla ortak bir codec veya şifreleme ayarı yok.';

  @override
  String get diagSip488Fix =>
      'Codec\'leri ve SRTP\'yi kontrol edin (SRTP\'nin zorunlu olduğu bir hesap, düz RTP kullanan bir uç noktayı arayamaz).';

  @override
  String get diagSip491Explain => 'İki re-INVITE çakıştı.';

  @override
  String get diagSip491Fix => 'Normalde otomatik olarak yeniden denenir.';

  @override
  String get diagSip500Explain => 'Sunucuda dahili bir hata oluştu.';

  @override
  String get diagSip500Fix =>
      'Daha sonra yeniden deneyin; sürerse sağlayıcıyla iletişime geçin.';

  @override
  String get diagSip502Explain => 'Üst sunucu geçersiz bir yanıt döndürdü.';

  @override
  String get diagSip502Fix =>
      'Daha sonra yeniden deneyin; sürerse sağlayıcıyla iletişime geçin.';

  @override
  String get diagSip503Explain =>
      'Sunucu aşırı yüklenmiş, kapalı veya bu istemciyi reddediyor (hız sınırı).';

  @override
  String get diagSip503Fix =>
      'Bekleyip yeniden deneyin, sağlayıcının durum sayfasına bakın veya başka bir sunucu/bağlantı noktası deneyin.';

  @override
  String get diagSip504Explain => 'Üst sunucu zamanında yanıt vermedi.';

  @override
  String get diagSip504Fix => 'Daha sonra yeniden deneyin.';

  @override
  String get diagSip600Explain => 'Tüm hedefler meşgul.';

  @override
  String get diagSip600Fix => 'Daha sonra tekrar deneyin.';

  @override
  String get diagSip603Explain => 'Karşı taraf aramayı reddetti.';

  @override
  String get diagSip603Fix => 'Düzeltilecek bir şey yok: arama reddedildi.';

  @override
  String get diagSip604Explain => 'Numara mevcut değil.';

  @override
  String get diagSip604Fix => 'Çevrilen numarayı kontrol edin.';

  @override
  String get diagSip606Explain =>
      'Karşı taraf oturumu sunulduğu şekliyle kabul edemiyor.';

  @override
  String get diagSip606Fix =>
      'Codec\'leri ve şifreleme ayarlarını kontrol edin.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Geçici ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'İstek işleniyor.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Başarılı ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'İstek başarılı oldu.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Yönlendirildi ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'Hedef taşındı.';

  @override
  String get diagSipRedirectedFix => 'Yönlendirme ayarlarını kontrol edin.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'İstemci hatası ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'Sunucu isteği reddetti.';

  @override
  String get diagSipClientErrorFix =>
      'Hesabı ve çevrilen numarayı kontrol edin.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Sunucu hatası ($code)';
  }

  @override
  String get diagSipServerErrorExplain => 'Sunucu isteği işleyemedi.';

  @override
  String get diagSipServerErrorFix =>
      'Daha sonra yeniden deneyin veya sağlayıcıyla iletişime geçin.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Genel hata ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'İstek hiçbir yerde karşılanamıyor.';

  @override
  String get diagSipNoResponseTitle => 'Yanıt yok';

  @override
  String get diagSipNoResponseExplain => 'Hiçbir SIP yanıtı alınmadı.';

  @override
  String get diagSipNoResponseFix =>
      'Ağ bağlantısını ve sunucu adresini kontrol edin.';

  @override
  String get diagWizStepNet => 'Ağ bağlantısı';

  @override
  String diagWizStepDns(String account) {
    return 'DNS ve SRV: $account';
  }

  @override
  String get diagWizStepNat => 'NAT türü';

  @override
  String diagWizStepOptions(String account) {
    return 'Sunucu erişilebilirliği: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS sertifikası: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Kayıt: $account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALG denetimi';

  @override
  String get diagWizChecking => 'Denetleniyor...';

  @override
  String diagWizEngineError(String message) {
    return 'Altyapı hatası: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Denetim başarısız oldu: $error';
  }

  @override
  String get diagWizNoEngine => 'SIP altyapısı çalışmıyor';

  @override
  String get diagWizNoEngineFix =>
      'Altyapının başlamasını bekleyin (veya uygulamayı yeniden başlatın), ardından denetimleri yeniden çalıştırın.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (özel)';
  }

  @override
  String get diagWizNetNone => 'IP adresi olan etkin ağ arayüzü yok';

  @override
  String get diagWizNetNoneFix =>
      'Wi-Fi, Ethernet veya mobil veriye bağlanın, ardından denetimleri yeniden çalıştırın.';

  @override
  String get diagWizNetIpv6Only => 'Yalnızca IPv6 adresleri bulundu';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Birçok SIP sağlayıcısı yalnızca IPv4 kullanır. Bu ağda IPv4\'ü etkinleştirin veya IPv6 destekleyen bir sağlayıcı kullanın.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces arayüzde',
      one: '1 arayüzde',
    );
    String _temp1 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 IPv4 adresi',
      one: '1 IPv4 adresi',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'VPN türünde bir arayüz etkin. VPN\'ler gecikme ekleyebilir veya UDP\'yi engelleyebilir; aramalarda sorun olursa devre dışı bırakın.';

  @override
  String get diagWizDnsNoServer => 'Hesabın sunucu adresi yok';

  @override
  String get diagWizDnsNoServerFix =>
      'Hesabı düzenleyin ve SIP alan adını girin.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host bir IP adresi, DNS gerekmiyor';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: yok';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: yok ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: yok';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (öncelik $priority, ağırlık $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: sorgu başarısız ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host çözümlenmiyor';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Alan adında yazım hatası olup olmadığını ve DNS sunucunuzun çalıştığını kontrol edin. Ayarlar > Ağ bölümünden özel bir DNS sunucusu (örn. 8.8.8.8) belirleyebilirsiniz.';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host için SRV kayıtları var ancak adres kaydı yok';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'SRV hedefleri kullanılacak. Aramalar başarısız olursa sağlayıcıdan A kaydını kontrol etmesini isteyin.';

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
      other: ', $srv SRV kaydı',
      one: ', 1 SRV kaydı',
      zero: '',
    );
    return '$host, $address adresine çözümleniyor$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'NAT algılama zaman aşımına uğradı';

  @override
  String get diagWizNatTimeoutFix =>
      'STUN sunucusuna ulaşılamıyor olabilir (UDP engelli mi?). Ayarlar > Ağ > STUN sunucularını kontrol edin.';

  @override
  String diagWizNatStun(String server) {
    return 'STUN sunucusu: $server';
  }

  @override
  String get diagWizNatOpen => 'NAT yok: bu cihazın genel bir adresi var';

  @override
  String get diagWizNatFullCone => 'Full cone NAT: VoIP için uygun';

  @override
  String get diagWizNatRestricted =>
      'Restricted cone NAT: STUN ve canlı tutma ile çalışır';

  @override
  String get diagWizNatPortRestricted =>
      'Port-restricted cone NAT: STUN ve canlı tutma ile çalışır';

  @override
  String get diagWizNatSymmetric =>
      'Simetrik NAT: yalnızca STUN medya bağlantı noktasını tahmin edemez';

  @override
  String get diagWizNatSymmetricFix =>
      'Bazı aramalarda tek yönlü ses veya sessizlik olması olasıdır. Hesap ayarlarında (Hesap > NAT) ICE ve TURN aktarıcısını etkinleştirin ya da medya aktarımı (rtpengine) olan bir sağlayıcı/santral kullanın.';

  @override
  String get diagWizNatBlocked => 'UDP engelleniyor gibi görünüyor';

  @override
  String get diagWizNatBlockedFix =>
      'Hesap için TCP veya TLS aktarımını kullanın. Ağ, web trafiği dışındaki her şeyi filtreliyorsa ve sağlayıcınız destekliyorsa 443 numaralı bağlantı noktasında TLS deneyin.';

  @override
  String get diagWizNatUnknown => 'NAT türü belirlenemedi';

  @override
  String get diagWizNatUnknownFix =>
      'STUN sunucusu yanıt vermedi. Ayarlar > Ağ bölümünde başka bir STUN sunucusu deneyin.';

  @override
  String get diagWizNatErr =>
      'STUN sunucusu yanıt vermedi, bu yüzden NAT türü belirlenemedi.';

  @override
  String get diagWizNatUnknownRaw => 'NAT türü belirlenemedi.';

  @override
  String get diagWizOptionsNotLoaded => 'Hesap altyapıya yüklenmemiş';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'OPTIONS isteğine $seconds sn içinde yanıt gelmedi (aktarım: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'Sunucuya ulaşılamıyor. Adresi ve bağlantı noktasını kontrol edin, bir güvenlik duvarının SIP\'i düşürmediğinden emin olun ve başka bir aktarım (TCP/TLS) deneyin.';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'İstek zaman aşımına uğradı ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Sunucu $ms ms sonra $code $reason yanıtı verdi';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Sunucu $ms ms içinde $code $reason yanıtı verdi';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'OPTIONS isteğine $code yanıtı normaldir: sunucuya ulaşılabiliyor ancak anonim yoklamalara izin vermiyor.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      '300 ms üzerindeki gidiş-dönüş süresi görüşmelere fark edilir gecikme ekler. Daha yakın bir sunucu veya kablolu bağlantı yardımcı olur.';

  @override
  String get diagWizTlsRejected => 'Sunucu sertifikası reddedildi';

  @override
  String diagWizTlsSubject(String value) {
    return 'Konu: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Veren: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Sorunlar: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Bitiş: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Şifre: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Bu, otomatik imzalı sertifikaya sahip kendi santralinizse ve yukarıdaki parmak izi eşleşiyorsa güvenebilirsiniz. Aksi halde sağlayıcıdan genel bir CA tarafından verilmiş sertifika isteyin.';

  @override
  String get diagWizTlsTrust => 'Bu sertifikaya güven';

  @override
  String diagWizTlsExpired(String date) {
    return 'Sertifikanın süresi $date tarihinde doldu';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Sunucu yöneticisinden sertifikayı yenilemesini isteyin.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sertifikanın süresi $days gün içinde doluyor',
      one: 'Sertifikanın süresi 1 gün içinde doluyor',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Sunucu yöneticisine yakında yenilemesini söyleyin.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Bağlanıldı, ancak doğrulama şunu bildirdi: $problems';
  }

  @override
  String get diagWizTlsOk => 'TLS bağlantısı kuruldu, sertifika geçerli';

  @override
  String get diagWizTlsRegistered =>
      'TLS üzerinden kayıt yapıldı (sertifika ayrıntısı bildirilmedi)';

  @override
  String get diagWizTlsNone => 'Henüz TLS bağlantısı gözlenmedi';

  @override
  String get diagWizTlsNoneFix =>
      'TLS bağlantı noktasını (genellikle 5061) ve sunucunun TLS 1.2 veya üstünü kabul ettiğini kontrol edin.';

  @override
  String get diagWizRegDisabledByConfig =>
      'Bu hesapta kayıt devre dışı (eşler arası kullanım)';

  @override
  String get diagWizRegRegistered => 'Kayıtlı';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Kayıtlı ($seconds sn içinde bitiyor)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Aktarım: $transport';
  }

  @override
  String get diagWizRegInProgress => 'Kayıt hâlâ sürüyor';

  @override
  String get diagWizRegInProgressFix =>
      'Birkaç saniye bekleyin. Hiç tamamlanmazsa sunucu yanıt vermiyordur; yukarıdaki erişilebilirlik denetimine bakın.';

  @override
  String get diagWizRegFailed => 'Kayıt başarısız oldu';

  @override
  String get diagWizRegOffline => 'Hesap çevrimdışı';

  @override
  String get diagWizRegOfflineFix =>
      'Ağ bağlantısını kontrol edin. Uygulama otomatik olarak yeniden dener.';

  @override
  String get diagWizRegDisabled => 'Hesap devre dışı';

  @override
  String get diagWizAlgNoUdp =>
      'Hiçbir hesap UDP kullanmıyor, bu yüzden SIP ALG sorun değil';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: UDP üzerinden yanıt yok, ancak TCP yanıt verdi ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: UDP veya TCP üzerinden yanıt yok (ALG\'den çok sunucu veya güvenlik duvarı sorunu)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS yanıtlanıyor ancak REGISTER zaman aşımına uğruyor; bu, SIP\'i yeniden yazan bir yönlendiriciye özgüdür';
  }

  @override
  String get diagWizAlgSuspected => 'Yönlendiricinizde SIP ALG şüphesi var';

  @override
  String get diagWizAlgSuspectedFix =>
      'Yönlendirici ayarlarında \"SIP ALG\" / \"SIP helper\" seçeneğini kapatın, hesabı TCP veya TLS\'e geçirin ya da yönlendirici paketleri bozmasın diye SIP bağlantı noktasını (örn. 5080) değiştirin.';

  @override
  String get diagWizAlgContactChanged =>
      'Contact adresi istek ile yanıt arasında değişti';

  @override
  String get diagWizAlgContactChangedFix =>
      'Bu bir SIP ALG ya da contact adreslerini yeniden yazan bir sunucu olabilir. Aramalar çalıyor ama ses yoksa veya bir süre sonra düşüyorsa yönlendiricide SIP ALG\'yi kapatın ya da TCP/TLS veya 5080 numaralı bağlantı noktasını kullanın.';

  @override
  String get diagWizAlgOk => 'SIP ALG müdahalesi belirtisi yok';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER Contact $sent değeri $received olarak döndü';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '$fileName dosyasını kaydet';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName kaydedildi';
  }

  @override
  String get diagSaveFailed => 'Dosya kaydedilemedi';

  @override
  String get diagCopiedText => 'Metin panoya kopyalandı';

  @override
  String get diagCopiedReport => 'Rapor panoya kopyalandı';

  @override
  String get diagCopiedBundle => 'Tanılama paketi panoya kopyalandı';

  @override
  String get diagCopiedLogs => 'Günlükler panoya kopyalandı';

  @override
  String get diagCopiedTrace => 'İz panoya kopyalandı';

  @override
  String get diagCopiedDialog => 'Diyalog panoya kopyalandı';

  @override
  String get diagSaveAsLog => '.log olarak kaydet';

  @override
  String get diagSysAppVersion => 'Uygulama sürümü';

  @override
  String get diagSysPlatform => 'Platform';

  @override
  String get diagSysEngine => 'Altyapı';

  @override
  String get diagSysAccounts => 'Hesaplar';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$total hesaptan $registered kayıtlı';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Sistem bilgisi okunamadı: $error';
  }

  @override
  String get diagSysTransports => 'Aktarımlar';

  @override
  String get diagSysNoneReported => 'Bildirilen yok';

  @override
  String get diagSysCodecs => 'Codec\'ler';

  @override
  String get diagSysCodecsFooter =>
      'Etkin codec\'ler, en yüksek öncelik başta.';

  @override
  String get diagSysEngineNotRunning => 'Altyapı çalışmıyor';

  @override
  String diagSysCodecPriority(int priority) {
    return 'öncelik $priority';
  }

  @override
  String get diagSysCodecDisabled => 'devre dışı';

  @override
  String get diagSysExport => 'Dışa aktar';

  @override
  String get diagSysExportFooter =>
      'Paket; sistem bilgisini, ağ denetimi sonuçlarını, son günlükleri ve SIP izini içerir, kimlik bilgileri gizlenmiştir.';

  @override
  String get diagSysCopyBundle => 'Tanılama paketini kopyala';

  @override
  String get diagSysSaveBundle => 'Tanılama paketini kaydet';

  @override
  String get diagTabSipTrace => 'SIP izi';

  @override
  String get diagTabNetwork => 'Ağ';

  @override
  String get diagTabQuality => 'Kalite';

  @override
  String get diagTabAudioTest => 'Ses testi';

  @override
  String get diagTabLogs => 'Günlükler';

  @override
  String get diagTabSystem => 'Sistem';

  @override
  String diagRawSentTo(String remote) {
    return '$remote adresine gönderildi';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return '$remote adresinden alındı';
  }

  @override
  String get diagRawCopied => 'Mesaj kopyalandı';

  @override
  String get diagRawLadder => 'Merdiven';

  @override
  String get diagRawRedact => 'Kimlik bilgilerini gizle';

  @override
  String diagRawTruncated(int count) {
    return '... kısaltıldı ($count karakter)';
  }

  @override
  String get diagWizIntro =>
      'Bağlantınızı, DNS\'i, NAT\'ı, sunucu erişilebilirliğini, TLS\'i ve kaydı denetler ve nelerin düzeltilmesi gerektiğini açıklar.';

  @override
  String get diagWizStop => 'Durdur';

  @override
  String get diagWizRunChecks => 'Denetimleri çalıştır';

  @override
  String get diagWizRunAgain => 'Yeniden çalıştır';

  @override
  String get diagWizCopyReport => 'Raporu kopyala';

  @override
  String get diagWizSaveReport => 'Raporu kaydet';

  @override
  String diagWizCountPassed(int count) {
    return 'Başarılı $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Uyarı $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Başarısız $count';
  }

  @override
  String get diagWizStatusPass => 'Başarılı';

  @override
  String get diagWizStatusWarn => 'Uyarı';

  @override
  String get diagWizStatusFail => 'Başarısız';

  @override
  String get diagWizStatusSkipped => 'Atlandı';

  @override
  String get diagWizStatusRunning => 'Çalışıyor';

  @override
  String get diagWizStatusPending => 'Bekliyor';

  @override
  String get diagQualityTitle => 'Arama kalitesi';

  @override
  String get diagQualityNoData => 'Bu arama için kalite verisi kaydedilmedi.';

  @override
  String get diagQualityTraceForCall => 'Bu aramanın SIP izi';

  @override
  String get diagQualityTraceNotCaptured => 'Bu arama için SIP izi yakalanmadı';

  @override
  String get diagQualityLiveCall => 'Canlı arama';

  @override
  String get diagQualityNoActiveCall =>
      'Etkin arama yok. Bir arama başlatın; MOS, jitter, kayıp ve gidiş-dönüş süresi burada canlı olarak çizilir.';

  @override
  String get diagQualityRecentCalls => 'Son aramalar';

  @override
  String get diagQualityNoFinished =>
      'Henüz kalite verisi olan biten arama yok.';

  @override
  String get diagQualityCallEnded => 'Arama bitti.';

  @override
  String get diagQualityMeasuring => 'ölçülüyor';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return '$title grafiği';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return '$title grafiği, son değer $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   en çok $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Ortalama $avg  ·  en kötü $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Kayıp';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count paket';
  }

  @override
  String get diagQualityMedia => 'Medya';

  @override
  String get diagQualityNoSeries => 'Bu arama için zaman serisi kaydedilmedi.';

  @override
  String get diagQualityPacketLoss => 'Paket kaybı';

  @override
  String get diagQualityRtt => 'Gidiş-dönüş süresi';

  @override
  String get diagLogsForward => 'Altyapı günlüklerini ilet';

  @override
  String get diagLogsForwardSub =>
      'pjsip günlük satırlarını bu görüntüleyiciye gönder';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Düzey $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Dışa aktarırken gizle';

  @override
  String get diagLogsSearch => 'Günlüklerde ara';

  @override
  String get diagLogsEmpty => 'Henüz günlük satırı yok.';

  @override
  String get diagLogsForwardingOff =>
      'Günlük iletme kapalı. Altyapı günlüklerini yakalamak için açın.';

  @override
  String get diagLogsNoMatch => 'Aramayla eşleşen satır yok.';

  @override
  String get diagAudioEngineNotRunning => 'SIP altyapısı çalışmıyor.';

  @override
  String get diagAudioMicrophone => 'Mikrofon';

  @override
  String get diagAudioMicFooter =>
      'Seviye ölçer, altyapının arama veya yankı testi sırasında açtığı ses cihazını okur.';

  @override
  String get diagAudioLevelMeter => 'Seviye ölçer';

  @override
  String get diagAudioLevelMeterSub => 'Konuşun ve çubuğun hareketini izleyin';

  @override
  String get diagAudioMic => 'Mikrofon';

  @override
  String get diagAudioSpeaker => 'Hoparlör';

  @override
  String get diagAudioEchoTest => 'Yankı testi';

  @override
  String get diagAudioEchoFooter =>
      'Sesinizi hoparlörden geri çalar. Geri besleme olmaması için kulaklık kullanın.';

  @override
  String get diagAudioEchoActive => 'Etkin: şimdi konuşun';

  @override
  String get diagAudioEchoIdle => 'Mikrofondan hoparlöre geri döngü';

  @override
  String get diagAudioSpeakerTest => 'Hoparlör testi';

  @override
  String get diagAudioPlayTone => 'Test tonunu çal';

  @override
  String get diagAudioPlayToneSub => 'Seçili hoparlörden çalar';

  @override
  String get diagAudioPlayingDtmf => 'DTMF çalınıyor';

  @override
  String get diagAudioPlayingRingback => 'Çalma tonu çalınıyor';

  @override
  String get diagAudioRingback => 'Çalma tonu';

  @override
  String get diagAudioDevices => 'Cihazlar';

  @override
  String get diagAudioChooseDevices => 'Mikrofon ve hoparlör seçin';

  @override
  String get diagAudioChooseDevicesSub => 'Ayarlar > Ses bölümünü açar';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label seviyesi yüzde $percent';
  }

  @override
  String get diagLadderLocal => 'Yerel';

  @override
  String diagLadderSent(String message) {
    return '$message gönderildi';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message alındı';
  }

  @override
  String get diagTraceCapture => 'SIP mesajlarını yakala';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesaj',
      one: '1 mesaj',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesaj',
      one: '1 mesaj',
    );
    return '$_temp0  ·  $size  ·  $dropped eski mesaj atıldı';
  }

  @override
  String get diagTraceOffHint =>
      'Kapalı. Açın, ardından kaydolun veya arama yapın.';

  @override
  String get diagTraceExportOrClear => 'Dışa aktar veya temizle';

  @override
  String get diagTraceSaveAsPcap => '.pcap olarak kaydet';

  @override
  String get diagTraceCopyAsText => 'Metin olarak kopyala';

  @override
  String get diagTraceSearchHint => 'Metin, numara veya Call-ID ara';

  @override
  String get diagTraceErrorsOnly => 'Yalnızca hatalar';

  @override
  String get diagTraceFilterMethod => 'Yönteme göre filtrele';

  @override
  String get diagTraceAllMethods => 'Tüm yöntemler';

  @override
  String get diagTraceMethod => 'Yöntem';

  @override
  String get diagTraceFilterAccount => 'Hesaba göre filtrele';

  @override
  String get diagTraceAllAccounts => 'Tüm hesaplar';

  @override
  String get diagTraceAccount => 'Hesap';

  @override
  String get diagTraceRedact => 'Gizle';

  @override
  String get diagTraceList => 'Liste';

  @override
  String get diagTraceWaiting => 'SIP trafiği bekleniyor';

  @override
  String get diagTraceWaitingSub =>
      'Bir hesaba kaydolun veya arama yapın; mesajlar burada görünür.';

  @override
  String get diagTraceOff => 'SIP izi kapalı';

  @override
  String get diagTraceOffSub =>
      'Her SIP isteğini ve yanıtını liste veya merdiven diyagramı olarak görmek için yakalamayı açın.';

  @override
  String get diagTraceNoMatch => 'Filtrelerle eşleşen mesaj yok';

  @override
  String get diagTraceAllDialogs => 'Tüm diyaloglar';

  @override
  String get diagTraceCopyDialog => 'Bu diyaloğu kopyala';

  @override
  String get diagTraceNoResponse => 'yanıt yok';

  @override
  String get diagTraceNoCallId => 'Call-ID yok';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesaj',
      one: '1 mesaj',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Kayıt';

  @override
  String get recFormatWav => 'Standart (WAV)';

  @override
  String get recFormatWavStereo =>
      'Stereo, siz ve arayan ayrı kanallarda (WAV)';

  @override
  String get recFormatOpus => 'Sıkıştırılmış (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, dakikada yaklaşık 2 MB. Her yerde çalınır.';

  @override
  String get recFormatWavStereoHint =>
      'İki kanal, dakikada yaklaşık 4 MB. Siz solda, arayan sağda.';

  @override
  String get recFormatOpusHint =>
      'Dakikada yaklaşık 0,2 MB. Ogg Opus; iPhone, Mac ve Windows\'taki bazı oynatıcılar açamaz.';

  @override
  String get recOptionInherit => 'Genel ayarı kullan';

  @override
  String get recOptionAlways => 'Tüm aramaları kaydet';

  @override
  String get recOptionIncoming => 'Yalnızca gelen aramaları kaydet';

  @override
  String get recOptionOutgoing => 'Yalnızca giden aramaları kaydet';

  @override
  String get recOptionNever => 'Hiç kaydetme';

  @override
  String get recRuleAll => 'Tüm aramalar';

  @override
  String get recRuleIncoming => 'Yalnızca gelen aramalar';

  @override
  String get recRuleOutgoing => 'Yalnızca giden aramalar';

  @override
  String get recAutoDeleteNever => 'Asla';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün sonra',
      one: '1 gün sonra',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => '1 yıl sonra';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıt',
      one: '1 kayıt',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıt',
      one: '1 kayıt',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıt',
      one: '1 kayıt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün',
      one: '1 gün',
    );
    return '$_temp0  ·  $size  ·  $_temp1 sonra otomatik silinir';
  }

  @override
  String get recSettingsFormat => 'Biçim';

  @override
  String get recSettingsAutoGroup => 'Otomatik kayıt';

  @override
  String get recSettingsAutoFooter =>
      'Aramaları kaydetmeden önce yerel yasaları kontrol edin. Bu kurallar ne derse desin bir kişiyle aramaları kaydetmek için kişide \"Bu kişiyle aramaları her zaman kaydet\" seçeneğini açın.';

  @override
  String get recSettingsAutoRule => 'Aramaları otomatik kaydet';

  @override
  String get recSettingsAccountOverride => 'Bu hesap için geçersiz kıl';

  @override
  String get recSettingsNoticesGroup => 'Bildirimler';

  @override
  String get recSettingsNoticeSwitch => 'Kayıttan önce bildirim çal';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Önce karşı tarafa bir bildirim çalar. Bildirim dosyası Ayarlar > Aramalar > Anonslar bölümünden seçilir.';

  @override
  String get recSettingsNoticeFile => 'Bildirim dosyasını seçin';

  @override
  String get recSettingsNoticeFileHint =>
      'Ayarlar > Aramalar > Anonslar bölümünü açar';

  @override
  String get recSettingsBeep => 'Kayıt bip sesi';

  @override
  String get recSettingsBeepHint => 'Karşı tarafı düzenli aralıklarla uyar';

  @override
  String get recSettingsTransfersGroup => 'Aktarmalar';

  @override
  String get recSettingsContinue => 'Aktarmalar boyunca kaydı sürdür';

  @override
  String get recSettingsContinueHint =>
      'Danışmalı aktarmanın danışma aramasını ve aktarmayla bize devredilen aramayı kaydet ve kayıtları bağla';

  @override
  String get recSettingsStorageGroup => 'Depolama';

  @override
  String get recSettingsFolder => 'Klasör';

  @override
  String get recSettingsFolderHint => 'Kayıtların kaydedileceği yer';

  @override
  String get recSettingsFolderPlaceholder => 'Uygulama belgeleri / Kayıtlar';

  @override
  String get recSettingsChooseFolder => 'Klasör seç...';

  @override
  String get recSettingsFolderPickerTitle => 'Kayıtlar klasörü';

  @override
  String get recSettingsAutoDelete => 'Eski kayıtları sil';

  @override
  String get recSettingsAutoDeleteHint =>
      'Başlangıçta ve günde bir kez denetlenir';

  @override
  String get recSettingsManage => 'Kayıtları yönet';

  @override
  String get recSettingsOpenFolder => 'Kayıtlar klasörünü aç';

  @override
  String get recPageTitle => 'Kayıtlar';

  @override
  String recSelectedCount(int count) {
    return '$count seçildi';
  }

  @override
  String get recCancelSelection => 'Seçimi iptal et';

  @override
  String get recSelectAll => 'Tümünü seç';

  @override
  String get recShareSelected => 'Seçilenleri paylaş';

  @override
  String get recDeleteSelected => 'Seçilenleri sil';

  @override
  String get recSearchTooltip => 'Kayıtlarda ara';

  @override
  String get recSelectTooltip => 'Kayıtları seç';

  @override
  String get recMenuSettings => 'Kayıt ayarları';

  @override
  String get recSearchHint => 'Ad veya numara ara';

  @override
  String get recEmptyNone => 'Henüz kayıt yok';

  @override
  String get recEmptyNoneHint =>
      'Kayıt düğmesiyle bir aramayı kaydedin veya Ayarlar\'da otomatik kaydı açın.';

  @override
  String get recEmptyNoMatch => 'Eşleşen kayıt yok';

  @override
  String get recEmptyNoMatchHint => 'Başka bir arama veya filtre deneyin.';

  @override
  String get recClearFilters => 'Filtreleri temizle';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıt silinsin mi?',
      one: '1 kayıt silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Ses dosyaları bu cihazdan kaldırılır. Bu işlem geri alınamaz.';

  @override
  String get recDeleteOneTitle => 'Bu kayıt silinsin mi?';

  @override
  String get recDeleteOneMessage =>
      'Ses dosyası bu cihazdan kaldırılır. Bu işlem geri alınamaz.';

  @override
  String get recFilterAll => 'Tümü';

  @override
  String get recFilterIncoming => 'Gelen';

  @override
  String get recFilterOutgoing => 'Giden';

  @override
  String get recFilterByAccount => 'Hesaba göre filtrele';

  @override
  String get recFilterAllAccounts => 'Tüm hesaplar';

  @override
  String get recFilterAccountFallback => 'Hesap';

  @override
  String get recFilterAnyDate => 'Herhangi bir tarih';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Tarihleri temizle';

  @override
  String get recMissingFile => 'Ses dosyası bu cihazda yok.';

  @override
  String recRelated(String title) {
    return 'İlgili: $title';
  }

  @override
  String get recRenameTitle => 'Kaydı yeniden adlandır';

  @override
  String get recRenameHint => 'Ad';

  @override
  String get recSaveAs => 'Farklı kaydet...';

  @override
  String get recShowInFinder => 'Finder\'da göster';

  @override
  String get recShowInFolder => 'Klasörde göster';

  @override
  String get recViewCall => 'Aramayı görüntüle';

  @override
  String recSavedTo(String path) {
    return '$path konumuna kaydedildi';
  }

  @override
  String get recSaveFailed => 'Kayıt kaydedilemedi';

  @override
  String get recShareFailed => 'Kayıt paylaşılamadı';

  @override
  String get recSaveDialogTitle => 'Kaydı kaydet';

  @override
  String get recShareSubject => 'Arama kayıtları';

  @override
  String get recPlayerUnsupported =>
      'Bu cihaz burada Opus kayıtlarını çalamıyor.';

  @override
  String get recPlayerOpenWith => 'Şununla aç...';

  @override
  String get recPlayerNotFound => 'Kayıt dosyası bulunamadı';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Bu kayıt çalınamıyor: $error';
  }

  @override
  String get recPlayerPlay => 'Kaydı çal';

  @override
  String get recPlayerPause => 'Kaydı duraklat';

  @override
  String get audioFilesTitle => 'Ses dosyaları';

  @override
  String audioAdded(String name) {
    return '\"$name\" eklendi';
  }

  @override
  String get audioFileUnavailable => 'Bu dosya kullanılamıyor.';

  @override
  String get audioNameRequired => 'Bir ad girin';

  @override
  String audioDeleteTitle(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get audioDeleteMessage =>
      'Bu dosyayı kullanan ayarlar varsayılana döner.';

  @override
  String get audioGroupAdd => 'Ekle';

  @override
  String get audioAddFooter =>
      'WAV (PCM, mu-law, A-law) ve MP3 dosyaları çalışır. Dosyalar uygulamaya kopyalanır, böylece orijinal taşınabilir.';

  @override
  String get audioImport => 'WAV veya MP3 içe aktar…';

  @override
  String get audioGroupMine => 'Dosyalarım';

  @override
  String get audioEmptyTitle => 'Henüz dosya yok';

  @override
  String get audioEmptyHint =>
      'Bir dosya içe aktarın veya kendi anonsunuzu kaydedin.';

  @override
  String get audioGroupBuiltIn => 'Yerleşik';

  @override
  String get audioBuiltInFooter =>
      'SoftphonePro için üretildi, özgürce kullanılabilir.';

  @override
  String get audioPreviewStop => 'Önizlemeyi durdur';

  @override
  String audioPreviewPlay(String name) {
    return '$name önizle';
  }

  @override
  String get audioRecordedName => 'Bu kaydı adlandırın';

  @override
  String get audioRecordedDefaultName => 'Anonsum';

  @override
  String audioSaved(String name) {
    return '\"$name\" kaydedildi';
  }

  @override
  String get audioRecorderStop => 'Durdur';

  @override
  String get audioRecorderPlay => 'Kaydı çal';

  @override
  String audioRecorderNew(String duration) {
    return 'Yeni kayıt  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Vazgeç';

  @override
  String get audioRecordOwn => 'Kendinizinkini kaydedin…';

  @override
  String get audioRecordOwnHint => 'Ses ayarlarında seçili mikrofonu kullanır';

  @override
  String get audioMissingFile => 'Eksik dosya';

  @override
  String get audioBuiltInCalm => 'Sakin (yerleşik)';

  @override
  String get audioBuiltInBreeze => 'Esinti (yerleşik)';

  @override
  String get audioBuiltInChime => 'Bildirim zili (yerleşik)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Yalnızca WAV ve MP3 dosyaları kullanılabilir.';

  @override
  String get audioErrNotFound => 'Bu dosya bulunamadı.';

  @override
  String get audioErrNotSaved => 'Kayıt kaydedilmedi.';

  @override
  String get audioErrEmpty => 'Bu ses dosyası boş veya okunamıyor.';

  @override
  String audioErrUnusable(String reason) {
    return 'Bu ses dosyası kullanılamaz ($reason). PCM, mu-law veya A-law WAV ya da MP3 kullanın.';
  }

  @override
  String get audioRecEngineOff => 'Arama altyapısı çalışmıyor.';

  @override
  String get audioRecUnsupported =>
      'Arama altyapısının bu sürümü mikrofonu kaydedemiyor.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Kayıt başlatılamadı: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Kayıt başarısız oldu: $reason';
  }

  @override
  String get audioStrengthLow => 'Düşük';

  @override
  String get audioStrengthMedium => 'Orta';

  @override
  String get audioStrengthHigh => 'Yüksek';

  @override
  String get audioStrengthMax => 'En yüksek';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label (%$percent)';
  }

  @override
  String get audioSystemDefault => 'Sistem varsayılanı';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Sistem varsayılanı ($name)';
  }

  @override
  String get voiceTitle => 'Ses yalıtımı';

  @override
  String get voiceUnavailable =>
      'Yapay zekâ gürültü engelleme, arama altyapısının bu sürümünde kullanılamıyor. İşleme altındaki standart gürültü bastırma yine de çalışır.';

  @override
  String get voiceGroupAi => 'Yapay zekâ gürültü engelleme';

  @override
  String get voiceAiFooter =>
      'Cihaz üzerindeki bir sinir ağı (RNNoise) kullanarak klavye tıkırtılarını, fanları ve arka plan seslerini aramadan kaldırır. Hiçbir şey cihazınızdan çıkmaz. Daha yüksek güç daha fazla gürültüyü kaldırır ancak kelime başlarını kırpabilir.';

  @override
  String get voiceMic => 'Mikrofonum';

  @override
  String get voiceMicHint => 'Karşı tarafın duyduğunu temizle';

  @override
  String get voiceOthers => 'Diğer katılımcılar';

  @override
  String get voiceOthersHint => 'Duyduğunuz gürültülü arayanları temizle';

  @override
  String voiceStrength(String value) {
    return 'Güç: $value';
  }

  @override
  String get voiceGroupTry => 'Deneyin';

  @override
  String get voiceTryFooter =>
      'Yankı testi için kulaklık kullanın, yoksa geri besleme duyarsınız.';

  @override
  String get voiceEchoTest => 'Yankıyla test et';

  @override
  String get voiceEchoTestHint => 'İşlenmiş mikrofonunuzu size geri çalar';

  @override
  String get voiceEchoFailed => 'Yankı testi başarısız oldu';

  @override
  String get voiceGroupSystem => 'Sistem';

  @override
  String get voiceSystemFooter =>
      'macOS ve iOS, her uygulama için sesinizi yalıtabilir. Sistem mikrofon modunda Ses Yalıtımı\'nı seçin.';

  @override
  String get voiceSystemMode => 'Sistem mikrofon modu (Ses Yalıtımı)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Mikrofon modları için macOS 12 veya iOS 15 ya da üstü gerekir.';

  @override
  String get voiceSpeechDetection => 'Konuşma algılama';

  @override
  String voiceSpeechPercent(int percent) {
    return 'yüzde $percent';
  }

  @override
  String voicePercent(int percent) {
    return '%$percent';
  }

  @override
  String get voiceGroupAndroid => 'Android ses efektleri';

  @override
  String get voiceAndroidFooter =>
      'Telefon mikrofonu kendisi de temizleyebilir. Bunlar Android tarafından bildirilir ve yukarıdaki ayardan bağımsızdır.';

  @override
  String get voiceAndroidNs => 'Gürültü bastırıcı';

  @override
  String get voiceAndroidAec => 'Yankı engelleyici';

  @override
  String get voiceNotAvailableDevice => 'Bu cihazda kullanılamıyor';

  @override
  String get callLinkNotLocal =>
      'Bu bağlantı türü yalnızca bu bilgisayarın komut satırından kullanılabilir.';

  @override
  String linkLanConnectTitle(String name) {
    return '$name cihazına bağlanılsın mı?';
  }

  @override
  String get linkLanConnectBody =>
      'Başka bir uygulamadan veya web sayfasından gelen bir bağlantı SoftphonePro\'yu bu cihaza bağlamak istiyor. Yalnızca bunu bekliyorsanız bağlanın.';

  @override
  String get linkLanConnectAction => 'Bağlan';

  @override
  String get linkImportSensitiveHeader =>
      'Bu yapılandırmadaki hassas değişiklikler:';

  @override
  String get linkImportFlagAutoAnswer => 'Gelen aramaları otomatik yanıtlar';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Aramaları $target numarasına yönlendirir';
  }

  @override
  String get linkImportFlagIntercom =>
      'Kimin interkom başlatabileceğini veya arama devralabileceğini değiştirir (LAN)';

  @override
  String get linkImportFlagDialRewrite =>
      'Çevirdiğiniz numaraları yeniden yazar';

  @override
  String get linkImportFlagLinksImmediately =>
      'Web bağlantılarından gelen aramalar onay olmadan hemen başlar';

  @override
  String get linkImportFlagDiagnostics =>
      'Ayrıntılı günlüğü veya SIP izlemeyi açar';

  @override
  String get linkImportAllowAutoAnswer =>
      'İçe aktarılan hesaplar için otomatik yanıtlamaya izin ver';

  @override
  String linkImportRefused(String setting) {
    return 'Bu içe aktarma, bağlantı, QR kodu, yapıştırılan metin veya dosya ile asla ayarlanamayan \"$setting\" ayarını değiştirmeye çalışıyor. Bunun yerine bu bilgisayarda --provision komut satırı seçeneğini kullanın. Hiçbir şey içe aktarılmadı.';
  }

  @override
  String get lanPairIntercomNote =>
      'Eşleştirilmiş cihazlar interkom araması isteyebilir; her seferinde size sorulur (Ayarlar > LAN bölümünden değiştirilebilir).';

  @override
  String get callLinkUnsupportedScheme => 'Bu tür bağlantı desteklenmiyor.';

  @override
  String get linkImportFlagAutoRecord => 'Aramaları otomatik olarak kaydeder';

  @override
  String get linkImportFlagBlocklist => 'Arama engelleme listenizi değiştirir';

  @override
  String get linkImportFlagEmergency => 'Acil durum numaralarınızı değiştirir';

  @override
  String get linkImportFlagSpeedDial => 'Hızlı arama numaraları ayarlar';

  @override
  String get linkImportFlagRecordingDelete =>
      'Eski kayıtları otomatik olarak siler';

  @override
  String get linkImportFlagFeatureCodes =>
      'Özel santral özellik kodlarını arar';

  @override
  String get linkImportAllowAutoRecord => 'Otomatik arama kaydına izin ver';

  @override
  String get importIgnoredHeader =>
      'Yok sayıldı (içe aktarmada izin verilmez):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - sunucu $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Proxy\'ler: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN aktarıcı: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Özel SIP başlıkları: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'Arayan kimliği: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'Medya şifrelemesi yok (SRTP kapalı)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Adres: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return '$updated mevcut hesabı güncelle, $added yeni hesap ekle';
  }

  @override
  String get mixerTitle => 'Ses karıştırıcı';

  @override
  String get mixerMicrophone => 'Mikrofon';

  @override
  String get mixerSpeaker => 'Kulaklık ve hoparlör';

  @override
  String get mixerMicVolume => 'Mikrofon ses düzeyi';

  @override
  String get mixerSpeakerVolume => 'Hoparlör ses düzeyi';

  @override
  String mixerMeterLabel(String name) {
    return '$name düzeyi';
  }

  @override
  String get mixerInputDevice => 'Giriş aygıtı';

  @override
  String get mixerOutputDevice => 'Çıkış aygıtı';

  @override
  String get mixerOutputRoute => 'Ses çıkışı';

  @override
  String get mixerInputFollowsOutput => 'Mikrofon, seçilen ses çıkışını izler.';

  @override
  String get mixerShowMore => 'Aygıtları ve fon müziğini göster';

  @override
  String get mixerShowLess => 'Daha az denetim göster';

  @override
  String get mixerStripShow => 'Ses karıştırıcıyı göster';

  @override
  String get mixerStripHide => 'Ses karıştırıcıyı gizle';

  @override
  String get musicbedTitle => 'Fon müziği';

  @override
  String get musicbedPlay => 'Fon müziğini çal';

  @override
  String get musicbedVolume => 'Fon müziği ses düzeyi';

  @override
  String get musicbedChooseFile => 'Dosya seç';

  @override
  String musicbedChangeFile(String name) {
    return 'Fon müziği dosyası: $name. Değiştirmek için dokunun.';
  }

  @override
  String get musicbedHearIt => 'Ben de duyayım';

  @override
  String get musicbedMonitorVolume => 'İzleme ses düzeyi';

  @override
  String get musicbedAddFile => 'Dosya ekle…';

  @override
  String get musicbedPickerTitle => 'Fon müziği dosyası';

  @override
  String get musicbedOn => 'Fon müziği açık';

  @override
  String get musicbedOnTooltip =>
      'Aramalarınızdaki herkese bir müzik dosyası çalınıyor.';

  @override
  String get musicbedFileMissing =>
      'Fon müziği dosyası artık yok, bu yüzden fon müziği kapatıldı.';

  @override
  String get musicbedNeedsFile => 'Önce bir fon müziği dosyası seçin.';

  @override
  String musicbedStopped(String message) {
    return 'Fon müziği durduruldu: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Aramalarınızdaki herkes için sesinizin altında bir müzik dosyasını döngüyle çalar; sessizdeyken bile. Beklemedeki aramalar bunun yerine bekletme müziğini duyar.';

  @override
  String get musicbedSettingsFile => 'Müzik dosyası';

  @override
  String get linkImportFlagMusicbed => 'Aramalarınızda müzik çalar';

  @override
  String get musicbedMonitorIosHint =>
      'iPhone’da bunu aramalar sırasında duyarsınız';

  @override
  String get musicbedStopFailed =>
      'Müzik durdurulamadı. Karşınızdakiler hâlâ duyuyor olabilir.';
}
