import 'package:equatable/equatable.dart';
import 'shot.dart';

class Scene extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final int sequenceNumber;
  final List<Shot> shots;

  const Scene({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.sequenceNumber,
    this.shots = const [],
  });

  @override
  List<Object?> get props => [id, projectId, name, description, sequenceNumber, shots];
}
