import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../widgets/geometric_pattern.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  /// Kaaba coordinates.
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  Future<bool>? _setupFuture;
  Position? _userPos;
  double _distanceKm = 0;
  double _qiblaFromNorth = 0; // bearing in degrees, 0 = north
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupFuture = _bootstrap();
  }

  Future<bool> _bootstrap() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _error = 'Location services are turned off.';
        return false;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _error = 'Location permission denied.';
        return false;
      }

      final pos = await Geolocator.getCurrentPosition();
      _userPos = pos;
      _distanceKm = Geolocator.distanceBetween(pos.latitude, pos.longitude, _kaabaLat, _kaabaLng) / 1000;
      _qiblaFromNorth = _bearingTo(pos.latitude, pos.longitude, _kaabaLat, _kaabaLng);

      // Confirm device sensors are available — this is what flutter_qiblah needs.
      final canSense = await FlutterQiblah.androidDeviceSensorSupport();
      if (canSense != null && !canSense) {
        _error = 'This device does not have a compass sensor.';
        return false;
      }
      return true;
    } catch (e) {
      _error = 'Could not initialise: $e';
      return false;
    }
  }

  /// Great-circle initial bearing from (lat1,lng1) → (lat2,lng2), degrees from north.
  double _bearingTo(double lat1, double lng1, double lat2, double lng2) {
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dLambda = (lng2 - lng1) * math.pi / 180;
    final y = math.sin(dLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi1) * math.cos(dLambda);
    // Note: standard formula has sin(phi1)*cos(phi2)*cos(dLambda); fix below
    return _normalizeDegrees(math.atan2(y,
        math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(dLambda)) * 180 / math.pi);
  }

  double _normalizeDegrees(double d) {
    final n = d % 360;
    return n < 0 ? n + 360 : n;
  }

  String _cardinal(double bearing) {
    const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                  'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    return dirs[((bearing / 22.5).round()) % 16];
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Qibla')),
      body: FutureBuilder<bool>(
        future: _setupFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          if (snap.data != true) {
            return _errorState();
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space7),
            child: Column(
              children: [
                _locationChip(),
                const SizedBox(height: AppTheme.space7),
                _compass(),
                const SizedBox(height: AppTheme.space7),
                _statsRow(),
                const SizedBox(height: AppTheme.space5),
                _calibrationHint(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _locationChip() {
    final coords = _userPos == null
        ? '—'
        : '${_userPos!.latitude.toStringAsFixed(2)}, ${_userPos!.longitude.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location_rounded, color: AppTheme.primaryGreen, size: 14),
          const SizedBox(width: 6),
          Text('Your location · $coords',
              style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _compass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snap) {
        final dir = snap.data;
        // dir.qiblah == clockwise rotation needed (degrees) so the device's top
        // edge points toward the Kaaba.
        final rotation = (dir?.qiblah ?? 0) * math.pi / 180;
        final aligned = dir != null && (dir.qiblah.abs() < 3 || (360 - dir.qiblah.abs()).abs() < 3);
        return SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer plate
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surface,
                  boxShadow: AppTheme.shadowLg,
                  border: Border.all(color: AppTheme.borderLight, width: 1),
                ),
              ),
              // Geometric inner pattern
              ClipOval(
                child: Container(
                  width: 280,
                  height: 280,
                  color: AppTheme.cream,
                  child: const GeometricPattern(color: AppTheme.gold, opacity: 0.06, cell: 50),
                ),
              ),
              // Cardinal letters (rotate so N stays on top w.r.t. compass — but we'll
              // rotate the whole compass dial below).
              CustomPaint(
                size: const Size(320, 320),
                painter: _CompassDialPainter(
                  ringRotationRad: -((dir?.direction ?? 0) * math.pi / 180),
                ),
              ),
              // Qibla needle (rotates so the gold tip points toward Kaaba).
              AnimatedRotation(
                turns: rotation / (2 * math.pi),
                duration: const Duration(milliseconds: 250),
                child: _needle(aligned: aligned),
              ),
              // Center disc with kaaba glyph
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: aligned ? AppTheme.gradientGold : AppTheme.gradientPrimary,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowGlow(aligned ? AppTheme.gold : AppTheme.primaryGreen),
                ),
                child: const Center(
                  child: Icon(Icons.mosque_rounded, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _needle({required bool aligned}) {
    final color = aligned ? AppTheme.gold : AppTheme.primaryGreen;
    return SizedBox(
      width: 60,
      height: 260,
      child: CustomPaint(painter: _NeedlePainter(color: color)),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('DISTANCE', '${_distanceKm.toStringAsFixed(0)} km', Icons.straighten_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('BEARING', '${_qiblaFromNorth.toStringAsFixed(1)}° ${_cardinal(_qiblaFromNorth)}', Icons.explore_rounded)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderHair),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 14),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.eyebrow().copyWith(fontSize: 10)),
          ]),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.h3()),
        ],
      ),
    );
  }

  Widget _calibrationHint() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.accentGold,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: AppTheme.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calibration tip', style: AppTheme.h3().copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'If the needle is jittery, hold the phone flat and rotate it in a figure-8 a few times to calibrate the magnetometer.',
                  style: AppTheme.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, color: AppTheme.textGrey, size: 48),
            const SizedBox(height: 16),
            Text("Couldn't open Qibla compass", style: AppTheme.h2()),
            const SizedBox(height: 6),
            Text(_error ?? 'Unknown error', style: AppTheme.body(), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() => _setupFuture = _bootstrap());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the rotating compass dial (cardinal letters and tick marks).
