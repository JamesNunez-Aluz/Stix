import 'package:flutter/material.dart';

/// Warm, playful palette — a jar of fun ideas.
class StixTheme {
  static const seed = Color(0xFFE76F51); // burnt coral

  /// A friendly palette users pick from when creating a jar.
  static const jarColors = <int>[
    0xFFE76F51, // coral
    0xFFF4A261, // amber
    0xFFE9C46A, // gold
    0xFF2A9D8F, // teal
    0xFF457B9D, // blue
    0xFF8E7DBE, // lavender
    0xFFE07A9B, // pink
    0xFF6A994E, // green
  ];

  /// A handful of emojis to make jar creation a one-tap delight.
  static const jarEmojis = <String>[
    '💖', '🍜', '🎬', '🌮', '🍩', '🏞️', '🎁', '✈️',
    '🍷', '🎨', '📚', '🎸', '🏖️', '☕', '🧗', '🎮',
  ];

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
