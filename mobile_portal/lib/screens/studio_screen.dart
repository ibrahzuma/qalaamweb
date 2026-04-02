import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Video>> _trendingFuture;
  late Future<List<VideoSeries>> _seriesFuture;
  late Future<List<Video>> _continueWatchingFuture;
  int _selectedTab = 0;
  final List<String> _tabs = ["Featured", "History", "Documentaries", "Educational"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _trendingFuture = _apiService.fetchTrendingVideos();
      _seriesFuture = _apiService.fetchEducationalSeries();
      _continueWatchingFuture = _apiService.fetchContinueWatching();
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
          "Qalaam Studio",
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
            child: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabs[index],
                            style: GoogleFonts.outfit(
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main Banner
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=800"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "PREMIERE • 10 Episodes",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "The Golden Age",
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Journey through the intellectual and scientific heights of the Abbasid era and the House of Wisdom.",
                        style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildBannerButton(Icons.play_arrow_rounded, "Watch Now", true),
                          const SizedBox(width: 15),
                          _buildBannerButton(Icons.add, "My List", false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Trending Now
            _buildSectionHeader("Trending Now"),
            const SizedBox(height: 15),
            FutureBuilder<List<Video>>(
              future: _trendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
                }
                final videos = snapshot.data ?? [];
                return SizedBox(
                  height: 240,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    children: [
                      if (videos.isEmpty) ...[
                        _buildMovieCard("Ottoman Legacy", "Historical Drama", "4.9", "https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?auto=format&fit=crop&q=80&w=300"),
                        _buildMovieCard("Pathways to Faith", "Documentary", "4.8", "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&q=80&w=300"),
                        _buildMovieCard("Andalusia", "Educational", "4.7", "https://images.unsplash.com/photo-1524334228333-0f6db392f8a1?auto=format&fit=crop&q=80&w=300"),
                      ] else
                        ...videos.map((v) => _buildMovieCard(v.title, v.category, v.rating, v.imageUrl)).toList(),
                    ],
                  ),
                );
              },
            ),

            // Educational Series
            const SizedBox(height: 30),
            _buildSectionHeader("Educational Series"),
            const SizedBox(height: 15),
            FutureBuilder<List<VideoSeries>>(
              future: _seriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final series = snapshot.data ?? [];
                return Column(
                  children: [
                    if (series.isEmpty) ...[
                      _buildSeriesItem("Pioneers of Science", "Exploring the life and inventions of Al-Khwarizmi, Al-Biruni and more.", "24 lessons", "https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&q=80&w=200"),
                      _buildSeriesItem("The Great Libraries", "A tour of the most influential centers of learning in Islamic history.", "12 episodes", "https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&q=80&w=200"),
                    ] else
                      ...series.map((s) => _buildSeriesItem(s.title, s.description, "${s.lessonCount} lessons", s.imageUrl)).toList(),
                  ],
                );
              },
            ),

            // Continue Watching
            const SizedBox(height: 30),
            _buildSectionHeader("Continue Watching"),
            const SizedBox(height: 15),
            FutureBuilder<List<Video>>(
               future: _continueWatchingFuture,
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                 }
                 final videos = snapshot.data ?? [];
                 return SizedBox(
                   height: 180,
                   child: ListView(
                     scrollDirection: Axis.horizontal,
                     padding: const EdgeInsets.only(left: 20),
                     children: [
                       if (videos.isEmpty) ...[
                         _buildContinueWatchingCard("Desert Nomads: Ep 4", "24m remaining", "https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&q=80&w=400"),
                         _buildContinueWatchingCard("Silk Road", "52m remaining", "https://images.unsplash.com/photo-1473186578172-c141e6798ee4?auto=format&fit=crop&q=80&w=400"),
                       ] else
                         ...videos.map((v) => _buildContinueWatchingCard(v.title, v.duration, v.imageUrl)).toList(),
                     ],
                   ),
                 );
               },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_rounded), label: "Studio"),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildBannerButton(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.primaryGreen : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text("SEE ALL", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMovieCard(String title, String category, String rating, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(imageUrl, height: 180, width: 150, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(rating, style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(category, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSeriesItem(String title, String description, String lessonCount, String imageUrl) {
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
            child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Text(lessonCount.toUpperCase(), style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryGreen, size: 30),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(imageUrl, height: 120, width: 280, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
