// ============================================================
// money_in_ui.dart — หน้าบันทึกรายรับ
// Validate ข้อมูล → บันทึกลง Supabase → กลับหน้า Home
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/constants/app_colors.dart';
import 'package:flutter_money_tracking_app/models/transaction.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:intl/intl.dart';

class MoneyInUi extends StatefulWidget {
  const MoneyInUi({super.key});

  @override
  State<MoneyInUi> createState() => _MoneyInUiState();
}

class _MoneyInUiState extends State<MoneyInUi> {
  // ---------- Controllers สำหรับ TextField ----------
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  // หมวดหมู่รายรับที่เลือกอยู่
  String _selectedCategory = 'เงินเดือน';

  // วันที่ที่เลือก (เก็บเป็น DateTime เพื่อแปลงรูปแบบ)
  DateTime? _selectedDate;

  // รายการหมวดหมู่รายรับ
  final List<String> _categories = [
    'เงินเดือน',
    'ธุรกิจ',
    'ค่าจ้าง',
    'โบนัส',
    'ดอกเบี้ย',
    'อื่นๆ',
  ];

  // instance ของ Service
  final _service = SupabaseService();

  // สถานะกำลังบันทึก (ป้องกันกดซ้ำ)
  bool _isSaving = false;

  // ----------------------------------------------------------
  // เปิดปฏิทินให้ผู้ใช้เลือกวันที่
  // ----------------------------------------------------------
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        // กำหนดสีของ DatePicker ให้ตรงธีม
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // แสดงวันที่ในรูปแบบ yyyy-MM-dd
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // ----------------------------------------------------------
  // Validate และบันทึกข้อมูลลง Supabase
  // ----------------------------------------------------------
  Future<void> _saveTransaction() async {
    // ---------- Validate UI ----------
    if (_amountCtrl.text.isEmpty) {
      _showSnackBar('กรุณากรอกจำนวนเงิน', isError: true);
      return;
    }
    if (double.tryParse(_amountCtrl.text) == null ||
        double.parse(_amountCtrl.text) <= 0) {
      _showSnackBar('จำนวนเงินต้องเป็นตัวเลขที่มากกว่า 0', isError: true);
      return;
    }
    if (_dateCtrl.text.isEmpty) {
      _showSnackBar('กรุณาเลือกวันที่', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // สร้าง Transaction object พร้อม type = 'income'
      final txn = Transaction(
        type: 'income',
        amount: double.parse(_amountCtrl.text),
        category: _selectedCategory,
        note: _noteCtrl.text.trim(),
        txn_date: _dateCtrl.text,
      );

      // ส่งไปบันทึกที่ Supabase ผ่าน Service
      await _service.insertTransaction(txn);

      _showSnackBar('บันทึกรายรับเรียบร้อยแล้ว ✓', isError: false);

      // รอให้ SnackBar แสดงสั้นๆ แล้วกลับหน้าก่อนหน้า
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // แสดง error ถ้าบันทึกไม่สำเร็จ
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    }

    setState(() => _isSaving = false);
  }

  // ----------------------------------------------------------
  // แสดง SnackBar แจ้งผล
  // ----------------------------------------------------------
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.expense : AppColors.income,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ----------------------------------------------------------
  // เคลียร์ฟอร์มทั้งหมด
  // ----------------------------------------------------------
  void _clearForm() {
    setState(() {
      _amountCtrl.clear();
      _noteCtrl.clear();
      _dateCtrl.clear();
      _selectedDate = null;
      _selectedCategory = 'เงินเดือน';
    });
  }

  @override
  void dispose() {
    // คืน resource ของ controller เมื่อ widget ถูกทำลาย
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.income,
        title: const Text(
          'บันทึกรายรับ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอนบนสุด
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.income.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.income,
                  size: 45,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- ฟิลด์จำนวนเงิน ----------
            _buildLabel('จำนวนเงิน (บาท) *'),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                hintText: 'เช่น 15000',
                prefixIcon: Icons.attach_money_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // ---------- ฟิลด์หมวดหมู่ (Dropdown) ----------
            _buildLabel('หมวดหมู่'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------- ฟิลด์หมายเหตุ ----------
            _buildLabel('หมายเหตุ (ไม่บังคับ)'),
            TextField(
              controller: _noteCtrl,
              decoration: _inputDecoration(
                hintText: 'เช่น เงินเดือนเดือนมกราคม',
                prefixIcon: Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // ---------- ฟิลด์วันที่ (เปิด DatePicker เมื่อกด) ----------
            _buildLabel('วันที่ *'),
            TextField(
              controller: _dateCtrl,
              readOnly: true, // ห้ามพิมพ์ตรง ต้องเลือกจากปฏิทิน
              decoration: _inputDecoration(
                hintText: 'กดเพื่อเลือกวันที่',
                prefixIcon: Icons.calendar_today_rounded,
              ),
              onTap: _pickDate, // เปิดปฏิทินเมื่อกด
            ),
            const SizedBox(height: 30),

            // ---------- ปุ่มบันทึก ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึกรายรับ',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ---------- ปุ่มยกเลิก/เคลียร์ ----------
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: _clearForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ล้างข้อมูล',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ย่อย: Label เหนือ TextField
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // InputDecoration กลางใช้ทุก TextField
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
