import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WorkbenchModule {
  script,
  storyboard,
  characters,
  settings,
}

// Simple state class to hold current selection
class WorkbenchState {
  final WorkbenchModule currentModule;
  final String? selectedSceneId;
  final String? selectedShotId;

  const WorkbenchState({
    this.currentModule = WorkbenchModule.storyboard,
    this.selectedSceneId,
    this.selectedShotId,
  });

  WorkbenchState copyWith({
    WorkbenchModule? currentModule,
    String? selectedSceneId,
    String? selectedShotId,
  }) {
    return WorkbenchState(
      currentModule: currentModule ?? this.currentModule,
      selectedSceneId: selectedSceneId ?? this.selectedSceneId,
      selectedShotId: selectedShotId ?? this.selectedShotId,
    );
  }
}

class WorkbenchStateNotifier extends StateNotifier<WorkbenchState> {
  WorkbenchStateNotifier() : super(const WorkbenchState(
          currentModule: WorkbenchModule.storyboard,
          selectedSceneId: 'scene_1',
          selectedShotId: 'shot_1',
        ));

  void selectModule(WorkbenchModule module) {
    state = state.copyWith(currentModule: module);
  }

  void selectScene(String sceneId) {
    // If clicking the already selected scene
    if (state.selectedSceneId == sceneId) {
      // If we are currently in a shot view, go back to scene view (deselect shot)
      if (state.selectedShotId != null) {
        state = WorkbenchState(
          selectedSceneId: sceneId,
          selectedShotId: null,
        );
      } else {
        // If we are already in scene view, collapse the scene
        state = const WorkbenchState(
          selectedSceneId: null,
          selectedShotId: null,
        );
      }
    } else {
      // If clicking a different scene, select it and clear shot selection
      state = WorkbenchState(
        selectedSceneId: sceneId,
        selectedShotId: null,
      );
    }
  }

  void selectShot(String shotId) {
    state = state.copyWith(selectedShotId: shotId);
  }
}

final workbenchStateProvider = StateNotifierProvider<WorkbenchStateNotifier, WorkbenchState>((ref) {
  return WorkbenchStateNotifier();
});
