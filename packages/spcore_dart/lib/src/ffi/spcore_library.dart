import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _VoidI32 = Int32 Function();
typedef _VoidI32D = int Function();
typedef _VersionC = Pointer<Utf8> Function();
typedef _VersionD = Pointer<Utf8> Function();
typedef _InitApiC = IntPtr Function(Pointer<Void>);
typedef _InitApiD = int Function(Pointer<Void>);
typedef _I64ToI32C = Int32 Function(Int64);
typedef _I64ToI32D = int Function(int);
typedef _RequestC = Int64 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _RequestD = int Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _RequestSyncC =
    Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _RequestSyncD =
    Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, int);
typedef _FreeC = Void Function(Pointer<Utf8>);
typedef _FreeD = void Function(Pointer<Utf8>);
typedef _ShutdownC = Void Function();
typedef _ShutdownD = void Function();

/// Hand-written bindings for the spcore C ABI (docs/ENGINE_API.md §1).
class SpcoreLibrary {
  SpcoreLibrary._(this.lib, this.path)
    : apiVersion = lib.lookupFunction<_VoidI32, _VoidI32D>('spc_api_version'),
      _versionString = lib.lookupFunction<_VersionC, _VersionD>(
        'spc_version_string',
      ),
      initDartApi = lib.lookupFunction<_InitApiC, _InitApiD>(
        'spc_init_dart_api',
      ),
      init = lib.lookupFunction<_I64ToI32C, _I64ToI32D>('spc_init'),
      setEventPort = lib.lookupFunction<_I64ToI32C, _I64ToI32D>(
        'spc_set_event_port',
      ),
      _request = lib.lookupFunction<_RequestC, _RequestD>('spc_request'),
      _requestSync = lib.lookupFunction<_RequestSyncC, _RequestSyncD>(
        'spc_request_sync',
      ),
      _free = lib.lookupFunction<_FreeC, _FreeD>('spc_free'),
      shutdown = lib.lookupFunction<_ShutdownC, _ShutdownD>('spc_shutdown');

  final DynamicLibrary lib;

  /// What was opened (for diagnostics).
  final String path;

  final int Function() apiVersion;
  final Pointer<Utf8> Function() _versionString;
  final int Function(Pointer<Void>) initDartApi;
  final int Function(int) init;
  final int Function(int) setEventPort;
  final int Function(Pointer<Utf8>, Pointer<Utf8>) _request;
  final Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, int) _requestSync;
  final void Function(Pointer<Utf8>) _free;
  final void Function() shutdown;

  static const int expectedApiVersion = 1;

  /// Candidate library names in resolution order (after explicit path and
  /// `SPCORE_LIB`).
  static List<String> platformDefaults() {
    if (Platform.isAndroid || Platform.isLinux) return ['libspcore.so'];
    if (Platform.isMacOS) {
      return ['spcore.framework/spcore', 'libspcore.dylib'];
    }
    if (Platform.isIOS) return ['spcore.framework/spcore'];
    if (Platform.isWindows) return ['spcore.dll'];
    return ['libspcore.so'];
  }

  /// Loads the library: explicit [path] -> env `SPCORE_LIB` -> platform
  /// default. Throws [StateError] listing every attempt on failure.
  static SpcoreLibrary load({String? path}) {
    final candidates = <String>[
      if (path != null) path,
      if (path == null && (Platform.environment['SPCORE_LIB'] ?? '').isNotEmpty)
        Platform.environment['SPCORE_LIB']!,
      if (path == null) ...platformDefaults(),
    ];
    final errors = <String>[];
    for (final c in candidates) {
      try {
        final lib = SpcoreLibrary._(DynamicLibrary.open(c), c);
        final v = lib.apiVersion();
        if (v != expectedApiVersion) {
          throw StateError(
            'spcore API version $v, expected $expectedApiVersion',
          );
        }
        return lib;
      } catch (e) {
        errors.add('$c: $e');
      }
    }
    throw StateError('Cannot load spcore:\n${errors.join('\n')}');
  }

  String versionString() => _versionString().toDartString();

  /// Async request; returns the request id (>0) or a negative error.
  int request(String method, String paramsJson) {
    final m = method.toNativeUtf8();
    final p = paramsJson.toNativeUtf8();
    try {
      return _request(m, p);
    } finally {
      malloc.free(m);
      malloc.free(p);
    }
  }

  /// Blocking request. For tests and tools only: never call on the UI isolate.
  String requestSync(
    String method,
    String paramsJson, {
    int timeoutMs = 10000,
  }) {
    final m = method.toNativeUtf8();
    final p = paramsJson.toNativeUtf8();
    try {
      final r = _requestSync(m, p, timeoutMs);
      if (r == nullptr) return '';
      final s = r.toDartString();
      _free(r);
      return s;
    } finally {
      malloc.free(m);
      malloc.free(p);
    }
  }
}
