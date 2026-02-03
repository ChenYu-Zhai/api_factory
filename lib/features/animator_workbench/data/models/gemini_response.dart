import 'dart:convert';

class GeminiResponse {
  final String id;
  final String model;
  final String content;
  final String? base64Image;

  GeminiResponse({
    required this.id,
    required this.model,
    required this.content,
    this.base64Image,
  });

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    final choices = json['choices'] as List;
    final message = choices[0]['message'];
    final content = message['content'] as String;

    // Extract Base64 image from markdown format: ![image](data:image/jpeg;base64,...)
    final imagePattern = RegExp(r"!\[.*?\]\(data:image/\w+;base64,(.*?)\)");
    final match = imagePattern.firstMatch(content);
    final base64Image = match?.group(1);

    return GeminiResponse(
      id: json['id'],
      model: json['model'],
      content: content,
      base64Image: base64Image,
    );
  }
}
