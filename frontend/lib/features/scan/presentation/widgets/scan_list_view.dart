// Path: frontend/lib/features/scan/presentation/widgets/scan_list_view.dart
import 'package:flutter/material.dart';
import '../../domain/entities/scanned_item_entity.dart';
import 'asset_card.dart';

class ScanListView extends StatelessWidget {
  final List<ScannedItemEntity> scannedItems;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const ScanListView({
    super.key,
    required this.scannedItems,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scannedItems.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // List
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: scannedItems.length,
              itemBuilder: (context, index) {
                return AssetCard(item: scannedItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalItems = scannedItems.length;
    final availableItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'available')
        .length;
    final checkedItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'checked')
        .length;
    final unknownItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'unknown')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                'หลกาสสถานแท RFID ($totalItems)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Summary
          Row(
            children: [
              _buildStatusChip('Available', availableItems, Colors.green),
              const SizedBox(width: 8),
              _buildStatusChip('Checked', checkedItems, Colors.blue),
              const SizedBox(width: 8),
              _buildStatusChip('Unknown', unknownItems, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label ($count)',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),

          const SizedBox(height: 16),

          Text(
            'No scanned items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap the scan button to start scanning RFID tags',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
