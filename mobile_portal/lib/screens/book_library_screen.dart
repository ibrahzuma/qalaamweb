import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({super.key});

  @override
  State<BookLibraryScreen> createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Article>> _articlesFuture;
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _articlesFuture = _apiService.fetchArticles();
      _booksFuture = _apiService.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.menu_rounded, color: AppTheme.primaryGreen),
        ),
        title: Text(
          "Qalaam",
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryGreen),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search books, authors...",
                    hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13),
                    icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                  ),
                ),
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Categories", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View all", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  _buildCategoryCircle(Icons.menu_book_rounded, "Theology", const Color(0xFFE8F8F5)),
                  _buildCategoryCircle(Icons.edit_note_rounded, "Jurisprudence", const Color(0xFFFDF2E9)),
                  _buildCategoryCircle(Icons.person_rounded, "Biography", const Color(0xFFEEF2FF)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Featured Reading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Featured Reading", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 340, child: Center(child: CircularProgressIndicator()));
                }
                final books = snapshot.data ?? [];
                return SizedBox(
                  height: 340,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    children: [
                      if (books.isEmpty) ...[
                        _buildFeaturedCard("Islamic Art & Architecture", "Dr. Ahmed Al-Farsi", "NEW RELEASE", "https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=600"),
                        _buildFeaturedCard("Foundations of Faith", "Sheikh Zaid Mansur", "TRENDING", "https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=600"),
                      ] else
                        ...books.map((b) => _buildFeaturedCard(b.title, b.author, b.category.toUpperCase(), b.imageUrl)).toList(),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // My Library
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("My Library", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("12 books >", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<Article>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final articles = snapshot.data ?? [];
                return Column(
                  children: [
                    if (articles.isEmpty) ...[
                      _buildLibraryItem("Al-Andalus: The Golden Age", "Yusuf Mansur", 0.65, "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=200"),
                      _buildLibraryItem("Spiritual Growth in Islam", "Imam Al-Ghazali Study", 0.12, "https://images.unsplash.com/photo-1589998059171-988d887df646?auto=format&fit=crop&q=80&w=200"),
                    ] else
                      ...articles.map((a) => _buildLibraryItem(a.title, a.author, 0.5, a.imageUrl)).toList(),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Browse"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildCategoryCircle(IconData icon, String label, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(right: 25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String author, String badge, String imageUrl) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badge == "NEW RELEASE" ? AppTheme.primaryGreen : Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(badge, style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(author, style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLibraryItem(String title, String author, double progress, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, width: 60, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(author, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(10))),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(height: 4, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text("${(progress * 100).toInt()}% Completed", style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryGreen, size: 24),
          ),
        ],
      ),
    );
  }
}
