import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../models/app_models.dart';

/// Schedules the 5 daily prayer notifications using a custom adhan sound.
///
/// Two playback channels:
///   * Notification — Android plays res/raw/adhan when the system fires.
///   * Foreground — if the app is open at the prayer time, we play the
///     bundled adhan via [just_audio] for full duration.
class NotificationService {
  static const _kEnabled = 'prayer_notifications_enabled';
  // Channel ID changes whenever we change the sound — Android caches the
  // sound at channel creation. Bump the suffix if you swap the audio file.
  static const _channelId = 'qalaam_prayer_adhan_v1';
  static const _channelName = 'Adhan reminders';
  static const _channelDesc = 'Adhan plays at the time of each prayer';
  static const _adhanSoundResource = 'adhan';        // res/raw/adhan
  static const _adhanAsset = 'assets/audio/adhan.mp3';

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audio = AudioPlayer();
  static final List<Timer> _foregroundTimers = [];
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(_adhanSoundResource),
        playSound: true,
      ),
    );

    _initialized = true;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<bool> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
    if (!value) {
      await cancelAll();
    } else {
      await _requestPermissions();
    }
    return value;
  }

  static Future<bool> _requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? true;
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return false;
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _cancelForegroundTimers();
  }

  static void _cancelForegroundTimers() {
    for (final t in _foregroundTimers) {
      t.cancel();
    }
    _foregroundTimers.clear();
  }

  /// Schedule the 5 prayer notifications + foreground adhan timers.
  static Future<void> schedulePrayerTimes(PrayerTimes times) async {
    if (!await isEnabled()) return;
    await init();
    await cancelAll();

    final today = DateTime.now();
    final entries = <_PrayerEntry>[
      _PrayerEntry('Fajr', times.fajr, 'It is time for Fajr'),
      _PrayerEntry('Dhuhr', times.dhuhr, 'It is time for Dhuhr'),
      _PrayerEntry('Asr', times.asr, 'It is time for Asr'),
      _PrayerEntry('Maghrib', times.maghrib, 'It is time for Maghrib'),
      _PrayerEntry('Isha', times.isha, 'It is time for Isha'),
    ];

    int id = 0;
    for (final e in entries) {
      final dt = _combineDateTime(today, e.time);
      if (dt == null) continue;
      // For notifications: if today's slot has passed, schedule for tomorrow.
      final scheduled = dt.isBefore(DateTime.now()) ? dt.add(const Duration(days: 1)) : dt;
      await _scheduleOne(id++, e.name, e.body, scheduled);

      // Foreground timer for full-length adhan playback. Only arms for
      // today's remaining prayers (no tomorrow scheduling — re-armed when
      // home is opened).
      if (dt.isAfter(DateTime.now())) {
        final delay = dt.difference(DateTime.now());
        _foregroundTimers.add(Timer(delay, () => playAdhan()));
      }
    }
  }

  /// Play the bundled adhan from the start. Safe to call repeatedly.
  static Future<void> playAdhan() async {
    try {
      await _audio.stop();
      await _audio.setAsset(_adhanAsset);
      await _audio.play();
    } catch (e) {
      debugPrint('Adhan playback failed: $e');
    }
  }

  static Future<void> stopAdhan() async {
    try {
      await _audio.stop();
    } catch (_) {}
  }

  static Future<void> _scheduleOne(int id, String name, String body, DateTime when) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    try {
      await _plugin.zonedSchedule(
        id,
        name,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'Prayer time',
            sound: RawResourceAndroidNotificationSound(_adhanSoundResource),
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            sound: 'adhan.mp3',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule $name: $e');
    }
  }

  static DateTime? _combineDateTime(DateTime day, String hhmm) {
    if (hhmm.isEmpty || hhmm.contains('-')) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(day.year, day.month, day.day, h, m);
  }
}

class _PrayerEntry {
  final String name;
  final String time;
  final String body;
  _PrayerEntry(this.name, this.time, this.body);
}
