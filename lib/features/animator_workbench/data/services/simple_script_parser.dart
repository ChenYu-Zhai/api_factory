import 'package:uuid/uuid.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/shot.dart';
import '../../domain/services/i_script_parser.dart';

class SimpleScriptParser implements IScriptParser {
  @override
  Future<List<Scene>> parseScript(String content, String projectId) async {
    final scenes = <Scene>[];
    final lines = content.split('\n');
    Scene? currentScene;
    var currentShots = <Shot>[];
    var sceneSequence = 1;
    var shotSequence = 1;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('SCENE') || line.startsWith('场景')) {
        if (currentScene != null) {
          scenes.add(Scene(
            id: currentScene.id,
            projectId: currentScene.projectId,
            name: currentScene.name,
            description: currentScene.description,
            sequenceNumber: currentScene.sequenceNumber,
            shots: List.from(currentShots),
          ));
          currentShots = [];
        }

        final sceneName = line.replaceAll(RegExp(r'^(SCENE|场景)(\s+\d+)?\s*[:：]?\s*'), '').trim();
        currentScene = Scene(
          id: const Uuid().v4(),
          projectId: projectId,
          name: sceneName.isEmpty ? 'Scene $sceneSequence' : sceneName,
          description: '',
          sequenceNumber: sceneSequence++,
          shots: const [],
        );
        shotSequence = 1;
      } else if (line.startsWith('SHOT') || line.startsWith('镜头')) {
        // Create a default scene if shots appear before any scene definition
        currentScene ??= Scene(
          id: const Uuid().v4(),
          projectId: projectId,
          name: 'Scene $sceneSequence',
          description: '',
          sequenceNumber: sceneSequence++,
          shots: const [],
        );
        
        final shotParts = line.split(RegExp(r'[:：]'));
        final shotName = shotParts.length > 1 ? shotParts[1].trim() : 'Shot $shotSequence';
        final shotDesc = shotParts.length > 2 ? shotParts.sublist(2).join(':').trim() : '';

        currentShots.add(Shot(
          id: const Uuid().v4(),
          sceneId: currentScene.id,
          name: shotName,
          description: shotDesc,
          sequenceNumber: shotSequence++,
        ));
      }
    }

    if (currentScene != null) {
      scenes.add(Scene(
        id: currentScene.id,
        projectId: currentScene.projectId,
        name: currentScene.name,
        description: currentScene.description,
        sequenceNumber: currentScene.sequenceNumber,
        shots: List.from(currentShots),
      ));
    }

    return scenes;
  }
}
