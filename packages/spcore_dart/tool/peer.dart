// A second spcore engine in its own OS process (pjsua allows only one
// instance per process). JSON lines protocol:
//
//   stdin : {"id": 1, "method": "core.start", "params": {...}}
//           {"id": 2, "method": "peer.exit"}
//   stdout: {"type":"response","id":1,"ok":true,"result":{...}}
//           {"type":"event", ...}   (raw engine events)
//
// Usage: dart run tool/peer.dart [--lib /path/to/libspcore.dylib]
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spcore_dart/spcore_dart.dart';

Future<void> main(List<String> args) async {
  String? lib;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--lib' && i + 1 < args.length) lib = args[++i];
  }
  final engine = FfiSipEngine(libraryPath: lib, watchdogInterval: null);
  void out(Map<String, dynamic> m) => stdout.writeln(jsonEncode(m));
  try {
    await engine.init();
  } catch (e) {
    out({'type': 'peer.error', 'message': '$e'});
    exit(2);
  }
  engine.events.listen((e) => out(e.raw));
  out({'type': 'peer.ready'});

  final pending = <Future<void>>[];
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.trim().isEmpty) continue;
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      continue;
    }
    final id = msg['id'];
    final method = '${msg['method']}';
    if (method == 'peer.exit') {
      await Future.wait(pending);
      try {
        await engine.stop(graceful: false);
      } catch (_) {}
      await engine.dispose();
      out({'type': 'response', 'id': id, 'ok': true, 'result': {}});
      await stdout.flush();
      exit(0);
    }
    pending.add(() async {
      try {
        final r = await engine.request(
          method,
          (msg['params'] as Map?)?.cast<String, dynamic>() ?? {},
          timeout: Duration(milliseconds: (msg['timeoutMs'] as int?) ?? 15000),
        );
        out({'type': 'response', 'id': id, 'ok': true, 'result': r});
      } on EngineException catch (e) {
        out({
          'type': 'response',
          'id': id,
          'ok': false,
          'error': e.error.toJson(),
        });
      }
    }());
  }
  await engine.dispose();
}
