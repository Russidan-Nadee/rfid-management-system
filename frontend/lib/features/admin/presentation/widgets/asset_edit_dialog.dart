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
  late TextEditingController _plantCodeController;
  late TextEditingController _locationCodeController;
  late TextEditingController _deptCodeController;
  late String _status;
  
  // Image management
  List<AdminAssetImageEntity> _images = [];
  bool _loadingImages = false;
  bool _uploadingImage = false;
  Set<int> _deletingImages = {};
  late GetAdminAssetImagesUsecase _getImagesUsecase;
  late UploadAdminImageUsecase _uploadImageUsecase;
  late DeleteImageUsecase _deleteImageUsecase;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.asset.description,
    );
    _serialNoController = TextEditingController(
      text: widget.asset.serialNo ?? '',
    );
    print('🔍 Serial No initialized with: ${widget.asset.serialNo}');
    _inventoryNoController = TextEditingController(
      text: widget.asset.inventoryNo ?? '',
    );
    print('🔍 Inventory No initialized with: ${widget.asset.inventoryNo}');
    _plantCodeController = TextEditingController(
      text: widget.asset.plantCode,
    );
    _locationCodeController = TextEditingController(
      text: widget.asset.locationCode,
    );
    _deptCodeController = TextEditingController(
      text: widget.asset.deptCode ?? '',
    );
    _status = widget.asset.status;
    
    // Initialize image use cases
    final datasource = AdminRemoteDatasourceImpl();
    final repository = AdminRepositoryImpl(remoteDataSource: datasource);
    _getImagesUsecase = GetAdminAssetImagesUsecase(repository);
    _uploadImageUsecase = UploadAdminImageUsecase(repository);
    _deleteImageUsecase = DeleteImageUsecase(repository);
    
    // Load images
    _loadImages();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _serialNoController.dispose();
    _inventoryNoController.dispose();
    _plantCodeController.dispose();
    _locationCodeController.dispose();
    _deptCodeController.dispose();
    super.dispose();
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
    print('🔍 Dialog: Starting image picker...');
    
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      print('🔍 Dialog: Image picker result: ${pickedFile?.path ?? 'null'}');

      if (pickedFile != null) {
        print('🔍 Dialog: Setting upload state to true...');
        setState(() {
          _uploadingImage = true;
        });
        print('🔍 Dialog: Upload state updated, starting upload...');

        try {
          print('🔍 Dialog: Creating File object...');
          print('🔍 Dialog: picked file path: ${pickedFile.path}');
          
          // Handle web blob URLs differently
          if (kIsWeb && pickedFile.path.startsWith('blob:')) {
            print('🔍 Dialog: Web blob URL detected, using XFile directly');
            
            // For web, read bytes from XFile instead of File
            final bytes = await pickedFile.readAsBytes();
            print('🔍 Dialog: Read ${bytes.length} bytes from XFile');
            
            // Create a temporary file-like object for web
            final webImageFile = WebImageFile(pickedFile.path, bytes, pickedFile.name);
            print('🔍 Dialog: Created WebImageFile wrapper with name: ${pickedFile.name}');
            
            print('🔍 Dialog: Calling upload use case with web file...');
            final success = await _uploadImageUsecase(
              widget.asset.assetNo,
              webImageFile,
            );
            
            print('🔍 Dialog: Upload use case completed, success: $success');
            
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
            print('🔍 Dialog: Regular file path, using File object');
            final imageFile = File(pickedFile.path);
            print('🔍 Dialog: File created successfully');
            
            print('🔍 Dialog: File exists check...');
            final exists = await imageFile.exists();
            print('🔍 Dialog: File exists: $exists');
            
            if (exists) {
              final size = await imageFile.length();
              print('🔍 Dialog: File size: $size bytes');
            }
            
            print('🔍 Dialog: Calling upload use case...');
            final success = await _uploadImageUsecase(
              widget.asset.assetNo,
              imageFile,
            );
            
            print('🔍 Dialog: Upload use case completed, success: $success');
            
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
              print('❌ Dialog: Mobile upload failed (success = false)');
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
          print('💥 Dialog: Upload error caught: $e');
          print('💥 Dialog: Error type: ${e.runtimeType}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          print('🔍 Dialog: Setting upload state to false...');
          if (mounted) {
            setState(() {
              _uploadingImage = false;
            });
          }
          print('🔍 Dialog: Upload state reset');
        }
      } else {
        print('ℹ️ Dialog: No image selected by user');
      }
    } catch (e) {
      print('💥 Dialog: Image picker error: $e');
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
                        Tab(
                          icon: const Icon(Icons.edit),
                          text: l10n.edit,
                        ),
                        Tab(
                          icon: const Icon(Icons.image),
                          text: 'Images',
                        ),
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
            Text(
              'Editable Fields',
              style: const TextStyle(
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
                print('🔍 Serial No changed to: $value');
              },
              onTap: () {
                print('🔍 Serial No field tapped');
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
            TextField(
              controller: _plantCodeController,
              decoration: InputDecoration(
                labelText: 'Plant Code',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCodeController,
              decoration: InputDecoration(
                labelText: 'Location Code',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deptCodeController,
              decoration: InputDecoration(
                labelText: 'Department Code',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit, color: Colors.green),
              ),
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
            
            const SizedBox(height: 32),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            
            // READ-ONLY FIELDS SECTION
            Text(
              'Read-Only Information',
              style: const TextStyle(
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
                    _buildReadOnlyField('Brand', widget.asset.brandCode ?? 'N/A', Icons.branding_watermark),
                    _buildReadOnlyField('Category', widget.asset.categoryCode ?? 'N/A', Icons.category),
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

  void _handleUpdate() {
    print('🔍 Update called - Serial No controller text: "${_serialNoController.text}"');
    print('🔍 Update called - Inventory No controller text: "${_inventoryNoController.text}"');
    
    final serialNoValue = _serialNoController.text.trim();
    final inventoryNoValue = _inventoryNoController.text.trim();
    print('🔍 Serial No value after trim: "$serialNoValue"');
    print('🔍 Inventory No value after trim: "$inventoryNoValue"');
    
    final request = UpdateAssetRequest(
      assetNo: widget.asset.assetNo,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      serialNo: serialNoValue.isNotEmpty ? serialNoValue : null,
      inventoryNo: inventoryNoValue.isNotEmpty ? inventoryNoValue : null,
      plantCode: _plantCodeController.text.trim().isNotEmpty
          ? _plantCodeController.text.trim()
          : null,
      locationCode: _locationCodeController.text.trim().isNotEmpty
          ? _locationCodeController.text.trim()
          : null,
      deptCode: _deptCodeController.text.trim().isNotEmpty
          ? _deptCodeController.text.trim()
          : null,
      status: _status,
    );

    widget.onUpdate(request);
    Navigator.of(context).pop();
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
    'WebImageFile only supports exists(), length(), readAsBytes(), and path'
  );
}
