import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class UserPage extends StatefulWidget {
  static const String routeName = '/user';
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  File? _avatarFile;
  String _nickname = "我的昵称";
  final TextEditingController _nicknameController = TextEditingController();
  static const String _prefsKey = 'user_profile';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_prefsKey);

    if (userData != null) {
      final data = jsonDecode(userData);
      setState(() {
        _nickname = data['nickname'] ?? "我的昵称";
        if (data['avatarPath'] != null) {
          _avatarFile = File(data['avatarPath']);
        }
      });
    }
  }


  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {'nickname': _nickname, 'avatarPath': _avatarFile?.path};
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
        _saveUserData();
      });
    }
  }

  void _editNickname() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: _nicknameController..text = _nickname,
          decoration: const InputDecoration(hintText: '请输入昵称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _nickname = _nicknameController.text;
                _saveUserData();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        children: [
          _buildUserHeader(),
          _buildDivider(),
          _buildMenuItem(Icons.history, '学习记录', () {
            Navigator.pushNamed(context, '/learn_history');
          }),
          _buildMenuItem(Icons.bookmark, '收藏夹', () {
            Navigator.pushNamed(context, '/collection');
          }),
          _buildDivider(),
          _buildMenuItem(Icons.settings, '设置', () {
            Navigator.pushNamed(context, '/setting');
          }),
          _buildMenuItem(Icons.calendar_month, '签到', () {
            Navigator.pushNamed(context, '/calender');
          }),
          _buildMenuItem(Icons.help, '关于软件', () {
            Navigator.pushNamed(context, '/about');
          }),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue, 
              backgroundImage: _avatarFile != null
                  ? FileImage(_avatarFile!)
                  : null, 
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _editNickname,
            child: Text(
              _nickname,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
      
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }


  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}