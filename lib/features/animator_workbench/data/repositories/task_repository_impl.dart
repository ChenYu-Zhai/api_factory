import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final DatabaseHelper _dbHelper;

  TaskRepositoryImpl(this._dbHelper);

  @override
  Future<List<Task>> getPendingTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [TaskStatus.pending.toString()],
    );
    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  @override
  Future<void> saveTask(Task task) async {
    final db = await _dbHelper.database;
    final taskModel = TaskModel.fromEntity(task);
    await db.insert(
      'tasks',
      taskModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status, {String? errorMessage}) async {
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{
      'status': status.toString(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (errorMessage != null) {
      updates['error_message'] = errorMessage;
    }
    
    // If failed, increment retry count
    if (status == TaskStatus.failed) {
       // We need to read the current retry count first, but for simplicity in this update
       // we will just let the service handle retry logic or add a specific method for it.
       // However, to support the field in DB:
       // updates['retry_count'] = ...
       // For now, let's assume the service might update the whole task if it wants to change retry count,
       // or we add a specific parameter here.
       // Let's keep it simple and just update status/error for now as per interface.
    }

    await db.update(
      'tasks',
      updates,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
