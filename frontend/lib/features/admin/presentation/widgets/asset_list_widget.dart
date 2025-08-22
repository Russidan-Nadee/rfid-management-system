import 'package:flutter/material.dart';
import '../../domain/entities/asset_admin_entity.dart';
import 'asset_edit_dialog.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

class AssetListWidget extends StatelessWidget {
  final List<AssetAdminEntity> assets;
  final Function(String) onDelete;
  final Function(UpdateAssetRequest) onUpdate;

  const AssetListWidget({
    super.key,
    required this.assets,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);

    if (assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noAssetsFound,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return _buildMobileLayout(context);
        } else if (constraints.maxWidth < 1200) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.assetNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, asset.status),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(l10n.serialNo, asset.serialNo ?? '-'),
                _buildInfoRow(
                  l10n.plant,
                  asset.plantDescription ?? asset.plantCode,
                ),
                _buildInfoRow(
                  l10n.location,
                  asset.locationDescription ?? asset.locationCode,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context, asset),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.edit),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context, asset),
                      icon: const Icon(Icons.delete_outlined, size: 16),
                      label: Text(l10n.deactivate),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    return ListView.builder(
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.assetNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.serialNo}: ${asset.serialNo ?? '-'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${l10n.plant}: ${asset.plantDescription ?? asset.plantCode}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildStatusChip(context, asset.status),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            onPressed: () => _showEditDialog(context, asset),
                            tooltip: l10n.edit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined, size: 16),
                            onPressed: () => _showDeleteDialog(context, asset),
                            tooltip: l10n.deactivate,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isUltraWide = constraints.maxWidth > 1400;

        if (isUltraWide) {
          return _buildExpandableTable(context, constraints);
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.assetNo)),
                DataColumn(label: Text(l10n.description)),
                DataColumn(label: Text(l10n.serialNo)),
                DataColumn(label: Text(l10n.status)),
                DataColumn(label: Text(l10n.plant)),
                DataColumn(label: Text(l10n.location)),
                DataColumn(label: Text(l10n.actions)),
              ],
              rows: assets
                  .map((asset) => _buildDataRow(context, asset))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildExpandableTable(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final l10n = AdminLocalizations.of(context);

    // Define column flex weights for proportional sizing
    const columnFlexes = {
      'assetNo': 3, // Asset number gets more space
      'description': 5, // Description gets the most space
      'serialNo': 2, // Serial number
      'status': 2, // Status column expanded
      'plant': 3, // Plant description
      'location': 3, // Location description
      'actions': 2, // Action buttons
    };


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell(l10n.assetNo, columnFlexes['assetNo']!),
                _buildHeaderCell(
                  l10n.description,
                  columnFlexes['description']!,
                ),
                _buildHeaderCell(l10n.serialNo, columnFlexes['serialNo']!),
                _buildHeaderCell(l10n.status, columnFlexes['status']!),
                _buildHeaderCell(l10n.plant, columnFlexes['plant']!),
                _buildHeaderCell(l10n.location, columnFlexes['location']!),
                _buildHeaderCell(l10n.actions, columnFlexes['actions']!),
              ],
            ),
          ),
          // Data rows
          Expanded(
            child: ListView.builder(
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final asset = assets[index];
                return _buildExpandableDataRow(context, asset, columnFlexes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildExpandableDataRow(
    BuildContext context,
    AssetAdminEntity asset,
    Map<String, int> columnFlexes,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: InkWell(
        onTap: () => _showEditDialog(context, asset),
        hoverColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        child: Row(
          children: [
            _buildDataCell(
              asset.assetNo,
              columnFlexes['assetNo']!,
              const TextStyle(fontWeight: FontWeight.w500),
            ),
            _buildDataCell(
              asset.description,
              columnFlexes['description']!,
              null,
              2,
            ),
            _buildDataCell(asset.serialNo ?? '-', columnFlexes['serialNo']!),
            _buildStatusCell(context, asset.status, columnFlexes['status']!),
            _buildDataCell(
              asset.plantDescription ?? asset.plantCode,
              columnFlexes['plant']!,
            ),
            _buildDataCell(
              asset.locationDescription ?? asset.locationCode,
              columnFlexes['location']!,
            ),
            _buildActionCell(context, asset, columnFlexes['actions']!),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    int flex, [
    TextStyle? style,
    int? maxLines,
  ]) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Text(
          text,
          style: style ?? const TextStyle(fontSize: 13),
          maxLines: maxLines ?? 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusCell(BuildContext context, String status, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Center(child: _buildStatusChip(context, status)),
      ),
    );
  }

  Widget _buildActionCell(
    BuildContext context,
    AssetAdminEntity asset,
    int flex,
  ) {
    final l10n = AdminLocalizations.of(context);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _showEditDialog(context, asset),
              tooltip: l10n.edit,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outlined, size: 18),
              onPressed: () => _showDeleteDialog(context, asset),
              tooltip: l10n.deactivate,
              color: Colors.red,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final l10n = AdminLocalizations.of(context);
    Color color;
    String text;
    switch (status) {
      case 'A':
        color = Colors.orange;
        text = l10n.awaiting;
        break;
      case 'I':
        color = Colors.grey;
        text = l10n.inactive;
        break;
      case 'C':
        color = Colors.green;
        text = l10n.checked;
        break;
      default:
        color = Colors.grey;
        text = l10n.unknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, AssetAdminEntity asset) {
    final l10n = AdminLocalizations.of(context);
    return DataRow(
      cells: [
        DataCell(Text(asset.assetNo)),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(asset.description, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(Text(asset.serialNo ?? '-')),
        DataCell(_buildStatusChip(context, asset.status)),
        DataCell(Text(asset.plantDescription ?? asset.plantCode)),
        DataCell(Text(asset.locationDescription ?? asset.locationCode)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditDialog(context, asset),
                tooltip: l10n.edit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outlined),
                onPressed: () => _showDeleteDialog(context, asset),
                tooltip: l10n.deactivate,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, AssetAdminEntity asset) {
    showDialog(
      context: context,
      builder: (context) => AssetEditDialog(asset: asset, onUpdate: onUpdate),
    );
  }

  void _showDeleteDialog(BuildContext context, AssetAdminEntity asset) {
    final l10n = AdminLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deactivateAssetTitle),
        content: Text(
          '${l10n.deactivateConfirmMessage}\n\n${l10n.deactivateExplanation}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(asset.assetNo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deactivate),
          ),
        ],
      ),
    );
  }
}
