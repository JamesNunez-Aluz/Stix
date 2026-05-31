import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/idea.dart';
import '../utils/caption.dart';
import '../utils/launch.dart';
import '../utils/photo_service.dart';
import '../utils/polaroid_share.dart';
import '../widgets/photo_actions.dart';
import '../widgets/polaroid_view.dart';

/// The "Tried It" wall — a gallery of polaroid memories. Each tried idea can
/// hold a photo you snapped at the spot, and be shared to socials with a
/// Stix-shoutout caption.
class TriedItScreen extends StatefulWidget {
  const TriedItScreen({super.key});

  @override
  State<TriedItScreen> createState() => _TriedItScreenState();
}

class _TriedItScreenState extends State<TriedItScreen> {
  late final StixRepository _repo;
  List<Idea> _tried = [];
  bool _loading = true;
  final Map<int, GlobalKey> _keys = {};

  GlobalKey _keyFor(int id) => _keys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    _repo = context.read<StixRepository>();
    _repo.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _repo.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final tried = await _repo.triedIdeas();
    if (!mounted) return;
    setState(() {
      _tried = tried;
      _loading = false;
    });
  }

  String? _jarLabel(Idea idea) {
    final jar = _repo.jarById(idea.jarId);
    return jar == null ? null : '${jar.emoji} ${jar.name}';
  }

  Future<void> _addPhoto(Idea idea) async {
    await addPhotoToIdea(context, _repo, idea, title: 'Add a photo 📸');
  }

  Future<void> _share(Idea idea) async {
    var current = idea;
    if (!current.hasPhoto) {
      final added = await addPhotoToIdea(context, _repo, current,
          title: 'Add a photo to share 📸');
      if (!added) return;
    }
    // Reload to pick up the freshly attached photo, then make sure it's decoded
    // before we rasterize the polaroid.
    await _load();
    final fresh =
        _tried.firstWhere((e) => e.id == idea.id, orElse: () => current);
    if (!fresh.hasPhoto) return;
    if (mounted) {
      await precacheImage(FileImage(File(fresh.photoPath!)), context);
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final ok = await PolaroidShare.share(
      boundaryKey: _keyFor(fresh.id!),
      caption: CaptionBuilder.build(fresh, jar: _repo.jarById(fresh.jarId)),
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not prepare the polaroid')),
      );
    }
  }

  Future<void> _delete(Idea idea) async {
    await PhotoService.deleteIfExists(idea.photoPath);
    await _repo.deleteIdea(idea.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tried It ✅')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tried.isEmpty
              ? const _Empty()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  itemCount: _tried.length,
                  itemBuilder: (_, i) {
                    final idea = _tried[i];
                    return _PolaroidTile(
                      idea: idea,
                      jarLabel: _jarLabel(idea),
                      captureKey: _keyFor(idea.id!),
                      tilt: (i.isEven ? -1 : 1) * 0.018,
                      onAddPhoto: () => _addPhoto(idea),
                      onShare: () => _share(idea),
                      onOpen: () => openLink(context, idea.sourceUrl),
                      onPutBack: () => _repo.untry(idea.id!),
                      onDelete: () => _delete(idea),
                    );
                  },
                ),
    );
  }
}

class _PolaroidTile extends StatelessWidget {
  final Idea idea;
  final String? jarLabel;
  final GlobalKey captureKey;
  final double tilt;
  final VoidCallback onAddPhoto;
  final VoidCallback onShare;
  final VoidCallback onOpen;
  final VoidCallback onPutBack;
  final VoidCallback onDelete;

  const _PolaroidTile({
    required this.idea,
    required this.jarLabel,
    required this.captureKey,
    required this.tilt,
    required this.onAddPhoto,
    required this.onShare,
    required this.onOpen,
    required this.onPutBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Column(
        children: [
          Transform.rotate(
            angle: tilt,
            child: Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black45,
              child: InkWell(
                onTap: idea.hasPhoto ? null : onAddPhoto,
                child: PolaroidView(
                  idea: idea,
                  jarLabel: jarLabel,
                  captureKey: captureKey,
                  width: 300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: Icon(
                    idea.hasPhoto ? Icons.cameraswitch : Icons.add_a_photo,
                    size: 18),
                label: Text(idea.hasPhoto ? 'Retake' : 'Photo'),
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                onPressed: onShare,
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('Share'),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'open':
                      onOpen();
                    case 'putback':
                      onPutBack();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) => [
                  if (idea.hasLink)
                    const PopupMenuItem(value: 'open', child: Text('Open link')),
                  const PopupMenuItem(
                      value: 'putback', child: Text('Put back in jar')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          if (idea.thoughts != null && idea.thoughts!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: Text(
                '“${idea.thoughts!}”',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📸', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('No memories yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Pull an idea, mark "We did this!", and snap a photo at the spot to start your polaroid wall.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
