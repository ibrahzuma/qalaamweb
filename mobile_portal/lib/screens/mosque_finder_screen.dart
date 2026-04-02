import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Mosque>> _mosquesFuture;
  Position? _currentPosition;
  final List<String> _filters = ["All Nearby", "Open Now", "Jumu'ah Prayer"];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((pos) {
      setState(() {
        _currentPosition = pos;
        _mosquesFuture = _apiService.fetchMosques(lat: pos.latitude, lng: pos.longitude);
      });
    }).catchError((e) {
      setState(() {
        _mosquesFuture = _apiService.fetchMosques(); // Fallback to general mosques
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Nearby Mosques"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Map View Area
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=1000"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Custom Marker Placeholder
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mosque, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "Masjid Al-Haram",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen, size: 30),
                    ],
                  ),
                ),
                // Map Controls
                Positioned(
                  right: 20,
                  top: 20,
                  child: Column(
                    children: [
                      _buildMapControl(Icons.my_location_rounded),
                      const SizedBox(height: 12),
                      _buildMapControl(Icons.layers_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Content Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            bool isSelected = _selectedFilter == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedFilter = index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryGreen : const Color(0xFFE8F8F5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.transparent),
                                ),
                                child: Text(
                                  _filters[index],
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
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Closest to You",
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    FutureBuilder<List<Mosque>>(
                      future: _mosquesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                        }
                        if (snapshot.hasError) {
                          return _buildDemoMosqueList(); // Fallback to demo
                        }
                        final mosques = snapshot.data ?? [];
                        if (mosques.isEmpty) {
                          return const Center(child: Text("No mosques found nearby."));
                        }
                        return Column(
                          children: mosques.map((m) => _buildMosqueCard(m)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoMosqueList() {
    return Column(
      children: [
        _buildMosqueCard(Mosque(
          id: 0,
          name: "Masjid Al-Haram",
          address: "123 Faith Street, Central District",
          latitude: 0, longitude: 0,
          distance: 0.5,
          imageUrl: "https://via.placeholder.com/300",
          prayerTimes: {"FAJR": "05:15", "DHUHR": "12:30", "ASR": "15:45", "MAGH": "18:15", "ISHA": "19:45"},
        )),
      ],
    );
  }

  Widget _buildMapControl(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
    );
  }

  Widget _buildMosqueCard(Mosque mosque) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  mosque.imageUrl.isNotEmpty ? mosque.imageUrl : "https://via.placeholder.com/80",
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey, width: 80, height: 80, child: const Icon(Icons.mosque)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mosque.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${mosque.distance} km", style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(mosque.address, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: AppTheme.primaryGreen, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "Next: Asr at 15:45", // Generic for now or calculated from mosque.prayerTimes
                          style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPrayerScheduleItem("FAJR", mosque.prayerTimes["FAJR"] ?? "--:--"),
              _buildPrayerScheduleItem("DHUHR", mosque.prayerTimes["DHUHR"] ?? "--:--"),
              _buildPrayerScheduleItem("ASR", mosque.prayerTimes["ASR"] ?? "--:--", isActive: true),
              _buildPrayerScheduleItem("MAGH", mosque.prayerTimes["MAGH"] ?? "--:--"),
              _buildPrayerScheduleItem("ISHA", mosque.prayerTimes["ISHA"] ?? "--:--"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerScheduleItem(String name, String time, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.white : AppTheme.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.white : AppTheme.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
