import 'package:equatable/equatable.dart';

enum AssetType { imageBase, imageRefined, video }

class Asset extends Equatable {
  final String id;
  final String projectId;
  final String? parentId;
  final AssetType type;
  final String filePath;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> pipelineInfo;
  final bool isMasterReference;
  final DateTime createdAt;

  const Asset({
    required this.id,
    required this.projectId,
    this.parentId,
    required this.type,
    required this.filePath,
    this.metadata = const {},
    this.pipelineInfo = const {},
    this.isMasterReference = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        parentId,
        type,
        filePath,
        metadata,
        pipelineInfo,
        isMasterReference,
        createdAt,
      ];
}
