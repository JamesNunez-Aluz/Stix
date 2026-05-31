import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Captures a photo (camera or gallery) and stores a copy inside the app's
/// private documents directory so it survives even if the original temp file
/// is cleared.
class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> capture({required ImageSource source}) async {
    final XFile? shot = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2000,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (shot == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docs.path, 'stix_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = p.extension(shot.path).isNotEmpty ? p.extension(shot.path) : '.jpg';
    final dest =
        p.join(photosDir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(shot.path).copy(dest);
    return dest;
  }

  static Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    final f = File(path);
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Best effort — a leftover file is harmless.
    }
  }
}
