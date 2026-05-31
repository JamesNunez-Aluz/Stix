import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/idea.dart';
import '../models/jar.dart';
import 'stix_database.dart';

/// Single source of truth for jars + ideas. Screens read from here and listen
/// for changes via [ChangeNotifier].
class StixRepository extends ChangeNotifier {
  final _rng = Random();

  List<Jar> _jars = [];
  final Map<int, int> _inJarCounts = {}; // jarId -> count of in_jar ideas
  int _triedCount = 0;
  bool _loaded = false;

  List<Jar> get jars => List.unmodifiable(_jars);
  bool get loaded => _loaded;
  int get triedCount => _triedCount;

  int countFor(int jarId) => _inJarCounts[jarId] ?? 0;

  Future<Database> get _db async => StixDatabase.instance.database;

  /// Load jars + counts. Seeds a couple of starter jars on first ever launch.
  Future<void> load() async {
    final db = await _db;
    final existing = await db.query('jars', orderBy: 'position ASC, id ASC');
    if (existing.isEmpty) {
      await _seedStarterJars(db);
    }
    await refresh();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _seedStarterJars(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('jars', {
      'name': 'Date Ideas',
      'emoji': '💖',
      'color': 0xFFE76F51,
      'position': 0,
      'createdAt': now,
    });
    await db.insert('jars', {
      'name': 'Food Ideas',
      'emoji': '🍜',
      'color': 0xFFF4A261,
      'position': 1,
      'createdAt': now + 1,
    });
  }

  /// Re-read jars and recompute the in-jar / tried counts.
  Future<void> refresh() async {
    final db = await _db;
    final jarRows = await db.query('jars', orderBy: 'position ASC, id ASC');
    _jars = jarRows.map(Jar.fromMap).toList();

    _inJarCounts.clear();
    final counts = await db.rawQuery(
      "SELECT jarId, COUNT(*) AS c FROM ideas WHERE status = ? GROUP BY jarId",
      [IdeaStatus.inJar],
    );
    for (final row in counts) {
      _inJarCounts[row['jarId'] as int] = row['c'] as int;
    }

    final tried = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM ideas WHERE status = ?",
      [IdeaStatus.tried],
    );
    _triedCount = (tried.first['c'] as int?) ?? 0;

    notifyListeners();
  }

  // ---- Jars -----------------------------------------------------------------

  Future<Jar> createJar({
    required String name,
    required String emoji,
    required int color,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final position = _jars.length;
    final id = await db.insert('jars', {
      'name': name,
      'emoji': emoji,
      'color': color,
      'position': position,
      'createdAt': now,
    });
    await refresh();
    return _jars.firstWhere((j) => j.id == id);
  }

  Future<void> updateJar(Jar jar) async {
    final db = await _db;
    await db.update('jars', jar.toMap(), where: 'id = ?', whereArgs: [jar.id]);
    await refresh();
  }

  /// Deletes a jar and (via cascade) all of its ideas, including tried ones.
  Future<void> deleteJar(int jarId) async {
    final db = await _db;
    await db.delete('jars', where: 'id = ?', whereArgs: [jarId]);
    await refresh();
  }

  // ---- Ideas ----------------------------------------------------------------

  Future<List<Idea>> ideasInJar(int jarId) async {
    final db = await _db;
    final rows = await db.query(
      'ideas',
      where: 'jarId = ? AND status = ?',
      whereArgs: [jarId, IdeaStatus.inJar],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Idea.fromMap).toList();
  }

  Future<List<Idea>> triedIdeas() async {
    final db = await _db;
    final rows = await db.query(
      'ideas',
      where: 'status = ?',
      whereArgs: [IdeaStatus.tried],
      orderBy: 'triedAt DESC',
    );
    return rows.map(Idea.fromMap).toList();
  }

  Future<Idea> addIdea({
    required int jarId,
    required String title,
    String? sourceUrl,
    String? sourcePlatform,
    String? thumbnailUrl,
    String? note,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final idea = Idea(
      jarId: jarId,
      title: title,
      sourceUrl: sourceUrl,
      sourcePlatform: sourcePlatform,
      thumbnailUrl: thumbnailUrl,
      note: note,
      createdAt: now,
    );
    final map = idea.toMap()..remove('id');
    final id = await db.insert('ideas', map);
    await refresh();
    return idea.copyWith(id: id);
  }

  Future<void> updateIdea(Idea idea) async {
    final db = await _db;
    await db.update('ideas', idea.toMap(),
        where: 'id = ?', whereArgs: [idea.id]);
    await refresh();
  }

  Future<void> deleteIdea(int ideaId) async {
    final db = await _db;
    await db.delete('ideas', where: 'id = ?', whereArgs: [ideaId]);
    await refresh();
  }

  /// Picks a random in-jar idea WITHOUT changing anything. The move to "tried"
  /// only happens later if the user confirms via [markTried].
  Future<Idea?> pullRandom(int jarId) async {
    final ideas = await ideasInJar(jarId);
    if (ideas.isEmpty) return null;
    return ideas[_rng.nextInt(ideas.length)];
  }

  /// Confirms an idea was tried: flips it to the Tried It jar with a rating
  /// and the user's thoughts.
  Future<void> markTried({
    required int ideaId,
    required int rating,
    String? thoughts,
  }) async {
    final db = await _db;
    await db.update(
      'ideas',
      {
        'status': IdeaStatus.tried,
        'rating': rating,
        'thoughts': thoughts,
        'triedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [ideaId],
    );
    await refresh();
  }

  /// Attaches (or replaces) the polaroid photo for an idea.
  Future<void> setPhoto(int ideaId, String photoPath) async {
    final db = await _db;
    await db.update('ideas', {'photoPath': photoPath},
        where: 'id = ?', whereArgs: [ideaId]);
    await refresh();
  }

  /// Removes the photo from an idea.
  Future<void> clearPhoto(int ideaId) async {
    final db = await _db;
    await db.update('ideas', {'photoPath': null},
        where: 'id = ?', whereArgs: [ideaId]);
    await refresh();
  }

  /// Returns a tried idea to its jar (undo).
  Future<void> untry(int ideaId) async {
    final db = await _db;
    await db.update(
      'ideas',
      {
        'status': IdeaStatus.inJar,
        'rating': null,
        'thoughts': null,
        'triedAt': null,
      },
      where: 'id = ?',
      whereArgs: [ideaId],
    );
    await refresh();
  }

  Jar? jarById(int id) {
    for (final j in _jars) {
      if (j.id == id) return j;
    }
    return null;
  }
}
