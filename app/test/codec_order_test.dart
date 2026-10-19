import 'package:flutter_test/flutter_test.dart';
import 'package:softphonepro/ui/settings/sections.dart';

void main() {
  test('orderCodecs drops duplicate engine ids and keeps the saved order', () {
    const known = ['speex/16000/1', 'G7221/32000/1', 'G7221/32000/1', 'G7221/32000/1', 'opus/48000/2', 'opus/48000/2'];
    expect(orderCodecs(known, const []), ['speex/16000/1', 'G7221/32000/1', 'opus/48000/2']);
    expect(orderCodecs(known, const ['opus/48000/2', 'gone/8000/1', 'opus/48000/2']), ['opus/48000/2', 'speex/16000/1', 'G7221/32000/1']);
  });
}
