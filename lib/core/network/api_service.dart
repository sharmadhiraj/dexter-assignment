import 'dart:convert';

import 'package:dexter_assignment/config/constants.dart';
import 'package:http/http.dart' as http;

class SttApiClient {
  static Future<Map<String, dynamic>> transcribe(String filePath) async {
    final request =
        http.MultipartRequest("POST", Uri.parse(AppConfig.sttApiUrl))
          ..headers["Authorization"] = "Bearer ${AppConfig.apiToken}"
          ..files.add(await http.MultipartFile.fromPath("file", filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    }
    throw Exception("Transcription failed (HTTP ${response.statusCode})");
  }
}
