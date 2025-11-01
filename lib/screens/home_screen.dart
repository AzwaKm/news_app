import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/models/news_articles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends GetView<NewsController> {
  HomeScreen({super.key}) {
    if (!Get.isRegistered<NewsController>()) {
      Get.put(NewsController());
    }
  }

  Widget _buildHeroCard(BuildContext context, NewsArticles currentArticle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Get.toNamed('/news-detail', arguments: currentArticle);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: currentArticle.urlToImage ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textHint),
                      ),
                    ),
                  ),
                ),

                if (currentArticle.publishedAt != null && DateTime.now().difference(DateTime.parse(currentArticle.publishedAt!)).inHours < 24)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentArticle.title ?? 'Title Not Available',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.3
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${currentArticle.source?.name ?? 'Unknown Source'} • ${currentArticle.publishedAt != null ? timeago.format(DateTime.parse(currentArticle.publishedAt!)) : 'Just now'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentArticle.description ?? 'A brief description is not available.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(NewsController controller, {bool isSection = false}) {
    return Padding(
      padding: EdgeInsets.all(isSection ? 16.0 : 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: isSection ? 40 : 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(
              fontSize: isSection ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing the category or reloading the news.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary
            ),
          ),
          if (!isSection)
            const SizedBox(height: 24),
          if (!isSection)
            ElevatedButton(
              onPressed: controller.refreshNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('Reload News')
            )
        ],
      ),
    );
  }

  Widget _buildErrorWidget(NewsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'An Error Has Occurred',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.split(':').last.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.refreshNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('Try Again')
            )
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, NewsController controller) {
    final TextEditingController searchController = TextEditingController();
   
    final List<String> suggestions = controller.categories.where((cat) => cat != 'general').toList();
   
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    ' News',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
               
              TextField(
                controller: searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Type your search topic here...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.08),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 28),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: AppColors.primary),
                    onPressed: () {
                      final value = searchController.text;
                      if (value.trim().isNotEmpty) {
                        controller.searchNews(value.trim());
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.searchNews(value.trim());
                    Navigator.of(context).pop();
                  }
                },
              ),

              const SizedBox(height: 25),

              Text(
                'Popular Suggestions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: suggestions.map((category) {
                  String displayCategory = category.capitalize ?? category;
                  return ActionChip(
                    label: Text(
                      '#$displayCategory',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: AppColors.secondary,
                    elevation: 2,
                    shadowColor: AppColors.secondary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      controller.searchNews(category);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel Search',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();
   
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'NEWNEEK',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () => _showSearchDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: () {}
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Obx(() {
        final List<NewsArticles> allArticles = controller.articles;
        final NewsArticles? heroArticle = allArticles.isNotEmpty ? allArticles.first : null;
        final List<NewsArticles> popularArticles = allArticles.length > 1 ? allArticles.sublist(1) : [];

        if (controller.isLoading && allArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty && allArticles.isEmpty) {
          return _buildErrorWidget(controller);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNews,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            ' ${DateFormat('d/M').format(DateTime.now())}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 55,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      String displayCategory = category.capitalize ?? category;
                      if (category == 'general') {
                        displayCategory = 'All';
                      }
                      return CategoryChip(
                        label: displayCategory,
                        isSelected: controller.selectedCategory == category,
                        onTap: () => controller.selectCategory(category),
                      );
                    },
                  ),
                ),

                if (heroArticle != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildHeroCard(context, heroArticle),
                  )
                else if (controller.isLoading == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildEmptyWidget(controller, isSection: true),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular News',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: controller.isLoading ? AppColors.textHint : AppColors.textSecondary
                        ),
                        onPressed: controller.isLoading ? null : controller.refreshNews,
                      ),
                    ],
                  ),
                ),

                if (popularArticles.isEmpty && !controller.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEmptyWidget(controller, isSection: true),
                  )
                else if (popularArticles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: popularArticles.length,
                      itemBuilder: (context, index) {
                        final article = popularArticles[index];
                        return PopularNewsTile(
                          article: article,
                          onTap: () {
                            Get.toNamed('/news-detail', arguments: article);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isSelected ? AppColors.secondary : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.secondary : Colors.grey.shade300,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class PopularNewsTile extends StatelessWidget {
  final NewsArticles article;
  final VoidCallback onTap;

  const PopularNewsTile({
    required this.article,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: Center(child: Icon(Icons.photo, color: AppColors.textHint)),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: Center(child: Icon(Icons.broken_image, color: AppColors.textHint)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'Title not available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.3
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.source?.name ?? 'Source'} • ${article.publishedAt != null ? timeago.format(DateTime.parse(article.publishedAt!)) : 'Recent'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}