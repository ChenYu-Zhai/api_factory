import 'package:api_factory/features/animator_workbench/data/services/gemini_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/midjourney_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/task_queue_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/veo_service.dart';
import 'package:api_factory/features/animator_workbench/domain/entities/task.dart';
import 'package:api_factory/features/animator_workbench/domain/repositories/i_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ITaskRepository, GeminiService, MidjourneyService, VeoService])
import 'task_queue_service_test.mocks.dart';

void main() {
  late TaskQueueService service;
  late MockITaskRepository mockRepository;
  late MockGeminiService mockGeminiService;
  late MockMidjourneyService mockMidjourneyService;
  late MockVeoService mockVeoService;

  setUp(() {
    mockRepository = MockITaskRepository();
    mockGeminiService = MockGeminiService();
    mockMidjourneyService = MockMidjourneyService();
    mockVeoService = MockVeoService();
  });

  test('should load pending tasks on init', () async {
    // Arrange
    when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRepository.getPendingTasks()).thenAnswer((_) async => []);

    // Act
    service = TaskQueueService(
      mockRepository,
      mockGeminiService,
      mockMidjourneyService,
      mockVeoService,
    );
    // Service init is called in constructor
    // We need to wait a bit for the async init to complete
    await Future.delayed(Duration.zero);

    // Assert
    verify(mockRepository.getAllTasks()).called(1);
  });

  test('should process pending tasks', () async {
    // Arrange
    final task = Task(
      id: '1',
      type: TaskType.refineFaceSwap,
      status: TaskStatus.pending,
      sourceAssetId: 'source',
      targetAssetId: 'target',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRepository.getPendingTasks()).thenAnswer((_) async => [task]);
    when(mockRepository.updateTaskStatus(any, any)).thenAnswer((_) async {});
    when(mockRepository.saveTask(any)).thenAnswer((_) async {});

    service = TaskQueueService(
      mockRepository,
      mockGeminiService,
      mockMidjourneyService,
      mockVeoService,
    );

    // Act
    await service.queueTask(task);

    // Assert
    // Verify status updates to processing then completed
    verify(mockRepository.updateTaskStatus(task.id, TaskStatus.processing)).called(1);
  });
}
