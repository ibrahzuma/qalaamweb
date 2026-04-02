import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MediaProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  String? _currentTitle;
  String? _currentArtist;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get isPlaying => _isPlaying;
  String? get currentTitle => _currentTitle;
  String? get currentArtist => _currentArtist;
  Duration get duration => _duration;
  Duration get position => _position;

  MediaProvider() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
  }

  Future<void> playUrl(String url, {String? title, String? artist}) async {
    try {
      _currentTitle = title;
      _currentArtist = artist;
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
