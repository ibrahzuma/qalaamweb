import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _ayahFuture = _apiService.fetchDailyAyah();
      _insightsFuture = _apiService.fetchArticles();
    });

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _prayerTimesFuture = _apiService.fetchPrayerTimes(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _prayerTimesFuture = Future.value(null);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen, size: 24),
          ),
        ),
        title: Text(
          "Qalaam",
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryGreen),
            ),
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
                  color: const Color(0xFFF2F6F5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search surah, ayah, or insights",
                    hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 14),
                    icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                  ),
                ),
              ),
            ),

            // Ayah of the Day
            FutureBuilder<DailyAyah?>(
              future: _ayahFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                }
                final ayah = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "AYAH OF THE DAY",
                          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          ayah?.text ?? "رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا",
                          style: GoogleFonts.amiri(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          ayah != null ? "\"${ayah.translation}\" (${ayah.reference})" : "\"Our Lord, let not our hearts deviate after You have guided us...\" (3:8)",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share_rounded, size: 18),
                                label: const Text("Share"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.bookmark_rounded, size: 18),
                                label: const Text("Save"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // Prayer Times Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Prayer Times", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 14),
                        const SizedBox(width: 4),
                        Text("London, UK", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Prayer Times Horizontal List
            FutureBuilder<PrayerTimes?>(
              future: _prayerTimesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()));
                }
                final times = snapshot.data;
                return SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    children: [
                      _buildPrayerBox("Fajr", times?.fajr ?? "05:12"),
                      _buildPrayerBox("Dhuhr", times?.dhuhr ?? "12:30", isHighlighted: true),
                      _buildPrayerBox("Asr", times?.asr ?? "15:45"),
                      _buildPrayerBox("Maghrib", times?.maghrib ?? "18:12"),
                      _buildPrayerBox("Isha", times?.isha ?? "20:05"),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // Quick Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Quick Links", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickLink(Icons.library_books_rounded, "Library", const Color(0xFFEBF5FF), Colors.blue),
                  _buildQuickLink(Icons.play_circle_fill_rounded, "Media", const Color(0xFFFFF4EB), Colors.orange),
                  _buildQuickLink(Icons.help_center_rounded, "Q&A", const Color(0xFFF7EBFF), Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Latest Insights
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Latest Insights", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Text("View All", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<Article>>(
              future: _insightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final articles = snapshot.data ?? [];
                return Column(
                  children: [
                    if (articles.isEmpty) ...[
                      _buildInsightCard("THEOLOGY", "Understanding Tawhid in Modern Times", "A deep dive into the core principles of...", "https://images.unsplash.com/photo-1594911776510-75d1d6118b6e?auto=format&fit=crop&q=80&w=400"),
                      _buildInsightCard("SPIRITUALITY", "The Art of Mindfulness in Prayer", "How to achieve khushu and presence in...", "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&q=80&w=400"),
                    ] else
                      ...articles.map((a) => _buildInsightCard(a.author.toUpperCase(), a.title, a.content, a.imageUrl)).toList(),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Read"),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: "Learn"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildPrayerBox(String name, String time, {bool isHighlighted = false}) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: isHighlighted ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: GoogleFonts.outfit(color: isHighlighted ? Colors.white.withOpacity(0.7) : AppTheme.textGrey, fontSize: 13)),
          const SizedBox(height: 5),
          Text(time, style: GoogleFonts.outfit(color: isHighlighted ? Colors.white : AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickLink(IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String category, String title, String subtitle, String imageUrl) {
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
            child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
