import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isPlaying = false;
  double _currentSliderValue = 12.45;
  final double _totalDuration = 45.30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textDark, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "NOW PLAYING",
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Cover Art
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                height: MediaQuery.of(context).size.width - 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=800"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title and Author
            Text(
              "The Path of Mindfulness",
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Dr. Omar Suleiman",
              style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 40),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: AppTheme.primaryGreen,
                      inactiveTrackColor: AppTheme.primaryGreen.withOpacity(0.1),
                      thumbColor: AppTheme.primaryGreen,
                    ),
                    child: Slider(
                      value: _currentSliderValue,
                      max: _totalDuration,
                      onChanged: (value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("12:45", style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13)),
                        Text("45:30", style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Playback Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle, color: AppTheme.textGrey),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: AppTheme.textDark, size: 40),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: AppTheme.textDark, size: 40),
                  onPressed: () {},
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.repeat_rounded, color: AppTheme.textGrey),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionIcon(Icons.favorite_rounded, "1.2k"),
                  _buildActionIcon(Icons.save_alt_rounded, "Save"),
                  _buildActionIcon(Icons.share_rounded, "Share"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Related Lectures Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Related Lectures", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View All", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Related Lectures List
            _buildRelatedItem("Finding Inner Peace", "Dr. Omar Suleiman", "32:10", "https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=150"),
            _buildRelatedItem("Gratitude in Hardship", "Imam Zaid Shakir", "18:45", "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&q=80&w=150"),
            _buildRelatedItem("The Power of Patience", "Sheikh Yasir Qadhi", "55:20", "https://images.unsplash.com/photo-1524334228333-0f6db392f8a1?auto=format&fit=crop&q=80&w=150"),

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
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textGrey),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _buildRelatedItem(String title, String author, String duration, String imageUrl) {
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
            child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("$author • $duration", style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryGreen.withOpacity(0.4), size: 36),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
