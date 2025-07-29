import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import "../apis/api.dart";
import '../components/word_display.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 状态管理
  Future<Word>? wordFuture;
  List<String>? wordList;
  int currentIndex = 0;
  bool _isFavorite = false;

  String selectedDictionary = 'CET4';
  String selectedLetter = 'A';

  final List<String> letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];
  final List<String> dictionaries = ['CET4', 'CET6', '考研', '托福', 'SAT'];

  // 初始化数据
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _loadSavedData();
    await _loadDictionary();
  }

  void _dispose() async {
    await _saveData();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _saveFavoriteWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    if (_isFavorite) {
      if (!favorites.contains(word)) {
        favorites.add(word);
      }
    } else {
      favorites.remove(word);
    }
    await prefs.setStringList('favorites', favorites);
  }
  Future<bool> _isWordFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(word);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentIndex = prefs.getInt('currentIndex') ?? 0;
      selectedDictionary = prefs.getString('selectedDictionary') ?? 'CET4';
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', currentIndex);
    await prefs.setString('selectedDictionary', selectedDictionary);
  }

  // 加载词典
  Future<void> _loadDictionary() async {
    final list = await ApiService.fetchSDictionary(selectedDictionary);
    setState(() {
      wordList = list.cast<String>();
      wordFuture = _fetchWord(wordList?[currentIndex] ?? 'hello');
    });
  }

  // 单词导航
  void _navigateWord(int offset) async {
    if (wordList == null || wordList!.isEmpty) return;
    final isFavorite_ = await _isWordFavorite(wordList![currentIndex]);
    setState(() {
      currentIndex = (currentIndex + offset) % wordList!.length;
      if (currentIndex < 0) currentIndex = wordList!.length - 1;
      wordFuture = _fetchWord(wordList![currentIndex]);
      _isFavorite = isFavorite_;
    });
  }

  // 词典选择
  void _selectDictionary(String newDictionary) async {
    setState(() => selectedDictionary = newDictionary);
    await _loadDictionary();
  }

  // 字母选择
  void _selectLetter(String newLetter) {
    String word = wordList!.firstWhere(
      (word) => word.startsWith(newLetter),
      orElse: () => '',
    );
    setState(() {
      selectedLetter = newLetter;
      wordFuture = _fetchWord(word);
    });
  }

  // 网络请求封装
  Future<Word> _fetchWord(String word) async {
    return await ApiService.fetchWord(word);
  }

  // 主页面构建
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('英语词典'),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.yellow : null,
              ),
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                _saveFavoriteWord(wordList![currentIndex]);
              },
            ),
          ),
          _buildLetterSelectDropdown(),
          _buildDictionaryDropdown(),
          _buildNavigationButtons(),
        ],
      ),
      body: _buildContent(),
    );
  }

  // 词典下拉菜单
  Widget _buildDictionaryDropdown() {
    return DropdownButton<String>(
      value: selectedDictionary,
      onChanged: (value) => _selectDictionary(value!),
      items: dictionaries
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      style: const TextStyle(color: Colors.black),
      underline: Container(height: 0),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
    );
  }

  // 字母选择下拉菜单
  Widget _buildLetterSelectDropdown() {
    return DropdownButton<String>(
      value: selectedLetter,
      onChanged: (value) => _selectLetter(value!),
      items: letters
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      style: const TextStyle(color: Colors.black),
      underline: Container(height: 0),
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
    );
  }

  // 单词导航按钮
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigateWord(-1),
          tooltip: '上一个单词',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => _navigateWord(1),
          tooltip: '下一个单词',
        ),
      ],
    );
  }

  // 修改 _buildContent 方法
  Widget _buildContent() {
    return FutureBuilder<Word>(
      future: wordFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('错误: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('没有任何数据'));
        }

        return WordDisplay(word: snapshot.data!.data);
      },
    );
  }
}
