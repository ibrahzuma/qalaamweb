import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/sura.dart';
import '../services/api_service.dart';
import '../services/reading_storage.dart';
import '../services/share_service.dart';
import '../widgets/geometric_pattern.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? scrollToAyah;
  const SurahDetailScreen({super.key, required this.surah, this.scrollToAyah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _ayahsFuture;
  Set<int> _bookmarked = {};
  final ItemKeys _keys = ItemKeys();

  @override
  void initState() {
    super.initState();
    _ayahsFuture = _apiService.fetchAyahs(widget.surah.number);
    _loadBookmarks();
    // Save last-read on open
    ReadingStorage.setLastRead(
      surah: widget.surah.number,
      ayah: widget.scrollToAyah ?? 1,
      surahName: widget.surah.englishName,
    );
  }

  Future<void> _loadBookmarks() async {
    final all = await ReadingStorage.getBookmarks();
    if (!mounted) return;
    setState(() {
      _bookmarked = all
          .where((b) => b.surah == widget.surah.number)
          .map((b) => b.ayah)
          .toSet();
    });
  }

  Future<void> _toggleBookmark(int ayahNum, String text, String translation) async {
    final state = await ReadingStorage.toggleBookmark(
      surah: widget.surah.number,
      ayah: ayahNum,
      surahName: widget.surah.englishName,
      text: text,
      translation: translation,
    );
    if (!mounted) return;
    setState(() {
      if (state) {
        _bookmarked.add(ayahNum);
      } else {
        _bookmarked.remove(ayahNum);
      }
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primaryGreenDeep,
        content: Text(state ? 'Bookmarked ${widget.surah.englishName} $ayahNum:1' : 'Bookmark removed',
            style: AppTheme.body(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _appBar(),
          SliverToBoxAdapter(child: _bismillah()),
          FutureBuilder<List<dynamic>>(
            future: _ayahsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text('Error loading ayahs: ${snapshot.error}', style: AppTheme.body())),
                  ),
                );
              }
              final ayahs = snapshot.data ?? [];
              if (widget.scrollToAyah != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _keys.scrollTo(widget.scrollToAyah!));
              }
              return SliverList.builder(
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final a = ayahs[index];
                  final num = (a['ayah_number'] as int?) ?? (index + 1);
                  return KeyedSubtree(
                    key: _keys.keyFor(num),
                    child: _ayahItem(num, a['text'] ?? '', a['translation'] ?? ''),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: AppTheme.primaryGreenDeep,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(widget.surah.englishName,
          style: AppTheme.h2(color: Colors.white).copyWith(fontSize: 17)),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.gradientHero)),
            const Positioned.fill(child: GeometricPattern(opacity: 0.07, cell: 56)),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [AppTheme.gold.withOpacity(0.18), Colors.transparent]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space9, AppTheme.space5, AppTheme.space5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.surah.name,
                    style: GoogleFonts.amiri(
                      fontSize: 56,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${widget.surah.revelationType} · ${widget.surah.numberOfAyahs} verses',
                      style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 10),
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

  Widget _bismillah() {
    if (widget.surah.number == 1 || widget.surah.number == 9) {
      return const SizedBox(height: AppTheme.space4);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space5),
      child: Center(
        child: Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          style: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
        ),
      ),
    );
  }

  Widget _ayahItem(int number, String arabic, String translation) {
    final saved = _bookmarked.contains(number);
    return InkWell(
      onLongPress: () => _toggleBookmark(number, arabic, translation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: 6),
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderHair),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('$number',
                      style: AppTheme.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w800, fontSize: 11)),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  onPressed: () => _toggleBookmark(number, arabic, translation),
                  icon: Icon(
                    saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: saved ? AppTheme.gold : AppTheme.textMuted,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  onPressed: () => ShareService.shareAyah(
                    context: context,
                    arabic: arabic,
                    translation: translation,
                    reference: '${widget.surah.englishName} ${widget.surah.number}:$number',
                  ),
                  icon: const Icon(Icons.ios_share_rounded, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space3),
            Text(
              arabic,
              style: GoogleFonts.amiri(
                fontSize: 24,
                height: 2,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.right,
            ),
            if (translation.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space3),
              Text(
                translation,
                style: AppTheme.bodyLarge().copyWith(height: 1.55),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Maintains GlobalKeys per ayah number so we can scroll-to.
class ItemKeys {
  final Map<int, GlobalKey> _map = {};

  GlobalKey keyFor(int n) => _map.putIfAbsent(n, () => GlobalKey());

  void scrollTo(int n) {
    final k = _map[n];
    final ctx = k?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }
}
