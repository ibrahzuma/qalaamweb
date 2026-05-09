import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/share_service.dart';
import '../models/dua.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/geometric_pattern.dart';
import '../widgets/shimmer.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Dua>> _duasFuture;
  late Future<Dua?> _dailyFuture;
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _duasFuture = _apiService.fetchDuas();
      _dailyFuture = _apiService.fetchDailyDua();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Duas')),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => _load(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _dailyHero()),
            SliverToBoxAdapter(child: _searchBar()),
            SliverToBoxAdapter(child: _categoryChips()),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space2)),
            FutureBuilder<List<Dua>>(
              future: _duasFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: SkeletonList(count: 6, itemHeight: 120),
                  );
                }
                final all = snap.data ?? const <Dua>[];
                final list = all.where((d) {
                  if (_selectedCategory != 'All' && d.category != _selectedCategory) return false;
                  if (_query.isEmpty) return true;
                  return d.title.toLowerCase().contains(_query) ||
                      d.translation.toLowerCase().contains(_query) ||
                      d.transliteration.toLowerCase().contains(_query) ||
                      d.arabic.contains(_query);
                }).toList();
                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          _query.isNotEmpty ? 'No duas match "$_query"' : 'No duas in this category',
                          style: AppTheme.body(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
                    child: _duaCard(list[i]),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space7)),
          ],
        ),
      ),
    );
  }

  // ── Daily dua hero ─────────────────────────────────────────
  Widget _dailyHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space3),
      child: FutureBuilder<Dua?>(
        future: _dailyFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Shimmer(child: ShimmerBox(width: double.infinity, height: 220, radius: AppTheme.radiusXl));
          }
          final d = snap.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: Container(
              decoration: AppTheme.cardHero,
              padding: const EdgeInsets.all(AppTheme.space6),
              child: Stack(
                children: [
                  const Positioned.fill(child: GeometricPattern(opacity: 0.07, cell: 50)),
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
                            const Icon(Icons.volunteer_activism_rounded, color: AppTheme.gold, size: 13),
                            const SizedBox(width: 5),
                            Text('DUA OF THE DAY',
                                style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.space5),
                      if (d == null)
                        Text('No daily dua set',
                            style: AppTheme.h2(color: Colors.white).copyWith(fontSize: 19))
                      else ...[
                        if (d.arabic.isNotEmpty)
                          Text(d.arabic,
                              style: AppTheme.arabicLarge(color: Colors.white).copyWith(fontSize: 22),
                              textAlign: TextAlign.right),
                        const SizedBox(height: AppTheme.space3),
                        Text(
                          d.translation.isNotEmpty ? d.translation : d.title,
                          style: AppTheme.bodyLarge(color: Colors.white.withOpacity(0.9))
                              .copyWith(fontStyle: FontStyle.italic, height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.space4),
                        Row(
                          children: [
                            if (d.reference.isNotEmpty) ...[
                              Container(width: 22, height: 2, color: AppTheme.gold),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(d.reference,
                                    style: AppTheme.caption(color: AppTheme.gold).copyWith(fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ] else
                              const Spacer(),
                            _heroBtn(Icons.share_rounded, () => ShareService.shareHadith(
                                  context: context,
                                  text: d.translation.isNotEmpty ? d.translation : d.title,
                                  reference: d.category,
                                  arabic: d.arabic,
                                )),
                            const SizedBox(width: 6),
                            _heroBtn(Icons.refresh_rounded, _load),
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

  Widget _heroBtn(IconData icon, VoidCallback onTap) {
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

  // ── Search bar ─────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space5, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderLight),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: TextField(
          onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
          style: AppTheme.body(color: AppTheme.textDark),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search a dua, topic or word',
            hintStyle: AppTheme.body(color: AppTheme.textMuted),
            icon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen, size: 20),
          ),
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────
  Widget _categoryChips() {
    return FutureBuilder<List<Dua>>(
      future: _duasFuture,
      builder: (context, snap) {
        final cats = <String>{'All'};
        if (snap.hasData) {
          for (final d in snap.data!) {
            if (d.category.isNotEmpty) cats.add(d.category);
          }
        }
        final list = cats.toList();
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 6),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = list[i];
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryGreen : AppTheme.surface,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.borderLight),
                  ),
                  child: Text(
                    cat.length > 30 ? '${cat.substring(0, 30)}…' : cat,
                    style: AppTheme.caption(color: selected ? Colors.white : AppTheme.textDark)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Dua card ──────────────────────────────────────────────
  Widget _duaCard(Dua d) {
    return QalaamTappableCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      onTap: () => _openDua(d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    d.category.length > 28 ? '${d.category.substring(0, 28)}…' : d.category,
                    style: AppTheme.eyebrow().copyWith(fontSize: 9.5, letterSpacing: 1.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Spacer(),
              if (d.audioUrl.isNotEmpty)
                const Icon(Icons.play_circle_outline_rounded, color: AppTheme.primaryGreen, size: 20),
            ],
          ),
          if (d.arabic.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(d.arabic,
                style: AppTheme.arabicStyle.copyWith(fontSize: 22, height: 1.6, color: AppTheme.textDark),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 6),
          Text(
            d.translation.isNotEmpty ? d.translation : d.title,
            style: AppTheme.body(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openDua(Dua d) {
    final audio = AudioPlayer();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (sheetCtx, setSheet) {
        bool playing = false;
        return DraggableScrollableSheet(
          initialChildSize: 0.86,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(99)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space4, AppTheme.space5, AppTheme.space2),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(d.category,
                              style: AppTheme.eyebrow().copyWith(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const Spacer(),
                      if (d.audioUrl.isNotEmpty)
                        IconButton(
                          icon: Icon(playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                              color: AppTheme.primaryGreen, size: 30),
                          onPressed: () async {
                            if (playing) {
                              await audio.pause();
                              setSheet(() => playing = false);
                            } else {
                              try {
                                await audio.setUrl(d.audioUrl);
                                await audio.play();
                                setSheet(() => playing = true);
                              } catch (_) {}
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppTheme.textGrey),
                        onPressed: () => ShareService.shareHadith(
                          context: context,
                          text: d.translation.isNotEmpty ? d.translation : d.title,
                          reference: d.reference.isNotEmpty ? d.reference : d.category,
                          arabic: d.arabic,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
                        onPressed: () {
                          audio.dispose();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space5, AppTheme.space7),
                    children: [
                      Text(d.title, style: AppTheme.h2()),
                      const SizedBox(height: AppTheme.space5),
                      if (d.arabic.isNotEmpty) ...[
                        Container(height: 1, color: AppTheme.borderLight),
                        const SizedBox(height: AppTheme.space5),
                        Text(d.arabic,
                            style: AppTheme.arabicStyle.copyWith(fontSize: 26, height: 2.0, color: AppTheme.textDark),
                            textAlign: TextAlign.right),
                      ],
                      if (d.transliteration.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.space4),
                        Text(d.transliteration,
                            style: AppTheme.body().copyWith(fontStyle: FontStyle.italic, height: 1.6, color: AppTheme.textGrey)),
                      ],
                      if (d.translation.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.space4),
                        Text('Translation', style: AppTheme.eyebrow().copyWith(fontSize: 10)),
                        const SizedBox(height: 6),
                        Text(d.translation, style: AppTheme.bodyLarge().copyWith(height: 1.55)),
                      ],
                      if (d.reference.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.space5),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.space3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Row(children: [
                            const Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(d.reference,
                                style: AppTheme.caption(color: AppTheme.textDark).copyWith(fontWeight: FontWeight.w700))),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ).whenComplete(() => audio.dispose());
  }
}
