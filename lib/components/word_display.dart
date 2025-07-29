import 'package:flutter/material.dart';
import '../models/word.dart';
import 'package:just_audio/just_audio.dart';

class WordDisplay extends StatefulWidget {
  final WordData word;

  const WordDisplay({super.key, required this.word});

  @override
  State<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends State<WordDisplay> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (state.playing) return;
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('播放失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildSection('单词信息', _buildWordBasicInfo(widget.word)),
          _buildSection('发音', _buildPronunciation(widget.word)),
          _buildSection('翻译', _buildTranslations(widget.word)),
          if (widget.word.phrases.isNotEmpty)
            _buildSection(
              '短语',
              _buildListContent(
                widget.word.phrases,
                (p) => [p.p_content, p.p_cn],
              ),
            ),
          if (widget.word.sentences.isNotEmpty)
            _buildSection(
              '例句',
              _buildListContent(
                widget.word.sentences,
                (s) => [s.s_content, s.s_cn],
              ),
            ),
          if (widget.word.relWords.isNotEmpty)
            _buildSection('相关词', _buildRelatedWords(widget.word)),
          if (widget.word.synonyms.isNotEmpty)
            _buildSection('同义词', _buildSynonyms(widget.word)),
        ],
      ),
    );
  }

  // 以下辅助方法保持不变
  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildListContent<T>(
    List<T> items,
    List<String> Function(T) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final texts = itemBuilder(item);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: texts.map((text) => Text(text)).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordBasicInfo(WordData word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word.word,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        if (word.bookId.isNotEmpty)
          Text(
            '来自书本: ${word.bookId}',
            style: TextStyle(color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildPronunciation(WordData word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPronunciationRow('英', word.ukphone, word.ukspeech),
        _buildPronunciationRow('美', word.usphone, word.usspeech),
      ],
    );
  }

  Widget _buildPronunciationRow(String label, String phone, String? speech) {
    return Row(
      children: [
        Text('$label: '),
        Text(phone),
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.volume_up),
          onPressed: () => _playAudio(speech),
        ),
      ],
    );
  }

  Widget _buildTranslations(WordData word) {
    return _buildListContent(
      word.translations,
      (trans) => ['${trans.pos}. ${trans.tran_cn}'],
    );
  }

  Widget _buildRelatedWords(WordData word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: word.relWords
          .map(
            (relWord) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${relWord.Pos}:'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: relWord.Hwds.map(
                      (hwd) => Chip(label: Text('${hwd.hwd} (${hwd.tran})')),
                    ).toList(),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSynonyms(WordData word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: word.synonyms
          .map(
            (synonym) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${synonym.pos} (${synonym.tran}):'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: synonym.Hwds.map(
                      (hwd) => Chip(label: Text(hwd.word)),
                    ).toList(),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
