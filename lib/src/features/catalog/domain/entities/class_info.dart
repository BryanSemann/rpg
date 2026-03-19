/// Core class data fetched from the catalog API.
class ClassInfo {
  const ClassInfo({
    required this.id,
    required this.name,
    required this.hitDie,
    required this.savingThrows,
    this.spellcastingAbility,
  });

  final String id;
  final String name;

  /// e.g. 12 for Barbarian, 6 for Wizard.
  final int hitDie;

  /// Ability codes the class is proficient in for saving throws, e.g. ['STR', 'CON'].
  final List<String> savingThrows;

  /// 'INT', 'WIS', or 'CHA' for spellcasting classes; null for non-casters.
  final String? spellcastingAbility;

  bool get isSpellcaster => spellcastingAbility != null;
}
