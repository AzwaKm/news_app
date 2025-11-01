import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app/models/news_articles.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsDetailScreen extends StatelessWidget {
  final NewsArticles article = Get.arguments as NewsArticles;

  NewsDetailScreen({super.key});

  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out this news'}\n\n${article.url!}',
          subject: article.title
      );
    }
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!));
      Get.snackbar(
        'Success',
        'Link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final Uri url = Uri.parse(article.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          "Couldn't open the link",
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('en', timeago.EnMessages()); 
    
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: CustomScrollView(
        slivers: [ 
          SliverAppBar(
            expandedHeight: 300, 
            pinned: true,
            backgroundColor: AppColors.primary, 
            iconTheme: const IconThemeData(color: Colors.white), 
            systemOverlayStyle: SystemUiOverlayStyle.light, 
            
            flexibleSpace: FlexibleSpaceBar( 
              title: null, 
              centerTitle: true,
              
              background: Stack(
                fit: StackFit.expand,
                children: [
                  article.urlToImage != null
                    ? CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        fit: BoxFit.cover, 
                        placeholder: (context, url) => Container( 
                          color: AppColors.divider,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary), 
                          ),
                        ), 
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.divider,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: AppColors.textHint,
                          ),
                        ),
                      )
                    : Container( 
                        color: AppColors.divider,
                        child: Icon(
                          Icons.newspaper,
                          size: 50,
                          color: AppColors.textHint,
                        ),
                      ),

                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black54, 
                          Colors.black26,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareArticle(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'copy link':
                      _copyLink(); 
                      break;
                    case 'open_browser':
                      _openInBrowser();
                      break;
                    default:
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy link',
                    child: Row(
                      children: [
                        Icon(Icons.copy, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Copy Link', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.launch, color: AppColors.textPrimary),
                        SizedBox(width: 8),
                        Text('Open in Browser', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  )
                ] ,
              )
            ],
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(top: 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25), 
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.title != null) ...[
                        Text(
                          article.title!,
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.w900, 
                            color: AppColors.textPrimary,
                            height: 1.2
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (article.source?.name != null) 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.5))
                              ),
                              child: Text(
                                article.source!.name!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                          if (article.publishedAt != null) 
                            Text(
                              timeago.format(DateTime.parse(article.publishedAt!), locale: 'en'),
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      
                      const Divider(height: 30),

                      if (article.description != null) ...[
                        Text(
                          article.description!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      if (article.description != null && article.content != null)
                        const SizedBox(height: 24),

                      if (article.content != null) ...[
                        Text(
                          article.content!.replaceAll(RegExp(r'\s*\[\+\d+\s*chars\]\s*$'), ''),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                      
                      const SizedBox(height: 32)
                    ],
                  ),
                ),

                if (article.url != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openInBrowser,
                        icon: const Icon(Icons.public, size: 20),
                        label: const Text(
                          'READ FULL ARTICLE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          elevation: 8,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}