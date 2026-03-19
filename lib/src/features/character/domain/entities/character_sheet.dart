class CharacterSheet {
  static const List<String> abilities = <String>[
    'STR',
    'DEX',
    'CON',
    'INT',
    'WIS',
    'CHA',
  ];

  static const Map<String, String> skillAbilityMap = <String, String>{
    'Acrobatics': 'DEX',
    'Animal Handling': 'WIS',
    'Arcana': 'INT',
    'Athletics': 'STR',
    'Deception': 'CHA',
    'History': 'INT',
    'Insight': 'WIS',
    'Intimidation': 'CHA',
    'Investigation': 'INT',
    'Medicine': 'WIS',
    'Nature': 'INT',
    'Perception': 'WIS',
    'Performance': 'CHA',
    'Persuasion': 'CHA',
    'Religion': 'INT',
    'Sleight of Hand': 'DEX',
    'Stealth': 'DEX',
    'Survival': 'WIS',
  };

  const CharacterSheet({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.classId,
    required this.race,
    required this.raceId,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.hitDie,
    required this.currentHp,
    required this.maxHp,
    required this.speed,
    required this.size,
    required this.alignmentHint,
    required this.notes,
    required this.savingThrowProficiencies,
    required this.skillProficiencies,
    required this.createdAt,
    required this.updatedAt,
    this.tempHp = 0,
    this.armorClass = 10,
    this.spellSlotsUsed = const <int, int>{},
  });

  final String id;
  final String name;
  final String characterClass;
  final String classId;
  final String race;
  final String raceId;
  final int level;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int hitDie;
  final int currentHp;
  final int maxHp;
  final String speed;
  final String size;
  final String alignmentHint;
  final String notes;
  final Set<String> savingThrowProficiencies;
  final Set<String> skillProficiencies;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Temporary hit points (not added to maxHp).
  final int tempHp;

  /// Armor class.
  final int armorClass;

  /// Spell slots consumed this session, keyed by spell level (1–9).
  final Map<int, int> spellSlotsUsed;

  int get proficiencyBonus {
    final safeLevel = level < 1 ? 1 : level;
    return 2 + ((safeLevel - 1) ~/ 4);
  }

  int abilityModifier(int score) {
    return ((score - 10) / 2).floor();
  }

  int get strengthModifier => abilityModifier(strength);
  int get dexterityModifier => abilityModifier(dexterity);
  int get constitutionModifier => abilityModifier(constitution);
  int get intelligenceModifier => abilityModifier(intelligence);
  int get wisdomModifier => abilityModifier(wisdom);
  int get charismaModifier => abilityModifier(charisma);

  int abilityModifierByCode(String code) {
    switch (code) {
      case 'STR':
        return strengthModifier;
      case 'DEX':
        return dexterityModifier;
      case 'CON':
        return constitutionModifier;
      case 'INT':
        return intelligenceModifier;
      case 'WIS':
        return wisdomModifier;
      case 'CHA':
        return charismaModifier;
      default:
        return 0;
    }
  }

  int savingThrowTotal(String abilityCode) {
    final base = abilityModifierByCode(abilityCode);
    final prof = savingThrowProficiencies.contains(abilityCode)
        ? proficiencyBonus
        : 0;
    return base + prof;
  }

  int skillTotal(String skillName) {
    final ability = skillAbilityMap[skillName];
    if (ability == null) {
      return 0;
    }

    final base = abilityModifierByCode(ability);
    final prof = skillProficiencies.contains(skillName) ? proficiencyBonus : 0;
    return base + prof;
  }

  CharacterSheet copyWith({
    String? name,
    String? characterClass,
    String? classId,
    String? race,
    String? raceId,
    int? level,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    int? hitDie,
    int? currentHp,
    int? maxHp,
    int? tempHp,
    int? armorClass,
    Map<int, int>? spellSlotsUsed,
    String? speed,
    String? size,
    String? alignmentHint,
    String? notes,
    Set<String>? savingThrowProficiencies,
    Set<String>? skillProficiencies,
    DateTime? updatedAt,
  }) {
    return CharacterSheet(
      id: id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      classId: classId ?? this.classId,
      race: race ?? this.race,
      raceId: raceId ?? this.raceId,
      level: level ?? this.level,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      hitDie: hitDie ?? this.hitDie,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      tempHp: tempHp ?? this.tempHp,
      armorClass: armorClass ?? this.armorClass,
      spellSlotsUsed: spellSlotsUsed ?? this.spellSlotsUsed,
      speed: speed ?? this.speed,
      size: size ?? this.size,
      alignmentHint: alignmentHint ?? this.alignmentHint,
      notes: notes ?? this.notes,
      savingThrowProficiencies:
          savingThrowProficiencies ?? this.savingThrowProficiencies,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
