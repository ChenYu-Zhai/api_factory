import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/i_asset_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements IAssetRepository {
  final DatabaseHelper _dbHelper;

  AssetRepositoryImpl(this._dbHelper);

  @override
  Future<List<Asset>> getAssetsByProject(String projectId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }

  @override
  Future<Asset?> getAssetById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AssetModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> saveAsset(Asset asset) async {
    final db = await _dbHelper.database;
    final assetModel = AssetModel.fromEntity(asset);
    await db.insert(
      'assets',
      assetModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAsset(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Asset>> getAssetLineage(String assetId) async {
    final db = await _dbHelper.database;
    // This is a simplified lineage query (only direct parent)
    // For full recursive lineage, we'd need a recursive CTE or iterative approach
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM assets WHERE id = ? OR parent_id = ?
    ''', [assetId, assetId]);
    return List.generate(maps.length, (i) => AssetModel.fromMap(maps[i]));
  }
}
