import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer.dart';
import 'podcast_detail_screen.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Podcast>> _future;
  final _categories = const ['All', 'History', 'Spirituality', 'Contemporary', 'Tafsir'];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _apiService.fetchPodcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        color: AppTheme.primaryGreen,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              pinned: false,
              floating: true,
              centerTitle: false,
              title: Text('Audio', style: AppTheme.h2()),
              actions: [
                IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
                IconButton(icon: const Icon(Icons.headphones_rounded), onPressed: () {}),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(child: _buildCategoryRow()),
            SliverToBoxAdapter(child: _buildBody()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryGreen : AppTheme.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.borderLight),
              ),
              child: Text(
                _categories[i],
                style: AppTheme.caption(color: selected ? Colors.white : AppTheme.textDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Podcast>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Column(children: [
              SkeletonList(count: 1, itemHeight: 220),
              SizedBox(height: 24),
              SkeletonRow(count: 3, itemWidth: 160, itemHeight: 200),
            ]),
          );
        }
        final list = snapshot.data ?? const <Podcast>[];
        if (list.isEmpty) {
          return _empty();
        }
        final featured = list.first;
        final rest = list.skip(1).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.space5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: _featuredCard(featured),
            ),
            SectionHeader(title: 'Popular shows', actionLabel: 'View all', onActionTap: () {}),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                itemCount: rest.isEmpty ? 1 : rest.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _showCard(rest.isEmpty ? featured : rest[i]),
              ),
            ),
            if (featured.episodes.isNotEmpty) ...[
              const SectionHeader(title: 'Recent episodes', eyebrow: 'Continue listening'),
              ...featured.episodes.take(4).map((ep) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 4),
                    child: _episodeRow(ep, featured.author),
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _featuredCard(Podcast p) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: p))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(p.imageUrl.isNotEmpty
                  ? p.imageUrl
                  : 'https://images.unsplash.com/photo-1518005020251-58d1396a6042?auto=format&fit=crop&q=80&w=800'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppTheme.primaryGreenDeep.withOpacity(0.85)],
              ),
            ),
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('FEATURED', style: AppTheme.eyebrow(color: Colors.white).copyWith(fontSize: 10)),
                ),
                const SizedBox(height: 10),
                Text(p.title, style: AppTheme.h1(color: Colors.white).copyWith(fontSize: 24), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Hosted by ${p.author}', style: AppTheme.body(color: Colors.white.withOpacity(0.86))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showCard(Podcast p) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: p))),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: AppTheme.parchment,
                  boxShadow: AppTheme.shadowSm,
                ),
                child: p.imageUrl.isNotEmpty
                    ? Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _audioFallback())
                    : _audioFallback(),
              ),
            ),
            const SizedBox(height: 10),
            Text(p.title,
                style: AppTheme.h3().copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(p.author, style: AppTheme.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _audioFallback() => Container(
        decoration: const BoxDecoration(gradient: AppTheme.gradientPrimary),
        child: const Center(child: Icon(Icons.podcasts_rounded, color: AppTheme.gold, size: 38)),
      );

  Widget _episodeRow(PodcastEpisode e, String host) {
    return QalaamTappableCard(
      padding: const EdgeInsets.all(AppTheme.space3),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: AppTheme.h3().copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('$host · ${e.duration.isNotEmpty ? e.duration : "—"}', style: AppTheme.caption()),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, color: AppTheme.textMuted),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: QalaamCard(
        padding: const EdgeInsets.all(AppTheme.space7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.podcasts_rounded, color: AppTheme.textGrey, size: 38),
            const SizedBox(height: 12),
            Text('No shows yet', style: AppTheme.h3()),
            const SizedBox(height: 4),
            Text('New audio content arriving soon.', style: AppTheme.caption()),
          ],
        ),
      ),
    );
  }
}
