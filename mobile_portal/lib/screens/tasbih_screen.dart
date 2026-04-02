import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  int _count = 0;
  int _totalCount = 0;
  bool _soundEnabled = true;
  
  Dhikr? _selectedDhikr;
  late Future<List<Dhikr>> _dhikrsFuture;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _dhikrsFuture = _apiService.fetchDhikrs();
    _loadProgress();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_progressController);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final selectedDhikrId = prefs.getInt('selected_dhikr_id') ?? 1;
      _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
      
      // We will set _count and _selectedDhikr after the future completes in the UI
      // but for persistence of current count:
      _count = prefs.getInt('tasbih_count_$selectedDhikrId') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    if (_selectedDhikr == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_dhikr_id', _selectedDhikr!.id);
    await prefs.setInt('tasbih_count_${_selectedDhikr!.id}', _count);
    await prefs.setInt('tasbih_total_count', _totalCount);
  }

  void _increment() {
    if (_selectedDhikr == null) return;
    setState(() {
      _count++;
      _totalCount++;
      if (_count > _selectedDhikr!.defaultTarget) {
        _count = 1;
        if (Vibration.hasVibrator() != null) Vibration.vibrate(duration: 100);
      }
      _updateProgress();
      _saveProgress();
      if (Vibration.hasVibrator() != null) Vibration.vibrate(duration: 30);
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
      _updateProgress();
      _saveProgress();
    });
  }

  void _updateProgress() {
    if (_selectedDhikr == null) return;
    double targetValue = _count / _selectedDhikr!.defaultTarget;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: targetValue,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Digital Tasbih",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Dhikr>>(
        future: _dhikrsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          
          final dhikrs = snapshot.data ?? [];
          if (dhikrs.isNotEmpty && _selectedDhikr == null) {
            _selectedDhikr = dhikrs.first;
            _updateProgress();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildCounterCircle(),
                  const SizedBox(height: 40),
                  _buildControlButtons(),
                  const SizedBox(height: 40),
                  _buildLibraryHeader(),
                  const SizedBox(height: 20),
                  _buildDhikrList(dhikrs),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "CURRENT DHIKR",
          style: GoogleFonts.outfit(
            color: AppTheme.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedDhikr?.name ?? "SubhanAllah",
          style: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          "\"${_selectedDhikr?.translation ?? "Glory be to Allah"}\"",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterCircle() {
    return GestureDetector(
      onTap: _increment,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _count.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                "TOTAL: $_totalCount",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: Colors.grey[400], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "TAP ANYWHERE TO COUNT",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _reset,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restart_alt_rounded, color: Color(0xFF4A5568)),
                  const SizedBox(width: 10),
                  Text(
                    "Reset",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A5568),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _soundEnabled = !_soundEnabled),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _soundEnabled ? "Sound On" : "Sound Off",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryHeader() {
    return Row(
      children: [
        const Icon(Icons.auto_awesome, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: 10),
        Text(
          "Dhikr Library",
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrList(List<Dhikr> dhikrs) {
    // Fallback if API returns empty
    final list = dhikrs.isEmpty ? [
      Dhikr(id: 1, name: "SubhanAllah", arabic: "سُبْحَانَ ٱللَّٰهِ", translation: "Glory be to Allah"),
      Dhikr(id: 2, name: "Alhamdulillah", arabic: "ٱلْحَمْدُ لِلَّٰهِ", translation: "All praise is due to Allah"),
      Dhikr(id: 3, name: "Allahu Akbar", arabic: "ٱللَّٰهُ أَكْبَرُ", translation: "Allah is the Greatest"),
      Dhikr(id: 4, name: "Astaghfirullah", arabic: "أَسْتَغْفِرُ ٱللَّٰهَ", translation: "I seek forgiveness from Allah"),
    ] : dhikrs;

    return Column(
      children: list.map((dhikr) => _buildDhikrCard(dhikr)).toList(),
    );
  }

  Widget _buildDhikrCard(Dhikr dhikr) {
    bool isSelected = _selectedDhikr?.id == dhikr.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDhikr = dhikr;
          _count = 0; // Reset count for new dhikr or keep if desired? Assuming reset like image selection
          _updateProgress();
          _saveProgress();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dhikr.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dhikr.translation,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey[200],
              ),
              child: isSelected 
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
            ),
          ],
        ),
      ),
    );
  }
}
