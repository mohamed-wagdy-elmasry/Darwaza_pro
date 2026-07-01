import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'bluetooth_service.dart'; // تأكد من مطابقة اسم الملف الذي أنشأته
import 'gate_storage_service.dart'; // 🟢 الإضافة الجديدة: استدعاء ملف الخزنة السرية
import 'icons_map.dart'; // تأكد أن الاسم صحيح
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // الملف السحري الذي أنشأته للتو
import 'package:flutter/foundation.dart' show kIsWeb;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تحميل اللغة المحفوظة
  final prefs = await SharedPreferences.getInstance();
  String? savedLang = prefs.getString('language_code');

  // تهيئة فايربيز بأمان باستخدام الملف النظيف الذي أرسلته للتو
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🚨 لقد قمنا بحذف أكواد FirebaseMessaging من هنا تماماً!
  // التطبيق سيتعامل مع الإشعارات بأمان من داخل دالة initApp في الشاشة الرئيسية

  // تشغيل التطبيق فوراً
  runApp(SmartGateApp(initialLang: savedLang));
}
FaIconData getIconData(String? iconName) {
  // إذا كان الاسم null أو غير موجود في القائمة، نرجع القلعة كافتراضي
  return fullIconMap[iconName] ?? FontAwesomeIcons.dungeon;
}
// دالة مساعدة لجلب الأيقونة بأمان
// ==========================================
// 1. إعدادات المشروع والثيمات
// ==========================================
// أضف http:// في البداية
const String domainUrl = kIsWeb 
    ? "https://app.darwaza.ae/proxy.php" 
    : "http://216.158.229.233/darwaza_pro_api/api.php";

const Color bgBody = Color(0xFF000000); // أسود خالص ليتماشى مع الخلفية الجديدة
const Color bgCard = Color(0xFF141414); // رمادي داكن جداً يبرز البطاقة بوضوح وأناقة
const Color defaultPrimary = Color(0xFFD4AF37); // اللون الذهبي الملكي المأخوذ من الشعار
const Color neonGreen = Color(0xFF00E676); // أخضر ساطع وأنيق لحالة الاتصال (MQTT Connected)
const Color dangerColor = Color(0xFFFF3B30); // أحمر واضح ومميز لحالة الانقطاع أو الإغلاق

