import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/task_queue_service.dart';
import '../../domain/entities/task.dart';
import 'dependency_injection.dart';

final taskQueueServiceProvider = Provider<TaskQueueService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final geminiService = ref.watch(geminiServiceProvider);
  final midjourneyService = ref.watch(midjourneyServiceProvider);
  final veoService = ref.watch(veoServiceProvider);
  return TaskQueueService(
    taskRepository,
    geminiService,
    midjourneyService,
    veoService,
  );
});

final taskListProvider = StreamProvider<List<Task>>((ref) {
  final taskQueueService = ref.watch(taskQueueServiceProvider);
  return taskQueueService.tasks;
});
