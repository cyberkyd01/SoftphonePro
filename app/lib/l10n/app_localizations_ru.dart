// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languagePickerHint =>
      'Названия языков показаны на их собственных языках.';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionRename => 'Переименовать';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionCopy => 'Копировать';

  @override
  String get actionShare => 'Поделиться';

  @override
  String get actionImport => 'Импорт';

  @override
  String get actionExport => 'Экспорт';

  @override
  String get actionDetails => 'Подробнее';

  @override
  String get actionMore => 'Ещё';

  @override
  String get actionSettings => 'Настройки';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionRefresh => 'Обновить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionYes => 'Да';

  @override
  String get actionNo => 'Нет';

  @override
  String get commonOn => 'Вкл.';

  @override
  String get commonOff => 'Выкл.';

  @override
  String get commonNone => 'Нет';

  @override
  String get commonDefault => 'По умолчанию';

  @override
  String get commonSystem => 'Системный';

  @override
  String get commonAutomatic => 'Автоматически';

  @override
  String get commonUnknown => 'Неизвестно';

  @override
  String get commonNotSet => 'Не задано';

  @override
  String get commonError => 'Ошибка';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get statusAvailable => 'Доступен';

  @override
  String get statusDoNotDisturb => 'Не беспокоить';

  @override
  String get statusOffline => 'Не в сети';

  @override
  String get statusOnACall => 'На звонке';

  @override
  String get settingsEntryAccounts => 'Учётные записи';

  @override
  String get settingsEntryAccountsSub => 'SIP-аккаунты и регистрация';

  @override
  String get settingsEntryAudio => 'Звук';

  @override
  String get settingsEntryAudioSub => 'Устройства, уровни, эхоподавление';

  @override
  String get settingsEntryCodecs => 'Кодеки';

  @override
  String get settingsEntryCodecsSub => 'Порядок, доступность, Opus';

  @override
  String get settingsEntryCalls => 'Звонки';

  @override
  String get settingsEntryCallsSub =>
      'Не беспокоить, ожидание, автоответ, правила набора';

  @override
  String get settingsEntryNetwork => 'Сеть';

  @override
  String get settingsEntryNetworkSub => 'Транспорты, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Запись';

  @override
  String get settingsEntryNotifications => 'Уведомления и мелодии';

  @override
  String get settingsEntryShortcuts => 'Горячие клавиши';

  @override
  String get settingsEntryShortcutsSub => 'Глобальные и внутри приложения';

  @override
  String get settingsEntryAppearance => 'Оформление';

  @override
  String get settingsEntryPrivacy => 'Конфиденциальность и безопасность';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Автонастройка';

  @override
  String get settingsEntryProvisioningSub => 'Импорт, экспорт, QR';

  @override
  String get settingsEntryDiagnostics => 'Диагностика';

  @override
  String get settingsEntryDiagnosticsSub => 'SIP-трассировка, проверки сети';

  @override
  String get settingsEntryAdvanced => 'Дополнительно';

  @override
  String get settingsEntryAbout => 'О приложении';

  @override
  String get settingsAccountsEmptyTitle => 'Добавьте первую учётную запись';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Подключитесь к вашей АТС или SIP-провайдеру, чтобы начать звонить.';

  @override
  String get settingsAccountsAdd => 'Добавить учётную запись';

  @override
  String get settingsAccountsYourAccounts => 'Ваши учётные записи';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  резервный сервер';
  }

  @override
  String get settingsAudioDevices => 'Устройства';

  @override
  String get settingsAudioMicrophone => 'Микрофон';

  @override
  String get settingsAudioSpeaker => 'Динамик';

  @override
  String get settingsAudioRinger => 'Звонок';

  @override
  String get settingsAudioRingerSub =>
      'Воспроизводить мелодию звонка на отдельном устройстве';

  @override
  String get settingsAudioRefreshDevices => 'Обновить устройства';

  @override
  String get settingsAudioLevelsAndTest => 'Уровни и проверка';

  @override
  String get settingsAudioMicVolume => 'Громкость микрофона';

  @override
  String get settingsAudioMicLevel => 'Уровень микрофона';

  @override
  String get settingsAudioSpeakerVolume => 'Громкость динамика';

  @override
  String get settingsAudioSpeakerLevel => 'Уровень динамика';

  @override
  String get settingsAudioTestSpeaker => 'Проверить динамик';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Воспроизводит короткий сигнал через выбранный динамик';

  @override
  String get settingsAudioTestToneFailed =>
      'Не удалось воспроизвести тестовый сигнал';

  @override
  String get settingsAudioEchoTestFailed => 'Эхо-тест не удался';

  @override
  String get settingsAudioEchoTest => 'Эхо-тест';

  @override
  String get settingsAudioEchoTestSub =>
      'Воспроизводит звук микрофона через динамик. Используйте наушники, чтобы избежать свиста.';

  @override
  String get settingsAudioVoiceAndFiles => 'Голос и файлы';

  @override
  String get settingsAudioVoiceIsolation =>
      'Выделение голоса (ИИ-шумоподавление)';

  @override
  String get settingsAudioAudioFiles => 'Аудиофайлы';

  @override
  String get settingsAudioAudioFilesSub => 'Музыка на удержании и объявления';

  @override
  String get settingsAudioProcessing => 'Обработка';

  @override
  String get settingsAudioEchoCancellation => 'Эхоподавление';

  @override
  String get settingsAudioEcSimple => 'Простое';

  @override
  String get settingsAudioEcPlatform => 'Системное';

  @override
  String get settingsAudioEchoTail => 'Длина эха';

  @override
  String get settingsAudioNoiseSuppression => 'Шумоподавление';

  @override
  String get settingsAudioAgc => 'Автоматическая регулировка усиления';

  @override
  String get settingsAudioVad => 'Обнаружение речи';

  @override
  String get settingsAudioVadSub => 'Экономит трафик во время пауз';

  @override
  String get settingsAudioAdvanced => 'Дополнительно';

  @override
  String get settingsAudioAdvancedFooter =>
      'Значения джиттер-буфера указаны в миллисекундах; -1 означает значение движка по умолчанию. При изменении движок звонков перезапускается.';

  @override
  String get settingsAudioPtime => 'Время пакета (ptime)';

  @override
  String get settingsAudioJbInitial => 'Джиттер-буфер: начальный';

  @override
  String get settingsAudioJbMinPrefetch => 'Джиттер-буфер: мин. предзагрузка';

  @override
  String get settingsAudioJbMaxPrefetch => 'Джиттер-буфер: макс. предзагрузка';

  @override
  String get settingsAudioJbMaxSize => 'Джиттер-буфер: макс. размер';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Микрофон: $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Собеседники: $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent процентов';
  }

  @override
  String settingsUnitMs(int value) {
    return '$value мс';
  }

  @override
  String settingsUnitKbps(int value) {
    return '$value кбит/с';
  }

  @override
  String settingsUnitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count секунды',
      many: '$count секунд',
      few: '$count секунды',
      one: '$count секунда',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Порядок и доступность';

  @override
  String get settingsCodecsDragHint =>
      'Перетащите, чтобы изменить порядок. Учётные записи могут переопределять этот список в своих настройках.';

  @override
  String get settingsCodecsBitrate => 'Битрейт';

  @override
  String get settingsCodecsFec => 'FEC в потоке';

  @override
  String get settingsCodecsFecSub =>
      'Восстанавливает данные при потере пакетов';

  @override
  String get settingsCodecsDtxSub => 'Не передавать данные во время пауз';

  @override
  String get settingsCodecsCbr => 'Постоянный битрейт';

  @override
  String get settingsCodecsComplexity => 'Сложность';

  @override
  String get settingsCallsIncoming => 'Входящие';

  @override
  String get settingsCallsDndSub => 'Отклонять все входящие звонки';

  @override
  String get settingsCallsRejectWith => 'Отклонять с ответом';

  @override
  String get settingsCallsReasonBusy => 'Занято (486)';

  @override
  String get settingsCallsReasonUnavailable => 'Временно недоступен (480)';

  @override
  String get settingsCallsReasonDecline => 'Отклонено (603)';

  @override
  String get settingsCallsWaiting => 'Ожидание вызова';

  @override
  String get settingsCallsWaitingSub =>
      'Разрешить второй входящий звонок во время разговора';

  @override
  String get settingsCallsWhenBusy => 'Если занято и ожидание выключено';

  @override
  String get settingsCallsRejectAnonymous => 'Отклонять анонимные звонки';

  @override
  String get settingsCallsLinksImmediately => 'Звонить по ссылке сразу';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Ссылки tel:, sip: и callto: сразу начинают звонок, не ожидая в наборе номера';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Синхронизировать «Не беспокоить» и переадресацию с АТС через сервисные коды';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Кратко набирает звёздочные коды учётной записи (например, *78) при изменении режима «Не беспокоить» или переадресации';

  @override
  String get settingsCallsAutoAnswerGroup => 'Автоответ';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'Переадресация и автоответ для отдельных учётных записей настраиваются в самих записях.';

  @override
  String get settingsCallsAutoAnswerAll => 'Автоответ на все звонки';

  @override
  String get settingsCallsAnswerAfter => 'Отвечать через';

  @override
  String get settingsCallsAnswerImmediately => 'Сразу';

  @override
  String get settingsCallsIntercomHeaders => 'Учитывать заголовки интеркома';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Подсказки автоответа Call-Info, Alert-Info и Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Заблокированные номера';

  @override
  String get settingsCallsBlockNumber => 'Заблокировать номер';

  @override
  String get settingsCallsBlockNumberTitle => 'Блокировка номера';

  @override
  String get settingsCallsBlockNumberHint => 'Номер или SIP-адрес';

  @override
  String get settingsCallsSpeedDial => 'Быстрый набор';

  @override
  String get settingsCallsDialPlan => 'План набора';

  @override
  String get settingsCallsDialRules => 'Правила набора';

  @override
  String get settingsCallsStripPrefix => 'Префикс выхода на линию для удаления';

  @override
  String get settingsCallsStripPrefixSub =>
      'Например, 9; удаляется из начала набираемых номеров';

  @override
  String get settingsCallsPlusReplacement => 'Заменять первый + на';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Например, 00 для международного доступа';

  @override
  String get settingsCallsPlusReplacementHint => 'Оставлять +';

  @override
  String get settingsCallsCountryPrefix => 'Код страны по умолчанию';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Национальные номера, начинающиеся с 0, получают этот префикс, например +44';

  @override
  String get settingsCallsEmergency => 'Экстренные номера';

  @override
  String get settingsCallsEmergencySub =>
      'Через запятую. Для них правила набора не применяются.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Разблокировать $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return 'Назначено $count из 9';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count правила',
      many: '$count правил',
      few: '$count правила',
      one: '$count правило',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Новое правило набора';

  @override
  String get settingsDialRulesEdit => 'Изменение правила набора';

  @override
  String get settingsDialRulesName => 'Название';

  @override
  String get settingsDialRulesPattern => 'Шаблон (regex)';

  @override
  String get settingsDialRulesReplacement => 'Замена';

  @override
  String get settingsDialRulesReplacementHelp =>
      'Используйте \$1, \$2 для групп';

  @override
  String get settingsDialRulesRoute => 'Направлять через учётную запись';

  @override
  String get settingsDialRulesAdd => 'Добавить правило';

  @override
  String get settingsDialRulesLiveTest => 'Проверка';

  @override
  String get settingsDialRulesTyped => 'Введённый номер';

  @override
  String get settingsDialRulesNothing => '(пусто)';

  @override
  String get settingsDialRulesEmergency =>
      'Экстренный номер: набирается как введён';

  @override
  String get settingsDialRulesAccountFallback => 'учётную запись';

  @override
  String get settingsDialRulesEmpty =>
      'Правил нет. Номера очищаются (удаляются пробелы, дефисы и скобки) и набираются как введены. Правила применяются сверху вниз; срабатывает первое совпавшее.';

  @override
  String get settingsDialRulesDelete => 'Удалить правило';

  @override
  String get settingsDialRulesDeleteTitle => 'Удалить правило?';

  @override
  String settingsDialRulesVia(String account) {
    return 'через $account';
  }

  @override
  String get settingsNetworkTransports => 'Транспорты';

  @override
  String get settingsNetworkTransportsFooter =>
      'Порт 0 выбирает случайный свободный порт. При смене транспортов движок звонков перезапускается.';

  @override
  String get settingsNetworkUdpPort => 'Порт UDP';

  @override
  String get settingsNetworkTcpPort => 'Порт TCP';

  @override
  String get settingsNetworkTlsPort => 'Порт TLS';

  @override
  String get settingsNetworkVerifyCerts => 'Проверять сертификаты серверов';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Отключайте только для АТС с самоподписанными сертификатами или закрепите сертификат ниже';

  @override
  String get settingsNetworkCustomCa => 'Свой файл CA';

  @override
  String get settingsNetworkCustomCaSub =>
      'Пакет PEM, используемый вместо встроенного списка (CA частной АТС)';

  @override
  String get settingsNetworkCustomCaHint => 'Встроенный список Mozilla';

  @override
  String get settingsNetworkPins => 'Закреплённые сертификаты';

  @override
  String get settingsNetworkPinsSub => 'хост=отпечаток SHA256, через запятую';

  @override
  String get settingsNetworkNat => 'Обход NAT';

  @override
  String get settingsNetworkStun => 'Серверы STUN';

  @override
  String get settingsNetworkStunSub => 'хост:порт, через запятую';

  @override
  String get settingsNetworkIceTurn => 'ICE и TURN';

  @override
  String get settingsNetworkIceTurnSub =>
      'Настраивается для каждой учётной записи в разделе NAT';

  @override
  String get settingsNetworkAdvanced => 'Дополнительно';

  @override
  String get settingsNetworkQos => 'QoS (маркировка DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Помечать пакеты SIP и голоса как приоритетные';

  @override
  String get settingsNetworkDns => 'Серверы DNS';

  @override
  String get settingsNetworkDnsSub =>
      'Оставьте пустым для автоматического выбора';

  @override
  String get settingsNetworkRtpStart => 'Начальный порт RTP';

  @override
  String get settingsNetworkRtpRange => 'Диапазон портов RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 — значение по умолчанию';

  @override
  String get settingsNotifRingtone => 'Мелодия звонка';

  @override
  String get settingsNotifDefaultRingtone => 'Мелодия по умолчанию';

  @override
  String get settingsNotifProgressTones => 'Сигналы состояния вызова';

  @override
  String get settingsNotifProgressTonesSub =>
      'Контроль посылки вызова, сигналы «занято» и перегрузки при наборе';

  @override
  String get settingsNotifRingerVolume => 'Громкость звонка';

  @override
  String get settingsNotifCustomRingtone => 'Свой файл мелодии';

  @override
  String get settingsNotifCustomRingtoneSub => 'Путь к файлу WAV (компьютер)';

  @override
  String get settingsNotifGroup => 'Уведомления';

  @override
  String get settingsNotifRequestPermissions => 'Запросить разрешения';

  @override
  String get settingsNotifRequestPermissionsSub => 'Микрофон и уведомления';

  @override
  String get settingsNotifTyping => 'Отправлять индикатор набора текста';

  @override
  String get settingsAppearanceTheme => 'Тема';

  @override
  String get settingsAppearanceLight => 'Светлая';

  @override
  String get settingsAppearanceDark => 'Тёмная';

  @override
  String get settingsAppearanceAccent => 'Цвет акцента';

  @override
  String get settingsAppearanceAccentOption => 'Вариант цвета акцента';

  @override
  String get settingsAppearanceCompact => 'Компактная плотность';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Микрофон: $microphone, уведомления: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Безопасность';

  @override
  String get settingsPrivacyPasswords => 'Пароли';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Хранятся в системной связке ключей / хранилище ключей (запасной вариант — зашифрованный файл)';

  @override
  String get settingsPrivacyGroup => 'Конфиденциальность';

  @override
  String get settingsPrivacyNoTelemetry => 'Без телеметрии';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro не отправляет аналитику. Сетевой трафик идёт только на ваши SIP-серверы.';

  @override
  String get settingsPrivacyYourData => 'Ваши данные';

  @override
  String get settingsPrivacyClearHistory => 'Очистить историю звонков';

  @override
  String get settingsPrivacyDeleteContacts => 'Удалить все контакты';

  @override
  String get settingsPrivacyDeleteMessages => 'Удалить все сообщения';

  @override
  String get settingsPrivacyConfirmHistory => 'Удалить историю звонков?';

  @override
  String get settingsPrivacyConfirmContacts => 'Удалить все контакты?';

  @override
  String get settingsPrivacyConfirmMessages => 'Удалить все сообщения?';

  @override
  String get settingsPrivacyCannotUndo => 'Это действие нельзя отменить.';

  @override
  String get settingsPrivacyDeletedHistory => 'История звонков удалена';

  @override
  String get settingsPrivacyDeletedContacts => 'Все контакты удалены';

  @override
  String get settingsPrivacyDeletedMessages => 'Все сообщения удалены';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Устройства в одной сети находят друг друга, сопрягаются по 6-значному коду и общаются напрямую, без какого-либо сервера.';

  @override
  String get settingsLanEnable => 'Включить LAN Link';

  @override
  String get settingsLanDeviceName => 'Имя устройства';

  @override
  String get settingsLanDeviceNameHint => 'Это устройство';

  @override
  String get settingsLanAllowIntercom => 'Разрешить интерком';

  @override
  String get settingsLanAllowIntercomSub =>
      'Сопряжённые устройства смогут звонить вам с автоответом';

  @override
  String get settingsLanAskIntercom => 'Спрашивать перед разрешением интеркома';

  @override
  String get settingsLanAskIntercomSub =>
      'Иначе на звонки сопряжённых устройств автоматически отвечают в течение 30 с после их запроса';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Автоматически принимать файлы от сопряжённых устройств';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Иначе подтверждение запрашивается для каждого файла';

  @override
  String get settingsLanAllowPull =>
      'Разрешить сопряжённым устройствам забирать мои звонки';

  @override
  String get settingsLanAllowPullSub =>
      'Сопряжённое устройство сможет перехватить активный здесь звонок';

  @override
  String get settingsLanDownloads => 'Папка загрузок';

  @override
  String get settingsLanDownloadsHint => 'По умолчанию (Загрузки/SoftphonePro)';

  @override
  String get settingsLanPort => 'Порт Link';

  @override
  String get settingsLanSharedAccounts =>
      'Учётные записи для сопряжённых устройств';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Если открыть доступ к зарегистрированной учётной записи, сопряжённое устройство на том же сервере сможет принимать ваши звонки напрямую (перевод звонка), а не через ретрансляцию.';

  @override
  String get settingsAdvEngine => 'Движок';

  @override
  String get settingsAdvSimulator => 'Использовать симулятор';

  @override
  String get settingsAdvSimulatorSub =>
      'Работа без встроенного движка. Звонки имитируются.';

  @override
  String get settingsAdvLogLevel => 'Уровень журнала';

  @override
  String get settingsAdvLogErrors => 'Ошибки';

  @override
  String get settingsAdvLogInfo => 'Информация';

  @override
  String get settingsAdvLogDebug => 'Отладка';

  @override
  String get settingsAdvLogVerbose => 'Подробный';

  @override
  String get settingsAdvSipTrace => 'SIP-трассировка';

  @override
  String get settingsAdvRestartEngine => 'Перезапустить движок';

  @override
  String get settingsAdvDesktop => 'Компьютер';

  @override
  String get settingsAdvStartAtLogin => 'Запускать при входе в систему';

  @override
  String get settingsAdvCloseToTray => 'Сворачивать в трей';

  @override
  String get settingsAdvCloseToTraySub =>
      'После закрытия окна SoftphonePro продолжает работать, и звонки будут приниматься. Выйти можно через значок в трее или строке меню.';

  @override
  String get settingsAboutLicence => 'Лицензия';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro — свободное программное обеспечение: вы можете распространять и изменять его на условиях Стандартной общественной лицензии GNU, опубликованной Фондом свободного программного обеспечения, версии 3 или более поздней. Программа распространяется БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ.';

  @override
  String get settingsAboutGpl => 'GNU GPL версии 3 или новее';

  @override
  String get settingsAboutGplSub =>
      'Исходный код доступен в репозитории проекта';

  @override
  String get settingsAboutThirdParty => 'Уведомления о сторонних компонентах';

  @override
  String get settingsAboutPackages => 'Пакеты Flutter и Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT и Apache 2.0. См. страницу лицензий.';

  @override
  String settingsAboutVersion(String version) {
    return 'Версия $version';
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
    return '$license. $purpose. Версия $version.';
  }

  @override
  String get updatesChecking => 'Проверка...';

  @override
  String updatesAvailable(String version) {
    return 'Доступна версия SoftphonePro $version';
  }

  @override
  String get updatesUpToDate => 'У вас последняя версия';

  @override
  String get updatesCouldNotCheck => 'Не удалось проверить';

  @override
  String get updatesNotCheckedYet => 'Ещё не проверялось';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Последняя проверка: $dateString';
  }

  @override
  String get updatesTitle => 'Обновления';

  @override
  String get updatesFooter =>
      'Проверка обращается только к api.github.com (раз в неделю) и не отправляет ничего, кроме самого запроса: ни идентификаторов, ни данных учётных записей или звонков. SoftphonePro никогда не скачивает и не устанавливает ничего самостоятельно.';

  @override
  String get updatesCheckSwitch => 'Проверять обновления';

  @override
  String get updatesCheckNow => 'Проверить сейчас';

  @override
  String updatesSkippingVersion(String version) {
    return 'Пропускается версия $version';
  }

  @override
  String get updatesStopSkipping => 'Не пропускать';

  @override
  String get updatesReleaseNotes => 'Список изменений';

  @override
  String get updatesDownload => 'Скачать';

  @override
  String get updatesSkipVersion => 'Пропустить версию';

  @override
  String get updatesDismiss => 'Скрыть';

  @override
  String get updatesRateLimited =>
      'Достигнут лимит запросов GitHub, повторите позже';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub ответил: $status';
  }

  @override
  String get updatesUnexpectedReply => 'Непредвиденный ответ';

  @override
  String get updatesTimedOut => 'Превышено время ожидания';

  @override
  String get updatesAlreadyChecking => 'Проверка уже выполняется';

  @override
  String get encryptionTitle => 'Шифрование';

  @override
  String get encryptionFooter =>
      'Шифрует локальную базу данных алгоритмом AES-256-GCM. Ключ хранится в системной связке ключей / хранилище ключей; если он будет утерян, данные не восстановить. Записи звонков и экспортированные файлы не шифруются. Изменение вступит в силу при следующем запуске SoftphonePro (сначала полностью закройте его); предыдущий файл перезаписывается и удаляется, как только новая база данных открыта и проверена.';

  @override
  String get encryptionSwitchTitle =>
      'Шифровать историю звонков, контакты и сообщения на этом устройстве';

  @override
  String get encryptionWillEncrypt => 'Будет зашифровано при следующем запуске';

  @override
  String get encryptionWillDecrypt =>
      'Будет расшифровано при следующем запуске';

  @override
  String get encryptionRestartToEncrypt =>
      'Закройте и снова запустите SoftphonePro, чтобы зашифровать данные.';

  @override
  String get encryptionRestartToDecrypt =>
      'Закройте и снова запустите SoftphonePro, чтобы расшифровать данные.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Быстрый набор $slot';
  }

  @override
  String get speedDialNumberLabel => 'Номер или SIP-адрес';

  @override
  String get speedDialLabelOptional => 'Подпись (необязательно)';

  @override
  String get speedDialCallFrom => 'Звонить с';

  @override
  String get speedDialSelectedAccount => 'Выбранная учётная запись';

  @override
  String get speedDialTitle => 'Быстрый набор';

  @override
  String get speedDialHint =>
      'Долгое нажатие на цифру (1–9) на пустой клавиатуре набора вызывает её номер.';

  @override
  String get speedDialNotAssigned => 'Не назначено';

  @override
  String provisioningNotValidJson(String detail) {
    return 'Недопустимый JSON: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Ожидался объект JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Неподдерживаемая версия конфигурации $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Пропущена запись учётной записи, не являющаяся объектом';

  @override
  String get provisioningNothingToImport =>
      'В файле нет учётных записей и настроек';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'Для учётной записи «$name» нужны имя пользователя и домен';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'Сервер ответил: $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Не удалось загрузить конфигурацию: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Не удалось прочитать $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count учётной записи',
      many: 'Импортировано $count учётных записей',
      few: 'Импортировано $count учётные записи',
      one: 'Импортирована $count учётная запись',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Импорт конфигурации';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts учётной записи',
      many: '$accounts учётных записей',
      few: '$accounts учётные записи',
      one: '$accounts учётная запись',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings настройки',
      many: '$settings настроек',
      few: '$settings настройки',
      one: '$settings настройка',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Импорт по URL или из JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... или вставьте JSON';

  @override
  String get provisioningInvalidSource =>
      'Это не допустимый URL, ссылка или JSON';

  @override
  String get provisioningScanTitle => 'Сканирование QR автонастройки';

  @override
  String get provisioningPasteHint => 'Вставьте JSON, ссылку или URL';

  @override
  String get provisioningImportGroup => 'Импорт';

  @override
  String get provisioningImportFooter =>
      'Поддерживается JSON с учётными записями и настройками. Заполнители \${VAR} заменяются пустыми значениями, если значение по умолчанию не задано как \${VAR:-default}.';

  @override
  String get provisioningScanQr => 'Сканировать QR-код';

  @override
  String get provisioningFromUrl => 'По URL или из вставленного JSON';

  @override
  String get provisioningFromFile => 'Из файла';

  @override
  String get provisioningFromClipboard => 'Из буфера обмена';

  @override
  String get provisioningExportGroup => 'Экспорт';

  @override
  String get provisioningIncludePasswords => 'Включить пароли';

  @override
  String get provisioningIncludePasswordsHint =>
      'Любой, у кого есть файл, сможет использовать ваши учётные записи';

  @override
  String get provisioningCopyConfig => 'Копировать конфигурацию (JSON)';

  @override
  String get provisioningConfigCopied => 'Конфигурация скопирована';

  @override
  String get provisioningQrGroup => 'QR-код';

  @override
  String get provisioningQrFooter =>
      'Отсканируйте этот код на другом устройстве, чтобы скопировать учётную запись. Обращайтесь с ним как с паролем, если пароль в нём есть.';

  @override
  String get provisioningQrAccount => 'Учётная запись';

  @override
  String get provisioningChoose => 'Выбрать...';

  @override
  String get provisioningQrTooMuchData => 'Слишком много данных для QR-кода';

  @override
  String tlsClearField(String field) {
    return 'Очистить: $field';
  }

  @override
  String get tlsChoose => 'Выбрать...';

  @override
  String get tlsChange => 'Изменить...';

  @override
  String get tlsClientCertTitle => 'Клиентский сертификат (взаимный TLS)';

  @override
  String get tlsIncomplete =>
      'Выберите и сертификат, и его закрытый ключ. Сертификат предъявляется, только когда заданы оба.';

  @override
  String get tlsFooter =>
      'Для серверов, которые требуют от приложения подтверждения подлинности сертификатом. Файлы PEM. Используется для TLS и защищённого WebSocket.';

  @override
  String get tlsCertFile => 'Файл сертификата';

  @override
  String get tlsKeyFile => 'Файл закрытого ключа';

  @override
  String get tlsKeyPassword => 'Пароль ключа';

  @override
  String get tlsKeyPasswordHint => 'Только если ключ зашифрован';

  @override
  String get callSettingsHoldGroupTitle => 'Удержание';

  @override
  String get callSettingsHoldFooter =>
      'При выборе «Как на АТС» звонок просто ставится на удержание, а ваша телефонная система может сама проигрывать музыку. Любой другой вариант воспроизводится собеседнику этим приложением.';

  @override
  String get callSettingsHoldMusic => 'Музыка на удержании';

  @override
  String get callSettingsHoldPbxDefault => 'Как на АТС';

  @override
  String get callSettingsHoldMusicVolume => 'Громкость музыки на удержании';

  @override
  String get callSettingsHoldAudioFiles => 'Аудиофайлы';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Импорт или запись музыки для удержания';

  @override
  String get callSettingsAnnounceTitle => 'Объявления';

  @override
  String get callSettingsAnnounceFooter =>
      'Объявления воспроизводятся собеседнику. Если файла нет, всё пропускается без уведомлений.';

  @override
  String get callSettingsAnnounceOpening => 'Приветственное объявление';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Проигрывать сообщение при соединении звонка';

  @override
  String get callSettingsAnnounceFile => 'Файл объявления';

  @override
  String get callSettingsAnnounceChooseFile => 'Выберите файл';

  @override
  String get callSettingsAnnouncePlayFor => 'Проигрывать для';

  @override
  String get callSettingsAnnounceBoth => 'Входящих и исходящих';

  @override
  String get callSettingsAnnounceIncoming => 'Входящих звонков';

  @override
  String get callSettingsAnnounceOutgoing => 'Исходящих звонков';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Отключать мой микрофон во время воспроизведения';

  @override
  String get callSettingsAnnounceMonitor => 'Также воспроизводить мне';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Перед началом записи проигрывать';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Перед переводом звонящего проигрывать';

  @override
  String get morePageTitle => 'Ещё';

  @override
  String get morePresence => 'Присутствие';

  @override
  String get morePresenceHint => 'Индикатор занятости (BLF)';

  @override
  String get moreRetrieveParked => 'Забрать припаркованный звонок';

  @override
  String get moreRetrieveParkedHint => 'Набрать ячейку парковки';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint => 'Устройства рядом, чат и обмен файлами';

  @override
  String get moreRecordings => 'Записи';

  @override
  String get moreRecordingsHint =>
      'Прослушивание, отправка и управление записями звонков';

  @override
  String get moreVoicemail => 'Голосовая почта';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нового сообщения',
      many: '$count новых сообщений',
      few: '$count новых сообщения',
      one: '$count новое сообщение',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Позвонить в голосовую почту';

  @override
  String get moreDiagnostics => 'Диагностика';

  @override
  String get moreDiagnosticsHint => 'SIP-трассировка и проверки сети';

  @override
  String get moreAbout => 'О приложении';

  @override
  String get moreNoVoicemailNumber =>
      'Номер голосовой почты не задан. Добавьте его в настройках учётной записи.';

  @override
  String get moreSearchHint => 'Поиск контактов и истории или ввод номера';

  @override
  String moreCallNumber(String number) {
    return 'Позвонить на $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Блокировка приложения';

  @override
  String get appLockFooter =>
      'Звонки по-прежнему поступают, и на них можно ответить при заблокированном приложении.';

  @override
  String get appLockRequirePin => 'Требовать PIN-код при открытии приложения';

  @override
  String get appLockOnHint =>
      'История, контакты, сообщения и настройки заблокированы';

  @override
  String get appLockIsOn => 'Блокировка приложения включена';

  @override
  String get appLockIsOff => 'Блокировка приложения выключена';

  @override
  String get appLockTurnOff => 'Отключить блокировку приложения';

  @override
  String get appLockChangePin => 'Изменить PIN-код';

  @override
  String get appLockEnterCurrent => 'Введите текущий PIN-код';

  @override
  String get appLockPinChanged => 'PIN-код изменён';

  @override
  String get appLockLockAfter => 'Блокировать через';

  @override
  String get appLockLockAfterHint =>
      'Время в фоновом режиме, после которого снова потребуется PIN-код';

  @override
  String get appLockImmediately => 'Сразу';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 час';

  @override
  String get appLockBiometrics => 'Разблокировка биометрией';

  @override
  String get appLockNow => 'Заблокировать сейчас';

  @override
  String get appLockSetPin => 'Задайте PIN-код';

  @override
  String get appLockPinDigits => 'PIN-код (4–8 цифр)';

  @override
  String get appLockRepeatPin => 'Повторите PIN-код';

  @override
  String get appLockUseDigits => 'Используйте от 4 до 8 цифр';

  @override
  String get appLockMismatch => 'PIN-коды не совпадают';

  @override
  String get appLockPin => 'PIN-код';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Слишком много попыток. Повторите через $seconds с';
  }

  @override
  String get appLockWrongPin => 'Неверный PIN-код';

  @override
  String get appLockTooMany => 'Слишком много попыток';

  @override
  String get appLockIsLocked => 'SoftphonePro заблокирован';

  @override
  String get appLockEnterPin => 'Введите PIN-код';

  @override
  String appLockTryAgainIn(String time) {
    return 'Повторите через $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '$minutes мин $seconds с';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '$seconds с';
  }

  @override
  String get appLockUnlock => 'Разблокировать';

  @override
  String get appLockIncomingCall => 'Входящий звонок';

  @override
  String get appLockDecline => 'Отклонить';

  @override
  String get appLockAnswer => 'Ответить';

  @override
  String get appLockHangUp => 'Завершить';

  @override
  String get appLockBiometricReason => 'Разблокировать SoftphonePro';

  @override
  String get automationNoToken =>
      'Токен доступа не задан. Создайте его в разделе «Настройки» > «Дополнительно».';

  @override
  String automationInvalidPort(int port) {
    return 'Недопустимый порт $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Не удалось запустить: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'Порт $port недоступен ($error). Выберите другой порт.';
  }

  @override
  String get automationTokenPlaceholder => 'Создаётся при включении API';

  @override
  String automationListening(String address) {
    return 'Прослушивается $address';
  }

  @override
  String get automationStarting => 'Запуск...';

  @override
  String get automationTitle => 'Локальный API автоматизации';

  @override
  String get automationFooter =>
      'Для интеграции с CRM и службами поддержки на этом компьютере. Слушает только 127.0.0.1, и каждый запрос требует токен доступа. См. docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Включить локальный API автоматизации';

  @override
  String get automationPort => 'Порт';

  @override
  String get automationPortHint =>
      'По умолчанию 7771. Выберите свободный порт от 1024 до 65535.';

  @override
  String get automationPortInvalid => 'Введите порт от 1024 до 65535';

  @override
  String get automationAccessToken => 'Токен доступа';

  @override
  String get automationHideToken => 'Скрыть токен';

  @override
  String get automationShowToken => 'Показать токен';

  @override
  String get automationCopyToken => 'Копировать токен';

  @override
  String get automationTokenCopied => 'Токен скопирован';

  @override
  String get automationGenerateToken => 'Создать новый токен';

  @override
  String get automationGenerateTitle => 'Создать новый токен?';

  @override
  String get automationGenerateBody =>
      'Программы, использующие старый токен, перестанут работать, пока вы не передадите им новый.';

  @override
  String get automationGenerate => 'Создать';

  @override
  String get automationOrigins => 'Разрешённые источники браузера';

  @override
  String get automationOriginsHint =>
      'Через запятую, например https://crm.example.com. Программам без браузера (curl, скрипты) это не требуется.';

  @override
  String automationNotOrigin(String origin) {
    return 'Не источник http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'Ответить';

  @override
  String get trayNotificationDecline => 'Отклонить';

  @override
  String get trayTooltipInCall => 'SoftphonePro - идёт звонок';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - новых: $count';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - нет учётных записей (Отошёл)',
      'dnd': 'SoftphonePro - нет учётных записей (Не беспокоить)',
      'other': 'SoftphonePro - нет учётных записей',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - в сети $online из $total (Отошёл)',
      'dnd': 'SoftphonePro - в сети $online из $total (Не беспокоить)',
      'other': 'SoftphonePro - в сети $online из $total',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Скрыть SoftphonePro';

  @override
  String get trayShowApp => 'Показать SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return 'Новых: $count - открыть недавние';
  }

  @override
  String get trayStatus => 'Статус';

  @override
  String get trayStatusAway => 'Отошёл';

  @override
  String get trayAccounts => 'Учётные записи';

  @override
  String get trayQuit => 'Выйти из SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Ответить на звонок';

  @override
  String get hotkeyHangUp => 'Завершить звонок';

  @override
  String get hotkeyMute => 'Выкл. / вкл. микрофон';

  @override
  String get hotkeyFocusDialer => 'Перейти к набору';

  @override
  String get shortcutsGlobalTitle => 'Глобальные горячие клавиши';

  @override
  String get shortcutsGlobalFooter =>
      'Работают в любом приложении. Если комбинацию уже использует другая программа, её регистрация может не удаться.';

  @override
  String get shortcutsChange => 'Изменить';

  @override
  String get shortcutsRestoreDefaults => 'Восстановить по умолчанию';

  @override
  String get shortcutsMediaTitle => 'Гарнитура и медиаклавиши';

  @override
  String get shortcutsMediaFooter =>
      'Кнопка воспроизведения/паузы гарнитуры или клавиатуры перехватывается только во время входящего или активного звонка, поэтому в остальное время она остаётся за музыкальными плеерами.';

  @override
  String get shortcutsMediaSwitch =>
      'Отвечать и завершать звонок кнопкой воспроизведения/паузы гарнитуры или медиаклавиатуры';

  @override
  String get shortcutsMediaDuringCall => 'Во время звонка кнопка';

  @override
  String get shortcutsMediaHangsUp => 'Завершает звонок';

  @override
  String get shortcutsMediaMutes => 'Выключает / включает микрофон';

  @override
  String get shortcutsInApp => 'В приложении';

  @override
  String get shortcutsFocusDialer => 'Перейти к набору';

  @override
  String get shortcutsHoldResume => 'Удержание / продолжить';

  @override
  String get shortcutsTransfer => 'Перевод';

  @override
  String get shortcutsEndCall => 'Завершить звонок';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Добавьте к букве или цифре Ctrl, Alt, Shift или $key';
  }

  @override
  String get shortcutsPressNew => 'Нажмите новую комбинацию клавиш';

  @override
  String get defaultHandlerChooseInSettings =>
      'Выберите SoftphonePro для SIP, TEL и CALLTO в разделе «Приложения по умолчанию»';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro теперь открывает ссылки sip:, tel: и callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Не удалось изменить приложение по умолчанию для $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Открывает ссылки sip:, tel: и callto: из браузеров и других приложений';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro обрабатывает ссылки sip:, tel: и callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Сейчас: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Сделать SoftphonePro приложением по умолчанию для ссылок sip:, tel: и callto:';

  @override
  String get reliabilityTitle => 'Надёжность в фоне';

  @override
  String get reliabilityMicrophone => 'Микрофон';

  @override
  String get reliabilityAllowed => 'Разрешено';

  @override
  String get reliabilityMicNeeded => 'Нужен для разговора во время звонков';

  @override
  String get reliabilityNotifications => 'Уведомления';

  @override
  String get reliabilityNotifNeeded =>
      'Нужны для показа входящих звонков и видимости службы';

  @override
  String get reliabilityFullScreen => 'Входящие звонки на весь экран';

  @override
  String get reliabilityFullScreenNeeded =>
      'Разрешите, чтобы звонки отображались поверх экрана блокировки';

  @override
  String get reliabilityBattery => 'Без ограничений батареи';

  @override
  String get reliabilityBatteryExempt => 'Исключено из оптимизации батареи';

  @override
  String get reliabilityBatteryNeeded =>
      'Android может приостанавливать приложение для экономии энергии, и вы пропустите звонки. Нажмите, чтобы исключить SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return '$manufacturer: автозапуск / защищённые приложения';
  }

  @override
  String get reliabilityAutostartHint =>
      'Производитель телефона может закрывать фоновые приложения. Разрешите автозапуск SoftphonePro.';

  @override
  String get reliabilityBoot => 'Запуск при включении';

  @override
  String get reliabilityBootHint =>
      'Регистрировать учётные записи после перезагрузки телефона';

  @override
  String get reliabilityWake => 'Не усыплять процессор в простое';

  @override
  String get reliabilityWakeHint =>
      'Надёжнее на строгих устройствах; расходует больше заряда';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Удалить $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Последняя ошибка: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Допустимый диапазон: от $min до $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Не менее $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Не более $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Отменить изменения?';

  @override
  String get acctEditorDiscardMessage =>
      'Изменения этой учётной записи не сохранены.';

  @override
  String get acctEditorDiscardConfirm => 'Отменить';

  @override
  String get acctEditorDeleteMessage =>
      'Учётная запись и сохранённый пароль будут удалены с этого устройства.';

  @override
  String get acctEditorMenuDelete => 'Удалить учётную запись';

  @override
  String get acctGroupBasic => 'Основное';

  @override
  String get acctFieldLabel => 'Название';

  @override
  String get acctFieldLabelHint => 'напр. Офис';

  @override
  String get acctFieldDisplayName => 'Отображаемое имя';

  @override
  String get acctFieldUsername => 'Имя пользователя';

  @override
  String get acctFieldProtocol => 'Протокол';

  @override
  String get acctFieldProtocolSub => 'Задаётся при создании учётной записи';

  @override
  String get acctFieldAuthUser => 'Пользователь для авторизации';

  @override
  String get acctFieldAuthUserHint => 'Как имя пользователя';

  @override
  String get acctFieldAuthUserSub =>
      'Только если провайдер использует логин, отличный от имени пользователя';

  @override
  String get acctFieldPassword => 'Пароль';

  @override
  String get acctFieldServerHost => 'Хост сервера';

  @override
  String get acctFieldPort => 'Порт';

  @override
  String get acctFieldIaxPortSub => 'Для IAX2 по умолчанию 4569';

  @override
  String get acctFieldIaxContext => 'Контекст';

  @override
  String get acctFieldIaxContextSub =>
      'Необязательно. Передаётся АТС как вызываемый контекст';

  @override
  String get acctFieldServerDomain => 'Сервер / домен';

  @override
  String get acctFieldServerDomainSub => 'хост или хост:порт';

  @override
  String get acctFieldEnabled => 'Включена';

  @override
  String get acctFieldDefault => 'Учётная запись по умолчанию для исходящих';

  @override
  String get acctFieldColour => 'Цвет';

  @override
  String get acctGroupRegistration => 'Регистрация';

  @override
  String get acctFieldRegister => 'Регистрировать';

  @override
  String get acctFieldRegisterSubIax =>
      'Отключите для пиров, которым регистрация не нужна';

  @override
  String get acctFieldRegExpiry => 'Срок регистрации (с)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk обычно принудительно задаёт 60 с. Диапазон от 10 до 86400';

  @override
  String get acctFieldRetryInterval => 'Интервал повтора (с)';

  @override
  String get acctFieldFirstRetry => 'Первый повтор (с)';

  @override
  String get acctGroupCodecs => 'Кодеки';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 поддерживает G.711 и GSM. Перетащите, чтобы задать порядок предпочтения.';

  @override
  String get acctCodecAdd => 'Добавить кодек';

  @override
  String get acctGroupServerTransport => 'Сервер и транспорт';

  @override
  String get acctFieldRegistrar => 'Другой регистратор';

  @override
  String get acctFieldBackupRegistrar => 'Резервный регистратор';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Используется после 3 неудачных попыток; основной проверяется каждые 5 минут';

  @override
  String get acctFieldProxies => 'Исходящие прокси';

  @override
  String get acctFieldTransport => 'Транспорт';

  @override
  String get acctFieldTransportAutoSub =>
      'Ищет DNS SRV-записи сервера и выбирает TLS, TCP или UDP';

  @override
  String get acctTransportAuto => 'Автоматически (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Путь WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'HTTP-путь обновления до WebSocket, например /ws. Должен начинаться с «/»';

  @override
  String get acctFieldRegExpirySubSip =>
      'Обычно от 300 до 3600. Диапазон от 10 до 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (с)';

  @override
  String get acctFieldKeepAliveSub =>
      'Интервал UDP keep-alive. 0 отключает. Диапазон от 0 до 3600';

  @override
  String get acctFieldLocalPort => 'Локальный порт SIP';

  @override
  String get acctFieldLocalPortSub =>
      '0 — общий транспорт. Диапазон от 0 до 65535';

  @override
  String get acctFieldRegisterSubSip => 'Отключите для транков без регистрации';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Поддерживает постоянное соединение через NAT. Требуется поддержка на сервере';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Использовать STUN';

  @override
  String get acctFieldTurn => 'Ретранслятор TURN';

  @override
  String get acctFieldTurnServer => 'Сервер TURN';

  @override
  String get acctFieldTurnUsername => 'Имя пользователя TURN';

  @override
  String get acctFieldTurnPassword => 'Пароль TURN';

  @override
  String get acctFieldContactRewrite => 'Переписывать заголовок Contact';

  @override
  String get acctFieldViaRewrite => 'Переписывать заголовок Via';

  @override
  String get acctFieldRewriteSub =>
      'Использовать адрес, который видит сервер. Оставьте включённым за NAT';

  @override
  String get acctFieldSdpRewrite => 'Переписывать адрес SDP';

  @override
  String get acctFieldSdpRewriteSub => 'Заменять медиаадрес в SDP публичным';

  @override
  String get acctFieldIpv6Sip => 'Сигнализация IPv6';

  @override
  String get acctFieldIpv6Media => 'Медиа IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Расширенные настройки медиа';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'Шлюзам WebRTC нужны мультиплексирование RTCP и обратная связь RTCP.';

  @override
  String get acctFieldRtcpMux => 'Мультиплексирование RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Передавать RTP и RTCP через один порт (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Обратная связь RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Предлагать RTP/AVPF с NACK. Нужно для серверов WebRTC';

  @override
  String get acctGroupSecurity => 'Безопасность';

  @override
  String get acctFieldSrtp => 'Шифрование медиа (SRTP)';

  @override
  String get acctOptOptional => 'Необязательно';

  @override
  String get acctOptRequired => 'Обязательно';

  @override
  String get acctFieldKeyExchange => 'Обмен ключами';

  @override
  String get acctFieldSecureSignaling => 'Защищённая сигнализация';

  @override
  String get acctOptNotRequired => 'Не требуется';

  @override
  String get acctOptTlsHop => 'TLS между узлами';

  @override
  String get acctOptTlsE2e => 'TLS сквозной (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Алгоритм аутентификации';

  @override
  String get acctFieldPrivacy => 'Скрывать номер (приватность)';

  @override
  String get acctFieldReferPolicy => 'Входящие переводы (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Наблюдатели присутствия';

  @override
  String get acctOptAccept => 'Принимать';

  @override
  String get acctOptReject => 'Отклонять';

  @override
  String get acctGroupCodecsFooter =>
      'Переопределяет общий список кодеков для этой учётной записи.';

  @override
  String get acctFieldUseGlobalCodecs => 'Использовать общий порядок кодеков';

  @override
  String get acctGroupFeatures => 'Функции';

  @override
  String get acctFieldVoicemailNumber => 'Номер голосовой почты';

  @override
  String get acctFieldMwi => 'Индикатор голосовой почты (MWI)';

  @override
  String get acctFieldMwiSub =>
      'Подписаться на уведомления об ожидающих сообщениях';

  @override
  String get acctFieldPublishPresence => 'Публиковать моё присутствие';

  @override
  String get acctFieldPublishPresenceSub =>
      'Разрешить серверу делиться вашим статусом в сети';

  @override
  String get acctFieldDnd => 'Не беспокоить';

  @override
  String get acctFieldForwarding => 'Переадресация';

  @override
  String get acctOptForwardAlways => 'Всегда';

  @override
  String get acctOptForwardBusy => 'При занятости';

  @override
  String get acctOptForwardNoAnswer => 'При неответе';

  @override
  String get acctFieldForwardTo => 'Переадресовать на';

  @override
  String get acctFieldForwardToHint => 'Номер или SIP-адрес';

  @override
  String get acctFieldRingFor => 'Звонить (с)';

  @override
  String get acctFieldAutoAnswer => 'Автоответ';

  @override
  String get acctFieldAnswerAfter => 'Ответить через (с)';

  @override
  String get acctFieldIntercomOnly => 'Только для звонков интеркома';

  @override
  String get acctFieldIntercomOnlySub =>
      'Требуется заголовок автоответа от АТС';

  @override
  String get acctFieldRingtone => 'Мелодия звонка';

  @override
  String get acctRingtoneClassic => 'Классическая';

  @override
  String get acctRingtoneSoft => 'Мягкая';

  @override
  String get acctRingtoneDigital => 'Цифровая';

  @override
  String get acctFieldRecordCalls => 'Записывать звонки';

  @override
  String get acctFieldHoldMusic => 'Музыка на удержании';

  @override
  String get acctOptUseGlobal => 'Общая настройка';

  @override
  String get acctOptPbxDefault => 'Как на АТС';

  @override
  String get acctFieldOpeningAnnouncement => 'Приветственное объявление';

  @override
  String get acctGroupFeatureCodes => 'Сервисные коды';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Набираются на вашей АТС для парковки, перехвата, режима «Не беспокоить» и переадресации.';

  @override
  String get acctFieldPark => 'Парковка';

  @override
  String get acctFieldGroupPickup => 'Групповой перехват';

  @override
  String get acctFieldDirectedPickup => 'Префикс направленного перехвата';

  @override
  String get acctFieldParkRetrieve => 'Префикс возврата с парковки';

  @override
  String get acctFieldParkRetrieveHint => 'Наберите номер ячейки';

  @override
  String get acctFieldParkRetrieveSub =>
      'Префикс, набираемый перед номером ячейки парковки, чтобы забрать припаркованный звонок';

  @override
  String get acctFieldDndOn => 'Не беспокоить: вкл.';

  @override
  String get acctFieldDndOff => 'Не беспокоить: выкл.';

  @override
  String get acctFieldForwardOn => 'Переадресация: вкл.';

  @override
  String get acctFieldForwardOff => 'Переадресация: выкл.';

  @override
  String get acctGroupAdvanced => 'Дополнительно';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF передаётся родными кадрами IAX2.';

  @override
  String get acctFieldCallerIdOverride => 'Свой Caller ID';

  @override
  String get acctFieldCallerIdHint => 'Использовать значение учётной записи';

  @override
  String get acctFieldCallerIdSub =>
      'Имя или номер Caller ID, передаваемые АТС';

  @override
  String get acctFieldSessionTimers => 'Таймеры сессии';

  @override
  String get acctFieldSessionExpires => 'Истечение сессии (с)';

  @override
  String get acctFieldSessionExpiresSub => 'Диапазон от 90 до 86400';

  @override
  String get acctField100rel => '100rel (надёжные предварительные ответы)';

  @override
  String get acctFieldHoldMethod => 'Способ удержания';

  @override
  String get acctFieldDtmfMethod => 'Способ передачи DTMF';

  @override
  String get acctOptDtmfInband => 'В потоке';

  @override
  String get acctFieldRedirects => 'Перенаправления (3xx)';

  @override
  String get acctOptRedirectFollow => 'Следовать';

  @override
  String get acctOptRedirectAsk => 'Спрашивать';

  @override
  String get acctFieldLockCodec => 'Фиксировать кодек после ответа';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive медиа';

  @override
  String get acctFieldDropCalls => 'Сбрасывать звонки при сбое регистрации';

  @override
  String get acctFieldExtraHeaders => 'Дополнительные заголовки SIP';

  @override
  String get acctFieldExtraHeadersHint =>
      'X-Header: значение (по одному на строку)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Ожидание перед повтором неудачной регистрации. Диапазон от 0 до 86400';

  @override
  String get acctFieldUnregTimeout => 'Тайм-аут отмены регистрации (мс)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Сколько ждать ответа на отмену регистрации. Диапазон от 0 до 60000';

  @override
  String get acctFieldMwiExpiry => 'Срок подписки MWI (с)';

  @override
  String get acctFieldDscpSip => 'DSCP для SIP';

  @override
  String get acctFieldDscpSipSub =>
      'QoS-маркировка сигнализации. Обычно 24 (CS3)';

  @override
  String get acctFieldDscpRtp => 'DSCP для RTP';

  @override
  String get acctFieldDscpRtpSub => 'QoS-маркировка медиа. Обычно 46 (EF)';

  @override
  String get acctFieldReinvite => 'Re-INVITE после смены сети';

  @override
  String get acctFieldHangupOnIpChange => 'Завершать звонки при смене сети';

  @override
  String get acctValidateInt => 'Введите целое число';

  @override
  String get acctValidateHostEmpty => 'Введите имя или адрес хоста сервера';

  @override
  String get acctValidateHostSpaces =>
      'Адрес сервера не может содержать пробелы';

  @override
  String get acctValidateHostFormat => 'Введите только хост или хост:порт';

  @override
  String get acctValidatePortRange => 'Порт должен быть от 1 до 65535';

  @override
  String get acctValidateWsStart => 'Путь должен начинаться с «/»';

  @override
  String get acctValidateWsLength => 'Используйте не более 120 символов';

  @override
  String get acctValidateWsSpaces => 'Путь не может содержать пробелы';

  @override
  String get acctTplAsteriskDescription =>
      'Внутренний номер на вашей АТС. UDP 5060, STUN включён.';

  @override
  String get acctTplAsteriskNotes =>
      'Используйте номер расширения PJSIP/SIP и его пароль (secret). Для TLS или WebRTC измените транспорт позже в настройках учётной записи.';

  @override
  String get acctTplAsteriskUsernameHint => 'Внутренний номер (напр. 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Используйте внутренний номер, ID аутентификации и пароль из портала 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'В 3CX откройте внутренний номер, затем «Phones > Provisioning», чтобы узнать ID аутентификации (укажите его как пользователя для авторизации) и пароль. FQDN — тот, что в вашем URL 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Внутренний номер';

  @override
  String get acctTplFreeswitchDescription =>
      'Пользователь каталога на сервере FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Используйте ID пользователя и пароль из каталога. Внутренний профиль по умолчанию слушает UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID пользователя';

  @override
  String get acctTplKamailioDescription =>
      'Регистратор SIP-прокси. За NAT рекомендуется TCP.';

  @override
  String get acctTplKamailioNotes =>
      'Используйте SIP-домен, который обслуживает ваш регистратор. Если регистратор доступен через другой хост, добавьте исходящий прокси в настройках учётной записи.';

  @override
  String get acctTplTwilioDescription =>
      'Учётные данные SIP-домена Programmable Voice. TLS и SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Создайте SIP Domain в консоли Twilio, добавьте Credential List и включите SIP Registration. Укажите полный домен (name.sip.twilio.com) как сервер, а также пользователя и пароль из списка учётных данных. TLS использует порт 5061. Twilio поддерживает только G.711.';

  @override
  String get acctTplTwilioUsernameHint =>
      'Имя пользователя из списка учётных данных';

  @override
  String get acctTplTelnyxDescription =>
      'Подключение с учётными данными. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Создайте Credential Connection на портале Telnyx и скопируйте его SIP-имя пользователя и пароль (не логин портала). Назначьте подключению номер или профиль исходящей голосовой связи, чтобы совершать и принимать звонки.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'SIP-имя пользователя (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Имя пользователя и пароль субучётной записи. Выберите ближайший POP.';

  @override
  String get acctTplVoipmsNotes =>
      'Используйте субучётную запись, созданную в разделе Sub Accounts, а не основную. Выберите ближайший к вам сервер (POP) из списка серверов VoIP.ms и при необходимости разрешите его для вашего IP.';

  @override
  String get acctTplVoipmsUsernameHint =>
      'Субучётная запись (напр. 123456_phone)';

  @override
  String get acctTplVonageDescription => 'SIP-регистрация с TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business предлагает SIP-регистрацию только в некоторых тарифах. Укажите SIP-сервер, пользователя и пароль, показанные для устройства на портале администратора Vonage.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange по UDP 4569. Без настроек NAT и SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Нужен пир/пользователь в iax.conf (type=friend или user+peer) с тем же паролем. Asterisk по умолчанию обновляет регистрации IAX2 каждые 60 с. Контекст необязателен и передаётся как вызываемый контекст.';

  @override
  String get acctTplIax2UsernameHint => 'Имя пользователя IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP через защищённый WebSocket с DTLS-SRTP, ICE и RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Для конечных точек WebSocket Asterisk (webrtc=yes, TLS в http.conf на 8089), FreeSWITCH или Kamailio. Серверу нужен действительный сертификат TLS. Если ваш шлюз не использует /ws, измените путь WebSocket в настройках учётной записи.';

  @override
  String get acctTplGenericDescription =>
      'Любой SIP-регистратор. Заполните данные самостоятельно.';

  @override
  String get acctTplDefaultUsernameHint =>
      'Внутренний номер / имя пользователя';

  @override
  String get appEngineFailedBody =>
      'Звонки и регистрация не будут работать, пока это не исправлено. Обычно причина — неверная настройка сети или сертификата.';

  @override
  String get appEngineFailedTitle => 'Не удалось запустить движок звонков';

  @override
  String get appEngineNotRunning => 'Движок звонков не запущен';

  @override
  String get appUnknownError => 'Неизвестная ошибка';

  @override
  String get appEngineOpenNetworkSettings => 'Открыть настройки сети';

  @override
  String get appEngineUseSimulator => 'Использовать симулятор (демо)';

  @override
  String get appDbLockedTitle => 'Ваши данные заблокированы';

  @override
  String get appDbUnreadableTitle => 'Не удаётся открыть ваши данные';

  @override
  String get appDbLockedBody =>
      'История звонков, контакты и сообщения зашифрованы на этом устройстве, но ключа шифрования больше нет в системной связке ключей / хранилище ключей (например, после сброса связки ключей или восстановления на новом устройстве).';

  @override
  String get appDbUnreadableBody =>
      'Не удалось прочитать локальную базу данных. Возможно, она повреждена или ключ шифрования не подходит.';

  @override
  String get appDbRecoveryAdvice =>
      'Повторите попытку, если ожидаете, что ключ вернётся (разблокируйте связку ключей, войдите под нужным пользователем). Если начать заново, старый файл останется рядом с данными приложения, но история, контакты и сообщения будут пустыми; учётные записи придётся добавить снова.';

  @override
  String get appDbCopyDetails => 'Копировать подробности';

  @override
  String get appDbTryAgain => 'Повторить';

  @override
  String get appDbStartFresh => 'Начать заново';

  @override
  String get appRedirectTitle => 'Звонок перенаправлен';

  @override
  String appRedirectMessage(String target) {
    return 'Звонок перенаправлен на $target - следовать?';
  }

  @override
  String get appRedirectCancelCall => 'Отменить звонок';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': 'Не удалось зашифровать данные ($error). Ничего не изменено.',
      'other': 'Не удалось расшифровать данные ($error). Ничего не изменено.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Встроенный движок недоступен ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Повтор в $time';
  }

  @override
  String get acctRegistrationError => 'Ошибка регистрации';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nТранспорт: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Звонок напрямую, без учётной записи';

  @override
  String acctCallingFromAccount(String name) {
    return 'Звонок с $name';
  }

  @override
  String get acctCallingFromNone => 'Звонок без учётной записи';

  @override
  String get acctNoAccount => 'Нет учётной записи';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds с';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return 'новых: $newCount, старых: $oldCount';
  }

  @override
  String get acctAddAccount => 'Добавить учётную запись';

  @override
  String get acctUnregister => 'Отменить регистрацию';

  @override
  String get acctSheetDndSub =>
      'Отклонять входящие звонки для этой учётной записи';

  @override
  String get acctKvServer => 'Сервер';

  @override
  String get acctKvResolvedServer => 'Определённый сервер';

  @override
  String get acctKvClientCert => 'Сертификат клиента';

  @override
  String get acctKvClientCertValue => 'Предъявляется серверу (взаимный TLS)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Истекает через';

  @override
  String get acctKvVoicemail => 'Голосовая почта';

  @override
  String get acctOpenSipTrace => 'Открыть SIP-трассировку';

  @override
  String get acctAddAnAccount => 'Добавить учётную запись';

  @override
  String get acctChooseAccountTooltip => 'Выберите учётную запись для звонка';

  @override
  String get acctDirectNoAccount => 'Напрямую (без учётной записи)';

  @override
  String get onboardingRequired => 'Требуются имя пользователя и сервер';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Используется порт $port, если не добавить :порт';
  }

  @override
  String get onboardingFineTuneIax =>
      'Кодеки и регистрацию можно настроить позже в разделе «Настройки».';

  @override
  String get onboardingFineTuneSip =>
      'Транспорт, NAT, безопасность и кодеки можно настроить позже в разделе «Настройки».';

  @override
  String get onboardingDemoUser => 'Демо-пользователь';

  @override
  String get onboardingDemoAccount => 'Демо-аккаунт';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Профессиональная связь для любой платформы — бесплатно и с открытым исходным кодом. Без рекламы и слежки.';

  @override
  String get onboardingGetStarted => 'Начать';

  @override
  String get onboardingPermissionsTitle => 'Разрешения';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro нужен микрофон, чтобы передавать ваш голос, и уведомления, чтобы сообщать о входящих звонках и сообщениях. Ничего, кроме ваших звонков, не покидает устройство.';

  @override
  String get onboardingChooseProvider => 'Выберите провайдера';

  @override
  String get onboardingChooseProviderSub =>
      'Мы заранее заполним настройки транспорта, портов и NAT.';

  @override
  String get onboardingScanQr => 'Сканировать QR';

  @override
  String get onboardingImportUrl => 'Импорт по URL';

  @override
  String get onboardingSkip => 'Пропустить (демо-режим)';

  @override
  String get onboardingHidePassword => 'Скрыть пароль';

  @override
  String get onboardingShowPassword => 'Показать пароль';

  @override
  String get onboardingContextOptional => 'Контекст (необязательно)';

  @override
  String get onboardingDisplayNameOptional =>
      'Отображаемое имя (необязательно)';

  @override
  String get onboardingLabelOptional =>
      'Название учётной записи (необязательно)';

  @override
  String get onboardingCallerIdOptional => 'Caller ID (необязательно)';

  @override
  String get onboardingAuthUserOptional =>
      'Пользователь для авторизации (если отличается)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Неверное имя пользователя или пароль ($code)';
  }

  @override
  String get acctRegNotFound => 'Учётная запись не найдена на сервере (404)';

  @override
  String get acctRegNoAnswer => 'Сервер не ответил (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Слишком короткий интервал регистрации (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Сервер временно недоступен (480)';

  @override
  String get acctRegServiceUnavailable => 'Служба недоступна (503)';

  @override
  String get acctRegFailed => 'Не удалось зарегистрироваться';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Не удалось зарегистрироваться ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'Не удалось изменить регистрацию';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Не удалось применить учётную запись «$name»';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'Снова основной сервер для $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Резервный сервер для $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'Учётная запись $name зарегистрирована';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'Учётная запись $name ещё регистрируется';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'Учётная запись $name ещё не зарегистрирована';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'Учётная запись $name не зарегистрирована (сбой регистрации)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'Учётная запись $name отключена';
  }

  @override
  String get callDialEngineFailed => 'Не удалось запустить движок звонков';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'Не удалось запустить движок звонков: $reason';
  }

  @override
  String get callDialEngineStarting => 'Движок звонков ещё запускается';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status через $seconds с; звонок не совершён';
  }

  @override
  String get callJournalInterrupted =>
      'Приложение было закрыто во время звонка';

  @override
  String get callLinkMissingArgument => 'Отсутствует аргумент';

  @override
  String get callLinkHttpsRequired =>
      'Ссылки конфигурации должны использовать https';

  @override
  String get callLinkInvalidLan => 'Недопустимая ссылка LAN';

  @override
  String callLinkConnectedTo(String name) {
    return 'Подключено к $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Не удалось подключиться к этому устройству';

  @override
  String callLinkCallFailed(String target) {
    return 'Не удалось позвонить на $target';
  }

  @override
  String get callLinkImportTitle => 'Импорт конфигурации';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts учётной записи',
      many: '$accounts учётных записей',
      few: '$accounts учётные записи',
      one: '$accounts учётная запись',
    );
    return 'Импортировать конфигурацию с $host? Будет добавлено: $_temp0.';
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
      other: '$accounts учётной записи',
      many: '$accounts учётных записей',
      few: '$accounts учётные записи',
      one: '$accounts учётная запись',
    );
    return 'Импортировать конфигурацию с $host? Будет добавлено: $_temp0 и настроек: $settings.';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Переадресовано с $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Переадресовано с $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Переведено: $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Как в системе';

  @override
  String get callRingtoneClassic => 'Классическая';

  @override
  String get callRingtoneSoft => 'Мягкая';

  @override
  String get callRingtoneDigital => 'Цифровая';

  @override
  String callIdentityFrom(String number) {
    return 'От $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Caller ID $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Caller ID $name $number';
  }

  @override
  String get callTransferring => 'Перевод...';

  @override
  String get callTransferNotConfirmed => 'Сервер не подтвердил перевод';

  @override
  String get callTransferStalledHint =>
      'Звонок всё ещё активен. Оставьте его или отправьте перевод снова.';

  @override
  String get callTransferKeepCall => 'Оставить звонок';

  @override
  String get callAnnouncementOpening => 'Воспроизводится объявление…';

  @override
  String get callAnnouncementTransfer =>
      'Воспроизводится уведомление о переводе…';

  @override
  String get callAnnouncementRecording =>
      'Воспроизводится уведомление о записи…';

  @override
  String get callAnnouncementSkip => 'Пропустить';

  @override
  String get callNoiseTooltipMic => 'ИИ-шумоподавление: ваш микрофон';

  @override
  String get callNoiseTooltipIncoming =>
      'ИИ-шумоподавление: остальные участники';

  @override
  String get callNoiseTooltipBoth =>
      'ИИ-шумоподавление: ваш микрофон и остальные участники';

  @override
  String get callNoiseOn => 'Шумоподавление вкл.';

  @override
  String get callNoiseTitle => 'Шумоподавление';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Мой микрофон: $strength';
  }

  @override
  String get callNoiseMicOffHint => 'Убирать фоновый шум с моего микрофона';

  @override
  String get callResultAnswered => 'Отвечен';

  @override
  String get callResultMissed => 'Пропущен';

  @override
  String get callResultRejected => 'Отклонён';

  @override
  String get callResultFailed => 'Не удался';

  @override
  String get callResultBusy => 'Занято';

  @override
  String get callResultForwarded => 'Переадресован';

  @override
  String get callResultTransferred => 'Переведён';

  @override
  String get callResultHandedOff => 'Передан';

  @override
  String get callResultInterrupted => 'Прерван';

  @override
  String get keypadCall => 'Позвонить';

  @override
  String get keypadNoVoicemail =>
      'Для этой учётной записи не задан номер голосовой почты';

  @override
  String get keypadCallDirectly => 'Позвонить напрямую (без учётной записи)';

  @override
  String get keypadAddAccount => 'Добавьте учётную запись, чтобы звонить';

  @override
  String keypadCallFrom(String account) {
    return 'Звонок с $account';
  }

  @override
  String get keypadRecent => 'Недавние';

  @override
  String get keypadSuggestions => 'Подсказки';

  @override
  String get keypadPhoneNumber => 'Номер телефона';

  @override
  String get keypadPaste => 'Вставить';

  @override
  String get keypadEnterNumber => 'Введите номер';

  @override
  String get keypadBackspace => 'Стереть (долгое нажатие — очистить)';

  @override
  String get keypadTypeNameOrNumber => 'Введите имя или номер';

  @override
  String get keypadNoMatches => 'Совпадений нет';

  @override
  String get keypadSuggestionsHint =>
      'Подсказки берутся из контактов и недавних звонков';

  @override
  String keypadCallPerson(String name) {
    return 'Позвонить: $name';
  }

  @override
  String get dialKeyStar => 'Звёздочка';

  @override
  String get dialKeyPound => 'Решётка';

  @override
  String get dialKeyLongPressPlus => 'Долгое нажатие — плюс';

  @override
  String get dialKeyLongPressSpeedDial => 'Долгое нажатие — быстрый набор';

  @override
  String get dialKeyLongPressVoicemail => 'Долгое нажатие — голосовая почта';

  @override
  String get callBackToApp => 'Вернуться в приложение (звонок продолжается)';

  @override
  String get callRecBadge => 'ЗАП.';

  @override
  String get callHideKeypad => 'Скрыть клавиатуру';

  @override
  String get callMute => 'Без звука';

  @override
  String get callKeypad => 'Клавиатура';

  @override
  String get callSpeaker => 'Динамик';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Гарнитура';

  @override
  String get callResume => 'Продолжить';

  @override
  String get callHold => 'Удержание';

  @override
  String get callAddCall => 'Добавить';

  @override
  String get callTransfer => 'Перевод';

  @override
  String get callStop => 'Стоп';

  @override
  String get callRecord => 'Запись';

  @override
  String get callSplit => 'Разделить';

  @override
  String get callMerge => 'Объединить';

  @override
  String get callSwap => 'Сменить';

  @override
  String get callEndCall => 'Завершить';

  @override
  String callEndCallWith(String name) {
    return 'Завершить звонок с $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Перевод с консультацией. Первый абонент на удержании.';

  @override
  String get callCompleteTransfer => 'Завершить перевод';

  @override
  String get callWaiting => 'Ожидающий звонок';

  @override
  String get callHoldAndAnswer =>
      'Поставить текущий звонок на удержание и ответить';

  @override
  String get callDecline => 'Отклонить';

  @override
  String get callAnswer => 'Ответить';

  @override
  String get callIncomingCall => 'Входящий звонок';

  @override
  String get callReply => 'Сообщение';

  @override
  String get callVoicemail => 'Голосовая почта';

  @override
  String get callToDevice => 'На устройство';

  @override
  String get callQuickReplyBusy => 'Не могу говорить, перезвоню позже.';

  @override
  String get callQuickReplyMeeting => 'Я на встрече. Напишите мне?';

  @override
  String get callQuickReplyOnMyWay => 'Уже в пути.';

  @override
  String callReturnToCallWith(String name) {
    return 'Вернуться к звонку с $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Входящий: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'Разговор с $name';
  }

  @override
  String get callStatsCodec => 'Кодек';

  @override
  String get callStatsJitter => 'Джиттер';

  @override
  String get callStatsPacketLoss => 'Потеря пакетов';

  @override
  String get callStatsRoundTrip => 'Задержка (RTT)';

  @override
  String get callStatsMedia => 'Медиа';

  @override
  String get callStatsMosHistory => 'История MOS';

  @override
  String get callQualityTitle => 'Качество связи';

  @override
  String get callTransferTitle => 'Перевод звонка';

  @override
  String get callTransferModeBlind => 'Слепой';

  @override
  String get callTransferModeAttended => 'С консультацией';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Устройство в LAN';

  @override
  String get callTransferNoLanDevices =>
      'В вашей сети не найдено сопряжённых устройств SoftphonePro. Выполните сопряжение на странице LAN.';

  @override
  String get callTransferLanDisabled =>
      'Включите LAN Link («Настройки» > «LAN Link»), чтобы передать этот звонок на другое устройство в вашей сети.';

  @override
  String get callTransferTalkFirst => 'Сначала поговорить';

  @override
  String get callTransferBlindHint =>
      'Звонящий сразу переводится, вы отключаетесь.';

  @override
  String get callTransferAttendedHint =>
      'Звонящий ставится на удержание, и вы сначала звоните адресату. Завершите перевод, когда он ответит.';

  @override
  String get callTransferNumberLabel => 'Номер или SIP-адрес';

  @override
  String get callTransferNow => 'Перевести сейчас';

  @override
  String get callTransferCallAndConsult => 'Позвонить и уточнить';

  @override
  String get callRetrieveParkedTitle => 'Забрать припаркованный звонок';

  @override
  String get callRetrieveParkedHint => 'Ячейка парковки, напр. 701';

  @override
  String get callMoreAudioOutput => 'Вывод звука';

  @override
  String get callMoreAudioDevices => 'Аудиоустройства';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Телефон, динамик, Bluetooth, гарнитура';

  @override
  String get callMoreAudioDevicesSubtitle => 'Выбор микрофона и динамика';

  @override
  String get callMoreParkCall => 'Припарковать звонок';

  @override
  String get callMoreParkCallSubtitle => 'Перевод на сервисный код парковки';

  @override
  String get callMoreRetrieveParkedSubtitle => 'Набрать ячейку парковки';

  @override
  String get callMoreSendDtmf => 'Отправить цифры DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Введите всю последовательность, например PIN-код';

  @override
  String get callSendDtmfTitle => 'Отправка DTMF';

  @override
  String get callMoreCallInfo => 'О звонке';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, джиттер, потери и задержка в реальном времени';

  @override
  String get callMoreSipTrace => 'SIP-трассировка';

  @override
  String get callMoreSipTraceSubtitle => 'Диаграмма обмена этого звонка';

  @override
  String get callInfoRemote => 'Собеседник';

  @override
  String get callInfoAccount => 'Учётная запись';

  @override
  String get callInfoState => 'Состояние';

  @override
  String get callInfoSecure => 'Защита';

  @override
  String get callInfoPlainSignalling => 'открытая сигнализация';

  @override
  String get callRoutePhone => 'Телефон';

  @override
  String get callRouteWiredHeadset => 'Проводная гарнитура';

  @override
  String get callAudioMicrophone => 'Микрофон';

  @override
  String callCardSemantics(String name, String state) {
    return 'Звонок с $name, $state';
  }

  @override
  String get callUnmute => 'Включить звук';

  @override
  String get callStopRecording => 'Остановить запись';

  @override
  String get callSplitConference => 'Разделить конференцию';

  @override
  String get callMergeCalls => 'Объединить звонки';

  @override
  String get callSwapCalls => 'Переключить звонки';

  @override
  String get callAttendedTransferBanner =>
      'Перевод с консультацией: первый абонент на удержании.';

  @override
  String get callActiveCalls => 'Активные звонки';

  @override
  String get callConferenceLevels => 'Уровни конференции';

  @override
  String get callLevelVolume => 'Громкость';

  @override
  String get callLevelMicToParty => 'Микрофон для абонента';

  @override
  String callPercentSemantics(int percent) {
    return '$percent процентов';
  }

  @override
  String get callFailInvalidNumber => 'Недопустимый номер (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Звонок не разрешён ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Номер не найден (404)';

  @override
  String get callFailNoAnswerFromServer => 'Сервер не ответил (408)';

  @override
  String get callFailTemporarilyUnavailable => 'Временно недоступен (480)';

  @override
  String get callFailIncompleteNumber => 'Неполный номер (484)';

  @override
  String callFailBusy(String code) {
    return 'Занято ($code)';
  }

  @override
  String get callFailCancelled => 'Звонок отменён (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Нет совместимого кодека ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Служба недоступна (503)';

  @override
  String get callFailDeclined => 'Звонок отклонён (603)';

  @override
  String get callFailGeneric => 'Звонок не удался';

  @override
  String callFailGenericWithCode(String code) {
    return 'Звонок не удался ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Идёт звонок';

  @override
  String get callTrayInCall => 'На звонке';

  @override
  String get callHistoryBlocked => 'Заблокирован';

  @override
  String get callHistoryAnonymityDisallowed => 'Анонимные звонки запрещены';

  @override
  String get callHistoryDoNotDisturb => 'Не беспокоить';

  @override
  String get callHistoryBusy => 'Занято';

  @override
  String get callHistoryForwardedAlways => 'Переадресован (всегда)';

  @override
  String get callHistoryForwardedBusy => 'Переадресован (занято)';

  @override
  String get callHistorySentToVoicemail => 'Отправлен в голосовую почту';

  @override
  String get callHistoryRedirected => 'Перенаправлен';

  @override
  String get callIncomingNotificationBody => 'Входящий звонок';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Входящий звонок на $account';
  }

  @override
  String get callMissedNotificationTitle => 'Пропущенный звонок';

  @override
  String get callErrEngineNotRunning => 'Движок звонков ещё не запущен';

  @override
  String get callErrAddAccount => 'Добавьте учётную запись, чтобы звонить';

  @override
  String get callErrCouldNotPlace => 'Не удалось совершить звонок';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account не зарегистрирована';
  }

  @override
  String get callErrCouldNotAnswer => 'Не удалось ответить';

  @override
  String get callErrNoVoicemailNumber =>
      'Для этой учётной записи не задан номер голосовой почты';

  @override
  String get callErrTransferFailed => 'Не удалось перевести звонок';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Не удалось перевести звонок: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Не удалось объединить звонки';

  @override
  String get callErrCouldNotStartRecording => 'Не удалось начать запись';

  @override
  String get callErrCouldNotStopRecording => 'Не удалось остановить запись';

  @override
  String callParkingNotice(String code) {
    return 'Парковка звонка (наберите $code)';
  }

  @override
  String get callErrParkFailed => 'Не удалось припарковать звонок';

  @override
  String get callErrHandoffFailed => 'Не удалось передать звонок';

  @override
  String get callErrCouldNotSendToDevice =>
      'Не удалось отправить на устройство';

  @override
  String get callHistoryForwardedNoAnswer => 'Переадресован (нет ответа)';

  @override
  String get shellTabKeypad => 'Клавиатура';

  @override
  String get shellTabRecents => 'Недавние';

  @override
  String get shellTabContacts => 'Контакты';

  @override
  String get shellTabMessages => 'Сообщения';

  @override
  String get shellTabPresence => 'Присутствие';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Записи';

  @override
  String get shellSearchSemantics =>
      'Поиск контактов и истории или набор номера';

  @override
  String get shellSearchHint => 'Поиск или набор';

  @override
  String get shellVoicemailTooltip => 'Голосовая почта';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count нового голосового сообщения. Нажмите, чтобы позвонить в голосовую почту',
      many:
          '$count новых голосовых сообщений. Нажмите, чтобы позвонить в голосовую почту',
      few:
          '$count новых голосовых сообщения. Нажмите, чтобы позвонить в голосовую почту',
      one:
          '$count новое голосовое сообщение. Нажмите, чтобы позвонить в голосовую почту',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Отошёл';

  @override
  String get shellStatusTooltip => 'Ваш статус';

  @override
  String get shellDemoBanner =>
      'Демо-режим: звонки имитируются, в настоящую сеть ничего не передаётся.';

  @override
  String get uiToday => 'Сегодня';

  @override
  String get uiYesterday => 'Вчера';

  @override
  String get uiUnknownCaller => 'Неизвестный абонент';

  @override
  String get uiCallEnded => 'Звонок завершён';

  @override
  String get uiCallTransferNotConfirmed => 'Перевод не подтверждён';

  @override
  String get uiCallTransferring => 'Перевод...';

  @override
  String get uiCallConference => 'Конференция';

  @override
  String get uiCallOnHold => 'На удержании';

  @override
  String get uiCallHeldByRemote => 'Удержан собеседником';

  @override
  String get uiCallCalling => 'Вызов...';

  @override
  String get uiCallRinging => 'Идёт вызов...';

  @override
  String get uiCallConnecting => 'Соединение...';

  @override
  String get uiCallIncoming => 'Входящий звонок';

  @override
  String get uiCallConnected => 'Соединено';

  @override
  String get uiQrScanTitle => 'Сканирование QR-кода';

  @override
  String get uiQrPasteHint => 'Вставьте текст кода';

  @override
  String get uiQrNoCamera =>
      'Сканирование камерой недоступно на этом устройстве. Вставьте текст кода.';

  @override
  String get uiQrPaste => 'Вставить';

  @override
  String get uiQrUse => 'Использовать';

  @override
  String get uiQrCameraDenied =>
      'Доступ к камере отключён. Разрешите его в системных настройках или вставьте текст кода ниже.';

  @override
  String get uiQrCameraUnavailable =>
      'Камера недоступна. Вставьте текст кода ниже.';

  @override
  String get presenceLampRinging => 'Вызывается';

  @override
  String get presenceHeader => 'Индикатор занятости';

  @override
  String get presenceChooseTooltip => 'Выбрать контакты для наблюдения';

  @override
  String get presenceEmptyTitle => 'На панели нет номеров';

  @override
  String get presenceEmptySubtitle =>
      'Включите «Показывать на панели BLF» для контакта, чтобы видеть, свободен ли он, вызывается или занят.';

  @override
  String get presenceOpenContacts => 'Открыть контакты';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Нажмите, чтобы позвонить, долгое нажатие — дополнительно';
  }

  @override
  String presenceCallName(String name) {
    return 'Позвонить: $name';
  }

  @override
  String get presencePickup => 'Перехватить этот номер';

  @override
  String get presencePickupSub =>
      'Ответить на его входящий звонок (направленный перехват)';

  @override
  String get presenceTransferHere => 'Перевести текущий звонок сюда';

  @override
  String get presenceRemove => 'Убрать с панели';

  @override
  String get uiCall => 'Звонок';

  @override
  String get uiMessage => 'Сообщение';

  @override
  String get recentsSearchTooltip => 'Поиск по истории';

  @override
  String get recentsClearTitle => 'Очистить историю звонков?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будут удалены все $count записи.',
      many: 'Будут удалены все $count записей.',
      few: 'Будут удалены все $count записи.',
      one: 'Будет удалена $count запись.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'История скопирована в буфер обмена в формате CSV';

  @override
  String get recentsMenuCopyCsv => 'Копировать как CSV';

  @override
  String get recentsMenuClear => 'Очистить историю';

  @override
  String get recentsSearchHint => 'Поиск по имени или номеру';

  @override
  String get recentsFilterAll => 'Все';

  @override
  String get recentsFilterMissed => 'Пропущенные';

  @override
  String get recentsFilterIncoming => 'Входящие';

  @override
  String get recentsFilterOutgoing => 'Исходящие';

  @override
  String get recentsFilterAccount => 'Фильтр по учётной записи';

  @override
  String get recentsAllAccounts => 'Все учётные записи';

  @override
  String get recentsAccountFallback => 'Учётная запись';

  @override
  String get recentsEmptyNone => 'Звонков пока нет';

  @override
  String get recentsEmptyNoMatch => 'Подходящих звонков нет';

  @override
  String get recentsEmptyNoneSub => 'Здесь будут появляться ваши звонки.';

  @override
  String get recentsEmptyNoMatchSub => 'Попробуйте другой фильтр.';

  @override
  String get recentsOpenKeypad => 'Открыть клавиатуру';

  @override
  String get recentsShowAll => 'Показать все';

  @override
  String get recentsSelectCall => 'Выберите звонок';

  @override
  String get recentsSelectCallSub =>
      'Здесь появятся подробности, качество связи и записи.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Пропущенный звонок',
      'incoming': 'Входящий звонок',
      'other': 'Исходящий звонок',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Позвонить: $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Добавьте учётную запись, чтобы отправлять сообщения';

  @override
  String get recentsAddContact => 'Добавить контакт';

  @override
  String get recentsContact => 'Контакт';

  @override
  String get recentsBlock => 'Заблокировать';

  @override
  String get recentsUnblock => 'Разблокировать';

  @override
  String recentsBlockTitle(String number) {
    return 'Заблокировать $number?';
  }

  @override
  String get recentsBlockMessage =>
      'Звонки с этого номера будут отклоняться автоматически.';

  @override
  String get recentsQualityHeader => 'Качество связи';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Худший MOS $mos   ·   Джиттер $jitter мс   ·   Потери $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Записи';

  @override
  String get recentsOpenInRecordings => 'Открыть в записях';

  @override
  String recentsRelatedCall(String title) {
    return 'Связанный звонок: $title';
  }

  @override
  String get recentsHistoryHeader => 'История';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Звонков с этим номером нет';

  @override
  String get recentsDeleteTitle => 'Удалить эти звонки?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будут удалены $count записи для $name.',
      many: 'Будут удалены $count записей для $name.',
      few: 'Будут удалены $count записи для $name.',
      one: 'Будет удалена $count запись для $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Удалить из истории';

  @override
  String get recentsCallDetails => 'Сведения о звонке';

  @override
  String get contactsFavoritesHeader => '★ Избранные';

  @override
  String get contactsFavoritesOnly => 'Только избранные';

  @override
  String get contactsShowAll => 'Показать все';

  @override
  String get contactsImportExportTooltip => 'Импорт и экспорт';

  @override
  String get contactsMenuDevice => 'Импорт с устройства';

  @override
  String get contactsMenuFile => 'Импорт файла vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Импорт из буфера обмена';

  @override
  String get contactsMenuCopyVcard => 'Копировать как vCard';

  @override
  String get contactsMenuCopyCsv => 'Копировать как CSV';

  @override
  String get contactsNewTooltip => 'Новый контакт';

  @override
  String get contactsSearchHint => 'Поиск контактов';

  @override
  String get contactsEmptyTitle => 'Контактов пока нет';

  @override
  String get contactsEmptySubtitle =>
      'Добавьте тех, кому часто звоните, или импортируйте файл vCard или CSV.';

  @override
  String get contactsEmptyAction => 'Добавить контакт';

  @override
  String get contactsNoMatches => 'Совпадений нет';

  @override
  String contactsCallName(String name) {
    return 'Позвонить: $name';
  }

  @override
  String get contactsSelect => 'Выберите контакт';

  @override
  String get contactsCopiedVcard => 'Контакты скопированы как vCard';

  @override
  String get contactsCopiedCsv => 'Контакты скопированы как CSV';

  @override
  String get contactsDeviceDenied =>
      'Доступ к контактам запрещён. Разрешите его в системных настройках для импорта.';

  @override
  String get contactsDeviceNone => 'На этом устройстве контактов не найдено';

  @override
  String contactsNothingNew(int count) {
    return 'Нечего импортировать (уже есть: $count)';
  }

  @override
  String get contactsImportDeviceTitle => 'Импортировать с устройства?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нового контакта',
      many: '$count новых контактов',
      few: '$count новых контакта',
      one: '$count новый контакт',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return 'Обновлено с добавлением номеров: $count';
  }

  @override
  String contactsImportSkipped(int count) {
    return 'Пропущено (дубликаты или нет номера): $count';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count контакта',
      many: 'Импортировано $count контактов',
      few: 'Импортировано $count контакта',
      one: 'Импортирован $count контакт',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'В этих данных контактов не найдено';

  @override
  String get contactsLabelMobile => 'мобильный';

  @override
  String get contactsLabelWork => 'рабочий';

  @override
  String get contactsLabelHome => 'домашний';

  @override
  String get contactsLabelOther => 'другой';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Контакт не найден';

  @override
  String get contactsActionFavorite => 'Избранное';

  @override
  String get contactsNumbersHeader => 'Номера';

  @override
  String get contactsSipAddress => 'SIP-адрес';

  @override
  String get contactsDetailsHeader => 'Подробности';

  @override
  String get contactsOnBlf => 'Показывается на панели BLF';

  @override
  String get contactsAlwaysRecorded => 'Звонки всегда записываются';

  @override
  String contactsDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get contactsDeleteMessage =>
      'Этот контакт будет удалён с этого устройства.';

  @override
  String get contactsDeleteButton => 'Удалить контакт';

  @override
  String get contactsDetailTitle => 'Контакт';

  @override
  String get contactsErrorNameOrNumber => 'Введите имя или номер';

  @override
  String get contactsEditTitle => 'Изменение контакта';

  @override
  String get contactsFieldName => 'Имя';

  @override
  String get contactsFieldCompany => 'Компания';

  @override
  String get contactsFieldNumber => 'Номер';

  @override
  String get contactsRemoveNumber => 'Удалить номер';

  @override
  String get contactsAddNumber => 'Добавить номер';

  @override
  String get contactsSipHeader => 'SIP-адреса';

  @override
  String get contactsRemoveAddress => 'Удалить адрес';

  @override
  String get contactsAddSip => 'Добавить SIP-адрес';

  @override
  String get contactsFieldEmail => 'Эл. почта';

  @override
  String get contactsFieldNotes => 'Заметки';

  @override
  String get contactsFieldFavorite => 'Избранное';

  @override
  String get contactsShowOnBlf => 'Показывать на панели BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Следить за присутствием и индикатором занятости этого номера';

  @override
  String get contactsAlwaysRecordTitle =>
      'Всегда записывать звонки с этим контактом';

  @override
  String get contactsAlwaysRecordSub =>
      'Переопределяет правила автоматической записи';

  @override
  String get contactsRingtone => 'Мелодия звонка';

  @override
  String get contactsPresenceVia => 'Присутствие через учётную запись';

  @override
  String get contactsDefaultAccount => 'Учётная запись по умолчанию';

  @override
  String get contactsDeleteContactTitle => 'Удалить контакт?';

  @override
  String get contactsCannotUndo => 'Это действие нельзя отменить.';

  @override
  String get messagesNewMessage => 'Новое сообщение';

  @override
  String get messagesNumberOrSip => 'Номер или SIP-адрес';

  @override
  String get messagesNoConversations => 'Нет бесед';

  @override
  String get messagesEmptySubtitle =>
      'Отправьте SIP-сообщение на любой номер или адрес через ваши учётные записи.';

  @override
  String get messagesTyping => 'печатает...';

  @override
  String get messagesYouPrefix => 'Вы: ';

  @override
  String get messagesSelect => 'Выберите беседу';

  @override
  String get messagesLanOnline => 'Онлайн в вашей сети';

  @override
  String get messagesLanOffline =>
      'Не в сети. Сообщения будут отправлены, когда устройство вернётся.';

  @override
  String messagesSendFileTo(String name) {
    return 'Отправить файл: $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Позвонить: $name';
  }

  @override
  String get messagesDeleteTitle => 'Удалить беседу?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Все сообщения с $name будут удалены.';
  }

  @override
  String get messagesDeleteMenu => 'Удалить беседу';

  @override
  String get messagesSayHello => 'Поздоровайтесь';

  @override
  String get messagesLanEmptySub =>
      'Сообщения идут напрямую на это устройство по вашей сети со сквозным шифрованием.';

  @override
  String get messagesSipEmptySub =>
      'Сообщения отправляются через вашу учётную запись с помощью SIP MESSAGE.';

  @override
  String get messagesInputHint => 'Сообщение';

  @override
  String get messagesSend => 'Отправить';

  @override
  String get messagesStatusSending => 'Отправляется';

  @override
  String get messagesStatusSent => 'Отправлено';

  @override
  String get messagesStatusDelivered => 'Доставлено';

  @override
  String get messagesStatusRead => 'Прочитано';

  @override
  String get messagesStatusFailed => 'Не удалось';

  @override
  String get messagesNotDelivered => 'Не доставлено. Нажмите, чтобы повторить';

  @override
  String get uiStatusRegistered => 'Зарегистрирован';

  @override
  String get uiStatusRegistering => 'Регистрация';

  @override
  String get uiStatusRegFailed => 'Сбой регистрации';

  @override
  String get uiStatusDisabled => 'Отключена';

  @override
  String get uiQualityMeasuring => 'Измерение';

  @override
  String get uiQualityExcellent => 'Отличное';

  @override
  String get uiQualityGood => 'Хорошее';

  @override
  String get uiQualityFair => 'Среднее';

  @override
  String get uiQualityPoor => 'Плохое';

  @override
  String get uiQualityBad => 'Очень плохое';

  @override
  String uiQualitySemantics(String label) {
    return 'Качество связи: $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Качество связи: $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Качество связи: $label';
  }

  @override
  String get uiSecureFull => 'Зашифровано';

  @override
  String get uiSecureMedia => 'Медиа зашифровано';

  @override
  String get uiSecureSignalling => 'Сигнализация зашифрована';

  @override
  String get uiSecureNone => 'Не зашифровано';

  @override
  String get uiSecureSrtpLine => 'Медиа SRTP';

  @override
  String get uiSecureTlsLine => 'Сигнализация TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Передача на $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Интерком на $name';
  }

  @override
  String get lanCallIntercomToUnnamed => 'Интерком на устройство поблизости';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Интерком от $name';
  }

  @override
  String get lanCallIntercomFromUnnamed => 'Интерком от устройства поблизости';

  @override
  String lanCallToNamed(String name) {
    return 'Звонок по LAN на $name';
  }

  @override
  String get lanCallToUnpaired => 'Звонок по LAN на несопряжённое устройство';

  @override
  String lanCallFromNamed(String name) {
    return 'Звонок по LAN от $name';
  }

  @override
  String get lanCallFromUnpaired =>
      'Звонок по LAN от несопряжённого устройства';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Звонок передан с устройства $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Звонок передан с устройства $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'другое устройство';

  @override
  String lanRelayedTitle(String name) {
    return 'Ретрансляция на $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Звонящий разговаривает с $name. Вы не участвуете в звонке.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Вызов $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Звонящий остаётся на связи, пока $name отвечает.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Запрос к $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Ожидание, пока звонок будет принят.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Разговор с $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Звонящий на удержании. Завершите передачу, когда будете готовы.';

  @override
  String get lanRelayTakingBack => 'Возврат звонка...';

  @override
  String get lanRelayTakeBack => 'Вернуть';

  @override
  String get lanRelayEnd => 'Завершить';

  @override
  String get lanSendToDevice => 'Отправить на устройство';

  @override
  String get lanBusy => 'Занято';

  @override
  String get lanNoPairedOnline => 'Нет сопряжённых устройств в сети';

  @override
  String lanPairRejectedBy(String name) {
    return '$name отклонило сопряжение.';
  }

  @override
  String get lanPairRejected => 'Сопряжение отклонено.';

  @override
  String get lanPairCancelled => 'Сопряжение отменено.';

  @override
  String get lanPairTimedOut => 'Время сопряжения истекло. Повторите попытку.';

  @override
  String get lanPairFailed => 'Не удалось выполнить сопряжение';

  @override
  String lanPairFailedReason(String reason) {
    return 'Не удалось выполнить сопряжение: $reason';
  }

  @override
  String get lanPairThisDevice => 'этим устройством';

  @override
  String get lanPairConnecting => 'Защищённое подключение...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name хочет выполнить сопряжение с этим устройством.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Сопряжение с $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Убедитесь, что этот код одинаков на обоих экранах.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Код сопряжения $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Ожидание подтверждения от $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name подтвердил.';
  }

  @override
  String get lanPairReject => 'Отклонить';

  @override
  String get lanPairCodesMatch => 'Коды совпадают';

  @override
  String lanPairPairedWith(String name) {
    return 'Сопряжено с $name.';
  }

  @override
  String get lanPairRequestTitle => 'Запрос на сопряжение';

  @override
  String lanPairTitle(String name) {
    return 'Сопряжение с $name';
  }

  @override
  String get lanActionDecline => 'Отклонить';

  @override
  String get lanActionAccept => 'Принять';

  @override
  String get lanFileIncomingTitle => 'Входящий файл';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size от $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Принять звонок сюда?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' от $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' на $account',
    });
    return '$device хочет передать вам звонок$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Сначала они поговорят с вами.';

  @override
  String get lanHandoffTakeCall => 'Принять звонок';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Разрешить интерком от $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'На их звонок будет автоматически дан ответ на громкой связи.';

  @override
  String get lanIntercomDeny => 'Запретить';

  @override
  String get lanIntercomAllow => 'Разрешить';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name удалил это устройство из списка сопряжённых';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправка $count файла...',
      many: 'Отправка $count файлов...',
      few: 'Отправка $count файлов...',
      one: 'Отправка $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Новое сообщение';

  @override
  String get lanSipMessage => 'SIP-сообщение';

  @override
  String get lanSipMessageSub => 'На номер или адрес через вашу учётную запись';

  @override
  String get lanChatOnline => 'Чат LAN, в сети';

  @override
  String get lanChatOffline => 'Чат LAN, не в сети';

  @override
  String lanSavedAt(String path) {
    return 'Сохранено в $path (путь скопирован)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Ваши устройства общаются напрямую';

  @override
  String get lanConnectByAddress => 'Подключиться по адресу';

  @override
  String get lanSettingsTooltip => 'Настройки LAN';

  @override
  String get lanOffTitle => 'LAN Link выключен';

  @override
  String get lanOffSubtitle =>
      'Находите другие свои устройства с SoftphonePro, общайтесь, обменивайтесь файлами и передавайте звонки без какого-либо сервера.';

  @override
  String get lanTurnOn => 'Включить LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'Не удалось запустить LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'Введите хост:порт или вставьте текст QR-кода, показанного на другом устройстве.';

  @override
  String get lanScanTitle => 'Сканирование QR сопряжения LAN';

  @override
  String get lanScanQr => 'Сканировать QR';

  @override
  String get lanPaste => 'Вставить';

  @override
  String get lanConnect => 'Подключиться';

  @override
  String lanConnectedTo(String name) {
    return 'Подключено к $name';
  }

  @override
  String get lanCouldNotConnect => 'Не удалось подключиться';

  @override
  String get lanCouldNotStartPairing => 'Не удалось начать сопряжение';

  @override
  String get lanThisDevice => 'Это устройство';

  @override
  String get lanDeviceNameTitle => 'Имя устройства';

  @override
  String get lanStarting => 'Запуск...';

  @override
  String get lanVisible => 'Видно в вашей сети';

  @override
  String get lanNotRunning => 'Не запущено';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Доступно $count учётной записи',
      many: 'Доступны $count учётных записей',
      few: 'Доступны $count учётные записи',
      one: 'Доступна $count учётная запись',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Отпечаток';

  @override
  String get lanHideQr => 'Скрыть QR-код';

  @override
  String get lanShowQr => 'Показать QR-код для подключения другого устройства';

  @override
  String get lanCopyConnectionText => 'Копировать текст подключения';

  @override
  String get lanConnectionTextCopied => 'Текст подключения скопирован';

  @override
  String get lanActiveOnOthers => 'Активно на других ваших устройствах';

  @override
  String get lanPairedDevices => 'Сопряжённые устройства';

  @override
  String get lanNoPaired =>
      'Сопряжённых устройств пока нет. Выполните сопряжение с устройством поблизости, чтобы общаться, отправлять файлы и передавать звонки.';

  @override
  String get lanNearby => 'Поблизости';

  @override
  String get lanNearbyHint =>
      'Поиск SoftphonePro в вашей сети. На других устройствах должен быть включён LAN Link. Также можно подключиться по адресу с помощью кнопки-ссылки выше.';

  @override
  String get lanTransfers => 'Передачи';

  @override
  String get lanFiles => 'Файлы';

  @override
  String get lanPairedBadge => 'Сопряжено';

  @override
  String get lanTyping => 'печатает...';

  @override
  String get lanPair => 'Сопрячь';

  @override
  String get lanUnpair => 'Разорвать сопряжение';

  @override
  String lanUnpairTitle(String name) {
    return 'Разорвать сопряжение с $name?';
  }

  @override
  String get lanUnpairMessage =>
      'Чтобы общаться, отправлять файлы или передавать звонки, придётся выполнить сопряжение заново.';

  @override
  String get lanActionMessage => 'Сообщение';

  @override
  String get lanActionSendFile => 'Отправить файл';

  @override
  String get lanActionCall => 'Позвонить';

  @override
  String get lanActionIntercom => 'Интерком';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Активен на $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Активен на $device  ·  $account';
  }

  @override
  String get lanPull => 'Забрать';

  @override
  String get lanTransferPreparing => 'Подготовка...';

  @override
  String get lanTransferWaitingYou => 'Ожидается ваше решение';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Ожидание принятия от $name';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done из $total';
  }

  @override
  String get lanTransferVerifying => 'Проверка...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'От $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'Для $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  от $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  для $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Сбой: $error';
  }

  @override
  String get lanFileActions => 'Действия с файлом';

  @override
  String get lanPathCopied => 'Путь скопирован';

  @override
  String get lanFileOpen => 'Открыть';

  @override
  String get lanFileShowInFolder => 'Показать в папке';

  @override
  String get lanFileCopyPath => 'Копировать путь';

  @override
  String lanNetworkError(String message) {
    return 'Ошибка сети: $message';
  }

  @override
  String get lanErrNotRunning => 'Сначала включите LAN Link';

  @override
  String get lanErrBadAddress =>
      'Введите адрес вида 192.168.1.20:4711 или вставьте текст QR-кода';

  @override
  String get lanErrFingerprint =>
      'Это устройство не соответствует отсканированному коду. QR-код с другого устройства?';

  @override
  String lanNoticeReceived(String file, String name) {
    return 'Получен файл $file от $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return 'Файл $file отправлен: $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name отклонил файл $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Не удалось передать файл: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Включите LAN Link, чтобы звонить на устройства поблизости';

  @override
  String get lanNoticePairFirst =>
      'Сначала выполните сопряжение с этим устройством';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name сейчас недоступен для звонков';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Запрос к $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name не разрешил интерком (или не ответил)';
  }

  @override
  String get lanHoOff => 'LAN Link выключен';

  @override
  String get lanHoPairFirst =>
      'Сначала выполните сопряжение с этим устройством';

  @override
  String lanHoOffline(String name) {
    return '$name не в сети';
  }

  @override
  String get lanHoAlready => 'Этот звонок уже передаётся';

  @override
  String get lanHoEnded => 'Звонок уже завершён';

  @override
  String get lanHoWaitConnected => 'Дождитесь соединения звонка';

  @override
  String get lanHoLanCall => 'Звонки по LAN нельзя передавать';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name не может принимать звонки по сети (звонки по LAN там отключены)';
  }

  @override
  String get lanHoNoLanHere => 'Звонки по LAN недоступны на этом устройстве';

  @override
  String lanHoDeclined(String name) {
    return '$name отклонил звонок. Он остаётся у вас.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name не ответил. Звонок остаётся у вас.';
  }

  @override
  String get lanHoCancelled => 'Передача отменена. Звонок остаётся у вас.';

  @override
  String lanHoUnreachable(String name) {
    return 'Не удалось связаться с $name. Звонок остаётся у вас.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Не удалось связаться с $name ($reason). Звонок остаётся у вас.';
  }

  @override
  String get lanHoEndedBefore => 'Звонок завершился до передачи';

  @override
  String lanHoPbxRefused(String name) {
    return 'АТС отклонила перевод, а $name не может принимать звонки по LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Перевод через АТС не удался. Используется ретрансляция по сети.';

  @override
  String lanHoSentTo(String name) {
    return 'Звонок отправлен: $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Не удалось позвонить на другое устройство через АТС';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name больше недоступен';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Не удалось ответить на звонок для передачи';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Не удалось позвонить $name по сети. Звонок остаётся у вас.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name не ответил. Звонок остаётся у вас.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Передан на $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Звонок ретранслирован на $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Сначала дождитесь ответа от $name';
  }

  @override
  String get lanHoFailed => 'Не удалось передать звонок';

  @override
  String lanHoTakenBack(String name) {
    return 'Звонок возвращён с $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name завершил консультацию. Звонок снова у вас.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Не удалось передать звонок на $name';
  }

  @override
  String get diagSip400Explain => 'Сервер не смог понять запрос.';

  @override
  String get diagSip400Fix =>
      'Проверьте настройки учётной записи (домен, имя пользователя, прокси). Если ошибка повторяется, отправьте SIP-трассировку своему провайдеру.';

  @override
  String get diagSip401Explain =>
      'Сервер отклонил учётные данные (или запрашивает их).';

  @override
  String get diagSip401Fix =>
      'Проверьте имя пользователя, имя для аутентификации и пароль. Некоторые провайдеры используют отдельный «auth ID».';

  @override
  String get diagSip403Explain =>
      'Сервер понял запрос, но отказывает: неверный пароль, учётная запись отключена или ваш IP не разрешён.';

  @override
  String get diagSip403Fix =>
      'Введите пароль заново, убедитесь, что учётная запись активна, и что ваш публичный IP не заблокирован (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'Сервер не знает этого пользователя или номера.';

  @override
  String get diagSip404Fix =>
      'Проверьте имя пользователя и домен; для звонков проверьте набранный номер и правила набора.';

  @override
  String get diagSip405Explain => 'Сервер не поддерживает этот запрос.';

  @override
  String get diagSip405Fix =>
      'Для проверок OPTIONS обычно безвредно. Для REGISTER убедитесь, что вы обращаетесь к SIP-регистратору.';

  @override
  String get diagSip407Explain => 'Исходящему прокси нужны учётные данные.';

  @override
  String get diagSip407Fix =>
      'Проверьте пароль учётной записи и настройки исходящего прокси.';

  @override
  String get diagSip408Explain => 'Сервер не ответил вовремя.';

  @override
  String get diagSip408Fix =>
      'Проверьте адрес и порт сервера, межсетевые экраны, попробуйте TCP или TLS. Повторяющиеся тайм-ауты только по UDP могут указывать на SIP ALG в маршрутизаторе.';

  @override
  String get diagSip410Explain => 'Такого номера больше не существует.';

  @override
  String get diagSip410Fix => 'Проверьте набранный номер.';

  @override
  String get diagSip415Explain =>
      'Другая сторона не принимает предложенный тип содержимого или кодеки.';

  @override
  String get diagSip415Fix =>
      'Включите больше кодеков (например, PCMU/PCMA) в разделе «Настройки» > «Кодеки».';

  @override
  String get diagSip421Explain =>
      'Серверу требуется расширение SIP, которое клиент не предложил.';

  @override
  String get diagSip421Fix =>
      'Проверьте параметры NAT/ICE/100rel/таймеров учётной записи.';

  @override
  String get diagSip423Explain =>
      'Срок регистрации короче, чем допускает сервер.';

  @override
  String get diagSip423Fix =>
      'Увеличьте срок регистрации в настройках учётной записи.';

  @override
  String get diagSip480Explain =>
      'Пользователь не зарегистрирован или сейчас недоступен.';

  @override
  String get diagSip480Fix =>
      'Убедитесь, что другая сторона зарегистрирована; при регистрации сервер может быть перегружен: повторите позже.';

  @override
  String get diagSip481Explain =>
      'Сервер потерял состояние диалога (например, после перезапуска или смены сети).';

  @override
  String get diagSip481Fix =>
      'Завершите звонок и повторите. Если это часто, включите таймеры сессии.';

  @override
  String get diagSip483Explain => 'Запрос циркулирует между серверами.';

  @override
  String get diagSip483Fix =>
      'Проверьте настройки переадресации и маршрутизации на АТС.';

  @override
  String get diagSip484Explain => 'Набранный номер слишком короткий.';

  @override
  String get diagSip484Fix =>
      'Наберите номер полностью или проверьте правила набора.';

  @override
  String get diagSip486Explain => 'Абонент занят.';

  @override
  String get diagSip486Fix => 'Повторите позже.';

  @override
  String get diagSip487Explain => 'Звонок отменён до ответа.';

  @override
  String get diagSip487Fix =>
      'Это нормально, если звонящий положил трубку во время вызова.';

  @override
  String get diagSip488Explain =>
      'Нет общего кодека или настройки шифрования с другой стороной.';

  @override
  String get diagSip488Fix =>
      'Проверьте кодеки и SRTP (учётная запись с обязательным SRTP не может звонить на конечную точку с обычным RTP).';

  @override
  String get diagSip491Explain => 'Два re-INVITE столкнулись.';

  @override
  String get diagSip491Fix => 'Обычно повторяется автоматически.';

  @override
  String get diagSip500Explain => 'Внутренний сбой сервера.';

  @override
  String get diagSip500Fix =>
      'Повторите позже и обратитесь к провайдеру, если сбой продолжается.';

  @override
  String get diagSip502Explain =>
      'Вышестоящий сервер вернул недопустимый ответ.';

  @override
  String get diagSip502Fix =>
      'Повторите позже; обратитесь к провайдеру, если сбой продолжается.';

  @override
  String get diagSip503Explain =>
      'Сервер перегружен, недоступен или отклоняет этого клиента (ограничение частоты).';

  @override
  String get diagSip503Fix =>
      'Подождите и повторите, проверьте страницу состояния провайдера или попробуйте другой сервер/порт.';

  @override
  String get diagSip504Explain => 'Вышестоящий сервер не ответил вовремя.';

  @override
  String get diagSip504Fix => 'Повторите позже.';

  @override
  String get diagSip600Explain => 'Все адресаты заняты.';

  @override
  String get diagSip600Fix => 'Повторите позже.';

  @override
  String get diagSip603Explain => 'Другая сторона отклонила звонок.';

  @override
  String get diagSip603Fix => 'Исправлять нечего: звонок был отклонён.';

  @override
  String get diagSip604Explain => 'Такого номера не существует.';

  @override
  String get diagSip604Fix => 'Проверьте набранный номер.';

  @override
  String get diagSip606Explain =>
      'Другая сторона не может принять сессию в предложенном виде.';

  @override
  String get diagSip606Fix => 'Проверьте кодеки и настройки шифрования.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Предварительный ответ ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'Запрос обрабатывается.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Успешно ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'Запрос выполнен.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Перенаправлено ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'Адресат переместился.';

  @override
  String get diagSipRedirectedFix => 'Проверьте настройки переадресации.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Ошибка клиента ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'Сервер отклонил запрос.';

  @override
  String get diagSipClientErrorFix =>
      'Проверьте учётную запись и набранный номер.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Ошибка сервера ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'Серверу не удалось обработать запрос.';

  @override
  String get diagSipServerErrorFix =>
      'Повторите позже или обратитесь к провайдеру.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Глобальный отказ ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'Запрос нигде не может быть выполнен.';

  @override
  String get diagSipNoResponseTitle => 'Нет ответа';

  @override
  String get diagSipNoResponseExplain => 'SIP-ответ не получен.';

  @override
  String get diagSipNoResponseFix =>
      'Проверьте подключение к сети и адрес сервера.';

  @override
  String get diagWizStepNet => 'Подключение к сети';

  @override
  String diagWizStepDns(String account) {
    return 'DNS и SRV: $account';
  }

  @override
  String get diagWizStepNat => 'Тип NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Доступность сервера: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'Сертификат TLS: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Регистрация: $account';
  }

  @override
  String get diagWizStepAlg => 'Проверка SIP ALG';

  @override
  String get diagWizChecking => 'Проверка...';

  @override
  String diagWizEngineError(String message) {
    return 'Ошибка движка: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Проверка не удалась: $error';
  }

  @override
  String get diagWizNoEngine => 'SIP-движок не запущен';

  @override
  String get diagWizNoEngineFix =>
      'Дождитесь запуска движка (или перезапустите приложение) и повторите проверки.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (частный)';
  }

  @override
  String get diagWizNetNone => 'Нет активного сетевого интерфейса с IP-адресом';

  @override
  String get diagWizNetNoneFix =>
      'Подключитесь к Wi-Fi, Ethernet или мобильной сети и повторите проверки.';

  @override
  String get diagWizNetIpv6Only => 'Найдены только адреса IPv6';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Многие SIP-провайдеры работают только по IPv4. Включите IPv4 в этой сети или выберите провайдера с поддержкой IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 адреса IPv4',
      many: '$v4 адресов IPv4',
      few: '$v4 адреса IPv4',
      one: '$v4 адрес IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces интерфейсах',
      many: '$ifaces интерфейсах',
      few: '$ifaces интерфейсах',
      one: '$ifaces интерфейсе',
    );
    return '$_temp0 на $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Активен интерфейс типа VPN. VPN может увеличивать задержку или блокировать UDP; отключите его, если звонки работают некорректно.';

  @override
  String get diagWizDnsNoServer => 'У учётной записи нет адреса сервера';

  @override
  String get diagWizDnsNoServerFix =>
      'Измените учётную запись и введите SIP-домен.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host — это IP-адрес, DNS не нужен';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: нет';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: нет ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: нет';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (приоритет $priority, вес $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: поиск не удался ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host не разрешается';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Проверьте домен на опечатки и работу вашего DNS-сервера. Свой DNS-сервер можно указать в разделе «Настройки» > «Сеть» (например, 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return 'У $host есть SRV-записи, но нет адресной записи';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Будут использованы цели SRV. Если звонки не проходят, попросите провайдера проверить A-запись.';

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
      other: ', $srv SRV-записи',
      many: ', $srv SRV-записей',
      few: ', $srv SRV-записи',
      one: ', $srv SRV-запись',
      zero: '',
    );
    return '$host разрешается в $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Время определения NAT истекло';

  @override
  String get diagWizNatTimeoutFix =>
      'Сервер STUN может быть недоступен (UDP заблокирован?). Проверьте «Настройки» > «Сеть» > «Серверы STUN».';

  @override
  String diagWizNatStun(String server) {
    return 'Сервер STUN: $server';
  }

  @override
  String get diagWizNatOpen => 'Нет NAT: у этого устройства публичный адрес';

  @override
  String get diagWizNatFullCone => 'Full cone NAT: подходит для VoIP';

  @override
  String get diagWizNatRestricted =>
      'Restricted cone NAT: работает со STUN и keep-alive';

  @override
  String get diagWizNatPortRestricted =>
      'Port-restricted cone NAT: работает со STUN и keep-alive';

  @override
  String get diagWizNatSymmetric =>
      'Симметричный NAT: один STUN не может предсказать медиапорт';

  @override
  String get diagWizNatSymmetricFix =>
      'В некоторых звонках вероятна односторонняя слышимость или её отсутствие. Включите ICE и ретранслятор TURN в настройках учётной записи (Учётная запись > NAT) или используйте провайдера/АТС с медиаретрансляцией (rtpengine).';

  @override
  String get diagWizNatBlocked => 'Похоже, UDP заблокирован';

  @override
  String get diagWizNatBlockedFix =>
      'Используйте для учётной записи транспорт TCP или TLS. Если сеть фильтрует всё, кроме веб-трафика, попробуйте TLS на порту 443, если ваш провайдер это поддерживает.';

  @override
  String get diagWizNatUnknown => 'Не удалось определить тип NAT';

  @override
  String get diagWizNatUnknownFix =>
      'Сервер STUN не ответил. Попробуйте другой сервер STUN в разделе «Настройки» > «Сеть».';

  @override
  String get diagWizNatErr =>
      'Сервер STUN не ответил, поэтому тип NAT определить не удалось.';

  @override
  String get diagWizNatUnknownRaw => 'Не удалось определить тип NAT.';

  @override
  String get diagWizOptionsNotLoaded => 'Учётная запись не загружена в движок';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Нет ответа на OPTIONS в течение $seconds с (транспорт: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'Сервер недоступен. Проверьте адрес и порт, не блокирует ли межсетевой экран SIP, и попробуйте другой транспорт (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Время запроса истекло ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'Сервер ответил $code $reason через $ms мс';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'Сервер ответил $code $reason за $ms мс';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Ответ $code на OPTIONS — это нормально: сервер доступен, но не разрешает анонимные проверки.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Задержка круговой передачи свыше 300 мс заметно ухудшает разговор. Поможет более близкий сервер или проводное подключение.';

  @override
  String get diagWizTlsRejected => 'Сертификат сервера отклонён';

  @override
  String diagWizTlsSubject(String value) {
    return 'Субъект: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Издатель: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Проблемы: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Истекает: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Шифр: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Если это ваша собственная АТС с самоподписанным сертификатом и отпечаток выше совпадает, ему можно доверять. Иначе попросите у провайдера сертификат от публичного CA.';

  @override
  String get diagWizTlsTrust => 'Доверять этому сертификату';

  @override
  String diagWizTlsExpired(String date) {
    return 'Срок действия сертификата истёк $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Попросите администратора сервера обновить сертификат.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Сертификат истекает через $days дня',
      many: 'Сертификат истекает через $days дней',
      few: 'Сертификат истекает через $days дня',
      one: 'Сертификат истекает через $days день',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Сообщите администратору сервера, чтобы он скоро его обновил.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Подключено, но проверка сообщила: $problems';
  }

  @override
  String get diagWizTlsOk =>
      'TLS-соединение установлено, сертификат действителен';

  @override
  String get diagWizTlsRegistered =>
      'Зарегистрировано по TLS (сведения о сертификате не получены)';

  @override
  String get diagWizTlsNone => 'TLS-соединений пока не наблюдалось';

  @override
  String get diagWizTlsNoneFix =>
      'Проверьте порт TLS (обычно 5061) и что сервер принимает TLS 1.2 или новее.';

  @override
  String get diagWizRegDisabledByConfig =>
      'Регистрация для этой учётной записи отключена (прямое соединение)';

  @override
  String get diagWizRegRegistered => 'Зарегистрировано';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Зарегистрировано (истекает через $seconds с)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Транспорт: $transport';
  }

  @override
  String get diagWizRegInProgress => 'Регистрация ещё выполняется';

  @override
  String get diagWizRegInProgressFix =>
      'Подождите несколько секунд. Если она так и не завершится, сервер не отвечает; см. проверку доступности выше.';

  @override
  String get diagWizRegFailed => 'Регистрация не удалась';

  @override
  String get diagWizRegOffline => 'Учётная запись не в сети';

  @override
  String get diagWizRegOfflineFix =>
      'Проверьте подключение к сети. Приложение повторяет попытки автоматически.';

  @override
  String get diagWizRegDisabled => 'Учётная запись отключена';

  @override
  String get diagWizAlgNoUdp =>
      'Ни одна учётная запись не использует UDP, поэтому SIP ALG не мешает';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: нет ответа по UDP, но TCP ответил ($code, $ms мс)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: нет ответа ни по UDP, ни по TCP (проблема сервера или межсетевого экрана, а не ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: на OPTIONS отвечают, но REGISTER не проходит по тайм-ауту — это типично для маршрутизатора, изменяющего SIP';
  }

  @override
  String get diagWizAlgSuspected =>
      'Возможно, на вашем маршрутизаторе работает SIP ALG';

  @override
  String get diagWizAlgSuspectedFix =>
      'Отключите «SIP ALG» / «SIP helper» в настройках маршрутизатора, переведите учётную запись на TCP или TLS либо измените порт SIP (например, на 5080), чтобы маршрутизатор перестал искажать пакеты.';

  @override
  String get diagWizAlgContactChanged =>
      'Адрес Contact изменился между запросом и ответом';

  @override
  String get diagWizAlgContactChangedFix =>
      'Это может быть SIP ALG или сервер, изменяющий контакты. Если звонки идут, но без звука или обрываются через некоторое время, отключите SIP ALG на маршрутизаторе или используйте TCP/TLS либо порт 5080.';

  @override
  String get diagWizAlgOk => 'Признаков вмешательства SIP ALG нет';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'Contact в REGISTER $sent вернулся как $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Сохранить $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return 'Сохранено: $fileName';
  }

  @override
  String get diagSaveFailed => 'Не удалось сохранить файл';

  @override
  String get diagCopiedText => 'Текст скопирован в буфер обмена';

  @override
  String get diagCopiedReport => 'Отчёт скопирован в буфер обмена';

  @override
  String get diagCopiedBundle =>
      'Диагностический пакет скопирован в буфер обмена';

  @override
  String get diagCopiedLogs => 'Журналы скопированы в буфер обмена';

  @override
  String get diagCopiedTrace => 'Трассировка скопирована в буфер обмена';

  @override
  String get diagCopiedDialog => 'Диалог скопирован в буфер обмена';

  @override
  String get diagSaveAsLog => 'Сохранить как .log';

  @override
  String get diagSysAppVersion => 'Версия приложения';

  @override
  String get diagSysPlatform => 'Платформа';

  @override
  String get diagSysEngine => 'Движок';

  @override
  String get diagSysAccounts => 'Учётные записи';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return 'Зарегистрировано $registered из $total';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Не удалось прочитать сведения о системе: $error';
  }

  @override
  String get diagSysTransports => 'Транспорты';

  @override
  String get diagSysNoneReported => 'Нет данных';

  @override
  String get diagSysCodecs => 'Кодеки';

  @override
  String get diagSysCodecsFooter =>
      'Включённые кодеки, сначала с наивысшим приоритетом.';

  @override
  String get diagSysEngineNotRunning => 'Движок не запущен';

  @override
  String diagSysCodecPriority(int priority) {
    return 'приоритет $priority';
  }

  @override
  String get diagSysCodecDisabled => 'отключён';

  @override
  String get diagSysExport => 'Экспорт';

  @override
  String get diagSysExportFooter =>
      'Пакет содержит сведения о системе, результаты проверки сети, последние журналы и SIP-трассировку; учётные данные скрыты.';

  @override
  String get diagSysCopyBundle => 'Копировать диагностический пакет';

  @override
  String get diagSysSaveBundle => 'Сохранить диагностический пакет';

  @override
  String get diagTabSipTrace => 'SIP-трассировка';

  @override
  String get diagTabNetwork => 'Сеть';

  @override
  String get diagTabQuality => 'Качество';

  @override
  String get diagTabAudioTest => 'Проверка звука';

  @override
  String get diagTabLogs => 'Журналы';

  @override
  String get diagTabSystem => 'Система';

  @override
  String diagRawSentTo(String remote) {
    return 'отправлено на $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'получено от $remote';
  }

  @override
  String get diagRawCopied => 'Сообщение скопировано';

  @override
  String get diagRawLadder => 'Диаграмма';

  @override
  String get diagRawRedact => 'Скрыть учётные данные';

  @override
  String diagRawTruncated(int count) {
    return '... обрезано ($count симв.)';
  }

  @override
  String get diagWizIntro =>
      'Проверяет подключение, DNS, NAT, доступность сервера, TLS и регистрацию и объясняет, что исправить.';

  @override
  String get diagWizStop => 'Стоп';

  @override
  String get diagWizRunChecks => 'Запустить проверки';

  @override
  String get diagWizRunAgain => 'Повторить';

  @override
  String get diagWizCopyReport => 'Копировать отчёт';

  @override
  String get diagWizSaveReport => 'Сохранить отчёт';

  @override
  String diagWizCountPassed(int count) {
    return 'Успешно: $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Предупреждения: $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Сбои: $count';
  }

  @override
  String get diagWizStatusPass => 'Успешно';

  @override
  String get diagWizStatusWarn => 'Предупреждение';

  @override
  String get diagWizStatusFail => 'Сбой';

  @override
  String get diagWizStatusSkipped => 'Пропущено';

  @override
  String get diagWizStatusRunning => 'Выполняется';

  @override
  String get diagWizStatusPending => 'Ожидает';

  @override
  String get diagQualityTitle => 'Качество связи';

  @override
  String get diagQualityNoData =>
      'Данные о качестве для этого звонка не записаны.';

  @override
  String get diagQualityTraceForCall => 'SIP-трассировка этого звонка';

  @override
  String get diagQualityTraceNotCaptured =>
      'SIP-трассировка этого звонка не записана';

  @override
  String get diagQualityLiveCall => 'Текущий звонок';

  @override
  String get diagQualityNoActiveCall =>
      'Нет активного звонка. Начните звонок, и здесь в реальном времени будут показаны MOS, джиттер, потери и задержка.';

  @override
  String get diagQualityRecentCalls => 'Недавние звонки';

  @override
  String get diagQualityNoFinished =>
      'Завершённых звонков с данными о качестве пока нет.';

  @override
  String get diagQualityCallEnded => 'Звонок завершён.';

  @override
  String get diagQualityMeasuring => 'измерение';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'График: $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'График: $title, последнее значение $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   макс. $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Среднее $avg  ·  худшее $worst';
  }

  @override
  String get diagQualityCodec => 'Кодек';

  @override
  String get diagQualityLoss => 'Потери';

  @override
  String get diagQualityJitter => 'Джиттер';

  @override
  String diagQualityPackets(int count) {
    return '$count пакетов';
  }

  @override
  String get diagQualityMedia => 'Медиа';

  @override
  String get diagQualityNoSeries =>
      'Временной ряд для этого звонка не записан.';

  @override
  String get diagQualityPacketLoss => 'Потеря пакетов';

  @override
  String get diagQualityRtt => 'Время кругового обхода';

  @override
  String get diagLogsForward => 'Пересылать журналы движка';

  @override
  String get diagLogsForwardSub =>
      'Отправлять строки журнала pjsip в этот просмотрщик';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Уровень $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Скрывать при экспорте';

  @override
  String get diagLogsSearch => 'Поиск по журналам';

  @override
  String get diagLogsEmpty => 'Строк журнала пока нет.';

  @override
  String get diagLogsForwardingOff =>
      'Пересылка журналов выключена. Включите её, чтобы записывать журналы движка.';

  @override
  String get diagLogsNoMatch => 'Нет строк, соответствующих поиску.';

  @override
  String get diagAudioEngineNotRunning => 'SIP-движок не запущен.';

  @override
  String get diagAudioMicrophone => 'Микрофон';

  @override
  String get diagAudioMicFooter =>
      'Индикатор уровня считывает звуковое устройство, которое движок открывает во время звонка или эхо-теста.';

  @override
  String get diagAudioLevelMeter => 'Индикатор уровня';

  @override
  String get diagAudioLevelMeterSub => 'Говорите и следите за полосой';

  @override
  String get diagAudioMic => 'Микр.';

  @override
  String get diagAudioSpeaker => 'Динамик';

  @override
  String get diagAudioEchoTest => 'Эхо-тест';

  @override
  String get diagAudioEchoFooter =>
      'Воспроизводит ваш голос через динамик. Используйте наушники, чтобы избежать свиста.';

  @override
  String get diagAudioEchoActive => 'Включён: говорите';

  @override
  String get diagAudioEchoIdle => 'Петля микрофон — динамик';

  @override
  String get diagAudioSpeakerTest => 'Проверка динамика';

  @override
  String get diagAudioPlayTone => 'Воспроизвести тестовый сигнал';

  @override
  String get diagAudioPlayToneSub => 'Воспроизводится через выбранный динамик';

  @override
  String get diagAudioPlayingDtmf => 'Воспроизводится DTMF';

  @override
  String get diagAudioPlayingRingback => 'Воспроизводится контроль вызова';

  @override
  String get diagAudioRingback => 'Контроль вызова';

  @override
  String get diagAudioDevices => 'Устройства';

  @override
  String get diagAudioChooseDevices => 'Выбор микрофона и динамика';

  @override
  String get diagAudioChooseDevicesSub => 'Открывает «Настройки» > «Звук»';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return '$label: уровень $percent процентов';
  }

  @override
  String get diagLadderLocal => 'Локально';

  @override
  String diagLadderSent(String message) {
    return 'Отправлено: $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Получено: $message';
  }

  @override
  String get diagTraceCapture => 'Захватывать SIP-сообщения';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$_temp0  ·  $size  ·  удалено старых: $dropped';
  }

  @override
  String get diagTraceOffHint =>
      'Выключено. Включите, затем зарегистрируйтесь или совершите звонок.';

  @override
  String get diagTraceExportOrClear => 'Экспорт или очистка';

  @override
  String get diagTraceSaveAsPcap => 'Сохранить как .pcap';

  @override
  String get diagTraceCopyAsText => 'Копировать как текст';

  @override
  String get diagTraceSearchHint => 'Текст, номер или Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Только ошибки';

  @override
  String get diagTraceFilterMethod => 'Фильтр по методу';

  @override
  String get diagTraceAllMethods => 'Все методы';

  @override
  String get diagTraceMethod => 'Метод';

  @override
  String get diagTraceFilterAccount => 'Фильтр по учётной записи';

  @override
  String get diagTraceAllAccounts => 'Все учётные записи';

  @override
  String get diagTraceAccount => 'Учётная запись';

  @override
  String get diagTraceRedact => 'Скрыть';

  @override
  String get diagTraceList => 'Список';

  @override
  String get diagTraceWaiting => 'Ожидание SIP-трафика';

  @override
  String get diagTraceWaitingSub =>
      'Зарегистрируйте учётную запись или совершите звонок, и сообщения появятся здесь.';

  @override
  String get diagTraceOff => 'SIP-трассировка выключена';

  @override
  String get diagTraceOffSub =>
      'Включите захват, чтобы видеть каждый SIP-запрос и ответ в виде списка или диаграммы обмена.';

  @override
  String get diagTraceNoMatch => 'Нет сообщений, подходящих под фильтры';

  @override
  String get diagTraceAllDialogs => 'Все диалоги';

  @override
  String get diagTraceCopyDialog => 'Копировать этот диалог';

  @override
  String get diagTraceNoResponse => 'нет ответа';

  @override
  String get diagTraceNoCallId => 'нет Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Запись';

  @override
  String get recFormatWav => 'Стандартный (WAV)';

  @override
  String get recFormatWavStereo =>
      'Стерео: вы и собеседник на разных каналах (WAV)';

  @override
  String get recFormatOpus => 'Сжатый (Opus)';

  @override
  String get recFormatWavHint =>
      'Моно, около 2 МБ в минуту. Воспроизводится везде.';

  @override
  String get recFormatWavStereoHint =>
      'Два канала, около 4 МБ в минуту. Вы слева, собеседник справа.';

  @override
  String get recFormatOpusHint =>
      'Около 0,2 МБ в минуту. Ogg Opus; некоторые плееры на iPhone, Mac и Windows не могут его открыть.';

  @override
  String get recOptionInherit => 'Общая настройка';

  @override
  String get recOptionAlways => 'Записывать все звонки';

  @override
  String get recOptionIncoming => 'Записывать только входящие';

  @override
  String get recOptionOutgoing => 'Записывать только исходящие';

  @override
  String get recOptionNever => 'Никогда не записывать';

  @override
  String get recRuleAll => 'Все звонки';

  @override
  String get recRuleIncoming => 'Только входящие';

  @override
  String get recRuleOutgoing => 'Только исходящие';

  @override
  String get recAutoDeleteNever => 'Никогда';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Через $days дня',
      many: 'Через $days дней',
      few: 'Через $days дня',
      one: 'Через $days день',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Через 1 год';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'через $days дня',
      many: 'через $days дней',
      few: 'через $days дня',
      one: 'через $days день',
    );
    return '$_temp0  ·  $size  ·  автоудаление $_temp1';
  }

  @override
  String get recSettingsFormat => 'Формат';

  @override
  String get recSettingsAutoGroup => 'Автоматическая запись';

  @override
  String get recSettingsAutoFooter =>
      'Прежде чем записывать звонки, ознакомьтесь с местным законодательством. Включите в контакте «Всегда записывать звонки с этим контактом», чтобы записывать их независимо от этих правил.';

  @override
  String get recSettingsAutoRule => 'Записывать звонки автоматически';

  @override
  String get recSettingsAccountOverride =>
      'Переопределение для этой учётной записи';

  @override
  String get recSettingsNoticesGroup => 'Уведомления';

  @override
  String get recSettingsNoticeSwitch => 'Проигрывать уведомление перед записью';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Сначала собеседнику проигрывается уведомление. Файл уведомления выбирается в разделе «Настройки» > «Звонки» > «Объявления».';

  @override
  String get recSettingsNoticeFile => 'Выбрать файл уведомления';

  @override
  String get recSettingsNoticeFileHint =>
      'Открывает «Настройки» > «Звонки» > «Объявления»';

  @override
  String get recSettingsBeep => 'Сигнал записи';

  @override
  String get recSettingsBeepHint => 'Периодически предупреждать собеседника';

  @override
  String get recSettingsTransfersGroup => 'Переводы';

  @override
  String get recSettingsContinue => 'Продолжать запись при переводах';

  @override
  String get recSettingsContinueHint =>
      'Записывать консультационный звонок при переводе с консультацией и звонок, переданный нам переводом, и связывать записи';

  @override
  String get recSettingsStorageGroup => 'Хранилище';

  @override
  String get recSettingsFolder => 'Папка';

  @override
  String get recSettingsFolderHint => 'Куда сохраняются записи';

  @override
  String get recSettingsFolderPlaceholder => 'Документы приложения / Записи';

  @override
  String get recSettingsChooseFolder => 'Выбрать папку...';

  @override
  String get recSettingsFolderPickerTitle => 'Папка записей';

  @override
  String get recSettingsAutoDelete => 'Удалять старые записи';

  @override
  String get recSettingsAutoDeleteHint =>
      'Проверяется при запуске и раз в сутки';

  @override
  String get recSettingsManage => 'Управление записями';

  @override
  String get recSettingsOpenFolder => 'Открыть папку записей';

  @override
  String get recPageTitle => 'Записи';

  @override
  String recSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get recCancelSelection => 'Отменить выбор';

  @override
  String get recSelectAll => 'Выбрать все';

  @override
  String get recShareSelected => 'Отправить выбранные';

  @override
  String get recDeleteSelected => 'Удалить выбранные';

  @override
  String get recSearchTooltip => 'Поиск записей';

  @override
  String get recSelectTooltip => 'Выбрать записи';

  @override
  String get recMenuSettings => 'Настройки записи';

  @override
  String get recSearchHint => 'Поиск по имени или номеру';

  @override
  String get recEmptyNone => 'Записей пока нет';

  @override
  String get recEmptyNoneHint =>
      'Запишите звонок кнопкой «Запись» или включите автоматическую запись в настройках.';

  @override
  String get recEmptyNoMatch => 'Подходящих записей нет';

  @override
  String get recEmptyNoMatchHint => 'Попробуйте другой поиск или фильтр.';

  @override
  String get recClearFilters => 'Сбросить фильтры';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count записи?',
      many: 'Удалить $count записей?',
      few: 'Удалить $count записи?',
      one: 'Удалить $count запись?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Аудиофайлы будут удалены с этого устройства. Это действие нельзя отменить.';

  @override
  String get recDeleteOneTitle => 'Удалить эту запись?';

  @override
  String get recDeleteOneMessage =>
      'Аудиофайл будет удалён с этого устройства. Это действие нельзя отменить.';

  @override
  String get recFilterAll => 'Все';

  @override
  String get recFilterIncoming => 'Входящие';

  @override
  String get recFilterOutgoing => 'Исходящие';

  @override
  String get recFilterByAccount => 'Фильтр по учётной записи';

  @override
  String get recFilterAllAccounts => 'Все учётные записи';

  @override
  String get recFilterAccountFallback => 'Учётная запись';

  @override
  String get recFilterAnyDate => 'Любая дата';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Сбросить даты';

  @override
  String get recMissingFile => 'Аудиофайл отсутствует на этом устройстве.';

  @override
  String recRelated(String title) {
    return 'Связано: $title';
  }

  @override
  String get recRenameTitle => 'Переименование записи';

  @override
  String get recRenameHint => 'Название';

  @override
  String get recSaveAs => 'Сохранить как...';

  @override
  String get recShowInFinder => 'Показать в Finder';

  @override
  String get recShowInFolder => 'Показать в папке';

  @override
  String get recViewCall => 'Открыть звонок';

  @override
  String recSavedTo(String path) {
    return 'Сохранено в $path';
  }

  @override
  String get recSaveFailed => 'Не удалось сохранить запись';

  @override
  String get recShareFailed => 'Не удалось отправить запись';

  @override
  String get recSaveDialogTitle => 'Сохранение записи';

  @override
  String get recShareSubject => 'Записи звонков';

  @override
  String get recPlayerUnsupported =>
      'Это устройство не может воспроизводить записи Opus здесь.';

  @override
  String get recPlayerOpenWith => 'Открыть в...';

  @override
  String get recPlayerNotFound => 'Файл записи не найден';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Не удаётся воспроизвести эту запись: $error';
  }

  @override
  String get recPlayerPlay => 'Воспроизвести запись';

  @override
  String get recPlayerPause => 'Приостановить запись';

  @override
  String get audioFilesTitle => 'Аудиофайлы';

  @override
  String audioAdded(String name) {
    return 'Добавлено: «$name»';
  }

  @override
  String get audioFileUnavailable => 'Этот файл недоступен.';

  @override
  String get audioNameRequired => 'Введите название';

  @override
  String audioDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get audioDeleteMessage =>
      'Настройки, использующие этот файл, вернутся к значениям по умолчанию.';

  @override
  String get audioGroupAdd => 'Добавить';

  @override
  String get audioAddFooter =>
      'Поддерживаются файлы WAV (PCM, mu-law, A-law) и MP3. Файлы копируются в приложение, поэтому оригинал можно перемещать.';

  @override
  String get audioImport => 'Импорт WAV или MP3…';

  @override
  String get audioGroupMine => 'Мои файлы';

  @override
  String get audioEmptyTitle => 'Файлов пока нет';

  @override
  String get audioEmptyHint =>
      'Импортируйте файл или запишите собственное объявление.';

  @override
  String get audioGroupBuiltIn => 'Встроенные';

  @override
  String get audioBuiltInFooter =>
      'Созданы для SoftphonePro, можно использовать свободно.';

  @override
  String get audioPreviewStop => 'Остановить прослушивание';

  @override
  String audioPreviewPlay(String name) {
    return 'Прослушать: $name';
  }

  @override
  String get audioRecordedName => 'Назовите эту запись';

  @override
  String get audioRecordedDefaultName => 'Моё объявление';

  @override
  String audioSaved(String name) {
    return 'Сохранено: «$name»';
  }

  @override
  String get audioRecorderStop => 'Стоп';

  @override
  String get audioRecorderPlay => 'Воспроизвести запись';

  @override
  String audioRecorderNew(String duration) {
    return 'Новая запись  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Отменить';

  @override
  String get audioRecordOwn => 'Записать своё…';

  @override
  String get audioRecordOwnHint =>
      'Используется микрофон, выбранный в настройках звука';

  @override
  String get audioMissingFile => 'Файл отсутствует';

  @override
  String get audioBuiltInCalm => 'Спокойствие (встроенная)';

  @override
  String get audioBuiltInBreeze => 'Бриз (встроенная)';

  @override
  String get audioBuiltInChime => 'Сигнал уведомления (встроенный)';

  @override
  String get audioErrOnlyWavMp3 => 'Можно использовать только файлы WAV и MP3.';

  @override
  String get audioErrNotFound => 'Файл не найден.';

  @override
  String get audioErrNotSaved => 'Запись не была сохранена.';

  @override
  String get audioErrEmpty => 'Этот аудиофайл пуст или не читается.';

  @override
  String audioErrUnusable(String reason) {
    return 'Этот аудиофайл нельзя использовать ($reason). Используйте WAV (PCM, mu-law или A-law) или MP3.';
  }

  @override
  String get audioRecEngineOff => 'Движок звонков не запущен.';

  @override
  String get audioRecUnsupported =>
      'Эта версия движка звонков не может записывать микрофон.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Не удалось начать запись: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Сбой записи: $reason';
  }

  @override
  String get audioStrengthLow => 'Низкий';

  @override
  String get audioStrengthMedium => 'Средний';

  @override
  String get audioStrengthHigh => 'Высокий';

  @override
  String get audioStrengthMax => 'Макс.';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Как в системе';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Как в системе ($name)';
  }

  @override
  String get voiceTitle => 'Выделение голоса';

  @override
  String get voiceUnavailable =>
      'ИИ-шумоподавление недоступно в этой сборке движка звонков. Обычное шумоподавление в разделе «Обработка» по-прежнему работает.';

  @override
  String get voiceGroupAi => 'ИИ-шумоподавление';

  @override
  String get voiceAiFooter =>
      'Убирает из звонка щелчки клавиатуры, шум вентиляторов и посторонние голоса с помощью нейросети на устройстве (RNNoise). Ничего не покидает ваше устройство. Чем выше уровень, тем больше шума удаляется, но начало слов может обрезаться.';

  @override
  String get voiceMic => 'Мой микрофон';

  @override
  String get voiceMicHint => 'Очищать то, что слышит собеседник';

  @override
  String get voiceOthers => 'Остальные участники';

  @override
  String get voiceOthersHint => 'Очищать звук шумных собеседников';

  @override
  String voiceStrength(String value) {
    return 'Уровень: $value';
  }

  @override
  String get voiceGroupTry => 'Попробуйте';

  @override
  String get voiceTryFooter =>
      'Для эхо-теста используйте наушники, иначе будет свист.';

  @override
  String get voiceEchoTest => 'Проверка с эхом';

  @override
  String get voiceEchoTestHint =>
      'Воспроизводит вам обработанный звук микрофона';

  @override
  String get voiceEchoFailed => 'Эхо-тест не удался';

  @override
  String get voiceGroupSystem => 'Система';

  @override
  String get voiceSystemFooter =>
      'macOS и iOS также могут выделять ваш голос для всех приложений. Выберите «Изоляция голоса» в системном режиме микрофона.';

  @override
  String get voiceSystemMode => 'Системный режим микрофона (изоляция голоса)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Режимы микрофона требуют macOS 12 или iOS 15 и новее.';

  @override
  String get voiceSpeechDetection => 'Обнаружение речи';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent процентов';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Звуковые эффекты Android';

  @override
  String get voiceAndroidFooter =>
      'Телефон также может сам очищать звук микрофона. Эти сведения предоставляет Android, они не зависят от настройки выше.';

  @override
  String get voiceAndroidNs => 'Шумоподавитель';

  @override
  String get voiceAndroidAec => 'Эхоподавитель';

  @override
  String get voiceNotAvailableDevice => 'Недоступно на этом устройстве';

  @override
  String get callLinkNotLocal =>
      'Этот тип ссылки можно использовать только из командной строки этого компьютера.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Подключиться к устройству $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Ссылка из другого приложения или веб-страницы хочет подключить SoftphonePro к этому устройству. Подключайтесь, только если ожидали этого.';

  @override
  String get linkLanConnectAction => 'Подключиться';

  @override
  String get linkImportSensitiveHeader =>
      'Чувствительные изменения в этой конфигурации:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Автоматически отвечает на входящие звонки';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Переадресует звонки на $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Меняет, кто может начать интерком или перехватить звонок (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Переписывает набираемые номера';

  @override
  String get linkImportFlagLinksImmediately =>
      'Звонки по веб-ссылкам начинаются сразу, без подтверждения';

  @override
  String get linkImportFlagDiagnostics =>
      'Включает подробное журналирование или трассировку SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Разрешить автоответ для импортированных учётных записей';

  @override
  String linkImportRefused(String setting) {
    return 'Этот импорт пытается изменить «$setting», что нельзя задать ссылкой, QR-кодом, вставленным текстом или файлом. Используйте на этом компьютере параметр командной строки --provision. Ничего не импортировано.';
  }

  @override
  String get lanPairIntercomNote =>
      'Сопряжённые устройства могут запросить интерком-вызов; перед каждым вас спросят (меняется в Настройки > LAN).';

  @override
  String get callLinkUnsupportedScheme => 'Этот тип ссылок не поддерживается.';

  @override
  String get linkImportFlagAutoRecord => 'Автоматически записывает звонки';

  @override
  String get linkImportFlagBlocklist => 'Изменяет список блокировки звонков';

  @override
  String get linkImportFlagEmergency => 'Изменяет экстренные номера';

  @override
  String get linkImportFlagSpeedDial => 'Задаёт номера быстрого набора';

  @override
  String get linkImportFlagRecordingDelete =>
      'Автоматически удаляет старые записи';

  @override
  String get linkImportFlagFeatureCodes =>
      'Набирает пользовательские служебные коды АТС';

  @override
  String get linkImportAllowAutoRecord =>
      'Разрешить автоматическую запись звонков';

  @override
  String get importIgnoredHeader => 'Игнорируется (импорт этого не разрешает):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - сервер $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Прокси: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'Ретранслятор TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Пользовательские заголовки SIP: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'Идентификатор вызывающего: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'Без шифрования медиа (SRTP выключен)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Адрес: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Обновить существующие: $updated, добавить новые: $added';
  }
}
