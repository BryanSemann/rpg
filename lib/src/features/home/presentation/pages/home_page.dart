import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';
import 'package:rpg_app/src/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:rpg_app/src/features/character/domain/entities/character_sheet.dart';
import 'package:rpg_app/src/features/character/presentation/pages/character_detail_page.dart';
import 'package:rpg_app/src/features/character/presentation/providers/character_providers.dart';
import 'package:rpg_app/src/features/settings/presentation/pages/settings_page.dart';
import 'package:rpg_app/src/shared/widgets/section_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RPG App - Fichas'),
        actions: [
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCharacterDialog(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Novo personagem'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: characterState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              SectionCard(title: 'Falha ao carregar', subtitle: 'Erro: $error'),
          data: (characters) {
            if (characters.isEmpty) {
              return const SectionCard(
                title: 'Nenhuma ficha ainda',
                subtitle:
                    'Toque em Novo personagem para criar sua primeira ficha.',
              );
            }

            return ListView.separated(
              itemCount: characters.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final character = characters[index];
                return _CharacterTile(character: character);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateCharacterDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _CreateCharacterDialog(
        onSave:
            ({
              required String name,
              required String characterClass,
              required String classId,
              required String race,
              required String raceId,
              required int hitDie,
              required int currentHp,
              required int maxHp,
              required String speed,
              required String size,
              required String alignmentHint,
            }) {
              return ref
                  .read(characterListControllerProvider.notifier)
                  .createCharacter(
                    name: name,
                    characterClass: characterClass,
                    classId: classId,
                    race: race,
                    raceId: raceId,
                    hitDie: hitDie,
                    currentHp: currentHp,
                    maxHp: maxHp,
                    speed: speed,
                    size: size,
                    alignmentHint: alignmentHint,
                  );
            },
      ),
    );
  }
}

class _CreateCharacterDialog extends ConsumerStatefulWidget {
  const _CreateCharacterDialog({required this.onSave});

  final Future<void> Function({
    required String name,
    required String characterClass,
    required String classId,
    required String race,
    required String raceId,
    required int hitDie,
    required int currentHp,
    required int maxHp,
    required String speed,
    required String size,
    required String alignmentHint,
  })
  onSave;

  @override
  ConsumerState<_CreateCharacterDialog> createState() =>
      _CreateCharacterDialogState();
}

class _CreateCharacterDialogState
    extends ConsumerState<_CreateCharacterDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _classController;
  late final TextEditingController _raceController;
  String? _selectedClassId;
  String? _selectedRaceId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _classController = TextEditingController();
    _raceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _raceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(catalogClassesProvider);
    final racesAsync = ref.watch(catalogRacesProvider);
    final rawClassesAsync = ref.watch(rawCatalogClassesProvider);
    final rawRacesAsync = ref.watch(rawCatalogRacesProvider);
    final selectedClassEntry = _resolveSelectedEntry(
      selectedId: _selectedClassId,
      items: classesAsync.valueOrNull,
    );
    final selectedRaceEntry = _resolveSelectedEntry(
      selectedId: _selectedRaceId,
      items: racesAsync.valueOrNull,
    );
    final rawSelectedClassEntry = _resolveSelectedEntry(
      selectedId: _selectedClassId,
      items: rawClassesAsync.valueOrNull,
    );
    final rawSelectedRaceEntry = _resolveSelectedEntry(
      selectedId: _selectedRaceId,
      items: rawRacesAsync.valueOrNull,
    );

    final classDetailAsync = selectedClassEntry == null
        ? null
        : ref.watch(catalogClassDetailProvider(selectedClassEntry.id));
    final raceDetailAsync = selectedRaceEntry == null
        ? null
        : ref.watch(catalogRaceDetailProvider(selectedRaceEntry.id));

    return AlertDialog(
      title: const Text('Criar personagem'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            _CatalogDropdownField(
              label: 'Classe',
              asyncItems: classesAsync,
              selectedValue: _selectedClassId,
              fallbackController: _classController,
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
            ),
            if (classDetailAsync != null) ...[
              const SizedBox(height: 8),
              _CatalogDetailCard(
                title: 'Detalhes da classe',
                asyncDetail: classDetailAsync,
              ),
            ],
            const SizedBox(height: 8),
            _CatalogDropdownField(
              label: 'Raca',
              asyncItems: racesAsync,
              selectedValue: _selectedRaceId,
              fallbackController: _raceController,
              onChanged: (value) {
                setState(() {
                  _selectedRaceId = value;
                });
              },
            ),
            if (raceDetailAsync != null) ...[
              const SizedBox(height: 8),
              _CatalogDetailCard(
                title: 'Detalhes da raca',
                asyncDetail: raceDetailAsync,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving
              ? null
              : () async {
                  final classValue =
                      rawSelectedClassEntry?.name ??
                      _classController.text;
                  final raceValue =
                      rawSelectedRaceEntry?.name ??
                      _raceController.text;
                  final classDetail = classDetailAsync?.valueOrNull;
                  final raceDetail = raceDetailAsync?.valueOrNull;
                  final hitDie = _parseHitDie(classDetail);
                  final initialMaxHp = hitDie > 0 ? hitDie : 10;
                  final navigator = Navigator.of(context);
                  setState(() => _isSaving = true);
                  await widget.onSave(
                    name: _nameController.text,
                    characterClass: classValue,
                    classId: rawSelectedClassEntry?.id ?? '',
                    race: raceValue,
                    raceId: rawSelectedRaceEntry?.id ?? '',
                    hitDie: hitDie,
                    currentHp: initialMaxHp,
                    maxHp: initialMaxHp,
                    speed: _fact(raceDetail, 'Speed'),
                    size: _fact(raceDetail, 'Size'),
                    alignmentHint: _fact(raceDetail, 'Alignment'),
                  );

                  if (!mounted) {
                    return;
                  }

                  navigator.pop();
                },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  CatalogEntry? _resolveSelectedEntry({
    required String? selectedId,
    required List<CatalogEntry>? items,
  }) {
    if (items == null || items.isEmpty) {
      return null;
    }

    if (selectedId == null || selectedId.isEmpty) {
      return items.first;
    }

    for (final item in items) {
      if (item.id == selectedId) {
        return item;
      }
    }

    return items.first;
  }

  int _parseHitDie(CatalogDetail? detail) {
    if (detail == null) {
      return 0;
    }

    final text = detail.facts['Hit Die'] ?? '';
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _fact(CatalogDetail? detail, String key) {
    return detail?.facts[key] ?? '';
  }
}

class _CatalogDropdownField extends StatelessWidget {
  const _CatalogDropdownField({
    required this.label,
    required this.asyncItems,
    required this.selectedValue,
    required this.fallbackController,
    required this.onChanged,
  });

  final String label;
  final AsyncValue<List<CatalogEntry>> asyncItems;
  final String? selectedValue;
  final TextEditingController fallbackController;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return asyncItems.when(
      loading: () => InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) => TextField(
        controller: fallbackController,
        decoration: InputDecoration(labelText: '$label (manual)'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return TextField(
            controller: fallbackController,
            decoration: InputDecoration(labelText: '$label (manual)'),
          );
        }

        final options = items
          .map((entry) => (id: entry.id, name: entry.name))
            .toList(growable: false);
        final ids = options.map((entry) => entry.id).toList(growable: false);
        final value = ids.contains(selectedValue)
            ? selectedValue
          : options.first.id;

        return DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: options
              .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.id,
              child: Text(entry.name),
            ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _CatalogDetailCard extends StatelessWidget {
  const _CatalogDetailCard({required this.title, required this.asyncDetail});

  final String title;
  final AsyncValue<CatalogDetail> asyncDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: asyncDetail.when(
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (_, __) => Text('$title: sem detalhes no momento'),
          data: (detail) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title: ${detail.name}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (detail.facts.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...detail.facts.entries
                      .take(3)
                      .map((entry) => Text('${entry.key}: ${entry.value}')),
                ],
                if (detail.highlights.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...detail.highlights
                      .take(2)
                      .map(
                        (text) => Text(
                          '- $text',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CharacterTile extends ConsumerWidget {
  const _CharacterTile({required this.character});

  final CharacterSheet character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classInfoAsync = character.classId.isEmpty
        ? const AsyncData<ClassInfo?>(null)
        : ref.watch(classInfoProvider(character.classId));
    final raceInfoAsync = character.raceId.isEmpty
        ? const AsyncData<RaceInfo?>(null)
        : ref.watch(raceInfoProvider(character.raceId));
    final className =
      classInfoAsync.valueOrNull?.name ?? character.characterClass;
    final raceName = raceInfoAsync.valueOrNull?.name ?? character.race;

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CharacterDetailPage(characterId: character.id),
            ),
          );
        },
        title: Text(character.name),
        subtitle: Text(
          '$raceName $className - Nivel ${character.level}',
        ),
        trailing: IconButton(
          tooltip: 'Excluir ficha',
          onPressed: () {
            ref
                .read(characterListControllerProvider.notifier)
                .deleteCharacter(character.id);
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}
