import '../entities/asset.dart';

abstract class IAssetRepository {
  Future<List<Asset>> getAssetsByProject(String projectId);
  Future<Asset?> getAssetById(String id);
  Future<void> saveAsset(Asset asset);
  Future<void> deleteAsset(String id);
  Future<List<Asset>> getAssetLineage(String assetId);
}
