import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:api_factory/features/animator_workbench/domain/entities/task.dart';
import 'package:api_factory/features/animator_workbench/presentation/providers/task_queue_provider.dart';
import 'package:uuid/uuid.dart';

class ApiVerificationPage extends ConsumerWidget {
  const ApiVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskQueueService = ref.watch(taskQueueServiceProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API Verification')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final task = Task(
                      id: const Uuid().v4(),
                      type: TaskType.generateImage,
                      status: TaskStatus.pending,
                      sourceAssetId: '',
                      targetAssetId: '',
                      parameters: {
                        'prompt': 'A cute robot artist painting a landscape, digital art',
                        'projectId': 'demo_project_1',
                        'source': 'gemini',
                      },
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    taskQueueService.queueTask(task);
                  },
                  child: const Text('Test Gemini'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final task = Task(
                      id: const Uuid().v4(),
                      type: TaskType.generateImage,
                      status: TaskStatus.pending,
                      sourceAssetId: '',
                      targetAssetId: '',
                      parameters: {
                        'prompt': 'A futuristic city floating in the sky, cyberpunk style --ar 16:9',
                        'projectId': 'demo_project_1',
                        'source': 'midjourney',
                      },
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    taskQueueService.queueTask(task);
                  },
                  child: const Text('Test Midjourney'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final task = Task(
                      id: const Uuid().v4(),
                      type: TaskType.generateVideo,
                      status: TaskStatus.pending,
                      sourceAssetId: '',
                      targetAssetId: '',
                      parameters: {
                        'prompt': 'A cow flying in the sky, blue sky background',
                        'projectId': 'demo_project_1',
                        'model': 'veo_3_1-fast',
                      },
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    taskQueueService.queueTask(task);
                  },
                  child: const Text('Test Veo'),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks queued'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text('${task.type.name} (${task.parameters['source'] ?? 'veo'})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${task.status.name}'),
                          if (task.errorMessage != null)
                            Text('Error: ${task.errorMessage}', style: const TextStyle(color: Colors.red)),
                          Text('ID: ${task.id}'),
                        ],
                      ),
                      trailing: _buildStatusIcon(task.status),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case TaskStatus.processing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
    }
  }
}
