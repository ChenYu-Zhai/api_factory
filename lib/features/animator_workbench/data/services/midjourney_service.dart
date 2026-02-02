import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../domain/entities/asset.dart';
import '../models/midjourney_response.dart';

class MidjourneyService {
  final String _baseUrl = 'https://yunwu.ai';
  final String _apiKey = dotenv.env['MJ_API_KEY'] ?? '';

  Future<String?> submitImagine(String prompt) async {
    final url = Uri.parse('$_baseUrl/mj/submit/imagine');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "botType": "MID_JOURNEY",
        "prompt": prompt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 1) {
        return data['result']; // Task ID
      }
    }
    return null;
  }

  Future<MidjourneyResponse?> fetchTaskResult(String taskId) async {
    final url = Uri.parse('$_baseUrl/mj/task/$taskId/fetch');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return MidjourneyResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Asset> downloadAndSaveImage(String imageUrl, String projectId, String prompt) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final fileName = 'mj_${const Uuid().v4()}.png';
      final appDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory(path.join(appDir.path, 'projects', projectId, 'assets'));
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      final filePath = path.join(projectDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return Asset(
        id: const Uuid().v4(),
        projectId: projectId,
        type: AssetType.imageBase,
        filePath: filePath,
        metadata: {
          'source': 'midjourney',
          'prompt': prompt,
        },
        createdAt: DateTime.now(),
        isMasterReference: false,
      );
    } else {
      throw Exception('Failed to download image from Midjourney');
    }
  }
}
