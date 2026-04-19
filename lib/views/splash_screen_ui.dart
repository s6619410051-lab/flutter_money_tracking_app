// ============================================================
// splash_screen_ui.dart — หน้า Splash Screen
// แสดงโลโก้และชื่อแอปฯ 3 วินาที แล้วไปหน้า Home
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/constants/app_colors.dart';
import 'package:flutter_money_tracking_app/views/home_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi>
    with SingleTickerProviderStateMixin {
  // ตัวควบคุม Animation สำหรับ fade-in โลโก้
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // ตั้งค่า Animation fade-in (0 → 1) ใช้เวลา 1.2 วินาที
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );
    _animCtrl.forward(); // เริ่ม animation

    // หลังจาก 3 วินาที ให้ข้ามไปหน้า HomeUi
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeUi()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose(); // คืน resource เมื่อ widget ถูกทำลาย
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังไล่สีน้ำเงิน
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim, // ใช้ Animation fade-in
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ไอคอนแอปฯ (ใช้ Icon แทน Image เพื่อความง่าย)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 70,
                    color: AppColors.textOnAccent,
                  ),
                ),
                const SizedBox(height: 28),

                // ชื่อแอปฯ
                const Text(
                  'Money Tracking',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // คำอธิบาย
                const Text(
                  'บันทึกรายรับรายจ่ายของฉัน',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),

                // Loading indicator
                const CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
