import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final String rootPath;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.rootPath,
  });

  @override
  List<Object?> get props => [id, name, createdAt, rootPath];
}
