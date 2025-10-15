import 'package:get/get.dart';
import 'package:news_app/models/news_articles.dart';
import 'package:news_app/services/news_services.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  // Untuk memproses request yang sudah dibuat oleh NewsServices
  final NewsServices _newsServices = NewsServices();

  // Setter
  // observable variables (variable yang bisa berubah)
  final _isLoading = false.obs; // Apakah aplikasi sedang memuat berita? (true/false)
  final _articles = <NewsArticles>[].obs; // Untuk menampilkan daftar berita yang berhasil didapat
  final _selectedCategory = 'general'.obs;// Untuk handle kategori yang akan di pilih (yang akan muncul di home screen)
  final _error = ''.obs; // Kalau ada kesalahan, pesan error akan disimpan disini

  // Getter
  // Getter ini, seperti jendela untuk untuk melihat isi variable yang sudah di definisikan
  // Dengan ini, UI bisa dengan mudah melihat data dari controller
  bool get isLoading => _isLoading.value;
  List<NewsArticles> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  // Begitu aplikasi dibuka, aplikasi langsung menampilkan berita utama dari endpoint top-headlines

  Future<void> fetchTopHeadlines({String? category}) async {
    // Blok ini akan dijalankan ketika REST API berhasil berkomunikasi dengan server
    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.getTopHeadlines(
        category: category ?? _selectedCategory.value,
      );

      _articles.value = response.articles;
      
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      // finally akan tetap di execute setalah salah satu dari blok try atau catch sudh berhasil mendapatkan hasil
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category){
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsServices.searchNews(query: query);
      _articles.value = response.articles;

    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      _isLoading.value = false;
    }
  }
}