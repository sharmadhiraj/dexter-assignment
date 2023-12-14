class TranscriptResponse {
  final String transcript;

  TranscriptResponse(this.transcript);

  factory TranscriptResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptResponse(json["transcript"] ?? "");
  }
}
