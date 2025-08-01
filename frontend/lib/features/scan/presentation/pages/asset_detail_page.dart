// Path: frontend/lib/features/scan/presentation/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/features/scan/scan_localizations.dart';
import '../../domain/entities/scanned_item_entity.dart';
import '../../domain/entities/asset_image_entity.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';
import '../widgets/image_gallery_widget.dart';

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

class AssetDetailView extends StatefulWidget {
  final ScannedItemEntity item;

  const AssetDetailView({super.key, required this.item});

  @override
  State<AssetDetailView> createState() => _AssetDetailViewState();
}

class _AssetDetailViewState extends State<AssetDetailView> {
  List<AssetImageEntity> _images = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
  }

  void _loadAssetImages() {
    context.read<ScanBloc>().add(LoadAssetImages(assetNo: widget.item.assetNo));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ScanLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        // Listener สำหรับ Asset Status Updates
        BlocListener<ScanBloc, ScanState>(
          listener: (context, state) {
            // ตรวจสอบว่า asset ถูก update แล้วหรือยัง
            if (state is ScanSuccess) {
              final updatedItem = state.scannedItems.firstWhere(
                (scanItem) => scanItem.assetNo == widget.item.assetNo,
                orElse: () => widget.item,
              );

              // ถ้า status เปลี่ยนจาก A เป็น C แสดงว่า update สำเร็จ
              if (widget.item.status.toUpperCase() == 'A' &&
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
        ),
        // Listener สำหรับ Asset Images
        BlocListener<ScanBloc, ScanState>(
          listener: (context, state) {
            if (state is AssetImagesLoaded &&
                state.assetNo == widget.item.assetNo) {
              setState(() {
                _images = state.images;
                _isLoadingImages = false;
              });
            } else if (state is AssetImagesLoading &&
                state.assetNo == widget.item.assetNo) {
              setState(() {
                _isLoadingImages = true;
              });
            } else if (state is AssetImagesError &&
                state.assetNo == widget.item.assetNo) {
              setState(() {
                _isLoadingImages = false;
              });
              // แสดง error แบบ silent (ไม่รบกวน user)
              print('Failed to load images: ${state.message}');
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.assetDetailPageTitle,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkText
                  : AppColors.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.primary,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.1)
            : theme.colorScheme.background,
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

  // Desktop Layout (2x5 Grid)
  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Column(
      children: [
        // Row 1: Image Gallery + Status Card
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildImageGallerySection(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusCard(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 2: Basic Info + Location Info
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildBasicInfoSection(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildLocationInfoSection(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 3: Quantity Info + Scan Activity
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuantityInfoSection(theme, l10n)),
              const SizedBox(width: 16),
              Expanded(child: _buildScanActivitySection(theme, l10n)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Row 4: Creation Info (Full Width)
        _buildCreationInfoSection(theme, l10n),

        const SizedBox(height: 24),

        // Row 5: Action Button (Center)
        if (widget.item.status.toUpperCase() == 'A')
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildActionButton(context, theme, l10n),
            ),
          ),
      ],
    );
  }

  // Mobile Layout (Original + Image Gallery at top)
  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    ScanLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Gallery (First)
        _buildImageGallerySection(theme, l10n),

        const SizedBox(height: 16),

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
        if (widget.item.status.toUpperCase() == 'A')
          _buildActionButton(context, theme, l10n),
      ],
    );
  }

  // ⭐ NEW: Image Gallery Section
  Widget _buildImageGallerySection(ThemeData theme, ScanLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurface
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkText
                      : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.images,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (_isLoadingImages) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingImages
                ? Container(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : ImageGalleryWidget(
                    images: _images,
                    assetNo: widget.item.assetNo,
                  ),
          ],
        ),
      ),
    );
  }

  // Section Components (เดิมทั้งหมด)
  Widget _buildBasicInfoSection(ThemeData theme, ScanLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      title: l10n.basicInformation,
      icon: Icons.inventory_2_outlined,
      children: [
        _buildDetailRow(theme, l10n.assetNumber, widget.item.assetNo, l10n),
        _buildDetailRow(
          theme,
          l10n.description,
          widget.item.description ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.serialNumber,
          widget.item.serialNo ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.inventoryNumber,
          widget.item.inventoryNo ?? '-',
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
          widget.item.plantDescription != null
              ? widget.item.plantDescription ?? '-'
              : widget.item.plantCode ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.location,
          widget.item.locationName != null
              ? widget.item.locationName ?? '-'
              : widget.item.locationCode ?? '-',
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.department,
          widget.item.deptDescription != null
              ? widget.item.deptDescription ?? '-'
              : widget.item.deptCode ?? '-',
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
          widget.item.quantity != null ? '${widget.item.quantity}' : '-',
          l10n,
        ),
        _buildDetailRow(theme, l10n.unit, widget.item.unitName ?? '-', l10n),
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
          widget.item.lastScanAt != null
              ? Helpers.formatDateTime(widget.item.lastScanAt)
              : l10n.neverScanned,
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.scannedBy,
          widget.item.lastScannedBy ?? '-',
          l10n,
        ),
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
          widget.item.createdByName ?? l10n.unknownUser,
          l10n,
        ),
        _buildDetailRow(
          theme,
          l10n.createdDate,
          widget.item.createdAt != null
              ? Helpers.formatDateTime(widget.item.createdAt)
              : '-',
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
            state is AssetStatusUpdating &&
            state.assetNo == widget.item.assetNo;

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
    context.read<ScanBloc>().add(
      MarkAssetChecked(assetNo: widget.item.assetNo),
    );
  }

  Widget _buildStatusCard(ThemeData theme, ScanLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.brightness == Brightness.dark
          ? AppColors.darkSurface
          : theme.colorScheme.surface,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(widget.item.status, theme),
              _getStatusColor(widget.item.status, theme).withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(widget.item.status),
              color: Colors.white,
              size: 48,
            ),

            const SizedBox(height: 12),

            Text(
              widget.item.displayName,
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
                _getStatusLabel(widget.item.status, l10n),
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
          ? AppColors.darkSurface
          : theme.colorScheme.surface,
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
                      ? AppColors.darkText
                      : theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkText
                        : theme.colorScheme.onSurface,
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
                    ? AppColors.darkTextSecondary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                    ? AppColors.darkText
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    // เก็บสี Unknown เป็นสีแดงทั้ง Light และ Dark Mode
    if (widget.item.isUnknown == true) {
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
    if (widget.item.isUnknown == true) {
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
    if (widget.item.isUnknown == true) {
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
