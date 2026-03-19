import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';

abstract class CharacterRepository {
  Future<List<CharacterSheet>> getAll();

  Future<CharacterSheet?> getById(String id);

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
  });

  Future<void> update(CharacterSheet character);

  Future<void> delete(String id);
}
