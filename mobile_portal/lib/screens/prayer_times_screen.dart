import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/geometric_pattern.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final ApiService _apiService = ApiService();
  late Future<PrayerTimes?> _future;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
    // Refresh "next prayer" countdown every 30s.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _load() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _future = _apiService.fetchPrayerTimes(pos.latitude, pos.longitude);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _future = Future.value(null);
      });
    }
  }

  /// Parse "HH:MM" into today's DateTime. Returns null on bad input.
  DateTime? _parseTime(String hhmm) {
    if (hhmm.isEmpty || hhmm.contains('-')) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(_now.year, _now.month, _now.day, h, m);
  }

  /// Returns ("Fajr", DateTime) etc for each named prayer in order.
  List<MapEntry<String, DateTime?>> _orderedPrayers(PrayerTimes t) => [
        MapEntry('Fajr', _parseTime(t.fajr)),
        MapEntry('Dhuhr', _parseTime(t.dhuhr)),
        MapEntry('Asr', _parseTime(t.asr)),
        MapEntry('Maghrib', _parseTime(t.maghrib)),
        MapEntry('Isha', _parseTime(t.isha)),
      ];

  /// Find the next-upcoming prayer (and the one currently in window).
  /// Returns (currentName | null, nextName | null, nextDateTime | null).
  ({String? currentName, String? nextName, DateTime? nextAt}) _resolveCurrentNext(PrayerTimes t) {
    final list = _orderedPrayers(t).where((e) => e.value != null).toList();
    if (list.isEmpty) return (currentName: null, nextName: null, nextAt: null);

    // Next prayer: first whose time is >= now.
    String? currentName;
    String? nextName;
    DateTime? nextAt;
    for (var i = 0; i < list.length; i++) {
      if (!list[i].value!.isAfter(_now)) {
        currentName = list[i].key;
      } else {
        nextName ??= list[i].key;
        nextAt ??= list[i].value;
      }
    }
    if (nextName == null) {
      // After Isha — next prayer is tomorrow's Fajr.
      nextName = 'Fajr';
      final fajr = list.first.value;
      if (fajr != null) {
        nextAt = fajr.add(const Duration(days: 1));
      }
    }
    return (currentName: currentName, nextName: nextName, nextAt: nextAt);
  }

  String _formatTimeUntil(DateTime target) {
    final diff = target.difference(_now);
    if (diff.isNegative) return 'now';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Prayer times')),
      body: FutureBuilder<PrayerTimes?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          final t = snapshot.data;
          final resolved = t == null
              ? (currentName: null, nextName: null, nextAt: null)
              : _resolveCurrentNext(t);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _nextCard(t, resolved.nextName, resolved.nextAt),
                const SizedBox(height: AppTheme.space6),
                Row(children: [Text("Today's schedule", style: AppTheme.h2()), const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.parchment,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen, size: 13),
                        const SizedBox(width: 4),
                        Text('Your location', style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: AppTheme.space3),
                QalaamCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      _row('Fajr', t?.fajr ?? '--:--', Icons.dark_mode_rounded, resolved.currentName == 'Fajr'),
                      _divider(),
                      _row('Dhuhr', t?.dhuhr ?? '--:--', Icons.wb_sunny_rounded, resolved.currentName == 'Dhuhr'),
                      _divider(),
                      _row('Asr', t?.asr ?? '--:--', Icons.sunny_snowing, resolved.currentName == 'Asr'),
                      _divider(),
                      _row('Maghrib', t?.maghrib ?? '--:--', Icons.nightlight_round, resolved.currentName == 'Maghrib'),
                      _divider(),
                      _row('Isha', t?.isha ?? '--:--', Icons.nights_stay_rounded, resolved.currentName == 'Isha'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space5),
                _qiblaPrompt(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _nextCard(PrayerTimes? t, String? nextName, DateTime? nextAt) {
    final name = nextName ?? '—';
    String timeStr = '--:--';
    if (t != null && nextName != null) {
      timeStr = switch (nextName) {
        'Fajr' => t.fajr,
        'Dhuhr' => t.dhuhr,
        'Asr' => t.asr,
        'Maghrib' => t.maghrib,
        'Isha' => t.isha,
        _ => '--:--',
      };
    }
    final until = nextAt != null ? _formatTimeUntil(nextAt) : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Container(
        decoration: AppTheme.cardHero,
        padding: const EdgeInsets.all(AppTheme.space6),
        child: Stack(
          children: [
            const Positioned.fill(child: GeometricPattern(opacity: 0.06, cell: 50)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT PRAYER', style: AppTheme.eyebrow(color: AppTheme.gold)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(name, style: AppTheme.display(color: Colors.white).copyWith(fontSize: 38)),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(timeStr, style: AppTheme.h2(color: Colors.white.withOpacity(0.9))),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space3),
                if (until != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(until == 'now' ? 'Now' : 'In $until',
                            style: AppTheme.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String name, String time, IconData icon, bool current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: 14),
      decoration: BoxDecoration(
        color: current ? AppTheme.accentGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: current ? AppTheme.primaryGreen : AppTheme.parchment,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: current ? Colors.white : AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.h3()),
                if (current) Text('Now praying', style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text(time, style: AppTheme.h2()),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.space4),
        child: Divider(height: 1, color: AppTheme.borderHair),
      );

  Widget _qiblaPrompt() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.accentGold,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.gold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find the Qibla', style: AppTheme.h3()),
                Text('Compass calibrated to your location', style: AppTheme.caption()),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen, size: 18),
        ],
      ),
    );
  }
}
