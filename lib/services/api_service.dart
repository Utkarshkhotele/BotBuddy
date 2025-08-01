import 'dart:convert';
import 'package:chatbot/constant/api_constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // for debugPrint

class GooglleApiService {
  static final http.Client _client = http.Client();
  static String get _fullUrl => "${ApiContant.baseUrl}${ApiContant.apiKey}";

  /// Sends [message] to the Gemini API and returns the text response.
  /// On failure returns a descriptive error string.
  static Future<String> getApiResponse(String message) async {
    try {
      final uri = Uri.parse(_fullUrl);

      final payload = {
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      };

      final response = await _client
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return "Error: ${response.statusCode} - ${response.body}";
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Safely navigate into expected structure
      if (data.containsKey("candidates") &&
          data["candidates"] is List &&
          (data["candidates"] as List).isNotEmpty) {
        final firstCandidate = (data["candidates"] as List).first;
        if (firstCandidate is Map &&
            firstCandidate.containsKey("content") &&
            firstCandidate["content"] is Map) {
          final content = firstCandidate["content"] as Map;
          if (content.containsKey("parts") &&
              content["parts"] is List &&
              (content["parts"] as List).isNotEmpty) {
            final firstPart = (content["parts"] as List).first;
            if (firstPart is Map && firstPart.containsKey("text")) {
              final text = firstPart["text"];
              if (text is String && text.trim().isNotEmpty) {
                return text;
              }
            }
          }
        }
        return "AI response structure unexpected or empty.";
      }

      return "AI did not return any content.";
    } on http.ClientException catch (e) {
      debugPrint("HTTP client error => $e");
      return "Network error: ${e.message}";
    } on FormatException catch (e) {
      debugPrint("Response parse error => $e");
      return "Failed to parse response.";
    } on Exception catch (e) {
      debugPrint("Unknown error => $e");
      return "Error: $e";
    }
  }
}
