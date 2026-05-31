import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Renders the polaroid behind [boundaryKey] to a PNG and opens the system
/// share sheet (Instagram, Messages, etc.) with [caption].
class PolaroidShare {
  static Future<bool> share({
    required GlobalKey boundaryKey,
    required String caption,
  }) async {
    final file = await _capture(boundaryKey);
    if (file == null) return false;
    await SharePlus.instance.share(
      ShareParams(text: caption, files: [XFile(file.path)]),
    );
    return true;
  }

  static Future<File?> _capture(GlobalKey key) async {
    // Make sure a frame has painted before we rasterize the boundary.
    await WidgetsBinding.instance.endOfFrame;
    final obj = key.currentContext?.findRenderObject();
    if (obj is! RenderRepaintBoundary) return null;
    final image = await obj.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    final dir = await getTemporaryDirectory();
    final file = File(p.join(
      dir.path,
      'stix_polaroid_${DateTime.now().millisecondsSinceEpoch}.png',
    ));
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  }
}
