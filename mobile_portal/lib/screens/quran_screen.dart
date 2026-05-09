import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/reading_storage.dart';
import '../models/sura.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/geometric_pattern.dart';
import '../widgets/shimmer.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Surah>> _surahsFuture;
  int _selectedTab = 0;
  String _query = '';
  LastRead? _lastRead;
  List<Surah> _surahsCache = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _refreshLastRead();
  }

  Future<void> _refreshLastRead() async {
    final lr = await ReadingStorage.getLastRead();
    if (mounted) setState(() => _lastRead = lr);
  }

  void _load() {
    setState(() {
      _surahsFuture = _apiService.fetchSurahs().then((list) {
        _surahsCache = list;
        return list;
      });
    });
  }

  Surah _surahFor(int number) {
    for (final s in _surahsCache) {
      if (s.number == number) return s;
    }
    return Surah(
      number: number,
      name: '',
      englishName: 'Surah $number',
      englishNameTranslation: '',
      numberOfAyahs: 0,
      revelationType: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => _load(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              pinned: false,
              floating: true,
              title: Text('Quran', style: AppTheme.h2()),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_outline_rounded, color: AppTheme.textDark),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: AppTheme.textDark),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(child: _buildContinueCard()),
            SliverToBoxAdapter(child: _buildSearchAndToggle()),
            SliverToBoxAdapter(child: _buildList()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueCard() {
    final lr = _lastRead;
    final isReady = lr != null;
    final surah = isReady ? _surahFor(lr.surah) : null;
    final totalAyahs = surah?.numberOfAyahs ?? 0;
    final percent = (isReady && totalAyahs > 0)
        ? ((lr.ayah / totalAyahs) * 100).clamp(0, 100).toStringAsFixed(0)
        : null;

    final title = isReady
        ? (lr.surahName.isNotEmpty
            ? lr.surahName
            : (surah?.englishName ?? 'Surah ${lr.surah}'))
        : 'Begin reading the Quran';
    final subtitle = isReady
        ? 'Ayah ${lr.ayah}${(surah?.numberOfAyahs ?? 0) > 0 ? " of ${surah!.numberOfAyahs}" : ""}'
        : '114 surahs · 6,236 ayahs · tap to start';
    final eyebrow = isReady ? 'CONTINUE READING' : 'GET STARTED';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space5, AppTheme.space5),
      child: GestureDetector(
        onTap: () {
          final target = isReady ? _surahFor(lr.surah) : _surahFor(1);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surah: target,
                scrollToAyah: isReady ? lr.ayah : null,
              ),
            ),
          ).then((_) => _refreshLastRead());
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.space6),
            decoration: AppTheme.cardHero,
            child: Stack(
              children: [
                const Positioned.fill(child: GeometricPattern(opacity: 0.07, cell: 50)),
                Positioned(
                  bottom: -20,
                  right: -10,
                  child: Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.10), size: 130),
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
                          Icon(isReady ? Icons.bookmark_rounded : Icons.auto_stories_rounded, color: AppTheme.gold, size: 12),
                          const SizedBox(width: 5),
                          Text(eyebrow, style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.space5),
                    Text(title, style: AppTheme.h1(color: Colors.white).copyWith(fontSize: 28),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.body(color: Colors.white.withOpacity(0.85))),
                    const SizedBox(height: AppTheme.space5),
                    Row(
                      children: [
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            onTap: () {
                              final target = isReady ? _surahFor(lr.surah) : _surahFor(1);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                    surah: target,
                                    scrollToAyah: isReady ? lr.ayah : null,
                                  ),
                                ),
                              ).then((_) => _refreshLastRead());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isReady ? Icons.play_arrow_rounded : Icons.menu_book_rounded,
                                      color: AppTheme.primaryGreen, size: 18),
                                  const SizedBox(width: 6),
                                  Text(isReady ? 'Resume' : 'Start',
                                      style: AppTheme.button(color: AppTheme.primaryGreen).copyWith(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (percent != null) ...[
                          const SizedBox(width: AppTheme.space3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Text('$percent% through surah',
                                style: AppTheme.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.borderLight),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: TextField(
              onChanged: (v) {
                setState(() {
                  _query = v.toLowerCase();
                });
              },
              style: AppTheme.body(color: AppTheme.textDark),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Surah, ayah or keyword',
                hintStyle: AppTheme.body(color: AppTheme.textMuted),
                icon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen, size: 20),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space5),
          Row(
            children: [
              Text('Surahs', style: AppTheme.h2()),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.parchment,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    _toggleTab('Surah', 0),
                    _toggleTab('Juz', 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, int i) {
    final selected = _selectedTab == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: AppTheme.button(color: selected ? Colors.white : AppTheme.textGrey).copyWith(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Surah>>(
      future: _surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonList(count: 8, itemHeight: 78);
        }
        final list = (snapshot.data ?? _demoSurahs())
            .where((s) =>
                _query.isEmpty ||
                s.englishName.toLowerCase().contains(_query) ||
                s.englishNameTranslation.toLowerCase().contains(_query))
            .toList();
        return Column(
          children: list.map(_surahTile).toList(),
        );
      },
    );
  }

  List<Surah> _demoSurahs() => [
        Surah(number: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'MECCAN'),
        Surah(number: 2, name: 'البقرة', englishName: 'Al-Baqarah', englishNameTranslation: 'The Cow', numberOfAyahs: 286, revelationType: 'MEDINAN'),
        Surah(number: 3, name: 'آل عمران', englishName: "Ali 'Imran", englishNameTranslation: 'Family of Imran', numberOfAyahs: 200, revelationType: 'MEDINAN'),
      ];

  Widget _surahTile(Surah surah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 6),
      child: QalaamTappableCard(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: surah))),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(44, 44), painter: _StarBadgePainter()),
                Text(
                  surah.number.toString(),
                  style: AppTheme.h3(color: AppTheme.primaryGreen).copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.englishName, style: AppTheme.h3()),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(surah.englishNameTranslation,
                          style: AppTheme.caption()),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(color: AppTheme.textMuted, shape: BoxShape.circle),
                      ),
                      Text('${surah.numberOfAyahs} verses', style: AppTheme.caption()),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              surah.name,
              style: AppTheme.arabicLarge(color: AppTheme.primaryGreen).copyWith(fontSize: 22, height: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const points = 8;
    final cx = size.width / 2, cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.78;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = i * math.pi / points - math.pi / 2;
      final p = Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
