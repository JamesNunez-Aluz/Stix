import 'package:flutter/material.dart';

/// A named container the user drops ideas into (e.g. "Date Ideas", "Food").
class Jar {
  final int? id;
  final String name;
  final String emoji;
  final int color; // stored as an ARGB int
  final int position; // sort order on the home screen
  final int createdAt; // millis since epoch

  const Jar({
    this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.position,
    required this.createdAt,
  });

  Color get colorValue => Color(color);

  Jar copyWith({
    int? id,
    String? name,
    String? emoji,
    int? color,
    int? position,
    int? createdAt,
  }) {
    return Jar(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'position': position,
      'createdAt': createdAt,
    };
  }

  factory Jar.fromMap(Map<String, Object?> map) {
    return Jar(
      id: map['id'] as int?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      color: map['color'] as int,
      position: map['position'] as int,
      createdAt: map['createdAt'] as int,
    );
  }
}
