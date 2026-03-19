import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';
import 'package:rpg_app/src/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/presentation/providers/character_providers.dart';
import 'package:rpg_app/src/features/settings/presentation/providers/app_settings_provider.dart';

class CharacterDetailPage extends ConsumerStatefulWidget {
  const CharacterDetailPage({required this.characterId, super.key});

  final String characterId;

  @override
  ConsumerState<CharacterDetailPage> createState() =>
      _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _levelController;
  late final TextEditingController _currentHpController;
  final TextEditingController _tempHpController = TextEditingController(
    text: '0',
  );
  late final TextEditingController _maxHpController;
  late final TextEditingController _hitDieController;
  late final TextEditingController _armorClassController;
  late final TextEditingController _strengthController;
  late final TextEditingController _dexterityController;
  late final TextEditingController _constitutionController;
  late final TextEditingController _intelligenceController;
  late final TextEditingController _wisdomController;
  late final TextEditingController _charismaController;
  late final TextEditingController _speedController;
  late final TextEditingController _notesController;

  CharacterSheet? _loaded;
  CharacterSheet? _currentDraft;
  Set<String> _savingThrowProficiencies = <String>{};
  Set<String> _skillProficiencies = <String>{};
  Map<int, int> _spellSlotsUsed = <int, int>{};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _levelController = TextEditingController();
    _currentHpController = TextEditingController();
    _maxHpController = TextEditingController();
    _hitDieController = TextEditingController();
    _armorClassController = TextEditingController(text: '10');
    _strengthController = TextEditingController();
    _dexterityController = TextEditingController();
    _constitutionController = TextEditingController();
    _intelligenceController = TextEditingController();
    _wisdomController = TextEditingController();
    _charismaController = TextEditingController();
    _speedController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _currentHpController.dispose();
    _tempHpController.dispose();
    _maxHpController.dispose();
    _hitDieController.dispose();
    _armorClassController.dispose();
    _strengthController.dispose();
    _dexterityController.dispose();
    _constitutionController.dispose();
    _intelligenceController.dispose();
    _wisdomController.dispose();
    _charismaController.dispose();
    _speedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCharacter = ref.watch(characterByIdProvider(widget.characterId));

