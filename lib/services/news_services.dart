import 'dart:convert';

import 'package:news_app/models/news_response.dart';
import 'package:news_app/utils/constants.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  static const String _baseUrl = Constants.baseUrl;
  static final String _apiKey = Constants.apiKey;

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

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse('$_baseUrl${Constants.topHeadlines}')
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

  Future<NewsResponse> searchNews ({
    required String query,
    int page = 1,
    int pageSize = 20,
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