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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;
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
  // 初始化数据
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _init();
  }

  void _init() async {
    await _loadDictionary();
    await _loadSavedData();
  }

  void _dispose() async {
    await _saveData();
  }

  @override
  void dispose() {
    _dispose();
    _scrollController.dispose();
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
    currentIndex = prefs.getInt('currentIndex') ?? 0;
    _updateCurrentWord(currentIndex);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentIndex', currentIndex);
  }

  Future<void> _loadDictionary() async {
    final list = await ApiService.fetchSDictionary();
    setState(() {
      wordList = list.cast<String>();
    });
  }

  void _navigateWord(int offset) async {
    if (wordList == null || wordList!.isEmpty) return;
    final isFavorite_ = await _isWordFavorite(wordList![currentIndex]);
    int newIndex = (currentIndex + offset) % wordList!.length;
    if (newIndex < 0) newIndex = wordList!.length - 1;

    _updateCurrentWord(newIndex);

    setState(() {
      _isFavorite = isFavorite_;
    });
  }

  void _selectLetter(String newLetter) {
    String word = wordList!.firstWhere((word) => word.startsWith(newLetter));
    int index = wordList!.indexOf(word);

    _updateCurrentWord(index, isSyncLetter: false);

    setState(() {
      selectedLetter = newLetter;
    });
  }

  Future<Word> _fetchWord(String word) async {
    return await ApiService.fetchWord(word);
  }

  void _updateCurrentWord(int index, {bool isSyncLetter = true}) {
    setState(() {
      currentIndex = index;
      final word = wordList![currentIndex];
      wordFuture = _fetchWord(word);
      if (isSyncLetter) {
        selectedLetter = word[0].toUpperCase();
      }
    });
  }

  void _searchAndJumpToWord(String searchWord) {
    if (wordList == null) return;
    int index = wordList!.indexWhere(
      (word) => word.toLowerCase() == searchWord.toLowerCase(),
    );

    if (index != -1) {
      _updateCurrentWord(index);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未找到该单词')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('英语词典'),
        actions: [
          _buildColloctionButton(),
          _buildLetterSelectDropdown(),
          _buildNavigationButtons(),
        ],
      ),
      body: _buildContent(),
      drawer: _buildWordListDrawer(),
    );
  }

  Widget _buildWordListDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Text(
              '单词搜索',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索单词...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _searchAndJumpToWord,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "*与搜索页面的不同，此搜索功能是在词典内查找，搜索页面是在英语单词内查找，可能会出现一些正常单词搜索不到的情况",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColloctionButton() {
    return Align(
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
