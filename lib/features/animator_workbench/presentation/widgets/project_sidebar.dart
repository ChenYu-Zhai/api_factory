import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/workbench_state_provider.dart';
import '../../data/datasources/mock_workbench_data.dart';

class ProjectSidebar extends ConsumerWidget {
  const ProjectSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workbenchState = ref.watch(workbenchStateProvider);
    final notifier = ref.read(workbenchStateProvider.notifier);

    return Container(
      width: 250,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '项目结构',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.upload_file, size: 16, color: AppColors.textSecondary),
                      tooltip: '导入脚本',
                      onPressed: () {
                        notifier.selectModule(WorkbenchModule.script);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scene/Shot Tree
          Expanded(
            child: ListView.builder(
              itemCount: mockScenes.length,
              itemBuilder: (context, index) {
                final scene = mockScenes[index];
                final isSceneSelected = workbenchState.selectedSceneId == scene['id'];
                final shots = scene['shots'] as List<Map<String, String>>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scene Header
                    InkWell(
                      onTap: () => notifier.selectScene(scene['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isSceneSelected ? AppColors.selectionOverlay : null,
                        child: Row(
                          children: [
                            Icon(
                              isSceneSelected ? Icons.folder_open : Icons.folder,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                scene['name'] as String,
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shots List
                    if (isSceneSelected)
                      ...shots.map((shot) {
                        final isShotSelected = workbenchState.selectedShotId == shot['id'];
                        return InkWell(
                          onTap: () => notifier.selectShot(shot['id'] as String),
                          child: Container(
                            padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8, right: 16),
                            color: isShotSelected ? AppColors.hoverOverlay : null,
                            child: Row(
                              children: [
                                const Icon(Icons.movie_creation_outlined, color: AppColors.textSecondary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    shot['name'] as String,
                                    style: TextStyle(
                                      color: isShotSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
          ),

          // Character Library Section (Placeholder)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.textSecondary, width: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '角色库',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildCharacterAvatar('主角', AppColors.warning),
                    const SizedBox(width: 12),
                    _buildCharacterAvatar('导师', AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          
          // Settings Footer
          Container(
             padding: const EdgeInsets.all(16),
             decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.textSecondary, width: 0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.settings, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Text('工作台设置', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCharacterAvatar(String name, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Text(name[0], style: const TextStyle(color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
