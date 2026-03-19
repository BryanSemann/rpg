import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/domain/repositories/character_repository.dart';

class CachedCharacterRepository implements CharacterRepository {
  CachedCharacterRepository(this._delegate);

  final CharacterRepository _delegate;

  List<CharacterSheet>? _listCache;
  final Map<String, CharacterSheet> _byId = <String, CharacterSheet>{};

  @override
  Future<CharacterSheet> create({
    String alignmentHint = '',
    required String characterClass,
    String classId = '',
    int charisma = 10,
    int constitution = 10,
    int currentHp = 0,
    int dexterity = 10,
    int hitDie = 0,
    int intelligence = 10,
    int maxHp = 0,
    int tempHp = 0,
    int armorClass = 10,
    Map<int, int> spellSlotsUsed = const <int, int>{},
    required String name,
    String notes = '',
    required String race,
    String raceId = '',
    Set<String> savingThrowProficiencies = const <String>{},
    String size = '',
    Set<String> skillProficiencies = const <String>{},
    String speed = '',
    int strength = 10,
    int wisdom = 10,
  }) async {
    final created = await _delegate.create(
      name: name,
      characterClass: characterClass,
      classId: classId,
      race: race,
      raceId: raceId,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      hitDie: hitDie,
      currentHp: currentHp,
      maxHp: maxHp,
      tempHp: tempHp,
      armorClass: armorClass,
      spellSlotsUsed: spellSlotsUsed,
      speed: speed,
      size: size,
      alignmentHint: alignmentHint,
      notes: notes,
      savingThrowProficiencies: savingThrowProficiencies,
      skillProficiencies: skillProficiencies,
    );

    _byId[created.id] = created;
    if (_listCache != null) {
      _listCache = <CharacterSheet>[created, ..._listCache!];
    }

    return created;
  }

  @override
  Future<void> delete(String id) async {
    await _delegate.delete(id);
    _byId.remove(id);
    if (_listCache != null) {
      _listCache = _listCache!.where((c) => c.id != id).toList(growable: false);
    }
  }

  @override
  Future<List<CharacterSheet>> getAll() async {
    if (_listCache != null) {
      return _listCache!;
    }

    final list = await _delegate.getAll();
    _listCache = list;
    for (final character in list) {
      _byId[character.id] = character;
    }
    return list;
  }

  @override
  Future<CharacterSheet?> getById(String id) async {
    final cached = _byId[id];
    if (cached != null) {
      return cached;
    }

    final fromSource = await _delegate.getById(id);
    if (fromSource != null) {
      _byId[id] = fromSource;
    }
    return fromSource;
  }

  @override
  Future<void> update(CharacterSheet character) async {
    await _delegate.update(character);
    _byId[character.id] = character;

    if (_listCache != null) {
      final updated = <CharacterSheet>[];
      var replaced = false;
      for (final item in _listCache!) {
        if (item.id == character.id) {
          updated.add(character);
          replaced = true;
        } else {
          updated.add(item);
        }
      }
      if (!replaced) {
        updated.insert(0, character);
      }
      _listCache = updated;
    }
  }
}
