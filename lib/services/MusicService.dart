import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:english_learn/models/music.dart';

class MusicPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  MusicData? _currentMusic;

  MusicPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  String? get currentAudioUrl => _currentAudioUrl;
  MusicData? get currentMusic => _currentMusic;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get isPlayingStream => _audioPlayer.playerStateStream.map(
        (state) => state.playing,
      );

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

  Future<void> disposePlayer() async {
    await _audioPlayer.dispose();
  }
}