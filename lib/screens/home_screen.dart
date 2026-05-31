import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stix_repository.dart';
import '../models/jar.dart';
import '../widgets/jar_editor_sheet.dart';
import 'jar_detail_screen.dart';
import 'tried_it_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<StixRepository>();
    final jars = repo.jars;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stix'),
        actions: [
          IconButton(
            tooltip: 'Tried It',
            icon: const Icon(Icons.history),
            onPressed: () => _openTried(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => JarEditorSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('New jar'),
      ),
      body: !repo.loaded
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: repo.refresh,
              child: GridView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                children: [
                  for (final jar in jars)
                    _JarCard(
                      jar: jar,
                      count: repo.countFor(jar.id!),
                      onTap: () => _openJar(context, jar),
                    ),
                  _TriedCard(
                    count: repo.triedCount,
                    onTap: () => _openTried(context),
                  ),
                ],
              ),
            ),
    );
  }

  void _openJar(BuildContext context, Jar jar) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JarDetailScreen(jarId: jar.id!)),
    );
  }

  void _openTried(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TriedItScreen()),
    );
  }
}

class _JarCard extends StatelessWidget {
  final Jar jar;
  final int count;
  final VoidCallback onTap;
  const _JarCard({required this.jar, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = jar.colorValue;
    return Card(
      color: color.withValues(alpha: 0.16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Text(jar.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const Spacer(),
              Text(
                jar.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                count == 1 ? '1 idea' : '$count ideas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriedCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _TriedCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.secondaryContainer,
                child: const Text('✅', style: TextStyle(fontSize: 24)),
              ),
              const Spacer(),
              Text(
                'Tried It',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                count == 1 ? '1 memory' : '$count memories',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
