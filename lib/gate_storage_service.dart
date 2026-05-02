import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GateStorageService {
  // تفعيل خيارات التشفير المتقدمة للأندرويد
 static const _storage = FlutterSecureStorage();
  

  /// 🟢 حفظ رمز الـ QR الخاص بالبوابة (يُستدعى مرة واحدة عند مسح الكود لأول مرة)
  static Future<void> saveGateQrCode(String gateId, String qrCode) async {
    // نربط الرمز بـ ID البوابة لكي يدعم التطبيق أكثر من بوابة لنفس المستخدم
    await _storage.write(key: 'gate_qr_$gateId', value: qrCode);
  }

  /// 🔵 استرجاع رمز الـ QR (يُستدعى في كل مرة يضغط فيها المستخدم على زر الفتح)
  static Future<String?> getGateQrCode(String gateId) async {
    return await _storage.read(key: 'gate_qr_$gateId');
  }

  /// 🔴 مسح رمز الـ QR (يُستدعى في حال قام العميل بحذف البوابة من حسابه)
  static Future<void> deleteGateQrCode(String gateId) async {
    await _storage.delete(key: 'gate_qr_$gateId');
  }
  
  /// مسح جميع بيانات البوابات (عند تسجيل الخروج من الحساب)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}