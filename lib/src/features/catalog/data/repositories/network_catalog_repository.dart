import 'package:rpg_app/src/features/catalog/data/datasources/open5e_catalog_datasource.dart';
import 'package:rpg_app/src/features/catalog/data/datasources/srd_catalog_datasource.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';
import 'package:rpg_app/src/features/catalog/domain/repositories/catalog_repository.dart';

class NetworkCatalogRepository implements CatalogRepository {
  NetworkCatalogRepository({
    required SrdCatalogDatasource primary,
    required Open5eCatalogDatasource fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final SrdCatalogDatasource _primary;
  final Open5eCatalogDatasource _fallback;

  @override
  Future<List<CatalogEntry>> getClasses() {
    return _runWithFallback(
      primaryCall: _primary.getClasses,
      fallbackCall: _fallback.getClasses,
    );
  }

  @override
  Future<List<CatalogEntry>> getRaces() {
    return _runWithFallback(
      primaryCall: _primary.getRaces,
      fallbackCall: _fallback.getRaces,
    );
  }

  @override
  Future<CatalogDetail> getClassDetail(String id) {
    return _runDetailWithFallback(
      primaryCall: () => _primary.getClassDetail(id),
      fallbackCall: () => _fallback.getClassDetail(id),
    );
  }

  @override
  Future<CatalogDetail> getRaceDetail(String id) {
    return _runDetailWithFallback(
      primaryCall: () => _primary.getRaceDetail(id),
      fallbackCall: () => _fallback.getRaceDetail(id),
    );
  }

  @override
  Future<RaceInfo> getRaceInfo(String id) => _primary.getRaceInfo(id);

  @override
  Future<ClassInfo> getClassInfo(String id) => _primary.getClassInfo(id);

  @override
  Future<ClassLevelInfo> getClassLevelInfo(String classId, int level) =>
      _primary.getClassLevelInfo(classId, level);

  @override
  Future<String> getTraitDescription(String traitId) =>
      _primary.getTraitDescription(traitId);

  @override
  Future<String> getFeatureDescription(String featureId) =>
      _primary.getFeatureDescription(featureId);

  Future<List<CatalogEntry>> _runWithFallback({
    required Future<List<CatalogEntry>> Function() primaryCall,
    required Future<List<CatalogEntry>> Function() fallbackCall,
  }) async {
    try {
      final primary = await primaryCall();
      if (primary.isNotEmpty) {
        return primary;
      }
    } catch (_) {
      // Uses fallback source when primary is unavailable.
    }

    return fallbackCall();
  }

  Future<CatalogDetail> _runDetailWithFallback({
    required Future<CatalogDetail> Function() primaryCall,
    required Future<CatalogDetail> Function() fallbackCall,
  }) async {
    try {
      return await primaryCall();
    } catch (_) {
      return fallbackCall();
    }
  }
}