// --- كلاس الترجمة (عربي - إنجليزي - أوردو) ---
// --- كلاس الترجمة (محدث ومصحح) ---
class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    // === English ===
    'en': {
      'app_title': 'DARWAZA',
      'welcome': 'Welcome,',
      'loading': 'Loading...',
      'delete_account': 'Delete Account',
      'edit_profile': 'Edit Profile & Language',
      'language': 'Language',
      'save_changes': 'Save Changes',
      'cancel': 'Cancel',
      'add_code_manually': 'Enter Code Manually',
      'hint_code': 'Ex: GATE_123',
      'add': 'Add',
      'scan_qr': 'Scan QR',
      'no_gates': 'No gates found, add one now',
      'open': 'OPEN',
      'closed': 'CLOSED',
      'tap_to_open': 'TAP TO OPEN',
      'control': 'Control',
      'members': 'Members',
      'my_info': 'My Info',
      'logs': 'Logs',
      'schedule_auto': 'Schedule Auto-Open',
      'active_schedules': 'Active Schedules',
      'admin': 'Admin',
      'user': 'User',
      'delete_gate_forever': 'Remove Gate',
      'edit_gate_name': 'Edit Gate Name',
      'confirm_delete': 'Yes, Delete',
      'name_placeholder': 'Your Name',
      'hello_first_time': 'Hello! Choose Language',
      'setup_profile': 'Setup Profile',
      'gold': 'Gold',
      'platinum': 'Platinum',
      'starter': 'Starter',
      'logs_locked': 'Logs for Admin only',
      'feature_locked': 'Locked Feature',
      'platinum_only': 'Platinum Plan Only',
      'success_schedule': 'Scheduled Successfully',
      'delete': 'Delete',
      'pick_date': 'Pick Date',
      'no_logs': 'No Logs',
      'sending': 'Sending...',
      'connection_error': 'Connection Error',
      'save_schedule': 'Save Schedule',
      'select_day_error': 'Please select at least one day',
      'scheduled_tasks': 'Scheduled Tasks',
      'no_active_schedules': 'No active schedules',
      'close': 'Close',
      'unknown': 'Unknown',
      'time': 'Time',
      'repeat_days': 'Repeat on:',
      'cmd_open': 'Open Command',
      'cmd_close': 'Close Command',
      'cmd_toggle': 'Toggle',
      'name_too_short': 'Name too short',
      'only_admin': 'Feature for Admins only',
      'enter_name': 'Enter Name',
      'save': 'Save',
      'default_user': 'New User',
      'default_admin': 'Admin',
      'auto_open_on': 'Auto-Open Enabled',
      'auto_open_off': 'Auto-Open Disabled',
      'auto_label': 'AUTO',
      'tech_error': 'Technical error',
      
      // --- الإضافات الجديدة ---
      'approve': 'Activate',           // للنص بجانب السويتش (اختياري)
      'pending': 'Pending',            // حالة المستخدم المعلق
      'success_op': 'Operation Successful', // رسالة نجاح عامة
      'delete_user': 'Remove User?',   // عنوان نافذة الحذف
      'confirm_kick': 'Are you sure you want to remove this user?', // نص تأكيد الحذف
      'transfer_admin': 'Transfer Ownership?', // عنوان نقل الملكية
      'confirm': 'Confirm',            // زر التأكيد
      'lose_privileges': 'You will lose your admin privileges for this gate.', // تحذير نقل الملكية
     'bluetooth_permission_error': 'Please enable Bluetooth and grant permissions.',
      'gate_not_in_range': 'Gate is not in range.',
      'bluetooth_error': 'Bluetooth error occurred.',
      'open_cmd_sent': 'Open command sent successfully!',
      'service_not_found': 'Connection service not found on the gate.',
      'connection_failed': 'Failed to connect to the gate.',
      'search_icon_hint': 'Search Icon (e.g. car, wifi)...',
      'no_icons_found': 'No icons found',
      'missing_qr_error': 'Gate key not found! Please delete and re-add by scanning QR.',
      'network_unavailable_fallback': 'Network unavailable, trying via Bluetooth...',
      'starter_internet_required': 'This feature requires an internet-enabled plan',
      'starter_logs_locked': 'Activity logs are available in higher plans',
      'local_key_not_found': 'Local key not found!',
      'scan_or_copy_key': 'Scan QR or copy the code to share',
      'copy': 'Copy',
      'copied_successfully': 'Code copied to clipboard successfully',
      'share': 'Share',
      'share_key': 'Share Key',
      'gate_key_is': 'Access key for gate',
      'copy_and_use': 'Copy and use it in the Darwaza app.',
      'under_review': 'Your request is currently under review',
      'plan_limit_reached': 'Plan users limit reached',
      'member_activated': 'Member activated successfully',
      'member_frozen': 'Member suspended successfully',
      'member_removed': 'Member removed successfully',
      'cant_do_to_self': 'You cannot perform this action on yourself',
      'updated_success': 'Updated successfully',
      'deleted_success': 'Deleted successfully',
      'scheduled_success_msg': 'Scheduled successfully',
      'no_permission': 'You do not have permission',
      'waiting_admin_approval': 'Request sent, waiting for admin approval',
      'gate_added_success': 'Gate added successfully',
      'invalid_qr': 'Invalid QR Code',
      'gate_already_exists': 'Gate already exists',
    
      'starter_limit': 'Starter plan allows a maximum of 5 users.',
      'gold_limit': 'Gold plan allows a maximum of 30 users.',
      'gate_added_admin': 'Gate added successfully (Admin)',
      'gate_deleted': 'Gate deleted successfully',
      'not_found': 'Gate not found',
      'lock_gate': 'Lock Gate',
      'unlock_gate': 'Unlock Gate',
      'lock_cmd_sent': 'Lock command sent successfully!',
      'lock_warning_title': '⚠️ Lock Gate Warning',
      'lock_warning_body': 'If you lock the gate, it cannot be opened by anyone except you or by using the physical emergency key. Are you sure?',
      'proceed_lock': 'Yes, Lock It',
      'opening_internet': 'Opening via Internet...',
      'opening_bluetooth': 'Opening via Bluetooth...',
      'locking_internet': 'Locking via Internet...',
      'locking_bluetooth': 'Locking via Bluetooth...',
      
     
    },

    // === Arabic ===
    'ar': {
      'app_title': 'دروازة',
      'welcome': 'أهلاً بك،',
      'loading': 'جاري التحميل...',
      'delete_account': 'حذف الحساب',
      'edit_profile': 'تعديل الملف واللغة',
      'language': 'اللغة',
      'save_changes': 'حفظ التغييرات',
      'cancel': 'إلغاء',
      'add_code_manually': 'إدخال الكود يدوياً',
      'hint_code': 'مثال: GATE_123',
      'add': 'إضافة',
      'scan_qr': 'امسح الكود',
      'no_gates': 'لا توجد بوابات، أضف واحدة الآن',
      'open': 'مفتوح',
      'closed': 'مغلق',
      'tap_to_open': 'اضغط للفتح',
      'control': 'تحكم',
      'members': 'الأعضاء',
      'my_info': 'معلوماتي',
      'logs': 'السجل',
      'schedule_auto': 'جدولة الفتح التلقائي',
      'active_schedules': 'المواعيد النشطة',
      'admin': 'مدير',
      'user': 'مستخدم',
      'delete_gate_forever': 'حذف البوابة',
      'edit_gate_name': 'تعديل اسم البوابة',
      'confirm_delete': 'نعم، احذف',
      'name_placeholder': 'الاسم الكريم',
      'hello_first_time': 'مرحباً! اختر لغتك',
      'setup_profile': 'إعداد الملف الشخصي',
      'gold': 'ذهبي',
      'platinum': 'بلاتيني',
      'starter': 'مبتدئ',
      'logs_locked': 'السجل للمدير فقط',
      'feature_locked': 'ميزة مقفلة',
      'platinum_only': 'للباقة البلاتينية فقط',
      'success_schedule': 'تمت الجدولة بنجاح',
      'delete': 'حذف',
      'pick_date': 'اختر التاريخ',
      'no_logs': 'لا يوجد سجل',
      'sending': 'جاري الإرسال...',
      'connection_error': 'خطأ في الاتصال',
      'save_schedule': 'حفظ الجدول',
      'select_day_error': 'يرجى اختيار يوم واحد على الأقل',
      'scheduled_tasks': 'المواعيد المجدولة',
      'no_active_schedules': 'لا توجد مواعيد نشطة',
      'close': 'إغلاق',
      'unknown': 'مجهول',
      'time': 'الوقت',
      'repeat_days': 'كرر في الأيام:',
      'cmd_open': 'أمر فتح',
      'cmd_close': 'أمر إغلاق',
      'cmd_toggle': 'تشغيل',
      'name_too_short': 'الاسم قصير جداً',
      'only_admin': 'هذه الميزة للمدراء فقط',
      'enter_name': 'أدخل الاسم',
      'save': 'حفظ',
      'default_user': 'مستخدم جديد',
      'default_admin': 'المدير',
      'auto_open_on': 'تم تفعيل الفتح التلقائي',
      'auto_open_off': 'تم إلغاء الفتح التلقائي',
      'auto_label': 'تلقائي',

      // --- الإضافات الجديدة ---
      'approve': 'تفعيل',
      'pending': 'معلق',
      'success_op': 'تمت العملية بنجاح',
      'delete_user': 'حذف المستخدم؟',
      'confirm_kick': 'هل أنت متأكد من حذف هذا العضو؟',
      'transfer_admin': 'نقل الملكية؟',
      'confirm': 'تأكيد',
      'lose_privileges': 'ستفقد صلاحياتك كمدير لهذه البوابة.',
      'bluetooth_permission_error': 'يرجى تفعيل البلوتوث ومنح الصلاحيات.',
      'gate_not_in_range': 'البوابة ليست في النطاق.',
      'bluetooth_error': 'حدث خطأ في البلوتوث.',
      'open_cmd_sent': 'تم إرسال أمر الفتح بنجاح!',
      'service_not_found': 'لم يتم العثور على خدمة الاتصال في البوابة.',
      'connection_failed': 'فشل الاتصال بالبوابة.',
      'search_icon_hint': 'ابحث عن أيقونة (مثال: سيارة، واي فاي)...',
      'no_icons_found': 'لم يتم العثور على أيقونات',
      'missing_qr_error': 'لم يتم العثور على مفتاح البوابة! يرجى حذفها وإعادة إضافتها بمسح الكود.',
      'network_unavailable_fallback': 'الشبكة غير متاحة، جاري المحاولة عبر البلوتوث...',
      'starter_internet_required': 'تتطلب هذه الميزة باقة تدعم الإنترنت',
      'starter_logs_locked': 'سجل الحركات متاح في الباقات الأعلى',
      'tech_error': 'عطل تقني',
      'local_key_not_found': 'لم يتم العثور على المفتاح محلياً!',
      'scan_or_copy_key': 'امسح الكود أو انسخ الرمز للمشاركة',
      'copy': 'نسخ',
      'copied_successfully': 'تم نسخ الرمز للحافظة بنجاح',
      'share': 'مشاركة',
      'share_key': 'مشاركة المفتاح',
      'gate_key_is': 'مفتاح الوصول لبوابة',
      'copy_and_use': 'قم بنسخه واستخدامه في تطبيق دروازة.',
      'under_review': 'طلبك قيد المراجعة حالياً',
      'plan_limit_reached': 'تم الوصول للحد الأقصى لمستخدمي الباقة',
      'member_activated': 'تم تفعيل العضو بنجاح',
      'member_frozen': 'تم تجميد العضو',
      'member_removed': 'تم استبعاد العضو',
      'cant_do_to_self': 'لا يمكنك تنفيذ هذا الإجراء على نفسك',
      'updated_success': 'تم التحديث بنجاح',
      'deleted_success': 'تم الحذف بنجاح',
      'scheduled_success_msg': 'تمت الجدولة بنجاح',
      'no_permission': 'ليس لديك صلاحية لهذا الإجراء',
      'gate_added_success': 'تمت إضافة البوابة بنجاح',
      'invalid_qr': 'الكود غير صالح أو خاطئ',
      'gate_already_exists': 'هذه البوابة مضافة مسبقاً',
      'waiting_admin_approval': 'تم إرسال الطلب، بانتظار موافقة المدير',
      'gate_deleted': 'تم حذف البوابة بنجاح',
      'not_found': 'البوابة غير موجودة',
      'starter_limit': 'عذراً، باقة Starter تسمح بـ 5 مستخدمين كحد أقصى.',
      'gold_limit': 'عذراً، الباقة الذهبية تسمح بـ 30 مستخدم كحد أقصى.',
      'lock_gate': 'قفل البوابة',
      'unlock_gate': 'إلغاء القفل',
      'lock_cmd_sent': 'تم إرسال أمر القفل بنجاح!',
      'lock_warning_title': '⚠️ تحذير قفل البوابة',
      'lock_warning_body': 'في حال قفل البوابة، لن يتمكن أي شخص من فتحها إلا من خلالك أو باستخدام مفتاح الطوارئ اليدوي. هل أنت متأكد؟',
      'proceed_lock': 'نعم، اقفلها',
      'opening_internet': 'جاري الفتح عبر الإنترنت...',
      'opening_bluetooth': 'جاري الفتح عبر البلوتوث...',
      'locking_internet': 'جاري القفل عبر الإنترنت...',
      'locking_bluetooth': 'جاري القفل عبر البلوتوث...',
      'gate_added_admin': 'تمت إضافة البوابة بنجاح (مدير)',

    },

    // === Urdu ===
    'ur': {
      'app_title':'دروازه',// 👈 تم التعديل
      'welcome': 'خوش آمدید،',
      'loading': 'لوڈ ہو رہا ہے...',
      'delete_account': 'اکاؤنٹ ڈیلیٹ کریں',
      'edit_profile': 'پروفائل اور زبان',
      'language': 'زبان',
      'save_changes': 'تبدیلیاں محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'add_code_manually': 'کوڈ درج کریں',
      'hint_code': 'مثال: GATE_123',
      'add': 'شامل کریں',
      'scan_qr': 'QR اسکین کریں',
      'no_gates': 'کوئی گیٹ نہیں، ابھی شامل کریں',
      'open': 'کھلا',
      'closed': 'بند',
      'tap_to_open': 'کھولنے کے لیے دبائیں',
      'control': 'کنٹرول',
      'members': 'ممبران',
      'my_info': 'میری معلومات',
      'logs': 'ریکارڈ',
      'schedule_auto': 'آٹو اوپن شیڈول',
      'active_schedules': 'فعال شیڈول',
      'admin': 'ایڈمن',
      'user': 'صارف',
      'delete_gate_forever': 'گیٹ ہٹائیں',
      'edit_gate_name': 'گیٹ کا نام تبدیل کریں',
      'confirm_delete': 'ہاں، ڈیلیٹ کریں',
      'name_placeholder': 'آپ کا نام',
      'hello_first_time': 'خوش آمدید! زبان منتخب کریں',
      'setup_profile': 'پروفائل سیٹ کریں',
      'gold': 'گولڈ',
      'platinum': 'پلیٹینم',
      'starter': 'اسٹارٹر',
      'logs_locked': 'ریکارڈ صرف ایڈمن کے لیے',
      'feature_locked': 'فیچر مقفل ہے',
      'platinum_only': 'صرف پلیٹینم پلان',
      'success_schedule': 'کامیابی سے شیڈول ہو گیا',
      'delete': 'ڈیلیٹ',
      'pick_date': 'تاریخ منتخب کریں',
      'no_logs': 'کوئی ریکارڈ نہیں',
      'sending': 'بھیج رہا ہے...',
      'connection_error': 'کنکشن کی خرابی',
      'save_schedule': 'شیڈول محفوظ کریں',
      'select_day_error': 'براہ کرم کم از کم ایک دن منتخب کریں',
      'scheduled_tasks': 'شیڈول کام',
      'no_active_schedules': 'کوئی فعال شیڈول نہیں',
      'close': 'بند کریں',
      'unknown': 'نامعلوم',
      'time': 'وقت',
      'repeat_days': 'ان دنوں میں دہرائیں:',
      'cmd_open': 'کھولنے کا حکم',
      'cmd_close': 'بند کرنے کا حکم',
      'cmd_toggle': 'سوئچ',
      'name_too_short': 'نام بہت چھوٹا ہے',
      'only_admin': 'صرف ایڈمن کے لیے',
      'enter_name': 'نام درج کریں',
      'save': 'محفوظ کریں',
      'default_user': 'نئے صارف',
      'default_admin': 'ایڈمن',
      'auto_open_on': 'آٹو اوپن فعال',
      'auto_open_off': 'آٹو اوپن بند',
      'auto_label': 'آٹو',

      // --- الإضافات الجديدة ---
      'approve': 'فعال کریں',
      'pending': 'زیر التوا',
      'success_op': 'آپریشن کامیاب',
      'delete_user': 'صارف کو ہٹائیں؟',
      'confirm_kick': 'کیا آپ واقعی اس صارف کو ہٹانا چاہتے ہیں؟',
      'transfer_admin': 'ملکیت منتقل کریں؟',
      'confirm': 'تصدیق',
      'lose_privileges': 'آپ اس گیٹ کے لیے ایڈمن کی حیثیت کھو دیں گے.',
      'bluetooth_permission_error': 'براہ کرم بلوٹوتھ آن کریں اور اجازت دیں۔',
      'gate_not_in_range': 'گیٹ حد میں نہیں ہے۔',
      'bluetooth_error': 'بلوٹوتھ میں خرابی پیش آگئی۔',
      'open_cmd_sent': 'کھولنے کا حکم کامیابی سے بھیج دیا گیا!',
      'service_not_found': 'گیٹ پر کنکشن سروس نہیں ملی۔',
      'connection_failed': 'گیٹ سے جڑنے میں ناکام۔',
      'search_icon_hint': 'آئیکن تلاش کریں (مثال: کار، وائی فائی)...',
      'no_icons_found': 'کوئی آئیکن نہیں ملا',
      'missing_qr_error': 'گیٹ کی چابی نہیں ملی! براہ کرم حذف کریں اور QR کوڈ سے دوبارہ شامل کریں۔',
      'network_unavailable_fallback': 'نیٹ ورک دستیاب نہیں، بلوٹوتھ کے ذریعے کوشش کر رہے ہیں...',
      'starter_internet_required': 'اس فیچر کے لیے انٹرنیٹ والا پلان درکار ہے',
      'starter_logs_locked': 'سرگرمی کا ریکارڈ اعلیٰ پلانز میں دستیاب ہے',
      'tech_error': 'تکنیکی خرابی',
      'local_key_not_found': 'مقامی کلید نہیں ملی!',
      'scan_or_copy_key': 'QR اسکین کریں یا کوڈ کاپی کریں',
      'copy': 'کاپی کریں',
      'copied_successfully': 'کوڈ کامیابی سے کاپی ہو گیا',
      'share': 'شیئر کریں',
      'share_key': 'چابی شیئر کریں',
      'gate_key_is': 'گیٹ کی رسائی کی کلید',
      'copy_and_use': 'اسے کاپی کریں اور دروازہ ایپ میں استعمال کریں۔',
      'under_review': 'آپ کی درخواست فی الحال زیر غور ہے',
      'plan_limit_reached': 'پلان کے صارفین کی حد پوری ہو چکی ہے',
      'member_activated': 'ممبر کامیابی سے فعال ہو گیا',
      'member_frozen': 'ممبر کو معطل کر دیا گیا ہے',
      'member_removed': 'ممبر کو ہٹا دیا گیا ہے',
      'cant_do_to_self': 'آپ خود پر یہ کارروائی نہیں کر سکتے',
      'updated_success': 'کامیابی سے اپ ڈیٹ ہو گیا',
      'deleted_success': 'کامیابی سے حذف ہو گیا',
      'scheduled_success_msg': 'کامیابی سے شیڈول ہو گیا',
      'no_permission': 'آپ کے پاس اجازت نہیں ہے',
      'waiting_admin_approval': 'درخواست بھیج دی گئی، ایڈمن کی منظوری کا انتظار ہے',
      'gate_added_success': 'گیٹ کامیابی کے ساتھ شامل ہو گیا',
      'invalid_qr': 'غلط QR کوڈ',
      'gate_already_exists': 'گیٹ پہلے سے موجود ہے',
      'gate_deleted': 'گیٹ کامیابی سے حذف ہو گیا',
      'not_found': 'گیٹ نہیں ملا',
      'starter_limit': 'اسٹارٹر پلان میں زیادہ سے زیادہ 5 صارفین کی اجازت ہے۔',
      'gold_limit': 'گولڈ پلان میں زیادہ سے زیادہ 30 صارفین کی اجازت ہے۔',
      'lock_gate': 'گیٹ لاک کریں',
      'unlock_gate': 'لاک کھولیں',
      'lock_cmd_sent': 'لاک کی کمانڈ کامیابی سے بھیج دی گئی!',
      'lock_warning_title': '⚠️ گیٹ لاک کی وارننگ',
      'lock_warning_body': 'اگر آپ گیٹ کو لاک کرتے ہیں، تو اسے آپ کے علاوہ کوئی اور نہیں کھول سکے گا، سوائے ہنگامی دستیابی کی چابی کے۔ کیا آپ کو یقین ہے؟',
      'proceed_lock': 'ہاں، لاک کریں',
      'opening_internet': 'انٹرنیٹ کے ذریعے کھولا جا رہا ہے...',
      'opening_bluetooth': 'بلوٹوتھ کے ذریعے کھولا جا رہا ہے...',
      'locking_internet': 'انٹرنیٹ کے ذریعے لاک کیا جا رہا ہے...',
      'locking_bluetooth': 'بلوٹوتھ کے ذریعے لاک کیا جا رہا ہے...',
      'gate_added_admin': 'گیٹ کامیابی کے ساتھ شامل ہو گیا (ایڈمن)',
    },

    // === Chinese ===
    'zh': {
     'app_title': '达尔瓦扎专业版', // 👈 تم التعديل (اللفظ الصوتي)
      'welcome': '欢迎，',
      'loading': '加载中...',
      'delete_account': '删除账户',
      'edit_profile': '编辑个人资料',
      'language': '语言',
      'save_changes': '保存更改',
      'cancel': '取消',
      'add_code_manually': '手动输入代码',
      'hint_code': '例如：GATE_123',
      'add': '添加',
      'scan_qr': '扫描二维码',
      'no_gates': '未找到大门，立即添加',
      'open': '开启',
      'closed': '关闭',
      'tap_to_open': '点击开启',
      'control': '控制',
      'members': '成员',
      'my_info': '我的信息',
      'logs': '记录',
      'schedule_auto': '自动开启计划',
      'active_schedules': '进行中的计划',
      'admin': '管理员',
      'user': '用户',
      'delete_gate_forever': '移除大门',
      'edit_gate_name': '修改大门名称',
      'confirm_delete': '是的，删除',
      'name_placeholder': '您的名字',
      'hello_first_time': '你好！请选择语言',
      'setup_profile': '设置个人资料',
      'gold': '黄金版',
      'platinum': '白金版',
      'starter': '入门版',
      'logs_locked': '记录仅限管理员查看',
      'feature_locked': '功能已锁定',
      'platinum_only': '仅限白金版',
      'success_schedule': '计划设置成功',
      'delete': '删除',
      'pick_date': '选择日期',
      'no_logs': '无记录',
      'sending': '发送指令中...',
      'connection_error': '连接错误',
      'save_schedule': '保存计划',
      'select_day_error': '请至少选择一天',
      'scheduled_tasks': '计划任务',
      'no_active_schedules': '无活动计划',
      'close': '关闭',
      'unknown': '未知',
      'time': '时间',
      'repeat_days': '重复：',
      'cmd_open': '开启指令',
      'cmd_close': '关闭指令',
      'cmd_toggle': '切换',
      'name_too_short': '名字太短',
      'only_admin': '仅限管理员功能',
      'enter_name': '输入名字',
      'save': '保存',
      'default_user': '新用户',
      'default_admin': '管理员',
      'auto_open_on': '自动开启已启用',
      'auto_open_off': '自动开启已禁用',
      'auto_label': '自动',

      // --- الإضافات الجديدة ---
      'approve': '激活',
      'pending': '待审核',
      'success_op': '操作成功',
      'delete_user': '移除用户？',
      'confirm_kick': '确定要移除此用户吗？',
      'transfer_admin': '转让所有权？',
      'confirm': '确认',
      'lose_privileges': '您将失去此大门的管理员权限。',
      'bluetooth_permission_error': '请启用蓝牙并授予权限。',
      'gate_not_in_range': '大门不在范围内。',
      'bluetooth_error': '发生蓝牙错误。',
      'open_cmd_sent': '开门指令发送成功！',
      'service_not_found': '未找到大门的连接服务。',
      'connection_failed': '连接大门失败。',
      'search_icon_hint': '搜索图标 (例如: 汽车, wifi)...',
      'no_icons_found': '未找到图标',
      'missing_qr_error': '未找到大门密钥！请删除并通过扫描二维码重新添加。',
      'network_unavailable_fallback': '网络不可用，正在通过蓝牙尝试...',
      'starter_internet_required': '此功能需要支持互联网的计划',
      'starter_logs_locked': '活动日志在更高级别的计划中可用',
      'tech_error': '技术故障',
      'local_key_not_found': '未找到本地密钥！',
      'scan_or_copy_key': '扫描二维码或复制密钥以分享',
      'copy': '复制',
      'copied_successfully': '代码已成功复制到剪贴板',
      'share': '分享',
      'share_key': '分享密钥',
      'gate_key_is': '大门的访问密钥',
      'copy_and_use': '复制并在 Darwaza 应用程序中使用。',
      'under_review': '您的请求目前正在审核中',
      'plan_limit_reached': '已达到计划用户上限',
      'member_activated': '成员已成功激活',
      'member_frozen': '成员已暂停',
      'member_removed': '成员已移除',
      'cant_do_to_self': '您不能对自己执行此操作',
      'updated_success': '更新成功',
      'deleted_success': '删除成功',
      'scheduled_success_msg': '安排成功',
      'no_permission': '您没有权限',
      'gate_added_success': '大门添加成功',
      'invalid_qr': '无效的二维码',
      'gate_already_exists': '大门已存在',
      'waiting_admin_approval': '请求已发送，等待管理员批准',
      'gate_deleted': '大门删除成功',
      'not_found': '未找到大门',
      'starter_limit': '入门版计划最多允许 5 个用户。',
      'gold_limit': '黄金版计划最多允许 30 个用户。',
      'lock_gate': '锁门',
      'unlock_gate': '开锁',
      'lock_cmd_sent': '锁定指令发送成功！',
      'lock_warning_title': '⚠️ 锁门警告',
      'lock_warning_body': '如果您锁定大门，除了您或使用紧急实体钥匙外，任何人都无法打开它。您确定吗？',
      'proceed_lock': '是的，锁定',
      'opening_internet': '正在通过网络开启...',
      'opening_bluetooth': '正在通过蓝牙开启...',
      'locking_internet': '正在通过网络锁定...',
      'locking_bluetooth': '正在通过蓝牙锁定...',
      'gate_added_admin': '成功添加大门 (管理员)',

    },
  };

  static String get(BuildContext context, String key) {
    Locale locale = Localizations.localeOf(context);
    String langCode = locale.languageCode;
    
    // إذا كانت اللغة الحالية غير موجودة، نستخدم الإنجليزية
    if (!_localizedValues.containsKey(langCode)) {
      langCode = 'en';
    }
    
    return _localizedValues[langCode]![key] ?? 
           _localizedValues['en']![key] ?? 
           key; 
  }
  // دالة ذكية لترجمة الردود القادمة من السيرفر (PHP) قبل عرضها
