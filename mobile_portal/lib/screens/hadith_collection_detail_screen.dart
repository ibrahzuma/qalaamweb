import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../services/share_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/shimmer.dart';

class HadithCollectionDetailScreen extends StatefulWidget {
  final HadithCollection collection;
  const HadithCollectionDetailScreen({super.key, required this.collection});

  @override
  State<HadithCollectionDetailScreen> createState() => _HadithCollectionDetailScreenState();
}

class _HadithCollectionDetailScreenState extends State<HadithCollectionDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Hadith>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _apiService.fetchHadiths(collectionSlug: widget.collection.slug);
    });
  }

  void _openHadith(Hadith h) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(h.reference,
                          style: AppTheme.eyebrow().copyWith(fontSize: 10)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: AppTheme.textGrey),
                      onPressed: () => ShareService.shareHadith(
                        context: context,
                        text: h.text,
                        reference: h.reference,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space5, AppTheme.space7),
                  children: [
                    if (h.category.isNotEmpty)
                      Text(h.category.toUpperCase(),
                          style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(letterSpacing: 1.4)),
                    const SizedBox(height: AppTheme.space3),
                    Text('Hadith ${h.reference}', style: AppTheme.h2()),
                    const SizedBox(height: AppTheme.space5),
                    Container(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: AppTheme.space5),
                    Text(h.text,
                        style: AppTheme.bodyLarge().copyWith(height: 1.6)),
                    if (h.narrator.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.space5),
                      Row(
                        children: [
                          const Icon(Icons.format_quote_rounded, color: AppTheme.gold, size: 18),
                          const SizedBox(width: 6),
                          Text('Narrated by ${h.narrator}',
                              style: AppTheme.caption().copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.collection.name, style: AppTheme.h2().copyWith(fontSize: 17)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space3),
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
                  hintText: 'Search hadiths in ${widget.collection.name}',
                  hintStyle: AppTheme.body(color: AppTheme.textMuted),
                  icon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen, size: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Hadith>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SkeletonList(count: 8, itemHeight: 110);
                }
                final all = snap.data ?? const <Hadith>[];
                final list = _query.isEmpty
                    ? all
                    : all
                        .where((h) =>
                            h.text.toLowerCase().contains(_query) ||
                            h.reference.toLowerCase().contains(_query) ||
                            h.narrator.toLowerCase().contains(_query))
                        .toList();
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.book_outlined, color: AppTheme.textGrey, size: 38),
                          const SizedBox(height: 12),
                          Text(_query.isEmpty ? 'No hadiths in this collection yet' : 'No matches for "$_query"',
                              style: AppTheme.h3(), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space5, AppTheme.space7),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _hadithCard(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hadithCard(Hadith h) {
    return QalaamTappableCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      onTap: () => _openHadith(h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(h.reference,
                    style: AppTheme.eyebrow().copyWith(fontSize: 10)),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(h.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTheme.body()),
        ],
      ),
    );
  }
}
