import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class ReelsScreen extends StatefulWidget {
  /// True when the Reels bottom-nav tab is the active tab.
  /// When false, all videos pause. The flag is read by [_ReelPage] via
  /// [didUpdateWidget].
  final bool isCurrentTab;
  const ReelsScreen({super.key, this.isCurrentTab = true});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Reel>> _reelsFuture;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _reelsFuture = _apiService.fetchReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMute() => setState(() => _muted = !_muted);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reels',
            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(_muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white),
            onPressed: _toggleMute,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Reel>>(
        future: _reelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          final reels = snapshot.data ?? const <Reel>[];
          if (reels.isEmpty) {
            return _empty();
          }
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => _ReelPage(
              key: ValueKey(reels[index].id),
              reel: reels[index],
              // Active = page is current AND tab is current.
              isActive: index == _currentIndex && widget.isCurrentTab,
              muted: _muted,
              onMuteToggle: _toggleMute,
            ),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline_rounded, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            Text('No reels yet',
                style: GoogleFonts.manrope(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Check back soon for new short videos.',
                style: GoogleFonts.manrope(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final Reel reel;
  final bool isActive;
  final bool muted;
  final VoidCallback onMuteToggle;
  const _ReelPage({
    super.key,
    required this.reel,
    required this.isActive,
    required this.muted,
    required this.onMuteToggle,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> with SingleTickerProviderStateMixin {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  bool _userPaused = false;
  bool _liked = false;
  late AnimationController _heartCtrl;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _setupVideo();
  }

  Future<void> _setupVideo() async {
    final url = widget.reel.videoUrl;
    if (url.isEmpty) return;
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      c.setLooping(true);
      c.setVolume(widget.muted ? 0 : 1);
      if (!mounted) {
        c.dispose();
        return;
      }
      _ctrl = c;
      _ctrl!.addListener(_onTick);
      setState(() => _ready = true);
      if (widget.isActive && !_userPaused) {
        c.play();
      }
    } catch (_) {
      if (mounted) setState(() => _ready = false);
    }
  }

  void _onTick() {
    if (mounted) setState(() {}); // refresh progress bar
  }

  @override
  void didUpdateWidget(covariant _ReelPage old) {
    super.didUpdateWidget(old);
    final c = _ctrl;
    if (c != null && _ready) {
      if (widget.isActive && !old.isActive) {
        c.seekTo(Duration.zero);
        if (!_userPaused) c.play();
      } else if (!widget.isActive && old.isActive) {
        c.pause();
      }
      if (widget.muted != old.muted) {
        c.setVolume(widget.muted ? 0 : 1);
      }
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _ctrl;
    if (c == null || !_ready) return;
    setState(() {
      _userPaused = !_userPaused;
      _userPaused ? c.pause() : c.play();
    });
  }

  void _onDoubleTap() {
    setState(() => _liked = true);
    _heartCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reel;
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred backdrop
          if (_ready && _ctrl != null)
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _ctrl!.value.size.width,
                    height: _ctrl!.value.size.height,
                    child: VideoPlayer(_ctrl!),
                  ),
                ),
              ),
            ),
          if (_ready && _ctrl != null)
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.55))),

          // Foreground video at natural aspect, centered
          Center(
            child: _ready && _ctrl != null
                ? AspectRatio(
                    aspectRatio: _ctrl!.value.aspectRatio,
                    child: VideoPlayer(_ctrl!),
                  )
                : _loadingOrThumbnail(r),
          ),

          // Loading spinner while video initializes
          if (!_ready)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator(color: Colors.white70)),
            ),

          // Pause indicator overlay
          if (_userPaused && _ready)
            const Center(
              child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 96),
            ),

          // Heart animation on double-tap
          Center(
            child: AnimatedBuilder(
              animation: _heartCtrl,
              builder: (_, __) {
                final progress = _heartCtrl.value;
                if (progress == 0) return const SizedBox.shrink();
                final scale = progress < 0.4
                    ? progress / 0.4 * 1.2
                    : 1.2 - (progress - 0.4) / 0.6 * 0.4;
                final opacity = progress < 0.6 ? 1.0 : (1.0 - (progress - 0.6) / 0.4);
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 140),
                  ),
                );
              },
            ),
          ),

          // Bottom dim gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 360,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),

          // Right-side action bar
          Positioned(
            right: 14,
            bottom: 130,
            child: Column(
              children: [
                _action(_liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    _liked ? 'Liked' : 'Like',
                    color: _liked ? const Color(0xFFFF4D6D) : Colors.white,
                    onTap: () => setState(() => _liked = !_liked)),
                const SizedBox(height: 18),
                _action(Icons.chat_bubble_outline_rounded, 'Comment'),
                const SizedBox(height: 18),
                _action(Icons.share_rounded, 'Share'),
                const SizedBox(height: 18),
                _action(Icons.bookmark_outline_rounded, 'Save'),
                const SizedBox(height: 18),
                _action(widget.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    widget.muted ? 'Muted' : 'Sound',
                    onTap: widget.onMuteToggle),
              ],
            ),
          ),

          // Title + description + author
          Positioned(
            left: 16,
            right: 80,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryGreenDeep,
                        child: Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('@qalaam',
                        style: GoogleFonts.manrope(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('FOLLOW',
                          style: GoogleFonts.manrope(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ),
                  ],
                ),
                if (r.title.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(r.title,
                      style: GoogleFonts.manrope(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3)),
                ],
                if (r.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r.description,
                      style: GoogleFonts.manrope(color: Colors.white.withOpacity(0.86), fontSize: 13, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),
                _progressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingOrThumbnail(Reel r) {
    if (r.thumbnailUrl.isNotEmpty) {
      return Image.network(
        r.thumbnailUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.gradientHero),
      alignment: Alignment.center,
      child: const Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 96),
    );
  }

  Widget _progressBar() {
    final c = _ctrl;
    final dur = c?.value.duration ?? Duration.zero;
    final pos = c?.value.position ?? Duration.zero;
    final progress = (dur.inMilliseconds == 0)
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, {VoidCallback? onTap, Color color = Colors.white}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Icon(icon, color: color, size: 30,
              shadows: [const Shadow(color: Colors.black54, blurRadius: 8)]),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  shadows: [const Shadow(color: Colors.black54, blurRadius: 4)])),
        ],
      ),
    );
  }
}
