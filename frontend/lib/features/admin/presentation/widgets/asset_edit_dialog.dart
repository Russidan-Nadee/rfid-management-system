import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/asset_admin_entity.dart';
import '../../domain/entities/admin_asset_image_entity.dart';
import '../../domain/usecases/get_admin_asset_images_usecase.dart';
import '../../domain/usecases/upload_admin_image_usecase.dart';
import '../../domain/usecases/delete_image_usecase.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import 'admin_image_gallery_widget.dart';
import '../../domain/entities/admin_master_data_entity.dart';

class AssetEditDialog extends StatefulWidget {
  final AssetAdminEntity asset;
  final Future<void> Function(UpdateAssetRequest) onUpdate;

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
  late String _status;

  // Master data for dropdowns
  List<AdminPlantEntity> _plants = [];
  List<AdminLocationEntity> _locations = [];
  List<AdminDepartmentEntity> _departments = [];
  AdminPlantEntity? _selectedPlant;
  AdminLocationEntity? _selectedLocation;
  AdminDepartmentEntity? _selectedDepartment;
  bool _loadingMasterData = false;

  // Image management
  List<AdminAssetImageEntity> _images = [];
  bool _loadingImages = false;
  bool _uploadingImage = false;
  Set<int> _deletingImages = {};
  late GetAdminAssetImagesUsecase _getImagesUsecase;
  late UploadAdminImageUsecase _uploadImageUsecase;
  late DeleteImageUsecase _deleteImageUsecase;
  late AdminRemoteDatasourceImpl _adminDatasource;

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
    _status = widget.asset.status;

    // Initialize admin datasource and use cases
    _adminDatasource = AdminRemoteDatasourceImpl();
    final repository = AdminRepositoryImpl(remoteDataSource: _adminDatasource);
    _getImagesUsecase = GetAdminAssetImagesUsecase(repository);
    _uploadImageUsecase = UploadAdminImageUsecase(repository);
    _deleteImageUsecase = DeleteImageUsecase(repository);

    // Initialize selected values based on current asset
    _initializeSelectedValues();

