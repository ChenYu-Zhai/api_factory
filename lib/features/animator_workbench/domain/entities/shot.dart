import 'package:equatable/equatable.dart';

class Shot extends Equatable {
  final String id;
  final String sceneId;
  final String name;
  final String description;
  final int sequenceNumber;

  const Shot({
    required this.id,
    required this.sceneId,
    required this.name,
    required this.description,
    required this.sequenceNumber,
  });

  @override
  List<Object?> get props => [id, sceneId, name, description, sequenceNumber];
}
