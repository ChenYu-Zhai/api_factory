class VeoResponse {
  final String? id;
  final String? status;
  final String? videoUrl;
  final String? enhancedPrompt;

  VeoResponse({
    this.id,
    this.status,
    this.videoUrl,
    this.enhancedPrompt,
  });

  factory VeoResponse.fromJson(Map<String, dynamic> json) {
    return VeoResponse(
      id: json['id'] as String?,
      status: json['status'] as String?,
      videoUrl: json['video_url'] as String?,
      enhancedPrompt: json['enhanced_prompt'] as String?,
    );
  }
}
