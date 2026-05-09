import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/shimmer.dart';

class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({super.key});

  @override
  State<BookLibraryScreen> createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Book>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Library')),
      body: FutureBuilder<List<Book>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.space5),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: AppTheme.space4,
                  mainAxisSpacing: AppTheme.space4,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: AppTheme.parchment,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
              ),
            );
          }
          final books = snapshot.data ?? const <Book>[];
          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 40, color: AppTheme.textGrey),
                    const SizedBox(height: 12),
                    Text('Library is empty', style: AppTheme.h3()),
                    const SizedBox(height: 4),
                    Text('New titles arriving soon.', style: AppTheme.caption()),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.space5),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: AppTheme.space4,
              mainAxisSpacing: AppTheme.space4,
            ),
            itemCount: books.length,
            itemBuilder: (_, i) => _bookCard(books[i]),
          );
        },
      ),
    );
  }

  Widget _bookCard(Book b) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.parchment,
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: b.imageUrl.isNotEmpty
                      ? Image.network(
                          b.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgFallback(b.title),
                        )
                      : _imgFallback(b.title),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(b.title, style: AppTheme.h3().copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(b.author, style: AppTheme.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback(String title) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.gradientHero),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 26),
          Text(title.toUpperCase(),
              style: AppTheme.h3(color: Colors.white).copyWith(fontSize: 14, height: 1.2),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
