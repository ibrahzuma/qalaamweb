import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/geometric_pattern.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _progress;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
    _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2700));
    final token = await _apiService.getAuthToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => token != null ? const MainNavigationScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Deep gradient base
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A4734), Color(0xFF051E15)],
              ),
            ),
          ),
          // Soft radial glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.gold.withOpacity(0.18),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Geometric pattern overlay
          const GeometricPattern(opacity: 0.05, cell: 64),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _Mark(animation: _entry),
                  const SizedBox(height: AppTheme.space7),
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _entry, curve: const Interval(0.4, 1.0)),
                    child: Column(
                      children: [
                        Text(
                          'Qalaam',
                          style: AppTheme.display(color: Colors.white).copyWith(
                            fontSize: 56,
                            letterSpacing: 1.2,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space3),
                        Container(width: 36, height: 2, color: AppTheme.gold),
                        const SizedBox(height: AppTheme.space4),
                        Text(
                          'A SCHOLARLY BRIDGE',
                          style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(letterSpacing: 6),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Progress
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _entry, curve: const Interval(0.6, 1.0)),
                    child: Column(
                      children: [
                        Text(
                          'Your gateway to knowledge',
                          style: AppTheme.caption(color: Colors.white.withOpacity(0.55)),
                        ),
                        const SizedBox(height: AppTheme.space4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            width: 180,
                            child: AnimatedBuilder(
                              animation: _progress,
                              builder: (_, __) => LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 3,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  final AnimationController animation;
  const _Mark({required this.animation});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.parchment],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withOpacity(0.35),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner crescent + book glyph
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
