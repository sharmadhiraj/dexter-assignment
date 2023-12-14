import 'package:dexter_assignment/core/network/api_service.dart';
import 'package:dexter_assignment/features/home/data/transcript_request.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';

class HomeRepo {
  static Future<TranscriptResponse> uploadAudioFile(
      TranscriptRequest request) async {
    try {
      final Map<String, dynamic> responseJson =
          await ApiService.sendAudioFile(request.filePath);
      print("RESPONSE FROM SERVER");
      print(responseJson);
      return TranscriptResponse.fromJson(responseJson);
    } catch (e) {
      return Future.error(e);
    }
  }
}
