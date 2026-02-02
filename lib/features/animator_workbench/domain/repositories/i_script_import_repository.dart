import '../entities/scene.dart';

abstract class IScriptImportRepository {
  Future<void> saveImportedScenes(List<Scene> scenes);
}
