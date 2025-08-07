import 'package:flutter/material.dart';
import '../../domain/entities/asset_admin_entity.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

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
    _descriptionController = TextEditingController(
      text: widget.asset.description,
    );
    _serialNoController = TextEditingController(
      text: widget.asset.serialNo ?? '',
    );
    _inventoryNoController = TextEditingController(
      text: widget.asset.inventoryNo ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.asset.quantity?.toString() ?? '',
    );
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
    final l10n = AdminLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    return AlertDialog(
      title: Text('${l10n.editAssetTitle}: ${widget.asset.assetNo}'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _serialNoController,
                decoration: InputDecoration(
                  labelText: l10n.serialNoLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inventoryNoController,
                decoration: InputDecoration(
                  labelText: l10n.inventoryNoLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantityLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: l10n.statusLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'A', child: Text(l10n.statusAwaiting)),
                  DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
                  DropdownMenuItem(value: 'I', child: Text(l10n.statusInactive)),
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
                      Text(
                        l10n.readOnlyInfoTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('${l10n.assetNo}: ${widget.asset.assetNo}'),
                      Text('${l10n.epcCodeLabel}: ${widget.asset.epcCode}'),
                      Text(
                        '${l10n.plantLabel}: ${widget.asset.plantDescription ?? widget.asset.plantCode}',
                      ),
                      Text(
                        '${l10n.locationLabel}: ${widget.asset.locationDescription ?? widget.asset.locationCode}',
                      ),
                      Text(
                        '${l10n.unitLabel}: ${widget.asset.unitName ?? widget.asset.unitCode}',
                      ),
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
          child: Text(l10n.cancel),
        ),
        ElevatedButton(onPressed: _handleUpdate, child: Text(l10n.update)),
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
