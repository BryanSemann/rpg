// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rpg_app/src/app/app.dart';
import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/domain/repositories/character_repository.dart';
import 'package:rpg_app/src/features/character/presentation/providers/character_providers.dart';

class _FakeCharacterRepository implements CharacterRepository {
  final List<CharacterSheet> _items = <CharacterSheet>[];

  @override
  Future<CharacterSheet> create({
    String alignmentHint = '',
    required String name,
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
    String notes = '',
    required String race,
    String raceId = '',
    Set<String> savingThrowProficiencies = const <String>{},
    String size = '',
    Set<String> skillProficiencies = const <String>{},
    String speed = '',
    int strength = 10,
    int wisdom = 10,
  }) {
    final now = DateTime.now();
    final character = CharacterSheet(
      id: 'fake-id',
      name: name,
      characterClass: characterClass,
      classId: classId,
      race: race,
      raceId: raceId,
      level: 1,
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
      createdAt: now,
      updatedAt: now,
    );
    _items.add(character);
    return Future.value(character);
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<CharacterSheet>> getAll() async => _items;

  @override
  Future<CharacterSheet?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> update(CharacterSheet character) async {}
}

void main() {
  testWidgets('Main app renders character hub', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          characterRepositoryProvider.overrideWithValue(
            _FakeCharacterRepository(),
          ),
        ],
        child: const RpgApp(),
      ),
    );

    // Wait for async load from local repository.
    await tester.pumpAndSettle();

    expect(find.text('RPG App - Fichas'), findsOneWidget);
    expect(find.text('Nenhuma ficha ainda'), findsOneWidget);
  });
}
