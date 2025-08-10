import 'package:english_learn/pages/MusicPage.dart';
import 'package:english_learn/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Learnhistorypage extends StatefulWidget {
  static const String routeName = '/learn_history';
  const Learnhistorypage({super.key});
  @override
  State<Learnhistorypage> createState() => _LearnhistorypageState();
}

class _LearnhistorypageState extends State<Learnhistorypage> {
  List<String> wordHistory = [];
  List<String> musicHistory = [];
  bool _isSelectionMode = false;
  Set<String> _selectedWords = {};
  Set<String> _selectedMusics = {};

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      wordHistory = prefs.getStringList('word_search_history') ?? [];
      musicHistory = prefs.getStringList('music_search_history') ?? [];
    });
  }

  Future<void> _removeWordHistory(List<String> wordsToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedWords = List.from(wordHistory);
    updatedWords.removeWhere((word) => wordsToRemove.contains(word));
    await prefs.setStringList('word_search_history', updatedWords);
    setState(() {
      wordHistory = updatedWords;
      _selectedWords.clear();
    });
  }

  Future<void> _removeMusicHistory(List<String> musicsToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedMusics = List.from(musicHistory);
    updatedMusics.removeWhere((music) => musicsToRemove.contains(music));
    await prefs.setStringList('music_search_history', updatedMusics);
    setState(() {
      musicHistory = updatedMusics;
      _selectedMusics.clear();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedWords.clear();
        _selectedMusics.clear();
      }
    });
  }

  void _toggleWordSelection(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else {
        _selectedWords.add(word);
      }
    });
  }

  void _toggleMusicSelection(String music) {
    setState(() {
      if (_selectedMusics.contains(music)) {
        _selectedMusics.remove(music);
      } else {
        _selectedMusics.add(music);
      }
    });
  }

  void _selectAllWords() {
    setState(() {
      if (_selectedWords.length == wordHistory.length) {
        _selectedWords.clear();
      } else {
        _selectedWords = Set.from(wordHistory);
      }
    });
  }

  void _selectAllMusics() {
    setState(() {
      if (_selectedMusics.length == musicHistory.length) {
        _selectedMusics.clear();
      } else {
        _selectedMusics = Set.from(musicHistory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习记录'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (_selectedWords.isNotEmpty || _selectedMusics.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除选中的 ${_selectedWords.length + _selectedMusics.length} 项记录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (_selectedWords.isNotEmpty) {
                                _removeWordHistory(_selectedWords.toList());
                              }
                              if (_selectedMusics.isNotEmpty) {
                                _removeMusicHistory(_selectedMusics.toList());
                              }
                              _toggleSelectionMode();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('删除成功'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.close : Icons.edit),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('已选择 ${_selectedWords.length} 个单词'),
                    TextButton(
                      onPressed: _selectAllWords,
                      child: Text(
                        _selectedWords.length == wordHistory.length && wordHistory.isNotEmpty
                            ? '取消全选'
                            : '全选',
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "单词",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wordHistory.length,
                      itemBuilder: (context, index) {
                        final word = wordHistory[index];
                        return ListTile(
                          title: Text(word),
                          leading: _isSelectionMode
                              ? Checkbox(
                                  value: _selectedWords.contains(word),
                                  onChanged: (_) => _toggleWordSelection(word),
                                )
                              : null,
                          onTap: _isSelectionMode
                              ? () => _toggleWordSelection(word)
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    SearchPage.routeName,
                                    arguments: word,
                                  );
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('已选择 ${_selectedMusics.length} 首歌曲'),
                    TextButton(
                      onPressed: _selectAllMusics,
                      child: Text(
                        _selectedMusics.length == musicHistory.length && musicHistory.isNotEmpty
                            ? '取消全选'
                            : '全选',
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "歌曲",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: musicHistory.length,
                      itemBuilder: (context, index) {
                        final music = musicHistory[index];
                        return ListTile(
                          title: Text(music),
                          leading: _isSelectionMode
                              ? Checkbox(
                                  value: _selectedMusics.contains(music),
                                  onChanged: (_) => _toggleMusicSelection(music),
                                )
                              : null,
                          onTap: _isSelectionMode
                              ? () => _toggleMusicSelection(music)
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    MusicPage.routeName,
                                    arguments: music,
                                  );
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}