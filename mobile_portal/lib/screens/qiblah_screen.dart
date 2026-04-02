import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  double _qiblaAngle = 0.0;
  double _distance = 0.0;
  String _locationName = "Detecting Location...";

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      // Simple Qibla calculation for demo purposes (Makkah is approx 21.4225° N, 39.8262° E)
      // distance calculation using Haversine formula is built into geolocator
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, 21.4225, 39.8262);
      
      setState(() {
        _distance = distanceInMeters / 1000;
        _locationName = "Mecca, Saudi Arabia (Target)"; // For real app, use reverse geocoding for current city
        _qiblaAngle = 118.6; // Mock angle for now
      });
    } catch (e) {
      setState(() {
        _locationName = "Location Access Denied";
      });
    }
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
        title: const Text("Qibla Finder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Location Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _locationName,
                    style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Facing the Kaaba",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              "Rotate your phone to align with the arrow",
              style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textGrey),
            ),

            const SizedBox(height: 40),

            // Premium Compass
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                ),
                // Inner Dotted Ring
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2), width: 2, style: BorderStyle.none),
                  ),
                  child: CustomPaint(painter: DottedCirclePainter()),
                ),
                // Compass markings
                ...['N', 'E', 'S', 'W'].asMap().entries.map((e) {
                  double angle = (e.key * math.pi / 2) - (math.pi / 2);
                  return Transform.translate(
                    offset: Offset(120 * math.cos(angle), 120 * math.sin(angle)),
                    child: Text(e.value, style: GoogleFonts.outfit(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
                  );
                }),

                // The Needle
                Transform.rotate(
                  angle: _qiblaAngle * (math.pi / 180),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: AppTheme.primaryGreen, width: 2),
                        ),
                      ),
                      const Positioned(
                        right: 15,
                        child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen, size: 30),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.mosque, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Distance and Angle Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard("DISTANCE", "${_distance.toStringAsFixed(0)} km", Icons.straighten_rounded),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInfoCard("ANGLE", "$_qiblaAngle° SE", Icons.explore_rounded),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map Preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1542623024-a797a7a48d60?auto=format&fit=crop&q=80&w=600"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.7),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_rounded, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          "View on full map",
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final radius = size.width / 2;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    double currentAngle = 0.0;
    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        currentAngle,
        dashWidth / radius,
        false,
        paint,
      );
      currentAngle += (dashWidth + dashSpace) / radius;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
