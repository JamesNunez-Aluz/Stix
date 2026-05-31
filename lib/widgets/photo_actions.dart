import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/stix_repository.dart';
import '../models/idea.dart';
import '../utils/photo_service.dart';

/// Bottom sheet to choose camera vs gallery.
Future<ImageSource?> showPhotoSourceSheet(
  BuildContext context, {
  String? title,
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: Theme.of(ctx).textTheme.titleLarge),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Full flow: ask source → capture → store the new photo on [idea],
/// replacing/cleaning up any previous one. Returns true if a photo was saved.
Future<bool> addPhotoToIdea(
  BuildContext context,
  StixRepository repo,
  Idea idea, {
  String? title,
}) async {
  final source = await showPhotoSourceSheet(context, title: title);
  if (source == null) return false;
  if (!context.mounted) return false;
  final messenger = ScaffoldMessenger.of(context);
  final newPath = await PhotoService.capture(source: source);
  if (newPath == null) return false;
  final oldPath = idea.photoPath;
  await repo.setPhoto(idea.id!, newPath);
  if (oldPath != null && oldPath != newPath) {
    await PhotoService.deleteIfExists(oldPath);
  }
  messenger.showSnackBar(
    const SnackBar(content: Text('Photo added 📸')),
  );
  return true;
}
