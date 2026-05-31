import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens (and creates on first launch) the local SQLite database.
///
/// Two tables:
///   jars  — the user's named containers
///   ideas — every saved idea; `status` is 'in_jar' or 'tried'
class StixDatabase {
  StixDatabase._();
  static final StixDatabase instance = StixDatabase._();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'stix.db');
    return openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        // Needed so ON DELETE CASCADE actually fires.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v2 adds link preview thumbnails.
          await db.execute('ALTER TABLE ideas ADD COLUMN thumbnailUrl TEXT');
        }
        if (oldVersion < 3) {
          // v3 adds a photo taken at the spot (polaroid memories).
          await db.execute('ALTER TABLE ideas ADD COLUMN photoPath TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jars(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            color INTEGER NOT NULL,
            position INTEGER NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE ideas(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jarId INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'in_jar',
            sourceUrl TEXT,
            sourcePlatform TEXT,
            thumbnailUrl TEXT,
            title TEXT NOT NULL,
            note TEXT,
            rating INTEGER,
            thoughts TEXT,
            photoPath TEXT,
            createdAt INTEGER NOT NULL,
            triedAt INTEGER,
            FOREIGN KEY(jarId) REFERENCES jars(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_ideas_jar ON ideas(jarId, status)');
        await db.execute('CREATE INDEX idx_ideas_status ON ideas(status)');
      },
    );
  }
}
