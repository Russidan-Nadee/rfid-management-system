// Path: frontend/lib/features/scan/presentation/pages/create_asset_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/master_data_entity.dart';
import '../bloc/asset_creation_bloc.dart';

class CreateAssetPage extends StatelessWidget {
  final String assetNo;
  final String? plantCode;
  final String? locationCode;
  final String? locationName;

  const CreateAssetPage({
    super.key,
    required this.assetNo,
    this.plantCode,
    this.locationCode,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssetCreationBloc>()..add(LoadMasterData()),
      child: CreateAssetView(
        assetNo: assetNo,
        plantCode: plantCode,
        locationCode: locationCode,
        locationName: locationName,
      ),
    );
  }
}

class CreateAssetView extends StatefulWidget {
  final String assetNo;
  final String? plantCode;
  final String? locationCode;
  final String? locationName;

  const CreateAssetView({
    super.key,
    required this.assetNo,
    this.plantCode,
    this.locationCode,
    this.locationName,
  });

  @override
  State<CreateAssetView> createState() => _CreateAssetViewState();
}

class _CreateAssetViewState extends State<CreateAssetView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _serialController = TextEditingController();
  final _inventoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String? _selectedPlant;
  String? _selectedLocation;
  String? _selectedUnit;
  String? _selectedDepartment;

  bool get _hasLocationData => widget.locationCode != null;

  @override
  void initState() {
    super.initState();
    if (_hasLocationData) {
      _selectedLocation = widget.locationCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AssetCreationBloc, AssetCreationState>(
      listener: (context, state) {
        if (state is AssetCreated) {
          Helpers.showSuccess(context, 'Asset created successfully');
          Navigator.of(context).pop(state.asset);
        } else if (state is AssetCreationError) {
          Helpers.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(theme),
        body: BlocBuilder<AssetCreationBloc, AssetCreationState>(
          builder: (context, state) {
            if (state is MasterDataLoading) {
              return _buildLoadingView(theme);
            }

            if (state is MasterDataLoaded) {
              return _buildForm(context, theme, state);
            }

            if (state is AssetCreating) {
              return _buildCreatingView(theme);
            }

            if (state is AssetCreationError) {
              return _buildErrorView(context, theme, state.message);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      elevation: 1,
      title: Row(
        children: [
          Text(
            'Create New Asset',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading form data...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: AppColors.success,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Creating asset...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we create your asset',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ThemeData theme,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AssetCreationBloc>().add(LoadMasterData()),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    ThemeData theme,
    MasterDataLoaded state,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Header Card
          _buildHeaderCard(),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionCard(
                    title: 'Basic Information',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    children: [
                      // Asset Number (Read-only)
                      _buildReadOnlyField(
                        label: 'Asset Number',
                        value: widget.assetNo,
                        icon: Icons.qr_code,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _buildTextFormField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        isRequired: true,
                        validator: Validators.description,
                        hint: 'Enter asset description',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location Information Section
                  _buildSectionCard(
                    title: 'Location Information',
                    icon: Icons.location_on,
                    color: AppColors.info,
                    children: [
                      if (_hasLocationData) ...[
                        // Read-only ถ้ามี location data
                        _buildDropdownField<String>(
                          value: _selectedPlant,
                          label: 'Plant',
                          icon: Icons.business,
                          isRequired: true,
                          items: state.plants
                              .map(
                                (plant) => DropdownMenuItem(
                                  value: plant.plantCode,
                                  child: Text(plant.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlant = value;
                              _selectedLocation = null;
                            });
                            if (value != null) {
                              context.read<AssetCreationBloc>().add(
                                PlantSelected(value),
                              );
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Please select a plant' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Location Code',
                          value: widget.locationCode!,
                          icon: Icons.place,
                        ),
                        if (widget.locationName != null) ...[
                          const SizedBox(height: 16),
                          _buildReadOnlyField(
                            label: 'Location Name',
                            value: widget.locationName!,
                            icon: Icons.location_city,
                          ),
                        ],
                      ] else ...[
                        // Dropdown ถ้าไม่มี location data
                        _buildDropdownField<String>(
                          value: _selectedPlant,
                          label: 'Plant',
                          icon: Icons.business,
                          isRequired: true,
                          items: state.plants
                              .map(
                                (plant) => DropdownMenuItem(
                                  value: plant.plantCode,
                                  child: Text(plant.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlant = value;
                              _selectedLocation = null;
                            });
                            if (value != null) {
                              context.read<AssetCreationBloc>().add(
                                PlantSelected(value),
                              );
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Please select a plant' : null,
                        ),
                        const SizedBox(height: 16),

                        // Location Dropdown
                        _buildDropdownField<String>(
                          value: _selectedLocation,
                          label: 'Location',
                          icon: Icons.place,
                          isRequired: true,
                          items: state.locations
                              .map(
                                (location) => DropdownMenuItem(
                                  value: location.locationCode,
                                  child: Text(location.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedLocation = value),
                          validator: (value) =>
                              value == null ? 'Please select a location' : null,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Department Dropdown
                      _buildDropdownField<String>(
                        value: _selectedDepartment,
                        label: 'Department',
                        icon: Icons.corporate_fare,
                        isRequired: false,
                        items: state.departments
                            .map(
                              (department) => DropdownMenuItem(
                                value: department.deptCode,
                                child: Text(department.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value);
                          if (value != null) {
                            context.read<AssetCreationBloc>().add(
                              DepartmentSelected(value),
                            );
                          }
                        },
                        validator: null, // Optional field
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quantity Information Section
                  _buildSectionCard(
                    title: 'Quantity Information',
                    icon: Icons.straighten,
                    color: AppColors.warning,
                    children: [
                      Row(
                        children: [
                          // Unit Dropdown
                          Expanded(
                            flex: 2,
                            child: _buildDropdownField<String>(
                              value: _selectedUnit,
                              label: 'Unit',
                              icon: Icons.category,
                              isRequired: true,
                              items: state.units
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit.unitCode,
                                      child: Text(unit.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedUnit = value),
                              validator: (value) =>
                                  value == null ? 'Please select a unit' : null,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Quantity
                          Expanded(
                            child: _buildTextFormField(
                              controller: _quantityController,
                              label: 'Quantity',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                              validator: Validators.positiveNumber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Optional Information Section
                  _buildSectionCard(
                    title: 'Optional Information',
                    icon: Icons.info_outline,
                    color: AppColors.textSecondary,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _serialController,
                              label: 'Serial Number',
                              icon: Icons.tag,
                              hint: 'Optional',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _inventoryController,
                              label: 'Inventory Number',
                              icon: Icons.inventory,
                              hint: 'Optional',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_circle, color: AppColors.onPrimary, size: 48),
          const SizedBox(height: 12),
          Text(
            'Creating Unknown Asset',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.assetNo,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool isRequired = false,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      dropdownColor: AppColors.surface,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textTertiary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _submitForm,
          icon: const Icon(Icons.save),
          label: const Text(
            'Create Asset',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final userId = await getIt.get<GetCurrentUserUseCase>().execute();

        final request = CreateAssetRequest(
          assetNo: widget.assetNo,
          description: _descriptionController.text,
          plantCode: _selectedPlant!,
          locationCode: widget.locationCode ?? _selectedLocation!,
          unitCode: _selectedUnit!,
          deptCode: _selectedDepartment, // เพิ่มนี้
          serialNo: _serialController.text.isNotEmpty
              ? _serialController.text
              : null,
          inventoryNo: _inventoryController.text.isNotEmpty
              ? _inventoryController.text
              : null,
          quantity: double.tryParse(_quantityController.text),
          createdBy: userId,
        );

        context.read<AssetCreationBloc>().add(CreateAssetSubmitted(request));
      } catch (e) {
        Helpers.showError(context, 'Failed to get current user');
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _serialController.dispose();
    _inventoryController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
