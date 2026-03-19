import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';

/// Full race data fetched from the catalog API.
class RaceInfo {
  const RaceInfo({
    required this.id,
    required this.name,
    required this.speedFt,
    required this.size,
    required this.abilityBonuses,
    required this.traits,
  });

  final String id;
  final String name;

  /// Base movement speed in feet (e.g. 30 for Elf).
  final int speedFt;

  /// Size category: 'Medium', 'Small', etc.
  final String size;

  /// Racial ability score bonuses, e.g. {'DEX': 2}.
  final Map<String, int> abilityBonuses;

  /// Racial traits with id and name for detail fetching.
  final List<CatalogEntry> traits;
}
