// ============================================================
// transaction_detail_ui.dart — หน้าดูรายละเอียด / แก้ไข / ลบ
// รับ Transaction object มาแสดง และให้ผู้ใช้แก้ไขหรือลบได้
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/constants/app_colors.dart';
import 'package:flutter_money_tracking_app/models/transaction.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:intl/intl.dart';

class TransactionDetailUi extends StatefulWidget {
  // รับ Transaction object จากหน้า Home เพื่อแสดง/แก้ไข
  final Transaction transaction;

  const TransactionDetailUi({super.key, required this.transaction});

  @override
  State<TransactionDetailUi> createState() => _TransactionDetailUiState();
}

class _TransactionDetailUiState extends State<TransactionDetailUi> {
  // Controllers — กำหนดค่าเริ่มต้นจาก transaction ที่รับมา
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _dateCtrl;

  late String _selectedCategory;
  DateTime? _selectedDate;

  final _service = SupabaseService();
  bool _isSaving = false;
  bool _isDeleting = false;

  // กำหนดหมวดหมู่ตามประเภท
  List<String> get _categories => widget.transaction.type == 'income'
      ? ['เงินเดือน', 'ธุรกิจ', 'ค่าจ้าง', 'โบนัส', 'ดอกเบี้ย', 'อื่นๆ']
      : [
          'อาหาร',
          'เดินทาง',
          'ที่พัก',
          'สุขภาพ',
          'บันเทิง',
          'ช้อปปิ้ง',
          'ค่าน้ำค่าไฟ',
          'อื่นๆ'
        ];

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นจากข้อมูลเดิม
    _amountCtrl = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteCtrl = TextEditingController(text: widget.transaction.note);
    _dateCtrl = TextEditingController(text: widget.transaction.txn_date);
    _selectedCategory = widget.transaction.category;

    // แปลงวันที่จาก String กลับเป็น DateTime
    try {
      _selectedDate = DateTime.parse(widget.transaction.txn_date);
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // เปิดปฏิทินเลือกวันที่
  Future<void> _pickDate() async {
    final isIncome = widget.transaction.type == 'income';
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: isIncome ? AppColors.income : AppColors.expense,
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

  // ----------------------------------------------------------
  // บันทึกการแก้ไข (UPDATE)
  // ----------------------------------------------------------
  Future<void> _updateTransaction() async {
    // Validate
    if (_amountCtrl.text.isEmpty ||
        double.tryParse(_amountCtrl.text) == null ||
        double.parse(_amountCtrl.text) <= 0) {
      _showSnackBar('จำนวนเงินไม่ถูกต้อง', isError: true);
      return;
    }
    if (_dateCtrl.text.isEmpty) {
      _showSnackBar('กรุณาเลือกวันที่', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedTxn = Transaction(
        type: widget.transaction.type, // type ไม่เปลี่ยน
        amount: double.parse(_amountCtrl.text),
        category: _selectedCategory,
        note: _noteCtrl.text.trim(),
        txn_date: _dateCtrl.text,
      );

      // ส่งคำสั่ง UPDATE ไปที่ Supabase โดยใช้ id ของรายการนี้
      await _service.updateTransaction(widget.transaction.id!, updatedTxn);

      _showSnackBar('อัปเดตข้อมูลเรียบร้อยแล้ว ✓', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    }

    setState(() => _isSaving = false);
  }

  // ----------------------------------------------------------
  // ยืนยันและลบรายการ (DELETE)
  // ----------------------------------------------------------
  Future<void> _confirmDelete() async {
    // แสดง AlertDialog ยืนยันก่อนลบ
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
            'คุณต้องการลบรายการนี้หรือไม่?\nการดำเนินการนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // ยกเลิก
            child: const Text('ยกเลิก',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), // ยืนยันลบ
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return; // ผู้ใช้กดยกเลิก

    setState(() => _isDeleting = true);

    try {
      // ส่งคำสั่ง DELETE ไปที่ Supabase
      await _service.deleteTransaction(widget.transaction.id!);

      _showSnackBar('ลบรายการเรียบร้อยแล้ว', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    }

    setState(() => _isDeleting = false);
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

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == 'income';
    final themeColor = isIncome ? AppColors.income : AppColors.expense;
    final typeLabel = isIncome ? 'รายรับ' : 'รายจ่าย';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          'รายละเอียด$typeLabel',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        // ปุ่มลบด้านขวาบน
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _confirmDelete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded, color: Colors.white),
            tooltip: 'ลบรายการ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ป้ายบอกประเภท
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withOpacity(0.4)),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                hintText: 'จำนวนเงิน',
                prefixIcon: Icons.attach_money_rounded,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 16),

            // หมวดหมู่
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
            _buildLabel('หมายเหตุ'),
            TextField(
              controller: _noteCtrl,
              decoration: _inputDecoration(
                hintText: 'หมายเหตุ',
                prefixIcon: Icons.notes_rounded,
                color: themeColor,
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
                color: themeColor,
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 30),

            // ปุ่มบันทึกการแก้ไข
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'บันทึกการแก้ไข',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
    required Color color,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(prefixIcon, color: color),
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
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }
}
