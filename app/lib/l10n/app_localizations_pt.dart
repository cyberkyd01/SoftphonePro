// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languagePickerHint =>
      'Os nomes dos idiomas são exibidos no próprio idioma.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluir';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Renomear';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionDetails => 'Detalhes';

  @override
  String get actionMore => 'Mais';

  @override
  String get actionSettings => 'Ajustes';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionRefresh => 'Atualizar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionYes => 'Sim';

  @override
  String get actionNo => 'Não';

  @override
  String get commonOn => 'Ativado';

  @override
  String get commonOff => 'Desativado';

  @override
  String get commonNone => 'Nenhum';

  @override
  String get commonDefault => 'Padrão';

  @override
  String get commonSystem => 'Sistema';

  @override
  String get commonAutomatic => 'Automático';

  @override
  String get commonUnknown => 'Desconhecido';

  @override
  String get commonNotSet => 'Não definido';

  @override
  String get commonError => 'Erro';

  @override
  String get commonLoading => 'Carregando…';

  @override
  String get statusAvailable => 'Disponível';

  @override
  String get statusDoNotDisturb => 'Não perturbe';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'Em ligação';

  @override
  String get settingsEntryAccounts => 'Contas';

  @override
  String get settingsEntryAccountsSub => 'Contas SIP e registro';

  @override
  String get settingsEntryAudio => 'Áudio';

  @override
  String get settingsEntryAudioSub =>
      'Dispositivos, níveis, cancelamento de eco';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Ordem, disponibilidade, Opus';

  @override
  String get settingsEntryCalls => 'Ligações';

  @override
  String get settingsEntryCallsSub =>
      'Não perturbe, espera, atendimento automático, regras de discagem';

  @override
  String get settingsEntryNetwork => 'Rede';

  @override
  String get settingsEntryNetworkSub => 'Transportes, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Gravação';

  @override
  String get settingsEntryNotifications => 'Notificações e toques';

  @override
  String get settingsEntryShortcuts => 'Atalhos';

  @override
  String get settingsEntryShortcutsSub => 'Atalhos globais, teclas no app';

  @override
  String get settingsEntryAppearance => 'Aparência';

  @override
  String get settingsEntryPrivacy => 'Privacidade e segurança';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisionamento';

  @override
  String get settingsEntryProvisioningSub => 'Importar, exportar, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnóstico';

  @override
  String get settingsEntryDiagnosticsSub => 'Rastreamento SIP, testes de rede';

  @override
  String get settingsEntryAdvanced => 'Avançado';

  @override
  String get settingsEntryAbout => 'Sobre';

  @override
  String get settingsAccountsEmptyTitle => 'Adicione sua primeira conta';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Conecte-se ao seu PBX ou provedor SIP para começar a ligar.';

  @override
  String get settingsAccountsAdd => 'Adicionar conta';

  @override
  String get settingsAccountsYourAccounts => 'Suas contas';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  usando servidor de backup';
  }

  @override
  String get settingsAudioDevices => 'Dispositivos';

  @override
  String get settingsAudioMicrophone => 'Microfone';

  @override
  String get settingsAudioSpeaker => 'Alto-falante';

  @override
  String get settingsAudioRinger => 'Campainha';

  @override
  String get settingsAudioRingerSub =>
      'Tocar o toque em um dispositivo separado';

  @override
  String get settingsAudioRefreshDevices => 'Atualizar dispositivos';

  @override
  String get settingsAudioLevelsAndTest => 'Níveis e teste';

  @override
  String get settingsAudioMicVolume => 'Volume do microfone';

  @override
  String get settingsAudioMicLevel => 'Nível do microfone';

  @override
  String get settingsAudioSpeakerVolume => 'Volume do alto-falante';

  @override
  String get settingsAudioSpeakerLevel => 'Nível do alto-falante';

  @override
  String get settingsAudioTestSpeaker => 'Testar alto-falante';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Reproduz um tom curto no alto-falante selecionado';

  @override
  String get settingsAudioTestToneFailed =>
      'Não foi possível reproduzir o tom de teste';

  @override
  String get settingsAudioEchoTestFailed => 'Falha no teste de eco';

  @override
  String get settingsAudioEchoTest => 'Teste de eco';

  @override
  String get settingsAudioEchoTestSub =>
      'Reproduz o áudio do seu microfone no alto-falante. Use fones de ouvido para evitar microfonia.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voz e arquivos';

  @override
  String get settingsAudioVoiceIsolation =>
      'Isolamento de voz (cancelamento de ruído por IA)';

  @override
  String get settingsAudioAudioFiles => 'Arquivos de áudio';

  @override
  String get settingsAudioAudioFilesSub => 'Música de espera e avisos';

  @override
  String get settingsAudioProcessing => 'Processamento';

  @override
  String get settingsAudioEchoCancellation => 'Cancelamento de eco';

  @override
  String get settingsAudioEcSimple => 'Simples';

  @override
  String get settingsAudioEcPlatform => 'Plataforma';

  @override
  String get settingsAudioEchoTail => 'Cauda de eco';

  @override
  String get settingsAudioNoiseSuppression => 'Supressão de ruído';

  @override
  String get settingsAudioAgc => 'Controle automático de ganho';

  @override
  String get settingsAudioVad => 'Detecção de atividade de voz';

  @override
  String get settingsAudioVadSub => 'Economiza banda durante o silêncio';

  @override
  String get settingsAudioAdvanced => 'Avançado';

  @override
  String get settingsAudioAdvancedFooter =>
      'Os valores do jitter buffer são em milissegundos; -1 usa o padrão do mecanismo. Alterá-los reinicia o mecanismo de ligações.';

  @override
  String get settingsAudioPtime => 'Tempo de pacote (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter buffer: inicial';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter buffer: pré-busca mínima';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter buffer: pré-busca máxima';

  @override
  String get settingsAudioJbMaxSize => 'Jitter buffer: tamanho máximo';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microfone $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Outros $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent por cento';
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
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Ordem e disponibilidade';

  @override
  String get settingsCodecsDragHint =>
      'Arraste para reordenar. As contas podem substituir esta lista em suas próprias configurações.';

  @override
  String get settingsCodecsBitrate => 'Taxa de bits';

  @override
  String get settingsCodecsFec => 'FEC in-band';

  @override
  String get settingsCodecsFecSub => 'Recupera perdas de pacotes';

  @override
  String get settingsCodecsDtxSub => 'Parar de enviar durante o silêncio';

  @override
  String get settingsCodecsCbr => 'Taxa de bits constante';

  @override
  String get settingsCodecsComplexity => 'Complexidade';

  @override
  String get settingsCallsIncoming => 'Recebidas';

  @override
  String get settingsCallsDndSub => 'Rejeitar todas as ligações recebidas';

  @override
  String get settingsCallsRejectWith => 'Rejeitar com';

  @override
  String get settingsCallsReasonBusy => 'Ocupado (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Temporariamente indisponível (480)';

  @override
  String get settingsCallsReasonDecline => 'Recusar (603)';

  @override
  String get settingsCallsWaiting => 'Chamada em espera';

  @override
  String get settingsCallsWaitingSub =>
      'Permitir uma segunda ligação recebida durante uma ligação';

  @override
  String get settingsCallsWhenBusy =>
      'Quando ocupado e a chamada em espera estiver desativada';

  @override
  String get settingsCallsRejectAnonymous => 'Rejeitar ligações anônimas';

  @override
  String get settingsCallsLinksImmediately => 'Ligar imediatamente por links';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Links tel:, sip: e callto: fazem a ligação sem esperar no discador';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Sincronizar Não perturbe / desvio com o PBX por códigos de recurso';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Disca brevemente os códigos de asterisco da conta (por exemplo *78) ao alterar Não perturbe ou o desvio';

  @override
  String get settingsCallsAutoAnswerGroup => 'Atendimento automático';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'O desvio de ligações e o atendimento automático por conta são definidos em cada conta.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Atender todas as ligações automaticamente';

  @override
  String get settingsCallsAnswerAfter => 'Atender após';

  @override
  String get settingsCallsAnswerImmediately => 'Imediatamente';

  @override
  String get settingsCallsIntercomHeaders =>
      'Respeitar cabeçalhos de interfone';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Indicações de atendimento automático em Call-Info, Alert-Info e Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Números bloqueados';

  @override
  String get settingsCallsBlockNumber => 'Bloquear um número';

  @override
  String get settingsCallsBlockNumberTitle => 'Bloquear número';

  @override
  String get settingsCallsBlockNumberHint => 'Número ou endereço SIP';

  @override
  String get settingsCallsSpeedDial => 'Discagem rápida';

  @override
  String get settingsCallsDialPlan => 'Plano de discagem';

  @override
  String get settingsCallsDialRules => 'Regras de discagem';

  @override
  String get settingsCallsStripPrefix => 'Prefixo de linha externa a remover';

  @override
  String get settingsCallsStripPrefixSub =>
      'Por exemplo 9, removido do início dos números discados';

  @override
  String get settingsCallsPlusReplacement => 'Substituir + inicial por';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Por exemplo 00 para acesso internacional';

  @override
  String get settingsCallsPlusReplacementHint => 'Manter +';

  @override
  String get settingsCallsCountryPrefix => 'Prefixo de país padrão';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Números nacionais que começam com 0 recebem este prefixo, por exemplo +55';

  @override
  String get settingsCallsEmergency => 'Números de emergência';

  @override
  String get settingsCallsEmergencySub =>
      'Separados por vírgula. Ignoram as regras de discagem.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Desbloquear $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count de 9 atribuídos';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regras',
      one: '1 regra',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nova regra de discagem';

  @override
  String get settingsDialRulesEdit => 'Editar regra de discagem';

  @override
  String get settingsDialRulesName => 'Nome';

  @override
  String get settingsDialRulesPattern => 'Padrão (regex)';

  @override
  String get settingsDialRulesReplacement => 'Substituição';

  @override
  String get settingsDialRulesReplacementHelp => 'Use \$1, \$2 para grupos';

  @override
  String get settingsDialRulesRoute => 'Encaminhar pela conta';

  @override
  String get settingsDialRulesAdd => 'Adicionar regra';

  @override
  String get settingsDialRulesLiveTest => 'Teste ao vivo';

  @override
  String get settingsDialRulesTyped => 'Número digitado';

  @override
  String get settingsDialRulesNothing => '(nada)';

  @override
  String get settingsDialRulesEmergency =>
      'Número de emergência: discado como digitado';

  @override
  String get settingsDialRulesAccountFallback => 'conta';

  @override
  String get settingsDialRulesEmpty =>
      'Nenhuma regra. Os números são limpos (espaços, hifens e parênteses removidos) e discados como digitados. As regras são aplicadas de cima para baixo; vale a primeira correspondência.';

  @override
  String get settingsDialRulesDelete => 'Excluir regra';

  @override
  String get settingsDialRulesDeleteTitle => 'Excluir regra?';

  @override
  String settingsDialRulesVia(String account) {
    return 'via $account';
  }

  @override
  String get settingsNetworkTransports => 'Transportes';

  @override
  String get settingsNetworkTransportsFooter =>
      'A porta 0 escolhe uma porta livre aleatória. Alterar os transportes reinicia o mecanismo de ligações.';

  @override
  String get settingsNetworkUdpPort => 'Porta UDP';

  @override
  String get settingsNetworkTcpPort => 'Porta TCP';

  @override
  String get settingsNetworkTlsPort => 'Porta TLS';

  @override
  String get settingsNetworkVerifyCerts => 'Verificar certificados do servidor';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Desative apenas para PBXs com certificado autoassinado, ou fixe o certificado abaixo';

  @override
  String get settingsNetworkCustomCa => 'Arquivo de CA personalizado';

  @override
  String get settingsNetworkCustomCaSub =>
      'Pacote PEM usado no lugar da lista integrada (CA de PBX privado)';

  @override
  String get settingsNetworkCustomCaHint => 'Lista integrada da Mozilla';

  @override
  String get settingsNetworkPins => 'Certificados fixados';

  @override
  String get settingsNetworkPinsSub =>
      'host=impressão digital SHA256, separados por vírgula';

  @override
  String get settingsNetworkNat => 'Travessia de NAT';

  @override
  String get settingsNetworkStun => 'Servidores STUN';

  @override
  String get settingsNetworkStunSub => 'host:porta, separados por vírgula';

  @override
  String get settingsNetworkIceTurn => 'ICE e TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Configurados por conta em NAT';

  @override
  String get settingsNetworkAdvanced => 'Avançado';

  @override
  String get settingsNetworkQos => 'QoS (marcação DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Marcar pacotes SIP e de voz como prioritários';

  @override
  String get settingsNetworkDns => 'Servidores DNS';

  @override
  String get settingsNetworkDnsSub => 'Deixe em branco para automático';

  @override
  String get settingsNetworkRtpStart => 'Porta RTP inicial';

  @override
  String get settingsNetworkRtpRange => 'Intervalo de portas RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 usa o padrão';

  @override
  String get settingsNotifRingtone => 'Toque';

  @override
  String get settingsNotifDefaultRingtone => 'Toque padrão';

  @override
  String get settingsNotifProgressTones => 'Tons de progresso da ligação';

  @override
  String get settingsNotifProgressTonesSub =>
      'Tons de chamando, ocupado e congestionamento durante a discagem';

  @override
  String get settingsNotifRingerVolume => 'Volume da campainha';

  @override
  String get settingsNotifCustomRingtone => 'Arquivo de toque personalizado';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Caminho de um arquivo WAV (desktop)';

  @override
  String get settingsNotifGroup => 'Notificações';

  @override
  String get settingsNotifRequestPermissions => 'Solicitar permissões';

  @override
  String get settingsNotifRequestPermissionsSub => 'Microfone e notificações';

  @override
  String get settingsNotifTyping => 'Enviar indicadores de digitação';

  @override
  String get settingsAppearanceTheme => 'Tema';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Escuro';

  @override
  String get settingsAppearanceAccent => 'Cor de destaque';

  @override
  String get settingsAppearanceAccentOption => 'Opção de cor de destaque';

  @override
  String get settingsAppearanceCompact => 'Densidade compacta';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microfone: $microphone, notificações: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Segurança';

  @override
  String get settingsPrivacyPasswords => 'Senhas';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Armazenadas no chaveiro / keystore do sistema (com arquivo criptografado como alternativa)';

  @override
  String get settingsPrivacyGroup => 'Privacidade';

  @override
  String get settingsPrivacyNoTelemetry => 'Sem telemetria';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'O SoftphonePro não envia dados de análise. O tráfego de rede vai apenas para os seus servidores SIP.';

  @override
  String get settingsPrivacyYourData => 'Seus dados';

  @override
  String get settingsPrivacyClearHistory => 'Limpar histórico de ligações';

  @override
  String get settingsPrivacyDeleteContacts => 'Excluir todos os contatos';

  @override
  String get settingsPrivacyDeleteMessages => 'Excluir todas as mensagens';

  @override
  String get settingsPrivacyConfirmHistory =>
      'Excluir o histórico de ligações?';

  @override
  String get settingsPrivacyConfirmContacts => 'Excluir todos os contatos?';

  @override
  String get settingsPrivacyConfirmMessages => 'Excluir todas as mensagens?';

  @override
  String get settingsPrivacyCannotUndo => 'Esta ação não pode ser desfeita.';

  @override
  String get settingsPrivacyDeletedHistory => 'Histórico de ligações excluído';

  @override
  String get settingsPrivacyDeletedContacts =>
      'Todos os contatos foram excluídos';

  @override
  String get settingsPrivacyDeletedMessages =>
      'Todas as mensagens foram excluídas';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Os dispositivos na mesma rede se encontram, são pareados com um código de 6 dígitos e conversam diretamente, sem nenhum servidor.';

  @override
  String get settingsLanEnable => 'Ativar LAN Link';

  @override
  String get settingsLanDeviceName => 'Nome do dispositivo';

  @override
  String get settingsLanDeviceNameHint => 'Este dispositivo';

  @override
  String get settingsLanAllowIntercom => 'Permitir interfone';

  @override
  String get settingsLanAllowIntercomSub =>
      'Permite que dispositivos pareados liguem para você e sejam atendidos automaticamente';

  @override
  String get settingsLanAskIntercom =>
      'Perguntar antes de permitir o interfone';

  @override
  String get settingsLanAskIntercomSub =>
      'Caso contrário, os dispositivos pareados são atendidos automaticamente por 30 s após solicitarem';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Aceitar automaticamente arquivos de dispositivos pareados';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Caso contrário, você será consultado a cada arquivo';

  @override
  String get settingsLanAllowPull =>
      'Permitir que dispositivos pareados puxem minhas ligações';

  @override
  String get settingsLanAllowPullSub =>
      'Um dispositivo pareado pode assumir uma ligação ativa aqui';

  @override
  String get settingsLanDownloads => 'Pasta de downloads';

  @override
  String get settingsLanDownloadsHint => 'Padrão (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'Porta do link';

  @override
  String get settingsLanSharedAccounts =>
      'Contas compartilhadas com dispositivos pareados';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Compartilhar uma conta registrada permite que um dispositivo pareado no mesmo servidor receba suas ligações diretamente (transferência de ligação), em vez de retransmiti-las.';

  @override
  String get settingsAdvEngine => 'Mecanismo';

  @override
  String get settingsAdvSimulator => 'Usar simulador';

  @override
  String get settingsAdvSimulatorSub =>
      'Executa sem o mecanismo nativo. As ligações são simuladas.';

  @override
  String get settingsAdvLogLevel => 'Nível de log';

  @override
  String get settingsAdvLogErrors => 'Erros';

  @override
  String get settingsAdvLogInfo => 'Informações';

  @override
  String get settingsAdvLogDebug => 'Depuração';

  @override
  String get settingsAdvLogVerbose => 'Detalhado';

  @override
  String get settingsAdvSipTrace => 'Rastreamento SIP';

  @override
  String get settingsAdvRestartEngine => 'Reiniciar mecanismo';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Iniciar com o sistema';

  @override
  String get settingsAdvCloseToTray => 'Fechar para a bandeja';

  @override
  String get settingsAdvCloseToTraySub =>
      'Ao fechar a janela, o SoftphonePro continua em execução para que as ligações ainda toquem. Saia pelo ícone da bandeja / barra de menus.';

  @override
  String get settingsAboutLicence => 'Licença';

  @override
  String get settingsAboutLicenceFooter =>
      'O SoftphonePro é software livre: você pode redistribuí-lo e/ou modificá-lo sob os termos da Licença Pública Geral GNU, publicada pela Free Software Foundation, versão 3 ou posterior. Ele é distribuído SEM QUALQUER GARANTIA.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 ou posterior';

  @override
  String get settingsAboutGplSub =>
      'Código-fonte disponível no repositório do projeto';

  @override
  String get settingsAboutThirdParty => 'Avisos de terceiros';

  @override
  String get settingsAboutPackages => 'Pacotes Flutter e Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT e Apache 2.0. Veja a página de licenças.';

  @override
  String settingsAboutVersion(String version) {
    return 'Versão $version';
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
    return '$license. $purpose. Versão $version.';
  }

  @override
  String get updatesChecking => 'Verificando...';

  @override
  String updatesAvailable(String version) {
    return 'O SoftphonePro $version está disponível';
  }

  @override
  String get updatesUpToDate => 'Você está com a versão mais recente';

  @override
  String get updatesCouldNotCheck => 'Não foi possível verificar';

  @override
  String get updatesNotCheckedYet => 'Ainda não verificado';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última verificação: $dateString';
  }

  @override
  String get updatesTitle => 'Atualizações';

  @override
  String get updatesFooter =>
      'A verificação contata apenas api.github.com (uma vez por semana) e não envia nada além da própria requisição: nenhum identificador, nem dados de conta ou de ligações. O SoftphonePro nunca baixa nem instala nada por conta própria.';

  @override
  String get updatesCheckSwitch => 'Verificar atualizações';

  @override
  String get updatesCheckNow => 'Verificar agora';

  @override
  String updatesSkippingVersion(String version) {
    return 'Ignorando a versão $version';
  }

  @override
  String get updatesStopSkipping => 'Parar de ignorar';

  @override
  String get updatesReleaseNotes => 'Notas da versão';

  @override
  String get updatesDownload => 'Baixar';

  @override
  String get updatesSkipVersion => 'Ignorar esta versão';

  @override
  String get updatesDismiss => 'Dispensar';

  @override
  String get updatesRateLimited =>
      'Limite de requisições do GitHub atingido, tente novamente mais tarde';

  @override
  String updatesServerAnswered(int status) {
    return 'O GitHub respondeu $status';
  }

  @override
  String get updatesUnexpectedReply => 'Resposta inesperada';

  @override
  String get updatesTimedOut => 'Tempo esgotado';

  @override
  String get updatesAlreadyChecking => 'Já está verificando';

  @override
  String get encryptionTitle => 'Criptografia';

  @override
  String get encryptionFooter =>
      'Encripta a base de dados local com AES-256-GCM. A chave fica no porta-chaves / keystore do sistema; se for perdida, os dados não poderão ser recuperados. As gravações de chamadas e os ficheiros exportados não são encriptados. A alteração entra em vigor na próxima vez que o SoftphonePro for iniciado (feche-o completamente antes); o ficheiro anterior é substituído e eliminado assim que a nova base de dados for aberta e verificada.';

  @override
  String get encryptionSwitchTitle =>
      'Criptografar histórico de ligações, contatos e mensagens neste dispositivo';

  @override
  String get encryptionWillEncrypt =>
      'Será criptografado na próxima inicialização';

  @override
  String get encryptionWillDecrypt =>
      'Será descriptografado na próxima inicialização';

  @override
  String get encryptionRestartToEncrypt =>
      'Feche e reinicie o SoftphonePro para criptografar seus dados.';

  @override
  String get encryptionRestartToDecrypt =>
      'Feche e reinicie o SoftphonePro para descriptografar seus dados.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Discagem rápida $slot';
  }

  @override
  String get speedDialNumberLabel => 'Número ou endereço SIP';

  @override
  String get speedDialLabelOptional => 'Rótulo (opcional)';

  @override
  String get speedDialCallFrom => 'Ligar de';

  @override
  String get speedDialSelectedAccount => 'Conta selecionada';

  @override
  String get speedDialTitle => 'Discagem rápida';

  @override
  String get speedDialHint =>
      'Mantenha pressionado um dígito (1-9) no teclado vazio para ligar para o número correspondente.';

  @override
  String get speedDialNotAssigned => 'Não atribuído';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON inválido: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Era esperado um objeto JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Versão de configuração $version não compatível';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Uma entrada de conta que não é objeto foi ignorada';

  @override
  String get provisioningNothingToImport =>
      'O arquivo não contém contas nem ajustes';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'A conta \"$name\" precisa de usuário e domínio';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'O servidor respondeu $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Não foi possível baixar a configuração: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Não foi possível ler $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas importadas',
      one: '1 conta importada',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Importar configuração';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts contas',
      one: '1 conta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings ajustes',
      one: '1 ajuste',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Importar de URL ou JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... ou cole o JSON';

  @override
  String get provisioningInvalidSource =>
      'Isso não é uma URL, link ou JSON válido';

  @override
  String get provisioningScanTitle => 'Ler QR de provisionamento';

  @override
  String get provisioningPasteHint => 'Cole um JSON, link ou URL';

  @override
  String get provisioningImportGroup => 'Importar';

  @override
  String get provisioningImportFooter =>
      'Aceita JSON com contas e ajustes. Os marcadores \${VAR} são preenchidos com valores vazios, a menos que um padrão seja informado como \${VAR:-padrão}.';

  @override
  String get provisioningScanQr => 'Ler código QR';

  @override
  String get provisioningFromUrl => 'De URL ou JSON colado';

  @override
  String get provisioningFromFile => 'De arquivo';

  @override
  String get provisioningFromClipboard => 'Da área de transferência';

  @override
  String get provisioningExportGroup => 'Exportar';

  @override
  String get provisioningIncludePasswords => 'Incluir senhas';

  @override
  String get provisioningIncludePasswordsHint =>
      'Qualquer pessoa com o arquivo pode usar suas contas';

  @override
  String get provisioningCopyConfig => 'Copiar configuração (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuração copiada';

  @override
  String get provisioningQrGroup => 'Código QR';

  @override
  String get provisioningQrFooter =>
      'Leia este código em outro dispositivo para copiar uma conta. Trate-o como uma senha se ele incluir uma.';

  @override
  String get provisioningQrAccount => 'Conta';

  @override
  String get provisioningChoose => 'Escolher...';

  @override
  String get provisioningQrTooMuchData => 'Dados demais para um código QR';

  @override
  String tlsClearField(String field) {
    return 'Limpar $field';
  }

  @override
  String get tlsChoose => 'Escolher...';

  @override
  String get tlsChange => 'Alterar...';

  @override
  String get tlsClientCertTitle => 'Certificado de cliente (TLS mútuo)';

  @override
  String get tlsIncomplete =>
      'Escolha um certificado e a respectiva chave privada. O certificado só é apresentado quando ambos estão definidos.';

  @override
  String get tlsFooter =>
      'Para servidores que pedem ao app que se identifique com um certificado. Arquivos PEM. Usado para TLS e WebSocket seguro.';

  @override
  String get tlsCertFile => 'Arquivo de certificado';

  @override
  String get tlsKeyFile => 'Arquivo de chave privada';

  @override
  String get tlsKeyPassword => 'Senha da chave';

  @override
  String get tlsKeyPasswordHint => 'Somente se a chave for criptografada';

  @override
  String get callSettingsHoldGroupTitle => 'Espera';

  @override
  String get callSettingsHoldFooter =>
      'Com \"Padrão do PBX\", a ligação é simplesmente colocada em espera e o seu sistema telefônico pode tocar a própria música. Qualquer outra escolha é reproduzida para quem ligou por este app.';

  @override
  String get callSettingsHoldMusic => 'Música de espera';

  @override
  String get callSettingsHoldPbxDefault => 'Padrão do PBX';

  @override
  String get callSettingsHoldMusicVolume => 'Volume da música de espera';

  @override
  String get callSettingsHoldAudioFiles => 'Arquivos de áudio';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Importe ou grave músicas de espera';

  @override
  String get callSettingsAnnounceTitle => 'Avisos';

  @override
  String get callSettingsAnnounceFooter =>
      'Os avisos são reproduzidos para a outra pessoa. Tudo é ignorado silenciosamente se o arquivo estiver ausente.';

  @override
  String get callSettingsAnnounceOpening => 'Aviso de abertura';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Reproduzir uma mensagem quando a ligação for conectada';

  @override
  String get callSettingsAnnounceFile => 'Arquivo do aviso';

  @override
  String get callSettingsAnnounceChooseFile => 'Escolha um arquivo';

  @override
  String get callSettingsAnnouncePlayFor => 'Reproduzir em';

  @override
  String get callSettingsAnnounceBoth => 'Recebidas e realizadas';

  @override
  String get callSettingsAnnounceIncoming => 'Ligações recebidas';

  @override
  String get callSettingsAnnounceOutgoing => 'Ligações realizadas';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Silenciar meu microfone durante a reprodução';

  @override
  String get callSettingsAnnounceMonitor => 'Também ouvir o aviso';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Antes de iniciar a gravação, reproduzir';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Antes de transferir quem ligou, reproduzir';

  @override
  String get morePageTitle => 'Mais';

  @override
  String get morePresence => 'Presença';

  @override
  String get morePresenceHint => 'Campo de lâmpada ocupada';

  @override
  String get moreRetrieveParked => 'Recuperar ligação estacionada';

  @override
  String get moreRetrieveParkedHint => 'Disque uma vaga de estacionamento';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint =>
      'Dispositivos próximos, chat e envio de arquivos';

  @override
  String get moreRecordings => 'Gravações';

  @override
  String get moreRecordingsHint =>
      'Ouça, compartilhe e gerencie gravações de ligações';

  @override
  String get moreVoicemail => 'Caixa postal';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens novas',
      one: '1 mensagem nova',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Ligar para sua caixa postal';

  @override
  String get moreDiagnostics => 'Diagnóstico';

  @override
  String get moreDiagnosticsHint => 'Rastreamento SIP e testes de rede';

  @override
  String get moreAbout => 'Sobre';

  @override
  String get moreNoVoicemailNumber =>
      'Nenhum número de caixa postal definido. Adicione um nas configurações da conta.';

  @override
  String get moreSearchHint => 'Busque contatos, histórico ou digite um número';

  @override
  String moreCallNumber(String number) {
    return 'Ligar para $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Bloqueio do app';

  @override
  String get appLockFooter =>
      'As ligações continuam tocando e podem ser atendidas com o app bloqueado.';

  @override
  String get appLockRequirePin => 'Exigir PIN para abrir o app';

  @override
  String get appLockOnHint =>
      'Histórico, contatos, mensagens e ajustes ficam bloqueados';

  @override
  String get appLockIsOn => 'Bloqueio do app ativado';

  @override
  String get appLockIsOff => 'Bloqueio do app desativado';

  @override
  String get appLockTurnOff => 'Desativar bloqueio do app';

  @override
  String get appLockChangePin => 'Alterar PIN';

  @override
  String get appLockEnterCurrent => 'Digite o PIN atual';

  @override
  String get appLockPinChanged => 'PIN alterado';

  @override
  String get appLockLockAfter => 'Bloquear após';

  @override
  String get appLockLockAfterHint =>
      'Tempo em segundo plano antes de o PIN ser exigido novamente';

  @override
  String get appLockImmediately => 'Imediatamente';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 hora';

  @override
  String get appLockBiometrics => 'Desbloquear com biometria';

  @override
  String get appLockNow => 'Bloquear agora';

  @override
  String get appLockSetPin => 'Definir um PIN';

  @override
  String get appLockPinDigits => 'PIN (4 a 8 dígitos)';

  @override
  String get appLockRepeatPin => 'Repita o PIN';

  @override
  String get appLockUseDigits => 'Use de 4 a 8 dígitos';

  @override
  String get appLockMismatch => 'Os PINs não coincidem';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Muitas tentativas. Tente novamente em ${seconds}s';
  }

  @override
  String get appLockWrongPin => 'PIN incorreto';

  @override
  String get appLockTooMany => 'Muitas tentativas';

  @override
  String get appLockIsLocked => 'O SoftphonePro está bloqueado';

  @override
  String get appLockEnterPin => 'Digite seu PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Tente novamente em $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '${seconds}s';
  }

  @override
  String get appLockUnlock => 'Desbloquear';

  @override
  String get appLockIncomingCall => 'Ligação recebida';

  @override
  String get appLockDecline => 'Recusar';

  @override
  String get appLockAnswer => 'Atender';

  @override
  String get appLockHangUp => 'Desligar';

  @override
  String get appLockBiometricReason => 'Desbloquear o SoftphonePro';

  @override
  String get automationNoToken =>
      'Nenhum token de acesso definido. Gere um em Ajustes > Avançado.';

  @override
  String automationInvalidPort(int port) {
    return 'Porta $port inválida';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Não foi possível iniciar: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'A porta $port não está disponível ($error). Escolha outra porta.';
  }

  @override
  String get automationTokenPlaceholder => 'Criado quando você ativa a API';

  @override
  String automationListening(String address) {
    return 'Escutando em $address';
  }

  @override
  String get automationStarting => 'Iniciando...';

  @override
  String get automationTitle => 'API de automação local';

  @override
  String get automationFooter =>
      'Para integrações de CRM e helpdesk neste computador. Ela escuta apenas em 127.0.0.1 e toda requisição precisa do token de acesso. Veja docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Ativar API de automação local';

  @override
  String get automationPort => 'Porta';

  @override
  String get automationPortHint =>
      'Padrão 7771. Escolha uma porta livre entre 1024 e 65535.';

  @override
  String get automationPortInvalid => 'Digite uma porta de 1024 a 65535';

  @override
  String get automationAccessToken => 'Token de acesso';

  @override
  String get automationHideToken => 'Ocultar token';

  @override
  String get automationShowToken => 'Mostrar token';

  @override
  String get automationCopyToken => 'Copiar token';

  @override
  String get automationTokenCopied => 'Token copiado';

  @override
  String get automationGenerateToken => 'Gerar um novo token';

  @override
  String get automationGenerateTitle => 'Gerar um novo token?';

  @override
  String get automationGenerateBody =>
      'Os programas que usam o token antigo deixam de funcionar até que você informe o novo.';

  @override
  String get automationGenerate => 'Gerar';

  @override
  String get automationOrigins => 'Origens de navegador permitidas';

  @override
  String get automationOriginsHint =>
      'Separadas por vírgula, por exemplo https://crm.example.com. Programas sem navegador (curl, scripts) não precisam disto.';

  @override
  String automationNotOrigin(String origin) {
    return 'Não é uma origem http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'Atender';

  @override
  String get trayNotificationDecline => 'Recusar';

  @override
  String get trayTooltipInCall => 'SoftphonePro - em ligação';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nova(s)';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - sem contas (Ausente)',
      'dnd': 'SoftphonePro - sem contas (Não perturbe)',
      'other': 'SoftphonePro - sem contas',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Ausente)',
      'dnd': 'SoftphonePro - $online/$total online (Não perturbe)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Ocultar o SoftphonePro';

  @override
  String get trayShowApp => 'Mostrar o SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nova(s) - abrir Recentes';
  }

  @override
  String get trayStatus => 'Status';

  @override
  String get trayStatusAway => 'Ausente';

  @override
  String get trayAccounts => 'Contas';

  @override
  String get trayQuit => 'Sair do SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Atender ligação';

  @override
  String get hotkeyHangUp => 'Desligar';

  @override
  String get hotkeyMute => 'Silenciar / reativar som';

  @override
  String get hotkeyFocusDialer => 'Focar no discador';

  @override
  String get shortcutsGlobalTitle => 'Atalhos globais';

  @override
  String get shortcutsGlobalFooter =>
      'Funcionam em qualquer aplicativo. Outro programa que já use uma combinação pode impedir que ela seja registrada.';

  @override
  String get shortcutsChange => 'Alterar';

  @override
  String get shortcutsRestoreDefaults => 'Restaurar padrões';

  @override
  String get shortcutsMediaTitle => 'Fones e teclas de mídia';

  @override
  String get shortcutsMediaFooter =>
      'O botão de reproduzir/pausar de um fone ou teclado só é capturado enquanto uma ligação toca ou está ativa; no restante do tempo ele continua com os players de música.';

  @override
  String get shortcutsMediaSwitch =>
      'Atender e desligar com o botão de reproduzir/pausar do fone ou de mídia';

  @override
  String get shortcutsMediaDuringCall => 'Durante uma ligação, o botão';

  @override
  String get shortcutsMediaHangsUp => 'Desliga';

  @override
  String get shortcutsMediaMutes => 'Silencia / reativa o som';

  @override
  String get shortcutsInApp => 'No app';

  @override
  String get shortcutsFocusDialer => 'Focar no discador';

  @override
  String get shortcutsHoldResume => 'Espera / retomar';

  @override
  String get shortcutsTransfer => 'Transferir';

  @override
  String get shortcutsEndCall => 'Encerrar ligação';

  @override
  String get shortcutsNeedX11 =>
      'Os atalhos globais requerem uma sessão X11. O Wayland não permite que as aplicações capturem teclas em todo o sistema.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Adicione Ctrl, Alt, Shift ou $key a uma letra ou dígito';
  }

  @override
  String get shortcutsPressNew => 'Pressione a nova combinação de teclas';

  @override
  String get defaultHandlerChooseInSettings =>
      'Escolha o SoftphonePro para SIP, TEL e CALLTO em Aplicativos padrão';

  @override
  String get defaultHandlerNowOpens =>
      'O SoftphonePro agora abre links sip:, tel: e callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Não foi possível alterar o padrão para $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Abre links sip:, tel: e callto: de navegadores e outros apps';

  @override
  String get defaultHandlerIsSelf =>
      'O SoftphonePro trata links sip:, tel: e callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Agora: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Tornar o SoftphonePro o app padrão para links sip:, tel: e callto:';

  @override
  String get reliabilityTitle => 'Confiabilidade em segundo plano';

  @override
  String get reliabilityMicrophone => 'Microfone';

  @override
  String get reliabilityAllowed => 'Permitido';

  @override
  String get reliabilityMicNeeded => 'Necessário para falar nas ligações';

  @override
  String get reliabilityNotifications => 'Notificações';

  @override
  String get reliabilityNotifNeeded =>
      'Necessárias para exibir ligações recebidas e manter o serviço visível';

  @override
  String get reliabilityFullScreen => 'Ligações recebidas em tela cheia';

  @override
  String get reliabilityFullScreenNeeded =>
      'Permita para que as ligações apareçam sobre a tela de bloqueio';

  @override
  String get reliabilityBattery => 'Uso irrestrito da bateria';

  @override
  String get reliabilityBatteryExempt => 'Isento da otimização de bateria';

  @override
  String get reliabilityBatteryNeeded =>
      'O Android pode suspender o app e perder ligações para economizar energia. Toque para isentar o SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'Início automático / apps protegidos de $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'O fabricante do seu celular pode encerrar apps em segundo plano. Permita que o SoftphonePro inicie automaticamente.';

  @override
  String get reliabilityBoot => 'Iniciar com o dispositivo';

  @override
  String get reliabilityBootHint =>
      'Registrar as contas após o celular reiniciar';

  @override
  String get reliabilityWake => 'Manter a CPU ativa em repouso';

  @override
  String get reliabilityWakeHint =>
      'Mais confiável em dispositivos restritivos; consome mais bateria';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Remover $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Último erro: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Intervalo permitido: $min a $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Deve ser no mínimo $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Deve ser no máximo $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Descartar alterações?';

  @override
  String get acctEditorDiscardMessage =>
      'Suas edições nesta conta não foram salvas.';

  @override
  String get acctEditorDiscardConfirm => 'Descartar';

  @override
  String get acctEditorDeleteMessage =>
      'A conta e a senha salva serão removidas deste dispositivo.';

  @override
  String get acctEditorMenuDelete => 'Excluir conta';

  @override
  String get acctGroupBasic => 'Básico';

  @override
  String get acctFieldLabel => 'Rótulo';

  @override
  String get acctFieldLabelHint => 'ex.: Escritório';

  @override
  String get acctFieldDisplayName => 'Nome de exibição';

  @override
  String get acctFieldUsername => 'Usuário';

  @override
  String get acctFieldProtocol => 'Protocolo';

  @override
  String get acctFieldProtocolSub => 'Definido na criação da conta';

  @override
  String get acctFieldAuthUser => 'Usuário de autorização';

  @override
  String get acctFieldAuthUserHint => 'Igual ao usuário';

  @override
  String get acctFieldAuthUserSub =>
      'Somente se o provedor usar um nome de login diferente do usuário';

  @override
  String get acctFieldPassword => 'Senha';

  @override
  String get acctFieldServerHost => 'Host do servidor';

  @override
  String get acctFieldPort => 'Porta';

  @override
  String get acctFieldIaxPortSub => 'O padrão do IAX2 é 4569';

  @override
  String get acctFieldIaxContext => 'Contexto';

  @override
  String get acctFieldIaxContextSub =>
      'Opcional. Enviado ao PBX como o contexto chamado';

  @override
  String get acctFieldServerDomain => 'Servidor / domínio';

  @override
  String get acctFieldServerDomainSub => 'host ou host:porta';

  @override
  String get acctFieldEnabled => 'Ativada';

  @override
  String get acctFieldDefault => 'Conta padrão para ligações realizadas';

  @override
  String get acctFieldColour => 'Cor';

  @override
  String get acctGroupRegistration => 'Registro';

  @override
  String get acctFieldRegister => 'Registrar';

  @override
  String get acctFieldRegisterSubIax =>
      'Desative para peers que não precisam de registro';

  @override
  String get acctFieldRegExpiry => 'Expiração do registro (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'O Asterisk geralmente força 60 s. Intervalo de 10 a 86400';

  @override
  String get acctFieldRetryInterval => 'Intervalo de nova tentativa (s)';

  @override
  String get acctFieldFirstRetry => 'Primeira nova tentativa (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'O IAX2 é compatível com G.711 e GSM. Arraste para definir a ordem de preferência.';

  @override
  String get acctCodecAdd => 'Adicionar codec';

  @override
  String get acctGroupServerTransport => 'Servidor e transporte';

  @override
  String get acctFieldRegistrar => 'Substituir registrar';

  @override
  String get acctFieldBackupRegistrar => 'Registrar de backup';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Usado após 3 tentativas com falha; o principal é testado novamente a cada 5 minutos';

  @override
  String get acctFieldProxies => 'Proxies de saída';

  @override
  String get acctFieldTransport => 'Transporte';

  @override
  String get acctFieldTransportAutoSub =>
      'Consulta os registros DNS SRV do servidor e escolhe TLS, TCP ou UDP';

  @override
  String get acctTransportAuto => 'Automático (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Caminho do WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'Caminho HTTP do upgrade para WebSocket, ex.: /ws. Deve começar com \"/\"';

  @override
  String get acctFieldRegExpirySubSip =>
      'O típico é de 300 a 3600. Intervalo de 10 a 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'Intervalo de keep-alive do UDP. 0 desativa. Intervalo de 0 a 3600';

  @override
  String get acctFieldLocalPort => 'Porta SIP local';

  @override
  String get acctFieldLocalPortSub =>
      '0 usa o transporte compartilhado. Intervalo de 0 a 65535';

  @override
  String get acctFieldRegisterSubSip => 'Desative para troncos sem registro';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Mantém um fluxo persistente através do NAT. Requer suporte do servidor';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Usar STUN';

  @override
  String get acctFieldTurn => 'Relay TURN';

  @override
  String get acctFieldTurnServer => 'Servidor TURN';

  @override
  String get acctFieldTurnUsername => 'Usuário TURN';

  @override
  String get acctFieldTurnPassword => 'Senha TURN';

  @override
  String get acctFieldContactRewrite => 'Reescrever cabeçalho Contact';

  @override
  String get acctFieldViaRewrite => 'Reescrever cabeçalho Via';

  @override
  String get acctFieldRewriteSub =>
      'Usa o endereço que o servidor enxerga. Mantenha ativado atrás de NAT';

  @override
  String get acctFieldSdpRewrite => 'Reescrever endereço SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'Substitui o endereço de mídia no SDP pelo público';

  @override
  String get acctFieldIpv6Sip => 'Sinalização IPv6';

  @override
  String get acctFieldIpv6Media => 'Mídia IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Mídia avançada';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'Gateways WebRTC exigem multiplexação RTCP e feedback RTCP.';

  @override
  String get acctFieldRtcpMux => 'Multiplexação RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Envia RTP e RTCP em uma única porta (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Feedback RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Oferece RTP/AVPF com NACK. Necessário para servidores WebRTC';

  @override
  String get acctGroupSecurity => 'Segurança';

  @override
  String get acctFieldSrtp => 'Criptografia de mídia (SRTP)';

  @override
  String get acctOptOptional => 'Opcional';

  @override
  String get acctOptRequired => 'Obrigatório';

  @override
  String get acctFieldKeyExchange => 'Troca de chaves';

  @override
  String get acctFieldSecureSignaling => 'Sinalização segura';

  @override
  String get acctOptNotRequired => 'Não obrigatória';

  @override
  String get acctOptTlsHop => 'TLS salto a salto';

  @override
  String get acctOptTlsE2e => 'TLS ponta a ponta (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Algoritmo de autenticação';

  @override
  String get acctFieldPrivacy =>
      'Ocultar identificador de chamadas (privacidade)';

  @override
  String get acctFieldReferPolicy => 'Transferências recebidas (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Observadores de presença';

  @override
  String get acctOptAccept => 'Aceitar';

  @override
  String get acctOptReject => 'Rejeitar';

  @override
  String get acctGroupCodecsFooter =>
      'Substitui a lista global de codecs para esta conta.';

  @override
  String get acctFieldUseGlobalCodecs => 'Usar ordem global de codecs';

  @override
  String get acctGroupFeatures => 'Recursos';

  @override
  String get acctFieldVoicemailNumber => 'Número da caixa postal';

  @override
  String get acctFieldMwi => 'Indicador de caixa postal (MWI)';

  @override
  String get acctFieldMwiSub => 'Assinar notificações de mensagem em espera';

  @override
  String get acctFieldPublishPresence => 'Publicar minha presença';

  @override
  String get acctFieldPublishPresenceSub =>
      'Permitir que o servidor compartilhe seu status online';

  @override
  String get acctFieldDnd => 'Não perturbe';

  @override
  String get acctFieldForwarding => 'Desvio de ligações';

  @override
  String get acctOptForwardAlways => 'Sempre';

  @override
  String get acctOptForwardBusy => 'Quando ocupado';

  @override
  String get acctOptForwardNoAnswer => 'Sem resposta';

  @override
  String get acctFieldForwardTo => 'Desviar para';

  @override
  String get acctFieldForwardToHint => 'Número ou endereço SIP';

  @override
  String get acctFieldRingFor => 'Tocar por (s)';

  @override
  String get acctFieldAutoAnswer => 'Atendimento automático';

  @override
  String get acctFieldAnswerAfter => 'Atender após (s)';

  @override
  String get acctFieldIntercomOnly => 'Somente para ligações de interfone';

  @override
  String get acctFieldIntercomOnlySub =>
      'Requer um cabeçalho de atendimento automático do PBX';

  @override
  String get acctFieldRingtone => 'Toque';

  @override
  String get acctRingtoneClassic => 'Clássico';

  @override
  String get acctRingtoneSoft => 'Suave';

  @override
  String get acctRingtoneDigital => 'Digital';

  @override
  String get acctFieldRecordCalls => 'Gravar ligações';

  @override
  String get acctFieldHoldMusic => 'Música de espera';

  @override
  String get acctOptUseGlobal => 'Usar configuração global';

  @override
  String get acctOptPbxDefault => 'Padrão do PBX';

  @override
  String get acctFieldOpeningAnnouncement => 'Aviso de abertura';

  @override
  String get acctGroupFeatureCodes => 'Códigos de recurso';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Discados para estacionar, capturar, Não perturbe e desvio no seu PBX.';

  @override
  String get acctFieldPark => 'Estacionar';

  @override
  String get acctFieldGroupPickup => 'Captura em grupo';

  @override
  String get acctFieldDirectedPickup => 'Prefixo de captura direcionada';

  @override
  String get acctFieldParkRetrieve => 'Prefixo de recuperação de estacionada';

  @override
  String get acctFieldParkRetrieveHint => 'Disque o número da vaga';

  @override
  String get acctFieldParkRetrieveSub =>
      'Prefixo discado antes da vaga de estacionamento para recuperar uma ligação estacionada';

  @override
  String get acctFieldDndOn => 'Ativar Não perturbe';

  @override
  String get acctFieldDndOff => 'Desativar Não perturbe';

  @override
  String get acctFieldForwardOn => 'Ativar desvio';

  @override
  String get acctFieldForwardOff => 'Desativar desvio';

  @override
  String get acctGroupAdvanced => 'Avançado';

  @override
  String get acctGroupAdvancedFooterIax =>
      'O DTMF é enviado como quadros IAX2 nativos.';

  @override
  String get acctFieldCallerIdOverride =>
      'Substituir identificador de chamadas';

  @override
  String get acctFieldCallerIdHint => 'Usar o padrão da conta';

  @override
  String get acctFieldCallerIdSub =>
      'Nome ou número do identificador de chamadas enviado ao PBX';

  @override
  String get acctFieldSessionTimers => 'Temporizadores de sessão';

  @override
  String get acctFieldSessionExpires => 'Expiração da sessão (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Intervalo de 90 a 86400';

  @override
  String get acctField100rel => '100rel (provisória confiável)';

  @override
  String get acctFieldHoldMethod => 'Método de espera';

  @override
  String get acctFieldDtmfMethod => 'Método DTMF';

  @override
  String get acctOptDtmfInband => 'In-band';

  @override
  String get acctFieldRedirects => 'Redirecionamentos (3xx)';

  @override
  String get acctOptRedirectFollow => 'Seguir';

  @override
  String get acctOptRedirectAsk => 'Perguntar';

  @override
  String get acctFieldLockCodec => 'Travar codec após o atendimento';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive de mídia';

  @override
  String get acctFieldDropCalls => 'Encerrar ligações quando o registro falhar';

  @override
  String get acctFieldExtraHeaders => 'Cabeçalhos SIP extras';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: valor (um por linha)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Tempo de espera antes de tentar novamente um registro com falha. Intervalo de 0 a 86400';

  @override
  String get acctFieldUnregTimeout =>
      'Tempo limite de cancelamento de registro (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Quanto tempo esperar pela resposta do cancelamento de registro. Intervalo de 0 a 60000';

  @override
  String get acctFieldMwiExpiry => 'Expiração da assinatura MWI (s)';

  @override
  String get acctFieldDscpSip => 'DSCP para SIP';

  @override
  String get acctFieldDscpSipSub =>
      'Marcação de QoS da sinalização. O típico é 24 (CS3)';

  @override
  String get acctFieldDscpRtp => 'DSCP para RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'Marcação de QoS da mídia. O típico é 46 (EF)';

  @override
  String get acctFieldReinvite => 'Re-INVITE após mudança de rede';

  @override
  String get acctFieldHangupOnIpChange => 'Desligar ligações ao mudar de rede';

  @override
  String get acctValidateInt => 'Digite um número inteiro';

  @override
  String get acctValidateHostEmpty =>
      'Digite o nome do host ou o endereço do servidor';

  @override
  String get acctValidateHostSpaces => 'O servidor não pode conter espaços';

  @override
  String get acctValidateHostFormat => 'Digite apenas host ou host:porta';

  @override
  String get acctValidatePortRange => 'A porta deve estar entre 1 e 65535';

  @override
  String get acctValidateWsStart => 'O caminho deve começar com \"/\"';

  @override
  String get acctValidateWsLength => 'Use no máximo 120 caracteres';

  @override
  String get acctValidateWsSpaces => 'O caminho não pode conter espaços';

  @override
  String get acctTplAsteriskDescription =>
      'Ramal no seu próprio PBX. UDP 5060, STUN ativado.';

  @override
  String get acctTplAsteriskNotes =>
      'Use o número do ramal PJSIP/SIP e o respectivo secret. Para TLS ou WebRTC, altere o transporte depois nas configurações da conta.';

  @override
  String get acctTplAsteriskUsernameHint => 'Ramal (ex.: 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Use o ramal, o ID de autenticação e a senha do portal do 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'No 3CX, abra o ramal e depois \"Phones > Provisioning\" para ver o ID de autenticação (defina-o como Usuário de autorização) e a senha. O FQDN é o da sua URL do 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Ramal';

  @override
  String get acctTplFreeswitchDescription =>
      'Usuário do diretório em um servidor FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Use o ID de usuário e a senha do diretório. O perfil internal padrão escuta em UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID de usuário';

  @override
  String get acctTplKamailioDescription =>
      'Registrar proxy SIP. TCP recomendado atrás de NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Use o domínio SIP atendido pelo seu registrar. Adicione um proxy de saída nas configurações da conta se o registrar for acessado por outro host.';

  @override
  String get acctTplTwilioDescription =>
      'Credenciais do domínio SIP do Programmable Voice. TLS e SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Crie um domínio SIP no console da Twilio, adicione uma Credential List e ative o SIP Registration. Informe o domínio completo (nome.sip.twilio.com) como servidor e o usuário e a senha da credential list. O TLS usa a porta 5061. A Twilio aceita apenas G.711.';

  @override
  String get acctTplTwilioUsernameHint => 'Usuário da credential list';

  @override
  String get acctTplTelnyxDescription =>
      'Credential connection. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Crie uma Credential Connection no portal da Telnyx e copie o usuário e a senha SIP dela (não o login do portal). Atribua um número ou um outbound voice profile à conexão para fazer e receber ligações.';

  @override
  String get acctTplTelnyxUsernameHint => 'Usuário SIP (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Usuário e senha da subconta. Escolha o POP mais próximo de você.';

  @override
  String get acctTplVoipmsNotes =>
      'Use uma subconta criada em Sub Accounts, não a sua conta principal. Escolha o servidor (POP) mais próximo de você na lista de servidores do VoIP.ms e libere-o para o seu IP, se necessário.';

  @override
  String get acctTplVoipmsUsernameHint => 'Subconta (ex.: 123456_phone)';

  @override
  String get acctTplVonageDescription => 'Registro SIP com TLS.';

  @override
  String get acctTplVonageNotes =>
      'O Vonage Business oferece registro SIP apenas em alguns planos. Informe o servidor SIP, o usuário e a senha exibidos no portal de administração do Vonage para o dispositivo.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange sobre UDP 4569. Sem configurações de NAT ou SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Requer um peer/usuário em iax.conf (type=friend ou user+peer) com o mesmo secret. O Asterisk renova os registros IAX2 a cada 60 s por padrão. O contexto é opcional e é enviado como o contexto chamado.';

  @override
  String get acctTplIax2UsernameHint => 'Usuário IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP sobre WebSocket seguro com DTLS-SRTP, ICE e RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Para endpoints WebSocket do Asterisk (webrtc=yes, TLS no http.conf na 8089), FreeSWITCH ou Kamailio. O servidor precisa de um certificado TLS válido. Altere o caminho do WebSocket nas configurações da conta se o seu gateway não usar /ws.';

  @override
  String get acctTplGenericDescription =>
      'Qualquer registrar SIP. Preencha os dados você mesmo.';

  @override
  String get acctTplDefaultUsernameHint => 'Ramal / usuário';

  @override
  String get appEngineFailedBody =>
      'As ligações e o registro não funcionarão até que isso seja corrigido. A causa mais comum é uma configuração de rede ou de certificado incorreta.';

  @override
  String get appEngineFailedTitle =>
      'Não foi possível iniciar o mecanismo de ligações';

  @override
  String get appEngineNotRunning =>
      'O mecanismo de ligações não está em execução';

  @override
  String get appUnknownError => 'Erro desconhecido';

  @override
  String get appEngineOpenNetworkSettings => 'Abrir ajustes de rede';

  @override
  String get appEngineUseSimulator => 'Usar simulador (demo)';

  @override
  String get appDbLockedTitle => 'Seus dados estão bloqueados';

  @override
  String get appDbUnreadableTitle => 'Não é possível abrir seus dados';

  @override
  String get appDbLockedBody =>
      'O histórico de ligações, os contatos e as mensagens estão criptografados neste dispositivo, mas a chave de criptografia não está mais no chaveiro / keystore do sistema (por exemplo, após uma redefinição do chaveiro ou uma restauração em um novo dispositivo).';

  @override
  String get appDbUnreadableBody =>
      'Não foi possível ler o banco de dados local. Ele pode estar danificado ou a chave de criptografia não corresponde.';

  @override
  String get appDbRecoveryAdvice =>
      'Tente novamente se você espera que a chave volte (desbloqueie o chaveiro, entre com o usuário correto). Começar do zero mantém o arquivo antigo junto aos dados do app, mas inicia com histórico, contatos e mensagens vazios; você precisará adicionar suas contas novamente.';

  @override
  String get appDbCopyDetails => 'Copiar detalhes';

  @override
  String get appDbTryAgain => 'Tentar novamente';

  @override
  String get appDbStartFresh => 'Começar do zero';

  @override
  String get appRedirectTitle => 'Ligação redirecionada';

  @override
  String appRedirectMessage(String target) {
    return 'Ligação redirecionada para $target - seguir?';
  }

  @override
  String get appRedirectCancelCall => 'Cancelar ligação';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Não foi possível criptografar seus dados ($error). Nada foi alterado.',
      'other':
          'Não foi possível descriptografar seus dados ($error). Nada foi alterado.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Mecanismo nativo indisponível ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Nova tentativa às $time';
  }

  @override
  String get acctRegistrationError => 'Erro de registro';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nTransporte: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Ligando direto, sem conta';

  @override
  String acctCallingFromAccount(String name) {
    return 'Ligando de $name';
  }

  @override
  String get acctCallingFromNone => 'Ligando sem conta';

  @override
  String get acctNoAccount => 'Sem conta';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nova(s), $oldCount antiga(s)';
  }

  @override
  String get acctAddAccount => 'Adicionar conta';

  @override
  String get acctUnregister => 'Cancelar registro';

  @override
  String get acctSheetDndSub => 'Rejeitar ligações recebidas nesta conta';

  @override
  String get acctKvServer => 'Servidor';

  @override
  String get acctKvResolvedServer => 'Servidor resolvido';

  @override
  String get acctKvClientCert => 'Cert. de cliente';

  @override
  String get acctKvClientCertValue => 'Apresentado ao servidor (TLS mútuo)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Expira em';

  @override
  String get acctKvVoicemail => 'Caixa postal';

  @override
  String get acctOpenSipTrace => 'Abrir rastreamento SIP';

  @override
  String get acctAddAnAccount => 'Adicionar uma conta';

  @override
  String get acctChooseAccountTooltip => 'Escolha a conta para ligar';

  @override
  String get acctDirectNoAccount => 'Direto (sem conta)';

  @override
  String get onboardingRequired => 'Usuário e servidor são obrigatórios';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'A porta $port é usada, a menos que você adicione :porta';
  }

  @override
  String get onboardingFineTuneIax =>
      'Você pode ajustar codecs e registro depois, em Ajustes.';

  @override
  String get onboardingFineTuneSip =>
      'Você pode ajustar transporte, NAT, segurança e codecs depois, em Ajustes.';

  @override
  String get onboardingDemoUser => 'Usuário demo';

  @override
  String get onboardingDemoAccount => 'Conta demo';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Ligações profissionais para todas as plataformas - gratuito e de código aberto. Sem anúncios, sem rastreamento.';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingPermissionsTitle => 'Permissões';

  @override
  String get onboardingPermissionsText =>
      'O SoftphonePro precisa do microfone para transmitir sua voz e das notificações para avisar sobre ligações e mensagens recebidas. Nada sai do seu dispositivo além das suas ligações.';

  @override
  String get onboardingChooseProvider => 'Escolha seu provedor';

  @override
  String get onboardingChooseProviderSub =>
      'Preenchemos o transporte, as portas e as configurações de NAT para você.';

  @override
  String get onboardingScanQr => 'Ler QR';

  @override
  String get onboardingImportUrl => 'Importar de URL';

  @override
  String get onboardingSkip => 'Pular por enquanto (modo demo)';

  @override
  String get onboardingHidePassword => 'Ocultar senha';

  @override
  String get onboardingShowPassword => 'Mostrar senha';

  @override
  String get onboardingContextOptional => 'Contexto (opcional)';

  @override
  String get onboardingDisplayNameOptional => 'Nome de exibição (opcional)';

  @override
  String get onboardingLabelOptional => 'Rótulo da conta (opcional)';

  @override
  String get onboardingCallerIdOptional =>
      'Identificador de chamadas (opcional)';

  @override
  String get onboardingAuthUserOptional =>
      'Usuário de autorização (se diferente)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Usuário ou senha incorretos ($code)';
  }

  @override
  String get acctRegNotFound => 'Conta não encontrada no servidor (404)';

  @override
  String get acctRegNoAnswer => 'O servidor não respondeu (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Intervalo de registro muito curto (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Servidor temporariamente indisponível (480)';

  @override
  String get acctRegServiceUnavailable => 'Serviço indisponível (503)';

  @override
  String get acctRegFailed => 'Falha no registro';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Falha no registro ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Não foi possível alterar o registro';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Não foi possível aplicar a conta \"$name\"';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'De volta ao servidor principal de $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Usando o servidor de backup de $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'A conta $name está registrada';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'A conta $name ainda está sendo registrada';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'A conta $name ainda não está registrada';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'A conta $name não está registrada (falha no registro)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'A conta $name está desativada';
  }

  @override
  String get callDialEngineFailed =>
      'O mecanismo de ligações não conseguiu iniciar';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'O mecanismo de ligações não conseguiu iniciar: $reason';
  }

  @override
  String get callDialEngineStarting =>
      'O mecanismo de ligações ainda está iniciando';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status após $seconds s; a ligação não foi feita';
  }

  @override
  String get callJournalInterrupted => 'O app foi fechado durante a ligação';

  @override
  String get callLinkMissingArgument => 'Argumento ausente';

  @override
  String get callLinkHttpsRequired =>
      'Os links de configuração devem usar https';

  @override
  String get callLinkInvalidLan => 'Esse link LAN não é válido';

  @override
  String callLinkConnectedTo(String name) {
    return 'Conectado a $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Não foi possível conectar a esse dispositivo';

  @override
  String callLinkCallFailed(String target) {
    return 'Não foi possível ligar para $target';
  }

  @override
  String get callLinkImportTitle => 'Importar configuração';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts contas',
      one: '1 conta',
    );
    return 'Importar a configuração de $host? Isso adicionará $_temp0.';
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
      other: '$accounts contas',
      one: '1 conta',
    );
    return 'Importar a configuração de $host? Isso adicionará $_temp0 e $settings ajuste(s).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Desviada de $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Desviada de $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Transferida por $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Padrão do sistema';

  @override
  String get callRingtoneClassic => 'Clássico';

  @override
  String get callRingtoneSoft => 'Suave';

  @override
  String get callRingtoneDigital => 'Digital';

  @override
  String callIdentityFrom(String number) {
    return 'De $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Identificador $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Identificador $name $number';
  }

  @override
  String get callTransferring => 'Transferindo...';

  @override
  String get callTransferNotConfirmed =>
      'Transferência não confirmada pelo servidor';

  @override
  String get callTransferStalledHint =>
      'A ligação continua ativa. Mantenha-a ou envie a transferência novamente.';

  @override
  String get callTransferKeepCall => 'Manter ligação';

  @override
  String get callAnnouncementOpening => 'Reproduzindo aviso…';

  @override
  String get callAnnouncementTransfer => 'Reproduzindo aviso de transferência…';

  @override
  String get callAnnouncementRecording => 'Reproduzindo aviso de gravação…';

  @override
  String get callAnnouncementSkip => 'Pular';

  @override
  String get callNoiseTooltipMic =>
      'Cancelamento de ruído por IA: seu microfone';

  @override
  String get callNoiseTooltipIncoming =>
      'Cancelamento de ruído por IA: outros participantes';

  @override
  String get callNoiseTooltipBoth =>
      'Cancelamento de ruído por IA: seu microfone e outros participantes';

  @override
  String get callNoiseOn => 'Cancelamento de ruído ativado';

  @override
  String get callNoiseTitle => 'Cancelamento de ruído';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Meu microfone: $strength';
  }

  @override
  String get callNoiseMicOffHint => 'Remover o ruído de fundo do meu microfone';

  @override
  String get callResultAnswered => 'Atendida';

  @override
  String get callResultMissed => 'Perdida';

  @override
  String get callResultRejected => 'Recusada';

  @override
  String get callResultFailed => 'Falhou';

  @override
  String get callResultBusy => 'Ocupado';

  @override
  String get callResultForwarded => 'Desviada';

  @override
  String get callResultTransferred => 'Transferida';

  @override
  String get callResultHandedOff => 'Repassada';

  @override
  String get callResultInterrupted => 'Interrompida';

  @override
  String get keypadCall => 'Ligar';

  @override
  String get keypadNoVoicemail =>
      'Nenhum número de caixa postal configurado para esta conta';

  @override
  String get keypadCallDirectly => 'Ligar direto (sem conta)';

  @override
  String get keypadAddAccount => 'Adicione uma conta para fazer ligações';

  @override
  String keypadCallFrom(String account) {
    return 'Ligar de $account';
  }

  @override
  String get keypadRecent => 'Recentes';

  @override
  String get keypadSuggestions => 'Sugestões';

  @override
  String get keypadPhoneNumber => 'Número de telefone';

  @override
  String get keypadPaste => 'Colar';

  @override
  String get keypadEnterNumber => 'Digite o número';

  @override
  String get keypadBackspace => 'Apagar (mantenha pressionado para limpar)';

  @override
  String get keypadTypeNameOrNumber => 'Digite um nome ou número';

  @override
  String get keypadNoMatches => 'Nenhum resultado';

  @override
  String get keypadSuggestionsHint =>
      'As sugestões vêm dos contatos e das ligações recentes';

  @override
  String keypadCallPerson(String name) {
    return 'Ligar para $name';
  }

  @override
  String get dialKeyStar => 'Asterisco';

  @override
  String get dialKeyPound => 'Cerquilha';

  @override
  String get dialKeyLongPressPlus => 'Mantenha pressionado para inserir mais';

  @override
  String get dialKeyLongPressSpeedDial =>
      'Mantenha pressionado para discagem rápida';

  @override
  String get dialKeyLongPressVoicemail =>
      'Mantenha pressionado para a caixa postal';

  @override
  String get callBackToApp => 'Voltar ao app (a ligação continua ativa)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Ocultar teclado';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callKeypad => 'Teclado';

  @override
  String get callSpeaker => 'Alto-falante';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Fone';

  @override
  String get callResume => 'Retomar';

  @override
  String get callHold => 'Espera';

  @override
  String get callAddCall => 'Nova ligação';

  @override
  String get callTransfer => 'Transferir';

  @override
  String get callStop => 'Parar';

  @override
  String get callRecord => 'Gravar';

  @override
  String get callSplit => 'Dividir';

  @override
  String get callMerge => 'Unir';

  @override
  String get callSwap => 'Alternar';

  @override
  String get callEndCall => 'Encerrar';

  @override
  String callEndCallWith(String name) {
    return 'Encerrar ligação com $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Transferência assistida. Quem ligou originalmente está em espera.';

  @override
  String get callCompleteTransfer => 'Concluir transferência';

  @override
  String get callWaiting => 'Chamada em espera';

  @override
  String get callHoldAndAnswer => 'Colocar a ligação atual em espera e atender';

  @override
  String get callDecline => 'Recusar';

  @override
  String get callAnswer => 'Atender';

  @override
  String get callIncomingCall => 'Ligação recebida';

  @override
  String get callReply => 'Responder';

  @override
  String get callVoicemail => 'Caixa postal';

  @override
  String get callToDevice => 'Ao dispositivo';

  @override
  String get callQuickReplyBusy => 'Não posso falar agora, ligo de volta.';

  @override
  String get callQuickReplyMeeting => 'Estou em reunião. Pode mandar mensagem?';

  @override
  String get callQuickReplyOnMyWay => 'Já estou a caminho.';

  @override
  String callReturnToCallWith(String name) {
    return 'Voltar à ligação com $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Recebendo: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'Em ligação com $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Perda de pacotes';

  @override
  String get callStatsRoundTrip => 'Ida e volta';

  @override
  String get callStatsMedia => 'Mídia';

  @override
  String get callStatsMosHistory => 'Histórico de MOS';

  @override
  String get callQualityTitle => 'Qualidade da ligação';

  @override
  String get callTransferTitle => 'Transferir ligação';

  @override
  String get callTransferModeBlind => 'Direta';

  @override
  String get callTransferModeAttended => 'Assistida';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Dispositivo LAN';

  @override
  String get callTransferNoLanDevices =>
      'Nenhum dispositivo SoftphonePro pareado encontrado na sua rede. Pareie um na página LAN.';

  @override
  String get callTransferLanDisabled =>
      'Ative o LAN Link (Ajustes, LAN Link) para passar esta ligação a outro dispositivo da sua rede.';

  @override
  String get callTransferTalkFirst => 'Falar antes';

  @override
  String get callTransferBlindHint =>
      'Passa quem ligou imediatamente. Você é desconectado.';

  @override
  String get callTransferAttendedHint =>
      'Coloca quem ligou em espera e liga primeiro para o destino. Conclua a transferência quando atenderem.';

  @override
  String get callTransferNumberLabel => 'Número ou endereço SIP';

  @override
  String get callTransferNow => 'Transferir agora';

  @override
  String get callTransferCallAndConsult => 'Ligar e consultar';

  @override
  String get callRetrieveParkedTitle => 'Recuperar ligação estacionada';

  @override
  String get callRetrieveParkedHint => 'Vaga de estacionamento, ex.: 701';

  @override
  String get callMoreAudioOutput => 'Saída de áudio';

  @override
  String get callMoreAudioDevices => 'Dispositivos de áudio';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefone, alto-falante, Bluetooth, fone';

  @override
  String get callMoreAudioDevicesSubtitle =>
      'Escolha o microfone e o alto-falante';

  @override
  String get callMoreParkCall => 'Estacionar ligação';

  @override
  String get callMoreParkCallSubtitle =>
      'Transferir para o código de recurso de estacionamento';

  @override
  String get callMoreRetrieveParkedSubtitle =>
      'Disque uma vaga de estacionamento';

  @override
  String get callMoreSendDtmf => 'Enviar dígitos DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Digite uma sequência inteira, ex.: um PIN';

  @override
  String get callSendDtmfTitle => 'Enviar DTMF';

  @override
  String get callMoreCallInfo => 'Informações da ligação';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, jitter, perda e tempo de ida e volta ao vivo';

  @override
  String get callMoreSipTrace => 'Rastreamento SIP';

  @override
  String get callMoreSipTraceSubtitle => 'Diagrama de sequência desta ligação';

  @override
  String get callInfoRemote => 'Remoto';

  @override
  String get callInfoAccount => 'Conta';

  @override
  String get callInfoState => 'Estado';

  @override
  String get callInfoSecure => 'Seguro';

  @override
  String get callInfoPlainSignalling => 'sinalização sem criptografia';

  @override
  String get callRoutePhone => 'Telefone';

  @override
  String get callRouteWiredHeadset => 'Fone com fio';

  @override
  String get callAudioMicrophone => 'Microfone';

  @override
  String callCardSemantics(String name, String state) {
    return 'Ligação com $name, $state';
  }

  @override
  String get callUnmute => 'Reativar som';

  @override
  String get callStopRecording => 'Parar gravação';

  @override
  String get callSplitConference => 'Dividir conferência';

  @override
  String get callMergeCalls => 'Unir ligações';

  @override
  String get callSwapCalls => 'Alternar ligações';

  @override
  String get callAttendedTransferBanner =>
      'Transferência assistida: quem ligou originalmente está em espera.';

  @override
  String get callActiveCalls => 'Ligações ativas';

  @override
  String get callConferenceLevels => 'Níveis da conferência';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Mic. para o participante';

  @override
  String callPercentSemantics(int percent) {
    return '$percent por cento';
  }

  @override
  String get callFailInvalidNumber => 'Número inválido (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Ligação não autorizada ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Número não encontrado (404)';

  @override
  String get callFailNoAnswerFromServer => 'Sem resposta do servidor (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Temporariamente indisponível (480)';

  @override
  String get callFailIncompleteNumber => 'Número incompleto (484)';

  @override
  String callFailBusy(String code) {
    return 'Ocupado ($code)';
  }

  @override
  String get callFailCancelled => 'Ligação cancelada (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Nenhum codec compatível ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Serviço indisponível (503)';

  @override
  String get callFailDeclined => 'Ligação recusada (603)';

  @override
  String get callFailGeneric => 'Falha na ligação';

  @override
  String callFailGenericWithCode(String code) {
    return 'Falha na ligação ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Ligação em andamento';

  @override
  String get callTrayInCall => 'Em ligação';

  @override
  String get callHistoryBlocked => 'Bloqueada';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimato não permitido';

  @override
  String get callHistoryDoNotDisturb => 'Não perturbe';

  @override
  String get callHistoryBusy => 'Ocupado';

  @override
  String get callHistoryForwardedAlways => 'Desviada (sempre)';

  @override
  String get callHistoryForwardedBusy => 'Desviada (ocupado)';

  @override
  String get callHistorySentToVoicemail => 'Enviada à caixa postal';

  @override
  String get callHistoryRedirected => 'Redirecionada';

  @override
  String get callIncomingNotificationBody => 'Ligação recebida';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Ligação recebida em $account';
  }

  @override
  String get callMissedNotificationTitle => 'Ligação perdida';

  @override
  String get callErrEngineNotRunning =>
      'O mecanismo de ligações ainda não está em execução';

  @override
  String get callErrAddAccount => 'Adicione uma conta para fazer ligações';

  @override
  String get callErrCouldNotPlace => 'Não foi possível fazer a ligação';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account não está registrada';
  }

  @override
  String get callErrCouldNotAnswer => 'Não foi possível atender';

  @override
  String get callErrNoVoicemailNumber =>
      'Nenhum número de caixa postal definido para esta conta';

  @override
  String get callErrTransferFailed => 'Falha na transferência';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Falha na transferência: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Não foi possível unir as ligações';

  @override
  String get callErrCouldNotStartRecording =>
      'Não foi possível iniciar a gravação';

  @override
  String get callErrCouldNotStopRecording =>
      'Não foi possível parar a gravação';

  @override
  String callParkingNotice(String code) {
    return 'Estacionando ligação (discar $code)';
  }

  @override
  String get callErrParkFailed => 'Falha ao estacionar';

  @override
  String get callErrHandoffFailed => 'Falha ao repassar';

  @override
  String get callErrCouldNotSendToDevice =>
      'Não foi possível enviar ao dispositivo';

  @override
  String get callHistoryForwardedNoAnswer => 'Desviada (sem resposta)';

  @override
  String get shellTabKeypad => 'Teclado';

  @override
  String get shellTabRecents => 'Recentes';

  @override
  String get shellTabContacts => 'Contatos';

  @override
  String get shellTabMessages => 'Mensagens';

  @override
  String get shellTabPresence => 'Presença';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Gravações';

  @override
  String get shellSearchSemantics =>
      'Buscar contatos, histórico ou discar um número';

  @override
  String get shellSearchHint => 'Buscar ou discar';

  @override
  String get shellVoicemailTooltip => 'Caixa postal';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count novas mensagens na caixa postal. Clique para ligar para a caixa postal',
      one:
          '1 nova mensagem na caixa postal. Clique para ligar para a caixa postal',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Ausente';

  @override
  String get shellStatusTooltip => 'Seu status';

  @override
  String get shellDemoBanner =>
      'Modo demo: as ligações são simuladas, nada chega a uma rede real.';

  @override
  String get uiToday => 'Hoje';

  @override
  String get uiYesterday => 'Ontem';

  @override
  String get uiUnknownCaller => 'Chamador desconhecido';

  @override
  String get uiCallEnded => 'Ligação encerrada';

  @override
  String get uiCallTransferNotConfirmed => 'Transferência não confirmada';

  @override
  String get uiCallTransferring => 'Transferindo...';

  @override
  String get uiCallConference => 'Conferência';

  @override
  String get uiCallOnHold => 'Em espera';

  @override
  String get uiCallHeldByRemote => 'Em espera pelo outro lado';

  @override
  String get uiCallCalling => 'Chamando...';

  @override
  String get uiCallRinging => 'Tocando...';

  @override
  String get uiCallConnecting => 'Conectando...';

  @override
  String get uiCallIncoming => 'Ligação recebida';

  @override
  String get uiCallConnected => 'Conectada';

  @override
  String get uiQrScanTitle => 'Ler código QR';

  @override
  String get uiQrPasteHint => 'Cole o texto do código';

  @override
  String get uiQrNoCamera =>
      'A leitura por câmera não está disponível neste dispositivo. Cole o texto do código.';

  @override
  String get uiQrPaste => 'Colar';

  @override
  String get uiQrUse => 'Usar';

  @override
  String get uiQrCameraDenied =>
      'O acesso à câmera está desativado. Permita-o nos ajustes do sistema ou cole o texto do código abaixo.';

  @override
  String get uiQrCameraUnavailable =>
      'A câmera não está disponível. Cole o texto do código abaixo.';

  @override
  String get presenceLampRinging => 'Tocando';

  @override
  String get presenceHeader => 'Campo de lâmpada ocupada';

  @override
  String get presenceChooseTooltip => 'Escolher contatos para monitorar';

  @override
  String get presenceEmptyTitle => 'Nenhum ramal no painel';

  @override
  String get presenceEmptySubtitle =>
      'Ative \"Mostrar no painel BLF\" em um contato para ver quando ele está livre, tocando ou ocupado.';

  @override
  String get presenceOpenContacts => 'Abrir contatos';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Toque para ligar, mantenha pressionado para mais opções';
  }

  @override
  String presenceCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get presencePickup => 'Capturar este ramal';

  @override
  String get presencePickupSub =>
      'Atender a ligação que está tocando nele (captura direcionada)';

  @override
  String get presenceTransferHere => 'Transferir a ligação atual para cá';

  @override
  String get presenceRemove => 'Remover do painel';

  @override
  String get uiCall => 'Ligar';

  @override
  String get uiMessage => 'Mensagem';

  @override
  String get recentsSearchTooltip => 'Buscar no histórico';

  @override
  String get recentsClearTitle => 'Limpar o histórico de ligações?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todos os $count registros serão excluídos.',
      one: '1 registro será excluído.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'Histórico copiado para a área de transferência como CSV';

  @override
  String get recentsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get recentsMenuClear => 'Limpar histórico';

  @override
  String get recentsSearchHint => 'Buscar nome ou número';

  @override
  String get recentsFilterAll => 'Todas';

  @override
  String get recentsFilterMissed => 'Perdidas';

  @override
  String get recentsFilterIncoming => 'Recebidas';

  @override
  String get recentsFilterOutgoing => 'Realizadas';

  @override
  String get recentsFilterAccount => 'Filtrar por conta';

  @override
  String get recentsAllAccounts => 'Todas as contas';

  @override
  String get recentsAccountFallback => 'Conta';

  @override
  String get recentsEmptyNone => 'Nenhuma ligação ainda';

  @override
  String get recentsEmptyNoMatch => 'Nenhuma ligação correspondente';

  @override
  String get recentsEmptyNoneSub => 'Suas ligações aparecerão aqui.';

  @override
  String get recentsEmptyNoMatchSub => 'Tente outro filtro.';

  @override
  String get recentsOpenKeypad => 'Abrir teclado';

  @override
  String get recentsShowAll => 'Mostrar todas';

  @override
  String get recentsSelectCall => 'Selecione uma ligação';

  @override
  String get recentsSelectCallSub =>
      'Detalhes, qualidade e gravações aparecem aqui.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Ligação perdida',
      'incoming': 'Ligação recebida',
      'other': 'Ligação realizada',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Ligar para $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Adicione uma conta para enviar mensagens';

  @override
  String get recentsAddContact => 'Adicionar contato';

  @override
  String get recentsContact => 'Contato';

  @override
  String get recentsBlock => 'Bloquear';

  @override
  String get recentsUnblock => 'Desbloquear';

  @override
  String recentsBlockTitle(String number) {
    return 'Bloquear $number?';
  }

  @override
  String get recentsBlockMessage =>
      'As ligações deste número serão rejeitadas automaticamente.';

  @override
  String get recentsQualityHeader => 'Qualidade da ligação';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Pior MOS $mos   ·   Jitter $jitter ms   ·   Perda $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Gravações';

  @override
  String get recentsOpenInRecordings => 'Abrir em Gravações';

  @override
  String recentsRelatedCall(String title) {
    return 'Ligação relacionada: $title';
  }

  @override
  String get recentsHistoryHeader => 'Histórico';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Nenhuma ligação com este número';

  @override
  String get recentsDeleteTitle => 'Excluir estas ligações?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count registros de $name.',
      one: 'Remove 1 registro de $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Excluir do histórico';

  @override
  String get recentsCallDetails => 'Detalhes da ligação';

  @override
  String get contactsFavoritesHeader => '★ Favoritos';

  @override
  String get contactsFavoritesOnly => 'Somente favoritos';

  @override
  String get contactsShowAll => 'Mostrar todos';

  @override
  String get contactsImportExportTooltip => 'Importar e exportar';

  @override
  String get contactsMenuDevice => 'Importar do dispositivo';

  @override
  String get contactsMenuFile => 'Importar arquivo vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Importar da área de transferência';

  @override
  String get contactsMenuCopyVcard => 'Copiar como vCard';

  @override
  String get contactsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get contactsNewTooltip => 'Novo contato';

  @override
  String get contactsSearchHint => 'Buscar contatos';

  @override
  String get contactsEmptyTitle => 'Nenhum contato ainda';

  @override
  String get contactsEmptySubtitle =>
      'Adicione as pessoas para quem você mais liga ou importe um arquivo vCard ou CSV.';

  @override
  String get contactsEmptyAction => 'Adicionar um contato';

  @override
  String get contactsNoMatches => 'Nenhum resultado';

  @override
  String contactsCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get contactsSelect => 'Selecione um contato';

  @override
  String get contactsCopiedVcard => 'Contatos copiados como vCard';

  @override
  String get contactsCopiedCsv => 'Contatos copiados como CSV';

  @override
  String get contactsDeviceDenied =>
      'O acesso aos contatos foi negado. Permita-o nos ajustes do sistema para importar.';

  @override
  String get contactsDeviceNone =>
      'Nenhum contato encontrado neste dispositivo';

  @override
  String contactsNothingNew(int count) {
    return 'Nada novo para importar ($count já existente(s))';
  }

  @override
  String get contactsImportDeviceTitle => 'Importar do dispositivo?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos novos',
      one: '1 contato novo',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count atualizado(s) com números extras';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count ignorado(s) (duplicados ou sem número de telefone)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos importados',
      one: '1 contato importado',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Nenhum contato encontrado nesses dados';

  @override
  String get contactsLabelMobile => 'celular';

  @override
  String get contactsLabelWork => 'trabalho';

  @override
  String get contactsLabelHome => 'casa';

  @override
  String get contactsLabelOther => 'outro';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contato não encontrado';

  @override
  String get contactsActionFavorite => 'Favorito';

  @override
  String get contactsNumbersHeader => 'Números';

  @override
  String get contactsSipAddress => 'Endereço SIP';

  @override
  String get contactsDetailsHeader => 'Detalhes';

  @override
  String get contactsOnBlf => 'Exibido no painel BLF';

  @override
  String get contactsAlwaysRecorded => 'As ligações são sempre gravadas';

  @override
  String contactsDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get contactsDeleteMessage =>
      'Este contato será removido deste dispositivo.';

  @override
  String get contactsDeleteButton => 'Excluir contato';

  @override
  String get contactsDetailTitle => 'Contato';

  @override
  String get contactsErrorNameOrNumber => 'Digite um nome ou um número';

  @override
  String get contactsEditTitle => 'Editar contato';

  @override
  String get contactsFieldName => 'Nome';

  @override
  String get contactsFieldCompany => 'Empresa';

  @override
  String get contactsFieldNumber => 'Número';

  @override
  String get contactsRemoveNumber => 'Remover número';

  @override
  String get contactsAddNumber => 'Adicionar número';

  @override
  String get contactsSipHeader => 'Endereços SIP';

  @override
  String get contactsRemoveAddress => 'Remover endereço';

  @override
  String get contactsAddSip => 'Adicionar endereço SIP';

  @override
  String get contactsFieldEmail => 'E-mail';

  @override
  String get contactsFieldNotes => 'Observações';

  @override
  String get contactsFieldFavorite => 'Favorito';

  @override
  String get contactsShowOnBlf => 'Mostrar no painel BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Monitorar a presença e a lâmpada de ocupado deste ramal';

  @override
  String get contactsAlwaysRecordTitle =>
      'Sempre gravar ligações com este contato';

  @override
  String get contactsAlwaysRecordSub =>
      'Substitui as regras de gravação automática';

  @override
  String get contactsRingtone => 'Toque';

  @override
  String get contactsPresenceVia => 'Presença pela conta';

  @override
  String get contactsDefaultAccount => 'Conta padrão';

  @override
  String get contactsDeleteContactTitle => 'Excluir contato?';

  @override
  String get contactsCannotUndo => 'Esta ação não pode ser desfeita.';

  @override
  String get messagesNewMessage => 'Nova mensagem';

  @override
  String get messagesNumberOrSip => 'Número ou endereço SIP';

  @override
  String get messagesNoConversations => 'Nenhuma conversa';

  @override
  String get messagesEmptySubtitle =>
      'Envie uma mensagem SIP para qualquer ramal ou endereço das suas contas.';

  @override
  String get messagesTyping => 'digitando...';

  @override
  String get messagesYouPrefix => 'Você: ';

  @override
  String get messagesSelect => 'Selecione uma conversa';

  @override
  String get messagesLanOnline => 'Online na sua rede';

  @override
  String get messagesLanOffline =>
      'Offline. As mensagens são enviadas quando ele voltar.';

  @override
  String messagesSendFileTo(String name) {
    return 'Enviar um arquivo para $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get messagesDeleteTitle => 'Excluir conversa?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Todas as mensagens com $name serão removidas.';
  }

  @override
  String get messagesDeleteMenu => 'Excluir conversa';

  @override
  String get messagesSayHello => 'Diga olá';

  @override
  String get messagesLanEmptySub =>
      'As mensagens vão direto para este dispositivo pela sua rede, com criptografia de ponta a ponta.';

  @override
  String get messagesSipEmptySub =>
      'As mensagens são enviadas com SIP MESSAGE pela sua conta.';

  @override
  String get messagesInputHint => 'Mensagem';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesStatusSending => 'Enviando';

  @override
  String get messagesStatusSent => 'Enviada';

  @override
  String get messagesStatusDelivered => 'Entregue';

  @override
  String get messagesStatusRead => 'Lida';

  @override
  String get messagesStatusFailed => 'Falhou';

  @override
  String get messagesNotDelivered =>
      'Não entregue. Toque para tentar novamente';

  @override
  String get uiStatusRegistered => 'Registrada';

  @override
  String get uiStatusRegistering => 'Registrando';

  @override
  String get uiStatusRegFailed => 'Falha no registro';

  @override
  String get uiStatusDisabled => 'Desativada';

  @override
  String get uiQualityMeasuring => 'Medindo';

  @override
  String get uiQualityExcellent => 'Excelente';

  @override
  String get uiQualityGood => 'Boa';

  @override
  String get uiQualityFair => 'Razoável';

  @override
  String get uiQualityPoor => 'Ruim';

  @override
  String get uiQualityBad => 'Péssima';

  @override
  String uiQualitySemantics(String label) {
    return 'Qualidade da ligação: $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Qualidade da ligação: $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Qualidade da ligação: $label';
  }

  @override
  String get uiSecureFull => 'Criptografada';

  @override
  String get uiSecureMedia => 'Mídia criptografada';

  @override
  String get uiSecureSignalling => 'Sinalização criptografada';

  @override
  String get uiSecureNone => 'Sem criptografia';

  @override
  String get uiSecureSrtpLine => 'Mídia SRTP';

  @override
  String get uiSecureTlsLine => 'Sinalização TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Repassando para $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Interfone para $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Interfone para um dispositivo próximo';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Interfone de $name';
  }

  @override
  String get lanCallIntercomFromUnnamed =>
      'Interfone de um dispositivo próximo';

  @override
  String lanCallToNamed(String name) {
    return 'Ligação LAN para $name';
  }

  @override
  String get lanCallToUnpaired => 'Ligação LAN para um dispositivo não pareado';

  @override
  String lanCallFromNamed(String name) {
    return 'Ligação LAN de $name';
  }

  @override
  String get lanCallFromUnpaired => 'Ligação LAN de um dispositivo não pareado';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Ligação transferida de $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Ligação transferida de $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'outro dispositivo';

  @override
  String lanRelayedTitle(String name) {
    return 'Retransmitida para $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Quem ligou está falando com $name. Você não está na ligação.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Ligando para $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Quem ligou continua conectado enquanto $name atende.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Consultando $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Aguardando que aceitem a ligação.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Falando com $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Quem ligou está em espera. Conclua o repasse quando estiver pronto.';

  @override
  String get lanRelayTakingBack => 'Retomando a ligação...';

  @override
  String get lanRelayTakeBack => 'Retomar';

  @override
  String get lanRelayEnd => 'Encerrar';

  @override
  String get lanSendToDevice => 'Enviar ao dispositivo';

  @override
  String get lanBusy => 'Ocupado';

  @override
  String get lanNoPairedOnline => 'Nenhum dispositivo pareado está online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name rejeitou o pareamento.';
  }

  @override
  String get lanPairRejected => 'Pareamento rejeitado.';

  @override
  String get lanPairCancelled => 'Pareamento cancelado.';

  @override
  String get lanPairTimedOut =>
      'Tempo do pareamento esgotado. Tente novamente.';

  @override
  String get lanPairFailed => 'Falha no pareamento';

  @override
  String lanPairFailedReason(String reason) {
    return 'Falha no pareamento: $reason';
  }

  @override
  String get lanPairThisDevice => 'este dispositivo';

  @override
  String get lanPairConnecting => 'Conectando com segurança...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name quer parear com este dispositivo.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Pareando com $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Confirme se este código é o mesmo nas duas telas.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Código de pareamento $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Aguardando a confirmação de $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name confirmou.';
  }

  @override
  String get lanPairReject => 'Rejeitar';

  @override
  String get lanPairCodesMatch => 'Os códigos coincidem';

  @override
  String lanPairPairedWith(String name) {
    return 'Pareado com $name.';
  }

  @override
  String get lanPairRequestTitle => 'Solicitação de pareamento';

  @override
  String lanPairTitle(String name) {
    return 'Parear com $name';
  }

  @override
  String get lanActionDecline => 'Recusar';

  @override
  String get lanActionAccept => 'Aceitar';

  @override
  String get lanFileIncomingTitle => 'Arquivo recebido';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size de $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Transferir uma ligação para cá?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' de $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' em $account',
    });
    return '$device quer passar uma ligação para você$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Eles falarão com você primeiro.';

  @override
  String get lanHandoffTakeCall => 'Atender';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Permitir interfone de $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'A ligação será atendida automaticamente no viva-voz.';

  @override
  String get lanIntercomDeny => 'Negar';

  @override
  String get lanIntercomAllow => 'Permitir';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name removeu este dispositivo da lista de pareados';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviando $count arquivos...',
      one: 'Enviando $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nova mensagem';

  @override
  String get lanSipMessage => 'Mensagem SIP';

  @override
  String get lanSipMessageSub => 'Para um número ou endereço pela sua conta';

  @override
  String get lanChatOnline => 'Chat LAN, online';

  @override
  String get lanChatOffline => 'Chat LAN, offline';

  @override
  String lanSavedAt(String path) {
    return 'Salvo em $path (caminho copiado)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Seus dispositivos, conversando diretamente';

  @override
  String get lanConnectByAddress => 'Conectar por endereço';

  @override
  String get lanSettingsTooltip => 'Ajustes da LAN';

  @override
  String get lanOffTitle => 'O LAN Link está desativado';

  @override
  String get lanOffSubtitle =>
      'Encontre seus outros dispositivos com SoftphonePro, converse, envie arquivos e repasse ligações, sem nenhum servidor.';

  @override
  String get lanTurnOn => 'Ativar LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'Não foi possível iniciar o LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'Digite host:porta ou cole o texto do código QR exibido no outro dispositivo.';

  @override
  String get lanScanTitle => 'Ler QR de pareamento LAN';

  @override
  String get lanScanQr => 'Ler QR';

  @override
  String get lanPaste => 'Colar';

  @override
  String get lanConnect => 'Conectar';

  @override
  String lanConnectedTo(String name) {
    return 'Conectado a $name';
  }

  @override
  String get lanCouldNotConnect => 'Não foi possível conectar';

  @override
  String get lanCouldNotStartPairing => 'Não foi possível iniciar o pareamento';

  @override
  String get lanThisDevice => 'Este dispositivo';

  @override
  String get lanDeviceNameTitle => 'Nome do dispositivo';

  @override
  String get lanStarting => 'Iniciando...';

  @override
  String get lanVisible => 'Visível na sua rede';

  @override
  String get lanNotRunning => 'Não está em execução';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas compartilhadas',
      one: '1 conta compartilhada',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Impressão digital';

  @override
  String get lanHideQr => 'Ocultar código QR';

  @override
  String get lanShowQr => 'Mostrar código QR para conectar outro dispositivo';

  @override
  String get lanCopyConnectionText => 'Copiar texto de conexão';

  @override
  String get lanConnectionTextCopied => 'Texto de conexão copiado';

  @override
  String get lanActiveOnOthers => 'Ativas em seus outros dispositivos';

  @override
  String get lanPairedDevices => 'Dispositivos pareados';

  @override
  String get lanNoPaired =>
      'Nenhum dispositivo pareado ainda. Pareie um dispositivo próximo para conversar, enviar arquivos e repassar ligações.';

  @override
  String get lanNearby => 'Próximos';

  @override
  String get lanNearbyHint =>
      'Procurando o SoftphonePro na sua rede. Os outros dispositivos precisam estar com o LAN Link ativado. Você também pode conectar por endereço com o botão de link acima.';

  @override
  String get lanTransfers => 'Transferências';

  @override
  String get lanFiles => 'Arquivos';

  @override
  String get lanPairedBadge => 'Pareado';

  @override
  String get lanTyping => 'digitando...';

  @override
  String get lanPair => 'Parear';

  @override
  String get lanUnpair => 'Desparear';

  @override
  String lanUnpairTitle(String name) {
    return 'Desparear $name?';
  }

  @override
  String get lanUnpairMessage =>
      'Você precisará parear novamente para conversar, enviar arquivos ou repassar ligações.';

  @override
  String get lanActionMessage => 'Mensagem';

  @override
  String get lanActionSendFile => 'Enviar arquivo';

  @override
  String get lanActionCall => 'Ligar';

  @override
  String get lanActionIntercom => 'Interfone';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Ativa em $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Ativa em $device  ·  $account';
  }

  @override
  String get lanPull => 'Puxar';

  @override
  String get lanTransferPreparing => 'Preparando...';

  @override
  String get lanTransferWaitingYou => 'Aguardando você';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Aguardando $name aceitar';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done de $total';
  }

  @override
  String get lanTransferVerifying => 'Verificando...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'De $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'Para $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  de $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  para $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Falhou: $error';
  }

  @override
  String get lanFileActions => 'Ações do arquivo';

  @override
  String get lanPathCopied => 'Caminho copiado';

  @override
  String get lanFileOpen => 'Abrir';

  @override
  String get lanFileShowInFolder => 'Mostrar na pasta';

  @override
  String get lanFileCopyPath => 'Copiar caminho';

  @override
  String lanNetworkError(String message) {
    return 'Erro de rede: $message';
  }

  @override
  String get lanErrNotRunning => 'Ative o LAN Link primeiro';

  @override
  String get lanErrBadAddress =>
      'Digite um endereço como 192.168.1.20:4711 ou cole o texto do código QR';

  @override
  String get lanErrFingerprint =>
      'Esse dispositivo não corresponde ao código lido. O código QR veio de outro dispositivo?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$file recebido de $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file enviado para $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name recusou $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Falha na transferência do arquivo: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Ative o LAN Link para ligar para dispositivos próximos';

  @override
  String get lanNoticePairFirst => 'Pareie com este dispositivo primeiro';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name não pode receber ligações no momento';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Consultando $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name não permitiu o interfone (ou não respondeu)';
  }

  @override
  String get lanHoOff => 'O LAN Link está desativado';

  @override
  String get lanHoPairFirst => 'Pareie com esse dispositivo primeiro';

  @override
  String lanHoOffline(String name) {
    return '$name está offline';
  }

  @override
  String get lanHoAlready => 'Esta ligação já está sendo repassada';

  @override
  String get lanHoEnded => 'A ligação já foi encerrada';

  @override
  String get lanHoWaitConnected => 'Aguarde até a ligação ser conectada';

  @override
  String get lanHoLanCall => 'Ligações LAN não podem ser repassadas';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name não pode receber ligações pela rede (as ligações LAN estão desativadas lá)';
  }

  @override
  String get lanHoNoLanHere =>
      'As ligações LAN não estão disponíveis neste dispositivo';

  @override
  String lanHoDeclined(String name) {
    return '$name recusou a ligação. Ela continua com você.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name não respondeu. A ligação continua com você.';
  }

  @override
  String get lanHoCancelled =>
      'O repasse foi cancelado. A ligação continua com você.';

  @override
  String lanHoUnreachable(String name) {
    return 'Não foi possível alcançar $name. A ligação continua com você.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Não foi possível alcançar $name ($reason). A ligação continua com você.';
  }

  @override
  String get lanHoEndedBefore =>
      'A ligação terminou antes de poder ser repassada';

  @override
  String lanHoPbxRefused(String name) {
    return 'O sistema telefônico recusou a transferência e $name não pode receber ligações LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Falha na transferência pelo sistema telefônico. Retransmitindo pela rede.';

  @override
  String lanHoSentTo(String name) {
    return 'Ligação enviada para $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Não foi possível ligar para o outro dispositivo pelo sistema telefônico';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name não está mais acessível';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Não foi possível atender a ligação para repassá-la';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Não foi possível ligar para $name pela rede. A ligação continua com você.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name não atendeu. A ligação continua com você.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Repassada para $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Ligação retransmitida para $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Aguarde $name atender primeiro';
  }

  @override
  String get lanHoFailed => 'Falha ao repassar';

  @override
  String lanHoTakenBack(String name) {
    return 'Ligação retomada de $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name encerrou a consulta. A ligação voltou para você.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Não foi possível repassar a ligação para $name';
  }

  @override
  String get diagSip400Explain =>
      'O servidor não conseguiu entender a requisição.';

  @override
  String get diagSip400Fix =>
      'Verifique as configurações da conta (domínio, usuário, proxy). Se persistir, envie um rastreamento SIP ao seu provedor.';

  @override
  String get diagSip401Explain =>
      'O servidor rejeitou as credenciais (ou está solicitando-as).';

  @override
  String get diagSip401Fix =>
      'Verifique o usuário, o usuário de autenticação e a senha. Alguns provedores usam um \"auth ID\" separado.';

  @override
  String get diagSip403Explain =>
      'O servidor entendeu a requisição, mas a recusa: senha incorreta, conta desativada ou seu IP não é permitido.';

  @override
  String get diagSip403Fix =>
      'Digite a senha novamente, verifique se a conta está ativa e confirme que seu IP público não está bloqueado (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'O servidor não conhece este usuário ou número.';

  @override
  String get diagSip404Fix =>
      'Verifique o usuário e o domínio; para ligações, verifique o número discado e as regras de discagem.';

  @override
  String get diagSip405Explain => 'O servidor não aceita esta requisição.';

  @override
  String get diagSip405Fix =>
      'Geralmente inofensivo para pings OPTIONS. Para REGISTER, verifique se você está falando com um registrar SIP.';

  @override
  String get diagSip407Explain => 'O proxy de saída exige credenciais.';

  @override
  String get diagSip407Fix =>
      'Verifique a senha da conta e as configurações do proxy de saída.';

  @override
  String get diagSip408Explain => 'O servidor não respondeu a tempo.';

  @override
  String get diagSip408Fix =>
      'Verifique o endereço e a porta do servidor e os firewalls, e tente TCP ou TLS. Tempos esgotados repetidos apenas em UDP podem indicar SIP ALG no roteador.';

  @override
  String get diagSip410Explain => 'O número não existe mais.';

  @override
  String get diagSip410Fix => 'Verifique o número discado.';

  @override
  String get diagSip415Explain =>
      'O outro lado não aceita o tipo de conteúdo ou os codecs oferecidos.';

  @override
  String get diagSip415Fix =>
      'Ative mais codecs (ex.: PCMU/PCMA) em Ajustes > Codecs.';

  @override
  String get diagSip421Explain =>
      'O servidor exige uma extensão SIP que este cliente não ofereceu.';

  @override
  String get diagSip421Fix =>
      'Verifique as opções de NAT/ICE/100rel/temporizadores da conta.';

  @override
  String get diagSip423Explain =>
      'A expiração do registro é menor do que o servidor permite.';

  @override
  String get diagSip423Fix =>
      'Aumente a expiração do registro nas configurações da conta.';

  @override
  String get diagSip480Explain =>
      'O usuário não está registrado ou não pode ser alcançado agora.';

  @override
  String get diagSip480Fix =>
      'Verifique se a outra parte está registrada; no registro, o servidor pode estar sobrecarregado: tente novamente mais tarde.';

  @override
  String get diagSip481Explain =>
      'O servidor perdeu o estado do diálogo (ex.: após uma reinicialização ou mudança de rede).';

  @override
  String get diagSip481Fix =>
      'Desligue e tente novamente. Se for frequente, ative os temporizadores de sessão.';

  @override
  String get diagSip483Explain => 'A requisição circulou entre servidores.';

  @override
  String get diagSip483Fix =>
      'Verifique a configuração de desvio e roteamento no PBX.';

  @override
  String get diagSip484Explain => 'O número discado é curto demais.';

  @override
  String get diagSip484Fix =>
      'Disque o número completo ou verifique as regras de discagem.';

  @override
  String get diagSip486Explain => 'A outra parte está ocupada.';

  @override
  String get diagSip486Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip487Explain =>
      'A ligação foi cancelada antes de ser atendida.';

  @override
  String get diagSip487Fix => 'Normal quando quem liga desliga enquanto toca.';

  @override
  String get diagSip488Explain =>
      'Nenhum codec ou configuração de criptografia em comum com o outro lado.';

  @override
  String get diagSip488Fix =>
      'Verifique os codecs e o SRTP (uma conta com SRTP obrigatório não consegue ligar para um endpoint RTP simples).';

  @override
  String get diagSip491Explain => 'Dois re-INVITEs colidiram.';

  @override
  String get diagSip491Fix => 'Normalmente repetido automaticamente.';

  @override
  String get diagSip500Explain => 'O servidor falhou internamente.';

  @override
  String get diagSip500Fix =>
      'Tente novamente mais tarde e contate o provedor se continuar.';

  @override
  String get diagSip502Explain =>
      'Um servidor upstream retornou uma resposta inválida.';

  @override
  String get diagSip502Fix =>
      'Tente novamente mais tarde; contate o provedor se continuar.';

  @override
  String get diagSip503Explain =>
      'O servidor está sobrecarregado, fora do ar ou rejeitando este cliente (limite de taxa).';

  @override
  String get diagSip503Fix =>
      'Aguarde e tente novamente, consulte a página de status do provedor ou tente outro servidor/porta.';

  @override
  String get diagSip504Explain => 'Um servidor upstream não respondeu a tempo.';

  @override
  String get diagSip504Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip600Explain => 'Todos os destinos estão ocupados.';

  @override
  String get diagSip600Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip603Explain => 'A outra parte rejeitou a ligação.';

  @override
  String get diagSip603Fix => 'Nada a corrigir: a ligação foi recusada.';

  @override
  String get diagSip604Explain => 'O número não existe.';

  @override
  String get diagSip604Fix => 'Verifique o número discado.';

  @override
  String get diagSip606Explain =>
      'A outra parte não pode aceitar a sessão como foi oferecida.';

  @override
  String get diagSip606Fix =>
      'Verifique os codecs e as configurações de criptografia.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provisória ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'A requisição está sendo processada.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Sucesso ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'A requisição foi bem-sucedida.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Redirecionada ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'O destino mudou de lugar.';

  @override
  String get diagSipRedirectedFix => 'Verifique as configurações de desvio.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Erro do cliente ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'O servidor rejeitou a requisição.';

  @override
  String get diagSipClientErrorFix => 'Verifique a conta e o número discado.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Erro do servidor ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'O servidor falhou ao processar a requisição.';

  @override
  String get diagSipServerErrorFix =>
      'Tente novamente mais tarde ou contate o provedor.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Falha global ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'A requisição não pode ser atendida em lugar nenhum.';

  @override
  String get diagSipNoResponseTitle => 'Sem resposta';

  @override
  String get diagSipNoResponseExplain => 'Nenhuma resposta SIP foi recebida.';

  @override
  String get diagSipNoResponseFix =>
      'Verifique a conexão de rede e o endereço do servidor.';

  @override
  String get diagWizStepNet => 'Conectividade de rede';

  @override
  String diagWizStepDns(String account) {
    return 'DNS e SRV: $account';
  }

  @override
  String get diagWizStepNat => 'Tipo de NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Alcance do servidor: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'Certificado TLS: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registro: $account';
  }

  @override
  String get diagWizStepAlg => 'Verificação de SIP ALG';

  @override
  String get diagWizChecking => 'Verificando...';

  @override
  String diagWizEngineError(String message) {
    return 'Erro do mecanismo: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Falha na verificação: $error';
  }

  @override
  String get diagWizNoEngine => 'O mecanismo SIP não está em execução';

  @override
  String get diagWizNoEngineFix =>
      'Aguarde o mecanismo iniciar (ou reinicie o app) e execute as verificações novamente.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privado)';
  }

  @override
  String get diagWizNetNone =>
      'Nenhuma interface de rede ativa com endereço IP';

  @override
  String get diagWizNetNoneFix =>
      'Conecte-se ao Wi-Fi, Ethernet ou dados móveis e execute as verificações novamente.';

  @override
  String get diagWizNetIpv6Only => 'Apenas endereços IPv6 encontrados';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Muitos provedores SIP são somente IPv4. Ative o IPv4 nesta rede ou use um provedor com suporte a IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 endereços IPv4',
      one: '1 endereço IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interface',
    );
    return '$_temp0 em $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Uma interface do tipo VPN está ativa. As VPNs podem adicionar latência ou bloquear UDP; desative-a se as ligações apresentarem problemas.';

  @override
  String get diagWizDnsNoServer => 'A conta não tem endereço de servidor';

  @override
  String get diagWizDnsNoServerFix => 'Edite a conta e informe o domínio SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host é um endereço IP, DNS não é necessário';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: nenhum';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: nenhum ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: nenhum';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (prioridade $priority, peso $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: falha na consulta ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host não é resolvido';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Verifique se o domínio tem erros de digitação e se o seu servidor DNS funciona. Você pode definir um servidor DNS personalizado em Ajustes > Rede (ex.: 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host tem registros SRV, mas nenhum registro de endereço';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Os destinos SRV serão usados. Se as ligações falharem, peça ao provedor que verifique o registro A.';

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
      other: ', $srv registros SRV',
      one: ', 1 registro SRV',
      zero: '',
    );
    return '$host é resolvido para $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Tempo esgotado na detecção de NAT';

  @override
  String get diagWizNatTimeoutFix =>
      'O servidor STUN pode estar inacessível (UDP bloqueado?). Verifique Ajustes > Rede > Servidores STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'Servidor STUN: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Sem NAT: este dispositivo tem um endereço público';

  @override
  String get diagWizNatFullCone => 'NAT full cone: favorável a VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT restricted cone: funciona com STUN e keep-alives';

  @override
  String get diagWizNatPortRestricted =>
      'NAT port-restricted cone: funciona com STUN e keep-alives';

  @override
  String get diagWizNatSymmetric =>
      'NAT simétrico: o STUN sozinho não consegue prever a porta de mídia';

  @override
  String get diagWizNatSymmetricFix =>
      'É provável haver áudio unidirecional ou ausência de áudio em algumas ligações. Ative o ICE e um relay TURN nas configurações da conta (Conta > NAT) ou use um provedor/PBX com relay de mídia (rtpengine).';

  @override
  String get diagWizNatBlocked => 'O UDP parece estar bloqueado';

  @override
  String get diagWizNatBlockedFix =>
      'Use o transporte TCP ou TLS na conta. Se a rede filtra tudo exceto tráfego web, tente TLS na porta 443, se o seu provedor aceitar.';

  @override
  String get diagWizNatUnknown => 'Não foi possível determinar o tipo de NAT';

  @override
  String get diagWizNatUnknownFix =>
      'O servidor STUN não respondeu. Tente outro servidor STUN em Ajustes > Rede.';

  @override
  String get diagWizNatErr =>
      'O servidor STUN não respondeu, por isso não foi possível determinar o tipo de NAT.';

  @override
  String get diagWizNatUnknownRaw =>
      'Não foi possível determinar o tipo de NAT.';

  @override
  String get diagWizOptionsNotLoaded =>
      'A conta não está carregada no mecanismo';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Sem resposta ao OPTIONS em $seconds s (transporte: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'O servidor não está acessível. Verifique o endereço e a porta, se um firewall não está descartando SIP, e tente outro transporte (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Tempo da requisição esgotado ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'O servidor respondeu $code $reason após $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'O servidor respondeu $code $reason em $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Um $code em resposta ao OPTIONS é normal: o servidor está acessível, mas não permite sondagens anônimas.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Um tempo de ida e volta acima de 300 ms adiciona atraso perceptível às conversas. Um servidor mais próximo ou uma conexão com fio ajudam.';

  @override
  String get diagWizTlsRejected => 'O certificado do servidor foi rejeitado';

  @override
  String diagWizTlsSubject(String value) {
    return 'Assunto: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Emissor: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problemas: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Expira em: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cifra: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Se este for o seu próprio PBX com certificado autoassinado e a impressão digital acima coincidir, você pode confiar nele. Caso contrário, peça ao provedor um certificado de uma CA pública.';

  @override
  String get diagWizTlsTrust => 'Confiar neste certificado';

  @override
  String diagWizTlsExpired(String date) {
    return 'O certificado expirou em $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Peça ao administrador do servidor que renove o certificado.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'O certificado expira em $days dias',
      one: 'O certificado expira em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Avise o administrador do servidor para renová-lo em breve.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Conectado, mas a verificação informou: $problems';
  }

  @override
  String get diagWizTlsOk => 'Conexão TLS estabelecida, certificado válido';

  @override
  String get diagWizTlsRegistered =>
      'Registrado via TLS (nenhum detalhe de certificado informado)';

  @override
  String get diagWizTlsNone => 'Nenhuma conexão TLS foi observada ainda';

  @override
  String get diagWizTlsNoneFix =>
      'Verifique a porta TLS (geralmente 5061) e se o servidor aceita TLS 1.2 ou mais recente.';

  @override
  String get diagWizRegDisabledByConfig =>
      'O registro está desativado para esta conta (uso ponto a ponto)';

  @override
  String get diagWizRegRegistered => 'Registrada';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registrada (expira em $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transporte: $transport';
  }

  @override
  String get diagWizRegInProgress => 'O registro ainda está em andamento';

  @override
  String get diagWizRegInProgressFix =>
      'Aguarde alguns segundos. Se nunca terminar, o servidor não está respondendo; veja a verificação de alcance acima.';

  @override
  String get diagWizRegFailed => 'Falha no registro';

  @override
  String get diagWizRegOffline => 'A conta está offline';

  @override
  String get diagWizRegOfflineFix =>
      'Verifique a conexão de rede. O app tenta novamente de forma automática.';

  @override
  String get diagWizRegDisabled => 'A conta está desativada';

  @override
  String get diagWizAlgNoUdp =>
      'Nenhuma conta usa UDP, portanto o SIP ALG não é um problema';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: sem resposta via UDP, mas o TCP respondeu ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: sem resposta via UDP ou TCP (problema de servidor ou firewall, e não de ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: o OPTIONS é respondido, mas o REGISTER esgota o tempo, o que é típico de um roteador reescrevendo o SIP';
  }

  @override
  String get diagWizAlgSuspected => 'Suspeita de SIP ALG no seu roteador';

  @override
  String get diagWizAlgSuspectedFix =>
      'Desative \"SIP ALG\" / \"SIP helper\" nas configurações do roteador, mude a conta para TCP ou TLS, ou altere a porta SIP (ex.: 5080) para que o roteador pare de alterar os pacotes.';

  @override
  String get diagWizAlgContactChanged =>
      'O endereço Contact mudou entre a requisição e a resposta';

  @override
  String get diagWizAlgContactChangedFix =>
      'Isso pode ser um SIP ALG ou um servidor que reescreve contatos. Se as ligações tocam, mas ficam sem áudio ou caem depois de um tempo, desative o SIP ALG no roteador ou use TCP/TLS ou a porta 5080.';

  @override
  String get diagWizAlgOk => 'Nenhum sinal de interferência de SIP ALG';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'O Contact do REGISTER $sent voltou como $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Salvar $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName salvo';
  }

  @override
  String get diagSaveFailed => 'Não foi possível salvar o arquivo';

  @override
  String get diagCopiedText => 'Texto copiado para a área de transferência';

  @override
  String get diagCopiedReport =>
      'Relatório copiado para a área de transferência';

  @override
  String get diagCopiedBundle =>
      'Pacote de diagnóstico copiado para a área de transferência';

  @override
  String get diagCopiedLogs => 'Logs copiados para a área de transferência';

  @override
  String get diagCopiedTrace =>
      'Rastreamento copiado para a área de transferência';

  @override
  String get diagCopiedDialog => 'Diálogo copiado para a área de transferência';

  @override
  String get diagSaveAsLog => 'Salvar como .log';

  @override
  String get diagSysAppVersion => 'Versão do app';

  @override
  String get diagSysPlatform => 'Plataforma';

  @override
  String get diagSysEngine => 'Mecanismo';

  @override
  String get diagSysAccounts => 'Contas';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered de $total registradas';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Não foi possível ler as informações do sistema: $error';
  }

  @override
  String get diagSysTransports => 'Transportes';

  @override
  String get diagSysNoneReported => 'Nenhum informado';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter =>
      'Codecs ativados, da maior para a menor prioridade.';

  @override
  String get diagSysEngineNotRunning => 'Mecanismo não está em execução';

  @override
  String diagSysCodecPriority(int priority) {
    return 'prioridade $priority';
  }

  @override
  String get diagSysCodecDisabled => 'desativado';

  @override
  String get diagSysExport => 'Exportar';

  @override
  String get diagSysExportFooter =>
      'O pacote contém informações do sistema, resultados da verificação de rede, logs recentes e o rastreamento SIP, com as credenciais ocultadas.';

  @override
  String get diagSysCopyBundle => 'Copiar pacote de diagnóstico';

  @override
  String get diagSysSaveBundle => 'Salvar pacote de diagnóstico';

  @override
  String get diagTabSipTrace => 'Rastreamento SIP';

  @override
  String get diagTabNetwork => 'Rede';

  @override
  String get diagTabQuality => 'Qualidade';

  @override
  String get diagTabAudioTest => 'Teste de áudio';

  @override
  String get diagTabLogs => 'Logs';

  @override
  String get diagTabSystem => 'Sistema';

  @override
  String diagRawSentTo(String remote) {
    return 'enviada para $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'recebida de $remote';
  }

  @override
  String get diagRawCopied => 'Mensagem copiada';

  @override
  String get diagRawLadder => 'Sequência';

  @override
  String get diagRawRedact => 'Ocultar credenciais';

  @override
  String diagRawTruncated(int count) {
    return '... truncada ($count caracteres)';
  }

  @override
  String get diagWizIntro =>
      'Verifica sua conexão, DNS, NAT, alcance do servidor, TLS e registro, e explica o que corrigir.';

  @override
  String get diagWizStop => 'Parar';

  @override
  String get diagWizRunChecks => 'Executar verificações';

  @override
  String get diagWizRunAgain => 'Executar de novo';

  @override
  String get diagWizCopyReport => 'Copiar relatório';

  @override
  String get diagWizSaveReport => 'Salvar relatório';

  @override
  String diagWizCountPassed(int count) {
    return 'Aprovadas $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Avisos $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Falhas $count';
  }

  @override
  String get diagWizStatusPass => 'Aprovada';

  @override
  String get diagWizStatusWarn => 'Aviso';

  @override
  String get diagWizStatusFail => 'Falhou';

  @override
  String get diagWizStatusSkipped => 'Ignorada';

  @override
  String get diagWizStatusRunning => 'Em execução';

  @override
  String get diagWizStatusPending => 'Pendente';

  @override
  String get diagQualityTitle => 'Qualidade da ligação';

  @override
  String get diagQualityNoData =>
      'Nenhum dado de qualidade foi registrado para esta ligação.';

  @override
  String get diagQualityTraceForCall => 'Rastreamento SIP desta ligação';

  @override
  String get diagQualityTraceNotCaptured =>
      'Rastreamento SIP não capturado para esta ligação';

  @override
  String get diagQualityLiveCall => 'Ligação ao vivo';

  @override
  String get diagQualityNoActiveCall =>
      'Nenhuma ligação ativa. Inicie uma ligação e o MOS, o jitter, a perda e o tempo de ida e volta serão exibidos aqui ao vivo.';

  @override
  String get diagQualityRecentCalls => 'Ligações recentes';

  @override
  String get diagQualityNoFinished =>
      'Ainda não há ligações concluídas com dados de qualidade.';

  @override
  String get diagQualityCallEnded => 'A ligação terminou.';

  @override
  String get diagQualityMeasuring => 'medindo';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Gráfico de $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Gráfico de $title, mais recente $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   máx. $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Média $avg  ·  pior $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Perda';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count pcts';
  }

  @override
  String get diagQualityMedia => 'Mídia';

  @override
  String get diagQualityNoSeries =>
      'Nenhuma série temporal foi registrada para esta ligação.';

  @override
  String get diagQualityPacketLoss => 'Perda de pacotes';

  @override
  String get diagQualityRtt => 'Tempo de ida e volta';

  @override
  String get diagLogsForward => 'Encaminhar logs do mecanismo';

  @override
  String get diagLogsForwardSub =>
      'Enviar linhas de log do pjsip a este visualizador';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Nível $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Ocultar ao exportar';

  @override
  String get diagLogsSearch => 'Buscar nos logs';

  @override
  String get diagLogsEmpty => 'Ainda não há linhas de log.';

  @override
  String get diagLogsForwardingOff =>
      'O encaminhamento de logs está desativado. Ative-o para capturar os logs do mecanismo.';

  @override
  String get diagLogsNoMatch => 'Nenhuma linha corresponde à busca.';

  @override
  String get diagAudioEngineNotRunning =>
      'O mecanismo SIP não está em execução.';

  @override
  String get diagAudioMicrophone => 'Microfone';

  @override
  String get diagAudioMicFooter =>
      'O medidor de nível lê o dispositivo de áudio, que o mecanismo abre durante uma ligação ou o teste de eco.';

  @override
  String get diagAudioLevelMeter => 'Medidor de nível';

  @override
  String get diagAudioLevelMeterSub => 'Fale e observe a barra se mover';

  @override
  String get diagAudioMic => 'Mic.';

  @override
  String get diagAudioSpeaker => 'Alto-falante';

  @override
  String get diagAudioEchoTest => 'Teste de eco';

  @override
  String get diagAudioEchoFooter =>
      'Reproduz sua voz no alto-falante. Use fones de ouvido para evitar microfonia.';

  @override
  String get diagAudioEchoActive => 'Ativo: fale agora';

  @override
  String get diagAudioEchoIdle => 'Loopback do microfone para o alto-falante';

  @override
  String get diagAudioSpeakerTest => 'Teste do alto-falante';

  @override
  String get diagAudioPlayTone => 'Reproduzir tom de teste';

  @override
  String get diagAudioPlayToneSub => 'Reproduz no alto-falante selecionado';

  @override
  String get diagAudioPlayingDtmf => 'Reproduzindo DTMF';

  @override
  String get diagAudioPlayingRingback => 'Reproduzindo tom de chamada';

  @override
  String get diagAudioRingback => 'Tom de chamada';

  @override
  String get diagAudioDevices => 'Dispositivos';

  @override
  String get diagAudioChooseDevices => 'Escolha o microfone e o alto-falante';

  @override
  String get diagAudioChooseDevicesSub => 'Abre Ajustes > Áudio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'Nível de $label: $percent por cento';
  }

  @override
  String get diagLadderLocal => 'Local';

  @override
  String diagLadderSent(String message) {
    return 'Enviada: $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Recebida: $message';
  }

  @override
  String get diagTraceCapture => 'Capturar mensagens SIP';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0  ·  $size  ·  $dropped mais antigas descartadas';
  }

  @override
  String get diagTraceOffHint =>
      'Desativado. Ative e depois registre ou faça uma ligação.';

  @override
  String get diagTraceExportOrClear => 'Exportar ou limpar';

  @override
  String get diagTraceSaveAsPcap => 'Salvar como .pcap';

  @override
  String get diagTraceCopyAsText => 'Copiar como texto';

  @override
  String get diagTraceSearchHint => 'Busque texto, número ou Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Somente erros';

  @override
  String get diagTraceFilterMethod => 'Filtrar por método';

  @override
  String get diagTraceAllMethods => 'Todos os métodos';

  @override
  String get diagTraceMethod => 'Método';

  @override
  String get diagTraceFilterAccount => 'Filtrar por conta';

  @override
  String get diagTraceAllAccounts => 'Todas as contas';

  @override
  String get diagTraceAccount => 'Conta';

  @override
  String get diagTraceRedact => 'Ocultar';

  @override
  String get diagTraceList => 'Lista';

  @override
  String get diagTraceWaiting => 'Aguardando tráfego SIP';

  @override
  String get diagTraceWaitingSub =>
      'Registre uma conta ou faça uma ligação e as mensagens aparecerão aqui.';

  @override
  String get diagTraceOff => 'O rastreamento SIP está desativado';

  @override
  String get diagTraceOffSub =>
      'Ative a captura para ver cada requisição e resposta SIP, em lista ou em diagrama de sequência.';

  @override
  String get diagTraceNoMatch => 'Nenhuma mensagem corresponde aos filtros';

  @override
  String get diagTraceAllDialogs => 'Todos os diálogos';

  @override
  String get diagTraceCopyDialog => 'Copiar este diálogo';

  @override
  String get diagTraceNoResponse => 'sem resposta';

  @override
  String get diagTraceNoCallId => 'sem Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Gravação';

  @override
  String get recFormatWav => 'Padrão (WAV)';

  @override
  String get recFormatWavStereo =>
      'Estéreo, você e quem ligou em canais separados (WAV)';

  @override
  String get recFormatOpus => 'Compactado (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, cerca de 2 MB por minuto. Toca em qualquer lugar.';

  @override
  String get recFormatWavStereoHint =>
      'Dois canais, cerca de 4 MB por minuto. Você à esquerda, quem ligou à direita.';

  @override
  String get recFormatOpusHint =>
      'Cerca de 0,2 MB por minuto. Ogg Opus; alguns players no iPhone, Mac e Windows não conseguem abri-lo.';

  @override
  String get recOptionInherit => 'Usar configuração global';

  @override
  String get recOptionAlways => 'Gravar todas as ligações';

  @override
  String get recOptionIncoming => 'Gravar somente ligações recebidas';

  @override
  String get recOptionOutgoing => 'Gravar somente ligações realizadas';

  @override
  String get recOptionNever => 'Nunca gravar';

  @override
  String get recRuleAll => 'Todas as ligações';

  @override
  String get recRuleIncoming => 'Somente recebidas';

  @override
  String get recRuleOutgoing => 'Somente realizadas';

  @override
  String get recAutoDeleteNever => 'Nunca';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Após $days dias',
      one: 'Após 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Após 1 ano';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0  ·  $size  ·  exclusão automática após $_temp1';
  }

  @override
  String get recSettingsFormat => 'Formato';

  @override
  String get recSettingsAutoGroup => 'Gravação automática';

  @override
  String get recSettingsAutoFooter =>
      'Verifique as leis locais antes de gravar ligações. Ative \"Sempre gravar ligações com este contato\" em um contato para gravá-las independentemente destas regras.';

  @override
  String get recSettingsAutoRule => 'Gravar ligações automaticamente';

  @override
  String get recSettingsAccountOverride => 'Substituição para esta conta';

  @override
  String get recSettingsNoticesGroup => 'Avisos';

  @override
  String get recSettingsNoticeSwitch => 'Reproduzir um aviso antes de gravar';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Reproduz primeiro um aviso para a outra pessoa. O arquivo do aviso é escolhido em Ajustes > Ligações > Avisos.';

  @override
  String get recSettingsNoticeFile => 'Escolher o arquivo do aviso';

  @override
  String get recSettingsNoticeFileHint => 'Abre Ajustes > Ligações > Avisos';

  @override
  String get recSettingsBeep => 'Bipe de gravação';

  @override
  String get recSettingsBeepHint => 'Avisar a outra pessoa periodicamente';

  @override
  String get recSettingsTransfersGroup => 'Transferências';

  @override
  String get recSettingsContinue => 'Continuar gravando durante transferências';

  @override
  String get recSettingsContinueHint =>
      'Grava a ligação de consulta de uma transferência assistida e a ligação repassada a nós por uma transferência, e vincula as gravações';

  @override
  String get recSettingsStorageGroup => 'Armazenamento';

  @override
  String get recSettingsFolder => 'Pasta';

  @override
  String get recSettingsFolderHint => 'Onde as gravações são salvas';

  @override
  String get recSettingsFolderPlaceholder => 'Documentos do app / Gravações';

  @override
  String get recSettingsChooseFolder => 'Escolher pasta...';

  @override
  String get recSettingsFolderPickerTitle => 'Pasta de gravações';

  @override
  String get recSettingsAutoDelete => 'Excluir gravações antigas';

  @override
  String get recSettingsAutoDeleteHint =>
      'Verificado na inicialização e uma vez por dia';

  @override
  String get recSettingsManage => 'Gerenciar gravações';

  @override
  String get recSettingsOpenFolder => 'Abrir pasta de gravações';

  @override
  String get recPageTitle => 'Gravações';

  @override
  String recSelectedCount(int count) {
    return '$count selecionada(s)';
  }

  @override
  String get recCancelSelection => 'Cancelar seleção';

  @override
  String get recSelectAll => 'Selecionar tudo';

  @override
  String get recShareSelected => 'Compartilhar selecionadas';

  @override
  String get recDeleteSelected => 'Excluir selecionadas';

  @override
  String get recSearchTooltip => 'Buscar gravações';

  @override
  String get recSelectTooltip => 'Selecionar gravações';

  @override
  String get recMenuSettings => 'Ajustes de gravação';

  @override
  String get recSearchHint => 'Buscar nome ou número';

  @override
  String get recEmptyNone => 'Nenhuma gravação ainda';

  @override
  String get recEmptyNoneHint =>
      'Grave uma ligação com o botão Gravar ou ative a gravação automática em Ajustes.';

  @override
  String get recEmptyNoMatch => 'Nenhuma gravação correspondente';

  @override
  String get recEmptyNoMatchHint => 'Tente outra busca ou filtro.';

  @override
  String get recClearFilters => 'Limpar filtros';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count gravações?',
      one: 'Excluir 1 gravação?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Os arquivos de áudio serão removidos deste dispositivo. Esta ação não pode ser desfeita.';

  @override
  String get recDeleteOneTitle => 'Excluir esta gravação?';

  @override
  String get recDeleteOneMessage =>
      'O arquivo de áudio será removido deste dispositivo. Esta ação não pode ser desfeita.';

  @override
  String get recFilterAll => 'Todas';

  @override
  String get recFilterIncoming => 'Recebidas';

  @override
  String get recFilterOutgoing => 'Realizadas';

  @override
  String get recFilterByAccount => 'Filtrar por conta';

  @override
  String get recFilterAllAccounts => 'Todas as contas';

  @override
  String get recFilterAccountFallback => 'Conta';

  @override
  String get recFilterAnyDate => 'Qualquer data';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Limpar datas';

  @override
  String get recMissingFile => 'O arquivo de áudio não está neste dispositivo.';

  @override
  String recRelated(String title) {
    return 'Relacionada: $title';
  }

  @override
  String get recRenameTitle => 'Renomear gravação';

  @override
  String get recRenameHint => 'Nome';

  @override
  String get recSaveAs => 'Salvar como...';

  @override
  String get recShowInFinder => 'Mostrar no Finder';

  @override
  String get recShowInFolder => 'Mostrar na pasta';

  @override
  String get recViewCall => 'Ver ligação';

  @override
  String recSavedTo(String path) {
    return 'Salva em $path';
  }

  @override
  String get recSaveFailed => 'Não foi possível salvar a gravação';

  @override
  String get recShareFailed => 'Não foi possível compartilhar a gravação';

  @override
  String get recSaveDialogTitle => 'Salvar gravação';

  @override
  String get recShareSubject => 'Gravações de ligações';

  @override
  String get recPlayerUnsupported =>
      'Este dispositivo não consegue reproduzir gravações Opus aqui.';

  @override
  String get recPlayerOpenWith => 'Abrir com...';

  @override
  String get recPlayerNotFound => 'O arquivo da gravação não foi encontrado';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Não é possível reproduzir esta gravação: $error';
  }

  @override
  String get recPlayerPlay => 'Reproduzir gravação';

  @override
  String get recPlayerPause => 'Pausar gravação';

  @override
  String get audioFilesTitle => 'Arquivos de áudio';

  @override
  String audioAdded(String name) {
    return '\"$name\" adicionado';
  }

  @override
  String get audioFileUnavailable => 'Esse arquivo não está disponível.';

  @override
  String get audioNameRequired => 'Digite um nome';

  @override
  String audioDeleteTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get audioDeleteMessage =>
      'As configurações que usam este arquivo voltam ao padrão.';

  @override
  String get audioGroupAdd => 'Adicionar';

  @override
  String get audioAddFooter =>
      'Arquivos WAV (PCM, mu-law, A-law) e MP3 funcionam. Os arquivos são copiados para o app, então o original pode ser movido.';

  @override
  String get audioImport => 'Importar um WAV ou MP3…';

  @override
  String get audioGroupMine => 'Meus arquivos';

  @override
  String get audioEmptyTitle => 'Nenhum arquivo ainda';

  @override
  String get audioEmptyHint => 'Importe um arquivo ou grave seu próprio aviso.';

  @override
  String get audioGroupBuiltIn => 'Integrados';

  @override
  String get audioBuiltInFooter => 'Gerados para o SoftphonePro, de uso livre.';

  @override
  String get audioPreviewStop => 'Parar prévia';

  @override
  String audioPreviewPlay(String name) {
    return 'Prévia de $name';
  }

  @override
  String get audioRecordedName => 'Dê um nome a esta gravação';

  @override
  String get audioRecordedDefaultName => 'Meu aviso';

  @override
  String audioSaved(String name) {
    return '\"$name\" salvo';
  }

  @override
  String get audioRecorderStop => 'Parar';

  @override
  String get audioRecorderPlay => 'Reproduzir gravação';

  @override
  String audioRecorderNew(String duration) {
    return 'Nova gravação  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Descartar';

  @override
  String get audioRecordOwn => 'Grave o seu…';

  @override
  String get audioRecordOwnHint =>
      'Usa o microfone selecionado nos ajustes de Áudio';

  @override
  String get audioMissingFile => 'Arquivo ausente';

  @override
  String get audioBuiltInCalm => 'Calmo (integrado)';

  @override
  String get audioBuiltInBreeze => 'Brisa (integrado)';

  @override
  String get audioBuiltInChime => 'Sino de aviso (integrado)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Somente arquivos WAV e MP3 podem ser usados.';

  @override
  String get audioErrNotFound => 'Não foi possível encontrar esse arquivo.';

  @override
  String get audioErrNotSaved => 'A gravação não foi salva.';

  @override
  String get audioErrEmpty => 'Este arquivo de áudio está vazio ou ilegível.';

  @override
  String audioErrUnusable(String reason) {
    return 'Este arquivo de áudio não pode ser usado ($reason). Use WAV PCM, mu-law ou A-law, ou MP3.';
  }

  @override
  String get audioRecEngineOff =>
      'O mecanismo de ligações não está em execução.';

  @override
  String get audioRecUnsupported =>
      'Esta versão do mecanismo de ligações não consegue gravar o microfone.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Não foi possível iniciar a gravação: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Falha na gravação: $reason';
  }

  @override
  String get audioStrengthLow => 'Baixa';

  @override
  String get audioStrengthMedium => 'Média';

  @override
  String get audioStrengthHigh => 'Alta';

  @override
  String get audioStrengthMax => 'Máxima';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Padrão do sistema';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Padrão do sistema ($name)';
  }

  @override
  String get voiceTitle => 'Isolamento de voz';

  @override
  String get voiceUnavailable =>
      'O cancelamento de ruído por IA não está disponível nesta versão do mecanismo de ligações. A supressão de ruído padrão em Processamento continua funcionando.';

  @override
  String get voiceGroupAi => 'Cancelamento de ruído por IA';

  @override
  String get voiceAiFooter =>
      'Remove cliques de teclado, ventiladores e vozes de fundo da ligação usando uma rede neural no dispositivo (RNNoise). Nada sai do seu dispositivo. Uma intensidade maior remove mais ruído, mas pode cortar o início das palavras.';

  @override
  String get voiceMic => 'Meu microfone';

  @override
  String get voiceMicHint => 'Melhora o que a outra pessoa ouve';

  @override
  String get voiceOthers => 'Outros participantes';

  @override
  String get voiceOthersHint => 'Melhora o áudio de quem liga com ruído';

  @override
  String voiceStrength(String value) {
    return 'Intensidade: $value';
  }

  @override
  String get voiceGroupTry => 'Experimente';

  @override
  String get voiceTryFooter =>
      'Use fones de ouvido para o teste de eco, ou você ouvirá microfonia.';

  @override
  String get voiceEchoTest => 'Testar com eco';

  @override
  String get voiceEchoTestHint =>
      'Reproduz para você o áudio processado do seu microfone';

  @override
  String get voiceEchoFailed => 'Falha no teste de eco';

  @override
  String get voiceGroupSystem => 'Sistema';

  @override
  String get voiceSystemFooter =>
      'O macOS e o iOS também podem isolar sua voz em todos os apps. Escolha Isolamento de Voz no modo de microfone do sistema.';

  @override
  String get voiceSystemMode =>
      'Modo de microfone do sistema (Isolamento de Voz)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Os modos de microfone exigem macOS 12 ou iOS 15 ou posterior.';

  @override
  String get voiceSpeechDetection => 'Detecção de fala';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent por cento';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Efeitos de áudio do Android';

  @override
  String get voiceAndroidFooter =>
      'O celular também pode tratar o microfone por conta própria. Isso é informado pelo Android e é separado da configuração acima.';

  @override
  String get voiceAndroidNs => 'Supressor de ruído';

  @override
  String get voiceAndroidAec => 'Cancelador de eco';

  @override
  String get voiceNotAvailableDevice => 'Não disponível neste dispositivo';

  @override
  String get callLinkNotLocal =>
      'Este tipo de link só pode ser usado a partir da linha de comandos deste computador.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Ligar ao dispositivo $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Um link de outra aplicação ou de uma página web quer ligar o SoftphonePro a este dispositivo. Ligue apenas se estiver à espera disto.';

  @override
  String get linkLanConnectAction => 'Ligar';

  @override
  String get linkImportSensitiveHeader =>
      'Alterações sensíveis nesta configuração:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Atende automaticamente as chamadas recebidas';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Reencaminha as chamadas para $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Altera quem pode iniciar um intercomunicador ou captar uma chamada (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Reescreve os números que marca';

  @override
  String get linkImportFlagLinksImmediately =>
      'As chamadas a partir de links web começam de imediato, sem confirmação';

  @override
  String get linkImportFlagDiagnostics =>
      'Ativa o registo detalhado ou o rastreio SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Permitir o atendimento automático nas contas importadas';

  @override
  String linkImportRefused(String setting) {
    return 'Esta importação tenta alterar \"$setting\", que nunca pode ser definido por ligação, código QR, texto colado ou ficheiro. Utilize antes a opção de linha de comandos --provision neste computador. Nada foi importado.';
  }

  @override
  String get lanPairIntercomNote =>
      'Os dispositivos emparelhados podem pedir uma chamada de intercomunicador; será perguntado antes de cada uma (altere em Definições > LAN).';

  @override
  String get callLinkUnsupportedScheme =>
      'Este tipo de ligação não é suportado.';

  @override
  String get linkImportFlagAutoRecord => 'Grava as chamadas automaticamente';

  @override
  String get linkImportFlagBlocklist =>
      'Altera a sua lista de bloqueio de chamadas';

  @override
  String get linkImportFlagEmergency => 'Altera os seus números de emergência';

  @override
  String get linkImportFlagSpeedDial => 'Define números de marcação rápida';

  @override
  String get linkImportFlagRecordingDelete =>
      'Elimina automaticamente as gravações antigas';

  @override
  String get linkImportFlagFeatureCodes =>
      'Marca códigos de funcionalidades PBX personalizados';

  @override
  String get linkImportAllowAutoRecord =>
      'Permitir a gravação automática de chamadas';

  @override
  String get importIgnoredHeader => 'Ignorado (não permitido em importações):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - servidor $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Proxies: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'Retransmissor TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Cabeçalhos SIP personalizados: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'ID do autor da chamada: $callerId';
  }

  @override
  String get importAccountSrtpOff =>
      'Sem cifragem de multimédia (SRTP desativado)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Endereço: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Atualizar $updated existentes, adicionar $added novas';
  }

  @override
  String get secretsKeyringLocked =>
      'Não foi possível abrir o seu chaveiro (bloqueado ou sem resposta), por isso não foi possível ler as palavras-passe guardadas. Desbloqueie-o e reinicie o SoftphonePro.';

  @override
  String get mixerTitle => 'Mesa de áudio';

  @override
  String get mixerMicrophone => 'Microfone';

  @override
  String get mixerSpeaker => 'Auscultadores e altifalante';

  @override
  String get mixerMicVolume => 'Volume do microfone';

  @override
  String get mixerSpeakerVolume => 'Volume do altifalante';

  @override
  String mixerMeterLabel(String name) {
    return 'Nível: $name';
  }

  @override
  String get mixerInputDevice => 'Dispositivo de entrada';

  @override
  String get mixerOutputDevice => 'Dispositivo de saída';

  @override
  String get mixerOutputRoute => 'Saída de áudio';

  @override
  String get mixerInputFollowsOutput =>
      'O microfone acompanha a saída de áudio selecionada.';

  @override
  String get mixerShowMore => 'Mostrar dispositivos e música de fundo';

  @override
  String get mixerShowLess => 'Mostrar menos controlos';

  @override
  String get mixerStripShow => 'Mostrar a mesa de áudio';

  @override
  String get mixerStripHide => 'Ocultar a mesa de áudio';

  @override
  String get musicbedTitle => 'Música de fundo';

  @override
  String get musicbedPlay => 'Reproduzir música de fundo';

  @override
  String get musicbedVolume => 'Volume da música de fundo';

  @override
  String get musicbedChooseFile => 'Escolher um ficheiro';

  @override
  String musicbedChangeFile(String name) {
    return 'Ficheiro da música de fundo: $name. Toque para alterar.';
  }

  @override
  String get musicbedHearIt => 'Ouvir também';

  @override
  String get musicbedMonitorVolume => 'Volume de monitorização';

  @override
  String get musicbedAddFile => 'Adicionar um ficheiro…';

  @override
  String get musicbedPickerTitle => 'Ficheiro da música de fundo';

  @override
  String get musicbedOn => 'Música de fundo ativa';

  @override
  String get musicbedPausedOnHold => 'Música de fundo em pausa (em espera)';

  @override
  String get musicbedOnTooltip =>
      'Um ficheiro de música está a ser reproduzido para todos nas suas chamadas.';

  @override
  String get musicbedFileMissing =>
      'O ficheiro da música de fundo já não está disponível, pelo que foi desativada.';

  @override
  String get musicbedNeedsFile =>
      'Escolha primeiro um ficheiro para a música de fundo.';

  @override
  String musicbedStopped(String message) {
    return 'Música de fundo parada: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Reproduz em ciclo um ficheiro de música por baixo da sua voz para todos nas suas chamadas, mesmo em silêncio. As chamadas em espera ouvem a música de espera.';

  @override
  String get musicbedSettingsFile => 'Ficheiro de música';

  @override
  String get linkImportFlagMusicbed => 'Reproduz música nas suas chamadas';

  @override
  String get musicbedMonitorIosHint =>
      'No iPhone, você a ouve durante as chamadas';

  @override
  String get musicbedStopFailed =>
      'Não foi possível parar a música. Ela pode ainda estar a tocar para os seus interlocutores.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languagePickerHint =>
      'Os nomes dos idiomas são exibidos no próprio idioma.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluir';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Renomear';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionDetails => 'Detalhes';

  @override
  String get actionMore => 'Mais';

  @override
  String get actionSettings => 'Ajustes';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionRefresh => 'Atualizar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionYes => 'Sim';

  @override
  String get actionNo => 'Não';

  @override
  String get commonOn => 'Ativado';

  @override
  String get commonOff => 'Desativado';

  @override
  String get commonNone => 'Nenhum';

  @override
  String get commonDefault => 'Padrão';

  @override
  String get commonSystem => 'Sistema';

  @override
  String get commonAutomatic => 'Automático';

  @override
  String get commonUnknown => 'Desconhecido';

  @override
  String get commonNotSet => 'Não definido';

  @override
  String get commonError => 'Erro';

  @override
  String get commonLoading => 'Carregando…';

  @override
  String get statusAvailable => 'Disponível';

  @override
  String get statusDoNotDisturb => 'Não perturbe';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOnACall => 'Em ligação';

  @override
  String get settingsEntryAccounts => 'Contas';

  @override
  String get settingsEntryAccountsSub => 'Contas SIP e registro';

  @override
  String get settingsEntryAudio => 'Áudio';

  @override
  String get settingsEntryAudioSub =>
      'Dispositivos, níveis, cancelamento de eco';

  @override
  String get settingsEntryCodecs => 'Codecs';

  @override
  String get settingsEntryCodecsSub => 'Ordem, disponibilidade, Opus';

  @override
  String get settingsEntryCalls => 'Ligações';

  @override
  String get settingsEntryCallsSub =>
      'Não perturbe, espera, atendimento automático, regras de discagem';

  @override
  String get settingsEntryNetwork => 'Rede';

  @override
  String get settingsEntryNetworkSub => 'Transportes, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Gravação';

  @override
  String get settingsEntryNotifications => 'Notificações e toques';

  @override
  String get settingsEntryShortcuts => 'Atalhos';

  @override
  String get settingsEntryShortcutsSub => 'Atalhos globais, teclas no app';

  @override
  String get settingsEntryAppearance => 'Aparência';

  @override
  String get settingsEntryPrivacy => 'Privacidade e segurança';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Provisionamento';

  @override
  String get settingsEntryProvisioningSub => 'Importar, exportar, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnóstico';

  @override
  String get settingsEntryDiagnosticsSub => 'Rastreamento SIP, testes de rede';

  @override
  String get settingsEntryAdvanced => 'Avançado';

  @override
  String get settingsEntryAbout => 'Sobre';

  @override
  String get settingsAccountsEmptyTitle => 'Adicione sua primeira conta';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Conecte-se ao seu PBX ou provedor SIP para começar a ligar.';

  @override
  String get settingsAccountsAdd => 'Adicionar conta';

  @override
  String get settingsAccountsYourAccounts => 'Suas contas';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  usando servidor de backup';
  }

  @override
  String get settingsAudioDevices => 'Dispositivos';

  @override
  String get settingsAudioMicrophone => 'Microfone';

  @override
  String get settingsAudioSpeaker => 'Alto-falante';

  @override
  String get settingsAudioRinger => 'Campainha';

  @override
  String get settingsAudioRingerSub =>
      'Tocar o toque em um dispositivo separado';

  @override
  String get settingsAudioRefreshDevices => 'Atualizar dispositivos';

  @override
  String get settingsAudioLevelsAndTest => 'Níveis e teste';

  @override
  String get settingsAudioMicVolume => 'Volume do microfone';

  @override
  String get settingsAudioMicLevel => 'Nível do microfone';

  @override
  String get settingsAudioSpeakerVolume => 'Volume do alto-falante';

  @override
  String get settingsAudioSpeakerLevel => 'Nível do alto-falante';

  @override
  String get settingsAudioTestSpeaker => 'Testar alto-falante';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Reproduz um tom curto no alto-falante selecionado';

  @override
  String get settingsAudioTestToneFailed =>
      'Não foi possível reproduzir o tom de teste';

  @override
  String get settingsAudioEchoTestFailed => 'Falha no teste de eco';

  @override
  String get settingsAudioEchoTest => 'Teste de eco';

  @override
  String get settingsAudioEchoTestSub =>
      'Reproduz o áudio do seu microfone no alto-falante. Use fones de ouvido para evitar microfonia.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voz e arquivos';

  @override
  String get settingsAudioVoiceIsolation =>
      'Isolamento de voz (cancelamento de ruído por IA)';

  @override
  String get settingsAudioAudioFiles => 'Arquivos de áudio';

  @override
  String get settingsAudioAudioFilesSub => 'Música de espera e avisos';

  @override
  String get settingsAudioProcessing => 'Processamento';

  @override
  String get settingsAudioEchoCancellation => 'Cancelamento de eco';

  @override
  String get settingsAudioEcSimple => 'Simples';

  @override
  String get settingsAudioEcPlatform => 'Plataforma';

  @override
  String get settingsAudioEchoTail => 'Cauda de eco';

  @override
  String get settingsAudioNoiseSuppression => 'Supressão de ruído';

  @override
  String get settingsAudioAgc => 'Controle automático de ganho';

  @override
  String get settingsAudioVad => 'Detecção de atividade de voz';

  @override
  String get settingsAudioVadSub => 'Economiza banda durante o silêncio';

  @override
  String get settingsAudioAdvanced => 'Avançado';

  @override
  String get settingsAudioAdvancedFooter =>
      'Os valores do jitter buffer são em milissegundos; -1 usa o padrão do mecanismo. Alterá-los reinicia o mecanismo de ligações.';

  @override
  String get settingsAudioPtime => 'Tempo de pacote (ptime)';

  @override
  String get settingsAudioJbInitial => 'Jitter buffer: inicial';

  @override
  String get settingsAudioJbMinPrefetch => 'Jitter buffer: pré-busca mínima';

  @override
  String get settingsAudioJbMaxPrefetch => 'Jitter buffer: pré-busca máxima';

  @override
  String get settingsAudioJbMaxSize => 'Jitter buffer: tamanho máximo';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Microfone $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Outros $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent por cento';
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
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get settingsCodecsOrder => 'Ordem e disponibilidade';

  @override
  String get settingsCodecsDragHint =>
      'Arraste para reordenar. As contas podem substituir esta lista em suas próprias configurações.';

  @override
  String get settingsCodecsBitrate => 'Taxa de bits';

  @override
  String get settingsCodecsFec => 'FEC in-band';

  @override
  String get settingsCodecsFecSub => 'Recupera perdas de pacotes';

  @override
  String get settingsCodecsDtxSub => 'Parar de enviar durante o silêncio';

  @override
  String get settingsCodecsCbr => 'Taxa de bits constante';

  @override
  String get settingsCodecsComplexity => 'Complexidade';

  @override
  String get settingsCallsIncoming => 'Recebidas';

  @override
  String get settingsCallsDndSub => 'Rejeitar todas as ligações recebidas';

  @override
  String get settingsCallsRejectWith => 'Rejeitar com';

  @override
  String get settingsCallsReasonBusy => 'Ocupado (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Temporariamente indisponível (480)';

  @override
  String get settingsCallsReasonDecline => 'Recusar (603)';

  @override
  String get settingsCallsWaiting => 'Chamada em espera';

  @override
  String get settingsCallsWaitingSub =>
      'Permitir uma segunda ligação recebida durante uma ligação';

  @override
  String get settingsCallsWhenBusy =>
      'Quando ocupado e a chamada em espera estiver desativada';

  @override
  String get settingsCallsRejectAnonymous => 'Rejeitar ligações anônimas';

  @override
  String get settingsCallsLinksImmediately => 'Ligar imediatamente por links';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Links tel:, sip: e callto: fazem a ligação sem esperar no discador';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Sincronizar Não perturbe / desvio com o PBX por códigos de recurso';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Disca brevemente os códigos de asterisco da conta (por exemplo *78) ao alterar Não perturbe ou o desvio';

  @override
  String get settingsCallsAutoAnswerGroup => 'Atendimento automático';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'O desvio de ligações e o atendimento automático por conta são definidos em cada conta.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Atender todas as ligações automaticamente';

  @override
  String get settingsCallsAnswerAfter => 'Atender após';

  @override
  String get settingsCallsAnswerImmediately => 'Imediatamente';

  @override
  String get settingsCallsIntercomHeaders =>
      'Respeitar cabeçalhos de interfone';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Indicações de atendimento automático em Call-Info, Alert-Info e Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Números bloqueados';

  @override
  String get settingsCallsBlockNumber => 'Bloquear um número';

  @override
  String get settingsCallsBlockNumberTitle => 'Bloquear número';

  @override
  String get settingsCallsBlockNumberHint => 'Número ou endereço SIP';

  @override
  String get settingsCallsSpeedDial => 'Discagem rápida';

  @override
  String get settingsCallsDialPlan => 'Plano de discagem';

  @override
  String get settingsCallsDialRules => 'Regras de discagem';

  @override
  String get settingsCallsStripPrefix => 'Prefixo de linha externa a remover';

  @override
  String get settingsCallsStripPrefixSub =>
      'Por exemplo 9, removido do início dos números discados';

  @override
  String get settingsCallsPlusReplacement => 'Substituir + inicial por';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Por exemplo 00 para acesso internacional';

  @override
  String get settingsCallsPlusReplacementHint => 'Manter +';

  @override
  String get settingsCallsCountryPrefix => 'Prefixo de país padrão';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Números nacionais que começam com 0 recebem este prefixo, por exemplo +55';

  @override
  String get settingsCallsEmergency => 'Números de emergência';

  @override
  String get settingsCallsEmergencySub =>
      'Separados por vírgula. Ignoram as regras de discagem.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Desbloquear $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count de 9 atribuídos';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regras',
      one: '1 regra',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nova regra de discagem';

  @override
  String get settingsDialRulesEdit => 'Editar regra de discagem';

  @override
  String get settingsDialRulesName => 'Nome';

  @override
  String get settingsDialRulesPattern => 'Padrão (regex)';

  @override
  String get settingsDialRulesReplacement => 'Substituição';

  @override
  String get settingsDialRulesReplacementHelp => 'Use \$1, \$2 para grupos';

  @override
  String get settingsDialRulesRoute => 'Encaminhar pela conta';

  @override
  String get settingsDialRulesAdd => 'Adicionar regra';

  @override
  String get settingsDialRulesLiveTest => 'Teste ao vivo';

  @override
  String get settingsDialRulesTyped => 'Número digitado';

  @override
  String get settingsDialRulesNothing => '(nada)';

  @override
  String get settingsDialRulesEmergency =>
      'Número de emergência: discado como digitado';

  @override
  String get settingsDialRulesAccountFallback => 'conta';

  @override
  String get settingsDialRulesEmpty =>
      'Nenhuma regra. Os números são limpos (espaços, hifens e parênteses removidos) e discados como digitados. As regras são aplicadas de cima para baixo; vale a primeira correspondência.';

  @override
  String get settingsDialRulesDelete => 'Excluir regra';

  @override
  String get settingsDialRulesDeleteTitle => 'Excluir regra?';

  @override
  String settingsDialRulesVia(String account) {
    return 'via $account';
  }

  @override
  String get settingsNetworkTransports => 'Transportes';

  @override
  String get settingsNetworkTransportsFooter =>
      'A porta 0 escolhe uma porta livre aleatória. Alterar os transportes reinicia o mecanismo de ligações.';

  @override
  String get settingsNetworkUdpPort => 'Porta UDP';

  @override
  String get settingsNetworkTcpPort => 'Porta TCP';

  @override
  String get settingsNetworkTlsPort => 'Porta TLS';

  @override
  String get settingsNetworkVerifyCerts => 'Verificar certificados do servidor';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Desative apenas para PBXs com certificado autoassinado, ou fixe o certificado abaixo';

  @override
  String get settingsNetworkCustomCa => 'Arquivo de CA personalizado';

  @override
  String get settingsNetworkCustomCaSub =>
      'Pacote PEM usado no lugar da lista integrada (CA de PBX privado)';

  @override
  String get settingsNetworkCustomCaHint => 'Lista integrada da Mozilla';

  @override
  String get settingsNetworkPins => 'Certificados fixados';

  @override
  String get settingsNetworkPinsSub =>
      'host=impressão digital SHA256, separados por vírgula';

  @override
  String get settingsNetworkNat => 'Travessia de NAT';

  @override
  String get settingsNetworkStun => 'Servidores STUN';

  @override
  String get settingsNetworkStunSub => 'host:porta, separados por vírgula';

  @override
  String get settingsNetworkIceTurn => 'ICE e TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Configurados por conta em NAT';

  @override
  String get settingsNetworkAdvanced => 'Avançado';

  @override
  String get settingsNetworkQos => 'QoS (marcação DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Marcar pacotes SIP e de voz como prioritários';

  @override
  String get settingsNetworkDns => 'Servidores DNS';

  @override
  String get settingsNetworkDnsSub => 'Deixe em branco para automático';

  @override
  String get settingsNetworkRtpStart => 'Porta RTP inicial';

  @override
  String get settingsNetworkRtpRange => 'Intervalo de portas RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 usa o padrão';

  @override
  String get settingsNotifRingtone => 'Toque';

  @override
  String get settingsNotifDefaultRingtone => 'Toque padrão';

  @override
  String get settingsNotifProgressTones => 'Tons de progresso da ligação';

  @override
  String get settingsNotifProgressTonesSub =>
      'Tons de chamando, ocupado e congestionamento durante a discagem';

  @override
  String get settingsNotifRingerVolume => 'Volume da campainha';

  @override
  String get settingsNotifCustomRingtone => 'Arquivo de toque personalizado';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Caminho de um arquivo WAV (desktop)';

  @override
  String get settingsNotifGroup => 'Notificações';

  @override
  String get settingsNotifRequestPermissions => 'Solicitar permissões';

  @override
  String get settingsNotifRequestPermissionsSub => 'Microfone e notificações';

  @override
  String get settingsNotifTyping => 'Enviar indicadores de digitação';

  @override
  String get settingsAppearanceTheme => 'Tema';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Escuro';

  @override
  String get settingsAppearanceAccent => 'Cor de destaque';

  @override
  String get settingsAppearanceAccentOption => 'Opção de cor de destaque';

  @override
  String get settingsAppearanceCompact => 'Densidade compacta';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Microfone: $microphone, notificações: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Segurança';

  @override
  String get settingsPrivacyPasswords => 'Senhas';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Armazenadas no chaveiro / keystore do sistema (com arquivo criptografado como alternativa)';

  @override
  String get settingsPrivacyGroup => 'Privacidade';

  @override
  String get settingsPrivacyNoTelemetry => 'Sem telemetria';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'O SoftphonePro não envia dados de análise. O tráfego de rede vai apenas para os seus servidores SIP.';

  @override
  String get settingsPrivacyYourData => 'Seus dados';

  @override
  String get settingsPrivacyClearHistory => 'Limpar histórico de ligações';

  @override
  String get settingsPrivacyDeleteContacts => 'Excluir todos os contatos';

  @override
  String get settingsPrivacyDeleteMessages => 'Excluir todas as mensagens';

  @override
  String get settingsPrivacyConfirmHistory =>
      'Excluir o histórico de ligações?';

  @override
  String get settingsPrivacyConfirmContacts => 'Excluir todos os contatos?';

  @override
  String get settingsPrivacyConfirmMessages => 'Excluir todas as mensagens?';

  @override
  String get settingsPrivacyCannotUndo => 'Esta ação não pode ser desfeita.';

  @override
  String get settingsPrivacyDeletedHistory => 'Histórico de ligações excluído';

  @override
  String get settingsPrivacyDeletedContacts =>
      'Todos os contatos foram excluídos';

  @override
  String get settingsPrivacyDeletedMessages =>
      'Todas as mensagens foram excluídas';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Os dispositivos na mesma rede se encontram, são pareados com um código de 6 dígitos e conversam diretamente, sem nenhum servidor.';

  @override
  String get settingsLanEnable => 'Ativar LAN Link';

  @override
  String get settingsLanDeviceName => 'Nome do dispositivo';

  @override
  String get settingsLanDeviceNameHint => 'Este dispositivo';

  @override
  String get settingsLanAllowIntercom => 'Permitir interfone';

  @override
  String get settingsLanAllowIntercomSub =>
      'Permite que dispositivos pareados liguem para você e sejam atendidos automaticamente';

  @override
  String get settingsLanAskIntercom =>
      'Perguntar antes de permitir o interfone';

  @override
  String get settingsLanAskIntercomSub =>
      'Caso contrário, os dispositivos pareados são atendidos automaticamente por 30 s após solicitarem';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Aceitar automaticamente arquivos de dispositivos pareados';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Caso contrário, você será consultado a cada arquivo';

  @override
  String get settingsLanAllowPull =>
      'Permitir que dispositivos pareados puxem minhas ligações';

  @override
  String get settingsLanAllowPullSub =>
      'Um dispositivo pareado pode assumir uma ligação ativa aqui';

  @override
  String get settingsLanDownloads => 'Pasta de downloads';

  @override
  String get settingsLanDownloadsHint => 'Padrão (Downloads/SoftphonePro)';

  @override
  String get settingsLanPort => 'Porta do link';

  @override
  String get settingsLanSharedAccounts =>
      'Contas compartilhadas com dispositivos pareados';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Compartilhar uma conta registrada permite que um dispositivo pareado no mesmo servidor receba suas ligações diretamente (transferência de ligação), em vez de retransmiti-las.';

  @override
  String get settingsAdvEngine => 'Mecanismo';

  @override
  String get settingsAdvSimulator => 'Usar simulador';

  @override
  String get settingsAdvSimulatorSub =>
      'Executa sem o mecanismo nativo. As ligações são simuladas.';

  @override
  String get settingsAdvLogLevel => 'Nível de log';

  @override
  String get settingsAdvLogErrors => 'Erros';

  @override
  String get settingsAdvLogInfo => 'Informações';

  @override
  String get settingsAdvLogDebug => 'Depuração';

  @override
  String get settingsAdvLogVerbose => 'Detalhado';

  @override
  String get settingsAdvSipTrace => 'Rastreamento SIP';

  @override
  String get settingsAdvRestartEngine => 'Reiniciar mecanismo';

  @override
  String get settingsAdvDesktop => 'Desktop';

  @override
  String get settingsAdvStartAtLogin => 'Iniciar com o sistema';

  @override
  String get settingsAdvCloseToTray => 'Fechar para a bandeja';

  @override
  String get settingsAdvCloseToTraySub =>
      'Ao fechar a janela, o SoftphonePro continua em execução para que as ligações ainda toquem. Saia pelo ícone da bandeja / barra de menus.';

  @override
  String get settingsAboutLicence => 'Licença';

  @override
  String get settingsAboutLicenceFooter =>
      'O SoftphonePro é software livre: você pode redistribuí-lo e/ou modificá-lo sob os termos da Licença Pública Geral GNU, publicada pela Free Software Foundation, versão 3 ou posterior. Ele é distribuído SEM QUALQUER GARANTIA.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 ou posterior';

  @override
  String get settingsAboutGplSub =>
      'Código-fonte disponível no repositório do projeto';

  @override
  String get settingsAboutThirdParty => 'Avisos de terceiros';

  @override
  String get settingsAboutPackages => 'Pacotes Flutter e Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD 3-clause, MIT e Apache 2.0. Veja a página de licenças.';

  @override
  String settingsAboutVersion(String version) {
    return 'Versão $version';
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
    return '$license. $purpose. Versão $version.';
  }

  @override
  String get updatesChecking => 'Verificando...';

  @override
  String updatesAvailable(String version) {
    return 'O SoftphonePro $version está disponível';
  }

  @override
  String get updatesUpToDate => 'Você está com a versão mais recente';

  @override
  String get updatesCouldNotCheck => 'Não foi possível verificar';

  @override
  String get updatesNotCheckedYet => 'Ainda não verificado';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última verificação: $dateString';
  }

  @override
  String get updatesTitle => 'Atualizações';

  @override
  String get updatesFooter =>
      'A verificação contata apenas api.github.com (uma vez por semana) e não envia nada além da própria requisição: nenhum identificador, nem dados de conta ou de ligações. O SoftphonePro nunca baixa nem instala nada por conta própria.';

  @override
  String get updatesCheckSwitch => 'Verificar atualizações';

  @override
  String get updatesCheckNow => 'Verificar agora';

  @override
  String updatesSkippingVersion(String version) {
    return 'Ignorando a versão $version';
  }

  @override
  String get updatesStopSkipping => 'Parar de ignorar';

  @override
  String get updatesReleaseNotes => 'Notas da versão';

  @override
  String get updatesDownload => 'Baixar';

  @override
  String get updatesSkipVersion => 'Ignorar esta versão';

  @override
  String get updatesDismiss => 'Dispensar';

  @override
  String get updatesRateLimited =>
      'Limite de requisições do GitHub atingido, tente novamente mais tarde';

  @override
  String updatesServerAnswered(int status) {
    return 'O GitHub respondeu $status';
  }

  @override
  String get updatesUnexpectedReply => 'Resposta inesperada';

  @override
  String get updatesTimedOut => 'Tempo esgotado';

  @override
  String get updatesAlreadyChecking => 'Já está verificando';

  @override
  String get encryptionTitle => 'Criptografia';

  @override
  String get encryptionFooter =>
      'Criptografa o banco de dados local com AES-256-GCM. A chave fica no chaveiro / keystore do sistema; se for perdida, os dados não poderão ser recuperados. As gravações de ligações e os arquivos exportados não são criptografados. A alteração entra em vigor na próxima vez que o SoftphonePro for iniciado (feche-o completamente antes); o arquivo anterior é sobrescrito e excluído assim que o novo banco de dados for aberto e verificado.';

  @override
  String get encryptionSwitchTitle =>
      'Criptografar histórico de ligações, contatos e mensagens neste dispositivo';

  @override
  String get encryptionWillEncrypt =>
      'Será criptografado na próxima inicialização';

  @override
  String get encryptionWillDecrypt =>
      'Será descriptografado na próxima inicialização';

  @override
  String get encryptionRestartToEncrypt =>
      'Feche e reinicie o SoftphonePro para criptografar seus dados.';

  @override
  String get encryptionRestartToDecrypt =>
      'Feche e reinicie o SoftphonePro para descriptografar seus dados.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Discagem rápida $slot';
  }

  @override
  String get speedDialNumberLabel => 'Número ou endereço SIP';

  @override
  String get speedDialLabelOptional => 'Rótulo (opcional)';

  @override
  String get speedDialCallFrom => 'Ligar de';

  @override
  String get speedDialSelectedAccount => 'Conta selecionada';

  @override
  String get speedDialTitle => 'Discagem rápida';

  @override
  String get speedDialHint =>
      'Mantenha pressionado um dígito (1-9) no teclado vazio para ligar para o número correspondente.';

  @override
  String get speedDialNotAssigned => 'Não atribuído';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON inválido: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Era esperado um objeto JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Versão de configuração $version não compatível';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Uma entrada de conta que não é objeto foi ignorada';

  @override
  String get provisioningNothingToImport =>
      'O arquivo não contém contas nem ajustes';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'A conta \"$name\" precisa de usuário e domínio';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'O servidor respondeu $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'Não foi possível baixar a configuração: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'Não foi possível ler $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas importadas',
      one: '1 conta importada',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Importar configuração';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts contas',
      one: '1 conta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      settings,
      locale: localeName,
      other: '$settings ajustes',
      one: '1 ajuste',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get provisioningImportFromUrlTitle => 'Importar de URL ou JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... ou cole o JSON';

  @override
  String get provisioningInvalidSource =>
      'Isso não é uma URL, link ou JSON válido';

  @override
  String get provisioningScanTitle => 'Ler QR de provisionamento';

  @override
  String get provisioningPasteHint => 'Cole um JSON, link ou URL';

  @override
  String get provisioningImportGroup => 'Importar';

  @override
  String get provisioningImportFooter =>
      'Aceita JSON com contas e ajustes. Os marcadores \${VAR} são preenchidos com valores vazios, a menos que um padrão seja informado como \${VAR:-padrão}.';

  @override
  String get provisioningScanQr => 'Ler código QR';

  @override
  String get provisioningFromUrl => 'De URL ou JSON colado';

  @override
  String get provisioningFromFile => 'De arquivo';

  @override
  String get provisioningFromClipboard => 'Da área de transferência';

  @override
  String get provisioningExportGroup => 'Exportar';

  @override
  String get provisioningIncludePasswords => 'Incluir senhas';

  @override
  String get provisioningIncludePasswordsHint =>
      'Qualquer pessoa com o arquivo pode usar suas contas';

  @override
  String get provisioningCopyConfig => 'Copiar configuração (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuração copiada';

  @override
  String get provisioningQrGroup => 'Código QR';

  @override
  String get provisioningQrFooter =>
      'Leia este código em outro dispositivo para copiar uma conta. Trate-o como uma senha se ele incluir uma.';

  @override
  String get provisioningQrAccount => 'Conta';

  @override
  String get provisioningChoose => 'Escolher...';

  @override
  String get provisioningQrTooMuchData => 'Dados demais para um código QR';

  @override
  String tlsClearField(String field) {
    return 'Limpar $field';
  }

  @override
  String get tlsChoose => 'Escolher...';

  @override
  String get tlsChange => 'Alterar...';

  @override
  String get tlsClientCertTitle => 'Certificado de cliente (TLS mútuo)';

  @override
  String get tlsIncomplete =>
      'Escolha um certificado e a respectiva chave privada. O certificado só é apresentado quando ambos estão definidos.';

  @override
  String get tlsFooter =>
      'Para servidores que pedem ao app que se identifique com um certificado. Arquivos PEM. Usado para TLS e WebSocket seguro.';

  @override
  String get tlsCertFile => 'Arquivo de certificado';

  @override
  String get tlsKeyFile => 'Arquivo de chave privada';

  @override
  String get tlsKeyPassword => 'Senha da chave';

  @override
  String get tlsKeyPasswordHint => 'Somente se a chave for criptografada';

  @override
  String get callSettingsHoldGroupTitle => 'Espera';

  @override
  String get callSettingsHoldFooter =>
      'Com \"Padrão do PBX\", a ligação é simplesmente colocada em espera e o seu sistema telefônico pode tocar a própria música. Qualquer outra escolha é reproduzida para quem ligou por este app.';

  @override
  String get callSettingsHoldMusic => 'Música de espera';

  @override
  String get callSettingsHoldPbxDefault => 'Padrão do PBX';

  @override
  String get callSettingsHoldMusicVolume => 'Volume da música de espera';

  @override
  String get callSettingsHoldAudioFiles => 'Arquivos de áudio';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Importe ou grave músicas de espera';

  @override
  String get callSettingsAnnounceTitle => 'Avisos';

  @override
  String get callSettingsAnnounceFooter =>
      'Os avisos são reproduzidos para a outra pessoa. Tudo é ignorado silenciosamente se o arquivo estiver ausente.';

  @override
  String get callSettingsAnnounceOpening => 'Aviso de abertura';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Reproduzir uma mensagem quando a ligação for conectada';

  @override
  String get callSettingsAnnounceFile => 'Arquivo do aviso';

  @override
  String get callSettingsAnnounceChooseFile => 'Escolha um arquivo';

  @override
  String get callSettingsAnnouncePlayFor => 'Reproduzir em';

  @override
  String get callSettingsAnnounceBoth => 'Recebidas e realizadas';

  @override
  String get callSettingsAnnounceIncoming => 'Ligações recebidas';

  @override
  String get callSettingsAnnounceOutgoing => 'Ligações realizadas';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Silenciar meu microfone durante a reprodução';

  @override
  String get callSettingsAnnounceMonitor => 'Também ouvir o aviso';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Antes de iniciar a gravação, reproduzir';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Antes de transferir quem ligou, reproduzir';

  @override
  String get morePageTitle => 'Mais';

  @override
  String get morePresence => 'Presença';

  @override
  String get morePresenceHint => 'Campo de lâmpada ocupada';

  @override
  String get moreRetrieveParked => 'Recuperar ligação estacionada';

  @override
  String get moreRetrieveParkedHint => 'Disque uma vaga de estacionamento';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint =>
      'Dispositivos próximos, chat e envio de arquivos';

  @override
  String get moreRecordings => 'Gravações';

  @override
  String get moreRecordingsHint =>
      'Ouça, compartilhe e gerencie gravações de ligações';

  @override
  String get moreVoicemail => 'Caixa postal';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens novas',
      one: '1 mensagem nova',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Ligar para sua caixa postal';

  @override
  String get moreDiagnostics => 'Diagnóstico';

  @override
  String get moreDiagnosticsHint => 'Rastreamento SIP e testes de rede';

  @override
  String get moreAbout => 'Sobre';

  @override
  String get moreNoVoicemailNumber =>
      'Nenhum número de caixa postal definido. Adicione um nas configurações da conta.';

  @override
  String get moreSearchHint => 'Busque contatos, histórico ou digite um número';

  @override
  String moreCallNumber(String number) {
    return 'Ligar para $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Bloqueio do app';

  @override
  String get appLockFooter =>
      'As ligações continuam tocando e podem ser atendidas com o app bloqueado.';

  @override
  String get appLockRequirePin => 'Exigir PIN para abrir o app';

  @override
  String get appLockOnHint =>
      'Histórico, contatos, mensagens e ajustes ficam bloqueados';

  @override
  String get appLockIsOn => 'Bloqueio do app ativado';

  @override
  String get appLockIsOff => 'Bloqueio do app desativado';

  @override
  String get appLockTurnOff => 'Desativar bloqueio do app';

  @override
  String get appLockChangePin => 'Alterar PIN';

  @override
  String get appLockEnterCurrent => 'Digite o PIN atual';

  @override
  String get appLockPinChanged => 'PIN alterado';

  @override
  String get appLockLockAfter => 'Bloquear após';

  @override
  String get appLockLockAfterHint =>
      'Tempo em segundo plano antes de o PIN ser exigido novamente';

  @override
  String get appLockImmediately => 'Imediatamente';

  @override
  String appLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get appLockHour => '1 hora';

  @override
  String get appLockBiometrics => 'Desbloquear com biometria';

  @override
  String get appLockNow => 'Bloquear agora';

  @override
  String get appLockSetPin => 'Definir um PIN';

  @override
  String get appLockPinDigits => 'PIN (4 a 8 dígitos)';

  @override
  String get appLockRepeatPin => 'Repita o PIN';

  @override
  String get appLockUseDigits => 'Use de 4 a 8 dígitos';

  @override
  String get appLockMismatch => 'Os PINs não coincidem';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Muitas tentativas. Tente novamente em ${seconds}s';
  }

  @override
  String get appLockWrongPin => 'PIN incorreto';

  @override
  String get appLockTooMany => 'Muitas tentativas';

  @override
  String get appLockIsLocked => 'O SoftphonePro está bloqueado';

  @override
  String get appLockEnterPin => 'Digite seu PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Tente novamente em $time';
  }

  @override
  String appLockDurationMinSec(int minutes, int seconds) {
    return '${minutes}min ${seconds}s';
  }

  @override
  String appLockDurationSec(int seconds) {
    return '${seconds}s';
  }

  @override
  String get appLockUnlock => 'Desbloquear';

  @override
  String get appLockIncomingCall => 'Ligação recebida';

  @override
  String get appLockDecline => 'Recusar';

  @override
  String get appLockAnswer => 'Atender';

  @override
  String get appLockHangUp => 'Desligar';

  @override
  String get appLockBiometricReason => 'Desbloquear o SoftphonePro';

  @override
  String get automationNoToken =>
      'Nenhum token de acesso definido. Gere um em Ajustes > Avançado.';

  @override
  String automationInvalidPort(int port) {
    return 'Porta $port inválida';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'Não foi possível iniciar: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'A porta $port não está disponível ($error). Escolha outra porta.';
  }

  @override
  String get automationTokenPlaceholder => 'Criado quando você ativa a API';

  @override
  String automationListening(String address) {
    return 'Escutando em $address';
  }

  @override
  String get automationStarting => 'Iniciando...';

  @override
  String get automationTitle => 'API de automação local';

  @override
  String get automationFooter =>
      'Para integrações de CRM e helpdesk neste computador. Ela escuta apenas em 127.0.0.1 e toda requisição precisa do token de acesso. Veja docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Ativar API de automação local';

  @override
  String get automationPort => 'Porta';

  @override
  String get automationPortHint =>
      'Padrão 7771. Escolha uma porta livre entre 1024 e 65535.';

  @override
  String get automationPortInvalid => 'Digite uma porta de 1024 a 65535';

  @override
  String get automationAccessToken => 'Token de acesso';

  @override
  String get automationHideToken => 'Ocultar token';

  @override
  String get automationShowToken => 'Mostrar token';

  @override
  String get automationCopyToken => 'Copiar token';

  @override
  String get automationTokenCopied => 'Token copiado';

  @override
  String get automationGenerateToken => 'Gerar um novo token';

  @override
  String get automationGenerateTitle => 'Gerar um novo token?';

  @override
  String get automationGenerateBody =>
      'Os programas que usam o token antigo deixam de funcionar até que você informe o novo.';

  @override
  String get automationGenerate => 'Gerar';

  @override
  String get automationOrigins => 'Origens de navegador permitidas';

  @override
  String get automationOriginsHint =>
      'Separadas por vírgula, por exemplo https://crm.example.com. Programas sem navegador (curl, scripts) não precisam disto.';

  @override
  String automationNotOrigin(String origin) {
    return 'Não é uma origem http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'Atender';

  @override
  String get trayNotificationDecline => 'Recusar';

  @override
  String get trayTooltipInCall => 'SoftphonePro - em ligação';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nova(s)';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - sem contas (Ausente)',
      'dnd': 'SoftphonePro - sem contas (Não perturbe)',
      'other': 'SoftphonePro - sem contas',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total online (Ausente)',
      'dnd': 'SoftphonePro - $online/$total online (Não perturbe)',
      'other': 'SoftphonePro - $online/$total online',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Ocultar o SoftphonePro';

  @override
  String get trayShowApp => 'Mostrar o SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nova(s) - abrir Recentes';
  }

  @override
  String get trayStatus => 'Status';

  @override
  String get trayStatusAway => 'Ausente';

  @override
  String get trayAccounts => 'Contas';

  @override
  String get trayQuit => 'Sair do SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Atender ligação';

  @override
  String get hotkeyHangUp => 'Desligar';

  @override
  String get hotkeyMute => 'Silenciar / reativar som';

  @override
  String get hotkeyFocusDialer => 'Focar no discador';

  @override
  String get shortcutsGlobalTitle => 'Atalhos globais';

  @override
  String get shortcutsGlobalFooter =>
      'Funcionam em qualquer aplicativo. Outro programa que já use uma combinação pode impedir que ela seja registrada.';

  @override
  String get shortcutsChange => 'Alterar';

  @override
  String get shortcutsRestoreDefaults => 'Restaurar padrões';

  @override
  String get shortcutsMediaTitle => 'Fones e teclas de mídia';

  @override
  String get shortcutsMediaFooter =>
      'O botão de reproduzir/pausar de um fone ou teclado só é capturado enquanto uma ligação toca ou está ativa; no restante do tempo ele continua com os players de música.';

  @override
  String get shortcutsMediaSwitch =>
      'Atender e desligar com o botão de reproduzir/pausar do fone ou de mídia';

  @override
  String get shortcutsMediaDuringCall => 'Durante uma ligação, o botão';

  @override
  String get shortcutsMediaHangsUp => 'Desliga';

  @override
  String get shortcutsMediaMutes => 'Silencia / reativa o som';

  @override
  String get shortcutsInApp => 'No app';

  @override
  String get shortcutsFocusDialer => 'Focar no discador';

  @override
  String get shortcutsHoldResume => 'Espera / retomar';

  @override
  String get shortcutsTransfer => 'Transferir';

  @override
  String get shortcutsEndCall => 'Encerrar ligação';

  @override
  String get shortcutsNeedX11 =>
      'Os atalhos globais exigem uma sessão X11. O Wayland não permite que aplicativos capturem teclas em todo o sistema.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Adicione Ctrl, Alt, Shift ou $key a uma letra ou dígito';
  }

  @override
  String get shortcutsPressNew => 'Pressione a nova combinação de teclas';

  @override
  String get defaultHandlerChooseInSettings =>
      'Escolha o SoftphonePro para SIP, TEL e CALLTO em Aplicativos padrão';

  @override
  String get defaultHandlerNowOpens =>
      'O SoftphonePro agora abre links sip:, tel: e callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'Não foi possível alterar o padrão para $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Abre links sip:, tel: e callto: de navegadores e outros apps';

  @override
  String get defaultHandlerIsSelf =>
      'O SoftphonePro trata links sip:, tel: e callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Agora: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Tornar o SoftphonePro o app padrão para links sip:, tel: e callto:';

  @override
  String get reliabilityTitle => 'Confiabilidade em segundo plano';

  @override
  String get reliabilityMicrophone => 'Microfone';

  @override
  String get reliabilityAllowed => 'Permitido';

  @override
  String get reliabilityMicNeeded => 'Necessário para falar nas ligações';

  @override
  String get reliabilityNotifications => 'Notificações';

  @override
  String get reliabilityNotifNeeded =>
      'Necessárias para exibir ligações recebidas e manter o serviço visível';

  @override
  String get reliabilityFullScreen => 'Ligações recebidas em tela cheia';

  @override
  String get reliabilityFullScreenNeeded =>
      'Permita para que as ligações apareçam sobre a tela de bloqueio';

  @override
  String get reliabilityBattery => 'Uso irrestrito da bateria';

  @override
  String get reliabilityBatteryExempt => 'Isento da otimização de bateria';

  @override
  String get reliabilityBatteryNeeded =>
      'O Android pode suspender o app e perder ligações para economizar energia. Toque para isentar o SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'Início automático / apps protegidos de $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'O fabricante do seu celular pode encerrar apps em segundo plano. Permita que o SoftphonePro inicie automaticamente.';

  @override
  String get reliabilityBoot => 'Iniciar com o dispositivo';

  @override
  String get reliabilityBootHint =>
      'Registrar as contas após o celular reiniciar';

  @override
  String get reliabilityWake => 'Manter a CPU ativa em repouso';

  @override
  String get reliabilityWakeHint =>
      'Mais confiável em dispositivos restritivos; consome mais bateria';

  @override
  String acctEditorDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Remover $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Último erro: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Intervalo permitido: $min a $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Deve ser no mínimo $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Deve ser no máximo $max';
  }

  @override
  String get acctEditorDiscardTitle => 'Descartar alterações?';

  @override
  String get acctEditorDiscardMessage =>
      'Suas edições nesta conta não foram salvas.';

  @override
  String get acctEditorDiscardConfirm => 'Descartar';

  @override
  String get acctEditorDeleteMessage =>
      'A conta e a senha salva serão removidas deste dispositivo.';

  @override
  String get acctEditorMenuDelete => 'Excluir conta';

  @override
  String get acctGroupBasic => 'Básico';

  @override
  String get acctFieldLabel => 'Rótulo';

  @override
  String get acctFieldLabelHint => 'ex.: Escritório';

  @override
  String get acctFieldDisplayName => 'Nome de exibição';

  @override
  String get acctFieldUsername => 'Usuário';

  @override
  String get acctFieldProtocol => 'Protocolo';

  @override
  String get acctFieldProtocolSub => 'Definido na criação da conta';

  @override
  String get acctFieldAuthUser => 'Usuário de autorização';

  @override
  String get acctFieldAuthUserHint => 'Igual ao usuário';

  @override
  String get acctFieldAuthUserSub =>
      'Somente se o provedor usar um nome de login diferente do usuário';

  @override
  String get acctFieldPassword => 'Senha';

  @override
  String get acctFieldServerHost => 'Host do servidor';

  @override
  String get acctFieldPort => 'Porta';

  @override
  String get acctFieldIaxPortSub => 'O padrão do IAX2 é 4569';

  @override
  String get acctFieldIaxContext => 'Contexto';

  @override
  String get acctFieldIaxContextSub =>
      'Opcional. Enviado ao PBX como o contexto chamado';

  @override
  String get acctFieldServerDomain => 'Servidor / domínio';

  @override
  String get acctFieldServerDomainSub => 'host ou host:porta';

  @override
  String get acctFieldEnabled => 'Ativada';

  @override
  String get acctFieldDefault => 'Conta padrão para ligações realizadas';

  @override
  String get acctFieldColour => 'Cor';

  @override
  String get acctGroupRegistration => 'Registro';

  @override
  String get acctFieldRegister => 'Registrar';

  @override
  String get acctFieldRegisterSubIax =>
      'Desative para peers que não precisam de registro';

  @override
  String get acctFieldRegExpiry => 'Expiração do registro (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'O Asterisk geralmente força 60 s. Intervalo de 10 a 86400';

  @override
  String get acctFieldRetryInterval => 'Intervalo de nova tentativa (s)';

  @override
  String get acctFieldFirstRetry => 'Primeira nova tentativa (s)';

  @override
  String get acctGroupCodecs => 'Codecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'O IAX2 é compatível com G.711 e GSM. Arraste para definir a ordem de preferência.';

  @override
  String get acctCodecAdd => 'Adicionar codec';

  @override
  String get acctGroupServerTransport => 'Servidor e transporte';

  @override
  String get acctFieldRegistrar => 'Substituir registrar';

  @override
  String get acctFieldBackupRegistrar => 'Registrar de backup';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Usado após 3 tentativas com falha; o principal é testado novamente a cada 5 minutos';

  @override
  String get acctFieldProxies => 'Proxies de saída';

  @override
  String get acctFieldTransport => 'Transporte';

  @override
  String get acctFieldTransportAutoSub =>
      'Consulta os registros DNS SRV do servidor e escolhe TLS, TCP ou UDP';

  @override
  String get acctTransportAuto => 'Automático (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Caminho do WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'Caminho HTTP do upgrade para WebSocket, ex.: /ws. Deve começar com \"/\"';

  @override
  String get acctFieldRegExpirySubSip =>
      'O típico é de 300 a 3600. Intervalo de 10 a 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'Intervalo de keep-alive do UDP. 0 desativa. Intervalo de 0 a 3600';

  @override
  String get acctFieldLocalPort => 'Porta SIP local';

  @override
  String get acctFieldLocalPortSub =>
      '0 usa o transporte compartilhado. Intervalo de 0 a 65535';

  @override
  String get acctFieldRegisterSubSip => 'Desative para troncos sem registro';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Mantém um fluxo persistente através do NAT. Requer suporte do servidor';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Usar STUN';

  @override
  String get acctFieldTurn => 'Relay TURN';

  @override
  String get acctFieldTurnServer => 'Servidor TURN';

  @override
  String get acctFieldTurnUsername => 'Usuário TURN';

  @override
  String get acctFieldTurnPassword => 'Senha TURN';

  @override
  String get acctFieldContactRewrite => 'Reescrever cabeçalho Contact';

  @override
  String get acctFieldViaRewrite => 'Reescrever cabeçalho Via';

  @override
  String get acctFieldRewriteSub =>
      'Usa o endereço que o servidor enxerga. Mantenha ativado atrás de NAT';

  @override
  String get acctFieldSdpRewrite => 'Reescrever endereço SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'Substitui o endereço de mídia no SDP pelo público';

  @override
  String get acctFieldIpv6Sip => 'Sinalização IPv6';

  @override
  String get acctFieldIpv6Media => 'Mídia IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Mídia avançada';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'Gateways WebRTC exigem multiplexação RTCP e feedback RTCP.';

  @override
  String get acctFieldRtcpMux => 'Multiplexação RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Envia RTP e RTCP em uma única porta (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Feedback RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Oferece RTP/AVPF com NACK. Necessário para servidores WebRTC';

  @override
  String get acctGroupSecurity => 'Segurança';

  @override
  String get acctFieldSrtp => 'Criptografia de mídia (SRTP)';

  @override
  String get acctOptOptional => 'Opcional';

  @override
  String get acctOptRequired => 'Obrigatório';

  @override
  String get acctFieldKeyExchange => 'Troca de chaves';

  @override
  String get acctFieldSecureSignaling => 'Sinalização segura';

  @override
  String get acctOptNotRequired => 'Não obrigatória';

  @override
  String get acctOptTlsHop => 'TLS salto a salto';

  @override
  String get acctOptTlsE2e => 'TLS ponta a ponta (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Algoritmo de autenticação';

  @override
  String get acctFieldPrivacy =>
      'Ocultar identificador de chamadas (privacidade)';

  @override
  String get acctFieldReferPolicy => 'Transferências recebidas (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Observadores de presença';

  @override
  String get acctOptAccept => 'Aceitar';

  @override
  String get acctOptReject => 'Rejeitar';

  @override
  String get acctGroupCodecsFooter =>
      'Substitui a lista global de codecs para esta conta.';

  @override
  String get acctFieldUseGlobalCodecs => 'Usar ordem global de codecs';

  @override
  String get acctGroupFeatures => 'Recursos';

  @override
  String get acctFieldVoicemailNumber => 'Número da caixa postal';

  @override
  String get acctFieldMwi => 'Indicador de caixa postal (MWI)';

  @override
  String get acctFieldMwiSub => 'Assinar notificações de mensagem em espera';

  @override
  String get acctFieldPublishPresence => 'Publicar minha presença';

  @override
  String get acctFieldPublishPresenceSub =>
      'Permitir que o servidor compartilhe seu status online';

  @override
  String get acctFieldDnd => 'Não perturbe';

  @override
  String get acctFieldForwarding => 'Desvio de ligações';

  @override
  String get acctOptForwardAlways => 'Sempre';

  @override
  String get acctOptForwardBusy => 'Quando ocupado';

  @override
  String get acctOptForwardNoAnswer => 'Sem resposta';

  @override
  String get acctFieldForwardTo => 'Desviar para';

  @override
  String get acctFieldForwardToHint => 'Número ou endereço SIP';

  @override
  String get acctFieldRingFor => 'Tocar por (s)';

  @override
  String get acctFieldAutoAnswer => 'Atendimento automático';

  @override
  String get acctFieldAnswerAfter => 'Atender após (s)';

  @override
  String get acctFieldIntercomOnly => 'Somente para ligações de interfone';

  @override
  String get acctFieldIntercomOnlySub =>
      'Requer um cabeçalho de atendimento automático do PBX';

  @override
  String get acctFieldRingtone => 'Toque';

  @override
  String get acctRingtoneClassic => 'Clássico';

  @override
  String get acctRingtoneSoft => 'Suave';

  @override
  String get acctRingtoneDigital => 'Digital';

  @override
  String get acctFieldRecordCalls => 'Gravar ligações';

  @override
  String get acctFieldHoldMusic => 'Música de espera';

  @override
  String get acctOptUseGlobal => 'Usar configuração global';

  @override
  String get acctOptPbxDefault => 'Padrão do PBX';

  @override
  String get acctFieldOpeningAnnouncement => 'Aviso de abertura';

  @override
  String get acctGroupFeatureCodes => 'Códigos de recurso';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Discados para estacionar, capturar, Não perturbe e desvio no seu PBX.';

  @override
  String get acctFieldPark => 'Estacionar';

  @override
  String get acctFieldGroupPickup => 'Captura em grupo';

  @override
  String get acctFieldDirectedPickup => 'Prefixo de captura direcionada';

  @override
  String get acctFieldParkRetrieve => 'Prefixo de recuperação de estacionada';

  @override
  String get acctFieldParkRetrieveHint => 'Disque o número da vaga';

  @override
  String get acctFieldParkRetrieveSub =>
      'Prefixo discado antes da vaga de estacionamento para recuperar uma ligação estacionada';

  @override
  String get acctFieldDndOn => 'Ativar Não perturbe';

  @override
  String get acctFieldDndOff => 'Desativar Não perturbe';

  @override
  String get acctFieldForwardOn => 'Ativar desvio';

  @override
  String get acctFieldForwardOff => 'Desativar desvio';

  @override
  String get acctGroupAdvanced => 'Avançado';

  @override
  String get acctGroupAdvancedFooterIax =>
      'O DTMF é enviado como quadros IAX2 nativos.';

  @override
  String get acctFieldCallerIdOverride =>
      'Substituir identificador de chamadas';

  @override
  String get acctFieldCallerIdHint => 'Usar o padrão da conta';

  @override
  String get acctFieldCallerIdSub =>
      'Nome ou número do identificador de chamadas enviado ao PBX';

  @override
  String get acctFieldSessionTimers => 'Temporizadores de sessão';

  @override
  String get acctFieldSessionExpires => 'Expiração da sessão (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Intervalo de 90 a 86400';

  @override
  String get acctField100rel => '100rel (provisória confiável)';

  @override
  String get acctFieldHoldMethod => 'Método de espera';

  @override
  String get acctFieldDtmfMethod => 'Método DTMF';

  @override
  String get acctOptDtmfInband => 'In-band';

  @override
  String get acctFieldRedirects => 'Redirecionamentos (3xx)';

  @override
  String get acctOptRedirectFollow => 'Seguir';

  @override
  String get acctOptRedirectAsk => 'Perguntar';

  @override
  String get acctFieldLockCodec => 'Travar codec após o atendimento';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive de mídia';

  @override
  String get acctFieldDropCalls => 'Encerrar ligações quando o registro falhar';

  @override
  String get acctFieldExtraHeaders => 'Cabeçalhos SIP extras';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: valor (um por linha)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Tempo de espera antes de tentar novamente um registro com falha. Intervalo de 0 a 86400';

  @override
  String get acctFieldUnregTimeout =>
      'Tempo limite de cancelamento de registro (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Quanto tempo esperar pela resposta do cancelamento de registro. Intervalo de 0 a 60000';

  @override
  String get acctFieldMwiExpiry => 'Expiração da assinatura MWI (s)';

  @override
  String get acctFieldDscpSip => 'DSCP para SIP';

  @override
  String get acctFieldDscpSipSub =>
      'Marcação de QoS da sinalização. O típico é 24 (CS3)';

  @override
  String get acctFieldDscpRtp => 'DSCP para RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'Marcação de QoS da mídia. O típico é 46 (EF)';

  @override
  String get acctFieldReinvite => 'Re-INVITE após mudança de rede';

  @override
  String get acctFieldHangupOnIpChange => 'Desligar ligações ao mudar de rede';

  @override
  String get acctValidateInt => 'Digite um número inteiro';

  @override
  String get acctValidateHostEmpty =>
      'Digite o nome do host ou o endereço do servidor';

  @override
  String get acctValidateHostSpaces => 'O servidor não pode conter espaços';

  @override
  String get acctValidateHostFormat => 'Digite apenas host ou host:porta';

  @override
  String get acctValidatePortRange => 'A porta deve estar entre 1 e 65535';

  @override
  String get acctValidateWsStart => 'O caminho deve começar com \"/\"';

  @override
  String get acctValidateWsLength => 'Use no máximo 120 caracteres';

  @override
  String get acctValidateWsSpaces => 'O caminho não pode conter espaços';

  @override
  String get acctTplAsteriskDescription =>
      'Ramal no seu próprio PBX. UDP 5060, STUN ativado.';

  @override
  String get acctTplAsteriskNotes =>
      'Use o número do ramal PJSIP/SIP e o respectivo secret. Para TLS ou WebRTC, altere o transporte depois nas configurações da conta.';

  @override
  String get acctTplAsteriskUsernameHint => 'Ramal (ex.: 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Use o ramal, o ID de autenticação e a senha do portal do 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'No 3CX, abra o ramal e depois \"Phones > Provisioning\" para ver o ID de autenticação (defina-o como Usuário de autorização) e a senha. O FQDN é o da sua URL do 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Ramal';

  @override
  String get acctTplFreeswitchDescription =>
      'Usuário do diretório em um servidor FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Use o ID de usuário e a senha do diretório. O perfil internal padrão escuta em UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID de usuário';

  @override
  String get acctTplKamailioDescription =>
      'Registrar proxy SIP. TCP recomendado atrás de NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Use o domínio SIP atendido pelo seu registrar. Adicione um proxy de saída nas configurações da conta se o registrar for acessado por outro host.';

  @override
  String get acctTplTwilioDescription =>
      'Credenciais do domínio SIP do Programmable Voice. TLS e SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Crie um domínio SIP no console da Twilio, adicione uma Credential List e ative o SIP Registration. Informe o domínio completo (nome.sip.twilio.com) como servidor e o usuário e a senha da credential list. O TLS usa a porta 5061. A Twilio aceita apenas G.711.';

  @override
  String get acctTplTwilioUsernameHint => 'Usuário da credential list';

  @override
  String get acctTplTelnyxDescription =>
      'Credential connection. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Crie uma Credential Connection no portal da Telnyx e copie o usuário e a senha SIP dela (não o login do portal). Atribua um número ou um outbound voice profile à conexão para fazer e receber ligações.';

  @override
  String get acctTplTelnyxUsernameHint => 'Usuário SIP (credential connection)';

  @override
  String get acctTplVoipmsDescription =>
      'Usuário e senha da subconta. Escolha o POP mais próximo de você.';

  @override
  String get acctTplVoipmsNotes =>
      'Use uma subconta criada em Sub Accounts, não a sua conta principal. Escolha o servidor (POP) mais próximo de você na lista de servidores do VoIP.ms e libere-o para o seu IP, se necessário.';

  @override
  String get acctTplVoipmsUsernameHint => 'Subconta (ex.: 123456_phone)';

  @override
  String get acctTplVonageDescription => 'Registro SIP com TLS.';

  @override
  String get acctTplVonageNotes =>
      'O Vonage Business oferece registro SIP apenas em alguns planos. Informe o servidor SIP, o usuário e a senha exibidos no portal de administração do Vonage para o dispositivo.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange sobre UDP 4569. Sem configurações de NAT ou SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Requer um peer/usuário em iax.conf (type=friend ou user+peer) com o mesmo secret. O Asterisk renova os registros IAX2 a cada 60 s por padrão. O contexto é opcional e é enviado como o contexto chamado.';

  @override
  String get acctTplIax2UsernameHint => 'Usuário IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP sobre WebSocket seguro com DTLS-SRTP, ICE e RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Para endpoints WebSocket do Asterisk (webrtc=yes, TLS no http.conf na 8089), FreeSWITCH ou Kamailio. O servidor precisa de um certificado TLS válido. Altere o caminho do WebSocket nas configurações da conta se o seu gateway não usar /ws.';

  @override
  String get acctTplGenericDescription =>
      'Qualquer registrar SIP. Preencha os dados você mesmo.';

  @override
  String get acctTplDefaultUsernameHint => 'Ramal / usuário';

  @override
  String get appEngineFailedBody =>
      'As ligações e o registro não funcionarão até que isso seja corrigido. A causa mais comum é uma configuração de rede ou de certificado incorreta.';

  @override
  String get appEngineFailedTitle =>
      'Não foi possível iniciar o mecanismo de ligações';

  @override
  String get appEngineNotRunning =>
      'O mecanismo de ligações não está em execução';

  @override
  String get appUnknownError => 'Erro desconhecido';

  @override
  String get appEngineOpenNetworkSettings => 'Abrir ajustes de rede';

  @override
  String get appEngineUseSimulator => 'Usar simulador (demo)';

  @override
  String get appDbLockedTitle => 'Seus dados estão bloqueados';

  @override
  String get appDbUnreadableTitle => 'Não é possível abrir seus dados';

  @override
  String get appDbLockedBody =>
      'O histórico de ligações, os contatos e as mensagens estão criptografados neste dispositivo, mas a chave de criptografia não está mais no chaveiro / keystore do sistema (por exemplo, após uma redefinição do chaveiro ou uma restauração em um novo dispositivo).';

  @override
  String get appDbUnreadableBody =>
      'Não foi possível ler o banco de dados local. Ele pode estar danificado ou a chave de criptografia não corresponde.';

  @override
  String get appDbRecoveryAdvice =>
      'Tente novamente se você espera que a chave volte (desbloqueie o chaveiro, entre com o usuário correto). Começar do zero mantém o arquivo antigo junto aos dados do app, mas inicia com histórico, contatos e mensagens vazios; você precisará adicionar suas contas novamente.';

  @override
  String get appDbCopyDetails => 'Copiar detalhes';

  @override
  String get appDbTryAgain => 'Tentar novamente';

  @override
  String get appDbStartFresh => 'Começar do zero';

  @override
  String get appRedirectTitle => 'Ligação redirecionada';

  @override
  String appRedirectMessage(String target) {
    return 'Ligação redirecionada para $target - seguir?';
  }

  @override
  String get appRedirectCancelCall => 'Cancelar ligação';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt':
          'Não foi possível criptografar seus dados ($error). Nada foi alterado.',
      'other':
          'Não foi possível descriptografar seus dados ($error). Nada foi alterado.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Mecanismo nativo indisponível ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Nova tentativa às $time';
  }

  @override
  String get acctRegistrationError => 'Erro de registro';

  @override
  String acctRegistrationDetails(
    int code,
    String reason,
    String status,
    String transport,
  ) {
    return 'SIP $code $reason\n$status\nTransporte: $transport';
  }

  @override
  String get acctCallingFromDirect => 'Ligando direto, sem conta';

  @override
  String acctCallingFromAccount(String name) {
    return 'Ligando de $name';
  }

  @override
  String get acctCallingFromNone => 'Ligando sem conta';

  @override
  String get acctNoAccount => 'Sem conta';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nova(s), $oldCount antiga(s)';
  }

  @override
  String get acctAddAccount => 'Adicionar conta';

  @override
  String get acctUnregister => 'Cancelar registro';

  @override
  String get acctSheetDndSub => 'Rejeitar ligações recebidas nesta conta';

  @override
  String get acctKvServer => 'Servidor';

  @override
  String get acctKvResolvedServer => 'Servidor resolvido';

  @override
  String get acctKvClientCert => 'Cert. de cliente';

  @override
  String get acctKvClientCertValue => 'Apresentado ao servidor (TLS mútuo)';

  @override
  String get acctKvContact => 'Contact';

  @override
  String get acctKvExpiresIn => 'Expira em';

  @override
  String get acctKvVoicemail => 'Caixa postal';

  @override
  String get acctOpenSipTrace => 'Abrir rastreamento SIP';

  @override
  String get acctAddAnAccount => 'Adicionar uma conta';

  @override
  String get acctChooseAccountTooltip => 'Escolha a conta para ligar';

  @override
  String get acctDirectNoAccount => 'Direto (sem conta)';

  @override
  String get onboardingRequired => 'Usuário e servidor são obrigatórios';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'A porta $port é usada, a menos que você adicione :porta';
  }

  @override
  String get onboardingFineTuneIax =>
      'Você pode ajustar codecs e registro depois, em Ajustes.';

  @override
  String get onboardingFineTuneSip =>
      'Você pode ajustar transporte, NAT, segurança e codecs depois, em Ajustes.';

  @override
  String get onboardingDemoUser => 'Usuário demo';

  @override
  String get onboardingDemoAccount => 'Conta demo';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Ligações profissionais para todas as plataformas - gratuito e de código aberto. Sem anúncios, sem rastreamento.';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingPermissionsTitle => 'Permissões';

  @override
  String get onboardingPermissionsText =>
      'O SoftphonePro precisa do microfone para transmitir sua voz e das notificações para avisar sobre ligações e mensagens recebidas. Nada sai do seu dispositivo além das suas ligações.';

  @override
  String get onboardingChooseProvider => 'Escolha seu provedor';

  @override
  String get onboardingChooseProviderSub =>
      'Preenchemos o transporte, as portas e as configurações de NAT para você.';

  @override
  String get onboardingScanQr => 'Ler QR';

  @override
  String get onboardingImportUrl => 'Importar de URL';

  @override
  String get onboardingSkip => 'Pular por enquanto (modo demo)';

  @override
  String get onboardingHidePassword => 'Ocultar senha';

  @override
  String get onboardingShowPassword => 'Mostrar senha';

  @override
  String get onboardingContextOptional => 'Contexto (opcional)';

  @override
  String get onboardingDisplayNameOptional => 'Nome de exibição (opcional)';

  @override
  String get onboardingLabelOptional => 'Rótulo da conta (opcional)';

  @override
  String get onboardingCallerIdOptional =>
      'Identificador de chamadas (opcional)';

  @override
  String get onboardingAuthUserOptional =>
      'Usuário de autorização (se diferente)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Usuário ou senha incorretos ($code)';
  }

  @override
  String get acctRegNotFound => 'Conta não encontrada no servidor (404)';

  @override
  String get acctRegNoAnswer => 'O servidor não respondeu (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Intervalo de registro muito curto (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Servidor temporariamente indisponível (480)';

  @override
  String get acctRegServiceUnavailable => 'Serviço indisponível (503)';

  @override
  String get acctRegFailed => 'Falha no registro';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Falha no registro ($code)';
  }

  @override
  String get acctNoticeRegistrationChange =>
      'Não foi possível alterar o registro';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'Não foi possível aplicar a conta \"$name\"';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'De volta ao servidor principal de $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Usando o servidor de backup de $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'A conta $name está registrada';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'A conta $name ainda está sendo registrada';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'A conta $name ainda não está registrada';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'A conta $name não está registrada (falha no registro)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'A conta $name está desativada';
  }

  @override
  String get callDialEngineFailed =>
      'O mecanismo de ligações não conseguiu iniciar';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'O mecanismo de ligações não conseguiu iniciar: $reason';
  }

  @override
  String get callDialEngineStarting =>
      'O mecanismo de ligações ainda está iniciando';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status após $seconds s; a ligação não foi feita';
  }

  @override
  String get callJournalInterrupted => 'O app foi fechado durante a ligação';

  @override
  String get callLinkMissingArgument => 'Argumento ausente';

  @override
  String get callLinkHttpsRequired =>
      'Os links de configuração devem usar https';

  @override
  String get callLinkInvalidLan => 'Esse link LAN não é válido';

  @override
  String callLinkConnectedTo(String name) {
    return 'Conectado a $name';
  }

  @override
  String get callLinkConnectFailed =>
      'Não foi possível conectar a esse dispositivo';

  @override
  String callLinkCallFailed(String target) {
    return 'Não foi possível ligar para $target';
  }

  @override
  String get callLinkImportTitle => 'Importar configuração';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts contas',
      one: '1 conta',
    );
    return 'Importar a configuração de $host? Isso adicionará $_temp0.';
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
      other: '$accounts contas',
      one: '1 conta',
    );
    return 'Importar a configuração de $host? Isso adicionará $_temp0 e $settings ajuste(s).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Desviada de $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Desviada de $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Transferida por $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Padrão do sistema';

  @override
  String get callRingtoneClassic => 'Clássico';

  @override
  String get callRingtoneSoft => 'Suave';

  @override
  String get callRingtoneDigital => 'Digital';

  @override
  String callIdentityFrom(String number) {
    return 'De $number';
  }

  @override
  String callIdentityCallerId(String number) {
    return 'Identificador $number';
  }

  @override
  String callIdentityCallerIdWithName(String name, String number) {
    return 'Identificador $name $number';
  }

  @override
  String get callTransferring => 'Transferindo...';

  @override
  String get callTransferNotConfirmed =>
      'Transferência não confirmada pelo servidor';

  @override
  String get callTransferStalledHint =>
      'A ligação continua ativa. Mantenha-a ou envie a transferência novamente.';

  @override
  String get callTransferKeepCall => 'Manter ligação';

  @override
  String get callAnnouncementOpening => 'Reproduzindo aviso…';

  @override
  String get callAnnouncementTransfer => 'Reproduzindo aviso de transferência…';

  @override
  String get callAnnouncementRecording => 'Reproduzindo aviso de gravação…';

  @override
  String get callAnnouncementSkip => 'Pular';

  @override
  String get callNoiseTooltipMic =>
      'Cancelamento de ruído por IA: seu microfone';

  @override
  String get callNoiseTooltipIncoming =>
      'Cancelamento de ruído por IA: outros participantes';

  @override
  String get callNoiseTooltipBoth =>
      'Cancelamento de ruído por IA: seu microfone e outros participantes';

  @override
  String get callNoiseOn => 'Cancelamento de ruído ativado';

  @override
  String get callNoiseTitle => 'Cancelamento de ruído';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Meu microfone: $strength';
  }

  @override
  String get callNoiseMicOffHint => 'Remover o ruído de fundo do meu microfone';

  @override
  String get callResultAnswered => 'Atendida';

  @override
  String get callResultMissed => 'Perdida';

  @override
  String get callResultRejected => 'Recusada';

  @override
  String get callResultFailed => 'Falhou';

  @override
  String get callResultBusy => 'Ocupado';

  @override
  String get callResultForwarded => 'Desviada';

  @override
  String get callResultTransferred => 'Transferida';

  @override
  String get callResultHandedOff => 'Repassada';

  @override
  String get callResultInterrupted => 'Interrompida';

  @override
  String get keypadCall => 'Ligar';

  @override
  String get keypadNoVoicemail =>
      'Nenhum número de caixa postal configurado para esta conta';

  @override
  String get keypadCallDirectly => 'Ligar direto (sem conta)';

  @override
  String get keypadAddAccount => 'Adicione uma conta para fazer ligações';

  @override
  String keypadCallFrom(String account) {
    return 'Ligar de $account';
  }

  @override
  String get keypadRecent => 'Recentes';

  @override
  String get keypadSuggestions => 'Sugestões';

  @override
  String get keypadPhoneNumber => 'Número de telefone';

  @override
  String get keypadPaste => 'Colar';

  @override
  String get keypadEnterNumber => 'Digite o número';

  @override
  String get keypadBackspace => 'Apagar (mantenha pressionado para limpar)';

  @override
  String get keypadTypeNameOrNumber => 'Digite um nome ou número';

  @override
  String get keypadNoMatches => 'Nenhum resultado';

  @override
  String get keypadSuggestionsHint =>
      'As sugestões vêm dos contatos e das ligações recentes';

  @override
  String keypadCallPerson(String name) {
    return 'Ligar para $name';
  }

  @override
  String get dialKeyStar => 'Asterisco';

  @override
  String get dialKeyPound => 'Cerquilha';

  @override
  String get dialKeyLongPressPlus => 'Mantenha pressionado para inserir mais';

  @override
  String get dialKeyLongPressSpeedDial =>
      'Mantenha pressionado para discagem rápida';

  @override
  String get dialKeyLongPressVoicemail =>
      'Mantenha pressionado para a caixa postal';

  @override
  String get callBackToApp => 'Voltar ao app (a ligação continua ativa)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Ocultar teclado';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callKeypad => 'Teclado';

  @override
  String get callSpeaker => 'Alto-falante';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Fone';

  @override
  String get callResume => 'Retomar';

  @override
  String get callHold => 'Espera';

  @override
  String get callAddCall => 'Nova ligação';

  @override
  String get callTransfer => 'Transferir';

  @override
  String get callStop => 'Parar';

  @override
  String get callRecord => 'Gravar';

  @override
  String get callSplit => 'Dividir';

  @override
  String get callMerge => 'Unir';

  @override
  String get callSwap => 'Alternar';

  @override
  String get callEndCall => 'Encerrar';

  @override
  String callEndCallWith(String name) {
    return 'Encerrar ligação com $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Transferência assistida. Quem ligou originalmente está em espera.';

  @override
  String get callCompleteTransfer => 'Concluir transferência';

  @override
  String get callWaiting => 'Chamada em espera';

  @override
  String get callHoldAndAnswer => 'Colocar a ligação atual em espera e atender';

  @override
  String get callDecline => 'Recusar';

  @override
  String get callAnswer => 'Atender';

  @override
  String get callIncomingCall => 'Ligação recebida';

  @override
  String get callReply => 'Responder';

  @override
  String get callVoicemail => 'Caixa postal';

  @override
  String get callToDevice => 'Ao dispositivo';

  @override
  String get callQuickReplyBusy => 'Não posso falar agora, ligo de volta.';

  @override
  String get callQuickReplyMeeting => 'Estou em reunião. Pode mandar mensagem?';

  @override
  String get callQuickReplyOnMyWay => 'Já estou a caminho.';

  @override
  String callReturnToCallWith(String name) {
    return 'Voltar à ligação com $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Recebendo: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'Em ligação com $name';
  }

  @override
  String get callStatsCodec => 'Codec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Perda de pacotes';

  @override
  String get callStatsRoundTrip => 'Ida e volta';

  @override
  String get callStatsMedia => 'Mídia';

  @override
  String get callStatsMosHistory => 'Histórico de MOS';

  @override
  String get callQualityTitle => 'Qualidade da ligação';

  @override
  String get callTransferTitle => 'Transferir ligação';

  @override
  String get callTransferModeBlind => 'Direta';

  @override
  String get callTransferModeAttended => 'Assistida';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Dispositivo LAN';

  @override
  String get callTransferNoLanDevices =>
      'Nenhum dispositivo SoftphonePro pareado encontrado na sua rede. Pareie um na página LAN.';

  @override
  String get callTransferLanDisabled =>
      'Ative o LAN Link (Ajustes, LAN Link) para passar esta ligação a outro dispositivo da sua rede.';

  @override
  String get callTransferTalkFirst => 'Falar antes';

  @override
  String get callTransferBlindHint =>
      'Passa quem ligou imediatamente. Você é desconectado.';

  @override
  String get callTransferAttendedHint =>
      'Coloca quem ligou em espera e liga primeiro para o destino. Conclua a transferência quando atenderem.';

  @override
  String get callTransferNumberLabel => 'Número ou endereço SIP';

  @override
  String get callTransferNow => 'Transferir agora';

  @override
  String get callTransferCallAndConsult => 'Ligar e consultar';

  @override
  String get callRetrieveParkedTitle => 'Recuperar ligação estacionada';

  @override
  String get callRetrieveParkedHint => 'Vaga de estacionamento, ex.: 701';

  @override
  String get callMoreAudioOutput => 'Saída de áudio';

  @override
  String get callMoreAudioDevices => 'Dispositivos de áudio';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Telefone, alto-falante, Bluetooth, fone';

  @override
  String get callMoreAudioDevicesSubtitle =>
      'Escolha o microfone e o alto-falante';

  @override
  String get callMoreParkCall => 'Estacionar ligação';

  @override
  String get callMoreParkCallSubtitle =>
      'Transferir para o código de recurso de estacionamento';

  @override
  String get callMoreRetrieveParkedSubtitle =>
      'Disque uma vaga de estacionamento';

  @override
  String get callMoreSendDtmf => 'Enviar dígitos DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Digite uma sequência inteira, ex.: um PIN';

  @override
  String get callSendDtmfTitle => 'Enviar DTMF';

  @override
  String get callMoreCallInfo => 'Informações da ligação';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, jitter, perda e tempo de ida e volta ao vivo';

  @override
  String get callMoreSipTrace => 'Rastreamento SIP';

  @override
  String get callMoreSipTraceSubtitle => 'Diagrama de sequência desta ligação';

  @override
  String get callInfoRemote => 'Remoto';

  @override
  String get callInfoAccount => 'Conta';

  @override
  String get callInfoState => 'Estado';

  @override
  String get callInfoSecure => 'Seguro';

  @override
  String get callInfoPlainSignalling => 'sinalização sem criptografia';

  @override
  String get callRoutePhone => 'Telefone';

  @override
  String get callRouteWiredHeadset => 'Fone com fio';

  @override
  String get callAudioMicrophone => 'Microfone';

  @override
  String callCardSemantics(String name, String state) {
    return 'Ligação com $name, $state';
  }

  @override
  String get callUnmute => 'Reativar som';

  @override
  String get callStopRecording => 'Parar gravação';

  @override
  String get callSplitConference => 'Dividir conferência';

  @override
  String get callMergeCalls => 'Unir ligações';

  @override
  String get callSwapCalls => 'Alternar ligações';

  @override
  String get callAttendedTransferBanner =>
      'Transferência assistida: quem ligou originalmente está em espera.';

  @override
  String get callActiveCalls => 'Ligações ativas';

  @override
  String get callConferenceLevels => 'Níveis da conferência';

  @override
  String get callLevelVolume => 'Volume';

  @override
  String get callLevelMicToParty => 'Mic. para o participante';

  @override
  String callPercentSemantics(int percent) {
    return '$percent por cento';
  }

  @override
  String get callFailInvalidNumber => 'Número inválido (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Ligação não autorizada ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Número não encontrado (404)';

  @override
  String get callFailNoAnswerFromServer => 'Sem resposta do servidor (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Temporariamente indisponível (480)';

  @override
  String get callFailIncompleteNumber => 'Número incompleto (484)';

  @override
  String callFailBusy(String code) {
    return 'Ocupado ($code)';
  }

  @override
  String get callFailCancelled => 'Ligação cancelada (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Nenhum codec compatível ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Serviço indisponível (503)';

  @override
  String get callFailDeclined => 'Ligação recusada (603)';

  @override
  String get callFailGeneric => 'Falha na ligação';

  @override
  String callFailGenericWithCode(String code) {
    return 'Falha na ligação ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Ligação em andamento';

  @override
  String get callTrayInCall => 'Em ligação';

  @override
  String get callHistoryBlocked => 'Bloqueada';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimato não permitido';

  @override
  String get callHistoryDoNotDisturb => 'Não perturbe';

  @override
  String get callHistoryBusy => 'Ocupado';

  @override
  String get callHistoryForwardedAlways => 'Desviada (sempre)';

  @override
  String get callHistoryForwardedBusy => 'Desviada (ocupado)';

  @override
  String get callHistorySentToVoicemail => 'Enviada à caixa postal';

  @override
  String get callHistoryRedirected => 'Redirecionada';

  @override
  String get callIncomingNotificationBody => 'Ligação recebida';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Ligação recebida em $account';
  }

  @override
  String get callMissedNotificationTitle => 'Ligação perdida';

  @override
  String get callErrEngineNotRunning =>
      'O mecanismo de ligações ainda não está em execução';

  @override
  String get callErrAddAccount => 'Adicione uma conta para fazer ligações';

  @override
  String get callErrCouldNotPlace => 'Não foi possível fazer a ligação';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account não está registrada';
  }

  @override
  String get callErrCouldNotAnswer => 'Não foi possível atender';

  @override
  String get callErrNoVoicemailNumber =>
      'Nenhum número de caixa postal definido para esta conta';

  @override
  String get callErrTransferFailed => 'Falha na transferência';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Falha na transferência: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'Não foi possível unir as ligações';

  @override
  String get callErrCouldNotStartRecording =>
      'Não foi possível iniciar a gravação';

  @override
  String get callErrCouldNotStopRecording =>
      'Não foi possível parar a gravação';

  @override
  String callParkingNotice(String code) {
    return 'Estacionando ligação (discar $code)';
  }

  @override
  String get callErrParkFailed => 'Falha ao estacionar';

  @override
  String get callErrHandoffFailed => 'Falha ao repassar';

  @override
  String get callErrCouldNotSendToDevice =>
      'Não foi possível enviar ao dispositivo';

  @override
  String get callHistoryForwardedNoAnswer => 'Desviada (sem resposta)';

  @override
  String get shellTabKeypad => 'Teclado';

  @override
  String get shellTabRecents => 'Recentes';

  @override
  String get shellTabContacts => 'Contatos';

  @override
  String get shellTabMessages => 'Mensagens';

  @override
  String get shellTabPresence => 'Presença';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Gravações';

  @override
  String get shellSearchSemantics =>
      'Buscar contatos, histórico ou discar um número';

  @override
  String get shellSearchHint => 'Buscar ou discar';

  @override
  String get shellVoicemailTooltip => 'Caixa postal';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count novas mensagens na caixa postal. Clique para ligar para a caixa postal',
      one:
          '1 nova mensagem na caixa postal. Clique para ligar para a caixa postal',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Ausente';

  @override
  String get shellStatusTooltip => 'Seu status';

  @override
  String get shellDemoBanner =>
      'Modo demo: as ligações são simuladas, nada chega a uma rede real.';

  @override
  String get uiToday => 'Hoje';

  @override
  String get uiYesterday => 'Ontem';

  @override
  String get uiUnknownCaller => 'Chamador desconhecido';

  @override
  String get uiCallEnded => 'Ligação encerrada';

  @override
  String get uiCallTransferNotConfirmed => 'Transferência não confirmada';

  @override
  String get uiCallTransferring => 'Transferindo...';

  @override
  String get uiCallConference => 'Conferência';

  @override
  String get uiCallOnHold => 'Em espera';

  @override
  String get uiCallHeldByRemote => 'Em espera pelo outro lado';

  @override
  String get uiCallCalling => 'Chamando...';

  @override
  String get uiCallRinging => 'Tocando...';

  @override
  String get uiCallConnecting => 'Conectando...';

  @override
  String get uiCallIncoming => 'Ligação recebida';

  @override
  String get uiCallConnected => 'Conectada';

  @override
  String get uiQrScanTitle => 'Ler código QR';

  @override
  String get uiQrPasteHint => 'Cole o texto do código';

  @override
  String get uiQrNoCamera =>
      'A leitura por câmera não está disponível neste dispositivo. Cole o texto do código.';

  @override
  String get uiQrPaste => 'Colar';

  @override
  String get uiQrUse => 'Usar';

  @override
  String get uiQrCameraDenied =>
      'O acesso à câmera está desativado. Permita-o nos ajustes do sistema ou cole o texto do código abaixo.';

  @override
  String get uiQrCameraUnavailable =>
      'A câmera não está disponível. Cole o texto do código abaixo.';

  @override
  String get presenceLampRinging => 'Tocando';

  @override
  String get presenceHeader => 'Campo de lâmpada ocupada';

  @override
  String get presenceChooseTooltip => 'Escolher contatos para monitorar';

  @override
  String get presenceEmptyTitle => 'Nenhum ramal no painel';

  @override
  String get presenceEmptySubtitle =>
      'Ative \"Mostrar no painel BLF\" em um contato para ver quando ele está livre, tocando ou ocupado.';

  @override
  String get presenceOpenContacts => 'Abrir contatos';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Toque para ligar, mantenha pressionado para mais opções';
  }

  @override
  String presenceCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get presencePickup => 'Capturar este ramal';

  @override
  String get presencePickupSub =>
      'Atender a ligação que está tocando nele (captura direcionada)';

  @override
  String get presenceTransferHere => 'Transferir a ligação atual para cá';

  @override
  String get presenceRemove => 'Remover do painel';

  @override
  String get uiCall => 'Ligar';

  @override
  String get uiMessage => 'Mensagem';

  @override
  String get recentsSearchTooltip => 'Buscar no histórico';

  @override
  String get recentsClearTitle => 'Limpar o histórico de ligações?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todos os $count registros serão excluídos.',
      one: '1 registro será excluído.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv =>
      'Histórico copiado para a área de transferência como CSV';

  @override
  String get recentsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get recentsMenuClear => 'Limpar histórico';

  @override
  String get recentsSearchHint => 'Buscar nome ou número';

  @override
  String get recentsFilterAll => 'Todas';

  @override
  String get recentsFilterMissed => 'Perdidas';

  @override
  String get recentsFilterIncoming => 'Recebidas';

  @override
  String get recentsFilterOutgoing => 'Realizadas';

  @override
  String get recentsFilterAccount => 'Filtrar por conta';

  @override
  String get recentsAllAccounts => 'Todas as contas';

  @override
  String get recentsAccountFallback => 'Conta';

  @override
  String get recentsEmptyNone => 'Nenhuma ligação ainda';

  @override
  String get recentsEmptyNoMatch => 'Nenhuma ligação correspondente';

  @override
  String get recentsEmptyNoneSub => 'Suas ligações aparecerão aqui.';

  @override
  String get recentsEmptyNoMatchSub => 'Tente outro filtro.';

  @override
  String get recentsOpenKeypad => 'Abrir teclado';

  @override
  String get recentsShowAll => 'Mostrar todas';

  @override
  String get recentsSelectCall => 'Selecione uma ligação';

  @override
  String get recentsSelectCallSub =>
      'Detalhes, qualidade e gravações aparecem aqui.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Ligação perdida',
      'incoming': 'Ligação recebida',
      'other': 'Ligação realizada',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Ligar para $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Adicione uma conta para enviar mensagens';

  @override
  String get recentsAddContact => 'Adicionar contato';

  @override
  String get recentsContact => 'Contato';

  @override
  String get recentsBlock => 'Bloquear';

  @override
  String get recentsUnblock => 'Desbloquear';

  @override
  String recentsBlockTitle(String number) {
    return 'Bloquear $number?';
  }

  @override
  String get recentsBlockMessage =>
      'As ligações deste número serão rejeitadas automaticamente.';

  @override
  String get recentsQualityHeader => 'Qualidade da ligação';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Pior MOS $mos   ·   Jitter $jitter ms   ·   Perda $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Gravações';

  @override
  String get recentsOpenInRecordings => 'Abrir em Gravações';

  @override
  String recentsRelatedCall(String title) {
    return 'Ligação relacionada: $title';
  }

  @override
  String get recentsHistoryHeader => 'Histórico';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'Nenhuma ligação com este número';

  @override
  String get recentsDeleteTitle => 'Excluir estas ligações?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count registros de $name.',
      one: 'Remove 1 registro de $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Excluir do histórico';

  @override
  String get recentsCallDetails => 'Detalhes da ligação';

  @override
  String get contactsFavoritesHeader => '★ Favoritos';

  @override
  String get contactsFavoritesOnly => 'Somente favoritos';

  @override
  String get contactsShowAll => 'Mostrar todos';

  @override
  String get contactsImportExportTooltip => 'Importar e exportar';

  @override
  String get contactsMenuDevice => 'Importar do dispositivo';

  @override
  String get contactsMenuFile => 'Importar arquivo vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Importar da área de transferência';

  @override
  String get contactsMenuCopyVcard => 'Copiar como vCard';

  @override
  String get contactsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get contactsNewTooltip => 'Novo contato';

  @override
  String get contactsSearchHint => 'Buscar contatos';

  @override
  String get contactsEmptyTitle => 'Nenhum contato ainda';

  @override
  String get contactsEmptySubtitle =>
      'Adicione as pessoas para quem você mais liga ou importe um arquivo vCard ou CSV.';

  @override
  String get contactsEmptyAction => 'Adicionar um contato';

  @override
  String get contactsNoMatches => 'Nenhum resultado';

  @override
  String contactsCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get contactsSelect => 'Selecione um contato';

  @override
  String get contactsCopiedVcard => 'Contatos copiados como vCard';

  @override
  String get contactsCopiedCsv => 'Contatos copiados como CSV';

  @override
  String get contactsDeviceDenied =>
      'O acesso aos contatos foi negado. Permita-o nos ajustes do sistema para importar.';

  @override
  String get contactsDeviceNone =>
      'Nenhum contato encontrado neste dispositivo';

  @override
  String contactsNothingNew(int count) {
    return 'Nada novo para importar ($count já existente(s))';
  }

  @override
  String get contactsImportDeviceTitle => 'Importar do dispositivo?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos novos',
      one: '1 contato novo',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count atualizado(s) com números extras';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count ignorado(s) (duplicados ou sem número de telefone)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatos importados',
      one: '1 contato importado',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'Nenhum contato encontrado nesses dados';

  @override
  String get contactsLabelMobile => 'celular';

  @override
  String get contactsLabelWork => 'trabalho';

  @override
  String get contactsLabelHome => 'casa';

  @override
  String get contactsLabelOther => 'outro';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contato não encontrado';

  @override
  String get contactsActionFavorite => 'Favorito';

  @override
  String get contactsNumbersHeader => 'Números';

  @override
  String get contactsSipAddress => 'Endereço SIP';

  @override
  String get contactsDetailsHeader => 'Detalhes';

  @override
  String get contactsOnBlf => 'Exibido no painel BLF';

  @override
  String get contactsAlwaysRecorded => 'As ligações são sempre gravadas';

  @override
  String contactsDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get contactsDeleteMessage =>
      'Este contato será removido deste dispositivo.';

  @override
  String get contactsDeleteButton => 'Excluir contato';

  @override
  String get contactsDetailTitle => 'Contato';

  @override
  String get contactsErrorNameOrNumber => 'Digite um nome ou um número';

  @override
  String get contactsEditTitle => 'Editar contato';

  @override
  String get contactsFieldName => 'Nome';

  @override
  String get contactsFieldCompany => 'Empresa';

  @override
  String get contactsFieldNumber => 'Número';

  @override
  String get contactsRemoveNumber => 'Remover número';

  @override
  String get contactsAddNumber => 'Adicionar número';

  @override
  String get contactsSipHeader => 'Endereços SIP';

  @override
  String get contactsRemoveAddress => 'Remover endereço';

  @override
  String get contactsAddSip => 'Adicionar endereço SIP';

  @override
  String get contactsFieldEmail => 'E-mail';

  @override
  String get contactsFieldNotes => 'Observações';

  @override
  String get contactsFieldFavorite => 'Favorito';

  @override
  String get contactsShowOnBlf => 'Mostrar no painel BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Monitorar a presença e a lâmpada de ocupado deste ramal';

  @override
  String get contactsAlwaysRecordTitle =>
      'Sempre gravar ligações com este contato';

  @override
  String get contactsAlwaysRecordSub =>
      'Substitui as regras de gravação automática';

  @override
  String get contactsRingtone => 'Toque';

  @override
  String get contactsPresenceVia => 'Presença pela conta';

  @override
  String get contactsDefaultAccount => 'Conta padrão';

  @override
  String get contactsDeleteContactTitle => 'Excluir contato?';

  @override
  String get contactsCannotUndo => 'Esta ação não pode ser desfeita.';

  @override
  String get messagesNewMessage => 'Nova mensagem';

  @override
  String get messagesNumberOrSip => 'Número ou endereço SIP';

  @override
  String get messagesNoConversations => 'Nenhuma conversa';

  @override
  String get messagesEmptySubtitle =>
      'Envie uma mensagem SIP para qualquer ramal ou endereço das suas contas.';

  @override
  String get messagesTyping => 'digitando...';

  @override
  String get messagesYouPrefix => 'Você: ';

  @override
  String get messagesSelect => 'Selecione uma conversa';

  @override
  String get messagesLanOnline => 'Online na sua rede';

  @override
  String get messagesLanOffline =>
      'Offline. As mensagens são enviadas quando ele voltar.';

  @override
  String messagesSendFileTo(String name) {
    return 'Enviar um arquivo para $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Ligar para $name';
  }

  @override
  String get messagesDeleteTitle => 'Excluir conversa?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Todas as mensagens com $name serão removidas.';
  }

  @override
  String get messagesDeleteMenu => 'Excluir conversa';

  @override
  String get messagesSayHello => 'Diga olá';

  @override
  String get messagesLanEmptySub =>
      'As mensagens vão direto para este dispositivo pela sua rede, com criptografia de ponta a ponta.';

  @override
  String get messagesSipEmptySub =>
      'As mensagens são enviadas com SIP MESSAGE pela sua conta.';

  @override
  String get messagesInputHint => 'Mensagem';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesStatusSending => 'Enviando';

  @override
  String get messagesStatusSent => 'Enviada';

  @override
  String get messagesStatusDelivered => 'Entregue';

  @override
  String get messagesStatusRead => 'Lida';

  @override
  String get messagesStatusFailed => 'Falhou';

  @override
  String get messagesNotDelivered =>
      'Não entregue. Toque para tentar novamente';

  @override
  String get uiStatusRegistered => 'Registrada';

  @override
  String get uiStatusRegistering => 'Registrando';

  @override
  String get uiStatusRegFailed => 'Falha no registro';

  @override
  String get uiStatusDisabled => 'Desativada';

  @override
  String get uiQualityMeasuring => 'Medindo';

  @override
  String get uiQualityExcellent => 'Excelente';

  @override
  String get uiQualityGood => 'Boa';

  @override
  String get uiQualityFair => 'Razoável';

  @override
  String get uiQualityPoor => 'Ruim';

  @override
  String get uiQualityBad => 'Péssima';

  @override
  String uiQualitySemantics(String label) {
    return 'Qualidade da ligação: $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Qualidade da ligação: $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Qualidade da ligação: $label';
  }

  @override
  String get uiSecureFull => 'Criptografada';

  @override
  String get uiSecureMedia => 'Mídia criptografada';

  @override
  String get uiSecureSignalling => 'Sinalização criptografada';

  @override
  String get uiSecureNone => 'Sem criptografia';

  @override
  String get uiSecureSrtpLine => 'Mídia SRTP';

  @override
  String get uiSecureTlsLine => 'Sinalização TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Repassando para $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Interfone para $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Interfone para um dispositivo próximo';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Interfone de $name';
  }

  @override
  String get lanCallIntercomFromUnnamed =>
      'Interfone de um dispositivo próximo';

  @override
  String lanCallToNamed(String name) {
    return 'Ligação LAN para $name';
  }

  @override
  String get lanCallToUnpaired => 'Ligação LAN para um dispositivo não pareado';

  @override
  String lanCallFromNamed(String name) {
    return 'Ligação LAN de $name';
  }

  @override
  String get lanCallFromUnpaired => 'Ligação LAN de um dispositivo não pareado';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Ligação transferida de $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Ligação transferida de $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'outro dispositivo';

  @override
  String lanRelayedTitle(String name) {
    return 'Retransmitida para $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Quem ligou está falando com $name. Você não está na ligação.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Ligando para $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Quem ligou continua conectado enquanto $name atende.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Consultando $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Aguardando que aceitem a ligação.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Falando com $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Quem ligou está em espera. Conclua o repasse quando estiver pronto.';

  @override
  String get lanRelayTakingBack => 'Retomando a ligação...';

  @override
  String get lanRelayTakeBack => 'Retomar';

  @override
  String get lanRelayEnd => 'Encerrar';

  @override
  String get lanSendToDevice => 'Enviar ao dispositivo';

  @override
  String get lanBusy => 'Ocupado';

  @override
  String get lanNoPairedOnline => 'Nenhum dispositivo pareado está online';

  @override
  String lanPairRejectedBy(String name) {
    return '$name rejeitou o pareamento.';
  }

  @override
  String get lanPairRejected => 'Pareamento rejeitado.';

  @override
  String get lanPairCancelled => 'Pareamento cancelado.';

  @override
  String get lanPairTimedOut =>
      'Tempo do pareamento esgotado. Tente novamente.';

  @override
  String get lanPairFailed => 'Falha no pareamento';

  @override
  String lanPairFailedReason(String reason) {
    return 'Falha no pareamento: $reason';
  }

  @override
  String get lanPairThisDevice => 'este dispositivo';

  @override
  String get lanPairConnecting => 'Conectando com segurança...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name quer parear com este dispositivo.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Pareando com $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Confirme se este código é o mesmo nas duas telas.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Código de pareamento $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Aguardando a confirmação de $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name confirmou.';
  }

  @override
  String get lanPairReject => 'Rejeitar';

  @override
  String get lanPairCodesMatch => 'Os códigos coincidem';

  @override
  String lanPairPairedWith(String name) {
    return 'Pareado com $name.';
  }

  @override
  String get lanPairRequestTitle => 'Solicitação de pareamento';

  @override
  String lanPairTitle(String name) {
    return 'Parear com $name';
  }

  @override
  String get lanActionDecline => 'Recusar';

  @override
  String get lanActionAccept => 'Aceitar';

  @override
  String get lanFileIncomingTitle => 'Arquivo recebido';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size de $name';
  }

  @override
  String get lanHandoffOfferTitle => 'Transferir uma ligação para cá?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' de $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' em $account',
    });
    return '$device quer passar uma ligação para você$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Eles falarão com você primeiro.';

  @override
  String get lanHandoffTakeCall => 'Atender';

  @override
  String lanIntercomRequestTitle(String name) {
    return 'Permitir interfone de $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'A ligação será atendida automaticamente no viva-voz.';

  @override
  String get lanIntercomDeny => 'Negar';

  @override
  String get lanIntercomAllow => 'Permitir';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name removeu este dispositivo da lista de pareados';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviando $count arquivos...',
      one: 'Enviando $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nova mensagem';

  @override
  String get lanSipMessage => 'Mensagem SIP';

  @override
  String get lanSipMessageSub => 'Para um número ou endereço pela sua conta';

  @override
  String get lanChatOnline => 'Chat LAN, online';

  @override
  String get lanChatOffline => 'Chat LAN, offline';

  @override
  String lanSavedAt(String path) {
    return 'Salvo em $path (caminho copiado)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Seus dispositivos, conversando diretamente';

  @override
  String get lanConnectByAddress => 'Conectar por endereço';

  @override
  String get lanSettingsTooltip => 'Ajustes da LAN';

  @override
  String get lanOffTitle => 'O LAN Link está desativado';

  @override
  String get lanOffSubtitle =>
      'Encontre seus outros dispositivos com SoftphonePro, converse, envie arquivos e repasse ligações, sem nenhum servidor.';

  @override
  String get lanTurnOn => 'Ativar LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'Não foi possível iniciar o LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'Digite host:porta ou cole o texto do código QR exibido no outro dispositivo.';

  @override
  String get lanScanTitle => 'Ler QR de pareamento LAN';

  @override
  String get lanScanQr => 'Ler QR';

  @override
  String get lanPaste => 'Colar';

  @override
  String get lanConnect => 'Conectar';

  @override
  String lanConnectedTo(String name) {
    return 'Conectado a $name';
  }

  @override
  String get lanCouldNotConnect => 'Não foi possível conectar';

  @override
  String get lanCouldNotStartPairing => 'Não foi possível iniciar o pareamento';

  @override
  String get lanThisDevice => 'Este dispositivo';

  @override
  String get lanDeviceNameTitle => 'Nome do dispositivo';

  @override
  String get lanStarting => 'Iniciando...';

  @override
  String get lanVisible => 'Visível na sua rede';

  @override
  String get lanNotRunning => 'Não está em execução';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contas compartilhadas',
      one: '1 conta compartilhada',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Impressão digital';

  @override
  String get lanHideQr => 'Ocultar código QR';

  @override
  String get lanShowQr => 'Mostrar código QR para conectar outro dispositivo';

  @override
  String get lanCopyConnectionText => 'Copiar texto de conexão';

  @override
  String get lanConnectionTextCopied => 'Texto de conexão copiado';

  @override
  String get lanActiveOnOthers => 'Ativas em seus outros dispositivos';

  @override
  String get lanPairedDevices => 'Dispositivos pareados';

  @override
  String get lanNoPaired =>
      'Nenhum dispositivo pareado ainda. Pareie um dispositivo próximo para conversar, enviar arquivos e repassar ligações.';

  @override
  String get lanNearby => 'Próximos';

  @override
  String get lanNearbyHint =>
      'Procurando o SoftphonePro na sua rede. Os outros dispositivos precisam estar com o LAN Link ativado. Você também pode conectar por endereço com o botão de link acima.';

  @override
  String get lanTransfers => 'Transferências';

  @override
  String get lanFiles => 'Arquivos';

  @override
  String get lanPairedBadge => 'Pareado';

  @override
  String get lanTyping => 'digitando...';

  @override
  String get lanPair => 'Parear';

  @override
  String get lanUnpair => 'Desparear';

  @override
  String lanUnpairTitle(String name) {
    return 'Desparear $name?';
  }

  @override
  String get lanUnpairMessage =>
      'Você precisará parear novamente para conversar, enviar arquivos ou repassar ligações.';

  @override
  String get lanActionMessage => 'Mensagem';

  @override
  String get lanActionSendFile => 'Enviar arquivo';

  @override
  String get lanActionCall => 'Ligar';

  @override
  String get lanActionIntercom => 'Interfone';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Ativa em $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Ativa em $device  ·  $account';
  }

  @override
  String get lanPull => 'Puxar';

  @override
  String get lanTransferPreparing => 'Preparando...';

  @override
  String get lanTransferWaitingYou => 'Aguardando você';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Aguardando $name aceitar';
  }

  @override
  String lanTransferProgress(String done, String total) {
    return '$done de $total';
  }

  @override
  String get lanTransferVerifying => 'Verificando...';

  @override
  String lanTransferFrom(String name, String status) {
    return 'De $name  ·  $status';
  }

  @override
  String lanTransferTo(String name, String status) {
    return 'Para $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  de $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  para $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Falhou: $error';
  }

  @override
  String get lanFileActions => 'Ações do arquivo';

  @override
  String get lanPathCopied => 'Caminho copiado';

  @override
  String get lanFileOpen => 'Abrir';

  @override
  String get lanFileShowInFolder => 'Mostrar na pasta';

  @override
  String get lanFileCopyPath => 'Copiar caminho';

  @override
  String lanNetworkError(String message) {
    return 'Erro de rede: $message';
  }

  @override
  String get lanErrNotRunning => 'Ative o LAN Link primeiro';

  @override
  String get lanErrBadAddress =>
      'Digite um endereço como 192.168.1.20:4711 ou cole o texto do código QR';

  @override
  String get lanErrFingerprint =>
      'Esse dispositivo não corresponde ao código lido. O código QR veio de outro dispositivo?';

  @override
  String lanNoticeReceived(String file, String name) {
    return '$file recebido de $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return '$file enviado para $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name recusou $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Falha na transferência do arquivo: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Ative o LAN Link para ligar para dispositivos próximos';

  @override
  String get lanNoticePairFirst => 'Pareie com este dispositivo primeiro';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name não pode receber ligações no momento';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Consultando $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name não permitiu o interfone (ou não respondeu)';
  }

  @override
  String get lanHoOff => 'O LAN Link está desativado';

  @override
  String get lanHoPairFirst => 'Pareie com esse dispositivo primeiro';

  @override
  String lanHoOffline(String name) {
    return '$name está offline';
  }

  @override
  String get lanHoAlready => 'Esta ligação já está sendo repassada';

  @override
  String get lanHoEnded => 'A ligação já foi encerrada';

  @override
  String get lanHoWaitConnected => 'Aguarde até a ligação ser conectada';

  @override
  String get lanHoLanCall => 'Ligações LAN não podem ser repassadas';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name não pode receber ligações pela rede (as ligações LAN estão desativadas lá)';
  }

  @override
  String get lanHoNoLanHere =>
      'As ligações LAN não estão disponíveis neste dispositivo';

  @override
  String lanHoDeclined(String name) {
    return '$name recusou a ligação. Ela continua com você.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name não respondeu. A ligação continua com você.';
  }

  @override
  String get lanHoCancelled =>
      'O repasse foi cancelado. A ligação continua com você.';

  @override
  String lanHoUnreachable(String name) {
    return 'Não foi possível alcançar $name. A ligação continua com você.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'Não foi possível alcançar $name ($reason). A ligação continua com você.';
  }

  @override
  String get lanHoEndedBefore =>
      'A ligação terminou antes de poder ser repassada';

  @override
  String lanHoPbxRefused(String name) {
    return 'O sistema telefônico recusou a transferência e $name não pode receber ligações LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Falha na transferência pelo sistema telefônico. Retransmitindo pela rede.';

  @override
  String lanHoSentTo(String name) {
    return 'Ligação enviada para $name';
  }

  @override
  String get lanHoConsultFailed =>
      'Não foi possível ligar para o outro dispositivo pelo sistema telefônico';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name não está mais acessível';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'Não foi possível atender a ligação para repassá-la';

  @override
  String lanHoCouldNotCall(String name) {
    return 'Não foi possível ligar para $name pela rede. A ligação continua com você.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name não atendeu. A ligação continua com você.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Repassada para $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Ligação retransmitida para $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Aguarde $name atender primeiro';
  }

  @override
  String get lanHoFailed => 'Falha ao repassar';

  @override
  String lanHoTakenBack(String name) {
    return 'Ligação retomada de $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name encerrou a consulta. A ligação voltou para você.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'Não foi possível repassar a ligação para $name';
  }

  @override
  String get diagSip400Explain =>
      'O servidor não conseguiu entender a requisição.';

  @override
  String get diagSip400Fix =>
      'Verifique as configurações da conta (domínio, usuário, proxy). Se persistir, envie um rastreamento SIP ao seu provedor.';

  @override
  String get diagSip401Explain =>
      'O servidor rejeitou as credenciais (ou está solicitando-as).';

  @override
  String get diagSip401Fix =>
      'Verifique o usuário, o usuário de autenticação e a senha. Alguns provedores usam um \"auth ID\" separado.';

  @override
  String get diagSip403Explain =>
      'O servidor entendeu a requisição, mas a recusa: senha incorreta, conta desativada ou seu IP não é permitido.';

  @override
  String get diagSip403Fix =>
      'Digite a senha novamente, verifique se a conta está ativa e confirme que seu IP público não está bloqueado (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'O servidor não conhece este usuário ou número.';

  @override
  String get diagSip404Fix =>
      'Verifique o usuário e o domínio; para ligações, verifique o número discado e as regras de discagem.';

  @override
  String get diagSip405Explain => 'O servidor não aceita esta requisição.';

  @override
  String get diagSip405Fix =>
      'Geralmente inofensivo para pings OPTIONS. Para REGISTER, verifique se você está falando com um registrar SIP.';

  @override
  String get diagSip407Explain => 'O proxy de saída exige credenciais.';

  @override
  String get diagSip407Fix =>
      'Verifique a senha da conta e as configurações do proxy de saída.';

  @override
  String get diagSip408Explain => 'O servidor não respondeu a tempo.';

  @override
  String get diagSip408Fix =>
      'Verifique o endereço e a porta do servidor e os firewalls, e tente TCP ou TLS. Tempos esgotados repetidos apenas em UDP podem indicar SIP ALG no roteador.';

  @override
  String get diagSip410Explain => 'O número não existe mais.';

  @override
  String get diagSip410Fix => 'Verifique o número discado.';

  @override
  String get diagSip415Explain =>
      'O outro lado não aceita o tipo de conteúdo ou os codecs oferecidos.';

  @override
  String get diagSip415Fix =>
      'Ative mais codecs (ex.: PCMU/PCMA) em Ajustes > Codecs.';

  @override
  String get diagSip421Explain =>
      'O servidor exige uma extensão SIP que este cliente não ofereceu.';

  @override
  String get diagSip421Fix =>
      'Verifique as opções de NAT/ICE/100rel/temporizadores da conta.';

  @override
  String get diagSip423Explain =>
      'A expiração do registro é menor do que o servidor permite.';

  @override
  String get diagSip423Fix =>
      'Aumente a expiração do registro nas configurações da conta.';

  @override
  String get diagSip480Explain =>
      'O usuário não está registrado ou não pode ser alcançado agora.';

  @override
  String get diagSip480Fix =>
      'Verifique se a outra parte está registrada; no registro, o servidor pode estar sobrecarregado: tente novamente mais tarde.';

  @override
  String get diagSip481Explain =>
      'O servidor perdeu o estado do diálogo (ex.: após uma reinicialização ou mudança de rede).';

  @override
  String get diagSip481Fix =>
      'Desligue e tente novamente. Se for frequente, ative os temporizadores de sessão.';

  @override
  String get diagSip483Explain => 'A requisição circulou entre servidores.';

  @override
  String get diagSip483Fix =>
      'Verifique a configuração de desvio e roteamento no PBX.';

  @override
  String get diagSip484Explain => 'O número discado é curto demais.';

  @override
  String get diagSip484Fix =>
      'Disque o número completo ou verifique as regras de discagem.';

  @override
  String get diagSip486Explain => 'A outra parte está ocupada.';

  @override
  String get diagSip486Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip487Explain =>
      'A ligação foi cancelada antes de ser atendida.';

  @override
  String get diagSip487Fix => 'Normal quando quem liga desliga enquanto toca.';

  @override
  String get diagSip488Explain =>
      'Nenhum codec ou configuração de criptografia em comum com o outro lado.';

  @override
  String get diagSip488Fix =>
      'Verifique os codecs e o SRTP (uma conta com SRTP obrigatório não consegue ligar para um endpoint RTP simples).';

  @override
  String get diagSip491Explain => 'Dois re-INVITEs colidiram.';

  @override
  String get diagSip491Fix => 'Normalmente repetido automaticamente.';

  @override
  String get diagSip500Explain => 'O servidor falhou internamente.';

  @override
  String get diagSip500Fix =>
      'Tente novamente mais tarde e contate o provedor se continuar.';

  @override
  String get diagSip502Explain =>
      'Um servidor upstream retornou uma resposta inválida.';

  @override
  String get diagSip502Fix =>
      'Tente novamente mais tarde; contate o provedor se continuar.';

  @override
  String get diagSip503Explain =>
      'O servidor está sobrecarregado, fora do ar ou rejeitando este cliente (limite de taxa).';

  @override
  String get diagSip503Fix =>
      'Aguarde e tente novamente, consulte a página de status do provedor ou tente outro servidor/porta.';

  @override
  String get diagSip504Explain => 'Um servidor upstream não respondeu a tempo.';

  @override
  String get diagSip504Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip600Explain => 'Todos os destinos estão ocupados.';

  @override
  String get diagSip600Fix => 'Tente novamente mais tarde.';

  @override
  String get diagSip603Explain => 'A outra parte rejeitou a ligação.';

  @override
  String get diagSip603Fix => 'Nada a corrigir: a ligação foi recusada.';

  @override
  String get diagSip604Explain => 'O número não existe.';

  @override
  String get diagSip604Fix => 'Verifique o número discado.';

  @override
  String get diagSip606Explain =>
      'A outra parte não pode aceitar a sessão como foi oferecida.';

  @override
  String get diagSip606Fix =>
      'Verifique os codecs e as configurações de criptografia.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provisória ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'A requisição está sendo processada.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Sucesso ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'A requisição foi bem-sucedida.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Redirecionada ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'O destino mudou de lugar.';

  @override
  String get diagSipRedirectedFix => 'Verifique as configurações de desvio.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Erro do cliente ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'O servidor rejeitou a requisição.';

  @override
  String get diagSipClientErrorFix => 'Verifique a conta e o número discado.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Erro do servidor ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'O servidor falhou ao processar a requisição.';

  @override
  String get diagSipServerErrorFix =>
      'Tente novamente mais tarde ou contate o provedor.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Falha global ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'A requisição não pode ser atendida em lugar nenhum.';

  @override
  String get diagSipNoResponseTitle => 'Sem resposta';

  @override
  String get diagSipNoResponseExplain => 'Nenhuma resposta SIP foi recebida.';

  @override
  String get diagSipNoResponseFix =>
      'Verifique a conexão de rede e o endereço do servidor.';

  @override
  String get diagWizStepNet => 'Conectividade de rede';

  @override
  String diagWizStepDns(String account) {
    return 'DNS e SRV: $account';
  }

  @override
  String get diagWizStepNat => 'Tipo de NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Alcance do servidor: $account';
  }

  @override
  String diagWizStepTls(String account) {
    return 'Certificado TLS: $account';
  }

  @override
  String diagWizStepReg(String account) {
    return 'Registro: $account';
  }

  @override
  String get diagWizStepAlg => 'Verificação de SIP ALG';

  @override
  String get diagWizChecking => 'Verificando...';

  @override
  String diagWizEngineError(String message) {
    return 'Erro do mecanismo: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Falha na verificação: $error';
  }

  @override
  String get diagWizNoEngine => 'O mecanismo SIP não está em execução';

  @override
  String get diagWizNoEngineFix =>
      'Aguarde o mecanismo iniciar (ou reinicie o app) e execute as verificações novamente.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privado)';
  }

  @override
  String get diagWizNetNone =>
      'Nenhuma interface de rede ativa com endereço IP';

  @override
  String get diagWizNetNoneFix =>
      'Conecte-se ao Wi-Fi, Ethernet ou dados móveis e execute as verificações novamente.';

  @override
  String get diagWizNetIpv6Only => 'Apenas endereços IPv6 encontrados';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Muitos provedores SIP são somente IPv4. Ative o IPv4 nesta rede ou use um provedor com suporte a IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 endereços IPv4',
      one: '1 endereço IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interface',
    );
    return '$_temp0 em $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Uma interface do tipo VPN está ativa. As VPNs podem adicionar latência ou bloquear UDP; desative-a se as ligações apresentarem problemas.';

  @override
  String get diagWizDnsNoServer => 'A conta não tem endereço de servidor';

  @override
  String get diagWizDnsNoServerFix => 'Edite a conta e informe o domínio SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host é um endereço IP, DNS não é necessário';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: nenhum';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: nenhum ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: nenhum';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (prioridade $priority, peso $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: falha na consulta ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host não é resolvido';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Verifique se o domínio tem erros de digitação e se o seu servidor DNS funciona. Você pode definir um servidor DNS personalizado em Ajustes > Rede (ex.: 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host tem registros SRV, mas nenhum registro de endereço';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Os destinos SRV serão usados. Se as ligações falharem, peça ao provedor que verifique o registro A.';

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
      other: ', $srv registros SRV',
      one: ', 1 registro SRV',
      zero: '',
    );
    return '$host é resolvido para $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Tempo esgotado na detecção de NAT';

  @override
  String get diagWizNatTimeoutFix =>
      'O servidor STUN pode estar inacessível (UDP bloqueado?). Verifique Ajustes > Rede > Servidores STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'Servidor STUN: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Sem NAT: este dispositivo tem um endereço público';

  @override
  String get diagWizNatFullCone => 'NAT full cone: favorável a VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT restricted cone: funciona com STUN e keep-alives';

  @override
  String get diagWizNatPortRestricted =>
      'NAT port-restricted cone: funciona com STUN e keep-alives';

  @override
  String get diagWizNatSymmetric =>
      'NAT simétrico: o STUN sozinho não consegue prever a porta de mídia';

  @override
  String get diagWizNatSymmetricFix =>
      'É provável haver áudio unidirecional ou ausência de áudio em algumas ligações. Ative o ICE e um relay TURN nas configurações da conta (Conta > NAT) ou use um provedor/PBX com relay de mídia (rtpengine).';

  @override
  String get diagWizNatBlocked => 'O UDP parece estar bloqueado';

  @override
  String get diagWizNatBlockedFix =>
      'Use o transporte TCP ou TLS na conta. Se a rede filtra tudo exceto tráfego web, tente TLS na porta 443, se o seu provedor aceitar.';

  @override
  String get diagWizNatUnknown => 'Não foi possível determinar o tipo de NAT';

  @override
  String get diagWizNatUnknownFix =>
      'O servidor STUN não respondeu. Tente outro servidor STUN em Ajustes > Rede.';

  @override
  String get diagWizNatErr =>
      'O servidor STUN não respondeu, por isso não foi possível determinar o tipo de NAT.';

  @override
  String get diagWizNatUnknownRaw =>
      'Não foi possível determinar o tipo de NAT.';

  @override
  String get diagWizOptionsNotLoaded =>
      'A conta não está carregada no mecanismo';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Sem resposta ao OPTIONS em $seconds s (transporte: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'O servidor não está acessível. Verifique o endereço e a porta, se um firewall não está descartando SIP, e tente outro transporte (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Tempo da requisição esgotado ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'O servidor respondeu $code $reason após $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'O servidor respondeu $code $reason em $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Um $code em resposta ao OPTIONS é normal: o servidor está acessível, mas não permite sondagens anônimas.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Um tempo de ida e volta acima de 300 ms adiciona atraso perceptível às conversas. Um servidor mais próximo ou uma conexão com fio ajudam.';

  @override
  String get diagWizTlsRejected => 'O certificado do servidor foi rejeitado';

  @override
  String diagWizTlsSubject(String value) {
    return 'Assunto: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Emissor: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problemas: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Expira em: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cifra: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Se este for o seu próprio PBX com certificado autoassinado e a impressão digital acima coincidir, você pode confiar nele. Caso contrário, peça ao provedor um certificado de uma CA pública.';

  @override
  String get diagWizTlsTrust => 'Confiar neste certificado';

  @override
  String diagWizTlsExpired(String date) {
    return 'O certificado expirou em $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Peça ao administrador do servidor que renove o certificado.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'O certificado expira em $days dias',
      one: 'O certificado expira em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Avise o administrador do servidor para renová-lo em breve.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Conectado, mas a verificação informou: $problems';
  }

  @override
  String get diagWizTlsOk => 'Conexão TLS estabelecida, certificado válido';

  @override
  String get diagWizTlsRegistered =>
      'Registrado via TLS (nenhum detalhe de certificado informado)';

  @override
  String get diagWizTlsNone => 'Nenhuma conexão TLS foi observada ainda';

  @override
  String get diagWizTlsNoneFix =>
      'Verifique a porta TLS (geralmente 5061) e se o servidor aceita TLS 1.2 ou mais recente.';

  @override
  String get diagWizRegDisabledByConfig =>
      'O registro está desativado para esta conta (uso ponto a ponto)';

  @override
  String get diagWizRegRegistered => 'Registrada';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registrada (expira em $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transporte: $transport';
  }

  @override
  String get diagWizRegInProgress => 'O registro ainda está em andamento';

  @override
  String get diagWizRegInProgressFix =>
      'Aguarde alguns segundos. Se nunca terminar, o servidor não está respondendo; veja a verificação de alcance acima.';

  @override
  String get diagWizRegFailed => 'Falha no registro';

  @override
  String get diagWizRegOffline => 'A conta está offline';

  @override
  String get diagWizRegOfflineFix =>
      'Verifique a conexão de rede. O app tenta novamente de forma automática.';

  @override
  String get diagWizRegDisabled => 'A conta está desativada';

  @override
  String get diagWizAlgNoUdp =>
      'Nenhuma conta usa UDP, portanto o SIP ALG não é um problema';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: sem resposta via UDP, mas o TCP respondeu ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: sem resposta via UDP ou TCP (problema de servidor ou firewall, e não de ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: o OPTIONS é respondido, mas o REGISTER esgota o tempo, o que é típico de um roteador reescrevendo o SIP';
  }

  @override
  String get diagWizAlgSuspected => 'Suspeita de SIP ALG no seu roteador';

  @override
  String get diagWizAlgSuspectedFix =>
      'Desative \"SIP ALG\" / \"SIP helper\" nas configurações do roteador, mude a conta para TCP ou TLS, ou altere a porta SIP (ex.: 5080) para que o roteador pare de alterar os pacotes.';

  @override
  String get diagWizAlgContactChanged =>
      'O endereço Contact mudou entre a requisição e a resposta';

  @override
  String get diagWizAlgContactChangedFix =>
      'Isso pode ser um SIP ALG ou um servidor que reescreve contatos. Se as ligações tocam, mas ficam sem áudio ou caem depois de um tempo, desative o SIP ALG no roteador ou use TCP/TLS ou a porta 5080.';

  @override
  String get diagWizAlgOk => 'Nenhum sinal de interferência de SIP ALG';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'O Contact do REGISTER $sent voltou como $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Salvar $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return '$fileName salvo';
  }

  @override
  String get diagSaveFailed => 'Não foi possível salvar o arquivo';

  @override
  String get diagCopiedText => 'Texto copiado para a área de transferência';

  @override
  String get diagCopiedReport =>
      'Relatório copiado para a área de transferência';

  @override
  String get diagCopiedBundle =>
      'Pacote de diagnóstico copiado para a área de transferência';

  @override
  String get diagCopiedLogs => 'Logs copiados para a área de transferência';

  @override
  String get diagCopiedTrace =>
      'Rastreamento copiado para a área de transferência';

  @override
  String get diagCopiedDialog => 'Diálogo copiado para a área de transferência';

  @override
  String get diagSaveAsLog => 'Salvar como .log';

  @override
  String get diagSysAppVersion => 'Versão do app';

  @override
  String get diagSysPlatform => 'Plataforma';

  @override
  String get diagSysEngine => 'Mecanismo';

  @override
  String get diagSysAccounts => 'Contas';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered de $total registradas';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'Não foi possível ler as informações do sistema: $error';
  }

  @override
  String get diagSysTransports => 'Transportes';

  @override
  String get diagSysNoneReported => 'Nenhum informado';

  @override
  String get diagSysCodecs => 'Codecs';

  @override
  String get diagSysCodecsFooter =>
      'Codecs ativados, da maior para a menor prioridade.';

  @override
  String get diagSysEngineNotRunning => 'Mecanismo não está em execução';

  @override
  String diagSysCodecPriority(int priority) {
    return 'prioridade $priority';
  }

  @override
  String get diagSysCodecDisabled => 'desativado';

  @override
  String get diagSysExport => 'Exportar';

  @override
  String get diagSysExportFooter =>
      'O pacote contém informações do sistema, resultados da verificação de rede, logs recentes e o rastreamento SIP, com as credenciais ocultadas.';

  @override
  String get diagSysCopyBundle => 'Copiar pacote de diagnóstico';

  @override
  String get diagSysSaveBundle => 'Salvar pacote de diagnóstico';

  @override
  String get diagTabSipTrace => 'Rastreamento SIP';

  @override
  String get diagTabNetwork => 'Rede';

  @override
  String get diagTabQuality => 'Qualidade';

  @override
  String get diagTabAudioTest => 'Teste de áudio';

  @override
  String get diagTabLogs => 'Logs';

  @override
  String get diagTabSystem => 'Sistema';

  @override
  String diagRawSentTo(String remote) {
    return 'enviada para $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'recebida de $remote';
  }

  @override
  String get diagRawCopied => 'Mensagem copiada';

  @override
  String get diagRawLadder => 'Sequência';

  @override
  String get diagRawRedact => 'Ocultar credenciais';

  @override
  String diagRawTruncated(int count) {
    return '... truncada ($count caracteres)';
  }

  @override
  String get diagWizIntro =>
      'Verifica sua conexão, DNS, NAT, alcance do servidor, TLS e registro, e explica o que corrigir.';

  @override
  String get diagWizStop => 'Parar';

  @override
  String get diagWizRunChecks => 'Executar verificações';

  @override
  String get diagWizRunAgain => 'Executar de novo';

  @override
  String get diagWizCopyReport => 'Copiar relatório';

  @override
  String get diagWizSaveReport => 'Salvar relatório';

  @override
  String diagWizCountPassed(int count) {
    return 'Aprovadas $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Avisos $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Falhas $count';
  }

  @override
  String get diagWizStatusPass => 'Aprovada';

  @override
  String get diagWizStatusWarn => 'Aviso';

  @override
  String get diagWizStatusFail => 'Falhou';

  @override
  String get diagWizStatusSkipped => 'Ignorada';

  @override
  String get diagWizStatusRunning => 'Em execução';

  @override
  String get diagWizStatusPending => 'Pendente';

  @override
  String get diagQualityTitle => 'Qualidade da ligação';

  @override
  String get diagQualityNoData =>
      'Nenhum dado de qualidade foi registrado para esta ligação.';

  @override
  String get diagQualityTraceForCall => 'Rastreamento SIP desta ligação';

  @override
  String get diagQualityTraceNotCaptured =>
      'Rastreamento SIP não capturado para esta ligação';

  @override
  String get diagQualityLiveCall => 'Ligação ao vivo';

  @override
  String get diagQualityNoActiveCall =>
      'Nenhuma ligação ativa. Inicie uma ligação e o MOS, o jitter, a perda e o tempo de ida e volta serão exibidos aqui ao vivo.';

  @override
  String get diagQualityRecentCalls => 'Ligações recentes';

  @override
  String get diagQualityNoFinished =>
      'Ainda não há ligações concluídas com dados de qualidade.';

  @override
  String get diagQualityCallEnded => 'A ligação terminou.';

  @override
  String get diagQualityMeasuring => 'medindo';

  @override
  String diagQualityMosSemantics(String value, String quality) {
    return 'MOS $value, $quality';
  }

  @override
  String diagQualityChartSemantics(String title) {
    return 'Gráfico de $title';
  }

  @override
  String diagQualityChartSemanticsLatest(String title, String value) {
    return 'Gráfico de $title, mais recente $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   máx. $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Média $avg  ·  pior $worst';
  }

  @override
  String get diagQualityCodec => 'Codec';

  @override
  String get diagQualityLoss => 'Perda';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count pcts';
  }

  @override
  String get diagQualityMedia => 'Mídia';

  @override
  String get diagQualityNoSeries =>
      'Nenhuma série temporal foi registrada para esta ligação.';

  @override
  String get diagQualityPacketLoss => 'Perda de pacotes';

  @override
  String get diagQualityRtt => 'Tempo de ida e volta';

  @override
  String get diagLogsForward => 'Encaminhar logs do mecanismo';

  @override
  String get diagLogsForwardSub =>
      'Enviar linhas de log do pjsip a este visualizador';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Nível $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Ocultar ao exportar';

  @override
  String get diagLogsSearch => 'Buscar nos logs';

  @override
  String get diagLogsEmpty => 'Ainda não há linhas de log.';

  @override
  String get diagLogsForwardingOff =>
      'O encaminhamento de logs está desativado. Ative-o para capturar os logs do mecanismo.';

  @override
  String get diagLogsNoMatch => 'Nenhuma linha corresponde à busca.';

  @override
  String get diagAudioEngineNotRunning =>
      'O mecanismo SIP não está em execução.';

  @override
  String get diagAudioMicrophone => 'Microfone';

  @override
  String get diagAudioMicFooter =>
      'O medidor de nível lê o dispositivo de áudio, que o mecanismo abre durante uma ligação ou o teste de eco.';

  @override
  String get diagAudioLevelMeter => 'Medidor de nível';

  @override
  String get diagAudioLevelMeterSub => 'Fale e observe a barra se mover';

  @override
  String get diagAudioMic => 'Mic.';

  @override
  String get diagAudioSpeaker => 'Alto-falante';

  @override
  String get diagAudioEchoTest => 'Teste de eco';

  @override
  String get diagAudioEchoFooter =>
      'Reproduz sua voz no alto-falante. Use fones de ouvido para evitar microfonia.';

  @override
  String get diagAudioEchoActive => 'Ativo: fale agora';

  @override
  String get diagAudioEchoIdle => 'Loopback do microfone para o alto-falante';

  @override
  String get diagAudioSpeakerTest => 'Teste do alto-falante';

  @override
  String get diagAudioPlayTone => 'Reproduzir tom de teste';

  @override
  String get diagAudioPlayToneSub => 'Reproduz no alto-falante selecionado';

  @override
  String get diagAudioPlayingDtmf => 'Reproduzindo DTMF';

  @override
  String get diagAudioPlayingRingback => 'Reproduzindo tom de chamada';

  @override
  String get diagAudioRingback => 'Tom de chamada';

  @override
  String get diagAudioDevices => 'Dispositivos';

  @override
  String get diagAudioChooseDevices => 'Escolha o microfone e o alto-falante';

  @override
  String get diagAudioChooseDevicesSub => 'Abre Ajustes > Áudio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'Nível de $label: $percent por cento';
  }

  @override
  String get diagLadderLocal => 'Local';

  @override
  String diagLadderSent(String message) {
    return 'Enviada: $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Recebida: $message';
  }

  @override
  String get diagTraceCapture => 'Capturar mensagens SIP';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0  ·  $size  ·  $dropped mais antigas descartadas';
  }

  @override
  String get diagTraceOffHint =>
      'Desativado. Ative e depois registre ou faça uma ligação.';

  @override
  String get diagTraceExportOrClear => 'Exportar ou limpar';

  @override
  String get diagTraceSaveAsPcap => 'Salvar como .pcap';

  @override
  String get diagTraceCopyAsText => 'Copiar como texto';

  @override
  String get diagTraceSearchHint => 'Busque texto, número ou Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Somente erros';

  @override
  String get diagTraceFilterMethod => 'Filtrar por método';

  @override
  String get diagTraceAllMethods => 'Todos os métodos';

  @override
  String get diagTraceMethod => 'Método';

  @override
  String get diagTraceFilterAccount => 'Filtrar por conta';

  @override
  String get diagTraceAllAccounts => 'Todas as contas';

  @override
  String get diagTraceAccount => 'Conta';

  @override
  String get diagTraceRedact => 'Ocultar';

  @override
  String get diagTraceList => 'Lista';

  @override
  String get diagTraceWaiting => 'Aguardando tráfego SIP';

  @override
  String get diagTraceWaitingSub =>
      'Registre uma conta ou faça uma ligação e as mensagens aparecerão aqui.';

  @override
  String get diagTraceOff => 'O rastreamento SIP está desativado';

  @override
  String get diagTraceOffSub =>
      'Ative a captura para ver cada requisição e resposta SIP, em lista ou em diagrama de sequência.';

  @override
  String get diagTraceNoMatch => 'Nenhuma mensagem corresponde aos filtros';

  @override
  String get diagTraceAllDialogs => 'Todos os diálogos';

  @override
  String get diagTraceCopyDialog => 'Copiar este diálogo';

  @override
  String get diagTraceNoResponse => 'sem resposta';

  @override
  String get diagTraceNoCallId => 'sem Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Gravação';

  @override
  String get recFormatWav => 'Padrão (WAV)';

  @override
  String get recFormatWavStereo =>
      'Estéreo, você e quem ligou em canais separados (WAV)';

  @override
  String get recFormatOpus => 'Compactado (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, cerca de 2 MB por minuto. Toca em qualquer lugar.';

  @override
  String get recFormatWavStereoHint =>
      'Dois canais, cerca de 4 MB por minuto. Você à esquerda, quem ligou à direita.';

  @override
  String get recFormatOpusHint =>
      'Cerca de 0,2 MB por minuto. Ogg Opus; alguns players no iPhone, Mac e Windows não conseguem abri-lo.';

  @override
  String get recOptionInherit => 'Usar configuração global';

  @override
  String get recOptionAlways => 'Gravar todas as ligações';

  @override
  String get recOptionIncoming => 'Gravar somente ligações recebidas';

  @override
  String get recOptionOutgoing => 'Gravar somente ligações realizadas';

  @override
  String get recOptionNever => 'Nunca gravar';

  @override
  String get recRuleAll => 'Todas as ligações';

  @override
  String get recRuleIncoming => 'Somente recebidas';

  @override
  String get recRuleOutgoing => 'Somente realizadas';

  @override
  String get recAutoDeleteNever => 'Nunca';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Após $days dias',
      one: 'Após 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Após 1 ano';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gravações',
      one: '1 gravação',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0  ·  $size  ·  exclusão automática após $_temp1';
  }

  @override
  String get recSettingsFormat => 'Formato';

  @override
  String get recSettingsAutoGroup => 'Gravação automática';

  @override
  String get recSettingsAutoFooter =>
      'Verifique as leis locais antes de gravar ligações. Ative \"Sempre gravar ligações com este contato\" em um contato para gravá-las independentemente destas regras.';

  @override
  String get recSettingsAutoRule => 'Gravar ligações automaticamente';

  @override
  String get recSettingsAccountOverride => 'Substituição para esta conta';

  @override
  String get recSettingsNoticesGroup => 'Avisos';

  @override
  String get recSettingsNoticeSwitch => 'Reproduzir um aviso antes de gravar';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Reproduz primeiro um aviso para a outra pessoa. O arquivo do aviso é escolhido em Ajustes > Ligações > Avisos.';

  @override
  String get recSettingsNoticeFile => 'Escolher o arquivo do aviso';

  @override
  String get recSettingsNoticeFileHint => 'Abre Ajustes > Ligações > Avisos';

  @override
  String get recSettingsBeep => 'Bipe de gravação';

  @override
  String get recSettingsBeepHint => 'Avisar a outra pessoa periodicamente';

  @override
  String get recSettingsTransfersGroup => 'Transferências';

  @override
  String get recSettingsContinue => 'Continuar gravando durante transferências';

  @override
  String get recSettingsContinueHint =>
      'Grava a ligação de consulta de uma transferência assistida e a ligação repassada a nós por uma transferência, e vincula as gravações';

  @override
  String get recSettingsStorageGroup => 'Armazenamento';

  @override
  String get recSettingsFolder => 'Pasta';

  @override
  String get recSettingsFolderHint => 'Onde as gravações são salvas';

  @override
  String get recSettingsFolderPlaceholder => 'Documentos do app / Gravações';

  @override
  String get recSettingsChooseFolder => 'Escolher pasta...';

  @override
  String get recSettingsFolderPickerTitle => 'Pasta de gravações';

  @override
  String get recSettingsAutoDelete => 'Excluir gravações antigas';

  @override
  String get recSettingsAutoDeleteHint =>
      'Verificado na inicialização e uma vez por dia';

  @override
  String get recSettingsManage => 'Gerenciar gravações';

  @override
  String get recSettingsOpenFolder => 'Abrir pasta de gravações';

  @override
  String get recPageTitle => 'Gravações';

  @override
  String recSelectedCount(int count) {
    return '$count selecionada(s)';
  }

  @override
  String get recCancelSelection => 'Cancelar seleção';

  @override
  String get recSelectAll => 'Selecionar tudo';

  @override
  String get recShareSelected => 'Compartilhar selecionadas';

  @override
  String get recDeleteSelected => 'Excluir selecionadas';

  @override
  String get recSearchTooltip => 'Buscar gravações';

  @override
  String get recSelectTooltip => 'Selecionar gravações';

  @override
  String get recMenuSettings => 'Ajustes de gravação';

  @override
  String get recSearchHint => 'Buscar nome ou número';

  @override
  String get recEmptyNone => 'Nenhuma gravação ainda';

  @override
  String get recEmptyNoneHint =>
      'Grave uma ligação com o botão Gravar ou ative a gravação automática em Ajustes.';

  @override
  String get recEmptyNoMatch => 'Nenhuma gravação correspondente';

  @override
  String get recEmptyNoMatchHint => 'Tente outra busca ou filtro.';

  @override
  String get recClearFilters => 'Limpar filtros';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count gravações?',
      one: 'Excluir 1 gravação?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Os arquivos de áudio serão removidos deste dispositivo. Esta ação não pode ser desfeita.';

  @override
  String get recDeleteOneTitle => 'Excluir esta gravação?';

  @override
  String get recDeleteOneMessage =>
      'O arquivo de áudio será removido deste dispositivo. Esta ação não pode ser desfeita.';

  @override
  String get recFilterAll => 'Todas';

  @override
  String get recFilterIncoming => 'Recebidas';

  @override
  String get recFilterOutgoing => 'Realizadas';

  @override
  String get recFilterByAccount => 'Filtrar por conta';

  @override
  String get recFilterAllAccounts => 'Todas as contas';

  @override
  String get recFilterAccountFallback => 'Conta';

  @override
  String get recFilterAnyDate => 'Qualquer data';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Limpar datas';

  @override
  String get recMissingFile => 'O arquivo de áudio não está neste dispositivo.';

  @override
  String recRelated(String title) {
    return 'Relacionada: $title';
  }

  @override
  String get recRenameTitle => 'Renomear gravação';

  @override
  String get recRenameHint => 'Nome';

  @override
  String get recSaveAs => 'Salvar como...';

  @override
  String get recShowInFinder => 'Mostrar no Finder';

  @override
  String get recShowInFolder => 'Mostrar na pasta';

  @override
  String get recViewCall => 'Ver ligação';

  @override
  String recSavedTo(String path) {
    return 'Salva em $path';
  }

  @override
  String get recSaveFailed => 'Não foi possível salvar a gravação';

  @override
  String get recShareFailed => 'Não foi possível compartilhar a gravação';

  @override
  String get recSaveDialogTitle => 'Salvar gravação';

  @override
  String get recShareSubject => 'Gravações de ligações';

  @override
  String get recPlayerUnsupported =>
      'Este dispositivo não consegue reproduzir gravações Opus aqui.';

  @override
  String get recPlayerOpenWith => 'Abrir com...';

  @override
  String get recPlayerNotFound => 'O arquivo da gravação não foi encontrado';

  @override
  String recPlayerCannotPlay(String error) {
    return 'Não é possível reproduzir esta gravação: $error';
  }

  @override
  String get recPlayerPlay => 'Reproduzir gravação';

  @override
  String get recPlayerPause => 'Pausar gravação';

  @override
  String get audioFilesTitle => 'Arquivos de áudio';

  @override
  String audioAdded(String name) {
    return '\"$name\" adicionado';
  }

  @override
  String get audioFileUnavailable => 'Esse arquivo não está disponível.';

  @override
  String get audioNameRequired => 'Digite um nome';

  @override
  String audioDeleteTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get audioDeleteMessage =>
      'As configurações que usam este arquivo voltam ao padrão.';

  @override
  String get audioGroupAdd => 'Adicionar';

  @override
  String get audioAddFooter =>
      'Arquivos WAV (PCM, mu-law, A-law) e MP3 funcionam. Os arquivos são copiados para o app, então o original pode ser movido.';

  @override
  String get audioImport => 'Importar um WAV ou MP3…';

  @override
  String get audioGroupMine => 'Meus arquivos';

  @override
  String get audioEmptyTitle => 'Nenhum arquivo ainda';

  @override
  String get audioEmptyHint => 'Importe um arquivo ou grave seu próprio aviso.';

  @override
  String get audioGroupBuiltIn => 'Integrados';

  @override
  String get audioBuiltInFooter => 'Gerados para o SoftphonePro, de uso livre.';

  @override
  String get audioPreviewStop => 'Parar prévia';

  @override
  String audioPreviewPlay(String name) {
    return 'Prévia de $name';
  }

  @override
  String get audioRecordedName => 'Dê um nome a esta gravação';

  @override
  String get audioRecordedDefaultName => 'Meu aviso';

  @override
  String audioSaved(String name) {
    return '\"$name\" salvo';
  }

  @override
  String get audioRecorderStop => 'Parar';

  @override
  String get audioRecorderPlay => 'Reproduzir gravação';

  @override
  String audioRecorderNew(String duration) {
    return 'Nova gravação  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Descartar';

  @override
  String get audioRecordOwn => 'Grave o seu…';

  @override
  String get audioRecordOwnHint =>
      'Usa o microfone selecionado nos ajustes de Áudio';

  @override
  String get audioMissingFile => 'Arquivo ausente';

  @override
  String get audioBuiltInCalm => 'Calmo (integrado)';

  @override
  String get audioBuiltInBreeze => 'Brisa (integrado)';

  @override
  String get audioBuiltInChime => 'Sino de aviso (integrado)';

  @override
  String get audioErrOnlyWavMp3 =>
      'Somente arquivos WAV e MP3 podem ser usados.';

  @override
  String get audioErrNotFound => 'Não foi possível encontrar esse arquivo.';

  @override
  String get audioErrNotSaved => 'A gravação não foi salva.';

  @override
  String get audioErrEmpty => 'Este arquivo de áudio está vazio ou ilegível.';

  @override
  String audioErrUnusable(String reason) {
    return 'Este arquivo de áudio não pode ser usado ($reason). Use WAV PCM, mu-law ou A-law, ou MP3.';
  }

  @override
  String get audioRecEngineOff =>
      'O mecanismo de ligações não está em execução.';

  @override
  String get audioRecUnsupported =>
      'Esta versão do mecanismo de ligações não consegue gravar o microfone.';

  @override
  String audioRecStartFailed(String reason) {
    return 'Não foi possível iniciar a gravação: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Falha na gravação: $reason';
  }

  @override
  String get audioStrengthLow => 'Baixa';

  @override
  String get audioStrengthMedium => 'Média';

  @override
  String get audioStrengthHigh => 'Alta';

  @override
  String get audioStrengthMax => 'Máxima';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Padrão do sistema';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Padrão do sistema ($name)';
  }

  @override
  String get voiceTitle => 'Isolamento de voz';

  @override
  String get voiceUnavailable =>
      'O cancelamento de ruído por IA não está disponível nesta versão do mecanismo de ligações. A supressão de ruído padrão em Processamento continua funcionando.';

  @override
  String get voiceGroupAi => 'Cancelamento de ruído por IA';

  @override
  String get voiceAiFooter =>
      'Remove cliques de teclado, ventiladores e vozes de fundo da ligação usando uma rede neural no dispositivo (RNNoise). Nada sai do seu dispositivo. Uma intensidade maior remove mais ruído, mas pode cortar o início das palavras.';

  @override
  String get voiceMic => 'Meu microfone';

  @override
  String get voiceMicHint => 'Melhora o que a outra pessoa ouve';

  @override
  String get voiceOthers => 'Outros participantes';

  @override
  String get voiceOthersHint => 'Melhora o áudio de quem liga com ruído';

  @override
  String voiceStrength(String value) {
    return 'Intensidade: $value';
  }

  @override
  String get voiceGroupTry => 'Experimente';

  @override
  String get voiceTryFooter =>
      'Use fones de ouvido para o teste de eco, ou você ouvirá microfonia.';

  @override
  String get voiceEchoTest => 'Testar com eco';

  @override
  String get voiceEchoTestHint =>
      'Reproduz para você o áudio processado do seu microfone';

  @override
  String get voiceEchoFailed => 'Falha no teste de eco';

  @override
  String get voiceGroupSystem => 'Sistema';

  @override
  String get voiceSystemFooter =>
      'O macOS e o iOS também podem isolar sua voz em todos os apps. Escolha Isolamento de Voz no modo de microfone do sistema.';

  @override
  String get voiceSystemMode =>
      'Modo de microfone do sistema (Isolamento de Voz)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Os modos de microfone exigem macOS 12 ou iOS 15 ou posterior.';

  @override
  String get voiceSpeechDetection => 'Detecção de fala';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent por cento';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Efeitos de áudio do Android';

  @override
  String get voiceAndroidFooter =>
      'O celular também pode tratar o microfone por conta própria. Isso é informado pelo Android e é separado da configuração acima.';

  @override
  String get voiceAndroidNs => 'Supressor de ruído';

  @override
  String get voiceAndroidAec => 'Cancelador de eco';

  @override
  String get voiceNotAvailableDevice => 'Não disponível neste dispositivo';

  @override
  String get callLinkNotLocal =>
      'Este tipo de link só pode ser usado pela linha de comando deste computador.';

  @override
  String linkLanConnectTitle(String name) {
    return 'Conectar ao dispositivo $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Um link de outro app ou de uma página da web quer conectar o SoftphonePro a este dispositivo. Conecte apenas se você esperava isso.';

  @override
  String get linkLanConnectAction => 'Conectar';

  @override
  String get linkImportSensitiveHeader =>
      'Alterações sensíveis nesta configuração:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Atende automaticamente as ligações recebidas';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Encaminha as ligações para $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Altera quem pode iniciar um interfone ou capturar uma ligação (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Reescreve os números que você disca';

  @override
  String get linkImportFlagLinksImmediately =>
      'Ligações de links da web começam imediatamente, sem confirmação';

  @override
  String get linkImportFlagDiagnostics =>
      'Ativa o registro detalhado ou o rastreamento SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Permitir atendimento automático nas contas importadas';

  @override
  String linkImportRefused(String setting) {
    return 'Esta importação tenta alterar \"$setting\", que nunca pode ser definido por link, código QR, texto colado ou arquivo. Use a opção de linha de comando --provision neste computador. Nada foi importado.';
  }

  @override
  String get lanPairIntercomNote =>
      'Dispositivos pareados podem pedir uma chamada de interfone; você será perguntado antes de cada uma (altere em Configurações > LAN).';

  @override
  String get callLinkUnsupportedScheme => 'Este tipo de link não é suportado.';

  @override
  String get linkImportFlagAutoRecord => 'Grava as chamadas automaticamente';

  @override
  String get linkImportFlagBlocklist =>
      'Altera sua lista de bloqueio de chamadas';

  @override
  String get linkImportFlagEmergency => 'Altera seus números de emergência';

  @override
  String get linkImportFlagSpeedDial => 'Define números de discagem rápida';

  @override
  String get linkImportFlagRecordingDelete =>
      'Exclui automaticamente gravações antigas';

  @override
  String get linkImportFlagFeatureCodes =>
      'Disca códigos de recursos PBX personalizados';

  @override
  String get linkImportAllowAutoRecord =>
      'Permitir a gravação automática de chamadas';

  @override
  String get importIgnoredHeader => 'Ignorado (não permitido em importações):';

  @override
  String importAccountLine(
    String name,
    String address,
    String server,
    String transport,
  ) {
    return '$name ($address) - servidor $server, $transport';
  }

  @override
  String importAccountProxies(String proxies) {
    return 'Proxies: $proxies';
  }

  @override
  String importAccountTurn(String server) {
    return 'Relay TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Cabeçalhos SIP personalizados: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'ID do chamador: $callerId';
  }

  @override
  String get importAccountSrtpOff =>
      'Sem criptografia de mídia (SRTP desativado)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Endereço: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Atualizar $updated existentes, adicionar $added novas';
  }

  @override
  String get secretsKeyringLocked =>
      'Não foi possível abrir seu chaveiro (bloqueado ou sem resposta), então não foi possível ler as senhas salvas. Desbloqueie-o e reinicie o SoftphonePro.';

  @override
  String get mixerTitle => 'Mixer de áudio';

  @override
  String get mixerMicrophone => 'Microfone';

  @override
  String get mixerSpeaker => 'Fones e alto-falante';

  @override
  String get mixerMicVolume => 'Volume do microfone';

  @override
  String get mixerSpeakerVolume => 'Volume do alto-falante';

  @override
  String mixerMeterLabel(String name) {
    return 'Nível: $name';
  }

  @override
  String get mixerInputDevice => 'Dispositivo de entrada';

  @override
  String get mixerOutputDevice => 'Dispositivo de saída';

  @override
  String get mixerOutputRoute => 'Saída de áudio';

  @override
  String get mixerInputFollowsOutput =>
      'O microfone acompanha a saída de áudio selecionada.';

  @override
  String get mixerShowMore => 'Mostrar dispositivos e música de fundo';

  @override
  String get mixerShowLess => 'Mostrar menos controles';

  @override
  String get mixerStripShow => 'Mostrar o mixer de áudio';

  @override
  String get mixerStripHide => 'Ocultar o mixer de áudio';

  @override
  String get musicbedTitle => 'Música de fundo';

  @override
  String get musicbedPlay => 'Reproduzir música de fundo';

  @override
  String get musicbedVolume => 'Volume da música de fundo';

  @override
  String get musicbedChooseFile => 'Escolher um arquivo';

  @override
  String musicbedChangeFile(String name) {
    return 'Arquivo da música de fundo: $name. Toque para alterar.';
  }

  @override
  String get musicbedHearIt => 'Ouvir também';

  @override
  String get musicbedMonitorVolume => 'Volume do monitor';

  @override
  String get musicbedAddFile => 'Adicionar um arquivo…';

  @override
  String get musicbedPickerTitle => 'Arquivo da música de fundo';

  @override
  String get musicbedOn => 'Música de fundo ativa';

  @override
  String get musicbedPausedOnHold => 'Música de fundo em pausa (em espera)';

  @override
  String get musicbedOnTooltip =>
      'Um arquivo de música está sendo reproduzido para todos nas suas chamadas.';

  @override
  String get musicbedFileMissing =>
      'O arquivo da música de fundo não está mais disponível, então ela foi desativada.';

  @override
  String get musicbedNeedsFile =>
      'Escolha primeiro um arquivo para a música de fundo.';

  @override
  String musicbedStopped(String message) {
    return 'Música de fundo interrompida: $message';
  }

  @override
  String get musicbedSettingsFooter =>
      'Reproduz em loop um arquivo de música por baixo da sua voz para todos nas suas chamadas, mesmo no mudo. Chamadas em espera ouvem a música de espera.';

  @override
  String get musicbedSettingsFile => 'Arquivo de música';

  @override
  String get linkImportFlagMusicbed => 'Toca música nas suas chamadas';

  @override
  String get musicbedMonitorIosHint =>
      'No iPhone, você ouve durante as chamadas';

  @override
  String get musicbedStopFailed =>
      'Não foi possível parar a música. Ela pode ainda estar tocando para quem está na chamada.';
}
