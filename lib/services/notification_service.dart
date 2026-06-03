import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../services/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final DBHelper _dbHelper = DBHelper();

  Future<void> initNotification(void Function(NotificationResponse) backgroundHandler) async {
    try {
      tz.initializeTimeZones();
      
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      // ফিক্সড: ভেরিয়েবলের নাম সংশোধন করে 'initializationSettings' করা হয়েছে
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // ফোরগ্রাউন্ডে ক্লিক হ্যান্ডেল করার জন্য
        },
        onDidReceiveBackgroundNotificationResponse: backgroundHandler,
      );
    } catch (e) {
      debugPrint("Error inside initNotification: $e");
    }
  }

  Future<void> scheduleAllSmartReminders() async {
    try {
      await Future.wait([
        scheduleDailyReminder(id: 1, title: 'ফজরের সালাতের ওয়াক্ত 🕋', body: 'রাসুলুল্লাহ (ﷺ) বলেছেন, "যে ব্যক্তি ফজর সালাত আদায় করল সে আল্লাহর জিম্মায় চলে গেল।"- চলন প্রথম ওয়াক্তে সালাত আদায় করি।', hour: 4, minute: 30),
        scheduleDailyReminder(id: 2, title: 'যোহরের সালাতের ওয়াক্ত 🕋', body: 'যোহরের ওয়াক্ত শুরু হয়েছে। দুনিয়ার ব্যস্ততা সরিয়ে রেখে রবের ডাকে সাড়া দিন ✨', hour: 12, minute: 15),
        scheduleDailyReminder(id: 3, title: 'আসরের সালাতের ওয়াক্ত 🕋', body: 'আসরের ওয়াক্ত হয়েছে। রাসুলুল্লাহ (ﷺ) বলেছেন, "যার আসরের সালাত ছুটে গেল তার পরিবার ও ধনসম্পদ যেন ধ্বংস হয়ে গেল।" [বুখারী]', hour: 16, minute: 30),
        scheduleDailyReminder(id: 4, title: 'মাগরিবের সালাতের ওয়াক্ত 🕋', body: 'মাগরিবের ওয়াক্ত হয়েছে। দেরি না করে দ্রুত প্রথম ওয়াক্তে সালাত সম্পন্ন করুন 🌅', hour: 18, minute: 45),
        scheduleDailyReminder(id: 5, title: 'ইশার সালাতের ওয়াক্ত 🕋', body: 'ইশার ওয়াক্ত হয়েছে। সারাদিনের ক্লান্তি ভুলে রবের সামনে সিজদায় দাঁড়ানোর প্রশান্তি নিন 🌌', hour: 20, minute: 0),
        scheduleDailyReminder(id: 11, title: 'সকালের মাসনুন দুআ ও জিকির 🌅', body: 'ফজর তো হলো, এবার সকালের আমলগুলো করে আপনার দিনটি বরকতময় ও নিরাপদ করে তুলুন।', hour: 5, minute: 30),
        scheduleDailyReminder(id: 12, title: 'সন্ধ্যার মাসনুন দুআ ও জিকির 🌌', body: 'দিনের শেষভাগে একটু সময় দিন। সন্ধ্যার আমল ও ইস্তিগফারের মাধ্যমে সারাদিনের ভুলত্রুটি ক্ষমা করিয়ে নিন।', hour: 17, minute: 15),
        scheduleSadakahReminder(hour: 9, minute: 30),
        scheduleSmartExerciseReminder(hour: 17, minute: 0),
        scheduleEndDaySummary(),
      ]);
    } catch (e) {
      debugPrint("Error inside scheduleAllSmartReminders: $e");
    }
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'amal_reminder_channel',
            'Amal Reminders',
            channelDescription: 'Daily reminders for tracking spiritual goals',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Failed to schedule daily reminder $id: $e");
    }
  }

  Future<void> scheduleSadakahReminder({required int hour, required int minute}) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        50,
        'আজকে কি কোনো সাদাকাহ করেছেন? 🪙',
        'রাসুলুল্লাহ (ﷺ) বলেছেন: "নিশ্চয়ই সদকা আল্লাহর ক্রোধকে প্রশমিত করে এবং অপমৃত্যু রোধ করে।" [তিরমিযী]',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sadakah_reminder_channel',
            'Sadakah Reminders',
            channelDescription: 'Reminders with interactive actions for donation',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'sadakah_done',
                'হ্যাঁ, সাদাকাহ দিয়েছি ✅',
                showsUserInterface: false,
                cancelNotification: true,
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Failed to schedule sadakah reminder: $e");
    }
  }

  Future<void> handleBackgroundSadakah() async {
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      await _dbHelper.insertOrUpdateLog(todayStr, 'sadakah', 1);
      debugPrint("Sadakah successfully marked complete from background notification!");
    } catch (e) {
      debugPrint("Error updating background sadakah: $e");
    }
  }

  Future<void> scheduleSmartExerciseReminder({required int hour, required int minute}) async {
    try {
      String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      List<Map<String, dynamic>> logs = [];
      
      try {
        logs = await _dbHelper.getLogsByDate(todayStr);
      } catch (dbError) {
        debugPrint("Database not ready during workout check: $dbError");
      }
      
      bool isExerciseDone = logs.any((log) => log['task_id'] == 'exercise' && log['is_completed'] == 1);

      if (!isExerciseDone) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          60,
          'শরীর ও মন চাঙ্গা রাখার সময় হয়েছে! 🏃‍♂️',
          '"নিশ্চয়ই আপনার শরীরেরও আপনার ওপর অধিকার রয়েছে।" [বুখারী] চলুন, আজকের ১০-১৫ মিনিটের ওয়ার্কআউট সম্পন্ন করি।',
          _nextInstanceOfTime(hour, minute),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'exercise_reminder_channel',
              'Exercise Reminders',
              channelDescription: 'Conditional fitness alerts if pending',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('notification'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      debugPrint("Failed to schedule exercise reminder: $e");
    }
  }

  Future<void> scheduleCustomTaskNotification(String taskId, String title, String startTime, String dateStr) async {
    try {
      final parts = startTime.split(':');
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      
      final parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, parsedDate.year, parsedDate.month, parsedDate.day, hour, minute
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      int notificationId = taskId.hashCode.abs();

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'নিজের কাস্টম টাস্কের সময় হয়েছে 📝',
        'আপনার সেট করা "$title" আমলটি শুরু করার সময় হয়েছে। উম্মাহর কল্যাণে এটি সম্পন্ন করুন ✨',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'custom_task_channel',
            'Custom Tasks',
            channelDescription: 'Notifications for your custom tasks',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Custom task notification scheduling failed: $e");
    }
  }

  Future<void> cancelCustomTaskNotification(String taskId) async {
    try {
      int notificationId = taskId.hashCode.abs();
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      debugPrint("Failed to cancel custom notification: $e");
    }
  }

  Future<void> scheduleEndDaySummary() async {
    try {
      final now = DateTime.now();
      String dateStr = DateFormat('yyyy-MM-dd').format(now);
      List<Map<String, dynamic>> logs = [];
      
      try {
        logs = await _dbHelper.getLogsByDate(dateStr);
      } catch (_) {}
      
      int completed = logs.where((log) => log['is_completed'] == 1).length;
      int total = 14; 
      int percent = total > 0 ? ((completed / total) * 100).toInt() : 0;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        202,
        'আজকের দিনের আমল রিপোর্ট! 🌟',
        'আলহামদুলিল্লাহ, আজ আপনি $percent% আমল সম্পন্ন করেছেন। আগামীকাল আরও উন্নত করার চেষ্টা করুন!',
        _nextInstanceOfTime(23, 45),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'amal_summary_channel',
            'Amal Daily Summary',
            channelDescription: 'End of day performance score summary',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Failed to schedule end day summary: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}