import 'dart:io';

import 'package:flutter/material.dart';

import '../models/idea.dart';

/// The pure visual of a polaroid: white frame, square photo, handwritten
/// caption. Kept free of shadows/tilts so it captures cleanly to an image for
/// sharing. Wrap with [captureKey] when you need to render it to a PNG.
class PolaroidView extends StatelessWidget {
  final Idea idea;
  final String? jarLabel; // e.g. "🍜 Food Ideas"
  final GlobalKey? captureKey;
  final double width;

  const PolaroidView({
    super.key,
    required this.idea,
    this.jarLabel,
    this.captureKey,
    this.width = 300,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dateLabel {
    final ms = idea.triedAt;
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rating = idea.rating ?? 0;
    final content = Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: idea.hasPhoto
                ? Image.file(
                    File(idea.photoPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
          const SizedBox(height: 12),
          Text(
            idea.title.isEmpty ? 'a little adventure' : idea.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Caveat',
              fontSize: 26,
              height: 1.05,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          if (rating > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
              ],
            ),
          Text(
            [?jarLabel, if (_dateLabel.isNotEmpty) _dateLabel].join('  ·  '),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 18,
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );

    if (captureKey != null) {
      return RepaintBoundary(key: captureKey, child: content);
    }
    return content;
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFEDEAE6),
      width: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.black38),
          SizedBox(height: 8),
          Text(
            'Add a photo',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 22,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
