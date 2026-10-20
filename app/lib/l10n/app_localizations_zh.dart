// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get languagePickerHint => '语言名称以其自身语言显示。';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String get actionClose => '关闭';

  @override
  String get actionOk => '确定';

  @override
  String get actionRetry => '重试';

  @override
  String get actionDone => '完成';

  @override
  String get actionAdd => '添加';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionRename => '重命名';

  @override
  String get actionClear => '清除';

  @override
  String get actionBack => '返回';

  @override
  String get actionCopy => '复制';

  @override
  String get actionShare => '分享';

  @override
  String get actionImport => '导入';

  @override
  String get actionExport => '导出';

  @override
  String get actionDetails => '详情';

  @override
  String get actionMore => '更多';

  @override
  String get actionSettings => '设置';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionRefresh => '刷新';

  @override
  String get actionContinue => '继续';

  @override
  String get actionYes => '是';

  @override
  String get actionNo => '否';

  @override
  String get commonOn => '开';

  @override
  String get commonOff => '关';

  @override
  String get commonNone => '无';

  @override
  String get commonDefault => '默认';

  @override
  String get commonSystem => '系统';

  @override
  String get commonAutomatic => '自动';

  @override
  String get commonUnknown => '未知';

  @override
  String get commonNotSet => '未设置';

  @override
  String get commonError => '错误';

  @override
  String get commonLoading => '正在加载…';

  @override
  String get statusAvailable => '空闲';

  @override
  String get statusDoNotDisturb => '免打扰';

  @override
  String get statusOffline => '离线';

  @override
  String get statusOnACall => '通话中';

  @override
  String get settingsEntryAccounts => '账户';

  @override
  String get settingsEntryAccountsSub => 'SIP 账户与注册';

  @override
  String get settingsEntryAudio => '音频';

  @override
  String get settingsEntryAudioSub => '设备、音量、回声消除';

  @override
  String get settingsEntryCodecs => '编解码器';

  @override
  String get settingsEntryCodecsSub => '顺序、可用性、Opus';

  @override
  String get settingsEntryCalls => '通话';

  @override
  String get settingsEntryCallsSub => '免打扰、呼叫等待、自动接听、拨号规则';

  @override
  String get settingsEntryNetwork => '网络';

  @override
  String get settingsEntryNetworkSub => '传输协议、STUN、TLS、DNS';

  @override
  String get settingsEntryRecording => '录音';

  @override
  String get settingsEntryNotifications => '通知与铃声';

  @override
  String get settingsEntryShortcuts => '快捷键';

  @override
  String get settingsEntryShortcutsSub => '全局热键、应用内按键';

  @override
  String get settingsEntryAppearance => '外观';

  @override
  String get settingsEntryPrivacy => '隐私与安全';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => '自动配置';

  @override
  String get settingsEntryProvisioningSub => '导入、导出、二维码';

  @override
  String get settingsEntryDiagnostics => '诊断';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP 跟踪、网络检查';

  @override
  String get settingsEntryAdvanced => '高级';

  @override
  String get settingsEntryAbout => '关于';

  @override
  String get settingsAccountsEmptyTitle => '添加您的第一个账户';

  @override
  String get settingsAccountsEmptySubtitle => '连接到您的 PBX 或 SIP 服务商，即可开始通话。';

  @override
  String get settingsAccountsAdd => '添加账户';

  @override
  String get settingsAccountsYourAccounts => '您的账户';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  使用备用服务器';
  }

  @override
  String get settingsAudioDevices => '设备';

  @override
  String get settingsAudioMicrophone => '麦克风';

  @override
  String get settingsAudioSpeaker => '扬声器';

  @override
  String get settingsAudioRinger => '响铃设备';

  @override
  String get settingsAudioRingerSub => '在单独的设备上播放铃声';

  @override
  String get settingsAudioRefreshDevices => '刷新设备';

  @override
  String get settingsAudioLevelsAndTest => '音量与测试';

  @override
  String get settingsAudioMicVolume => '麦克风音量';

  @override
  String get settingsAudioMicLevel => '麦克风电平';

  @override
  String get settingsAudioSpeakerVolume => '扬声器音量';

  @override
  String get settingsAudioSpeakerLevel => '扬声器电平';

  @override
  String get settingsAudioTestSpeaker => '测试扬声器';

  @override
  String get settingsAudioTestSpeakerSub => '通过所选扬声器播放一段短音';

  @override
  String get settingsAudioTestToneFailed => '无法播放测试音';

  @override
  String get settingsAudioEchoTestFailed => '回声测试失败';

  @override
  String get settingsAudioEchoTest => '回声测试';

  @override
  String get settingsAudioEchoTestSub => '将您的麦克风声音通过扬声器回放。请使用耳机以避免啸叫。';

  @override
  String get settingsAudioVoiceAndFiles => '语音与文件';

  @override
  String get settingsAudioVoiceIsolation => '人声隔离（AI 降噪）';

  @override
  String get settingsAudioAudioFiles => '音频文件';

  @override
  String get settingsAudioAudioFilesSub => '保持音乐与提示音';

  @override
  String get settingsAudioProcessing => '音频处理';

  @override
  String get settingsAudioEchoCancellation => '回声消除';

  @override
  String get settingsAudioEcSimple => '简单';

  @override
  String get settingsAudioEcPlatform => '系统';

  @override
  String get settingsAudioEchoTail => '回声尾长';

  @override
  String get settingsAudioNoiseSuppression => '噪声抑制';

  @override
  String get settingsAudioAgc => '自动增益控制';

  @override
  String get settingsAudioVad => '语音活动检测';

  @override
  String get settingsAudioVadSub => '静音时节省带宽';

  @override
  String get settingsAudioAdvanced => '高级';

  @override
  String get settingsAudioAdvancedFooter =>
      '抖动缓冲值以毫秒为单位；-1 表示使用引擎默认值。更改这些设置将重启通话引擎。';

  @override
  String get settingsAudioPtime => '包时长（ptime）';

  @override
  String get settingsAudioJbInitial => '抖动缓冲：初始值';

  @override
  String get settingsAudioJbMinPrefetch => '抖动缓冲：最小预取';

  @override
  String get settingsAudioJbMaxPrefetch => '抖动缓冲：最大预取';

  @override
  String get settingsAudioJbMaxSize => '抖动缓冲：最大大小';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return '麦克风$strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return '对方$strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent%';
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
      other: '$count 秒',
      one: '1 秒',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => '顺序与可用性';

  @override
  String get settingsCodecsDragHint => '拖动以重新排序。各账户可在其自身设置中覆盖此列表。';

  @override
  String get settingsCodecsBitrate => '比特率';

  @override
  String get settingsCodecsFec => '带内 FEC';

  @override
  String get settingsCodecsFecSub => '从丢包中恢复';

  @override
  String get settingsCodecsDtxSub => '静音时停止发送';

  @override
  String get settingsCodecsCbr => '恒定比特率';

  @override
  String get settingsCodecsComplexity => '复杂度';

  @override
  String get settingsCallsIncoming => '来电';

  @override
  String get settingsCallsDndSub => '拒绝所有来电';

  @override
  String get settingsCallsRejectWith => '拒绝方式';

  @override
  String get settingsCallsReasonBusy => '此处忙（486）';

  @override
  String get settingsCallsReasonUnavailable => '暂时无法接通（480）';

  @override
  String get settingsCallsReasonDecline => '拒绝（603）';

  @override
  String get settingsCallsWaiting => '呼叫等待';

  @override
  String get settingsCallsWaitingSub => '通话期间允许第二个来电';

  @override
  String get settingsCallsWhenBusy => '忙线且呼叫等待关闭时';

  @override
  String get settingsCallsRejectAnonymous => '拒绝匿名来电';

  @override
  String get settingsCallsLinksImmediately => '立即拨打链接号码';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'tel:、sip: 和 callto: 链接将直接拨出，无需在拨号盘中等待';

  @override
  String get settingsCallsSyncFeatureCodes => '通过功能码将免打扰/呼叫转移同步到 PBX';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      '更改免打扰或呼叫转移时，短暂拨打账户的星号功能码（例如 *78）';

  @override
  String get settingsCallsAutoAnswerGroup => '自动接听';

  @override
  String get settingsCallsAutoAnswerFooter => '呼叫转移和各账户的自动接听需在对应账户中设置。';

  @override
  String get settingsCallsAutoAnswerAll => '自动接听所有来电';

  @override
  String get settingsCallsAnswerAfter => '接听延迟';

  @override
  String get settingsCallsAnswerImmediately => '立即';

  @override
  String get settingsCallsIntercomHeaders => '遵循对讲头信息';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Call-Info、Alert-Info 和 Answer-Mode 自动接听提示';

  @override
  String get settingsCallsBlocked => '已屏蔽号码';

  @override
  String get settingsCallsBlockNumber => '屏蔽号码';

  @override
  String get settingsCallsBlockNumberTitle => '屏蔽号码';

  @override
  String get settingsCallsBlockNumberHint => '号码或 SIP 地址';

  @override
  String get settingsCallsSpeedDial => '快速拨号';

  @override
  String get settingsCallsDialPlan => '拨号方案';

  @override
  String get settingsCallsDialRules => '拨号规则';

  @override
  String get settingsCallsStripPrefix => '需去除的外线前缀';

  @override
  String get settingsCallsStripPrefixSub => '例如 9，将从所拨号码开头去除';

  @override
  String get settingsCallsPlusReplacement => '将开头的 + 替换为';

  @override
  String get settingsCallsPlusReplacementSub => '例如 00 作为国际长途冠码';

  @override
  String get settingsCallsPlusReplacementHint => '保留 +';

  @override
  String get settingsCallsCountryPrefix => '默认国家区号';

  @override
  String get settingsCallsCountryPrefixSub => '以 0 开头的国内号码将加上此前缀，例如 +44';

  @override
  String get settingsCallsEmergency => '紧急号码';

  @override
  String get settingsCallsEmergencySub => '以逗号分隔。这些号码不受拨号规则影响。';

  @override
  String settingsCallsUnblock(String number) {
    return '取消屏蔽 $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '已分配 $count/9';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条规则',
      one: '1 条规则',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => '新建拨号规则';

  @override
  String get settingsDialRulesEdit => '编辑拨号规则';

  @override
  String get settingsDialRulesName => '名称';

  @override
  String get settingsDialRulesPattern => '匹配模式（正则）';

  @override
  String get settingsDialRulesReplacement => '替换为';

  @override
  String get settingsDialRulesReplacementHelp => '用 \$1、\$2 表示分组';

  @override
  String get settingsDialRulesRoute => '通过账户拨出';

  @override
  String get settingsDialRulesAdd => '添加规则';

  @override
  String get settingsDialRulesLiveTest => '实时测试';

  @override
  String get settingsDialRulesTyped => '输入的号码';

  @override
  String get settingsDialRulesNothing => '（空）';

  @override
  String get settingsDialRulesEmergency => '紧急号码：按输入原样拨出';

  @override
  String get settingsDialRulesAccountFallback => '账户';

  @override
  String get settingsDialRulesEmpty =>
      '暂无规则。号码会先被清理（去除空格、短横线、括号），然后按输入拨出。规则自上而下执行，首个匹配的规则生效。';

  @override
  String get settingsDialRulesDelete => '删除规则';

  @override
  String get settingsDialRulesDeleteTitle => '删除规则？';

  @override
  String settingsDialRulesVia(String account) {
    return '经由 $account';
  }

  @override
  String get settingsNetworkTransports => '传输协议';

  @override
  String get settingsNetworkTransportsFooter =>
      '端口 0 表示随机选取空闲端口。更改传输协议将重启通话引擎。';

  @override
  String get settingsNetworkUdpPort => 'UDP 端口';

  @override
  String get settingsNetworkTcpPort => 'TCP 端口';

  @override
  String get settingsNetworkTlsPort => 'TLS 端口';

  @override
  String get settingsNetworkVerifyCerts => '验证服务器证书';

  @override
  String get settingsNetworkVerifyCertsSub => '仅在使用自签名 PBX 时关闭，或在下方固定证书';

  @override
  String get settingsNetworkCustomCa => '自定义 CA 文件';

  @override
  String get settingsNetworkCustomCaSub => '用于替代内置列表的 PEM 证书包（私有 PBX 的 CA）';

  @override
  String get settingsNetworkCustomCaHint => '内置 Mozilla 列表';

  @override
  String get settingsNetworkPins => '固定的证书';

  @override
  String get settingsNetworkPinsSub => '主机=SHA256 指纹，以逗号分隔';

  @override
  String get settingsNetworkNat => 'NAT 穿透';

  @override
  String get settingsNetworkStun => 'STUN 服务器';

  @override
  String get settingsNetworkStunSub => '主机:端口，以逗号分隔';

  @override
  String get settingsNetworkIceTurn => 'ICE 和 TURN';

  @override
  String get settingsNetworkIceTurnSub => '在各账户的 NAT 设置中配置';

  @override
  String get settingsNetworkAdvanced => '高级';

  @override
  String get settingsNetworkQos => 'QoS（DSCP 标记）';

  @override
  String get settingsNetworkQosSub => '为 SIP 和语音数据包标记优先级';

  @override
  String get settingsNetworkDns => 'DNS 服务器';

  @override
  String get settingsNetworkDnsSub => '留空则自动获取';

  @override
  String get settingsNetworkRtpStart => 'RTP 起始端口';

  @override
  String get settingsNetworkRtpRange => 'RTP 端口范围';

  @override
  String get settingsNetworkRtpRangeSub => '0 表示使用默认值';

  @override
  String get settingsNotifRingtone => '铃声';

  @override
  String get settingsNotifDefaultRingtone => '默认铃声';

  @override
  String get settingsNotifProgressTones => '呼叫进度音';

  @override
  String get settingsNotifProgressTonesSub => '拨号时的回铃音、忙音和拥塞音';

  @override
  String get settingsNotifRingerVolume => '铃声音量';

  @override
  String get settingsNotifCustomRingtone => '自定义铃声文件';

  @override
  String get settingsNotifCustomRingtoneSub => 'WAV 文件路径（桌面端）';

  @override
  String get settingsNotifGroup => '通知';

  @override
  String get settingsNotifRequestPermissions => '请求权限';

  @override
  String get settingsNotifRequestPermissionsSub => '麦克风和通知';

  @override
  String get settingsNotifTyping => '发送正在输入提示';

  @override
  String get settingsAppearanceTheme => '主题';

  @override
  String get settingsAppearanceLight => '浅色';

  @override
  String get settingsAppearanceDark => '深色';

  @override
  String get settingsAppearanceAccent => '强调色';

  @override
  String get settingsAppearanceAccentOption => '强调色选项';

  @override
  String get settingsAppearanceCompact => '紧凑布局';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return '麦克风：$microphone，通知：$notifications';
  }

  @override
  String get settingsPrivacySecurity => '安全';

  @override
  String get settingsPrivacyPasswords => '密码';

  @override
  String get settingsPrivacyPasswordsSub => '存储在系统钥匙串/密钥库中（备选为加密文件）';

  @override
  String get settingsPrivacyGroup => '隐私';

  @override
  String get settingsPrivacyNoTelemetry => '无遥测';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro 不发送任何分析数据。网络流量仅发往您的 SIP 服务器。';

  @override
  String get settingsPrivacyYourData => '您的数据';

  @override
  String get settingsPrivacyClearHistory => '清除通话记录';

  @override
  String get settingsPrivacyDeleteContacts => '删除所有联系人';

  @override
  String get settingsPrivacyDeleteMessages => '删除所有消息';

  @override
  String get settingsPrivacyConfirmHistory => '删除通话记录？';

  @override
  String get settingsPrivacyConfirmContacts => '删除所有联系人？';

  @override
  String get settingsPrivacyConfirmMessages => '删除所有消息？';

  @override
  String get settingsPrivacyCannotUndo => '此操作无法撤销。';

  @override
  String get settingsPrivacyDeletedHistory => '已删除通话记录';

  @override
  String get settingsPrivacyDeletedContacts => '已删除所有联系人';

  @override
  String get settingsPrivacyDeletedMessages => '已删除所有消息';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter => '同一网络中的设备可相互发现，通过 6 位数字码配对，并直接通话，无需任何服务器。';

  @override
  String get settingsLanEnable => '启用 LAN Link';

  @override
  String get settingsLanDeviceName => '设备名称';

  @override
  String get settingsLanDeviceNameHint => '本设备';

  @override
  String get settingsLanAllowIntercom => '允许对讲';

  @override
  String get settingsLanAllowIntercomSub => '允许已配对设备呼叫您并自动接听';

  @override
  String get settingsLanAskIntercom => '允许对讲前先询问';

  @override
  String get settingsLanAskIntercomSub => '否则已配对设备发出请求后，将在 30 秒内被自动接听';

  @override
  String get settingsLanAutoAcceptFiles => '自动接收已配对设备的文件';

  @override
  String get settingsLanAutoAcceptFilesSub => '否则每个文件都会先询问您';

  @override
  String get settingsLanAllowPull => '允许已配对设备接管我的通话';

  @override
  String get settingsLanAllowPullSub => '已配对设备可接管此处正在进行的通话';

  @override
  String get settingsLanDownloads => '下载文件夹';

  @override
  String get settingsLanDownloadsHint => '默认（Downloads/SoftphonePro）';

  @override
  String get settingsLanPort => 'Link 端口';

  @override
  String get settingsLanSharedAccounts => '与已配对设备共享的账户';

  @override
  String get settingsLanSharedAccountsFooter =>
      '共享已注册的账户后，同一服务器上的已配对设备可直接接收您的来电（通话转接），而无需中转。';

  @override
  String get settingsAdvEngine => '引擎';

  @override
  String get settingsAdvSimulator => '使用模拟器';

  @override
  String get settingsAdvSimulatorSub => '不使用原生引擎运行，通话为模拟。';

  @override
  String get settingsAdvLogLevel => '日志级别';

  @override
  String get settingsAdvLogErrors => '错误';

  @override
  String get settingsAdvLogInfo => '信息';

  @override
  String get settingsAdvLogDebug => '调试';

  @override
  String get settingsAdvLogVerbose => '详细';

  @override
  String get settingsAdvSipTrace => 'SIP 跟踪';

  @override
  String get settingsAdvRestartEngine => '重启引擎';

  @override
  String get settingsAdvDesktop => '桌面端';

  @override
  String get settingsAdvStartAtLogin => '登录时启动';

  @override
  String get settingsAdvCloseToTray => '关闭到托盘';

  @override
  String get settingsAdvCloseToTraySub =>
      '关闭窗口后 SoftphonePro 继续运行，以便仍可响铃。请从托盘/菜单栏图标退出。';

  @override
  String get settingsAboutLicence => '许可证';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro 是自由软件：您可以依据自由软件基金会发布的 GNU 通用公共许可证第 3 版或更高版本的条款，重新分发和/或修改它。分发本软件不附带任何担保。';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 或更高版本';

  @override
  String get settingsAboutGplSub => '源代码可在项目仓库中获取';

  @override
  String get settingsAboutThirdParty => '第三方声明';

  @override
  String get settingsAboutPackages => 'Flutter 和 Dart 软件包';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause、MIT 和 Apache 2.0。请参阅许可证页面。';

  @override
  String settingsAboutVersion(String version) {
    return '版本 $version';
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
    return '$license。$purpose。版本 $version。';
  }

  @override
  String get updatesChecking => '正在检查…';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version 可用';
  }

  @override
  String get updatesUpToDate => '已是最新版本';

  @override
  String get updatesCouldNotCheck => '无法检查';

  @override
  String get updatesNotCheckedYet => '尚未检查';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '上次检查：$dateString';
  }

  @override
  String get updatesTitle => '更新';

  @override
  String get updatesFooter =>
      '检查更新仅访问 api.github.com（每周一次），除请求本身外不发送任何内容：没有标识符，也没有账户或通话数据。SoftphonePro 绝不会自行下载或安装任何内容。';

  @override
  String get updatesCheckSwitch => '检查更新';

  @override
  String get updatesCheckNow => '立即检查';

  @override
  String updatesSkippingVersion(String version) {
    return '正在跳过版本 $version';
  }

  @override
  String get updatesStopSkipping => '停止跳过';

  @override
  String get updatesReleaseNotes => '发行说明';

  @override
  String get updatesDownload => '下载';

  @override
  String get updatesSkipVersion => '跳过此版本';

  @override
  String get updatesDismiss => '忽略';

  @override
  String get updatesRateLimited => '已达到 GitHub 速率限制，请稍后重试';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub 返回 $status';
  }

  @override
  String get updatesUnexpectedReply => '意外的响应';

  @override
  String get updatesTimedOut => '超时';

  @override
  String get updatesAlreadyChecking => '正在检查中';

  @override
  String get encryptionTitle => '加密';

  @override
  String get encryptionFooter =>
      '使用 AES-256-GCM 加密本地数据库。密钥保存在系统钥匙串/密钥库中；如果丢失，数据将无法恢复。通话录音和导出的文件不会被加密。更改将在 SoftphonePro 下次启动时生效（请先完全退出）；新数据库打开并验证后，旧文件会立即被覆盖并删除。';

  @override
  String get encryptionSwitchTitle => '在此设备上加密通话记录、联系人和消息';

  @override
  String get encryptionWillEncrypt => '将在下次启动时加密';

  @override
  String get encryptionWillDecrypt => '将在下次启动时解密';

  @override
  String get encryptionRestartToEncrypt => '请退出并重新启动 SoftphonePro 以加密您的数据。';

  @override
  String get encryptionRestartToDecrypt => '请退出并重新启动 SoftphonePro 以解密您的数据。';

  @override
  String speedDialSlotTitle(int slot) {
    return '快速拨号 $slot';
  }

  @override
  String get speedDialNumberLabel => '号码或 SIP 地址';

  @override
  String get speedDialLabelOptional => '标签（可选）';

  @override
  String get speedDialCallFrom => '拨出账户';

  @override
  String get speedDialSelectedAccount => '当前所选账户';

  @override
  String get speedDialTitle => '快速拨号';

  @override
  String get speedDialHint => '在空白拨号盘上长按数字（1-9）即可拨打对应号码。';

  @override
  String get speedDialNotAssigned => '未分配';

  @override
  String provisioningNotValidJson(String detail) {
    return '不是有效的 JSON：$detail';
  }

  @override
  String get provisioningExpectedObject => '应为 JSON 对象';

  @override
  String provisioningUnsupportedVersion(String version) {
    return '不支持的配置版本 $version';
  }

  @override
  String get provisioningSkippedAccountEntry => '已跳过一个非对象的账户条目';

  @override
  String get provisioningNothingToImport => '文件中不包含账户或设置';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return '账户“$name”需要用户名和域名';
  }

  @override
  String provisioningServerAnswered(int status) {
    return '服务器返回 $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return '无法下载配置：$error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return '无法读取 $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个账户',
      one: '已导入 1 个账户',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => '导入配置';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts 个账户',
      one: '1 个账户',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings 项设置',
      one: '1 项设置',
    );
    return '$_temp0，$_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => '从 URL 或 JSON 导入';

  @override
  String get provisioningImportFromUrlHint => 'https://... 或粘贴 JSON';

  @override
  String get provisioningInvalidSource => '这不是有效的 URL、链接或 JSON';

  @override
  String get provisioningScanTitle => '扫描配置二维码';

  @override
  String get provisioningPasteHint => '粘贴 JSON、链接或 URL';

  @override
  String get provisioningImportGroup => '导入';

  @override
  String get provisioningImportFooter =>
      '支持包含账户和设置的 JSON。\${VAR} 占位符将填入空值，除非以 \${VAR:-default} 形式给出默认值。';

  @override
  String get provisioningScanQr => '扫描二维码';

  @override
  String get provisioningFromUrl => '从 URL 或粘贴的 JSON';

  @override
  String get provisioningFromFile => '从文件';

  @override
  String get provisioningFromClipboard => '从剪贴板';

  @override
  String get provisioningExportGroup => '导出';

  @override
  String get provisioningIncludePasswords => '包含密码';

  @override
  String get provisioningIncludePasswordsHint => '任何获得该文件的人都可使用您的账户';

  @override
  String get provisioningCopyConfig => '复制配置（JSON）';

  @override
  String get provisioningConfigCopied => '配置已复制';

  @override
  String get provisioningQrGroup => '二维码';

  @override
  String get provisioningQrFooter =>
      '在另一台设备上扫描此二维码即可复制账户。若其中包含密码，请像对待密码一样妥善保管。';

  @override
  String get provisioningQrAccount => '账户';

  @override
  String get provisioningChoose => '选择…';

  @override
  String get provisioningQrTooMuchData => '数据过多，无法生成二维码';

  @override
  String tlsClearField(String field) {
    return '清除$field';
  }

  @override
  String get tlsChoose => '选择…';

  @override
  String get tlsChange => '更改…';

  @override
  String get tlsClientCertTitle => '客户端证书（双向 TLS）';

  @override
  String get tlsIncomplete => '请同时选择证书及其私钥。只有两者都设置后才会出示证书。';

  @override
  String get tlsFooter => '适用于要求应用以证书表明身份的服务器。PEM 文件。用于 TLS 和安全 WebSocket。';

  @override
  String get tlsCertFile => '证书文件';

  @override
  String get tlsKeyFile => '私钥文件';

  @override
  String get tlsKeyPassword => '密钥密码';

  @override
  String get tlsKeyPasswordHint => '仅当密钥已加密时需要';

  @override
  String get callSettingsHoldGroupTitle => '通话保持';

  @override
  String get callSettingsHoldFooter =>
      '选择“PBX 默认”时，通话仅会被保持，您的电话系统可能会播放自己的音乐。其他任何选择均由本应用向对方播放。';

  @override
  String get callSettingsHoldMusic => '保持音乐';

  @override
  String get callSettingsHoldPbxDefault => 'PBX 默认';

  @override
  String get callSettingsHoldMusicVolume => '保持音乐音量';

  @override
  String get callSettingsHoldAudioFiles => '音频文件';

  @override
  String get callSettingsHoldAudioFilesHint => '导入或录制保持音乐';

  @override
  String get callSettingsAnnounceTitle => '提示音';

  @override
  String get callSettingsAnnounceFooter => '提示音会播放给对方。如果文件缺失，将直接跳过而不提示。';

  @override
  String get callSettingsAnnounceOpening => '开场提示音';

  @override
  String get callSettingsAnnounceOpeningHint => '通话接通时播放一段语音';

  @override
  String get callSettingsAnnounceFile => '提示音文件';

  @override
  String get callSettingsAnnounceChooseFile => '选择文件';

  @override
  String get callSettingsAnnouncePlayFor => '播放对象';

  @override
  String get callSettingsAnnounceBoth => '来电和去电';

  @override
  String get callSettingsAnnounceIncoming => '来电';

  @override
  String get callSettingsAnnounceOutgoing => '去电';

  @override
  String get callSettingsAnnounceMuteMic => '播放期间将我的麦克风静音';

  @override
  String get callSettingsAnnounceMonitor => '同时让我听到';

  @override
  String get callSettingsAnnounceBeforeRecording => '开始录音前播放';

  @override
  String get callSettingsAnnounceBeforeTransfer => '转接来电者前播放';

  @override
  String get morePageTitle => '更多';

  @override
  String get morePresence => '在线状态';

  @override
  String get morePresenceHint => '忙线指示灯';

  @override
  String get moreRetrieveParked => '取回停靠的通话';

  @override
  String get moreRetrieveParkedHint => '拨打停靠位';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => '附近设备、聊天和文件传送';

  @override
  String get moreRecordings => '录音';

  @override
  String get moreRecordingsHint => '收听、分享和管理通话录音';

  @override
  String get moreVoicemail => '语音信箱';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新留言',
      one: '1 条新留言',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => '拨打您的语音信箱';

  @override
  String get moreDiagnostics => '诊断';

  @override
  String get moreDiagnosticsHint => 'SIP 跟踪和网络检查';

  @override
  String get moreAbout => '关于';

  @override
  String get moreNoVoicemailNumber => '未设置语音信箱号码。请在账户设置中添加。';

  @override
  String get moreSearchHint => '搜索联系人、记录，或输入号码';

  @override
  String moreCallNumber(String number) {
    return '呼叫 $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day $time';
  }

  @override
  String get appLockTitle => '应用锁';

  @override
  String get appLockFooter => '应用锁定时，来电仍会响铃并可接听。';

  @override
  String get appLockRequirePin => '打开应用需输入 PIN';

  @override
  String get appLockOnHint => '记录、联系人、消息和设置均已锁定';

  @override
  String get appLockIsOn => '应用锁已开启';

  @override
  String get appLockIsOff => '应用锁已关闭';

  @override
  String get appLockTurnOff => '关闭应用锁';

  @override
  String get appLockChangePin => '更改 PIN';

  @override
  String get appLockEnterCurrent => '输入当前 PIN';

  @override
  String get appLockPinChanged => 'PIN 已更改';

  @override
  String get appLockLockAfter => '锁定时间';

  @override
  String get appLockLockAfterHint => '在后台停留多久后需再次输入 PIN';

  @override
  String get appLockImmediately => '立即';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟',
      one: '1 分钟',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 小时';

  @override
  String get appLockBiometrics => '使用生物识别解锁';

  @override
  String get appLockNow => '立即锁定';

  @override
  String get appLockSetPin => '设置 PIN';

  @override
  String get appLockPinDigits => 'PIN（4-8 位数字）';

  @override
  String get appLockRepeatPin => '再次输入 PIN';

  @override
  String get appLockUseDigits => '请使用 4 到 8 位数字';

  @override
  String get appLockMismatch => '两次输入的 PIN 不一致';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return '尝试次数过多。请在 $seconds 秒后重试';
  }

  @override
  String get appLockWrongPin => 'PIN 错误';

  @override
  String get appLockTooMany => '尝试次数过多';

  @override
  String get appLockIsLocked => 'SoftphonePro 已锁定';

  @override
  String get appLockEnterPin => '请输入您的 PIN';

  @override
  String appLockTryAgainIn(String time) {
    return '请在 $time后重试';
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
  String get appLockUnlock => '解锁';

  @override
  String get appLockIncomingCall => '来电';

  @override
  String get appLockDecline => '拒接';

  @override
  String get appLockAnswer => '接听';

  @override
  String get appLockHangUp => '挂断';

  @override
  String get appLockBiometricReason => '解锁 SoftphonePro';

  @override
  String get automationNoToken => '未设置访问令牌。请在“设置 > 高级”中生成。';

  @override
  String automationInvalidPort(int port) {
    return '无效的端口 $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return '无法启动：$error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return '端口 $port 不可用（$error）。请选择其他端口。';
  }

  @override
  String get automationTokenPlaceholder => '开启 API 时创建';

  @override
  String automationListening(String address) {
    return '正在监听 $address';
  }

  @override
  String get automationStarting => '正在启动…';

  @override
  String get automationTitle => '本地自动化 API';

  @override
  String get automationFooter =>
      '用于本机上的 CRM 和服务台集成。它仅监听 127.0.0.1，且每个请求都需要访问令牌。请参阅 docs/AUTOMATION_API.md。';

  @override
  String get automationEnable => '启用本地自动化 API';

  @override
  String get automationPort => '端口';

  @override
  String get automationPortHint => '默认 7771。请选择 1024 到 65535 之间的空闲端口。';

  @override
  String get automationPortInvalid => '请输入 1024 到 65535 之间的端口';

  @override
  String get automationAccessToken => '访问令牌';

  @override
  String get automationHideToken => '隐藏令牌';

  @override
  String get automationShowToken => '显示令牌';

  @override
  String get automationCopyToken => '复制令牌';

  @override
  String get automationTokenCopied => '令牌已复制';

  @override
  String get automationGenerateToken => '生成新令牌';

  @override
  String get automationGenerateTitle => '生成新令牌？';

  @override
  String get automationGenerateBody => '使用旧令牌的程序将停止工作，直到您为其提供新令牌。';

  @override
  String get automationGenerate => '生成';

  @override
  String get automationOrigins => '允许的浏览器来源';

  @override
  String get automationOriginsHint =>
      '以逗号分隔，例如 https://crm.example.com。不使用浏览器的程序（curl、脚本）无需设置。';

  @override
  String automationNotOrigin(String origin) {
    return '不是 http(s) 来源：$origin';
  }

  @override
  String get trayNotificationAnswer => '接听';

  @override
  String get trayNotificationDecline => '拒接';

  @override
  String get trayTooltipInCall => 'SoftphonePro - 通话中';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count 条新消息';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - 无账户（离开）',
      'dnd': 'SoftphonePro - 无账户（免打扰）',
      'other': 'SoftphonePro - 无账户',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total 在线（离开）',
      'dnd': 'SoftphonePro - $online/$total 在线（免打扰）',
      'other': 'SoftphonePro - $online/$total 在线',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => '隐藏 SoftphonePro';

  @override
  String get trayShowApp => '显示 SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count 条新记录 - 打开最近通话';
  }

  @override
  String get trayStatus => '状态';

  @override
  String get trayStatusAway => '离开';

  @override
  String get trayAccounts => '账户';

  @override
  String get trayQuit => '退出 SoftphonePro';

  @override
  String get hotkeyAnswerCall => '接听来电';

  @override
  String get hotkeyHangUp => '挂断';

  @override
  String get hotkeyMute => '静音/取消静音';

  @override
  String get hotkeyFocusDialer => '聚焦拨号盘';

  @override
  String get shortcutsGlobalTitle => '全局热键';

  @override
  String get shortcutsGlobalFooter => '可在任何应用中使用。若其他程序已占用某个组合键，则可能无法注册。';

  @override
  String get shortcutsChange => '更改';

  @override
  String get shortcutsRestoreDefaults => '恢复默认设置';

  @override
  String get shortcutsMediaTitle => '耳机和媒体键';

  @override
  String get shortcutsMediaFooter =>
      '仅在来电响铃或通话期间才会占用耳机或键盘的播放/暂停键，其余时间仍归音乐播放器使用。';

  @override
  String get shortcutsMediaSwitch => '使用耳机/媒体播放暂停键接听和挂断';

  @override
  String get shortcutsMediaDuringCall => '通话期间按此键将';

  @override
  String get shortcutsMediaHangsUp => '挂断';

  @override
  String get shortcutsMediaMutes => '静音/取消静音';

  @override
  String get shortcutsInApp => '应用内';

  @override
  String get shortcutsFocusDialer => '聚焦拨号盘';

  @override
  String get shortcutsHoldResume => '保持/恢复通话';

  @override
  String get shortcutsTransfer => '转接';

  @override
  String get shortcutsEndCall => '结束通话';

  @override
  String get shortcutsNeedX11 => '全局快捷键需要 X11 会话。Wayland 不允许应用在系统范围内捕获按键。';

  @override
  String shortcutsNeedModifier(String key) {
    return '请在字母或数字上加 Ctrl、Alt、Shift 或 $key';
  }

  @override
  String get shortcutsPressNew => '请按下新的组合键';

  @override
  String get defaultHandlerChooseInSettings =>
      '请在“默认应用”中为 SIP、TEL 和 CALLTO 选择 SoftphonePro';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro 现在会打开 sip:、tel: 和 callto: 链接';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return '无法更改 $schemes 的默认应用';
  }

  @override
  String get defaultHandlerIntro => '从浏览器和其他应用中打开 sip:、tel: 和 callto: 链接';

  @override
  String get defaultHandlerIsSelf => 'SoftphonePro 负责处理 sip:、tel: 和 callto: 链接';

  @override
  String defaultHandlerNow(String handlers) {
    return '当前：$handlers';
  }

  @override
  String get defaultHandlerTitle =>
      '将 SoftphonePro 设为 sip:、tel: 和 callto: 链接的默认应用';

  @override
  String get reliabilityTitle => '后台可靠性';

  @override
  String get reliabilityMicrophone => '麦克风';

  @override
  String get reliabilityAllowed => '已允许';

  @override
  String get reliabilityMicNeeded => '通话时需要使用';

  @override
  String get reliabilityNotifications => '通知';

  @override
  String get reliabilityNotifNeeded => '用于显示来电并保持服务可见';

  @override
  String get reliabilityFullScreen => '全屏来电';

  @override
  String get reliabilityFullScreenNeeded => '允许后，来电可显示在锁屏界面上';

  @override
  String get reliabilityBattery => '不受限制的电池使用';

  @override
  String get reliabilityBatteryExempt => '已豁免电池优化';

  @override
  String get reliabilityBatteryNeeded =>
      'Android 可能为省电而挂起应用，导致漏接来电。点按以豁免 SoftphonePro。';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer 自启动/受保护的应用';
  }

  @override
  String get reliabilityAutostartHint => '手机厂商可能会终止后台应用。请允许 SoftphonePro 自动启动。';

  @override
  String get reliabilityBoot => '开机启动';

  @override
  String get reliabilityBootHint => '手机重启后注册账户';

  @override
  String get reliabilityWake => '空闲时保持 CPU 唤醒';

  @override
  String get reliabilityWakeHint => '在限制严格的设备上更可靠；更耗电';

  @override
  String acctEditorDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String acctCodecRemove(String codec) {
    return '移除 $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return '上次错误：$error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return '允许范围 $min 至 $max';
  }

  @override
  String acctValidateMin(int min) {
    return '不得小于 $min';
  }

  @override
  String acctValidateMax(int max) {
    return '不得大于 $max';
  }

  @override
  String get acctEditorDiscardTitle => '放弃更改？';

  @override
  String get acctEditorDiscardMessage => '您对此账户的修改尚未保存。';

  @override
  String get acctEditorDiscardConfirm => '放弃';

  @override
  String get acctEditorDeleteMessage => '该账户及其保存的密码将从此设备中移除。';

  @override
  String get acctEditorMenuDelete => '删除账户';

  @override
  String get acctGroupBasic => '基本';

  @override
  String get acctFieldLabel => '标签';

  @override
  String get acctFieldLabelHint => '例如：办公室';

  @override
  String get acctFieldDisplayName => '显示名称';

  @override
  String get acctFieldUsername => '用户名';

  @override
  String get acctFieldProtocol => '协议';

  @override
  String get acctFieldProtocolSub => '创建账户后不可更改';

  @override
  String get acctFieldAuthUser => '认证用户名';

  @override
  String get acctFieldAuthUserHint => '与用户名相同';

  @override
  String get acctFieldAuthUserSub => '仅当服务商使用的登录名与用户名不同时填写';

  @override
  String get acctFieldPassword => '密码';

  @override
  String get acctFieldServerHost => '服务器主机';

  @override
  String get acctFieldPort => '端口';

  @override
  String get acctFieldIaxPortSub => 'IAX2 默认端口为 4569';

  @override
  String get acctFieldIaxContext => '上下文';

  @override
  String get acctFieldIaxContextSub => '可选。作为被叫上下文发送给 PBX';

  @override
  String get acctFieldServerDomain => '服务器/域名';

  @override
  String get acctFieldServerDomainSub => '主机 或 主机:端口';

  @override
  String get acctFieldEnabled => '已启用';

  @override
  String get acctFieldDefault => '外呼默认账户';

  @override
  String get acctFieldColour => '颜色';

  @override
  String get acctGroupRegistration => '注册';

  @override
  String get acctFieldRegister => '注册';

  @override
  String get acctFieldRegisterSubIax => '对无需注册的对端请关闭';

  @override
  String get acctFieldRegExpiry => '注册有效期（秒）';

  @override
  String get acctFieldRegExpirySubIax => 'Asterisk 通常强制为 60 秒。范围 10 至 86400';

  @override
  String get acctFieldRetryInterval => '重试间隔（秒）';

  @override
  String get acctFieldFirstRetry => '首次重试（秒）';

  @override
  String get acctGroupCodecs => '编解码器';

  @override
  String get acctGroupCodecsFooterIax => 'IAX2 支持 G.711 和 GSM。拖动以设置优先顺序。';

  @override
  String get acctCodecAdd => '添加编解码器';

  @override
  String get acctGroupServerTransport => '服务器与传输';

  @override
  String get acctFieldRegistrar => '注册服务器覆盖';

  @override
  String get acctFieldBackupRegistrar => '备用注册服务器';

  @override
  String get acctFieldBackupRegistrarSub => '失败 3 次后启用；每 5 分钟重试一次主服务器';

  @override
  String get acctFieldProxies => '出站代理';

  @override
  String get acctFieldTransport => '传输协议';

  @override
  String get acctFieldTransportAutoSub => '查询服务器的 DNS SRV 记录并选择 TLS、TCP 或 UDP';

  @override
  String get acctTransportAuto => '自动（DNS SRV）';

  @override
  String get acctFieldWsPath => 'WebSocket 路径';

  @override
  String get acctFieldWsPathSub => 'WebSocket 升级的 HTTP 路径，例如 /ws。必须以“/”开头';

  @override
  String get acctFieldRegExpirySubSip => '通常为 300 至 3600。范围 10 至 86400';

  @override
  String get acctFieldKeepAlive => '保活（秒）';

  @override
  String get acctFieldKeepAliveSub => 'UDP 保活间隔。0 表示关闭。范围 0 至 3600';

  @override
  String get acctFieldLocalPort => '本地 SIP 端口';

  @override
  String get acctFieldLocalPortSub => '0 表示使用共享传输。范围 0 至 65535';

  @override
  String get acctFieldRegisterSubSip => '对无需注册的中继请关闭';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound（RFC 5626）';

  @override
  String get acctFieldSipOutboundSub => '通过 NAT 保持持久连接。需要服务器支持';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => '使用 STUN';

  @override
  String get acctFieldTurn => 'TURN 中继';

  @override
  String get acctFieldTurnServer => 'TURN 服务器';

  @override
  String get acctFieldTurnUsername => 'TURN 用户名';

  @override
  String get acctFieldTurnPassword => 'TURN 密码';

  @override
  String get acctFieldContactRewrite => '重写 Contact 头';

  @override
  String get acctFieldViaRewrite => '重写 Via 头';

  @override
  String get acctFieldRewriteSub => '使用服务器看到的地址。位于 NAT 后请保持开启';

  @override
  String get acctFieldSdpRewrite => '重写 SDP 地址';

  @override
  String get acctFieldSdpRewriteSub => '将 SDP 中的媒体地址替换为公网地址';

  @override
  String get acctFieldIpv6Sip => 'IPv6 信令';

  @override
  String get acctFieldIpv6Media => 'IPv6 媒体';

  @override
  String get acctGroupAdvancedMedia => '高级媒体';

  @override
  String get acctGroupAdvancedMediaFooter => 'WebRTC 网关需要 RTCP 复用和 RTCP 反馈。';

  @override
  String get acctFieldRtcpMux => 'RTCP 复用';

  @override
  String get acctFieldRtcpMuxSub => '在同一端口发送 RTP 和 RTCP（rtcp-mux）';

  @override
  String get acctFieldRtcpFb => 'RTCP 反馈（AVPF）';

  @override
  String get acctFieldRtcpFbSub => '提供带 NACK 的 RTP/AVPF。WebRTC 服务器需要';

  @override
  String get acctGroupSecurity => '安全';

  @override
  String get acctFieldSrtp => '媒体加密（SRTP）';

  @override
  String get acctOptOptional => '可选';

  @override
  String get acctOptRequired => '必需';

  @override
  String get acctFieldKeyExchange => '密钥交换';

  @override
  String get acctFieldSecureSignaling => '安全信令';

  @override
  String get acctOptNotRequired => '不要求';

  @override
  String get acctOptTlsHop => 'TLS 逐跳';

  @override
  String get acctOptTlsE2e => 'TLS 端到端（sips）';

  @override
  String get acctFieldAuthAlgorithm => '认证算法';

  @override
  String get acctFieldPrivacy => '隐藏主叫号码（隐私）';

  @override
  String get acctFieldReferPolicy => '来电转接（REFER）';

  @override
  String get acctFieldWatcherPolicy => '在线状态订阅者';

  @override
  String get acctOptAccept => '接受';

  @override
  String get acctOptReject => '拒绝';

  @override
  String get acctGroupCodecsFooter => '覆盖此账户的全局编解码器列表。';

  @override
  String get acctFieldUseGlobalCodecs => '使用全局编解码器顺序';

  @override
  String get acctGroupFeatures => '功能';

  @override
  String get acctFieldVoicemailNumber => '语音信箱号码';

  @override
  String get acctFieldMwi => '语音信箱指示（MWI）';

  @override
  String get acctFieldMwiSub => '订阅留言等待通知';

  @override
  String get acctFieldPublishPresence => '发布我的在线状态';

  @override
  String get acctFieldPublishPresenceSub => '允许服务器分享您的在线状态';

  @override
  String get acctFieldDnd => '免打扰';

  @override
  String get acctFieldForwarding => '呼叫转移';

  @override
  String get acctOptForwardAlways => '始终';

  @override
  String get acctOptForwardBusy => '忙线时';

  @override
  String get acctOptForwardNoAnswer => '无人接听时';

  @override
  String get acctFieldForwardTo => '转移到';

  @override
  String get acctFieldForwardToHint => '号码或 SIP 地址';

  @override
  String get acctFieldRingFor => '响铃时长（秒）';

  @override
  String get acctFieldAutoAnswer => '自动接听';

  @override
  String get acctFieldAnswerAfter => '接听延迟（秒）';

  @override
  String get acctFieldIntercomOnly => '仅限对讲呼叫';

  @override
  String get acctFieldIntercomOnlySub => '需要 PBX 提供自动接听头信息';

  @override
  String get acctFieldRingtone => '铃声';

  @override
  String get acctRingtoneClassic => '经典';

  @override
  String get acctRingtoneSoft => '柔和';

  @override
  String get acctRingtoneDigital => '数码';

  @override
  String get acctFieldRecordCalls => '通话录音';

  @override
  String get acctFieldHoldMusic => '保持音乐';

  @override
  String get acctOptUseGlobal => '使用全局设置';

  @override
  String get acctOptPbxDefault => 'PBX 默认';

  @override
  String get acctFieldOpeningAnnouncement => '开场提示音';

  @override
  String get acctGroupFeatureCodes => '功能码';

  @override
  String get acctGroupFeatureCodesFooter => '用于在您的 PBX 上拨打停靠、代接、免打扰和呼叫转移。';

  @override
  String get acctFieldPark => '停靠';

  @override
  String get acctFieldGroupPickup => '组代接';

  @override
  String get acctFieldDirectedPickup => '定向代接前缀';

  @override
  String get acctFieldParkRetrieve => '取回停靠前缀';

  @override
  String get acctFieldParkRetrieveHint => '拨打停靠位号码';

  @override
  String get acctFieldParkRetrieveSub => '在停靠位前拨打的前缀，用于取回已停靠的通话';

  @override
  String get acctFieldDndOn => '开启免打扰';

  @override
  String get acctFieldDndOff => '关闭免打扰';

  @override
  String get acctFieldForwardOn => '开启转移';

  @override
  String get acctFieldForwardOff => '关闭转移';

  @override
  String get acctGroupAdvanced => '高级';

  @override
  String get acctGroupAdvancedFooterIax => 'DTMF 以原生 IAX2 帧发送。';

  @override
  String get acctFieldCallerIdOverride => '主叫号码覆盖';

  @override
  String get acctFieldCallerIdHint => '使用账户默认值';

  @override
  String get acctFieldCallerIdSub => '发送给 PBX 的主叫名称或号码';

  @override
  String get acctFieldSessionTimers => '会话计时器';

  @override
  String get acctFieldSessionExpires => '会话有效期（秒）';

  @override
  String get acctFieldSessionExpiresSub => '范围 90 至 86400';

  @override
  String get acctField100rel => '100rel（可靠临时响应）';

  @override
  String get acctFieldHoldMethod => '保持方式';

  @override
  String get acctFieldDtmfMethod => 'DTMF 方式';

  @override
  String get acctOptDtmfInband => '带内';

  @override
  String get acctFieldRedirects => '重定向（3xx）';

  @override
  String get acctOptRedirectFollow => '跟随';

  @override
  String get acctOptRedirectAsk => '询问';

  @override
  String get acctFieldLockCodec => '接听后锁定编解码器';

  @override
  String get acctFieldMediaKeepAlive => '媒体保活';

  @override
  String get acctFieldDropCalls => '注册失败时断开通话';

  @override
  String get acctFieldExtraHeaders => '额外 SIP 头';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: 值（每行一个）';

  @override
  String get acctFieldRetryIntervalSub => '注册失败后重试前的等待时间。范围 0 至 86400';

  @override
  String get acctFieldUnregTimeout => '注销超时（毫秒）';

  @override
  String get acctFieldUnregTimeoutSub => '等待注销响应的时长。范围 0 至 60000';

  @override
  String get acctFieldMwiExpiry => 'MWI 订阅有效期（秒）';

  @override
  String get acctFieldDscpSip => 'SIP 的 DSCP';

  @override
  String get acctFieldDscpSipSub => '信令的 QoS 标记。通常为 24（CS3）';

  @override
  String get acctFieldDscpRtp => 'RTP 的 DSCP';

  @override
  String get acctFieldDscpRtpSub => '媒体的 QoS 标记。通常为 46（EF）';

  @override
  String get acctFieldReinvite => '网络变化后重发 INVITE';

  @override
  String get acctFieldHangupOnIpChange => '网络变化时挂断通话';

  @override
  String get acctValidateInt => '请输入整数';

  @override
  String get acctValidateHostEmpty => '请输入服务器主机名或地址';

  @override
  String get acctValidateHostSpaces => '服务器不能包含空格';

  @override
  String get acctValidateHostFormat => '仅可输入 主机 或 主机:端口';

  @override
  String get acctValidatePortRange => '端口必须在 1 到 65535 之间';

  @override
  String get acctValidateWsStart => '路径必须以“/”开头';

  @override
  String get acctValidateWsLength => '最多使用 120 个字符';

  @override
  String get acctValidateWsSpaces => '路径不能包含空格';

  @override
  String get acctTplAsteriskDescription => '您自己 PBX 上的分机。UDP 5060，已启用 STUN。';

  @override
  String get acctTplAsteriskNotes =>
      '请使用 PJSIP/SIP 分机号及其密码。如需 TLS 或 WebRTC，请稍后在账户设置中更改传输协议。';

  @override
  String get acctTplAsteriskUsernameHint => '分机（例如 1001）';

  @override
  String get acctTpl3cxDescription => '使用 3CX 管理门户中的分机、认证 ID 和密码。';

  @override
  String get acctTpl3cxNotes =>
      '在 3CX 中打开该分机，然后在“Phones > Provisioning”中查看认证 ID（将其设为认证用户名）和密码。FQDN 即您的 3CX 网址中的域名。';

  @override
  String get acctTpl3cxUsernameHint => '分机';

  @override
  String get acctTplFreeswitchDescription => 'FreeSWITCH 服务器上的目录用户。';

  @override
  String get acctTplFreeswitchNotes =>
      '请使用目录中的用户 ID 和密码。默认的 internal 配置监听 UDP/TCP 5060。';

  @override
  String get acctTplFreeswitchUsernameHint => '用户 ID';

  @override
  String get acctTplKamailioDescription => 'SIP 代理注册服务器。位于 NAT 后建议使用 TCP。';

  @override
  String get acctTplKamailioNotes =>
      '请使用您的注册服务器所服务的 SIP 域。如果需要通过其他主机访问注册服务器，请在账户设置中添加出站代理。';

  @override
  String get acctTplTwilioDescription =>
      'Programmable Voice SIP 域凭据。TLS 和 SRTP。';

  @override
  String get acctTplTwilioNotes =>
      '在 Twilio 控制台中创建 SIP 域，添加凭据列表并启用 SIP 注册。将完整域名（name.sip.twilio.com）作为服务器，并填写凭据列表中的用户名和密码。TLS 使用端口 5061。Twilio 仅支持 G.711。';

  @override
  String get acctTplTwilioUsernameHint => '凭据列表用户名';

  @override
  String get acctTplTelnyxDescription => '凭据连接。UDP，G.711 / Opus。';

  @override
  String get acctTplTelnyxNotes =>
      '在 Telnyx 门户中创建 Credential Connection，并复制其 SIP 用户名和密码（不是门户登录账号）。将号码或外呼语音配置分配给该连接，才能拨打和接听电话。';

  @override
  String get acctTplTelnyxUsernameHint => 'SIP 用户名（凭据连接）';

  @override
  String get acctTplVoipmsDescription => '子账户用户名和密码。请选择离您最近的 POP。';

  @override
  String get acctTplVoipmsNotes =>
      '请使用在“Sub Accounts”下创建的子账户，而不是主账户。从 VoIP.ms 服务器列表中选择离您最近的服务器（POP），如有需要，请为您的 IP 放行。';

  @override
  String get acctTplVoipmsUsernameHint => '子账户（例如 123456_phone）';

  @override
  String get acctTplVonageDescription => '使用 TLS 的 SIP 注册。';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business 仅在部分套餐中提供 SIP 注册。请输入 Vonage 管理门户中为该设备显示的 SIP 服务器、用户名和密码。';

  @override
  String get acctTplIax2Description =>
      '基于 UDP 4569 的 Inter-Asterisk eXchange。无 NAT 或 SRTP 设置。';

  @override
  String get acctTplIax2Notes =>
      '需要在 iax.conf 中配置使用相同密码的 peer/user（type=friend 或 user+peer）。Asterisk 默认每 60 秒更新一次 IAX2 注册。上下文为可选项，将作为被叫上下文发送。';

  @override
  String get acctTplIax2UsernameHint => 'IAX2 用户名';

  @override
  String get acctTplWebrtcDescription =>
      '基于安全 WebSocket 的 SIP，支持 DTLS-SRTP、ICE 和 RTCP-mux。';

  @override
  String get acctTplWebrtcNotes =>
      '适用于 Asterisk（webrtc=yes，http.conf 中 TLS 端口 8089）、FreeSWITCH 或 Kamailio 的 WebSocket 端点。服务器需要有效的 TLS 证书。如果您的网关不使用 /ws，请在账户设置中更改 WebSocket 路径。';

  @override
  String get acctTplGenericDescription => '任意 SIP 注册服务器。请自行填写详细信息。';

  @override
  String get acctTplDefaultUsernameHint => '分机/用户名';

  @override
  String get appEngineFailedBody => '在问题解决之前，通话和注册将无法使用。通常是网络或证书设置有误所致。';

  @override
  String get appEngineFailedTitle => '无法启动通话引擎';

  @override
  String get appEngineNotRunning => '通话引擎未运行';

  @override
  String get appUnknownError => '未知错误';

  @override
  String get appEngineOpenNetworkSettings => '打开网络设置';

  @override
  String get appEngineUseSimulator => '使用模拟器（演示）';

  @override
  String get appDbLockedTitle => '您的数据已锁定';

  @override
  String get appDbUnreadableTitle => '无法打开您的数据';

  @override
  String get appDbLockedBody =>
      '通话记录、联系人和消息已在此设备上加密，但加密密钥已不在系统钥匙串/密钥库中（例如钥匙串重置或还原到新设备后）。';

  @override
  String get appDbUnreadableBody => '无法读取本地数据库。它可能已损坏，或加密密钥不匹配。';

  @override
  String get appDbRecoveryAdvice =>
      '如果您预计密钥会恢复（解锁钥匙串、登录正确的用户），请重试。重新开始会将旧文件保留在应用数据旁，但通话记录、联系人和消息将为空；您需要重新添加账户。';

  @override
  String get appDbCopyDetails => '复制详情';

  @override
  String get appDbTryAgain => '重试';

  @override
  String get appDbStartFresh => '重新开始';

  @override
  String get appRedirectTitle => '通话已重定向';

  @override
  String appRedirectMessage(String target) {
    return '通话已重定向到 $target，是否跟随？';
  }

  @override
  String get appRedirectCancelCall => '取消通话';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': '无法加密您的数据（$error）。未做任何更改。',
      'other': '无法解密您的数据（$error）。未做任何更改。',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return '原生引擎不可用（$error）';
  }

  @override
  String acctRetryingAt(String time) {
    return '将于 $time 重试';
  }

  @override
  String get acctRegistrationError => '注册错误';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\n传输协议：$transport';
  }

  @override
  String get acctCallingFromDirect => '直接拨出，未使用账户';

  @override
  String acctCallingFromAccount(String name) {
    return '使用 $name 拨出';
  }

  @override
  String get acctCallingFromNone => '无可用账户拨出';

  @override
  String get acctNoAccount => '无账户';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds 秒';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount 条新留言，$oldCount 条旧留言';
  }

  @override
  String get acctAddAccount => '添加账户';

  @override
  String get acctUnregister => '注销';

  @override
  String get acctSheetDndSub => '拒绝此账户的来电';

  @override
  String get acctKvServer => '服务器';

  @override
  String get acctKvResolvedServer => '解析的服务器';

  @override
  String get acctKvClientCert => '客户端证书';

  @override
  String get acctKvClientCertValue => '已向服务器出示（双向 TLS）';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => '剩余有效期';

  @override
  String get acctKvVoicemail => '语音信箱';

  @override
  String get acctOpenSipTrace => '打开 SIP 跟踪';

  @override
  String get acctAddAnAccount => '添加账户';

  @override
  String get acctChooseAccountTooltip => '选择拨出账户';

  @override
  String get acctDirectNoAccount => '直接拨打（无账户）';

  @override
  String get onboardingRequired => '用户名和服务器为必填项';

  @override
  String onboardingDefaultPortHelper(int port) {
    return '除非添加 :端口，否则使用端口 $port';
  }

  @override
  String get onboardingFineTuneIax => '您可以稍后在“设置”中微调编解码器和注册。';

  @override
  String get onboardingFineTuneSip => '您可以稍后在“设置”中微调传输协议、NAT、安全和编解码器。';

  @override
  String get onboardingDemoUser => '演示用户';

  @override
  String get onboardingDemoAccount => '演示账户';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 SoftphonePro';

  @override
  String get onboardingWelcomeText => '适用于所有平台的专业通话应用——免费且开源。无广告，无跟踪。';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingPermissionsTitle => '权限';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro 需要使用麦克风来传送您的声音，并需要通知权限来提醒您来电和新消息。除通话外，不会有任何数据离开您的设备。';

  @override
  String get onboardingChooseProvider => '选择您的服务商';

  @override
  String get onboardingChooseProviderSub => '我们会为您预填传输协议、端口和 NAT 设置。';

  @override
  String get onboardingScanQr => '扫描二维码';

  @override
  String get onboardingImportUrl => '从 URL 导入';

  @override
  String get onboardingSkip => '暂时跳过（演示模式）';

  @override
  String get onboardingHidePassword => '隐藏密码';

  @override
  String get onboardingShowPassword => '显示密码';

  @override
  String get onboardingContextOptional => '上下文（可选）';

  @override
  String get onboardingDisplayNameOptional => '显示名称（可选）';

  @override
  String get onboardingLabelOptional => '账户标签（可选）';

  @override
  String get onboardingCallerIdOptional => '主叫号码（可选）';

  @override
  String get onboardingAuthUserOptional => '认证用户名（如不同）';

  @override
  String acctRegWrongCredentials(int code) {
    return '用户名或密码错误（$code）';
  }

  @override
  String get acctRegNotFound => '服务器上未找到该账户（404）';

  @override
  String get acctRegNoAnswer => '服务器无响应（408）';

  @override
  String get acctRegIntervalTooShort => '注册间隔过短（423）';

  @override
  String get acctRegTemporarilyUnavailable => '服务器暂时不可用（480）';

  @override
  String get acctRegServiceUnavailable => '服务不可用（503）';

  @override
  String get acctRegFailed => '注册失败';

  @override
  String acctRegFailedWithCode(int code) {
    return '注册失败（$code）';
  }

  @override
  String get acctNoticeRegistrationChange => '无法更改注册状态';

  @override
  String acctNoticeApplyFailed(String name) {
    return '无法应用账户“$name”';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return '$name 已切回主服务器';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return '$name 正在使用备用服务器';
  }

  @override
  String callDialAccountRegistered(String name) {
    return '账户 $name 已注册';
  }

  @override
  String callDialAccountRegistering(String name) {
    return '账户 $name 仍在注册中';
  }

  @override
  String callDialAccountOffline(String name) {
    return '账户 $name 尚未注册';
  }

  @override
  String callDialAccountFailed(String name) {
    return '账户 $name 未注册（注册失败）';
  }

  @override
  String callDialAccountDisabled(String name) {
    return '账户 $name 已停用';
  }

  @override
  String get callDialEngineFailed => '通话引擎启动失败';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return '通话引擎启动失败：$reason';
  }

  @override
  String get callDialEngineStarting => '通话引擎仍在启动';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status：$reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status，已过 $seconds 秒；通话未拨出';
  }

  @override
  String get callJournalInterrupted => '通话期间应用被关闭';

  @override
  String get callLinkMissingArgument => '缺少参数';

  @override
  String get callLinkHttpsRequired => '配置链接必须使用 https';

  @override
  String get callLinkInvalidLan => '该 LAN 链接无效';

  @override
  String callLinkConnectedTo(String name) {
    return '已连接到 $name';
  }

  @override
  String get callLinkConnectFailed => '无法连接到该设备';

  @override
  String callLinkCallFailed(String target) {
    return '无法呼叫 $target';
  }

  @override
  String get callLinkImportTitle => '导入配置';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts 个账户',
      one: '1 个账户',
    );
    return '要从 $host 导入配置吗？这将添加 $_temp0。';
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
      other: '$accounts 个账户',
      one: '1 个账户',
    );
    return '要从 $host 导入配置吗？这将添加 $_temp0和 $settings 项设置。';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return '由 $number 转来';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return '由 $number 转来（$reason）';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return '由 $number 转接';
  }

  @override
  String get callRingtoneSystemDefault => '跟随系统';

  @override
  String get callRingtoneClassic => '经典';

  @override
  String get callRingtoneSoft => '柔和';

  @override
  String get callRingtoneDigital => '数码';

  @override
  String callIdentityFrom(String number) {
    return '来自 $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return '主叫号码 $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return '主叫号码 $name $number';
  }

  @override
  String get callTransferring => '正在转接…';

  @override
  String get callTransferNotConfirmed => '服务器未确认转接';

  @override
  String get callTransferStalledHint => '通话仍在继续。可保留通话，或重新发送转接。';

  @override
  String get callTransferKeepCall => '保留通话';

  @override
  String get callAnnouncementOpening => '正在播放提示音…';

  @override
  String get callAnnouncementTransfer => '正在播放转接提示…';

  @override
  String get callAnnouncementRecording => '正在播放录音提示…';

  @override
  String get callAnnouncementSkip => '跳过';

  @override
  String get callNoiseTooltipMic => 'AI 降噪：您的麦克风';

  @override
  String get callNoiseTooltipIncoming => 'AI 降噪：其他参与者';

  @override
  String get callNoiseTooltipBoth => 'AI 降噪：您的麦克风和其他参与者';

  @override
  String get callNoiseOn => '降噪已开启';

  @override
  String get callNoiseTitle => '降噪';

  @override
  String callNoiseMicStrength(String strength) {
    return '我的麦克风：$strength';
  }

  @override
  String get callNoiseMicOffHint => '消除我的麦克风中的背景噪声';

  @override
  String get callResultAnswered => '已接听';

  @override
  String get callResultMissed => '未接';

  @override
  String get callResultRejected => '已拒接';

  @override
  String get callResultFailed => '失败';

  @override
  String get callResultBusy => '忙线';

  @override
  String get callResultForwarded => '已转移';

  @override
  String get callResultTransferred => '已转接';

  @override
  String get callResultHandedOff => '已移交';

  @override
  String get callResultInterrupted => '已中断';

  @override
  String get keypadCall => '呼叫';

  @override
  String get keypadNoVoicemail => '此账户未配置语音信箱号码';

  @override
  String get keypadCallDirectly => '直接拨打（无账户）';

  @override
  String get keypadAddAccount => '添加账户后才能拨打电话';

  @override
  String keypadCallFrom(String account) {
    return '使用 $account 拨出';
  }

  @override
  String get keypadRecent => '最近';

  @override
  String get keypadSuggestions => '建议';

  @override
  String get keypadPhoneNumber => '电话号码';

  @override
  String get keypadPaste => '粘贴';

  @override
  String get keypadEnterNumber => '输入号码';

  @override
  String get keypadBackspace => '退格（长按清除）';

  @override
  String get keypadTypeNameOrNumber => '输入姓名或号码';

  @override
  String get keypadNoMatches => '无匹配结果';

  @override
  String get keypadSuggestionsHint => '建议来自联系人和最近通话';

  @override
  String keypadCallPerson(String name) {
    return '呼叫 $name';
  }

  @override
  String get dialKeyStar => '星号';

  @override
  String get dialKeyPound => '井号';

  @override
  String get dialKeyLongPressPlus => '长按输入加号';

  @override
  String get dialKeyLongPressSpeedDial => '长按快速拨号';

  @override
  String get dialKeyLongPressVoicemail => '长按拨打语音信箱';

  @override
  String get callBackToApp => '返回应用（通话保持进行）';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => '隐藏键盘';

  @override
  String get callMute => '静音';

  @override
  String get callKeypad => '键盘';

  @override
  String get callSpeaker => '扬声器';

  @override
  String get callRouteBluetooth => '蓝牙';

  @override
  String get callRouteHeadset => '耳机';

  @override
  String get callResume => '恢复';

  @override
  String get callHold => '保持';

  @override
  String get callAddCall => '添加通话';

  @override
  String get callTransfer => '转接';

  @override
  String get callStop => '停止';

  @override
  String get callRecord => '录音';

  @override
  String get callSplit => '拆分';

  @override
  String get callMerge => '合并';

  @override
  String get callSwap => '切换';

  @override
  String get callEndCall => '结束通话';

  @override
  String callEndCallWith(String name) {
    return '结束与 $name 的通话';
  }

  @override
  String get callAttendedTransferHint => '协商转接。原来电者已被保持。';

  @override
  String get callCompleteTransfer => '完成转接';

  @override
  String get callWaiting => '呼叫等待';

  @override
  String get callHoldAndAnswer => '保持当前通话并接听';

  @override
  String get callDecline => '拒接';

  @override
  String get callAnswer => '接听';

  @override
  String get callIncomingCall => '来电';

  @override
  String get callReply => '回复';

  @override
  String get callVoicemail => '语音信箱';

  @override
  String get callToDevice => '转到设备';

  @override
  String get callQuickReplyBusy => '现在不方便接听，稍后回电给您。';

  @override
  String get callQuickReplyMeeting => '我在开会，请发短信给我好吗？';

  @override
  String get callQuickReplyOnMyWay => '我正在路上。';

  @override
  String callReturnToCallWith(String name) {
    return '返回与 $name 的通话';
  }

  @override
  String callBarIncoming(String name) {
    return '来电：$name';
  }

  @override
  String callBarInCallWith(String name) {
    return '正在与 $name 通话';
  }

  @override
  String get callStatsCodec => '编解码器';

  @override
  String get callStatsJitter => '抖动';

  @override
  String get callStatsPacketLoss => '丢包';

  @override
  String get callStatsRoundTrip => '往返时延';

  @override
  String get callStatsMedia => '媒体';

  @override
  String get callStatsMosHistory => 'MOS 历史';

  @override
  String get callQualityTitle => '通话质量';

  @override
  String get callTransferTitle => '转接通话';

  @override
  String get callTransferModeBlind => '盲转';

  @override
  String get callTransferModeAttended => '协商转';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'LAN 设备';

  @override
  String get callTransferNoLanDevices =>
      '在您的网络中未找到已配对的 SoftphonePro 设备。请在 LAN 页面进行配对。';

  @override
  String get callTransferLanDisabled =>
      '请开启 LAN Link（设置 > LAN Link），以便将此通话转交给网络中的其他设备。';

  @override
  String get callTransferTalkFirst => '先沟通';

  @override
  String get callTransferBlindHint => '立即将来电者转出，您将断开通话。';

  @override
  String get callTransferAttendedHint => '先保持来电者并呼叫转接目标，对方接听后再完成转接。';

  @override
  String get callTransferNumberLabel => '号码或 SIP 地址';

  @override
  String get callTransferNow => '立即转接';

  @override
  String get callTransferCallAndConsult => '呼叫并沟通';

  @override
  String get callRetrieveParkedTitle => '取回停靠的通话';

  @override
  String get callRetrieveParkedHint => '停靠位，例如 701';

  @override
  String get callMoreAudioOutput => '音频输出';

  @override
  String get callMoreAudioDevices => '音频设备';

  @override
  String get callMoreAudioOutputSubtitle => '手机、扬声器、蓝牙、耳机';

  @override
  String get callMoreAudioDevicesSubtitle => '选择麦克风和扬声器';

  @override
  String get callMoreParkCall => '停靠通话';

  @override
  String get callMoreParkCallSubtitle => '转接到停靠功能码';

  @override
  String get callMoreRetrieveParkedSubtitle => '拨打停靠位';

  @override
  String get callMoreSendDtmf => '发送 DTMF 数字';

  @override
  String get callMoreSendDtmfSubtitle => '输入完整序列，例如 PIN';

  @override
  String get callSendDtmfTitle => '发送 DTMF';

  @override
  String get callMoreCallInfo => '通话信息';

  @override
  String get callMoreQualitySubtitle => '实时 MOS、抖动、丢包和往返时延';

  @override
  String get callMoreSipTrace => 'SIP 跟踪';

  @override
  String get callMoreSipTraceSubtitle => '本次通话的梯形图';

  @override
  String get callInfoRemote => '对方';

  @override
  String get callInfoAccount => '账户';

  @override
  String get callInfoState => '状态';

  @override
  String get callInfoSecure => '安全';

  @override
  String get callInfoPlainSignalling => '明文信令';

  @override
  String get callRoutePhone => '手机';

  @override
  String get callRouteWiredHeadset => '有线耳机';

  @override
  String get callAudioMicrophone => '麦克风';

  @override
  String callCardSemantics(String name, String state) {
    return '与 $name 通话，$state';
  }

  @override
  String get callUnmute => '取消静音';

  @override
  String get callStopRecording => '停止录音';

  @override
  String get callSplitConference => '拆分会议';

  @override
  String get callMergeCalls => '合并通话';

  @override
  String get callSwapCalls => '切换通话';

  @override
  String get callAttendedTransferBanner => '协商转接：原来电者已被保持。';

  @override
  String get callActiveCalls => '进行中的通话';

  @override
  String get callConferenceLevels => '会议音量';

  @override
  String get callLevelVolume => '音量';

  @override
  String get callLevelMicToParty => '发给对方的麦克风';

  @override
  String callPercentSemantics(int percent) {
    return '$percent%';
  }

  @override
  String get callFailInvalidNumber => '号码无效（400）';

  @override
  String callFailNotAuthorised(String code) {
    return '通话未授权（$code）';
  }

  @override
  String get callFailNumberNotFound => '号码未找到（404）';

  @override
  String get callFailNoAnswerFromServer => '服务器无响应（408）';

  @override
  String get callFailTemporarilyUnavailable => '暂时无法接通（480）';

  @override
  String get callFailIncompleteNumber => '号码不完整（484）';

  @override
  String callFailBusy(String code) {
    return '对方忙线（$code）';
  }

  @override
  String get callFailCancelled => '通话已取消（487）';

  @override
  String callFailNoCompatibleCodec(String code) {
    return '无兼容的编解码器（$code）';
  }

  @override
  String get callFailServiceUnavailable => '服务不可用（503）';

  @override
  String get callFailDeclined => '对方已拒接（603）';

  @override
  String get callFailGeneric => '通话失败';

  @override
  String callFailGenericWithCode(String code) {
    return '通话失败（$code）';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason（$code）';
  }

  @override
  String get callForegroundServiceText => '通话进行中';

  @override
  String get callTrayInCall => '通话中';

  @override
  String get callHistoryBlocked => '已屏蔽';

  @override
  String get callHistoryAnonymityDisallowed => '不允许匿名';

  @override
  String get callHistoryDoNotDisturb => '免打扰';

  @override
  String get callHistoryBusy => '忙线';

  @override
  String get callHistoryForwardedAlways => '已转移（始终）';

  @override
  String get callHistoryForwardedBusy => '已转移（忙线）';

  @override
  String get callHistorySentToVoicemail => '已转到语音信箱';

  @override
  String get callHistoryRedirected => '已重定向';

  @override
  String get callIncomingNotificationBody => '来电';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return '$account 有来电';
  }

  @override
  String get callMissedNotificationTitle => '未接来电';

  @override
  String get callErrEngineNotRunning => '通话引擎尚未运行';

  @override
  String get callErrAddAccount => '添加账户后才能拨打电话';

  @override
  String get callErrCouldNotPlace => '无法拨出电话';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account 未注册';
  }

  @override
  String get callErrCouldNotAnswer => '无法接听';

  @override
  String get callErrNoVoicemailNumber => '此账户未设置语音信箱号码';

  @override
  String get callErrTransferFailed => '转接失败';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return '转接失败：$reason（$code）';
  }

  @override
  String get callErrCouldNotMerge => '无法合并通话';

  @override
  String get callErrCouldNotStartRecording => '无法开始录音';

  @override
  String get callErrCouldNotStopRecording => '无法停止录音';

  @override
  String callParkingNotice(String code) {
    return '正在停靠通话（拨打 $code）';
  }

  @override
  String get callErrParkFailed => '停靠失败';

  @override
  String get callErrHandoffFailed => '移交失败';

  @override
  String get callErrCouldNotSendToDevice => '无法发送到设备';

  @override
  String get callHistoryForwardedNoAnswer => '已转移（无人接听）';

  @override
  String get shellTabKeypad => '拨号盘';

  @override
  String get shellTabRecents => '最近通话';

  @override
  String get shellTabContacts => '联系人';

  @override
  String get shellTabMessages => '消息';

  @override
  String get shellTabPresence => '在线状态';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => '录音';

  @override
  String get shellSearchSemantics => '搜索联系人、记录或拨打号码';

  @override
  String get shellSearchHint => '搜索或拨号';

  @override
  String get shellVoicemailTooltip => '语音信箱';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新语音留言。点击拨打语音信箱',
      one: '1 条新语音留言。点击拨打语音信箱',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => '离开';

  @override
  String get shellStatusTooltip => '您的状态';

  @override
  String get shellDemoBanner => '演示模式：通话为模拟，不会连接真实网络。';

  @override
  String get uiToday => '今天';

  @override
  String get uiYesterday => '昨天';

  @override
  String get uiUnknownCaller => '未知来电者';

  @override
  String get uiCallEnded => '通话已结束';

  @override
  String get uiCallTransferNotConfirmed => '转接未确认';

  @override
  String get uiCallTransferring => '正在转接…';

  @override
  String get uiCallConference => '会议';

  @override
  String get uiCallOnHold => '保持中';

  @override
  String get uiCallHeldByRemote => '对方已保持';

  @override
  String get uiCallCalling => '正在呼叫…';

  @override
  String get uiCallRinging => '对方响铃中…';

  @override
  String get uiCallConnecting => '正在连接…';

  @override
  String get uiCallIncoming => '来电';

  @override
  String get uiCallConnected => '已接通';

  @override
  String get uiQrScanTitle => '扫描二维码';

  @override
  String get uiQrPasteHint => '粘贴二维码文本';

  @override
  String get uiQrNoCamera => '此设备不支持摄像头扫描。请改为粘贴二维码文本。';

  @override
  String get uiQrPaste => '粘贴';

  @override
  String get uiQrUse => '使用';

  @override
  String get uiQrCameraDenied => '摄像头权限已关闭。请在系统设置中允许，或在下方粘贴二维码文本。';

  @override
  String get uiQrCameraUnavailable => '摄像头不可用。请在下方粘贴二维码文本。';

  @override
  String get presenceLampRinging => '响铃中';

  @override
  String get presenceHeader => '忙线指示灯';

  @override
  String get presenceChooseTooltip => '选择要监视的联系人';

  @override
  String get presenceEmptyTitle => '面板上暂无分机';

  @override
  String get presenceEmptySubtitle => '为联系人开启“在 BLF 面板上显示”，即可查看其空闲、响铃或忙线状态。';

  @override
  String get presenceOpenContacts => '打开联系人';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name，$status。点按拨打，长按查看更多';
  }

  @override
  String presenceCallName(String name) {
    return '呼叫 $name';
  }

  @override
  String get presencePickup => '代接此分机';

  @override
  String get presencePickupSub => '接听其正在响铃的来电（定向代接）';

  @override
  String get presenceTransferHere => '将当前通话转接到此处';

  @override
  String get presenceRemove => '从面板移除';

  @override
  String get uiCall => '呼叫';

  @override
  String get uiMessage => '消息';

  @override
  String get recentsSearchTooltip => '搜索记录';

  @override
  String get recentsClearTitle => '清除通话记录？';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将删除全部 $count 条记录。',
      one: '将删除 1 条记录。',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => '记录已以 CSV 格式复制到剪贴板';

  @override
  String get recentsMenuCopyCsv => '复制为 CSV';

  @override
  String get recentsMenuClear => '清除记录';

  @override
  String get recentsSearchHint => '搜索姓名或号码';

  @override
  String get recentsFilterAll => '全部';

  @override
  String get recentsFilterMissed => '未接';

  @override
  String get recentsFilterIncoming => '来电';

  @override
  String get recentsFilterOutgoing => '去电';

  @override
  String get recentsFilterAccount => '按账户筛选';

  @override
  String get recentsAllAccounts => '所有账户';

  @override
  String get recentsAccountFallback => '账户';

  @override
  String get recentsEmptyNone => '暂无通话';

  @override
  String get recentsEmptyNoMatch => '没有匹配的通话';

  @override
  String get recentsEmptyNoneSub => '您的通话将显示在这里。';

  @override
  String get recentsEmptyNoMatchSub => '请尝试其他筛选条件。';

  @override
  String get recentsOpenKeypad => '打开拨号盘';

  @override
  String get recentsShowAll => '显示全部';

  @override
  String get recentsSelectCall => '选择一个通话';

  @override
  String get recentsSelectCallSub => '详情、质量和录音将显示在这里。';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': '未接来电',
      'incoming': '来电',
      'other': '去电',
    });
    return '$_temp0 $name，$number，$time';
  }

  @override
  String recentsCallTooltip(String name) {
    return '呼叫 $name';
  }

  @override
  String get recentsAddAccountToMessage => '添加账户后才能发送消息';

  @override
  String get recentsAddContact => '添加联系人';

  @override
  String get recentsContact => '联系人';

  @override
  String get recentsBlock => '屏蔽';

  @override
  String get recentsUnblock => '取消屏蔽';

  @override
  String recentsBlockTitle(String number) {
    return '屏蔽 $number？';
  }

  @override
  String get recentsBlockMessage => '来自该号码的来电将被自动拒接。';

  @override
  String get recentsQualityHeader => '通话质量';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return '最差 MOS $mos   ·   抖动 $jitter ms   ·   丢包 $loss %';
  }

  @override
  String get recentsRecordingsHeader => '录音';

  @override
  String get recentsOpenInRecordings => '在录音中打开';

  @override
  String recentsRelatedCall(String title) {
    return '相关通话：$title';
  }

  @override
  String get recentsHistoryHeader => '记录';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => '与该号码没有通话';

  @override
  String get recentsDeleteTitle => '删除这些通话？';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将移除 $name 的 $count 条记录。',
      one: '将移除 $name 的 1 条记录。',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => '从记录中删除';

  @override
  String get recentsCallDetails => '通话详情';

  @override
  String get contactsFavoritesHeader => '★ 收藏';

  @override
  String get contactsFavoritesOnly => '仅显示收藏';

  @override
  String get contactsShowAll => '显示全部';

  @override
  String get contactsImportExportTooltip => '导入和导出';

  @override
  String get contactsMenuDevice => '从设备导入';

  @override
  String get contactsMenuFile => '导入 vCard / CSV 文件';

  @override
  String get contactsMenuClipboard => '从剪贴板导入';

  @override
  String get contactsMenuCopyVcard => '复制为 vCard';

  @override
  String get contactsMenuCopyCsv => '复制为 CSV';

  @override
  String get contactsNewTooltip => '新建联系人';

  @override
  String get contactsSearchHint => '搜索联系人';

  @override
  String get contactsEmptyTitle => '暂无联系人';

  @override
  String get contactsEmptySubtitle => '添加常联系的人，或导入 vCard 或 CSV 文件。';

  @override
  String get contactsEmptyAction => '添加联系人';

  @override
  String get contactsNoMatches => '无匹配结果';

  @override
  String contactsCallName(String name) {
    return '呼叫 $name';
  }

  @override
  String get contactsSelect => '选择一位联系人';

  @override
  String get contactsCopiedVcard => '联系人已以 vCard 格式复制';

  @override
  String get contactsCopiedCsv => '联系人已以 CSV 格式复制';

  @override
  String get contactsDeviceDenied => '联系人访问权限被拒绝。请在系统设置中允许后再导入。';

  @override
  String get contactsDeviceNone => '此设备上未找到联系人';

  @override
  String contactsNothingNew(int count) {
    return '没有可导入的新内容（已有 $count 个）';
  }

  @override
  String get contactsImportDeviceTitle => '从设备导入？';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 位新联系人',
      one: '1 位新联系人',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count 位已补充更多号码';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count 位已跳过（重复或无电话号码）';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 位联系人',
      one: '已导入 1 位联系人',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => '该数据中未找到联系人';

  @override
  String get contactsLabelMobile => '手机';

  @override
  String get contactsLabelWork => '工作';

  @override
  String get contactsLabelHome => '住宅';

  @override
  String get contactsLabelOther => '其他';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => '未找到联系人';

  @override
  String get contactsActionFavorite => '收藏';

  @override
  String get contactsNumbersHeader => '号码';

  @override
  String get contactsSipAddress => 'SIP 地址';

  @override
  String get contactsDetailsHeader => '详情';

  @override
  String get contactsOnBlf => '已显示在 BLF 面板上';

  @override
  String get contactsAlwaysRecorded => '始终录音';

  @override
  String contactsDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String get contactsDeleteMessage => '该联系人将从此设备中移除。';

  @override
  String get contactsDeleteButton => '删除联系人';

  @override
  String get contactsDetailTitle => '联系人';

  @override
  String get contactsErrorNameOrNumber => '请输入姓名或号码';

  @override
  String get contactsEditTitle => '编辑联系人';

  @override
  String get contactsFieldName => '姓名';

  @override
  String get contactsFieldCompany => '公司';

  @override
  String get contactsFieldNumber => '号码';

  @override
  String get contactsRemoveNumber => '移除号码';

  @override
  String get contactsAddNumber => '添加号码';

  @override
  String get contactsSipHeader => 'SIP 地址';

  @override
  String get contactsRemoveAddress => '移除地址';

  @override
  String get contactsAddSip => '添加 SIP 地址';

  @override
  String get contactsFieldEmail => '电子邮件';

  @override
  String get contactsFieldNotes => '备注';

  @override
  String get contactsFieldFavorite => '收藏';

  @override
  String get contactsShowOnBlf => '在 BLF 面板上显示';

  @override
  String get contactsShowOnBlfSub => '监视该分机的在线状态和忙线指示灯';

  @override
  String get contactsAlwaysRecordTitle => '始终录制与此联系人的通话';

  @override
  String get contactsAlwaysRecordSub => '优先于自动录音规则';

  @override
  String get contactsRingtone => '铃声';

  @override
  String get contactsPresenceVia => '在线状态使用的账户';

  @override
  String get contactsDefaultAccount => '默认账户';

  @override
  String get contactsDeleteContactTitle => '删除联系人？';

  @override
  String get contactsCannotUndo => '此操作无法撤销。';

  @override
  String get messagesNewMessage => '新消息';

  @override
  String get messagesNumberOrSip => '号码或 SIP 地址';

  @override
  String get messagesNoConversations => '暂无会话';

  @override
  String get messagesEmptySubtitle => '向您账户上的任意分机或地址发送 SIP 消息。';

  @override
  String get messagesTyping => '正在输入…';

  @override
  String get messagesYouPrefix => '您：';

  @override
  String get messagesSelect => '选择一个会话';

  @override
  String get messagesLanOnline => '在您的网络中在线';

  @override
  String get messagesLanOffline => '离线。对方上线后将发送消息。';

  @override
  String messagesSendFileTo(String name) {
    return '向 $name 发送文件';
  }

  @override
  String messagesCallName(String name) {
    return '呼叫 $name';
  }

  @override
  String get messagesDeleteTitle => '删除会话？';

  @override
  String messagesDeleteMessage(String name) {
    return '与 $name 的所有消息都将被移除。';
  }

  @override
  String get messagesDeleteMenu => '删除会话';

  @override
  String get messagesSayHello => '打个招呼吧';

  @override
  String get messagesLanEmptySub => '消息通过您的网络直接发送到此设备，并经端到端加密。';

  @override
  String get messagesSipEmptySub => '消息通过您的账户以 SIP MESSAGE 发送。';

  @override
  String get messagesInputHint => '消息';

  @override
  String get messagesSend => '发送';

  @override
  String get messagesStatusSending => '发送中';

  @override
  String get messagesStatusSent => '已发送';

  @override
  String get messagesStatusDelivered => '已送达';

  @override
  String get messagesStatusRead => '已读';

  @override
  String get messagesStatusFailed => '失败';

  @override
  String get messagesNotDelivered => '未送达。点按重试';

  @override
  String get uiStatusRegistered => '已注册';

  @override
  String get uiStatusRegistering => '注册中';

  @override
  String get uiStatusRegFailed => '注册失败';

  @override
  String get uiStatusDisabled => '已停用';

  @override
  String get uiQualityMeasuring => '测量中';

  @override
  String get uiQualityExcellent => '极佳';

  @override
  String get uiQualityGood => '良好';

  @override
  String get uiQualityFair => '一般';

  @override
  String get uiQualityPoor => '较差';

  @override
  String get uiQualityBad => '很差';

  @override
  String uiQualitySemantics(String label) {
    return '通话质量$label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return '通话质量$label，MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return '通话质量：$label';
  }

  @override
  String get uiSecureFull => '已加密';

  @override
  String get uiSecureMedia => '媒体已加密';

  @override
  String get uiSecureSignalling => '信令已加密';

  @override
  String get uiSecureNone => '未加密';

  @override
  String get uiSecureSrtpLine => 'SRTP 媒体';

  @override
  String get uiSecureTlsLine => 'TLS 信令';

  @override
  String lanCallHandingOver(String name) {
    return '正在移交给 $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return '对讲至 $name';
  }

  @override
  String get lanCallIntercomToUnnamed => '对讲至附近设备';

  @override
  String lanCallIntercomFromNamed(String name) {
    return '来自 $name 的对讲';
  }

  @override
  String get lanCallIntercomFromUnnamed => '来自附近设备的对讲';

  @override
  String lanCallToNamed(String name) {
    return 'LAN 呼叫 $name';
  }

  @override
  String get lanCallToUnpaired => 'LAN 呼叫未配对设备';

  @override
  String lanCallFromNamed(String name) {
    return '来自 $name 的 LAN 呼叫';
  }

  @override
  String get lanCallFromUnpaired => '来自未配对设备的 LAN 呼叫';

  @override
  String lanHandoffTransferredFrom(String device) {
    return '从 $device 转来的通话';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return '从 $device 转来的通话：$caller';
  }

  @override
  String get lanHandoffAnotherDevice => '其他设备';

  @override
  String lanRelayedTitle(String name) {
    return '已中转给 $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return '来电者正在与 $name 通话。您已不在通话中。';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return '正在呼叫 $name…';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return '$name 接听期间，来电者保持连接。';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return '正在询问 $name…';
  }

  @override
  String get lanRelayOfferingSubtitle => '等待对方接受通话。';

  @override
  String lanRelayConsultingTitle(String name) {
    return '正在与 $name 沟通';
  }

  @override
  String get lanRelayConsultingSubtitle => '来电者已被保持。准备好后请完成移交。';

  @override
  String get lanRelayTakingBack => '正在收回通话…';

  @override
  String get lanRelayTakeBack => '收回';

  @override
  String get lanRelayEnd => '结束';

  @override
  String get lanSendToDevice => '发送到设备';

  @override
  String get lanBusy => '忙线';

  @override
  String get lanNoPairedOnline => '没有在线的已配对设备';

  @override
  String lanPairRejectedBy(String name) {
    return '$name 拒绝了配对。';
  }

  @override
  String get lanPairRejected => '配对被拒绝。';

  @override
  String get lanPairCancelled => '配对已取消。';

  @override
  String get lanPairTimedOut => '配对超时。请重试。';

  @override
  String get lanPairFailed => '配对失败';

  @override
  String lanPairFailedReason(String reason) {
    return '配对失败：$reason';
  }

  @override
  String get lanPairThisDevice => '此设备';

  @override
  String get lanPairConnecting => '正在安全连接…';

  @override
  String lanPairWantsToPair(String name) {
    return '$name 想与此设备配对。';
  }

  @override
  String lanPairPairingWith(String name) {
    return '正在与 $name 配对。';
  }

  @override
  String get lanPairCheckCode => '请确认两台设备屏幕上的代码一致。';

  @override
  String lanPairCodeSemantics(String code) {
    return '配对码 $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return '等待 $name 确认…';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name 已确认。';
  }

  @override
  String get lanPairReject => '拒绝';

  @override
  String get lanPairCodesMatch => '代码一致';

  @override
  String lanPairPairedWith(String name) {
    return '已与 $name 配对。';
  }

  @override
  String get lanPairRequestTitle => '配对请求';

  @override
  String lanPairTitle(String name) {
    return '与 $name 配对';
  }

  @override
  String get lanActionDecline => '拒绝';

  @override
  String get lanActionAccept => '接受';

  @override
  String get lanFileIncomingTitle => '收到文件';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size，来自 $name';
  }

  @override
  String get lanHandoffOfferTitle => '将通话转到此处？';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': '（来电者：$caller）',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': '，账户：$account',
    });
    return '$device 想把一个通话转交给您$_temp0$_temp1。';
  }

  @override
  String get lanHandoffOfferAttended => '对方会先与您沟通。';

  @override
  String get lanHandoffTakeCall => '接管通话';

  @override
  String lanIntercomRequestTitle(String name) {
    return '允许 $name 对讲？';
  }

  @override
  String get lanIntercomRequestBody => '其呼叫将自动以免提方式接听。';

  @override
  String get lanIntercomDeny => '拒绝';

  @override
  String get lanIntercomAllow => '允许';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name 已将此设备从其配对列表中移除';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在发送 $count 个文件…',
      one: '正在发送 $name…',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => '新消息';

  @override
  String get lanSipMessage => 'SIP 消息';

  @override
  String get lanSipMessageSub => '通过您的账户发送到号码或地址';

  @override
  String get lanChatOnline => 'LAN 聊天，在线';

  @override
  String get lanChatOffline => 'LAN 聊天，离线';

  @override
  String lanSavedAt(String path) {
    return '已保存到 $path（路径已复制）';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => '您的设备，直接对话';

  @override
  String get lanConnectByAddress => '通过地址连接';

  @override
  String get lanSettingsTooltip => 'LAN 设置';

  @override
  String get lanOffTitle => 'LAN Link 已关闭';

  @override
  String get lanOffSubtitle => '无需任何服务器，即可发现您的其他 SoftphonePro 设备、聊天、传送文件和移交通话。';

  @override
  String get lanTurnOn => '开启 LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'LAN Link 无法启动：$error';
  }

  @override
  String get lanConnectHelp => '输入 主机:端口，或粘贴另一台设备上显示的二维码文本。';

  @override
  String get lanScanTitle => '扫描 LAN 配对二维码';

  @override
  String get lanScanQr => '扫描二维码';

  @override
  String get lanPaste => '粘贴';

  @override
  String get lanConnect => '连接';

  @override
  String lanConnectedTo(String name) {
    return '已连接到 $name';
  }

  @override
  String get lanCouldNotConnect => '无法连接';

  @override
  String get lanCouldNotStartPairing => '无法开始配对';

  @override
  String get lanThisDevice => '本设备';

  @override
  String get lanDeviceNameTitle => '设备名称';

  @override
  String get lanStarting => '正在启动…';

  @override
  String get lanVisible => '在您的网络中可见';

  @override
  String get lanNotRunning => '未运行';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已共享 $count 个账户',
      one: '已共享 1 个账户',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => '指纹';

  @override
  String get lanHideQr => '隐藏二维码';

  @override
  String get lanShowQr => '显示二维码以连接其他设备';

  @override
  String get lanCopyConnectionText => '复制连接文本';

  @override
  String get lanConnectionTextCopied => '连接文本已复制';

  @override
  String get lanActiveOnOthers => '在您的其他设备上进行中';

  @override
  String get lanPairedDevices => '已配对设备';

  @override
  String get lanNoPaired => '暂无已配对设备。配对附近的设备后即可聊天、传送文件和移交通话。';

  @override
  String get lanNearby => '附近';

  @override
  String get lanNearbyHint =>
      '正在您的网络中查找 SoftphonePro。其他设备需开启 LAN Link。您也可以使用上方的链接按钮通过地址连接。';

  @override
  String get lanTransfers => '传输';

  @override
  String get lanFiles => '文件';

  @override
  String get lanPairedBadge => '已配对';

  @override
  String get lanTyping => '正在输入…';

  @override
  String get lanPair => '配对';

  @override
  String get lanUnpair => '取消配对';

  @override
  String lanUnpairTitle(String name) {
    return '取消与 $name 的配对？';
  }

  @override
  String get lanUnpairMessage => '之后需重新配对，才能聊天、传送文件或移交通话。';

  @override
  String get lanActionMessage => '消息';

  @override
  String get lanActionSendFile => '发送文件';

  @override
  String get lanActionCall => '呼叫';

  @override
  String get lanActionIntercom => '对讲';

  @override
  String lanRemoteActiveOn(String device) {
    return '正在 $device 上进行';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return '正在 $device 上进行  ·  $account';
  }

  @override
  String get lanPull => '接管';

  @override
  String get lanTransferPreparing => '准备中…';

  @override
  String get lanTransferWaitingYou => '等待您处理';

  @override
  String lanTransferWaitingPeer(String name) {
    return '等待 $name 接受';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get lanTransferVerifying => '正在校验…';

  @override
  String lanTransferFrom(String name, String status) {
    return '来自 $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return '发往 $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  来自 $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  发往 $name';
  }

  @override
  String lanFileFailed(String error) {
    return '失败：$error';
  }

  @override
  String get lanFileActions => '文件操作';

  @override
  String get lanPathCopied => '路径已复制';

  @override
  String get lanFileOpen => '打开';

  @override
  String get lanFileShowInFolder => '在文件夹中显示';

  @override
  String get lanFileCopyPath => '复制路径';

  @override
  String lanNetworkError(String message) {
    return '网络错误：$message';
  }

  @override
  String get lanErrNotRunning => '请先开启 LAN Link';

  @override
  String get lanErrBadAddress => '请输入类似 192.168.1.20:4711 的地址，或粘贴二维码文本';

  @override
  String get lanErrFingerprint => '该设备与扫描的二维码不符。二维码是否来自另一台设备？';

  @override
  String lanNoticeReceived(String file, String name) {
    return '已从 $name 收到 $file';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '已向 $name 发送 $file';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name 拒绝了 $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return '文件传输失败：$error';
  }

  @override
  String get lanNoticeNeedLanOn => '请开启 LAN Link 以呼叫附近的设备';

  @override
  String get lanNoticePairFirst => '请先与该设备配对';

  @override
  String lanNoticeNotReachable(String name) {
    return '目前无法通过呼叫联系到 $name';
  }

  @override
  String lanNoticeAsking(String name) {
    return '正在询问 $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name 未允许对讲（或未应答）';
  }

  @override
  String get lanHoOff => 'LAN Link 已关闭';

  @override
  String get lanHoPairFirst => '请先与该设备配对';

  @override
  String lanHoOffline(String name) {
    return '$name 已离线';
  }

  @override
  String get lanHoAlready => '此通话正在移交中';

  @override
  String get lanHoEnded => '通话已结束';

  @override
  String get lanHoWaitConnected => '请等待通话接通';

  @override
  String get lanHoLanCall => 'LAN 通话无法移交';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name 无法通过网络接听通话（该设备已关闭 LAN 呼叫）';
  }

  @override
  String get lanHoNoLanHere => '此设备不支持 LAN 呼叫';

  @override
  String lanHoDeclined(String name) {
    return '$name 拒绝了通话。通话仍保留在您这里。';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name 没有响应。通话仍保留在您这里。';
  }

  @override
  String get lanHoCancelled => '移交已取消。通话仍保留在您这里。';

  @override
  String lanHoUnreachable(String name) {
    return '无法联系到 $name。通话仍保留在您这里。';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return '无法联系到 $name（$reason）。通话仍保留在您这里。';
  }

  @override
  String get lanHoEndedBefore => '通话在移交前已结束';

  @override
  String lanHoPbxRefused(String name) {
    return '电话系统拒绝了转接，且 $name 无法接听 LAN 通话';
  }

  @override
  String get lanHoPbxFailedRelaying => '通过电话系统转接失败。改为通过网络中转。';

  @override
  String lanHoSentTo(String name) {
    return '通话已发送给 $name';
  }

  @override
  String get lanHoConsultFailed => '无法通过电话系统呼叫另一台设备';

  @override
  String lanHoNoLongerReachable(String name) {
    return '已无法联系到 $name';
  }

  @override
  String get lanHoCouldNotAnswer => '无法接听通话以进行移交';

  @override
  String lanHoCouldNotCall(String name) {
    return '无法通过网络呼叫 $name。通话仍保留在您这里。';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name 未接听。通话仍保留在您这里。';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return '已移交给 $name';
  }

  @override
  String lanHoRelayed(String name) {
    return '通话已中转给 $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return '请先等待 $name 接听';
  }

  @override
  String get lanHoFailed => '移交失败';

  @override
  String lanHoTakenBack(String name) {
    return '已从 $name 收回通话';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name 已结束沟通。通话已回到您这里。';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return '无法将通话移交给 $name';
  }

  @override
  String get diagSip400Explain => '服务器无法理解该请求。';

  @override
  String get diagSip400Fix => '请检查账户设置（域名、用户名、代理）。如果问题持续，请将 SIP 跟踪发送给您的服务商。';

  @override
  String get diagSip401Explain => '服务器拒绝了凭据（或正在要求提供凭据）。';

  @override
  String get diagSip401Fix => '请检查用户名、认证用户名和密码。有些服务商使用单独的“认证 ID”。';

  @override
  String get diagSip403Explain => '服务器理解该请求但拒绝执行：密码错误、账户已停用，或您的 IP 不被允许。';

  @override
  String get diagSip403Fix =>
      '请重新输入密码，确认账户处于启用状态，并确认您的公网 IP 未被拦截（fail2ban/ACL）。';

  @override
  String get diagSip404Explain => '服务器不认识此用户或号码。';

  @override
  String get diagSip404Fix => '请检查用户名和域名；拨打电话时，请检查所拨号码和拨号规则。';

  @override
  String get diagSip405Explain => '服务器不支持此请求。';

  @override
  String get diagSip405Fix =>
      '对于 OPTIONS 探测通常无害。对于 REGISTER，请确认连接的是 SIP 注册服务器。';

  @override
  String get diagSip407Explain => '出站代理需要凭据。';

  @override
  String get diagSip407Fix => '请检查账户密码和出站代理设置。';

  @override
  String get diagSip408Explain => '服务器未在规定时间内响应。';

  @override
  String get diagSip408Fix =>
      '请检查服务器地址和端口、防火墙，并尝试 TCP 或 TLS。仅在 UDP 上反复超时可能意味着路由器启用了 SIP ALG。';

  @override
  String get diagSip410Explain => '该号码已不存在。';

  @override
  String get diagSip410Fix => '请检查所拨号码。';

  @override
  String get diagSip415Explain => '对方不接受所提供的内容类型或编解码器。';

  @override
  String get diagSip415Fix => '请在“设置 > 编解码器”中启用更多编解码器（例如 PCMU/PCMA）。';

  @override
  String get diagSip421Explain => '服务器要求使用此客户端未提供的 SIP 扩展。';

  @override
  String get diagSip421Fix => '请检查账户的 NAT/ICE/100rel/计时器选项。';

  @override
  String get diagSip423Explain => '注册有效期短于服务器允许的时长。';

  @override
  String get diagSip423Fix => '请在账户设置中增大注册有效期。';

  @override
  String get diagSip480Explain => '该用户未注册或当前无法联系到。';

  @override
  String get diagSip480Fix => '请确认对方已注册；如果是在注册时出现，服务器可能过载：请稍后重试。';

  @override
  String get diagSip481Explain => '服务器丢失了对话状态（例如重启或网络变化后）。';

  @override
  String get diagSip481Fix => '请挂断后重试。如果经常发生，请启用会话计时器。';

  @override
  String get diagSip483Explain => '请求在服务器之间循环转发。';

  @override
  String get diagSip483Fix => '请检查 PBX 上的呼叫转移和路由配置。';

  @override
  String get diagSip484Explain => '所拨号码过短。';

  @override
  String get diagSip484Fix => '请拨打完整号码或检查拨号规则。';

  @override
  String get diagSip486Explain => '对方正忙。';

  @override
  String get diagSip486Fix => '请稍后再试。';

  @override
  String get diagSip487Explain => '通话在被接听前已取消。';

  @override
  String get diagSip487Fix => '主叫方在响铃时挂断属于正常情况。';

  @override
  String get diagSip488Explain => '与对方没有共同的编解码器或加密设置。';

  @override
  String get diagSip488Fix => '请检查编解码器和 SRTP（要求 SRTP 的账户无法呼叫仅支持普通 RTP 的终端）。';

  @override
  String get diagSip491Explain => '两个 re-INVITE 发生冲突。';

  @override
  String get diagSip491Fix => '通常会自动重试。';

  @override
  String get diagSip500Explain => '服务器内部出错。';

  @override
  String get diagSip500Fix => '请稍后重试，如果持续出现请联系服务商。';

  @override
  String get diagSip502Explain => '上游服务器返回了无效响应。';

  @override
  String get diagSip502Fix => '请稍后重试；如果持续出现请联系服务商。';

  @override
  String get diagSip503Explain => '服务器过载、已宕机，或正在拒绝此客户端（速率限制）。';

  @override
  String get diagSip503Fix => '请等待后重试，查看服务商状态页面，或尝试其他服务器/端口。';

  @override
  String get diagSip504Explain => '上游服务器未在规定时间内响应。';

  @override
  String get diagSip504Fix => '请稍后重试。';

  @override
  String get diagSip600Explain => '所有目的地均忙线。';

  @override
  String get diagSip600Fix => '请稍后再试。';

  @override
  String get diagSip603Explain => '对方拒绝了通话。';

  @override
  String get diagSip603Fix => '无需修复：通话已被拒接。';

  @override
  String get diagSip604Explain => '该号码不存在。';

  @override
  String get diagSip604Fix => '请检查所拨号码。';

  @override
  String get diagSip606Explain => '对方无法接受所提议的会话。';

  @override
  String get diagSip606Fix => '请检查编解码器和加密设置。';

  @override
  String diagSipProvisionalTitle(int code) {
    return '临时响应（$code）';
  }

  @override
  String get diagSipProvisionalExplain => '请求正在处理中。';

  @override
  String diagSipSuccessTitle(int code) {
    return '成功（$code）';
  }

  @override
  String get diagSipSuccessExplain => '请求成功。';

  @override
  String diagSipRedirectedTitle(int code) {
    return '已重定向（$code）';
  }

  @override
  String get diagSipRedirectedExplain => '目的地已迁移。';

  @override
  String get diagSipRedirectedFix => '请检查呼叫转移设置。';

  @override
  String diagSipClientErrorTitle(int code) {
    return '客户端错误（$code）';
  }

  @override
  String get diagSipClientErrorExplain => '服务器拒绝了该请求。';

  @override
  String get diagSipClientErrorFix => '请检查账户和所拨号码。';

  @override
  String diagSipServerErrorTitle(int code) {
    return '服务器错误（$code）';
  }

  @override
  String get diagSipServerErrorExplain => '服务器处理请求失败。';

  @override
  String get diagSipServerErrorFix => '请稍后重试或联系服务商。';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return '全局失败（$code）';
  }

  @override
  String get diagSipGlobalFailureExplain => '该请求在任何地方都无法完成。';

  @override
  String get diagSipNoResponseTitle => '无响应';

  @override
  String get diagSipNoResponseExplain => '未收到 SIP 响应。';

  @override
  String get diagSipNoResponseFix => '请检查网络连接和服务器地址。';

  @override
  String get diagWizStepNet => '网络连通性';

  @override
  String diagWizStepDns(String account) {
    return 'DNS 与 SRV：$account';
  }

  @override
  String get diagWizStepNat => 'NAT 类型';

  @override
  String diagWizStepOptions(String account) {
    return '服务器可达性：$account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'TLS 证书：$account';
  }

  @override
  String diagWizStepReg(String account) {
    return '注册：$account';
  }

  @override
  String get diagWizStepAlg => 'SIP ALG 检查';

  @override
  String get diagWizChecking => '正在检查…';

  @override
  String diagWizEngineError(String message) {
    return '引擎错误：$message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return '检查失败：$error';
  }

  @override
  String get diagWizNoEngine => 'SIP 引擎未运行';

  @override
  String get diagWizNoEngineFix => '请等待引擎启动（或重启应用），然后重新运行检查。';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface：$address（私有）';
  }

  @override
  String get diagWizNetNone => '没有带 IP 地址的活动网络接口';

  @override
  String get diagWizNetNoneFix => '请连接 Wi-Fi、以太网或移动数据，然后重新运行检查。';

  @override
  String get diagWizNetIpv6Only => '仅发现 IPv6 地址';

  @override
  String get diagWizNetIpv6OnlyFix =>
      '许多 SIP 服务商仅支持 IPv4。请在此网络上启用 IPv4，或使用支持 IPv6 的服务商。';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces 个接口',
      one: '1 个接口',
    );
    String _temp1 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 个 IPv4 地址',
      one: '1 个 IPv4 地址',
    );
    return '$_temp0上共有 $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      '检测到 VPN 类接口处于活动状态。VPN 可能增加延迟或阻止 UDP；如果通话异常，请将其关闭。';

  @override
  String get diagWizDnsNoServer => '该账户没有服务器地址';

  @override
  String get diagWizDnsNoServerFix => '请编辑账户并输入 SIP 域名。';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host 是 IP 地址，无需 DNS';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA：无';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA：无（$error）';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name：无';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name：$target:$port（优先级 $priority，权重 $weight）';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport：查询失败（$error）';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host 无法解析';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      '请检查域名是否拼写有误，以及您的 DNS 服务器是否正常。您可以在“设置 > 网络”中设置自定义 DNS 服务器（例如 8.8.8.8）。';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host 有 SRV 记录但没有地址记录';
  }

  @override
  String get diagWizDnsSrvOnlyFix => '将使用 SRV 目标。如果通话失败，请让服务商检查 A 记录。';

  @override
  String diagWizDnsResolves(String host, String address, int more, int srv) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '（另有 $more 个）',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      srv,
      locale: localeName,
      other: '，$srv 条 SRV 记录',
      one: '，1 条 SRV 记录',
      zero: '',
    );
    return '$host 解析为 $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'NAT 检测超时';

  @override
  String get diagWizNatTimeoutFix =>
      'STUN 服务器可能无法访问（UDP 被阻止？）。请检查“设置 > 网络 > STUN 服务器”。';

  @override
  String diagWizNatStun(String server) {
    return 'STUN 服务器：$server';
  }

  @override
  String get diagWizNatOpen => '无 NAT：此设备拥有公网地址';

  @override
  String get diagWizNatFullCone => '完全锥形 NAT：对 VoIP 友好';

  @override
  String get diagWizNatRestricted => '受限锥形 NAT：配合 STUN 和保活可正常工作';

  @override
  String get diagWizNatPortRestricted => '端口受限锥形 NAT：配合 STUN 和保活可正常工作';

  @override
  String get diagWizNatSymmetric => '对称 NAT：仅靠 STUN 无法预测媒体端口';

  @override
  String get diagWizNatSymmetricFix =>
      '部分通话可能出现单向音频或无声。请在账户设置（账户 > NAT）中启用 ICE 和 TURN 中继，或使用带媒体中继（rtpengine）的服务商/PBX。';

  @override
  String get diagWizNatBlocked => 'UDP 似乎被阻止';

  @override
  String get diagWizNatBlockedFix =>
      '请为该账户使用 TCP 或 TLS 传输。如果网络仅放行网页流量，且服务商支持，请尝试使用 443 端口的 TLS。';

  @override
  String get diagWizNatUnknown => '无法确定 NAT 类型';

  @override
  String get diagWizNatUnknownFix => 'STUN 服务器未响应。请在“设置 > 网络”中尝试其他 STUN 服务器。';

  @override
  String get diagWizNatErr => 'STUN 服务器未响应，因此无法确定 NAT 类型。';

  @override
  String get diagWizNatUnknownRaw => '无法确定 NAT 类型。';

  @override
  String get diagWizOptionsNotLoaded => '该账户未加载到引擎中';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return '$seconds 秒内未收到 OPTIONS 的响应（传输协议：$transport）';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      '无法连接到服务器。请检查地址和端口、防火墙是否丢弃了 SIP，并尝试其他传输协议（TCP/TLS）。';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return '请求超时（$code $reason）';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return '服务器在 $ms ms 后返回 $code $reason';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return '服务器在 $ms ms 内返回 $code $reason';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return '对 OPTIONS 返回 $code 属于正常：服务器可达，但不允许匿名探测。';
  }

  @override
  String get diagWizOptionsSlowFix =>
      '往返时延超过 300 ms 会使通话出现明显延迟。使用更近的服务器或有线连接会有所改善。';

  @override
  String get diagWizTlsRejected => '服务器证书被拒绝';

  @override
  String diagWizTlsSubject(String value) {
    return '主题：$value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return '颁发者：$value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return '问题：$value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return '到期时间：$date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return '密码套件：$cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      '如果这是您自己使用自签名证书的 PBX，且上方指纹一致，则可以信任它。否则请向服务商索取由公共 CA 签发的证书。';

  @override
  String get diagWizTlsTrust => '信任此证书';

  @override
  String diagWizTlsExpired(String date) {
    return '证书已于 $date 过期';
  }

  @override
  String get diagWizTlsExpiredFix => '请让服务器管理员更新证书。';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '证书将在 $days 天后过期',
      one: '证书将在 1 天后过期',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix => '请通知服务器管理员尽快更新。';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return '已连接，但验证报告：$problems';
  }

  @override
  String get diagWizTlsOk => 'TLS 连接已建立，证书有效';

  @override
  String get diagWizTlsRegistered => '已通过 TLS 注册（未报告证书详情）';

  @override
  String get diagWizTlsNone => '尚未观察到 TLS 连接';

  @override
  String get diagWizTlsNoneFix =>
      '请检查 TLS 端口（通常为 5061），并确认服务器接受 TLS 1.2 或更高版本。';

  @override
  String get diagWizRegDisabledByConfig => '此账户已禁用注册（点对点使用）';

  @override
  String get diagWizRegRegistered => '已注册';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return '已注册（$seconds 秒后过期）';
  }

  @override
  String diagWizRegTransport(String transport) {
    return '传输协议：$transport';
  }

  @override
  String get diagWizRegInProgress => '注册仍在进行中';

  @override
  String get diagWizRegInProgressFix =>
      '请等待几秒钟。如果始终无法完成，说明服务器没有响应；请参阅上方的可达性检查。';

  @override
  String get diagWizRegFailed => '注册失败';

  @override
  String get diagWizRegOffline => '账户处于离线状态';

  @override
  String get diagWizRegOfflineFix => '请检查网络连接。应用会自动重试。';

  @override
  String get diagWizRegDisabled => '账户已停用';

  @override
  String get diagWizAlgNoUdp => '没有账户使用 UDP，因此无需关注 SIP ALG';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account：UDP 无响应，但 TCP 有响应（$code，$ms ms）';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account：UDP 和 TCP 均无响应（更可能是服务器或防火墙问题，而非 ALG）';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account：OPTIONS 有响应但 REGISTER 超时，这是路由器改写 SIP 的典型表现';
  }

  @override
  String get diagWizAlgSuspected => '怀疑您的路由器启用了 SIP ALG';

  @override
  String get diagWizAlgSuspectedFix =>
      '请在路由器设置中关闭“SIP ALG”/“SIP helper”，或将账户切换为 TCP 或 TLS，或更改 SIP 端口（例如 5080），以免路由器篡改数据包。';

  @override
  String get diagWizAlgContactChanged => 'Contact 地址在请求与响应之间发生了变化';

  @override
  String get diagWizAlgContactChangedFix =>
      '这可能是 SIP ALG 或改写 Contact 的服务器所致。如果通话能响铃但没有声音或过一会儿就断开，请在路由器上关闭 SIP ALG，或使用 TCP/TLS 或端口 5080。';

  @override
  String get diagWizAlgOk => '未发现 SIP ALG 干扰迹象';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'REGISTER 的 Contact $sent 返回为 $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return '保存 $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return '已保存 $fileName';
  }

  @override
  String get diagSaveFailed => '无法保存文件';

  @override
  String get diagCopiedText => '文本已复制到剪贴板';

  @override
  String get diagCopiedReport => '报告已复制到剪贴板';

  @override
  String get diagCopiedBundle => '诊断包已复制到剪贴板';

  @override
  String get diagCopiedLogs => '日志已复制到剪贴板';

  @override
  String get diagCopiedTrace => '跟踪已复制到剪贴板';

  @override
  String get diagCopiedDialog => '对话已复制到剪贴板';

  @override
  String get diagSaveAsLog => '另存为 .log';

  @override
  String get diagSysAppVersion => '应用版本';

  @override
  String get diagSysPlatform => '平台';

  @override
  String get diagSysEngine => '引擎';

  @override
  String get diagSysAccounts => '账户';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered/$total 已注册';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return '无法读取系统信息：$error';
  }

  @override
  String get diagSysTransports => '传输协议';

  @override
  String get diagSysNoneReported => '无报告';

  @override
  String get diagSysCodecs => '编解码器';

  @override
  String get diagSysCodecsFooter => '已启用的编解码器，优先级由高到低。';

  @override
  String get diagSysEngineNotRunning => '引擎未运行';

  @override
  String diagSysCodecPriority(int priority) {
    return '优先级 $priority';
  }

  @override
  String get diagSysCodecDisabled => '已停用';

  @override
  String get diagSysExport => '导出';

  @override
  String get diagSysExportFooter => '诊断包包含系统信息、网络检查结果、最近日志和 SIP 跟踪，其中的凭据已被隐去。';

  @override
  String get diagSysCopyBundle => '复制诊断包';

  @override
  String get diagSysSaveBundle => '保存诊断包';

  @override
  String get diagTabSipTrace => 'SIP 跟踪';

  @override
  String get diagTabNetwork => '网络';

  @override
  String get diagTabQuality => '质量';

  @override
  String get diagTabAudioTest => '音频测试';

  @override
  String get diagTabLogs => '日志';

  @override
  String get diagTabSystem => '系统';

  @override
  String diagRawSentTo(String remote) {
    return '发送至 $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return '接收自 $remote';
  }

  @override
  String get diagRawCopied => '消息已复制';

  @override
  String get diagRawLadder => '梯形图';

  @override
  String get diagRawRedact => '隐去凭据';

  @override
  String diagRawTruncated(int count) {
    return '…… 已截断（$count 个字符）';
  }

  @override
  String get diagWizIntro => '检查您的连接、DNS、NAT、服务器可达性、TLS 和注册，并说明需要修复的问题。';

  @override
  String get diagWizStop => '停止';

  @override
  String get diagWizRunChecks => '开始检查';

  @override
  String get diagWizRunAgain => '重新运行';

  @override
  String get diagWizCopyReport => '复制报告';

  @override
  String get diagWizSaveReport => '保存报告';

  @override
  String diagWizCountPassed(int count) {
    return '通过 $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return '警告 $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return '失败 $count';
  }

  @override
  String get diagWizStatusPass => '通过';

  @override
  String get diagWizStatusWarn => '警告';

  @override
  String get diagWizStatusFail => '失败';

  @override
  String get diagWizStatusSkipped => '已跳过';

  @override
  String get diagWizStatusRunning => '运行中';

  @override
  String get diagWizStatusPending => '等待中';

  @override
  String get diagQualityTitle => '通话质量';

  @override
  String get diagQualityNoData => '此通话未记录质量数据。';

  @override
  String get diagQualityTraceForCall => '此通话的 SIP 跟踪';

  @override
  String get diagQualityTraceNotCaptured => '未捕获此通话的 SIP 跟踪';

  @override
  String get diagQualityLiveCall => '实时通话';

  @override
  String get diagQualityNoActiveCall =>
      '当前没有进行中的通话。开始通话后，MOS、抖动、丢包和往返时延会在此实时绘制。';

  @override
  String get diagQualityRecentCalls => '最近通话';

  @override
  String get diagQualityNoFinished => '暂无带质量数据的已结束通话。';

  @override
  String get diagQualityCallEnded => '通话已结束。';

  @override
  String get diagQualityMeasuring => '测量中';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value，$quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return '$title图表';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return '$title图表，最新 $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   最大 $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return '平均 $avg  ·  最差 $worst';
  }

  @override
  String get diagQualityCodec => '编解码器';

  @override
  String get diagQualityLoss => '丢包';

  @override
  String get diagQualityJitter => '抖动';

  @override
  String diagQualityPackets(int count) {
    return '$count 包';
  }

  @override
  String get diagQualityMedia => '媒体';

  @override
  String get diagQualityNoSeries => '此通话未记录时间序列。';

  @override
  String get diagQualityPacketLoss => '丢包';

  @override
  String get diagQualityRtt => '往返时延';

  @override
  String get diagLogsForward => '转发引擎日志';

  @override
  String get diagLogsForwardSub => '将 pjsip 日志行发送到此查看器';

  @override
  String diagLogsLevel(int level, String name) {
    return '级别 $level（$name）';
  }

  @override
  String get diagLogsRedact => '导出时隐去敏感信息';

  @override
  String get diagLogsSearch => '搜索日志';

  @override
  String get diagLogsEmpty => '暂无日志。';

  @override
  String get diagLogsForwardingOff => '日志转发已关闭。开启后才能捕获引擎日志。';

  @override
  String get diagLogsNoMatch => '没有与搜索匹配的行。';

  @override
  String get diagAudioEngineNotRunning => 'SIP 引擎未运行。';

  @override
  String get diagAudioMicrophone => '麦克风';

  @override
  String get diagAudioMicFooter => '电平表读取音频设备，引擎会在通话或回声测试期间打开该设备。';

  @override
  String get diagAudioLevelMeter => '电平表';

  @override
  String get diagAudioLevelMeterSub => '说话并观察电平条的变化';

  @override
  String get diagAudioMic => '麦克风';

  @override
  String get diagAudioSpeaker => '扬声器';

  @override
  String get diagAudioEchoTest => '回声测试';

  @override
  String get diagAudioEchoFooter => '将您的声音通过扬声器回放。请使用耳机以避免啸叫。';

  @override
  String get diagAudioEchoActive => '已启用：请说话';

  @override
  String get diagAudioEchoIdle => '麦克风到扬声器回环';

  @override
  String get diagAudioSpeakerTest => '扬声器测试';

  @override
  String get diagAudioPlayTone => '播放测试音';

  @override
  String get diagAudioPlayToneSub => '通过所选扬声器播放';

  @override
  String get diagAudioPlayingDtmf => '正在播放 DTMF';

  @override
  String get diagAudioPlayingRingback => '正在播放回铃音';

  @override
  String get diagAudioRingback => '回铃音';

  @override
  String get diagAudioDevices => '设备';

  @override
  String get diagAudioChooseDevices => '选择麦克风和扬声器';

  @override
  String get diagAudioChooseDevicesSub => '打开“设置 > 音频”';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label电平 $percent%';
  }

  @override
  String get diagLadderLocal => '本地';

  @override
  String diagLadderSent(String message) {
    return '已发送 $message';
  }

  @override
  String diagLadderReceived(String message) {
    return '已接收 $message';
  }

  @override
  String get diagTraceCapture => '捕获 SIP 消息';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条消息',
      one: '1 条消息',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条消息',
      one: '1 条消息',
    );
    return '$_temp0  ·  $size  ·  已丢弃 $dropped 条较早消息';
  }

  @override
  String get diagTraceOffHint => '已关闭。开启后，再进行注册或拨打电话。';

  @override
  String get diagTraceExportOrClear => '导出或清除';

  @override
  String get diagTraceSaveAsPcap => '另存为 .pcap';

  @override
  String get diagTraceCopyAsText => '复制为文本';

  @override
  String get diagTraceSearchHint => '搜索文本、号码或 Call-ID';

  @override
  String get diagTraceErrorsOnly => '仅显示错误';

  @override
  String get diagTraceFilterMethod => '按方法筛选';

  @override
  String get diagTraceAllMethods => '所有方法';

  @override
  String get diagTraceMethod => '方法';

  @override
  String get diagTraceFilterAccount => '按账户筛选';

  @override
  String get diagTraceAllAccounts => '所有账户';

  @override
  String get diagTraceAccount => '账户';

  @override
  String get diagTraceRedact => '隐去';

  @override
  String get diagTraceList => '列表';

  @override
  String get diagTraceWaiting => '等待 SIP 流量';

  @override
  String get diagTraceWaitingSub => '注册账户或拨打电话后，消息会显示在这里。';

  @override
  String get diagTraceOff => 'SIP 跟踪已关闭';

  @override
  String get diagTraceOffSub => '开启捕获后，可以列表或梯形图查看每条 SIP 请求和响应。';

  @override
  String get diagTraceNoMatch => '没有与筛选条件匹配的消息';

  @override
  String get diagTraceAllDialogs => '所有对话';

  @override
  String get diagTraceCopyDialog => '复制此对话';

  @override
  String get diagTraceNoResponse => '无响应';

  @override
  String get diagTraceNoCallId => '无 Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条消息',
      one: '1 条消息',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => '录音';

  @override
  String get recFormatWav => '标准（WAV）';

  @override
  String get recFormatWavStereo => '立体声，您和来电者分在不同声道（WAV）';

  @override
  String get recFormatOpus => '压缩（Opus）';

  @override
  String get recFormatWavHint => '单声道，约每分钟 2 MB。可在任何设备上播放。';

  @override
  String get recFormatWavStereoHint => '双声道，约每分钟 4 MB。您在左声道，来电者在右声道。';

  @override
  String get recFormatOpusHint =>
      '约每分钟 0.2 MB。Ogg Opus 格式；iPhone、Mac 和 Windows 上的部分播放器无法打开。';

  @override
  String get recOptionInherit => '使用全局设置';

  @override
  String get recOptionAlways => '录制所有通话';

  @override
  String get recOptionIncoming => '仅录制来电';

  @override
  String get recOptionOutgoing => '仅录制去电';

  @override
  String get recOptionNever => '从不录音';

  @override
  String get recRuleAll => '所有通话';

  @override
  String get recRuleIncoming => '仅来电';

  @override
  String get recRuleOutgoing => '仅去电';

  @override
  String get recAutoDeleteNever => '从不';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天后',
      one: '1 天后',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => '1 年后';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条录音',
      one: '1 条录音',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条录音',
      one: '1 条录音',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条录音',
      one: '1 条录音',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天后',
      one: '1 天后',
    );
    return '$_temp0  ·  $size  ·  $_temp1自动删除';
  }

  @override
  String get recSettingsFormat => '格式';

  @override
  String get recSettingsAutoGroup => '自动录音';

  @override
  String get recSettingsAutoFooter =>
      '录音前请了解当地法律。在联系人中开启“始终录制与此联系人的通话”，即可无视这些规则对其通话录音。';

  @override
  String get recSettingsAutoRule => '自动录制通话';

  @override
  String get recSettingsAccountOverride => '对此账户单独设置';

  @override
  String get recSettingsNoticesGroup => '提示音';

  @override
  String get recSettingsNoticeSwitch => '录音前播放提示';

  @override
  String get recSettingsNoticeSwitchHint =>
      '先向对方播放提示音。提示音文件请在“设置 > 通话 > 提示音”中选择。';

  @override
  String get recSettingsNoticeFile => '选择提示音文件';

  @override
  String get recSettingsNoticeFileHint => '打开“设置 > 通话 > 提示音”';

  @override
  String get recSettingsBeep => '录音提示音';

  @override
  String get recSettingsBeepHint => '定期提醒对方';

  @override
  String get recSettingsTransfersGroup => '转接';

  @override
  String get recSettingsContinue => '转接期间继续录音';

  @override
  String get recSettingsContinueHint => '录制协商转接的咨询通话以及转接给我们的通话，并关联这些录音';

  @override
  String get recSettingsStorageGroup => '存储';

  @override
  String get recSettingsFolder => '文件夹';

  @override
  String get recSettingsFolderHint => '录音的保存位置';

  @override
  String get recSettingsFolderPlaceholder => '应用文档 / Recordings';

  @override
  String get recSettingsChooseFolder => '选择文件夹…';

  @override
  String get recSettingsFolderPickerTitle => '录音文件夹';

  @override
  String get recSettingsAutoDelete => '删除旧录音';

  @override
  String get recSettingsAutoDeleteHint => '启动时及每天检查一次';

  @override
  String get recSettingsManage => '管理录音';

  @override
  String get recSettingsOpenFolder => '打开录音文件夹';

  @override
  String get recPageTitle => '录音';

  @override
  String recSelectedCount(int count) {
    return '已选 $count 项';
  }

  @override
  String get recCancelSelection => '取消选择';

  @override
  String get recSelectAll => '全选';

  @override
  String get recShareSelected => '分享所选';

  @override
  String get recDeleteSelected => '删除所选';

  @override
  String get recSearchTooltip => '搜索录音';

  @override
  String get recSelectTooltip => '选择录音';

  @override
  String get recMenuSettings => '录音设置';

  @override
  String get recSearchHint => '搜索姓名或号码';

  @override
  String get recEmptyNone => '暂无录音';

  @override
  String get recEmptyNoneHint => '使用“录音”按钮录制通话，或在设置中开启自动录音。';

  @override
  String get recEmptyNoMatch => '没有匹配的录音';

  @override
  String get recEmptyNoMatchHint => '请尝试其他搜索或筛选条件。';

  @override
  String get recClearFilters => '清除筛选';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除 $count 条录音？',
      one: '删除 1 条录音？',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage => '音频文件将从此设备中移除。此操作无法撤销。';

  @override
  String get recDeleteOneTitle => '删除这条录音？';

  @override
  String get recDeleteOneMessage => '音频文件将从此设备中移除。此操作无法撤销。';

  @override
  String get recFilterAll => '全部';

  @override
  String get recFilterIncoming => '来电';

  @override
  String get recFilterOutgoing => '去电';

  @override
  String get recFilterByAccount => '按账户筛选';

  @override
  String get recFilterAllAccounts => '所有账户';

  @override
  String get recFilterAccountFallback => '账户';

  @override
  String get recFilterAnyDate => '任意日期';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => '清除日期';

  @override
  String get recMissingFile => '此设备上缺少该音频文件。';

  @override
  String recRelated(String title) {
    return '相关：$title';
  }

  @override
  String get recRenameTitle => '重命名录音';

  @override
  String get recRenameHint => '名称';

  @override
  String get recSaveAs => '另存为…';

  @override
  String get recShowInFinder => '在 Finder 中显示';

  @override
  String get recShowInFolder => '在文件夹中显示';

  @override
  String get recViewCall => '查看通话';

  @override
  String recSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String get recSaveFailed => '无法保存录音';

  @override
  String get recShareFailed => '无法分享录音';

  @override
  String get recSaveDialogTitle => '保存录音';

  @override
  String get recShareSubject => '通话录音';

  @override
  String get recPlayerUnsupported => '此设备无法在此播放 Opus 录音。';

  @override
  String get recPlayerOpenWith => '用其他应用打开…';

  @override
  String get recPlayerNotFound => '未找到录音文件';

  @override
  String recPlayerCannotPlay(String error) {
    return '无法播放此录音：$error';
  }

  @override
  String get recPlayerPlay => '播放录音';

  @override
  String get recPlayerPause => '暂停录音';

  @override
  String get audioFilesTitle => '音频文件';

  @override
  String audioAdded(String name) {
    return '已添加“$name”';
  }

  @override
  String get audioFileUnavailable => '该文件不可用。';

  @override
  String get audioNameRequired => '请输入名称';

  @override
  String audioDeleteTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get audioDeleteMessage => '使用此文件的设置将恢复为默认值。';

  @override
  String get audioGroupAdd => '添加';

  @override
  String get audioAddFooter =>
      '支持 WAV（PCM、mu-law、A-law）和 MP3 文件。文件会被复制到应用中，因此原文件可以移动。';

  @override
  String get audioImport => '导入 WAV 或 MP3…';

  @override
  String get audioGroupMine => '我的文件';

  @override
  String get audioEmptyTitle => '暂无文件';

  @override
  String get audioEmptyHint => '导入文件，或录制您自己的提示音。';

  @override
  String get audioGroupBuiltIn => '内置';

  @override
  String get audioBuiltInFooter => '为 SoftphonePro 生成，可免费使用。';

  @override
  String get audioPreviewStop => '停止试听';

  @override
  String audioPreviewPlay(String name) {
    return '试听 $name';
  }

  @override
  String get audioRecordedName => '为此录音命名';

  @override
  String get audioRecordedDefaultName => '我的提示音';

  @override
  String audioSaved(String name) {
    return '已保存“$name”';
  }

  @override
  String get audioRecorderStop => '停止';

  @override
  String get audioRecorderPlay => '播放录音';

  @override
  String audioRecorderNew(String duration) {
    return '新录音  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => '放弃';

  @override
  String get audioRecordOwn => '录制您自己的…';

  @override
  String get audioRecordOwnHint => '使用在音频设置中选择的麦克风';

  @override
  String get audioMissingFile => '文件缺失';

  @override
  String get audioBuiltInCalm => '宁静（内置）';

  @override
  String get audioBuiltInBreeze => '微风（内置）';

  @override
  String get audioBuiltInChime => '提示钟声（内置）';

  @override
  String get audioErrOnlyWavMp3 => '仅可使用 WAV 和 MP3 文件。';

  @override
  String get audioErrNotFound => '找不到该文件。';

  @override
  String get audioErrNotSaved => '录音未保存。';

  @override
  String get audioErrEmpty => '此音频文件为空或无法读取。';

  @override
  String audioErrUnusable(String reason) {
    return '无法使用此音频文件（$reason）。请使用 PCM、mu-law 或 A-law 的 WAV，或 MP3。';
  }

  @override
  String get audioRecEngineOff => '通话引擎未运行。';

  @override
  String get audioRecUnsupported => '此版本的通话引擎无法录制麦克风。';

  @override
  String audioRecStartFailed(String reason) {
    return '无法开始录音：$reason';
  }

  @override
  String audioRecFailed(String reason) {
    return '录音失败：$reason';
  }

  @override
  String get audioStrengthLow => '低';

  @override
  String get audioStrengthMedium => '中';

  @override
  String get audioStrengthHigh => '高';

  @override
  String get audioStrengthMax => '最大';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label（$percent%）';
  }

  @override
  String get audioSystemDefault => '跟随系统';

  @override
  String audioSystemDefaultNamed(String name) {
    return '跟随系统（$name）';
  }

  @override
  String get voiceTitle => '人声隔离';

  @override
  String get voiceUnavailable => '此版本的通话引擎不支持 AI 降噪。“音频处理”下的标准噪声抑制仍然可用。';

  @override
  String get voiceGroupAi => 'AI 降噪';

  @override
  String get voiceAiFooter =>
      '使用设备端神经网络（RNNoise）消除通话中的键盘敲击声、风扇声和背景人声。数据不会离开您的设备。强度越高，消除的噪声越多，但可能削掉字词的开头。';

  @override
  String get voiceMic => '我的麦克风';

  @override
  String get voiceMicHint => '优化对方听到的声音';

  @override
  String get voiceOthers => '其他参与者';

  @override
  String get voiceOthersHint => '优化您听到的嘈杂来电者声音';

  @override
  String voiceStrength(String value) {
    return '强度：$value';
  }

  @override
  String get voiceGroupTry => '试一试';

  @override
  String get voiceTryFooter => '回声测试请使用耳机，否则会听到啸叫。';

  @override
  String get voiceEchoTest => '回声测试';

  @override
  String get voiceEchoTestHint => '将处理后的麦克风声音回放给您';

  @override
  String get voiceEchoFailed => '回声测试失败';

  @override
  String get voiceGroupSystem => '系统';

  @override
  String get voiceSystemFooter =>
      'macOS 和 iOS 也可为所有应用隔离您的人声。请在系统麦克风模式中选择“人声隔离”。';

  @override
  String get voiceSystemMode => '系统麦克风模式（人声隔离）…';

  @override
  String get voiceSystemModeUnsupported => '麦克风模式需要 macOS 12 或 iOS 15 及以上版本。';

  @override
  String get voiceSpeechDetection => '语音检测';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent%';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Android 音频效果';

  @override
  String get voiceAndroidFooter => '手机本身也可能优化麦克风。这些信息由 Android 报告，与上方设置相互独立。';

  @override
  String get voiceAndroidNs => '噪声抑制器';

  @override
  String get voiceAndroidAec => '回声消除器';

  @override
  String get voiceNotAvailableDevice => '此设备不可用';

  @override
  String get callLinkNotLocal => '此类链接只能从本机的命令行使用。';

  @override
  String linkLanConnectTitle(String name) {
    return '连接到设备 $name？';
  }

  @override
  String get linkLanConnectBody =>
      '来自其他应用或网页的链接想把 SoftphonePro 连接到此设备。仅在您预期此操作时才连接。';

  @override
  String get linkLanConnectAction => '连接';

  @override
  String get linkImportSensitiveHeader => '此配置中的敏感更改：';

  @override
  String get linkImportFlagAutoAnswer => '自动接听来电';

  @override
  String linkImportFlagForwarding(String target) {
    return '将来电转接到 $target';
  }

  @override
  String get linkImportFlagIntercom => '更改谁可以发起对讲或代接来电（局域网）';

  @override
  String get linkImportFlagDialRewrite => '改写您拨打的号码';

  @override
  String get linkImportFlagLinksImmediately => '来自网页链接的呼叫会立即开始，无需确认';

  @override
  String get linkImportFlagDiagnostics => '开启详细日志或 SIP 跟踪';

  @override
  String get linkImportAllowAutoAnswer => '允许对导入的账户自动接听';

  @override
  String linkImportRefused(String setting) {
    return '此导入试图更改“$setting”，该设置无法通过链接、二维码、粘贴文本或文件设置。请改用本机上的 --provision 命令行选项。未导入任何内容。';
  }

  @override
  String get lanPairIntercomNote => '已配对的设备可以请求对讲通话；每次都会先询问您（可在 设置 > 局域网 中更改）。';

  @override
  String get callLinkUnsupportedScheme => '不支持此类链接。';

  @override
  String get linkImportFlagAutoRecord => '自动录制通话';

  @override
  String get linkImportFlagBlocklist => '更改您的通话黑名单';

  @override
  String get linkImportFlagEmergency => '更改您的紧急号码';

  @override
  String get linkImportFlagSpeedDial => '设置快速拨号号码';

  @override
  String get linkImportFlagRecordingDelete => '自动删除旧录音';

  @override
  String get linkImportFlagFeatureCodes => '拨打自定义 PBX 功能码';

  @override
  String get linkImportAllowAutoRecord => '允许自动通话录音';

  @override
  String get importIgnoredHeader => '已忽略（导入不允许）：';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name（$address）- 服务器 $server，$transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return '代理：$proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'TURN 中继：$server';
  }

  @override
  String importAccountHeaders(String headers) {
    return '自定义 SIP 头：$headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return '主叫号码：$callerId';
  }

  @override
  String get importAccountSrtpOff => '无媒体加密（SRTP 关闭）';

  @override
  String linkLanConnectAddress(String host, String port) {
    return '地址：$host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return '更新 $updated 个现有账户，添加 $added 个新账户';
  }

  @override
  String get secretsKeyringLocked =>
      '无法打开密钥环(已锁定或无响应),因此无法读取已保存的密码。请解锁后重新启动 SoftphonePro。';

  @override
  String get mixerTitle => '音频混音器';

  @override
  String get mixerMicrophone => '麦克风';

  @override
  String get mixerSpeaker => '耳机和扬声器';

  @override
  String get mixerMicVolume => '麦克风音量';

  @override
  String get mixerSpeakerVolume => '扬声器音量';

  @override
  String mixerMeterLabel(String name) {
    return '$name电平';
  }

  @override
  String get mixerInputDevice => '输入设备';

  @override
  String get mixerOutputDevice => '输出设备';

  @override
  String get mixerOutputRoute => '音频输出';

  @override
  String get mixerInputFollowsOutput => '麦克风跟随所选的音频输出。';

  @override
  String get mixerShowMore => '显示设备和背景音乐';

  @override
  String get mixerShowLess => '显示更少选项';

  @override
  String get mixerStripShow => '显示音频混音器';

  @override
  String get mixerStripHide => '隐藏音频混音器';

  @override
  String get musicbedTitle => '背景音乐';

  @override
  String get musicbedPlay => '播放背景音乐';

  @override
  String get musicbedVolume => '背景音乐音量';

  @override
  String get musicbedChooseFile => '选择文件';

  @override
  String musicbedChangeFile(String name) {
    return '背景音乐文件：$name。点按可更改。';
  }

  @override
  String get musicbedHearIt => '我也收听';

  @override
  String get musicbedMonitorVolume => '监听音量';

  @override
  String get musicbedAddFile => '添加文件…';

  @override
  String get musicbedPickerTitle => '背景音乐文件';

  @override
  String get musicbedOn => '背景音乐已开启';

  @override
  String get musicbedOnTooltip => '正在向通话中的所有人播放音乐文件。';

  @override
  String get musicbedFileMissing => '背景音乐文件已不可用，已关闭背景音乐。';

  @override
  String get musicbedNeedsFile => '请先选择背景音乐文件。';

  @override
  String musicbedStopped(String message) {
    return '背景音乐已停止：$message';
  }

  @override
  String get musicbedSettingsFooter =>
      '在您的声音下方循环播放音乐文件，通话中的所有人都能听到，静音时也一样。保持中的通话将听到等待音乐。';

  @override
  String get musicbedSettingsFile => '音乐文件';

  @override
  String get linkImportFlagMusicbed => '在你的通话中播放音乐';

  @override
  String get musicbedMonitorIosHint => '在 iPhone 上，通话期间才能听到';

  @override
  String get musicbedStopFailed => '无法停止音乐。通话对方可能仍能听到。';
}
