// ============================================================
// transaction.dart — Model คลาส
// ใช้สำหรับแมปข้อมูลกับตารางในฐานข้อมูล Supabase (transaction_tb)
//
// โครงสร้างตาราง Supabase ที่ต้องสร้าง:
//   Table name : transaction_tb
//   Columns    :
//     id          uuid  (Primary Key, default: gen_random_uuid())
//     type        text  ('income' หรือ 'expense')
//     amount      float8
//     category    text
//     note        text
//     txn_date    date
// ============================================================

// ignore_for_file: non_constant_identifier_names

class Transaction {
  // ตัวแปรที่ตั้งชื่อล้อกับคอลัมน์ในฐานข้อมูล
  String? id; // Primary Key (UUID) — null ตอน insert, มีค่าหลัง fetch
  String type; // ประเภท: 'income' (รายรับ) หรือ 'expense' (รายจ่าย)
  double amount; // จำนวนเงิน
  String category; // หมวดหมู่ เช่น อาหาร, เดินทาง, เงินเดือน
  String note; // หมายเหตุเพิ่มเติม
  String txn_date; // วันที่ทำรายการ (รูปแบบ 'yyyy-MM-dd')

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.txn_date,
  });

  // ---------- fromJson ----------
  // แปลงข้อมูล JSON ที่ได้จาก Supabase ให้เป็น Transaction object
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      note: json['note'] ?? '', // ถ้า null ให้ใช้ค่าว่าง
      txn_date: json['txn_date'],
    );
  }

  // ---------- toJson ----------
  // แปลง Transaction object เป็น Map เพื่อส่งไป Supabase (insert / update)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'txn_date': txn_date,
    };
  }
}
