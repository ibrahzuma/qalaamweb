import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/dua.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Dua>> _duasFuture;
  late Future<Dua?> _dailyDuaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _duasFuture = _apiService.fetchDuas();
      _dailyDuaFuture = _apiService.fetchDailyDua();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryGreen),
          onPressed: () {},
        ),
        title: const Text("Daily Duas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryGreen),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search for a specific Dua",
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13),
                      icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ),

              // Featured "Dua of the Day"
              FutureBuilder<Dua?>(
                future: _dailyDuaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return _buildDemoFeaturedCard(); // Fallback to demo if error
                  }
                  return _buildFeaturedCard(snapshot.data!);
                },
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categories",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View All",
                        style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _buildCategoryCard("Morning & Evening", Icons.wb_sunny_rounded, const Color(0xFFE8F8F5)),
                    _buildCategoryCard("Travel & Trip", Icons.airplanemode_active_rounded, const Color(0xFFEBF5FB)),
                    _buildCategoryCard("Health & Shifa", Icons.medical_services_rounded, const Color(0xFFF4ECF7)),
                    _buildCategoryCard("Dhikr & Remembrance", Icons.favorite_rounded, const Color(0xFFFEF9E7)),
                  ],
                ),
              ),

              // Favorites
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Favorites",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              FutureBuilder<List<Dua>>(
                future: _duasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading favorites"));
                  }
                  final favorites = snapshot.data?.where((d) => d.isFavorite).toList() ?? [];
                  if (favorites.isEmpty) {
                    return _buildFavoriteItem("For Forgiveness", "Astaghfirullahal 'azim...", Icons.sentiment_satisfied_rounded);
                  }
                  return Column(
                    children: favorites.map((dua) => _buildFavoriteItem(dua.title, dua.translation, Icons.favorite)).toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Dua dua) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD1F2EB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "FEATURED",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dua.title,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF16A085),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.auto_awesome, color: Color(0xFF76D7C4), size: 40),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    dua.arabic,
                    textAlign: TextAlign.center,
                    style: AppTheme.arabicStyle.copyWith(fontSize: 22, height: 1.6),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    dua.transliteration,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\"${dua.translation}\"",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppTheme.primaryGreen),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(dua.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_outline, color: AppTheme.primaryGreen),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: const Text("Listen"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
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
  }

  Widget _buildDemoFeaturedCard() {
    // Return the same featured card but with dummy data if backend fails
    return _buildFeaturedCard(Dua(
      id: 0,
      title: "Dua of the Day",
      arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا",
      transliteration: "Allahumma inni as'aluka 'ilman nafi'an...",
      translation: "O Allah, I ask You for knowledge that is of benefit...",
      category: "Daily",
    ));
  }

  Widget _buildCategoryCard(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite, color: AppTheme.primaryGreen),
        ],
      ),
    );
  }
}
