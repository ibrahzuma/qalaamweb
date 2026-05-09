import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../models/dua.dart';
import '../models/sura.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'QALAAM_API_BASE_URL',
    defaultValue: 'http://qalaam.co.tz/api/v1',
  );
  static const String apiKey = String.fromEnvironment('QALAAM_API_KEY');

  Map<String, String> _authHeaders(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    } else if (apiKey.isNotEmpty) {
      headers['Authorization'] = 'ApiKey $apiKey';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final token = await getAuthToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('API GET: $url');

    try {
      final response = await http.get(
        url,
        headers: _authHeaders(token),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API Error (GET $endpoint): $e');
      throw Exception('Failed to connect to the server.');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getAuthToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('API POST: $url');

    try {
      final response = await http.post(
        url,
        headers: _authHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      debugPrint('API Error (POST $endpoint): $e');
      throw Exception('Failed to connect to the server.');
    }
  }

  // Auth Methods
  Future<AuthResponse> login(String email, String password) async {
    final data = await post('auth/login/', {
      'email': email,
      'password': password,
    });
    final authResponse = AuthResponse.fromJson(data);
    await saveAuthToken(authResponse.token);
    return authResponse;
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final data = await post('auth/register/', {
      'name': name,
      'email': email,
      'password': password,
    });
    final authResponse = AuthResponse.fromJson(data);
    await saveAuthToken(authResponse.token);
    return authResponse;
  }

  // Token Persistence
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Feature Specific Methods
  Future<List<Podcast>> fetchPodcasts() async {
    final List<dynamic> data = await get('podcasts/');
    return data.map((json) => Podcast.fromJson(json)).toList();
  }

  Future<List<Fatwa>> fetchFatawa() async {
    final List<dynamic> data = await get('fatwa/');
    return data.map((json) => Fatwa.fromJson(json)).toList();
  }

  Future<List<Dua>> fetchDuas() async {
    final List<dynamic> data = await get('duas/');
    return data.map((json) => Dua.fromJson(json)).toList();
  }

  Future<Dua?> fetchDailyDua() async {
    final data = await get('duas/daily/');
    return data != null ? Dua.fromJson(data) : null;
  }

  Future<List<Surah>> fetchSurahs() async {
    // Al-Quran Cloud proxy or Qalaam's own Surah list
    final List<dynamic> data = await get('quran/surahs/');
    return data.map((json) => Surah.fromJson(json)).toList();
  }

  Future<List<dynamic>> fetchAyahs(int surahNumber) async {
    final List<dynamic> data = await get('quran/surahs/$surahNumber/ayahs/');
    return data;
  }

  Future<List<Mosque>> fetchMosques({double? lat, double? lng}) async {
    String query = (lat != null && lng != null) ? '?lat=$lat&lng=$lng' : '';
    final List<dynamic> data = await get('mosques/$query');
    return data.map((json) => Mosque.fromJson(json)).toList();
  }

  Future<PrayerTimes> fetchPrayerTimes(double lat, double lng) async {
    final data = await get('prayer-times/?lat=$lat&lng=$lng');
    return PrayerTimes.fromJson(data);
  }

  Future<Hadith?> fetchHadithDaily() async {
    final data = await get('hadiths/daily/');
    return data != null ? Hadith.fromJson(data) : null;
  }

  Future<List<HadithCollection>> fetchHadithCollections() async {
    final List<dynamic> data = await get('hadiths/collections/');
    return data.map((json) => HadithCollection.fromJson(json)).toList();
  }

  Future<List<Hadith>> fetchHadiths({String? collectionSlug, String? bookNumber, String? search}) async {
    final params = <String, String>{};
    if (collectionSlug != null && collectionSlug.isNotEmpty) params['collection'] = collectionSlug;
    if (bookNumber != null && bookNumber.isNotEmpty) params['book'] = bookNumber;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final qs = params.isEmpty ? '' : '?${params.entries.map((e) => "${e.key}=${Uri.encodeComponent(e.value)}").join("&")}';
    final List<dynamic> data = await get('hadiths/$qs');
    return data.map((json) => Hadith.fromJson(json)).toList();
  }

  Future<List<Article>> fetchArticles() async {
    final List<dynamic> data = await get('articles/');
    return data.map((json) => Article.fromJson(json)).toList();
  }

  Future<List<Book>> fetchBooks() async {
    final List<dynamic> data = await get('books/');
    return data.map((json) => Book.fromJson(json)).toList();
  }

  Future<List<PodcastEpisode>> fetchRelatedAudios() async {
    final List<dynamic> data = await get('audios/related/');
    return data.map((json) => PodcastEpisode.fromJson(json)).toList();
  }

  Future<DailyAyah?> fetchDailyAyah() async {
    final data = await get('quran/ayah/daily/');
    return data != null ? DailyAyah.fromJson(data) : null;
  }

  Future<List<Video>> fetchTrendingVideos() async {
    final List<dynamic> data = await get('studio/trending/');
    return data.map((json) => Video.fromJson(json)).toList();
  }

  Future<List<VideoSeries>> fetchEducationalSeries() async {
    final List<dynamic> data = await get('studio/series/educational/');
    return data.map((json) => VideoSeries.fromJson(json)).toList();
  }

  Future<List<Video>> fetchContinueWatching() async {
    final List<dynamic> data = await get('studio/continue-watching/');
    return data.map((json) => Video.fromJson(json)).toList();
  }

  Future<List<Clip>> fetchClips() async {
    final List<dynamic> data = await get('clips/');
    return data.map((json) => Clip.fromJson(json)).toList();
  }

  Future<List<Reel>> fetchReels() async {
    final List<dynamic> data = await get('reels/');
    return data.map((json) => Reel.fromJson(json)).toList();
  }

  Future<List<Dhikr>> fetchDhikrs() async {
    final List<dynamic> data = await get('dhikrs/');
    return data.map((json) => Dhikr.fromJson(json)).toList();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      // Treat "not found" as missing data rather than an error.
      return null;
    } else if (response.statusCode == 401) {
      // Stored token rejected — drop it so subsequent calls fall back to ApiKey.
      logout();
      debugPrint('API 401 — cleared stored auth token; falling back to ApiKey on next call.');
      throw Exception('Server error: 401');
    } else {
      debugPrint('API Non-200 Response (${response.statusCode}): ${response.body}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
