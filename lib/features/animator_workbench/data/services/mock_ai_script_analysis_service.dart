import 'package:uuid/uuid.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/shot.dart';
import '../../domain/services/i_ai_script_analysis_service.dart';

class MockAIScriptAnalysisService implements IAIScriptAnalysisService {
  @override
  Future<List<Scene>> analyzeScript(String scriptContent, String projectId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock analyzed data regardless of input
    return [
      Scene(
        id: const Uuid().v4(),
        projectId: projectId,
        name: 'AI 分析场景 1: 森林追逐',
        description: '主角在密林中奔跑，躲避追击',
        sequenceNumber: 1,
        shots: [
          Shot(
            id: const Uuid().v4(),
            sceneId: 'temp_scene_id_1', // Will be updated when saving
            name: '全景：森林入口',
            description: '阳光透过树叶洒下斑驳光影，主角身影出现',
            sequenceNumber: 1,
          ),
          Shot(
            id: const Uuid().v4(),
            sceneId: 'temp_scene_id_1',
            name: '特写：紧张神情',
            description: '主角额头渗出汗珠，眼神惊恐',
            sequenceNumber: 2,
          ),
        ],
      ),
      Scene(
        id: const Uuid().v4(),
        projectId: projectId,
        name: 'AI 分析场景 2: 悬崖对峙',
        description: '主角被逼至悬崖边，无路可退',
        sequenceNumber: 2,
        shots: [
          Shot(
            id: const Uuid().v4(),
            sceneId: 'temp_scene_id_2',
            name: '中景：背水一战',
            description: '主角转身面对敌人，拔出武器',
            sequenceNumber: 1,
          ),
        ],
      ),
    ];
  }
}
