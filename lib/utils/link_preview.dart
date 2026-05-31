import 'package:any_link_preview/any_link_preview.dart';

/// The bits of a link's Open Graph metadata we care about.
class LinkPreview {
  final String? title;
  final String? imageUrl;
  final String? description;
  const LinkPreview({this.title, this.imageUrl, this.description});

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

/// Fetches a link's preview (thumbnail + title) from its Open Graph tags.
/// Best-effort: returns null on any failure, timeout, or unsupported site
/// (e.g. Instagram often blocks this without login). The app degrades to the
/// platform emoji when there's no preview.
class LinkPreviewService {
  static Future<LinkPreview?> fetch(String url) async {
    final link = url.trim();
    if (link.isEmpty) return null;
    try {
      final meta = await AnyLinkPreview.getMetadata(link: link)
          .timeout(const Duration(seconds: 10));
      if (meta == null) return null;
      String? clean(String? s) =>
          (s == null || s.isEmpty || s == 'null') ? null : s;
      return LinkPreview(
        title: clean(meta.title),
        imageUrl: clean(meta.image),
        description: clean(meta.desc),
      );
    } catch (_) {
      return null;
    }
  }
}
