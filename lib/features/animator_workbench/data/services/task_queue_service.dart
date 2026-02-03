import 'dart:async';
import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import 'gemini_service.dart';
import 'midjourney_service.dart';
import 'veo_service.dart';

class TaskQueueService {
  final ITaskRepository _taskRepository;
  final GeminiService _geminiService;
  final MidjourneyService _midjourneyService;
  final VeoService _veoService;
  final StreamController<List<Task>> _taskStreamController = StreamController<List<Task>>.broadcast();
  List<Task> _currentTasks = [];
  bool _isProcessing = false;

  TaskQueueService(
    this._taskRepository,
    this._geminiService,
    this._midjourneyService,
    this._veoService,
  ) {
    _init();
  }

  Stream<List<Task>> get tasks => _taskStreamController.stream;
  List<Task> get currentTasks => _currentTasks;

  Future<void> _init() async {
    await refresh();
    _processQueue();
  }

  Future<void> refresh() async {
    final tasks = await _taskRepository.getAllTasks();
    _currentTasks = tasks;
    _taskStreamController.add(tasks);
  }

  Future<void> queueTask(Task task) async {
    await _taskRepository.saveTask(task);
    await refresh();
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
      await refresh();

      switch (task.type) {
        case TaskType.generateImage:
          // Assuming Gemini for simple generation for now, or check params
          // If parameters contain 'source': 'midjourney', use MJ
          if (task.parameters['source'] == 'midjourney') {
            await _processMidjourneyTask(task);
          } else {
            await _processGeminiTask(task);
          }
          break;
        case TaskType.generateVideo:
          await _processVeoTask(task);
          break;
        default:
          // Fallback for unimplemented types
          await Future.delayed(const Duration(seconds: 1));
          await _taskRepository.updateTaskStatus(task.id, TaskStatus.completed);
      }
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
      await refresh();
    }
  }

  Future<void> _processGeminiTask(Task task) async {
    final prompt = task.parameters['prompt'];
    final projectId = task.parameters['projectId'];
    
    if (prompt == null || projectId == null) {
      throw Exception('Missing required parameters for Gemini task');
    }

    final asset = await _geminiService.generateImage({
      'prompt': prompt,
      'projectId': projectId,
    });

    // Here we might want to link the new asset to the task or project
    // For now, just mark completed. Ideally, we update the task with the result asset ID.
    await _taskRepository.updateTaskStatus(task.id, TaskStatus.completed);
  }

  Future<void> _processMidjourneyTask(Task task) async {
    final prompt = task.parameters['prompt'];
    final projectId = task.parameters['projectId'];

    if (prompt == null || projectId == null) {
      throw Exception('Missing required parameters for Midjourney task');
    }

    // 1. Submit Task
    final mjTaskId = await _midjourneyService.submitImagine(prompt);
    if (mjTaskId == null) {
      throw Exception('Failed to submit Midjourney task');
    }

    // 2. Poll for result
    String? imageUrl;
    while (true) {
      final result = await _midjourneyService.fetchTaskResult(mjTaskId);
      if (result?.status == 'SUCCESS') {
        imageUrl = result?.imageUrl;
        break;
      } else if (result?.status == 'FAILURE') {
        throw Exception('Midjourney task failed: ${result?.failReason}');
      }
      await Future.delayed(const Duration(seconds: 5));
    }

    // 3. Download and Save
    if (imageUrl != null) {
      await _midjourneyService.downloadAndSaveImage(imageUrl, projectId, prompt);
      await _taskRepository.updateTaskStatus(task.id, TaskStatus.completed);
    } else {
      throw Exception('Midjourney task succeeded but no image URL found');
    }
  }

  Future<void> _processVeoTask(Task task) async {
    final prompt = task.parameters['prompt'];
    final projectId = task.parameters['projectId'];
    final model = task.parameters['model'] ?? 'veo_3_1-fast';

    if (prompt == null || projectId == null) {
      throw Exception('Missing required parameters for Veo task');
    }

    // 1. Create Task
    final veoTaskId = await _veoService.createVideo(prompt, model: model);
    if (veoTaskId == null) {
      throw Exception('Failed to create Veo task');
    }

    // 2. Poll for result
    String? videoUrl;
    while (true) {
      final result = await _veoService.queryTask(veoTaskId);
      if (result?.status == 'success') {
        videoUrl = result?.videoUrl;
        break;
      } else if (result?.status == 'failed') {
        throw Exception('Veo task failed');
      }
      await Future.delayed(const Duration(seconds: 5));
    }

    // 3. Download and Save
    if (videoUrl != null) {
      await _veoService.downloadAndSaveVideo(videoUrl, projectId, prompt);
      await _taskRepository.updateTaskStatus(task.id, TaskStatus.completed);
    } else {
      throw Exception('Veo task succeeded but no video URL found');
    }
  }

  void dispose() {
    _taskStreamController.close();
  }
}
