import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart';
import '../providers/task_queue_provider.dart';

class RefinementPanel extends ConsumerStatefulWidget {
  final Asset sourceAsset;

  const RefinementPanel({super.key, required this.sourceAsset});

  @override
  ConsumerState<RefinementPanel> createState() => _RefinementPanelState();
}

class _RefinementPanelState extends ConsumerState<RefinementPanel> {
  TaskType _selectedType = TaskType.refineFaceSwap;
  final TextEditingController _promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Refine Asset', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            DropdownButton<TaskType>(
              value: _selectedType,
              dropdownColor: AppColors.surfaceVariant,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (TaskType? newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: TaskType.values.map<DropdownMenuItem<TaskType>>((TaskType value) {
                return DropdownMenuItem<TaskType>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Parameters (JSON or Text)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: _queueTask,
              child: const Text('Queue Refinement'),
            ),
          ],
        ),
      ),
    );
  }

  void _queueTask() {
    final task = Task(
      id: const Uuid().v4(),
      type: _selectedType,
      status: TaskStatus.pending,
      sourceAssetId: widget.sourceAsset.id,
      targetAssetId: const Uuid().v4(), // Placeholder ID
      parameters: {'prompt': _promptController.text},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(taskQueueServiceProvider).queueTask(task);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task Queued Successfully')),
    );
    
    Navigator.pop(context); // Close panel/modal if needed
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
