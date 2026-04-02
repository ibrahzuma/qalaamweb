import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final ApiService _apiService = ApiService();
  late Future<PrayerTimes?> _prayerTimesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _prayerTimesFuture = _apiService.fetchPrayerTimes(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _prayerTimesFuture = Future.value(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(width: 15),
            const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 5),
            Text(
              "Casablanca",
              style: GoogleFonts.outfit(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        leadingWidth: 150,
        title: Column(
          children: [
            Text(
              "TUESDAY, 14 MAY",
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, letterSpacing: 1),
            ),
          ],
        ),
        centerTitle: true,
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
            children: [
              const SizedBox(height: 30),
              // Countdown Timer
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: 0.65,
                        strokeWidth: 8,
                        color: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "03:14:05",
                          style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Text(
                          "until Maghrib",
                          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Prayer Times List
              FutureBuilder<PrayerTimes?>(
                future: _prayerTimesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }
                  final times = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildPrayerItem("Fajr", "Dawn Prayer", times?.fajr ?? "04:12 AM", Icons.wb_sunny_outlined),
                        _buildPrayerItem("Dhuhr", "Noon Prayer", times?.dhuhr ?? "12:34 PM", Icons.wb_sunny_rounded),
                        _buildPrayerItem("Asr", "Afternoon Prayer", times?.asr ?? "04:15 PM", Icons.wb_cloudy_outlined),
                        _buildPrayerItem("Maghrib", "Sunset Prayer", times?.maghrib ?? "07:28 PM", Icons.wb_twilight_rounded, isNext: true),
                        _buildPrayerItem("Isha", "Night Prayer", times?.isha ?? "08:52 PM", Icons.nightlight_round),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Bottom Map decorative
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage("https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=600"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.screen),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_filled_rounded), label: "Prayers"),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: "Qibla"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(String name, String subtitle, String time, IconData icon, {bool isNext = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isNext ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNext ? Colors.white.withOpacity(0.2) : const Color(0xFFE8F8F5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isNext ? Colors.white : AppTheme.primaryGreen),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isNext ? Colors.white : AppTheme.textDark),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 13, color: isNext ? Colors.white.withOpacity(0.8) : AppTheme.textGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isNext ? Colors.white : AppTheme.textDark),
              ),
              if (isNext)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "NEXT",
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Icon(isNext ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, color: isNext ? Colors.white : AppTheme.textGrey.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }
}
