import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';
import 'task_status_indicator.dart';

class PlaceholderCard extends StatelessWidget {
  final Task task;

  const PlaceholderCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Processing Asset...'),
            const SizedBox(height: 8),
            TaskStatusIndicator(status: task.status, progress: task.progress),
            if (task.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  task.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
