import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the browser / source app. Shows a snackbar on failure.
Future<void> openLink(BuildContext context, String? url) async {
  if (url == null || url.trim().isEmpty) return;
  final messenger = ScaffoldMessenger.of(context);
  Uri? uri;
  try {
    uri = Uri.parse(url.trim());
  } catch (_) {
    uri = null;
  }
  final ok = uri != null &&
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open $url')),
    );
  }
}
