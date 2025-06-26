// Path: frontend/lib/features/scan/presentation/pages/create_asset_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/scan/presentation/widgets/create/basic_info_section.dart';
import 'package:frontend/features/scan/presentation/widgets/create/create_asset_header.dart';
import 'package:frontend/features/scan/presentation/widgets/create/location_info_section.dart';
import 'package:frontend/features/scan/presentation/widgets/create/quantity_info_section.dart';
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
          CreateAssetHeader(assetNo: widget.assetNo),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  BasicInfoSection(
                    assetNo: widget.assetNo,
                    descriptionController: _descriptionController,
                    descriptionValidator: Validators.description,
                  ),

                  const SizedBox(height: 16),

                  // Location Information Section
                  LocationInfoSection(
                    hasLocationData: _hasLocationData,
                    locationCode: widget.locationCode,
                    locationName: widget.locationName,
                    selectedPlant: _selectedPlant,
                    selectedLocation: _selectedLocation,
                    selectedDepartment: _selectedDepartment,
                    plants: state.plants,
                    locations: state.locations,
                    departments: state.departments,
                    onPlantChanged: (value) {
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
                    onLocationChanged: (value) =>
                        setState(() => _selectedLocation = value),
                    onDepartmentChanged: (value) {
                      setState(() => _selectedDepartment = value);
                      if (value != null) {
                        context.read<AssetCreationBloc>().add(
                          DepartmentSelected(value),
                        );
                      }
                    },
                    plantValidator: (value) =>
                        value == null ? 'Please select a plant' : null,
                    locationValidator: (value) =>
                        value == null ? 'Please select a location' : null,
                  ),

                  const SizedBox(height: 16),

                  // Quantity Information Section
                  QuantityInfoSection(
                    selectedUnit: _selectedUnit,
                    quantityController: _quantityController,
                    serialController: _serialController,
                    inventoryController: _inventoryController,
                    units: state.units,
                    onUnitChanged: (value) =>
                        setState(() => _selectedUnit = value),
                    unitValidator: (value) =>
                        value == null ? 'Please select a unit' : null,
                    quantityValidator: Validators.positiveNumber,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit Button
          SubmitButtonSection(onSubmit: _submitForm),
        ],
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
          deptCode: _selectedDepartment,
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
