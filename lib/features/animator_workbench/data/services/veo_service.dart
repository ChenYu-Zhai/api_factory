import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../domain/entities/asset.dart';
import '../models/veo_response.dart';

class VeoService {
  final String _baseUrl = 'https://yunwu.ai/v1/video';
  final String _apiKey = dotenv.env['VEO_API_KEY'] ?? '';

  Future<String?> createVideo(String prompt, {String model = 'veo_3_1-fast'}) async {
    final url = Uri.parse('$_baseUrl/create');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": model,
        "prompt": prompt,
        "enhance_prompt": true,
        "enable_upsample": true,
        "aspect_ratio": "16:9"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // Task ID
    } else {
      throw Exception('Veo API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<VeoResponse?> queryTask(String taskId) async {
    final url = Uri.parse('$_baseUrl/query?id=$taskId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return VeoResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Asset> downloadAndSaveVideo(String videoUrl, String projectId, String prompt) async {
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode == 200) {
      final fileName = 'veo_${const Uuid().v4()}.mp4';
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
        type: AssetType.video,
        filePath: filePath,
        metadata: {
          'source': 'veo',
          'prompt': prompt,
        },
        createdAt: DateTime.now(),
        isMasterReference: false,
      );
    } else {
      throw Exception('Failed to download video from Veo');
    }
  }
}
