// ============================================================
// home_ui.dart — หน้าหลัก (Balance Summary + รายการทั้งหมด)
// แสดง: ยอดรวมรายรับ, ยอดรวมรายจ่าย, ยอดคงเหลือ
//        และรายการล่าสุดทั้งหมดเรียงตามวันที่
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/constants/app_colors.dart';
import 'package:flutter_money_tracking_app/models/transaction.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:flutter_money_tracking_app/views/money_in_ui.dart';
import 'package:flutter_money_tracking_app/views/money_out_ui.dart';
import 'package:flutter_money_tracking_app/views/transaction_detail_ui.dart';
import 'package:intl/intl.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  // ตัวแปรเก็บข้อมูลรายการทั้งหมดสำหรับแสดงใน ListView
  List<Transaction> _transactions = [];

  // ยอดสรุป
  double _totalIncome = 0;
  double _totalExpense = 0;
  double get _balance => _totalIncome - _totalExpense; // ยอดคงเหลือ

  // สถานะ loading
  bool _isLoading = true;

  // instance ของ SupabaseService สำหรับเรียก CRUD
  final _service = SupabaseService();

  // formatter สำหรับแสดงตัวเลขเงิน (1,234.56)
  final _fmt = NumberFormat('#,##0.00', 'th_TH');

  @override
  void initState() {
    super.initState();
    _loadData(); // โหลดข้อมูลทันทีที่หน้าเปิด
  }

  // ----------------------------------------------------------
  // โหลดข้อมูลทั้งหมดจาก Supabase
  // ----------------------------------------------------------
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // ดึงข้อมูลพร้อมกัน (parallel) เพื่อความเร็ว
    final results = await Future.wait([
      _service.getAllTransactions(),
      _service.getTotalIncome(),
      _service.getTotalExpense(),
    ]);

    setState(() {
      _transactions = results[0] as List<Transaction>;
      _totalIncome = results[1] as double;
      _totalExpense = results[2] as double;
      _isLoading = false;
    });
  }

  // ----------------------------------------------------------
  // Widget: Card สรุปยอดรายรับ / รายจ่าย / คงเหลือ
  // ----------------------------------------------------------
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // หัวข้อ
          const Text(
            'ยอดคงเหลือ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),

          // ยอดคงเหลือ (ใหญ่)
          Text(
            '฿ ${_fmt.format(_balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // แถวรายรับ / รายจ่าย
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // รายรับ
              _buildSummaryItem(
                icon: Icons.arrow_downward_rounded,
                label: 'รายรับ',
                amount: _totalIncome,
                color: const Color(0xFF69F0AE), // เขียวสว่าง
              ),

              // เส้นแบ่ง
              Container(width: 1, height: 40, color: Colors.white24),

              // รายจ่าย
              _buildSummaryItem(
                icon: Icons.arrow_upward_rounded,
                label: 'รายจ่าย',
                amount: _totalExpense,
                color: const Color(0xFFFF6E6E), // แดงสว่าง
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget ย่อย: แสดงยอดรายรับ/รายจ่าย ใน card สรุป
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '฿ ${_fmt.format(amount)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // Widget: แถวปุ่ม "เพิ่มรายรับ" และ "เพิ่มรายจ่าย"
  // ----------------------------------------------------------
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ปุ่มเพิ่มรายรับ
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                // เปิดหน้า MoneyInUi และรอผล แล้ว reload ข้อมูล
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoneyInUi()),
                );
                _loadData(); // reload เมื่อกลับมา
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('เพิ่มรายรับ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.income,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ปุ่มเพิ่มรายจ่าย
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                // เปิดหน้า MoneyOutUi และรอผล แล้ว reload ข้อมูล
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoneyOutUi()),
                );
                _loadData(); // reload เมื่อกลับมา
              },
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('เพิ่มรายจ่าย'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // Widget: แต่ละรายการใน ListView
  // ----------------------------------------------------------
  Widget _buildTransactionTile(Transaction txn) {
    // กำหนดสีและไอคอนตามประเภท
    final isIncome = txn.type == 'income';
    final color = isIncome ? AppColors.income : AppColors.expense;
    final icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign = isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () async {
          // กดที่รายการ → ไปหน้า TransactionDetailUi เพื่อแก้ไข/ลบ
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailUi(transaction: txn),
            ),
          );
          _loadData(); // reload เมื่อกลับมา
        },
        // ไอคอนวงกลมสีซ้ายมือ
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        // หมวดหมู่
        title: Text(
          txn.category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // หมายเหตุ + วันที่
        subtitle: Text(
          '${txn.note.isNotEmpty ? txn.note : "—"} · ${txn.txn_date}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        // จำนวนเงิน
        trailing: Text(
          '$sign ฿${_fmt.format(txn.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // build หลัก
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Money Tracking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // ปุ่ม refresh ด้านขวา
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: _isLoading
          // แสดง loading indicator ขณะโหลดข้อมูล
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              // ดึงลงเพื่อ refresh
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView(
                children: [
                  // Card สรุปยอด
                  _buildSummaryCard(),

                  // ปุ่มบันทึกรายรับ/รายจ่าย
                  _buildActionButtons(),
                  const SizedBox(height: 16),

                  // หัวข้อรายการ
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'รายการทั้งหมด',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // รายการ หรือ ข้อความเมื่อไม่มีข้อมูล
                  if (_transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          'ยังไม่มีรายการ\nกด "เพิ่มรายรับ" หรือ "เพิ่มรายจ่าย" เพื่อเริ่มต้น',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  else
                    // สร้าง ListTile สำหรับแต่ละรายการ
                    ..._transactions.map(_buildTransactionTile),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
