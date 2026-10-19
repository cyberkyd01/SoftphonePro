import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/automation/automation_auth.dart';
import 'package:softphonepro/automation/automation_service.dart';
import 'package:softphonepro/models/app_settings.dart';
import 'package:softphonepro/services/app_services.dart';
import 'package:softphonepro/services/settings_controller.dart';
import 'package:spcore_dart/spcore_dart.dart';

import '../harness.dart';

const _token = 'test-token-0123456789abcdef0123456789abcdef';

class _Resp {
  _Resp(this.status, this.headers, this.text);
  final int status;
  final HttpHeaders headers;
  final String text;
  dynamic get json => jsonDecode(text);
  String? get errorCode => (json as Map)['error']?['code'] as String?;
}

class _Env {
  late TestEnv env;
  late ProviderContainer c;
  late int port;
  late HttpClient http;
  FakeSipEngine get engine => env.engine;

  static Future<_Env> start({
    Map<String, dynamic> settings = const {},
    List<String> origins = const [],
    bool enable = true,
  }) async {
    final e = _Env();
    e.env = await TestEnv.create(
      profiles: [testProfile(id: 'acc1', user: '1016')],
      settings: AppSettings({
        'onboardingDone': true,
        if (enable) ...{
          'automationEnabled': true,
          'automationPort': 0,
          'automationToken': _token,
          'automationOrigins': origins,
        },
        ...settings,
      }),
    );
    e.c = ProviderContainer(overrides: e.env.overrides);
    addTearDown(() async {
      e.http.close(force: true);
      e.c.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    e.http = HttpClient();
    e.c.read(appServicesProvider);
    await e.pump();
    if (enable) {
      for (var i = 0; i < 100 && !e.c.read(automationServiceProvider).running; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      e.port = e.c.read(automationServiceProvider).port;
    }
    return e;
  }

  /// Lets engine events, timers and futures flow.
  Future<void> pump([int rounds = 5]) async {
    for (var i = 0; i < rounds; i++) {
      await engine.settle();
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
  }

  Future<_Resp> call(
    String method,
    String path, {
    Object? body,
    String? token = _token,
    Map<String, String> headers = const {},
    String? rawBody,
    String? host,
  }) async {
    final req = await http.openUrl(method, Uri.parse('http://127.0.0.1:$port$path'));
    if (token != null) req.headers.set('Authorization', 'Bearer $token');
    if (host != null) req.headers.host = host;
    headers.forEach(req.headers.set);
    final payload = rawBody ?? (body == null ? null : jsonEncode(body));
    if (payload != null) {
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(payload));
    }
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    return _Resp(res.statusCode, res.headers, text);
  }

  Future<_Resp> get(String p, {String? token = _token}) => call('GET', p, token: token);
  Future<_Resp> post(String p, [Object? body]) => call('POST', p, body: body ?? <String, Object?>{});

  /// Opens /v1/events; returns the received text so far and a closer.
  Future<_Sse> events({String? token = _token}) async {
    final req = await http.getUrl(Uri.parse('http://127.0.0.1:$port/v1/events'));
    if (token != null) req.headers.set('Authorization', 'Bearer $token');
    final res = await req.close();
    return _Sse(res);
  }
}

class _Sse {
  _Sse(this.res) {
    sub = res.transform(utf8.decoder).listen((s) {
      text += s;
      _wake.add(null);
    });
  }
  final HttpClientResponse res;
  late final StreamSubscription<String> sub;
  String text = '';
  final _wake = StreamController<void>.broadcast();

  Future<void> waitFor(bool Function(String) test, {Duration timeout = const Duration(seconds: 5)}) async {
    final end = DateTime.now().add(timeout);
    while (!test(text)) {
      if (DateTime.now().isAfter(end)) fail('timed out waiting; received:\n$text');
      await Future.any([_wake.stream.first, Future<void>.delayed(const Duration(milliseconds: 50))]);
    }
  }

  List<Map<String, dynamic>> events(String category) {
    final out = <Map<String, dynamic>>[];
    for (final block in text.split('\n\n')) {
      if (!block.contains('event: $category\n')) continue;
      final d = RegExp(r'data: (.*)').firstMatch(block);
      if (d != null) out.add(jsonDecode(d.group(1)!) as Map<String, dynamic>);
    }
    return out;
  }

  bool hasCall(String type) => events('call').any((e) => e['type'] == type);
  Future<void> close() async => sub.cancel();
}

void main() {
  group('auth helpers', () {
    test('token generation: 64 hex characters, unique', () {
      final a = generateAutomationToken();
      final b = generateAutomationToken();
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(a, isNot(b));
    });

    test('constant time compare and token matching', () {
      expect(constantTimeEquals('abc', 'abc'), isTrue);
      expect(constantTimeEquals('abc', 'abd'), isFalse);
      expect(constantTimeEquals('abc', 'abcd'), isFalse);
      expect(constantTimeEquals('', ''), isTrue);
      expect(tokenMatches('', ''), isFalse, reason: 'an empty token never authenticates');
      expect(tokenMatches('secret', null), isFalse);
      expect(tokenMatches('secret', 'secret'), isTrue);
      expect(bearerToken('Bearer abc'), 'abc');
      expect(bearerToken('bearer   abc '), 'abc');
      expect(bearerToken('Basic abc'), isNull);
      expect(bearerToken(null), isNull);
    });

    test('origins are normalised; wildcards and paths refused', () {
      expect(normalizeOrigin('https://CRM.example.com/'), 'https://crm.example.com');
      expect(normalizeOrigin('http://localhost:3000'), 'http://localhost:3000');
      expect(normalizeOrigin('https://x.test:443'), 'https://x.test');
      expect(normalizeOrigin('*'), isNull);
      expect(normalizeOrigin('https://*.example.com'), isNull);
      expect(normalizeOrigin('https://x.test/path'), isNull);
      expect(normalizeOrigin('ftp://x.test'), isNull);
    });

    test('host header must be loopback', () {
      expect(isLoopbackHost('127.0.0.1:7771', 7771), isTrue);
      expect(isLoopbackHost('localhost:7771', 7771), isTrue);
      expect(isLoopbackHost('127.0.0.1', 7771), isTrue);
      expect(isLoopbackHost('evil.example:7771', 7771), isFalse);
      expect(isLoopbackHost('127.0.0.1:9', 7771), isFalse);
      expect(isLoopbackHost(null, 7771), isFalse);
    });
  });

  group('lifecycle', () {
    test('disabled by default: nothing listens', () async {
      final e = await _Env.start(enable: false);
      expect(AppSettings().automationEnabled, isFalse);
      expect(e.c.read(automationServiceProvider).running, isFalse);
    });

    test('enabling starts the server on loopback only; disabling stops it; port in use is reported', () async {
      final e = await _Env.start(enable: false);
      // A port that is taken.
      final blocker = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(blocker.close);
      await e.c.read(settingsProvider.notifier).update({
        'automationEnabled': true,
        'automationToken': _token,
        'automationPort': blocker.port,
      });
      await e.pump();
      var st = e.c.read(automationServiceProvider);
      expect(st.running, isFalse);
      expect(st.error, contains('${blocker.port}'));

      await e.c.read(settingsProvider.notifier).update({'automationPort': 0});
      for (var i = 0; i < 50 && !e.c.read(automationServiceProvider).running; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      st = e.c.read(automationServiceProvider);
      expect(st.running, isTrue);
      e.port = st.port;
      expect((await e.get('/v1/status')).status, 200);

      // Never reachable through a non-loopback interface.
      final lan = (await NetworkInterface.list(type: InternetAddressType.IPv4))
          .expand((i) => i.addresses)
          .where((a) => !a.isLoopback)
          .toList();
      for (final a in lan) {
        await expectLater(
          Socket.connect(a, e.port, timeout: const Duration(seconds: 1)),
          throwsA(isA<SocketException>()),
          reason: 'bound to ${a.address}',
        );
      }

      await e.c.read(settingsProvider.notifier).update({'automationEnabled': false});
      await e.pump();
      expect(e.c.read(automationServiceProvider).running, isFalse);
      await expectLater(e.get('/v1/status'), throwsA(isA<SocketException>()));
    });

    test('enabling from the service creates a 32-byte token; regenerating changes it', () async {
      final e = await _Env.start(enable: false);
      final svc = e.c.read(automationServiceProvider.notifier);
      await svc.setEnabled(true);
      final t1 = e.c.read(settingsProvider).automationToken;
      expect(t1, matches(RegExp(r'^[0-9a-f]{64}$')));
      final t2 = await svc.regenerateToken();
      expect(t2, isNot(t1));
      expect(e.c.read(settingsProvider).automationToken, t2);
      await e.pump();
      await svc.setEnabled(false);
    });
  });

  group('security', () {
    test('401 without or with a wrong token; 200 with the right one', () async {
      final e = await _Env.start();
      var r = await e.get('/v1/status', token: null);
      expect(r.status, 401);
      expect(r.errorCode, 'unauthorized');
      expect(r.headers.value('www-authenticate'), startsWith('Bearer'));
      r = await e.get('/v1/status', token: 'nope');
      expect(r.status, 401);
      r = await e.get('/v1/status', token: '${_token}x');
      expect(r.status, 401);
      r = await e.call('GET', '/v1/status', token: null, headers: {'Authorization': 'Basic $_token'});
      expect(r.status, 401);
      expect((await e.get('/v1/status')).status, 200);
      // Nothing is served without auth, even unknown paths.
      expect((await e.get('/etc/passwd', token: null)).status, 401);
    });

    test('foreign Host header (DNS rebinding) is refused with 403', () async {
      final e = await _Env.start();
      final r = await e.call('GET', '/v1/status', host: 'evil.example');
      expect(r.status, 403);
      expect(r.errorCode, 'bad_host');
    });

    test('CORS only for allowed origins', () async {
      final e = await _Env.start(origins: ['https://crm.example.com']);
      var r = await e.call('GET', '/v1/status', headers: {'Origin': 'https://evil.example'});
      expect(r.status, 403);
      expect(r.errorCode, 'origin_not_allowed');
      expect(r.headers.value('access-control-allow-origin'), isNull);

      r = await e.call('GET', '/v1/status', headers: {'Origin': 'https://crm.example.com'});
      expect(r.status, 200);
      expect(r.headers.value('access-control-allow-origin'), 'https://crm.example.com');

      // Preflight carries no credentials.
      r = await e.call('OPTIONS', '/v1/calls', token: null, headers: {
        'Origin': 'https://crm.example.com',
        'Access-Control-Request-Method': 'POST',
      });
      expect(r.status, 204);
      expect(r.headers.value('access-control-allow-headers'), contains('Authorization'));
      r = await e.call('OPTIONS', '/v1/calls', token: null, headers: {'Origin': 'https://evil.example'});
      expect(r.status, 403);
      // An allowed origin still needs the token; the error is readable by the page.
      r = await e.call('GET', '/v1/status', token: null, headers: {'Origin': 'https://crm.example.com'});
      expect(r.status, 401);
      expect(r.headers.value('access-control-allow-origin'), 'https://crm.example.com');
      // No origin allow list: browsers get nothing.
      r = await e.call('OPTIONS', '/v1/calls', token: null);
      expect(r.status, 403);
    });

    test('request size limit, invalid JSON, bad bodies', () async {
      final e = await _Env.start();
      var r = await e.call('POST', '/v1/calls', rawBody: '{"to":"${'9' * 70000}"}');
      expect(r.status, 413);
      expect(r.errorCode, 'payload_too_large');
      r = await e.call('POST', '/v1/calls', rawBody: '{nope');
      expect(r.status, 400);
      expect(r.errorCode, 'invalid_json');
      r = await e.call('POST', '/v1/calls', rawBody: '[1,2]');
      expect(r.status, 400);
      expect(r.errorCode, 'invalid_body');
      r = await e.post('/v1/calls', {'to': 42});
      expect(r.status, 400);
      expect(r.errorCode, 'invalid_to');
    });

    test('404 and 405 are JSON', () async {
      final e = await _Env.start();
      var r = await e.get('/v1/nothing');
      expect(r.status, 404);
      expect(r.errorCode, 'not_found');
      r = await e.get('/v2/status');
      expect(r.status, 404);
      r = await e.call('DELETE', '/v1/status');
      expect(r.status, 405);
      expect(r.errorCode, 'method_not_allowed');
      r = await e.get('/v1/calls/999');
      expect(r.status, 404);
      expect(r.errorCode, 'call_not_found');
      r = await e.post('/v1/calls/abc/hangup');
      expect(r.status, 404);
    });

    test('too many event streams are refused (429)', () async {
      final e = await _Env.start();
      final streams = <_Sse>[];
      for (var i = 0; i < 16; i++) {
        streams.add(await e.events());
      }
      final req = await e.http.getUrl(Uri.parse('http://127.0.0.1:${e.port}/v1/events'));
      req.headers.set('Authorization', 'Bearer $_token');
      final res = await req.close();
      expect(res.statusCode, 429);
      await res.drain<void>();
      for (final s in streams) {
        await s.close();
      }
    });
  });

  group('read endpoints', () {
    test('status and accounts report engine and registration state', () async {
      final e = await _Env.start();
      final r = await e.get('/v1/status');
      expect(r.status, 200);
      final j = r.json as Map;
      expect(j['app'], 'SoftphonePro');
      expect(j['version'], isNotEmpty);
      expect(j['engine']['state'], 'running');
      expect(j['dnd'], false);
      expect(j['accounts'], hasLength(1));
      expect(j['accounts'][0]['regState'], 'registered');
      expect(j['accounts'][0]['username'], '1016');

      final a = await e.get('/v1/accounts');
      expect((a.json as Map)['accounts'][0]['id'], 'acc1');
      expect((a.json as Map)['accounts'][0]['address'], '1016@pbx.test');
      expect((await e.get('/v1/calls')).json['calls'], isEmpty);
    });

    test('registration loss shows in status', () async {
      final e = await _Env.start();
      e.engine.simulateRegistrationLost(AccountRef.uid('acc1'), code: 403, error: 'Forbidden (403)');
      await e.pump();
      final j = (await e.get('/v1/accounts')).json as Map;
      expect(j['accounts'][0]['regState'], 'failed');
      expect(j['accounts'][0]['error'], contains('Forbidden'));
    });
  });

  group('calls', () {
    test('outgoing call: dial, hold, unhold, mute, dtmf, hangup, history', () async {
      final e = await _Env.start();
      final sse = await e.events();
      var r = await e.post('/v1/calls', {'to': '600'});
      expect(r.status, 201);
      final cid = r.json['cid'] as int;
      await e.pump();
      await sse.waitFor((_) => sse.hasCall('state') || sse.hasCall('outgoing'));

      var calls = (await e.get('/v1/calls')).json['calls'] as List;
      expect(calls, hasLength(1));
      expect(calls.single['cid'], cid);
      expect(calls.single['direction'], 'outgoing');
      expect(calls.single['state'], 'active');
      expect(calls.single['number'], '600');

      expect((await e.post('/v1/calls/$cid/answer')).status, 409);
      expect((await e.post('/v1/calls/$cid/unhold')).status, 409);

      r = await e.post('/v1/calls/$cid/hold');
      expect(r.status, 200);
      await e.pump();
      expect((await e.get('/v1/calls/$cid')).json['call']['state'], 'held');
      expect((await e.post('/v1/calls/$cid/hold')).status, 409);
      r = await e.post('/v1/calls/$cid/unhold');
      expect(r.status, 200);
      await e.pump();
      expect((await e.get('/v1/calls/$cid')).json['call']['state'], 'active');

      r = await e.post('/v1/calls/$cid/mute');
      expect(r.status, 200);
      await e.pump();
      expect((await e.get('/v1/calls/$cid')).json['call']['muted'], true);
      await e.post('/v1/calls/$cid/unmute');
      await e.pump();
      expect((await e.get('/v1/calls/$cid')).json['call']['muted'], false);

      expect((await e.post('/v1/calls/$cid/dtmf', {'digits': 'x1'})).errorCode, 'invalid_digits');
      expect((await e.post('/v1/calls/$cid/dtmf', {})).status, 400);
      r = await e.post('/v1/calls/$cid/dtmf', {'digits': '1234#'});
      expect(r.status, 200);
      expect(e.engine.sentDtmf[cid], '1234#');

      r = await e.post('/v1/calls/$cid/hangup');
      expect(r.status, 200);
      await e.pump();
      expect((await e.get('/v1/calls')).json['calls'], isEmpty);
      expect((await e.post('/v1/calls/$cid/hangup')).status, anyOf(404, 409));

      await sse.waitFor((_) => sse.hasCall('ended'));
      expect(sse.hasCall('outgoing'), isTrue);
      final h = await e.get('/v1/history?limit=5');
      expect(h.status, 200);
      expect((h.json['history'] as List).first['number'], '600');
      expect((h.json['history'] as List).first['direction'], 'outgoing');
      expect((await e.get('/v1/history?limit=0')).errorCode, 'invalid_limit');
      expect((await e.get('/v1/history?limit=abc')).status, 400);
      await sse.close();
    });

    test('dial validates the account and the engine', () async {
      final e = await _Env.start();
      var r = await e.post('/v1/calls', {'to': '600', 'accountId': 'nope'});
      expect(r.status, 404);
      expect(r.errorCode, 'account_not_found');
      r = await e.post('/v1/calls', {'to': '600', 'accountId': '1016'});
      expect(r.status, 201, reason: 'accounts can be addressed by username');
      r = await e.post('/v1/calls', {'to': '600', 'waitSeconds': 99});
      expect(r.status, 400);
      expect(r.errorCode, 'invalid_wait');
      await e.pump();
    });

    test('dial to an account that failed to register: 409 naming the state', () async {
      final e = await _Env.start();
      e.engine.simulateRegistrationLost(AccountRef.uid('acc1'), code: 403, error: 'Forbidden (403)');
      await e.pump();
      final r = await e.post('/v1/calls', {'to': '600'});
      expect(r.status, 409);
      expect(r.errorCode, 'account_not_ready');
      expect(r.json['error']['message'], contains('not registered'));
    });

    test('incoming call: event, answer via API, remote hangup', () async {
      final e = await _Env.start();
      final sse = await e.events();
      await sse.waitFor((t) => t.contains('event: hello'));
      final ref = e.engine.simulateIncomingCall(from: 'sip:1015@pbx.test', displayName: 'Far End');
      await e.pump();
      await sse.waitFor((_) => sse.hasCall('incoming'));
      final ev = sse.events('call').firstWhere((x) => x['type'] == 'incoming');
      expect(ev['call']['cid'], ref.cid);
      expect(ev['call']['number'], '1015');
      expect(ev['call']['state'], 'ringing_in');
      expect((await e.get('/v1/calls')).json['calls'].single['state'], 'ringing_in');

      expect((await e.post('/v1/calls/${ref.cid}/hold')).status, 409);
      final r = await e.post('/v1/calls/${ref.cid}/answer');
      expect(r.status, 200);
      await e.pump();
      expect((await e.get('/v1/calls/${ref.cid}')).json['call']['state'], 'active');
      expect((await e.post('/v1/calls/${ref.cid}/answer')).status, 409);

      e.engine.simulateRemoteHangup(ref.cid);
      await e.pump();
      await sse.waitFor((_) => sse.hasCall('ended'));
      expect((await e.get('/v1/calls')).json['calls'], isEmpty);
      await sse.close();
    });

    test('blind and attended transfer', () async {
      final e = await _Env.start();
      var r = await e.post('/v1/calls', {'to': '1015'});
      final cid = r.json['cid'] as int;
      await e.pump();
      expect((await e.post('/v1/calls/$cid/transfer', {})).errorCode, 'invalid_target');
      expect((await e.post('/v1/calls/$cid/transfer', {'target': '600', 'attended': 'yes'})).status, 400);
      r = await e.post('/v1/calls/$cid/transfer', {'target': '600'});
      expect(r.status, 200);
      await e.pump();

      r = await e.post('/v1/calls', {'to': '1015'});
      final cid2 = r.json['cid'] as int;
      await e.pump();
      r = await e.post('/v1/calls/$cid2/transfer', {'target': '602', 'attended': true});
      expect(r.status, 200);
      final consult = r.json['consultCid'] as int;
      await e.pump();
      expect((await e.post('/v1/calls/$consult/complete-transfer')).status, 200);
      await e.pump();
    });

    test('ui/show validates the route and brings the window forward', () async {
      final e = await _Env.start();
      expect((await e.post('/v1/ui/show', {'route': '/etc/passwd'})).errorCode, 'invalid_route');
      expect((await e.post('/v1/ui/show', {'route': 7})).status, 400);
      final r = await e.post('/v1/ui/show', {'route': '/settings/advanced'});
      expect(r.status, 200);
      expect(r.json['route'], '/settings/advanced');
      expect((await e.post('/v1/ui/show')).status, 200);
      expect((await e.get('/v1/ui/show')).status, 405);
    });

    test('unknown action is 404', () async {
      final e = await _Env.start();
      final cid = (await e.post('/v1/calls', {'to': '600'})).json['cid'];
      await e.pump();
      expect((await e.post('/v1/calls/$cid/explode')).status, 404);
    });
  });

  group('dnd, messages, events', () {
    test('DND on rejects incoming calls; off accepts them again', () async {
      final e = await _Env.start();
      final sse = await e.events();
      expect((await e.post('/v1/dnd', {'enabled': 'yes'})).status, 400);
      var r = await e.post('/v1/dnd', {'enabled': true});
      expect(r.json['enabled'], true);
      expect((await e.get('/v1/dnd')).json['enabled'], true);
      expect((await e.get('/v1/status')).json['dnd'], true);
      expect(e.c.read(settingsProvider).dnd, isTrue);

      e.engine.simulateIncomingCall(from: 'sip:1015@pbx.test');
      await e.pump();
      expect((await e.get('/v1/calls')).json['calls'], isEmpty);
      await sse.waitFor((_) => sse.events('history').isNotEmpty);
      expect(sse.events('history').first['record']['direction'], 'incoming');
      expect(sse.events('history').first['record']['result'], isNot('answered'));
      expect(sse.events('dnd').single['enabled'], true);

      await e.post('/v1/dnd', {'enabled': false});
      e.engine.simulateIncomingCall(from: 'sip:1015@pbx.test');
      await e.pump();
      expect((await e.get('/v1/calls')).json['calls'], hasLength(1));
      await sse.close();
    });

    test('send a message; delivery events; unreachable peer gives 502', () async {
      final e = await _Env.start();
      final sse = await e.events();
      var r = await e.post('/v1/messages', {'to': '1015', 'body': 'hello from the API'});
      expect(r.status, 201, reason: r.text);
      expect(r.json['message']['direction'], 'outgoing');
      await e.pump();
      await sse.waitFor((_) => sse.events('message').isNotEmpty);
      expect(sse.events('message').first['message']['body'], 'hello from the API');

      expect((await e.post('/v1/messages', {'to': '1015'})).errorCode, 'invalid_body');
      expect((await e.post('/v1/messages', {'body': 'x'})).errorCode, 'invalid_to');
      expect((await e.post('/v1/messages', {'to': '1015', 'body': 'x', 'accountId': 'zzz'})).status, 404);

      e.engine.unreachableUsers.add('1099');
      r = await e.post('/v1/messages', {'to': '1099', 'body': 'x'});
      expect(r.status, anyOf(201, 502));

      e.engine.simulateIm(from: 'sip:1015@pbx.test', body: 'reply');
      await e.pump();
      await sse.waitFor((_) => sse.events('message').any((m) => m['type'] == 'received'));
      await sse.close();
    });

    test('events stream: hello snapshot, account, mwi and heartbeat', () async {
      final e = await _Env.start(enable: false);
      e.c.read(automationServiceProvider.notifier).heartbeat = const Duration(milliseconds: 120);
      await e.c.read(settingsProvider.notifier).update({
        'automationEnabled': true,
        'automationPort': 0,
        'automationToken': _token,
      });
      for (var i = 0; i < 50 && !e.c.read(automationServiceProvider).running; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      e.port = e.c.read(automationServiceProvider).port;
      final sse = await e.events();
      await sse.waitFor((t) => t.startsWith(': connected'));
      await sse.waitFor((t) => t.contains('event: hello'));
      expect(sse.events('hello').single['status']['engine']['state'], 'running');

      e.engine.simulateMwi(AccountRef.uid('acc1'), waiting: true, newMsgs: 3, oldMsgs: 1);
      await e.pump();
      await sse.waitFor((_) => sse.events('mwi').isNotEmpty);
      expect(sse.events('mwi').first['new'], 3);

      e.engine.simulateRegistrationLost(AccountRef.uid('acc1'), code: 503);
      await e.pump();
      await sse.waitFor((_) => sse.events('account').any((a) => a['account']['regState'] != 'registered'));

      await sse.waitFor((t) => t.contains(': ping'));
      expect(RegExp(r'\nid: (\d+)\n').allMatches(sse.text).length, greaterThan(1));
      await sse.close();
    });

    test('a bad token cannot open the event stream', () async {
      final e = await _Env.start();
      final req = await e.http.getUrl(Uri.parse('http://127.0.0.1:${e.port}/v1/events'));
      final res = await req.close();
      expect(res.statusCode, 401);
      await res.drain<void>();
    });
  });
}
