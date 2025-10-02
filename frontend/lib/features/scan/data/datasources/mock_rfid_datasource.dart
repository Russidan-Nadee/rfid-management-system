// Path: frontend/lib/features/scan/data/datasources/mock_rfid_datasource.dart
import 'dart:async';

class RfidDataSource {
  final List<String> _mockEpcCodes = [
    'E28011606000020000000203',
    'E28011606000020000000378',
    'E28011606000020000000034',
    'E28011606000020000000129',
    'E28011606000020000000240',
    'E28011606000020000000173',
    'E28011606000020000000312',
    'E28011606000020000000258',
    'E28011606000020000000089',
    'E28011606000020000000145',
    'E28011606000020000000323',
    'E28011606000020000000267',
    'E28011606000020000000424',
    'E28011606000020000000462',
    'E28011606000020000000463',
    'E28011606000020000000464',
    'E28011606000020000000465',
    'E28011606000020000000466',
  ];

  RfidDataSource();

  Future<List<String>> generateAssetNumbers() async {
    try {
      // จำลองการ scan ใช้เวลา 3 วินาที
      await Future.delayed(const Duration(seconds: 3));

      // Return mock EPC codes
      return List.from(_mockEpcCodes);
    } catch (e) {
      throw Exception('Mock RFID scan failed: $e');
    }
  }

  Future<void> simulateScanDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
