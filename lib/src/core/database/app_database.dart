import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rpg_app.sqlite');
    _database = await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE character_sheets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            character_class TEXT NOT NULL,
            class_id TEXT NOT NULL DEFAULT '',
            race TEXT NOT NULL,
            race_id TEXT NOT NULL DEFAULT '',
            level INTEGER NOT NULL DEFAULT 1,
            strength_score INTEGER NOT NULL DEFAULT 10,
            dexterity_score INTEGER NOT NULL DEFAULT 10,
            constitution_score INTEGER NOT NULL DEFAULT 10,
            intelligence_score INTEGER NOT NULL DEFAULT 10,
            wisdom_score INTEGER NOT NULL DEFAULT 10,
            charisma_score INTEGER NOT NULL DEFAULT 10,
            hit_die INTEGER NOT NULL DEFAULT 0,
            current_hp INTEGER NOT NULL DEFAULT 0,
            max_hp INTEGER NOT NULL DEFAULT 0,
            speed TEXT NOT NULL DEFAULT '',
            size TEXT NOT NULL DEFAULT '',
            alignment_hint TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT '',
            saving_throw_proficiencies TEXT NOT NULL DEFAULT '',
            skill_proficiencies TEXT NOT NULL DEFAULT '',
            temp_hp INTEGER NOT NULL DEFAULT 0,
            armor_class INTEGER NOT NULL DEFAULT 10,
            spell_slots_used TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN class_id TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN race_id TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN hit_die INTEGER NOT NULL DEFAULT 0',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN current_hp INTEGER NOT NULL DEFAULT 0',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN max_hp INTEGER NOT NULL DEFAULT 0',
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN speed TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN size TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN alignment_hint TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN notes TEXT NOT NULL DEFAULT ''",
          );
        }

        if (oldVersion < 3) {
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN strength_score INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN dexterity_score INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN constitution_score INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN intelligence_score INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN wisdom_score INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN charisma_score INTEGER NOT NULL DEFAULT 10',
          );
        }

        if (oldVersion < 4) {
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN saving_throw_proficiencies TEXT NOT NULL DEFAULT ''",
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN skill_proficiencies TEXT NOT NULL DEFAULT ''",
          );
        }

        if (oldVersion < 5) {
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN temp_hp INTEGER NOT NULL DEFAULT 0',
          );
          await _tryAddColumn(
            db,
            'ALTER TABLE character_sheets ADD COLUMN armor_class INTEGER NOT NULL DEFAULT 10',
          );
          await _tryAddColumn(
            db,
            "ALTER TABLE character_sheets ADD COLUMN spell_slots_used TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );

    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _tryAddColumn(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (_) {
      // Column may already exist in local debug databases.
    }
  }
}
