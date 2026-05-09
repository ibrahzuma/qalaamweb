import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/shimmer.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final ApiService _apiService = ApiService();
  Future<List<Mosque>>? _mosquesFuture;
  Position? _pos;
  final _filters = const ['All nearby', 'Open now', 'Jumu\'ah'];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final pos = await _resolvePosition();
      setState(() {
        _pos = pos;
        _mosquesFuture = _apiService.fetchMosques(lat: pos.latitude, lng: pos.longitude);
      });
    } catch (_) {
      setState(() {
        _mosquesFuture = _apiService.fetchMosques();
      });
    }
  }

  Future<Position> _resolvePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw 'Location services disabled';
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw 'Location denied';
    }
    if (perm == LocationPermission.deniedForever) throw 'Location permanently denied';
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Nearby mosques'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, AppTheme.space3, 0, AppTheme.space7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapPreview(),
            const SizedBox(height: AppTheme.space5),
            _filterRow(),
            const SizedBox(height: AppTheme.space5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: Row(
                children: [
                  Text('Closest to you', style: AppTheme.h2()),
                  const Spacer(),
                  if (_pos != null)
                    Text(
                      '${_pos!.latitude.toStringAsFixed(2)}, ${_pos!.longitude.toStringAsFixed(2)}',
                      style: AppTheme.caption(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space3),
            FutureBuilder<List<Mosque>>(
              future: _mosquesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SkeletonList(count: 4, itemHeight: 160);
                }
                final list = snapshot.data ?? const <Mosque>[];
                if (list.isEmpty) {
                  return _emptyMosques();
                }
                return Column(children: list.map(_mosqueCard).toList());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F8460), Color(0xFF0E5C44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Stack(
        children: [
          // Faint grid lines as a stylized map
          ...List.generate(8, (i) => Positioned(
                top: 22.0 * i,
                left: 0,
                right: 0,
                child: Container(height: 0.6, color: Colors.white.withOpacity(0.06)),
              )),
          ...List.generate(10, (i) => Positioned(
                left: 36.0 * i,
                top: 0,
                bottom: 0,
                child: Container(width: 0.6, color: Colors.white.withOpacity(0.06)),
              )),
          // Pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowGlow(AppTheme.gold),
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 6),
                Container(width: 2, height: 18, color: AppTheme.gold),
              ],
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              children: [
                _mapBtn(Icons.my_location_rounded),
                const SizedBox(height: 8),
                _mapBtn(Icons.layers_rounded),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('Map preview', style: AppTheme.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBtn(IconData icon) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
      );

  Widget _filterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryGreen : AppTheme.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: selected ? AppTheme.primaryGreen : AppTheme.borderLight,
                ),
              ),
              child: Text(
                _filters[i],
                style: AppTheme.caption(color: selected ? Colors.white : AppTheme.textDark)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mosqueCard(Mosque m) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space5, 12),
      child: QalaamTappableCard(
        padding: const EdgeInsets.all(AppTheme.space4),
        onTap: () {},
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: m.imageUrl.isNotEmpty
                      ? Image.network(
                          m.imageUrl,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgFallback(),
                        )
                      : _imgFallback(),
                ),
                const SizedBox(width: AppTheme.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(m.name, style: AppTheme.h3())),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text('${m.distance.toStringAsFixed(1)} km',
                                style: AppTheme.caption(color: AppTheme.primaryGreen)
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(m.address, style: AppTheme.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded, color: AppTheme.primaryGreen, size: 13),
                          const SizedBox(width: 4),
                          Text('Next: Asr · 15:45',
                              style: AppTheme.caption(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space4),
            Row(
              children: [
                _slot('FAJR', m.prayerTimes['FAJR'] ?? '--:--'),
                _slot('DHUHR', m.prayerTimes['DHUHR'] ?? '--:--'),
                _slot('ASR', m.prayerTimes['ASR'] ?? '--:--', active: true),
                _slot('MAGH', m.prayerTimes['MAGHRIB'] ?? m.prayerTimes['MAGH'] ?? '--:--'),
                _slot('ISHA', m.prayerTimes['ISHA'] ?? '--:--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(color: AppTheme.parchment, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        child: const Icon(Icons.mosque_rounded, color: AppTheme.primaryGreen, size: 36),
      );

  Widget _slot(String name, String time, {bool active = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryGreen : AppTheme.parchment,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(name,
                style: AppTheme.caption(color: active ? Colors.white.withOpacity(0.85) : AppTheme.textGrey)
                    .copyWith(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
            const SizedBox(height: 2),
            Text(time,
                style: AppTheme.caption(color: active ? Colors.white : AppTheme.textDark)
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _emptyMosques() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 20),
      child: QalaamCard(
        padding: const EdgeInsets.all(AppTheme.space6),
        child: Column(
          children: [
            const Icon(Icons.mosque_outlined, color: AppTheme.textGrey, size: 32),
            const SizedBox(height: 12),
            Text('No mosques found nearby', style: AppTheme.h3()),
            const SizedBox(height: 4),
            Text('Try adjusting filters or check back later.', style: AppTheme.caption(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
