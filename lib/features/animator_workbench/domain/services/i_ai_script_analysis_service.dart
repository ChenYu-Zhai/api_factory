import '../entities/scene.dart';

abstract class IAIScriptAnalysisService {
  Future<List<Scene>> analyzeScript(String scriptContent, String projectId);
}
