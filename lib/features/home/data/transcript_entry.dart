class TranscriptEntry {
  final String text;
  final DateTime capturedAt;

  const TranscriptEntry({required this.text, required this.capturedAt});

  Map<String, dynamic> toJson() => {
        "text": text,
        "capturedAt": capturedAt.millisecondsSinceEpoch,
      };

  factory TranscriptEntry.fromJson(Map<String, dynamic> json) =>
      TranscriptEntry(
        text: json["text"] as String,
        capturedAt:
            DateTime.fromMillisecondsSinceEpoch(json["capturedAt"] as int),
      );
}
