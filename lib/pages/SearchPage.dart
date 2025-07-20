import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/api.dart';
import '../models/word.dart';
import '../components/word_display.dart';

class SearchPage extends StatefulWidget {
  static const String routeName = '/search';
  const SearchPage({super.key, this.word});
  final String? word;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  Future<Word>? _searchResult;
  bool _showHistory = false;
  static const String _historyKey = 'word_search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (widget.word != null) {
      // 检查是否有传入的word参数
      _searchController.text = widget.word!;
      _performSearch(widget.word!);
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

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _showHistory = false;
      _searchResult = ApiService.fetchWord(query);

      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
        _saveHistory();
      }
    });
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
            onPressed: () {
              _performSearch(_searchController.text);
            },
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
        hintText: '搜索单词...',
        border: InputBorder.none,
      ),
      onTap: () {
        setState(() {
          _showHistory = _searchHistory.isNotEmpty;
        });
      },
      onSubmitted: _performSearch,
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

    return FutureBuilder<Word>(
      future: _searchResult,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('搜索失败'));
        }
        if (snapshot.hasData) {
          return WordDisplay(word: snapshot.data!.data);
        }
        return const Center(child: Text('输入单词开始搜索'));
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
            _performSearch(item);
          },
        );
      },
    );
  }
}
