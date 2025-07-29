import 'package:english_learn/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionPage extends StatefulWidget {
  static const String routeName = '/collection';
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<String> favoriteWords = [];
  bool _isSelectionMode = false;
  Set<String> _selectedWords = {};

  @override
  void initState() {
    super.initState();
    _loadFavoriteWords();
  }

  Future<void> _loadFavoriteWords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      favoriteWords = favorites;
    });
  }

  void _removeFavoriteWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    favorites.remove(word);
    await prefs.setStringList('favorites', favorites);
    setState(() {
      favoriteWords = favorites;
    });
  }

  void _removeMultipleFavoriteWords(List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    favorites.removeWhere((word) => words.contains(word));
    await prefs.setStringList('favorites', favorites);
    setState(() {
      favoriteWords = favorites;
      _selectedWords.clear();
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedWords.clear();
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

  void _selectAllWords() {
    setState(() {
      if (_selectedWords.length == favoriteWords.length) {
        _selectedWords.clear();
      } else {
        _selectedWords = Set.from(favoriteWords);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收藏夹'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (_selectedWords.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除选中的 ${_selectedWords.length} 个收藏单词吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _removeMultipleFavoriteWords(_selectedWords.toList());
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
      body: favoriteWords.isEmpty
          ? const Center(
              child: Text(
                '暂无收藏单词',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('已选择 ${_selectedWords.length} 个单词'),
                        TextButton(
                          onPressed: _selectAllWords,
                          child: Text(
                            _selectedWords.length == favoriteWords.length
                                ? '取消全选'
                                : '全选',
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: favoriteWords.length,
                    itemBuilder: (context, index) {
                      final word = favoriteWords[index];
                      if (_isSelectionMode) {
                        return ListTile(
                          title: Text(word, style: const TextStyle(fontSize: 18)),
                          leading: Checkbox(
                            value: _selectedWords.contains(word),
                            onChanged: (_) => _toggleWordSelection(word),
                          ),
                          onTap: () => _toggleWordSelection(word),
                        );
                      } else {
                        return Dismissible(
                          key: Key(word),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _removeFavoriteWord(word);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已取消收藏 "$word"'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(word, style: const TextStyle(fontSize: 18)),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // 跳转到主页并传递单词信息
                              Navigator.pushNamed(
                                context,
                                SearchPage.routeName,
                                arguments: word,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}