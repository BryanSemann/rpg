import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';

/// Class data for a specific level, fetched from the catalog API.
class ClassLevelInfo {
  const ClassLevelInfo({
    required this.level,
    required this.profBonus,
    required this.features,
    required this.spellSlotsTotal,
    required this.cantripsKnown,
    required this.classSpecific,
  });

  final int level;
  final int profBonus;

  /// Features unlocked at this level (id + name for detail fetching).
  final List<CatalogEntry> features;

  /// Spell slot totals by spell level (1–9). Empty map for non-casters.
  final Map<int, int> spellSlotsTotal;

  final int cantripsKnown;

  /// Class-specific numeric stats at this level, e.g. {'rage_count': 3, 'ki_points': 5}.
  final Map<String, int> classSpecific;
}
