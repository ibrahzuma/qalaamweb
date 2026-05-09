import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/notification_service.dart';
import '../widgets/qalaam_card.dart';
import 'bookmarks_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _prayerNotifEnabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final enabled = await NotificationService.isEnabled();
    if (mounted) setState(() {
      _prayerNotifEnabled = enabled;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, AppTheme.space9),
        children: [
          _profileCard(),
          const SizedBox(height: AppTheme.space6),
          _sectionHeader('Account'),
          _tile(Icons.person_outline_rounded, 'Edit profile', 'Name, email, phone', () {}),
          _tile(Icons.lock_outline_rounded, 'Privacy & security', 'Change password', () {}),
          const SizedBox(height: AppTheme.space5),
          _sectionHeader('Preferences'),
          _switchTile(
            Icons.notifications_active_outlined,
            'Prayer reminders',
            'Daily local notifications at fajr, dhuhr, asr, maghrib, isha',
            _loaded ? _prayerNotifEnabled : false,
            (val) async {
              final newVal = await NotificationService.setEnabled(val);
              if (mounted) setState(() => _prayerNotifEnabled = newVal);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: AppTheme.primaryGreenDeep,
                  content: Text(
                    newVal
                        ? 'Prayer reminders enabled — they\'ll trigger after the next prayer-time fetch'
                        : 'Prayer reminders disabled',
                    style: AppTheme.body(color: Colors.white),
                  ),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          ),
          _tile(Icons.volume_up_rounded, 'Test adhan', 'Play the adhan now to verify audio', () async {
            await NotificationService.playAdhan();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: AppTheme.primaryGreenDeep,
                content: Row(children: [
                  const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Playing adhan — tap "Stop" to silence',
                        style: AppTheme.body(color: Colors.white)),
                  ),
                ]),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'STOP',
                  textColor: AppTheme.gold,
                  onPressed: NotificationService.stopAdhan,
                ),
              ));
            }
          }),
          _tile(Icons.bookmark_outline_rounded, 'Bookmarks', 'Saved ayahs', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()));
          }),
          _tile(Icons.language_rounded, 'App language', 'English (US)', () {}),
          _tile(Icons.location_on_outlined, 'Location', 'Manage location permission', () {}),
          const SizedBox(height: AppTheme.space5),
          _sectionHeader('Support'),
          _tile(Icons.help_outline_rounded, 'Help center', 'FAQs and support', () {}),
          _tile(Icons.info_outline_rounded, 'About Qalaam', 'Version 2.0.1', () {}),
          const SizedBox(height: AppTheme.space7),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error, width: 1.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return QalaamCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('As-salaamu alaykum', style: AppTheme.caption()),
                const SizedBox(height: 2),
                Text('Guest user', style: AppTheme.h3()),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('PRO MEMBER',
                      style: AppTheme.eyebrow(color: AppTheme.gold).copyWith(fontSize: 9)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10, top: 6),
      child: Text(title.toUpperCase(), style: AppTheme.eyebrow().copyWith(fontSize: 11, letterSpacing: 1.4)),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QalaamTappableCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppTheme.accentGreen, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h3().copyWith(fontSize: 15)),
                  Text(subtitle, style: AppTheme.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: QalaamCard(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space2),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppTheme.accentGreen, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h3().copyWith(fontSize: 15)),
                  Text(subtitle, style: AppTheme.caption()),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
