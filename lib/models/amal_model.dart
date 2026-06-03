class AmalTask {
  final String id;
  final String title;
  final String category;
  bool isCompleted;          // রানটাইমে চেঞ্জ হয় তাই final নয়
  bool isCustom;             // কন্ট্রোলারের ডাইনামিক চেকের সুবিধার্থে এটি bool টাইপ নিশ্চিত করা হলো
  final String? startTime;   // ফরম্যাট: "HH:mm" (যেমন "14:00")
  final String? endTime;     // ফরম্যাট: "HH:mm" (যেমন "15:00")
  final String? customDate;  // নির্দিষ্ট তারিখ ট্র্যাকিং (যেমন "2026-06-02")

  AmalTask({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false, // ডিফল্ট ভ্যালু স্পষ্ট বুুলিয়ান
    this.isCustom = false,    // ডিফল্ট ভ্যালু স্পষ্ট বুুলিয়ান
    this.startTime,
    this.endTime,
    this.customDate,
  });

  // নির্দিষ্ট টাস্কটির সময় উইন্ডো ভ্যালিডেশন করার নিখুঁত লজিক
  String? validateTimeWindow() {
    final now = DateTime.now();
    final double currentTime = now.hour + (now.minute / 60.0);

    // ১. কাস্টম টাস্কের জন্য স্টার্ট এবং এন্ড টাইমের নিখুঁত ভ্যালিডেশন
    if (isCustom && startTime != null && endTime != null) {
      try {
        final startParts = startTime!.split(':');
        final int startHour = int.parse(startParts[0]);
        final int startMin = int.parse(startParts[1]);
        final double customStartTime = startHour + (startMin / 60.0);

        final endParts = endTime!.split(':');
        final int endHour = int.parse(endParts[0]);
        final int endMin = int.parse(endParts[1]);
        final double customEndTime = endHour + (endMin / 60.0);

        if (currentTime < customStartTime) {
          return 'টাস্কটি শুরু হওয়ার সময় এখনও হয়নি।';
        }
        if (currentTime > customEndTime) {
          return 'টাস্কটির নির্ধারিত সময় পার হয়ে গেছে।';
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    // ২. ফিক্সড আমল সমূহের জন্য রিকোয়ারমেন্ট অনুযায়ী ওয়াক্তের বাধানিষেধ
    switch (id) {
      case 'fajr':
        if (currentTime < 4.5) return 'ফজরের ওয়াক্ত এখনও শুরু হয়নি।'; // ৪:৩০ এর আগে
        if (currentTime > 6.0) return 'ফজরের ওয়াক্ত শেষ হয়ে গেছে।';     // ৬:০০ এর পরে
        break;
      case 'tahajjud':
        if (currentTime > 4.5) return 'তাহাজ্জুদের সময় শেষ হয়ে গেছে।';
        break;
      case 'duha':
        if (currentTime < 6.0) return 'দুহার সময় এখনও শুরু হয়নি।';
        if (currentTime > 12.0) return 'দুহার সময় শেষ হয়ে গেছে।';
        break;
      case 'morning_dua':
        if (currentTime < 4.5) return 'সকালের মাসনুন আমল ফজরের আগে করা সম্ভব নয়।';
        if (currentTime > 12.0) return 'সকালের আমলের সময় শেষ হয়ে গেছে।';
        break;
      case 'zuhr':
        if (currentTime < 12.25) return 'যোহরের ওয়াক্ত এখনও শুরু হয়নি।'; // ১২:১৫ এর আগে
        if (currentTime > 16.5) return 'যোহরের ওয়াক্ত শেষ হয়ে গেছে।';     // ৪:৩০ এর পরে
        break;
      case 'asr':
        if (currentTime < 16.5) return 'আসরের ওয়াক্ত এখনও শুরু হয়নি।';   // ৪:৩০ এর আগে
        if (currentTime > 18.75) return 'আসরের ওয়াক্ত শেষ হয়ে গেছে।';    // ৬:৪৫ এর পরে
        break;
      case 'evening_dua':
        if (currentTime < 18.75) return 'সন্ধ্যার মাসনুন আমল মাগরিবের আগে করা সম্ভব নয়।'; // ৬:৪৫ এর আগে
        break;
      case 'maghrib':
        if (currentTime < 18.75) return 'মাগরিবের ওয়াক্ত এখনও শুরু হয়নি।'; // ৬:৪৫ এর আগে
        if (currentTime > 20.0) return 'মাগরিবের ওয়াক্ত শেষ হয়ে গেছে।';     // ৮:০০ এর পরে
        break;
      case 'nafl_siyam':
        if (currentTime < 18.75) return 'সিয়াম পালন শেষ হয় মাগরিবের পর, তাই মাগরিবের আগে সম্পন্ন করা যাবে না।';
        break;
      case 'isha':
        if (currentTime < 20.0) return 'ইশার ওয়াক্ত এখনও শুরু হয়নি।'; // ৮:০০ এর আগে
        break;
      default:
        return null;
    }
    return null;
  }

  // পুরানো এক্সপায়ারড মেথড যা UI তে স্টেট কালার নির্ধারণে হেল্প করে
  bool isExpired(DateTime selectedDate) {
    if (isCompleted) return false;

    final now = DateTime.now();
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    
    if (selectedDateOnly.isBefore(todayOnly)) {
      return true;
    }

    if (selectedDateOnly.isAtSameMomentAs(todayOnly)) {
      final double currentTime = now.hour + (now.minute / 60.0);

      if (isCustom && endTime != null) {
        try {
          final parts = endTime!.split(':');
          final int endHour = int.parse(parts[0]);
          final int endMin = int.parse(parts[1]);
          final double customEndTime = endHour + (endMin / 60.0);
          return currentTime > customEndTime;
        } catch (_) {
          return false;
        }
      }

      switch (id) {
        case 'fajr': return currentTime > 6.0;
        case 'duha': return currentTime > 12.0;
        case 'tahajjud': return currentTime > 5.0;
        case 'morning_dua': return currentTime > 12.0;
        case 'zuhr': return currentTime > 16.5; 
        case 'asr': return currentTime > 18.5; 
        case 'evening_dua': return currentTime > 20.0; 
        case 'maghrib': return currentTime > 20.0; 
        case 'isha': return currentTime > 23.99; 
        default: return false; 
      }
    }

    return false;
  }
}

class AmalCategory {
  final String title;
  final List<AmalTask> tasks;
  bool isExpanded;           // কন্ট্রোলারে toggle করার জন্য এটি পরিবর্তনশীল (bool)
  bool isCustomCategory;     // কাস্টম সেগমেন্ট আইডেন্টিফায়ার (bool)

  AmalCategory({
    required this.title,
    required this.tasks,
    this.isExpanded = true,         // স্পষ্ট বুুলিয়ান ডিফল্ট ভ্যালু
    this.isCustomCategory = false,   // স্পষ্ট বুুলিয়ান ডিফল্ট ভ্যালু
  });
}