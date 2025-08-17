import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class CheckInReminderService {
  static final CheckInReminderService _instance = CheckInReminderService._internal();
  factory CheckInReminderService() => _instance;
  CheckInReminderService._internal();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const int _notificationId = 1;
  
  Future<void> initialize() async {
    // 初始化时区数据
    tz.initializeTimeZones();
    
    // 初始化通知插件
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }
  
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
  
  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    // 取消之前的提醒
    await _notificationsPlugin.cancel(_notificationId);
    
    // 设置新的每日提醒
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'check_in_reminder',
      '签到提醒',
      channelDescription: '每日签到提醒',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    // 设置每天提醒时间
    await _notificationsPlugin.zonedSchedule(
      _notificationId,
      '每日签到提醒',
      '不要忘记签到哦，坚持签到可以获得更多积分奖励！',
      _nextInstanceOfTime(hour, minute),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  Future<void> cancelReminder() async {
    await _notificationsPlugin.cancel(_notificationId);
  }
  
  Future<bool> isCheckInToday() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载签到日期列表
    final List<String>? dateStrings = prefs.getStringList('check_in_dates');
    if (dateStrings != null) {
      final Set<DateTime> checkedInDates = dateStrings
          .map((dateStr) => DateFormat('yyyy-MM-dd').parse(dateStr))
          .toSet();
      
      final today = DateTime.now();
      return checkedInDates.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    }
    
    return false;
  }
  
  Future<void> showCheckInReminder() async {
    // 检查今天是否已签到
    final bool isCheckedIn = await isCheckInToday();
    
    // 如果今天未签到，则发送提醒通知
    if (!isCheckedIn) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'check_in_reminder',
        '签到提醒',
        channelDescription: '每日签到提醒',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _notificationsPlugin.show(
        _notificationId,
        '每日签到提醒',
        '不要忘记签到哦，坚持签到可以获得更多积分奖励！',
        notificationDetails,
      );
    }
  }
}