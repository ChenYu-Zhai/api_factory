import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:api_factory/features/animator_workbench/domain/entities/asset.dart';
import 'package:api_factory/features/animator_workbench/domain/services/i_generative_image_service.dart';

class MockGenerativeImageService implements IGenerativeImageService {
  @override
  Future<Asset> refineImage(Asset sourceAsset, Map<String, dynamic> parameters) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    return Asset(
      id: const Uuid().v4(),
      projectId: sourceAsset.projectId,
      parentId: sourceAsset.id,
      type: AssetType.imageRefined,
      filePath: '/mock/path/refined_${DateTime.now().millisecondsSinceEpoch}.png',
      metadata: const {'width': 1024, 'height': 1024},
      pipelineInfo: parameters,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Asset> generateImage(Map<String, dynamic> parameters) async {
    await Future.delayed(const Duration(seconds: 3));

    return Asset(
      id: const Uuid().v4(),
      projectId: 'mock_project_id', // In real app, this would come from context
      type: AssetType.imageBase,
      filePath: '/mock/path/generated_${DateTime.now().millisecondsSinceEpoch}.png',
      metadata: const {'width': 1024, 'height': 1024},
      pipelineInfo: parameters,
      createdAt: DateTime.now(),
    );
  }
}
