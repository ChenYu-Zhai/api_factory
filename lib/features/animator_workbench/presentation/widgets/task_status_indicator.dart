import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';

class TaskStatusIndicator extends StatelessWidget {
  final TaskStatus status;
  final double progress;

  const TaskStatusIndicator({
    super.key,
    required this.status,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TaskStatus.pending:
        return const Icon(Icons.hourglass_empty, color: AppColors.pending);
      case TaskStatus.processing:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(value: progress > 0 ? progress : null),
        );
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: AppColors.success);
      case TaskStatus.failed:
        return const Icon(Icons.error, color: AppColors.error);
    }
  }
}
