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
      Uri.parse('$baseUrl/verses/search'),
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: jsonEncode(
        {
          'version': 'kjv',
          'search': keyword,
        },
      ),
    );

    if (response.statusCode == 200) {
      // Ubah menjadi Map jika hasil dari API adalah objek
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Akses list dari map, sesuaikan dengan struktur respons yang tepat
      List<dynamic> versesList = jsonResponse['verses'];

      return versesList.map((data) => Verse.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search verses');
    }
  }
}
