// Path: frontend/lib/features/scan/data/datasources/rfid_datasource.dart
import 'package:flutter/services.dart';
import 'dart:async';

class RfidDataSource {
  static const MethodChannel _channel = MethodChannel('uhf_scanner');
  final List<String> _scannedTags = [];

  RfidDataSource() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onTagFound':
        String tagData = call.arguments;
        _addTagToList(tagData);
        break;
    }
  }

  void _addTagToList(String tagData) {
    // เหมือนโค้ดต้นฉบับ - เช็คว่ามีแล้วหรือยัง
    bool isExist = _scannedTags.any((tag) => tag.contains(tagData));
    if (!isExist) {
      _scannedTags.add(tagData);
    }
  }

  Future<List<String>> generateAssetNumbers() async {
    try {
      _scannedTags.clear();

      // เปิด UHF ก่อนสแกน - เหมือนโค้ดต้นฉบับ
      await _channel.invokeMethod('powerOn');

      // เริ่มสแกน - เหมือนโค้ดต้นฉบับ
      await _channel.invokeMethod('startContinuousScan');

      // รอสแกน 3 วินาที (แทนการกดหยุดเอง)
      await Future.delayed(const Duration(seconds: 3));

      // หยุดสแกน - เหมือนโค้ดต้นฉบับ
      await _channel.invokeMethod('stopContinuousScan');

      // ปิด UHF - เหมือนโค้ดต้นฉบับ
      await _channel.invokeMethod('powerOff');

      return List.from(_scannedTags);
    } catch (e) {
      throw Exception('RFID scan failed: $e');
    }
  }

  Future<void> simulateScanDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
