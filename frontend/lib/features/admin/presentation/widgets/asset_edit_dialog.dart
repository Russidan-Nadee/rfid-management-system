import 'package:flutter/material.dart';
import '../../domain/entities/asset_admin_entity.dart';

class AssetEditDialog extends StatefulWidget {
  final AssetAdminEntity asset;
  final Function(UpdateAssetRequest) onUpdate;

  const AssetEditDialog({
    super.key,
    required this.asset,
    required this.onUpdate,
  });

  @override
  State<AssetEditDialog> createState() => _AssetEditDialogState();
}

class _AssetEditDialogState extends State<AssetEditDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _serialNoController;
  late TextEditingController _inventoryNoController;
  late TextEditingController _quantityController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.asset.description);
    _serialNoController = TextEditingController(text: widget.asset.serialNo ?? '');
    _inventoryNoController = TextEditingController(text: widget.asset.inventoryNo ?? '');
    _quantityController = TextEditingController(text: widget.asset.quantity?.toString() ?? '');
    _status = widget.asset.status;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _serialNoController.dispose();
    _inventoryNoController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Asset: ${widget.asset.assetNo}'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serialNoController,
                decoration: const InputDecoration(
                  labelText: 'Serial No',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inventoryNoController,
                decoration: const InputDecoration(
                  labelText: 'Inventory No',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('Active')),
                  DropdownMenuItem(value: 'I', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Read-only Information:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Asset No: ${widget.asset.assetNo}'),
                      Text('EPC Code: ${widget.asset.epcCode}'),
                      Text('Plant: ${widget.asset.plantDescription ?? widget.asset.plantCode}'),
                      Text('Location: ${widget.asset.locationDescription ?? widget.asset.locationCode}'),
                      Text('Unit: ${widget.asset.unitName ?? widget.asset.unitCode}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleUpdate,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _handleUpdate() {
    final request = UpdateAssetRequest(
      assetNo: widget.asset.assetNo,
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim()
          : null,
      serialNo: _serialNoController.text.trim().isNotEmpty 
          ? _serialNoController.text.trim()
          : null,
      inventoryNo: _inventoryNoController.text.trim().isNotEmpty 
          ? _inventoryNoController.text.trim()
          : null,
      quantity: _quantityController.text.trim().isNotEmpty 
          ? double.tryParse(_quantityController.text.trim())
          : null,
      status: _status,
    );

    widget.onUpdate(request);
    Navigator.of(context).pop();
  }
}