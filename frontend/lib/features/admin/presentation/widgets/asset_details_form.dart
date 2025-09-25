import 'package:flutter/material.dart';
import '../../domain/entities/asset_admin_entity.dart';
import '../../domain/entities/admin_master_data_entity.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

class AssetDetailsForm extends StatefulWidget {
  final AssetAdminEntity asset;
  final TextEditingController descriptionController;
  final TextEditingController serialNoController;
  final TextEditingController inventoryNoController;
  final String status;
  final ValueChanged<String> onStatusChanged;

  // Master data
  final List<AdminPlantEntity> plants;
  final List<AdminLocationEntity> locations;
  final List<AdminDepartmentEntity> departments;
  final bool loadingMasterData;

  // Selected values
  final AdminPlantEntity? selectedPlant;
  final AdminLocationEntity? selectedLocation;
  final AdminDepartmentEntity? selectedDepartment;

  // Callbacks
  final ValueChanged<AdminPlantEntity?> onPlantChanged;
  final ValueChanged<AdminLocationEntity?> onLocationChanged;
  final ValueChanged<AdminDepartmentEntity?> onDepartmentChanged;

  const AssetDetailsForm({
    super.key,
    required this.asset,
    required this.descriptionController,
    required this.serialNoController,
    required this.inventoryNoController,
    required this.status,
    required this.onStatusChanged,
    required this.plants,
    required this.locations,
    required this.departments,
    required this.loadingMasterData,
    required this.selectedPlant,
    required this.selectedLocation,
    required this.selectedDepartment,
    required this.onPlantChanged,
    required this.onLocationChanged,
    required this.onDepartmentChanged,
  });

  @override
  State<AssetDetailsForm> createState() => _AssetDetailsFormState();
}

class _AssetDetailsFormState extends State<AssetDetailsForm> {
  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EDITABLE FIELDS SECTION
              const Text(
                'Editable Fields',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: widget.descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: widget.serialNoController,
                enabled: true,
                readOnly: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.serialNoLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                  helperText: 'Click to edit serial number',
                  hintText: 'Enter serial number',
                ),
                onChanged: (value) {
                  print('🔍 Serial No changed to: $value');
                },
                onTap: () {
                  print('🔍 Serial No field tapped');
                },
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: widget.inventoryNoController,
                enabled: true,
                readOnly: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.inventoryNoLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                  helperText: 'Click to edit inventory number',
                  hintText: 'Enter inventory number',
                ),
                onChanged: (value) {
                  print('🔍 Inventory No changed to: $value');
                },
                onTap: () {
                  print('🔍 Inventory No field tapped');
                },
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Plant Dropdown
              widget.loadingMasterData
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<AdminPlantEntity>(
                      value: widget.selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Plant',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.factory, color: Colors.green),
                      ),
                      items: widget.plants.map((plant) {
                        return DropdownMenuItem<AdminPlantEntity>(
                          value: plant,
                          child: Text('${plant.plantCode} - ${plant.description}'),
                        );
                      }).toList(),
                      onChanged: widget.onPlantChanged,
                    ),
              const SizedBox(height: 16),

              // Location Dropdown
              widget.loadingMasterData
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<AdminLocationEntity>(
                      value: widget.selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on, color: Colors.green),
                      ),
                      items: widget.locations
                          .where((location) =>
                            widget.selectedPlant == null || location.plantCode == widget.selectedPlant!.plantCode)
                          .map((location) {
                        return DropdownMenuItem<AdminLocationEntity>(
                          value: location,
                          child: Text('${location.locationCode} - ${location.description}'),
                        );
                      }).toList(),
                      onChanged: widget.onLocationChanged,
                    ),
              const SizedBox(height: 16),

              // Department Dropdown
              widget.loadingMasterData
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        final availableDepartments = _getAvailableDepartments();

                        return DropdownButtonFormField<AdminDepartmentEntity>(
                          value: availableDepartments.contains(widget.selectedDepartment)
                              ? widget.selectedDepartment
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Department (${availableDepartments.length} available)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.business, color: Colors.green),
                          ),
                          items: availableDepartments.map((dept) {
                            return DropdownMenuItem<AdminDepartmentEntity>(
                              value: dept,
                              child: Text('${dept.deptCode} - ${dept.description}'),
                            );
                          }).toList(),
                          onChanged: widget.onDepartmentChanged,
                        );
                      },
                    ),
              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: widget.status,
                decoration: InputDecoration(
                  labelText: l10n.statusLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                ),
                items: [
                  DropdownMenuItem(value: 'A', child: Text(l10n.statusAwaiting)),
                  DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
                  DropdownMenuItem(value: 'I', child: Text(l10n.statusInactive)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    widget.onStatusChanged(value);
                  }
                },
              ),

              const SizedBox(height: 32),
              const Divider(thickness: 2),
              const SizedBox(height: 16),

              // READ-ONLY FIELDS SECTION
              const Text(
                'Read-Only Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReadOnlyField('Asset No', widget.asset.assetNo, Icons.tag),
                      _buildReadOnlyField('EPC Code', widget.asset.epcCode, Icons.qr_code),
                      _buildReadOnlyField('Unit', widget.asset.unitName ?? widget.asset.unitCode, Icons.straighten),
                      _buildReadOnlyField('Quantity', widget.asset.quantity?.toString() ?? 'N/A', Icons.inventory),
                      _buildReadOnlyField('Brand', widget.asset.brandName ?? widget.asset.brandCode ?? 'N/A', Icons.branding_watermark),
                      _buildReadOnlyField('Category', widget.asset.categoryName ?? widget.asset.categoryCode ?? 'N/A', Icons.category),
                      _buildReadOnlyField('Created By', widget.asset.createdByName ?? widget.asset.createdBy, Icons.person),
                      _buildReadOnlyField('Created At', _formatDateTime(widget.asset.createdAt), Icons.access_time),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AdminDepartmentEntity> _getAvailableDepartments() {
    if (widget.selectedPlant == null) {
      return widget.departments;
    }

    return widget.departments.where((dept) =>
      dept.plantCode == null || dept.plantCode == widget.selectedPlant!.plantCode
    ).toList();
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}