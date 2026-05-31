import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/idea.dart';
import '../models/jar.dart';
import '../utils/launch.dart';
import '../utils/link_utils.dart';
import '../widgets/idea_editor_sheet.dart';
import '../widgets/idea_thumbnail.dart';
import '../widgets/jar_editor_sheet.dart';
import 'pull_screen.dart';

class JarDetailScreen extends StatefulWidget {
  final int jarId;
  const JarDetailScreen({super.key, required this.jarId});

  @override
  State<JarDetailScreen> createState() => _JarDetailScreenState();
}

class _JarDetailScreenState extends State<JarDetailScreen> {
  late final StixRepository _repo;
  List<Idea> _ideas = [];
  bool _loading = true;

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
    final ideas = await _repo.ideasInJar(widget.jarId);
    if (!mounted) return;
    setState(() {
      _ideas = ideas;
      _loading = false;
    });
  }

  Future<void> _deleteJar(Jar jar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${jar.name}"?'),
        content: const Text(
          'This removes the jar and all of its ideas, including any tried memories from it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteJar(jar.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch so jar renames/recolors reflect immediately.
    final repo = context.watch<StixRepository>();
    final jar = repo.jarById(widget.jarId);
    if (jar == null) {
      // Jar was deleted out from under us.
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(jar.emoji),
            const SizedBox(width: 8),
            Flexible(child: Text(jar.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                JarEditorSheet.show(context, existing: jar);
              } else if (v == 'delete') {
                _deleteJar(jar);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit jar')),
              PopupMenuItem(value: 'delete', child: Text('Delete jar')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            IdeaEditorSheet.show(context, jarId: widget.jarId),
        icon: const Icon(Icons.add),
        label: const Text('Add idea'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: jar.colorValue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _ideas.isEmpty
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PullScreen(jar: jar),
                                ),
                              ),
                      icon: const Icon(Icons.casino),
                      label: Text(
                        _ideas.isEmpty
                            ? 'Add an idea to start'
                            : 'Pull a random idea 🎲',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _ideas.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                          itemCount: _ideas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) => _IdeaTile(
                            idea: _ideas[i],
                            onOpen: () => openLink(context, _ideas[i].sourceUrl),
                            onDelete: () => _repo.deleteIdea(_ideas[i].id!),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _IdeaTile extends StatelessWidget {
  final Idea idea;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const _IdeaTile({
    required this.idea,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final host = LinkUtils.displayHost(idea.sourceUrl);
    final subtitle = [
      if (host.isNotEmpty) host,
      if (idea.note != null && idea.note!.isNotEmpty) idea.note!,
    ].join(' · ');

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: IdeaThumbnail(
          thumbnailUrl: idea.thumbnailUrl,
          platform: idea.sourcePlatform,
          width: 52,
          height: 52,
          radius: 10,
        ),
        title: Text(
          idea.title.isEmpty ? (host.isEmpty ? 'Untitled idea' : host) : idea.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: idea.hasLink ? onOpen : null,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'open') onOpen();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            if (idea.hasLink)
              const PopupMenuItem(value: 'open', child: Text('Open link')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🫙', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('No ideas yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Share a TikTok or Instagram post into Stix, or tap "Add idea".',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
