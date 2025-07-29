import 'package:flutter/material.dart';
import '../models/music.dart';
import 'package:provider/provider.dart';
import '../services/MusicService.dart';

class MusicPlayerPage extends StatefulWidget {
  final MusicData musicData;
  final List<MusicData>? musicList;

  const MusicPlayerPage({super.key, required this.musicData, this.musicList});
  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late final MusicPlayerService playerService;
  late MusicData musicData_;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    musicData_ = widget.musicData;
    playerService = Provider.of<MusicPlayerService>(context, listen: false);
    if (playerService.currentMusicData != musicData_) {
      await playerService.reset();
    }
    playerService.initData(musicData_);
  }
    Future<void> _playPrevious() async {
    if (widget.musicList != null && widget.musicList!.isNotEmpty) {
      final currentIndex = widget.musicList!.indexOf(
        playerService.currentMusicData!,
      );
      if (currentIndex > 0) {
        final previousMusic = widget.musicList![currentIndex - 1];
        await playerService.initData(previousMusic);
        await playerService.play();
        setState(() {
          musicData_ = previousMusic;
        });
      }
    }
  }

  Future<void> _playNext() async {
    if (widget.musicList != null && widget.musicList!.isNotEmpty) {
      final currentIndex = widget.musicList!.indexOf(
        playerService.currentMusicData!,
      );
      if (currentIndex < widget.musicList!.length - 1) {
        final nextMusic = widget.musicList![currentIndex + 1];
        await playerService.initData(nextMusic);
        await playerService.play();
        setState(() {
          musicData_ = nextMusic;
        });
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(musicData_.song)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(musicData_.cover, width: 300, height: 300),
            const SizedBox(height: 20),
            Text(
              musicData_.song,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              musicData_.singer,
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
                  value: currentPosition.inMilliseconds.toDouble().clamp(
                    0,
                    totalDuration.inMilliseconds.toDouble(),
                  ),
                  max: totalDuration.inMilliseconds.toDouble(),
                  min: 0,
                  onChanged: (value) {
                    playerService.seek(Duration(milliseconds: value.toInt()));
                  },
                  onChangeEnd: (value) {
                    // 确保最终值不超过最大时长
                    final clampedValue = value.clamp(
                      0,
                      totalDuration.inMilliseconds.toDouble(),
                    );
                    playerService.seek(
                      Duration(milliseconds: clampedValue.toInt()),
                    );
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
                // ... existing code ...
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _playPrevious,
                ),
                // ... existing code ...
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: playerService.togglePlay,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _playNext,
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
