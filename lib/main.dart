import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'data/stix_repository.dart';
import 'screens/home_screen.dart';
import 'screens/save_to_stix_screen.dart';
import 'theme.dart';
import 'widgets/quick_save_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = StixRepository();
  // Kick off the initial load; the UI shows a spinner until it's ready.
  repo.load();
  runApp(StixApp(repo: repo));
}

class StixApp extends StatelessWidget {
  final StixRepository repo;
  const StixApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: repo,
      child: MaterialApp(
        title: 'Stix',
        debugShowCheckedModeBanner: false,
        theme: StixTheme.light(),
        darkTheme: StixTheme.dark(),
        home: const _ShareGate(child: HomeScreen()),
      ),
    );
  }
}

/// Wraps the home screen and listens for content shared into Stix from other
/// apps. On a share (cold start or while running) it opens the Save-to-Stix
/// screen. Lives below the Navigator + Provider so it can push routes.
class _ShareGate extends StatefulWidget {
  final Widget child;
  const _ShareGate({required this.child});

  @override
  State<_ShareGate> createState() => _ShareGateState();
}

class _ShareGateState extends State<_ShareGate> {
  StreamSubscription<List<SharedMediaFile>>? _sub;
  bool _routing = false;

  @override
  void initState() {
    super.initState();
    final intent = ReceiveSharingIntent.instance;

    // Shares that arrive while the app is already running.
    _sub = intent.getMediaStream().listen(
      _handleShared,
      onError: (_) {},
    );

    // A share that cold-started the app.
    intent.getInitialMedia().then((files) {
      _handleShared(files);
      intent.reset(); // so it isn't re-delivered on the next launch
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleShared(List<SharedMediaFile> files) {
    if (files.isEmpty || _routing) return;
    // We only handle shared text/links in v1.
    final textItem = files.firstWhere(
      (f) => f.type == SharedMediaType.text || f.type == SharedMediaType.url,
      orElse: () => files.first,
    );
    final shared = textItem.path.trim();
    if (shared.isEmpty) return;

    _routing = true;
    // Defer to the next frame so a Navigator is definitely available.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Compact one-tap card so the user barely leaves their feed.
        final outcome = await QuickSaveSheet.show(context, shared);
        if (outcome == QuickSaveOutcome.details && mounted) {
          // They wanted to add a title/note — hand off to the full editor.
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SaveToStixScreen(sharedText: shared),
            ),
          );
        }
        // Drop back to the app the post came from (e.g. TikTok).
        await SystemNavigator.pop();
      } catch (e) {
        debugPrint('Stix: failed to handle shared content: $e');
      } finally {
        _routing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
