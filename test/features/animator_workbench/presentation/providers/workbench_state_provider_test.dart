import 'package:flutter_test/flutter_test.dart';
import 'package:api_factory/features/animator_workbench/presentation/providers/workbench_state_provider.dart';

void main() {
  group('WorkbenchStateNotifier', () {
    test('initial state is correct', () {
      final notifier = WorkbenchStateNotifier();
      expect(notifier.state.currentModule, WorkbenchModule.storyboard);
      expect(notifier.state.selectedSceneId, 'scene_1');
      expect(notifier.state.selectedShotId, 'shot_1');
    });

    test('selectModule updates current module', () {
      final notifier = WorkbenchStateNotifier();
      
      notifier.selectModule(WorkbenchModule.script);
      expect(notifier.state.currentModule, WorkbenchModule.script);

      notifier.selectModule(WorkbenchModule.characters);
      expect(notifier.state.currentModule, WorkbenchModule.characters);
    });

    test('selectScene behavior', () {
      final notifier = WorkbenchStateNotifier();
      
      // Initial: scene_1, shot_1
      
      // 1. Click scene_1 while in shot_1 -> Should go to scene_1 view (shot_1 deselected)
      notifier.selectScene('scene_1');
      expect(notifier.state.selectedSceneId, 'scene_1');
      expect(notifier.state.selectedShotId, null);

      // 2. Click scene_1 while in scene_1 view -> Should collapse (deselect scene)
      notifier.selectScene('scene_1');
      expect(notifier.state.selectedSceneId, null);
      expect(notifier.state.selectedShotId, null);

      // 3. Click scene_1 again -> Should expand
      notifier.selectScene('scene_1');
      expect(notifier.state.selectedSceneId, 'scene_1');
      expect(notifier.state.selectedShotId, null);

      // 4. Select a shot
      notifier.selectShot('shot_1');
      expect(notifier.state.selectedShotId, 'shot_1');

      // 5. Click scene_2 -> Should switch to scene_2 and clear shot
      notifier.selectScene('scene_2');
      expect(notifier.state.selectedSceneId, 'scene_2');
      expect(notifier.state.selectedShotId, null);
    });

    test('selectShot updates selection', () {
      final notifier = WorkbenchStateNotifier();
      
      notifier.selectShot('shot_2');
      expect(notifier.state.selectedShotId, 'shot_2');
    });
  });
}
