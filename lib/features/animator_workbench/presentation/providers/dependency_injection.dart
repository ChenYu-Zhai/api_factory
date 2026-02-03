import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../data/repositories/script_import_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/services/mock_ai_script_analysis_service.dart';
import '../../data/services/simple_script_parser.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/midjourney_service.dart';
import '../../data/services/veo_service.dart';
import '../../domain/repositories/i_asset_repository.dart';
import '../../domain/repositories/i_script_import_repository.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../domain/services/i_ai_script_analysis_service.dart';
import '../../domain/services/i_script_parser.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return TaskRepositoryImpl(dbHelper);
});

final assetRepositoryProvider = Provider<IAssetRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return AssetRepositoryImpl(dbHelper);
});

final scriptParserProvider = Provider<IScriptParser>((ref) {
  return SimpleScriptParser();
});

final scriptImportRepositoryProvider = Provider<IScriptImportRepository>((ref) {
  return ScriptImportRepositoryImpl();
});

final aiScriptAnalysisServiceProvider = Provider<IAIScriptAnalysisService>((ref) {
  return MockAIScriptAnalysisService();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final midjourneyServiceProvider = Provider<MidjourneyService>((ref) {
  return MidjourneyService();
});

final veoServiceProvider = Provider<VeoService>((ref) {
  return VeoService();
});
