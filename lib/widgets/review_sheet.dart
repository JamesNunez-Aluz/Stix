import 'package:flutter/material.dart';

/// The result of reviewing a tried idea.
class ReviewResult {
  final int rating; // 1..5
  final String? thoughts;
  const ReviewResult(this.rating, this.thoughts);
}

/// Bottom sheet: rate an idea you just tried + jot what you thought.
class ReviewSheet extends StatefulWidget {
  final String ideaTitle;
  const ReviewSheet({super.key, required this.ideaTitle});

  static Future<ReviewResult?> show(BuildContext context, String ideaTitle) {
    return showModalBottomSheet<ReviewResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReviewSheet(ideaTitle: ideaTitle),
    );
  }

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int _rating = 4;
  final _thoughts = TextEditingController();

  @override
  void dispose() {
    _thoughts.dispose();
    super.dispose();
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
          Text('How was it?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.ideaTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    iconSize: 36,
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _thoughts,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Thoughts (optional)',
              hintText: 'What did you think? Would you do it again?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(
                ReviewResult(
                  _rating,
                  _thoughts.text.trim().isEmpty ? null : _thoughts.text.trim(),
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Save to Tried It'),
            ),
          ),
        ],
      ),
    );
  }
}
