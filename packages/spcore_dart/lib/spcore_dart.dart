/// Pure-Dart engine layer of SoftphonePro: typed Engine API, event model,
/// in-memory [FakeSipEngine] and dart:ffi-backed [FfiSipEngine].
library;

export 'src/events.dart';
export 'src/fake_sip_engine.dart';
export 'src/ffi/ffi_sip_engine.dart';
export 'src/ffi/spcore_library.dart';
export 'src/json_sip_engine.dart' show JsonSipEngine;
export 'src/models/models.dart';
export 'src/sip_engine.dart';
