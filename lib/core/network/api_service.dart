import 'dart:convert';

import 'package:dexter_assignment/config/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> sendAudioFile(String filePath) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(Constant.sttApiUrl),
    );

    request.headers.addAll({
      "Authorization": "Bearer ${Constant.apiToken}",
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
