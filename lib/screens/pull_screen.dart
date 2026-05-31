import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/idea.dart';
import '../models/jar.dart';
import '../utils/launch.dart';
import '../utils/link_utils.dart';
import '../widgets/idea_thumbnail.dart';
import '../widgets/photo_actions.dart';
import '../widgets/review_sheet.dart';

/// Full-screen "draw a stick from the jar" moment. Shows one random idea with
/// the option to commit it to Tried It, put it back, or pull another.
class PullScreen extends StatefulWidget {
  final Jar jar;
  const PullScreen({super.key, required this.jar});

  @override
  State<PullScreen> createState() => _PullScreenState();
}

class _PullScreenState extends State<PullScreen> {
  Idea? _idea;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pull();
  }

  Future<void> _pull() async {
    setState(() => _loading = true);
    final idea = await context.read<StixRepository>().pullRandom(widget.jar.id!);
    if (!mounted) return;
    setState(() {
      _idea = idea;
      _loading = false;
    });
  }

  Future<void> _weDidThis() async {
    final idea = _idea;
    if (idea == null) return;
    final review = await ReviewSheet.show(context, idea.title);
    if (review == null) return; // user backed out of the review
    if (!mounted) return;
    final repo = context.read<StixRepository>();
    await repo.markTried(
      ideaId: idea.id!,
      rating: review.rating,
      thoughts: review.thoughts,
    );
    if (!mounted) return;
    // Offer to snap a photo at the spot for the polaroid wall.
    final tried = idea.copyWith(
      status: IdeaStatus.tried,
      rating: review.rating,
      thoughts: review.thoughts,
    );
    await addPhotoToIdea(context, repo, tried,
        title: 'Snap a photo at the spot? 📸');
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to Tried It ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.jar.colorValue;
    return Scaffold(
      appBar: AppBar(title: Text('Pull from ${widget.jar.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _idea == null
              ? _EmptyJar(jarName: widget.jar.name)
              : _Reveal(
                  idea: _idea!,
                  color: color,
                  onWeDidThis: _weDidThis,
                  onPutBack: () => Navigator.of(context).pop(),
                  onPullAnother: _pull,
                ),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Idea idea;
  final Color color;
  final VoidCallback onWeDidThis;
  final VoidCallback onPutBack;
  final VoidCallback onPullAnother;

  const _Reveal({
    required this.idea,
    required this.color,
    required this.onWeDidThis,
    required this.onPutBack,
    required this.onPullAnother,
  });

  @override
  Widget build(BuildContext context) {
    final host = LinkUtils.displayHost(idea.sourceUrl);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  if (idea.hasThumbnail)
                    IdeaThumbnail(
                      thumbnailUrl: idea.thumbnailUrl,
                      platform: idea.sourcePlatform,
                      width: double.infinity,
                      height: 180,
                      radius: 16,
                      emojiSize: 56,
                    )
                  else
                    Text(
                      LinkUtils.platformEmoji(idea.sourcePlatform),
                      style: const TextStyle(fontSize: 48),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    idea.title.isEmpty ? 'Tap to open' : idea.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (idea.note != null && idea.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(idea.note!, textAlign: TextAlign.center),
                  ],
                  if (idea.hasLink) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => openLink(context, idea.sourceUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(host.isEmpty ? 'Open link' : 'Open on $host'),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onWeDidThis,
                icon: const Icon(Icons.check_circle),
                label: const Text('We did this!'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPutBack,
                    icon: const Icon(Icons.undo),
                    label: const Text('Put it back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPullAnother,
                    icon: const Icon(Icons.casino),
                    label: const Text('Pull another'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyJar extends StatelessWidget {
  final String jarName;
  const _EmptyJar({required this.jarName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🫙', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$jarName is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Share a post into Stix or add an idea, then come back to pull one.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to jar'),
            ),
          ],
        ),
      ),
    );
  }
}
