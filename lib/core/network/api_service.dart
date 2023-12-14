import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> sendAudioFile(String filePath) async {
    // Create a multipart request
    var request = http.MultipartRequest('POST',
        Uri.parse('https://35.207.149.36:443/stt_flutter_tech_assignment'));

    // Add headers
    request.headers.addAll({
      'Authorization': 'Bearer KsJ5Ag3',
    });

    // Add the file
    var file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

    try {
      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        debugPrint("File uploaded successfully.");
        return jsonDecode(await response.stream.bytesToString());
      } else {
        debugPrint("Failed to upload file.");
        return Future.error("Failed to upload file.");
      }
    } catch (e) {
      debugPrint(e.toString());
      return Future.error(e.toString());
    }
  }
}
