import 'package:dexter_assignment/core/network/api_service.dart';
import 'package:dexter_assignment/features/home/data/transcript_request.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';
import 'package:flutter/material.dart';

class HomeRepo {
  static Future<TranscriptResponse> uploadAudioFile(
      TranscriptRequest request) async {
    try {
      final Map<String, dynamic> responseJson =
          await ApiService.sendAudioFile(request.filePath);
      debugPrint("RESPONSE FROM SERVER");
      debugPrint(responseJson.toString());
      return TranscriptResponse.fromJson(responseJson);
    } catch (e) {
      return Future.error(e);
    }
  }
}
