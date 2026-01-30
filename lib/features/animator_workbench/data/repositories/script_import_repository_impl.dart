import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/i_script_import_repository.dart';
import '../datasources/mock_workbench_data.dart';

class ScriptImportRepositoryImpl implements IScriptImportRepository {
  @override
  Future<void> saveImportedScenes(List<Scene> scenes) async {
    // 1. Update in-memory mock data (for immediate UI feedback)
    for (final scene in scenes) {
      final sceneMap = {
        'id': scene.id,
        'name': scene.name,
        'shots': scene.shots.map((shot) => {
          'id': shot.id,
          'name': shot.name,
          'description': shot.description,
        }).toList(),
      };
      mockScenes.add(sceneMap);
    }

    // 2. Persist to local JSON file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/project_data.json');
      
      List<Map<String, dynamic>> existingData = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          existingData = List<Map<String, dynamic>>.from(json.decode(content));
        }
      }

      final newScenesData = scenes.map((scene) => {
        'id': scene.id,
        'projectId': scene.projectId,
        'name': scene.name,
        'description': scene.description,
        'sequenceNumber': scene.sequenceNumber,
        'shots': scene.shots.map((shot) => {
          'id': shot.id,
          'sceneId': shot.sceneId,
          'name': shot.name,
          'description': shot.description,
          'sequenceNumber': shot.sequenceNumber,
        }).toList(),
      }).toList();

      existingData.addAll(newScenesData);

      await file.writeAsString(json.encode(existingData));
      print('Saved imported scenes to ${file.path}');
    } catch (e) {
      print('Error saving to JSON file: $e');
      // Consider rethrowing or handling error more gracefully
    }
  }
}
