import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // 👈 1. إضافة مكتبة التشفير
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// استدعاء ملف الترجمة (تأكد من المسار حسب مشروعك)
import 'main.dart'; 

class BluetoothGateService {
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  // =====================================
  // 🟢 دالة التشفير الجديدة (مدمجة داخل الكلاس)
  // =====================================
  static String _generateSecureCommand(String command, String gateQr) {
    int timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    String dataToHash = "$command$timestamp$gateQr";
    
    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);
    String hashStr = digest.toString();

    return "$command|$timestamp|$hashStr";
  }

  static Future<bool> _checkPermissionsAndBluetooth() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isDenied == true ||
        statuses[Permission.bluetoothConnect]?.isDenied == true) {
      return false;
    }

    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  // =====================================
  // 1. دالة الفتح (Open)
  // =====================================
  static Future<Map<String, dynamic>> openGateFast(BuildContext context, String gateId, String userId, String uuid, String qrCode) async {
    final String msgPermissionError = AppStrings.get(context, 'bluetooth_permission_error');
    final String msgNotInRange = AppStrings.get(context, 'gate_not_in_range');
    final String msgBluetoothError = AppStrings.get(context, 'bluetooth_error');
    final String msgCmdSent = AppStrings.get(context, 'open_cmd_sent');
    final String msgServiceNotFound = AppStrings.get(context, 'service_not_found');
    final String msgConnectionFailed = AppStrings.get(context, 'connection_failed');
    final String msgTechError = AppStrings.get(context, 'tech_error'); 

    bool isReady = await _checkPermissionsAndBluetooth();
    if (!isReady) {
      return {'success': false, 'message': msgPermissionError};
    }

    Completer<Map<String, dynamic>> completer = Completer();
    StreamSubscription<List<ScanResult>>? scanSubscription;
    BluetoothDevice? targetDevice;

    String expectedDeviceName = "DRWZ_PRO_$gateId";

    try {
      scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == expectedDeviceName || r.advertisementData.advName == expectedDeviceName) {
            targetDevice = r.device;
            await FlutterBluePlus.stopScan();
            
            if (!completer.isCompleted) {
              _connectAndWrite(
                targetDevice!, 
                userId, 
                uuid, 
                qrCode, 
                completer, 
                msgCmdSent, 
                msgServiceNotFound, 
                msgConnectionFailed,
                msgTechError, 
                "CMD:OPEN" // 👈 التعديل: إزالة النقطتين الرأسيتين ليتوافق مع فاصل التشفير |
              );
            }
            break; 
          }
        }
      });

      await FlutterBluePlus.startScan(
        withNames: [expectedDeviceName], 
        timeout: const Duration(seconds: 2) 
      );

      Future.delayed(const Duration(seconds: 15), () { 
        if (!completer.isCompleted) {
          scanSubscription?.cancel();
          completer.complete({'success': false, 'message': msgNotInRange});
        }
      });

      return await completer.future;

    } catch (e) {
      return {'success': false, 'message': msgBluetoothError};
    } finally {
      scanSubscription?.cancel();
    }
  }

  // =====================================
  // 2. دالة القفل (Toggle Lock)
  // =====================================
  static Future<Map<String, dynamic>> toggleLockFast(BuildContext context, String gateId, String userId, String uuid, String qrCode) async {
    final String msgPermissionError = AppStrings.get(context, 'bluetooth_permission_error');
    final String msgNotInRange = AppStrings.get(context, 'gate_not_in_range');
    final String msgBluetoothError = AppStrings.get(context, 'bluetooth_error');
    final String msgCmdSent = AppStrings.get(context, 'lock_cmd_sent'); 
    final String msgServiceNotFound = AppStrings.get(context, 'service_not_found');
    final String msgConnectionFailed = AppStrings.get(context, 'connection_failed');
    final String msgTechError = AppStrings.get(context, 'tech_error'); 

    bool isReady = await _checkPermissionsAndBluetooth();
    if (!isReady) {
      return {'success': false, 'message': msgPermissionError};
    }

    Completer<Map<String, dynamic>> completer = Completer();
    StreamSubscription<List<ScanResult>>? scanSubscription;
    BluetoothDevice? targetDevice;

    String expectedDeviceName = "DRWZ_PRO_$gateId";

    try {
      scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == expectedDeviceName || r.advertisementData.advName == expectedDeviceName) {
            targetDevice = r.device;
            await FlutterBluePlus.stopScan();
            
            if (!completer.isCompleted) {
              _connectAndWrite(
                targetDevice!, 
                userId, 
                uuid, 
                qrCode, 
                completer, 
                msgCmdSent, 
                msgServiceNotFound, 
                msgConnectionFailed,
                msgTechError, 
                "CMD:TOGGLE_LOCK" // 👈 التعديل: إزالة النقطتين الرأسيتين ليتوافق مع فاصل التشفير |
              );
            }
            break; 
          }
        }
      });

      await FlutterBluePlus.startScan(
        withNames: [expectedDeviceName], 
        timeout: const Duration(seconds: 2) 
      );

      Future.delayed(const Duration(seconds: 15), () { 
        if (!completer.isCompleted) {
          scanSubscription?.cancel();
          completer.complete({'success': false, 'message': msgNotInRange});
        }
      });

      return await completer.future;

    } catch (e) {
      return {'success': false, 'message': msgBluetoothError};
    } finally {
      scanSubscription?.cancel();
    }
  }

  // =====================================
  // 3. دالة الاتصال والكتابة المشتركة
  // =====================================
  static Future<void> _connectAndWrite(
      BluetoothDevice device, 
      String userId, 
      String uuid, 
      String qrCode, 
      Completer completer,
      String msgCmdSent,
      String msgServiceNotFound,
      String msgConnectionFailed,
      String msgTechError,
      String commandPrefix 
      ) async { 
        
    try {
      try {
        await device.disconnect();
      } catch (e) {}
      await Future.delayed(const Duration(milliseconds: 100));

     await device.connect(
        license: License.free, // 👈 تم مسح // ليعود السطر للعمل
        autoConnect: false, 
        timeout: const Duration(seconds: 10)
      );

      await Future.delayed(const Duration(milliseconds: 300));

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
              writeCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (writeCharacteristic != null) {
        // 👈 التعديل الأهم هنا: إيقاف السطر القديم وتفعيل التشفير
        // السطر القديم: String payload = "$commandPrefix$qrCode";
        
        // توليد الأمر المشفر المنيع
        String payload = _generateSecureCommand(commandPrefix, qrCode);

        List<int> bytes = utf8.encode(payload);

        await writeCharacteristic.write(bytes, withoutResponse: false);
        
        if (!completer.isCompleted) {
          completer.complete({'success': true, 'message': msgCmdSent});
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete({'success': false, 'message': msgServiceNotFound});
        }
      }

    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete({'success': false, 'message': "$msgTechError: ${e.toString()}"});
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        await device.disconnect();
      } catch (e) {}
    }
  }
}