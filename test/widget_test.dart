import 'package:flutter_test/flutter_test.dart';
import 'package:stix/utils/link_utils.dart';

void main() {
  group('LinkUtils.firstUrl', () {
    test('pulls a URL out of typical shared text', () {
      const shared = 'Check out this video! https://vm.tiktok.com/ZMabc123/';
      expect(LinkUtils.firstUrl(shared), 'https://vm.tiktok.com/ZMabc123/');
    });

    test('returns null when there is no URL', () {
      expect(LinkUtils.firstUrl('just some words'), isNull);
    });
  });

  group('LinkUtils.titleFromSharedText', () {
    test('uses the leftover words as a title', () {
      const shared = 'Amazing ramen spot https://instagram.com/p/abc';
      expect(LinkUtils.titleFromSharedText(shared), 'Amazing ramen spot');
    });
  });

  group('LinkUtils.platformFromUrl', () {
    test('detects platforms from the host', () {
      expect(LinkUtils.platformFromUrl('https://www.tiktok.com/@x/video/1'),
          'tiktok');
      expect(LinkUtils.platformFromUrl('https://instagram.com/p/abc'),
          'instagram');
      expect(LinkUtils.platformFromUrl('https://youtu.be/abc'), 'youtube');
      expect(LinkUtils.platformFromUrl('https://example.com/thing'), 'web');
      expect(LinkUtils.platformFromUrl(null), 'web');
    });
  });
}
