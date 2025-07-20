import 'package:flutter/material.dart';
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
  String selectedDictionary = 'CET4';
  final List<String> dictionaries = ['CET4', 'CET6', '考研', '托福', 'SAT'];

  // 初始化数据
  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  // 加载词典
  Future<void> _loadDictionary() async {
    try {
      final list = await ApiService.fetchSDictionary(selectedDictionary);
      setState(() {
        wordList = list.cast<String>();
        currentIndex = 0;
        wordFuture = _fetchWord(wordList?.firstOrNull ?? 'hello');
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('词典加载错误')));
    }
  }

  // 单词导航
  void _navigateWord(int offset) {
    if (wordList == null || wordList!.isEmpty) return;

    setState(() {
      currentIndex = (currentIndex + offset) % wordList!.length;
      if (currentIndex < 0) currentIndex = wordList!.length - 1;
      wordFuture = _fetchWord(wordList![currentIndex]);
    });
  }

  // 词典选择
  void _selectDictionary(String newDictionary) async {
    setState(() => selectedDictionary = newDictionary);
    await _loadDictionary();
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
          _buildDictionaryDropdown(),
          const SizedBox(width: 16),
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
