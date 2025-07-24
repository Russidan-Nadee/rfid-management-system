// Path: frontend/lib/features/scan/data/datasources/mock_rfid_datasource.dart
import 'dart:async';

class RfidDataSource {
  final List<String> _mockEpcCodes = [
    'E28011700000021ACF3B8A55',
    'E28011700000021ACF3B8A14',
    'E28011606000020000000001',
    'E28011700000021ACF3B8C67',
    'E28011606000020000000045',
    'E28011700000021ACF3B9F23',
  ];

  RfidDataSource();

  Future<List<String>> generateAssetNumbers() async {
    try {
      // จำลองการ scan ใช้เวลา 3 วินาที
      await Future.delayed(Duration(seconds: 3));

      // Return mock EPC codes
      return List.from(_mockEpcCodes);
    } catch (e) {
      throw Exception('Mock RFID scan failed: $e');
    }
  }

  Future<void> simulateScanDelay() async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}
