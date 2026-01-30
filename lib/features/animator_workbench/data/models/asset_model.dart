import 'dart:convert';
import '../../domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.projectId,
    super.parentId,
    required super.type,
    required super.filePath,
    super.metadata,
    super.pipelineInfo,
    super.isMasterReference,
    required super.createdAt,
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'],
      projectId: map['project_id'],
      parentId: map['parent_id'],
      type: AssetType.values.firstWhere((e) => e.toString() == map['type']),
      filePath: map['file_path'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : {},
      pipelineInfo: map['pipeline_info'] != null ? jsonDecode(map['pipeline_info']) : {},
      isMasterReference: map['is_master_reference'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'parent_id': parentId,
      'type': type.toString(),
      'file_path': filePath,
      'metadata': jsonEncode(metadata),
      'pipeline_info': jsonEncode(pipelineInfo),
      'is_master_reference': isMasterReference ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AssetModel.fromEntity(Asset asset) {
    return AssetModel(
      id: asset.id,
      projectId: asset.projectId,
      parentId: asset.parentId,
      type: asset.type,
      filePath: asset.filePath,
      metadata: asset.metadata,
      pipelineInfo: asset.pipelineInfo,
      isMasterReference: asset.isMasterReference,
      createdAt: asset.createdAt,
    );
  }
}
