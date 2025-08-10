import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = '/setting';
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String selectedDictionary = 'CET4';
  final List<String> dictionaries = ['CET4', 'CET6', '考研', '托福', 'SAT'];
  int currentIndex = 0; // 修复拼写错误: currntIndex -> currentIndex

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDictionary = prefs.getString('selectedDictionary') ?? 'CET4';
      currentIndex = prefs.getInt('currentIndex') ?? 0; // 加载 currentIndex
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDictionary', selectedDictionary);
    await prefs.setInt('currentIndex', currentIndex);
  }

  // 构建设置项组件
  Widget _buildSettingItem({
    required String mode,
    required String text,
    required dynamic currentValue,
    required List<dynamic> options,
    required Function(dynamic) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (mode == 'dropdown')
          DropdownButtonHideUnderline(
            child: DropdownButton2<dynamic>(
              value: currentValue,
              onChanged: (dynamic newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
              items: options.map<DropdownMenuItem<dynamic>>((dynamic item) {
                String label;
                dynamic value;
                
                if (item is String) {
                  label = item;
                  value = item;
                } else if (item is Map<String, String>) {
                  label = item['label']!;
                  value = item['value'];
                } else {
                  label = item.toString();
                  value = item;
                }
                
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: 40,
                width: 150,
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 300,
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          )
        else if (mode == 'number')
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              controller: TextEditingController()..text = currentValue.toString(),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final number = int.tryParse(value);
                  if (number != null) {
                    onChanged(number);
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '词典设置',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingItem(
                      mode: 'dropdown',
                      text: '默认词典:',
                      currentValue: selectedDictionary,
                      options: dictionaries,
                      onChanged: (value) {
                        setState(() {
                          selectedDictionary = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '学习进度',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingItem(
                      mode: 'number',
                      text: '当前单词位置:',
                      currentValue: currentIndex,
                      options: [],
                      onChanged: (value) {
                        setState(() {
                          currentIndex = value;
                        });
                        _saveSettings();
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '词典单词索引',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // 可以添加重置设置等功能
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重置设置'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DropdownButton2<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>>? items;
  final ButtonStyleData? buttonStyleData;
  final DropdownStyleData? dropdownStyleData;
  final MenuItemStyleData? menuItemStyleData;

  const DropdownButton2({
    super.key,
    this.value,
    this.onChanged,
    this.items,
    this.buttonStyleData,
    this.dropdownStyleData,
    this.menuItemStyleData,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      underline: Container(),
      borderRadius: BorderRadius.circular(8),
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }
}

class ButtonStyleData {
  final EdgeInsetsGeometry padding;
  final double height;
  final double width;

  const ButtonStyleData({
    required this.padding,
    required this.height,
    required this.width,
  });
}

class DropdownStyleData {
  final double maxHeight;

  const DropdownStyleData({
    required this.maxHeight,
  });
}

class MenuItemStyleData {
  final EdgeInsetsGeometry padding;

  const MenuItemStyleData({
    required this.padding,
  });
}