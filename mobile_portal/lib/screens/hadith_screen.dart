import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/share_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/section_header.dart';
import '../widgets/geometric_pattern.dart';
import '../widgets/shimmer.dart';
import 'hadith_collection_detail_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final ApiService _apiService = ApiService();
  late Future<Hadith?> _dailyFuture;
  late Future<List<HadithCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _dailyFuture = _apiService.fetchHadithDaily();
      _collectionsFuture = _apiService.fetchHadithCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Hadith')),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => _load(),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppTheme.space7),
          children: [
            const SizedBox(height: AppTheme.space2),
            _dailyHero(),
            const SectionHeader(title: 'Collections', eyebrow: 'Browse'),
            _collectionsRow(),
            const SizedBox(height: AppTheme.space5),
            _searchPrompt(),
          ],
        ),
      ),
    );
  }

  // ── Daily hadith hero ──────────────────────────────────────
  Widget _dailyHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space3),
      child: FutureBuilder<Hadith?>(
        future: _dailyFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Shimmer(
              child: ShimmerBox(width: double.infinity, height: 220, radius: AppTheme.radiusXl),
            );
          }
          final h = snap.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: Container(
              decoration: AppTheme.cardHero,
              padding: const EdgeInsets.all(AppTheme.space6),
              child: Stack(
                children: [
                  const Positioned.fill(child: GeometricPattern(opacity: 0.07, cell: 56)),
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [AppTheme.gold.withOpacity(0.18), Colors.transparent]),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppTheme.gold.withOpacity(0.45), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppTheme.gold, size: 13),
                            const SizedBox(width: 5),
                            Text('HADITH OF THE DAY',
                                style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.space5),
                      if (h == null)
                        _heroPlaceholder()
                      else ...[
                        Text(
                          '"${h.text}"',
                          style: AppTheme.bodyLarge(color: Colors.white).copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.55,
                            fontSize: 16.5,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.space4),
                        Row(
                          children: [
                            Container(width: 22, height: 2, color: AppTheme.gold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(h.reference,
                                  style: AppTheme.caption(color: AppTheme.gold).copyWith(fontWeight: FontWeight.w800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            _heroAction(Icons.share_rounded, () => ShareService.shareHadith(
                                  context: context,
                                  text: h.text,
                                  reference: h.reference,
                                )),
                            const SizedBox(width: 6),
                            _heroAction(Icons.refresh_rounded, _load),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('No daily hadith set',
            style: AppTheme.h2(color: Colors.white).copyWith(fontSize: 20)),
        const SizedBox(height: 6),
        Text('Pull down to refresh, or check back later.',
            style: AppTheme.body(color: Colors.white.withOpacity(0.85))),
      ],
    );
  }

  Widget _heroAction(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withOpacity(0.13),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  // ── Collections row ───────────────────────────────────────
  Widget _collectionsRow() {
    return SizedBox(
      height: 130,
      child: FutureBuilder<List<HadithCollection>>(
        future: _collectionsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SkeletonRow(count: 3, itemWidth: 200, itemHeight: 130);
          }
          final list = snap.data ?? const <HadithCollection>[];
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: QalaamCard(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: Row(children: [
                  const Icon(Icons.book_outlined, color: AppTheme.textGrey),
                  const SizedBox(width: 12),
                  Expanded(child: Text('No collections yet', style: AppTheme.body())),
                ]),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _collectionCard(list[i], i),
          );
        },
      ),
    );
  }

  Widget _collectionCard(HadithCollection c, int index) {
    final tints = [
      (AppTheme.accentGreen, AppTheme.primaryGreen),
      (AppTheme.accentGold, AppTheme.gold),
      (AppTheme.accentLavender, const Color(0xFF7B5CC9)),
      (AppTheme.accentBlue, const Color(0xFF3B7DCB)),
      (AppTheme.accentRose, const Color(0xFFC85A4F)),
    ];
    final (tint, accent) = tints[index % tints.length];
    return SizedBox(
      width: 220,
      child: QalaamTappableCard(
        padding: const EdgeInsets.all(AppTheme.space4),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HadithCollectionDetailScreen(collection: c)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.menu_book_rounded, color: accent, size: 22),
            ),
            const Spacer(),
            Text(c.name, style: AppTheme.h3().copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('Browse hadiths', style: AppTheme.caption()),
          ],
        ),
      ),
    );
  }

  // ── Search-everywhere CTA ─────────────────────────────────
  Widget _searchPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
      child: QalaamCard(
        padding: const EdgeInsets.all(AppTheme.space4),
        color: AppTheme.parchment,
        border: Border.all(color: AppTheme.borderLight),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.search_rounded, color: AppTheme.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search hadiths', style: AppTheme.h3().copyWith(fontSize: 15)),
                  Text('Open a collection then use its search bar',
                      style: AppTheme.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
