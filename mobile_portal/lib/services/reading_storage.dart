import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local store for Quran reading progress + bookmarks.
class ReadingStorage {
  static const _kLastRead = 'reading_last_read';        // {"surah":2,"ayah":255}
  static const _kBookmarks = 'reading_bookmarks';        // [{"surah":2,"ayah":255,"savedAt":1700000000}]

  // ── last read ──────────────────────────────────────────
  static Future<void> setLastRead({required int surah, required int ayah, String? surahName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLastRead,
      jsonEncode({'surah': surah, 'ayah': ayah, 'surahName': surahName ?? '', 'savedAt': DateTime.now().millisecondsSinceEpoch}),
    );
  }

  static Future<LastRead?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastRead);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return LastRead(
        surah: m['surah'] as int,
        ayah: m['ayah'] as int,
        surahName: (m['surahName'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  // ── bookmarks ─────────────────────────────────────────
  static Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBookmarks);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(Bookmark.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isBookmarked({required int surah, required int ayah}) async {
    final list = await getBookmarks();
    return list.any((b) => b.surah == surah && b.ayah == ayah);
  }

  /// Toggles bookmark — returns the new state (true = bookmarked).
  static Future<bool> toggleBookmark({
    required int surah,
    required int ayah,
    String? surahName,
    String? text,
    String? translation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookmarks();
    final idx = list.indexWhere((b) => b.surah == surah && b.ayah == ayah);
    if (idx >= 0) {
      list.removeAt(idx);
      await prefs.setString(_kBookmarks, jsonEncode(list.map((b) => b.toJson()).toList()));
      return false;
    }
    list.insert(
      0,
      Bookmark(
        surah: surah,
        ayah: ayah,
        surahName: surahName ?? '',
        text: text ?? '',
        translation: translation ?? '',
        savedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await prefs.setString(_kBookmarks, jsonEncode(list.map((b) => b.toJson()).toList()));
    return true;
  }

  static Future<void> removeBookmark({required int surah, required int ayah}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBookmarks();
    list.removeWhere((b) => b.surah == surah && b.ayah == ayah);
    await prefs.setString(_kBookmarks, jsonEncode(list.map((b) => b.toJson()).toList()));
  }
}

class LastRead {
  final int surah;
  final int ayah;
  final String surahName;
  const LastRead({required this.surah, required this.ayah, this.surahName = ''});
}

class Bookmark {
  final int surah;
  final int ayah;
  final String surahName;
  final String text;
  final String translation;
  final int savedAt;

  const Bookmark({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.text,
    required this.translation,
    required this.savedAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> j) => Bookmark(
        surah: j['surah'] as int,
        ayah: j['ayah'] as int,
        surahName: (j['surahName'] as String?) ?? '',
        text: (j['text'] as String?) ?? '',
        translation: (j['translation'] as String?) ?? '',
        savedAt: (j['savedAt'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'ayah': ayah,
        'surahName': surahName,
        'text': text,
        'translation': translation,
        'savedAt': savedAt,
      };
}
