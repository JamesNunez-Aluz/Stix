import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../utils/link_preview.dart';
import '../utils/link_utils.dart';

/// Bottom sheet to manually add an idea to a jar (paste a link / type a title).
class IdeaEditorSheet extends StatefulWidget {
  final int jarId;
  final String? initialLink;
  const IdeaEditorSheet({super.key, required this.jarId, this.initialLink});

  static Future<bool?> show(BuildContext context,
      {required int jarId, String? initialLink}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => IdeaEditorSheet(jarId: jarId, initialLink: initialLink),
    );
  }

  @override
  State<IdeaEditorSheet> createState() => _IdeaEditorSheetState();
}

class _IdeaEditorSheetState extends State<IdeaEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _link;
  late final TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _link = TextEditingController(text: widget.initialLink ?? '');
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _link.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final link = _link.text.trim();
    if (title.isEmpty && link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title or a link')),
      );
      return;
    }
    final platform = link.isEmpty ? null : LinkUtils.platformFromUrl(link);
    final repo = context.read<StixRepository>();
    setState(() => _saving = true);
    // Grab a thumbnail/title from the link if there is one.
    final preview = link.isEmpty ? null : await LinkPreviewService.fetch(link);
    if (!mounted) return;
    final resolvedTitle = title.isNotEmpty
        ? title
        : (preview?.title?.isNotEmpty ?? false)
            ? preview!.title!
            : LinkUtils.displayHost(link);
    await repo.addIdea(
      jarId: widget.jarId,
      title: resolvedTitle,
      sourceUrl: link.isEmpty ? null : link,
      sourcePlatform: platform,
      thumbnailUrl: preview?.imageUrl,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add an idea',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Ramen place downtown',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _link,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Link (optional)',
              hintText: 'Paste a TikTok / Instagram link',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add to jar'),
            ),
          ),
        ],
      ),
    );
  }
}
