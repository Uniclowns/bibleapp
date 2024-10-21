import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse.dart';

class ApiService {
  final String baseUrl = 'https://www.abibliadigital.com.br/api';

  Future<Verse> fetchVerse(String version, String book, int chapter) async {
    final response = await http.get(
      Uri.parse('$baseUrl/verses/$version/$book/$chapter'),
    );

    if (response.statusCode == 200) {
      return Verse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load verse');
    }
  }

  Future<List<Verse>> searchVerses(String keyword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verses/$keyword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'q': keyword}),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Verse.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search verses');
    }
  }
}