// دالة ذكية لترجمة الردود القادمة من السيرفر (PHP) قبل عرضها
  // دالة ذكية لترجمة الردود القادمة من السيرفر (PHP) قبل عرضها
  static String translateServerMsg(BuildContext context, String serverMsg) {
    // 1. رسائل إضافة البوابة (Link Gate) حسب كود السيرفر الجديد
    if (serverMsg.contains('غير صحيح') || serverMsg.contains('غير صالح')) {
      return get(context, 'invalid_qr');
    }
    if (serverMsg.contains('قيد المراجعة')) {
      return get(context, 'under_review');
    }
    if (serverMsg.contains('مضاف بالفعل') || serverMsg.contains('مضافة مسبقاً')) {
      return get(context, 'gate_already_exists');
    }
    if (serverMsg.contains('بمستخدمين اثنين')) {
      return get(context, 'starter_limit');
    }
    if (serverMsg.contains('بـ 5 مستخدمين')) {
      return get(context, 'gold_limit');
    }
    if (serverMsg.contains('بصلاحية مدير') || serverMsg.contains('تمت إضافة')) {
      return get(context, 'gate_added_admin');
    }
    if (serverMsg.contains('بانتظار') || serverMsg.contains('موافقة') || serverMsg.contains('المدير')) {
      return get(context, 'waiting_admin_approval');
    }

    // 2. رسالة تأكيد الاستلام (القديمة)
    if (serverMsg.contains('لم تؤكد الاستلام') || serverMsg.contains('تم استلام الرمز')) {
      return get(context, 'gate_no_confirmation');
    }
    // --- 3. رسائل الحذف (الجديدة) ---
   
    if (serverMsg.contains('غير موجودة')) {
      return get(context, 'not_found');
    }
    // إذا لم تكن من العبارات المعروفة، نعرضها كما هي
    return serverMsg;
  }
}
// --- كلاس إدارة الثيمات ---
class GateTheme {
  final Color primary;
  final Color secondary;
  final List<Color> gradient;
  GateTheme(this.primary, this.secondary, this.gradient);
}

GateTheme getGateTheme(String? planType) {
  switch (planType) {
    case 'gold':
      return GateTheme(const Color(0xFFFFD700), const Color(0xFFB8860B), [const Color(0xFFFDB931).withValues(alpha: 0.15), const Color(0xFFFFD700).withValues(alpha: 0.02)]);
    case 'platinum':
      return GateTheme(const Color(0xFFd946ef), const Color(0xFF86198f), [const Color(0xFFd946ef).withValues(alpha: 0.15), const Color(0xFF4c1d95).withValues(alpha: 0.02)]);
    default:
      return GateTheme(const Color(0xFF3b82f6), const Color(0xFF1e40af), [const Color(0xFF3b82f6).withValues(alpha: 0.15), const Color(0xFF1e3a8a).withValues(alpha: 0.02)]);
  }
}



class SmartGateApp extends StatefulWidget {
  final String? initialLang;
  const SmartGateApp({super.key, this.initialLang});

  static void setLocale(BuildContext context, Locale newLocale) {
    _SmartGateAppState? state = context.findAncestorStateOfType<_SmartGateAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<SmartGateApp> createState() => _SmartGateAppState();
}

class _SmartGateAppState extends State<SmartGateApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    if (widget.initialLang != null) {
      _locale = Locale(widget.initialLang!);
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 التعديل الأول: إضافة هذا السطر هنا
      title: 'Smart Gate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgBody,
        textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: defaultPrimary, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(backgroundColor: bgBody, elevation: 0),
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
        Locale('ur', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (_locale != null) {
          return _locale;
        }
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return locale;
          }
        }
        return supportedLocales.first;
      },
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 2. شاشة البداية المتحركة
// ==========================================
// ==========================================
// 2. شاشة البداية المتحركة (Updated)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // إعداد الأنيميشن (المدة 2.5 ثانية)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // تأثير التكبير والتصغير (النبض)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // تأثير الظهور التدريجي
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // الانتقال للشاشة الرئيسية بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم نفس لون الخلفية الموجود في pubspec.yaml لضمان عدم وجود ومضة
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // تم التعديل: أسود خالص
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. الشعار المتحرك
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  // حجم الكونتينر
                  width: 150, 
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // وهج خفيف خلف الشعار
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5), // تم التعديل: وهج ذهبي بدلاً من الأزرق
                        blurRadius: 60,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                 // 👇👇 التعديل الأول: قص الصورة لتصبح دائرية ناعمة 👇👇
child: ClipOval(
  child: Image.asset(
    'assets/splash_center.png', // تأكد أن هذا هو اسم الصورة الذهبية الجديدة
    // نستخدم cover لملء الدائرة بالكامل مما يخفي الحواف الحادة
    fit: BoxFit.cover, 
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.home_repair_service, size: 80, color: Color(0xFFD4AF37)); // تم التعديل: أيقونة الخطأ ذهبية
    },
  ),
),
                ),
              ),
            ),
            // 👇👇 التعديل الثاني: إضافة كلمة دروازة 👇👇
const SizedBox(height: 25), // مسافة بين الصورة والنص

// 👇👇 الكود النظيف المعتمد على AppStrings 👇👇
FadeTransition(
  opacity: _fadeAnimation,
  child: Text(
    AppStrings.get(context, 'app_title'), // 👈 سيجلب الاسم الصحيح (Darwaza/دروازة/...) تلقائياً
    style: GoogleFonts.tajawal(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFD4AF37), // تم التعديل: توحيد درجة الذهبي مع باقي العناصر
      letterSpacing: 1.2,
    ),
  ),
),
// 👆👆 --------------------------------------- 👆👆
// 👆👆 نهاية التعديل الثاني 👆👆

// (هذا السطر موجود أصلاً، تأكد أنه تحته)
const SizedBox(height: 30),
            const SizedBox(height: 30),

            // 2. مؤشر التحميل الصغير في الأسفل
            const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37), // تم التعديل: لون التحميل ذهبي بدلاً من الأخضر النيون
                strokeWidth: 2,
              )
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. الشاشة الرئيسية (HomeScreen)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userId;
 String userName = ""; // نجعله فارغاً
  String? role;
  String? deviceUuid;
  List<dynamic> gates = [];
  bool isLoading = true;
  bool _isFirstLoad = true;
  // 🌟 دالة المعالجة الذكية للتوجيه العميق (Deep Linking)
  // 🌟 دالة المعالجة الذكية للتوجيه العميق (Deep Linking)
  void _handleNotificationClick(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      String? targetScreen = message.data['screen'];
      String? targetGateId = message.data['gate_id'];
      
      if (targetScreen != null && targetGateId != null) {
        // البحث عن البوابة المطلوبة في قائمة البوابات المحملة
        final gate = gates.firstWhere((g) => g['id'].toString() == targetGateId, orElse: () => null);

        if (gate != null && navigatorKey.currentContext != null) {
          // جلب الثيم
          final theme = getGateTheme(gate['plan_type']);
          
          // 👈 التعديل هنا: تحديد رقم التبويبة بناءً على الإشعار
          int tabIndex = 0; // الافتراضي: التحكم (0)
          if (targetScreen == 'members') tabIndex = 1; // الأعضاء (1)
          if (targetScreen == 'logs') tabIndex = 2;    // السجل (2)

          // الانتقال لشاشة التفاصيل
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => GateDetailsScreen(
                gate: gate,
                userId: userId!,
                userRole: gate['role'] ?? 'user',
                theme: theme,
                initialTabIndex: tabIndex, // 👈 تمرير رقم التبويبة السحري هنا
              ),
            ),
          );
        } else {
           debugPrint("البوابة غير موجودة في قائمة المستخدم!");
        }
      }
    }
  }
  @override
  void initState() {
    super.initState();
    initApp();

    // 1. اصطياد الإشعارات والتطبيق مفتوح أمامك (تظهر كـ Toast)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showFancyToast("🔔 ${message.notification!.title}: ${message.notification!.body}");
      }
      
      // 🌟 التحديث السحري: تحديث الواجهة فور استلام أي إشعار
      // إذا كان الإشعار عبارة عن "موافقة على الانضمام"، ستظهر البوابة فوراً للمستخدم!
      if (userId != null) {
        loadMyGates(); 
      }
    });

    // 🌟 2. اصطياد النقرة على الإشعار (التطبيق في الخلفية - Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // 🌟 3. اصطياد النقرة على الإشعار (التطبيق كان مغلقاً تماماً - Terminated)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // نضع تأخير بسيط لضمان تحميل الشاشة الرئيسية أولاً
        Future.delayed(const Duration(seconds: 1), () {
          _handleNotificationClick(message);
        });
      }
    });

   

    // 🟢 2. السلاح السري: صياد التوكن (يعمل بصمت في الخلفية)
    // إذا تأخر جوجل في توليد التوكن في البداية، هذه الدالة ستلتقطه فور جهوزه وترسله للسيرفر
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔥 تم اصطياد التوكن المتأخر بنجاح: $newToken");
      
      final prefs = await SharedPreferences.getInstance();
      String? myUuid = prefs.getString('gate_app_uuid');
      String currentLang = prefs.getString('language_code') ?? 'en';
      
      if (myUuid != null) {
        try {
          await http.post(
            Uri.parse(domainUrl),
            body: {
              'action': 'register_device', 
              'uuid': myUuid,
              'fcm_token': newToken, // إرسال التوكن الجديد
              'lang': currentLang,
            },
          );
        } catch (e) {
          debugPrint("خطأ في إرسال التوكن المتأخر: $e");
        }
      }
    });
  }

  void showFancyToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    
    // 👈 التعديل السحري هنا: مسح فوري للتوست القديم بدون أنيميشن خروج
    ScaffoldMessenger.of(context).clearSnackBars(); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(isError ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: 15),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? dangerColor : const Color(0xFF10b981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2), // 👈 تقليل مدة البقاء ليكون التطبيق أسرع
      ),
    );
  }
  // 1. دالة تعديل اسم البوابة (من الشاشة الرئيسية)
