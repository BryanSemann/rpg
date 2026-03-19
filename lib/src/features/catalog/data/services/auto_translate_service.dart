import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';
import 'package:translator/translator.dart';

class AutoTranslateService {
  AutoTranslateService({GoogleTranslator? translator})
    : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;
  final Map<String, Future<String>> _cache = <String, Future<String>>{};

  Future<String> maybeToPortuguese(String text, {required bool enabled}) {
    if (!enabled) {
      return Future<String>.value(text);
    }
    return toPortuguese(text);
  }

  Future<String> toPortuguese(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return Future<String>.value(normalized);
    }

    return _cache.putIfAbsent(normalized, () async {
      try {
        final translated = await _translator.translate(
          normalized,
          from: 'en',
          to: 'pt',
        );
        final result = translated.text.trim();
        return result.isEmpty ? normalized : result;
      } catch (_) {
        return normalized;
      }
    });
  }

  Future<List<CatalogEntry>> translateEntries(
    List<CatalogEntry> entries, {
    required bool enabled,
  }) async {
    if (!enabled) {
      return entries;
    }

    return Future.wait(
      entries.map(
        (entry) async => CatalogEntry(
          id: entry.id,
          name: await toPortuguese(entry.name),
        ),
      ),
    );
  }

  Future<CatalogDetail> translateDetail(
    CatalogDetail detail, {
    required bool enabled,
  }) async {
    if (!enabled) {
      return detail;
    }

    final translatedFacts = <String, String>{};
    for (final entry in detail.facts.entries) {
      translatedFacts[
        await toPortuguese(entry.key)
      ] = await toPortuguese(entry.value);
    }

    final translatedHighlights = await Future.wait(
      detail.highlights.map(toPortuguese),
    );

    return CatalogDetail(
      id: detail.id,
      name: await toPortuguese(detail.name),
      facts: translatedFacts,
      highlights: translatedHighlights,
    );
  }

  Future<RaceInfo> translateRaceInfo(
    RaceInfo raceInfo, {
    required bool enabled,
  }) async {
    if (!enabled) {
      return raceInfo;
    }

    return RaceInfo(
      id: raceInfo.id,
      name: await toPortuguese(raceInfo.name),
      speedFt: raceInfo.speedFt,
      size: await toPortuguese(raceInfo.size),
      abilityBonuses: raceInfo.abilityBonuses,
      traits: await translateEntries(raceInfo.traits, enabled: true),
    );
  }

  Future<ClassInfo> translateClassInfo(
    ClassInfo classInfo, {
    required bool enabled,
  }) async {
    if (!enabled) {
      return classInfo;
    }

    return ClassInfo(
      id: classInfo.id,
      name: await toPortuguese(classInfo.name),
      hitDie: classInfo.hitDie,
      savingThrows: classInfo.savingThrows,
      spellcastingAbility: classInfo.spellcastingAbility,
    );
  }

  Future<ClassLevelInfo> translateClassLevelInfo(
    ClassLevelInfo info, {
    required bool enabled,
  }) async {
    if (!enabled) {
      return info;
    }

    final translatedClassSpecific = <String, int>{};
    for (final entry in info.classSpecific.entries) {
      translatedClassSpecific[await toPortuguese(entry.key)] = entry.value;
    }

    return ClassLevelInfo(
      level: info.level,
      profBonus: info.profBonus,
      features: await translateEntries(info.features, enabled: true),
      spellSlotsTotal: info.spellSlotsTotal,
      cantripsKnown: info.cantripsKnown,
      classSpecific: translatedClassSpecific,
    );
  }
}
