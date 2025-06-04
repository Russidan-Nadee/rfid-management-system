// Path: frontend/lib/features/scan/data/datasources/mock_rfid_datasource.dart
import 'dart:math';

class MockRfidDataSource {
  final Random _random = Random();

  // Sample real asset numbers (these should exist in database)
  final List<String> _realAssetNumbers = [
    'ITM089',
    'ITM054',
    'ITM059',
    'ITM103',
    'ITM113',
    'AST001',
    'AST002',
    'AST003',
    'AST004',
    'AST005',
  ];

  Future<List<String>> generateAssetNumbers() async {
    final List<String> result = [];

    // Add 3-4 real asset numbers
    final realCount = 3 + _random.nextInt(2); // 3 or 4
    final shuffledReal = List<String>.from(_realAssetNumbers)..shuffle(_random);

    for (int i = 0; i < realCount && i < shuffledReal.length; i++) {
      result.add(shuffledReal[i]);
    }

    // Add 1 fake asset number
    final fakeAssetNo =
        'FAKE${_random.nextInt(9999).toString().padLeft(4, '0')}';
    result.add(fakeAssetNo);

    // Shuffle the final result
    result.shuffle(_random);

    return result;
  }

  // Simulate scanning delay
  Future<void> simulateScanDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }
}
