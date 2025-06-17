// Path: frontend/lib/features/scan/presentation/widgets/asset_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:frontend/features/scan/presentation/bloc/scan_event.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../pages/asset_detail_page.dart';
import '../pages/create_asset_page.dart';

class AssetCard extends StatelessWidget {
  final ScannedItemEntity item;

  const AssetCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
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
                  color: _getStatusColor(item.status, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(item.status),
                  color: _getStatusColor(item.status, theme),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Asset Number
                    Text(
                      'Asset No: ${item.assetNo}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Status และ Location Row
                    Row(
                      children: [
                        // Status
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status, theme),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusLabel(item.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(item.status, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Location (ถ้ามี)
                        if (item.locationName != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.locationName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow or Create Icon
              Icon(
                item.isUnknown ? Icons.add_circle_outline : Icons.chevron_right,
                color: item.isUnknown
                    ? Colors.green
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // แก้ไข _navigateToDetail method ส่ง location data
  void _navigateToDetail(BuildContext context) async {
    if (item.isUnknown) {
      print('DEBUG: plantCode=${item.plantCode}');
      print('DEBUG: locationCode=${item.locationCode}');
      print('DEBUG: locationName=${item.locationName}');
      // Navigate to Create Asset Page for unknown items พร้อม location data
      final result = await Navigator.of(context).push<ScannedItemEntity>(
        MaterialPageRoute(
          builder: (context) => CreateAssetPage(
            assetNo: item.assetNo,
            plantCode: item.plantCode,
            locationCode: item.locationCode,
            locationName: item.locationName,
          ),
        ),
      );

      // ถ้าสร้าง asset สำเร็จ แล้ว result กลับมา
      if (result != null && context.mounted) {
        context.read<ScanBloc>().add(
          AssetCreatedFromUnknown(createdAsset: result),
        );
      }
    } else {
      // Navigate to Asset Detail Page for existing items
      final scanBloc = context.read<ScanBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssetDetailPage(item: item, scanBloc: scanBloc),
        ),
      );
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'A':
        return theme.colorScheme.primary;
      case 'C':
        return Colors.deepPurple;
      case 'I':
        return Colors.grey;
      case 'UNKNOWN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return Icons.check_circle_outline;
      case 'C':
        return Icons.task_alt;
      case 'I':
        return Icons.disabled_by_default_outlined;
      case 'UNKNOWN':
        return Icons.help_outline;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return 'Active';
      case 'C':
        return 'Checked';
      case 'I':
        return 'Inactive';
      case 'UNKNOWN':
        return 'Unknown';
      default:
        return status;
    }
  }
}
