import 'dart:convert';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.type,
    required super.status,
    required super.sourceAssetId,
    required super.targetAssetId,
    super.parameters,
    super.errorMessage,
    super.progress,
    super.retryCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      type: TaskType.values.firstWhere((e) => e.toString() == map['type']),
      status: TaskStatus.values.firstWhere((e) => e.toString() == map['status']),
      sourceAssetId: map['source_asset_id'],
      targetAssetId: map['target_asset_id'],
      parameters: map['parameters'] != null ? jsonDecode(map['parameters']) : {},
      errorMessage: map['error_message'],
      progress: map['progress'] ?? 0.0,
      retryCount: map['retry_count'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'status': status.toString(),
      'source_asset_id': sourceAssetId,
      'target_asset_id': targetAssetId,
      'parameters': jsonEncode(parameters),
      'error_message': errorMessage,
      'progress': progress,
      'retry_count': retryCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      type: task.type,
      status: task.status,
      sourceAssetId: task.sourceAssetId,
      targetAssetId: task.targetAssetId,
      parameters: task.parameters,
      errorMessage: task.errorMessage,
      progress: task.progress,
      retryCount: task.retryCount,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }
}
