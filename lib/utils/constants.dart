import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2/';

  // Get API KEY from env variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // List of Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // List of Categories
  static const List<String> categories = [
    'general',
    'technology',
    'business',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  // Countries
  static const String defaultCountry = 'us';

  // App Info
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
}