    final loadedCharacter = asyncCharacter.valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do personagem'),
        actions: [
          if (loadedCharacter != null &&
              loadedCharacter.classId.isNotEmpty &&
              (_currentDraft?.level ?? loadedCharacter.level) < 20)
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Subir de nivel',
              onPressed: () => _showLevelUpDialog(context, loadedCharacter),
            ),
        ],
      ),
      floatingActionButton: _currentDraft == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_skills',
                  tooltip: 'Pericias',
                  onPressed: () async {
                    final updated = await _showSkillsModal(
                      context,
                      _currentDraft!,
                      _skillProficiencies,
                    );
                    if (updated != null && mounted) {
                      setState(() => _skillProficiencies = updated);
                    }
                  },
                  child: const Icon(Icons.auto_awesome_outlined),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fab_saves',
                  tooltip: 'Resistencias',
                  onPressed: () async {
                    final updated = await _showSavingThrowsModal(
                      context,
                      _currentDraft!,
                      _savingThrowProficiencies,
                    );
                    if (updated != null && mounted) {
                      setState(() => _savingThrowProficiencies = updated);
                    }
                  },
                  child: const Icon(Icons.shield_outlined),
                ),
              ],
            ),
      body: asyncCharacter.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (character) {
          if (character == null) {
            return const Center(child: Text('Personagem nao encontrado'));
          }

          _hydrateFormIfNeeded(character);
          final liveLevel = _toBoundedInt(
            _levelController.text,
            min: 1,
            max: 20,
            fallback: character.level,
          );
          final liveStrength = _toBoundedInt(
            _strengthController.text,
            min: 1,
            max: 30,
            fallback: character.strength,
          );
          final liveDexterity = _toBoundedInt(
            _dexterityController.text,
            min: 1,
            max: 30,
            fallback: character.dexterity,
          );
          final liveConstitution = _toBoundedInt(
            _constitutionController.text,
            min: 1,
            max: 30,
            fallback: character.constitution,
          );
          final liveIntelligence = _toBoundedInt(
            _intelligenceController.text,
            min: 1,
            max: 30,
            fallback: character.intelligence,
          );
          final liveWisdom = _toBoundedInt(
            _wisdomController.text,
            min: 1,
            max: 30,
            fallback: character.wisdom,
          );
          final liveCharisma = _toBoundedInt(
            _charismaController.text,
            min: 1,
            max: 30,
            fallback: character.charisma,
          );
          final liveDraft = character.copyWith(
            level: liveLevel,
            strength: liveStrength,
            dexterity: liveDexterity,
            constitution: liveConstitution,
            intelligence: liveIntelligence,
            wisdom: liveWisdom,
            charisma: liveCharisma,
            savingThrowProficiencies: _savingThrowProficiencies,
            skillProficiencies: _skillProficiencies,
          );

          _currentDraft = liveDraft;

          // Enrichment from catalog API — optional if IDs unavailable.
          final raceInfoAsync = character.raceId.isNotEmpty
              ? ref.watch(raceInfoProvider(character.raceId))
              : const AsyncData<RaceInfo?>(null);
          final classInfoAsync = character.classId.isNotEmpty
              ? ref.watch(classInfoProvider(character.classId))
              : const AsyncData<ClassInfo?>(null);
          final classLevelInfoAsync = character.classId.isNotEmpty
              ? ref.watch(
                  classLevelInfoProvider((character.classId, liveLevel)),
                )
              : const AsyncData<ClassLevelInfo?>(null);

          final raceInfo = raceInfoAsync.valueOrNull;
          final classInfo = classInfoAsync.valueOrNull;
          final classLevelInfo = classLevelInfoAsync.valueOrNull;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _TopInfoGrid(
                  nameController: _nameController,
                  className: classInfo?.name ?? character.characterClass,
                  raceName: raceInfo?.name ?? character.race,
                  levelController: _levelController,
                  onLevelChanged: (_) => setState(() {}),
                  proficiencyBonus: liveDraft.proficiencyBonus,
                ),
                const SizedBox(height: 12),
                _CombatStatsSection(
                  hpController: _currentHpController,
                  tempHpController: _tempHpController,
                  maxHpController: _maxHpController,
                  hitDieController: _hitDieController,
                  armorClassController: _armorClassController,
                  speedController: _speedController,
                    speedHint: raceInfo != null
                        ? '${raceInfo.speedFt} ft (base da raca)'
                      : null,
                ),
                const SizedBox(height: 12),
                _AbilityGrid(
                  character: liveDraft,
                  strengthController: _strengthController,
                  dexterityController: _dexterityController,
                  constitutionController: _constitutionController,
                  intelligenceController: _intelligenceController,
                  wisdomController: _wisdomController,
                  charismaController: _charismaController,
                  onChanged: (_) => setState(() {}),
                  abilityBonuses:
                      raceInfo?.abilityBonuses ?? const <String, int>{},
                ),
                if (raceInfo != null && raceInfo.traits.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ChipSection(
                    title: 'Traços raciais',
                    entries: raceInfo.traits,
                    descType: 'trait',
                  ),
                ],
                if (classLevelInfo != null &&
                    classLevelInfo.features.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ChipSection(
                    title: 'Habilidades de classe (nível $liveLevel)',
                    entries: classLevelInfo.features,
                    descType: 'feature',
                  ),
                ],
                if (classInfo != null &&
                    classInfo.isSpellcaster &&
                    classLevelInfo != null) ...[
                  const SizedBox(height: 12),
                  _SpellSlotsSection(
                    classInfo: classInfo,
                    levelInfo: classLevelInfo,
                    character: liveDraft,
                    slotsUsed: _spellSlotsUsed,
                    onSlotsChanged: (updated) =>
                        setState(() => _spellSlotsUsed = updated),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notas'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () => _saveCharacter(context, character),
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar alteracoes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _hydrateFormIfNeeded(CharacterSheet character) {
    if (_loaded?.id == character.id &&
        _loaded?.updatedAt == character.updatedAt) {
      return;
    }

    _loaded = character;
    _nameController.text = character.name;
    _levelController.text = character.level.toString();
    _currentHpController.text = character.currentHp.toString();
    _tempHpController.text = character.tempHp.toString();
    _maxHpController.text = character.maxHp.toString();
    _hitDieController.text = character.hitDie.toString();
    _armorClassController.text = character.armorClass.toString();
    _strengthController.text = character.strength.toString();
    _dexterityController.text = character.dexterity.toString();
    _constitutionController.text = character.constitution.toString();
    _intelligenceController.text = character.intelligence.toString();
    _wisdomController.text = character.wisdom.toString();
    _charismaController.text = character.charisma.toString();
    _speedController.text = character.speed;
    _notesController.text = character.notes;
    _savingThrowProficiencies = Set<String>.from(
      character.savingThrowProficiencies,
    );
    _skillProficiencies = Set<String>.from(character.skillProficiencies);
    _spellSlotsUsed = Map<int, int>.from(character.spellSlotsUsed);
  }

  Future<void> _saveCharacter(BuildContext context, CharacterSheet base) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    final level = _toPositiveInt(_levelController.text, fallback: base.level);
    final boundedLevel = level.clamp(1, 20);
    final maxHp = _toPositiveInt(_maxHpController.text, fallback: base.maxHp);
    final currentHp = _toPositiveInt(
      _currentHpController.text,
      fallback: base.currentHp,
    ).clamp(0, maxHp > 0 ? maxHp : 9999);
    final tempHp = _toPositiveInt(
      _tempHpController.text,
      fallback: base.tempHp,
    ).clamp(0, 9999);
    final hitDie = _toPositiveInt(
      _hitDieController.text,
      fallback: base.hitDie,
    );
    final armorClass = _toBoundedInt(
      _armorClassController.text,
      min: 1,
      max: 30,
      fallback: base.armorClass,
    );
    final strength = _toBoundedInt(
      _strengthController.text,
      min: 1,
      max: 30,
      fallback: base.strength,
    );
    final dexterity = _toBoundedInt(
      _dexterityController.text,
      min: 1,
      max: 30,
      fallback: base.dexterity,
    );
    final constitution = _toBoundedInt(
      _constitutionController.text,
      min: 1,
      max: 30,
      fallback: base.constitution,
    );
    final intelligence = _toBoundedInt(
      _intelligenceController.text,
      min: 1,
      max: 30,
      fallback: base.intelligence,
    );
    final wisdom = _toBoundedInt(
      _wisdomController.text,
      min: 1,
      max: 30,
      fallback: base.wisdom,
    );
    final charisma = _toBoundedInt(
      _charismaController.text,
      min: 1,
      max: 30,
      fallback: base.charisma,
    );

    final updated = base.copyWith(
      name: _nameController.text.trim(),
      level: boundedLevel,
      strength: strength,
      dexterity: dexterity,
      constitution: constitution,
      intelligence: intelligence,
      wisdom: wisdom,
      charisma: charisma,
      currentHp: currentHp,
      tempHp: tempHp,
      maxHp: maxHp,
      hitDie: hitDie,
      armorClass: armorClass,
      speed: _speedController.text.trim(),
      notes: _notesController.text,
      savingThrowProficiencies: _savingThrowProficiencies,
      skillProficiencies: _skillProficiencies,
      spellSlotsUsed: _spellSlotsUsed,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(characterListControllerProvider.notifier)
        .updateCharacter(updated);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    messenger.showSnackBar(
      const SnackBar(content: Text('Ficha atualizada com sucesso')),
    );
  }

  int _toPositiveInt(String value, {required int fallback}) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return fallback;
    }
    return parsed < 0 ? 0 : parsed;
  }

  int _toBoundedInt(
    String value, {
    required int min,
    required int max,
    required int fallback,
  }) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return fallback;
    }
    if (parsed < min) {
      return min;
    }
    if (parsed > max) {
      return max;
    }
    return parsed;
  }

  Future<void> _showLevelUpDialog(
    BuildContext context,
    CharacterSheet character,
  ) async {
    final liveLevel = _toBoundedInt(
      _levelController.text,
      min: 1,
      max: 20,
      fallback: character.level,
    );
    final nextLevel = liveLevel + 1;
    if (nextLevel > 20) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    ClassLevelInfo? nextLevelInfo;
    try {
      nextLevelInfo = await ref.read(
        classLevelInfoProvider((character.classId, nextLevel)).future,
      );
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.of(context).pop();

    final classInfo = ref
        .read(classInfoProvider(character.classId))
        .valueOrNull;
    final conMod = character.constitutionModifier;
    final hitDie = character.hitDie;
    final avgHpGain = ((hitDie / 2).ceil() + conMod).clamp(1, 99);
    const asiLevels = {4, 8, 12, 16, 19};
    final isAsiLevel = asiLevels.contains(nextLevel);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Subir para nivel $nextLevel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nextLevelInfo != null &&
                  nextLevelInfo.features.isNotEmpty) ...[
                Text(
                  'Habilidades ganhas:',
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                ...nextLevelInfo.features.map((f) => Text('• ${f.name}')),
                const SizedBox(height: 8),
              ],
              Text(
                'HP sugerido: +$avgHpGain '
                '(d$hitDie/2+1 + CON ${_fmt(conMod)})',
              ),
              if (isAsiLevel) ...[
                const SizedBox(height: 6),
                Text(
                  'Nivel ASI: voce ganha um incremento de atributo!',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (classInfo != null && classInfo.isSpellcaster) ...[
                const SizedBox(height: 6),
                const Text('Os usos dos espacos de magia serao resetados.'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _levelController.text = nextLevel.toString();
        _spellSlotsUsed = {};
      });
      final updated = character.copyWith(
        level: nextLevel,
        spellSlotsUsed: const <int, int>{},
        updatedAt: DateTime.now(),
      );
      await ref
          .read(characterListControllerProvider.notifier)
          .updateCharacter(updated);
    }
  }

  Future<Set<String>?> _showSavingThrowsModal(
    BuildContext context,
    CharacterSheet character,
    Set<String> initial,
  ) async {
    return showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final local = Set<String>.from(initial);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Resistencias'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    children: CharacterSheet.abilities
                        .map((ability) {
                          final isProficient = local.contains(ability);
                          final total = character
                              .copyWith(savingThrowProficiencies: local)
                              .savingThrowTotal(ability);
                          return CheckboxListTile(
                            dense: true,
                            value: isProficient,
                            onChanged: (value) {
                              setModalState(() {
                                if (value ?? false) {
                                  local.add(ability);
                                } else {
                                  local.remove(ability);
                                }
                              });
                            },
                            title: Text('$ability: ${_fmt(total)}'),
                            subtitle: Text(
                              isProficient
                                  ? 'Com proficiencia (+${character.proficiencyBonus})'
                                  : 'Sem proficiencia',
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(local),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Set<String>?> _showSkillsModal(
    BuildContext context,
    CharacterSheet character,
    Set<String> initial,
  ) async {
    return showDialog<Set<String>>(
      context: context,
      builder: (context) {
        final local = Set<String>.from(initial);
        final skills = CharacterSheet.skillAbilityMap.keys.toList()..sort();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Pericias'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    children: skills
                        .map((skill) {
                          final ability =
                              CharacterSheet.skillAbilityMap[skill]!;
                          final isProficient = local.contains(skill);
                          final total = character
                              .copyWith(skillProficiencies: local)
                              .skillTotal(skill);
                          return CheckboxListTile(
                            dense: true,
                            value: isProficient,
                            onChanged: (value) {
                              setModalState(() {
                                if (value ?? false) {
                                  local.add(skill);
                                } else {
                                  local.remove(skill);
                                }
                              });
                            },
                            title: Text('$skill ($ability): ${_fmt(total)}'),
                            subtitle: Text(
                              isProficient
                                  ? 'Com proficiencia (+${character.proficiencyBonus})'
                                  : 'Sem proficiencia',
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(local),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _TopInfoGrid extends StatelessWidget {
  const _TopInfoGrid({
    required this.nameController,
    required this.className,
    required this.raceName,
    required this.levelController,
    required this.onLevelChanged,
    required this.proficiencyBonus,
  });

  final TextEditingController nameController;
  final String className;
  final String raceName;
  final TextEditingController levelController;
  final ValueChanged<String> onLevelChanged;
  final int proficiencyBonus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  return (value == null || value.trim().isEmpty)
                      ? 'Informe o nome'
                      : null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: className,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Classe'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: raceName,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Raca'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: levelController,
                decoration: const InputDecoration(labelText: 'Nivel'),
                keyboardType: TextInputType.number,
                onChanged: onLevelChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Bonus prof.'),
                child: Text('+$proficiencyBonus'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Combat Stats ─────────────────────────────────────────────────────────────

class _CombatStatsSection extends StatelessWidget {
  const _CombatStatsSection({
    required this.hpController,
    required this.tempHpController,
    required this.maxHpController,
    required this.hitDieController,
    required this.armorClassController,
    required this.speedController,
    this.speedHint,
  });

  final TextEditingController hpController;
  final TextEditingController tempHpController;
  final TextEditingController maxHpController;
  final TextEditingController hitDieController;
  final TextEditingController armorClassController;
  final TextEditingController speedController;
  final String? speedHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: hpController,
                decoration: const InputDecoration(labelText: 'HP'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: tempHpController,
                decoration: const InputDecoration(labelText: 'HP Temp'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: maxHpController,
                decoration: const InputDecoration(labelText: 'HP Max'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: hitDieController,
                decoration: const InputDecoration(labelText: 'Dado de vida'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: armorClassController,
                decoration: const InputDecoration(labelText: 'CA'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: speedController,
                decoration: InputDecoration(
                  labelText: 'Deslocamento',
                  hintText: speedHint,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Ability Scores ────────────────────────────────────────────────────────────

class _AbilityGrid extends StatelessWidget {
  const _AbilityGrid({
    required this.character,
    required this.strengthController,
    required this.dexterityController,
    required this.constitutionController,
    required this.intelligenceController,
    required this.wisdomController,
    required this.charismaController,
    required this.onChanged,
    this.abilityBonuses = const <String, int>{},
  });

  final CharacterSheet character;
  final TextEditingController strengthController;
  final TextEditingController dexterityController;
  final TextEditingController constitutionController;
  final TextEditingController intelligenceController;
  final TextEditingController wisdomController;
  final TextEditingController charismaController;
  final ValueChanged<String> onChanged;
  final Map<String, int> abilityBonuses;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
      children: [
        _AbilityCell(
          label: 'STR',
          controller: strengthController,
          modifier: character.strengthModifier,
          racialBonus: abilityBonuses['STR'],
          onChanged: onChanged,
        ),
        _AbilityCell(
          label: 'DEX',
          controller: dexterityController,
          modifier: character.dexterityModifier,
          racialBonus: abilityBonuses['DEX'],
          onChanged: onChanged,
        ),
        _AbilityCell(
          label: 'CON',
          controller: constitutionController,
          modifier: character.constitutionModifier,
          racialBonus: abilityBonuses['CON'],
          onChanged: onChanged,
        ),
        _AbilityCell(
          label: 'INT',
          controller: intelligenceController,
          modifier: character.intelligenceModifier,
          racialBonus: abilityBonuses['INT'],
          onChanged: onChanged,
        ),
        _AbilityCell(
          label: 'WIS',
          controller: wisdomController,
          modifier: character.wisdomModifier,
          racialBonus: abilityBonuses['WIS'],
          onChanged: onChanged,
        ),
        _AbilityCell(
          label: 'CHA',
          controller: charismaController,
          modifier: character.charismaModifier,
          racialBonus: abilityBonuses['CHA'],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AbilityCell extends StatelessWidget {
  const _AbilityCell({
    required this.label,
    required this.controller,
    required this.modifier,
    required this.onChanged,
    this.racialBonus,
  });

  final String label;
  final TextEditingController controller;
  final int modifier;
  final int? racialBonus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(label, style: theme.textTheme.labelLarge),
                if (racialBonus != null && racialBonus != 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+$racialBonus',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(isDense: true),
              keyboardType: TextInputType.number,
              onChanged: onChanged,
            ),
            const SizedBox(height: 4),
            Text('Mod ${_fmt(modifier)}'),
          ],
        ),
      ),
    );
  }
}

// ─── Racial Traits & Class Features ───────────────────────────────────────────

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.entries,
    required this.descType,
  });

  final String title;
  final List<CatalogEntry> entries;
  final String descType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: entries
              .map((e) => _TappableChip(entry: e, descType: descType))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _TappableChip extends ConsumerWidget {
  const _TappableChip({required this.entry, required this.descType});

  final CatalogEntry entry;
  final String descType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: Text(entry.name, style: Theme.of(context).textTheme.bodySmall),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () => _showDescription(context, ref),
    );
  }

  Future<void> _showDescription(BuildContext context, WidgetRef ref) async {
    final autoTranslateEnabled = ref.read(autoTranslateEnabledProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    String description;
    try {
      description = descType == 'trait'
          ? await ref.read(traitDescriptionProvider(entry.id).future)
          : await ref.read(featureDescriptionProvider(entry.id).future);
    } catch (_) {
      description = 'Descricao nao disponivel.';
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                autoTranslateEnabled
                    ? 'Traducao automatica do ingles quando disponivel.'
                    : 'Traducao automatica desativada. Exibindo texto original.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(description),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// ─── Spell Slots ──────────────────────────────────────────────────────────────

class _SpellSlotsSection extends StatelessWidget {
  const _SpellSlotsSection({
    required this.classInfo,
    required this.levelInfo,
    required this.character,
    required this.slotsUsed,
    required this.onSlotsChanged,
  });

  final ClassInfo classInfo;
  final ClassLevelInfo levelInfo;
  final CharacterSheet character;
  final Map<int, int> slotsUsed;
  final ValueChanged<Map<int, int>> onSlotsChanged;

  int get _spellAbilityModifier {
    switch (classInfo.spellcastingAbility) {
      case 'INT':
        return character.intelligenceModifier;
      case 'WIS':
        return character.wisdomModifier;
      case 'CHA':
        return character.charismaModifier;
      default:
        return 0;
    }
  }

  int get _spellSaveDC =>
      8 + character.proficiencyBonus + _spellAbilityModifier;
  int get _spellAttackBonus =>
      character.proficiencyBonus + _spellAbilityModifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slots = Map<int, int>.fromEntries(
      (levelInfo.spellSlotsTotal.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => a.key.compareTo(b.key))),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Magia (${classInfo.spellcastingAbility})',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                Text('DC: $_spellSaveDC'),
                const SizedBox(width: 12),
                Text('Ataque: ${_fmt(_spellAttackBonus)}'),
              ],
            ),
            if (levelInfo.cantripsKnown > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Truques conhecidos: ${levelInfo.cantripsKnown}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (slots.isNotEmpty) ...[
              const Divider(height: 16),
              ...slots.entries.map((entry) {
                final slotLevel = entry.key;
                final total = entry.value;
                final used = slotsUsed[slotLevel] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(width: 64, child: Text('Nível $slotLevel:')),
                      IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        onPressed: used <= 0
                            ? null
                            : () {
                                final updated = Map<int, int>.from(slotsUsed);
                                updated[slotLevel] = used - 1;
                                onSlotsChanged(updated);
                              },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          '$used / $total',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: used >= total
                                ? theme.colorScheme.error
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        onPressed: used >= total
                            ? null
                            : () {
                                final updated = Map<int, int>.from(slotsUsed);
                                updated[slotLevel] = used + 1;
                                onSlotsChanged(updated);
                              },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Wrap(
                          spacing: 3,
                          children: List.generate(
                            total,
                            (i) => Icon(
                              i < used ? Icons.circle : Icons.circle_outlined,
                              size: 14,
                              color: i < used
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

String _fmt(int value) {
  return value >= 0 ? '+$value' : '$value';
}
