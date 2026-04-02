import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Clip>> _clipsFuture;

  @override
  void initState() {
    super.initState();
    _clipsFuture = _apiService.fetchClips();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Clip>>(
        future: _clipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          final clips = snapshot.data ?? [];
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: clips.isEmpty ? 3 : clips.length,
            itemBuilder: (context, index) {
              if (clips.isEmpty) {
                // Fallback to static items if no clips in DB
                if (index == 0) return _buildReelItem("scholar_ali", "Understanding the wisdom behind patience (Sabr). #Wisdom #Islam", "12.4K", "1.2K", "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&q=80&w=600");
                if (index == 1) return _buildReelItem("qalaam_studio", "The Golden Age of Andalusia: A quick tour. #History #AlAndalus", "8.1K", "540", "https://images.unsplash.com/photo-1524334228333-0f6db392f8a1?auto=format&fit=crop&q=80&w=600");
                return _buildReelItem("heart_soother", "Recitation of Surah Ar-Rahman. Beautiful scenery. #Quran #Nature", "45K", "2.1K", "https://images.unsplash.com/photo-1509233725247-49e657c54213?auto=format&fit=crop&q=80&w=600");
              }
              final clip = clips[index];
              return _buildReelItem(clip.username, clip.description, clip.likes, clip.comments, clip.videoUrl);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill_rounded), label: "Reels"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: "Ummah"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildReelItem(String username, String description, String likes, String comments, String imageUrl) {
    return Stack(
      children: [
        // Video Background Placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Gradient Overlay (Bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),

        // Side Interaction Bar
        Positioned(
          right: 20,
          bottom: 110,
          child: Column(
            children: [
              _buildInteractionIcon(Icons.favorite_rounded, likes, false),
              const SizedBox(height: 25),
              _buildInteractionIcon(Icons.chat_bubble_rounded, comments, false),
              const SizedBox(height: 25),
              _buildInteractionIcon(Icons.share_rounded, "Share", false),
              const SizedBox(height: 25),
              _buildInteractionIcon(Icons.bookmark_rounded, "Save", true),
            ],
          ),
        ),

        // Profile and Meta Details
        Positioned(
          left: 20,
          bottom: 110,
          right: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage("https://images.unsplash.com/photo-1566492031773-4f4e44671857?auto=format&fit=crop&q=80&w=150"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "@$username",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "FOLLOW",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "Original Audio - Scholar Series",
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionIcon(IconData icon, String count, bool isSpecial) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSpecial ? AppTheme.primaryGreen : Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          count,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
