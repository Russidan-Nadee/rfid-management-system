// Path: frontend/lib/features/scan/presentation/widgets/asset_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../pages/asset_detail_page.dart';
import '../pages/unknown_item_detail_page.dart';

class AssetCard extends StatelessWidget {
  final ScannedItemEntity item;

  const AssetCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(item.status),
                  color: _getStatusColor(item.status),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    if (!item.isUnknown && item.serialNo != null) ...[
                      Text(
                        'Serial: ${item.serialNo}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ] else if (item.isUnknown) ...[
                      Text(
                        'Asset No: ${item.assetNo}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(item.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Arrow
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    if (item.isUnknown) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UnknownItemDetailPage(assetNo: item.assetNo),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AssetDetailPage(item: item)),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'checked':
        return Colors.blue;
      case 'unknown':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'checked':
        return Icons.verified_outlined;
      case 'unknown':
        return Icons.help_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'checked':
        return 'Checked';
      case 'unknown':
        return 'Unknown';
      default:
        return status;
    }
  }
}
