import 'package:equatable/equatable.dart';

enum TaskType { refineFaceSwap, refineInpainting, convert, generateVideo, generateImage }
enum TaskStatus { pending, processing, completed, failed }

class Task extends Equatable {
  final String id;
  final TaskType type;
  final TaskStatus status;
  final String sourceAssetId;
  final String targetAssetId;
  final Map<String, dynamic> parameters;
  final String? errorMessage;
  final double progress;
  final int retryCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.type,
    required this.status,
    required this.sourceAssetId,
    required this.targetAssetId,
    this.parameters = const {},
    this.errorMessage,
    this.progress = 0.0,
    this.retryCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        sourceAssetId,
        targetAssetId,
        parameters,
        errorMessage,
        progress,
        retryCount,
        createdAt,
        updatedAt,
      ];
}
