import 'package:news_app/models/news_articles.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticles> articles;

  NewsResponse({required this.status, required this.totalResults, required this.articles});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles: (json['articles'] as List<dynamic>?)
                ?.map((article) => NewsArticles.fromJson(article))
               .toList() ?? []
    );
  }
}