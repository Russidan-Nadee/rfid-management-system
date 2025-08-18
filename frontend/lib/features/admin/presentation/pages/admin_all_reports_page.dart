import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';
import '../widgets/admin_report_card_widget.dart';

class AdminAllReportsPage extends StatefulWidget {
  const AdminAllReportsPage({super.key});

  @override
  State<AdminAllReportsPage> createState() => _AdminAllReportsPageState();
}

class _AdminAllReportsPageState extends State<AdminAllReportsPage> {
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter state
  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedProblemType;
  String? _selectedPlantCode;
  String? _selectedLocationCode;

  // Master data for dropdowns
  List<dynamic> _plants = [];
  List<dynamic> _locations = [];
  bool _masterDataLoaded = false;

  // Filter bar collapse state
  bool _isFilterExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
    _loadAllReports();
  }

  Future<void> _loadAllReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authState = context.read<AuthBloc>().state;
      final isAdmin =
          authState is AuthAuthenticated &&
          (authState.user.isAdmin || authState.user.isManager);

      final notificationService = getIt<NotificationService>();

      final response = isAdmin
          ? await notificationService.getAllReports(
              limit: 100,
              sortBy: 'created_at',
              sortOrder: 'desc',
              status: _selectedStatus,
              priority: _selectedPriority,
              problemType: _selectedProblemType,
              plantCode: _selectedPlantCode,
              locationCode: _selectedLocationCode,
            )
          : await notificationService.getMyReports();

      if (response.success && response.data != null) {
        List<dynamic> notifications = [];

        if (isAdmin) {
          final data = response.data! as Map<String, dynamic>;
          if (data['notifications'] != null) {
            notifications = data['notifications'] as List<dynamic>;
          }
        } else {
          notifications = response.data! as List<dynamic>;
        }

        setState(() {
          _reports = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to load reports';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading reports: $e';
        _isLoading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedProblemType = null;
      _selectedPlantCode = null;
      _selectedLocationCode = null;
    });
    _loadAllReports();
  }

  Future<void> _loadMasterData() async {
    try {
      final notificationService = getIt<NotificationService>();
      final response = await notificationService.getMasterData();

      if (response.success && response.data != null) {
        final data = response.data!;
        setState(() {
          _plants = data['plants'] ?? [];
          _locations = data['locations'] ?? [];
          _masterDataLoaded = true;
        });
      } else {
        print('Failed to load master data: ${response.message}');
      }
    } catch (e) {
      print('Error loading master data: $e');
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity, // Full width
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: isDark ? AppColors.darkText : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Reports',
                style: AppTextStyles.subtitle1.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Active filter indicator
              if (_hasActiveFilters()) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getActiveFilterCount()} active',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Collapse/Expand button
              InkWell(
                onTap: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isFilterExpanded ? 'Hide' : 'Show',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.darkText : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isFilterExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          color: isDark ? AppColors.darkText : AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isFilterExpanded ? 1.0 : 0.0,
              child: Column(
                children: [
                  const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final isWideScreen = availableWidth > 1400;
              final isMediumScreen = availableWidth > 900;
              
              if (isWideScreen) {
                // Extra large screens: All filters in one row with full width
                return _buildFullWidthLayout();
              } else if (isMediumScreen) {
                // Medium screens: 3 filters per row
                return _buildMediumScreenLayout();
              } else {
                // Small screens: 2 filters per row
                return _buildSmallScreenLayout();
              }
            },
          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extra large screens: Full width layout with equal spacing
  Widget _buildFullWidthLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildFilterDropdown(
            hint: 'Status',
            value: _selectedStatus,
            items: [
              'pending',
              'acknowledged',
              'in_progress',
              'resolved',
              'cancelled',
            ],
            includeAllOption: true,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
              _loadAllReports();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildFilterDropdown(
            hint: 'Priority',
            value: _selectedPriority,
            items: ['low', 'normal', 'high', 'critical'],
            includeAllOption: true,
            onChanged: (value) {
              setState(() {
                _selectedPriority = value;
              });
              _loadAllReports();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildFilterDropdown(
            hint: 'Problem Type',
            value: _selectedProblemType,
            items: [
              'asset_damage',
              'asset_missing',
              'location_issue',
              'data_error',
              'urgent_issue',
              'other',
            ],
            includeAllOption: true,
            onChanged: (value) {
              setState(() {
                _selectedProblemType = value;
              });
              _loadAllReports();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildPlantDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildLocationDropdown(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildClearFiltersButton(),
        ),
      ],
    );
  }

  // Large screens: All filters in one row
  Widget _buildSingleRowLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown(
            hint: 'Status',
            value: _selectedStatus,
            items: [
              'pending',
              'acknowledged',
              'in_progress',
              'resolved',
              'cancelled',
            ],
            includeAllOption: true,
            width: 180,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
              _loadAllReports();
            },
          ),
          AppSpacing.horizontalSpaceMD,
          _buildFilterDropdown(
            hint: 'Priority',
            value: _selectedPriority,
            items: ['low', 'normal', 'high', 'critical'],
            includeAllOption: true,
            width: 150,
            onChanged: (value) {
              setState(() {
                _selectedPriority = value;
              });
              _loadAllReports();
            },
          ),
          AppSpacing.horizontalSpaceMD,
          _buildFilterDropdown(
            hint: 'Problem Type',
            value: _selectedProblemType,
            items: [
              'asset_damage',
              'asset_missing',
              'location_issue',
              'data_error',
              'urgent_issue',
              'other',
            ],
            includeAllOption: true,
            width: 180,
            onChanged: (value) {
              setState(() {
                _selectedProblemType = value;
              });
              _loadAllReports();
            },
          ),
          AppSpacing.horizontalSpaceMD,
          _buildPlantDropdown(width: 200),
          AppSpacing.horizontalSpaceMD,
          _buildLocationDropdown(width: 200),
          AppSpacing.horizontalSpaceMD,
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  // Medium screens: 3 filters per row
  Widget _buildMediumScreenLayout() {
    return Column(
      children: [
        // First row: Status, Priority, Problem Type
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Status',
                value: _selectedStatus,
                items: [
                  'pending',
                  'acknowledged',
                  'in_progress',
                  'resolved',
                  'cancelled',
                ],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Priority',
                value: _selectedPriority,
                items: ['low', 'normal', 'high', 'critical'],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Problem Type',
                value: _selectedProblemType,
                items: [
                  'asset_damage',
                  'asset_missing',
                  'location_issue',
                  'data_error',
                  'urgent_issue',
                  'other',
                ],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedProblemType = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        // Second row: Plant, Location, Clear Button
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildPlantDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildLocationDropdown(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildClearFiltersButton(),
            ),
          ],
        ),
      ],
    );
  }

  // Small screens: 2 filters per row
  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        // First row: Status, Priority
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Status',
                value: _selectedStatus,
                items: [
                  'pending',
                  'acknowledged',
                  'in_progress',
                  'resolved',
                  'cancelled',
                ],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Priority',
                value: _selectedPriority,
                items: ['low', 'normal', 'high', 'critical'],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        // Second row: Problem Type, Plant
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                hint: 'Problem Type',
                value: _selectedProblemType,
                items: [
                  'asset_damage',
                  'asset_missing',
                  'location_issue',
                  'data_error',
                  'urgent_issue',
                  'other',
                ],
                includeAllOption: true,
                onChanged: (value) {
                  setState(() {
                    _selectedProblemType = value;
                  });
                  _loadAllReports();
                },
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(child: _buildPlantDropdown()),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        // Third row: Location, Clear Button
        Row(
          children: [
            Expanded(child: _buildLocationDropdown()),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildClearFiltersButton(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool includeAllOption = false,
    double? width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<DropdownMenuItem<String>> dropdownItems = [];
    
    // Add "All" option if requested
    if (includeAllOption) {
      dropdownItems.add(
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            'All ${hint}s',
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    
    // Add the regular items
    dropdownItems.addAll(
      items.map((String itemValue) {
        return DropdownMenuItem<String>(
          value: itemValue,
          child: Text(
            _formatFilterDisplayText(itemValue),
            style: AppTextStyles.body1.copyWith(
              color: isDark ? AppColors.darkText : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );

    final dropdown = Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        hint: Text(
          hint,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        items: dropdownItems,
        onChanged: onChanged,
        underline: const SizedBox(), // Remove default underline
        isExpanded: true,
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? AppColors.darkText : AppColors.primary,
        ),
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: AppTextStyles.body1.copyWith(
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        ),
      ),
    );

    return width != null ? dropdown : Flexible(child: dropdown);
  }

  String _formatFilterDisplayText(String value) {
    // Convert underscore-separated values to readable text
    switch (value) {
      case 'in_progress':
        return 'In Progress';
      case 'asset_damage':
        return 'Asset Damage';
      case 'asset_missing':
        return 'Asset Missing';
      case 'location_issue':
        return 'Location Issue';
      case 'data_error':
        return 'Data Error';
      case 'urgent_issue':
        return 'Urgent Issue';
      default:
        // Capitalize first letter for simple values
        return value.substring(0, 1).toUpperCase() + value.substring(1);
    }
  }

  Widget _buildFilterTextField({
    required String hint,
    required ValueChanged<String> onSubmitted,
  }) {
    return SizedBox(
      width: 150,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }

  Widget _buildPlantDropdown({double? width}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!_masterDataLoaded || _plants.isEmpty) {
      final loading = Container(
        width: width,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
      return width != null ? loading : Flexible(child: loading);
    }

    final dropdown = Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        hint: Text(
          'Plant',
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        value: _selectedPlantCode,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? AppColors.darkText : AppColors.primary,
        ),
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: AppTextStyles.body1.copyWith(
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'All Plants',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ..._plants.map((plant) {
            final plantCode = plant['plant_code'] as String;
            final description = plant['description'] as String?;
            final displayText = description != null && description.isNotEmpty
                ? '$plantCode - $description'
                : plantCode;
            
            return DropdownMenuItem<String>(
              value: plantCode,
              child: Text(
                displayText,
                style: AppTextStyles.body1.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPlantCode = value;
            // Clear location when plant changes
            if (_selectedLocationCode != null && value != _selectedPlantCode) {
              _selectedLocationCode = null;
            }
          });
          _loadAllReports();
        },
      ),
    );

    return width != null ? dropdown : Flexible(child: dropdown);
  }

  Widget _buildLocationDropdown({double? width}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!_masterDataLoaded || _locations.isEmpty) {
      final loading = Container(
        width: width,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
      return width != null ? loading : Flexible(child: loading);
    }

    // Filter locations based on selected plant
    List<dynamic> filteredLocations = _locations;
    if (_selectedPlantCode != null) {
      filteredLocations = _locations.where((location) {
        return location['plant_code'] == _selectedPlantCode;
      }).toList();
    }

    final dropdown = Container(
      width: width,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        hint: Text(
          'Location',
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        value: _selectedLocationCode,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? AppColors.darkText : AppColors.primary,
        ),
        dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
        style: AppTextStyles.body1.copyWith(
          color: isDark ? AppColors.darkText : AppColors.textPrimary,
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              'All Locations',
              style: AppTextStyles.body1.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...filteredLocations.map((location) {
            final locationCode = location['location_code'] as String;
            final description = location['description'] as String?;
            final displayText = description != null && description.isNotEmpty
                ? '$locationCode - $description'
                : locationCode;
            
            return DropdownMenuItem<String>(
              value: locationCode,
              child: Text(
                displayText,
                style: AppTextStyles.body1.copyWith(
                  color: isDark ? AppColors.darkText : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ],
        onChanged: (value) {
          setState(() {
            _selectedLocationCode = value;
          });
          _loadAllReports();
        },
      ),
    );

    return width != null ? dropdown : Flexible(child: dropdown);
  }

  Widget _buildClearFiltersButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48, // Match dropdown height
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _clearFilters,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              'Clear',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedStatus != null ||
           _selectedPriority != null ||
           _selectedProblemType != null ||
           _selectedPlantCode != null ||
           _selectedLocationCode != null;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedStatus != null) count++;
    if (_selectedPriority != null) count++;
    if (_selectedProblemType != null) count++;
    if (_selectedPlantCode != null) count++;
    if (_selectedLocationCode != null) count++;
    return count;
  }

  Future<void> _testApiConnection() async {
    print('🧪 Testing Frontend API Connection...');

    try {
      final notificationService = getIt<NotificationService>();

      // Get current user role
      final authState = context.read<AuthBloc>().state;
      final isAdmin =
          authState is AuthAuthenticated &&
          (authState.user.isAdmin || authState.user.isManager);

      print('🔍 Current user is admin/manager: $isAdmin');

      if (isAdmin) {
        // Test 1: Check counts endpoint (admin only)
        print('📊 Testing notification counts...');
        final countsResponse = await notificationService
            .getNotificationCounts();
        print('Counts Response - Success: ${countsResponse.success}');
        print('Counts Response - Message: ${countsResponse.message}');
        print('Counts Response - Data: ${countsResponse.data}');

        // Test 2: Check all reports endpoint (admin only)
        print('📋 Testing all-reports endpoint...');
        final notificationsResponse = await notificationService.getAllReports(
          limit: 10,
          sortBy: 'created_at',
          sortOrder: 'desc',
        );
        print(
          'All Reports Response - Success: ${notificationsResponse.success}',
        );
        print(
          'All Reports Response - Message: ${notificationsResponse.message}',
        );
        if (notificationsResponse.data != null) {
          print(
            'All Reports Response - Data Keys: ${notificationsResponse.data!.keys}',
          );
          if (notificationsResponse.data!['notifications'] != null) {
            final notifications =
                notificationsResponse.data!['notifications'] as List;
            print('Found ${notifications.length} notifications from all users');
          }
        }
      } else {
        // Test: Check my reports endpoint (regular user)
        print('📋 Testing my-reports endpoint...');
        final myReportsResponse = await notificationService.getMyReports();
        print('My Reports Response - Success: ${myReportsResponse.success}');
        print('My Reports Response - Message: ${myReportsResponse.message}');
        if (myReportsResponse.data != null) {
          final myReports = myReportsResponse.data as List;
          print('Found ${myReports.length} personal reports');
        }
      }

      // Show results in UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Test Complete (Admin Mode) - Check console'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ Frontend API test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Test Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_reports.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: _UniformCardGrid(
          reports: _reports,
          onReportUpdated: _loadAllReports,
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AdminLocalizations.of(context).loadingAllReports),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              AdminLocalizations.of(context).errorLoadingReports,
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton.icon(
              onPressed: _loadAllReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: AppSpacing.buttonPaddingSymmetric,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: AppSpacing.paddingXXL,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: isDark ? AppColors.darkText : AppColors.primary,
                size: 60,
              ),
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              AdminLocalizations.of(context).noReportsFound,
              style: AppTextStyles.headline4.copyWith(
                color: isDark ? AppColors.darkText : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              AdminLocalizations.of(context).noReportsFoundMessage,
              style: AppTextStyles.body1.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Auto-adjusting grid where each row height adjusts to its tallest card
class _UniformCardGrid extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const _UniformCardGrid({
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        int crossAxisCount;

        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4; // Extra large screens: 4 columns
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3; // Large screens: 3 columns
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 2; // Medium screens: 2 columns
        } else {
          crossAxisCount = 1; // Small screens: 1 column
        }

        return _buildAutoAdjustingGrid(crossAxisCount: crossAxisCount);
      },
    );
  }

  Widget _buildAutoAdjustingGrid({required int crossAxisCount}) {
    final rows = <Widget>[];

    // Group reports into rows
    for (int i = 0; i < reports.length; i += crossAxisCount) {
      final rowReports = <dynamic>[];

      // Collect reports for this row
      for (int j = 0; j < crossAxisCount; j++) {
        final index = i + j;
        if (index < reports.length) {
          rowReports.add(reports[index]);
        }
      }

      // Create row with IntrinsicHeight to auto-adjust height
      rows.add(
        Container(
          margin: EdgeInsets.only(
            bottom: i + crossAxisCount < reports.length ? 16 : 0,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  rowReports.asMap().entries.map((entry) {
                    final j = entry.key;
                    final report = entry.value;

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: j < rowReports.length - 1 ? 16 : 0,
                        ),
                        child: AdminReportCardWidget(
                          report: report,
                          onReportUpdated: onReportUpdated,
                        ),
                      ),
                    );
                  }).toList() +
                  // Add empty spaces for incomplete rows
                  List.generate(crossAxisCount - rowReports.length, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right:
                              (rowReports.length + index) < crossAxisCount - 1
                              ? 16
                              : 0,
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(child: Column(children: rows));
  }
}
