import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/task.dart';
import '../../data/datasources/mock_workbench_data.dart';
import '../providers/dependency_injection.dart';
import '../providers/task_queue_provider.dart';
import '../pages/asset_details_page.dart';
import 'placeholder_card.dart';

final assetListProvider = StreamProvider.family<List<Asset>, String>((ref, projectId) async* {
  // Use mock data for now
  yield mockAssets;
});

class AssetList extends ConsumerWidget {
  final String projectId;

  const AssetList({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListProvider(projectId));
    final tasksAsync = ref.watch(taskListProvider);

    return Column(
      children: [
        // Show pending/processing tasks as placeholders
        tasksAsync.when(
          data: (tasks) {
            final activeTasks = tasks.where((t) => t.status == TaskStatus.pending || t.status == TaskStatus.processing).toList();
            if (activeTasks.isEmpty) return const SizedBox.shrink();
            
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeTasks.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 120,
                    child: PlaceholderCard(task: activeTasks[index]),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        Expanded(
          child: assetsAsync.when(
            data: (assets) {
              if (assets.isEmpty) {
                return const Center(child: Text('No assets found.'));
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 16 / 9, // Cinematic aspect ratio
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssetDetailsPage(asset: asset),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        // Main Card Content
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: asset.isMasterReference
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                            color: AppColors.surfaceVariant,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  color: AppColors.surface,
                                  child: Icon(Icons.image, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                color: AppColors.overlay,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.type.toString().split('.').last.toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.textPrimary.withOpacity(0.7),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Master Reference Badge
                        if (asset.isMasterReference)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.star, size: 10, color: AppColors.textPrimary),
                                  SizedBox(width: 4),
                                  Text(
                                    'MASTER',
                                    style: TextStyle(color: AppColors.textPrimary, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Refined Badge (Lineage)
                        if (asset.parentId != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.overlay,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'REFINED',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
