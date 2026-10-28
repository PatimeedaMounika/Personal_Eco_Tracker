import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<dynamic>> fetchPosts() async {
    try {
      final uri = Uri.parse('$baseUrl/posts');

      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData;
        }

        throw Exception('Invalid data received from API.');
      }

      throw Exception(
        'API request failed with status code '
        '${response.statusCode}.',
      );
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException {
      throw Exception('The API returned invalid JSON data.');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unable to load posts: $e');
    }
  }
}
