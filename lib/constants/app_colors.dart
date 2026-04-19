// ============================================================
// app_colors.dart — ค่าสีกลางของแอปฯ
// เก็บสีทั้งหมดไว้ที่นี่ที่เดียว ถ้าอยากเปลี่ยนธีมก็แก้ที่นี่จุดเดียว
// ธีม: น้ำเงิน | เหลือง | ขาว
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // สีหลัก (Primary) — น้ำเงิน
  static const Color primary = Color(0xFF1565C0); // น้ำเงินเข้ม
  static const Color primaryLight = Color(0xFF1E88E5); // น้ำเงินอ่อน
  static const Color primaryDark = Color(0xFF0D47A1); // น้ำเงินเข้มมาก

  // สีเสริม (Accent) — เหลือง
  static const Color accent = Color(0xFFFFD600); // เหลืองสด
  static const Color accentDark = Color(0xFFFFC107); // เหลืองเข้ม

  // สีพื้นหลัง
  static const Color background = Color(0xFFF5F7FA); // ขาวอมเทาอ่อนๆ
  static const Color surface = Colors.white;

  // สีสำหรับรายรับ / รายจ่าย
  static const Color income = Color(0xFF2E7D32); // เขียวเข้ม
  static const Color expense = Color(0xFFC62828); // แดงเข้ม

  // สีข้อความ
  static const Color textPrimary = Color(0xFF1A237E); // น้ำเงินเข้ม (หัวข้อ)
  static const Color textSecondary = Color(0xFF546E7A); // เทา (คำอธิบาย)
  static const Color textOnPrimary = Colors.white; // ข้อความบนพื้นน้ำเงิน
  static const Color textOnAccent = Color(0xFF1A237E); // ข้อความบนพื้นเหลือง
}
