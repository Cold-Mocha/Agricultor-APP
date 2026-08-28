import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

final class CropSeedLoader {
  CropSeedLoader(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  Future<void> seedIfEmpty() async {
    if ((await _database.select(_database.officialCrops).get()).isNotEmpty) {
      return;
    }
    final source = await _bundle.loadString('assets/data/crop_catalog_v1.json');
    final rows = (jsonDecode(source) as List<Object?>)
        .cast<Map<String, Object?>>();
    await _database.batch((batch) {
      batch.insertAll(
        _database.officialCrops,
        rows
            .map(
              (row) => OfficialCropsCompanion.insert(
                id: row['id']! as String,
                commonName: row['commonName']! as String,
                scientificName: Value(row['scientificName'] as String?),
                category: row['category']! as String,
                colorToken: row['colorToken']! as String,
                iconAsset: row['iconAsset']! as String,
              ),
            )
            .toList(growable: false),
      );
    });
  }
}
