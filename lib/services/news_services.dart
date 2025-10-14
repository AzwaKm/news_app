import 'dart:convert';

import 'package:news_app/models/news_response.dart';
import 'package:news_app/utils/constants.dart';
// Mendefinisikan sebuah package atau library menjadi sebuah variabel secara langsung
import 'package:http/http.dart' as http;

class NewsService {
  static const String _baseUrl = Constants.baseUrl;
  static final String _apiKey = Constants.apiKey;

  // Fungsi yang bertujuan untuk membuat request GET ke server
  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'country': country,
        'page': page.toString(),
        'pageSize': pageSize.toString()
      };

      // Statement yang akan dijalankan ketika category tidak kosong
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      // Berfungsi untuk parsing data dari JSON ke UI
      // Parsing: melempar dan mengambil data, yang ngambil UI yang lempar JSON
      // Simplenya: kita daftarin baseUrl + endpoint yang akan digunakan
      final uri = Uri.parse('$_baseUrl${Constants.topHeadlines}')
          .replace(queryParameters: queryParams);

      // Untuk menyimpan respon yang diberikan oleh server  
      final response = await http.get(uri);

      // Kode yang akan dijalankan jika request ke API sukses
      if (response.statusCode == 200) {
        // Untuk merubah data dari json ke bahasa dart
        final jsonData = json.decode(response.body);
        return NewsResponse.fromJson(jsonData);
      // Kode yang akan dijalankan jika request ke API gagal (status HTTP != 200)
      } else {
        throw Exception('Failed to load news, please try again later.');
      }
      // Kode yang akan dijalankan ketika terjadi error lain, selain yang sudah dibuat di atas
      // e = error
    } catch (e) {
      throw Exception('Another problem occurs, please try again later.');
    }
  }

  Future<NewsResponse> searchNews ({
    required String query, // Ini adalah nilai yang dimasukkan ke kolom pencarian
    int page = 1, // Ini untuk mendefinisikan halaman berita ke berapa
    int pageSize = 20, // Berapa banyak berita yang ingin ditampilkan ketika sekali proses rendering data
    String? sortBy,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final uri = Uri.parse('$_baseUrl${Constants.everything}')
            .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return NewsResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load news, please try again later.');
    }
    } catch (e) {
      throw Exception('Another problem occurs, please try again later.');
    }
  }
}