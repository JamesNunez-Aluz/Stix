import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/link_utils.dart';

/// Shows an idea's link thumbnail (cached for offline), falling back to the
/// platform emoji when there's no preview image or it fails to load.
class IdeaThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final String? platform;
  final double width;
  final double height;
  final double radius;
  final double emojiSize;

  const IdeaThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.platform,
    this.width = 48,
    this.height = 48,
    this.radius = 12,
    this.emojiSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = _emojiBox(context);
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }

  Widget _emojiBox(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        LinkUtils.platformEmoji(platform),
        style: TextStyle(fontSize: emojiSize),
      ),
    );
  }
}
