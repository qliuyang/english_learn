import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalenderPage extends StatefulWidget {
  static const String routeName = '/calender';
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  // 存储签到日期的列表
  Set<DateTime> _checkedInDates = <DateTime>{};
  int _consecutiveDays = 0;
  int _totalCheckIns = 0;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadCheckInData();
  }

  // 加载签到数据
  Future<void> _loadCheckInData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载连续签到天数
    _consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
    
    // 加载总签到次数
    _totalCheckIns = prefs.getInt('total_check_ins') ?? 0;
    
    // 加载签到日期列表
    final List<String>? dateStrings = prefs.getStringList('check_in_dates');
    if (dateStrings != null) {
      _checkedInDates = dateStrings
          .map((dateStr) => DateFormat('yyyy-MM-dd').parse(dateStr))
          .toSet();
    }
    
    setState(() {});
  }

  // 保存签到数据
  Future<void> _saveCheckInData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 保存连续签到天数
    await prefs.setInt('consecutive_days', _consecutiveDays);
    
    // 保存总签到次数
    await prefs.setInt('total_check_ins', _totalCheckIns);
    
    // 保存签到日期列表
    final List<String> dateStrings = _checkedInDates
        .map((date) => DateFormat('yyyy-MM-dd').format(date))
        .toList();
    await prefs.setStringList('check_in_dates', dateStrings);
  }

  // 检查是否今天已签到
  bool get _isTodayCheckedIn {
    final today = DateTime.now();
    return _checkedInDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  // 执行签到操作
  Future<void> _performCheckIn() async {
    if (_isTodayCheckedIn) return;

    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    setState(() {
      _checkedInDates.add(today);
      _totalCheckIns++;

      // 检查是否连续签到
      if (_checkedInDates.any((date) =>
          date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day)) {
        _consecutiveDays++;
      } else {
        _consecutiveDays = 1; // 重新开始计算连续签到
      }
    });

    // 保存数据
    await _saveCheckInData();

    // 取消今天的签到提醒通知
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    await notificationsPlugin.cancel(1);

    // 显示签到成功提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('签到成功！已连续签到 $_consecutiveDays 天'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 构建日历网格
  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    
    // 获取当月第一天是星期几 (0=Sunday, 1=Monday, ..., 6=Saturday)
    int firstDayWeekday = firstDayOfMonth.weekday % 7;
    
    // 创建日历单元格列表
    List<Widget> dayWidgets = [];
    
    // 添加空白单元格以对齐第一天
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }
    
    // 添加日期单元格
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      final isCheckInDay = _checkedInDates.any((checkDate) =>
          checkDate.year == date.year &&
          checkDate.month == date.month &&
          checkDate.day == date.day);
      
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      
      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isCheckInDay 
                ? (isToday ? Colors.lightBlue : Colors.green) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday 
                ? Border.all(color: Colors.blue, width: 2) 
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCheckInDay ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 7,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('签到'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 签到统计卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('连续签到', '$_consecutiveDays 天'),
                      _buildStatItem('总签到', '$_totalCheckIns 次'),
                      _buildStatItem('今日', _isTodayCheckedIn ? '已签到' : '未签到'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 签到按钮
              Center(
                child: ElevatedButton(
                  onPressed: _isTodayCheckedIn ? null : _performCheckIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _isTodayCheckedIn ? '已签到' : '立即签到',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 日历标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy年MM月').format(_currentDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // 星期标题
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('日', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('一', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('二', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('三', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('四', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('五', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('六', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // 日历网格
              _buildCalendar(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建统计数据项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
      ],
    );
  }
}