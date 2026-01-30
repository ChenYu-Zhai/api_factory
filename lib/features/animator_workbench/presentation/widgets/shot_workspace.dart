import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/datasources/mock_workbench_data.dart';
import '../../domain/entities/asset.dart';
import '../providers/workbench_state_provider.dart';
import 'asset_list.dart';
import 'refinement_panel.dart';

class ShotWorkspace extends ConsumerWidget {
  final String projectId;

  const ShotWorkspace({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workbenchState = ref.watch(workbenchStateProvider);
    final selectedShotId = workbenchState.selectedShotId;
    final selectedSceneId = workbenchState.selectedSceneId;

    if (selectedShotId != null) {
      return _buildShotView(context, ref, selectedShotId);
    } else if (selectedSceneId != null) {
      return _buildSceneView(context, ref, selectedSceneId);
    }

    return const Center(child: Text('请选择一个场景或镜头开始编辑'));
  }

  Widget _buildSceneView(BuildContext context, WidgetRef ref, String sceneId) {
    // Find scene info from mock data
    Map<String, dynamic>? currentScene;
    try {
      currentScene = mockScenes.firstWhere((s) => s['id'] == sceneId);
    } catch (_) {}

    if (currentScene == null) {
      return const Center(child: Text('场景未找到'));
    }

    final sceneName = currentScene['name'] as String;
    final shots = currentScene['shots'] as List<Map<String, dynamic>>;

    return Column(
      children: [
        // Scene Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.textSecondary, width: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sceneName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ],
          ),
        ),

        // Scene Content (Grid of Shots)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: shots.length,
            itemBuilder: (context, index) {
              final shot = shots[index];
              final notifier = ref.read(workbenchStateProvider.notifier);
              
              return InkWell(
                onTap: () {
                  // 切换到镜头视图
                  notifier.selectShot(shot['id'] as String);
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder for Shot First Frame
                      Container(
                        color: AppColors.surfaceVariant,
                        child: Center(
                          child: Icon(Icons.movie_creation_outlined, color: AppColors.textPrimary.withValues(alpha:0.24), size: 48),
                        ),
                      ),
                      // Shot Name Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: AppColors.overlay,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                shot['name'] as String,
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (shot['description'] != null)
                                Text(
                                  shot['description'] as String,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShotView(BuildContext context, WidgetRef ref, String shotId) {
    // Find shot info from mock data
    Map<String, dynamic>? currentShot;
    for (final scene in mockScenes) {
      final shots = scene['shots'] as List<Map<String, dynamic>>;
      try {
        currentShot = shots.firstWhere((s) => s['id'] == shotId);
        break;
      } catch (_) {}
    }

    final shotName = currentShot?['name'] as String? ?? '未知镜头';

    return Column(
      children: [
        // Shot Header / Timeline Control
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.textSecondary, width: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        shotName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'AI 激活',
                          style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                ],
              ),
            ],
          ),
        ),

        // Main Workspace Area
        Expanded(
          child: Row(
            children: [
              // Left: Asset Versions / Gallery
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('起始帧版本', style: Theme.of(context).textTheme.labelMedium),
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            tooltip: '精修镜头',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => RefinementPanel(
                                  sourceAsset: Asset(
                                    id: const Uuid().v4(),
                                    projectId: projectId,
                                    type: AssetType.imageBase,
                                    filePath: '/mock/path/base_image.png',
                                    createdAt: DateTime.now(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AssetList(projectId: projectId),
                      ),
                    ],
                  ),
                ),
              ),

              // Right: Video Output / Timeline Preview (Placeholder)
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondary.withValues(alpha:0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text('视频输出', style: Theme.of(context).textTheme.labelMedium),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.hourglass_empty, size: 48, color: AppColors.textSecondary),
                              SizedBox(height: 16),
                              Text('等待资源', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
