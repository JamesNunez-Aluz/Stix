import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../utils/link_preview.dart';
import '../utils/link_utils.dart';
import 'idea_thumbnail.dart';
import 'jar_editor_sheet.dart';

/// What the user did with the Quick Save card.
enum QuickSaveOutcome { saved, details, cancelled }

/// A compact "save without leaving your feed" card. Shown when a post is shared
/// into Stix: tap a jar and it's saved instantly (then the app returns to the
/// previous app). "Add details" hands off to the full editor.
class QuickSaveSheet extends StatefulWidget {
  final String sharedText;
  const QuickSaveSheet({super.key, required this.sharedText});

  static Future<QuickSaveOutcome> show(
      BuildContext context, String sharedText) async {
    final r = await showModalBottomSheet<QuickSaveOutcome>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => QuickSaveSheet(sharedText: sharedText),
    );
    return r ?? QuickSaveOutcome.cancelled;
  }

  @override
  State<QuickSaveSheet> createState() => _QuickSaveSheetState();
}

class _QuickSaveSheetState extends State<QuickSaveSheet> {
  String? _url;
  String? _platform;
  String _title = '';
  LinkPreview? _preview;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _url = LinkUtils.firstUrl(widget.sharedText);
    _platform = LinkUtils.platformFromUrl(_url);
    _title = LinkUtils.titleFromSharedText(widget.sharedText);
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (_url == null) return;
    final preview = await LinkPreviewService.fetch(_url!);
    if (!mounted) return;
    setState(() {
      _preview = preview;
      if (_title.isEmpty && (preview?.title?.isNotEmpty ?? false)) {
        _title = preview!.title!;
      }
    });
  }

  Future<void> _saveTo(int jarId) async {
    if (_saving) return;
    setState(() => _saving = true);
    final repo = context.read<StixRepository>();
    final jar = repo.jarById(jarId);
    await repo.addIdea(
      jarId: jarId,
      title: _title.isEmpty ? LinkUtils.displayHost(_url) : _title,
      sourceUrl: _url,
      sourcePlatform: _platform,
      thumbnailUrl: _preview?.imageUrl,
    );
    // Native toast — stays visible after we drop back to the previous app.
    await Fluttertoast.showToast(msg: 'Saved to ${jar?.name ?? 'Stix'} 🫙');
    if (mounted) Navigator.of(context).pop(QuickSaveOutcome.saved);
  }

  Future<void> _newJarThenSave() async {
    final repo = context.read<StixRepository>();
    final before = repo.jars.map((j) => j.id).toSet();
    await JarEditorSheet.show(context);
    final added = repo.jars.where((j) => !before.contains(j.id)).toList();
    if (added.isNotEmpty) {
      await _saveTo(added.first.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StixRepository>();
    final jars = repo.jars;
    final host = LinkUtils.displayHost(_url);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IdeaThumbnail(
                thumbnailUrl: _preview?.imageUrl,
                platform: _platform,
                width: 56,
                height: 56,
                radius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title.isEmpty ? (host.isEmpty ? 'New idea' : host) : _title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (host.isNotEmpty)
                      Text(host,
                          style: text.bodySmall, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tap a jar to save', style: text.titleSmall),
          const SizedBox(height: 8),
          if (!repo.loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final jar in jars)
                  ActionChip(
                    avatar: Text(jar.emoji),
                    label: Text(jar.name),
                    onPressed: _saving ? null : () => _saveTo(jar.id!),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('New jar'),
                  onPressed: _saving ? null : _newJarThenSave,
                ),
              ],
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _saving
                  ? null
                  : () => Navigator.of(context).pop(QuickSaveOutcome.details),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Add details'),
            ),
          ),
        ],
      ),
    );
  }
}
