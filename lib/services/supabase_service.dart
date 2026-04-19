// ============================================================
// supabase_service.dart — Service Layer
// รวมคำสั่ง CRUD ทั้งหมดที่ใช้กับ Supabase ไว้ที่เดียว
// UI จะไม่คุยกับ Supabase โดยตรง แต่จะเรียกผ่าน class นี้เสมอ
// ============================================================

import 'package:flutter_money_tracking_app/models/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // สร้าง Supabase client ที่จะใช้เรียก API ทั้งหมด
  final supabase = Supabase.instance.client;

  // ชื่อตารางในฐานข้อมูล Supabase
  static const String _table = 'transaction_tb';

  // ----------------------------------------------------------
  // READ: ดึงรายการทั้งหมด เรียงจากวันที่ใหม่ไปเก่า
  // ----------------------------------------------------------
  Future<List<Transaction>> getAllTransactions() async {
    final data = await supabase
        .from(_table)
        .select('*')
        .order('txn_date', ascending: false);

    // แปลง List<Map> ที่ได้จาก Supabase ให้เป็น List<Transaction>
    return data.map<Transaction>((e) => Transaction.fromJson(e)).toList();
  }

  // ----------------------------------------------------------
  // READ: ดึงเฉพาะรายรับ (type = 'income')
  // ----------------------------------------------------------
  Future<List<Transaction>> getIncomes() async {
    final data = await supabase
        .from(_table)
        .select('*')
        .eq('type', 'income')
        .order('txn_date', ascending: false);

    return data.map<Transaction>((e) => Transaction.fromJson(e)).toList();
  }

  // ----------------------------------------------------------
  // READ: ดึงเฉพาะรายจ่าย (type = 'expense')
  // ----------------------------------------------------------
  Future<List<Transaction>> getExpenses() async {
    final data = await supabase
        .from(_table)
        .select('*')
        .eq('type', 'expense')
        .order('txn_date', ascending: false);

    return data.map<Transaction>((e) => Transaction.fromJson(e)).toList();
  }

  // ----------------------------------------------------------
  // CREATE: เพิ่มรายการใหม่เข้า Supabase
  // ----------------------------------------------------------
  Future<void> insertTransaction(Transaction txn) async {
    await supabase.from(_table).insert(txn.toJson());
  }

  // ----------------------------------------------------------
  // UPDATE: แก้ไขรายการที่มี id ตรงกัน
  // ----------------------------------------------------------
  Future<void> updateTransaction(String id, Transaction txn) async {
    await supabase.from(_table).update(txn.toJson()).eq('id', id);
  }

  // ----------------------------------------------------------
  // DELETE: ลบรายการที่มี id ตรงกัน
  // ----------------------------------------------------------
  Future<void> deleteTransaction(String id) async {
    await supabase.from(_table).delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // SUMMARY: คำนวณยอดรวมรายรับ
  // ----------------------------------------------------------
  Future<double> getTotalIncome() async {
    final data =
        await supabase.from(_table).select('amount').eq('type', 'income');

    // รวมยอดจาก list ที่ได้
    double total = 0;
    for (var row in data) {
      total += (row['amount'] as num).toDouble();
    }
    return total;
  }

  // ----------------------------------------------------------
  // SUMMARY: คำนวณยอดรวมรายจ่าย
  // ----------------------------------------------------------
  Future<double> getTotalExpense() async {
    final data =
        await supabase.from(_table).select('amount').eq('type', 'expense');

    double total = 0;
    for (var row in data) {
      total += (row['amount'] as num).toDouble();
    }
    return total;
  }
}
