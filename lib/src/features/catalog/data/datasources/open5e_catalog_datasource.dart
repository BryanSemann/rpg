import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_detail.dart';
import 'package:rpg_app/src/features/catalog/domain/entities/catalog_entry.dart';

class Open5eCatalogDatasource {
  Open5eCatalogDatasource(this._client);

  final http.Client _client;
  static const String _baseUrl = 'https://api.open5e.com/v1';

  Future<List<CatalogEntry>> getClasses() {
    return _getSimpleList('/classes/');
  }

  Future<List<CatalogEntry>> getRaces() {
    return _getSimpleList('/races/');
  }

  Future<CatalogDetail> getClassDetail(String id) async {
    final body = await _getDetail('/classes/$id/');
    return _mapDetail(body, fallbackId: id);
  }

  Future<CatalogDetail> getRaceDetail(String id) async {
    final body = await _getDetail('/races/$id/');
    return _mapDetail(body, fallbackId: id);
  }

  Future<List<CatalogEntry>> _getSimpleList(String path) async {
    final body = await _getDetail(path);
    final rawResults = body['results'] as List<dynamic>?;
    if (rawResults == null) {
      throw Exception('Open5e API response did not contain results');
    }

    return rawResults
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final id = (item['slug'] ?? item['index'] ?? item['name'] ?? '')
              .toString();
          final name = (item['name'] ?? '').toString();
          return CatalogEntry(id: id, name: name);
        })
        .where((entry) => entry.id.isNotEmpty && entry.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getDetail(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Open5e API request failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  CatalogDetail _mapDetail(
    Map<String, dynamic> body, {
    required String fallbackId,
  }) {
    final name = (body['name'] ?? fallbackId).toString();
    final id = (body['slug'] ?? body['index'] ?? fallbackId).toString();

    final facts = <String, String>{};
    _tryPutFact(facts, 'Hit Die', body['hit_dice']);
    _tryPutFact(facts, 'HP Lvl 1', body['hp_at_1st_level']);
    _tryPutFact(facts, 'Speed', body['speed']);
    _tryPutFact(facts, 'Size', body['size']);
    _tryPutFact(facts, 'Alignment', body['alignment']);

    final highlights = <String>[];
    final desc = body['desc'];
    if (desc is List<dynamic>) {
      for (final line in desc.take(3)) {
        final text = line.toString().trim();
        if (text.isNotEmpty) {
          highlights.add(text);
        }
      }
    } else if (desc is String && desc.trim().isNotEmpty) {
      highlights.add(desc.trim());
    }

    return CatalogDetail(
      id: id,
      name: name,
      facts: facts,
      highlights: highlights,
    );
  }

  void _tryPutFact(Map<String, String> facts, String key, dynamic value) {
    if (value == null) {
      return;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      facts[key] = text;
    }
  }
}
