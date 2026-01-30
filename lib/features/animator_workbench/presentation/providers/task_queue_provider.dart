import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../data/services/task_queue_service.dart';
import 'dependency_injection.dart';

final taskQueueServiceProvider = Provider<TaskQueueService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskQueueService(taskRepository);
});

final taskListProvider = StreamProvider<List<Task>>((ref) {
  final taskQueueService = ref.watch(taskQueueServiceProvider);
  return taskQueueService.tasks;
});
