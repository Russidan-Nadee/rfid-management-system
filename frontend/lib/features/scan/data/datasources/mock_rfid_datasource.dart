// Path: frontend/lib/features/scan/data/datasources/mock_rfid_datasource.dart
import 'dart:math';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class MockRfidDataSource {
  final Random _random = Random();
  final ApiService _apiService = ApiService();

  Future<List<String>> generateAssetNumbers() async {
    try {
      // 1. Get real asset numbers from Backend (3-4 items)
      final realCount = 3 + _random.nextInt(2); // 3 or 4
      final realAssets = await _getRealAssetNumbers(realCount);

      // 2. Generate fake asset numbers (1-2 items)
      final fakeCount = 5 - realAssets.length; // Total should be around 5
      final fakeAssets = _generateFakeAssetNumbers(fakeCount);

      // 3. Combine real and fake assets
      final allAssets = <String>[...realAssets, ...fakeAssets];

      // 4. Shuffle to make it look random
      allAssets.shuffle(_random);

      return allAssets;
    } catch (e) {
      // If API fails, generate all fake assets
      print('Failed to get real assets, generating fake assets: $e');
      return _generateFakeAssetNumbers(5);
    }
  }

  // Get real asset numbers from Backend API
  Future<List<String>> _getRealAssetNumbers(int count) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.assetNumbers,
        queryParams: {'limit': count.toString()},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final assetNumbers = response.data!['asset_numbers'] as List<dynamic>?;
        if (assetNumbers != null) {
          return assetNumbers.map((asset) => asset.toString()).toList();
        }
      }

      throw Exception('Failed to get asset numbers from API');
    } catch (e) {
      throw Exception('API call failed: $e');
    }
  }

  // Generate fake asset numbers with random 4 digits
  List<String> _generateFakeAssetNumbers(int count) {
    final fakeAssets = <String>[];
    final usedNumbers = <String>{};

    for (int i = 0; i < count; i++) {
      String fakeAsset;
      int attempts = 0;

      // Generate unique fake asset number
      do {
        final randomLast4 = _random.nextInt(10000).toString().padLeft(4, '0');
        fakeAsset = '3100005$randomLast4';
        attempts++;
      } while (usedNumbers.contains(fakeAsset) && attempts < 50);

      usedNumbers.add(fakeAsset);
      fakeAssets.add(fakeAsset);
    }

    return fakeAssets;
  }

  // Simulate scanning delay
  Future<void> simulateScanDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }
}
