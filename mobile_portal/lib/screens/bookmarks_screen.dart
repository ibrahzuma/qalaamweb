import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/reading_storage.dart';
import '../widgets/qalaam_card.dart';
import '../models/sura.dart';
import 'surah_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<List<Bookmark>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = ReadingStorage.getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Bookmarks')),
      body: FutureBuilder<List<Bookmark>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          final list = snapshot.data ?? const <Bookmark>[];
          if (list.isEmpty) {
            return _empty();
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space7),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space3),
            itemBuilder: (_, i) => _bookmarkCard(list[i]),
          );
        },
      ),
    );
  }

  Widget _bookmarkCard(Bookmark b) {
    return QalaamTappableCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      onTap: () {
        // Open the surah at the bookmarked ayah.
        final surah = Surah(
          number: b.surah,
          name: b.surahName,
          englishName: b.surahName,
          englishNameTranslation: '',
          numberOfAyahs: 0,
          revelationType: '',
        );
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => SurahDetailScreen(surah: surah, scrollToAyah: b.ayah),
        )).then((_) => _refresh());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${b.surah}:${b.ayah}',
                  style: AppTheme.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  b.surahName.isNotEmpty ? b.surahName : 'Surah ${b.surah}',
                  style: AppTheme.h3(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined, color: AppTheme.error, size: 20),
                onPressed: () async {
                  await ReadingStorage.removeBookmark(surah: b.surah, ayah: b.ayah);
                  _refresh();
                },
              ),
            ],
          ),
          if (b.text.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space3),
            Text(b.text, style: AppTheme.arabicStyle.copyWith(fontSize: 22), textAlign: TextAlign.right),
          ],
          if (b.translation.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space2),
            Text(b.translation, style: AppTheme.body(), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: QalaamCard(
          padding: const EdgeInsets.all(AppTheme.space7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bookmark_outline_rounded, color: AppTheme.gold, size: 28),
              ),
              const SizedBox(height: AppTheme.space4),
              Text('No bookmarks yet', style: AppTheme.h2()),
              const SizedBox(height: 4),
              Text('Long-press an ayah to save it here.',
                  style: AppTheme.body(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
