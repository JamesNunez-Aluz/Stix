import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/jar.dart';
import '../theme.dart';

/// Bottom sheet for creating or editing a jar (name + emoji + color).
class JarEditorSheet extends StatefulWidget {
  final Jar? existing;
  const JarEditorSheet({super.key, this.existing});

  /// Opens the editor. Returns true if something was saved.
  static Future<bool?> show(BuildContext context, {Jar? existing}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => JarEditorSheet(existing: existing),
    );
  }

  @override
  State<JarEditorSheet> createState() => _JarEditorSheetState();
}

class _JarEditorSheetState extends State<JarEditorSheet> {
  late final TextEditingController _name;
  late String _emoji;
  late int _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _emoji = widget.existing?.emoji ?? StixTheme.jarEmojis.first;
    _color = widget.existing?.color ?? StixTheme.jarColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your jar a name')),
      );
      return;
    }
    final repo = context.read<StixRepository>();
    if (widget.existing == null) {
      await repo.createJar(name: name, emoji: _emoji, color: _color);
    } else {
      await repo.updateJar(
        widget.existing!.copyWith(name: name, emoji: _emoji, color: _color),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit jar' : 'New jar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Color(_color),
                child: Text(_emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  autofocus: !isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Jar name',
                    hintText: 'e.g. Date Ideas',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Emoji'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in StixTheme.jarEmojis)
                GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: e == _emoji
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(e, style: const TextStyle(fontSize: 18)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in StixTheme.jarColors)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: c == _color
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: c == _color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save changes' : 'Create jar'),
            ),
          ),
        ],
      ),
    );
  }
}
