import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'controllers/amal_controller.dart';
import 'views/amal_tracker_home.dart';
import 'services/notification_service.dart';

// নোটিফিকেশন অ্যাকশন বাটন ব্যাকগ্রাউন্ডে হ্যান্ডেল করার এন্ট্রি পয়েন্ট
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // ব্যাকগ্রাউন্ড আইসোলেটে অবশই বাইন্ডিং আগে ইনিশিয়েলাইজ করতে হয়
  WidgetsFlutterBinding.ensureInitialized();
  
  if (notificationResponse.actionId == 'sadakah_done') {
    try {
      await NotificationService().handleBackgroundSadakah();
    } catch (e) {
      debugPrint("Background sadakah handler error: $e");
    }
  }
}

void main() async {
  // ১. ফ্লাটার উইজেট বাইন্ডিং নিশ্চিত করা (সবার আগে)
  WidgetsFlutterBinding.ensureInitialized();
  
  // ২. নোটিফিকেশন সার্ভিস ইনিশিয়ালাইজেশন (এটি দ্রুত হয়, তাই await থাকবে)
  try {
    await NotificationService().initNotification(notificationTapBackground);
  } catch (e) {
    debugPrint("Notification initialization failed: $e");
  }
  
  // ৩. রিমাইন্ডার শিডিউলিং সম্পূর্ণ নন-ব্লকিং প্যারালাল থ্রেডে দেওয়া হয়েছে
  // এর ফলে এটি ব্যাকগ্রাউন্ডে রান হবে এবং অ্যাপ ১ সেকেন্ডে ওপেন হবে
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService().scheduleAllSmartReminders().catchError((e) {
      debugPrint("Background reminder scheduling error: $e");
    });
  });
  
  // ৪. অ্যাপ ওপেন হওয়ার সময় হালকা সাউন্ড প্লে করা
  _playAppOpenSound();

  runApp(const AmalTrackerApp());
}

// প্রতিবার অ্যাপ ওপেন করার সময় সাউন্ড প্লে করার মেথড
void _playAppOpenSound() {
  try {
    final player = AudioPlayer();
    player.play(AssetSource('sounds/open.mp3'));
  } catch (e) {
    debugPrint("App open sound error: $e");
  }
}

class AmalTrackerApp extends StatelessWidget {
  const AmalTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AmalController()),
      ],
      child: MaterialApp(
        title: 'Amal Tracker',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('bn', 'BD'),
          Locale('en', 'US'),
        ],
        locale: const Locale('bn', 'BD'),
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFF111E1E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF12E5A0),
            surface: Color(0xFF111A1A),
          ),
        ),
        home: const AmalTrackerHome(),
      ),
    );
  }
}