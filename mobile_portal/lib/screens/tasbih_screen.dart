import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/qalaam_card.dart';
import '../widgets/geometric_pattern.dart';
import '../widgets/shimmer.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  int _count = 0;
  int _totalCount = 0;
  bool _hapticOn = true;

  Dhikr? _selected;
  late Future<List<Dhikr>> _dhikrsFuture;

  late AnimationController _progress;
  late Animation<double> _progressAnim;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _dhikrsFuture = _apiService.fetchDhikrs();
    _loadProgress();
    _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(_progress);
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final id = prefs.getInt('selected_dhikr_id') ?? 1;
      _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
      _count = prefs.getInt('tasbih_count_$id') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    if (_selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_dhikr_id', _selected!.id);
    await prefs.setInt('tasbih_count_${_selected!.id}', _count);
    await prefs.setInt('tasbih_total_count', _totalCount);
  }

  void _increment() {
    if (_selected == null) return;
    setState(() {
      _count++;
      _totalCount++;
      if (_count > _selected!.defaultTarget) {
        _count = 1;
        _maybeVibrate(120);
      }
      _retargetProgress();
      _saveProgress();
      _maybeVibrate(20);
    });
    _pulse.forward(from: 0).then((_) => _pulse.reverse());
  }

  Future<void> _maybeVibrate(int ms) async {
    if (!_hapticOn) return;
    final has = await Vibration.hasVibrator();
    if (has == true) Vibration.vibrate(duration: ms);
  }

  void _reset() {
    setState(() {
      _count = 0;
      _retargetProgress();
      _saveProgress();
    });
  }

  void _retargetProgress() {
    if (_selected == null) return;
    final target = (_count / _selected!.defaultTarget).clamp(0.0, 1.0);
    _progressAnim = Tween<double>(begin: _progressAnim.value, end: target)
        .animate(CurvedAnimation(parent: _progress, curve: Curves.easeOut));
    _progress.forward(from: 0);
  }

  @override
  void dispose() {
    _progress.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Digital tasbih'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Dhikr>>(
        future: _dhikrsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: 80),
              child: Column(
                children: [
                  Shimmer(child: ShimmerBox(width: 280, height: 280, radius: 999)),
                  SizedBox(height: 32),
                  SkeletonList(count: 3, itemHeight: 90, padding: EdgeInsets.symmetric(vertical: 6)),
                ],
              ),
            );
          }
          final dhikrs = (snapshot.data ?? []).isEmpty ? _demoDhikrs() : snapshot.data!;
          if (_selected == null && dhikrs.isNotEmpty) {
            _selected = dhikrs.first;
            WidgetsBinding.instance.addPostFrameCallback((_) => _retargetProgress());
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5),
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.space4),
                  _currentHeader(),
                  const SizedBox(height: AppTheme.space7),
                  _ringCounter(),
                  const SizedBox(height: AppTheme.space6),
                  _stats(),
                  const SizedBox(height: AppTheme.space5),
                  _controls(),
                  const SizedBox(height: AppTheme.space7),
                  _libraryHeader(),
                  const SizedBox(height: AppTheme.space3),
                  ...dhikrs.map(_dhikrTile).toList(),
                  const SizedBox(height: AppTheme.space9),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Dhikr> _demoDhikrs() => [
        Dhikr(id: 1, name: 'SubhanAllah', arabic: 'سُبْحَانَ ٱللَّٰهِ', translation: 'Glory be to Allah'),
        Dhikr(id: 2, name: 'Alhamdulillah', arabic: 'ٱلْحَمْدُ لِلَّٰهِ', translation: 'All praise is due to Allah'),
        Dhikr(id: 3, name: 'Allahu Akbar', arabic: 'ٱللَّٰهُ أَكْبَرُ', translation: 'Allah is the Greatest'),
        Dhikr(id: 4, name: 'Astaghfirullah', arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ', translation: 'I seek forgiveness from Allah'),
      ];

  Widget _currentHeader() {
    final d = _selected;
    return Column(
      children: [
        Text('CURRENT DHIKR', style: AppTheme.eyebrow()),
        const SizedBox(height: AppTheme.space3),
        Text(d?.arabic ?? 'سُبْحَانَ ٱللَّٰهِ', style: AppTheme.arabicLarge().copyWith(fontSize: 32)),
        const SizedBox(height: 6),
        Text(d?.name ?? 'SubhanAllah', style: AppTheme.h2()),
        const SizedBox(height: 4),
        Text('"${d?.translation ?? "Glory be to Allah"}"',
            style: AppTheme.body().copyWith(fontStyle: FontStyle.italic, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _ringCounter() {
    return GestureDetector(
      onTap: _increment,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final scale = 1.0 - _pulse.value * 0.03;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface,
            boxShadow: AppTheme.shadowLg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => CircularProgressIndicator(
                    value: _progressAnim.value,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppTheme.parchment,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
              ),
              ClipOval(
                child: Container(
                  width: 250,
                  height: 250,
                  color: AppTheme.cream,
                  child: const Stack(
                    children: [
                      Positioned.fill(child: GeometricPattern(color: AppTheme.gold, opacity: 0.05, cell: 50)),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_count',
                      style: AppTheme.display(color: AppTheme.primaryGreenDeep).copyWith(fontSize: 84, fontWeight: FontWeight.w800)),
                  Text('of ${_selected?.defaultTarget ?? 33}',
                      style: AppTheme.caption().copyWith(letterSpacing: 1.4)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.parchment,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: AppTheme.gold, size: 14),
                        const SizedBox(width: 4),
                        Text('Tap to count', style: AppTheme.caption(color: AppTheme.textDark).copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stats() {
    return QalaamCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppTheme.space5),
      child: Row(
        children: [
          Expanded(child: _statColumn('Lifetime', _totalCount.toString(), Icons.workspace_premium_rounded, AppTheme.gold)),
          Container(width: 1, height: 36, color: AppTheme.borderLight),
          Expanded(child: _statColumn('Target', _selected?.defaultTarget.toString() ?? '33', Icons.adjust_rounded, AppTheme.primaryGreen)),
          Container(width: 1, height: 36, color: AppTheme.borderLight),
          Expanded(
            child: _statColumn(
              'Streak',
              '0d',
              Icons.local_fire_department_rounded,
              const Color(0xFFC85A4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.h3()),
        Text(label, style: AppTheme.caption()),
      ],
    );
  }

  Widget _controls() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset'),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => setState(() => _hapticOn = !_hapticOn),
              icon: Icon(_hapticOn ? Icons.vibration_rounded : Icons.notifications_off_rounded),
              label: Text(_hapticOn ? 'Haptics on' : 'Haptics off'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _libraryHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.gold, size: 18),
        ),
        const SizedBox(width: 10),
        Text('Dhikr library', style: AppTheme.h2()),
      ],
    );
  }

  Widget _dhikrTile(Dhikr d) {
    final selected = _selected?.id == d.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: QalaamTappableCard(
        padding: const EdgeInsets.all(AppTheme.space4),
        color: selected ? AppTheme.accentGreen : AppTheme.surface,
        onTap: () {
          setState(() {
            _selected = d;
            _count = 0;
            _retargetProgress();
            _saveProgress();
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.arabic,
                      style: AppTheme.arabicStyle.copyWith(fontSize: 22, height: 1.4),
                      textAlign: TextAlign.right),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(d.name, style: AppTheme.h3().copyWith(fontSize: 15)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryGreen : AppTheme.parchment,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'x${d.defaultTarget}',
                          style: AppTheme.caption(color: selected ? Colors.white : AppTheme.textDark)
                              .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(d.translation, style: AppTheme.caption()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppTheme.primaryGreen : AppTheme.surface,
                border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.borderLight, width: 1.4),
              ),
              child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }
}
