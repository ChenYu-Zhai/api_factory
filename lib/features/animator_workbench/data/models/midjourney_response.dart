class MidjourneyResponse {
  final String? id;
  final String? status;
  final String? progress;
  final String? imageUrl;
  final String? failReason;
  final String? result; // For submit response (task ID)

  MidjourneyResponse({
    this.id,
    this.status,
    this.progress,
    this.imageUrl,
    this.failReason,
    this.result,
  });

  factory MidjourneyResponse.fromJson(Map<String, dynamic> json) {
    return MidjourneyResponse(
      id: json['id'] as String?,
      status: json['status'] as String?,
      progress: json['progress'] as String?,
      imageUrl: json['imageUrl'] as String?,
      failReason: json['failReason'] as String?,
      result: json['result'] as String?,
    );
  }
}
