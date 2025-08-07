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
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: asset.status == 'A' ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              asset.status == 'A' ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
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