// --- 4. دالة التعديل الجديدة (الاسم + الأيقونة) ---
// --- دالة التعديل المصححة (Fix Context Issues) ---
Future<void> editGateNameFromHome(String gateId, String oldName, String currentIcon) async {
  String newName = oldName;
  String selectedIcon = currentIcon;
  
  // التأكد من وجود الأيقونة الحالية في القائمة
  if (!fullIconMap.containsKey(selectedIcon)) {
    // إذا لم تكن موجودة، نحاول إضافتها يدوياً للعرض فقط أو نستخدم الافتراضي
    if (selectedIcon.startsWith('fa-')) {
       // محاولة ذكية: إذا كانت الأيقونة محفوظة في قاعدة البيانات لكن ليست في قائمتنا المختصرة
       // سنعرض الافتراضية، لكن نحافظ على قيمتها
    } else {
       selectedIcon = 'fa-dungeon';
    }
  }

  // متغيرات للبحث
  String searchQuery = "";
  List<String> filteredKeys = fullIconMap.keys.toList();

  await showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (innerCtx, setStateDialog) {
          return AlertDialog(
            backgroundColor: bgCard,
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(AppStrings.get(context, 'edit_gate_name'), style: const TextStyle(fontSize: 18)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. حقل الاسم
                  TextFormField(
                    initialValue: oldName,
                    onChanged: (v) => newName = v,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppStrings.get(context, 'name_placeholder'),
                      filled: true, fillColor: bgBody,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 2. حقل البحث عن الأيقونة
                 // 2. حقل البحث عن الأيقونة
                  TextField(
                    onChanged: (val) {
                      setStateDialog(() {
                        searchQuery = val.toLowerCase();
                        filteredKeys = fullIconMap.keys
                            .where((k) => k.contains(searchQuery))
                            .toList();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppStrings.get(context, 'search_icon_hint'),
                      filled: true, fillColor: bgBody,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. شبكة الأيقونات (قابلة للتمرير)
                 // 3. شبكة الأيقونات (قابلة للتمرير)
                  Container(
                    height: 200, // ارتفاع ثابت للقائمة
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: bgBody,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: filteredKeys.isEmpty 
                    ? Center(child: Text(AppStrings.get(context, 'no_icons_found'), style: const TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, 
                          crossAxisSpacing: 8, 
                          mainAxisSpacing: 8
                        ),
                        itemCount: filteredKeys.length,
                        itemBuilder: (ctx, index) {
                          String key = filteredKeys[index];
                          bool isSelected = selectedIcon == key;
                          return GestureDetector(
                            onTap: () => setStateDialog(() => selectedIcon = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? defaultPrimary : bgCard,
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                              ),
                              child: Center(
                                child: FaIcon(fullIconMap[key], color: isSelected ? Colors.white : Colors.grey, size: 18),
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(AppStrings.get(context, 'cancel'), style: const TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: defaultPrimary),
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  // ... نفس كود الحفظ السابق ...
                  // تأكد من نسخ كود الحفظ (API Call) من الدالة السابقة ووضعه هنا
                   final prefs = await SharedPreferences.getInstance();
                  String? myUuid = prefs.getString('gate_app_uuid');
                  
                  try {
                    final response = await http.post(Uri.parse(domainUrl), body: {
                      'action': 'update_gate_name',
                      'gate_id': gateId,
                      'user_id': userId,
                      'new_name': newName,
                      'new_icon': selectedIcon,
                      'uuid': myUuid ?? '',
                    });

                    if (!mounted) return;
                    final data = json.decode(response.body);
                    
                    if (data['success'] == true) {
                      showFancyToast(AppStrings.get(context, 'save_changes'));
                      loadMyGates();
                    } else {
                      showFancyToast(data['message'], isError: true);
                    }
                  } catch (e) {
                    if (mounted) showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
                  }
                },
                child: Text(AppStrings.get(context, 'save'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}
// 2. دالة حذف البوابة (من الشاشة الرئيسية)
// دالة حذف البوابة (من الشاشة الرئيسية)
  Future<void> deleteGateFromHome(String gateId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        title: Text(AppStrings.get(context, 'confirm'), style: const TextStyle(color: Colors.white)),
        content: Text(AppStrings.get(context, 'confirm_delete'), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get(context, 'cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.get(context, 'delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final prefs = await SharedPreferences.getInstance();
      String? myUuid = prefs.getString('gate_app_uuid');
      
      if (!mounted) return;

      try {
        final response = await http.post(Uri.parse(domainUrl), body: {
          'action': 'delete_gate',
          'gate_id': gateId, // نستخدم المتغير المرر للدالة
          'user_id': userId, // نستخدم المتغير المحلي للشاشة الرئيسية
          'uuid': myUuid ?? '',
        });

        if (!mounted) return;

        final data = json.decode(response.body);
        if (data['success'] == true) {
          // جلب الترجمة من مفتاح السيرفر
          showFancyToast(AppStrings.get(context, data['message'].toString()));
          loadMyGates(); // تحديث القائمة
        } else {
          showFancyToast(AppStrings.get(context, data['message'].toString()), isError: true);
        }
      } catch (e) {
        if (mounted) {
          showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
        }
      }
    }
  }
  // دالة حذف الحساب
 Future<void> deleteMyAccount() async {
    // 1. نافذة التأكيد
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgCard,
        title: Text(AppStrings.get(context, 'delete_account'), style: const TextStyle(color: dangerColor)),
        content: Text(AppStrings.get(context, 'confirm_delete'), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.get(context, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.get(context, 'delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // ✅ تصحيح 1: التأكد من وجود الشاشة بعد إغلاق الـ Dialog
    if (!mounted) return;

    showFancyToast(AppStrings.get(context, 'loading'));

    try {
      final prefs = await SharedPreferences.getInstance();
      String? myUuid = prefs.getString('gate_app_uuid');

      // 2. طلب الحذف من السيرفر
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'delete_my_account',
          'user_id': userId,
          'uuid': myUuid ?? '',
        },
      );
      
      // ✅ التحقق الأساسي (موجود سابقاً وهو ممتاز)
      if (!mounted) return;
      
      final data = json.decode(response.body);

      if (data['success'] == true) {
        // ============================================================
        // ⚠️ التعديل الجديد: مسح كل البيانات المخزنة في الهاتف
        // ============================================================
        await prefs.clear(); 
        
        // ✅ تصحيح 2: التأكد من وجود الشاشة بعد عملية المسح (prefs.clear)
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SplashScreen()), 
            (Route<dynamic> route) => false
        );
      } else {
        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      // ✅ تصحيح 3: التحقق داخل الـ catch
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    }
}
  Future<void> updateUserName(String newName) async {
    if (newName.length < 2) {
      showFancyToast(AppStrings.get(context, 'name_too_short'), isError: true);
      return;
    }
    
    // 1. جلب UUID المخزن
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    // ✅ تصحيح 1: التحقق هنا ضروري لأننا انتظرنا SharedPreferences
    if (!mounted) return;

    showFancyToast(AppStrings.get(context, 'loading')); 

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'update_user_name',
          'user_id': userId,
          'new_name': newName,
          'uuid': myUuid ?? '', 
        }
      );
      
      // ✅ هذا التحقق كان موجوداً وهو صحيح ومهم جداً
      if (!mounted) return;
      
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        setState(() { userName = newName; });
        Navigator.pop(context); // إغلاق النافذة
        showFancyToast(AppStrings.get(context, 'save_changes'));
      } else {
        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      // ✅ تصحيح 2: التحقق داخل الـ catch قبل استخدام context
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    }
}

  // --- نافذة الإعدادات الشاملة (اللغة + الاسم) ---
  void showSettingsDialog({bool isFirstTime = false}) {
    String tempName = userName;
    if (isFirstTime || tempName == 'مستخدم جديد' || tempName == 'المدير') {
      tempName = "";
    }

    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: defaultPrimary, width: 2),
                  boxShadow: [BoxShadow(color: defaultPrimary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(isFirstTime ? FontAwesomeIcons.earthAmericas : FontAwesomeIcons.userGear, size: 50, color: defaultPrimary),
                      const SizedBox(height: 20),
                      Text(
                        isFirstTime ? AppStrings.get(context, 'hello_first_time') : AppStrings.get(context, 'edit_profile'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      
                      // 1. قسم تغيير اللغة
                      const Align(alignment: AlignmentDirectional.centerStart, child: Text("🌐 Language / اللغة / زبان", style: TextStyle(color: Colors.grey, fontSize: 12))),
                      const SizedBox(height: 10),
                     // داخل Row الأزرار
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildLangBtn(context, 'ar', '🇦🇪', "عربي"),
    _buildLangBtn(context, 'en', '🇺🇸', "English"),
    _buildLangBtn(context, 'ur', '🇵🇰', "اردو"),
    _buildLangBtn(context, 'zh', '🇨🇳', "中文"), // <--- الزر الجديد
  ],
),
                      const Divider(height: 30),

                      // 2. قسم تعديل الاسم
                      Align(alignment: AlignmentDirectional.centerStart, child: Text(AppStrings.get(context, 'name_placeholder'), style: const TextStyle(color: Colors.grey, fontSize: 12))),
                      const SizedBox(height: 10),
                      TextField(
                        textAlign: TextAlign.center,
                        onChanged: (v) => tempName = v,
                        decoration: InputDecoration(
                          hintText: tempName.isEmpty ? AppStrings.get(context, 'name_placeholder') : tempName,
                          filled: true,
                          fillColor: bgBody,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // أضف هذا داخل الـ Column في showSettingsDialog
                      ListTile(
  leading: const Icon(Icons.privacy_tip, color: Colors.grey),
  title: Text(
    // فحص اللغة لاختيار النص المناسب
    Localizations.localeOf(context).languageCode == 'ar' 
    ? "سياسة الخصوصية" 
    : (Localizations.localeOf(context).languageCode == 'ur' 
        ? "رازداری کی پالیسی" 
        : (Localizations.localeOf(context).languageCode == 'zh'
            ? "隐私政策" 
            : "Privacy Policy")),
    style: const TextStyle(color: Colors.white),
  ),
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
  },
),
const Divider(height: 30), // خط فاصل جمالي // خط فاصل
                      // زر الحفظ
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: defaultPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () async {
                             // 1. التقاط اللغة الحالية قبل الـ await لتجنب أي مشاكل مع الـ context
                             String currentLang = Localizations.localeOf(context).languageCode;
                             
                             final prefs = await SharedPreferences.getInstance();
                             if (prefs.getString('language_code') == null) {
                               await prefs.setString('language_code', currentLang);
                             }

                             // ⭐ 2. سطر الحماية: التأكد من أن النافذة ما زالت موجودة في الشاشة
                             if (!context.mounted) return;

                             // 3. حفظ الاسم وإغلاق النافذة بأمان تام
                             if (tempName.isNotEmpty && tempName != userName) {
                               updateUserName(tempName); 
                             } else {
                               Navigator.pop(context);
                             }
                          },
                          child: Text(AppStrings.get(context, 'save_changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildLangBtn(BuildContext context, String code, String flag, String name) {
    bool isSelected = Localizations.localeOf(context).languageCode == code;
    return GestureDetector(
      onTap: () async {
        Locale newLocale = Locale(code);
        SmartGateApp.setLocale(context, newLocale); 
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', code); 
        await prefs.setString('language_code', code); 
      
      // 🟢 تحديث اللغة في السيرفر بصمت في الخلفية
      String? myUuid = prefs.getString('gate_app_uuid');
      if (myUuid != null) {
        http.post(Uri.parse(domainUrl), body: {
          'action': 'register_device',
          'uuid': myUuid,
          'lang': code, // اللغة الجديدة
          // لا نرسل التوكن هنا لتجنب حذفه بطريق الخطأ في السيرفر (PHP يحتفظ بالتوكن القديم إذا أرسلناه فارغاً)
        });
      }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? defaultPrimary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? defaultPrimary : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
Future<void> initApp() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. التأكد من وجود UUID
    deviceUuid = prefs.getString('gate_app_uuid');
    if (deviceUuid == null) {
      deviceUuid = const Uuid().v4();
      await prefs.setString('gate_app_uuid', deviceUuid!);
    }

    // 🟢 2. استخراج التوكن مع حماية (Timeout) لمنع تعليق التطبيق إذا تأخرت جوجل
    String? fcmToken;
    try {
      // إجبار الفايربيز على الرد خلال 3 ثوانٍ فقط وإلا سيتجاوزه التطبيق ليفتح
      fcmToken = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("FCM Token Error or Timeout: $e");
    }

    setState(() {
      userId = prefs.getString('cached_user_id');
      userName = prefs.getString('cached_user_name') ?? "";
      role = prefs.getString('cached_role');
    });

    // تحميل البوابات فورا إذا كان مسجلاً من قبل
    if (userId != null) {
      loadMyGates();
    }

    try {
      String currentLang = prefs.getString('language_code') ?? 'en';
      
      // 3. الاتصال بالسيرفر 
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'register_device', 
          'uuid': deviceUuid ?? '',
          'fcm_token': fcmToken ?? '',
          'lang': currentLang, 
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body.trim());
        if (data['success'] == true) {
          setState(() {
            userId = data['user_id'].toString();
            userName = data['name'];
            role = data['role'];
          });
          
          await prefs.setString('cached_user_id', userId!);
          await prefs.setString('cached_user_name', userName);
          await prefs.setString('cached_role', role ?? 'user');
          
          loadMyGates(); // 👈 هذا السطر يوقف التحميل في حالة النجاح

          String? savedLang = prefs.getString('language_code');
          
          if (savedLang == null) {
             Future.delayed(const Duration(milliseconds: 500), () {
               if (mounted) showSettingsDialog(isFirstTime: true);
             });
          }
        } else {
          // 🔴 إذا رفض السيرفر التسجيل (بسبب خطأ SQL مثلاً)، نوقف التحميل إجبارياً
          if (mounted) {
            setState(() => isLoading = false);
            showFancyToast(data['message'] ?? 'خطأ في السيرفر', isError: true);
          }
        }
      } else {
         // 🔴 إذا كان السيرفر معطلاً (Error 500)
         if (mounted) {
            setState(() => isLoading = false);
            showFancyToast("خطأ استجابة السيرفر: ${response.statusCode}", isError: true);
         }
      }
    } catch (e) {
      debugPrint("Offline mode or Server Error: $e");
      // 🔴 إيقاف دائرة التحميل إجبارياً إذا انقطع الإنترنت
      if (mounted) {
         setState(() => isLoading = false);
      }
    }
  }
// أضف هذه الدالة داخل _HomeScreenState
Future<void> triggerGate(String gateId) async {
   final prefs = await SharedPreferences.getInstance();
   String? myUuid = prefs.getString('gate_app_uuid');
   if (!mounted) return;
   // showFancyToast(AppStrings.get(context, 'sending')); // اختياري لعدم الإزعاج

   try {
     await http.post(
       Uri.parse(domainUrl),
       body: {
         'action': 'toggle_gate',
         'gate_id': gateId,
         'uuid': myUuid ?? '', 
         'user_id': userId, 
       },
     );
     // لا داعي لانتظار الرد لتحديث الواجهة، سنحدثها تلقائياً لاحقاً
     // لكن يمكننا إعادة تحميل الحالة
     loadMyGates();
   } catch (e) {
     // ignore
   }
}
  bool isBluetoothLoading = false;

  // دالة مخصصة لفتح البلوتوث من الشاشة الرئيسية
  // دالة مخصصة لفتح البلوتوث من الشاشة الرئيسية (محدثة وآمنة)
 // دالة مخصصة لفتح البلوتوث من الشاشة الرئيسية
  Future<void> triggerBluetoothGateFromHome(String gateId) async {
    if (kIsWeb) {
      showFancyToast(AppStrings.get(context, 'starter_internet_required'), isError: true);
      return; // نوقف التنفيذ فوراً
    }
    if (isBluetoothLoading) return;
    
    // 🟢 1. جلب الترجمة قبل أي فجوة زمنية (await)
    String missingQrText = AppStrings.get(context, 'missing_qr_error');
    
    setState(() => isBluetoothLoading = true);
    
    // الفجوة الزمنية الأولى
    String? savedQr = await GateStorageService.getGateQrCode(gateId);
    
    if (savedQr == null || savedQr.isEmpty) {
      if (mounted) {
        setState(() => isBluetoothLoading = false);
        // استخدام المتغير الجاهز هنا بدلاً من استدعاء context
        showFancyToast(missingQrText, isError: true); 
      }
      return; 
    }
    
    // الفجوة الزمنية الثانية
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');
    
    // 🟢 2. حماية الـ context قبل الانتقال لخدمة البلوتوث
    if (!mounted) return;
    
    await BluetoothGateService.openGateFast(
      context,
      gateId,
      userId ?? '',
      myUuid ?? '',
      savedQr,
    );
    
    if (mounted) setState(() => isBluetoothLoading = false);
  }
  
  // الدالة الذكية التي تقرر كيف تفتح البوابة بناءً على الباقة
  Future<void> triggerGateSmart(dynamic gate) async {
    String planType = gate['plan_type'] ?? 'gold';
    String gateId = gate['id'].toString();
    
    if (planType == 'starter') {
    // الستارتر: بلوتوث فقط
    if (kIsWeb) {
      // الويب لا يدعم بلوتوث، نعرض رسالة أن الباقة تتطلب إنترنت أو موبايل
      showFancyToast(AppStrings.get(context, 'starter_internet_required'), isError: true);
    } else {
      await triggerBluetoothGateFromHome(gateId);
    }
  } else if (planType == 'gold') {
      // الجولد: إنترنت فقط
      await triggerGate(gateId);
    } else {
      // البلاتينيوم: المحاولة عبر الإنترنت أولاً بمهلة قصيرة
      bool mqttSuccess = false;
      final prefs = await SharedPreferences.getInstance();
      String? myUuid = prefs.getString('gate_app_uuid');
      
      try {
        final response = await http.post(
          Uri.parse(domainUrl),
          body: {
            'action': 'toggle_gate',
            'gate_id': gateId,
            'uuid': myUuid ?? '',
            'user_id': userId,
          },
        ).timeout(const Duration(seconds: 3));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) mqttSuccess = true;
        }
      } catch (e) {
        // تجاهل الخطأ للانتقال للبلوتوث
      }
      
      // إذا فشل الإنترنت أو تأخر، ننتقل فوراً للبلوتوث
      if (!mqttSuccess) {
        
        await triggerBluetoothGateFromHome(gateId);
      }
    }
  }
  // دالة لعرض نافذة مفتاح البوابة الجذابة
 // دالة لعرض نافذة مفتاح البوابة الجذابة (محدثة لتدعم اللغات)
  Future<void> showGateKeyDialog(String gateId, String gateName) async {
    String? qrSecret = await GateStorageService.getGateQrCode(gateId);

    if (qrSecret == null || qrSecret.isEmpty) {
      if (mounted) showFancyToast(AppStrings.get(context, 'local_key_not_found'), isError: true);
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: defaultPrimary, width: 2),
              boxShadow: [
                BoxShadow(color: defaultPrimary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.qrcode, size: 40, color: defaultPrimary),
                const SizedBox(height: 15),
                Text(
                  gateName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.get(context, 'scan_or_copy_key'), // تم التعديل
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // --- صندوق الكيو آر كود ---
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: QrImageView(
                    data: qrSecret,
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ),
                const SizedBox(height: 20),

                // --- صندوق النص الذي يحتوي على الكود السري ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgBody,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SelectableText(
                    qrSecret,
                    style: const TextStyle(color: neonGreen, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),

                // --- أزرار النسخ والمشاركة ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر النسخ
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgBody,
                        side: const BorderSide(color: defaultPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy, color: defaultPrimary, size: 18),
                      label: Text(AppStrings.get(context, 'copy'), style: const TextStyle(color: defaultPrimary)), // تم التعديل
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrSecret));
                        showFancyToast(AppStrings.get(context, 'copied_successfully')); // تم التعديل
                      },
                    ),
                    
                    // زر المشاركة
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: defaultPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share, color: Colors.white, size: 18),
                      label: Text(AppStrings.get(context, 'share'), style: const TextStyle(color: Colors.white)), // تم التعديل
                      onPressed: () {
                        // تجميع النص للمشاركة بناءً على اللغة
                        String shareText = "${AppStrings.get(context, 'gate_key_is')} ($gateName):\n\n$qrSecret\n\n${AppStrings.get(context, 'copy_and_use')}";
                        Share.share(shareText);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // زر الإغلاق
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppStrings.get(context, 'close'), style: const TextStyle(color: Colors.grey)), // تم التعديل (نستخدم close الموجودة مسبقاً)
                )
              ],
            ),
          ),
        );
      },
    );
  }
Future<void> loadMyGates() async {
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();

    // 🟢 1. استرجاع البوابات المخزنة محلياً أولاً
    String? cachedGatesStr = prefs.getString('cached_gates_$userId');
    if (cachedGatesStr != null) {
      List<dynamic> localGates = json.decode(cachedGatesStr);
      
      // 🛡️ فلتر الويب: حذف بوابات الستارتر من القائمة المحلية
      if (kIsWeb) {
        localGates = localGates.where((g) => g['plan_type'] != 'starter').toList();
      }

      setState(() {
        gates = localGates;
        isLoading = false; // نوقف التحميل لأننا جلبنا البيانات محلياً
      });
    }

    try {
      // محاولة الجلب من السيرفر بمهلة زمنية
      final response = await http.post(
        Uri.parse(domainUrl), 
        body: {'action': 'get_my_gates', 'user_id': userId}
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> fetchedGates = data['data'] ?? [];

        // 🟢 تحديث الذاكرة المحلية بالبوابات الجديدة (نحفظها كاملة كما جاءت من السيرفر)
        await prefs.setString('cached_gates_$userId', json.encode(fetchedGates));

        // 🛡️ فلتر الويب: حذف بوابات الستارتر من القائمة القادمة من السيرفر قبل عرضها
        if (kIsWeb) {
          fetchedGates = fetchedGates.where((g) => g['plan_type'] != 'starter').toList();
        }

        setState(() {
          gates = fetchedGates;
          isLoading = false;
        });

        // === منطق الفتح التلقائي ===
        if (_isFirstLoad && gates.isNotEmpty) {
          for (var gate in gates) {
            String gId = gate['id'].toString();
            bool isAuto = prefs.getBool('auto_open_$gId') ?? false;

            if (isAuto) {
              showFancyToast("🚀 ${gate['name']}...");
              triggerGateSmart(gate); 
            }
          }
          _isFirstLoad = false;
        }
      }
    } catch (e) {
      // لا يوجد إنترنت: ستبقى البوابات المخزنة محلياً ظاهرة ولن يتم مسحها
      if (mounted) setState(() => isLoading = false);
      debugPrint("Offline mode: Using cached gates.");
    }
  }

  Future<void> linkGate(String qrCode) async {
    showFancyToast(AppStrings.get(context, 'loading'));
    
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'link_gate', 
          'qr_code': qrCode, 
          'user_id': userId,
          'uuid': myUuid ?? '', 
        },
      );
      
      if (!mounted) return;

      final data = json.decode(response.body.trim());
      
      if (data['success'] == true) {
        
        // 🟢 التعديل الجوهري: حفظ الرمز (سواء كان QR أو يدوي) في الخزنة السرية
        if (data['gate_id'] != null) {
           await GateStorageService.saveGateQrCode(data['gate_id'].toString(), qrCode);
           debugPrint("✅ تم تأمين مفتاح البوابة محلياً: $qrCode");
        }

        // 👇 التعديل هنا: تمرير رسالة النجاح للمترجم
        // ignore: use_build_context_synchronously
        showFancyToast(AppStrings.translateServerMsg(context, data['message'].toString())); 
        loadMyGates();
      } else {
        // 👇 التعديل هنا: تمرير رسالة الخطأ للمترجم
        showFancyToast(AppStrings.translateServerMsg(context, data['message'].toString()), isError: true);
      }
    } catch (e) {
      if (mounted) showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
    }
} // دالة لإظهار نافذة الإدخال اليدوي
void showManualAddDialog() {
    String manualCode = "";
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bgCard,
          title: Text(AppStrings.get(context, 'add_code_manually'), style: const TextStyle(color: Colors.white)),
          content: TextField(
            onChanged: (val) => manualCode = val,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: bgBody,
              hintText: AppStrings.get(context, 'hint_code'), // مثال: GATE_123
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.get(context, 'cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: defaultPrimary),
              onPressed: () {
                if (manualCode.length > 3) {
                  Navigator.pop(ctx);
                  linkGate(manualCode); // نستخدم نفس دالة الربط الموجودة سابقاً
                } else {
                   showFancyToast(AppStrings.get(context, 'connection_error'), isError: true); // أو رسالة أن الكود قصير
                }
              },
              child: Text(AppStrings.get(context, 'add'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
}
Future<void> toggleAutoOpen(String gateId, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  if (value) {
    await prefs.setBool('auto_open_$gateId', true);
    if (mounted) showFancyToast(AppStrings.get(context, 'auto_open_on'));
  } else {
    await prefs.remove('auto_open_$gateId');
    if (mounted) showFancyToast(AppStrings.get(context, 'auto_open_off')); // استخدمنا info افتراضياً
  }
  // إعادة تحميل البوابات لتحديث الواجهة (اختياري، لكن يفضل لتأكيد الحالة)
  setState(() {});
}
  Widget buildGateCard(dynamic gate) {
  final theme = getGateTheme(gate['plan_type']);
  bool isAr = Localizations.localeOf(context).languageCode == 'ar';
  String gateId = gate['id'].toString();

  return Stack(
    children: [
      // 1. جسم الكارت
      Positioned.fill(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GateDetailsScreen(gate: gate, userId: userId!, userRole: gate['role'] ?? 'user', theme: theme)))
            .then((value) => loadMyGates());
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(20),
             border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgCard, ...theme.gradient]
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // تعديل بسيط لترك مساحة لزر التفعيل في الأعلى
                const SizedBox(height: 20), 
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: FaIcon(getIconData(gate['icon']), size: 28, color: theme.primary),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    gate['name'],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (gate['status'] == 'OPEN' ? neonGreen : dangerColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (gate['status'] == 'OPEN' ? neonGreen : dangerColor).withValues(alpha: 0.5), width: 1)
                  ),
                  child: Text(
                    gate['status'] == 'OPEN' ? AppStrings.get(context, 'open') : AppStrings.get(context, 'closed'),
                    style: TextStyle(color: gate['status'] == 'OPEN' ? neonGreen : dangerColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. زر القائمة (3 نقاط) - اليمين أو اليسار حسب اللغة
      // 2. زر القائمة (3 نقاط) - اليمين أو اليسار حسب اللغة
      Positioned(
        top: 8,
        right: isAr ? null : 8, 
        left: isAr ? 8 : null,
        child: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha : 0.6), size: 20),
          color: bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          onSelected: (value) {
            if (value == 'edit') {
               editGateNameFromHome(gate['id'].toString(), gate['name'], gate['icon'] ?? 'fa-dungeon');
            } else if (value == 'share') {
               // ✅ هنا استدعينا نافذة العرض والمشاركة الجديدة
               showGateKeyDialog(gate['id'].toString(), gate['name']);
            } else if (value == 'delete') {
               deleteGateFromHome(gate['id'].toString());
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            // الزر الجديد للمشاركة
           // الزر الجديد للمشاركة (مع إضافة const لتحسين الأداء)
            PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: neonGreen, size: 16), 
                  const SizedBox(width: 8), 
                  Text(AppStrings.get(context, 'share_key'), style: const TextStyle(fontSize: 13)) // تم التعديل هنا
                ]
              ),
            ),
            const PopupMenuDivider(height: 1),
            // زر التعديل الأصلي
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(children: [const Icon(Icons.edit, color: defaultPrimary, size: 16), const SizedBox(width: 8), Text(AppStrings.get(context, 'edit_gate_name'), style: const TextStyle(fontSize: 13))]),
            ),
            const PopupMenuDivider(height: 1),
            // زر الحذف الأصلي
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(children: [const Icon(Icons.delete_forever, color: dangerColor, size: 16), const SizedBox(width: 8), Text(AppStrings.get(context, 'delete_gate_forever'), style: const TextStyle(color: dangerColor, fontSize: 13))]),
            ),
          ],
        ),
      ),

      // 3. (الجديد) زر التفعيل التلقائي - عكس اتجاه القائمة
      Positioned(
        top: 8,
        left: isAr ? null : 8, // عكس القائمة
        right: isAr ? 8 : null,
        child: FutureBuilder<bool>(
          future: SharedPreferences.getInstance().then((p) => p.getBool('auto_open_$gateId') ?? false),
          builder: (context, snapshot) {
            bool isAuto = snapshot.data ?? false;
            return GestureDetector(
              onTap: () {
                // تغيير الحالة
                toggleAutoOpen(gateId, !isAuto);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isAuto ? neonGreen : Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAuto ? Icons.check_circle : Icons.circle_outlined,
                      size: 14,
                      color: isAuto ? neonGreen : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.get(context, 'auto_label'), // AUTO
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold,
                        color: isAuto ? neonGreen : Colors.grey
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgCard.withValues(alpha: 0.9),
        title: GestureDetector(
          onTap: () => showSettingsDialog(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.get(context, 'welcome'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
             Row(
  children: [
    Text(
      _getDisplayName(), // <--- سنستخدم دالة جديدة هنا
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: defaultPrimary),
    ),
    const SizedBox(width: 5),
    const Icon(Icons.edit, size: 14, color: Colors.grey)
  ],
),
            ],
          ),
        ),
        actions: [
          IconButton(
      icon: const FaIcon(FontAwesomeIcons.keyboard, size: 18, color: Colors.white70),
      tooltip: AppStrings.get(context, 'add_code_manually'),
      onPressed: showManualAddDialog, // استدعاء الدالة التي أنشأناها
    ),
           IconButton(
             icon: const FaIcon(FontAwesomeIcons.userXmark, size: 18, color: dangerColor), 
              // الطريقة المختصرة والنظيفة
onPressed: deleteMyAccount,
           ),
           IconButton(
             icon: const FaIcon(FontAwesomeIcons.qrcode, size: 18, color: defaultPrimary), 
             onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen())).then((v) { 
                if(v!=null && v is String) {
                  linkGate(v); 
                }
              });
           })
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : gates.isEmpty 
              ? Center(child: Text(AppStrings.get(context, 'no_gates'), style: const TextStyle(color: Colors.grey)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.85),
                    itemCount: gates.length,
                    itemBuilder: (context, index) => buildGateCard(gates[index]),
                  ),
                ),
    );
  }
  String _getDisplayName() {
  // 1. إذا كان الاسم فارغاً (في بداية التشغيل)
  if (userName.isEmpty) {
    return AppStrings.get(context, 'loading'); // سيأخذ كلمة "جاري التحميل" حسب لغة الجهاز
  }

  // 2. إذا كان الاسم هو الافتراضي القادم من السيرفر (بالعربي)
  // نستبدله بالكلمة المترجمة من القاموس
  if (userName == 'مستخدم جديد') {
    return AppStrings.get(context, 'default_user');
  }
  if (userName == 'المدير') {
    return AppStrings.get(context, 'default_admin');
  }

  // 3. إذا كان المستخدم قد كتب اسمه الخاص، نعرضه كما هو
  return userName;
}
}

