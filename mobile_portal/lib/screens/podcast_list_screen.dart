import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class PodcastListScreen extends StatefulWidget {
  const PodcastListScreen({super.key});

  @override
  State<PodcastListScreen> createState() => _PodcastListScreenState();
}

class _PodcastListScreenState extends State<PodcastListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Podcast>> _podcastsFuture;
  final List<String> _categories = ["All", "History", "Spirituality", "Contemporary"];
  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _podcastsFuture = _apiService.fetchPodcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
          ),
        ),
        title: const Text("Qalaam"),
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
                    color: const Color(0xFFEBF5F1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search podcasts, scholars, or topics",
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13),
                      icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ),

              // Categories
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedCategory == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryGreen : const Color(0xFFE8F8F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : AppTheme.primaryGreen,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              FutureBuilder<List<Podcast>>(
                future: _podcastsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return _buildDemoContent(); // Fallback to demo
                  }
                  final podcasts = snapshot.data ?? [];
                  if (podcasts.isEmpty) {
                    return const Center(child: Text("No podcasts found."));
                  }
                  return _buildDynamicContent(podcasts);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicContent(List<Podcast> podcasts) {
    final featured = podcasts.first;
    final popular = podcasts.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Show
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(featured.imageUrl.isNotEmpty ? featured.imageUrl : "https://images.unsplash.com/photo-1518005020251-58d1396a6042?auto=format&fit=crop&q=80&w=800"),
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
                      "FEATURED SHOW",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    featured.title,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Hosted by ${featured.author}",
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Popular Shows
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Popular Shows", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("See All", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: popular.length,
            itemBuilder: (context, index) {
              return _buildShowCard(popular[index]);
            },
          ),
        ),

        // Recent Episodes (Taking from first show for demo)
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Episodes", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("View History", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        ...featured.episodes.take(3).map((ep) => _buildEpisodeItem(ep, featured.author)),
      ],
    );
  }

  Widget _buildDemoContent() {
    // Demo data similar to initial redesign
    return Column(
      children: [
        const Center(child: Text("Using demo data due to API error")),
        const SizedBox(height: 10),
        _buildShowCard(Podcast(id: 0, title: "Ottoman Legacies", author: "Dr. Omar Farooq", description: "", imageUrl: "https://via.placeholder.com/300", episodes: [])),
      ],
    );
  }

  Widget _buildShowCard(Podcast podcast) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              podcast.imageUrl.isNotEmpty ? podcast.imageUrl : "https://via.placeholder.com/160",
              height: 160, width: 160, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey, height: 160, width: 160, child: const Icon(Icons.podcasts)),
            ),
          ),
          const SizedBox(height: 12),
          Text(podcast.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(podcast.author, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(PodcastEpisode episode, String host) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.mic, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(episode.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("$host • ${episode.duration}", style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryGreen, size: 40),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
