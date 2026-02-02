import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/animator_workbench/presentation/providers/workbench_state_provider.dart';
import 'features/animator_workbench/presentation/widgets/character_workbench.dart';
import 'features/animator_workbench/presentation/widgets/script_workbench.dart';
import 'features/animator_workbench/presentation/widgets/storyboard_workbench.dart';
import 'features/animator_workbench/presentation/widgets/workbench_navigation.dart';
import 'features/animator_workbench/presentation/pages/api_verification_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animator Workbench',
      theme: AppTheme.darkTheme,
      // Temporary switch to verification page for testing
      // home: const WorkbenchPage(),
      home: const ApiVerificationPage(),
    );
  }
}

class WorkbenchPage extends ConsumerWidget {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock project ID for demo
    const projectId = 'demo_project_1';
    final workbenchState = ref.watch(workbenchStateProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          const WorkbenchNavigation(),

          // Main Content Area
          Expanded(
            child: _buildContent(workbenchState.currentModule, projectId),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WorkbenchModule module, String projectId) {
    switch (module) {
      case WorkbenchModule.script:
        return ScriptWorkbench(projectId: projectId);
      case WorkbenchModule.storyboard:
        return StoryboardWorkbench(projectId: projectId);
      case WorkbenchModule.characters:
        return const CharacterWorkbench();
      case WorkbenchModule.settings:
        return const Center(child: Text('设置 (开发中)'));
    }
  }
}
