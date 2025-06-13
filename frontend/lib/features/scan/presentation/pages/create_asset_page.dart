// Path: lib/features/scan/presentation/pages/create_asset_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../domain/entities/master_data_entity.dart';
import '../bloc/asset_creation_bloc.dart';

class CreateAssetPage extends StatelessWidget {
  final String assetNo;

  const CreateAssetPage({super.key, required this.assetNo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssetCreationBloc>()..add(LoadMasterData()),
      child: CreateAssetView(assetNo: assetNo),
    );
  }
}

class CreateAssetView extends StatefulWidget {
  final String assetNo;

  const CreateAssetView({super.key, required this.assetNo});

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
        appBar: AppBar(
          title: const Text('Create Asset'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: BlocBuilder<AssetCreationBloc, AssetCreationState>(
          builder: (context, state) {
            if (state is MasterDataLoading) {
              return Helpers.buildLoadingWidget(
                message: 'Loading form data...',
              );
            }

            if (state is MasterDataLoaded) {
              return _buildForm(context, theme, state);
            }

            if (state is AssetCreating) {
              return Helpers.buildLoadingWidget(message: 'Creating asset...');
            }

            if (state is AssetCreationError) {
              return Helpers.buildErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<AssetCreationBloc>().add(LoadMasterData()),
              );
            }

            return const SizedBox();
          },
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Number (Read-only)
                    TextFormField(
                      initialValue: widget.assetNo,
                      decoration: const InputDecoration(
                        labelText: 'Asset Number',
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                      ),
                      validator: Validators.description,
                    ),
                    const SizedBox(height: 16),

                    // Plant Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedPlant,
                      decoration: const InputDecoration(labelText: 'Plant *'),
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
                    DropdownButtonFormField<String>(
                      value: _selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                      ),
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
                    const SizedBox(height: 16),

                    // Unit Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit *'),
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
                    const SizedBox(height: 16),

                    // Optional Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _serialController,
                            decoration: const InputDecoration(
                              labelText: 'Serial Number',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _inventoryController,
                            decoration: const InputDecoration(
                              labelText: 'Inventory Number',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: Validators.positiveNumber,
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Asset'),
              ),
            ),
          ],
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
          locationCode: _selectedLocation!,
          unitCode: _selectedUnit!,
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
