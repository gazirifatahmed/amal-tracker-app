import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/amal_model.dart';
import '../services/db_helper.dart';

class AmalController extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  String get formattedDate =>
      DateFormat('EEEE, MMMM dd, yyyy', 'bn').format(_selectedDate);
  String get dbDateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  List<AmalCategory> categories = [];
  int totalTasks = 0;
  int completedTasks = 0;
  double completionPercentage = 0.0;

  AmalController() {
    loadDailyData(_selectedDate);
  }

  void _initFixedCategories() {
    categories = [
      AmalCategory(
        title: 'ফরজ নামাজ সমূহ',
        tasks: [
          AmalTask(
            id: 'fajr',
            title: 'ফজর',
            category: 'ফরজ নামাজ সমূহ',
            isCustom: false,
          ),
          AmalTask(
            id: 'zuhr',
            title: 'যোহর',
            category: 'ফরজ নামাজ সমূহ',
            isCustom: false,
          ),
          AmalTask(
            id: 'asr',
            title: 'আসর',
            category: 'ফরজ নামাজ সমূহ',
            isCustom: false,
          ),
          AmalTask(
            id: 'maghrib',
            title: 'মাগরিব',
            category: 'ফরজ নামাজ সমূহ',
            isCustom: false,
          ),
          AmalTask(
            id: 'isha',
            title: 'ইশা',
            category: 'ফরজ নামাজ সমূহ',
            isCustom: false,
          ),
        ],
      ),
      AmalCategory(
        title: 'নফল নামাজ সমূহ',
        tasks: [
          AmalTask(
            id: 'duha',
            title: 'দুহা (ইশরাক ও চাশত)',
            category: 'নফল নামাজ সমূহ',
            isCustom: false,
          ),
          AmalTask(
            id: 'tahajjud',
            title: 'তাহাজ্জুদ',
            category: 'নফল নামাজ সমূহ',
            isCustom: false,
          ),
        ],
      ),
      AmalCategory(
        title: 'কুরআন ও দ্বীনি ইলম',
        tasks: [
          AmalTask(
            id: 'quran_tilawat',
            title: 'কুরআন تিলাওয়াত',
            category: 'কুরআন ও দ্বীনি ইলম',
            isCustom: false,
          ),
          AmalTask(
            id: 'quran_meaning',
            title: 'অর্থ সহ কুরআন অধ্যয়ন',
            category: 'কুরআন ও দ্বীনি ইলম',
            isCustom: false,
          ),
        ],
      ),
      AmalCategory(
        title: 'হেফাজতের দুআ',
        tasks: [
          AmalTask(
            id: 'morning_dua',
            title: 'সকালের দুআ',
            category: 'হেফাজতের দুআ',
            isCustom: false,
          ),
          AmalTask(
            id: 'evening_dua',
            title: 'সন্ধ্যার দুআ',
            category: 'হেফাজতের দুআ',
            isCustom: false,
          ),
        ],
      ),
      AmalCategory(
        title: 'আত্ম-উন্নয়ন',
        tasks: [
          AmalTask(
            id: 'nafl_siyam',
            title: 'নফল সিয়াম',
            category: 'आত্মউন্নয়ন',
            isCustom: false,
          ),
          AmalTask(
            id: 'sadakah',
            title: 'সাদাকাহ',
            category: 'आত্মউন্নয়ন',
            isCustom: false,
          ),
          AmalTask(
            id: 'exercise',
            title: 'শরীরচর্চা',
            category: 'आत্মউন্নয়ন',
            isCustom: false,
          ),
        ],
      ),
    ];
  }

  void changeDate(DateTime date) {
    _selectedDate = date;
    loadDailyData(date);
  }

  Future<void> loadDailyData(DateTime date) async {
    _initFixedCategories();
    String dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Custom Tasks Load
    final customTaskLogs = await _dbHelper.getCustomTasksByDate(dateStr);
    List<AmalTask> customTasksList = [];

    for (var rawTask in customTaskLogs) {
      customTasksList.add(
        AmalTask(
          id: rawTask['id'].toString(),
          title: rawTask['title'].toString(),
          category: 'নিজের টাস্ক',
          isCustom: true,
          startTime: rawTask['start_time']?.toString(),
          endTime: rawTask['end_time']?.toString(),
        ),
      );
    }

    if (customTasksList.isNotEmpty) {
      categories.add(
        AmalCategory(
          title: 'নিজের টাস্ক',
          tasks: customTasksList,
          isCustomCategory: true,
        ),
      );
    }

    // Load Completion Status
    final completionLogs = await _dbHelper.getLogsByDate(dateStr);
    for (var log in completionLogs) {
      String taskId = log['task_id'].toString();
      bool isCompleted = log['is_completed'] == 1;

      for (var cat in categories) {
        for (var task in cat.tasks) {
          if (task.id == taskId) {
            task.isCompleted = isCompleted;
          }
        }
      }
    }

    _calculateTotals();
    notifyListeners();
  }

  Future<String?> toggleTask(AmalTask task) async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // শুধুমাত্র আজকের তারিখের জন্য সময়ের কঠোর কন্ডিশন এবং ওয়ার্নিং সাউন্ড ভ্যালিডেশন হবে
    if (dbDateStr == todayStr && !task.isCompleted) {
      String? warningMessage = task.validateTimeWindow();
      if (warningMessage != null) {
        try {
          await _audioPlayer.stop();
          await _audioPlayer.play(AssetSource('sounds/warning.mp3'));
        } catch (e) {
          debugPrint("Error playing warning sound: $e");
        }
        return warningMessage;
      }
    }

    // স্টেট পরিবর্তন
    task.isCompleted = !task.isCompleted;
    _calculateTotals();
    notifyListeners();

    try {
      await _dbHelper.insertOrUpdateLog(
        dbDateStr,
        task.id,
        task.isCompleted ? 1 : 0,
      );

      await _audioPlayer.stop();
      if (task.isCompleted) {
        // সফলভাবে টাস্ক কমপ্লিট হলে সাকসেস সাউন্ড
        await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      } else {
        // অলরেডি কমপ্লিট টাস্ক আনচেক/এডিট করলে এডিট সাউন্ড
        await _audioPlayer.play(AssetSource('sounds/edit.mp3'));
      }
      return null;
    } catch (e) {
      // রিলব্যাক স্টেট যদি ডেটাবেজে ইরর আসে
      task.isCompleted = !task.isCompleted;
      _calculateTotals();
      notifyListeners();
      return 'ডাটা সেভ করতে সমস্যা হয়েছে।';
    }
  }

  void _calculateTotals() {
    int total = 0;
    int completed = 0;
    for (var cat in categories) {
      total += cat.tasks.length;
      completed += cat.tasks.where((t) => t.isCompleted).length;
    }
    totalTasks = total;
    completedTasks = completed;
    completionPercentage = total > 0 ? completed / total : 0.0;
  }

  void toggleCategoryExpansion(AmalCategory category) {
    category.isExpanded = !category.isExpanded;
    notifyListeners();
  }

  Future<String?> addCustomTask(String title, String start, String end) async {
    try {
      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      // এখানে প্যারামিটারগুলো DBHelper এর সাথে মিলিয়ে সিরিয়ালে সাজানো হলো (id, title, date, start, end)
      await _dbHelper.insertCustomTask(id, title, dbDateStr, start, end);
      await loadDailyData(_selectedDate);

      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/add.mp3'));
      return null;
    } catch (e) {
      return 'টাস্ক যুক্ত করা সম্ভব হয়নি।';
    }
  }
}