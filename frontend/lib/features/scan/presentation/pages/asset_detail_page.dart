// Path: frontend/lib/features/scan/presentation/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
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
    final l10n = ScanLocalizations.of(context);

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
            Helpers.showSuccess(context, l10n.assetMarkedSuccess);
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
            l10n.assetDetailPageTitle,
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
                alpha: 0.1,
              ) // Dark Mode: เหมือน Scan Page
            : theme.colorScheme.background, // Light Mode: เดิม
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isDesktop
                  ? _buildDesktopLayout(context, theme, l10n)
                  : _buildMobileLayout(context, theme, l10n),
            );
          },
        ),
      ),
    );
  }

  // Desktop Layout (2x3 Grid)
  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Column(
      children: [
        // Row 1: Status Card + Basic Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusCard(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildBasicInfoSection(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 2: Location Info + Quantity Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLocationInfoSection(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildQuantityInfoSection(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 3: Scan Activity + Creation Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildScanActivitySection(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildCreationInfoSection(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Button (Full Width Center)
        if (item.status.toUpperCase() == 'A')
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildActionButton(context, theme, l10n),
            ),
          ),
      ],
    );
  }

  // Mobile Layout (Original)
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Card
        _buildStatusCard(theme, l10n),

        const SizedBox(height: 16),

        // Basic Information
        _buildBasicInfoSection(theme, l10n),

        const SizedBox(height: 16),

        // Location Information
        _buildLocationInfoSection(theme, l10n),

        const SizedBox(height: 16),

        // Quantity Information
        _buildQuantityInfoSection(theme, l10n),

        const SizedBox(height: 16),

        // Scan Activity Information
        _buildScanActivitySection(theme, l10n),

        const SizedBox(height: 16),

        // Creation Information
        _buildCreationInfoSection(theme, l10n),

        const SizedBox(height: 24),

        // Action Button (แสดงเฉพาะเมื่อ status = 'A')
        if (item.status.toUpperCase() == 'A')
          _buildActionButton(context, theme, l10n),
      ],
    );
  }

  // Section Components (เดิมทั้งหมด)
  Widget _buildBasicInfoSection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.basicInformation,
      icon: Icons.inventory_2_outlined,
      children: [
        _buildDetailRow(theme, l10n.assetNumber, item.assetNo, l10n),
        _buildDetailRow(theme, l10n.description, item.description ?? '-', l10n),
        _buildDetailRow(theme, l10n.serialNumber, item.serialNo ?? '-', l10n),
        _buildDetailRow(
          theme,
          l10n.inventoryNumber,
          item.inventoryNo ?? '-',
          l10n,
        ),
      ],
    );
  }

  Widget _buildLocationInfoSection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.locationInformation,
      icon: Icons.location_on,
      children: [
        _buildDetailRow(
          theme,
          l10n.plant,
          item.plantDescription != null
              ? item.plantDescription ?? '-'
              : item.plantCode ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.location,
          item.locationName != null
              ? item.locationName ?? '-'
              : item.locationCode ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.department,
          item.deptDescription != null
              ? item.deptDescription ?? '-'
              : item.deptCode ?? '-',
          l10n,
        ),
      ],
    );
  }

  Widget _buildQuantityInfoSection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.quantityInformation,
      icon: Icons.straighten,
      children: [
        _buildDetailRow(
          theme,
          l10n.quantity,
          item.quantity != null ? '${item.quantity}' : '-',
          l10n,
        ),
        _buildDetailRow(theme, l10n.unit, item.unitName ?? '-', l10n),
      ],
    );
  }

  Widget _buildScanActivitySection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.scanActivity,
      icon: Icons.qr_code_scanner,
      children: [
        _buildDetailRow(
          theme,
          l10n.lastScan,
          item.lastScanAt != null
              ? Helpers.formatDateTime(item.lastScanAt)
              : l10n.neverScanned,
          l10n,
        ),
        _buildDetailRow(theme, l10n.scannedBy, item.lastScannedBy ?? '-', l10n),
      ],
    );
  }

  Widget _buildCreationInfoSection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.creationInformation,
      icon: Icons.person_outline,
      children: [
        _buildDetailRow(
          theme,
          l10n.createdBy,
          item.createdByName ?? l10n.unknownUser,
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.createdDate,
          item.createdAt != null ? Helpers.formatDateTime(item.createdAt) : '-',
          l10n,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
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
            label: Text(isLoading ? l10n.markingAsChecked : l10n.markAsChecked),
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

  Widget _buildStatusCard(ThemeData theme, ScanLocalizations l10n) {
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
                _getStatusLabel(item.status, l10n),
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

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    ScanLocalizations l10n,
  ) {
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
      return AppColors.error.withValues(alpha: 0.7); // สีแดงสำหรับ Unknown
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

  String _getStatusLabel(String status, ScanLocalizations l10n) {
    if (item.isUnknown == true) {
      return l10n.statusUnknown;
    }

    switch (status.toUpperCase()) {
      case 'A':
        return l10n.statusActive;
      case 'C':
        return l10n.statusChecked;
      case 'I':
        return l10n.statusInactive;
      case 'UNKNOWN':
        return l10n.statusUnknown;
      default:
        return status;
    }
  }
}
