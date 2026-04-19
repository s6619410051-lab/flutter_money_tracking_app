import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/splash_screen_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// จุดเริ่มต้นของแอปฯ
void main() async {
  // ต้องเรียกก่อนเสมอเมื่อใช้ async ใน main()
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- ตั้งค่าการเชื่อมต่อกับ Supabase ------------
  // ใส่ URL และ anonKey ของโปรเจค Supabase ของคุณที่นี่
  await Supabase.initialize(
    url:
        'https://qdsyiwotmadwgjlzzvnc.supabase.co', // <-- เปลี่ยนเป็น URL ของคุณ
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkc3lpd290bWFkd2dqbHp6dm5jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMTkzMzUsImV4cCI6MjA5MTg5NTMzNX0.hlIAGxob-vt4C1vdjkHLzg1h96c3rTH66VNWQW_DPtQ', // <-- เปลี่ยนเป็น Key ของคุณ
  );
  // -------------------------------------------------------

  runApp(const FlutterMoneyTrackingApp());
}

// Widget หลักของแอปฯ (StatefulWidget เพื่อรองรับการเปลี่ยนแปลงในอนาคต)
class FlutterMoneyTrackingApp extends StatefulWidget {
  const FlutterMoneyTrackingApp({super.key});

  @override
  State<FlutterMoneyTrackingApp> createState() =>
      _FlutterMoneyTrackingAppState();
}

class _FlutterMoneyTrackingAppState extends State<FlutterMoneyTrackingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ซ่อน banner debug มุมขวาบน
      // กำหนดหน้าแรกของแอปฯ เป็น SplashScreen
      home: const SplashScreenUi(),
      // ใช้ฟอนต์ Prompt (ภาษาไทย) ทั้งแอปฯ
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(Theme.of(context).textTheme),
        // กำหนด Color Scheme หลักของแอปฯ (น้ำเงิน, เหลือง, ขาว)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // น้ำเงินเข้ม
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFFFFD600), // เหลือง
          surface: Colors.white,
        ),
      ),
    );
  }
}
