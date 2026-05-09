import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/reading_storage.dart';
import '../services/share_service.dart';
import '../models/app_models.dart';
import '../models/sura.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/section_header.dart';
import '../widgets/geometric_pattern.dart';
import '../widgets/shimmer.dart';
import 'prayer_times_screen.dart';
import 'book_library_screen.dart';
import 'studio_screen.dart';
import 'fatwa_screen.dart';
import 'article_list_screen.dart';
import 'mosque_finder_screen.dart';
import 'tasbih_screen.dart';
import 'qiblah_screen.dart';
import 'bookmarks_screen.dart';
import 'surah_detail_screen.dart';
import 'quran_screen.dart';
import 'hadith_screen.dart';
import 'dua_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<DailyAyah?> _ayahFuture;
  late Future<PrayerTimes?> _prayerTimesFuture;
  late Future<List<Article>> _insightsFuture;
  LastRead? _lastRead;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshLastRead();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refreshLastRead() async {
    final lr = await ReadingStorage.getLastRead();
    if (mounted) setState(() => _lastRead = lr);
  }

  DateTime? _parseHM(String hhmm) {
    if (hhmm.isEmpty || hhmm.contains('-')) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(_now.year, _now.month, _now.day, h, m);
  }

  ({String? currentName, String? nextName, DateTime? nextAt}) _resolveNext(PrayerTimes? t) {
    if (t == null) return (currentName: null, nextName: null, nextAt: null);
    final list = <MapEntry<String, DateTime?>>[
      MapEntry('Fajr', _parseHM(t.fajr)),
      MapEntry('Dhuhr', _parseHM(t.dhuhr)),
      MapEntry('Asr', _parseHM(t.asr)),
      MapEntry('Maghrib', _parseHM(t.maghrib)),
      MapEntry('Isha', _parseHM(t.isha)),
    ].where((e) => e.value != null).toList();
    if (list.isEmpty) return (currentName: null, nextName: null, nextAt: null);
    String? currentName;
    String? nextName;
    DateTime? nextAt;
    for (final e in list) {
      if (!e.value!.isAfter(_now)) {
        currentName = e.key;
      } else {
        nextName ??= e.key;
        nextAt ??= e.value;
      }
    }
    if (nextName == null) {
      nextName = 'Fajr';
      final f = list.first.value;
      if (f != null) nextAt = f.add(const Duration(days: 1));
    }
    return (currentName: currentName, nextName: nextName, nextAt: nextAt);
  }

  String _formatUntil(DateTime target) {
    final diff = target.difference(_now);
    if (diff.isNegative) return 'now';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }

  void _loadData() async {
    setState(() {
      _ayahFuture = _apiService.fetchDailyAyah();
      _insightsFuture = _apiService.fetchArticles();
      _prayerTimesFuture = Future.value(null);
    });
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final future = _apiService.fetchPrayerTimes(position.latitude, position.longitude);
      setState(() {
        _prayerTimesFuture = future;
      });
      // Fire-and-forget: schedule prayer notifications when fresh times land.
      future.then((times) {
        if (times != null) NotificationService.schedulePrayerTimes(times);
      }).catchError((_) {});
    } catch (_) {}
  }

  String get _timeOfDayGreeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'Peaceful night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Peaceful night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildHeroAyah()),
            SliverToBoxAdapter(child: _buildContinueReading()),
            SliverToBoxAdapter(child: _buildPrayerStrip()),
            SliverToBoxAdapter(child: _buildQuickGrid()),
            SliverToBoxAdapter(child: _buildInsightsHeader()),
            SliverToBoxAdapter(child: _buildInsightsList()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // App bar
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AppTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 76,
      automaticallyImplyLeading: false,
      titleSpacing: AppTheme.space5,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_timeOfDayGreeting, style: AppTheme.caption()),
                const SizedBox(height: 2),
                Text('As-salaamu alaykum', style: AppTheme.h3()),
              ],
            ),
          ),
          _IconButton(
            icon: Icons.bookmark_outline_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))
                .then((_) => _refreshLastRead()),
          ),
          const SizedBox(width: 8),
          _IconButton(
            icon: Icons.settings_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Hero Ayah card
  // ─────────────────────────────────────────────────────────
  Widget _buildHeroAyah() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space4, AppTheme.space5, AppTheme.space4),
      child: FutureBuilder<DailyAyah?>(
        future: _ayahFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final ayah = snapshot.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: Container(
              decoration: AppTheme.cardHero,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: GeometricPattern(opacity: 0.08, cell: 60),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppTheme.gold.withOpacity(0.18),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_stories_rounded, color: AppTheme.gold, size: 13),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AYAH OF THE DAY',
                                    style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (ayah != null)
                              Text(ayah.reference, style: AppTheme.caption(color: Colors.white.withOpacity(0.7))),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space5),
                        if (isLoading)
                          _buildAyahSkeleton()
                        else if (ayah == null)
                          _buildAyahEmpty()
                        else ...[
                          Text(
                            ayah.text,
                            style: AppTheme.arabicLarge(color: Colors.white).copyWith(fontSize: 26),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: AppTheme.space4),
                          Text(
                            ayah.translation,
                            style: AppTheme.bodyLarge(color: Colors.white.withOpacity(0.86)).copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.55,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.space6),
                        Row(
                          children: [
                            _heroAction(Icons.share_rounded, 'Share', () {
                              if (ayah != null) {
                                ShareService.shareAyah(
                                  context: context,
                                  arabic: ayah.text,
                                  translation: ayah.translation,
                                  reference: ayah.reference,
                                );
                              }
                            }),
                            const SizedBox(width: AppTheme.space3),
                            _heroAction(Icons.bookmark_outline_rounded, 'Save', () async {
                              if (ayah == null) return;
                              final parts = ayah.reference.split(':');
                              if (parts.length < 2) return;
                              final s = int.tryParse(parts[0]);
                              final a = int.tryParse(parts[1]);
                              if (s == null || a == null) return;
                              final state = await ReadingStorage.toggleBookmark(
                                surah: s,
                                ayah: a,
                                surahName: 'Surah $s',
                                text: ayah.text,
                                translation: ayah.translation,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: AppTheme.primaryGreenDeep,
                                content: Text(state ? 'Saved to bookmarks' : 'Removed from bookmarks',
                                    style: AppTheme.body(color: Colors.white)),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ));
                            }),
                            const Spacer(),
                            _heroAction(Icons.refresh_rounded, '', _loadData, compact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroAction(IconData icon, String label, VoidCallback onTap, {bool compact = false}) {
    return Material(
      color: Colors.white.withOpacity(0.13),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(label, style: AppTheme.button(color: Colors.white).copyWith(fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildAyahSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _shimmerBar(double.infinity, 22),
        const SizedBox(height: 10),
        _shimmerBar(MediaQuery.of(context).size.width * 0.55, 22),
        const SizedBox(height: AppTheme.space4),
        Align(
          alignment: Alignment.centerLeft,
          child: _shimmerBar(double.infinity, 14),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: _shimmerBar(MediaQuery.of(context).size.width * 0.6, 14),
        ),
      ],
    );
  }

  Widget _buildAyahEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.space2),
        Text(
          'No Ayah of the Day set',
          style: AppTheme.h2(color: Colors.white).copyWith(fontSize: 19),
        ),
        const SizedBox(height: 8),
        Text(
          'Pull down to refresh, or check back later.',
          style: AppTheme.body(color: Colors.white.withOpacity(0.85)).copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // Continue reading (last-read ayah)
  // ─────────────────────────────────────────────────────────
  Widget _buildContinueReading() {
    final lr = _lastRead;
    if (lr == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space5, AppTheme.space2),
      child: QalaamTappableCard(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surah: Surah(
                  number: lr.surah,
                  name: lr.surahName,
                  englishName: lr.surahName.isNotEmpty ? lr.surahName : 'Surah ${lr.surah}',
                  englishNameTranslation: '',
                  numberOfAyahs: 0,
                  revelationType: '',
                ),
                scrollToAyah: lr.ayah,
              ),
            ),
          ).then((_) => _refreshLastRead());
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.auto_stories_rounded, color: AppTheme.gold, size: 20),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continue reading', style: AppTheme.caption()),
                  Text(
                    '${lr.surahName.isNotEmpty ? lr.surahName : "Surah ${lr.surah}"} · Ayah ${lr.ayah}',
                    style: AppTheme.h3(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen, size: 18),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Prayer strip
  // ─────────────────────────────────────────────────────────
  Widget _buildPrayerStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space5, AppTheme.space2),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
        child: QalaamCard(
          padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space5, AppTheme.space5, AppTheme.space4),
          child: FutureBuilder<PrayerTimes?>(
            future: _prayerTimesFuture,
            builder: (context, snapshot) {
              final t = snapshot.data;
              final r = _resolveNext(t);
              final headerLabel = (t == null)
                  ? 'Locating you…'
                  : (r.nextName != null && r.nextAt != null)
                      ? 'Next: ${r.nextName} · ${_pickTimeFor(t, r.nextName!)} · in ${_formatUntil(r.nextAt!)}'
                      : 'Today\'s prayers';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.access_time_rounded, color: AppTheme.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Today\'s prayers', style: AppTheme.caption()),
                            Text(headerLabel,
                                style: AppTheme.h3(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _prayerPill('Fajr', t?.fajr, Icons.dark_mode_outlined,
                            highlighted: r.currentName == 'Fajr'),
                        _prayerPill('Dhuhr', t?.dhuhr, Icons.wb_sunny_outlined,
                            highlighted: r.currentName == 'Dhuhr'),
                        _prayerPill('Asr', t?.asr, Icons.wb_twilight_outlined,
                            highlighted: r.currentName == 'Asr'),
                        _prayerPill('Maghrib', t?.maghrib, Icons.brightness_3_outlined,
                            highlighted: r.currentName == 'Maghrib'),
                        _prayerPill('Isha', t?.isha, Icons.nights_stay_outlined,
                            highlighted: r.currentName == 'Isha'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _pickTimeFor(PrayerTimes t, String name) => switch (name) {
        'Fajr' => t.fajr,
        'Dhuhr' => t.dhuhr,
        'Asr' => t.asr,
        'Maghrib' => t.maghrib,
        'Isha' => t.isha,
        _ => '--:--',
      };

  Widget _prayerPill(String name, String? time, IconData icon, {bool highlighted = false}) {
    return Container(
      width: 86,
      margin: const EdgeInsets.only(right: AppTheme.space3),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space3, horizontal: AppTheme.space2),
      decoration: BoxDecoration(
        color: highlighted ? AppTheme.primaryGreen : AppTheme.parchment,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: highlighted ? Colors.white : AppTheme.primaryGreen, size: 16),
          const SizedBox(height: 6),
          Text(
            name,
            style: AppTheme.caption(color: highlighted ? Colors.white.withOpacity(0.8) : AppTheme.textGrey),
          ),
          const SizedBox(height: 2),
          Text(
            time ?? '--:--',
            style: AppTheme.h3(color: highlighted ? Colors.white : AppTheme.textDark).copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Quick grid
  // ─────────────────────────────────────────────────────────
  Widget _buildQuickGrid() {
    final items = [
      _QuickItem('Quran', Icons.menu_book_rounded, AppTheme.accentGreen, AppTheme.primaryGreen,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranScreen()))),
      _QuickItem('Hadith', Icons.format_quote_rounded, AppTheme.accentGold, AppTheme.gold,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithScreen()))),
      _QuickItem('Duas', Icons.volunteer_activism_rounded, AppTheme.accentRose, const Color(0xFFC85A4F),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuaScreen()))),
      _QuickItem('Tasbih', Icons.fingerprint_rounded, AppTheme.accentLavender, const Color(0xFF7B5CC9),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen()))),
      _QuickItem('Qibla', Icons.explore_rounded, AppTheme.accentBlue, const Color(0xFF3B7DCB),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblahScreen()))),
      _QuickItem('Mosques', Icons.location_on_outlined, AppTheme.accentGold, AppTheme.gold,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MosqueFinderScreen()))),
      _QuickItem('Library', Icons.library_books_rounded, AppTheme.accentGreen, AppTheme.primaryGreenSoft,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookLibraryScreen()))),
      _QuickItem('Q&A', Icons.help_outline_rounded, AppTheme.accentLavender, const Color(0xFF7B5CC9),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FatwaScreen()))),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space5, AppTheme.space5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore', style: AppTheme.h2()),
          const SizedBox(height: AppTheme.space3),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppTheme.space3,
              mainAxisSpacing: AppTheme.space3,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) => _quickTile(items[i]),
          ),
        ],
      ),
    );
  }

  Widget _quickTile(_QuickItem it) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: it.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space3),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderHair, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: it.tint, borderRadius: BorderRadius.circular(11)),
                child: Icon(it.icon, color: it.iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(it.label, style: AppTheme.caption(color: AppTheme.textDark).copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Insights
  // ─────────────────────────────────────────────────────────
  Widget _buildInsightsHeader() {
    return SectionHeader(
      title: 'Latest insights',
      eyebrow: 'For you',
      actionLabel: 'View all',
      onActionTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticleListScreen())),
    );
  }

  Widget _buildInsightsList() {
    return FutureBuilder<List<Article>>(
      future: _insightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonList(count: 3, itemHeight: 100);
        }
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return Column(
            children: [
              _placeholderInsight('THEOLOGY', 'Understanding Tawhid in modern times',
                  'A deep dive into the core principles of Islamic monotheism.'),
              _placeholderInsight('SPIRITUALITY', 'The art of khushu in prayer',
                  'How to achieve presence and stillness in daily salah.'),
              _placeholderInsight('HISTORY', 'The Golden Age of scholarship',
                  'A tour through Baghdad\'s House of Wisdom and its legacy.'),
            ],
          );
        }
        return Column(
          children: articles
              .map((a) => GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const ArticleListScreen())),
                    child: _insightCard(a.author.toUpperCase(), a.title, a.content, a.imageUrl),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _placeholderInsight(String cat, String title, String body) =>
      _insightCard(cat, title, body, null);

  Widget _insightCard(String category, String title, String subtitle, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 6),
      child: QalaamTappableCard(
        padding: const EdgeInsets.all(AppTheme.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(category),
                    )
                  : _imagePlaceholder(category),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: AppTheme.eyebrow().copyWith(fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(title, style: AppTheme.h3(), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(String category) {
    final tint = {
      'THEOLOGY': AppTheme.accentGreen,
      'SPIRITUALITY': AppTheme.accentBlue,
      'HISTORY': AppTheme.accentGold,
      'SCIENCE': AppTheme.accentLavender,
    }[category] ?? AppTheme.parchment;
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 32),
    );
  }
}

class _QuickItem {
  final String label;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;
  _QuickItem(this.label, this.icon, this.tint, this.iconColor, this.onTap);
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;
  const _IconButton({required this.icon, required this.onTap, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.borderHair)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: AppTheme.textDark, size: 19),
            ),
          ),
        ),
        if (dot)
          Positioned(
            top: 7,
            right: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
