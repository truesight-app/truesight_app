import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl =
      'http://64.23.143.191:5000'; // Replace with your server URL

  static Future<Map<String, dynamic>> analyzeAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/analyze_audio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio': base64Audio,
          'filename': audioPath.split('/').last,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to analyze audio: $e');
    }
  }
}
