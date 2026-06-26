class Transcript {
  final String text;

  const Transcript(this.text);

  factory Transcript.fromJson(Map<String, dynamic> json) {
    return Transcript(json["text"] ?? "");
  }
}
