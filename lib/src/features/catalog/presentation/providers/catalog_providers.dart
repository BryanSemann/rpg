import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rpg_app/src/features/catalog/data/datasources/open5e_catalog_datasource.dart';
import 'package:rpg_app/src/features/catalog/data/datasources/srd_catalog_datasource.dart';
import 'package:rpg_app/src/features/catalog/data/repositories/network_catalog_repository.dart';
import 'package:rpg_app/src/features/catalog/data/services/auto_translate_service.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';
import 'package:rpg_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:rpg_app/src/features/settings/presentation/providers/app_settings_provider.dart';

final catalogHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final srdCatalogDatasourceProvider = Provider<SrdCatalogDatasource>((ref) {
  final client = ref.watch(catalogHttpClientProvider);
  return SrdCatalogDatasource(client);
});

final open5eCatalogDatasourceProvider = Provider<Open5eCatalogDatasource>((
  ref,
) {
  final client = ref.watch(catalogHttpClientProvider);
  return Open5eCatalogDatasource(client);
});

final autoTranslateServiceProvider = Provider<AutoTranslateService>((ref) {
  return AutoTranslateService();
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final primary = ref.watch(srdCatalogDatasourceProvider);
  final fallback = ref.watch(open5eCatalogDatasourceProvider);
  return NetworkCatalogRepository(primary: primary, fallback: fallback);
});

final rawCatalogClassesProvider = FutureProvider<List<CatalogEntry>>((ref) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getClasses();
});

final rawCatalogRacesProvider = FutureProvider<List<CatalogEntry>>((ref) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getRaces();
});

final rawCatalogClassDetailProvider = FutureProvider.family<CatalogDetail, String>(
  (ref, classId) {
    final repository = ref.watch(catalogRepositoryProvider);
    return repository.getClassDetail(classId);
  },
);

final rawCatalogRaceDetailProvider = FutureProvider.family<CatalogDetail, String>((
  ref,
  raceId,
) {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getRaceDetail(raceId);
});

final rawRaceInfoProvider = FutureProvider.family<RaceInfo?, String>((
  ref,
  raceId,
) async {
  if (raceId.isEmpty) return null;
  return ref.watch(catalogRepositoryProvider).getRaceInfo(raceId);
});

final rawClassInfoProvider = FutureProvider.family<ClassInfo?, String>((
  ref,
  classId,
) async {
  if (classId.isEmpty) return null;
  return ref.watch(catalogRepositoryProvider).getClassInfo(classId);
});

final rawClassLevelInfoProvider =
    FutureProvider.family<ClassLevelInfo?, (String, int)>((ref, args) async {
      final (classId, level) = args;
      if (classId.isEmpty) return null;
      return ref
          .watch(catalogRepositoryProvider)
          .getClassLevelInfo(classId, level);
    });

final catalogClassesProvider = FutureProvider<List<CatalogEntry>>((ref) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final items = await ref.watch(rawCatalogClassesProvider.future);
  return ref
      .read(autoTranslateServiceProvider)
      .translateEntries(items, enabled: enabled);
});

final catalogRacesProvider = FutureProvider<List<CatalogEntry>>((ref) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final items = await ref.watch(rawCatalogRacesProvider.future);
  return ref
      .read(autoTranslateServiceProvider)
      .translateEntries(items, enabled: enabled);
});

final catalogClassDetailProvider = FutureProvider.family<CatalogDetail, String>(
  (ref, classId) async {
    final enabled = ref.watch(autoTranslateEnabledProvider);
    final detail = await ref.watch(rawCatalogClassDetailProvider(classId).future);
    return ref
        .read(autoTranslateServiceProvider)
        .translateDetail(detail, enabled: enabled);
  },
);

final catalogRaceDetailProvider = FutureProvider.family<CatalogDetail, String>((
  ref,
  raceId,
) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final detail = await ref.watch(rawCatalogRaceDetailProvider(raceId).future);
  return ref
      .read(autoTranslateServiceProvider)
      .translateDetail(detail, enabled: enabled);
});

final raceInfoProvider = FutureProvider.family<RaceInfo?, String>((
  ref,
  raceId,
) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final info = await ref.watch(rawRaceInfoProvider(raceId).future);
  if (info == null) return null;
  return ref
      .read(autoTranslateServiceProvider)
      .translateRaceInfo(info, enabled: enabled);
});

final classInfoProvider = FutureProvider.family<ClassInfo?, String>((
  ref,
  classId,
) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final info = await ref.watch(rawClassInfoProvider(classId).future);
  if (info == null) return null;
  return ref
      .read(autoTranslateServiceProvider)
      .translateClassInfo(info, enabled: enabled);
});

final classLevelInfoProvider =
    FutureProvider.family<ClassLevelInfo?, (String, int)>((ref, args) async {
      final enabled = ref.watch(autoTranslateEnabledProvider);
      final info = await ref.watch(rawClassLevelInfoProvider(args).future);
      if (info == null) return null;
      return ref
          .read(autoTranslateServiceProvider)
          .translateClassLevelInfo(info, enabled: enabled);
    });

final rawTraitDescriptionProvider = FutureProvider.family<String, String>((
  ref,
  traitId,
) {
  return ref.watch(catalogRepositoryProvider).getTraitDescription(traitId);
});

final rawFeatureDescriptionProvider = FutureProvider.family<String, String>((
  ref,
  featureId,
) {
  return ref.watch(catalogRepositoryProvider).getFeatureDescription(featureId);
});

final traitDescriptionProvider = FutureProvider.family<String, String>((
  ref,
  traitId,
) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final original = await ref.watch(rawTraitDescriptionProvider(traitId).future);
  return ref
      .read(autoTranslateServiceProvider)
      .maybeToPortuguese(original, enabled: enabled);
});

final featureDescriptionProvider = FutureProvider.family<String, String>((
  ref,
  featureId,
) async {
  final enabled = ref.watch(autoTranslateEnabledProvider);
  final original = await ref.watch(
    rawFeatureDescriptionProvider(featureId).future,
  );
  return ref
      .read(autoTranslateServiceProvider)
      .maybeToPortuguese(original, enabled: enabled);
});
