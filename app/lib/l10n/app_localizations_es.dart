// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SoftphonePro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languagePickerHint =>
      'Los nombres de los idiomas se muestran en su propio idioma.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionOk => 'Aceptar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionClear => 'Borrar';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionDetails => 'Detalles';

  @override
  String get actionMore => 'Más';

  @override
  String get actionSettings => 'Ajustes';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionYes => 'Sí';

  @override
  String get actionNo => 'No';

  @override
  String get commonOn => 'Activado';

  @override
  String get commonOff => 'Desactivado';

  @override
  String get commonNone => 'Ninguno';

  @override
  String get commonDefault => 'Predeterminado';

  @override
  String get commonSystem => 'Sistema';

  @override
  String get commonAutomatic => 'Automático';

  @override
  String get commonUnknown => 'Desconocido';

  @override
  String get commonNotSet => 'Sin definir';

  @override
  String get commonError => 'Error';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get statusAvailable => 'Disponible';

  @override
  String get statusDoNotDisturb => 'No molestar';

  @override
  String get statusOffline => 'Sin conexión';

  @override
  String get statusOnACall => 'En una llamada';

  @override
  String get settingsEntryAccounts => 'Cuentas';

  @override
  String get settingsEntryAccountsSub => 'Cuentas SIP y registro';

  @override
  String get settingsEntryAudio => 'Audio';

  @override
  String get settingsEntryAudioSub =>
      'Dispositivos, niveles, cancelación de eco';

  @override
  String get settingsEntryCodecs => 'Códecs';

  @override
  String get settingsEntryCodecsSub => 'Orden, disponibilidad, Opus';

  @override
  String get settingsEntryCalls => 'Llamadas';

  @override
  String get settingsEntryCallsSub =>
      'No molestar, espera, respuesta automática, reglas de marcación';

  @override
  String get settingsEntryNetwork => 'Red';

  @override
  String get settingsEntryNetworkSub => 'Transportes, STUN, TLS, DNS';

  @override
  String get settingsEntryRecording => 'Grabación';

  @override
  String get settingsEntryNotifications => 'Notificaciones y tonos';

  @override
  String get settingsEntryShortcuts => 'Atajos';

  @override
  String get settingsEntryShortcutsSub => 'Atajos globales y de la app';

  @override
  String get settingsEntryAppearance => 'Apariencia';

  @override
  String get settingsEntryPrivacy => 'Privacidad y seguridad';

  @override
  String get settingsEntryLan => 'LAN Link';

  @override
  String get settingsEntryProvisioning => 'Aprovisionamiento';

  @override
  String get settingsEntryProvisioningSub => 'Importar, exportar, QR';

  @override
  String get settingsEntryDiagnostics => 'Diagnóstico';

  @override
  String get settingsEntryDiagnosticsSub => 'Traza SIP, pruebas de red';

  @override
  String get settingsEntryAdvanced => 'Avanzado';

  @override
  String get settingsEntryAbout => 'Acerca de';

  @override
  String get settingsAccountsEmptyTitle => 'Añade tu primera cuenta';

  @override
  String get settingsAccountsEmptySubtitle =>
      'Conéctate a tu centralita o proveedor SIP para empezar a llamar.';

  @override
  String get settingsAccountsAdd => 'Añadir cuenta';

  @override
  String get settingsAccountsYourAccounts => 'Tus cuentas';

  @override
  String settingsAccountSubtitle(String address, String status) {
    return '$address  ·  $status';
  }

  @override
  String settingsAccountSubtitleBackup(String address, String status) {
    return '$address  ·  $status  ·  usando servidor de respaldo';
  }

  @override
  String get settingsAudioDevices => 'Dispositivos';

  @override
  String get settingsAudioMicrophone => 'Micrófono';

  @override
  String get settingsAudioSpeaker => 'Altavoz';

  @override
  String get settingsAudioRinger => 'Timbre';

  @override
  String get settingsAudioRingerSub =>
      'Reproducir el tono de llamada en otro dispositivo';

  @override
  String get settingsAudioRefreshDevices => 'Actualizar dispositivos';

  @override
  String get settingsAudioLevelsAndTest => 'Niveles y prueba';

  @override
  String get settingsAudioMicVolume => 'Volumen del micrófono';

  @override
  String get settingsAudioMicLevel => 'Nivel del micrófono';

  @override
  String get settingsAudioSpeakerVolume => 'Volumen del altavoz';

  @override
  String get settingsAudioSpeakerLevel => 'Nivel del altavoz';

  @override
  String get settingsAudioTestSpeaker => 'Probar altavoz';

  @override
  String get settingsAudioTestSpeakerSub =>
      'Reproduce un tono corto por el altavoz seleccionado';

  @override
  String get settingsAudioTestToneFailed =>
      'No se pudo reproducir el tono de prueba';

  @override
  String get settingsAudioEchoTestFailed => 'Falló la prueba de eco';

  @override
  String get settingsAudioEchoTest => 'Prueba de eco';

  @override
  String get settingsAudioEchoTestSub =>
      'Reproduce tu micrófono por el altavoz. Usa auriculares para evitar el acople.';

  @override
  String get settingsAudioVoiceAndFiles => 'Voz y archivos';

  @override
  String get settingsAudioVoiceIsolation =>
      'Aislamiento de voz (cancelación de ruido con IA)';

  @override
  String get settingsAudioAudioFiles => 'Archivos de audio';

  @override
  String get settingsAudioAudioFilesSub => 'Música en espera y anuncios';

  @override
  String get settingsAudioProcessing => 'Procesamiento';

  @override
  String get settingsAudioEchoCancellation => 'Cancelación de eco';

  @override
  String get settingsAudioEcSimple => 'Simple';

  @override
  String get settingsAudioEcPlatform => 'Plataforma';

  @override
  String get settingsAudioEchoTail => 'Cola de eco';

  @override
  String get settingsAudioNoiseSuppression => 'Supresión de ruido';

  @override
  String get settingsAudioAgc => 'Control automático de ganancia';

  @override
  String get settingsAudioVad => 'Detección de actividad de voz';

  @override
  String get settingsAudioVadSub =>
      'Ahorra ancho de banda durante los silencios';

  @override
  String get settingsAudioAdvanced => 'Avanzado';

  @override
  String get settingsAudioAdvancedFooter =>
      'Los valores del búfer de jitter están en milisegundos; -1 usa el valor predeterminado del motor. Al cambiarlos se reinicia el motor de llamadas.';

  @override
  String get settingsAudioPtime => 'Tiempo de paquete (ptime)';

  @override
  String get settingsAudioJbInitial => 'Búfer de jitter: inicial';

  @override
  String get settingsAudioJbMinPrefetch => 'Búfer de jitter: precarga mínima';

  @override
  String get settingsAudioJbMaxPrefetch => 'Búfer de jitter: precarga máxima';

  @override
  String get settingsAudioJbMaxSize => 'Búfer de jitter: tamaño máximo';

  @override
  String settingsAudioVoiceIsolationMic(String strength) {
    return 'Micrófono $strength';
  }

  @override
  String settingsAudioVoiceIsolationOthers(String strength) {
    return 'Otros $strength';
  }

  @override
  String settingsAudioPercentValue(int percent) {
    return '$percent por ciento';
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
  String get settingsCodecsOrder => 'Orden y disponibilidad';

  @override
  String get settingsCodecsDragHint =>
      'Arrastra para reordenar. Las cuentas pueden reemplazar esta lista en su propia configuración.';

  @override
  String get settingsCodecsBitrate => 'Tasa de bits';

  @override
  String get settingsCodecsFec => 'FEC en banda';

  @override
  String get settingsCodecsFecSub => 'Se recupera de la pérdida de paquetes';

  @override
  String get settingsCodecsDtxSub => 'Dejar de enviar durante los silencios';

  @override
  String get settingsCodecsCbr => 'Tasa de bits constante';

  @override
  String get settingsCodecsComplexity => 'Complejidad';

  @override
  String get settingsCallsIncoming => 'Entrantes';

  @override
  String get settingsCallsDndSub => 'Rechazar todas las llamadas entrantes';

  @override
  String get settingsCallsRejectWith => 'Rechazar con';

  @override
  String get settingsCallsReasonBusy => 'Ocupado (486)';

  @override
  String get settingsCallsReasonUnavailable =>
      'Temporalmente no disponible (480)';

  @override
  String get settingsCallsReasonDecline => 'Rechazada (603)';

  @override
  String get settingsCallsWaiting => 'Llamada en espera';

  @override
  String get settingsCallsWaitingSub =>
      'Permitir una segunda llamada entrante durante una llamada';

  @override
  String get settingsCallsWhenBusy =>
      'Si está ocupado y la espera está desactivada';

  @override
  String get settingsCallsRejectAnonymous => 'Rechazar llamadas anónimas';

  @override
  String get settingsCallsLinksImmediately =>
      'Llamar al instante desde enlaces';

  @override
  String get settingsCallsLinksImmediatelySub =>
      'Los enlaces tel:, sip: y callto: inician la llamada sin esperar en el teclado';

  @override
  String get settingsCallsSyncFeatureCodes =>
      'Sincronizar No molestar y desvío con la centralita mediante códigos de servicio';

  @override
  String get settingsCallsSyncFeatureCodesSub =>
      'Marca brevemente los códigos con asterisco de la cuenta (por ejemplo *78) al cambiar No molestar o el desvío';

  @override
  String get settingsCallsAutoAnswerGroup => 'Respuesta automática';

  @override
  String get settingsCallsAutoAnswerFooter =>
      'El desvío de llamadas y la respuesta automática por cuenta se configuran en cada cuenta.';

  @override
  String get settingsCallsAutoAnswerAll =>
      'Responder todas las llamadas automáticamente';

  @override
  String get settingsCallsAnswerAfter => 'Responder tras';

  @override
  String get settingsCallsAnswerImmediately => 'De inmediato';

  @override
  String get settingsCallsIntercomHeaders =>
      'Respetar cabeceras de intercomunicador';

  @override
  String get settingsCallsIntercomHeadersSub =>
      'Indicaciones de respuesta automática de Call-Info, Alert-Info y Answer-Mode';

  @override
  String get settingsCallsBlocked => 'Números bloqueados';

  @override
  String get settingsCallsBlockNumber => 'Bloquear un número';

  @override
  String get settingsCallsBlockNumberTitle => 'Bloquear número';

  @override
  String get settingsCallsBlockNumberHint => 'Número o dirección SIP';

  @override
  String get settingsCallsSpeedDial => 'Marcación rápida';

  @override
  String get settingsCallsDialPlan => 'Plan de marcación';

  @override
  String get settingsCallsDialRules => 'Reglas de marcación';

  @override
  String get settingsCallsStripPrefix => 'Prefijo de línea externa a quitar';

  @override
  String get settingsCallsStripPrefixSub =>
      'Por ejemplo 9, se elimina del inicio de los números marcados';

  @override
  String get settingsCallsPlusReplacement => 'Reemplazar el + inicial por';

  @override
  String get settingsCallsPlusReplacementSub =>
      'Por ejemplo 00 para el acceso internacional';

  @override
  String get settingsCallsPlusReplacementHint => 'Mantener +';

  @override
  String get settingsCallsCountryPrefix => 'Prefijo de país predeterminado';

  @override
  String get settingsCallsCountryPrefixSub =>
      'Los números nacionales que empiezan por 0 reciben este prefijo, por ejemplo +44';

  @override
  String get settingsCallsEmergency => 'Números de emergencia';

  @override
  String get settingsCallsEmergencySub =>
      'Separados por comas. Omiten las reglas de marcación.';

  @override
  String settingsCallsUnblock(String number) {
    return 'Desbloquear $number';
  }

  @override
  String settingsCallsSpeedDialAssigned(int count) {
    return '$count de 9 asignados';
  }

  @override
  String settingsCallsDialRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas',
      one: '1 regla',
    );
    return '$_temp0';
  }

  @override
  String get settingsDialRulesNew => 'Nueva regla de marcación';

  @override
  String get settingsDialRulesEdit => 'Editar regla de marcación';

  @override
  String get settingsDialRulesName => 'Nombre';

  @override
  String get settingsDialRulesPattern => 'Patrón (regex)';

  @override
  String get settingsDialRulesReplacement => 'Reemplazo';

  @override
  String get settingsDialRulesReplacementHelp => 'Usa \$1, \$2 para los grupos';

  @override
  String get settingsDialRulesRoute => 'Enrutar por la cuenta';

  @override
  String get settingsDialRulesAdd => 'Añadir regla';

  @override
  String get settingsDialRulesLiveTest => 'Prueba en vivo';

  @override
  String get settingsDialRulesTyped => 'Número escrito';

  @override
  String get settingsDialRulesNothing => '(nada)';

  @override
  String get settingsDialRulesEmergency =>
      'Número de emergencia: se marca tal como se escribió';

  @override
  String get settingsDialRulesAccountFallback => 'cuenta';

  @override
  String get settingsDialRulesEmpty =>
      'Sin reglas. Los números se limpian (se quitan espacios, guiones y paréntesis) y se marcan tal como se escribieron. Las reglas se aplican de arriba abajo; gana la primera coincidencia.';

  @override
  String get settingsDialRulesDelete => 'Eliminar regla';

  @override
  String get settingsDialRulesDeleteTitle => '¿Eliminar la regla?';

  @override
  String settingsDialRulesVia(String account) {
    return 'por $account';
  }

  @override
  String get settingsNetworkTransports => 'Transportes';

  @override
  String get settingsNetworkTransportsFooter =>
      'El puerto 0 elige un puerto libre al azar. Al cambiar los transportes se reinicia el motor de llamadas.';

  @override
  String get settingsNetworkUdpPort => 'Puerto UDP';

  @override
  String get settingsNetworkTcpPort => 'Puerto TCP';

  @override
  String get settingsNetworkTlsPort => 'Puerto TLS';

  @override
  String get settingsNetworkVerifyCerts =>
      'Verificar certificados del servidor';

  @override
  String get settingsNetworkVerifyCertsSub =>
      'Desactívalo solo para centralitas con certificado autofirmado, o fija el certificado más abajo';

  @override
  String get settingsNetworkCustomCa => 'Archivo de CA personalizado';

  @override
  String get settingsNetworkCustomCaSub =>
      'Paquete PEM que se usa en lugar de la lista integrada (CA de una centralita privada)';

  @override
  String get settingsNetworkCustomCaHint => 'Lista integrada de Mozilla';

  @override
  String get settingsNetworkPins => 'Certificados fijados';

  @override
  String get settingsNetworkPinsSub =>
      'host=huella SHA256, separados por comas';

  @override
  String get settingsNetworkNat => 'Traversal de NAT';

  @override
  String get settingsNetworkStun => 'Servidores STUN';

  @override
  String get settingsNetworkStunSub => 'host:puerto, separados por comas';

  @override
  String get settingsNetworkIceTurn => 'ICE y TURN';

  @override
  String get settingsNetworkIceTurnSub => 'Se configuran por cuenta en NAT';

  @override
  String get settingsNetworkAdvanced => 'Avanzado';

  @override
  String get settingsNetworkQos => 'QoS (marcado DSCP)';

  @override
  String get settingsNetworkQosSub =>
      'Marca los paquetes SIP y de voz como prioritarios';

  @override
  String get settingsNetworkDns => 'Servidores DNS';

  @override
  String get settingsNetworkDnsSub => 'Déjalo vacío para automático';

  @override
  String get settingsNetworkRtpStart => 'Puerto RTP inicial';

  @override
  String get settingsNetworkRtpRange => 'Rango de puertos RTP';

  @override
  String get settingsNetworkRtpRangeSub => '0 usa el valor predeterminado';

  @override
  String get settingsNotifRingtone => 'Tono de llamada';

  @override
  String get settingsNotifDefaultRingtone => 'Tono predeterminado';

  @override
  String get settingsNotifProgressTones => 'Tonos de progreso de llamada';

  @override
  String get settingsNotifProgressTonesSub =>
      'Tonos de llamada, ocupado y congestión al marcar';

  @override
  String get settingsNotifRingerVolume => 'Volumen del timbre';

  @override
  String get settingsNotifCustomRingtone => 'Archivo de tono personalizado';

  @override
  String get settingsNotifCustomRingtoneSub =>
      'Ruta a un archivo WAV (escritorio)';

  @override
  String get settingsNotifGroup => 'Notificaciones';

  @override
  String get settingsNotifRequestPermissions => 'Solicitar permisos';

  @override
  String get settingsNotifRequestPermissionsSub => 'Micrófono y notificaciones';

  @override
  String get settingsNotifTyping => 'Enviar indicadores de escritura';

  @override
  String get settingsAppearanceTheme => 'Tema';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Oscuro';

  @override
  String get settingsAppearanceAccent => 'Color de énfasis';

  @override
  String get settingsAppearanceAccentOption => 'Opción de color de énfasis';

  @override
  String get settingsAppearanceCompact => 'Densidad compacta';

  @override
  String settingsNotifPermissionResult(
    String microphone,
    String notifications,
  ) {
    return 'Micrófono: $microphone, notificaciones: $notifications';
  }

  @override
  String get settingsPrivacySecurity => 'Seguridad';

  @override
  String get settingsPrivacyPasswords => 'Contraseñas';

  @override
  String get settingsPrivacyPasswordsSub =>
      'Se guardan en el llavero o almacén de claves del sistema (archivo cifrado como alternativa)';

  @override
  String get settingsPrivacyGroup => 'Privacidad';

  @override
  String get settingsPrivacyNoTelemetry => 'Sin telemetría';

  @override
  String get settingsPrivacyNoTelemetrySub =>
      'SoftphonePro no envía analíticas. El tráfico de red va solo a tus servidores SIP.';

  @override
  String get settingsPrivacyYourData => 'Tus datos';

  @override
  String get settingsPrivacyClearHistory => 'Borrar historial de llamadas';

  @override
  String get settingsPrivacyDeleteContacts => 'Eliminar todos los contactos';

  @override
  String get settingsPrivacyDeleteMessages => 'Eliminar todos los mensajes';

  @override
  String get settingsPrivacyConfirmHistory =>
      '¿Eliminar el historial de llamadas?';

  @override
  String get settingsPrivacyConfirmContacts => '¿Eliminar todos los contactos?';

  @override
  String get settingsPrivacyConfirmMessages => '¿Eliminar todos los mensajes?';

  @override
  String get settingsPrivacyCannotUndo => 'Esta acción no se puede deshacer.';

  @override
  String get settingsPrivacyDeletedHistory => 'Historial de llamadas eliminado';

  @override
  String get settingsPrivacyDeletedContacts => 'Todos los contactos eliminados';

  @override
  String get settingsPrivacyDeletedMessages => 'Todos los mensajes eliminados';

  @override
  String get settingsLanGroup => 'LAN Link';

  @override
  String get settingsLanFooter =>
      'Los dispositivos de la misma red se encuentran entre sí, se vinculan con un código de 6 dígitos y hablan directamente, sin ningún servidor.';

  @override
  String get settingsLanEnable => 'Activar LAN Link';

  @override
  String get settingsLanDeviceName => 'Nombre del dispositivo';

  @override
  String get settingsLanDeviceNameHint => 'Este dispositivo';

  @override
  String get settingsLanAllowIntercom => 'Permitir intercomunicador';

  @override
  String get settingsLanAllowIntercomSub =>
      'Permite que los dispositivos vinculados te llamen y se les responda automáticamente';

  @override
  String get settingsLanAskIntercom =>
      'Preguntar antes de permitir el intercomunicador';

  @override
  String get settingsLanAskIntercomSub =>
      'Si no, a los dispositivos vinculados se les responde automáticamente durante 30 s después de solicitarlo';

  @override
  String get settingsLanAutoAcceptFiles =>
      'Aceptar automáticamente archivos de dispositivos vinculados';

  @override
  String get settingsLanAutoAcceptFilesSub =>
      'Si no, se te pregunta por cada archivo';

  @override
  String get settingsLanAllowPull =>
      'Permitir que los dispositivos vinculados tomen mis llamadas';

  @override
  String get settingsLanAllowPullSub =>
      'Un dispositivo vinculado puede retomar una llamada activa aquí';

  @override
  String get settingsLanDownloads => 'Carpeta de descargas';

  @override
  String get settingsLanDownloadsHint =>
      'Predeterminada (Descargas/SoftphonePro)';

  @override
  String get settingsLanPort => 'Puerto de Link';

  @override
  String get settingsLanSharedAccounts =>
      'Cuentas compartidas con dispositivos vinculados';

  @override
  String get settingsLanSharedAccountsFooter =>
      'Al compartir una cuenta registrada, un dispositivo vinculado del mismo servidor puede recibir tus llamadas directamente (transferencia de llamada) en lugar de retransmitirlas.';

  @override
  String get settingsAdvEngine => 'Motor';

  @override
  String get settingsAdvSimulator => 'Usar simulador';

  @override
  String get settingsAdvSimulatorSub =>
      'Funciona sin el motor nativo. Las llamadas se simulan.';

  @override
  String get settingsAdvLogLevel => 'Nivel de registro';

  @override
  String get settingsAdvLogErrors => 'Errores';

  @override
  String get settingsAdvLogInfo => 'Información';

  @override
  String get settingsAdvLogDebug => 'Depuración';

  @override
  String get settingsAdvLogVerbose => 'Detallado';

  @override
  String get settingsAdvSipTrace => 'Traza SIP';

  @override
  String get settingsAdvRestartEngine => 'Reiniciar motor';

  @override
  String get settingsAdvDesktop => 'Escritorio';

  @override
  String get settingsAdvStartAtLogin => 'Iniciar al arrancar sesión';

  @override
  String get settingsAdvCloseToTray => 'Cerrar a la bandeja';

  @override
  String get settingsAdvCloseToTraySub =>
      'Al cerrar la ventana, SoftphonePro sigue en ejecución para que las llamadas puedan sonar. Sal desde el icono de la bandeja o de la barra de menús.';

  @override
  String get settingsAboutLicence => 'Licencia';

  @override
  String get settingsAboutLicenceFooter =>
      'SoftphonePro es software libre: puedes redistribuirlo y/o modificarlo bajo los términos de la Licencia Pública General de GNU publicada por la Free Software Foundation, versión 3 o posterior. Se distribuye SIN NINGUNA GARANTÍA.';

  @override
  String get settingsAboutGpl => 'GNU GPL v3 o posterior';

  @override
  String get settingsAboutGplSub =>
      'Código fuente disponible en el repositorio del proyecto';

  @override
  String get settingsAboutThirdParty => 'Avisos de terceros';

  @override
  String get settingsAboutPackages => 'Paquetes de Flutter y Dart';

  @override
  String get settingsAboutPackagesSub =>
      'BSD de 3 cláusulas, MIT y Apache 2.0. Consulta la página de licencias.';

  @override
  String settingsAboutVersion(String version) {
    return 'Versión $version';
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
    return '$license. $purpose. Versión $version.';
  }

  @override
  String get updatesChecking => 'Comprobando...';

  @override
  String updatesAvailable(String version) {
    return 'SoftphonePro $version está disponible';
  }

  @override
  String get updatesUpToDate => 'Estás al día';

  @override
  String get updatesCouldNotCheck => 'No se pudo comprobar';

  @override
  String get updatesNotCheckedYet => 'Aún sin comprobar';

  @override
  String updatesLastChecked(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última comprobación: $dateString';
  }

  @override
  String get updatesTitle => 'Actualizaciones';

  @override
  String get updatesFooter =>
      'La comprobación solo contacta con api.github.com (una vez por semana) y no envía nada más que la propia solicitud: ningún identificador ni datos de cuentas o llamadas. SoftphonePro nunca descarga ni instala nada por sí mismo.';

  @override
  String get updatesCheckSwitch => 'Buscar actualizaciones';

  @override
  String get updatesCheckNow => 'Comprobar ahora';

  @override
  String updatesSkippingVersion(String version) {
    return 'Omitiendo la versión $version';
  }

  @override
  String get updatesStopSkipping => 'Dejar de omitir';

  @override
  String get updatesReleaseNotes => 'Notas de la versión';

  @override
  String get updatesDownload => 'Descargar';

  @override
  String get updatesSkipVersion => 'Omitir esta versión';

  @override
  String get updatesDismiss => 'Descartar';

  @override
  String get updatesRateLimited =>
      'Se alcanzó el límite de GitHub, inténtalo más tarde';

  @override
  String updatesServerAnswered(int status) {
    return 'GitHub respondió $status';
  }

  @override
  String get updatesUnexpectedReply => 'Respuesta inesperada';

  @override
  String get updatesTimedOut => 'Tiempo de espera agotado';

  @override
  String get updatesAlreadyChecking => 'Ya se está comprobando';

  @override
  String get encryptionTitle => 'Cifrado';

  @override
  String get encryptionFooter =>
      'Cifra la base de datos local con AES-256-GCM. La clave se guarda en el llavero o almacén de claves del sistema; si se pierde, los datos no se pueden recuperar. Las grabaciones de llamadas y los archivos exportados no se cifran. El cambio se aplica la próxima vez que se inicie SoftphonePro (ciérralo por completo antes); el archivo anterior se sobrescribe y se elimina en cuanto la nueva base de datos se abre y se verifica.';

  @override
  String get encryptionSwitchTitle =>
      'Cifrar historial de llamadas, contactos y mensajes en este dispositivo';

  @override
  String get encryptionWillEncrypt => 'Se cifrará en el próximo inicio';

  @override
  String get encryptionWillDecrypt => 'Se descifrará en el próximo inicio';

  @override
  String get encryptionRestartToEncrypt =>
      'Cierra y vuelve a abrir SoftphonePro para cifrar tus datos.';

  @override
  String get encryptionRestartToDecrypt =>
      'Cierra y vuelve a abrir SoftphonePro para descifrar tus datos.';

  @override
  String speedDialSlotTitle(int slot) {
    return 'Marcación rápida $slot';
  }

  @override
  String get speedDialNumberLabel => 'Número o dirección SIP';

  @override
  String get speedDialLabelOptional => 'Etiqueta (opcional)';

  @override
  String get speedDialCallFrom => 'Llamar desde';

  @override
  String get speedDialSelectedAccount => 'Cuenta seleccionada';

  @override
  String get speedDialTitle => 'Marcación rápida';

  @override
  String get speedDialHint =>
      'Mantén pulsado un dígito (1-9) en el teclado vacío para llamar a su número.';

  @override
  String get speedDialNotAssigned => 'Sin asignar';

  @override
  String provisioningNotValidJson(String detail) {
    return 'JSON no válido: $detail';
  }

  @override
  String get provisioningExpectedObject => 'Se esperaba un objeto JSON';

  @override
  String provisioningUnsupportedVersion(String version) {
    return 'Versión de configuración no compatible: $version';
  }

  @override
  String get provisioningSkippedAccountEntry =>
      'Se omitió una entrada de cuenta que no es un objeto';

  @override
  String get provisioningNothingToImport =>
      'El archivo no contiene cuentas ni ajustes';

  @override
  String provisioningAccountNeedsUserDomain(String name) {
    return 'La cuenta \"$name\" necesita usuario y dominio';
  }

  @override
  String provisioningServerAnswered(int status) {
    return 'El servidor respondió $status';
  }

  @override
  String provisioningDownloadFailed(String error) {
    return 'No se pudo descargar la configuración: $error';
  }

  @override
  String provisioningCouldNotRead(String path) {
    return 'No se pudo leer $path';
  }

  @override
  String provisioningImportedAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas importadas',
      one: '1 cuenta importada',
    );
    return '$_temp0';
  }

  @override
  String get provisioningImportTitle => 'Importar configuración';

  @override
  String provisioningSummary(int accounts, int settings) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts cuentas',
      one: '1 cuenta',
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
  String get provisioningImportFromUrlTitle => 'Importar desde URL o JSON';

  @override
  String get provisioningImportFromUrlHint => 'https://... o pega JSON';

  @override
  String get provisioningInvalidSource => 'No es una URL, enlace o JSON válido';

  @override
  String get provisioningScanTitle => 'Escanear QR de aprovisionamiento';

  @override
  String get provisioningPasteHint => 'Pega JSON, un enlace o una URL';

  @override
  String get provisioningImportGroup => 'Importar';

  @override
  String get provisioningImportFooter =>
      'Admite JSON con cuentas y ajustes. Los marcadores \${VAR} se rellenan con valores vacíos, salvo que se indique un valor predeterminado como \${VAR:-default}.';

  @override
  String get provisioningScanQr => 'Escanear código QR';

  @override
  String get provisioningFromUrl => 'Desde URL o JSON pegado';

  @override
  String get provisioningFromFile => 'Desde archivo';

  @override
  String get provisioningFromClipboard => 'Desde el portapapeles';

  @override
  String get provisioningExportGroup => 'Exportar';

  @override
  String get provisioningIncludePasswords => 'Incluir contraseñas';

  @override
  String get provisioningIncludePasswordsHint =>
      'Cualquiera que tenga el archivo podrá usar tus cuentas';

  @override
  String get provisioningCopyConfig => 'Copiar configuración (JSON)';

  @override
  String get provisioningConfigCopied => 'Configuración copiada';

  @override
  String get provisioningQrGroup => 'Código QR';

  @override
  String get provisioningQrFooter =>
      'Escanea este código en otro dispositivo para copiar una cuenta. Trátalo como una contraseña si la incluye.';

  @override
  String get provisioningQrAccount => 'Cuenta';

  @override
  String get provisioningChoose => 'Elegir...';

  @override
  String get provisioningQrTooMuchData => 'Demasiados datos para un código QR';

  @override
  String tlsClearField(String field) {
    return 'Borrar $field';
  }

  @override
  String get tlsChoose => 'Elegir...';

  @override
  String get tlsChange => 'Cambiar...';

  @override
  String get tlsClientCertTitle => 'Certificado de cliente (TLS mutuo)';

  @override
  String get tlsIncomplete =>
      'Elige tanto un certificado como su clave privada. El certificado solo se presenta cuando ambos están definidos.';

  @override
  String get tlsFooter =>
      'Para servidores que piden a la app identificarse con un certificado. Archivos PEM. Se usa con TLS y WebSocket seguro.';

  @override
  String get tlsCertFile => 'Archivo de certificado';

  @override
  String get tlsKeyFile => 'Archivo de clave privada';

  @override
  String get tlsKeyPassword => 'Contraseña de la clave';

  @override
  String get tlsKeyPasswordHint => 'Solo si la clave está cifrada';

  @override
  String get callSettingsHoldGroupTitle => 'Espera';

  @override
  String get callSettingsHoldFooter =>
      'Con \"Predeterminada de la centralita\", la llamada simplemente se pone en espera y tu sistema telefónico puede reproducir su propia música. Cualquier otra opción la reproduce esta app para quien llama.';

  @override
  String get callSettingsHoldMusic => 'Música en espera';

  @override
  String get callSettingsHoldPbxDefault => 'Predeterminada de la centralita';

  @override
  String get callSettingsHoldMusicVolume => 'Volumen de la música en espera';

  @override
  String get callSettingsHoldAudioFiles => 'Archivos de audio';

  @override
  String get callSettingsHoldAudioFilesHint =>
      'Importar o grabar música en espera';

  @override
  String get callSettingsAnnounceTitle => 'Anuncios';

  @override
  String get callSettingsAnnounceFooter =>
      'Los anuncios se reproducen a la otra parte. Todo se omite en silencio si falta el archivo.';

  @override
  String get callSettingsAnnounceOpening => 'Anuncio de bienvenida';

  @override
  String get callSettingsAnnounceOpeningHint =>
      'Reproducir un mensaje cuando se conecta una llamada';

  @override
  String get callSettingsAnnounceFile => 'Archivo del anuncio';

  @override
  String get callSettingsAnnounceChooseFile => 'Elegir un archivo';

  @override
  String get callSettingsAnnouncePlayFor => 'Reproducir en';

  @override
  String get callSettingsAnnounceBoth => 'Entrantes y salientes';

  @override
  String get callSettingsAnnounceIncoming => 'Llamadas entrantes';

  @override
  String get callSettingsAnnounceOutgoing => 'Llamadas salientes';

  @override
  String get callSettingsAnnounceMuteMic =>
      'Silenciar mi micrófono mientras se reproduce';

  @override
  String get callSettingsAnnounceMonitor => 'Que yo también lo escuche';

  @override
  String get callSettingsAnnounceBeforeRecording =>
      'Antes de iniciar la grabación, reproducir';

  @override
  String get callSettingsAnnounceBeforeTransfer =>
      'Antes de transferir a quien llama, reproducir';

  @override
  String get morePageTitle => 'Más';

  @override
  String get morePresence => 'Presencia';

  @override
  String get morePresenceHint => 'Campo de lámpara de ocupado';

  @override
  String get moreRetrieveParked => 'Recuperar llamada aparcada';

  @override
  String get moreRetrieveParkedHint => 'Marcar una ranura de aparcamiento';

  @override
  String get moreLanLink => 'LAN Link';

  @override
  String get moreLanLinkHint =>
      'Dispositivos cercanos, chat y envío de archivos';

  @override
  String get moreRecordings => 'Grabaciones';

  @override
  String get moreRecordingsHint =>
      'Escucha, comparte y gestiona las grabaciones de llamadas';

  @override
  String get moreVoicemail => 'Buzón de voz';

  @override
  String moreVoicemailNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes nuevos',
      one: '1 mensaje nuevo',
    );
    return '$_temp0';
  }

  @override
  String get moreVoicemailDial => 'Llamar a tu buzón de voz';

  @override
  String get moreDiagnostics => 'Diagnóstico';

  @override
  String get moreDiagnosticsHint => 'Traza SIP y pruebas de red';

  @override
  String get moreAbout => 'Acerca de';

  @override
  String get moreNoVoicemailNumber =>
      'No hay un número de buzón de voz definido. Añade uno en los ajustes de la cuenta.';

  @override
  String get moreSearchHint => 'Busca contactos, historial o escribe un número';

  @override
  String moreCallNumber(String number) {
    return 'Llamar a $number';
  }

  @override
  String moreRecentWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String get appLockTitle => 'Bloqueo de la app';

  @override
  String get appLockFooter =>
      'Las llamadas siguen sonando y se pueden contestar con la app bloqueada.';

  @override
  String get appLockRequirePin => 'Pedir PIN para abrir la app';

  @override
  String get appLockOnHint =>
      'El historial, los contactos, los mensajes y los ajustes están bloqueados';

  @override
  String get appLockIsOn => 'Bloqueo de la app activado';

  @override
  String get appLockIsOff => 'Bloqueo de la app desactivado';

  @override
  String get appLockTurnOff => 'Desactivar bloqueo de la app';

  @override
  String get appLockChangePin => 'Cambiar PIN';

  @override
  String get appLockEnterCurrent => 'Introduce el PIN actual';

  @override
  String get appLockPinChanged => 'PIN cambiado';

  @override
  String get appLockLockAfter => 'Bloquear tras';

  @override
  String get appLockLockAfterHint =>
      'Tiempo en segundo plano antes de volver a pedir el PIN';

  @override
  String get appLockImmediately => 'De inmediato';

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
  String get appLockBiometrics => 'Desbloquear con biometría';

  @override
  String get appLockNow => 'Bloquear ahora';

  @override
  String get appLockSetPin => 'Definir un PIN';

  @override
  String get appLockPinDigits => 'PIN (4-8 dígitos)';

  @override
  String get appLockRepeatPin => 'Repetir PIN';

  @override
  String get appLockUseDigits => 'Usa de 4 a 8 dígitos';

  @override
  String get appLockMismatch => 'Los PIN no coinciden';

  @override
  String get appLockPin => 'PIN';

  @override
  String appLockTooManyTryIn(int seconds) {
    return 'Demasiados intentos. Inténtalo de nuevo en $seconds s';
  }

  @override
  String get appLockWrongPin => 'PIN incorrecto';

  @override
  String get appLockTooMany => 'Demasiados intentos';

  @override
  String get appLockIsLocked => 'SoftphonePro está bloqueado';

  @override
  String get appLockEnterPin => 'Introduce tu PIN';

  @override
  String appLockTryAgainIn(String time) {
    return 'Inténtalo de nuevo en $time';
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
  String get appLockUnlock => 'Desbloquear';

  @override
  String get appLockIncomingCall => 'Llamada entrante';

  @override
  String get appLockDecline => 'Rechazar';

  @override
  String get appLockAnswer => 'Contestar';

  @override
  String get appLockHangUp => 'Colgar';

  @override
  String get appLockBiometricReason => 'Desbloquear SoftphonePro';

  @override
  String get automationNoToken =>
      'No hay token de acceso. Genera uno en Ajustes > Avanzado.';

  @override
  String automationInvalidPort(int port) {
    return 'Puerto no válido: $port';
  }

  @override
  String automationCouldNotStart(String error) {
    return 'No se pudo iniciar: $error';
  }

  @override
  String automationPortUnavailable(int port, String error) {
    return 'El puerto $port no está disponible ($error). Elige otro puerto.';
  }

  @override
  String get automationTokenPlaceholder => 'Se crea al activar la API';

  @override
  String automationListening(String address) {
    return 'Escuchando en $address';
  }

  @override
  String get automationStarting => 'Iniciando...';

  @override
  String get automationTitle => 'API de automatización local';

  @override
  String get automationFooter =>
      'Para integraciones de CRM y mesa de ayuda en este equipo. Solo escucha en 127.0.0.1 y cada solicitud necesita el token de acceso. Consulta docs/AUTOMATION_API.md.';

  @override
  String get automationEnable => 'Activar API de automatización local';

  @override
  String get automationPort => 'Puerto';

  @override
  String get automationPortHint =>
      'Predeterminado 7771. Elige un puerto libre entre 1024 y 65535.';

  @override
  String get automationPortInvalid => 'Introduce un puerto de 1024 a 65535';

  @override
  String get automationAccessToken => 'Token de acceso';

  @override
  String get automationHideToken => 'Ocultar token';

  @override
  String get automationShowToken => 'Mostrar token';

  @override
  String get automationCopyToken => 'Copiar token';

  @override
  String get automationTokenCopied => 'Token copiado';

  @override
  String get automationGenerateToken => 'Generar un token nuevo';

  @override
  String get automationGenerateTitle => '¿Generar un token nuevo?';

  @override
  String get automationGenerateBody =>
      'Los programas que usen el token anterior dejarán de funcionar hasta que les des el nuevo.';

  @override
  String get automationGenerate => 'Generar';

  @override
  String get automationOrigins => 'Orígenes de navegador permitidos';

  @override
  String get automationOriginsHint =>
      'Separados por comas, por ejemplo https://crm.example.com. Los programas sin navegador (curl, scripts) no lo necesitan.';

  @override
  String automationNotOrigin(String origin) {
    return 'No es un origen http(s): $origin';
  }

  @override
  String get trayNotificationAnswer => 'Contestar';

  @override
  String get trayNotificationDecline => 'Rechazar';

  @override
  String get trayTooltipInCall => 'SoftphonePro - en una llamada';

  @override
  String trayTooltipWithNew(String tooltip, int count) {
    return '$tooltip - $count nuevos';
  }

  @override
  String trayTooltipNoAccounts(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - sin cuentas (Ausente)',
      'dnd': 'SoftphonePro - sin cuentas (No molestar)',
      'other': 'SoftphonePro - sin cuentas',
    });
    return '$_temp0';
  }

  @override
  String trayTooltipOnline(int online, int total, String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'away': 'SoftphonePro - $online/$total en línea (Ausente)',
      'dnd': 'SoftphonePro - $online/$total en línea (No molestar)',
      'other': 'SoftphonePro - $online/$total en línea',
    });
    return '$_temp0';
  }

  @override
  String get trayHideApp => 'Ocultar SoftphonePro';

  @override
  String get trayShowApp => 'Mostrar SoftphonePro';

  @override
  String trayNewOpenRecents(int count) {
    return '$count nuevos - abrir Recientes';
  }

  @override
  String get trayStatus => 'Estado';

  @override
  String get trayStatusAway => 'Ausente';

  @override
  String get trayAccounts => 'Cuentas';

  @override
  String get trayQuit => 'Salir de SoftphonePro';

  @override
  String get hotkeyAnswerCall => 'Contestar llamada';

  @override
  String get hotkeyHangUp => 'Colgar';

  @override
  String get hotkeyMute => 'Silenciar / activar micrófono';

  @override
  String get hotkeyFocusDialer => 'Enfocar teclado';

  @override
  String get shortcutsGlobalTitle => 'Atajos globales';

  @override
  String get shortcutsGlobalFooter =>
      'Funcionan desde cualquier aplicación. Si otro programa ya usa una combinación, es posible que no se pueda registrar.';

  @override
  String get shortcutsChange => 'Cambiar';

  @override
  String get shortcutsRestoreDefaults => 'Restablecer valores predeterminados';

  @override
  String get shortcutsMediaTitle => 'Auriculares y teclas multimedia';

  @override
  String get shortcutsMediaFooter =>
      'El botón de reproducir/pausar de unos auriculares o del teclado solo se reclama mientras una llamada suena o está activa; el resto del tiempo lo conservan los reproductores de música.';

  @override
  String get shortcutsMediaSwitch =>
      'Contestar y colgar con el botón reproducir/pausar de los auriculares o multimedia';

  @override
  String get shortcutsMediaDuringCall => 'Durante una llamada, el botón';

  @override
  String get shortcutsMediaHangsUp => 'Cuelga';

  @override
  String get shortcutsMediaMutes => 'Silencia / activa el micrófono';

  @override
  String get shortcutsInApp => 'En la app';

  @override
  String get shortcutsFocusDialer => 'Enfocar el teclado de marcación';

  @override
  String get shortcutsHoldResume => 'Poner en espera / reanudar';

  @override
  String get shortcutsTransfer => 'Transferir';

  @override
  String get shortcutsEndCall => 'Finalizar llamada';

  @override
  String get shortcutsNeedX11 =>
      'Los atajos globales requieren una sesión X11. Wayland no permite que las aplicaciones capturen teclas en todo el sistema.';

  @override
  String shortcutsNeedModifier(String key) {
    return 'Añade Ctrl, Alt, Shift o $key a una letra o dígito';
  }

  @override
  String get shortcutsPressNew => 'Pulsa la nueva combinación de teclas';

  @override
  String get defaultHandlerChooseInSettings =>
      'Elige SoftphonePro para SIP, TEL y CALLTO en Aplicaciones predeterminadas';

  @override
  String get defaultHandlerNowOpens =>
      'SoftphonePro ahora abre los enlaces sip:, tel: y callto:';

  @override
  String defaultHandlerCouldNotChange(String schemes) {
    return 'No se pudo cambiar el valor predeterminado de $schemes';
  }

  @override
  String get defaultHandlerIntro =>
      'Abre enlaces sip:, tel: y callto: de navegadores y otras apps';

  @override
  String get defaultHandlerIsSelf =>
      'SoftphonePro gestiona los enlaces sip:, tel: y callto:';

  @override
  String defaultHandlerNow(String handlers) {
    return 'Ahora: $handlers';
  }

  @override
  String get defaultHandlerTitle =>
      'Usar SoftphonePro como app predeterminada para enlaces sip:, tel: y callto:';

  @override
  String get reliabilityTitle => 'Fiabilidad en segundo plano';

  @override
  String get reliabilityMicrophone => 'Micrófono';

  @override
  String get reliabilityAllowed => 'Permitido';

  @override
  String get reliabilityMicNeeded => 'Necesario para hablar en las llamadas';

  @override
  String get reliabilityNotifications => 'Notificaciones';

  @override
  String get reliabilityNotifNeeded =>
      'Necesarias para mostrar las llamadas entrantes y mantener visible el servicio';

  @override
  String get reliabilityFullScreen => 'Llamadas entrantes a pantalla completa';

  @override
  String get reliabilityFullScreenNeeded =>
      'Permítelo para que las llamadas aparezcan sobre la pantalla de bloqueo';

  @override
  String get reliabilityBattery => 'Uso de batería sin restricciones';

  @override
  String get reliabilityBatteryExempt => 'Exenta de la optimización de batería';

  @override
  String get reliabilityBatteryNeeded =>
      'Android puede suspender la app y perder llamadas para ahorrar energía. Toca para eximir a SoftphonePro.';

  @override
  String reliabilityAutostart(String manufacturer) {
    return 'Inicio automático / apps protegidas de $manufacturer';
  }

  @override
  String get reliabilityAutostartHint =>
      'El fabricante de tu teléfono puede cerrar las apps en segundo plano. Permite que SoftphonePro se inicie automáticamente.';

  @override
  String get reliabilityBoot => 'Iniciar con el sistema';

  @override
  String get reliabilityBootHint =>
      'Registrar las cuentas tras reiniciar el teléfono';

  @override
  String get reliabilityWake => 'Mantener la CPU activa en reposo';

  @override
  String get reliabilityWakeHint =>
      'Más fiable en dispositivos estrictos; consume más batería';

  @override
  String acctEditorDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String acctCodecRemove(String codec) {
    return 'Quitar $codec';
  }

  @override
  String acctEditorLastError(String error) {
    return 'Último error: $error';
  }

  @override
  String acctRangeAllowed(int min, int max) {
    return 'Rango permitido: de $min a $max';
  }

  @override
  String acctValidateMin(int min) {
    return 'Debe ser al menos $min';
  }

  @override
  String acctValidateMax(int max) {
    return 'Debe ser como máximo $max';
  }

  @override
  String get acctEditorDiscardTitle => '¿Descartar los cambios?';

  @override
  String get acctEditorDiscardMessage =>
      'Los cambios en esta cuenta no se han guardado.';

  @override
  String get acctEditorDiscardConfirm => 'Descartar';

  @override
  String get acctEditorDeleteMessage =>
      'La cuenta y su contraseña guardada se eliminarán de este dispositivo.';

  @override
  String get acctEditorMenuDelete => 'Eliminar cuenta';

  @override
  String get acctGroupBasic => 'Básico';

  @override
  String get acctFieldLabel => 'Etiqueta';

  @override
  String get acctFieldLabelHint => 'p. ej., Oficina';

  @override
  String get acctFieldDisplayName => 'Nombre para mostrar';

  @override
  String get acctFieldUsername => 'Usuario';

  @override
  String get acctFieldProtocol => 'Protocolo';

  @override
  String get acctFieldProtocolSub => 'Se fija al crear la cuenta';

  @override
  String get acctFieldAuthUser => 'Usuario de autorización';

  @override
  String get acctFieldAuthUserHint => 'Igual que el usuario';

  @override
  String get acctFieldAuthUserSub =>
      'Solo si el proveedor usa un nombre de inicio de sesión distinto del usuario';

  @override
  String get acctFieldPassword => 'Contraseña';

  @override
  String get acctFieldServerHost => 'Host del servidor';

  @override
  String get acctFieldPort => 'Puerto';

  @override
  String get acctFieldIaxPortSub => 'El valor predeterminado de IAX2 es 4569';

  @override
  String get acctFieldIaxContext => 'Contexto';

  @override
  String get acctFieldIaxContextSub =>
      'Opcional. Se envía a la centralita como contexto de destino';

  @override
  String get acctFieldServerDomain => 'Servidor / dominio';

  @override
  String get acctFieldServerDomainSub => 'host o host:puerto';

  @override
  String get acctFieldEnabled => 'Activada';

  @override
  String get acctFieldDefault =>
      'Cuenta predeterminada para llamadas salientes';

  @override
  String get acctFieldColour => 'Color';

  @override
  String get acctGroupRegistration => 'Registro';

  @override
  String get acctFieldRegister => 'Registrar';

  @override
  String get acctFieldRegisterSubIax =>
      'Desactívalo para peers que no necesitan registro';

  @override
  String get acctFieldRegExpiry => 'Caducidad del registro (s)';

  @override
  String get acctFieldRegExpirySubIax =>
      'Asterisk suele forzar 60 s. Rango de 10 a 86400';

  @override
  String get acctFieldRetryInterval => 'Intervalo de reintento (s)';

  @override
  String get acctFieldFirstRetry => 'Primer reintento (s)';

  @override
  String get acctGroupCodecs => 'Códecs';

  @override
  String get acctGroupCodecsFooterIax =>
      'IAX2 admite G.711 y GSM. Arrastra para definir el orden de preferencia.';

  @override
  String get acctCodecAdd => 'Añadir códec';

  @override
  String get acctGroupServerTransport => 'Servidor y transporte';

  @override
  String get acctFieldRegistrar => 'Servidor de registro alternativo';

  @override
  String get acctFieldBackupRegistrar => 'Servidor de registro de respaldo';

  @override
  String get acctFieldBackupRegistrarSub =>
      'Se usa tras 3 intentos fallidos; el principal se reintenta cada 5 minutos';

  @override
  String get acctFieldProxies => 'Proxies salientes';

  @override
  String get acctFieldTransport => 'Transporte';

  @override
  String get acctFieldTransportAutoSub =>
      'Consulta los registros DNS SRV del servidor y elige TLS, TCP o UDP';

  @override
  String get acctTransportAuto => 'Automático (DNS SRV)';

  @override
  String get acctFieldWsPath => 'Ruta de WebSocket';

  @override
  String get acctFieldWsPathSub =>
      'Ruta HTTP de la actualización a WebSocket, p. ej. /ws. Debe empezar por \"/\"';

  @override
  String get acctFieldRegExpirySubSip =>
      'Lo habitual es de 300 a 3600. Rango de 10 a 86400';

  @override
  String get acctFieldKeepAlive => 'Keep-alive (s)';

  @override
  String get acctFieldKeepAliveSub =>
      'Intervalo de keep-alive UDP. 0 lo desactiva. Rango de 0 a 3600';

  @override
  String get acctFieldLocalPort => 'Puerto SIP local';

  @override
  String get acctFieldLocalPortSub =>
      '0 usa el transporte compartido. Rango de 0 a 65535';

  @override
  String get acctFieldRegisterSubSip =>
      'Desactívalo para troncales sin registro';

  @override
  String get acctFieldSipOutbound => 'SIP Outbound (RFC 5626)';

  @override
  String get acctFieldSipOutboundSub =>
      'Mantiene un flujo persistente a través de NAT. Requiere compatibilidad del servidor';

  @override
  String get acctGroupNat => 'NAT';

  @override
  String get acctFieldUseStun => 'Usar STUN';

  @override
  String get acctFieldTurn => 'Relé TURN';

  @override
  String get acctFieldTurnServer => 'Servidor TURN';

  @override
  String get acctFieldTurnUsername => 'Usuario TURN';

  @override
  String get acctFieldTurnPassword => 'Contraseña TURN';

  @override
  String get acctFieldContactRewrite => 'Reescribir cabecera Contact';

  @override
  String get acctFieldViaRewrite => 'Reescribir cabecera Via';

  @override
  String get acctFieldRewriteSub =>
      'Usa la dirección que ve el servidor. Déjalo activado tras un NAT';

  @override
  String get acctFieldSdpRewrite => 'Reescribir dirección SDP';

  @override
  String get acctFieldSdpRewriteSub =>
      'Sustituye la dirección de medios en el SDP por la pública';

  @override
  String get acctFieldIpv6Sip => 'Señalización IPv6';

  @override
  String get acctFieldIpv6Media => 'Medios IPv6';

  @override
  String get acctGroupAdvancedMedia => 'Medios avanzados';

  @override
  String get acctGroupAdvancedMediaFooter =>
      'Las pasarelas WebRTC necesitan multiplexación RTCP y retroalimentación RTCP.';

  @override
  String get acctFieldRtcpMux => 'Multiplexación RTCP';

  @override
  String get acctFieldRtcpMuxSub =>
      'Envía RTP y RTCP por un solo puerto (rtcp-mux)';

  @override
  String get acctFieldRtcpFb => 'Retroalimentación RTCP (AVPF)';

  @override
  String get acctFieldRtcpFbSub =>
      'Ofrece RTP/AVPF con NACK. Necesario para servidores WebRTC';

  @override
  String get acctGroupSecurity => 'Seguridad';

  @override
  String get acctFieldSrtp => 'Cifrado de medios (SRTP)';

  @override
  String get acctOptOptional => 'Opcional';

  @override
  String get acctOptRequired => 'Obligatorio';

  @override
  String get acctFieldKeyExchange => 'Intercambio de claves';

  @override
  String get acctFieldSecureSignaling => 'Señalización segura';

  @override
  String get acctOptNotRequired => 'No obligatoria';

  @override
  String get acctOptTlsHop => 'TLS salto a salto';

  @override
  String get acctOptTlsE2e => 'TLS de extremo a extremo (sips)';

  @override
  String get acctFieldAuthAlgorithm => 'Algoritmo de autenticación';

  @override
  String get acctFieldPrivacy =>
      'Ocultar mi identificador de llamada (privacidad)';

  @override
  String get acctFieldReferPolicy => 'Transferencias entrantes (REFER)';

  @override
  String get acctFieldWatcherPolicy => 'Observadores de presencia';

  @override
  String get acctOptAccept => 'Aceptar';

  @override
  String get acctOptReject => 'Rechazar';

  @override
  String get acctGroupCodecsFooter =>
      'Reemplaza la lista global de códecs para esta cuenta.';

  @override
  String get acctFieldUseGlobalCodecs => 'Usar el orden global de códecs';

  @override
  String get acctGroupFeatures => 'Funciones';

  @override
  String get acctFieldVoicemailNumber => 'Número del buzón de voz';

  @override
  String get acctFieldMwi => 'Indicador de buzón de voz (MWI)';

  @override
  String get acctFieldMwiSub =>
      'Suscribirse a las notificaciones de mensaje en espera';

  @override
  String get acctFieldPublishPresence => 'Publicar mi presencia';

  @override
  String get acctFieldPublishPresenceSub =>
      'Permite que el servidor comparta tu estado en línea';

  @override
  String get acctFieldDnd => 'No molestar';

  @override
  String get acctFieldForwarding => 'Desvío de llamadas';

  @override
  String get acctOptForwardAlways => 'Siempre';

  @override
  String get acctOptForwardBusy => 'Si está ocupado';

  @override
  String get acctOptForwardNoAnswer => 'Sin respuesta';

  @override
  String get acctFieldForwardTo => 'Desviar a';

  @override
  String get acctFieldForwardToHint => 'Número o dirección SIP';

  @override
  String get acctFieldRingFor => 'Sonar durante (s)';

  @override
  String get acctFieldAutoAnswer => 'Respuesta automática';

  @override
  String get acctFieldAnswerAfter => 'Responder tras (s)';

  @override
  String get acctFieldIntercomOnly => 'Solo para llamadas de intercomunicador';

  @override
  String get acctFieldIntercomOnlySub =>
      'Requiere una cabecera de respuesta automática de la centralita';

  @override
  String get acctFieldRingtone => 'Tono de llamada';

  @override
  String get acctRingtoneClassic => 'Clásico';

  @override
  String get acctRingtoneSoft => 'Suave';

  @override
  String get acctRingtoneDigital => 'Digital';

  @override
  String get acctFieldRecordCalls => 'Grabar llamadas';

  @override
  String get acctFieldHoldMusic => 'Música en espera';

  @override
  String get acctOptUseGlobal => 'Usar ajuste global';

  @override
  String get acctOptPbxDefault => 'Predeterminada de la centralita';

  @override
  String get acctFieldOpeningAnnouncement => 'Anuncio de bienvenida';

  @override
  String get acctGroupFeatureCodes => 'Códigos de servicio';

  @override
  String get acctGroupFeatureCodesFooter =>
      'Se marcan para aparcar, captura, No molestar y desvío en tu centralita.';

  @override
  String get acctFieldPark => 'Aparcar';

  @override
  String get acctFieldGroupPickup => 'Captura de grupo';

  @override
  String get acctFieldDirectedPickup => 'Prefijo de captura dirigida';

  @override
  String get acctFieldParkRetrieve => 'Prefijo para recuperar aparcada';

  @override
  String get acctFieldParkRetrieveHint => 'Marca el número de ranura';

  @override
  String get acctFieldParkRetrieveSub =>
      'Prefijo que se marca antes de la ranura de aparcamiento para recuperar una llamada aparcada';

  @override
  String get acctFieldDndOn => 'Activar No molestar';

  @override
  String get acctFieldDndOff => 'Desactivar No molestar';

  @override
  String get acctFieldForwardOn => 'Activar desvío';

  @override
  String get acctFieldForwardOff => 'Desactivar desvío';

  @override
  String get acctGroupAdvanced => 'Avanzado';

  @override
  String get acctGroupAdvancedFooterIax =>
      'DTMF se envía como tramas IAX2 nativas.';

  @override
  String get acctFieldCallerIdOverride =>
      'Identificador de llamada personalizado';

  @override
  String get acctFieldCallerIdHint => 'Usar el de la cuenta';

  @override
  String get acctFieldCallerIdSub =>
      'Nombre o número de identificador de llamada enviado a la centralita';

  @override
  String get acctFieldSessionTimers => 'Temporizadores de sesión';

  @override
  String get acctFieldSessionExpires => 'Caducidad de sesión (s)';

  @override
  String get acctFieldSessionExpiresSub => 'Rango de 90 a 86400';

  @override
  String get acctField100rel => '100rel (provisional fiable)';

  @override
  String get acctFieldHoldMethod => 'Método de espera';

  @override
  String get acctFieldDtmfMethod => 'Método DTMF';

  @override
  String get acctOptDtmfInband => 'En banda';

  @override
  String get acctFieldRedirects => 'Redirecciones (3xx)';

  @override
  String get acctOptRedirectFollow => 'Seguir';

  @override
  String get acctOptRedirectAsk => 'Preguntar';

  @override
  String get acctFieldLockCodec => 'Fijar el códec tras contestar';

  @override
  String get acctFieldMediaKeepAlive => 'Keep-alive de medios';

  @override
  String get acctFieldDropCalls => 'Cortar llamadas si falla el registro';

  @override
  String get acctFieldExtraHeaders => 'Cabeceras SIP adicionales';

  @override
  String get acctFieldExtraHeadersHint => 'X-Header: valor (una por línea)';

  @override
  String get acctFieldRetryIntervalSub =>
      'Espera antes de reintentar un registro fallido. Rango de 0 a 86400';

  @override
  String get acctFieldUnregTimeout => 'Tiempo de espera de baja (ms)';

  @override
  String get acctFieldUnregTimeoutSub =>
      'Cuánto esperar la respuesta de la baja del registro. Rango de 0 a 60000';

  @override
  String get acctFieldMwiExpiry => 'Caducidad de la suscripción MWI (s)';

  @override
  String get acctFieldDscpSip => 'DSCP para SIP';

  @override
  String get acctFieldDscpSipSub =>
      'Marcado QoS de la señalización. Lo habitual es 24 (CS3)';

  @override
  String get acctFieldDscpRtp => 'DSCP para RTP';

  @override
  String get acctFieldDscpRtpSub =>
      'Marcado QoS de los medios. Lo habitual es 46 (EF)';

  @override
  String get acctFieldReinvite => 'Re-INVITE tras un cambio de red';

  @override
  String get acctFieldHangupOnIpChange => 'Colgar llamadas al cambiar de red';

  @override
  String get acctValidateInt => 'Introduce un número entero';

  @override
  String get acctValidateHostEmpty =>
      'Introduce el nombre o la dirección del servidor';

  @override
  String get acctValidateHostSpaces => 'El servidor no puede contener espacios';

  @override
  String get acctValidateHostFormat => 'Introduce solo host o host:puerto';

  @override
  String get acctValidatePortRange => 'El puerto debe estar entre 1 y 65535';

  @override
  String get acctValidateWsStart => 'La ruta debe empezar por \"/\"';

  @override
  String get acctValidateWsLength => 'Usa 120 caracteres como máximo';

  @override
  String get acctValidateWsSpaces => 'La ruta no puede contener espacios';

  @override
  String get acctTplAsteriskDescription =>
      'Extensión en tu propia centralita. UDP 5060, STUN activado.';

  @override
  String get acctTplAsteriskNotes =>
      'Usa el número de extensión PJSIP/SIP y su secreto. Para TLS o WebRTC, cambia el transporte más tarde en los ajustes de la cuenta.';

  @override
  String get acctTplAsteriskUsernameHint => 'Extensión (p. ej., 1001)';

  @override
  String get acctTpl3cxDescription =>
      'Usa la extensión, el ID de autenticación y la contraseña del portal de 3CX.';

  @override
  String get acctTpl3cxNotes =>
      'En 3CX abre la extensión y luego \"Teléfonos > Aprovisionamiento\" para ver el ID de autenticación (indícalo como usuario de autorización) y la contraseña. El FQDN es el de tu URL de 3CX.';

  @override
  String get acctTpl3cxUsernameHint => 'Extensión';

  @override
  String get acctTplFreeswitchDescription =>
      'Usuario del directorio en un servidor FreeSWITCH.';

  @override
  String get acctTplFreeswitchNotes =>
      'Usa el ID de usuario y la contraseña del directorio. El perfil interno predeterminado escucha en UDP/TCP 5060.';

  @override
  String get acctTplFreeswitchUsernameHint => 'ID de usuario';

  @override
  String get acctTplKamailioDescription =>
      'Servidor de registro con proxy SIP. Se recomienda TCP tras un NAT.';

  @override
  String get acctTplKamailioNotes =>
      'Usa el dominio SIP que atiende tu servidor de registro. Añade un proxy saliente en los ajustes de la cuenta si el servidor de registro se alcanza a través de otro host.';

  @override
  String get acctTplTwilioDescription =>
      'Credenciales de dominio SIP de Programmable Voice. TLS y SRTP.';

  @override
  String get acctTplTwilioNotes =>
      'Crea un dominio SIP en la consola de Twilio, añade una lista de credenciales y activa el registro SIP. Introduce el dominio completo (name.sip.twilio.com) como servidor, y el usuario y la contraseña de la lista de credenciales. TLS usa el puerto 5061. Twilio solo admite G.711.';

  @override
  String get acctTplTwilioUsernameHint => 'Usuario de la lista de credenciales';

  @override
  String get acctTplTelnyxDescription =>
      'Conexión por credenciales. UDP, G.711 / Opus.';

  @override
  String get acctTplTelnyxNotes =>
      'Crea una conexión por credenciales en el portal de Telnyx y copia su usuario y contraseña SIP (no los de inicio de sesión del portal). Asigna un número o un perfil de voz saliente a la conexión para hacer y recibir llamadas.';

  @override
  String get acctTplTelnyxUsernameHint =>
      'Usuario SIP (conexión por credenciales)';

  @override
  String get acctTplVoipmsDescription =>
      'Usuario y contraseña de subcuenta. Elige el POP más cercano.';

  @override
  String get acctTplVoipmsNotes =>
      'Usa una subcuenta creada en Sub Accounts, no tu cuenta principal. Elige el servidor (POP) más cercano de la lista de servidores de VoIP.ms y permítelo para tu IP si es necesario.';

  @override
  String get acctTplVoipmsUsernameHint => 'Subcuenta (p. ej., 123456_phone)';

  @override
  String get acctTplVonageDescription => 'Registro SIP con TLS.';

  @override
  String get acctTplVonageNotes =>
      'Vonage Business solo ofrece registro SIP en algunos planes. Introduce el servidor SIP, el usuario y la contraseña que aparecen en el portal de administración de Vonage para el dispositivo.';

  @override
  String get acctTplIax2Description =>
      'Inter-Asterisk eXchange sobre UDP 4569. Sin ajustes de NAT ni SRTP.';

  @override
  String get acctTplIax2Notes =>
      'Requiere un peer/user en iax.conf (type=friend o user+peer) con el mismo secreto. Asterisk renueva los registros IAX2 cada 60 s de forma predeterminada. El contexto es opcional y se envía como contexto de destino.';

  @override
  String get acctTplIax2UsernameHint => 'Usuario IAX2';

  @override
  String get acctTplWebrtcDescription =>
      'SIP sobre WebSocket seguro con DTLS-SRTP, ICE y RTCP-mux.';

  @override
  String get acctTplWebrtcNotes =>
      'Para endpoints WebSocket de Asterisk (webrtc=yes, TLS en http.conf en el 8089), FreeSWITCH o Kamailio. El servidor necesita un certificado TLS válido. Cambia la ruta de WebSocket en los ajustes de la cuenta si tu pasarela no usa /ws.';

  @override
  String get acctTplGenericDescription =>
      'Cualquier servidor de registro SIP. Completa los datos tú mismo.';

  @override
  String get acctTplDefaultUsernameHint => 'Extensión / usuario';

  @override
  String get appEngineFailedBody =>
      'Las llamadas y el registro no funcionarán hasta que se solucione. La causa habitual es un ajuste de red o de certificado incorrecto.';

  @override
  String get appEngineFailedTitle => 'No se pudo iniciar el motor de llamadas';

  @override
  String get appEngineNotRunning => 'El motor de llamadas no está en ejecución';

  @override
  String get appUnknownError => 'Error desconocido';

  @override
  String get appEngineOpenNetworkSettings => 'Abrir ajustes de red';

  @override
  String get appEngineUseSimulator => 'Usar simulador (demo)';

  @override
  String get appDbLockedTitle => 'Tus datos están bloqueados';

  @override
  String get appDbUnreadableTitle => 'No se pueden abrir tus datos';

  @override
  String get appDbLockedBody =>
      'El historial de llamadas, los contactos y los mensajes están cifrados en este dispositivo, pero la clave de cifrado ya no está en el llavero o almacén de claves del sistema (por ejemplo, tras restablecer el llavero o restaurar en un dispositivo nuevo).';

  @override
  String get appDbUnreadableBody =>
      'No se pudo leer la base de datos local. Puede estar dañada o la clave de cifrado no coincide.';

  @override
  String get appDbRecoveryAdvice =>
      'Inténtalo de nuevo si esperas que la clave vuelva (desbloquea el llavero, inicia sesión con el usuario correcto). Empezar de cero conserva el archivo anterior junto a los datos de la app, pero comienza con historial, contactos y mensajes vacíos; tendrás que añadir tus cuentas de nuevo.';

  @override
  String get appDbCopyDetails => 'Copiar detalles';

  @override
  String get appDbTryAgain => 'Reintentar';

  @override
  String get appDbStartFresh => 'Empezar de cero';

  @override
  String get appRedirectTitle => 'Llamada redirigida';

  @override
  String appRedirectMessage(String target) {
    return 'Llamada redirigida a $target. ¿Seguirla?';
  }

  @override
  String get appRedirectCancelCall => 'Cancelar llamada';

  @override
  String appDbConversionFailed(String mode, String error) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'encrypt': 'No se pudieron cifrar tus datos ($error). No se cambió nada.',
      'other':
          'No se pudieron descifrar tus datos ($error). No se cambió nada.',
    });
    return '$_temp0';
  }

  @override
  String appEngineNativeUnavailable(String error) {
    return 'Motor nativo no disponible ($error)';
  }

  @override
  String acctRetryingAt(String time) {
    return 'Reintentando a las $time';
  }

  @override
  String get acctRegistrationError => 'Error de registro';

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
  String get acctCallingFromDirect => 'Llamando directamente, sin cuenta';

  @override
  String acctCallingFromAccount(String name) {
    return 'Llamando desde $name';
  }

  @override
  String get acctCallingFromNone => 'Llamando sin cuenta';

  @override
  String get acctNoAccount => 'Sin cuenta';

  @override
  String acctSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String acctVoicemailCounts(int newCount, int oldCount) {
    return '$newCount nuevos, $oldCount antiguos';
  }

  @override
  String get acctAddAccount => 'Añadir cuenta';

  @override
  String get acctUnregister => 'Dar de baja';

  @override
  String get acctSheetDndSub => 'Rechazar llamadas entrantes en esta cuenta';

  @override
  String get acctKvServer => 'Servidor';

  @override
  String get acctKvResolvedServer => 'Servidor resuelto';

  @override
  String get acctKvClientCert => 'Cert. de cliente';

  @override
  String get acctKvClientCertValue => 'Presentado al servidor (TLS mutuo)';

  @override
  String get acctKvContact => 'Contacto';

  @override
  String get acctKvExpiresIn => 'Caduca en';

  @override
  String get acctKvVoicemail => 'Buzón de voz';

  @override
  String get acctOpenSipTrace => 'Abrir traza SIP';

  @override
  String get acctAddAnAccount => 'Añadir una cuenta';

  @override
  String get acctChooseAccountTooltip => 'Elige la cuenta desde la que llamar';

  @override
  String get acctDirectNoAccount => 'Directa (sin cuenta)';

  @override
  String get onboardingRequired => 'El usuario y el servidor son obligatorios';

  @override
  String onboardingDefaultPortHelper(int port) {
    return 'Se usa el puerto $port salvo que añadas :puerto';
  }

  @override
  String get onboardingFineTuneIax =>
      'Más tarde puedes ajustar con detalle los códecs y el registro en Ajustes.';

  @override
  String get onboardingFineTuneSip =>
      'Más tarde puedes ajustar con detalle el transporte, NAT, seguridad y códecs en Ajustes.';

  @override
  String get onboardingDemoUser => 'Usuario de demostración';

  @override
  String get onboardingDemoAccount => 'Cuenta de demostración';

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a SoftphonePro';

  @override
  String get onboardingWelcomeText =>
      'Llamadas profesionales para todas las plataformas: gratis y de código abierto. Sin anuncios ni rastreo.';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingPermissionsTitle => 'Permisos';

  @override
  String get onboardingPermissionsText =>
      'SoftphonePro necesita el micrófono para transmitir tu voz y las notificaciones para avisarte de llamadas y mensajes entrantes. Nada sale de tu dispositivo salvo tus llamadas.';

  @override
  String get onboardingChooseProvider => 'Elige tu proveedor';

  @override
  String get onboardingChooseProviderSub =>
      'Rellenamos por ti el transporte, los puertos y los ajustes de NAT.';

  @override
  String get onboardingScanQr => 'Escanear QR';

  @override
  String get onboardingImportUrl => 'Importar desde URL';

  @override
  String get onboardingSkip => 'Omitir por ahora (modo demo)';

  @override
  String get onboardingHidePassword => 'Ocultar contraseña';

  @override
  String get onboardingShowPassword => 'Mostrar contraseña';

  @override
  String get onboardingContextOptional => 'Contexto (opcional)';

  @override
  String get onboardingDisplayNameOptional => 'Nombre para mostrar (opcional)';

  @override
  String get onboardingLabelOptional => 'Etiqueta de la cuenta (opcional)';

  @override
  String get onboardingCallerIdOptional =>
      'Identificador de llamada (opcional)';

  @override
  String get onboardingAuthUserOptional =>
      'Usuario de autorización (si es distinto)';

  @override
  String acctRegWrongCredentials(int code) {
    return 'Usuario o contraseña incorrectos ($code)';
  }

  @override
  String get acctRegNotFound => 'Cuenta no encontrada en el servidor (404)';

  @override
  String get acctRegNoAnswer => 'El servidor no respondió (408)';

  @override
  String get acctRegIntervalTooShort =>
      'Intervalo de registro demasiado corto (423)';

  @override
  String get acctRegTemporarilyUnavailable =>
      'Servidor temporalmente no disponible (480)';

  @override
  String get acctRegServiceUnavailable => 'Servicio no disponible (503)';

  @override
  String get acctRegFailed => 'Falló el registro';

  @override
  String acctRegFailedWithCode(int code) {
    return 'Falló el registro ($code)';
  }

  @override
  String get acctNoticeRegistrationChange => 'No se pudo cambiar el registro';

  @override
  String acctNoticeApplyFailed(String name) {
    return 'No se pudo aplicar la cuenta \"$name\"';
  }

  @override
  String acctNoticeBackOnPrimary(String name) {
    return 'De vuelta en el servidor principal de $name';
  }

  @override
  String acctNoticeUsingBackup(String name) {
    return 'Usando el servidor de respaldo de $name';
  }

  @override
  String callDialAccountRegistered(String name) {
    return 'La cuenta $name está registrada';
  }

  @override
  String callDialAccountRegistering(String name) {
    return 'La cuenta $name aún se está registrando';
  }

  @override
  String callDialAccountOffline(String name) {
    return 'La cuenta $name aún no está registrada';
  }

  @override
  String callDialAccountFailed(String name) {
    return 'La cuenta $name no está registrada (falló el registro)';
  }

  @override
  String callDialAccountDisabled(String name) {
    return 'La cuenta $name está desactivada';
  }

  @override
  String get callDialEngineFailed => 'No se pudo iniciar el motor de llamadas';

  @override
  String callDialEngineFailedWithReason(String reason) {
    return 'No se pudo iniciar el motor de llamadas: $reason';
  }

  @override
  String get callDialEngineStarting =>
      'El motor de llamadas aún se está iniciando';

  @override
  String callDialBlockedWithReason(String status, String reason) {
    return '$status: $reason';
  }

  @override
  String callDialTimedOut(String status, int seconds) {
    return '$status tras $seconds s; la llamada no se realizó';
  }

  @override
  String get callJournalInterrupted => 'La app se cerró durante la llamada';

  @override
  String get callLinkMissingArgument => 'Falta un argumento';

  @override
  String get callLinkHttpsRequired =>
      'Los enlaces de configuración deben usar https';

  @override
  String get callLinkInvalidLan => 'Ese enlace de LAN no es válido';

  @override
  String callLinkConnectedTo(String name) {
    return 'Conectado con $name';
  }

  @override
  String get callLinkConnectFailed => 'No se pudo conectar con ese dispositivo';

  @override
  String callLinkCallFailed(String target) {
    return 'No se pudo realizar la llamada a $target';
  }

  @override
  String get callLinkImportTitle => 'Importar configuración';

  @override
  String callLinkImportBody(String host, int accounts) {
    String _temp0 = intl.Intl.pluralLogic(
      accounts,
      locale: localeName,
      other: '$accounts cuentas',
      one: '1 cuenta',
    );
    return '¿Importar la configuración de $host? Se añadirá $_temp0.';
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
      other: '$accounts cuentas',
      one: '1 cuenta',
    );
    return '¿Importar la configuración de $host? Se añadirá $_temp0 y $settings ajuste(s).';
  }

  @override
  String callIdentityForwardedFrom(String number) {
    return 'Desviada desde $number';
  }

  @override
  String callIdentityForwardedFromReason(String number, String reason) {
    return 'Desviada desde $number ($reason)';
  }

  @override
  String callIdentityTransferredBy(String number) {
    return 'Transferida por $number';
  }

  @override
  String get callRingtoneSystemDefault => 'Predeterminado del sistema';

  @override
  String get callRingtoneClassic => 'Clásico';

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
  String get callTransferring => 'Transfiriendo...';

  @override
  String get callTransferNotConfirmed =>
      'El servidor no confirmó la transferencia';

  @override
  String get callTransferStalledHint =>
      'La llamada sigue activa. Mantenla o vuelve a enviar la transferencia.';

  @override
  String get callTransferKeepCall => 'Mantener llamada';

  @override
  String get callAnnouncementOpening => 'Reproduciendo anuncio…';

  @override
  String get callAnnouncementTransfer =>
      'Reproduciendo aviso de transferencia…';

  @override
  String get callAnnouncementRecording => 'Reproduciendo aviso de grabación…';

  @override
  String get callAnnouncementSkip => 'Omitir';

  @override
  String get callNoiseTooltipMic => 'Cancelación de ruido con IA: tu micrófono';

  @override
  String get callNoiseTooltipIncoming =>
      'Cancelación de ruido con IA: otros participantes';

  @override
  String get callNoiseTooltipBoth =>
      'Cancelación de ruido con IA: tu micrófono y otros participantes';

  @override
  String get callNoiseOn => 'Cancelación de ruido activada';

  @override
  String get callNoiseTitle => 'Cancelación de ruido';

  @override
  String callNoiseMicStrength(String strength) {
    return 'Mi micrófono: $strength';
  }

  @override
  String get callNoiseMicOffHint => 'Elimina el ruido de fondo de mi micrófono';

  @override
  String get callResultAnswered => 'Contestada';

  @override
  String get callResultMissed => 'Perdida';

  @override
  String get callResultRejected => 'Rechazada';

  @override
  String get callResultFailed => 'Fallida';

  @override
  String get callResultBusy => 'Ocupado';

  @override
  String get callResultForwarded => 'Desviada';

  @override
  String get callResultTransferred => 'Transferida';

  @override
  String get callResultHandedOff => 'Traspasada';

  @override
  String get callResultInterrupted => 'Interrumpida';

  @override
  String get keypadCall => 'Llamar';

  @override
  String get keypadNoVoicemail =>
      'No hay número de buzón de voz configurado para esta cuenta';

  @override
  String get keypadCallDirectly => 'Llamar directamente (sin cuenta)';

  @override
  String get keypadAddAccount => 'Añade una cuenta para hacer llamadas';

  @override
  String keypadCallFrom(String account) {
    return 'Llamar desde $account';
  }

  @override
  String get keypadRecent => 'Recientes';

  @override
  String get keypadSuggestions => 'Sugerencias';

  @override
  String get keypadPhoneNumber => 'Número de teléfono';

  @override
  String get keypadPaste => 'Pegar';

  @override
  String get keypadEnterNumber => 'Introduce un número';

  @override
  String get keypadBackspace => 'Borrar (mantén pulsado para vaciar)';

  @override
  String get keypadTypeNameOrNumber => 'Escribe un nombre o número';

  @override
  String get keypadNoMatches => 'Sin coincidencias';

  @override
  String get keypadSuggestionsHint =>
      'Las sugerencias provienen de los contactos y las llamadas recientes';

  @override
  String keypadCallPerson(String name) {
    return 'Llamar a $name';
  }

  @override
  String get dialKeyStar => 'Asterisco';

  @override
  String get dialKeyPound => 'Almohadilla';

  @override
  String get dialKeyLongPressPlus => 'Mantén pulsado para el signo más';

  @override
  String get dialKeyLongPressSpeedDial =>
      'Mantén pulsado para marcación rápida';

  @override
  String get dialKeyLongPressVoicemail => 'Mantén pulsado para el buzón de voz';

  @override
  String get callBackToApp => 'Volver a la app (la llamada sigue activa)';

  @override
  String get callRecBadge => 'REC';

  @override
  String get callHideKeypad => 'Ocultar teclado';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callKeypad => 'Teclado';

  @override
  String get callSpeaker => 'Altavoz';

  @override
  String get callRouteBluetooth => 'Bluetooth';

  @override
  String get callRouteHeadset => 'Auriculares';

  @override
  String get callResume => 'Reanudar';

  @override
  String get callHold => 'Espera';

  @override
  String get callAddCall => 'Añadir llamada';

  @override
  String get callTransfer => 'Transferir';

  @override
  String get callStop => 'Detener';

  @override
  String get callRecord => 'Grabar';

  @override
  String get callSplit => 'Separar';

  @override
  String get callMerge => 'Unir';

  @override
  String get callSwap => 'Alternar';

  @override
  String get callEndCall => 'Finalizar llamada';

  @override
  String callEndCallWith(String name) {
    return 'Finalizar llamada con $name';
  }

  @override
  String get callAttendedTransferHint =>
      'Transferencia asistida. La persona que llamó está en espera.';

  @override
  String get callCompleteTransfer => 'Completar transferencia';

  @override
  String get callWaiting => 'Llamada en espera';

  @override
  String get callHoldAndAnswer =>
      'Poner en espera la llamada actual y contestar';

  @override
  String get callDecline => 'Rechazar';

  @override
  String get callAnswer => 'Contestar';

  @override
  String get callIncomingCall => 'Llamada entrante';

  @override
  String get callReply => 'Responder';

  @override
  String get callVoicemail => 'Buzón de voz';

  @override
  String get callToDevice => 'A dispositivo';

  @override
  String get callQuickReplyBusy => 'No puedo hablar ahora, te llamo luego.';

  @override
  String get callQuickReplyMeeting => 'Estoy en una reunión. ¿Me escribes?';

  @override
  String get callQuickReplyOnMyWay => 'Voy en camino.';

  @override
  String callReturnToCallWith(String name) {
    return 'Volver a la llamada con $name';
  }

  @override
  String callBarIncoming(String name) {
    return 'Entrante: $name';
  }

  @override
  String callBarInCallWith(String name) {
    return 'En llamada con $name';
  }

  @override
  String get callStatsCodec => 'Códec';

  @override
  String get callStatsJitter => 'Jitter';

  @override
  String get callStatsPacketLoss => 'Pérdida de paquetes';

  @override
  String get callStatsRoundTrip => 'Ida y vuelta';

  @override
  String get callStatsMedia => 'Medios';

  @override
  String get callStatsMosHistory => 'Historial MOS';

  @override
  String get callQualityTitle => 'Calidad de la llamada';

  @override
  String get callTransferTitle => 'Transferir llamada';

  @override
  String get callTransferModeBlind => 'Ciega';

  @override
  String get callTransferModeAttended => 'Asistida';

  @override
  String get callTransferModeLan => 'LAN';

  @override
  String get callTransferModeLanTooltip => 'Dispositivo LAN';

  @override
  String get callTransferNoLanDevices =>
      'No se encontraron dispositivos SoftphonePro vinculados en tu red. Vincula uno en la página de LAN.';

  @override
  String get callTransferLanDisabled =>
      'Activa LAN Link (Ajustes, LAN Link) para pasar esta llamada a otro dispositivo de tu red.';

  @override
  String get callTransferTalkFirst => 'Hablar antes';

  @override
  String get callTransferBlindHint =>
      'Pasa la llamada de inmediato. Tú te desconectas.';

  @override
  String get callTransferAttendedHint =>
      'Pone en espera a quien llama y llama primero al destino. Completa la transferencia cuando conteste.';

  @override
  String get callTransferNumberLabel => 'Número o dirección SIP';

  @override
  String get callTransferNow => 'Transferir ahora';

  @override
  String get callTransferCallAndConsult => 'Llamar y consultar';

  @override
  String get callRetrieveParkedTitle => 'Recuperar llamada aparcada';

  @override
  String get callRetrieveParkedHint => 'Ranura de aparcamiento, p. ej. 701';

  @override
  String get callMoreAudioOutput => 'Salida de audio';

  @override
  String get callMoreAudioDevices => 'Dispositivos de audio';

  @override
  String get callMoreAudioOutputSubtitle =>
      'Teléfono, altavoz, Bluetooth, auriculares';

  @override
  String get callMoreAudioDevicesSubtitle => 'Elige micrófono y altavoz';

  @override
  String get callMoreParkCall => 'Aparcar llamada';

  @override
  String get callMoreParkCallSubtitle => 'Transferir al código de aparcamiento';

  @override
  String get callMoreRetrieveParkedSubtitle =>
      'Marcar una ranura de aparcamiento';

  @override
  String get callMoreSendDtmf => 'Enviar dígitos DTMF';

  @override
  String get callMoreSendDtmfSubtitle =>
      'Escribe una secuencia completa, p. ej. un PIN';

  @override
  String get callSendDtmfTitle => 'Enviar DTMF';

  @override
  String get callMoreCallInfo => 'Info de la llamada';

  @override
  String get callMoreQualitySubtitle =>
      'MOS, jitter, pérdida y tiempo de ida y vuelta en vivo';

  @override
  String get callMoreSipTrace => 'Traza SIP';

  @override
  String get callMoreSipTraceSubtitle => 'Diagrama de escalera de esta llamada';

  @override
  String get callInfoRemote => 'Remoto';

  @override
  String get callInfoAccount => 'Cuenta';

  @override
  String get callInfoState => 'Estado';

  @override
  String get callInfoSecure => 'Seguro';

  @override
  String get callInfoPlainSignalling => 'señalización sin cifrar';

  @override
  String get callRoutePhone => 'Teléfono';

  @override
  String get callRouteWiredHeadset => 'Auriculares con cable';

  @override
  String get callAudioMicrophone => 'Micrófono';

  @override
  String callCardSemantics(String name, String state) {
    return 'Llamada con $name, $state';
  }

  @override
  String get callUnmute => 'Activar micrófono';

  @override
  String get callStopRecording => 'Detener grabación';

  @override
  String get callSplitConference => 'Separar conferencia';

  @override
  String get callMergeCalls => 'Unir llamadas';

  @override
  String get callSwapCalls => 'Alternar llamadas';

  @override
  String get callAttendedTransferBanner =>
      'Transferencia asistida: quien llamó está en espera.';

  @override
  String get callActiveCalls => 'Llamadas activas';

  @override
  String get callConferenceLevels => 'Niveles de la conferencia';

  @override
  String get callLevelVolume => 'Volumen';

  @override
  String get callLevelMicToParty => 'Micrófono al participante';

  @override
  String callPercentSemantics(int percent) {
    return '$percent por ciento';
  }

  @override
  String get callFailInvalidNumber => 'Número no válido (400)';

  @override
  String callFailNotAuthorised(String code) {
    return 'Llamada no autorizada ($code)';
  }

  @override
  String get callFailNumberNotFound => 'Número no encontrado (404)';

  @override
  String get callFailNoAnswerFromServer => 'Sin respuesta del servidor (408)';

  @override
  String get callFailTemporarilyUnavailable =>
      'Temporalmente no disponible (480)';

  @override
  String get callFailIncompleteNumber => 'Número incompleto (484)';

  @override
  String callFailBusy(String code) {
    return 'Ocupado ($code)';
  }

  @override
  String get callFailCancelled => 'Llamada cancelada (487)';

  @override
  String callFailNoCompatibleCodec(String code) {
    return 'Ningún códec compatible ($code)';
  }

  @override
  String get callFailServiceUnavailable => 'Servicio no disponible (503)';

  @override
  String get callFailDeclined => 'Llamada rechazada (603)';

  @override
  String get callFailGeneric => 'La llamada falló';

  @override
  String callFailGenericWithCode(String code) {
    return 'La llamada falló ($code)';
  }

  @override
  String callFailReasonWithCode(String reason, String code) {
    return '$reason ($code)';
  }

  @override
  String get callForegroundServiceText => 'Llamada en curso';

  @override
  String get callTrayInCall => 'En una llamada';

  @override
  String get callHistoryBlocked => 'Bloqueada';

  @override
  String get callHistoryAnonymityDisallowed => 'Anonimato no permitido';

  @override
  String get callHistoryDoNotDisturb => 'No molestar';

  @override
  String get callHistoryBusy => 'Ocupado';

  @override
  String get callHistoryForwardedAlways => 'Desviada (siempre)';

  @override
  String get callHistoryForwardedBusy => 'Desviada (ocupado)';

  @override
  String get callHistorySentToVoicemail => 'Enviada al buzón de voz';

  @override
  String get callHistoryRedirected => 'Redirigida';

  @override
  String get callIncomingNotificationBody => 'Llamada entrante';

  @override
  String callIncomingNotificationBodyOnAccount(String account) {
    return 'Llamada entrante en $account';
  }

  @override
  String get callMissedNotificationTitle => 'Llamada perdida';

  @override
  String get callErrEngineNotRunning =>
      'El motor de llamadas aún no está en ejecución';

  @override
  String get callErrAddAccount => 'Añade una cuenta para hacer llamadas';

  @override
  String get callErrCouldNotPlace => 'No se pudo realizar la llamada';

  @override
  String callErrAccountNotRegistered(String account) {
    return '$account no está registrada';
  }

  @override
  String get callErrCouldNotAnswer => 'No se pudo contestar';

  @override
  String get callErrNoVoicemailNumber =>
      'No hay número de buzón de voz para esta cuenta';

  @override
  String get callErrTransferFailed => 'Falló la transferencia';

  @override
  String callErrTransferFailedWithReason(String reason, int code) {
    return 'Falló la transferencia: $reason ($code)';
  }

  @override
  String get callErrCouldNotMerge => 'No se pudieron unir las llamadas';

  @override
  String get callErrCouldNotStartRecording => 'No se pudo iniciar la grabación';

  @override
  String get callErrCouldNotStopRecording => 'No se pudo detener la grabación';

  @override
  String callParkingNotice(String code) {
    return 'Aparcando llamada (marca $code)';
  }

  @override
  String get callErrParkFailed => 'Falló el aparcamiento';

  @override
  String get callErrHandoffFailed => 'Falló el traspaso';

  @override
  String get callErrCouldNotSendToDevice => 'No se pudo enviar al dispositivo';

  @override
  String get callHistoryForwardedNoAnswer => 'Desviada (sin respuesta)';

  @override
  String get shellTabKeypad => 'Teclado';

  @override
  String get shellTabRecents => 'Recientes';

  @override
  String get shellTabContacts => 'Contactos';

  @override
  String get shellTabMessages => 'Mensajes';

  @override
  String get shellTabPresence => 'Presencia';

  @override
  String get shellTabLan => 'LAN';

  @override
  String get shellTabRecordings => 'Grabaciones';

  @override
  String get shellSearchSemantics =>
      'Buscar contactos, historial o marcar un número';

  @override
  String get shellSearchHint => 'Buscar o marcar';

  @override
  String get shellVoicemailTooltip => 'Buzón de voz';

  @override
  String shellVoicemailNewTooltip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes de voz nuevos. Haz clic para llamar al buzón',
      one: '1 mensaje de voz nuevo. Haz clic para llamar al buzón',
    );
    return '$_temp0';
  }

  @override
  String get shellStatusAway => 'Ausente';

  @override
  String get shellStatusTooltip => 'Tu estado';

  @override
  String get shellDemoBanner =>
      'Modo demo: las llamadas son simuladas y nada llega a una red real.';

  @override
  String get uiToday => 'Hoy';

  @override
  String get uiYesterday => 'Ayer';

  @override
  String get uiUnknownCaller => 'Llamante desconocido';

  @override
  String get uiCallEnded => 'Llamada finalizada';

  @override
  String get uiCallTransferNotConfirmed => 'Transferencia sin confirmar';

  @override
  String get uiCallTransferring => 'Transfiriendo...';

  @override
  String get uiCallConference => 'Conferencia';

  @override
  String get uiCallOnHold => 'En espera';

  @override
  String get uiCallHeldByRemote => 'En espera por el otro lado';

  @override
  String get uiCallCalling => 'Llamando...';

  @override
  String get uiCallRinging => 'Sonando...';

  @override
  String get uiCallConnecting => 'Conectando...';

  @override
  String get uiCallIncoming => 'Llamada entrante';

  @override
  String get uiCallConnected => 'Conectada';

  @override
  String get uiQrScanTitle => 'Escanear código QR';

  @override
  String get uiQrPasteHint => 'Pega el texto del código';

  @override
  String get uiQrNoCamera =>
      'El escaneo con cámara no está disponible en este dispositivo. Pega el texto del código.';

  @override
  String get uiQrPaste => 'Pegar';

  @override
  String get uiQrUse => 'Usar';

  @override
  String get uiQrCameraDenied =>
      'El acceso a la cámara está desactivado. Permítelo en los ajustes del sistema o pega abajo el texto del código.';

  @override
  String get uiQrCameraUnavailable =>
      'La cámara no está disponible. Pega abajo el texto del código.';

  @override
  String get presenceLampRinging => 'Sonando';

  @override
  String get presenceHeader => 'Campo de lámpara de ocupado';

  @override
  String get presenceChooseTooltip => 'Elegir contactos a vigilar';

  @override
  String get presenceEmptyTitle => 'No hay extensiones en el panel';

  @override
  String get presenceEmptySubtitle =>
      'Activa \"Mostrar en el panel BLF\" en un contacto para ver cuándo está libre, sonando u ocupado.';

  @override
  String get presenceOpenContacts => 'Abrir contactos';

  @override
  String presenceTileSemantics(String name, String status) {
    return '$name, $status. Toca para llamar, mantén pulsado para más opciones';
  }

  @override
  String presenceCallName(String name) {
    return 'Llamar a $name';
  }

  @override
  String get presencePickup => 'Capturar esta extensión';

  @override
  String get presencePickupSub =>
      'Contesta su llamada entrante (captura dirigida)';

  @override
  String get presenceTransferHere => 'Transferir aquí la llamada actual';

  @override
  String get presenceRemove => 'Quitar del panel';

  @override
  String get uiCall => 'Llamar';

  @override
  String get uiMessage => 'Mensaje';

  @override
  String get recentsSearchTooltip => 'Buscar en el historial';

  @override
  String get recentsClearTitle => '¿Borrar el historial de llamadas?';

  @override
  String recentsClearMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminarán las $count entradas.',
      one: 'Se eliminará 1 entrada.',
    );
    return '$_temp0';
  }

  @override
  String get recentsCopiedCsv => 'Historial copiado al portapapeles como CSV';

  @override
  String get recentsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get recentsMenuClear => 'Borrar historial';

  @override
  String get recentsSearchHint => 'Buscar nombre o número';

  @override
  String get recentsFilterAll => 'Todas';

  @override
  String get recentsFilterMissed => 'Perdidas';

  @override
  String get recentsFilterIncoming => 'Entrantes';

  @override
  String get recentsFilterOutgoing => 'Salientes';

  @override
  String get recentsFilterAccount => 'Filtrar por cuenta';

  @override
  String get recentsAllAccounts => 'Todas las cuentas';

  @override
  String get recentsAccountFallback => 'Cuenta';

  @override
  String get recentsEmptyNone => 'Aún no hay llamadas';

  @override
  String get recentsEmptyNoMatch => 'No hay llamadas coincidentes';

  @override
  String get recentsEmptyNoneSub => 'Tus llamadas aparecerán aquí.';

  @override
  String get recentsEmptyNoMatchSub => 'Prueba con otro filtro.';

  @override
  String get recentsOpenKeypad => 'Abrir teclado';

  @override
  String get recentsShowAll => 'Mostrar todas';

  @override
  String get recentsSelectCall => 'Selecciona una llamada';

  @override
  String get recentsSelectCallSub =>
      'Aquí aparecerán los detalles, la calidad y las grabaciones.';

  @override
  String recentsRowSemantics(
    String kind,
    String name,
    String number,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'missed': 'Llamada perdida',
      'incoming': 'Llamada entrante',
      'other': 'Llamada saliente',
    });
    return '$_temp0 $name, $number, $time';
  }

  @override
  String recentsCallTooltip(String name) {
    return 'Llamar a $name';
  }

  @override
  String get recentsAddAccountToMessage =>
      'Añade una cuenta para enviar mensajes';

  @override
  String get recentsAddContact => 'Añadir contacto';

  @override
  String get recentsContact => 'Contacto';

  @override
  String get recentsBlock => 'Bloquear';

  @override
  String get recentsUnblock => 'Desbloquear';

  @override
  String recentsBlockTitle(String number) {
    return '¿Bloquear $number?';
  }

  @override
  String get recentsBlockMessage =>
      'Las llamadas de este número se rechazarán automáticamente.';

  @override
  String get recentsQualityHeader => 'Calidad de la llamada';

  @override
  String recentsQualitySummary(String mos, String jitter, String loss) {
    return 'Peor MOS $mos   ·   Jitter $jitter ms   ·   Pérdida $loss %';
  }

  @override
  String get recentsRecordingsHeader => 'Grabaciones';

  @override
  String get recentsOpenInRecordings => 'Abrir en Grabaciones';

  @override
  String recentsRelatedCall(String title) {
    return 'Llamada relacionada: $title';
  }

  @override
  String get recentsHistoryHeader => 'Historial';

  @override
  String recentsDirectionResult(String direction, String result) {
    return '$direction  ·  $result';
  }

  @override
  String get recentsNoCallsWithNumber => 'No hay llamadas con este número';

  @override
  String get recentsDeleteTitle => '¿Eliminar estas llamadas?';

  @override
  String recentsDeleteMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elimina $count entradas de $name.',
      one: 'Elimina 1 entrada de $name.',
    );
    return '$_temp0';
  }

  @override
  String get recentsDeleteFromHistory => 'Eliminar del historial';

  @override
  String get recentsCallDetails => 'Detalles de la llamada';

  @override
  String get contactsFavoritesHeader => '★ Favoritos';

  @override
  String get contactsFavoritesOnly => 'Solo favoritos';

  @override
  String get contactsShowAll => 'Mostrar todos';

  @override
  String get contactsImportExportTooltip => 'Importar y exportar';

  @override
  String get contactsMenuDevice => 'Importar desde el dispositivo';

  @override
  String get contactsMenuFile => 'Importar archivo vCard / CSV';

  @override
  String get contactsMenuClipboard => 'Importar desde el portapapeles';

  @override
  String get contactsMenuCopyVcard => 'Copiar como vCard';

  @override
  String get contactsMenuCopyCsv => 'Copiar como CSV';

  @override
  String get contactsNewTooltip => 'Nuevo contacto';

  @override
  String get contactsSearchHint => 'Buscar contactos';

  @override
  String get contactsEmptyTitle => 'Aún no hay contactos';

  @override
  String get contactsEmptySubtitle =>
      'Añade a las personas a las que llamas a menudo o importa un archivo vCard o CSV.';

  @override
  String get contactsEmptyAction => 'Añadir un contacto';

  @override
  String get contactsNoMatches => 'Sin coincidencias';

  @override
  String contactsCallName(String name) {
    return 'Llamar a $name';
  }

  @override
  String get contactsSelect => 'Selecciona un contacto';

  @override
  String get contactsCopiedVcard => 'Contactos copiados como vCard';

  @override
  String get contactsCopiedCsv => 'Contactos copiados como CSV';

  @override
  String get contactsDeviceDenied =>
      'Se denegó el acceso a los contactos. Permítelo en los ajustes del sistema para importar.';

  @override
  String get contactsDeviceNone =>
      'No se encontraron contactos en este dispositivo';

  @override
  String contactsNothingNew(int count) {
    return 'No hay nada nuevo que importar ($count ya existentes)';
  }

  @override
  String get contactsImportDeviceTitle => '¿Importar desde el dispositivo?';

  @override
  String contactsImportNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos nuevos',
      one: '1 contacto nuevo',
    );
    return '$_temp0';
  }

  @override
  String contactsImportUpdated(int count) {
    return '$count actualizados con números adicionales';
  }

  @override
  String contactsImportSkipped(int count) {
    return '$count omitidos (duplicados o sin número de teléfono)';
  }

  @override
  String contactsImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos importados',
      one: '1 contacto importado',
    );
    return '$_temp0';
  }

  @override
  String get contactsImportNone => 'No se encontraron contactos en esos datos';

  @override
  String get contactsLabelMobile => 'móvil';

  @override
  String get contactsLabelWork => 'trabajo';

  @override
  String get contactsLabelHome => 'casa';

  @override
  String get contactsLabelOther => 'otro';

  @override
  String get contactsSip => 'SIP';

  @override
  String get contactsNotFound => 'Contacto no encontrado';

  @override
  String get contactsActionFavorite => 'Favorito';

  @override
  String get contactsNumbersHeader => 'Números';

  @override
  String get contactsSipAddress => 'Dirección SIP';

  @override
  String get contactsDetailsHeader => 'Detalles';

  @override
  String get contactsOnBlf => 'Se muestra en el panel BLF';

  @override
  String get contactsAlwaysRecorded => 'Las llamadas siempre se graban';

  @override
  String contactsDeleteTitle(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get contactsDeleteMessage =>
      'Este contacto se eliminará de este dispositivo.';

  @override
  String get contactsDeleteButton => 'Eliminar contacto';

  @override
  String get contactsDetailTitle => 'Contacto';

  @override
  String get contactsErrorNameOrNumber => 'Introduce un nombre o un número';

  @override
  String get contactsEditTitle => 'Editar contacto';

  @override
  String get contactsFieldName => 'Nombre';

  @override
  String get contactsFieldCompany => 'Empresa';

  @override
  String get contactsFieldNumber => 'Número';

  @override
  String get contactsRemoveNumber => 'Quitar número';

  @override
  String get contactsAddNumber => 'Añadir número';

  @override
  String get contactsSipHeader => 'Direcciones SIP';

  @override
  String get contactsRemoveAddress => 'Quitar dirección';

  @override
  String get contactsAddSip => 'Añadir dirección SIP';

  @override
  String get contactsFieldEmail => 'Correo electrónico';

  @override
  String get contactsFieldNotes => 'Notas';

  @override
  String get contactsFieldFavorite => 'Favorito';

  @override
  String get contactsShowOnBlf => 'Mostrar en el panel BLF';

  @override
  String get contactsShowOnBlfSub =>
      'Vigila la presencia y la lámpara de ocupado de esta extensión';

  @override
  String get contactsAlwaysRecordTitle =>
      'Grabar siempre las llamadas con este contacto';

  @override
  String get contactsAlwaysRecordSub =>
      'Tiene prioridad sobre las reglas de grabación automática';

  @override
  String get contactsRingtone => 'Tono de llamada';

  @override
  String get contactsPresenceVia => 'Presencia mediante la cuenta';

  @override
  String get contactsDefaultAccount => 'Cuenta predeterminada';

  @override
  String get contactsDeleteContactTitle => '¿Eliminar el contacto?';

  @override
  String get contactsCannotUndo => 'Esta acción no se puede deshacer.';

  @override
  String get messagesNewMessage => 'Nuevo mensaje';

  @override
  String get messagesNumberOrSip => 'Número o dirección SIP';

  @override
  String get messagesNoConversations => 'No hay conversaciones';

  @override
  String get messagesEmptySubtitle =>
      'Envía un mensaje SIP a cualquier extensión o dirección desde tus cuentas.';

  @override
  String get messagesTyping => 'escribiendo...';

  @override
  String get messagesYouPrefix => 'Tú: ';

  @override
  String get messagesSelect => 'Selecciona una conversación';

  @override
  String get messagesLanOnline => 'En línea en tu red';

  @override
  String get messagesLanOffline =>
      'Sin conexión. Los mensajes se envían cuando vuelva.';

  @override
  String messagesSendFileTo(String name) {
    return 'Enviar un archivo a $name';
  }

  @override
  String messagesCallName(String name) {
    return 'Llamar a $name';
  }

  @override
  String get messagesDeleteTitle => '¿Eliminar la conversación?';

  @override
  String messagesDeleteMessage(String name) {
    return 'Se eliminarán todos los mensajes con $name.';
  }

  @override
  String get messagesDeleteMenu => 'Eliminar conversación';

  @override
  String get messagesSayHello => 'Saluda';

  @override
  String get messagesLanEmptySub =>
      'Los mensajes van directamente a este dispositivo por tu red, con cifrado de extremo a extremo.';

  @override
  String get messagesSipEmptySub =>
      'Los mensajes se envían con SIP MESSAGE a través de tu cuenta.';

  @override
  String get messagesInputHint => 'Mensaje';

  @override
  String get messagesSend => 'Enviar';

  @override
  String get messagesStatusSending => 'Enviando';

  @override
  String get messagesStatusSent => 'Enviado';

  @override
  String get messagesStatusDelivered => 'Entregado';

  @override
  String get messagesStatusRead => 'Leído';

  @override
  String get messagesStatusFailed => 'Fallido';

  @override
  String get messagesNotDelivered => 'No entregado. Toca para reintentar';

  @override
  String get uiStatusRegistered => 'Registrada';

  @override
  String get uiStatusRegistering => 'Registrando';

  @override
  String get uiStatusRegFailed => 'Registro fallido';

  @override
  String get uiStatusDisabled => 'Desactivada';

  @override
  String get uiQualityMeasuring => 'Midiendo';

  @override
  String get uiQualityExcellent => 'Excelente';

  @override
  String get uiQualityGood => 'Buena';

  @override
  String get uiQualityFair => 'Aceptable';

  @override
  String get uiQualityPoor => 'Pobre';

  @override
  String get uiQualityBad => 'Mala';

  @override
  String uiQualitySemantics(String label) {
    return 'Calidad de la llamada: $label';
  }

  @override
  String uiQualitySemanticsMos(String label, String mos) {
    return 'Calidad de la llamada: $label, MOS $mos';
  }

  @override
  String uiQualityTooltip(String label) {
    return 'Calidad de la llamada: $label';
  }

  @override
  String get uiSecureFull => 'Cifrada';

  @override
  String get uiSecureMedia => 'Medios cifrados';

  @override
  String get uiSecureSignalling => 'Señalización cifrada';

  @override
  String get uiSecureNone => 'Sin cifrar';

  @override
  String get uiSecureSrtpLine => 'Medios SRTP';

  @override
  String get uiSecureTlsLine => 'Señalización TLS';

  @override
  String lanCallHandingOver(String name) {
    return 'Pasando a $name';
  }

  @override
  String lanCallIntercomToNamed(String name) {
    return 'Intercomunicador a $name';
  }

  @override
  String get lanCallIntercomToUnnamed =>
      'Intercomunicador a un dispositivo cercano';

  @override
  String lanCallIntercomFromNamed(String name) {
    return 'Intercomunicador de $name';
  }

  @override
  String get lanCallIntercomFromUnnamed =>
      'Intercomunicador de un dispositivo cercano';

  @override
  String lanCallToNamed(String name) {
    return 'Llamada LAN a $name';
  }

  @override
  String get lanCallToUnpaired => 'Llamada LAN a un dispositivo sin vincular';

  @override
  String lanCallFromNamed(String name) {
    return 'Llamada LAN de $name';
  }

  @override
  String get lanCallFromUnpaired =>
      'Llamada LAN de un dispositivo sin vincular';

  @override
  String lanHandoffTransferredFrom(String device) {
    return 'Llamada transferida desde $device';
  }

  @override
  String lanHandoffTransferredFromCaller(String device, String caller) {
    return 'Llamada transferida desde $device: $caller';
  }

  @override
  String get lanHandoffAnotherDevice => 'otro dispositivo';

  @override
  String lanRelayedTitle(String name) {
    return 'Retransmitida a $name';
  }

  @override
  String lanRelayedSubtitle(String name) {
    return 'Quien llama está hablando con $name. Tú no estás en la llamada.';
  }

  @override
  String lanRelayDialingTitle(String name) {
    return 'Llamando a $name...';
  }

  @override
  String lanRelayDialingSubtitle(String name) {
    return 'Quien llama sigue conectado mientras $name contesta.';
  }

  @override
  String lanRelayOfferingTitle(String name) {
    return 'Preguntando a $name...';
  }

  @override
  String get lanRelayOfferingSubtitle => 'Esperando a que acepte la llamada.';

  @override
  String lanRelayConsultingTitle(String name) {
    return 'Hablando con $name';
  }

  @override
  String get lanRelayConsultingSubtitle =>
      'Quien llama está en espera. Completa el traspaso cuando estés listo.';

  @override
  String get lanRelayTakingBack => 'Recuperando la llamada...';

  @override
  String get lanRelayTakeBack => 'Recuperar';

  @override
  String get lanRelayEnd => 'Finalizar';

  @override
  String get lanSendToDevice => 'Enviar a dispositivo';

  @override
  String get lanBusy => 'Ocupado';

  @override
  String get lanNoPairedOnline => 'Ningún dispositivo vinculado está en línea';

  @override
  String lanPairRejectedBy(String name) {
    return '$name rechazó la vinculación.';
  }

  @override
  String get lanPairRejected => 'Vinculación rechazada.';

  @override
  String get lanPairCancelled => 'Vinculación cancelada.';

  @override
  String get lanPairTimedOut =>
      'Se agotó el tiempo de la vinculación. Inténtalo de nuevo.';

  @override
  String get lanPairFailed => 'Falló la vinculación';

  @override
  String lanPairFailedReason(String reason) {
    return 'Falló la vinculación: $reason';
  }

  @override
  String get lanPairThisDevice => 'este dispositivo';

  @override
  String get lanPairConnecting => 'Conectando de forma segura...';

  @override
  String lanPairWantsToPair(String name) {
    return '$name quiere vincularse con este dispositivo.';
  }

  @override
  String lanPairPairingWith(String name) {
    return 'Vinculando con $name.';
  }

  @override
  String get lanPairCheckCode =>
      'Comprueba que este código sea el mismo en ambas pantallas.';

  @override
  String lanPairCodeSemantics(String code) {
    return 'Código de vinculación $code';
  }

  @override
  String lanPairWaitingConfirm(String name) {
    return 'Esperando la confirmación de $name...';
  }

  @override
  String lanPairRemoteConfirmed(String name) {
    return '$name ha confirmado.';
  }

  @override
  String get lanPairReject => 'Rechazar';

  @override
  String get lanPairCodesMatch => 'Los códigos coinciden';

  @override
  String lanPairPairedWith(String name) {
    return 'Vinculado con $name.';
  }

  @override
  String get lanPairRequestTitle => 'Solicitud de vinculación';

  @override
  String lanPairTitle(String name) {
    return 'Vincular con $name';
  }

  @override
  String get lanActionDecline => 'Rechazar';

  @override
  String get lanActionAccept => 'Aceptar';

  @override
  String get lanFileIncomingTitle => 'Archivo entrante';

  @override
  String lanFileSizeFrom(String size, String name) {
    return '$size de $name';
  }

  @override
  String get lanHandoffOfferTitle => '¿Transferir una llamada aquí?';

  @override
  String lanHandoffOfferBody(String device, String caller, String account) {
    String _temp0 = intl.Intl.selectLogic(caller, {
      'none': '',
      'other': ' de $caller',
    });
    String _temp1 = intl.Intl.selectLogic(account, {
      'none': '',
      'other': ' en $account',
    });
    return '$device quiere pasarte una llamada$_temp0$_temp1.';
  }

  @override
  String get lanHandoffOfferAttended => 'Hablará contigo primero.';

  @override
  String get lanHandoffTakeCall => 'Tomar llamada';

  @override
  String lanIntercomRequestTitle(String name) {
    return '¿Permitir intercomunicador de $name?';
  }

  @override
  String get lanIntercomRequestBody =>
      'Su llamada se contestará automáticamente por el altavoz.';

  @override
  String get lanIntercomDeny => 'Denegar';

  @override
  String get lanIntercomAllow => 'Permitir';

  @override
  String lanNoticeUnpairedByPeer(String name) {
    return '$name quitó este dispositivo de su lista de vinculados';
  }

  @override
  String get lanBadge => 'LAN';

  @override
  String lanSendingFiles(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviando $count archivos...',
      one: 'Enviando $name...',
    );
    return '$_temp0';
  }

  @override
  String get lanNewMessage => 'Nuevo mensaje';

  @override
  String get lanSipMessage => 'Mensaje SIP';

  @override
  String get lanSipMessageSub =>
      'A un número o dirección a través de tu cuenta';

  @override
  String get lanChatOnline => 'Chat LAN, en línea';

  @override
  String get lanChatOffline => 'Chat LAN, sin conexión';

  @override
  String lanSavedAt(String path) {
    return 'Guardado en $path (ruta copiada)';
  }

  @override
  String get lanPageTitle => 'LAN Link';

  @override
  String get lanPageSubtitle => 'Tus dispositivos, hablando directamente';

  @override
  String get lanConnectByAddress => 'Conectar por dirección';

  @override
  String get lanSettingsTooltip => 'Ajustes de LAN';

  @override
  String get lanOffTitle => 'LAN Link está desactivado';

  @override
  String get lanOffSubtitle =>
      'Encuentra tus otros dispositivos con SoftphonePro, chatea, envía archivos y pasa llamadas, sin ningún servidor.';

  @override
  String get lanTurnOn => 'Activar LAN Link';

  @override
  String lanCouldNotStart(String error) {
    return 'No se pudo iniciar LAN Link: $error';
  }

  @override
  String get lanConnectHelp =>
      'Escribe host:puerto o pega el texto del código QR que muestra el otro dispositivo.';

  @override
  String get lanScanTitle => 'Escanear QR de vinculación LAN';

  @override
  String get lanScanQr => 'Escanear QR';

  @override
  String get lanPaste => 'Pegar';

  @override
  String get lanConnect => 'Conectar';

  @override
  String lanConnectedTo(String name) {
    return 'Conectado con $name';
  }

  @override
  String get lanCouldNotConnect => 'No se pudo conectar';

  @override
  String get lanCouldNotStartPairing => 'No se pudo iniciar la vinculación';

  @override
  String get lanThisDevice => 'Este dispositivo';

  @override
  String get lanDeviceNameTitle => 'Nombre del dispositivo';

  @override
  String get lanStarting => 'Iniciando...';

  @override
  String get lanVisible => 'Visible en tu red';

  @override
  String get lanNotRunning => 'Detenido';

  @override
  String lanAccountsShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cuentas compartidas',
      one: '1 cuenta compartida',
    );
    return '$_temp0';
  }

  @override
  String get lanFingerprint => 'Huella';

  @override
  String get lanHideQr => 'Ocultar código QR';

  @override
  String get lanShowQr => 'Mostrar código QR para conectar otro dispositivo';

  @override
  String get lanCopyConnectionText => 'Copiar texto de conexión';

  @override
  String get lanConnectionTextCopied => 'Texto de conexión copiado';

  @override
  String get lanActiveOnOthers => 'Activas en tus otros dispositivos';

  @override
  String get lanPairedDevices => 'Dispositivos vinculados';

  @override
  String get lanNoPaired =>
      'Aún no hay dispositivos vinculados. Vincula un dispositivo cercano para chatear, enviar archivos y pasar llamadas.';

  @override
  String get lanNearby => 'Cercanos';

  @override
  String get lanNearbyHint =>
      'Buscando SoftphonePro en tu red. Los demás dispositivos necesitan tener LAN Link activado. También puedes conectar por dirección con el botón de enlace de arriba.';

  @override
  String get lanTransfers => 'Transferencias';

  @override
  String get lanFiles => 'Archivos';

  @override
  String get lanPairedBadge => 'Vinculado';

  @override
  String get lanTyping => 'escribiendo...';

  @override
  String get lanPair => 'Vincular';

  @override
  String get lanUnpair => 'Desvincular';

  @override
  String lanUnpairTitle(String name) {
    return '¿Desvincular $name?';
  }

  @override
  String get lanUnpairMessage =>
      'Tendrás que volver a vincular para chatear, enviar archivos o pasar llamadas.';

  @override
  String get lanActionMessage => 'Mensaje';

  @override
  String get lanActionSendFile => 'Enviar archivo';

  @override
  String get lanActionCall => 'Llamar';

  @override
  String get lanActionIntercom => 'Intercomunicador';

  @override
  String lanRemoteActiveOn(String device) {
    return 'Activa en $device';
  }

  @override
  String lanRemoteActiveOnAccount(String device, String account) {
    return 'Activa en $device  ·  $account';
  }

  @override
  String get lanPull => 'Traer';

  @override
  String get lanTransferPreparing => 'Preparando...';

  @override
  String get lanTransferWaitingYou => 'Esperándote';

  @override
  String lanTransferWaitingPeer(String name) {
    return 'Esperando a que $name acepte';
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
    return 'A $name  ·  $status';
  }

  @override
  String lanFileFromPeer(String size, String name) {
    return '$size  ·  de $name';
  }

  @override
  String lanFileToPeer(String size, String name) {
    return '$size  ·  a $name';
  }

  @override
  String lanFileFailed(String error) {
    return 'Fallido: $error';
  }

  @override
  String get lanFileActions => 'Acciones del archivo';

  @override
  String get lanPathCopied => 'Ruta copiada';

  @override
  String get lanFileOpen => 'Abrir';

  @override
  String get lanFileShowInFolder => 'Mostrar en carpeta';

  @override
  String get lanFileCopyPath => 'Copiar ruta';

  @override
  String lanNetworkError(String message) {
    return 'Error de red: $message';
  }

  @override
  String get lanErrNotRunning => 'Activa primero LAN Link';

  @override
  String get lanErrBadAddress =>
      'Introduce una dirección como 192.168.1.20:4711 o pega el texto del código QR';

  @override
  String get lanErrFingerprint =>
      'Ese dispositivo no coincide con el código escaneado. ¿El código QR venía de otro dispositivo?';

  @override
  String lanNoticeReceived(String file, String name) {
    return 'Recibido $file de $name';
  }

  @override
  String lanNoticeSent(String file, String name) {
    return 'Enviado $file a $name';
  }

  @override
  String lanNoticeDeclined(String name, String file) {
    return '$name rechazó $file';
  }

  @override
  String lanNoticeTransferFailed(String error) {
    return 'Falló la transferencia del archivo: $error';
  }

  @override
  String get lanNoticeNeedLanOn =>
      'Activa LAN Link para llamar a dispositivos cercanos';

  @override
  String get lanNoticePairFirst => 'Vincúlate primero con este dispositivo';

  @override
  String lanNoticeNotReachable(String name) {
    return '$name no está disponible para llamadas en este momento';
  }

  @override
  String lanNoticeAsking(String name) {
    return 'Preguntando a $name…';
  }

  @override
  String lanNoticeIntercomDenied(String name) {
    return '$name no permitió el intercomunicador (o no respondió)';
  }

  @override
  String get lanHoOff => 'LAN Link está desactivado';

  @override
  String get lanHoPairFirst => 'Vincúlate primero con ese dispositivo';

  @override
  String lanHoOffline(String name) {
    return '$name no está en línea';
  }

  @override
  String get lanHoAlready => 'Esta llamada ya se está traspasando';

  @override
  String get lanHoEnded => 'La llamada ya ha finalizado';

  @override
  String get lanHoWaitConnected => 'Espera a que la llamada esté conectada';

  @override
  String get lanHoLanCall => 'Las llamadas LAN no se pueden traspasar';

  @override
  String lanHoPeerNoLan(String name) {
    return '$name no puede recibir llamadas por la red (las llamadas LAN están desactivadas allí)';
  }

  @override
  String get lanHoNoLanHere =>
      'Las llamadas LAN no están disponibles en este dispositivo';

  @override
  String lanHoDeclined(String name) {
    return '$name rechazó la llamada. Sigue contigo.';
  }

  @override
  String lanHoTimeout(String name) {
    return '$name no respondió. La llamada sigue contigo.';
  }

  @override
  String get lanHoCancelled =>
      'Se canceló el traspaso. La llamada sigue contigo.';

  @override
  String lanHoUnreachable(String name) {
    return 'No se pudo contactar con $name. La llamada sigue contigo.';
  }

  @override
  String lanHoUnreachableReason(String name, String reason) {
    return 'No se pudo contactar con $name ($reason). La llamada sigue contigo.';
  }

  @override
  String get lanHoEndedBefore =>
      'La llamada finalizó antes de poder traspasarse';

  @override
  String lanHoPbxRefused(String name) {
    return 'El sistema telefónico rechazó la transferencia y $name no puede recibir llamadas LAN';
  }

  @override
  String get lanHoPbxFailedRelaying =>
      'Falló la transferencia por el sistema telefónico. Se retransmite por la red.';

  @override
  String lanHoSentTo(String name) {
    return 'Llamada enviada a $name';
  }

  @override
  String get lanHoConsultFailed =>
      'No se pudo llamar al otro dispositivo a través del sistema telefónico';

  @override
  String lanHoNoLongerReachable(String name) {
    return '$name ya no está disponible';
  }

  @override
  String get lanHoCouldNotAnswer =>
      'No se pudo contestar la llamada para traspasarla';

  @override
  String lanHoCouldNotCall(String name) {
    return 'No se pudo llamar a $name por la red. La llamada sigue contigo.';
  }

  @override
  String lanHoNoAnswer(String name) {
    return '$name no contestó. La llamada sigue contigo.';
  }

  @override
  String lanHoHandedOffReason(String name) {
    return 'Traspasada a $name';
  }

  @override
  String lanHoRelayed(String name) {
    return 'Llamada retransmitida a $name';
  }

  @override
  String lanHoWaitAnswer(String name) {
    return 'Espera primero a que $name conteste';
  }

  @override
  String get lanHoFailed => 'Falló el traspaso';

  @override
  String lanHoTakenBack(String name) {
    return 'Llamada recuperada de $name';
  }

  @override
  String lanHoConsultEnded(String name) {
    return '$name terminó la consulta. La llamada vuelve contigo.';
  }

  @override
  String lanHoCouldNotHand(String name) {
    return 'No se pudo pasar la llamada a $name';
  }

  @override
  String get diagSip400Explain => 'El servidor no pudo entender la solicitud.';

  @override
  String get diagSip400Fix =>
      'Revisa los ajustes de la cuenta (dominio, usuario, proxy). Si persiste, envía una traza SIP a tu proveedor.';

  @override
  String get diagSip401Explain =>
      'El servidor rechazó las credenciales (o las está pidiendo).';

  @override
  String get diagSip401Fix =>
      'Revisa el usuario, el usuario de autenticación y la contraseña. Algunos proveedores usan un \"ID de autenticación\" aparte.';

  @override
  String get diagSip403Explain =>
      'El servidor entendió la solicitud pero la rechaza: contraseña incorrecta, cuenta desactivada o tu IP no está permitida.';

  @override
  String get diagSip403Fix =>
      'Vuelve a introducir la contraseña, comprueba que la cuenta esté activa y confirma que tu IP pública no esté bloqueada (fail2ban/ACL).';

  @override
  String get diagSip404Explain =>
      'El servidor no conoce a este usuario o número.';

  @override
  String get diagSip404Fix =>
      'Revisa el usuario y el dominio; para llamadas, revisa el número marcado y las reglas de marcación.';

  @override
  String get diagSip405Explain => 'El servidor no admite esta solicitud.';

  @override
  String get diagSip405Fix =>
      'Normalmente es inofensivo en los pings OPTIONS. Para REGISTER, comprueba que hablas con un servidor de registro SIP.';

  @override
  String get diagSip407Explain => 'El proxy saliente necesita credenciales.';

  @override
  String get diagSip407Fix =>
      'Revisa la contraseña de la cuenta y los ajustes del proxy saliente.';

  @override
  String get diagSip408Explain => 'El servidor no respondió a tiempo.';

  @override
  String get diagSip408Fix =>
      'Revisa la dirección y el puerto del servidor y los cortafuegos, y prueba con TCP o TLS. Si los tiempos de espera se repiten solo con UDP, puede ser SIP ALG en el router.';

  @override
  String get diagSip410Explain => 'El número ya no existe.';

  @override
  String get diagSip410Fix => 'Revisa el número marcado.';

  @override
  String get diagSip415Explain =>
      'La otra parte no acepta el tipo de contenido ni los códecs ofrecidos.';

  @override
  String get diagSip415Fix =>
      'Activa más códecs (p. ej., PCMU/PCMA) en Ajustes > Códecs.';

  @override
  String get diagSip421Explain =>
      'El servidor exige una extensión SIP que este cliente no ofreció.';

  @override
  String get diagSip421Fix =>
      'Revisa las opciones de NAT/ICE/100rel/temporizadores de la cuenta.';

  @override
  String get diagSip423Explain =>
      'La caducidad del registro es menor de lo que permite el servidor.';

  @override
  String get diagSip423Fix =>
      'Aumenta la caducidad del registro en los ajustes de la cuenta.';

  @override
  String get diagSip480Explain =>
      'El usuario no está registrado o no se le puede alcanzar ahora.';

  @override
  String get diagSip480Fix =>
      'Comprueba que la otra parte esté registrada; al registrarte, el servidor puede estar sobrecargado: inténtalo más tarde.';

  @override
  String get diagSip481Explain =>
      'El servidor perdió el estado del diálogo (p. ej., tras un reinicio o un cambio de red).';

  @override
  String get diagSip481Fix =>
      'Cuelga y vuelve a intentarlo. Si es frecuente, activa los temporizadores de sesión.';

  @override
  String get diagSip483Explain => 'La solicitud dio vueltas entre servidores.';

  @override
  String get diagSip483Fix =>
      'Revisa la configuración de desvíos y enrutamiento en la centralita.';

  @override
  String get diagSip484Explain => 'El número marcado es demasiado corto.';

  @override
  String get diagSip484Fix =>
      'Marca el número completo o revisa las reglas de marcación.';

  @override
  String get diagSip486Explain => 'La otra parte está ocupada.';

  @override
  String get diagSip486Fix => 'Inténtalo de nuevo más tarde.';

  @override
  String get diagSip487Explain =>
      'La llamada se canceló antes de ser contestada.';

  @override
  String get diagSip487Fix =>
      'Es normal cuando quien llama cuelga mientras suena.';

  @override
  String get diagSip488Explain =>
      'No hay códec ni ajuste de cifrado en común con la otra parte.';

  @override
  String get diagSip488Fix =>
      'Revisa los códecs y SRTP (una cuenta con SRTP obligatorio no puede llamar a un destino con RTP sin cifrar).';

  @override
  String get diagSip491Explain => 'Dos re-INVITE colisionaron.';

  @override
  String get diagSip491Fix => 'Normalmente se reintenta automáticamente.';

  @override
  String get diagSip500Explain => 'El servidor falló internamente.';

  @override
  String get diagSip500Fix =>
      'Inténtalo más tarde y contacta con el proveedor si continúa.';

  @override
  String get diagSip502Explain =>
      'Un servidor ascendente devolvió una respuesta no válida.';

  @override
  String get diagSip502Fix =>
      'Inténtalo más tarde; contacta con el proveedor si continúa.';

  @override
  String get diagSip503Explain =>
      'El servidor está sobrecargado, caído o rechaza a este cliente (límite de tasa).';

  @override
  String get diagSip503Fix =>
      'Espera y vuelve a intentarlo, revisa la página de estado del proveedor o prueba con otro servidor/puerto.';

  @override
  String get diagSip504Explain =>
      'Un servidor ascendente no respondió a tiempo.';

  @override
  String get diagSip504Fix => 'Inténtalo más tarde.';

  @override
  String get diagSip600Explain => 'Todos los destinos están ocupados.';

  @override
  String get diagSip600Fix => 'Inténtalo de nuevo más tarde.';

  @override
  String get diagSip603Explain => 'La otra parte rechazó la llamada.';

  @override
  String get diagSip603Fix => 'Nada que corregir: la llamada fue rechazada.';

  @override
  String get diagSip604Explain => 'El número no existe.';

  @override
  String get diagSip604Fix => 'Revisa el número marcado.';

  @override
  String get diagSip606Explain =>
      'La otra parte no puede aceptar la sesión tal como se ofreció.';

  @override
  String get diagSip606Fix => 'Revisa los ajustes de códecs y cifrado.';

  @override
  String diagSipProvisionalTitle(int code) {
    return 'Provisional ($code)';
  }

  @override
  String get diagSipProvisionalExplain => 'La solicitud se está procesando.';

  @override
  String diagSipSuccessTitle(int code) {
    return 'Correcto ($code)';
  }

  @override
  String get diagSipSuccessExplain => 'La solicitud se completó correctamente.';

  @override
  String diagSipRedirectedTitle(int code) {
    return 'Redirigida ($code)';
  }

  @override
  String get diagSipRedirectedExplain => 'El destino cambió de lugar.';

  @override
  String get diagSipRedirectedFix => 'Revisa los ajustes de desvío.';

  @override
  String diagSipClientErrorTitle(int code) {
    return 'Error de cliente ($code)';
  }

  @override
  String get diagSipClientErrorExplain => 'El servidor rechazó la solicitud.';

  @override
  String get diagSipClientErrorFix => 'Revisa la cuenta y el número marcado.';

  @override
  String diagSipServerErrorTitle(int code) {
    return 'Error del servidor ($code)';
  }

  @override
  String get diagSipServerErrorExplain =>
      'El servidor no pudo procesar la solicitud.';

  @override
  String get diagSipServerErrorFix =>
      'Inténtalo más tarde o contacta con el proveedor.';

  @override
  String diagSipGlobalFailureTitle(int code) {
    return 'Fallo global ($code)';
  }

  @override
  String get diagSipGlobalFailureExplain =>
      'La solicitud no se puede cumplir en ningún lugar.';

  @override
  String get diagSipNoResponseTitle => 'Sin respuesta';

  @override
  String get diagSipNoResponseExplain => 'No se recibió ninguna respuesta SIP.';

  @override
  String get diagSipNoResponseFix =>
      'Revisa la conexión de red y la dirección del servidor.';

  @override
  String get diagWizStepNet => 'Conectividad de red';

  @override
  String diagWizStepDns(String account) {
    return 'DNS y SRV: $account';
  }

  @override
  String get diagWizStepNat => 'Tipo de NAT';

  @override
  String diagWizStepOptions(String account) {
    return 'Accesibilidad del servidor: $account';
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
  String get diagWizStepAlg => 'Comprobación de SIP ALG';

  @override
  String get diagWizChecking => 'Comprobando...';

  @override
  String diagWizEngineError(String message) {
    return 'Error del motor: $message';
  }

  @override
  String diagWizCheckFailed(String error) {
    return 'Falló la comprobación: $error';
  }

  @override
  String get diagWizNoEngine => 'El motor SIP no está en ejecución';

  @override
  String get diagWizNoEngineFix =>
      'Espera a que el motor se inicie (o reinicia la app) y vuelve a ejecutar las comprobaciones.';

  @override
  String diagWizNetAddrPrivate(String interface, String address) {
    return '$interface: $address (privada)';
  }

  @override
  String get diagWizNetNone =>
      'No hay ninguna interfaz de red activa con dirección IP';

  @override
  String get diagWizNetNoneFix =>
      'Conéctate a Wi-Fi, Ethernet o datos móviles y vuelve a ejecutar las comprobaciones.';

  @override
  String get diagWizNetIpv6Only => 'Solo se encontraron direcciones IPv6';

  @override
  String get diagWizNetIpv6OnlyFix =>
      'Muchos proveedores SIP solo admiten IPv4. Activa IPv4 en esta red o usa un proveedor compatible con IPv6.';

  @override
  String diagWizNetSummary(int v4, int ifaces) {
    String _temp0 = intl.Intl.pluralLogic(
      v4,
      locale: localeName,
      other: '$v4 direcciones IPv4',
      one: '1 dirección IPv4',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ifaces,
      locale: localeName,
      other: '$ifaces interfaces',
      one: '1 interfaz',
    );
    return '$_temp0 en $_temp1';
  }

  @override
  String get diagWizNetVpnFix =>
      'Hay una interfaz tipo VPN activa. Las VPN pueden añadir latencia o bloquear UDP; desactívala si las llamadas fallan.';

  @override
  String get diagWizDnsNoServer => 'La cuenta no tiene dirección de servidor';

  @override
  String get diagWizDnsNoServerFix =>
      'Edita la cuenta e introduce el dominio SIP.';

  @override
  String diagWizDnsIpLiteral(String host) {
    return '$host es una dirección IP, no se necesita DNS';
  }

  @override
  String get diagWizDnsANone => 'A/AAAA: ninguno';

  @override
  String diagWizDnsANoneError(String error) {
    return 'A/AAAA: ninguno ($error)';
  }

  @override
  String diagWizDnsSrvNone(String name) {
    return 'SRV $name: ninguno';
  }

  @override
  String diagWizDnsSrvRecord(
    String name,
    String target,
    int port,
    int priority,
    int weight,
  ) {
    return 'SRV $name: $target:$port (prioridad $priority, peso $weight)';
  }

  @override
  String diagWizDnsSrvFailed(String transport, String error) {
    return 'SRV $transport: falló la consulta ($error)';
  }

  @override
  String diagWizDnsNotResolved(String host) {
    return '$host no se resuelve';
  }

  @override
  String get diagWizDnsNotResolvedFix =>
      'Revisa que el dominio no tenga errores y que tu servidor DNS funcione. Puedes definir un servidor DNS propio en Ajustes > Red (p. ej., 8.8.8.8).';

  @override
  String diagWizDnsSrvOnly(String host) {
    return '$host tiene registros SRV pero ningún registro de dirección';
  }

  @override
  String get diagWizDnsSrvOnlyFix =>
      'Se usarán los destinos SRV. Si las llamadas fallan, pide al proveedor que revise el registro A.';

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
    return '$host se resuelve a $address$_temp0$_temp1';
  }

  @override
  String get diagWizNatTimeout => 'Se agotó el tiempo de la detección de NAT';

  @override
  String get diagWizNatTimeoutFix =>
      'Puede que el servidor STUN no sea accesible (¿UDP bloqueado?). Revisa Ajustes > Red > Servidores STUN.';

  @override
  String diagWizNatStun(String server) {
    return 'Servidor STUN: $server';
  }

  @override
  String get diagWizNatOpen =>
      'Sin NAT: este dispositivo tiene una dirección pública';

  @override
  String get diagWizNatFullCone => 'NAT de cono completo: apto para VoIP';

  @override
  String get diagWizNatRestricted =>
      'NAT de cono restringido: funciona con STUN y keep-alives';

  @override
  String get diagWizNatPortRestricted =>
      'NAT de cono con puerto restringido: funciona con STUN y keep-alives';

  @override
  String get diagWizNatSymmetric =>
      'NAT simétrico: STUN por sí solo no puede predecir el puerto de medios';

  @override
  String get diagWizNatSymmetricFix =>
      'Es probable que haya audio unidireccional o ausencia de audio en algunas llamadas. Activa ICE y un relé TURN en los ajustes de la cuenta (Cuenta > NAT) o usa un proveedor/centralita con retransmisión de medios (rtpengine).';

  @override
  String get diagWizNatBlocked => 'Parece que UDP está bloqueado';

  @override
  String get diagWizNatBlockedFix =>
      'Usa el transporte TCP o TLS en la cuenta. Si la red filtra todo salvo el tráfico web, prueba TLS en el puerto 443 si tu proveedor lo admite.';

  @override
  String get diagWizNatUnknown => 'No se pudo determinar el tipo de NAT';

  @override
  String get diagWizNatUnknownFix =>
      'El servidor STUN no respondió. Prueba con otro servidor STUN en Ajustes > Red.';

  @override
  String get diagWizNatErr =>
      'El servidor STUN no respondió, por lo que no se pudo determinar el tipo de NAT.';

  @override
  String get diagWizNatUnknownRaw => 'No se pudo determinar el tipo de NAT.';

  @override
  String get diagWizOptionsNotLoaded => 'La cuenta no está cargada en el motor';

  @override
  String diagWizOptionsNoAnswer(int seconds, String transport) {
    return 'Sin respuesta a OPTIONS en $seconds s (transporte: $transport)';
  }

  @override
  String get diagWizOptionsNoAnswerFix =>
      'El servidor no es accesible. Revisa la dirección y el puerto, que ningún cortafuegos descarte SIP, y prueba con otro transporte (TCP/TLS).';

  @override
  String diagWizOptionsTimedOut(int code, String reason) {
    return 'Se agotó el tiempo de la solicitud ($code $reason)';
  }

  @override
  String diagWizOptionsAnsweredAfter(int code, String reason, int ms) {
    return 'El servidor respondió $code $reason tras $ms ms';
  }

  @override
  String diagWizOptionsAnsweredIn(int code, String reason, int ms) {
    return 'El servidor respondió $code $reason en $ms ms';
  }

  @override
  String diagWizOptionsNormalError(int code) {
    return 'Un $code a OPTIONS es normal: el servidor es accesible pero no permite sondeos anónimos.';
  }

  @override
  String get diagWizOptionsSlowFix =>
      'Un tiempo de ida y vuelta superior a 300 ms añade un retardo notable a las conversaciones. Un servidor más cercano o una conexión por cable ayuda.';

  @override
  String get diagWizTlsRejected => 'Se rechazó el certificado del servidor';

  @override
  String diagWizTlsSubject(String value) {
    return 'Sujeto: $value';
  }

  @override
  String diagWizTlsIssuer(String value) {
    return 'Emisor: $value';
  }

  @override
  String diagWizTlsProblems(String value) {
    return 'Problemas: $value';
  }

  @override
  String diagWizTlsExpires(String date) {
    return 'Caduca: $date';
  }

  @override
  String diagWizTlsCipher(String cipher) {
    return 'Cifrado: $cipher';
  }

  @override
  String get diagWizTlsRejectedFix =>
      'Si es tu propia centralita con certificado autofirmado y la huella de arriba coincide, puedes confiar en él. Si no, pide al proveedor un certificado de una CA pública.';

  @override
  String get diagWizTlsTrust => 'Confiar en este certificado';

  @override
  String diagWizTlsExpired(String date) {
    return 'El certificado caducó el $date';
  }

  @override
  String get diagWizTlsExpiredFix =>
      'Pide al administrador del servidor que renueve el certificado.';

  @override
  String diagWizTlsExpiresSoon(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'El certificado caduca en $days días',
      one: 'El certificado caduca en 1 día',
    );
    return '$_temp0';
  }

  @override
  String get diagWizTlsExpiresSoonFix =>
      'Pide al administrador del servidor que lo renueve pronto.';

  @override
  String diagWizTlsVerifyReported(String problems) {
    return 'Conectado, pero la verificación informó: $problems';
  }

  @override
  String get diagWizTlsOk => 'Conexión TLS establecida, certificado válido';

  @override
  String get diagWizTlsRegistered =>
      'Registrada por TLS (sin detalles del certificado)';

  @override
  String get diagWizTlsNone => 'Aún no se ha observado ninguna conexión TLS';

  @override
  String get diagWizTlsNoneFix =>
      'Revisa el puerto TLS (normalmente 5061) y que el servidor acepte TLS 1.2 o superior.';

  @override
  String get diagWizRegDisabledByConfig =>
      'El registro está desactivado en esta cuenta (uso peer-to-peer)';

  @override
  String get diagWizRegRegistered => 'Registrada';

  @override
  String diagWizRegRegisteredExpires(int seconds) {
    return 'Registrada (caduca en $seconds s)';
  }

  @override
  String diagWizRegTransport(String transport) {
    return 'Transporte: $transport';
  }

  @override
  String get diagWizRegInProgress => 'El registro aún está en curso';

  @override
  String get diagWizRegInProgressFix =>
      'Espera unos segundos. Si nunca termina, el servidor no responde; consulta la comprobación de accesibilidad de arriba.';

  @override
  String get diagWizRegFailed => 'Falló el registro';

  @override
  String get diagWizRegOffline => 'La cuenta está sin conexión';

  @override
  String get diagWizRegOfflineFix =>
      'Revisa la conexión de red. La app reintenta automáticamente.';

  @override
  String get diagWizRegDisabled => 'La cuenta está desactivada';

  @override
  String get diagWizAlgNoUdp =>
      'Ninguna cuenta usa UDP, así que SIP ALG no es un problema';

  @override
  String diagWizAlgTcpOnly(String account, int code, int ms) {
    return '$account: sin respuesta por UDP, pero TCP respondió ($code, $ms ms)';
  }

  @override
  String diagWizAlgNoAnswer(String account) {
    return '$account: sin respuesta por UDP ni TCP (problema del servidor o del cortafuegos más que de ALG)';
  }

  @override
  String diagWizAlgRegisterTimeout(String account) {
    return '$account: OPTIONS se responde pero REGISTER agota el tiempo, algo típico de un router que reescribe SIP';
  }

  @override
  String get diagWizAlgSuspected => 'Se sospecha SIP ALG en tu router';

  @override
  String get diagWizAlgSuspectedFix =>
      'Desactiva \"SIP ALG\" / \"SIP helper\" en los ajustes del router, cambia la cuenta a TCP o TLS, o cambia el puerto SIP (p. ej., 5080) para que el router deje de alterar los paquetes.';

  @override
  String get diagWizAlgContactChanged =>
      'La dirección Contact cambió entre la solicitud y la respuesta';

  @override
  String get diagWizAlgContactChangedFix =>
      'Puede ser un SIP ALG o un servidor que reescribe contactos. Si las llamadas suenan pero no tienen audio o se cortan al rato, desactiva SIP ALG en el router o usa TCP/TLS o el puerto 5080.';

  @override
  String get diagWizAlgOk => 'Sin indicios de interferencia de SIP ALG';

  @override
  String diagWizAlgContactRewritten(String sent, String received) {
    return 'El Contact de REGISTER $sent volvió como $received';
  }

  @override
  String diagSaveDialogTitle(String fileName) {
    return 'Guardar $fileName';
  }

  @override
  String diagSavedFile(String fileName) {
    return 'Guardado $fileName';
  }

  @override
  String get diagSaveFailed => 'No se pudo guardar el archivo';

  @override
  String get diagCopiedText => 'Texto copiado al portapapeles';

  @override
  String get diagCopiedReport => 'Informe copiado al portapapeles';

  @override
  String get diagCopiedBundle =>
      'Paquete de diagnóstico copiado al portapapeles';

  @override
  String get diagCopiedLogs => 'Registros copiados al portapapeles';

  @override
  String get diagCopiedTrace => 'Traza copiada al portapapeles';

  @override
  String get diagCopiedDialog => 'Diálogo copiado al portapapeles';

  @override
  String get diagSaveAsLog => 'Guardar como .log';

  @override
  String get diagSysAppVersion => 'Versión de la app';

  @override
  String get diagSysPlatform => 'Plataforma';

  @override
  String get diagSysEngine => 'Motor';

  @override
  String get diagSysAccounts => 'Cuentas';

  @override
  String diagSysAccountsRegistered(int registered, int total) {
    return '$registered de $total registradas';
  }

  @override
  String get diagSysLanLink => 'LAN Link';

  @override
  String diagSysReadError(String error) {
    return 'No se pudo leer la información del sistema: $error';
  }

  @override
  String get diagSysTransports => 'Transportes';

  @override
  String get diagSysNoneReported => 'Ninguno informado';

  @override
  String get diagSysCodecs => 'Códecs';

  @override
  String get diagSysCodecsFooter =>
      'Códecs activados, de mayor a menor prioridad.';

  @override
  String get diagSysEngineNotRunning => 'Motor detenido';

  @override
  String diagSysCodecPriority(int priority) {
    return 'prioridad $priority';
  }

  @override
  String get diagSysCodecDisabled => 'desactivado';

  @override
  String get diagSysExport => 'Exportar';

  @override
  String get diagSysExportFooter =>
      'El paquete incluye información del sistema, resultados de las comprobaciones de red, registros recientes y la traza SIP, con las credenciales ocultas.';

  @override
  String get diagSysCopyBundle => 'Copiar paquete de diagnóstico';

  @override
  String get diagSysSaveBundle => 'Guardar paquete de diagnóstico';

  @override
  String get diagTabSipTrace => 'Traza SIP';

  @override
  String get diagTabNetwork => 'Red';

  @override
  String get diagTabQuality => 'Calidad';

  @override
  String get diagTabAudioTest => 'Prueba de audio';

  @override
  String get diagTabLogs => 'Registros';

  @override
  String get diagTabSystem => 'Sistema';

  @override
  String diagRawSentTo(String remote) {
    return 'enviado a $remote';
  }

  @override
  String diagRawReceivedFrom(String remote) {
    return 'recibido de $remote';
  }

  @override
  String get diagRawCopied => 'Mensaje copiado';

  @override
  String get diagRawLadder => 'Escalera';

  @override
  String get diagRawRedact => 'Ocultar credenciales';

  @override
  String diagRawTruncated(int count) {
    return '... truncado ($count caracteres)';
  }

  @override
  String get diagWizIntro =>
      'Comprueba tu conexión, DNS, NAT, accesibilidad del servidor, TLS y registro, y explica qué corregir.';

  @override
  String get diagWizStop => 'Detener';

  @override
  String get diagWizRunChecks => 'Ejecutar pruebas';

  @override
  String get diagWizRunAgain => 'Repetir';

  @override
  String get diagWizCopyReport => 'Copiar informe';

  @override
  String get diagWizSaveReport => 'Guardar informe';

  @override
  String diagWizCountPassed(int count) {
    return 'Correctas $count';
  }

  @override
  String diagWizCountWarnings(int count) {
    return 'Avisos $count';
  }

  @override
  String diagWizCountFailed(int count) {
    return 'Fallidas $count';
  }

  @override
  String get diagWizStatusPass => 'Correcta';

  @override
  String get diagWizStatusWarn => 'Aviso';

  @override
  String get diagWizStatusFail => 'Fallida';

  @override
  String get diagWizStatusSkipped => 'Omitida';

  @override
  String get diagWizStatusRunning => 'En curso';

  @override
  String get diagWizStatusPending => 'Pendiente';

  @override
  String get diagQualityTitle => 'Calidad de la llamada';

  @override
  String get diagQualityNoData =>
      'No se registraron datos de calidad para esta llamada.';

  @override
  String get diagQualityTraceForCall => 'Traza SIP de esta llamada';

  @override
  String get diagQualityTraceNotCaptured =>
      'No se capturó la traza SIP de esta llamada';

  @override
  String get diagQualityLiveCall => 'Llamada en vivo';

  @override
  String get diagQualityNoActiveCall =>
      'No hay una llamada activa. Inicia una llamada y aquí se representan en vivo MOS, jitter, pérdida y tiempo de ida y vuelta.';

  @override
  String get diagQualityRecentCalls => 'Llamadas recientes';

  @override
  String get diagQualityNoFinished =>
      'Aún no hay llamadas finalizadas con datos de calidad.';

  @override
  String get diagQualityCallEnded => 'La llamada ha finalizado.';

  @override
  String get diagQualityMeasuring => 'midiendo';

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
    return 'Gráfico de $title, último $value';
  }

  @override
  String diagQualityLatestMax(String latest, String max) {
    return '$latest   máx. $max';
  }

  @override
  String diagQualityAvgWorst(String avg, String worst) {
    return 'Promedio $avg  ·  peor $worst';
  }

  @override
  String get diagQualityCodec => 'Códec';

  @override
  String get diagQualityLoss => 'Pérdida';

  @override
  String get diagQualityJitter => 'Jitter';

  @override
  String diagQualityPackets(int count) {
    return '$count paq.';
  }

  @override
  String get diagQualityMedia => 'Medios';

  @override
  String get diagQualityNoSeries =>
      'No se registró ninguna serie temporal para esta llamada.';

  @override
  String get diagQualityPacketLoss => 'Pérdida de paquetes';

  @override
  String get diagQualityRtt => 'Tiempo de ida y vuelta';

  @override
  String get diagLogsForward => 'Reenviar registros del motor';

  @override
  String get diagLogsForwardSub =>
      'Enviar las líneas de registro de pjsip a este visor';

  @override
  String diagLogsLevel(int level, String name) {
    return 'Nivel $level ($name)';
  }

  @override
  String get diagLogsRedact => 'Ocultar al exportar';

  @override
  String get diagLogsSearch => 'Buscar en registros';

  @override
  String get diagLogsEmpty => 'Aún no hay líneas de registro.';

  @override
  String get diagLogsForwardingOff =>
      'El reenvío de registros está desactivado. Actívalo para capturar los registros del motor.';

  @override
  String get diagLogsNoMatch => 'Ninguna línea coincide con la búsqueda.';

  @override
  String get diagAudioEngineNotRunning => 'El motor SIP no está en ejecución.';

  @override
  String get diagAudioMicrophone => 'Micrófono';

  @override
  String get diagAudioMicFooter =>
      'El medidor de nivel lee el dispositivo de audio, que el motor abre durante una llamada o la prueba de eco.';

  @override
  String get diagAudioLevelMeter => 'Medidor de nivel';

  @override
  String get diagAudioLevelMeterSub => 'Habla y observa cómo se mueve la barra';

  @override
  String get diagAudioMic => 'Micrófono';

  @override
  String get diagAudioSpeaker => 'Altavoz';

  @override
  String get diagAudioEchoTest => 'Prueba de eco';

  @override
  String get diagAudioEchoFooter =>
      'Reproduce tu voz por el altavoz. Usa auriculares para evitar el acople.';

  @override
  String get diagAudioEchoActive => 'Activa: habla ahora';

  @override
  String get diagAudioEchoIdle => 'Bucle del micrófono al altavoz';

  @override
  String get diagAudioSpeakerTest => 'Prueba del altavoz';

  @override
  String get diagAudioPlayTone => 'Reproducir tono de prueba';

  @override
  String get diagAudioPlayToneSub => 'Se reproduce por el altavoz seleccionado';

  @override
  String get diagAudioPlayingDtmf => 'Reproduciendo DTMF';

  @override
  String get diagAudioPlayingRingback => 'Reproduciendo tono de llamada';

  @override
  String get diagAudioRingback => 'Tono de llamada';

  @override
  String get diagAudioDevices => 'Dispositivos';

  @override
  String get diagAudioChooseDevices => 'Elegir micrófono y altavoz';

  @override
  String get diagAudioChooseDevicesSub => 'Abre Ajustes > Audio';

  @override
  String diagAudioLevelSemantics(String label, int percent) {
    return 'Nivel de $label: $percent por ciento';
  }

  @override
  String get diagLadderLocal => 'Local';

  @override
  String diagLadderSent(String message) {
    return 'Enviado $message';
  }

  @override
  String diagLadderReceived(String message) {
    return 'Recibido $message';
  }

  @override
  String get diagTraceCapture => 'Capturar mensajes SIP';

  @override
  String diagTraceStats(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String diagTraceStatsDropped(int count, String size, int dropped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0  ·  $size  ·  $dropped antiguos descartados';
  }

  @override
  String get diagTraceOffHint =>
      'Desactivada. Actívala y luego regístrate o haz una llamada.';

  @override
  String get diagTraceExportOrClear => 'Exportar o borrar';

  @override
  String get diagTraceSaveAsPcap => 'Guardar como .pcap';

  @override
  String get diagTraceCopyAsText => 'Copiar como texto';

  @override
  String get diagTraceSearchHint => 'Buscar texto, número o Call-ID';

  @override
  String get diagTraceErrorsOnly => 'Solo errores';

  @override
  String get diagTraceFilterMethod => 'Filtrar por método';

  @override
  String get diagTraceAllMethods => 'Todos los métodos';

  @override
  String get diagTraceMethod => 'Método';

  @override
  String get diagTraceFilterAccount => 'Filtrar por cuenta';

  @override
  String get diagTraceAllAccounts => 'Todas las cuentas';

  @override
  String get diagTraceAccount => 'Cuenta';

  @override
  String get diagTraceRedact => 'Ocultar';

  @override
  String get diagTraceList => 'Lista';

  @override
  String get diagTraceWaiting => 'Esperando tráfico SIP';

  @override
  String get diagTraceWaitingSub =>
      'Registra una cuenta o haz una llamada y los mensajes aparecerán aquí.';

  @override
  String get diagTraceOff => 'La traza SIP está desactivada';

  @override
  String get diagTraceOffSub =>
      'Activa la captura para ver cada solicitud y respuesta SIP, como lista o como diagrama de escalera.';

  @override
  String get diagTraceNoMatch => 'Ningún mensaje coincide con los filtros';

  @override
  String get diagTraceAllDialogs => 'Todos los diálogos';

  @override
  String get diagTraceCopyDialog => 'Copiar este diálogo';

  @override
  String get diagTraceNoResponse => 'sin respuesta';

  @override
  String get diagTraceNoCallId => 'sin Call-ID';

  @override
  String diagTraceMessageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0';
  }

  @override
  String get recTitleFallback => 'Grabación';

  @override
  String get recFormatWav => 'Estándar (WAV)';

  @override
  String get recFormatWavStereo =>
      'Estéreo, tú y quien llama en canales separados (WAV)';

  @override
  String get recFormatOpus => 'Comprimido (Opus)';

  @override
  String get recFormatWavHint =>
      'Mono, unos 2 MB por minuto. Se reproduce en todas partes.';

  @override
  String get recFormatWavStereoHint =>
      'Dos canales, unos 4 MB por minuto. Tú a la izquierda, quien llama a la derecha.';

  @override
  String get recFormatOpusHint =>
      'Unos 0,2 MB por minuto. Ogg Opus; algunos reproductores de iPhone, Mac y Windows no pueden abrirlo.';

  @override
  String get recOptionInherit => 'Usar ajuste global';

  @override
  String get recOptionAlways => 'Grabar todas las llamadas';

  @override
  String get recOptionIncoming => 'Grabar solo llamadas entrantes';

  @override
  String get recOptionOutgoing => 'Grabar solo llamadas salientes';

  @override
  String get recOptionNever => 'No grabar nunca';

  @override
  String get recRuleAll => 'Todas las llamadas';

  @override
  String get recRuleIncoming => 'Solo llamadas entrantes';

  @override
  String get recRuleOutgoing => 'Solo llamadas salientes';

  @override
  String get recAutoDeleteNever => 'Nunca';

  @override
  String recAutoDeleteAfterDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tras $days días',
      one: 'Tras 1 día',
    );
    return '$_temp0';
  }

  @override
  String get recAutoDeleteAfterYear => 'Tras 1 año';

  @override
  String recCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones',
      one: '1 grabación',
    );
    return '$_temp0';
  }

  @override
  String recUsageSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones',
      one: '1 grabación',
    );
    return '$_temp0  ·  $size';
  }

  @override
  String recUsageSummaryAutoDelete(int count, String size, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones',
      one: '1 grabación',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0  ·  $size  ·  eliminación automática tras $_temp1';
  }

  @override
  String get recSettingsFormat => 'Formato';

  @override
  String get recSettingsAutoGroup => 'Grabación automática';

  @override
  String get recSettingsAutoFooter =>
      'Consulta las leyes locales antes de grabar llamadas. Activa \"Grabar siempre las llamadas con este contacto\" en un contacto para grabarlas sin importar estas reglas.';

  @override
  String get recSettingsAutoRule => 'Grabar llamadas automáticamente';

  @override
  String get recSettingsAccountOverride => 'Personalizar para esta cuenta';

  @override
  String get recSettingsNoticesGroup => 'Avisos';

  @override
  String get recSettingsNoticeSwitch => 'Reproducir un aviso antes de grabar';

  @override
  String get recSettingsNoticeSwitchHint =>
      'Primero reproduce un aviso a la otra parte. El archivo del aviso se elige en Ajustes > Llamadas > Anuncios.';

  @override
  String get recSettingsNoticeFile => 'Elegir el archivo del aviso';

  @override
  String get recSettingsNoticeFileHint => 'Abre Ajustes > Llamadas > Anuncios';

  @override
  String get recSettingsBeep => 'Pitido de grabación';

  @override
  String get recSettingsBeepHint => 'Avisar periódicamente a la otra parte';

  @override
  String get recSettingsTransfersGroup => 'Transferencias';

  @override
  String get recSettingsContinue =>
      'Seguir grabando durante las transferencias';

  @override
  String get recSettingsContinueHint =>
      'Graba la llamada de consulta de una transferencia asistida y la llamada que nos pasa una transferencia, y enlaza las grabaciones';

  @override
  String get recSettingsStorageGroup => 'Almacenamiento';

  @override
  String get recSettingsFolder => 'Carpeta';

  @override
  String get recSettingsFolderHint => 'Dónde se guardan las grabaciones';

  @override
  String get recSettingsFolderPlaceholder =>
      'Documentos de la app / Grabaciones';

  @override
  String get recSettingsChooseFolder => 'Elegir carpeta...';

  @override
  String get recSettingsFolderPickerTitle => 'Carpeta de grabaciones';

  @override
  String get recSettingsAutoDelete => 'Eliminar grabaciones antiguas';

  @override
  String get recSettingsAutoDeleteHint =>
      'Se comprueba al iniciar y una vez al día';

  @override
  String get recSettingsManage => 'Gestionar grabaciones';

  @override
  String get recSettingsOpenFolder => 'Abrir carpeta de grabaciones';

  @override
  String get recPageTitle => 'Grabaciones';

  @override
  String recSelectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String get recCancelSelection => 'Cancelar selección';

  @override
  String get recSelectAll => 'Seleccionar todo';

  @override
  String get recShareSelected => 'Compartir selección';

  @override
  String get recDeleteSelected => 'Eliminar selección';

  @override
  String get recSearchTooltip => 'Buscar grabaciones';

  @override
  String get recSelectTooltip => 'Seleccionar grabaciones';

  @override
  String get recMenuSettings => 'Ajustes de grabación';

  @override
  String get recSearchHint => 'Buscar nombre o número';

  @override
  String get recEmptyNone => 'Aún no hay grabaciones';

  @override
  String get recEmptyNoneHint =>
      'Graba una llamada con el botón Grabar o activa la grabación automática en Ajustes.';

  @override
  String get recEmptyNoMatch => 'No hay grabaciones coincidentes';

  @override
  String get recEmptyNoMatchHint => 'Prueba con otra búsqueda o filtro.';

  @override
  String get recClearFilters => 'Borrar filtros';

  @override
  String recDeleteManyTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count grabaciones?',
      one: '¿Eliminar 1 grabación?',
    );
    return '$_temp0';
  }

  @override
  String get recDeleteManyMessage =>
      'Los archivos de audio se eliminan de este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get recDeleteOneTitle => '¿Eliminar esta grabación?';

  @override
  String get recDeleteOneMessage =>
      'El archivo de audio se elimina de este dispositivo. Esta acción no se puede deshacer.';

  @override
  String get recFilterAll => 'Todas';

  @override
  String get recFilterIncoming => 'Entrantes';

  @override
  String get recFilterOutgoing => 'Salientes';

  @override
  String get recFilterByAccount => 'Filtrar por cuenta';

  @override
  String get recFilterAllAccounts => 'Todas las cuentas';

  @override
  String get recFilterAccountFallback => 'Cuenta';

  @override
  String get recFilterAnyDate => 'Cualquier fecha';

  @override
  String recFilterDateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get recFilterClearDates => 'Borrar fechas';

  @override
  String get recMissingFile => 'Falta el archivo de audio en este dispositivo.';

  @override
  String recRelated(String title) {
    return 'Relacionada: $title';
  }

  @override
  String get recRenameTitle => 'Renombrar grabación';

  @override
  String get recRenameHint => 'Nombre';

  @override
  String get recSaveAs => 'Guardar como...';

  @override
  String get recShowInFinder => 'Mostrar en Finder';

  @override
  String get recShowInFolder => 'Mostrar en carpeta';

  @override
  String get recViewCall => 'Ver llamada';

  @override
  String recSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String get recSaveFailed => 'No se pudo guardar la grabación';

  @override
  String get recShareFailed => 'No se pudo compartir la grabación';

  @override
  String get recSaveDialogTitle => 'Guardar grabación';

  @override
  String get recShareSubject => 'Grabaciones de llamadas';

  @override
  String get recPlayerUnsupported =>
      'Este dispositivo no puede reproducir aquí grabaciones Opus.';

  @override
  String get recPlayerOpenWith => 'Abrir con...';

  @override
  String get recPlayerNotFound => 'No se encontró el archivo de la grabación';

  @override
  String recPlayerCannotPlay(String error) {
    return 'No se puede reproducir esta grabación: $error';
  }

  @override
  String get recPlayerPlay => 'Reproducir grabación';

  @override
  String get recPlayerPause => 'Pausar grabación';

  @override
  String get audioFilesTitle => 'Archivos de audio';

  @override
  String audioAdded(String name) {
    return 'Se añadió \"$name\"';
  }

  @override
  String get audioFileUnavailable => 'Ese archivo no está disponible.';

  @override
  String get audioNameRequired => 'Introduce un nombre';

  @override
  String audioDeleteTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get audioDeleteMessage =>
      'Los ajustes que usan este archivo vuelven al valor predeterminado.';

  @override
  String get audioGroupAdd => 'Añadir';

  @override
  String get audioAddFooter =>
      'Se admiten archivos WAV (PCM, mu-law, A-law) y MP3. Los archivos se copian a la app, así que el original puede moverse.';

  @override
  String get audioImport => 'Importar un WAV o MP3…';

  @override
  String get audioGroupMine => 'Mis archivos';

  @override
  String get audioEmptyTitle => 'Aún no hay archivos';

  @override
  String get audioEmptyHint => 'Importa un archivo o graba tu propio anuncio.';

  @override
  String get audioGroupBuiltIn => 'Integrados';

  @override
  String get audioBuiltInFooter => 'Generados para SoftphonePro, de uso libre.';

  @override
  String get audioPreviewStop => 'Detener vista previa';

  @override
  String audioPreviewPlay(String name) {
    return 'Escuchar $name';
  }

  @override
  String get audioRecordedName => 'Ponle nombre a esta grabación';

  @override
  String get audioRecordedDefaultName => 'Mi anuncio';

  @override
  String audioSaved(String name) {
    return 'Se guardó \"$name\"';
  }

  @override
  String get audioRecorderStop => 'Detener';

  @override
  String get audioRecorderPlay => 'Reproducir grabación';

  @override
  String audioRecorderNew(String duration) {
    return 'Nueva grabación  ·  $duration';
  }

  @override
  String get audioRecorderDiscard => 'Descartar';

  @override
  String get audioRecordOwn => 'Grabar el tuyo…';

  @override
  String get audioRecordOwnHint =>
      'Usa el micrófono seleccionado en los ajustes de Audio';

  @override
  String get audioMissingFile => 'Archivo no encontrado';

  @override
  String get audioBuiltInCalm => 'Calma (integrada)';

  @override
  String get audioBuiltInBreeze => 'Brisa (integrada)';

  @override
  String get audioBuiltInChime => 'Campanilla de aviso (integrada)';

  @override
  String get audioErrOnlyWavMp3 => 'Solo se pueden usar archivos WAV y MP3.';

  @override
  String get audioErrNotFound => 'No se pudo encontrar ese archivo.';

  @override
  String get audioErrNotSaved => 'La grabación no se guardó.';

  @override
  String get audioErrEmpty =>
      'Este archivo de audio está vacío o no se puede leer.';

  @override
  String audioErrUnusable(String reason) {
    return 'No se puede usar este archivo de audio ($reason). Usa WAV PCM, mu-law o A-law, o MP3.';
  }

  @override
  String get audioRecEngineOff => 'El motor de llamadas no está en ejecución.';

  @override
  String get audioRecUnsupported =>
      'Esta versión del motor de llamadas no puede grabar el micrófono.';

  @override
  String audioRecStartFailed(String reason) {
    return 'No se pudo iniciar la grabación: $reason';
  }

  @override
  String audioRecFailed(String reason) {
    return 'Falló la grabación: $reason';
  }

  @override
  String get audioStrengthLow => 'Baja';

  @override
  String get audioStrengthMedium => 'Media';

  @override
  String get audioStrengthHigh => 'Alta';

  @override
  String get audioStrengthMax => 'Máxima';

  @override
  String audioStrengthText(String label, int percent) {
    return '$label ($percent%)';
  }

  @override
  String get audioSystemDefault => 'Predeterminado del sistema';

  @override
  String audioSystemDefaultNamed(String name) {
    return 'Predeterminado del sistema ($name)';
  }

  @override
  String get voiceTitle => 'Aislamiento de voz';

  @override
  String get voiceUnavailable =>
      'La cancelación de ruido con IA no está disponible en esta compilación del motor de llamadas. La supresión de ruido estándar de Procesamiento sigue funcionando.';

  @override
  String get voiceGroupAi => 'Cancelación de ruido con IA';

  @override
  String get voiceAiFooter =>
      'Elimina clics de teclado, ventiladores y voces de fondo de la llamada mediante una red neuronal en el propio dispositivo (RNNoise). Nada sale de tu dispositivo. Una intensidad mayor elimina más ruido, pero puede recortar el inicio de las palabras.';

  @override
  String get voiceMic => 'Mi micrófono';

  @override
  String get voiceMicHint => 'Limpia lo que oye la otra persona';

  @override
  String get voiceOthers => 'Otros participantes';

  @override
  String get voiceOthersHint => 'Limpia a quienes llaman con ruido';

  @override
  String voiceStrength(String value) {
    return 'Intensidad: $value';
  }

  @override
  String get voiceGroupTry => 'Pruébalo';

  @override
  String get voiceTryFooter =>
      'Usa auriculares para la prueba de eco o escucharás acople.';

  @override
  String get voiceEchoTest => 'Probar con eco';

  @override
  String get voiceEchoTestHint => 'Te reproduce tu micrófono ya procesado';

  @override
  String get voiceEchoFailed => 'Falló la prueba de eco';

  @override
  String get voiceGroupSystem => 'Sistema';

  @override
  String get voiceSystemFooter =>
      'macOS e iOS también pueden aislar tu voz en todas las apps. Elige Aislamiento de voz en el modo de micrófono del sistema.';

  @override
  String get voiceSystemMode =>
      'Modo de micrófono del sistema (Aislamiento de voz)…';

  @override
  String get voiceSystemModeUnsupported =>
      'Los modos de micrófono requieren macOS 12 o iOS 15 o posterior.';

  @override
  String get voiceSpeechDetection => 'Detección de voz';

  @override
  String voiceSpeechPercent(int percent) {
    return '$percent por ciento';
  }

  @override
  String voicePercent(int percent) {
    return '$percent%';
  }

  @override
  String get voiceGroupAndroid => 'Efectos de audio de Android';

  @override
  String get voiceAndroidFooter =>
      'Es posible que el teléfono también limpie el micrófono por sí mismo. Android los informa y son independientes del ajuste anterior.';

  @override
  String get voiceAndroidNs => 'Supresor de ruido';

  @override
  String get voiceAndroidAec => 'Cancelador de eco';

  @override
  String get voiceNotAvailableDevice => 'No disponible en este dispositivo';

  @override
  String get callLinkNotLocal =>
      'Este tipo de enlace solo se puede usar desde la línea de comandos de este equipo.';

  @override
  String linkLanConnectTitle(String name) {
    return '¿Conectar con el dispositivo $name?';
  }

  @override
  String get linkLanConnectBody =>
      'Un enlace de otra aplicación o de una página web quiere conectar SoftphonePro a este dispositivo. Conecta solo si lo esperas.';

  @override
  String get linkLanConnectAction => 'Conectar';

  @override
  String get linkImportSensitiveHeader =>
      'Cambios sensibles en esta configuración:';

  @override
  String get linkImportFlagAutoAnswer =>
      'Responde automáticamente a las llamadas entrantes';

  @override
  String linkImportFlagForwarding(String target) {
    return 'Desvía las llamadas a $target';
  }

  @override
  String get linkImportFlagIntercom =>
      'Cambia quién puede iniciar un intercomunicador o recoger una llamada (LAN)';

  @override
  String get linkImportFlagDialRewrite => 'Reescribe los números que marcas';

  @override
  String get linkImportFlagLinksImmediately =>
      'Las llamadas desde enlaces web se inician de inmediato, sin confirmación';

  @override
  String get linkImportFlagDiagnostics =>
      'Activa el registro detallado o el rastreo SIP';

  @override
  String get linkImportAllowAutoAnswer =>
      'Permitir la respuesta automática en las cuentas importadas';

  @override
  String linkImportRefused(String setting) {
    return 'Esta importación intenta cambiar «$setting», que nunca puede establecerse mediante un enlace, código QR, texto pegado o archivo. Use la opción de línea de comandos --provision en este equipo. No se importó nada.';
  }

  @override
  String get lanPairIntercomNote =>
      'Los dispositivos emparejados pueden pedir una llamada de intercomunicador; se te preguntará antes de cada una (cámbialo en Ajustes > LAN).';

  @override
  String get callLinkUnsupportedScheme =>
      'Este tipo de enlace no es compatible.';

  @override
  String get linkImportFlagAutoRecord => 'Graba las llamadas automáticamente';

  @override
  String get linkImportFlagBlocklist =>
      'Cambia su lista de bloqueo de llamadas';

  @override
  String get linkImportFlagEmergency => 'Cambia sus números de emergencia';

  @override
  String get linkImportFlagSpeedDial => 'Define números de marcación rápida';

  @override
  String get linkImportFlagRecordingDelete =>
      'Elimina automáticamente las grabaciones antiguas';

  @override
  String get linkImportFlagFeatureCodes =>
      'Marca códigos de función personalizados de la centralita';

  @override
  String get linkImportAllowAutoRecord =>
      'Permitir la grabación automática de llamadas';

  @override
  String get importIgnoredHeader => 'Ignorado (no permitido en importaciones):';

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
    return 'Relé TURN: $server';
  }

  @override
  String importAccountHeaders(String headers) {
    return 'Cabeceras SIP personalizadas: $headers';
  }

  @override
  String importAccountCallerId(String callerId) {
    return 'ID de llamada: $callerId';
  }

  @override
  String get importAccountSrtpOff => 'Sin cifrado de medios (SRTP desactivado)';

  @override
  String linkLanConnectAddress(String host, String port) {
    return 'Dirección: $host:$port';
  }

  @override
  String provisioningUpdateSummary(int updated, int added) {
    return 'Actualizar $updated existentes, añadir $added nuevas';
  }

  @override
  String get secretsKeyringLocked =>
      'Su llavero está bloqueado, por lo que no se pudieron leer las contraseñas guardadas. Desbloquéelo y reinicie SoftphonePro.';
}