// ==========================================
// 4. شاشة التفاصيل (GateDetailsScreen)
// ==========================================
class GateDetailsScreen extends StatefulWidget {
  final dynamic gate;
  final String userId;
  final String userRole;
  final GateTheme theme;
  final int initialTabIndex; // 👈 التعديل الأول

  const GateDetailsScreen({
    super.key, 
    required this.gate, 
    required this.userId, 
    required this.userRole, 
    required this.theme,
    this.initialTabIndex = 0, // 👈 القيمة الافتراضية
  });
 
  @override
  State<GateDetailsScreen> createState() => _GateDetailsScreenState();
}

class _GateDetailsScreenState extends State<GateDetailsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late String currentGateName;
  bool isLocked = false; // 👈 1. أضف هذا المتغير هنا
  List<dynamic> logs = [];
  List<dynamic> users = [];
  bool isLoadingLogs = false;
  bool isLoadingUsers = false;
  DateTime? selectedDate; 

  @override
  void initState() {
    super.initState();
    currentGateName = widget.gate['name'];
    isLocked = widget.gate['lock_status'] == 'LOCKED';
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
   
    fetchLogs(); 
    if (widget.userRole == 'admin') {
      fetchUsers();
    }
  }

 void showFancyToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    
    // 👈 التعديل السحري هنا: مسح فوري للتوست القديم بدون أنيميشن خروج
    ScaffoldMessenger.of(context).clearSnackBars(); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(isError ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.circleCheck, color: Colors.white, size: 20),
            const SizedBox(width: 15),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? dangerColor : const Color(0xFF10b981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2), // 👈 تقليل مدة البقاء ليكون التطبيق أسرع
      ),
    );
  }
  // 1. متغير لمنع الضغط المزدوج لزر القفل
  bool isLockLoading = false;

  // 2. دالة إرسال أمر القفل/إلغاء القفل
  Future<void> toggleGateLock() async {
    // منع التنفيذ إذا كان هناك تحميل جاري لزر الفتح أو زر القفل
    if (isLockLoading || isBluetoothLoading) return;
    setState(() => isLockLoading = true);

    showFancyToast(AppStrings.get(context, 'opening_internet'));

    bool mqttSuccess = false;
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    try {
      // إرسال الطلب للسيرفر (سيتم استلامه في api.php لتشغيل الريلي الثاني على الرجل 17)
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'toggle_lock', // هذا هو الأمر الجديد الذي يجب إضافته في السيرفر
          'gate_id': widget.gate['id'].toString(),
          'uuid': myUuid ?? '',
          'user_id': widget.userId,
        },
      ).timeout(const Duration(seconds: 3)); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          mqttSuccess = true;
          if (mounted) {
            // 👈 3. أضف هذا السطر لتغيير شكل الزر فوراً عند النجاح
            setState(() { isLocked = !isLocked; });
            fetchLogs(); // تحديث السجل
            showFancyToast(AppStrings.get(context, 'lock_cmd_sent'));
          }
        } else {
           if (mounted) showFancyToast(data['message'], isError: true);
        }
      }
    } catch (e) {
      // تم التجاهل عن قصد للتعامل مع انقطاع الشبكة
    }
  // 👈 التعديل هنا: التحويل التلقائي للبلوتوث في حال فشل الإنترنت
    // 👈 التعديل هنا (لا يوجد أي تأخير)
    // التحويل التلقائي للبلوتوث في حال فشل الإنترنت (للموبايل فقط)
    if (!mqttSuccess && mounted) {
      if (kIsWeb) {
        // نحن على الويب، لا نذهب للبلوتوث، نكتفي بإظهار خطأ اتصال
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
        setState(() => isLockLoading = false);
      } else {
        // نحن على الموبايل، نكمل خطة البلوتوث
        showFancyToast(AppStrings.get(context, 'network_unavailable_fallback'));
        setState(() => isLockLoading = false);
        await triggerBluetoothLock(isFallback: true); 
      }
    } else {
      if (mounted) setState(() => isLockLoading = false);
    }
    // التحقق من نجاح العملية
    

    if (mounted) setState(() => isLockLoading = false);
  }
  // دالة إظهار تحذير قبل قفل البوابة
  Future<void> showLockWarningDialog() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.amber, width: 2), // إطار تحذيري برتقالي
              boxShadow: [
                BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(FontAwesomeIcons.triangleExclamation, size: 50, color: Colors.amber),
                const SizedBox(height: 15),
                Text(
                  AppStrings.get(context, 'lock_warning_title'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  AppStrings.get(context, 'lock_warning_body'),
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppStrings.get(context, 'cancel'), style: const TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black, // نص أسود ليتناسب مع الخلفية البرتقالية
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(AppStrings.get(context, 'proceed_lock'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // إذا ضغط المستخدم على "نعم"، نقوم باستدعاء دالة القفل الأصلية
    if (confirm == true) {
      toggleGateLock(); 
    }
  }
Future<void> triggerGate() async {
    if (isBluetoothLoading) return; // 🔒 1. منع الضغط المزدوج
    setState(() => isBluetoothLoading = true); // 🔒 2. تشغيل حالة التحميل (تغيير شكل الزر)

    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    if (!mounted) return;

   showFancyToast(AppStrings.get(context, 'opening_internet'));
    
    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'toggle_gate',
          'gate_id': widget.gate['id'].toString(),
          'uuid': myUuid ?? '', 
          'user_id': widget.userId, 
        },
      );
      
      if (!mounted) return;

      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        fetchLogs(); 
        showFancyToast(AppStrings.get(context, 'success_op')); 
      } else {
        String translatedMsg = AppStrings.translateServerMsg(context, data['message'].toString());
        showFancyToast(translatedMsg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    } finally {
      // 🔓 3. فك القفل دائماً وإعادة الزر لشكله الطبيعي في جميع الحالات (نجاح، خطأ سيرفر، أو خطأ نت)
      if (mounted) {
        setState(() => isBluetoothLoading = false);
      }
    }
  }
bool isBluetoothLoading = false; 

  Future<void> triggerBluetoothGate() async {
    if (kIsWeb) {
      showFancyToast(AppStrings.get(context, 'starter_internet_required'), isError: true);
      return; 
    }
    if (isBluetoothLoading) return; 

    // 🟢 1. جلب النصوص التي تحتاج context في أول سطر قبل أي عملية انتظار (Await)
   

    // قراءة المفتاح السري من الخزنة المشفرة للهاتف
    String? savedQr = await GateStorageService.getGateQrCode(widget.gate['id'].toString());

    // التأكد من أن الهاتف يمتلك مفتاح هذه البوابة
    if (savedQr == null || savedQr.isEmpty) {
     // ignore: use_build_context_synchronously
     showFancyToast(AppStrings.get(context, 'missing_qr_error'), isError: true);
      return; // نوقف العملية تماماً
    }

    setState(() {
      isBluetoothLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    // 🟢 2. الفحص الإجباري لحماية التطبيق قبل استخدام context مجدداً
    if (!mounted) return;

    showFancyToast(AppStrings.get(context, 'opening_bluetooth'));

    // استدعاء خدمة البلوتوث السريعة وتمرير المفتاح السري (savedQr) كمعامل خامس
    final result = await BluetoothGateService.openGateFast(
      context, 
      widget.gate['id'].toString(),
      widget.userId,
      myUuid ?? '',
      savedQr, 
    );

    if (!mounted) return;

    setState(() {
      isBluetoothLoading = false;
    });

    // عرض النتيجة
    if (result['success'] == true) {
      showFancyToast(result['message']);
      fetchLogs(); // تحديث سجل النشاطات
    } else {
      showFancyToast(result['message'], isError: true);
    }
  }
  // 👈 1. أضفنا {bool isFallback = false}
  Future<void> triggerBluetoothLock({bool isFallback = false}) async {
    if (kIsWeb) {
      showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      return;
    }
    if (isLockLoading) return; 

   String? savedQr = await GateStorageService.getGateQrCode(widget.gate['id'].toString());

// 1. أضف سطر الحماية السحري هنا
if (!mounted) return; 

if (savedQr == null || savedQr.isEmpty) {
  showFancyToast(AppStrings.get(context, 'missing_qr_error'), isError: true); // ✅ أصبح آمناً تماماً
  return;
}

    setState(() => isLockLoading = true);
    showFancyToast(AppStrings.get(context, 'locking_bluetooth'));
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    if (!mounted) return;
    
    // 👈 2. التعديل هنا: نظهر توست البلوتوث فقط إذا لم يكن تحويلاً تلقائياً
    

    // استدعاء البلوتوث
    final result = await BluetoothGateService.toggleLockFast(
      context, 
      widget.gate['id'].toString(),
      widget.userId,
      myUuid ?? '',
      savedQr, 
    );

    if (!mounted) return;
    setState(() => isLockLoading = false);

    if (result['success'] == true) {
      setState(() { isLocked = !isLocked; });
      showFancyToast(AppStrings.get(context, 'lock_cmd_sent'));
      fetchLogs(); 
    } else {
      showFancyToast(result['message'], isError: true);
    }
  }
  Future<void> fetchUsers() async {
    setState(() => isLoadingUsers = true);
    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {'action': 'get_gate_users', 'gate_id': widget.gate['id'].toString()},
      );
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() => users = data['data']);
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => isLoadingUsers = false);
      }
    }
  }

  Future<void> transferOwnership(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'transfer_ownership',
          'user_id': widget.userId,
          'target_id': targetId,
          'gate_id': widget.gate['id'].toString(), // <--- ⚠️ هذا هو السطر الجديد الضروري
          'uuid': myUuid ?? '',
        },
      );
      
      if (!mounted) return;

      final data = json.decode(response.body);
      if (data['success'] == true) {
        Navigator.pop(context); // إغلاق النافذة
        showFancyToast(AppStrings.get(context, 'success_op')); // تم بنجاح
        fetchUsers(); // تحديث القائمة
        
        // إذا نقلت الملكية لشخص آخر، ستصبح أنت "مستخدم" وتختفي الأزرار
        // سنحتاج لإعادة تحميل البوابات في الصفحة الرئيسية لاحقاً
      } else {
        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    }
}
  Future<void> deleteUser(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          // 🛑 التغيير الجذري هنا:
          // بدلاً من 'delete_user' التي تحذف الحساب بالكامل
          // نستخدم 'unlink_user_gate' التي تحذفه من هذه البوابة فقط
          'action': 'unlink_user_gate', 
          
          'user_id': widget.userId,       // المعرف الخاص بالمدير الذي يقوم بالحذف
          'target_id': targetId,          // العضو المراد طرده
          'gate_id': widget.gate['id'].toString(), // ⚠️ ضروري جداً تحديد البوابة
          'uuid': myUuid ?? '',
        },
      );
      
      if (!mounted) return;

      final data = json.decode(response.body);
      if (data['success'] == true) {
        fetchUsers(); // تحديث القائمة
        showFancyToast(AppStrings.get(context, 'success_op'));
      } else {
         showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
       if (mounted) {
         showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
       }
    }
}

  Future<void> fetchLogs() async {
     setState(() => isLoadingLogs = true);
    try {
      Map<String, String> body = {
        'action': 'get_system_logs', 
        'user_id': widget.userId
      };
      if (selectedDate != null) {
        String formattedDate = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2,'0')}-${selectedDate!.day.toString().padLeft(2,'0')}";
        body['target_date'] = formattedDate;
      }
      final response = await http.post(Uri.parse(domainUrl), body: body);
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['success'] == true) {
        List<dynamic> allLogs = data['data'];
        setState(() {
          logs = allLogs.where((log) => log['gate_name'] == widget.gate['name']).toList();
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => isLoadingLogs = false);
      }
    }
  }

  Future<void> pickDateAndRefresh() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: widget.theme.primary, onPrimary: Colors.black, surface: bgCard),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchLogs();
    }
  }

  Future<void> updateGateName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    // ✅ تصحيح 1: التحقق بعد العملية غير المتزامنة الأولى
    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'update_gate_name', 
          'gate_id': widget.gate['id'].toString(), 
          'user_id': widget.userId,
          'new_name': newName,
          'uuid': myUuid ?? '', 
        },
      );
      
      // ✅ هذا التحقق موجود وصحيح
      if (!mounted) return;

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() => currentGateName = newName);
        Navigator.pop(context); 
        showFancyToast(AppStrings.get(context, 'save_changes'));
      } else {
        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      // ✅ تصحيح 2: التحقق داخل الـ catch قبل استخدام context
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    }
}

 Future<void> deleteGate() async {
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'delete_gate', 
          'gate_id': widget.gate['id'].toString(), 
          'user_id': widget.userId,
          'uuid': myUuid ?? '', 
        },
      );
      
      if (!mounted) return;
      
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        // 🟢 1. جلب الترجمة أولاً والاحتفاظ بها قبل إغلاق أي شيء
        String successMsg = AppStrings.get(context, data['message'].toString());
        
        // 🟢 2. الآن نغلق النوافذ بأمان تام
        Navigator.of(context).pop(); 
        Navigator.of(context).pop(); 
        
        // 🟢 3. نعرض التوست باستخدام المتغير النصي الجاهز
        showFancyToast(successMsg); 
      } else {
        // هنا لا بأس لأننا لم نغلق الشاشة في حالة الخطأ
        showFancyToast(AppStrings.get(context, data['message'].toString()), isError: true);
      }
    } catch (e) {
      if (mounted) {
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
      }
    }
  }
  void showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit, color: widget.theme.primary),
                title: Text(AppStrings.get(context, 'edit_gate_name')),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) {
                      String newName = currentGateName;
                      return AlertDialog(
                        backgroundColor: bgCard,
                        title: Text(AppStrings.get(context, 'edit_gate_name')),
                        content: TextFormField(
                          initialValue: newName,
                          onChanged: (v) => newName = v,
                          decoration: InputDecoration(hintText: AppStrings.get(context, 'name_placeholder')),
                        ),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(dCtx), child: Text(AppStrings.get(context, 'cancel'))),
                          TextButton(onPressed: () => updateGateName(newName), child: Text(AppStrings.get(context, 'save_changes'))),
                        ],
                      );
                    }
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: dangerColor),
                title: Text(AppStrings.get(context, 'delete_gate_forever'), style: const TextStyle(color: dangerColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: bgCard,
                      title: Text(AppStrings.get(context, 'confirm')),
                      content: Text(AppStrings.get(context, 'confirm_delete')),
                      actions: [
                        TextButton(onPressed: ()=>Navigator.pop(dCtx), child: Text(AppStrings.get(context, 'cancel'))),
                        TextButton(onPressed: () => deleteGate(), child: Text(AppStrings.get(context, 'delete'), style: const TextStyle(color: Colors.red))),
                      ],
                    )
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void showScheduleDialog() {
    if (widget.gate['plan_type'] != 'platinum') {
       showDialog(
         context: context,
         builder: (ctx) => AlertDialog(
           backgroundColor: bgCard,
           title: Text(AppStrings.get(context, 'feature_locked')),
           content: Text(AppStrings.get(context, 'platinum_only')),
           actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.get(context, 'cancel')))],
         )
       );
       return;
    }

    TimeOfDay selectedTime = TimeOfDay.now();
    List<String> selectedDays = [];
    String selectedAction = 'OPEN'; // 👈 الإضافة الأولى (الافتراضي هو أمر الفتح)
    final List<String> weekDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bgCard,
              title: Text(AppStrings.get(context, 'schedule_auto')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("${AppStrings.get(context, 'time')}: ${selectedTime.format(context)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.access_time, color: widget.theme.primary),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const Divider(),
                  // 👇👇 الإضافة الثانية تبدأ من هنا 👇👇
                  Text(AppStrings.get(context, 'control'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: Text(AppStrings.get(context, 'cmd_open'), style: TextStyle(color: selectedAction == 'OPEN' ? Colors.white : Colors.grey)),
                        selected: selectedAction == 'OPEN',
                        selectedColor: neonGreen.withValues(alpha: 0.3),
                        checkmarkColor: Colors.white,
                        side: BorderSide(color: selectedAction == 'OPEN' ? neonGreen : Colors.white10),
                        onSelected: (bool selected) {
                          setDialogState(() => selectedAction = 'OPEN');
                        },
                      ),
                      ChoiceChip(
                        label: Text(AppStrings.get(context, 'cmd_close'), style: TextStyle(color: selectedAction == 'CLOSE' ? Colors.white : Colors.grey)),
                        selected: selectedAction == 'CLOSE',
                        selectedColor: dangerColor.withValues(alpha: 0.3),
                        checkmarkColor: Colors.white,
                        side: BorderSide(color: selectedAction == 'CLOSE' ? dangerColor : Colors.white10),
                        onSelected: (bool selected) {
                          setDialogState(() => selectedAction = 'CLOSE');
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  // 👆👆 الإضافة الثانية تنتهي هنا 👆👆
                  Text(AppStrings.get(context, 'repeat_days'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    children: List.generate(weekDays.length, (index) {
                      bool isSelected = selectedDays.contains(weekDays[index]);
                      return ChoiceChip(
                        label: Text(weekDays[index]), 
                        selected: isSelected,
                        selectedColor: widget.theme.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                        onSelected: (bool selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedDays.add(weekDays[index]); 
                            } else {
                              selectedDays.remove(weekDays[index]);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get(context, 'cancel'))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.theme.primary),
                  onPressed: () {
                    if (selectedDays.isEmpty) {
                      showFancyToast(AppStrings.get(context, 'select_day_error'), isError: true);
                      return;
                    }
                    Navigator.pop(context);
                   saveSchedule(selectedTime, selectedDays, selectedAction); // 👈 الإضافة الثالثة
                  }, 
                  child: Text(AppStrings.get(context, 'save_schedule'), style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveSchedule(TimeOfDay time, List<String> days, String actionType) async {
    final String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    final String daysString = days.join(","); 
    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'add_schedule',
          'gate_id': widget.gate['id'].toString(),
          'user_id': widget.userId,
          'sch_action': actionType,
          'time': formattedTime,
          'days': daysString
        },
      );
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['success'] == true) {
        showFancyToast(AppStrings.get(context, 'success_schedule'));
      } else {
        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
    }
  }

  void showActiveSchedulesDialog() async {
    // إظهار دائرة التحميل
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));
    
    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {'action': 'get_gate_schedules', 'gate_id': widget.gate['id'].toString()},
      );

      if (!mounted) return;
      Navigator.pop(context); // إخفاء التحميل

      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        List<dynamic> schedules = data['data'];
        
        showDialog(
          context: context,
          builder: (ctx) => StatefulBuilder( 
            builder: (context, setStateList) {
              return AlertDialog(
                backgroundColor: bgCard,
                title: Text(AppStrings.get(context, 'scheduled_tasks')),
                content: schedules.isEmpty 
                  ? Text(AppStrings.get(context, 'no_active_schedules'), style: const TextStyle(color: Colors.white70)) 
                  : SizedBox(
                      width: double.maxFinite, 
                      height: 300,
                      child: ListView.separated(
                        itemCount: schedules.length,
                        separatorBuilder: (c, i) => const Divider(color: Colors.white10),
                        itemBuilder: (context, index) {
                          // هنا التصحيح: التعامل مع بيانات الجدول وليس المستخدمين
                          final item = schedules[index];
                          
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.access_alarm, color: widget.theme.primary),
                            title: Text(
                              item['run_time'].toString().substring(0, 5), // عرض الوقت (00:00)
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: widget.theme.primary)
                            ),
                            subtitle: Text(
                              "${item['days']}",
                              style: const TextStyle(color: Colors.grey, fontSize: 12)
                            ),
                            trailing: IconButton(
                              icon: const FaIcon(FontAwesomeIcons.trash, size: 16, color: dangerColor),
                              onPressed: () async {
                                // استدعاء دالة حذف الجدول
                                await deleteSchedule(item['id'].toString());
                                // تحديث القائمة محلياً
                                setStateList(() { schedules.removeAt(index); });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx), 
                    child: Text(AppStrings.get(context, 'close'))
                  )
                ],
              );
            }
          ),
        );
      }
    } catch (e) {
      if (mounted) { 
        Navigator.pop(context); 
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true); 
      }
    }
  }
  // دالة لتبديل حالة المستخدم (تفعيل / تجميد)

  Future<void> deleteSchedule(String schId) async {
    try {
      await http.post(Uri.parse(domainUrl), body: {'action': 'delete_schedule', 'schedule_id': schId});
    } catch (e) { /* ignore */ }
  }
  // دالة لتبديل حالة المستخدم (تفعيل / تجميد)
Future<void> toggleUserStatus(String targetId, bool currentStatusIsActive) async {
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');
    
    // تحديد الحالة الجديدة بناءً على الوضع الحالي
    String newStatus = currentStatusIsActive ? 'pending' : 'active';

    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'update_member_status',
          'user_id': widget.userId,
          'target_id': targetId,
          'gate_id': widget.gate['id'].toString(),
          'new_status': newStatus,
          'uuid': myUuid ?? '',
        },
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      // ... داخل toggleUserStatus
      if (data['success'] == true) {
        // 🛑 التعديل هنا: استخدام الترجمة المحلية بدلاً من رسالة السيرفر
        showFancyToast(AppStrings.get(context, 'success_op')); 
        fetchUsers(); 
      } else {

        showFancyToast(data['message'], isError: true);
      }
    } catch (e) {
      if (mounted) showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
    }
}
Future<void> triggerPlatinumGate() async {
    if (isBluetoothLoading) return;
    setState(() => isBluetoothLoading = true);

    showFancyToast(AppStrings.get(context, 'opening_internet'));

    bool mqttSuccess = false;
    final prefs = await SharedPreferences.getInstance();
    String? myUuid = prefs.getString('gate_app_uuid');

    try {
      // 1. محاولة الفتح عبر الإنترنت مع مهلة قصيرة (مثلاً 3 ثواني) حتى لا يطول الانتظار
      final response = await http.post(
        Uri.parse(domainUrl),
        body: {
          'action': 'toggle_gate',
          'gate_id': widget.gate['id'].toString(),
          'uuid': myUuid ?? '',
          'user_id': widget.userId,
        },
      ).timeout(const Duration(seconds: 3)); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          mqttSuccess = true;
          if (mounted) {
            fetchLogs();
            showFancyToast(AppStrings.get(context, 'success_op'));
          }
        }
      }
    } catch (e) {
      // تم التجاهل عن قصد: في حال وجود خطأ بالشبكة أو انتهى الوقت، سينتقل الكود للبلوتوث
    }

    // 2. التحويل التلقائي للبلوتوث في حال فشل الإنترنت
   // 2. التحويل التلقائي للبلوتوث في حال فشل الإنترنت
    // التحويل التلقائي للبلوتوث في حال فشل الإنترنت (للموبايل فقط)
    if (!mqttSuccess && mounted) {
      if (kIsWeb) {
        // نحن على الويب، نكتفي بإظهار خطأ اتصال ولا نفتح البلوتوث
        showFancyToast(AppStrings.get(context, 'connection_error'), isError: true);
        setState(() => isBluetoothLoading = false);
      } else {
        // نحن على الموبايل، نفتح البلوتوث
        showFancyToast(AppStrings.get(context, 'network_unavailable_fallback'));
        setState(() => isBluetoothLoading = false);
        await triggerBluetoothGate();
      }
    } else {
      if (mounted) setState(() => isBluetoothLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.userRole == 'admin';
    final theme = widget.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text(currentGateName, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: bgBody,
        iconTheme: IconThemeData(color: theme.primary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primary,
          labelColor: theme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: const FaIcon(FontAwesomeIcons.powerOff), text: AppStrings.get(context, 'control')),
            Tab(icon: const FaIcon(FontAwesomeIcons.users), text: isAdmin ? AppStrings.get(context, 'members') : AppStrings.get(context, 'my_info')),
            Tab(icon: const FaIcon(FontAwesomeIcons.clock), text: AppStrings.get(context, 'logs')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
         // 1. Control
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // ==========================================
                  // أزرار التحكم المخصصة حسب الباقة
                  // ==========================================
                  
                  // 1. باقة Starter (بلوتوث فقط)
                  if (widget.gate['plan_type'] == 'starter')
                    BouncingButton(
                      onTap: isBluetoothLoading ? () {} : triggerBluetoothGate,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isBluetoothLoading ? 0.4 : 1.0, 
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            color: bgCard, 
                            border: Border.all(color: theme.primary, width: 4), 
                            boxShadow: [
                              if (!isBluetoothLoading)
                                BoxShadow(color: theme.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 2)
                            ]
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bluetooth, size: 30, color: theme.primary),
                                const SizedBox(height: 8),
                                FaIcon(FontAwesomeIcons.powerOff, size: 45, color: theme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  isBluetoothLoading ? AppStrings.get(context, 'sending') : AppStrings.get(context, 'tap_to_open'), 
                                  style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: theme.primary.withValues(alpha: 0.7)),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )

                  // 2. باقة Gold (إنترنت/MQTT فقط)
                 // 2. باقة Gold (إنترنت/MQTT فقط)
                  else if (widget.gate['plan_type'] == 'gold')
                    BouncingButton(
                      onTap: isBluetoothLoading ? () {} : triggerGate, // 🔒 منع الاستجابة للضغط أثناء التحميل
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isBluetoothLoading ? 0.4 : 1.0, // 🔒 تخفيف الشفافية لإعلام المستخدم
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            color: bgCard, 
                            border: Border.all(color: theme.primary, width: 4), 
                            boxShadow: [
                              // 🔒 إخفاء توهج الزر أثناء التحميل
                              if (!isBluetoothLoading)
                                BoxShadow(color: theme.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 2)
                            ]
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi, size: 30, color: neonGreen),
                                const SizedBox(height: 8),
                                FaIcon(FontAwesomeIcons.powerOff, size: 45, color: theme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  // 🔒 تغيير الكلمة إلى "جاري الإرسال"
                                  isBluetoothLoading ? AppStrings.get(context, 'sending') : AppStrings.get(context, 'tap_to_open'), 
                                  style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: theme.primary.withValues(alpha: 0.7)),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  // 3. باقة Platinum (الزر المدمج الذكي - نت ثم بلوتوث)
                  else
                    BouncingButton(
                      onTap: isBluetoothLoading ? () {} : triggerPlatinumGate,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isBluetoothLoading ? 0.4 : 1.0, 
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            color: bgCard, 
                            border: Border.all(color: theme.primary, width: 4), 
                            boxShadow: [
                              if (!isBluetoothLoading)
                                BoxShadow(color: theme.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 2)
                            ]
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wifi, size: 24, color: neonGreen),
                                    const SizedBox(width: 5),
                                    Icon(Icons.sync_alt, size: 16, color: theme.primary.withValues(alpha: 0.5)),
                                    const SizedBox(width: 5),
                                    Icon(Icons.bluetooth, size: 24, color: theme.primary),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                FaIcon(FontAwesomeIcons.powerOff, size: 45, color: theme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  isBluetoothLoading ? AppStrings.get(context, 'sending') : AppStrings.get(context, 'tap_to_open'), 
                                  style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: theme.primary.withValues(alpha: 0.7)),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                 // ==========================================
                  // 4. زر القفل الخاص بباقة البلاتينيوم (للمدير فقط)
                  // ==========================================
                  // ==========================================
                  // 4. زر القفل الخاص بباقة البلاتينيوم (للمدير فقط)
                  // ==========================================
                  if (isAdmin && widget.gate['plan_type'] == 'platinum') ...[
                    const SizedBox(height: 25), // مسافة بين الزر الرئيسي وزر القفل
                    
                    Builder(
                      builder: (context) {
                        // تحديد الألوان والأيقونات والنصوص بناءً على حالة القفل
                        Color lockColor = isLocked ? dangerColor : Colors.amber;
                        FaIconData lockIcon = isLocked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen;
                        String lockText = isLocked ? AppStrings.get(context, 'unlock_gate') : AppStrings.get(context, 'lock_gate');
                        
                        return BouncingButton(
                          onTap: isLockLoading || isBluetoothLoading 
    ? () {} 
    : () {
        if (!isLocked) {
          // إذا كانت البوابة غير مقفلة (ويحاول قفلها)، أظهر التحذير أولاً
          showLockWarningDialog();
        } else {
          // إذا كانت مقفلة بالفعل (ويحاول فك القفل)، نفذ الأمر فوراً بدون تحذير
          toggleGateLock();
        }
      },
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isLockLoading ? 0.4 : 1.0,
                            child: AnimatedContainer( // استخدام AnimatedContainer لتغيير اللون بنعومة
                              duration: const Duration(milliseconds: 300),
                              width: 80, 
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bgCard,
                                border: Border.all(color: lockColor, width: 2), 
                                boxShadow: [
                                  if (!isLockLoading)
                                    BoxShadow(color: lockColor.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 1)
                                ]
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLockLoading 
                                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: lockColor))
                                    : FaIcon(lockIcon, size: 24, color: lockColor),
                                  const SizedBox(height: 5),
                                  Text(
                                    isLockLoading ? AppStrings.get(context, 'sending') : lockText,
                                    style: TextStyle(fontSize: 10, color: lockColor, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                  const SizedBox(height: 45), // مسافة مريحة قبل أزرار الجدولة

                  // ==========================================
                  // أزرار الجدولة والسجل
                  // ==========================================
                  OutlinedButton.icon(
                    onPressed: showScheduleDialog, 
                    icon: Icon(Icons.calendar_month, color: theme.primary),
                    label: Text(AppStrings.get(context, 'schedule_auto'), style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primary), 
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.gate['plan_type'] == 'platinum') 
                    TextButton.icon(
                      onPressed: showActiveSchedulesDialog, 
                      icon: const Icon(Icons.list, color: Colors.grey),
                      label: Text(AppStrings.get(context, 'active_schedules'), style: const TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            ),
          ),
          // 2. Members
        
          widget.gate['plan_type'] == 'starter'
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 15),
                    Text(AppStrings.get(context, 'feature_locked'), style: TextStyle(color: theme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(AppStrings.get(context, 'starter_internet_required'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              )
            : isAdmin
                ? (isLoadingUsers 
                ? const Center(child: CircularProgressIndicator()) 
                : ListView.separated(
                    padding: const EdgeInsets.all(15),
                    itemCount: users.length,
                    separatorBuilder: (c, i) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
  final user = users[index];
  
  // تحويل القيم لنصوص لضمان المقارنة الصحيحة
  String myIdStr = widget.userId.toString();
  String userIdStr = user['id'].toString();
  bool isMe = (userIdStr == myIdStr);
  
  // استقبال الحالة
  String status = user['status']?.toString() ?? 'pending';
  bool isActive = status == 'active';
  bool isPending = status == 'pending';

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: bgCard,
      borderRadius: BorderRadius.circular(12),
      // استخدام withValues للإطار
      border: isPending ? Border.all(color: Colors.amber.withValues(alpha: 0.5)) : null,
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isActive 
            ? widget.theme.primary.withValues(alpha: 0.2) 
            : Colors.grey.withValues(alpha: 0.2),
        child: FaIcon(
          user['role'] == 'admin' ? FontAwesomeIcons.userTie : FontAwesomeIcons.user,
          size: 14,
          color: isActive ? widget.theme.primary : Colors.grey,
        ),
      ),

      title: Text(
        user['name'],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.white60,
        ),
      ),
      
      subtitle: isPending 
        ? Text(AppStrings.get(context, 'pending'), style: const TextStyle(fontSize: 10, color: Colors.amber))
        : null,

      trailing: !isMe
          ? SizedBox(
              width: 140, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // --- السويتش (Toggle) ---
                  SizedBox(
                    width: 40,
                    height: 25, // ارتفاع مناسب
                    child: Switch(
                      value: isActive,
                      activeColor: neonGreen,
                      activeTrackColor: neonGreen.withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                      onChanged: (val) {
                         toggleUserStatus(user['id'].toString(), isActive);
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 8),

                  // --- زر نقل الملكية (للمفعلين فقط) ---
                  if (isActive)
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: bgCard,
                            title: Text(AppStrings.get(context, 'transfer_admin')),
                            content: Text(AppStrings.get(context, 'lose_privileges')),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text(AppStrings.get(context, 'cancel'))),
                              TextButton(
                                onPressed: (){Navigator.pop(ctx); transferOwnership(user['id'].toString());}, 
                                child: Text(AppStrings.get(context, 'confirm'), style: const TextStyle(color: Colors.amber))
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: FaIcon(FontAwesomeIcons.crown, size: 16, color: Colors.amber),
                      ),
                    ),

                  // --- زر الحذف (للجميع) ---
                  InkWell(
                    onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: bgCard,
                            title: Text(AppStrings.get(context, 'delete_user')),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text(AppStrings.get(context, 'cancel'))),
                              TextButton(
                                onPressed: (){Navigator.pop(ctx); deleteUser(user['id'].toString());}, 
                                child: Text(AppStrings.get(context, 'delete'), style: const TextStyle(color:Colors.red))
                              ),
                            ],
                          ),
                        );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: FaIcon(FontAwesomeIcons.trash, size: 16, color: dangerColor),
                    ),
                  ),
                ],
              ),
            )
          : null, // لا شيء للمدير (أنا)
    ),
  );
},
                  ))
            : Center(child: Text(AppStrings.get(context, 'only_admin'), style: const TextStyle(color: Colors.grey))),
         
            // 3. Logs
          
          Builder(
            builder: (context) {
              // 🔒 إضافة جديدة: منع باقة الستارتر من رؤية السجل لأنه يتطلب إنترنت
              if (widget.gate['plan_type'] == 'starter') {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 15),
                      Text(AppStrings.get(context, 'feature_locked'), style: TextStyle(color: theme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(AppStrings.get(context, 'starter_logs_locked'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                );
              }

              // 🔒 التعديل الجذري: منع أي مستخدم ليس مديراً من رؤية السجل (في كل الباقات)
              // 🔒 التعديل الجذري: منع أي مستخدم ليس مديراً من رؤية السجل (في كل الباقات)
              if (widget.userRole != 'admin') {
                return Center(
                  child: Text(
                    AppStrings.get(context, 'logs_locked'), 
                    style: const TextStyle(color: Colors.grey, fontSize: 16)
                  )
                );
              }
              
              // باقي الكود يعرض السجل للمدير فقط...
              return Column(
                children: [
                   if (widget.gate['plan_type'] == 'platinum')
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              style: OutlinedButton.styleFrom(foregroundColor: theme.primary, side: BorderSide(color: theme.primary)),
                              label: Text(selectedDate == null ? AppStrings.get(context, 'pick_date') : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"),
                              onPressed: pickDateAndRefresh,
                            ),
                          ),
                          if (selectedDate != null)
                            IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () { setState(() => selectedDate = null); fetchLogs(); })
                        ],
                      ),
                    ),
                   Expanded(
                    child: isLoadingLogs 
                      ? const Center(child: CircularProgressIndicator()) 
                      : logs.isEmpty 
                        ? Center(child: Text(AppStrings.get(context, 'no_logs'), style: const TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              String time = log['timestamp'].toString().substring(5, 16);
                              String actionKey = log['action'] == 'OPEN_CMD' ? 'cmd_open' : (log['action'] == 'CLOSE_CMD' ? 'cmd_close' : 'cmd_toggle');
                              return ListTile(
                                leading: const FaIcon(FontAwesomeIcons.clock, color: Colors.grey, size: 16),
                                title: Text(log['user_name'] ?? AppStrings.get(context, 'unknown')),
                                subtitle: Text(AppStrings.get(context, actionKey), style: TextStyle(color: log['action'].toString().contains('OPEN') ? neonGreen : Colors.white70)),
                                trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. كلاسات مساعدة
// ==========================================
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BouncingButton({super.key, required this.child, required this.onTap});
  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(_controller); 
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _controller.forward(); SystemSound.play(SystemSoundType.click); HapticFeedback.lightImpact(); },
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // 👈 1. القفل السحري لمنع القراءة المزدوجة
  bool _isScanned = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get(context, 'scan_qr'))),
      body: MobileScanner(
        onDetect: (capture) {
          // 👈 2. إذا تم مسح الكود مسبقاً، تجاهل أي قراءات إضافية فوراً
          if (_isScanned) return; 

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              
              // 👈 3. تفعيل القفل حتى لا يتم استدعاء pop مرة أخرى
              setState(() {
                _isScanned = true; 
              });

              // إغلاق الشاشة وإرجاع الكود بأمان
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // معرفة لغة الجهاز الحالية
    String lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTrans(lang, 'title')),
        backgroundColor: bgBody,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              _getTrans(lang, 'intro_title'),
              _getTrans(lang, 'intro_body'),
            ),
            _buildSection(
              _getTrans(lang, 'data_title'),
              _getTrans(lang, 'data_body'),
            ),
            _buildSection(
              _getTrans(lang, 'usage_title'),
              _getTrans(lang, 'usage_body'),
            ),
            _buildSection(
              _getTrans(lang, 'delete_title'),
              _getTrans(lang, 'delete_body'),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Smart Gate App \n© 2026",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لجلب النص حسب اللغة
  String _getTrans(String lang, String key) {
    // النصوص العربية
    if (lang == 'ar') {
      switch (key) {
        case 'title': return "سياسة الخصوصية";
        case 'intro_title': return "مقدمة";
        case 'intro_body': return "نحن نأخذ خصوصيتك على محمل الجد. يوضح هذا المستند البيانات التي نجمعها وكيفية استخدامها في تطبيق 'بوابتي الذكية'.";
        case 'data_title': return "البيانات التي نجمعها";
        case 'data_body': return "1. معرف الجهاز (UUID): للتعرف على جهازك ومنع الوصول غير المصرح به.\n2. الاسم: لتمييز المستخدمين في سجلات الدخول.\n3. الكاميرا: تستخدم فقط لمسح كود QR لإضافة البوابات.";
        case 'usage_title': return "كيف نستخدم بياناتك";
        case 'usage_body': return "نستخدم البيانات فقط لتأمين منزلك والتحكم في البوابة. لا نشارك بياناتك مع أي طرف ثالث.";
        case 'delete_title': return "حذف الحساب";
        case 'delete_body': return "لديك الحق في حذف حسابك وبياناتك نهائياً من داخل التطبيق عبر خيار 'حذف الحساب' في الإعدادات.";
      }
    }
    // اللغة الصينية (Chinese)
    else if (lang == 'zh') {
      switch (key) {
        case 'title': return "隐私政策";
        case 'intro_title': return "简介";
        case 'intro_body': return "我们非常重视您的隐私。本文档说明了我们在“智能大门”应用中收集的数据及其使用方式。";
        case 'data_title': return "我们收集的数据";
        case 'data_body': return "1. 设备标识符 (UUID)：用于识别您的设备并防止未经授权的访问。\n2. 姓名：用于在访问记录中区分用户。\n3. 相机：仅用于扫描二维码以添加大门。";
        case 'usage_title': return "我们如何使用您的数据";
        case 'usage_body': return "我们仅将数据用于保护您的家庭安全和控制大门。我们不会与任何第三方分享您的数据。";
        case 'delete_title': return "删除账户";
        case 'delete_body': return "您有权通过设置中的“删除账户”选项，在应用内永久删除您的账户和数据。";
      }
    }
    // النصوص الأوردو (Urdu)
    else if (lang == 'ur') {
      switch (key) {
        case 'title': return "رازداری کی پالیسی";
        case 'intro_title': return "تعارف";
        case 'intro_body': return "ہم آپ کی رازداری کو سنجیدگی سے لیتے ہیں۔ یہ دستاویز بتاتی ہے کہ ہم 'اسمارٹ گیٹ' ایپ میں کون سا ڈیٹا جمع کرتے ہیں اور اسے کیسے استعمال کرتے ہیں۔";
        case 'data_title': return "ڈیٹا جو ہم جمع کرتے ہیں";
        case 'data_body': return "1. ڈیوائس آئی ڈی (UUID): آپ کے آلے کی شناخت اور غیر مجاز رسائی کو روکنے کے لیے۔\n2. نام: لاگ ان ریکارڈ میں صارفین کی شناخت کے لیے۔\n3. کیمرا: صرف گیٹس شامل کرنے کے لیے QR کوڈ اسکین کرنے کے لیے استعمال ہوتا ہے۔";
        case 'usage_title': return "ہم آپ کا ڈیٹا کیسے استعمال کرتے ہیں";
        case 'usage_body': return "ہم ڈیٹا کا استعمال صرف آپ کے گھر کو محفوظ بنانے اور گیٹ کو کنٹرول کرنے کے لیے کرتے ہیں۔ ہم آپ کا ڈیٹا کسی تیسرے فریق کے ساتھ شیئر نہیں کرتے ہیں۔";
        case 'delete_title': return "اکاؤنٹ ڈیلیٹ کریں";
        case 'delete_body': return "آپ کو ترتیبات میں 'اکاؤنٹ ڈیلیٹ کریں' کے آپشن کے ذریعے ایپ کے اندر سے اپنے اکاؤنٹ اور ڈیٹا کو مستقل طور پر حذف کرنے کا حق حاصل ہے۔";
      }
    }
    
    // الإنجليزية (الافتراضي)
    switch (key) {
      case 'title': return "Privacy Policy";
      case 'intro_title': return "Introduction";
      case 'intro_body': return "We take your privacy seriously. This document explains what data we collect and how we use it in 'Smart Gate' app.";
      case 'data_title': return "Data Collection";
      case 'data_body': return "1. Device ID (UUID): To identify your device and prevent unauthorized access.\n2. Name: To identify users in entry logs.\n3. Camera: Used solely for scanning QR codes to add gates.";
      case 'usage_title': return "Data Usage";
      case 'usage_body': return "We use data solely to secure your home and control the gate. We do not share your data with any third parties.";
      case 'delete_title': return "Account Deletion";
      case 'delete_body': return "You have the right to permanently delete your account and data from within the app via the 'Delete Account' option in settings.";
      default: return "";
    }
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: defaultPrimary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }
}
