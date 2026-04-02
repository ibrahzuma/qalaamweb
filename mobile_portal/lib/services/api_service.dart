import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../models/dua.dart';
import '../models/sura.dart';

class ApiService {
  static const String baseUrl = 'https://qalaam.co.tz/api';
  static const String apiKey = 'PRO_SECRET_KEY_2026';

  Future<dynamic> get(String endpoint) async {
    final token = await getAuthToken();
    final url = Uri.parse('$baseUrl/$endpoint');
    debugPrint('API GET: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : 'ApiKey $apiKey',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : 'ApiKey $apiKey',
        },
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

  Future<List<Dhikr>> fetchDhikrs() async {
    final List<dynamic> data = await get('dhikrs/');
    return data.map((json) => Dhikr.fromJson(json)).toList();
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API Non-200 Response (${response.statusCode}): ${response.body}');
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
