// Path: frontend/lib/features/scan/presentation/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';

class AssetDetailPage extends StatelessWidget {
  final ScannedItemEntity item;
  final ScanBloc scanBloc;

  const AssetDetailPage({
    super.key,
    required this.item,
    required this.scanBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: scanBloc,
      child: AssetDetailView(item: item),
    );
  }
}

class AssetDetailView extends StatelessWidget {
  final ScannedItemEntity item;

  const AssetDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state is AssetStatusUpdated) {
          Helpers.showSuccess(context, 'Asset marked as checked successfully');
          Navigator.of(context).pop(state.updatedAsset);
        } else if (state is AssetStatusUpdateError) {
          Helpers.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Asset Detail',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 1,
        ),
        backgroundColor: theme.colorScheme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(theme),

              const SizedBox(height: 16),

              // Basic Information
              _buildSectionCard(
                theme: theme,
                title: 'Basic Information',
                icon: Icons.inventory_2_outlined,
                children: [
                  _buildDetailRow(theme, 'Asset Number', item.assetNo),
                  _buildDetailRow(
                    theme,
                    'Description',
                    item.description ?? '-',
                  ),
                  _buildDetailRow(theme, 'Serial Number', item.serialNo ?? '-'),
                  _buildDetailRow(
                    theme,
                    'Inventory Number',
                    item.inventoryNo ?? '-',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quantity Information
              _buildSectionCard(
                theme: theme,
                title: 'Quantity Information',
                icon: Icons.straighten,
                children: [
                  _buildDetailRow(
                    theme,
                    'Quantity',
                    item.quantity != null ? '${item.quantity}' : '-',
                  ),
                  _buildDetailRow(theme, 'Unit', item.unitName ?? '-'),
                ],
              ),

              const SizedBox(height: 16),

              // Creation Information
              _buildSectionCard(
                theme: theme,
                title: 'Creation Information',
                icon: Icons.person_outline,
                children: [
                  _buildDetailRow(
                    theme,
                    'Created By',
                    item.createdByName ?? 'Unknown User',
                  ),
                  _buildDetailRow(
                    theme,
                    'Created Date',
                    item.createdAt != null
                        ? Helpers.formatDateTime(item.createdAt)
                        : '-',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Button (แสดงเฉพาะเมื่อ status = 'A')
              if (item.status.toUpperCase() == 'A')
                _buildActionButton(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    return BlocBuilder<ScanBloc, ScanState>(
      builder: (context, state) {
        final isLoading =
            state is AssetStatusUpdating && state.assetNo == item.assetNo;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => _markAsChecked(context),
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(
              isLoading ? 'Marking as Checked...' : 'Mark as Checked',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  void _markAsChecked(BuildContext context) {
    context.read<ScanBloc>().add(MarkAssetChecked(assetNo: item.assetNo));
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(item.status, theme),
              _getStatusColor(item.status, theme).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(_getStatusIcon(item.status), color: Colors.white, size: 48),

            const SizedBox(height: 12),

            Text(
              item.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(item.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'A':
        return theme.colorScheme.primary;
      case 'C':
        return Colors.green;
      case 'I':
        return Colors.grey;
      case 'UNKNOWN':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return Icons.padding_rounded;
      case 'C':
        return Icons.check_circle;
      case 'I':
        return Icons.disabled_by_default;
      case 'UNKNOWN':
        return Icons.help;
      default:
        return Icons.inventory_2;
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
