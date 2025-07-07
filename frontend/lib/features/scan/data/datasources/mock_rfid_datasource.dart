// Path: frontend/lib/features/scan/data/datasources/mock_rfid_datasource.dart
import 'dart:math';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class MockRfidDataSource {
  final Random _random = Random();
  final ApiService _apiService = ApiService();

  Future<List<String>> generateAssetNumbers() async {
    print('🔍 generateAssetNumbers called');
    try {
      // 1. Get real asset numbers from Backend (20-30 items) - พยายามดึงพร้อม location
      final realCount = 20 + _random.nextInt(11); // 20-30 items
      print('🔍 Trying to get $realCount real assets');
      final realAssets = await _getRealAssetNumbers(realCount);

      // 2. Generate fake asset numbers (2-3 items) for unknown items
      final fakeCount = 2 + _random.nextInt(2); // 2-3 items
      print('🔍 Generating $fakeCount fake assets');
      final fakeAssets = _generateFakeAssetNumbers(fakeCount);

      // 3. Combine real and fake assets
      final allAssets = <String>[...realAssets, ...fakeAssets];
      print(
        '🔍 Total assets: ${allAssets.length} (${realAssets.length} real + ${fakeAssets.length} fake)',
      );

      // 4. Shuffle to make it look random
      allAssets.shuffle(_random);

      return allAssets;
    } catch (e) {
      // If API fails, generate all fake assets
      print('🔍 Failed to get real assets, generating fake assets: $e');
      print('🔍 Generating 25 fake assets as fallback');
      return _generateFakeAssetNumbers(
        25,
      ); // Generate 25 fake assets if API fails
    }
  }

  // Get real asset numbers from Backend API - พยายามดึงพร้อม location
  Future<List<String>> _getRealAssetNumbers(int count) async {
    try {
      print('🔍 Starting API call...');

      // Option 1: พยายามเรียก endpoint ใหม่ที่ส่ง location มาด้วย
      try {
        print('🔍 Option 1: Trying new API with location');
        final response = await _apiService.get<Map<String, dynamic>>(
          ApiConstants.scanAssetsMock,
          queryParams: {
            'limit': count.toString(),
            'include_location': 'true', // บอกให้ส่ง location มาด้วย
          },
          fromJson: (json) => json,
        );

        print('🔍 Option 1 response success: ${response.success}');
        print('🔍 Option 1 response data keys: ${response.data?.keys}');

        if (response.success && response.data != null) {
          final assetData = response.data!['assets'] as List<dynamic>?;
          print('🔍 Option 1 assets found: ${assetData?.length}');
          if (assetData != null) {
            // ถ้า API ส่ง location มาแล้ว ให้เก็บไว้ใน cache
            _cacheLocationData(assetData);
            print(
              '🔍 Option 1 SUCCESS: Returning ${assetData.length} assets with location',
            );
            return assetData
                .map((asset) => asset['asset_no'].toString())
                .toList();
          }
        }
        print('🔍 Option 1 failed: No assets field found');
      } catch (locationError) {
        print('🔍 Option 1 EXCEPTION: $locationError');
      }

      // Option 2: Fallback ใช้ API เดิม (แค่ asset numbers)
      print('🔍 Option 2: Trying fallback API');
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.scanAssetsMock,
        queryParams: {'limit': count.toString()},
        fromJson: (json) => json,
      );

      print('🔍 Option 2 response success: ${response.success}');
      print('🔍 Option 2 response data keys: ${response.data?.keys}');

      if (response.success && response.data != null) {
        final assetNumbers = response.data!['asset_numbers'] as List<dynamic>?;
        print('🔍 Option 2 asset_numbers found: ${assetNumbers?.length}');
        if (assetNumbers != null) {
          print(
            '🔍 Option 2 SUCCESS: Returning ${assetNumbers.length} asset numbers',
          );
          return assetNumbers.map((asset) => asset.toString()).toList();
        }
      }

      print('🔍 Option 2 failed: No asset_numbers field found');
      throw Exception('Failed to get asset numbers from API');
    } catch (e) {
      print('🔍 _getRealAssetNumbers EXCEPTION: $e');
      throw Exception('API call failed: $e');
    }
  }

  // Cache location data สำหรับใช้ใน getAssetDetails
  static final Map<String, Map<String, dynamic>> _locationCache = {};

  void _cacheLocationData(List<dynamic> assetData) {
    print('🔍 Caching location data for ${assetData.length} assets');
    for (final asset in assetData) {
      if (asset is Map<String, dynamic> && asset['asset_no'] != null) {
        _locationCache[asset['asset_no']] = {
          'plant_code': asset['plant_code'],
          'location_code': asset['location_code'],
          'location_name': asset['location_name'],
        };
      }
    }
  }

  // Method สำหรับให้ Repository เรียกใช้เพื่อเอา location data
  static Map<String, dynamic>? getCachedLocationData(String assetNo) {
    return _locationCache[assetNo];
  }

  // Generate fake asset numbers with random 4 digits และ location
  List<String> _generateFakeAssetNumbers(int count) {
    print('🔍 Generating $count fake assets');
    final fakeAssets = <String>[];
    final usedNumbers = <String>{};

    // Real location data
    final realLocations = [
      {'code': '30-OFF-001', 'name': 'Accounting Office'},
      {'code': '30-OFF-002', 'name': 'Finance Office'},
      {'code': '30-OFF-003', 'name': 'HR Office'},
      {'code': '30-OFF-004', 'name': 'Sales Office'},
      {'code': '30-OFF-005', 'name': 'IT Office'},
      {'code': '30-OFF-006', 'name': 'General Affairs Office'},
      {'code': '30-OFF-007', 'name': 'Meeting Room'},
      {'code': '30-OFF-008', 'name': 'Server Room'},
    ];

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

      // สุ่ม location จาก real locations
      final randomLocation =
          realLocations[_random.nextInt(realLocations.length)];

      // Cache fake location data
      _locationCache[fakeAsset] = {
        'plant_code': '30', // Plant code เดียว
        'location_code': randomLocation['code'],
        'location_name': randomLocation['name'],
      };
    }

    print(
      '🔍 Generated fake assets: ${fakeAssets.take(3)}... (${fakeAssets.length} total)',
    );
    return fakeAssets;
  }

  // Simulate scanning delay
  Future<void> simulateScanDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }
}
