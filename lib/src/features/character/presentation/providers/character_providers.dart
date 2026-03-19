import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_app/src/core/database/app_database.dart';
import 'package:rpg_app/src/features/character/data/repositories/cached_character_repository.dart';
import 'package:rpg_app/src/features/character/data/repositories/drift_character_repository.dart';
import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/domain/repositories/character_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final local = LocalCharacterRepository(db);
  return CachedCharacterRepository(local);
});

final characterListControllerProvider =
    AsyncNotifierProvider<CharacterListController, List<CharacterSheet>>(
      CharacterListController.new,
    );

final characterByIdProvider = FutureProvider.family<CharacterSheet?, String>((
  ref,
  id,
) {
  final repository = ref.watch(characterRepositoryProvider);
  return repository.getById(id);
});

class CharacterListController extends AsyncNotifier<List<CharacterSheet>> {
  CharacterRepository get _repository => ref.read(characterRepositoryProvider);

  @override
  Future<List<CharacterSheet>> build() {
    return _repository.getAll();
  }

  Future<void> createCharacter({
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
    String speed = '',
    String size = '',
    String alignmentHint = '',
    String notes = '',
    Set<String> savingThrowProficiencies = const <String>{},
    Set<String> skillProficiencies = const <String>{},
  }) async {
    final safeName = name.trim();
    final safeClass = characterClass.trim();
    final safeRace = race.trim();
    if (safeName.isEmpty || safeClass.isEmpty || safeRace.isEmpty) {
      return;
    }

    await _repository.create(
      name: safeName,
      characterClass: safeClass,
      classId: classId,
      race: safeRace,
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
      speed: speed,
      size: size,
      alignmentHint: alignmentHint,
      notes: notes,
      savingThrowProficiencies: savingThrowProficiencies,
      skillProficiencies: skillProficiencies,
    );

    state = AsyncData(await _repository.getAll());
  }

  Future<void> deleteCharacter(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.getAll());
  }

  Future<void> updateCharacter(CharacterSheet character) async {
    await _repository.update(character);
    state = AsyncData(await _repository.getAll());
    ref.invalidate(characterByIdProvider(character.id));
  }
}
