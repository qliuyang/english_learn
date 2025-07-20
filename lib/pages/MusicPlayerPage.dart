import 'package:english_learn/apis/api.dart';
import 'package:flutter/material.dart';
import '../models/music.dart';
import 'package:provider/provider.dart';
import '../services/MusicService.dart';

class MusicPlayerPage extends StatelessWidget {
  final MusicData musicData;

  const MusicPlayerPage({super.key, required this.musicData});

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<MusicPlayerService>(context);

    return Scaffold(
      appBar: AppBar(title: Text(musicData.song)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(musicData.cover, width: 300, height: 300),
            const SizedBox(height: 20),
            Text(
              musicData.song,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              musicData.singer,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            _buildPlayerControls(context, playerService),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerControls(
    BuildContext context,
    MusicPlayerService playerService,
  ) {
    return Column(
      children: [
        // 进度条
        StreamBuilder<Duration>(
          stream: playerService.positionStream,
          builder: (context, snapshot) {
            final currentPosition = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: playerService.durationStream
                  .where((d) => d != null)
                  .map((d) => d!),
              builder: (context, snapshot) {
                final totalDuration = snapshot.data ?? Duration.zero;
                return Slider(
                  value: currentPosition.inMilliseconds.toDouble().clamp(0, totalDuration.inMilliseconds.toDouble()),
                  max: totalDuration.inMilliseconds.toDouble(),
                  min: 0,
                  onChanged: (value) {
                    playerService.seek(Duration(milliseconds: value.toInt()));
                  },
                  onChangeEnd: (value) {
                    // 确保最终值不超过最大时长
                    final clampedValue = value.clamp(0, totalDuration.inMilliseconds.toDouble());
                    playerService.seek(Duration(milliseconds: clampedValue.toInt()));
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 8),
        // 时间显示
        StreamBuilder<Duration>(
          stream: playerService.positionStream,
          builder: (context, snapshot) {
            final currentPosition = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: playerService.durationStream
                  .where((d) => d != null)
                  .map((d) => d!),
              builder: (context, snapshot) {
                final totalDuration = snapshot.data ?? Duration.zero;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(currentPosition)),
                    Text(_formatDuration(totalDuration)),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        // 控制按钮
        StreamBuilder<bool>(
          stream: playerService.isPlayingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    // 上一首
                  },
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () async {
                    if (playerService.currentAudioUrl == null) {
                      final url = await ApiService.fetchMediaSource(
                        musicData.mid,
                        '8',
                      );
                      await playerService.play(url,musicData: musicData);
                    } else {
                      if (isPlaying) {
                        await playerService.pause();
                      } else {
                        await playerService.resume();
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    // 下一首
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
