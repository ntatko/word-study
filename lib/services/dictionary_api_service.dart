import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryApiService {
  static const String _baseUrl =
      'https://freedictionaryapi.com/api/v1/entries/en/';

  static Future<List<DictionaryEntry>> fetchDefinitions(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${Uri.encodeComponent(word.toLowerCase())}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> entriesData = data['entries'] as List<dynamic>;

        return entriesData
            .map(
              (json) => DictionaryEntry.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to load definitions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching definitions: $e');
    }
  }
}

class DictionaryEntry {
  final String partOfSpeech;
  final List<String> pronunciations;
  final List<DictionarySense> senses;
  final List<String> synonyms;
  final List<String> antonyms;

  DictionaryEntry({
    required this.partOfSpeech,
    required this.pronunciations,
    required this.senses,
    required this.synonyms,
    required this.antonyms,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      partOfSpeech: json['partOfSpeech'] as String,
      pronunciations:
          (json['pronunciations'] as List<dynamic>?)
              ?.map((p) => p['text'] as String)
              .toList() ??
          [],
      senses:
          (json['senses'] as List<dynamic>?)
              ?.map((s) => DictionarySense.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      synonyms:
          (json['synonyms'] as List<dynamic>?)
              ?.map((s) => s as String)
              .toList() ??
          [],
      antonyms:
          (json['antonyms'] as List<dynamic>?)
              ?.map((a) => a as String)
              .toList() ??
          [],
    );
  }
}

class DictionarySense {
  final String definition;
  final List<String> examples;
  final List<String> tags;

  DictionarySense({
    required this.definition,
    required this.examples,
    required this.tags,
  });

  factory DictionarySense.fromJson(Map<String, dynamic> json) {
    return DictionarySense(
      definition: json['definition'] as String,
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ??
          [],
    );
  }
}
