import 'package:dexter_assignment/core/network/api_service.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';

class TranscriptionRepository {
  static Future<Transcript> upload(String filePath) async {
    final json = await SttApiClient.transcribe(filePath);
    return Transcript.fromJson(json);
  }
}
