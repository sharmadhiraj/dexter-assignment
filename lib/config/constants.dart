class AppConfig {
  static const String appName = "Dexter";
  static const String nativeChannelName =
      "com.sharmadhiraj.always_listening_service/data";

  // Get a free API key at https://console.groq.com — no credit card required.
  static const String apiToken = "YOUR_GROQ_API_KEY";
  static const String sttApiUrl =
      "https://api.groq.com/openai/v1/audio/transcriptions";
  static const String sttModel = "whisper-large-v3-turbo";
}
