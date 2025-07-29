import 'package:english_learn/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import "package:english_learn/models/music.dart";

class MusicPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioUrl;
  MusicData? _currentMusicData;

  Future<void> initData(MusicData? musicData) async {
    _currentMusicData = musicData;
    _currentAudioUrl = await ApiService.fetchMediaSource(musicData!.mid, '8');
    await _audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(_currentAudioUrl!)),
    );
    notifyListeners();
  }

  String? get currentAudioUrl => _currentAudioUrl;
  MusicData? get currentMusicData => _currentMusicData;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get isPlayingStream =>
      _audioPlayer.playerStateStream.map((state) => state.playing);

  Future<void> play() async {
    if (_currentAudioUrl == null) return;
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('播放失败: $e');
      rethrow;
    }
  }

  Future<void> togglePlay() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    _currentAudioUrl = null;
    _currentMusicData = null;
    _audioPlayer.clearAudioSources();
    _audioPlayer.seek(Duration.zero);
    notifyListeners();
  }

  Future<void> disposePlayer() async {
    await _audioPlayer.dispose();
  }

  @override
  void dispose() {
    disposePlayer();
    super.dispose();
  }
}
