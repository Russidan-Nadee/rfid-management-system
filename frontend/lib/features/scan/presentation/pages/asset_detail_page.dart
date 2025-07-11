// Path: frontend/lib/features/scan/presentation/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
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
        // ตรวจสอบว่า asset ถูก update แล้วหรือยัง
        if (state is ScanSuccess) {
          final updatedItem = state.scannedItems.firstWhere(
            (scanItem) =>
                scanItem.assetNo ==
                item.assetNo, // ✅ แก้ไข bug: เปลี่ยนจาก item เป็น scanItem
            orElse: () => item,
          );

          // ถ้า status เปลี่ยนจาก A เป็น C แสดงว่า update สำเร็จ
          if (item.status.toUpperCase() == 'A' &&
              updatedItem.status.toUpperCase() == 'C') {
            // แสดง success message
            Helpers.showSuccess(
              context,
              'Asset marked as checked successfully',
            );
            // Pop กลับไปหน้า scan list
            Navigator.of(context).pop(updatedItem);
          }
        } else if (state is AssetStatusUpdateError) {
          // แสดง error message
          Helpers.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Asset Detail',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .darkText // Dark Mode: สีขาว
                  : AppColors.primary, // Light Mode: สีน้ำเงิน
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors
                    .darkText // Dark Mode: สีขาว
              : AppColors.primary, // Light Mode: สีน้ำเงิน
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(
                alpha: 0.8,
              ) // Dark Mode: เหมือน Scan Page
            : theme.colorScheme.background, // Light Mode: เดิม
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? _buildDesktopLayout(context, theme)
                  : _buildMobileLayout(context, theme),
            );
          },
        ),
      ),
    );
  }

  // Desktop Layout (2x3 Grid)
  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Row 1: Status Card + Basic Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusCard(theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildBasicInfoSection(theme)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 2: Location Info + Quantity Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLocationInfoSection(theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildQuantityInfoSection(theme)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 3: Scan Activity + Creation Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildScanActivitySection(theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildCreationInfoSection(theme)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Button (Full Width Center)
        if (item.status.toUpperCase() == 'A')
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildActionButton(context, theme),
            ),
          ),
      ],
    );
  }

  // Mobile Layout (Original)
  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildStatusCard(theme),

        const SizedBox(height: 16),

        // Basic Information
        _buildBasicInfoSection(theme),

        const SizedBox(height: 16),

        // Location Information
        _buildLocationInfoSection(theme),

        const SizedBox(height: 16),

        // Quantity Information
        _buildQuantityInfoSection(theme),

        const SizedBox(height: 16),

        // Scan Activity Information
        _buildScanActivitySection(theme),

        const SizedBox(height: 16),

        // Creation Information
        _buildCreationInfoSection(theme),

        const SizedBox(height: 24),

        // Action Button (แสดงเฉพาะเมื่อ status = 'A')
        if (item.status.toUpperCase() == 'A')
          _buildActionButton(context, theme),
      ],
    );
  }

  // Section Components (เดิมทั้งหมด)
  Widget _buildBasicInfoSection(ThemeData theme) {
    return _buildSectionCard(
      theme: theme,
      title: 'Basic Information',
      icon: Icons.inventory_2_outlined,
      children: [
        _buildDetailRow(theme, 'Asset Number', item.assetNo),
        _buildDetailRow(theme, 'Description', item.description ?? '-'),
        _buildDetailRow(theme, 'Serial Number', item.serialNo ?? '-'),
        _buildDetailRow(theme, 'Inventory Number', item.inventoryNo ?? '-'),
      ],
    );
  }

  Widget _buildLocationInfoSection(ThemeData theme) {
    return _buildSectionCard(
      theme: theme,
      title: 'Location Information',
      icon: Icons.location_on,
      children: [
        _buildDetailRow(
          theme,
          'Plant',
          item.plantDescription != null
              ? item.plantDescription ?? '-'
              : item.plantCode ?? '-',
        ),
        _buildDetailRow(
          theme,
          'Location',
          item.locationName != null
              ? item.locationName ?? '-'
              : item.locationCode ?? '-',
        ),
        _buildDetailRow(
          theme,
          'Department',
          item.deptDescription != null
              ? item.deptDescription ?? '-'
              : item.deptCode ?? '-',
        ),
      ],
    );
  }

  Widget _buildQuantityInfoSection(ThemeData theme) {
    return _buildSectionCard(
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
    );
  }

  Widget _buildScanActivitySection(ThemeData theme) {
    return _buildSectionCard(
      theme: theme,
      title: 'Scan Activity',
      icon: Icons.qr_code_scanner,
      children: [
        _buildDetailRow(
          theme,
          'Last Scan',
          item.lastScanAt != null
              ? Helpers.formatDateTime(item.lastScanAt)
              : 'Never scanned',
        ),
        _buildDetailRow(theme, 'Scanned By', item.lastScannedBy ?? '-'),
      ],
    );
  }

  Widget _buildCreationInfoSection(ThemeData theme) {
    return _buildSectionCard(
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
          item.createdAt != null ? Helpers.formatDateTime(item.createdAt) : '-',
        ),
      ],
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
      color: theme.brightness == Brightness.dark
          ? AppColors
                .darkSurface // Dark Mode: Blue-Gray surface
          : theme.colorScheme.surface, // Light Mode: เดิม
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(item.status, theme),
              _getStatusColor(item.status, theme).withValues(alpha: 0.8),
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
                color: Colors.white.withValues(alpha: 0.2),
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
      color: theme.brightness == Brightness.dark
          ? AppColors
                .darkSurface // Dark Mode: Blue-Gray surface
          : theme.colorScheme.surface, // Light Mode: เดิม
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.brightness == Brightness.dark
                      ? AppColors
                            .darkText // Dark Mode: สีขาว
                      : theme.colorScheme.primary, // Light Mode: สีน้ำเงิน
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? AppColors
                              .darkText // Dark Mode: สีขาว
                        : theme.colorScheme.onSurface, // Light Mode: เดิม
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
                color: theme.brightness == Brightness.dark
                    ? AppColors
                          .darkTextSecondary // Dark Mode: สีเทาอ่อน
                    : theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ), // Light Mode: เดิม
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
                color: theme.brightness == Brightness.dark
                    ? AppColors
                          .darkText // Dark Mode: สีขาว
                    : theme.colorScheme.onSurface, // Light Mode: เดิม
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    // เก็บสี Unknown เป็นสีแดงทั้ง Light และ Dark Mode
    if (item.isUnknown == true) {
      return AppColors.error; // สีแดงสำหรับ Unknown
    }

    switch (status.toUpperCase()) {
      case 'A':
        return theme.colorScheme.primary;
      case 'C':
        return theme.colorScheme.primary;
      case 'I':
        return Colors.grey;
      case 'UNKNOWN':
        return AppColors.error; // สีแดงสำหรับ Unknown
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    if (item.isUnknown == true) {
      return Icons.help;
    }

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
    if (item.isUnknown == true) {
      return 'Unknown';
    }

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
