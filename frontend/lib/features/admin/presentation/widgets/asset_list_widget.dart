import 'package:flutter/material.dart';
import '../../domain/entities/asset_admin_entity.dart';
import 'asset_edit_dialog.dart';

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
    if (assets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No assets found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
                    _buildStatusChip(asset.status),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Serial No', asset.serialNo ?? '-'),
                _buildInfoRow('Plant', asset.plantDescription ?? asset.plantCode),
                _buildInfoRow('Location', asset.locationDescription ?? asset.locationCode),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditDialog(context, asset),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context, asset),
                      icon: const Icon(Icons.delete_outlined, size: 16),
                      label: const Text('Delete'),
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
                      Text('Serial: ${asset.serialNo ?? '-'}', style: const TextStyle(fontSize: 12)),
                      Text('Plant: ${asset.plantDescription ?? asset.plantCode}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildStatusChip(asset.status),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            onPressed: () => _showEditDialog(context, asset),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined, size: 16),
                            onPressed: () => _showDeleteDialog(context, asset),
                            tooltip: 'Delete',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isUltraWide = constraints.maxWidth > 1400;
        
        if (isUltraWide) {
          return _buildExpandableTable(context, constraints);
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Asset No')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Serial No')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Plant')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Actions')),
              ],
              rows: assets.map((asset) => _buildDataRow(context, asset)).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildExpandableTable(BuildContext context, BoxConstraints constraints) {
    // Account for container margins and borders
    final containerMargin = 16.0; // 8px on each side
    final borderWidth = 2.0; // 1px border on each side
    final availableWidth = constraints.maxWidth - containerMargin - borderWidth;
    
    // Define column flex weights for proportional sizing
    const columnFlexes = {
      'assetNo': 2,      // Asset number gets more space
      'description': 4,   // Description gets the most space
      'serialNo': 2,     // Serial number
      'status': 1,       // Status is compact
      'plant': 2,        // Plant description
      'location': 2,     // Location description
      'actions': 2,      // Action buttons
    };
    
    final totalFlex = columnFlexes.values.reduce((a, b) => a + b);
    
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          child: Row(
            children: [
              _buildHeaderCell('Asset No', columnFlexes['assetNo']!),
              _buildHeaderCell('Description', columnFlexes['description']!),
              _buildHeaderCell('Serial No', columnFlexes['serialNo']!),
              _buildHeaderCell('Status', columnFlexes['status']!),
              _buildHeaderCell('Plant', columnFlexes['plant']!),
              _buildHeaderCell('Location', columnFlexes['location']!),
              _buildHeaderCell('Actions', columnFlexes['actions']!),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDataRow(
    BuildContext context, 
    AssetAdminEntity asset, 
    Map<String, int> columnFlexes
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
        hoverColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
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
            _buildDataCell(
              asset.serialNo ?? '-',
              columnFlexes['serialNo']!,
            ),
            _buildStatusCell(
              asset.status,
              columnFlexes['status']!,
            ),
            _buildDataCell(
              asset.plantDescription ?? asset.plantCode,
              columnFlexes['plant']!,
            ),
            _buildDataCell(
              asset.locationDescription ?? asset.locationCode,
              columnFlexes['location']!,
            ),
            _buildActionCell(
              context,
              asset,
              columnFlexes['actions']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, 
    int flex,
    [TextStyle? style, int? maxLines]
  ) {
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

  Widget _buildStatusCell(String status, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Center(
          child: _buildStatusChip(status),
        ),
      ),
    );
  }

  Widget _buildActionCell(
    BuildContext context,
    AssetAdminEntity asset,
    int flex,
  ) {
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
              tooltip: 'Edit Asset',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outlined, size: 18),
              onPressed: () => _showDeleteDialog(context, asset),
              tooltip: 'Delete Asset',
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'A':
        color = Colors.orange;
        text = 'Awaiting';
        break;
      case 'I':
        color = Colors.grey;
        text = 'Inactive';
        break;
      case 'C':
        color = Colors.green;
        text = 'Checked';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, AssetAdminEntity asset) {
    return DataRow(
      cells: [
        DataCell(Text(asset.assetNo)),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              asset.description,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(asset.serialNo ?? '-')),
        DataCell(_buildStatusChip(asset.status)),
        DataCell(Text(asset.plantDescription ?? asset.plantCode)),
        DataCell(Text(asset.locationDescription ?? asset.locationCode)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditDialog(context, asset),
                tooltip: 'Edit Asset',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outlined),
                onPressed: () => _showDeleteDialog(context, asset),
                tooltip: 'Delete Asset',
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
      builder: (context) => AssetEditDialog(
        asset: asset,
        onUpdate: onUpdate,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AssetAdminEntity asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text(
          'Are you sure you want to delete asset "${asset.assetNo}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}