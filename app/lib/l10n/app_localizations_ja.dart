// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystemDefault => 'システムの設定';

  @override
  String get languagePickerHint => '言語名はそれぞれの言語で表示されます。';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionDone => '完了';

  @override
  String get actionAdd => '追加';

  @override
  String get actionEdit => '編集';

  @override
  String get actionRename => '名前を変更';

  @override
  String get actionClear => 'クリア';

  @override
  String get actionBack => '戻る';

  @override
  String get actionCopy => 'コピー';

  @override
  String get actionShare => '共有';

  @override
  String get actionImport => 'インポート';

  @override
  String get actionExport => 'エクスポート';

  @override
  String get actionDetails => '詳細';

  @override
  String get actionMore => 'その他';

  @override
  String get actionSettings => '設定';

  @override
  String get actionSearch => '検索';

  @override
  String get actionRefresh => '更新';

  @override
  String get actionContinue => '続ける';

  @override
  String get actionYes => 'はい';

  @override
  String get actionNo => 'いいえ';

  @override
  String get commonOn => 'オン';

  @override
  String get commonOff => 'オフ';

  @override
  String get commonNone => 'なし';

  @override
  String get commonDefault => 'デフォルト';

  @override
  String get commonSystem => 'システム';

  @override
  String get commonAutomatic => '自動';

  @override
  String get commonUnknown => '不明';

  @override
  String get commonNotSet => '未設定';

  @override
  String get commonError => 'エラー';

  @override
  String get commonLoading => '読み込み中…';

  @override
  String get statusAvailable => '対応可能';

  @override
  String get statusDoNotDisturb => '応答不可';

  @override
  String get statusOffline => 'オフライン';

  @override
  String get statusOnACall => '通話中';

  @override
  String get settingsEntryAccounts => 'アカウント';

  @override
  String get settingsEntryAccountsSub => 'SIPアカウントと登録';

  @override
  String get settingsEntryAudio => 'オーディオ';

  @override
  String get settingsEntryAudioSub => 'デバイス、音量、エコーキャンセル';

  @override
  String get settingsEntryCodecs => 'コーデック';

  @override
  String get settingsEntryCodecsSub => '順序、有効化、Opus';

  @override
  String get settingsEntryCalls => '通話';

  @override
  String get settingsEntryCallsSub => '応答不可、通話待機、自動応答、ダイヤル規則';

  @override
  String get settingsEntryNetwork => 'ネットワーク';

  @override
  String get settingsEntryNetworkSub => 'トランスポート、STUN、TLS、DNS';

  @override
  String get settingsEntryRecording => '録音';

  @override
  String get settingsEntryNotifications => '通知と着信音';

  @override
  String get settingsEntryShortcuts => 'ショートカット';

  @override
  String get settingsEntryShortcutsSub => 'グローバルホットキー、アプリ内キー';

  @override
  String get settingsEntryAppearance => '外観';

  @override
  String get settingsEntryPrivacy => 'プライバシーとセキュリティ';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'プロビジョニング';

  @override
  String get settingsEntryProvisioningSub => 'インポート、エクスポート、QR';

  @override
  String get settingsEntryDiagnostics => '診断';

  @override
  String get settingsEntryDiagnosticsSub => 'SIPトレース、ネットワークチェック';

  @override
  String get settingsEntryAdvanced => '詳細設定';

  @override
  String get settingsEntryAbout => 'このアプリについて';

  @override
  String get settingsAccountsEmptyTitle => '最初のアカウントを追加';

  @override
  String get settingsAccountsEmptySubtitle => 'PBXまたはSIPプロバイダーに接続して、発信を始めましょう。';

  @override
  String get settingsAccountsAdd => 'アカウントを追加';

  @override
  String get settingsAccountsYourAccounts => 'アカウント一覧';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  バックアップサーバー使用中';
  }

  @override
  String get settingsAudioDevices => 'デバイス';

  @override
  String get settingsAudioMicrophone => 'マイク';

  @override
  String get settingsAudioSpeaker => 'スピーカー';

  @override
  String get settingsAudioRinger => '着信音の出力先';

  @override
  String get settingsAudioRingerSub => '着信音を別のデバイスで再生します';

  @override
  String get settingsAudioRefreshDevices => 'デバイスを再検出';

  @override
  String get settingsAudioLevelsAndTest => '音量とテスト';

  @override
  String get settingsAudioMicVolume => 'マイク音量';

  @override
  String get settingsAudioMicLevel => 'マイクレベル';

  @override
  String get settingsAudioSpeakerVolume => 'スピーカー音量';

  @override
  String get settingsAudioSpeakerLevel => 'スピーカーレベル';

  @override
  String get settingsAudioTestSpeaker => 'スピーカーをテスト';

  @override
  String get settingsAudioTestSpeakerSub => '選択したスピーカーから短い音を再生します';

  @override
  String get settingsAudioTestToneFailed => 'テスト音を再生できませんでした';

  @override
  String get settingsAudioEchoTestFailed => 'エコーテストに失敗しました';

  @override
  String get settingsAudioEchoTest => 'エコーテスト';

  @override
  String get settingsAudioEchoTestSub =>
      'マイクの音をスピーカーから再生します。ハウリングを防ぐため、ヘッドフォンを使用してください。';

  @override
  String get settingsAudioVoiceAndFiles => '音声とファイル';

  @override
  String get settingsAudioVoiceIsolation => '音声分離（AIノイズキャンセル）';

  @override
  String get settingsAudioAudioFiles => 'オーディオファイル';

  @override
  String get settingsAudioAudioFilesSub => '保留音とアナウンス';

  @override
  String get settingsAudioProcessing => '音声処理';

  @override
  String get settingsAudioEchoCancellation => 'エコーキャンセル';

  @override
  String get settingsAudioEcSimple => 'シンプル';

  @override
  String get settingsAudioEcPlatform => 'OS標準';

  @override
  String get settingsAudioEchoTail => 'エコーテール';

  @override
  String get settingsAudioNoiseSuppression => 'ノイズ抑制';

  @override
  String get settingsAudioAgc => '自動ゲイン制御';

  @override
  String get settingsAudioVad => '音声区間検出';

  @override
  String get settingsAudioVadSub => '無音時の帯域を節約します';

  @override
  String get settingsAudioAdvanced => '詳細設定';

  @override
  String get settingsAudioAdvancedFooter =>
      'ジッターバッファの値はミリ秒単位です。-1 を指定するとエンジンの既定値を使用します。変更すると通話エンジンが再起動します。';

  @override
  String get settingsAudioPtime => 'パケット時間（ptime）';

  @override
  String get settingsAudioJbInitial => 'ジッターバッファ：初期値';

  @override
  String get settingsAudioJbMinPrefetch => 'ジッターバッファ：最小プリフェッチ';

  @override
  String get settingsAudioJbMaxPrefetch => 'ジッターバッファ：最大プリフェッチ';

  @override
  String get settingsAudioJbMaxSize => 'ジッターバッファ：最大サイズ';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'マイク $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return '相手側 $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent パーセント';
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
      other: '$count秒',
      one: '1秒',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => '順序と有効化';

  @override
  String get settingsCodecsDragHint => 'ドラッグして並べ替えます。アカウントごとの設定でこのリストを上書きできます。';

  @override
  String get settingsCodecsBitrate => 'ビットレート';

  @override
  String get settingsCodecsFec => 'インバンドFEC';

  @override
  String get settingsCodecsFecSub => 'パケット損失から回復します';

  @override
  String get settingsCodecsDtxSub => '無音時は送信を停止します';

  @override
  String get settingsCodecsCbr => '固定ビットレート';

  @override
  String get settingsCodecsComplexity => '複雑度';

  @override
  String get settingsCallsIncoming => '着信';

  @override
  String get settingsCallsDndSub => 'すべての着信を拒否します';

  @override
  String get settingsCallsRejectWith => '拒否時の応答';

  @override
  String get settingsCallsReasonBusy => 'Busy Here（486）';

  @override
  String get settingsCallsReasonUnavailable => 'Temporarily Unavailable（480）';

  @override
  String get settingsCallsReasonDecline => 'Decline（603）';

  @override
  String get settingsCallsWaiting => '通話待機';

  @override
  String get settingsCallsWaitingSub => '通話中に2件目の着信を受け付けます';

  @override
  String get settingsCallsWhenBusy => '通話中で通話待機がオフのとき';

  @override
  String get settingsCallsRejectAnonymous => '非通知の着信を拒否';

  @override
  String get settingsCallsLinksImmediately => 'リンクからすぐに発信';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'tel:、sip:、callto: のリンクは、ダイヤラーで待たずに発信します';

  @override
  String get settingsCallsSyncFeatureCodes => '応答不可／転送をフィーチャーコードでPBXに同期';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      '応答不可や転送を変更したときに、アカウントのスターコード（例：*78）を短時間ダイヤルします';

  @override
  String get settingsCallsAutoAnswerGroup => '自動応答';

  @override
  String get settingsCallsAutoAnswerFooter =>
      '着信転送とアカウントごとの自動応答は、各アカウントで設定します。';

  @override
  String get settingsCallsAutoAnswerAll => 'すべての着信に自動応答';

  @override
  String get settingsCallsAnswerAfter => '応答までの時間';

  @override
  String get settingsCallsAnswerImmediately => 'すぐに応答';

  @override
  String get settingsCallsIntercomHeaders => 'インターコムヘッダーに従う';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info、Alert-Info、Answer-Mode による自動応答の指示';

  @override
  String get settingsCallsBlocked => '着信拒否の番号';

  @override
  String get settingsCallsBlockNumber => '番号を拒否';

  @override
  String get settingsCallsBlockNumberTitle => '番号を拒否';

  @override
  String get settingsCallsBlockNumberHint => '電話番号またはSIPアドレス';

  @override
  String get settingsCallsSpeedDial => '短縮ダイヤル';

  @override
  String get settingsCallsDialPlan => 'ダイヤルプラン';

  @override
  String get settingsCallsDialRules => 'ダイヤル規則';

  @override
  String get settingsCallsStripPrefix => '削除する外線発信番号';

  @override
  String get settingsCallsStripPrefixSub => '例：9。ダイヤルした番号の先頭から削除されます';

  @override
  String get settingsCallsPlusReplacement => '先頭の + の置き換え';

  @override
  String get settingsCallsPlusReplacementSub => '例：国際アクセスコードの 00';

  @override
  String get settingsCallsPlusReplacementHint => '+ をそのまま使用';

  @override
  String get settingsCallsCountryPrefix => 'デフォルトの国番号';

  @override
  String get settingsCallsCountryPrefixSub => '0で始まる国内番号にこの番号が付きます（例：+44）';

  @override
  String get settingsCallsEmergency => '緊急通報番号';

  @override
  String get settingsCallsEmergencySub => 'カンマ区切り。ダイヤル規則は適用されません。';

  @override
  String settingsCallsUnblock(String number) {
    return '$number の拒否を解除';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '9件中$count件を割り当て済み';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のルール',
      one: '1件のルール',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => '新しいダイヤル規則';

  @override
  String get settingsDialRulesEdit => 'ダイヤル規則を編集';

  @override
  String get settingsDialRulesName => '名前';

  @override
  String get settingsDialRulesPattern => 'パターン（正規表現）';

  @override
  String get settingsDialRulesReplacement => '置換後';

  @override
  String get settingsDialRulesReplacementHelp => 'グループには \$1、\$2 を使用';

  @override
  String get settingsDialRulesRoute => '経由するアカウント';

  @override
  String get settingsDialRulesAdd => 'ルールを追加';

  @override
  String get settingsDialRulesLiveTest => 'ライブテスト';

  @override
  String get settingsDialRulesTyped => '入力した番号';

  @override
  String get settingsDialRulesNothing => '（なし）';

  @override
  String get settingsDialRulesEmergency => '緊急通報番号：入力どおりにダイヤルします';

  @override
  String get settingsDialRulesAccountFallback => 'アカウント';

  @override
  String get settingsDialRulesEmpty =>
      'ルールはありません。番号はスペース、ハイフン、括弧を取り除いて、入力どおりにダイヤルされます。ルールは上から順に適用され、最初に一致したものが使われます。';

  @override
  String get settingsDialRulesDelete => 'ルールを削除';

  @override
  String get settingsDialRulesDeleteTitle => 'ルールを削除しますか？';

  @override
  String settingsDialRulesVia(String account) {
    return '$account 経由';
  }

  @override
  String get settingsNetworkTransports => 'トランスポート';

  @override
  String get settingsNetworkTransportsFooter =>
      'ポート0を指定すると、空いているポートがランダムに選ばれます。トランスポートを変更すると通話エンジンが再起動します。';

  @override
  String get settingsNetworkUdpPort => 'UDPポート';

  @override
  String get settingsNetworkTcpPort => 'TCPポート';

  @override
  String get settingsNetworkTlsPort => 'TLSポート';

  @override
  String get settingsNetworkVerifyCerts => 'サーバー証明書を検証';

  @override
  String get settingsNetworkVerifyCertsSub =>
      '自己署名証明書のPBXの場合のみオフにするか、下で証明書をピン留めしてください';

  @override
  String get settingsNetworkCustomCa => 'カスタムCAファイル';

  @override
  String get settingsNetworkCustomCaSub => '内蔵リストの代わりに使うPEMバンドル（プライベートPBXのCA）';

  @override
  String get settingsNetworkCustomCaHint => '内蔵のMozillaリスト';

  @override
  String get settingsNetworkPins => 'ピン留めした証明書';

  @override
  String get settingsNetworkPinsSub => 'ホスト=SHA256フィンガープリント（カンマ区切り）';

  @override
  String get settingsNetworkNat => 'NAT越え';

  @override
  String get settingsNetworkStun => 'STUNサーバー';

  @override
  String get settingsNetworkStunSub => 'ホスト:ポート（カンマ区切り）';

  @override
  String get settingsNetworkIceTurn => 'ICEとTURN';

  @override
  String get settingsNetworkIceTurnSub => 'アカウントごとにNATの項目で設定します';

  @override
  String get settingsNetworkAdvanced => '詳細設定';

  @override
  String get settingsNetworkQos => 'QoS（DSCPマーキング）';

  @override
  String get settingsNetworkQosSub => 'SIPと音声パケットに優先度を設定します';

  @override
  String get settingsNetworkDns => 'DNSサーバー';

  @override
  String get settingsNetworkDnsSub => '空欄の場合は自動';

  @override
  String get settingsNetworkRtpStart => 'RTPポートの開始値';

  @override
  String get settingsNetworkRtpRange => 'RTPポートの範囲';

  @override
  String get settingsNetworkRtpRangeSub => '0の場合はデフォルト';

  @override
  String get settingsNotifRingtone => '着信音';

  @override
  String get settingsNotifDefaultRingtone => 'デフォルトの着信音';

  @override
  String get settingsNotifProgressTones => '通話進行音';

  @override
  String get settingsNotifProgressTonesSub => '発信中の呼び出し音、話し中音、輻輳音';

  @override
  String get settingsNotifRingerVolume => '着信音量';

  @override
  String get settingsNotifCustomRingtone => 'カスタム着信音ファイル';

  @override
  String get settingsNotifCustomRingtoneSub => 'WAVファイルのパス（デスクトップ）';

  @override
  String get settingsNotifGroup => '通知';

  @override
  String get settingsNotifRequestPermissions => '権限をリクエスト';

  @override
  String get settingsNotifRequestPermissionsSub => 'マイクと通知';

  @override
  String get settingsNotifTyping => '入力中インジケーターを送信';

  @override
  String get settingsAppearanceTheme => 'テーマ';

  @override
  String get settingsAppearanceLight => 'ライト';

  @override
  String get settingsAppearanceDark => 'ダーク';

  @override
  String get settingsAppearanceAccent => 'アクセントカラー';

  @override
  String get settingsAppearanceAccentOption => 'アクセントカラーの選択肢';

  @override
  String get settingsAppearanceCompact => 'コンパクト表示';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'マイク：$microphone、通知：$notifications';
  }

  @override
  String get settingsPrivacySecurity => 'セキュリティ';

  @override
  String get settingsPrivacyPasswords => 'パスワード';

  @override
  String get settingsPrivacyPasswordsSub => 'システムのキーチェーン／キーストアに保存（暗号化ファイルで代替）';

  @override
  String get settingsPrivacyGroup => 'プライバシー';

  @override
  String get settingsPrivacyNoTelemetry => 'テレメトリーなし';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphoneProは分析データを送信しません。ネットワーク通信はSIPサーバーとのみ行われます。';

  @override
  String get settingsPrivacyYourData => 'お客様のデータ';

  @override
  String get settingsPrivacyClearHistory => '通話履歴を消去';

  @override
  String get settingsPrivacyDeleteContacts => 'すべての連絡先を削除';

  @override
  String get settingsPrivacyDeleteMessages => 'すべてのメッセージを削除';

  @override
  String get settingsPrivacyConfirmHistory => '通話履歴を削除しますか？';

  @override
  String get settingsPrivacyConfirmContacts => 'すべての連絡先を削除しますか？';

  @override
  String get settingsPrivacyConfirmMessages => 'すべてのメッセージを削除しますか？';

  @override
  String get settingsPrivacyCannotUndo => 'この操作は元に戻せません。';

  @override
  String get settingsPrivacyDeletedHistory => '通話履歴を削除しました';

  @override
  String get settingsPrivacyDeletedContacts => 'すべての連絡先を削除しました';

  @override
  String get settingsPrivacyDeletedMessages => 'すべてのメッセージを削除しました';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      '同じネットワーク上のデバイス同士が互いを見つけ、6桁のコードでペアリングして、サーバーを介さずに直接通話できます。';

  @override
  String get settingsLanEnable => 'LAN Linkを有効にする';

  @override
  String get settingsLanDeviceName => 'デバイス名';

  @override
  String get settingsLanDeviceNameHint => 'このデバイス';

  @override
  String get settingsLanAllowIntercom => 'インターコムを許可';

  @override
  String get settingsLanAllowIntercomSub => 'ペアリング済みのデバイスからの発信を許可し、自動応答します';

  @override
  String get settingsLanAskIntercom => 'インターコムの許可前に確認';

  @override
  String get settingsLanAskIntercomSub =>
      'オフの場合、ペアリング済みのデバイスからの要求後30秒間は自動応答します';

  @override
  String get settingsLanAutoAcceptFiles => 'ペアリング済みデバイスからのファイルを自動受信';

  @override
  String get settingsLanAutoAcceptFilesSub => 'オフの場合、ファイルごとに確認します';

  @override
  String get settingsLanAllowPull => 'ペアリング済みデバイスへの通話移行を許可';

  @override
  String get settingsLanAllowPullSub => 'ペアリング済みのデバイスが、ここで通話中の通話を引き継げます';

  @override
  String get settingsLanDownloads => 'ダウンロードフォルダ';

  @override
  String get settingsLanDownloadsHint => 'デフォルト（Downloads/SoftphonePro）';

  @override
  String get settingsLanPort => 'リンクポート';

  @override
  String get settingsLanSharedAccounts => 'ペアリング済みデバイスと共有するアカウント';

  @override
  String get settingsLanSharedAccountsFooter =>
      '登録済みのアカウントを共有すると、同じサーバー上のペアリング済みデバイスが、中継を介さずに着信を直接受けられます（通話転送）。';

  @override
  String get settingsAdvEngine => 'エンジン';

  @override
  String get settingsAdvSimulator => 'シミュレーターを使用';

  @override
  String get settingsAdvSimulatorSub => 'ネイティブエンジンなしで動作します。通話はシミュレートされます。';

  @override
  String get settingsAdvLogLevel => 'ログレベル';

  @override
  String get settingsAdvLogErrors => 'エラー';

  @override
  String get settingsAdvLogInfo => '情報';

  @override
  String get settingsAdvLogDebug => 'デバッグ';

  @override
  String get settingsAdvLogVerbose => '詳細';

  @override
  String get settingsAdvSipTrace => 'SIPトレース';

  @override
  String get settingsAdvRestartEngine => 'エンジンを再起動';

  @override
  String get settingsAdvDesktop => 'デスクトップ';

  @override
  String get settingsAdvStartAtLogin => 'ログイン時に起動';

  @override
  String get settingsAdvCloseToTray => 'トレイに格納して閉じる';

  @override
  String get settingsAdvCloseToTraySub =>
      'ウィンドウを閉じてもSoftphoneProは動作し続け、着信を受けられます。終了するには、トレイ／メニューバーのアイコンから行ってください。';

  @override
  String get settingsAboutLicence => 'ライセンス';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphoneProはフリーソフトウェアです。Free Software Foundationが公開するGNU General Public License バージョン3以降の条件に従って、再配布および改変できます。本ソフトウェアは一切の保証なしで配布されます。';

  @override
  String get settingsAboutGpl => 'GNU GPL v3以降';

  @override
  String get settingsAboutGplSub => 'ソースコードはプロジェクトのリポジトリで公開されています';

  @override
  String get settingsAboutThirdParty => 'サードパーティの通知';

  @override
  String get settingsAboutPackages => 'FlutterおよびDartパッケージ';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause、MIT、Apache 2.0。ライセンスのページをご覧ください。';

  @override
  String settingsAboutVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String settingsAboutNotice(String license, String purpose) {
    return '$license。$purpose。';
  }

  @override
  String settingsAboutNoticeVersion(
    String license,
    String purpose,
    String version,
  ) {
    return '$license。$purpose。バージョン $version。';
  }

  @override
  String get updatesChecking => '確認中...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version が利用可能です';
  }

  @override
  String get updatesUpToDate => '最新の状態です';

  @override
  String get updatesCouldNotCheck => '確認できませんでした';

  @override
  String get updatesNotCheckedYet => '未確認';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '最終確認：$dateString';
  }

  @override
  String get updatesTitle => 'アップデート';

  @override
  String get updatesFooter =>
      '確認時の通信先はapi.github.comのみ（週1回）で、リクエスト以外は何も送信しません。識別子、アカウント、通話のデータは送られません。SoftphoneProが自動でダウンロードやインストールを行うことはありません。';

  @override
  String get updatesCheckSwitch => 'アップデートを確認';

  @override
  String get updatesCheckNow => '今すぐ確認';

  @override
  String updatesSkippingVersion(String version) {
    return 'バージョン $version をスキップ中';
  }

  @override
  String get updatesStopSkipping => 'スキップを解除';

  @override
  String get updatesReleaseNotes => 'リリースノート';

  @override
  String get updatesDownload => 'ダウンロード';

  @override
  String get updatesSkipVersion => 'このバージョンをスキップ';

  @override
  String get updatesDismiss => '閉じる';

  @override
  String get updatesRateLimited => 'GitHubのレート制限に達しました。しばらくしてからもう一度お試しください';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHubの応答：$status';
  }

  @override
  String get updatesUnexpectedReply => '予期しない応答です';

  @override
  String get updatesTimedOut => 'タイムアウトしました';

  @override
  String get updatesAlreadyChecking => 'すでに確認中です';

  @override
  String get encryptionTitle => '暗号化';

  @override
  String get encryptionFooter =>
      'ローカルデータベースをAES-256-GCMで暗号化します。鍵はシステムのキーチェーン／キーストアに保管され、紛失するとデータを復元できません。通話の録音とエクスポートしたファイルは暗号化されません。変更は次回SoftphoneProを起動したときに反映されます（先に完全に終了してください）。以前のファイルは、新しいデータベースを開いて検証した直後に上書きして削除されます。';

  @override
  String get encryptionSwitchTitle => 'このデバイスの通話履歴、連絡先、メッセージを暗号化';

  @override
  String get encryptionWillEncrypt => '次回の起動時に暗号化されます';

  @override
  String get encryptionWillDecrypt => '次回の起動時に復号されます';

  @override
  String get encryptionRestartToEncrypt =>
      'データを暗号化するには、SoftphoneProを終了して再起動してください。';

  @override
  String get encryptionRestartToDecrypt =>
      'データを復号するには、SoftphoneProを終了して再起動してください。';

  @override
  String speedDialSlotTitle(int slot) {
    return '短縮ダイヤル $slot';
  }

  @override
  String get speedDialNumberLabel => '電話番号またはSIPアドレス';

  @override
  String get speedDialLabelOptional => 'ラベル（任意）';

  @override
  String get speedDialCallFrom => '発信元';

  @override
  String get speedDialSelectedAccount => '選択中のアカウント';

  @override
  String get speedDialTitle => '短縮ダイヤル';

  @override
  String get speedDialHint => '空のキーパッドで数字（1〜9）を長押しすると、その番号に発信します。';

  @override
  String get speedDialNotAssigned => '未割り当て';

  @override
  String provisioningNotValidJson(String detail) {
    return '有効なJSONではありません：$detail';
  }

  @override
  String get provisioningExpectedObject => 'JSONオブジェクトが必要です';

  @override
  String provisioningUnsupportedVersion(String version) {
    return '未対応の設定バージョン $version';
  }

  @override
  String get provisioningSkippedAccountEntry => 'オブジェクトではないアカウント項目をスキップしました';

  @override
  String get provisioningNothingToImport => 'ファイルにアカウントも設定も含まれていません';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'アカウント「$name」にはユーザー名とドメインが必要です';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'サーバーの応答：$status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return '設定をダウンロードできませんでした：$error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '$path を読み込めませんでした';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のアカウントをインポートしました',
      one: '1件のアカウントをインポートしました',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => '設定のインポート';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: 'アカウント$accounts件',
      one: 'アカウント1件',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '設定$settings件',
      one: '設定1件',
    );
    return '$_temp0、$_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'URLまたはJSONからインポート';

  @override
  String get provisioningImportFromUrlHint => 'https://... またはJSONを貼り付け';

  @override
  String get provisioningInvalidSource => '有効なURL、リンク、JSONではありません';

  @override
  String get provisioningScanTitle => 'プロビジョニングQRをスキャン';

  @override
  String get provisioningPasteHint => 'JSON、リンク、URLを貼り付け';

  @override
  String get provisioningImportGroup => 'インポート';

  @override
  String get provisioningImportFooter =>
      'アカウントと設定を含むJSONに対応しています。\${VAR} のプレースホルダーは、\${VAR:-default} の形式でデフォルト値を指定しない限り、空の値で置き換えられます。';

  @override
  String get provisioningScanQr => 'QRコードをスキャン';

  @override
  String get provisioningFromUrl => 'URLまたは貼り付けたJSONから';

  @override
  String get provisioningFromFile => 'ファイルから';

  @override
  String get provisioningFromClipboard => 'クリップボードから';

  @override
  String get provisioningExportGroup => 'エクスポート';

  @override
  String get provisioningIncludePasswords => 'パスワードを含める';

  @override
  String get provisioningIncludePasswordsHint => 'ファイルを入手した人は誰でもアカウントを使用できます';

  @override
  String get provisioningCopyConfig => '設定をコピー（JSON）';

  @override
  String get provisioningConfigCopied => '設定をコピーしました';

  @override
  String get provisioningQrGroup => 'QRコード';

  @override
  String get provisioningQrFooter =>
      '別のデバイスでこのコードをスキャンすると、アカウントをコピーできます。パスワードが含まれる場合は、パスワードと同様に扱ってください。';

  @override
  String get provisioningQrAccount => 'アカウント';

  @override
  String get provisioningChoose => '選択...';

  @override
  String get provisioningQrTooMuchData => 'QRコードにするにはデータが大きすぎます';

  @override
  String tlsClearField(String field) {
    return '$field をクリア';
  }

  @override
  String get tlsChoose => '選択...';

  @override
  String get tlsChange => '変更...';

  @override
  String get tlsClientCertTitle => 'クライアント証明書（相互TLS）';

  @override
  String get tlsIncomplete => '証明書と秘密鍵の両方を選択してください。証明書は、両方を設定した場合にのみ提示されます。';

  @override
  String get tlsFooter =>
      'アプリに証明書での本人確認を求めるサーバー向けです。PEMファイル。TLSおよびセキュアWebSocketで使用されます。';

  @override
  String get tlsCertFile => '証明書ファイル';

  @override
  String get tlsKeyFile => '秘密鍵ファイル';

  @override
  String get tlsKeyPassword => '鍵のパスワード';

  @override
  String get tlsKeyPasswordHint => '鍵が暗号化されている場合のみ';

  @override
  String get callSettingsHoldGroupTitle => '保留';

  @override
  String get callSettingsHoldFooter =>
      '「PBXのデフォルト」では、通話は単に保留されるだけで、電話システムが独自の音楽を流す場合があります。それ以外を選ぶと、このアプリが相手に再生します。';

  @override
  String get callSettingsHoldMusic => '保留音';

  @override
  String get callSettingsHoldPbxDefault => 'PBXのデフォルト';

  @override
  String get callSettingsHoldMusicVolume => '保留音の音量';

  @override
  String get callSettingsHoldAudioFiles => 'オーディオファイル';

  @override
  String get callSettingsHoldAudioFilesHint => '保留音をインポートまたは録音';

  @override
  String get callSettingsAnnounceTitle => 'アナウンス';

  @override
  String get callSettingsAnnounceFooter =>
      'アナウンスは通話相手に再生されます。ファイルがない場合は、何も流さずにスキップされます。';

  @override
  String get callSettingsAnnounceOpening => '開始アナウンス';

  @override
  String get callSettingsAnnounceOpeningHint => '通話がつながったときにメッセージを再生します';

  @override
  String get callSettingsAnnounceFile => 'アナウンスファイル';

  @override
  String get callSettingsAnnounceChooseFile => 'ファイルを選択';

  @override
  String get callSettingsAnnouncePlayFor => '再生の対象';

  @override
  String get callSettingsAnnounceBoth => '着信と発信';

  @override
  String get callSettingsAnnounceIncoming => '着信';

  @override
  String get callSettingsAnnounceOutgoing => '発信';

  @override
  String get callSettingsAnnounceMuteMic => '再生中は自分のマイクをミュート';

  @override
  String get callSettingsAnnounceMonitor => '自分にも聞こえるようにする';

  @override
  String get callSettingsAnnounceBeforeRecording => '録音開始前に再生';

  @override
  String get callSettingsAnnounceBeforeTransfer => '発信者を転送する前に再生';

  @override
  String get morePageTitle => 'その他';

  @override
  String get morePresence => 'プレゼンス';

  @override
  String get morePresenceHint => 'ビジーランプフィールド';

  @override
  String get moreRetrieveParked => 'パーク中の通話を取り出す';

  @override
  String get moreRetrieveParkedHint => 'パークスロットをダイヤル';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => '近くのデバイス、チャット、ファイル受け渡し';

  @override
  String get moreRecordings => '録音';

  @override
  String get moreRecordingsHint => '通話録音の再生、共有、管理';

  @override
  String get moreVoicemail => 'ボイスメール';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新着メッセージ$count件',
      one: '新着メッセージ1件',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'ボイスメールに発信';

  @override
  String get moreDiagnostics => '診断';

  @override
  String get moreDiagnosticsHint => 'SIPトレースとネットワークチェック';

  @override
  String get moreAbout => 'このアプリについて';

  @override
  String get moreNoVoicemailNumber => 'ボイスメールの番号が設定されていません。アカウント設定で追加してください。';

  @override
  String get moreSearchHint => '連絡先や履歴を検索、または番号を入力';

  @override
  String moreCallNumber(String number) {
    return '$number に発信';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day $time';
  }

  @override
  String get appLockTitle => 'アプリロック';

  @override
  String get appLockFooter => 'アプリがロックされていても、着信は鳴り、応答できます。';

  @override
  String get appLockRequirePin => 'アプリを開くときにPINを要求';

  @override
  String get appLockOnHint => '履歴、連絡先、メッセージ、設定がロックされます';

  @override
  String get appLockIsOn => 'アプリロックをオンにしました';

  @override
  String get appLockIsOff => 'アプリロックをオフにしました';

  @override
  String get appLockTurnOff => 'アプリロックをオフにする';

  @override
  String get appLockChangePin => 'PINを変更';

  @override
  String get appLockEnterCurrent => '現在のPINを入力';

  @override
  String get appLockPinChanged => 'PINを変更しました';

  @override
  String get appLockLockAfter => 'ロックまでの時間';

  @override
  String get appLockLockAfterHint => 'バックグラウンドになってから、再びPINが必要になるまでの時間';

  @override
  String get appLockImmediately => 'すぐに';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分',
      one: '1分',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1時間';

  @override
  String get appLockBiometrics => '生体認証でロック解除';

  @override
  String get appLockNow => '今すぐロック';

  @override
  String get appLockSetPin => 'PINを設定';

  @override
  String get appLockPinDigits => 'PIN（4〜8桁）';

  @override
  String get appLockRepeatPin => 'PINを再入力';

  @override
  String get appLockUseDigits => '4〜8桁で入力してください';

  @override
  String get appLockMismatch => 'PINが一致しません';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return '試行回数が多すぎます。$seconds秒後にもう一度お試しください';
  }

  @override
  String get appLockWrongPin => 'PINが違います';

  @override
  String get appLockTooMany => '試行回数が多すぎます';

  @override
  String get appLockIsLocked => 'SoftphoneProはロックされています';

  @override
  String get appLockEnterPin => 'PINを入力してください';

  @override
  String appLockTryAgainIn(String time) {
    return '$time後にもう一度お試しください';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes分$seconds秒';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds秒';
  }

  @override
  String get appLockUnlock => 'ロック解除';

  @override
  String get appLockIncomingCall => '着信';

  @override
  String get appLockDecline => '拒否';

  @override
  String get appLockAnswer => '応答';

  @override
  String get appLockHangUp => '終了';

  @override
  String get appLockBiometricReason => 'SoftphoneProのロックを解除';

  @override
  String get automationNoToken => 'アクセストークンが未設定です。設定 > 詳細設定 で生成してください。';

  @override
  String automationInvalidPort(int port) {
    return '無効なポート $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return '起動できませんでした：$error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'ポート $port は使用できません（$error）。別のポートを選択してください。';
  }

  @override
  String get automationTokenPlaceholder => 'APIをオンにすると作成されます';

  @override
  String automationListening(String address) {
    return '$address で待ち受け中';
  }

  @override
  String get automationStarting => '起動中...';

  @override
  String get automationTitle => 'ローカル自動化API';

  @override
  String get automationFooter =>
      'このコンピューター上のCRMやヘルプデスクとの連携用です。127.0.0.1でのみ待ち受け、すべてのリクエストにアクセストークンが必要です。docs/AUTOMATION_API.md を参照してください。';

  @override
  String get automationEnable => 'ローカル自動化APIを有効にする';

  @override
  String get automationPort => 'ポート';

  @override
  String get automationPortHint => 'デフォルトは7771です。1024〜65535の空いているポートを選択してください。';

  @override
  String get automationPortInvalid => '1024〜65535のポートを入力してください';

  @override
  String get automationAccessToken => 'アクセストークン';

  @override
  String get automationHideToken => 'トークンを隠す';

  @override
  String get automationShowToken => 'トークンを表示';

  @override
  String get automationCopyToken => 'トークンをコピー';

  @override
  String get automationTokenCopied => 'トークンをコピーしました';

  @override
  String get automationGenerateToken => '新しいトークンを生成';

  @override
  String get automationGenerateTitle => '新しいトークンを生成しますか？';

  @override
  String get automationGenerateBody =>
      '古いトークンを使用しているプログラムは、新しいトークンを設定するまで動作しなくなります。';

  @override
  String get automationGenerate => '生成';

  @override
  String get automationOrigins => '許可するブラウザーのオリジン';

  @override
  String get automationOriginsHint =>
      'カンマ区切り（例：https://crm.example.com）。ブラウザーを使わないプログラム（curlやスクリプト）では不要です。';

  @override
  String automationNotOrigin(String origin) {
    return 'http(s)のオリジンではありません：$origin';
  }

  @override
  String get trayNotificationAnswer => '応答';

  @override
  String get trayNotificationDecline => '拒否';

  @override
  String get trayTooltipInCall => 'SoftphonePro - 通話中';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - 新着$count件';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - アカウントなし（離席中）',
      'dnd': 'SoftphonePro - アカウントなし（応答不可）',
      'other': 'SoftphonePro - アカウントなし',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $total件中$online件オンライン（離席中）',
      'dnd': 'SoftphonePro - $total件中$online件オンライン（応答不可）',
      'other': 'SoftphonePro - $total件中$online件オンライン',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'SoftphoneProを隠す';

  @override
  String get trayShowApp => 'SoftphoneProを表示';

  @override
  String trayNewOpenRecents(int count) {
    return '新着$count件 - 履歴を開く';
  }

  @override
  String get trayStatus => 'ステータス';

  @override
  String get trayStatusAway => '離席中';

  @override
  String get trayAccounts => 'アカウント';

  @override
  String get trayQuit => 'SoftphoneProを終了';

  @override
  String get hotkeyAnswerCall => '着信に応答';

  @override
  String get hotkeyHangUp => '通話を終了';

  @override
  String get hotkeyMute => 'ミュート／解除';

  @override
  String get hotkeyFocusDialer => 'ダイヤラーにフォーカス';

  @override
  String get shortcutsGlobalTitle => 'グローバルホットキー';

  @override
  String get shortcutsGlobalFooter =>
      'どのアプリからでも使えます。すでに別のプログラムが使用しているキーの組み合わせは、登録できない場合があります。';

  @override
  String get shortcutsChange => '変更';

  @override
  String get shortcutsRestoreDefaults => 'デフォルトに戻す';

  @override
  String get shortcutsMediaTitle => 'ヘッドセットとメディアキー';

  @override
  String get shortcutsMediaFooter =>
      'ヘッドセットやキーボードの再生／一時停止ボタンは、着信中または通話中のみ使用され、それ以外のときは音楽プレーヤーが使用できます。';

  @override
  String get shortcutsMediaSwitch => 'ヘッドセット／メディアの再生・一時停止ボタンで応答・終了';

  @override
  String get shortcutsMediaDuringCall => '通話中のボタンの動作';

  @override
  String get shortcutsMediaHangsUp => '通話を終了';

  @override
  String get shortcutsMediaMutes => 'ミュート／解除';

  @override
  String get shortcutsInApp => 'アプリ内';

  @override
  String get shortcutsFocusDialer => 'ダイヤラーにフォーカス';

  @override
  String get shortcutsHoldResume => '保留／再開';

  @override
  String get shortcutsTransfer => '転送';

  @override
  String get shortcutsEndCall => '通話を終了';

  @override
  String get shortcutsNeedX11 =>
      'グローバルショートカットにはX11セッションが必要です。Waylandではアプリがシステム全体でキーを取得することはできません。';

  @override
  String shortcutsNeedModifier(String key) {
    return '文字または数字に Ctrl、Alt、Shift、$key のいずれかを組み合わせてください';
  }

  @override
  String get shortcutsPressNew => '新しいキーの組み合わせを押してください';

  @override
  String get defaultHandlerChooseInSettings =>
      '既定のアプリで、SIP、TEL、CALLTOにSoftphoneProを選択してください';

  @override
  String get defaultHandlerNowOpens =>
      'sip:、tel:、callto: のリンクをSoftphoneProで開くようになりました';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return '$schemes の既定のアプリを変更できませんでした';
  }

  @override
  String get defaultHandlerIntro => 'ブラウザーや他のアプリの sip:、tel:、callto: リンクを開きます';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphoneProが sip:、tel:、callto: のリンクを処理します';

  @override
  String defaultHandlerNow(String handlers) {
    return '現在：$handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'SoftphoneProを sip:、tel:、callto: リンクの既定のアプリにする';

  @override
  String get reliabilityTitle => 'バックグラウンドでの安定動作';

  @override
  String get reliabilityMicrophone => 'マイク';

  @override
  String get reliabilityAllowed => '許可済み';

  @override
  String get reliabilityMicNeeded => '通話で話すために必要です';

  @override
  String get reliabilityNotifications => '通知';

  @override
  String get reliabilityNotifNeeded => '着信の表示とサービスの常時表示に必要です';

  @override
  String get reliabilityFullScreen => '全画面での着信表示';

  @override
  String get reliabilityFullScreenNeeded => 'ロック画面の上に着信を表示するには許可してください';

  @override
  String get reliabilityBattery => 'バッテリー使用の制限なし';

  @override
  String get reliabilityBatteryExempt => 'バッテリー最適化の対象外';

  @override
  String get reliabilityBatteryNeeded =>
      'Androidが節電のためにアプリを停止し、着信を逃す場合があります。タップしてSoftphoneProを対象外にしてください。';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturerの自動起動／保護されたアプリ';
  }

  @override
  String get reliabilityAutostartHint =>
      'お使いの端末メーカーの機能によって、バックグラウンドのアプリが終了される場合があります。SoftphoneProの自動起動を許可してください。';

  @override
  String get reliabilityBoot => '起動時に開始';

  @override
  String get reliabilityBootHint => '端末の再起動後にアカウントを登録します';

  @override
  String get reliabilityWake => 'アイドル中もCPUを動作させる';

  @override
  String get reliabilityWakeHint => '制限の厳しい端末でより確実になりますが、バッテリーを多く消費します';

  @override
  String acctEditorDeleteTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String acctCodecRemove(String codec) {
    return '$codec を削除';
  }

  @override
  String acctEditorLastError(String error) {
    return '直近のエラー：$error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return '指定可能な範囲：$min〜$max';
  }

  @override
  String acctValidateMin(int min) {
    return '$min 以上にしてください';
  }

  @override
  String acctValidateMax(int max) {
    return '$max 以下にしてください';
  }

  @override
  String get acctEditorDiscardTitle => '変更を破棄しますか？';

  @override
  String get acctEditorDiscardMessage => 'このアカウントの編集内容は保存されていません。';

  @override
  String get acctEditorDiscardConfirm => '破棄';

  @override
  String get acctEditorDeleteMessage => 'アカウントと保存されたパスワードがこのデバイスから削除されます。';

  @override
  String get acctEditorMenuDelete => 'アカウントを削除';

  @override
  String get acctGroupBasic => '基本';

  @override
  String get acctFieldLabel => 'ラベル';

  @override
  String get acctFieldLabelHint => '例：オフィス';

  @override
  String get acctFieldDisplayName => '表示名';

  @override
  String get acctFieldUsername => 'ユーザー名';

  @override
  String get acctFieldProtocol => 'プロトコル';

  @override
  String get acctFieldProtocolSub => 'アカウント作成時に固定されます';

  @override
  String get acctFieldAuthUser => '認証ユーザー';

  @override
  String get acctFieldAuthUserHint => 'ユーザー名と同じ';

  @override
  String get acctFieldAuthUserSub => 'プロバイダーがユーザー名と異なるログイン名を使用する場合のみ';

  @override
  String get acctFieldPassword => 'パスワード';

  @override
  String get acctFieldServerHost => 'サーバーホスト';

  @override
  String get acctFieldPort => 'ポート';

  @override
  String get acctFieldIaxPortSub => 'IAX2のデフォルトは4569です';

  @override
  String get acctFieldIaxContext => 'コンテキスト';

  @override
  String get acctFieldIaxContextSub => '任意。発信先コンテキストとしてPBXに送信されます';

  @override
  String get acctFieldServerDomain => 'サーバー／ドメイン';

  @override
  String get acctFieldServerDomainSub => 'ホスト または ホスト:ポート';

  @override
  String get acctFieldEnabled => '有効';

  @override
  String get acctFieldDefault => '発信のデフォルトアカウント';

  @override
  String get acctFieldColour => 'カラー';

  @override
  String get acctGroupRegistration => '登録';

  @override
  String get acctFieldRegister => '登録する';

  @override
  String get acctFieldRegisterSubIax => '登録が不要なピアではオフにします';

  @override
  String get acctFieldRegExpiry => '登録の有効期間（秒）';

  @override
  String get acctFieldRegExpirySubIax => 'Asteriskでは通常60秒に固定されます。範囲：10〜86400';

  @override
  String get acctFieldRetryInterval => '再試行間隔（秒）';

  @override
  String get acctFieldFirstRetry => '最初の再試行（秒）';

  @override
  String get acctGroupCodecs => 'コーデック';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2はG.711とGSMに対応しています。ドラッグして優先順位を設定します。';

  @override
  String get acctCodecAdd => 'コーデックを追加';

  @override
  String get acctGroupServerTransport => 'サーバーとトランスポート';

  @override
  String get acctFieldRegistrar => 'レジストラーの上書き';

  @override
  String get acctFieldBackupRegistrar => 'バックアップレジストラー';

  @override
  String get acctFieldBackupRegistrarSub => '3回失敗した後に使用されます。プライマリは5分ごとに再試行されます';

  @override
  String get acctFieldProxies => 'アウトバウンドプロキシ';

  @override
  String get acctFieldTransport => 'トランスポート';

  @override
  String get acctFieldTransportAutoSub =>
      'サーバーのDNS SRVレコードを調べ、TLS、TCP、UDPから選択します';

  @override
  String get acctTransportAuto => '自動（DNS SRV）';

  @override
  String get acctFieldWsPath => 'WebSocketパス';

  @override
  String get acctFieldWsPathSub =>
      'WebSocketアップグレードのHTTPパス（例：/ws）。「/」で始める必要があります';

  @override
  String get acctFieldRegExpirySubSip => '通常は300〜3600です。範囲：10〜86400';

  @override
  String get acctFieldKeepAlive => 'キープアライブ（秒）';

  @override
  String get acctFieldKeepAliveSub => 'UDPキープアライブの間隔。0でオフ。範囲：0〜3600';

  @override
  String get acctFieldLocalPort => 'ローカルSIPポート';

  @override
  String get acctFieldLocalPortSub => '0の場合は共有トランスポートを使用します。範囲：0〜65535';

  @override
  String get acctFieldRegisterSubSip => '登録なしのトランクではオフにします';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound（RFC 5626）';

  @override
  String get acctFieldSipOutboundSub => 'NAT越しに持続的なフローを維持します。サーバー側の対応が必要です';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'STUNを使用';

  @override
  String get acctFieldTurn => 'TURNリレー';

  @override
  String get acctFieldTurnServer => 'TURNサーバー';

  @override
  String get acctFieldTurnUsername => 'TURNユーザー名';

  @override
  String get acctFieldTurnPassword => 'TURNパスワード';

  @override
  String get acctFieldContactRewrite => 'Contactヘッダーを書き換え';

  @override
  String get acctFieldViaRewrite => 'Viaヘッダーを書き換え';

  @override
  String get acctFieldRewriteSub => 'サーバーから見えるアドレスを使用します。NAT配下ではオンのままにします';

  @override
  String get acctFieldSdpRewrite => 'SDPアドレスを書き換え';

  @override
  String get acctFieldSdpRewriteSub => 'SDP内のメディアアドレスをパブリックアドレスに置き換えます';

  @override
  String get acctFieldIpv6Sip => 'IPv6シグナリング';

  @override
  String get acctFieldIpv6Media => 'IPv6メディア';

  @override
  String get acctGroupAdvancedMedia => 'メディアの詳細設定';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'WebRTCゲートウェイにはRTCP多重化とRTCPフィードバックが必要です。';

  @override
  String get acctFieldRtcpMux => 'RTCP多重化';

  @override
  String get acctFieldRtcpMuxSub => 'RTPとRTCPを1つのポートで送信します（rtcp-mux）';

  @override
  String get acctFieldRtcpFb => 'RTCPフィードバック（AVPF）';

  @override
  String get acctFieldRtcpFbSub => 'NACK付きのRTP/AVPFを提案します。WebRTCサーバーで必要です';

  @override
  String get acctGroupSecurity => 'セキュリティ';

  @override
  String get acctFieldSrtp => 'メディア暗号化（SRTP）';

  @override
  String get acctOptOptional => '任意';

  @override
  String get acctOptRequired => '必須';

  @override
  String get acctFieldKeyExchange => '鍵交換';

  @override
  String get acctFieldSecureSignaling => 'セキュアシグナリング';

  @override
  String get acctOptNotRequired => '不要';

  @override
  String get acctOptTlsHop => 'TLS（ホップ間）';

  @override
  String get acctOptTlsE2e => 'TLS（エンドツーエンド、sips）';

  @override
  String get acctFieldAuthAlgorithm => '認証アルゴリズム';

  @override
  String get acctFieldPrivacy => '発信者番号を非通知にする（プライバシー）';

  @override
  String get acctFieldReferPolicy => '着信側の転送（REFER）';

  @override
  String get acctFieldWatcherPolicy => 'プレゼンスの監視者';

  @override
  String get acctOptAccept => '受け入れる';

  @override
  String get acctOptReject => '拒否';

  @override
  String get acctGroupCodecsFooter => 'このアカウントでは、グローバルのコーデックリストを上書きします。';

  @override
  String get acctFieldUseGlobalCodecs => 'グローバルのコーデック順序を使用';

  @override
  String get acctGroupFeatures => '機能';

  @override
  String get acctFieldVoicemailNumber => 'ボイスメールの番号';

  @override
  String get acctFieldMwi => 'ボイスメール通知（MWI）';

  @override
  String get acctFieldMwiSub => 'メッセージ待機通知を購読します';

  @override
  String get acctFieldPublishPresence => '自分のプレゼンスを公開';

  @override
  String get acctFieldPublishPresenceSub => 'オンライン状態をサーバーと共有します';

  @override
  String get acctFieldDnd => '応答不可';

  @override
  String get acctFieldForwarding => '着信転送';

  @override
  String get acctOptForwardAlways => '常に';

  @override
  String get acctOptForwardBusy => '通話中のとき';

  @override
  String get acctOptForwardNoAnswer => '応答なしのとき';

  @override
  String get acctFieldForwardTo => '転送先';

  @override
  String get acctFieldForwardToHint => '電話番号またはSIPアドレス';

  @override
  String get acctFieldRingFor => '呼び出し時間（秒）';

  @override
  String get acctFieldAutoAnswer => '自動応答';

  @override
  String get acctFieldAnswerAfter => '応答までの時間（秒）';

  @override
  String get acctFieldIntercomOnly => 'インターコム通話のみ';

  @override
  String get acctFieldIntercomOnlySub => 'PBXからの自動応答ヘッダーが必要です';

  @override
  String get acctFieldRingtone => '着信音';

  @override
  String get acctRingtoneClassic => 'クラシック';

  @override
  String get acctRingtoneSoft => 'ソフト';

  @override
  String get acctRingtoneDigital => 'デジタル';

  @override
  String get acctFieldRecordCalls => '通話を録音';

  @override
  String get acctFieldHoldMusic => '保留音';

  @override
  String get acctOptUseGlobal => '全体設定を使用';

  @override
  String get acctOptPbxDefault => 'PBXのデフォルト';

  @override
  String get acctFieldOpeningAnnouncement => '開始アナウンス';

  @override
  String get acctGroupFeatureCodes => 'フィーチャーコード';

  @override
  String get acctGroupFeatureCodesFooter =>
      'PBXのパーク、ピックアップ、応答不可、転送のためにダイヤルされます。';

  @override
  String get acctFieldPark => 'パーク';

  @override
  String get acctFieldGroupPickup => 'グループピックアップ';

  @override
  String get acctFieldDirectedPickup => '指定ピックアップのプレフィックス';

  @override
  String get acctFieldParkRetrieve => 'パーク取り出しのプレフィックス';

  @override
  String get acctFieldParkRetrieveHint => 'スロット番号をダイヤル';

  @override
  String get acctFieldParkRetrieveSub =>
      'パーク中の通話を取り戻すとき、パークスロットの前にダイヤルするプレフィックス';

  @override
  String get acctFieldDndOn => '応答不可オン';

  @override
  String get acctFieldDndOff => '応答不可オフ';

  @override
  String get acctFieldForwardOn => '転送オン';

  @override
  String get acctFieldForwardOff => '転送オフ';

  @override
  String get acctGroupAdvanced => '詳細設定';

  @override
  String get acctGroupAdvancedFooterIax => 'DTMFはIAX2ネイティブのフレームで送信されます。';

  @override
  String get acctFieldCallerIdOverride => '発信者番号の上書き';

  @override
  String get acctFieldCallerIdHint => 'アカウントのデフォルトを使用';

  @override
  String get acctFieldCallerIdSub => 'PBXに送信する発信者名または番号';

  @override
  String get acctFieldSessionTimers => 'セッションタイマー';

  @override
  String get acctFieldSessionExpires => 'セッション有効期間（秒）';

  @override
  String get acctFieldSessionExpiresSub => '範囲：90〜86400';

  @override
  String get acctField100rel => '100rel（信頼性のある暫定応答）';

  @override
  String get acctFieldHoldMethod => '保留方式';

  @override
  String get acctFieldDtmfMethod => 'DTMF方式';

  @override
  String get acctOptDtmfInband => 'インバンド';

  @override
  String get acctFieldRedirects => 'リダイレクト（3xx）';

  @override
  String get acctOptRedirectFollow => '従う';

  @override
  String get acctOptRedirectAsk => '確認する';

  @override
  String get acctFieldLockCodec => '応答後にコーデックを固定';

  @override
  String get acctFieldMediaKeepAlive => 'メディアのキープアライブ';

  @override
  String get acctFieldDropCalls => '登録に失敗したら通話を切断';

  @override
  String get acctFieldExtraHeaders => '追加のSIPヘッダー';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: 値（1行に1つ）';

  @override
  String get acctFieldRetryIntervalSub => '登録に失敗してから再試行するまでの待ち時間。範囲：0〜86400';

  @override
  String get acctFieldUnregTimeout => '登録解除のタイムアウト（ms）';

  @override
  String get acctFieldUnregTimeoutSub => '登録解除の応答を待つ時間。範囲：0〜60000';

  @override
  String get acctFieldMwiExpiry => 'MWI購読の有効期間（秒）';

  @override
  String get acctFieldDscpSip => 'SIPのDSCP';

  @override
  String get acctFieldDscpSipSub => 'シグナリングのQoSマーキング。通常は24（CS3）です';

  @override
  String get acctFieldDscpRtp => 'RTPのDSCP';

  @override
  String get acctFieldDscpRtpSub => 'メディアのQoSマーキング。通常は46（EF）です';

  @override
  String get acctFieldReinvite => 'ネットワーク変更後にRe-INVITE';

  @override
  String get acctFieldHangupOnIpChange => 'ネットワーク変更時に通話を切断';

  @override
  String get acctValidateInt => '整数を入力してください';

  @override
  String get acctValidateHostEmpty => 'サーバーのホスト名またはアドレスを入力してください';

  @override
  String get acctValidateHostSpaces => 'サーバーにスペースは使用できません';

  @override
  String get acctValidateHostFormat => 'ホスト または ホスト:ポート のみを入力してください';

  @override
  String get acctValidatePortRange => 'ポートは1〜65535の範囲で指定してください';

  @override
  String get acctValidateWsStart => 'パスは「/」で始める必要があります';

  @override
  String get acctValidateWsLength => '120文字以内で入力してください';

  @override
  String get acctValidateWsSpaces => 'パスにスペースは使用できません';

  @override
  String get acctTplAsteriskDescription => '自社PBXの内線。UDP 5060、STUNオン。';

  @override
  String get acctTplAsteriskNotes =>
      'PJSIP/SIPの内線番号とそのシークレットを使用してください。TLSやWebRTCを使う場合は、後でアカウント設定からトランスポートを変更します。';

  @override
  String get acctTplAsteriskUsernameHint => '内線番号（例：1001）';

  @override
  String get acctTpl3cxDescription => '3CXポータルの内線、認証ID、パスワードを使用します。';

  @override
  String get acctTpl3cxNotes =>
      '3CXで内線を開き、「電話 > プロビジョニング」で認証ID（認証ユーザーとして設定）とパスワードを確認します。FQDNは3CXのURLに含まれているものです。';

  @override
  String get acctTpl3cxUsernameHint => '内線';

  @override
  String get acctTplFreeswitchDescription => 'FreeSWITCHサーバーのディレクトリユーザー。';

  @override
  String get acctTplFreeswitchNotes =>
      'ディレクトリのユーザーIDとパスワードを使用してください。デフォルトのinternalプロファイルはUDP/TCP 5060で待ち受けます。';

  @override
  String get acctTplFreeswitchUsernameHint => 'ユーザーID';

  @override
  String get acctTplKamailioDescription => 'SIPプロキシレジストラー。NAT配下ではTCPを推奨。';

  @override
  String get acctTplKamailioNotes =>
      'レジストラーが提供するSIPドメインを使用してください。レジストラーに別のホスト経由で接続する場合は、アカウント設定でアウトバウンドプロキシを追加します。';

  @override
  String get acctTplTwilioDescription =>
      'Programmable Voice SIPドメインの認証情報。TLSとSRTP。';

  @override
  String get acctTplTwilioNotes =>
      'TwilioコンソールでSIPドメインを作成し、認証情報リストを追加して、SIP登録を有効にします。サーバーには完全なドメイン（name.sip.twilio.com）、ユーザーとパスワードには認証情報リストのものを入力します。TLSはポート5061を使用します。TwilioはG.711のみ対応です。';

  @override
  String get acctTplTwilioUsernameHint => '認証情報リストのユーザー名';

  @override
  String get acctTplTelnyxDescription => '認証情報接続。UDP、G.711／Opus。';

  @override
  String get acctTplTelnyxNotes =>
      'Telnyxポータルで認証情報接続（Credential Connection）を作成し、そのSIPユーザー名とパスワード（ポータルのログイン情報ではありません）をコピーします。発着信するには、接続に番号またはアウトバウンド音声プロファイルを割り当ててください。';

  @override
  String get acctTplTelnyxUsernameHint => 'SIPユーザー名（認証情報接続）';

  @override
  String get acctTplVoipmsDescription =>
      'サブアカウントのユーザー名とパスワード。最寄りのPOPを選択してください。';

  @override
  String get acctTplVoipmsNotes =>
      'メインアカウントではなく、Sub Accountsで作成したサブアカウントを使用してください。VoIP.msのサーバー一覧から最寄りのサーバー（POP）を選び、必要に応じてお使いのIPを許可してください。';

  @override
  String get acctTplVoipmsUsernameHint => 'サブアカウント（例：123456_phone）';

  @override
  String get acctTplVonageDescription => 'TLSによるSIP登録。';

  @override
  String get acctTplVonageNotes =>
      'Vonage BusinessでSIP登録を利用できるのは一部のプランのみです。Vonage管理ポータルに表示されるデバイスのSIPサーバー、ユーザー、パスワードを入力してください。';

  @override
  String get acctTplIax2Description =>
      'UDP 4569によるInter-Asterisk eXchange。NATやSRTPの設定はありません。';

  @override
  String get acctTplIax2Notes =>
      'iax.confに同じシークレットのピア／ユーザー（type=friend、またはuser+peer）が必要です。AsteriskはデフォルトでIAX2の登録を60秒ごとに更新します。コンテキストは任意で、発信先コンテキストとして送信されます。';

  @override
  String get acctTplIax2UsernameHint => 'IAX2ユーザー名';

  @override
  String get acctTplWebrtcDescription =>
      'DTLS-SRTP、ICE、RTCP-muxを使用するセキュアWebSocket上のSIP。';

  @override
  String get acctTplWebrtcNotes =>
      'Asterisk（webrtc=yes、http.confでTLSをポート8089に設定）、FreeSWITCH、KamailioのWebSocketエンドポイント向けです。サーバーには有効なTLS証明書が必要です。ゲートウェイが /ws を使用しない場合は、アカウント設定でWebSocketパスを変更してください。';

  @override
  String get acctTplGenericDescription => '任意のSIPレジストラー。詳細を自分で入力します。';

  @override
  String get acctTplDefaultUsernameHint => '内線／ユーザー名';

  @override
  String get appEngineFailedBody =>
      'これが解決するまで、通話と登録は動作しません。多くの場合、ネットワークまたは証明書の設定が原因です。';

  @override
  String get appEngineFailedTitle => '通話エンジンを起動できませんでした';

  @override
  String get appEngineNotRunning => '通話エンジンが動作していません';

  @override
  String get appUnknownError => '不明なエラー';

  @override
  String get appEngineOpenNetworkSettings => 'ネットワーク設定を開く';

  @override
  String get appEngineUseSimulator => 'シミュレーターを使用（デモ）';

  @override
  String get appDbLockedTitle => 'データがロックされています';

  @override
  String get appDbUnreadableTitle => 'データを開けません';

  @override
  String get appDbLockedBody =>
      '通話履歴、連絡先、メッセージはこのデバイスで暗号化されていますが、暗号化キーがシステムのキーチェーン／キーストアにありません（キーチェーンのリセットや新しいデバイスへの復元後など）。';

  @override
  String get appDbUnreadableBody =>
      'ローカルデータベースを読み込めませんでした。破損しているか、暗号化キーが一致しない可能性があります。';

  @override
  String get appDbRecoveryAdvice =>
      'キーが戻ると思われる場合は、もう一度お試しください（キーチェーンのロックを解除する、正しいユーザーでサインインするなど）。新規に開始すると、古いファイルはアプリのデータの横に残りますが、履歴、連絡先、メッセージは空の状態から始まり、アカウントを再度追加する必要があります。';

  @override
  String get appDbCopyDetails => '詳細をコピー';

  @override
  String get appDbTryAgain => '再試行';

  @override
  String get appDbStartFresh => '新規に開始';

  @override
  String get appRedirectTitle => '通話がリダイレクトされました';

  @override
  String appRedirectMessage(String target) {
    return '通話が $target にリダイレクトされました。従いますか？';
  }

  @override
  String get appRedirectCancelCall => '通話をキャンセル';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': 'データを暗号化できませんでした（$error）。変更は行われていません。',
      'other': 'データを復号できませんでした（$error）。変更は行われていません。',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'ネイティブエンジンを利用できません（$error）';
  }

  @override
  String acctRetryingAt(String time) {
    return '$time に再試行します';
  }

  @override
  String get acctRegistrationError => '登録エラー';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nトランスポート：$transport';
  }

  @override
  String get acctCallingFromDirect => 'アカウントなしで直接発信';

  @override
  String acctCallingFromAccount(String name) {
    return '$name から発信';
  }

  @override
  String get acctCallingFromNone => '発信元アカウントなし';

  @override
  String get acctNoAccount => 'アカウントなし';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds 秒';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '新着$newCount件、既読$oldCount件';
  }

  @override
  String get acctAddAccount => 'アカウントを追加';

  @override
  String get acctUnregister => '登録解除';

  @override
  String get acctSheetDndSub => 'このアカウントの着信を拒否します';

  @override
  String get acctKvServer => 'サーバー';

  @override
  String get acctKvResolvedServer => '解決済みサーバー';

  @override
  String get acctKvClientCert => 'クライアント証明書';

  @override
  String get acctKvClientCertValue => 'サーバーに提示されます（相互TLS）';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => '有効期限まで';

  @override
  String get acctKvVoicemail => 'ボイスメール';

  @override
  String get acctOpenSipTrace => 'SIPトレースを開く';

  @override
  String get acctAddAnAccount => 'アカウントを追加';

  @override
  String get acctChooseAccountTooltip => '発信に使うアカウントを選択';

  @override
  String get acctDirectNoAccount => '直接発信（アカウントなし）';

  @override
  String get onboardingRequired => 'ユーザー名とサーバーは必須です';

  @override
  String onboardingDefaultPortHelper(int port) {
    return ':ポート を追加しない場合はポート $port を使用します';
  }

  @override
  String get onboardingFineTuneIax => 'コーデックと登録の詳細は、後で設定から調整できます。';

  @override
  String get onboardingFineTuneSip =>
      'トランスポート、NAT、セキュリティ、コーデックの詳細は、後で設定から調整できます。';

  @override
  String get onboardingDemoUser => 'デモユーザー';

  @override
  String get onboardingDemoAccount => 'デモアカウント';

  @override
  String get onboardingWelcomeTitle => 'SoftphoneProへようこそ';

  @override
  String get onboardingWelcomeText =>
      'あらゆるプラットフォームで使える本格的な通話アプリ。無料のオープンソースで、広告もトラッキングもありません。';

  @override
  String get onboardingGetStarted => 'はじめる';

  @override
  String get onboardingPermissionsTitle => '権限';

  @override
  String get onboardingPermissionsText =>
      'SoftphoneProは、音声を届けるためにマイクを、着信やメッセージをお知らせするために通知を必要とします。通話以外のデータがデバイスの外に送信されることはありません。';

  @override
  String get onboardingChooseProvider => 'プロバイダーを選択';

  @override
  String get onboardingChooseProviderSub => 'トランスポート、ポート、NATの設定は自動で入力されます。';

  @override
  String get onboardingScanQr => 'QRをスキャン';

  @override
  String get onboardingImportUrl => 'URLからインポート';

  @override
  String get onboardingSkip => '今はスキップ（デモモード）';

  @override
  String get onboardingHidePassword => 'パスワードを隠す';

  @override
  String get onboardingShowPassword => 'パスワードを表示';

  @override
  String get onboardingContextOptional => 'コンテキスト（任意）';

  @override
  String get onboardingDisplayNameOptional => '表示名（任意）';

  @override
  String get onboardingLabelOptional => 'アカウントのラベル（任意）';

  @override
  String get onboardingCallerIdOptional => '発信者番号（任意）';

  @override
  String get onboardingAuthUserOptional => '認証ユーザー（異なる場合）';

  @override
  String acctRegWrongCredentials(int code) {
    return 'ユーザー名またはパスワードが違います（$code）';
  }

  @override
  String get acctRegNotFound => 'サーバーにアカウントが見つかりません（404）';

  @override
  String get acctRegNoAnswer => 'サーバーが応答しませんでした（408）';

  @override
  String get acctRegIntervalTooShort => '登録間隔が短すぎます（423）';

  @override
  String get acctRegTemporarilyUnavailable => 'サーバーが一時的に利用できません（480）';

  @override
  String get acctRegServiceUnavailable => 'サービスを利用できません（503）';

  @override
  String get acctRegFailed => '登録に失敗しました';

  @override
  String acctRegFailedWithCode(int code) {
    return '登録に失敗しました（$code）';
  }

  @override
  String get acctNoticeRegistrationChange => '登録を変更できませんでした';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'アカウント「$name」を適用できませんでした';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return '$name をプライマリサーバーに戻しました';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return '$name はバックアップサーバーを使用中です';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'アカウント $name は登録済みです';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'アカウント $name は登録中です';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'アカウント $name はまだ登録されていません';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'アカウント $name は登録されていません（登録に失敗しました）';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'アカウント $name は無効です';
  }

  @override
  String get callDialEngineFailed => '通話エンジンを起動できませんでした';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return '通話エンジンを起動できませんでした：$reason';
  }

  @override
  String get callDialEngineStarting => '通話エンジンを起動中です';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status：$reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status（$seconds秒経過）。発信されませんでした';
  }

  @override
  String get callJournalInterrupted => '通話中にアプリが終了しました';

  @override
  String get callLinkMissingArgument => '引数がありません';

  @override
  String get callLinkHttpsRequired => '設定リンクにはhttpsが必要です';

  @override
  String get callLinkInvalidLan => 'このLANリンクは無効です';

  @override
  String callLinkConnectedTo(String name) {
    return '$name に接続しました';
  }

  @override
  String get callLinkConnectFailed => 'そのデバイスに接続できませんでした';

  @override
  String callLinkCallFailed(String target) {
    return '$target に発信できませんでした';
  }

  @override
  String get callLinkImportTitle => '設定のインポート';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts件のアカウント',
      one: '1件のアカウント',
    );
    return '$host から設定をインポートしますか？$_temp0が追加されます。';
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
      other: '$accounts件のアカウント',
      one: '1件のアカウント',
    );
    return '$host から設定をインポートしますか？$_temp0と$settings件の設定が追加されます。';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return '$number から転送';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return '$number から転送（$reason）';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return '$number が転送';
  }

  @override
  String get callRingtoneSystemDefault => 'システムの設定';

  @override
  String get callRingtoneClassic => 'クラシック';

  @override
  String get callRingtoneSoft => 'ソフト';

  @override
  String get callRingtoneDigital => 'デジタル';

  @override
  String callIdentityFrom(String number) {
    return '発信元 $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return '発信者番号 $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return '発信者番号 $name $number';
  }

  @override
  String get callTransferring => '転送中...';

  @override
  String get callTransferNotConfirmed => 'サーバーが転送を確認しませんでした';

  @override
  String get callTransferStalledHint => '通話は継続中です。そのまま続けるか、もう一度転送してください。';

  @override
  String get callTransferKeepCall => '通話を継続';

  @override
  String get callAnnouncementOpening => 'アナウンスを再生中…';

  @override
  String get callAnnouncementTransfer => '転送のお知らせを再生中…';

  @override
  String get callAnnouncementRecording => '録音のお知らせを再生中…';

  @override
  String get callAnnouncementSkip => 'スキップ';

  @override
  String get callNoiseTooltipMic => 'AIノイズキャンセル：自分のマイク';

  @override
  String get callNoiseTooltipIncoming => 'AIノイズキャンセル：他の参加者';

  @override
  String get callNoiseTooltipBoth => 'AIノイズキャンセル：自分のマイクと他の参加者';

  @override
  String get callNoiseOn => 'ノイズキャンセル オン';

  @override
  String get callNoiseTitle => 'ノイズキャンセル';

  @override
  String callNoiseMicStrength(String strength) {
    return '自分のマイク：$strength';
  }

  @override
  String get callNoiseMicOffHint => '自分のマイクから背景ノイズを除去します';

  @override
  String get callResultAnswered => '応答済み';

  @override
  String get callResultMissed => '不在着信';

  @override
  String get callResultRejected => '拒否';

  @override
  String get callResultFailed => '失敗';

  @override
  String get callResultBusy => '話し中';

  @override
  String get callResultForwarded => '転送済み';

  @override
  String get callResultTransferred => '転送済み';

  @override
  String get callResultHandedOff => '引き継ぎ済み';

  @override
  String get callResultInterrupted => '中断';

  @override
  String get keypadCall => '発信';

  @override
  String get keypadNoVoicemail => 'このアカウントにはボイスメールの番号が設定されていません';

  @override
  String get keypadCallDirectly => '直接発信（アカウントなし）';

  @override
  String get keypadAddAccount => '発信するにはアカウントを追加してください';

  @override
  String keypadCallFrom(String account) {
    return '$account から発信';
  }

  @override
  String get keypadRecent => '最近';

  @override
  String get keypadSuggestions => '候補';

  @override
  String get keypadPhoneNumber => '電話番号';

  @override
  String get keypadPaste => '貼り付け';

  @override
  String get keypadEnterNumber => '番号を入力';

  @override
  String get keypadBackspace => '削除（長押しですべてクリア）';

  @override
  String get keypadTypeNameOrNumber => '名前または番号を入力';

  @override
  String get keypadNoMatches => '一致なし';

  @override
  String get keypadSuggestionsHint => '候補は連絡先と最近の通話から表示されます';

  @override
  String keypadCallPerson(String name) {
    return '$name に発信';
  }

  @override
  String get dialKeyStar => 'スター';

  @override
  String get dialKeyPound => 'シャープ';

  @override
  String get dialKeyLongPressPlus => '長押しで＋';

  @override
  String get dialKeyLongPressSpeedDial => '長押しで短縮ダイヤル';

  @override
  String get dialKeyLongPressVoicemail => '長押しでボイスメール';

  @override
  String get callBackToApp => 'アプリに戻る（通話は継続）';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'キーパッドを隠す';

  @override
  String get callMute => 'ミュート';

  @override
  String get callKeypad => 'キーパッド';

  @override
  String get callSpeaker => 'スピーカー';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'ヘッドセット';

  @override
  String get callResume => '再開';

  @override
  String get callHold => '保留';

  @override
  String get callAddCall => '通話を追加';

  @override
  String get callTransfer => '転送';

  @override
  String get callStop => '停止';

  @override
  String get callRecord => '録音';

  @override
  String get callSplit => '分割';

  @override
  String get callMerge => '統合';

  @override
  String get callSwap => '切り替え';

  @override
  String get callEndCall => '通話を終了';

  @override
  String callEndCallWith(String name) {
    return '$name との通話を終了';
  }

  @override
  String get callAttendedTransferHint => '確認転送です。元の発信者は保留中です。';

  @override
  String get callCompleteTransfer => '転送を完了';

  @override
  String get callWaiting => '通話待機';

  @override
  String get callHoldAndAnswer => '現在の通話を保留して応答';

  @override
  String get callDecline => '拒否';

  @override
  String get callAnswer => '応答';

  @override
  String get callIncomingCall => '着信';

  @override
  String get callReply => '返信';

  @override
  String get callVoicemail => '留守番電話';

  @override
  String get callToDevice => '他の端末へ';

  @override
  String get callQuickReplyBusy => '今は話せません。あとでかけ直します。';

  @override
  String get callQuickReplyMeeting => '会議中です。メッセージをもらえますか？';

  @override
  String get callQuickReplyOnMyWay => '向かっています。';

  @override
  String callReturnToCallWith(String name) {
    return '$name との通話に戻る';
  }

  @override
  String callBarIncoming(String name) {
    return '着信：$name';
  }

  @override
  String callBarInCallWith(String name) {
    return '$name と通話中';
  }

  @override
  String get callStatsCodec => 'コーデック';

  @override
  String get callStatsJitter => 'ジッター';

  @override
  String get callStatsPacketLoss => 'パケット損失';

  @override
  String get callStatsRoundTrip => '往復遅延';

  @override
  String get callStatsMedia => 'メディア';

  @override
  String get callStatsMosHistory => 'MOS履歴';

  @override
  String get callQualityTitle => '通話品質';

  @override
  String get callTransferTitle => '通話を転送';

  @override
  String get callTransferModeBlind => 'ブラインド';

  @override
  String get callTransferModeAttended => '確認';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LANデバイス';

  @override
  String get callTransferNoLanDevices =>
      'ネットワーク上にペアリング済みのSoftphoneProデバイスが見つかりません。LANページでペアリングしてください。';

  @override
  String get callTransferLanDisabled =>
      'この通話をネットワーク上の別のデバイスに引き継ぐには、LAN Linkをオンにしてください（設定 > LAN Link）。';

  @override
  String get callTransferTalkFirst => '先に話す';

  @override
  String get callTransferBlindHint => '発信者をすぐに転送します。あなたは切断されます。';

  @override
  String get callTransferAttendedHint =>
      '発信者を保留にして、先に転送先を呼び出します。相手が応答したら転送を完了します。';

  @override
  String get callTransferNumberLabel => '電話番号またはSIPアドレス';

  @override
  String get callTransferNow => '今すぐ転送';

  @override
  String get callTransferCallAndConsult => '呼び出して確認';

  @override
  String get callRetrieveParkedTitle => 'パーク中の通話を取り出す';

  @override
  String get callRetrieveParkedHint => 'パークスロット（例：701）';

  @override
  String get callMoreAudioOutput => '音声出力';

  @override
  String get callMoreAudioDevices => 'オーディオデバイス';

  @override
  String get callMoreAudioOutputSubtitle => '本体、スピーカー、Bluetooth、ヘッドセット';

  @override
  String get callMoreAudioDevicesSubtitle => 'マイクとスピーカーを選択';

  @override
  String get callMoreParkCall => '通話をパーク';

  @override
  String get callMoreParkCallSubtitle => 'パークのフィーチャーコードに転送します';

  @override
  String get callMoreRetrieveParkedSubtitle => 'パークスロットをダイヤル';

  @override
  String get callMoreSendDtmf => 'DTMFを送信';

  @override
  String get callMoreSendDtmfSubtitle => 'PINなど、一連の数字をまとめて入力します';

  @override
  String get callSendDtmfTitle => 'DTMFを送信';

  @override
  String get callMoreCallInfo => '通話情報';

  @override
  String get callMoreQualitySubtitle => 'リアルタイムのMOS、ジッター、損失、往復遅延';

  @override
  String get callMoreSipTrace => 'SIPトレース';

  @override
  String get callMoreSipTraceSubtitle => 'この通話のラダー図';

  @override
  String get callInfoRemote => '相手';

  @override
  String get callInfoAccount => 'アカウント';

  @override
  String get callInfoState => '状態';

  @override
  String get callInfoSecure => 'セキュリティ';

  @override
  String get callInfoPlainSignalling => '暗号化なしのシグナリング';

  @override
  String get callRoutePhone => '本体';

  @override
  String get callRouteWiredHeadset => '有線ヘッドセット';

  @override
  String get callAudioMicrophone => 'マイク';

  @override
  String callCardSemantics(String name, String state) {
    return '$name との通話、$state';
  }

  @override
  String get callUnmute => 'ミュート解除';

  @override
  String get callStopRecording => '録音を停止';

  @override
  String get callSplitConference => '会議通話を分割';

  @override
  String get callMergeCalls => '通話を統合';

  @override
  String get callSwapCalls => '通話を切り替え';

  @override
  String get callAttendedTransferBanner => '確認転送：元の発信者は保留中です。';

  @override
  String get callActiveCalls => '通話中';

  @override
  String get callConferenceLevels => '会議通話のレベル';

  @override
  String get callLevelVolume => '音量';

  @override
  String get callLevelMicToParty => '相手へのマイク';

  @override
  String callPercentSemantics(int percent) {
    return '$percent パーセント';
  }

  @override
  String get callFailInvalidNumber => '無効な番号です（400）';

  @override
  String callFailNotAuthorised(String code) {
    return '通話が許可されていません（$code）';
  }

  @override
  String get callFailNumberNotFound => '番号が見つかりません（404）';

  @override
  String get callFailNoAnswerFromServer => 'サーバーから応答がありません（408）';

  @override
  String get callFailTemporarilyUnavailable => '一時的に利用できません（480）';

  @override
  String get callFailIncompleteNumber => '番号が不完全です（484）';

  @override
  String callFailBusy(String code) {
    return '話し中です（$code）';
  }

  @override
  String get callFailCancelled => '通話がキャンセルされました（487）';

  @override
  String callFailNoCompatibleCodec(String code) {
    return '対応するコーデックがありません（$code）';
  }

  @override
  String get callFailServiceUnavailable => 'サービスを利用できません（503）';

  @override
  String get callFailDeclined => '通話が拒否されました（603）';

  @override
  String get callFailGeneric => '通話に失敗しました';

  @override
  String callFailGenericWithCode(String code) {
    return '通話に失敗しました（$code）';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason（$code）';
  }

  @override
  String get callForegroundServiceText => '通話中';

  @override
  String get callTrayInCall => '通話中';

  @override
  String get callHistoryBlocked => '着信拒否';

  @override
  String get callHistoryAnonymityDisallowed => '非通知は不許可';

  @override
  String get callHistoryDoNotDisturb => '応答不可';

  @override
  String get callHistoryBusy => '話し中';

  @override
  String get callHistoryForwardedAlways => '転送（常時）';

  @override
  String get callHistoryForwardedBusy => '転送（通話中）';

  @override
  String get callHistorySentToVoicemail => '留守番電話に送信';

  @override
  String get callHistoryRedirected => 'リダイレクト';

  @override
  String get callIncomingNotificationBody => '着信';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return '$account に着信';
  }

  @override
  String get callMissedNotificationTitle => '不在着信';

  @override
  String get callErrEngineNotRunning => '通話エンジンはまだ起動していません';

  @override
  String get callErrAddAccount => '発信するにはアカウントを追加してください';

  @override
  String get callErrCouldNotPlace => '発信できませんでした';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account は登録されていません';
  }

  @override
  String get callErrCouldNotAnswer => '応答できませんでした';

  @override
  String get callErrNoVoicemailNumber => 'このアカウントにはボイスメールの番号が設定されていません';

  @override
  String get callErrTransferFailed => '転送に失敗しました';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return '転送に失敗しました：$reason（$code）';
  }

  @override
  String get callErrCouldNotMerge => '通話を統合できませんでした';

  @override
  String get callErrCouldNotStartRecording => '録音を開始できませんでした';

  @override
  String get callErrCouldNotStopRecording => '録音を停止できませんでした';

  @override
  String callParkingNotice(String code) {
    return '通話をパーク中（$code をダイヤル）';
  }

  @override
  String get callErrParkFailed => 'パークに失敗しました';

  @override
  String get callErrHandoffFailed => '引き継ぎに失敗しました';

  @override
  String get callErrCouldNotSendToDevice => 'デバイスに送信できませんでした';

  @override
  String get callHistoryForwardedNoAnswer => '転送（応答なし）';

  @override
  String get shellTabKeypad => 'キーパッド';

  @override
  String get shellTabRecents => '履歴';

  @override
  String get shellTabContacts => '連絡先';

  @override
  String get shellTabMessages => 'メッセージ';

  @override
  String get shellTabPresence => 'プレゼンス';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => '録音';

  @override
  String get shellSearchSemantics => '連絡先や履歴を検索、または番号をダイヤル';

  @override
  String get shellSearchHint => '検索またはダイヤル';

  @override
  String get shellVoicemailTooltip => 'ボイスメール';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新着ボイスメール$count件。クリックして発信',
      one: '新着ボイスメール1件。クリックして発信',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => '離席中';

  @override
  String get shellStatusTooltip => 'ステータス';

  @override
  String get shellDemoBanner => 'デモモード：通話はシミュレートされ、実際のネットワークには接続されません。';

  @override
  String get uiToday => '今日';

  @override
  String get uiYesterday => '昨日';

  @override
  String get uiUnknownCaller => '不明な発信者';

  @override
  String get uiCallEnded => '通話終了';

  @override
  String get uiCallTransferNotConfirmed => '転送が未確認です';

  @override
  String get uiCallTransferring => '転送中...';

  @override
  String get uiCallConference => '会議通話';

  @override
  String get uiCallOnHold => '保留中';

  @override
  String get uiCallHeldByRemote => '相手が保留中';

  @override
  String get uiCallCalling => '発信中...';

  @override
  String get uiCallRinging => '呼び出し中...';

  @override
  String get uiCallConnecting => '接続中...';

  @override
  String get uiCallIncoming => '着信';

  @override
  String get uiCallConnected => '通話中';

  @override
  String get uiQrScanTitle => 'QRコードをスキャン';

  @override
  String get uiQrPasteHint => 'コードのテキストを貼り付け';

  @override
  String get uiQrNoCamera =>
      'このデバイスではカメラでのスキャンを利用できません。代わりにコードのテキストを貼り付けてください。';

  @override
  String get uiQrPaste => '貼り付け';

  @override
  String get uiQrUse => '使用';

  @override
  String get uiQrCameraDenied =>
      'カメラへのアクセスがオフです。システム設定で許可するか、下にコードのテキストを貼り付けてください。';

  @override
  String get uiQrCameraUnavailable => 'カメラを利用できません。下にコードのテキストを貼り付けてください。';

  @override
  String get presenceLampRinging => '呼び出し中';

  @override
  String get presenceHeader => 'ビジーランプフィールド';

  @override
  String get presenceChooseTooltip => '監視する連絡先を選択';

  @override
  String get presenceEmptyTitle => 'ボードに内線がありません';

  @override
  String get presenceEmptySubtitle =>
      '連絡先の「BLFボードに表示」をオンにすると、その相手が空き、呼び出し中、通話中のどれかを確認できます。';

  @override
  String get presenceOpenContacts => '連絡先を開く';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name、$status。タップで発信、長押しでその他の操作';
  }

  @override
  String presenceCallName(String name) {
    return '$name に発信';
  }

  @override
  String get presencePickup => 'この内線をピックアップ';

  @override
  String get presencePickupSub => '相手の呼び出し中の通話に応答します（指定ピックアップ）';

  @override
  String get presenceTransferHere => '現在の通話をここに転送';

  @override
  String get presenceRemove => 'ボードから削除';

  @override
  String get uiCall => '発信';

  @override
  String get uiMessage => 'メッセージ';

  @override
  String get recentsSearchTooltip => '履歴を検索';

  @override
  String get recentsClearTitle => '通話履歴を消去しますか？';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件すべての履歴が削除されます。',
      one: '1件の履歴が削除されます。',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => '履歴をCSVとしてクリップボードにコピーしました';

  @override
  String get recentsMenuCopyCsv => 'CSVとしてコピー';

  @override
  String get recentsMenuClear => '履歴を消去';

  @override
  String get recentsSearchHint => '名前または番号を検索';

  @override
  String get recentsFilterAll => 'すべて';

  @override
  String get recentsFilterMissed => '不在着信';

  @override
  String get recentsFilterIncoming => '着信';

  @override
  String get recentsFilterOutgoing => '発信';

  @override
  String get recentsFilterAccount => 'アカウントで絞り込み';

  @override
  String get recentsAllAccounts => 'すべてのアカウント';

  @override
  String get recentsAccountFallback => 'アカウント';

  @override
  String get recentsEmptyNone => '通話履歴はまだありません';

  @override
  String get recentsEmptyNoMatch => '一致する通話がありません';

  @override
  String get recentsEmptyNoneSub => '通話はここに表示されます。';

  @override
  String get recentsEmptyNoMatchSub => '別のフィルターをお試しください。';

  @override
  String get recentsOpenKeypad => 'キーパッドを開く';

  @override
  String get recentsShowAll => 'すべて表示';

  @override
  String get recentsSelectCall => '通話を選択';

  @override
  String get recentsSelectCallSub => '詳細、品質、録音がここに表示されます。';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': '不在着信',
      'incoming': '着信',
      'other': '発信',
    });
    return '$_temp0 $name、$number、$time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '$name に発信';
  }

  @override
  String get recentsAddAccountToMessage => 'メッセージを送信するにはアカウントを追加してください';

  @override
  String get recentsAddContact => '連絡先に追加';

  @override
  String get recentsContact => '連絡先';

  @override
  String get recentsBlock => '拒否';

  @override
  String get recentsUnblock => '拒否を解除';

  @override
  String recentsBlockTitle(String number) {
    return '$number を拒否しますか？';
  }

  @override
  String get recentsBlockMessage => 'この番号からの着信は自動的に拒否されます。';

  @override
  String get recentsQualityHeader => '通話品質';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return '最悪MOS $mos   ·   ジッター $jitter ms   ·   損失 $loss %';
  }

  @override
  String get recentsRecordingsHeader => '録音';

  @override
  String get recentsOpenInRecordings => '録音で開く';

  @override
  String recentsRelatedCall(String title) {
    return '関連する通話：$title';
  }

  @override
  String get recentsHistoryHeader => '履歴';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'この番号との通話はありません';

  @override
  String get recentsDeleteTitle => 'これらの通話を削除しますか？';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name の履歴$count件を削除します。',
      one: '$name の履歴1件を削除します。',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => '履歴から削除';

  @override
  String get recentsCallDetails => '通話の詳細';

  @override
  String get contactsFavoritesHeader => '★ お気に入り';

  @override
  String get contactsFavoritesOnly => 'お気に入りのみ';

  @override
  String get contactsShowAll => 'すべて表示';

  @override
  String get contactsImportExportTooltip => 'インポートとエクスポート';

  @override
  String get contactsMenuDevice => 'デバイスからインポート';

  @override
  String get contactsMenuFile => 'vCard／CSVファイルをインポート';

  @override
  String get contactsMenuClipboard => 'クリップボードからインポート';

  @override
  String get contactsMenuCopyVcard => 'vCardとしてコピー';

  @override
  String get contactsMenuCopyCsv => 'CSVとしてコピー';

  @override
  String get contactsNewTooltip => '新しい連絡先';

  @override
  String get contactsSearchHint => '連絡先を検索';

  @override
  String get contactsEmptyTitle => '連絡先はまだありません';

  @override
  String get contactsEmptySubtitle =>
      'よく連絡する相手を追加するか、vCardまたはCSVファイルをインポートしてください。';

  @override
  String get contactsEmptyAction => '連絡先を追加';

  @override
  String get contactsNoMatches => '一致なし';

  @override
  String contactsCallName(String name) {
    return '$name に発信';
  }

  @override
  String get contactsSelect => '連絡先を選択';

  @override
  String get contactsCopiedVcard => '連絡先をvCardとしてコピーしました';

  @override
  String get contactsCopiedCsv => '連絡先をCSVとしてコピーしました';

  @override
  String get contactsDeviceDenied =>
      '連絡先へのアクセスが拒否されました。インポートするには、システム設定で許可してください。';

  @override
  String get contactsDeviceNone => 'このデバイスに連絡先が見つかりません';

  @override
  String contactsNothingNew(int count) {
    return 'インポートする新しい連絡先はありません（$count件は登録済み）';
  }

  @override
  String get contactsImportDeviceTitle => 'デバイスからインポートしますか？';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新しい連絡先$count件',
      one: '新しい連絡先1件',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count件を番号の追加で更新';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count件をスキップ（重複または電話番号なし）';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '連絡先$count件をインポートしました',
      one: '連絡先1件をインポートしました',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'そのデータに連絡先が見つかりません';

  @override
  String get contactsLabelMobile => '携帯';

  @override
  String get contactsLabelWork => '仕事';

  @override
  String get contactsLabelHome => '自宅';

  @override
  String get contactsLabelOther => 'その他';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => '連絡先が見つかりません';

  @override
  String get contactsActionFavorite => 'お気に入り';

  @override
  String get contactsNumbersHeader => '電話番号';

  @override
  String get contactsSipAddress => 'SIPアドレス';

  @override
  String get contactsDetailsHeader => '詳細';

  @override
  String get contactsOnBlf => 'BLFボードに表示中';

  @override
  String get contactsAlwaysRecorded => '通話を常に録音';

  @override
  String contactsDeleteTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String get contactsDeleteMessage => 'この連絡先はこのデバイスから削除されます。';

  @override
  String get contactsDeleteButton => '連絡先を削除';

  @override
  String get contactsDetailTitle => '連絡先';

  @override
  String get contactsErrorNameOrNumber => '名前または電話番号を入力してください';

  @override
  String get contactsEditTitle => '連絡先を編集';

  @override
  String get contactsFieldName => '名前';

  @override
  String get contactsFieldCompany => '会社';

  @override
  String get contactsFieldNumber => '電話番号';

  @override
  String get contactsRemoveNumber => '番号を削除';

  @override
  String get contactsAddNumber => '番号を追加';

  @override
  String get contactsSipHeader => 'SIPアドレス';

  @override
  String get contactsRemoveAddress => 'アドレスを削除';

  @override
  String get contactsAddSip => 'SIPアドレスを追加';

  @override
  String get contactsFieldEmail => 'メール';

  @override
  String get contactsFieldNotes => 'メモ';

  @override
  String get contactsFieldFavorite => 'お気に入り';

  @override
  String get contactsShowOnBlf => 'BLFボードに表示';

  @override
  String get contactsShowOnBlfSub => 'この内線のプレゼンスとビジーランプを監視します';

  @override
  String get contactsAlwaysRecordTitle => 'この連絡先との通話を常に録音';

  @override
  String get contactsAlwaysRecordSub => '自動録音のルールより優先されます';

  @override
  String get contactsRingtone => '着信音';

  @override
  String get contactsPresenceVia => 'プレゼンスに使うアカウント';

  @override
  String get contactsDefaultAccount => 'デフォルトのアカウント';

  @override
  String get contactsDeleteContactTitle => '連絡先を削除しますか？';

  @override
  String get contactsCannotUndo => 'この操作は元に戻せません。';

  @override
  String get messagesNewMessage => '新規メッセージ';

  @override
  String get messagesNumberOrSip => '電話番号またはSIPアドレス';

  @override
  String get messagesNoConversations => '会話はありません';

  @override
  String get messagesEmptySubtitle => 'アカウントを使って、任意の内線やアドレスにSIPメッセージを送信できます。';

  @override
  String get messagesTyping => '入力中...';

  @override
  String get messagesYouPrefix => '自分：';

  @override
  String get messagesSelect => '会話を選択';

  @override
  String get messagesLanOnline => 'ネットワーク上でオンライン';

  @override
  String get messagesLanOffline => 'オフラインです。オンラインに戻ったときにメッセージが送信されます。';

  @override
  String messagesSendFileTo(String name) {
    return '$name にファイルを送信';
  }

  @override
  String messagesCallName(String name) {
    return '$name に発信';
  }

  @override
  String get messagesDeleteTitle => '会話を削除しますか？';

  @override
  String messagesDeleteMessage(String name) {
    return '$name とのメッセージがすべて削除されます。';
  }

  @override
  String get messagesDeleteMenu => '会話を削除';

  @override
  String get messagesSayHello => 'あいさつしましょう';

  @override
  String get messagesLanEmptySub =>
      'メッセージはネットワーク経由でこのデバイスに直接、エンドツーエンドで暗号化されて送信されます。';

  @override
  String get messagesSipEmptySub => 'メッセージは、アカウントを通じてSIP MESSAGEで送信されます。';

  @override
  String get messagesInputHint => 'メッセージ';

  @override
  String get messagesSend => '送信';

  @override
  String get messagesStatusSending => '送信中';

  @override
  String get messagesStatusSent => '送信済み';

  @override
  String get messagesStatusDelivered => '配信済み';

  @override
  String get messagesStatusRead => '既読';

  @override
  String get messagesStatusFailed => '失敗';

  @override
  String get messagesNotDelivered => '配信されませんでした。タップして再試行';

  @override
  String get uiStatusRegistered => '登録済み';

  @override
  String get uiStatusRegistering => '登録中';

  @override
  String get uiStatusRegFailed => '登録失敗';

  @override
  String get uiStatusDisabled => '無効';

  @override
  String get uiQualityMeasuring => '測定中';

  @override
  String get uiQualityExcellent => '非常に良い';

  @override
  String get uiQualityGood => '良い';

  @override
  String get uiQualityFair => '普通';

  @override
  String get uiQualityPoor => '悪い';

  @override
  String get uiQualityBad => '非常に悪い';

  @override
  String uiQualitySemantics(String label) {
    return '通話品質：$label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return '通話品質：$label、MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return '通話品質：$label';
  }

  @override
  String get uiSecureFull => '暗号化済み';

  @override
  String get uiSecureMedia => 'メディア暗号化済み';

  @override
  String get uiSecureSignalling => 'シグナリング暗号化済み';

  @override
  String get uiSecureNone => '暗号化なし';

  @override
  String get uiSecureSrtpLine => 'SRTPメディア';

  @override
  String get uiSecureTlsLine => 'TLSシグナリング';

  @override
  String lanCallHandingOver(String name) {
    return '$name に引き継ぎ中';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return '$name へのインターコム';
  }

  @override
  String get lanCallIntercomToUnnamed => '近くのデバイスへのインターコム';

  @override
  String lanCallIntercomFromNamed(String name) {
    return '$name からのインターコム';
  }

  @override
  String get lanCallIntercomFromUnnamed => '近くのデバイスからのインターコム';

  @override
  String lanCallToNamed(String name) {
    return '$name へのLAN通話';
  }

  @override
  String get lanCallToUnpaired => '未ペアリングのデバイスへのLAN通話';

  @override
  String lanCallFromNamed(String name) {
    return '$name からのLAN通話';
  }

  @override
  String get lanCallFromUnpaired => '未ペアリングのデバイスからのLAN通話';

  @override
  String lanHandoffTransferredFrom(String device) {
    return '$device から転送された通話';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return '$device から転送された通話：$caller';
  }

  @override
  String get lanHandoffAnotherDevice => '別のデバイス';

  @override
  String lanRelayedTitle(String name) {
    return '$name に中継中';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return '発信者は $name と通話中です。あなたは通話に参加していません。';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '$name を呼び出し中...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return '$name が応答するまで、発信者は接続されたままです。';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '$name に確認中...';
  }

  @override
  String get lanRelayOfferingSubtitle => '通話の受け入れを待っています。';

  @override
  String lanRelayConsultingTitle(String name) {
    return '$name と通話中';
  }

  @override
  String get lanRelayConsultingSubtitle => '発信者は保留中です。準備ができたら引き継ぎを完了してください。';

  @override
  String get lanRelayTakingBack => '通話を取り戻し中...';

  @override
  String get lanRelayTakeBack => '取り戻す';

  @override
  String get lanRelayEnd => '終了';

  @override
  String get lanSendToDevice => 'デバイスに送信';

  @override
  String get lanBusy => '通話中';

  @override
  String get lanNoPairedOnline => 'オンラインのペアリング済みデバイスがありません';

  @override
  String lanPairRejectedBy(String name) {
    return '$name がペアリングを拒否しました。';
  }

  @override
  String get lanPairRejected => 'ペアリングが拒否されました。';

  @override
  String get lanPairCancelled => 'ペアリングがキャンセルされました。';

  @override
  String get lanPairTimedOut => 'ペアリングがタイムアウトしました。もう一度お試しください。';

  @override
  String get lanPairFailed => 'ペアリングに失敗しました';

  @override
  String lanPairFailedReason(String reason) {
    return 'ペアリングに失敗しました：$reason';
  }

  @override
  String get lanPairThisDevice => 'このデバイス';

  @override
  String get lanPairConnecting => '安全に接続中...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name がこのデバイスとのペアリングを求めています。';
  }

  @override
  String lanPairPairingWith(String name) {
    return '$name とペアリング中です。';
  }

  @override
  String get lanPairCheckCode => 'このコードが両方の画面で同じであることを確認してください。';

  @override
  String lanPairCodeSemantics(String code) {
    return 'ペアリングコード $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return '$name の確認を待っています...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name が確認しました。';
  }

  @override
  String get lanPairReject => '拒否';

  @override
  String get lanPairCodesMatch => 'コードが一致';

  @override
  String lanPairPairedWith(String name) {
    return '$name とペアリングしました。';
  }

  @override
  String get lanPairRequestTitle => 'ペアリングのリクエスト';

  @override
  String lanPairTitle(String name) {
    return '$name とペアリング';
  }

  @override
  String get lanActionDecline => '拒否';

  @override
  String get lanActionAccept => '受け入れる';

  @override
  String get lanFileIncomingTitle => 'ファイルを受信';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$name から $size';
  }

  @override
  String get lanHandoffOfferTitle => '通話をここに転送しますか？';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': '（発信者：$caller）',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': '（アカウント：$account）',
    });
    return '$device が通話を引き継ごうとしています$_temp0$_temp1。';
  }

  @override
  String get lanHandoffOfferAttended => '先に相手があなたと話します。';

  @override
  String get lanHandoffTakeCall => '通話を受ける';

  @override
  String lanIntercomRequestTitle(String name) {
    return '$name からのインターコムを許可しますか？';
  }

  @override
  String get lanIntercomRequestBody => '相手からの通話にスピーカーで自動応答します。';

  @override
  String get lanIntercomDeny => '拒否';

  @override
  String get lanIntercomAllow => '許可';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name がこのデバイスをペアリング済みリストから削除しました';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のファイルを送信中...',
      one: '$name を送信中...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => '新規メッセージ';

  @override
  String get lanSipMessage => 'SIPメッセージ';

  @override
  String get lanSipMessageSub => 'アカウント経由で番号またはアドレスに送信';

  @override
  String get lanChatOnline => 'LANチャット（オンライン）';

  @override
  String get lanChatOffline => 'LANチャット（オフライン）';

  @override
  String lanSavedAt(String path) {
    return '$path に保存しました（パスをコピー済み）';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'デバイス同士が直接つながります';

  @override
  String get lanConnectByAddress => 'アドレスで接続';

  @override
  String get lanSettingsTooltip => 'LAN設定';

  @override
  String get lanOffTitle => 'LAN Linkはオフです';

  @override
  String get lanOffSubtitle =>
      'サーバーなしで、他のSoftphoneProデバイスを見つけ、チャットやファイルの受け渡し、通話の引き継ぎができます。';

  @override
  String get lanTurnOn => 'LAN Linkをオンにする';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Linkを起動できませんでした：$error';
  }

  @override
  String get lanConnectHelp =>
      'ホスト:ポートを入力するか、他のデバイスに表示されたQRコードのテキストを貼り付けてください。';

  @override
  String get lanScanTitle => 'LANペアリングQRをスキャン';

  @override
  String get lanScanQr => 'QRをスキャン';

  @override
  String get lanPaste => '貼り付け';

  @override
  String get lanConnect => '接続';

  @override
  String lanConnectedTo(String name) {
    return '$name に接続しました';
  }

  @override
  String get lanCouldNotConnect => '接続できませんでした';

  @override
  String get lanCouldNotStartPairing => 'ペアリングを開始できませんでした';

  @override
  String get lanThisDevice => 'このデバイス';

  @override
  String get lanDeviceNameTitle => 'デバイス名';

  @override
  String get lanStarting => '起動中...';

  @override
  String get lanVisible => 'ネットワーク上に公開中';

  @override
  String get lanNotRunning => '停止中';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のアカウントを共有中',
      one: '1件のアカウントを共有中',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'フィンガープリント';

  @override
  String get lanHideQr => 'QRコードを隠す';

  @override
  String get lanShowQr => 'QRコードを表示して別のデバイスを接続';

  @override
  String get lanCopyConnectionText => '接続用テキストをコピー';

  @override
  String get lanConnectionTextCopied => '接続用テキストをコピーしました';

  @override
  String get lanActiveOnOthers => '他のデバイスで通話中';

  @override
  String get lanPairedDevices => 'ペアリング済みデバイス';

  @override
  String get lanNoPaired =>
      'ペアリング済みのデバイスはまだありません。近くのデバイスとペアリングすると、チャット、ファイル送信、通話の引き継ぎができます。';

  @override
  String get lanNearby => '近くのデバイス';

  @override
  String get lanNearbyHint =>
      'ネットワーク上のSoftphoneProを探しています。他のデバイスでもLAN Linkをオンにする必要があります。上のリンクボタンから、アドレスを指定して接続することもできます。';

  @override
  String get lanTransfers => '転送中';

  @override
  String get lanFiles => 'ファイル';

  @override
  String get lanPairedBadge => 'ペアリング済み';

  @override
  String get lanTyping => '入力中...';

  @override
  String get lanPair => 'ペアリング';

  @override
  String get lanUnpair => 'ペアリング解除';

  @override
  String lanUnpairTitle(String name) {
    return '$name のペアリングを解除しますか？';
  }

  @override
  String get lanUnpairMessage => 'チャット、ファイル送信、通話の引き継ぎを行うには、再度ペアリングが必要になります。';

  @override
  String get lanActionMessage => 'メッセージ';

  @override
  String get lanActionSendFile => 'ファイルを送信';

  @override
  String get lanActionCall => '発信';

  @override
  String get lanActionIntercom => 'インターコム';

  @override
  String lanRemoteActiveOn(String device) {
    return '$device で通話中';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return '$device で通話中  ·  $account';
  }

  @override
  String get lanPull => '引き取る';

  @override
  String get lanTransferPreparing => '準備中...';

  @override
  String get lanTransferWaitingYou => '確認待ち';

  @override
  String lanTransferWaitingPeer(String name) {
    return '$name の受け入れを待っています';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get lanTransferVerifying => '検証中...';

  @override
  String lanTransferFrom(String name, String status) {
    return '$name から  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return '$name へ  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  $name から';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  $name へ';
  }

  @override
  String lanFileFailed(String error) {
    return '失敗：$error';
  }

  @override
  String get lanFileActions => 'ファイルの操作';

  @override
  String get lanPathCopied => 'パスをコピーしました';

  @override
  String get lanFileOpen => '開く';

  @override
  String get lanFileShowInFolder => 'フォルダで表示';

  @override
  String get lanFileCopyPath => 'パスをコピー';

  @override
  String lanNetworkError(String message) {
    return 'ネットワークエラー：$message';
  }

  @override
  String get lanErrNotRunning => '先にLAN Linkをオンにしてください';

  @override
  String get lanErrBadAddress =>
      '192.168.1.20:4711 の形式でアドレスを入力するか、QRコードのテキストを貼り付けてください';

  @override
  String get lanErrFingerprint =>
      'そのデバイスはスキャンしたコードと一致しません。QRコードは別のデバイスのものではありませんか？';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$name から $file を受信しました';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file を $name に送信しました';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name が $file を拒否しました';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'ファイル転送に失敗しました：$error';
  }

  @override
  String get lanNoticeNeedLanOn => '近くのデバイスに発信するには、LAN Linkをオンにしてください';

  @override
  String get lanNoticePairFirst => '先にこのデバイスとペアリングしてください';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name は現在、通話を受けられません';
  }

  @override
  String lanNoticeAsking(String name) {
    return '$name に確認中…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name がインターコムを許可しませんでした（または応答がありませんでした）';
  }

  @override
  String get lanHoOff => 'LAN Linkはオフです';

  @override
  String get lanHoPairFirst => '先にそのデバイスとペアリングしてください';

  @override
  String lanHoOffline(String name) {
    return '$name はオフラインです';
  }

  @override
  String get lanHoAlready => 'この通話はすでに引き継ぎ中です';

  @override
  String get lanHoEnded => '通話はすでに終了しています';

  @override
  String get lanHoWaitConnected => '通話がつながるまでお待ちください';

  @override
  String get lanHoLanCall => 'LAN通話は引き継げません';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name はネットワーク経由で通話を受けられません（そちらでLAN通話がオフです）';
  }

  @override
  String get lanHoNoLanHere => 'このデバイスではLAN通話を利用できません';

  @override
  String lanHoDeclined(String name) {
    return '$name が通話を拒否しました。通話はそのまま継続します。';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name から応答がありませんでした。通話はそのまま継続します。';
  }

  @override
  String get lanHoCancelled => '引き継ぎがキャンセルされました。通話はそのまま継続します。';

  @override
  String lanHoUnreachable(String name) {
    return '$name に接続できませんでした。通話はそのまま継続します。';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '$name に接続できませんでした（$reason）。通話はそのまま継続します。';
  }

  @override
  String get lanHoEndedBefore => '引き継ぐ前に通話が終了しました';

  @override
  String lanHoPbxRefused(String name) {
    return '電話システムが転送を拒否し、$name はLAN通話を受けられません';
  }

  @override
  String get lanHoPbxFailedRelaying => '電話システム経由の転送に失敗しました。代わりにネットワーク経由で中継します。';

  @override
  String lanHoSentTo(String name) {
    return '通話を $name に送信しました';
  }

  @override
  String get lanHoConsultFailed => '電話システム経由で他のデバイスを呼び出せませんでした';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name に接続できなくなりました';
  }

  @override
  String get lanHoCouldNotAnswer => '引き継ぐための通話に応答できませんでした';

  @override
  String lanHoCouldNotCall(String name) {
    return 'ネットワーク経由で $name を呼び出せませんでした。通話はそのまま継続します。';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name が応答しませんでした。通話はそのまま継続します。';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return '$name に引き継ぎ済み';
  }

  @override
  String lanHoRelayed(String name) {
    return '通話を $name に中継しました';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return '先に $name が応答するまでお待ちください';
  }

  @override
  String get lanHoFailed => '引き継ぎに失敗しました';

  @override
  String lanHoTakenBack(String name) {
    return '$name から通話を取り戻しました';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name が確認を終了しました。通話はあなたに戻りました。';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return '通話を $name に引き継げませんでした';
  }

  @override
  String get diagSip400Explain => 'サーバーがリクエストを理解できませんでした。';

  @override
  String get diagSip400Fix =>
      'アカウント設定（ドメイン、ユーザー名、プロキシ）を確認してください。解決しない場合は、SIPトレースをプロバイダーに送ってください。';

  @override
  String get diagSip401Explain => 'サーバーが認証情報を拒否しました（または認証情報を求めています）。';

  @override
  String get diagSip401Fix =>
      'ユーザー名、認証ユーザー名、パスワードを確認してください。プロバイダーによっては、別途「認証ID」が必要です。';

  @override
  String get diagSip403Explain =>
      'サーバーはリクエストを理解しましたが、拒否しました。パスワードの誤り、アカウントの無効化、またはお使いのIPが許可されていない可能性があります。';

  @override
  String get diagSip403Fix =>
      'パスワードを再入力し、アカウントが有効であること、お使いのグローバルIPがブロックされていないこと（fail2ban／ACL）を確認してください。';

  @override
  String get diagSip404Explain => 'サーバーがこのユーザーまたは番号を認識していません。';

  @override
  String get diagSip404Fix =>
      'ユーザー名とドメインを確認してください。発信の場合は、ダイヤルした番号とダイヤル規則を確認してください。';

  @override
  String get diagSip405Explain => 'サーバーはこのリクエストに対応していません。';

  @override
  String get diagSip405Fix =>
      'OPTIONSのpingであれば、通常は問題ありません。REGISTERの場合は、接続先がSIPレジストラーであることを確認してください。';

  @override
  String get diagSip407Explain => 'アウトバウンドプロキシが認証情報を必要としています。';

  @override
  String get diagSip407Fix => 'アカウントのパスワードとアウトバウンドプロキシの設定を確認してください。';

  @override
  String get diagSip408Explain => 'サーバーから時間内に応答がありませんでした。';

  @override
  String get diagSip408Fix =>
      'サーバーのアドレスとポート、ファイアウォールを確認し、TCPまたはTLSを試してください。UDPでのみタイムアウトが繰り返される場合は、ルーターのSIP ALGが原因の可能性があります。';

  @override
  String get diagSip410Explain => 'この番号はすでに存在しません。';

  @override
  String get diagSip410Fix => 'ダイヤルした番号を確認してください。';

  @override
  String get diagSip415Explain => '相手が、提示されたコンテンツタイプまたはコーデックを受け付けません。';

  @override
  String get diagSip415Fix => '設定 > コーデック で、より多くのコーデック（PCMU／PCMAなど）を有効にしてください。';

  @override
  String get diagSip421Explain => 'サーバーは、このクライアントが提示しなかったSIP拡張を必要としています。';

  @override
  String get diagSip421Fix => 'アカウントのNAT／ICE／100rel／タイマーの設定を確認してください。';

  @override
  String get diagSip423Explain => '登録の有効期間が、サーバーの許容値より短く設定されています。';

  @override
  String get diagSip423Fix => 'アカウント設定で登録の有効期間を長くしてください。';

  @override
  String get diagSip480Explain => 'ユーザーが登録されていないか、現在連絡が取れません。';

  @override
  String get diagSip480Fix =>
      '相手が登録されていることを確認してください。登録時の場合は、サーバーが過負荷の可能性があるため、後で再試行してください。';

  @override
  String get diagSip481Explain => 'サーバーがダイアログの状態を失いました（再起動やネットワーク変更の後など）。';

  @override
  String get diagSip481Fix => '通話を終了して再試行してください。頻繁に起こる場合は、セッションタイマーを有効にしてください。';

  @override
  String get diagSip483Explain => 'リクエストがサーバー間で循環しました。';

  @override
  String get diagSip483Fix => 'PBXの転送とルーティングの設定を確認してください。';

  @override
  String get diagSip484Explain => 'ダイヤルした番号が短すぎます。';

  @override
  String get diagSip484Fix => '番号を最後まで入力するか、ダイヤル規則を確認してください。';

  @override
  String get diagSip486Explain => '相手は話し中です。';

  @override
  String get diagSip486Fix => 'しばらくしてからもう一度お試しください。';

  @override
  String get diagSip487Explain => '応答される前に通話がキャンセルされました。';

  @override
  String get diagSip487Fix => '呼び出し中に発信者が切った場合は正常な動作です。';

  @override
  String get diagSip488Explain => '相手と共通のコーデックまたは暗号化設定がありません。';

  @override
  String get diagSip488Fix =>
      'コーデックとSRTPを確認してください（SRTP必須のアカウントは、暗号化なしのRTPのエンドポイントには発信できません）。';

  @override
  String get diagSip491Explain => '2つのre-INVITEが衝突しました。';

  @override
  String get diagSip491Fix => '通常は自動的に再試行されます。';

  @override
  String get diagSip500Explain => 'サーバーで内部エラーが発生しました。';

  @override
  String get diagSip500Fix => '後で再試行し、解決しない場合はプロバイダーに連絡してください。';

  @override
  String get diagSip502Explain => '上位のサーバーが無効な応答を返しました。';

  @override
  String get diagSip502Fix => '後で再試行し、解決しない場合はプロバイダーに連絡してください。';

  @override
  String get diagSip503Explain => 'サーバーが過負荷、停止中、またはこのクライアントを拒否しています（レート制限）。';

  @override
  String get diagSip503Fix =>
      'しばらく待って再試行するか、プロバイダーのステータスページを確認するか、別のサーバー／ポートを試してください。';

  @override
  String get diagSip504Explain => '上位のサーバーから時間内に応答がありませんでした。';

  @override
  String get diagSip504Fix => '後で再試行してください。';

  @override
  String get diagSip600Explain => 'すべての宛先が話し中です。';

  @override
  String get diagSip600Fix => 'しばらくしてからもう一度お試しください。';

  @override
  String get diagSip603Explain => '相手が通話を拒否しました。';

  @override
  String get diagSip603Fix => '対処は不要です。通話が拒否されただけです。';

  @override
  String get diagSip604Explain => 'この番号は存在しません。';

  @override
  String get diagSip604Fix => 'ダイヤルした番号を確認してください。';

  @override
  String get diagSip606Explain => '相手は、提示された内容ではセッションを受け付けられません。';

  @override
  String get diagSip606Fix => 'コーデックと暗号化の設定を確認してください。';

  @override
  String diagSipProvisionalTitle(int code) {
    return '暫定応答（$code）';
  }

  @override
  String get diagSipProvisionalExplain => 'リクエストを処理中です。';

  @override
  String diagSipSuccessTitle(int code) {
    return '成功（$code）';
  }

  @override
  String get diagSipSuccessExplain => 'リクエストは成功しました。';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'リダイレクト（$code）';
  }

  @override
  String get diagSipRedirectedExplain => '宛先が移動しました。';

  @override
  String get diagSipRedirectedFix => '転送の設定を確認してください。';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'クライアントエラー（$code）';
  }

  @override
  String get diagSipClientErrorExplain => 'サーバーがリクエストを拒否しました。';

  @override
  String get diagSipClientErrorFix => 'アカウントとダイヤルした番号を確認してください。';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'サーバーエラー（$code）';
  }

  @override
  String get diagSipServerErrorExplain => 'サーバーがリクエストを処理できませんでした。';

  @override
  String get diagSipServerErrorFix => '後で再試行するか、プロバイダーに連絡してください。';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return '全体的な失敗（$code）';
  }

  @override
  String get diagSipGlobalFailureExplain => 'どこでもリクエストを実行できません。';

  @override
  String get diagSipNoResponseTitle => '応答なし';

  @override
  String get diagSipNoResponseExplain => 'SIP応答を受信しませんでした。';

  @override
  String get diagSipNoResponseFix => 'ネットワーク接続とサーバーのアドレスを確認してください。';

  @override
  String get diagWizStepNet => 'ネットワーク接続';

  @override
  String diagWizStepDns(String account) {
    return 'DNSとSRV：$account';
  }

  @override
  String get diagWizStepNat => 'NATの種類';

  @override
  String diagWizStepOptions(String account) {
    return 'サーバーへの到達性：$account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS証明書：$account';
  }

  @override
  String diagWizStepReg(String account) {
    return '登録：$account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALGチェック';

  @override
  String get diagWizChecking => '確認中...';

  @override
  String diagWizEngineError(String message) {
    return 'エンジンエラー：$message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'チェックに失敗しました：$error';
  }

  @override
  String get diagWizNoEngine => 'SIPエンジンが動作していません';

  @override
  String get diagWizNoEngineFix =>
      'エンジンが起動するのを待つか（またはアプリを再起動して）、もう一度チェックを実行してください。';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface：$address（プライベート）';
  }

  @override
  String get diagWizNetNone => 'IPアドレスを持つ有効なネットワークインターフェースがありません';

  @override
  String get diagWizNetNoneFix =>
      'Wi-Fi、イーサネット、またはモバイルデータに接続してから、もう一度チェックを実行してください。';

  @override
  String get diagWizNetIpv6Only => 'IPv6アドレスのみ見つかりました';

  @override
  String get diagWizNetIpv6OnlyFix =>
      '多くのSIPプロバイダーはIPv4のみ対応です。このネットワークでIPv4を有効にするか、IPv6に対応したプロバイダーを使用してください。';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces個のインターフェース',
      one: '1個のインターフェース',
    );
    String _temp1 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: 'IPv4アドレス$v4件',
      one: 'IPv4アドレス1件',
    );
    return '$_temp0に$_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'VPN系のインターフェースが有効です。VPNは遅延を増やしたりUDPをブロックしたりすることがあるため、通話の調子が悪い場合は無効にしてください。';

  @override
  String get diagWizDnsNoServer => 'アカウントにサーバーアドレスがありません';

  @override
  String get diagWizDnsNoServerFix => 'アカウントを編集して、SIPドメインを入力してください。';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host はIPアドレスのため、DNSは不要です';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA：なし';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA：なし（$error）';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name：なし';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name：$target:$port（優先度 $priority、重み $weight）';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport：検索に失敗しました（$error）';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host を名前解決できません';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'ドメインに誤字がないこと、DNSサーバーが動作していることを確認してください。設定 > ネットワーク でカスタムDNSサーバー（例：8.8.8.8）を指定できます。';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host にはSRVレコードがありますが、アドレスレコードがありません';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'SRVのターゲットが使用されます。通話に失敗する場合は、プロバイダーにAレコードの確認を依頼してください。';

  @override
  String diagWizDnsResolves(String host, String address, int more, int srv) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '（ほか$more件）',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      srv,
      locale: localeName,
      other: '、SRVレコード$srv件',
      one: '、SRVレコード1件',
      zero: '',
    );
    return '$host は $address に解決されます$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'NAT検出がタイムアウトしました';

  @override
  String get diagWizNatTimeoutFix =>
      'STUNサーバーに到達できない可能性があります（UDPがブロックされている？）。設定 > ネットワーク > STUNサーバー を確認してください。';

  @override
  String diagWizNatStun(String server) {
    return 'STUNサーバー：$server';
  }

  @override
  String get diagWizNatOpen => 'NATなし：このデバイスはグローバルアドレスを持っています';

  @override
  String get diagWizNatFullCone => 'フルコーンNAT：VoIPに適しています';

  @override
  String get diagWizNatRestricted => '制限コーンNAT：STUNとキープアライブで動作します';

  @override
  String get diagWizNatPortRestricted => 'ポート制限コーンNAT：STUNとキープアライブで動作します';

  @override
  String get diagWizNatSymmetric => '対称型NAT：STUNだけではメディアポートを予測できません';

  @override
  String get diagWizNatSymmetricFix =>
      '一部の通話で片方向の音声や無音になる可能性があります。アカウント設定（アカウント > NAT）でICEとTURNリレーを有効にするか、メディアリレー（rtpengine）のあるプロバイダー／PBXを使用してください。';

  @override
  String get diagWizNatBlocked => 'UDPがブロックされているようです';

  @override
  String get diagWizNatBlockedFix =>
      'アカウントのトランスポートにTCPまたはTLSを使用してください。ネットワークがWeb通信以外をすべて遮断している場合は、プロバイダーが対応していればポート443のTLSを試してください。';

  @override
  String get diagWizNatUnknown => 'NATの種類を判別できませんでした';

  @override
  String get diagWizNatUnknownFix =>
      'STUNサーバーが応答しませんでした。設定 > ネットワーク で別のSTUNサーバーを試してください。';

  @override
  String get diagWizNatErr => 'STUNサーバーが応答しなかったため、NATの種類を判別できませんでした。';

  @override
  String get diagWizNatUnknownRaw => 'NATの種類を判別できませんでした。';

  @override
  String get diagWizOptionsNotLoaded => 'アカウントがエンジンに読み込まれていません';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return '$seconds秒以内にOPTIONSへの応答がありませんでした（トランスポート：$transport）';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'サーバーに到達できません。アドレスとポート、ファイアウォールがSIPを破棄していないかを確認し、別のトランスポート（TCP／TLS）を試してください。';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'リクエストがタイムアウトしました（$code $reason）';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'サーバーが $ms ms 後に $code $reason で応答しました';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'サーバーが $ms ms で $code $reason と応答しました';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'OPTIONSに対する $code は正常です。サーバーには到達できていますが、匿名のプローブは許可されていません。';
  }

  @override
  String get diagWizOptionsSlowFix =>
      '往復遅延が300 msを超えると、会話に目立つ遅れが生じます。より近いサーバーや有線接続が有効です。';

  @override
  String get diagWizTlsRejected => 'サーバー証明書が拒否されました';

  @override
  String diagWizTlsSubject(String value) {
    return 'サブジェクト：$value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return '発行者：$value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return '問題点：$value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return '有効期限：$date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return '暗号スイート：$cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      '自己署名証明書を使用した自社PBXで、上記のフィンガープリントが一致する場合は、信頼しても構いません。それ以外の場合は、プロバイダーに公的CAの証明書を依頼してください。';

  @override
  String get diagWizTlsTrust => 'この証明書を信頼';

  @override
  String diagWizTlsExpired(String date) {
    return '証明書は $date に期限切れになりました';
  }

  @override
  String get diagWizTlsExpiredFix => 'サーバー管理者に証明書の更新を依頼してください。';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '証明書の有効期限まであと$days日です',
      one: '証明書の有効期限まであと1日です',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix => 'サーバー管理者に、早めに更新するよう伝えてください。';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return '接続しましたが、検証で次の問題が報告されました：$problems';
  }

  @override
  String get diagWizTlsOk => 'TLS接続を確立しました。証明書は有効です';

  @override
  String get diagWizTlsRegistered => 'TLSで登録済みです（証明書の詳細は報告されていません）';

  @override
  String get diagWizTlsNone => 'TLS接続はまだ確認されていません';

  @override
  String get diagWizTlsNoneFix =>
      'TLSポート（通常は5061）と、サーバーがTLS 1.2以降を受け付けることを確認してください。';

  @override
  String get diagWizRegDisabledByConfig => 'このアカウントでは登録が無効です（ピアツーピア用）';

  @override
  String get diagWizRegRegistered => '登録済み';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return '登録済み（$seconds秒後に期限切れ）';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'トランスポート：$transport';
  }

  @override
  String get diagWizRegInProgress => '登録はまだ進行中です';

  @override
  String get diagWizRegInProgressFix =>
      '数秒待ってください。完了しない場合はサーバーが応答していません。上の到達性チェックを参照してください。';

  @override
  String get diagWizRegFailed => '登録に失敗しました';

  @override
  String get diagWizRegOffline => 'アカウントはオフラインです';

  @override
  String get diagWizRegOfflineFix => 'ネットワーク接続を確認してください。アプリは自動的に再試行します。';

  @override
  String get diagWizRegDisabled => 'アカウントは無効です';

  @override
  String get diagWizAlgNoUdp => 'UDPを使用するアカウントがないため、SIP ALGは問題になりません';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account：UDPでは応答がありませんでしたが、TCPでは応答がありました（$code、$ms ms）';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account：UDPでもTCPでも応答がありません（ALGではなく、サーバーまたはファイアウォールの問題）';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account：OPTIONSには応答がありますがREGISTERはタイムアウトします。ルーターがSIPを書き換えている場合の典型的な症状です';
  }

  @override
  String get diagWizAlgSuspected => 'ルーターのSIP ALGが疑われます';

  @override
  String get diagWizAlgSuspectedFix =>
      'ルーターの設定で「SIP ALG」／「SIPヘルパー」を無効にするか、アカウントをTCPまたはTLSに切り替えるか、SIPポートを変更（例：5080）して、ルーターがパケットを書き換えないようにしてください。';

  @override
  String get diagWizAlgContactChanged => 'リクエストと応答の間でContactアドレスが変更されました';

  @override
  String get diagWizAlgContactChangedFix =>
      'SIP ALG、またはContactを書き換えるサーバーが原因の可能性があります。呼び出しはできても音声がない、またはしばらくして切れる場合は、ルーターのSIP ALGを無効にするか、TCP/TLSまたはポート5080を使用してください。';

  @override
  String get diagWizAlgOk => 'SIP ALGによる干渉の兆候はありません';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTERのContact $sent が $received に変わって返ってきました';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '$fileName を保存';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName を保存しました';
  }

  @override
  String get diagSaveFailed => 'ファイルを保存できませんでした';

  @override
  String get diagCopiedText => 'テキストをクリップボードにコピーしました';

  @override
  String get diagCopiedReport => 'レポートをクリップボードにコピーしました';

  @override
  String get diagCopiedBundle => '診断バンドルをクリップボードにコピーしました';

  @override
  String get diagCopiedLogs => 'ログをクリップボードにコピーしました';

  @override
  String get diagCopiedTrace => 'トレースをクリップボードにコピーしました';

  @override
  String get diagCopiedDialog => 'ダイアログをクリップボードにコピーしました';

  @override
  String get diagSaveAsLog => '.logとして保存';

  @override
  String get diagSysAppVersion => 'アプリのバージョン';

  @override
  String get diagSysPlatform => 'プラットフォーム';

  @override
  String get diagSysEngine => 'エンジン';

  @override
  String get diagSysAccounts => 'アカウント';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$total件中$registered件が登録済み';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'システム情報を読み取れませんでした：$error';
  }

  @override
  String get diagSysTransports => 'トランスポート';

  @override
  String get diagSysNoneReported => '報告なし';

  @override
  String get diagSysCodecs => 'コーデック';

  @override
  String get diagSysCodecsFooter => '有効なコーデックを優先度の高い順に表示しています。';

  @override
  String get diagSysEngineNotRunning => 'エンジンが動作していません';

  @override
  String diagSysCodecPriority(int priority) {
    return '優先度 $priority';
  }

  @override
  String get diagSysCodecDisabled => '無効';

  @override
  String get diagSysExport => 'エクスポート';

  @override
  String get diagSysExportFooter =>
      'バンドルには、システム情報、ネットワークチェックの結果、最近のログ、SIPトレースが含まれます。認証情報は伏せ字になります。';

  @override
  String get diagSysCopyBundle => '診断バンドルをコピー';

  @override
  String get diagSysSaveBundle => '診断バンドルを保存';

  @override
  String get diagTabSipTrace => 'SIPトレース';

  @override
  String get diagTabNetwork => 'ネットワーク';

  @override
  String get diagTabQuality => '品質';

  @override
  String get diagTabAudioTest => '音声テスト';

  @override
  String get diagTabLogs => 'ログ';

  @override
  String get diagTabSystem => 'システム';

  @override
  String diagRawSentTo(String remote) {
    return '$remote に送信';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return '$remote から受信';
  }

  @override
  String get diagRawCopied => 'メッセージをコピーしました';

  @override
  String get diagRawLadder => 'ラダー';

  @override
  String get diagRawRedact => '認証情報を伏せる';

  @override
  String diagRawTruncated(int count) {
    return '... 省略（$count文字）';
  }

  @override
  String get diagWizIntro => '接続、DNS、NAT、サーバーへの到達性、TLS、登録を確認し、修正すべき点を説明します。';

  @override
  String get diagWizStop => '停止';

  @override
  String get diagWizRunChecks => 'チェックを実行';

  @override
  String get diagWizRunAgain => 'もう一度実行';

  @override
  String get diagWizCopyReport => 'レポートをコピー';

  @override
  String get diagWizSaveReport => 'レポートを保存';

  @override
  String diagWizCountPassed(int count) {
    return '合格 $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return '警告 $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return '失敗 $count';
  }

  @override
  String get diagWizStatusPass => '合格';

  @override
  String get diagWizStatusWarn => '警告';

  @override
  String get diagWizStatusFail => '失敗';

  @override
  String get diagWizStatusSkipped => 'スキップ';

  @override
  String get diagWizStatusRunning => '実行中';

  @override
  String get diagWizStatusPending => '待機中';

  @override
  String get diagQualityTitle => '通話品質';

  @override
  String get diagQualityNoData => 'この通話の品質データは記録されていません。';

  @override
  String get diagQualityTraceForCall => 'この通話のSIPトレース';

  @override
  String get diagQualityTraceNotCaptured => 'この通話のSIPトレースは記録されていません';

  @override
  String get diagQualityLiveCall => '通話中';

  @override
  String get diagQualityNoActiveCall =>
      '通話中ではありません。通話を開始すると、MOS、ジッター、損失、往復遅延がここにリアルタイムで表示されます。';

  @override
  String get diagQualityRecentCalls => '最近の通話';

  @override
  String get diagQualityNoFinished => '品質データのある終了済みの通話はまだありません。';

  @override
  String get diagQualityCallEnded => '通話は終了しました。';

  @override
  String get diagQualityMeasuring => '測定中';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value、$quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return '$titleのグラフ';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return '$titleのグラフ、最新 $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   最大 $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return '平均 $avg  ·  最悪 $worst';
  }

  @override
  String get diagQualityCodec => 'コーデック';

  @override
  String get diagQualityLoss => '損失';

  @override
  String get diagQualityJitter => 'ジッター';

  @override
  String diagQualityPackets(int count) {
    return '$count パケット';
  }

  @override
  String get diagQualityMedia => 'メディア';

  @override
  String get diagQualityNoSeries => 'この通話の時系列データは記録されていません。';

  @override
  String get diagQualityPacketLoss => 'パケット損失';

  @override
  String get diagQualityRtt => '往復遅延';

  @override
  String get diagLogsForward => 'エンジンログを転送';

  @override
  String get diagLogsForwardSub => 'pjsipのログ行をこのビューアーに送信します';

  @override
  String diagLogsLevel(int level, String name) {
    return 'レベル $level（$name）';
  }

  @override
  String get diagLogsRedact => 'エクスポート時に伏せる';

  @override
  String get diagLogsSearch => 'ログを検索';

  @override
  String get diagLogsEmpty => 'ログ行はまだありません。';

  @override
  String get diagLogsForwardingOff => 'ログの転送がオフです。エンジンログを取得するにはオンにしてください。';

  @override
  String get diagLogsNoMatch => '検索に一致する行がありません。';

  @override
  String get diagAudioEngineNotRunning => 'SIPエンジンが動作していません。';

  @override
  String get diagAudioMicrophone => 'マイク';

  @override
  String get diagAudioMicFooter =>
      'レベルメーターは、通話中またはエコーテスト中にエンジンが開くオーディオデバイスの入力を表示します。';

  @override
  String get diagAudioLevelMeter => 'レベルメーター';

  @override
  String get diagAudioLevelMeterSub => '話しかけてバーの動きを確認します';

  @override
  String get diagAudioMic => 'マイク';

  @override
  String get diagAudioSpeaker => 'スピーカー';

  @override
  String get diagAudioEchoTest => 'エコーテスト';

  @override
  String get diagAudioEchoFooter =>
      'あなたの声をスピーカーから再生します。ハウリングを防ぐため、ヘッドフォンを使用してください。';

  @override
  String get diagAudioEchoActive => '実行中：話してください';

  @override
  String get diagAudioEchoIdle => 'マイクからスピーカーへのループバック';

  @override
  String get diagAudioSpeakerTest => 'スピーカーテスト';

  @override
  String get diagAudioPlayTone => 'テスト音を再生';

  @override
  String get diagAudioPlayToneSub => '選択したスピーカーから再生します';

  @override
  String get diagAudioPlayingDtmf => 'DTMFを再生中';

  @override
  String get diagAudioPlayingRingback => '呼び出し音を再生中';

  @override
  String get diagAudioRingback => '呼び出し音';

  @override
  String get diagAudioDevices => 'デバイス';

  @override
  String get diagAudioChooseDevices => 'マイクとスピーカーを選択';

  @override
  String get diagAudioChooseDevicesSub => '設定 > オーディオ を開きます';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$labelのレベル $percent パーセント';
  }

  @override
  String get diagLadderLocal => 'ローカル';

  @override
  String diagLadderSent(String message) {
    return '$message を送信';
  }

  @override
  String diagLadderReceived(String message) {
    return '$message を受信';
  }

  @override
  String get diagTraceCapture => 'SIPメッセージを取得';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のメッセージ',
      one: '1件のメッセージ',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のメッセージ',
      one: '1件のメッセージ',
    );
    return '$_temp0  ·  $size  ·  古い$dropped件を破棄';
  }

  @override
  String get diagTraceOffHint => 'オフです。オンにしてから、登録または発信してください。';

  @override
  String get diagTraceExportOrClear => 'エクスポートまたはクリア';

  @override
  String get diagTraceSaveAsPcap => '.pcapとして保存';

  @override
  String get diagTraceCopyAsText => 'テキストとしてコピー';

  @override
  String get diagTraceSearchHint => 'テキスト、番号、Call-IDを検索';

  @override
  String get diagTraceErrorsOnly => 'エラーのみ';

  @override
  String get diagTraceFilterMethod => 'メソッドで絞り込み';

  @override
  String get diagTraceAllMethods => 'すべてのメソッド';

  @override
  String get diagTraceMethod => 'メソッド';

  @override
  String get diagTraceFilterAccount => 'アカウントで絞り込み';

  @override
  String get diagTraceAllAccounts => 'すべてのアカウント';

  @override
  String get diagTraceAccount => 'アカウント';

  @override
  String get diagTraceRedact => '伏せる';

  @override
  String get diagTraceList => 'リスト';

  @override
  String get diagTraceWaiting => 'SIP通信を待機中';

  @override
  String get diagTraceWaitingSub => 'アカウントを登録するか発信すると、メッセージがここに表示されます。';

  @override
  String get diagTraceOff => 'SIPトレースはオフです';

  @override
  String get diagTraceOffSub =>
      '取得をオンにすると、すべてのSIPリクエストとレスポンスを、リストまたはラダー図で確認できます。';

  @override
  String get diagTraceNoMatch => 'フィルターに一致するメッセージがありません';

  @override
  String get diagTraceAllDialogs => 'すべてのダイアログ';

  @override
  String get diagTraceCopyDialog => 'このダイアログをコピー';

  @override
  String get diagTraceNoResponse => '応答なし';

  @override
  String get diagTraceNoCallId => 'Call-IDなし';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のメッセージ',
      one: '1件のメッセージ',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => '録音';

  @override
  String get recFormatWav => '標準（WAV）';

  @override
  String get recFormatWavStereo => 'ステレオ（自分と相手を別チャンネルに録音、WAV）';

  @override
  String get recFormatOpus => '圧縮（Opus）';

  @override
  String get recFormatWavHint => 'モノラルで、1分あたり約2 MB。どこでも再生できます。';

  @override
  String get recFormatWavStereoHint => '2チャンネルで、1分あたり約4 MB。左が自分、右が相手です。';

  @override
  String get recFormatOpusHint =>
      '1分あたり約0.2 MB。Ogg Opus形式のため、iPhone、Mac、Windowsの一部のプレーヤーでは開けません。';

  @override
  String get recOptionInherit => '全体設定を使用';

  @override
  String get recOptionAlways => 'すべての通話を録音';

  @override
  String get recOptionIncoming => '着信のみ録音';

  @override
  String get recOptionOutgoing => '発信のみ録音';

  @override
  String get recOptionNever => '録音しない';

  @override
  String get recRuleAll => 'すべての通話';

  @override
  String get recRuleIncoming => '着信のみ';

  @override
  String get recRuleOutgoing => '発信のみ';

  @override
  String get recAutoDeleteNever => 'しない';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日後',
      one: '1日後',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => '1年後';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '録音$count件',
      one: '録音1件',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '録音$count件',
      one: '録音1件',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '録音$count件',
      one: '録音1件',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日後',
      one: '1日後',
    );
    return '$_temp0  ·  $size  ·  $_temp1に自動削除';
  }

  @override
  String get recSettingsFormat => '形式';

  @override
  String get recSettingsAutoGroup => '自動録音';

  @override
  String get recSettingsAutoFooter =>
      '通話を録音する前に、お住まいの地域の法律を確認してください。連絡先の「この連絡先との通話を常に録音」をオンにすると、これらのルールにかかわらず録音されます。';

  @override
  String get recSettingsAutoRule => '通話を自動で録音';

  @override
  String get recSettingsAccountOverride => 'このアカウントの個別設定';

  @override
  String get recSettingsNoticesGroup => 'お知らせ';

  @override
  String get recSettingsNoticeSwitch => '録音前にお知らせを再生';

  @override
  String get recSettingsNoticeSwitchHint =>
      '先に相手へお知らせを再生します。お知らせのファイルは 設定 > 通話 > アナウンス で選択します。';

  @override
  String get recSettingsNoticeFile => 'お知らせのファイルを選択';

  @override
  String get recSettingsNoticeFileHint => '設定 > 通話 > アナウンス を開きます';

  @override
  String get recSettingsBeep => '録音中のビープ音';

  @override
  String get recSettingsBeepHint => '相手に定期的に知らせます';

  @override
  String get recSettingsTransfersGroup => '転送';

  @override
  String get recSettingsContinue => '転送をまたいで録音を継続';

  @override
  String get recSettingsContinueHint => '確認転送の確認通話と、転送されてきた通話を録音し、録音同士を関連付けます';

  @override
  String get recSettingsStorageGroup => '保存先';

  @override
  String get recSettingsFolder => 'フォルダ';

  @override
  String get recSettingsFolderHint => '録音の保存先';

  @override
  String get recSettingsFolderPlaceholder => 'アプリのドキュメント / Recordings';

  @override
  String get recSettingsChooseFolder => 'フォルダを選択...';

  @override
  String get recSettingsFolderPickerTitle => '録音フォルダ';

  @override
  String get recSettingsAutoDelete => '古い録音を削除';

  @override
  String get recSettingsAutoDeleteHint => '起動時と1日1回確認します';

  @override
  String get recSettingsManage => '録音を管理';

  @override
  String get recSettingsOpenFolder => '録音フォルダを開く';

  @override
  String get recPageTitle => '録音';

  @override
  String recSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String get recCancelSelection => '選択を解除';

  @override
  String get recSelectAll => 'すべて選択';

  @override
  String get recShareSelected => '選択した録音を共有';

  @override
  String get recDeleteSelected => '選択した録音を削除';

  @override
  String get recSearchTooltip => '録音を検索';

  @override
  String get recSelectTooltip => '録音を選択';

  @override
  String get recMenuSettings => '録音設定';

  @override
  String get recSearchHint => '名前または番号を検索';

  @override
  String get recEmptyNone => '録音はまだありません';

  @override
  String get recEmptyNoneHint => '録音ボタンで通話を録音するか、設定で自動録音をオンにしてください。';

  @override
  String get recEmptyNoMatch => '一致する録音がありません';

  @override
  String get recEmptyNoMatchHint => '別の検索条件やフィルターをお試しください。';

  @override
  String get recClearFilters => 'フィルターをクリア';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '録音$count件を削除しますか？',
      one: '録音1件を削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage => '音声ファイルはこのデバイスから削除されます。この操作は元に戻せません。';

  @override
  String get recDeleteOneTitle => 'この録音を削除しますか？';

  @override
  String get recDeleteOneMessage => '音声ファイルはこのデバイスから削除されます。この操作は元に戻せません。';

  @override
  String get recFilterAll => 'すべて';

  @override
  String get recFilterIncoming => '着信';

  @override
  String get recFilterOutgoing => '発信';

  @override
  String get recFilterByAccount => 'アカウントで絞り込み';

  @override
  String get recFilterAllAccounts => 'すべてのアカウント';

  @override
  String get recFilterAccountFallback => 'アカウント';

  @override
  String get recFilterAnyDate => 'すべての日付';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => '日付をクリア';

  @override
  String get recMissingFile => '音声ファイルがこのデバイスにありません。';

  @override
  String recRelated(String title) {
    return '関連：$title';
  }

  @override
  String get recRenameTitle => '録音の名前を変更';

  @override
  String get recRenameHint => '名前';

  @override
  String get recSaveAs => '名前を付けて保存...';

  @override
  String get recShowInFinder => 'Finderで表示';

  @override
  String get recShowInFolder => 'フォルダで表示';

  @override
  String get recViewCall => '通話を表示';

  @override
  String recSavedTo(String path) {
    return '$path に保存しました';
  }

  @override
  String get recSaveFailed => '録音を保存できませんでした';

  @override
  String get recShareFailed => '録音を共有できませんでした';

  @override
  String get recSaveDialogTitle => '録音を保存';

  @override
  String get recShareSubject => '通話の録音';

  @override
  String get recPlayerUnsupported => 'このデバイスではOpusの録音を再生できません。';

  @override
  String get recPlayerOpenWith => '別のアプリで開く...';

  @override
  String get recPlayerNotFound => '録音ファイルが見つかりません';

  @override
  String recPlayerCannotPlay(String error) {
    return 'この録音を再生できません：$error';
  }

  @override
  String get recPlayerPlay => '録音を再生';

  @override
  String get recPlayerPause => '録音を一時停止';

  @override
  String get audioFilesTitle => 'オーディオファイル';

  @override
  String audioAdded(String name) {
    return '「$name」を追加しました';
  }

  @override
  String get audioFileUnavailable => 'そのファイルは利用できません。';

  @override
  String get audioNameRequired => '名前を入力してください';

  @override
  String audioDeleteTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get audioDeleteMessage => 'このファイルを使用している設定は、デフォルトに戻ります。';

  @override
  String get audioGroupAdd => '追加';

  @override
  String get audioAddFooter =>
      'WAV（PCM、μ-law、A-law）とMP3ファイルを使用できます。ファイルはアプリ内にコピーされるため、元のファイルを移動しても問題ありません。';

  @override
  String get audioImport => 'WAVまたはMP3をインポート…';

  @override
  String get audioGroupMine => 'マイファイル';

  @override
  String get audioEmptyTitle => 'ファイルはまだありません';

  @override
  String get audioEmptyHint => 'ファイルをインポートするか、自分のアナウンスを録音してください。';

  @override
  String get audioGroupBuiltIn => '内蔵';

  @override
  String get audioBuiltInFooter => 'SoftphonePro用に作成された、無料で使えるサウンドです。';

  @override
  String get audioPreviewStop => 'プレビューを停止';

  @override
  String audioPreviewPlay(String name) {
    return '$name をプレビュー';
  }

  @override
  String get audioRecordedName => 'この録音に名前を付ける';

  @override
  String get audioRecordedDefaultName => 'マイアナウンス';

  @override
  String audioSaved(String name) {
    return '「$name」を保存しました';
  }

  @override
  String get audioRecorderStop => '停止';

  @override
  String get audioRecorderPlay => '録音を再生';

  @override
  String audioRecorderNew(String duration) {
    return '新しい録音  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => '破棄';

  @override
  String get audioRecordOwn => '自分で録音…';

  @override
  String get audioRecordOwnHint => 'オーディオ設定で選択したマイクを使用します';

  @override
  String get audioMissingFile => 'ファイルが見つかりません';

  @override
  String get audioBuiltInCalm => '穏やか（内蔵）';

  @override
  String get audioBuiltInBreeze => 'そよ風（内蔵）';

  @override
  String get audioBuiltInChime => 'お知らせチャイム（内蔵）';

  @override
  String get audioErrOnlyWavMp3 => '使用できるのはWAVとMP3ファイルのみです。';

  @override
  String get audioErrNotFound => 'そのファイルが見つかりませんでした。';

  @override
  String get audioErrNotSaved => '録音は保存されませんでした。';

  @override
  String get audioErrEmpty => 'この音声ファイルは空か、読み取れません。';

  @override
  String audioErrUnusable(String reason) {
    return 'この音声ファイルは使用できません（$reason）。PCM、μ-law、A-lawのWAV、またはMP3を使用してください。';
  }

  @override
  String get audioRecEngineOff => '通話エンジンが動作していません。';

  @override
  String get audioRecUnsupported => 'このバージョンの通話エンジンでは、マイクを録音できません。';

  @override
  String audioRecStartFailed(String reason) {
    return '録音を開始できませんでした：$reason';
  }

  @override
  String audioRecFailed(String reason) {
    return '録音に失敗しました：$reason';
  }

  @override
  String get audioStrengthLow => '弱';

  @override
  String get audioStrengthMedium => '中';

  @override
  String get audioStrengthHigh => '強';

  @override
  String get audioStrengthMax => '最大';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label（$percent%）';
  }

  @override
  String get audioSystemDefault => 'システムの設定';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'システムの設定（$name）';
  }

  @override
  String get voiceTitle => '音声分離';

  @override
  String get voiceUnavailable =>
      'このビルドの通話エンジンでは、AIノイズキャンセルを利用できません。音声処理の標準のノイズ抑制は引き続き使用できます。';

  @override
  String get voiceGroupAi => 'AIノイズキャンセル';

  @override
  String get voiceAiFooter =>
      'デバイス上のニューラルネットワーク（RNNoise）を使って、キーボードのクリック音、ファンの音、背景の話し声を通話から除去します。データがデバイスの外に出ることはありません。強度を上げるとより多くのノイズを除去できますが、語頭が欠ける場合があります。';

  @override
  String get voiceMic => '自分のマイク';

  @override
  String get voiceMicHint => '相手に聞こえる音声をクリーンにします';

  @override
  String get voiceOthers => '他の参加者';

  @override
  String get voiceOthersHint => 'ノイズの多い相手の音声をクリーンにします';

  @override
  String voiceStrength(String value) {
    return '強度：$value';
  }

  @override
  String get voiceGroupTry => '試してみる';

  @override
  String get voiceTryFooter => 'エコーテストにはヘッドフォンを使用してください。使用しないとハウリングが発生します。';

  @override
  String get voiceEchoTest => 'エコーでテスト';

  @override
  String get voiceEchoTestHint => '処理後のマイクの音声を再生します';

  @override
  String get voiceEchoFailed => 'エコーテストに失敗しました';

  @override
  String get voiceGroupSystem => 'システム';

  @override
  String get voiceSystemFooter =>
      'macOSとiOSでは、すべてのアプリで音声を分離することもできます。システムのマイクモードで「声を分離」を選択してください。';

  @override
  String get voiceSystemMode => 'システムのマイクモード（声を分離）…';

  @override
  String get voiceSystemModeUnsupported => 'マイクモードにはmacOS 12またはiOS 15以降が必要です。';

  @override
  String get voiceSpeechDetection => '音声検出';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent パーセント';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Androidのオーディオエフェクト';

  @override
  String get voiceAndroidFooter =>
      '端末側でもマイクの音声を補正している場合があります。これらはAndroidが報告する情報で、上の設定とは別です。';

  @override
  String get voiceAndroidNs => 'ノイズ抑制';

  @override
  String get voiceAndroidAec => 'エコーキャンセラー';

  @override
  String get voiceNotAvailableDevice => 'このデバイスでは利用できません';

  @override
  String get callLinkNotLocal => 'この種類のリンクは、このコンピューターのコマンドラインからのみ使用できます。';

  @override
  String linkLanConnectTitle(String name) {
    return 'デバイス $name に接続しますか？';
  }

  @override
  String get linkLanConnectBody =>
      '他のアプリまたはウェブページからのリンクが、SoftphoneProをこのデバイスに接続しようとしています。心当たりがある場合のみ接続してください。';

  @override
  String get linkLanConnectAction => '接続';

  @override
  String get linkImportSensitiveHeader => 'この設定に含まれる重要な変更:';

  @override
  String get linkImportFlagAutoAnswer => '着信に自動で応答します';

  @override
  String linkImportFlagForwarding(String target) {
    return '通話を $target に転送します';
  }

  @override
  String get linkImportFlagIntercom => 'インターコムの開始や通話の引き取りを許可する相手を変更します（LAN）';

  @override
  String get linkImportFlagDialRewrite => 'ダイヤルする番号を書き換えます';

  @override
  String get linkImportFlagLinksImmediately => 'ウェブリンクからの発信が確認なしですぐに始まります';

  @override
  String get linkImportFlagDiagnostics => '詳細ログまたはSIPトレースを有効にします';

  @override
  String get linkImportAllowAutoAnswer => 'インポートしたアカウントの自動応答を許可する';

  @override
  String linkImportRefused(String setting) {
    return 'このインポートは「$setting」を変更しようとしていますが、リンク、QR コード、貼り付けたテキスト、ファイルでは設定できません。代わりにこのコンピューターで --provision コマンドラインオプションを使用してください。何もインポートされませんでした。';
  }

  @override
  String get lanPairIntercomNote =>
      'ペアリング済みのデバイスはインターコム通話を要求できます。毎回確認が表示されます（設定 > LAN で変更できます）。';

  @override
  String get callLinkUnsupportedScheme => 'この種類のリンクはサポートされていません。';

  @override
  String get linkImportFlagAutoRecord => '通話を自動的に録音します';

  @override
  String get linkImportFlagBlocklist => '通話ブロックリストを変更します';

  @override
  String get linkImportFlagEmergency => '緊急番号を変更します';

  @override
  String get linkImportFlagSpeedDial => '短縮ダイヤル番号を設定します';

  @override
  String get linkImportFlagRecordingDelete => '古い録音を自動的に削除します';

  @override
  String get linkImportFlagFeatureCodes => 'カスタム PBX 機能コードをダイヤルします';

  @override
  String get linkImportAllowAutoRecord => '通話の自動録音を許可する';

  @override
  String get importIgnoredHeader => '無視されました（インポートでは許可されていません）：';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name（$address）- サーバー $server、$transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'プロキシ：$proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN リレー：$server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'カスタム SIP ヘッダー：$headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return '発信者番号：$callerId';
  }

  @override
  String get importAccountSrtpOff => 'メディア暗号化なし（SRTP オフ）';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'アドレス：$host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return '既存の $updated 件を更新し、新しい $added 件を追加';
  }
}
