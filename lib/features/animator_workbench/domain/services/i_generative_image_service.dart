import '../entities/asset.dart';

abstract class IGenerativeImageService {
  Future<Asset> refineImage(Asset sourceAsset, Map<String, dynamic> parameters);
  Future<Asset> generateImage(Map<String, dynamic> parameters);
}
