import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final ApiService _apiService = ApiService();
  late Future<Hadith?> _dailyHadithFuture;
  late Future<List<HadithCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dailyHadithFuture = _apiService.fetchHadithDaily();
      _collectionsFuture = _apiService.fetchHadithCollections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textDark),
          onPressed: () {},
        ),
        title: const Text("Qalaam Hadeeth"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Bukhari, Muslim, or topics...",
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13),
                      icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ),

              // Hadeeth of the Day
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Hadeeth of the Day",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              FutureBuilder<Hadith?>(
                future: _dailyHadithFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  final hadith = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                            child: Image.network(
                              "https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=600",
                              height: 150, width: double.infinity, fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.format_quote_rounded, color: AppTheme.primaryGreen, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "PROPHET MUHAMMAD (PBUH) SAID",
                                      style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  hadith != null ? "\"${hadith.text}\"" : "\"The best among you are those who have the best manners and character.\"",
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark, height: 1.4),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      hadith?.reference ?? "Sahih al-Bukhari 6035",
                                      style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13, fontStyle: FontStyle.italic),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 0,
                                      ),
                                      child: const Text("Read Full"),
                                    ),
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

              // Collections
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Collections", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("View All", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              FutureBuilder<List<HadithCollection>>(
                future: _collectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                  }
                  final collections = snapshot.data ?? [];
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20),
                      itemCount: collections.isNotEmpty ? collections.length : 3,
                      itemBuilder: (context, index) {
                        if (collections.isEmpty) {
                          // Fallback demo cards
                          if (index == 0) return _buildCollectionCard("Sahih al-Bukhari", "7,563 Hadeeths", Icons.menu_book_rounded);
                          if (index == 1) return _buildCollectionCard("Sahih Muslim", "3,033 Hadeeths", Icons.library_books_rounded);
                          return _buildCollectionCard("Sunan an-Nasa'i", "5,758 Hadeeths", Icons.history_edu_rounded);
                        }
                        final col = collections[index];
                        return _buildCollectionCard(col.name, "${col.count} Hadeeths", Icons.menu_book_rounded);
                      },
                    ),
                  );
                },
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Categories",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              _buildCategoryItem("Ethics (Akhlaq)", Icons.favorite_rounded, const Color(0xFFE8F8F5)),
              _buildCategoryItem("Worship (Ibadah)", Icons.mosque_rounded, const Color(0xFFEBF5FB)),
              _buildCategoryItem("Transactions (Mu'amalat)", Icons.payments_rounded, const Color(0xFFF4ECF7)),
              _buildCategoryItem("Belief (Aqidah)", Icons.explore_rounded, const Color(0xFFFEF9E7)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(String name, String count, IconData icon) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE8F8F5), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(height: 12),
          Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(count, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textGrey),
        ],
      ),
    );
  }
}
