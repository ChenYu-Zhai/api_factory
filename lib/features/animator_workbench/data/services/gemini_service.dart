import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../domain/entities/asset.dart';
import '../../domain/services/i_generative_image_service.dart';
import '../models/gemini_response.dart';

class GeminiService implements IGenerativeImageService {
  final String _baseUrl = 'https://yunwu.ai/v1/chat/completions';
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  @override
  Future<Asset> generateImage(Map<String, dynamic> parameters) async {
    final prompt = parameters['prompt'] as String;
    final projectId = parameters['projectId'] as String;

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gemini-3-pro-image-preview",
        "messages": [
          {
            "role": "user",
            "content": prompt,
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final geminiResponse = GeminiResponse.fromJson(jsonDecode(response.body));
      
      if (geminiResponse.base64Image != null) {
        final imageBytes = base64Decode(geminiResponse.base64Image!);
        final fileName = 'gemini_${const Uuid().v4()}.jpg';
        
        // Save to local file system
        final appDir = await getApplicationDocumentsDirectory();
        final projectDir = Directory(path.join(appDir.path, 'projects', projectId, 'assets'));
        if (!await projectDir.exists()) {
          await projectDir.create(recursive: true);
        }
        
        final filePath = path.join(projectDir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        return Asset(
          id: const Uuid().v4(),
          projectId: projectId,
          type: AssetType.imageBase,
          filePath: filePath,
          metadata: {
            'source': 'gemini',
            'prompt': prompt,
            'model': geminiResponse.model,
          },
          createdAt: DateTime.now(),
          isMasterReference: false,
        );
      } else {
        throw Exception('No image data found in Gemini response');
      }
    } else {
      throw Exception('Failed to generate image: ${response.body}');
    }
  }

  @override
  Future<Asset> refineImage(Asset sourceAsset, Map<String, dynamic> parameters) async {
    // Gemini currently doesn't support direct image-to-image refinement in this specific API endpoint structure 
    // as easily as text-to-image without more complex multi-modal setup.
    // For this MVP, we will treat it as a new generation or throw unimplemented if strict refinement is needed.
    // Or we could implement a multi-modal request if the API supports it (sending image + text).
    
    // For now, let's assume we just use the prompt to regenerate, or throw.
    // A better approach for "refine" might be to use Midjourney's remix or similar if available, 
    // or just re-prompt Gemini with more details.
    
    throw UnimplementedError('Gemini refinement not yet implemented');
  }
}
