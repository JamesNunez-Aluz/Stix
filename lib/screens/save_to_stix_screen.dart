import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/jar.dart';
import '../utils/link_preview.dart';
import '../utils/link_utils.dart';
import '../widgets/idea_thumbnail.dart';
import '../widgets/jar_editor_sheet.dart';

/// Shown when something is shared into Stix from another app. Lets the user
/// confirm the link, pick a jar, tweak the title/note, and save.
class SaveToStixScreen extends StatefulWidget {
  final String sharedText;
  const SaveToStixScreen({super.key, required this.sharedText});

  @override
  State<SaveToStixScreen> createState() => _SaveToStixScreenState();
}

class _SaveToStixScreenState extends State<SaveToStixScreen> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  String? _url;
  String? _platform;
  int? _selectedJarId;
  LinkPreview? _preview;
  bool _loadingPreview = false;

  @override
  void initState() {
    super.initState();
    _url = LinkUtils.firstUrl(widget.sharedText);
    _platform = LinkUtils.platformFromUrl(_url);
    final defaultTitle = LinkUtils.titleFromSharedText(widget.sharedText);
    _title = TextEditingController(text: defaultTitle);
    _note = TextEditingController();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    final url = _url;
    if (url == null) return;
    setState(() => _loadingPreview = true);
    final preview = await LinkPreviewService.fetch(url);
    if (!mounted) return;
    setState(() {
      _preview = preview;
      _loadingPreview = false;
      // If the caption gave us no title, borrow the link's own title.
      if (_title.text.trim().isEmpty && (preview?.title?.isNotEmpty ?? false)) {
        _title.text = preview!.title!;
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repo = context.read<StixRepository>();
    final jarId = _selectedJarId;
    if (jarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a jar first')),
      );
      return;
    }
    final title = _title.text.trim();
    await repo.addIdea(
      jarId: jarId,
      title: title.isEmpty ? LinkUtils.displayHost(_url) : title,
      sourceUrl: _url,
      sourcePlatform: _platform,
      thumbnailUrl: _preview?.imageUrl,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (!mounted) return;
    final jar = repo.jarById(jarId);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${jar?.name ?? 'jar'} 🫙')),
    );
  }

  Future<void> _newJar() async {
    final repo = context.read<StixRepository>();
    final before = repo.jars.map((j) => j.id).toSet();
    await JarEditorSheet.show(context);
    // Auto-select the newly created jar.
    final added = repo.jars.where((j) => !before.contains(j.id)).toList();
    if (added.isNotEmpty) {
      setState(() => _selectedJarId = added.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StixRepository>();
    final jars = repo.jars;
    final host = LinkUtils.displayHost(_url);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save to Stix'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_preview?.hasImage ?? false)
                  IdeaThumbnail(
                    thumbnailUrl: _preview!.imageUrl,
                    platform: _platform,
                    width: double.infinity,
                    height: 170,
                    radius: 0,
                    emojiSize: 48,
                  ),
                ListTile(
                  leading: CircleAvatar(
                    child: Text(LinkUtils.platformEmoji(_platform)),
                  ),
                  title: Text(_url ?? widget.sharedText,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: host.isEmpty ? null : Text(host),
                  trailing: _loadingPreview
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Which jar?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final jar in jars) _JarChip(
                jar: jar,
                selected: _selectedJarId == jar.id,
                onTap: () => setState(() => _selectedJarId = jar.id),
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('New jar'),
                onPressed: _newJar,
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save idea'),
          ),
        ],
      ),
    );
  }
}

class _JarChip extends StatelessWidget {
  final Jar jar;
  final bool selected;
  final VoidCallback onTap;
  const _JarChip({
    required this.jar,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Text(jar.emoji),
      label: Text(jar.name),
      selectedColor: jar.colorValue.withValues(alpha: 0.30),
    );
  }
}
