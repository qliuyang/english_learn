import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/api.dart';
import '../models/music.dart';
import 'MusicPlayerPage.dart';

class MusicPage extends StatefulWidget {
  static const String routeName = '/music';
  const MusicPage({super.key, this.musicName});
  final String? musicName;

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  List<MusicData> _musicList = [];
  bool _isLoading = false;
  bool _showHistory = false;
  static const String _historyKey = 'music_search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.musicName != null) {
      _searchController.text = widget.musicName!;
      _searchMusic(widget.musicName!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  Future<void> _searchMusic(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showHistory = false;
    });

    try {
      final result = await ApiService.fetchMusicList(query);
      setState(() {
        _musicList = result;
        if (!_searchHistory.contains(query)) {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory.removeLast();
          }
          _saveHistory();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('搜索失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeHistoryItem(int index) async {
    setState(() {
      _searchHistory.removeAt(index);
    });
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    setState(() {
      _searchHistory.clear();
      _showHistory = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchMusic(_searchController.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        hintText: '搜索歌曲...',
        border: InputBorder.none,
      ),
      onTap: () {
        setState(() {
          _showHistory = _searchHistory.isNotEmpty;
        });
      },
      onSubmitted: _searchMusic,
    );
  }

  Widget _buildBody() {
    if (_showHistory) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: _clearHistory, child: const Text('清空历史')),
              ],
            ),
          ),
          Expanded(child: _buildHistoryList()),
        ],
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_musicList.isEmpty) {
      return const Center(child: Text('输入歌曲名称开始搜索'));
    }

    return ListView.builder(
      itemCount: _musicList.length,
      itemBuilder: (context, index) {
        final music = _musicList[index];
        return ListTile(
          leading: Image.network(music.cover, width: 50, height: 50),
          title: Text(music.song),
          subtitle: Text(music.singer),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(musicData: music,
                  musicList: _musicList,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final item = _searchHistory[index];
        return ListTile(
          title: Text(item),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeHistoryItem(index),
          ),
          onTap: () {
            _searchController.text = item;
            _searchMusic(item);
          },
        );
      },
    );
  }
}
