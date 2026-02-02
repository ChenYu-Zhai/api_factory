import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../providers/workbench_state_provider.dart';

class WorkbenchNavigation extends ConsumerWidget {
  const WorkbenchNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workbenchState = ref.watch(workbenchStateProvider);
    final notifier = ref.read(workbenchStateProvider.notifier);

    return NavigationRail(
      backgroundColor: AppColors.surface,
      selectedIndex: workbenchState.currentModule.index,
      onDestinationSelected: (int index) {
        notifier.selectModule(WorkbenchModule.values[index]);
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('剧本'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.movie_creation_outlined),
          selectedIcon: Icon(Icons.movie_creation),
          label: Text('分镜'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('角色'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('设置'),
        ),
      ],
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
      selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      useIndicator: true,
      indicatorColor: AppColors.primary.withValues(alpha:0.1),
    );
  }
}
