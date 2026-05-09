import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'podcast_list_screen.dart';
import 'reels_screen.dart';
import 'tasbih_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const _items = <_NavItem>[
    _NavItem('Home', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Quran', Icons.menu_book_rounded, Icons.menu_book_outlined),
    _NavItem('Reels', Icons.play_circle_fill_rounded, Icons.play_circle_outline_rounded),
    _NavItem('Audio', Icons.headphones_rounded, Icons.headphones_outlined),
    _NavItem('Tasbih', Icons.fingerprint_rounded, Icons.fingerprint_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const QuranScreen(),
          ReelsScreen(isCurrentTab: _selectedIndex == 2),
          const PodcastListScreen(),
          const TasbihScreen(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppTheme.borderHair, width: 1),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Row(
                children: List.generate(_items.length, (i) {
                  final active = i == _selectedIndex;
                  return _NavTile(
                    item: _items[i],
                    active: active,
                    onTap: () => setState(() => _selectedIndex = i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData iconActive;
  final IconData iconInactive;
  const _NavItem(this.label, this.iconActive, this.iconInactive);
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: active ? 5 : 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: EdgeInsets.symmetric(horizontal: active ? 14 : 0),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.gradientPrimary : null,
            borderRadius: BorderRadius.circular(99),
            boxShadow: active ? AppTheme.shadowGlow(AppTheme.primaryGreen) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? item.iconActive : item.iconInactive,
                size: active ? 22 : 24,
                color: active ? Colors.white : AppTheme.textGrey,
              ),
              if (active)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    item.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.button(color: Colors.white).copyWith(fontSize: 12.5, letterSpacing: 0.1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
