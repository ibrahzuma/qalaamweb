import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/sura.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Surah>> _surahsFuture;
  int _selectedTab = 0; // 0 for All, 1 for Juz

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _surahsFuture = _apiService.fetchSurahs();
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
        title: const Text("Qalaam"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F8F5),
              child: const Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppTheme.primaryGreen,
        child: Column(
          children: [
            // Search Bar (Static for now)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Surah, Ayat, or Keyword",
                    hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 15),
                    icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Continue Reading Banner (Demo data)
                    _buildContinueReadingBanner(),

                    // Surahs header & Toggle
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Surahs",
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildToggleTab("All", 0),
                                _buildToggleTab("Juz", 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Surah List Dynamic
                    FutureBuilder<List<Surah>>(
                      future: _surahsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                        }
                        if (snapshot.hasError) {
                          return _buildDemoSurahList(); // Demo list if backend fails
                        }
                        final surahs = snapshot.data ?? [];
                        if (surahs.isEmpty) {
                          return const Center(child: Text("No surahs found."));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: surahs.length,
                          itemBuilder: (context, index) {
                            final surah = surahs[index];
                            return _buildSurahItem(surah);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bookmark_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "CONTINUE READING",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Al-Baqarah",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ayah 255 • Juz 3",
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    ),
                    child: Text(
                      "Resume",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.2), size: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSurahList() {
    final demoSurahs = [
      Surah(number: 1, name: "الفاتحة", englishName: "Al-Fatihah", englishNameTranslation: "The Opening", numberOfAyahs: 7, revelationType: "MECCAN"),
      Surah(number: 2, name: "البقرة", englishName: "Al-Baqarah", englishNameTranslation: "The Cow", numberOfAyahs: 286, revelationType: "MEDINAN"),
      Surah(number: 3, name: "آل عمران", englishName: "Ali 'Imran", englishNameTranslation: "Family of Imran", numberOfAyahs: 200, revelationType: "MEDINAN"),
    ];
    return Column(
      children: demoSurahs.map((s) => _buildSurahItem(s)).toList(),
    );
  }

  Widget _buildToggleTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(Surah surah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(40, 40),
                painter: HexagonPainter(color: const Color(0xFFE8F8F5)),
              ),
              Text(
                surah.number.toString(),
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.englishName,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Text(
                      surah.englishNameTranslation.toUpperCase(),
                      style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.brightness_1, size: 4, color: AppTheme.textGrey),
                    const SizedBox(width: 8),
                    Text(
                      surah.revelationType,
                      style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.brightness_1, size: 4, color: AppTheme.textGrey),
                    const SizedBox(width: 8),
                    Text(
                      "${surah.numberOfAyahs} Verses",
                      style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            surah.name,
            style: GoogleFonts.outfit(
              color: AppTheme.primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double width = size.width;
    double height = size.height;
    double sideLength = width / 2;
    double centerX = width / 2;
    double centerY = height / 2;

    Path path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (math.pi / 3) * i;
      double x = centerX + sideLength * math.cos(angle);
      double y = centerY + sideLength * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
