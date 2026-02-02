import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> getPendingTasks();
  Future<List<Task>> getAllTasks();
  Future<void> saveTask(Task task);
  Future<void> updateTaskStatus(String taskId, TaskStatus status, {String? errorMessage});
  Future<void> deleteTask(String id);
}
