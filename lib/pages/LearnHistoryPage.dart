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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习记录')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "单词",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wordHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(wordHistory[index]),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      SearchPage.routeName,
                      arguments: wordHistory[index],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "歌曲",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: musicHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(musicHistory[index]),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      MusicPage.routeName,
                      arguments: musicHistory[index],
                    );
                  },
                  
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
