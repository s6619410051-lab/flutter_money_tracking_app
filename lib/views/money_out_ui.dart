// ============================================================
// money_out_ui.dart — หน้าบันทึกรายจ่าย
// โครงสร้างเหมือน money_in_ui.dart แต่ type = 'expense'
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/constants/app_colors.dart';
import 'package:flutter_money_tracking_app/models/transaction.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:intl/intl.dart';

class MoneyOutUi extends StatefulWidget {
  const MoneyOutUi({super.key});

  @override
  State<MoneyOutUi> createState() => _MoneyOutUiState();
}

class _MoneyOutUiState extends State<MoneyOutUi> {
  // Controllers
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();

  // หมวดหมู่รายจ่าย
  String _selectedCategory = 'อาหาร';
  final List<String> _categories = [
    'อาหาร',
    'เดินทาง',
    'ที่พัก',
    'สุขภาพ',
    'บันเทิง',
    'ช้อปปิ้ง',
    'ค่าน้ำค่าไฟ',
    'อื่นๆ',
  ];

  DateTime? _selectedDate;
  final _service = SupabaseService();
  bool _isSaving = false;

  // เปิดปฏิทินเลือกวันที่
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.expense,
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
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Validate และบันทึก
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
      // สร้าง Transaction object พร้อม type = 'expense'
      final txn = Transaction(
        type: 'expense',
        amount: double.parse(_amountCtrl.text),
        category: _selectedCategory,
        note: _noteCtrl.text.trim(),
        txn_date: _dateCtrl.text,
      );

      await _service.insertTransaction(txn);
      _showSnackBar('บันทึกรายจ่ายเรียบร้อยแล้ว ✓', isError: false);

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    }

    setState(() => _isSaving = false);
  }

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

  void _clearForm() {
    setState(() {
      _amountCtrl.clear();
      _noteCtrl.clear();
      _dateCtrl.clear();
      _selectedDate = null;
      _selectedCategory = 'อาหาร';
    });
  }

  @override
  void dispose() {
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
        backgroundColor: AppColors.expense,
        title: const Text(
          'บันทึกรายจ่าย',
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
                  color: AppColors.expense.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                  size: 45,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // จำนวนเงิน
            _buildLabel('จำนวนเงิน (บาท) *'),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                hintText: 'เช่น 350',
                prefixIcon: Icons.attach_money_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // หมวดหมู่ (Dropdown)
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

            // หมายเหตุ
            _buildLabel('หมายเหตุ (ไม่บังคับ)'),
            TextField(
              controller: _noteCtrl,
              decoration: _inputDecoration(
                hintText: 'เช่น ค่าข้าวกลางวัน',
                prefixIcon: Icons.notes_rounded,
              ),
            ),
            const SizedBox(height: 16),

            // วันที่
            _buildLabel('วันที่ *'),
            TextField(
              controller: _dateCtrl,
              readOnly: true,
              decoration: _inputDecoration(
                hintText: 'กดเพื่อเลือกวันที่',
                prefixIcon: Icons.calendar_today_rounded,
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 30),

            // ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึกรายจ่าย',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ปุ่มล้างข้อมูล
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
                  style:
                      TextStyle(fontSize: 17, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(prefixIcon, color: AppColors.expense),
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
        borderSide: const BorderSide(color: AppColors.expense, width: 2),
      ),
    );
  }
}