/// [ringRotationRad] is applied so that as the phone rotates, the dial
/// counter-rotates to keep N pointing geographic north.
class _CompassDialPainter extends CustomPainter {
  final double ringRotationRad;
  _CompassDialPainter({required this.ringRotationRad});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 14;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(ringRotationRad);

    final tickPaint = Paint()
      ..color = AppTheme.borderLight
      ..strokeWidth = 1.5;
    final majorPaint = Paint()
      ..color = AppTheme.primaryGreen
      ..strokeWidth = 2.4;

    for (var i = 0; i < 72; i++) {
      final angle = i * 5.0 * math.pi / 180;
      final isMajor = i % 9 == 0;
      final outer = radius;
      final inner = isMajor ? radius - 14 : radius - 6;
      final p1 = Offset(math.sin(angle) * inner, -math.cos(angle) * inner);
      final p2 = Offset(math.sin(angle) * outer, -math.cos(angle) * outer);
      canvas.drawLine(p1, p2, isMajor ? majorPaint : tickPaint);
    }

    // Cardinal letters
    const cardinals = [('N', 0), ('E', 90), ('S', 180), ('W', 270)];
    for (final (label, deg) in cardinals) {
      final rad = deg * math.pi / 180;
      final r = radius - 30;
      final off = Offset(math.sin(rad) * r, -math.cos(rad) * r);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'N' ? const Color(0xFFC85A4F) : AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Cancel the dial rotation so letters stay upright.
      canvas.save();
      canvas.translate(off.dx, off.dy);
      canvas.rotate(-ringRotationRad);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter old) => old.ringRotationRad != ringRotationRad;
}

/// The qibla needle — a tapered arrow pointing up (toward the Kaaba when
/// rotation == qibla angle from the device's top).
class _NeedlePainter extends CustomPainter {
  final Color color;
  _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final tipY = 8.0;
    final tailY = size.height - 8;
    final width = size.width * 0.45;

    // Tail (smaller, lower)
    final tail = Path()
      ..moveTo(cx, tailY - 24)
      ..lineTo(cx - width / 2, tailY)
      ..lineTo(cx + width / 2, tailY)
      ..close();
    canvas.drawPath(
      tail,
      Paint()..color = AppTheme.borderLight,
    );

    // Tip arrow (larger)
    final tip = Path()
      ..moveTo(cx, tipY)
      ..lineTo(cx - width / 1.6, tipY + 60)
      ..lineTo(cx, tipY + 50)
      ..lineTo(cx + width / 1.6, tipY + 60)
      ..close();
    canvas.drawPath(tip, Paint()..color = color);

    // Slim shaft
    canvas.drawLine(
      Offset(cx, tipY + 50),
      Offset(cx, tailY - 24),
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter old) => old.color != color;
}
