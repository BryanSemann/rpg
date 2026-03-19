import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';

class SrdCatalogDatasource {
  SrdCatalogDatasource(this._client);

  final http.Client _client;
  static const String _baseUrl = 'https://www.dnd5eapi.co/api';

  Future<List<CatalogEntry>> getClasses() {
    return _getSimpleList('/classes');
  }

  Future<List<CatalogEntry>> getRaces() {
    return _getSimpleList('/races');
  }

  Future<CatalogDetail> getClassDetail(String id) async {
    final body = await _getDetail('/classes/$id');

    final hitDie = body['hit_die']?.toString();
    final savingThrows = _extractNames(body['saving_throws']);
    final proficiencies = _extractNames(body['proficiencies']);

    final facts = <String, String>{
      if (hitDie != null && hitDie.isNotEmpty) 'Hit Die': 'd$hitDie',
      if (savingThrows.isNotEmpty) 'Saving Throws': savingThrows.join(', '),
      if (proficiencies.isNotEmpty)
        'Proficiencies': '${proficiencies.length} listadas',
    };

    final highlights = <String>[
      ...savingThrows.take(3).map((s) => 'Saving Throw: $s'),
      ...proficiencies.take(3).map((p) => 'Proficiency: $p'),
    ];

    return CatalogDetail(
      id: (body['index'] ?? id).toString(),
      name: (body['name'] ?? id).toString(),
      facts: facts,
      highlights: highlights,
    );
  }

  Future<CatalogDetail> getRaceDetail(String id) async {
    final body = await _getDetail('/races/$id');

    final speed = body['speed']?.toString();
    final size = body['size']?.toString();
    final alignment = body['alignment']?.toString();
    final languageDesc = body['language_desc']?.toString();
    final abilityBonuses = _extractNames(body['ability_bonuses']);

    final facts = <String, String>{
      if (size != null && size.isNotEmpty) 'Size': size,
      if (speed != null && speed.isNotEmpty) 'Speed': speed,
      if (alignment != null && alignment.isNotEmpty) 'Alignment': alignment,
      if (languageDesc != null && languageDesc.isNotEmpty)
        'Languages': languageDesc,
    };

    final highlights = <String>[
      ...abilityBonuses.take(4).map((b) => 'Ability Bonus: $b'),
    ];

    return CatalogDetail(
      id: (body['index'] ?? id).toString(),
      name: (body['name'] ?? id).toString(),
      facts: facts,
      highlights: highlights,
    );
  }

  Future<RaceInfo> getRaceInfo(String id) async {
    final body = await _getDetail('/races/$id');

    final speedRaw = body['speed'];
    final speedFt = speedRaw is int
        ? speedRaw
        : int.tryParse(speedRaw?.toString() ?? '') ?? 30;
    final size = (body['size'] ?? 'Medium').toString();

    final abilityBonuses = <String, int>{};
    final rawBonuses = body['ability_bonuses'];
    if (rawBonuses is List) {
      for (final item in rawBonuses.whereType<Map<String, dynamic>>()) {
        final score = item['ability_score'];
        if (score is Map<String, dynamic>) {
          final name = (score['name'] ?? '').toString();
          final bonus = item['bonus'];
          if (name.isNotEmpty && bonus is int) {
            abilityBonuses[name] = bonus;
          }
        }
      }
    }

    return RaceInfo(
      id: (body['index'] ?? id).toString(),
      name: (body['name'] ?? id).toString(),
      speedFt: speedFt,
      size: size,
      abilityBonuses: abilityBonuses,
      traits: _extractEntries(body['traits']),
    );
  }

  Future<ClassInfo> getClassInfo(String id) async {
    final body = await _getDetail('/classes/$id');

    final hitDie = body['hit_die'] is int ? body['hit_die'] as int : 8;
    final savingThrows = _extractNames(body['saving_throws']);

    String? spellcastingAbility;
    final sc = body['spellcasting'];
    if (sc is Map<String, dynamic>) {
      final ability = sc['spellcasting_ability'];
      if (ability is Map<String, dynamic>) {
        final name = (ability['name'] ?? '').toString();
        if (name.isNotEmpty) spellcastingAbility = name;
      }
    }

    return ClassInfo(
      id: (body['index'] ?? id).toString(),
      name: (body['name'] ?? id).toString(),
      hitDie: hitDie,
      savingThrows: savingThrows,
      spellcastingAbility: spellcastingAbility,
    );
  }

  Future<ClassLevelInfo> getClassLevelInfo(String classId, int level) async {
    final body = await _getDetail('/classes/$classId/levels/$level');

    final profBonus = body['prof_bonus'] is int ? body['prof_bonus'] as int : 2;
    final features = _extractEntries(body['features']);

    final spellSlotsTotal = <int, int>{};
    var cantripsKnown = 0;
    final sc = body['spellcasting'];
    if (sc is Map<String, dynamic>) {
      cantripsKnown = sc['cantrips_known'] is int
          ? sc['cantrips_known'] as int
          : 0;
      for (var slotLevel = 1; slotLevel <= 9; slotLevel++) {
        final count = sc['spell_slots_level_$slotLevel'];
        if (count is int && count > 0) {
          spellSlotsTotal[slotLevel] = count;
        }
      }
    }

    final classSpecific = <String, int>{};
    final cs = body['class_specific'];
    if (cs is Map<String, dynamic>) {
      cs.forEach((key, value) {
        if (value is int) classSpecific[key] = value;
      });
    }

    return ClassLevelInfo(
      level: level,
      profBonus: profBonus,
      features: features,
      spellSlotsTotal: spellSlotsTotal,
      cantripsKnown: cantripsKnown,
      classSpecific: classSpecific,
    );
  }

  Future<String> getTraitDescription(String traitId) async {
    final body = await _getDetail('/traits/$traitId');
    return _extractDesc(body);
  }

  Future<String> getFeatureDescription(String featureId) async {
    final body = await _getDetail('/features/$featureId');
    return _extractDesc(body);
  }

  String _extractDesc(Map<String, dynamic> body) {
    final desc = body['desc'];
    if (desc is List && desc.isNotEmpty) {
      return desc.whereType<String>().join('\n\n');
    }
    return 'Descrição não disponível.';
  }

  Future<List<CatalogEntry>> _getSimpleList(String path) async {
    final body = await _getDetail(path);
    final rawResults = body['results'] as List<dynamic>?;
    if (rawResults == null) {
      throw Exception('SRD API response did not contain results');
    }

    return rawResults
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CatalogEntry(
            id: (item['index'] ?? item['url'] ?? '').toString(),
            name: (item['name'] ?? '').toString(),
          ),
        )
        .where((entry) => entry.id.isNotEmpty && entry.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getDetail(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('SRD API request failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<CatalogEntry> _extractEntries(dynamic value) {
    if (value is! List<dynamic>) return const <CatalogEntry>[];
    final result = <CatalogEntry>[];
    for (final item in value.whereType<Map<String, dynamic>>()) {
      final id = (item['index'] ?? '').toString();
      final name = (item['name'] ?? '').toString();
      if (id.isNotEmpty && name.isNotEmpty) {
        result.add(CatalogEntry(id: id, name: name));
      }
    }
    return result;
  }

  List<String> _extractNames(dynamic value) {
    if (value is! List<dynamic>) {
      return const <String>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((entry) => (entry['name'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }
}
