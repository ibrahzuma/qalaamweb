import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/shimmer.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Article>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Insights')),
      body: FutureBuilder<List<Article>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList(count: 4, itemHeight: 280);
          }
          final articles = snapshot.data ?? const <Article>[];
          if (articles.isEmpty) {
            return _empty();
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space7),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space4),
            itemBuilder: (_, i) => _articleCard(articles[i]),
          );
        },
      ),
    );
  }

  Widget _articleCard(Article a) {
    return QalaamTappableCard(
      padding: EdgeInsets.zero,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: a.imageUrl.isNotEmpty
                  ? Image.network(a.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imgFallback())
                  : _imgFallback(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.author.toUpperCase(), style: AppTheme.eyebrow().copyWith(fontSize: 11)),
                    const Spacer(),
                    Text(a.date.isNotEmpty ? a.date : 'Apr 6, 2026', style: AppTheme.caption()),
                  ],
                ),
                const SizedBox(height: 8),
                Text(a.title, style: AppTheme.h2().copyWith(fontSize: 19), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(a.content, style: AppTheme.body(), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppTheme.space3),
                Row(
                  children: [
                    Icon(Icons.bookmark_outline_rounded, color: AppTheme.textMuted, size: 18),
                    const SizedBox(width: 14),
                    Icon(Icons.share_outlined, color: AppTheme.textMuted, size: 18),
                    const Spacer(),
                    Text('Read more', style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w800)),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: AppTheme.parchment,
        child: const Center(child: Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 48)),
      );

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: QalaamCard(
          padding: const EdgeInsets.all(AppTheme.space7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.article_outlined, color: AppTheme.textGrey, size: 38),
              const SizedBox(height: 12),
              Text('No insights yet', style: AppTheme.h3()),
              const SizedBox(height: 4),
              Text('Check back soon for new articles.', style: AppTheme.caption()),
            ],
          ),
        ),
      ),
    );
  }
}
