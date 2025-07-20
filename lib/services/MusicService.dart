import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import "package:english_learn/models/music.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MusicPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  MusicData? _currentMusic;
  Duration? _lastPosition;
  bool _isInitialized = false;

  MusicPlayerService() {
    _init();
  }

  Future<void> _init() async {
    await _loadState();
    _audioPlayer.playerStateStream.listen((state) {
      _saveState(); // 状态变化时自动保存
      notifyListeners();
    });

    // 每5秒保存一次播放进度
    _audioPlayer.positionStream.listen((position) {
      _lastPosition = position;
    });

    _isInitialized = true;
  }

  Future<void> _saveState() async {
    if (!_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentAudioUrl', _currentAudioUrl ?? '');

    if (_currentMusic != null) {
      await prefs.setString(
        'currentMusic',
        jsonEncode(_currentMusic!.toJson()),
      );
    }

    if (_lastPosition != null) {
      await prefs.setInt('lastPosition', _lastPosition!.inMilliseconds);
    }

    await prefs.setBool('wasPlaying', _audioPlayer.playing);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('currentAudioUrl');

    if (url != null && url.isNotEmpty) {
      _currentAudioUrl = url;

      final musicJson = prefs.getString('currentMusic');
      if (musicJson != null) {
        _currentMusic = MusicData.fromJson(jsonDecode(musicJson));
      }

      final position = prefs.getInt('lastPosition');
      if (position != null) {
        _lastPosition = Duration(milliseconds: position);
      }

      notifyListeners();

      // 恢复播放状态
      if (prefs.getBool('wasPlaying') == true && url.isNotEmpty) {
        await play(url, musicData: _currentMusic);
        if (_lastPosition != null) {
          await seek(_lastPosition!);
        }
      }
    }
  }

  String? get currentAudioUrl => _currentAudioUrl;
  MusicData? get currentMusic => _currentMusic;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get isPlayingStream =>
      _audioPlayer.playerStateStream.map((state) => state.playing);

  Future<void> play(String url, {MusicData? musicData}) async {
    try {
      _currentAudioUrl = url;
      _currentMusic = musicData;
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('播放失败: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;
    _currentMusic = null;
    _lastPosition = null;
    notifyListeners();
    await _saveState();
  }

  Future<void> disposePlayer() async {
    await _saveState();
    await _audioPlayer.dispose();
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }
}
