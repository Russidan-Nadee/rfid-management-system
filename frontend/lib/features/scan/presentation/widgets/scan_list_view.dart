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
    final theme = Theme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (scannedItems.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: theme.colorScheme.primary,
      child: Column(
        children: [
          // Header
          _buildHeader(theme),

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

  Widget _buildHeader(ThemeData theme) {
    final totalItems = scannedItems.length;
    final activeItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'a')
        .length;
    final createdItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'c')
        .length;
    final inactiveItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'i')
        .length;
    final unknownItems = scannedItems
        .where((item) => item.status.toLowerCase() == 'unknown')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'RFID Scan Results ($totalItems)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Summary
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (activeItems > 0)
                _buildStatusChip(
                  theme,
                  'Active',
                  activeItems,
                  theme.colorScheme.primary,
                ),
              if (createdItems > 0)
                _buildStatusChip(theme, 'Created', createdItems, Colors.blue),
              if (inactiveItems > 0)
                _buildStatusChip(theme, 'Inactive', inactiveItems, Colors.grey),
              if (unknownItems > 0)
                _buildStatusChip(theme, 'Unknown', unknownItems, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    String label,
    int count,
    Color color,
  ) {
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No scanned items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap the scan button to start scanning RFID tags',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
