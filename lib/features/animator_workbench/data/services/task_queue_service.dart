import 'dart:async';
import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';

class TaskQueueService {
  final ITaskRepository _taskRepository;
  final StreamController<List<Task>> _taskStreamController = StreamController<List<Task>>.broadcast();
  bool _isProcessing = false;

  TaskQueueService(this._taskRepository) {
    _init();
  }

  Stream<List<Task>> get tasks => _taskStreamController.stream;

  Future<void> _init() async {
    await _refreshTasks();
    _processQueue();
  }

  Future<void> _refreshTasks() async {
    final tasks = await _taskRepository.getAllTasks();
    _taskStreamController.add(tasks);
  }

  Future<void> queueTask(Task task) async {
    await _taskRepository.saveTask(task);
    await _refreshTasks();
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final pendingTasks = await _taskRepository.getPendingTasks();
      for (final task in pendingTasks) {
        await _processTask(task);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processTask(Task task) async {
    try {
      await _taskRepository.updateTaskStatus(task.id, TaskStatus.processing);
      await _refreshTasks();

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual task processing logic here based on task.type
      // For now, we just mark it as completed

      await _taskRepository.updateTaskStatus(task.id, TaskStatus.completed);
    } catch (e) {
      if (task.retryCount < 3) {
        // Retry logic: increment retry count and keep pending (or move to pending)
        // Note: We need to update the task object with new retry count and save it
        // For simplicity in this MVP, we just mark failed.
        // To implement retry properly:
        // final updatedTask = task.copyWith(retryCount: task.retryCount + 1, status: TaskStatus.pending);
        // await _taskRepository.saveTask(updatedTask);
      }
      await _taskRepository.updateTaskStatus(task.id, TaskStatus.failed, errorMessage: e.toString());
    } finally {
      await _refreshTasks();
    }
  }

  void dispose() {
    _taskStreamController.close();
  }
}
