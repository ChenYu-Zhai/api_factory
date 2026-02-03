import 'package:api_factory/features/animator_workbench/data/services/gemini_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/midjourney_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/task_queue_service.dart';
import 'package:api_factory/features/animator_workbench/data/services/veo_service.dart';
import 'package:api_factory/features/animator_workbench/domain/entities/task.dart';
import 'package:api_factory/features/animator_workbench/domain/repositories/i_task_repository.dart';
import 'package:api_factory/features/animator_workbench/presentation/pages/api_verification_page.dart';
import 'package:api_factory/features/animator_workbench/presentation/providers/dependency_injection.dart';
import 'package:api_factory/features/animator_workbench/presentation/providers/task_queue_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../task_queue_service_test.mocks.dart';

void main() {
  late MockITaskRepository mockRepository;
  late MockGeminiService mockGeminiService;
  late MockMidjourneyService mockMidjourneyService;
  late MockVeoService mockVeoService;
  late TaskQueueService taskQueueService;

  setUp(() {
    mockRepository = MockITaskRepository();
    mockGeminiService = MockGeminiService();
    mockMidjourneyService = MockMidjourneyService();
    mockVeoService = MockVeoService();

    // Setup default stubs
    when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRepository.getPendingTasks()).thenAnswer((_) async => []);
    when(mockRepository.saveTask(any)).thenAnswer((_) async {});
    when(mockRepository.updateTaskStatus(any, any)).thenAnswer((_) async {});
    
    taskQueueService = TaskQueueService(
      mockRepository,
      mockGeminiService,
      mockMidjourneyService,
      mockVeoService,
    );
  });

  testWidgets('ApiVerificationPage shows empty state initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskQueueServiceProvider.overrideWithValue(taskQueueService),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ApiVerificationPage()),
        ),
      ),
    );

    // Allow the async _init to complete and stream to emit
    // We trigger a refresh to ensure the stream emits a value after the widget has subscribed
    await taskQueueService.refresh();
    await tester.pumpAndSettle();

    expect(find.text('No tasks queued'), findsOneWidget);
  });

  testWidgets('Tapping Test Gemini button adds a task', (WidgetTester tester) async {
    // Arrange
    final task = Task(
      id: '123',
      type: TaskType.generateImage,
      status: TaskStatus.pending,
      sourceAssetId: '',
      targetAssetId: '',
      parameters: {'source': 'gemini'},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // When saveTask is called, we want to simulate the repository updating the list
    // Since TaskQueueService calls getAllTasks after saveTask, we need to update what getAllTasks returns
    when(mockRepository.saveTask(any)).thenAnswer((invocation) async {
      // After save, next getAllTasks should return the task
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [task]);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskQueueServiceProvider.overrideWithValue(taskQueueService),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ApiVerificationPage()),
        ),
      ),
    );
    // Ensure initial state is loaded
    await taskQueueService.refresh();
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.text('Test Gemini'));
    await tester.pump(); // Trigger tap
    
    // We need to wait for the async operations in TaskQueueService to complete and the stream to update
    // queueTask -> saveTask -> refreshTasks -> stream update
    await tester.pumpAndSettle();

    // Assert
    // verify(mockRepository.saveTask(any)).called(1); // This might be hard to verify exact call count due to async nature in widget test sometimes, but let's try checking UI
    
    // Since we mocked getAllTasks to return the task after save, the UI should update
    
    expect(find.text('generateImage (gemini)'), findsOneWidget);
    expect(find.text('Status: pending'), findsOneWidget);
  });
}
