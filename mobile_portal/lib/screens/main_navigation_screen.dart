import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'podcast_list_screen.dart';
import 'tasbih_screen.dart';
import 'hadith_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const QuranScreen(),
    const PodcastListScreen(),
    const HadithScreen(),
    const TasbihScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const qalaamGreen = Color(0xFF2ECC71);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: qalaamGreen,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Quran'),
          BottomNavigationBarItem(icon: Icon(Icons.podcasts_outlined), activeIcon: Icon(Icons.podcasts), label: 'Podcast'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_outlined), activeIcon: Icon(Icons.auto_stories), label: 'Hadith'),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint_outlined), activeIcon: Icon(Icons.fingerprint), label: 'Tasbih'),
        ],
      ),
    );
  }
}
