import 'dart:convert';

import 'package:rpg_app/src/core/database/app_database.dart';
import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/domain/repositories/character_repository.dart';
import 'package:uuid/uuid.dart';

class LocalCharacterRepository implements CharacterRepository {
  LocalCharacterRepository(this._database);

  final AppDatabase _database;
  static const Uuid _uuid = Uuid();

  @override
  Future<CharacterSheet> create({
    required String name,
    required String characterClass,
    String classId = '',
    required String race,
    String raceId = '',
    int strength = 10,
    int dexterity = 10,
    int constitution = 10,
    int intelligence = 10,
    int wisdom = 10,
    int charisma = 10,
    int hitDie = 0,
    int currentHp = 0,
    int maxHp = 0,
    int tempHp = 0,
    int armorClass = 10,
    Map<int, int> spellSlotsUsed = const <int, int>{},
    String speed = '',
    String size = '',
    String alignmentHint = '',
    String notes = '',
    Set<String> savingThrowProficiencies = const <String>{},
    Set<String> skillProficiencies = const <String>{},
  }) async {
    final db = await _database.database;
    final now = DateTime.now();
    final id = _uuid.v4();
    final data = <String, Object>{
      'id': id,
      'name': name.trim(),
      'character_class': characterClass.trim(),
      'class_id': classId.trim(),
      'race': race.trim(),
      'race_id': raceId.trim(),
      'level': 1,
      'strength_score': strength,
      'dexterity_score': dexterity,
      'constitution_score': constitution,
      'intelligence_score': intelligence,
      'wisdom_score': wisdom,
      'charisma_score': charisma,
      'hit_die': hitDie,
      'current_hp': currentHp,
      'max_hp': maxHp,
      'speed': speed.trim(),
      'size': size.trim(),
      'alignment_hint': alignmentHint.trim(),
      'notes': notes.trim(),
      'saving_throw_proficiencies': _toCsv(savingThrowProficiencies),
      'skill_proficiencies': _toCsv(skillProficiencies),
      'temp_hp': tempHp,
      'armor_class': armorClass,
      'spell_slots_used': _encodeSlots(spellSlotsUsed),
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
    };

    await db.insert('character_sheets', data);

    return CharacterSheet(
      id: id,
      name: data['name']! as String,
      characterClass: data['character_class']! as String,
      classId: data['class_id']! as String,
      race: data['race']! as String,
      raceId: data['race_id']! as String,
      level: data['level']! as int,
      strength: data['strength_score']! as int,
      dexterity: data['dexterity_score']! as int,
      constitution: data['constitution_score']! as int,
      intelligence: data['intelligence_score']! as int,
      wisdom: data['wisdom_score']! as int,
      charisma: data['charisma_score']! as int,
      hitDie: data['hit_die']! as int,
      currentHp: data['current_hp']! as int,
      maxHp: data['max_hp']! as int,
      speed: data['speed']! as String,
      size: data['size']! as String,
      alignmentHint: data['alignment_hint']! as String,
      notes: data['notes']! as String,
      savingThrowProficiencies: savingThrowProficiencies,
      skillProficiencies: skillProficiencies,
      tempHp: tempHp,
      armorClass: armorClass,
      spellSlotsUsed: spellSlotsUsed,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<CharacterSheet?> getById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'character_sheets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapRow(rows.first);
  }

  @override
  Future<void> update(CharacterSheet character) async {
    final db = await _database.database;
    final now = DateTime.now();
    await db.update(
      'character_sheets',
      {
        'name': character.name.trim(),
        'character_class': character.characterClass.trim(),
        'class_id': character.classId.trim(),
        'race': character.race.trim(),
        'race_id': character.raceId.trim(),
        'level': character.level,
        'strength_score': character.strength,
        'dexterity_score': character.dexterity,
        'constitution_score': character.constitution,
        'intelligence_score': character.intelligence,
        'wisdom_score': character.wisdom,
        'charisma_score': character.charisma,
        'hit_die': character.hitDie,
        'current_hp': character.currentHp,
        'max_hp': character.maxHp,
        'speed': character.speed.trim(),
        'size': character.size.trim(),
        'alignment_hint': character.alignmentHint.trim(),
        'notes': character.notes,
        'saving_throw_proficiencies': _toCsv(
          character.savingThrowProficiencies,
        ),
        'skill_proficiencies': _toCsv(character.skillProficiencies),
        'temp_hp': character.tempHp,
        'armor_class': character.armorClass,
        'spell_slots_used': _encodeSlots(character.spellSlotsUsed),
        'updated_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [character.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete('character_sheets', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CharacterSheet>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('character_sheets', orderBy: 'updated_at DESC');

    return rows.map(_mapRow).toList(growable: false);
  }

  CharacterSheet _mapRow(Map<String, Object?> row) {
    return CharacterSheet(
      id: row['id']! as String,
      name: row['name']! as String,
      characterClass: row['character_class']! as String,
      classId: (row['class_id'] ?? '').toString(),
      race: row['race']! as String,
      raceId: (row['race_id'] ?? '').toString(),
      level: row['level']! as int,
      strength: (row['strength_score'] ?? 10) as int,
      dexterity: (row['dexterity_score'] ?? 10) as int,
      constitution: (row['constitution_score'] ?? 10) as int,
      intelligence: (row['intelligence_score'] ?? 10) as int,
      wisdom: (row['wisdom_score'] ?? 10) as int,
      charisma: (row['charisma_score'] ?? 10) as int,
      hitDie: (row['hit_die'] ?? 0) as int,
      currentHp: (row['current_hp'] ?? 0) as int,
      maxHp: (row['max_hp'] ?? 0) as int,
      speed: (row['speed'] ?? '').toString(),
      size: (row['size'] ?? '').toString(),
      alignmentHint: (row['alignment_hint'] ?? '').toString(),
      notes: (row['notes'] ?? '').toString(),
      savingThrowProficiencies: _fromCsv(
        (row['saving_throw_proficiencies'] ?? '').toString(),
      ),
      skillProficiencies: _fromCsv(
        (row['skill_proficiencies'] ?? '').toString(),
      ),
      tempHp: (row['temp_hp'] ?? 0) as int,
      armorClass: (row['armor_class'] ?? 10) as int,
      spellSlotsUsed: _decodeSlots((row['spell_slots_used'] ?? '').toString()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
    );
  }

  String _toCsv(Set<String> values) {
    if (values.isEmpty) {
      return '';
    }
    final sorted = values.toList()..sort();
    return sorted.join(',');
  }

  Set<String> _fromCsv(String value) {
    if (value.trim().isEmpty) {
      return <String>{};
    }
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  String _encodeSlots(Map<int, int> slots) {
    if (slots.isEmpty) return '';
    return jsonEncode(slots.map((k, v) => MapEntry(k.toString(), v)));
  }

  Map<int, int> _decodeSlots(String value) {
    if (value.isEmpty) return <int, int>{};
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return <int, int>{};
    }
  }
}
