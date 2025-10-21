import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/passage_model.dart';
import '../utils/constants.dart';

class PassagesApiService {
  static Future<List<Passage>> fetchPassages() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.passagesApiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> passagesData = data['data'] as List<dynamic>;

        return passagesData
            .map((json) => Passage.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load passages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching passages: $e');
    }
  }

  static String buildBibleGatewayUrl(String passage, String version) {
    final encodedPassage = Uri.encodeComponent(passage);
    return '${AppConstants.bibleGatewayBaseUrl}?search=$encodedPassage&version=$version&interface=print';
  }
}