    // Load data
    _loadMasterData();
    _loadImages();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _serialNoController.dispose();
    _inventoryNoController.dispose();
    super.dispose();
  }

  void _initializeSelectedValues() {
    // Initialize with current asset values
    // These will be properly set after master data is loaded
  }

  Future<void> _loadMasterData() async {
    setState(() {
      _loadingMasterData = true;
    });

    try {
      final masterData = await _adminDatasource.getMasterData();

      // Parse plants
      final plantsJson = masterData['plants'] as List<dynamic>? ?? [];
      _plants = plantsJson
          .map(
            (json) => AdminPlantEntity(
              plantCode: json['plant_code'],
              description: json['description'],
            ),
          )
          .toList();

      // Parse locations
      final locationsJson = masterData['locations'] as List<dynamic>? ?? [];
      _locations = locationsJson
          .map(
            (json) => AdminLocationEntity(
              locationCode: json['location_code'],
              description: json['description'],
              plantCode: json['plant_code'],
            ),
          )
          .toList();

      // Parse departments
      final departmentsJson = masterData['departments'] as List<dynamic>? ?? [];
      _departments = departmentsJson
          .map(
            (json) => AdminDepartmentEntity(
              deptCode: json['dept_code'],
              description: json['description'],
              plantCode: json['plant_code'],
            ),
          )
          .toList();

      // Set initial selected values based on current asset
      try {
        _selectedPlant = _plants.firstWhere(
          (plant) => plant.plantCode == (widget.asset.plantCode),
        );
      } catch (e) {
        _selectedPlant = _plants.isNotEmpty ? _plants.first : null;
      }

      if (_selectedPlant != null) {
        // Filter locations and departments for selected plant
        _updateLocationsForPlant(_selectedPlant!.plantCode);
        _updateDepartmentsForPlant(_selectedPlant!.plantCode);

        // Set selected location and department
        try {
          _selectedLocation = _locations.firstWhere(
            (location) => location.locationCode == widget.asset.locationCode,
          );
        } catch (e) {
          final availableLocations = _locations
              .where(
                (location) => location.plantCode == _selectedPlant!.plantCode,
              )
              .toList();
          _selectedLocation = availableLocations.isNotEmpty
              ? availableLocations.first
              : null;
        }

        try {
          _selectedDepartment = _departments.firstWhere(
            (dept) => dept.deptCode == widget.asset.deptCode,
          );
        } catch (e) {
          final availableDepartments = _departments
              .where(
                (dept) =>
                    dept.plantCode == null ||
                    dept.plantCode == _selectedPlant!.plantCode,
              )
              .toList();
          _selectedDepartment = availableDepartments.isNotEmpty
              ? availableDepartments.first
              : null;
        }
      }

      setState(() {
        _loadingMasterData = false;
      });
    } catch (e) {
      setState(() {
        _loadingMasterData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load master data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateLocationsForPlant(String plantCode) {
    setState(() {
      // Reset location selection when plant changes
      final availableLocations = _locations
          .where((location) => location.plantCode == plantCode)
          .toList();

      // If current selection is not available for new plant, reset it
      if (_selectedLocation != null &&
          !availableLocations.contains(_selectedLocation)) {
        _selectedLocation = null;
      }
    });
  }

  void _updateDepartmentsForPlant(String plantCode) {
    setState(() {
      // Reset department selection when plant changes
      final availableDepartments = _getAvailableDepartments();

      // If current selection is not available for new plant, reset it
      if (_selectedDepartment != null &&
          !availableDepartments.contains(_selectedDepartment)) {
        _selectedDepartment = null;
      }
    });
  }

  List<AdminDepartmentEntity> _getAvailableDepartments() {
    if (_selectedPlant == null) {
      // If no plant selected, show all departments
      return _departments;
    }

    // Filter departments for selected plant
    // Include departments that have no plant restriction (plantCode == null)
    // or match the selected plant
    return _departments
        .where(
          (dept) =>
              dept.plantCode == null ||
              dept.plantCode == _selectedPlant!.plantCode,
        )
        .toList();
  }

  Future<void> _loadImages() async {
    setState(() {
      _loadingImages = true;
    });

    try {
      final images = await _getImagesUsecase(widget.asset.assetNo);
      setState(() {
        _images = images;
        _loadingImages = false;
      });
    } catch (e) {
      setState(() {
        _loadingImages = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _uploadingImage = true;
        });

        try {
          // Handle web blob URLs differently
          if (kIsWeb && pickedFile.path.startsWith('blob:')) {
            // For web, read bytes from XFile instead of File
            final bytes = await pickedFile.readAsBytes();

            // Create a temporary file-like object for web
            final webImageFile = WebImageFile(
              pickedFile.path,
              bytes,
              pickedFile.name,
            );

            final success = await _uploadImageUsecase(
              widget.asset.assetNo,
              webImageFile,
            );

            if (success) {
              await _loadImages();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } else {
            final imageFile = File(pickedFile.path);

            final success = await _uploadImageUsecase(
              widget.asset.assetNo,
              imageFile,
            );

            if (success) {
              await _loadImages();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload failed - please try again'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _uploadingImage = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open image picker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(int imageId) async {
    setState(() {
      _deletingImages.add(imageId);
    });

    try {
      await _deleteImageUsecase(imageId);
      await _loadImages(); // Reload images
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _deletingImages.remove(imageId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth < 800 ? screenWidth * 0.95 : 800.0;
    final dialogHeight = screenHeight * 0.8;

    return Dialog(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Header with tabs
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.editAssetTitle}: ${widget.asset.assetNo}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      tabs: [
                        Tab(icon: const Icon(Icons.edit), text: l10n.edit),
                        const Tab(icon: Icon(Icons.image), text: 'Images'),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    // Asset Details Tab
                    _buildAssetDetailsTab(l10n),
                    // Images Tab
                    _buildImagesTab(l10n),
                  ],
                ),
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleUpdate,
                      child: Text(l10n.update),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetDetailsTab(AdminLocalizations l10n) {
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
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descriptionLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNoController,
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
                  // Handle serial number changes
                },
                validator: (value) {
                  // Optional: Add validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _inventoryNoController,
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
                  // Handle inventory number changes
                },
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _loadingMasterData
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
                      value: _selectedPlant,
                      decoration: const InputDecoration(
                        labelText: 'Plant',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.factory, color: Colors.green),
                      ),
                      items: _plants.map((plant) {
                        return DropdownMenuItem<AdminPlantEntity>(
                          value: plant,
                          child: Text(
                            '${plant.plantCode} - ${plant.description}',
                          ),
                        );
                      }).toList(),
                      onChanged: (AdminPlantEntity? newPlant) {
                        setState(() {
                          _selectedPlant = newPlant;
                          _selectedLocation = null;
                          _selectedDepartment = null;
                        });
                        if (newPlant != null) {
                          _updateLocationsForPlant(newPlant.plantCode);
                          _updateDepartmentsForPlant(newPlant.plantCode);
                        }
                      },
                    ),
              const SizedBox(height: 16),
              _loadingMasterData
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
                      value: _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                      ),
                      items: _locations
                          .where(
                            (location) =>
                                _selectedPlant == null ||
                                location.plantCode == _selectedPlant!.plantCode,
                          )
                          .map((location) {
                            return DropdownMenuItem<AdminLocationEntity>(
                              value: location,
                              child: Text(
                                '${location.locationCode} - ${location.description}',
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (AdminLocationEntity? newLocation) {
                        setState(() {
                          _selectedLocation = newLocation;
                        });
                      },
                    ),
              const SizedBox(height: 16),
              _loadingMasterData
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
                        // Reset selected department if it's not in available list
                        if (_selectedDepartment != null &&
                            !availableDepartments.contains(
                              _selectedDepartment,
                            )) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedDepartment = null;
                            });
                          });
                        }

                        return DropdownButtonFormField<AdminDepartmentEntity>(
                          value:
                              availableDepartments.contains(_selectedDepartment)
                              ? _selectedDepartment
                              : null,
                          decoration: InputDecoration(
                            labelText:
                                'Department (${availableDepartments.length} available)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.business,
                              color: Colors.green,
                            ),
                          ),
                          items: availableDepartments.map((dept) {
                            return DropdownMenuItem<AdminDepartmentEntity>(
                              value: dept,
                              child: Text(
                                '${dept.deptCode} - ${dept.description}',
                              ),
                            );
                          }).toList(),
                          onChanged: (AdminDepartmentEntity? newDept) {
                            setState(() {
                              _selectedDepartment = newDept;
                            });
                          },
                        );
                      },
                    ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: l10n.statusLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit, color: Colors.green),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'A',
                    child: Text(l10n.statusAwaiting),
                  ),
                  DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
                  DropdownMenuItem(
                    value: 'I',
                    child: Text(l10n.statusInactive),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
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
                      _buildReadOnlyField(
                        'Asset No',
                        widget.asset.assetNo,
                        Icons.tag,
                      ),
                      _buildReadOnlyField(
                        'EPC Code',
                        widget.asset.epcCode,
                        Icons.qr_code,
                      ),
                      _buildReadOnlyField(
                        'Unit',
                        widget.asset.unitName ?? widget.asset.unitCode,
                        Icons.straighten,
                      ),
                      _buildReadOnlyField(
                        'Quantity',
                        widget.asset.quantity?.toString() ?? 'N/A',
                        Icons.inventory,
                      ),
                      _buildReadOnlyField(
                        'Brand',
                        widget.asset.brandName ??
                            widget.asset.brandCode ??
                            'N/A',
                        Icons.branding_watermark,
                      ),
                      _buildReadOnlyField(
                        'Category',
                        widget.asset.categoryName ??
                            widget.asset.categoryCode ??
                            'N/A',
                        Icons.category,
                      ),
                      _buildReadOnlyField(
                        'Created By',
                        widget.asset.createdByName ?? widget.asset.createdBy,
                        Icons.person,
                      ),
                      _buildReadOnlyField(
                        'Created At',
                        _formatDateTime(widget.asset.createdAt),
                        Icons.access_time,
                      ),
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

  Widget _buildImagesTab(AdminLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _uploadingImage ? null : _pickAndUploadImage,
                icon: _uploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_uploadingImage ? 'Uploading...' : 'Add Image'),
              ),
              const SizedBox(width: 16),
              Text(
                'Total: ${_images.length} images',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Images grid
          Expanded(
            child: _loadingImages
                ? const Center(child: CircularProgressIndicator())
                : AdminImageGalleryWidget(
                    images: _images,
                    assetNo: widget.asset.assetNo,
                    onDeleteImage: _deleteImage,
                    deletingImages: _deletingImages,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final serialNoValue = _serialNoController.text.trim();
    final inventoryNoValue = _inventoryNoController.text.trim();

    final request = UpdateAssetRequest(
      assetNo: widget.asset.assetNo,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      serialNo: serialNoValue.isNotEmpty ? serialNoValue : null,
      inventoryNo: inventoryNoValue.isNotEmpty ? inventoryNoValue : null,
      plantCode: _selectedPlant?.plantCode,
      locationCode: _selectedLocation?.locationCode,
      deptCode: _selectedDepartment?.deptCode,
      status: _status,
    );

    try {
      await widget.onUpdate(request);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Web-compatible File wrapper for blob URLs
class WebImageFile implements File {
  final String _path;
  final Uint8List _bytes;
  final String _name;

  WebImageFile(this._path, this._bytes, this._name);

  @override
  String get path => _path;

  @override
  Future<bool> exists() async => true; // Blob always exists if we have bytes

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  String get name => _name;

  // Minimal File interface implementation - only implement what we need
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'WebImageFile only supports exists(), length(), readAsBytes(), and path',
  );
}
