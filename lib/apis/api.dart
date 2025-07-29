import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/word.dart';
import '../models/music.dart';

class ApiService {
  static const String _baseUrl =
      'https://v2.xxapi.cn/api/englishwords'; // 替换为实际API地址

  static Future<Word> fetchWord(String word) async {
    final response = await http.get(Uri.parse('$_baseUrl?word=$word'));

    if (response.statusCode == 200) {
      return Word.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load word data');
    }
  }

  static Future<List<dynamic>> fetchSDictionary(String dictionary) async {
    String data = await rootBundle.loadString('assets/$dictionary.json');
    List dynamicList = json.decode(data)['word_list'];
    return dynamicList;
  }

  static Future<List<MusicData>> fetchMusicList(String word) async {
    final response = await http.get(
      Uri.parse('https://api.vkeys.cn/v2/music/tencent/search/song?word=$word'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final musicResponse = MusicApiResponse.fromJson(jsonData);
      return musicResponse.data;
    } else {
      throw Exception('Failed to load music list');
    }
  }

  static Future<String> fetchMediaSource(String hash, String quality) async {
    print('fetchMediaSource: $hash $quality');
    // https://api.vkeys.cn/v2/music/tencent/geturl?mid=0023CVP23SH17s&quality=8
    final response = await http.get(
      Uri.parse(
        'https://api.vkeys.cn/v2/music/tencent/geturl?mid=$hash&quality=$quality',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data']['url'];
    } else {
      throw Exception('Failed to load music source');
    }
  }
}
