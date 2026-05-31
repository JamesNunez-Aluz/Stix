/// Helpers for making sense of links shared in from other apps.
///
/// Social apps usually share a chunk of text like
/// "Check out this video! https://vm.tiktok.com/abc/ ..." so we pull the first
/// URL out, and use the leftover words as a friendly default title.
class LinkUtils {
  static final RegExp _urlPattern = RegExp(
    r'https?:\/\/[^\s]+',
    caseSensitive: false,
  );

  /// Returns the first http(s) URL found in [text], or null.
  static String? firstUrl(String text) {
    final match = _urlPattern.firstMatch(text);
    return match?.group(0);
  }

  /// The shared text minus the URL, trimmed — a decent default title.
  static String titleFromSharedText(String text) {
    final without = text.replaceAll(_urlPattern, '').trim();
    // Collapse whitespace/newlines into single spaces.
    final cleaned = without.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  /// Best-effort source label from a URL's host (tiktok / instagram / ...).
  static String platformFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return 'web';
    Uri? uri;
    try {
      uri = Uri.parse(url.trim());
    } catch (_) {
      return 'web';
    }
    final host = uri.host.toLowerCase();
    if (host.contains('tiktok')) return 'tiktok';
    if (host.contains('instagram')) return 'instagram';
    if (host.contains('youtube') || host.contains('youtu.be')) return 'youtube';
    if (host.contains('pinterest') || host.contains('pin.it')) return 'pinterest';
    if (host.contains('facebook') || host.contains('fb.watch')) return 'facebook';
    if (host.contains('reddit')) return 'reddit';
    if (host.contains('twitter') || host.contains('x.com')) return 'twitter';
    return 'web';
  }

  /// An emoji to represent each platform in the UI.
  static String platformEmoji(String? platform) {
    switch (platform) {
      case 'tiktok':
        return '🎵';
      case 'instagram':
        return '📸';
      case 'youtube':
        return '▶️';
      case 'pinterest':
        return '📌';
      case 'facebook':
        return '👥';
      case 'reddit':
        return '👽';
      case 'twitter':
        return '🐦';
      default:
        return '🔗';
    }
  }

  /// Human-friendly host for display, e.g. "tiktok.com".
  static String displayHost(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    try {
      final host = Uri.parse(url.trim()).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return '';
    }
  }
}
