import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/class_level_info.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/race_info.dart';

abstract class CatalogRepository {
  Future<List<CatalogEntry>> getClasses();
  Future<List<CatalogEntry>> getRaces();
  Future<CatalogDetail> getClassDetail(String id);
  Future<CatalogDetail> getRaceDetail(String id);
  Future<RaceInfo> getRaceInfo(String id);
  Future<ClassInfo> getClassInfo(String id);
  Future<ClassLevelInfo> getClassLevelInfo(String classId, int level);
  Future<String> getTraitDescription(String traitId);
  Future<String> getFeatureDescription(String featureId);
}
