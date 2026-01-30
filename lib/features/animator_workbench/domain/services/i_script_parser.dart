import '../entities/scene.dart';

abstract class IScriptParser {
  Future<List<Scene>> parseScript(String content, String projectId);
}
