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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [ 
          SliverAppBar(
            expandedHeight: 300, // utk ukuran gambar dari atas sampe bawah gambar
            pinned: true, // jadi pas di scroll ttp keliatan, gaikut ke scroll si appbar nya 
            flexibleSpace: FlexibleSpaceBar( // utk menyimpan gambarnya
            background: article.urlToImage != null // ini dijalankan jika dari server memiliki gambar, maka kita akan menjalankan ini
                ? CachedNetworkImage( // membuat kompresi dari gambar yg ada di server -> jadi kecil
                    imageUrl: article.urlToImage!,
                    fit: BoxFit.cover, 
                    placeholder: (context, url) => Container( // kalau gambar belum muncul
                    color: AppColors.divider,
                    child: Center(
                       child: CircularProgressIndicator(), // jika masih loading, bisa pake yg theme
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
                // titik dua = nilai false // ini statement yg akan dijalankan ketika server tidak memiliki gambar
                // atau -> image = null
                : Container( 
                  color: AppColors.divider,
                  child: Icon(
                    Icons.newspaper,
                    size: 50,
                    color: AppColors.textHint,
                  ),
                )

            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareArticle(),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    // dua kondisi
                    case 'copy link': // 1
                    _copyLink();                 
                      break;
                      case 'open_browser': // 2
                      _openInBrowser();
                      break;
                    default:
                  }
                },
                itemBuilder: (context) => [ // ini utk yg titik tiga (popupmenubutton) di detail screen
                  PopupMenuItem(
                    value: 'Copy link',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(height: 8),
                        Text('Copy link'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Open_browser',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser),
                        SizedBox(height: 8),
                        Text('Open in browser'),
                      ],
                    ),
                  )
                ] ,
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // source and date
                  Row(
                    children: [
                      if (article.source?.name != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            article.source!.name!,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        SizedBox(width: 12)
                      ],
                      if (article.publishedAt != null) ...[
                        Text(
                          timeago.format(DateTime.parse(article.publishedAt!)),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12
                          ),
                        ),
                      ]
                    ],
                  ),
                  SizedBox(height: 16),
                  // title
                  if (article.title != null) ...[
                    Text(
                      article.title!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  // description
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5
                      ),
                    )
                  ],
                  SizedBox(height: 20),
                  // content
                  if (article.content != null) ...[
                    Text(
                      'Content',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      article.content!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.6
                      ),
                    ),
                    SizedBox(height: 24)
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

 // void function yg tidak memiliki kembalian.
  void _shareArticle() {
    if (article.url != null) {
      Share.share(
        '${article.title ?? 'Check out this news'}\n\n${article.url!}', //n = baris baru -> enter
         subject: article.title
      );
    }
  }

  void _copyLink() {
    if (article.url != null) {
      Clipboard.setData(ClipboardData(text: article.url!)); // menyalin
      Get.snackbar(
        'Succes',
        'Link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    }
  }

  void _openInBrowser() async {
    if (article.url != null) {
      final Uri url = Uri.parse(article.url!); // uri digunakan utk parsing link agar diketahui oleh aplikasi lain, biar si chrome paham.
      // proses menunggu apakah url valid dan bisa dibuka oleh browser
      if (await canLaunchUrl(url)) {
        // proses menunggu ketika url sudah valid dan sedang diproses oleh browser sampai datanya muncul
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
}