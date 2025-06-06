// Path: frontend/lib/features/export/presentation/widgets/export_config_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_config_entity.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';

class ExportConfigForm extends StatefulWidget {
  const ExportConfigForm({super.key});

  @override
  State<ExportConfigForm> createState() => _ExportConfigFormState();
}

class _ExportConfigFormState extends State<ExportConfigForm>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedExportType = 'assets';
  String _selectedFormat = 'xlsx';
  final List<String> _selectedPlants = [];
  final List<String> _selectedLocations = [];
  final List<String> _selectedStatus = ['A'];
  DateTimeRange? _dateRange;

  // Mock data - in real app would come from API
  final List<String> _availablePlants = ['PLANT-A', 'PLANT-B', 'PLANT-C'];
  final List<String> _availableLocations = [
    'LOC-001',
    'LOC-002',
    'LOC-003',
    'LOC-004',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ExportBloc, ExportState>(
      builder: (context, state) {
        final isLoading = state is ExportCreating || state is ExportLoading;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 2,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildExportTypeSelection(theme, isLoading),
                  const SizedBox(height: 24),
                  _buildFormatSelection(theme, isLoading),
                  const SizedBox(height: 24),
                  _buildFiltersSection(theme, isLoading),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme, isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Configuration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Configure your export settings and filters',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _resetConfiguration(),
          icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
          tooltip: 'Reset to defaults',
        ),
      ],
    );
  }

  Widget _buildExportTypeSelection(ThemeData theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, Icons.category, 'Export Type'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildExportTypeCard(
                theme,
                'assets',
                'Assets',
                'All asset information',
                Icons.inventory_2,
                isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportTypeCard(
                theme,
                'scan_logs',
                'Scan Logs',
                'RFID scan history',
                Icons.qr_code_scanner,
                isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExportTypeCard(
                theme,
                'status_history',
                'Status History',
                'Asset status changes',
                Icons.history,
                isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportTypeCard(
    ThemeData theme,
    String type,
    String title,
    String description,
    IconData icon,
    bool isLoading,
  ) {
    final isSelected = _selectedExportType == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: isLoading ? null : () => _selectExportType(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatSelection(ThemeData theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, Icons.description, 'File Format'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormatButton(
                theme,
                'xlsx',
                '📊 Excel (.xlsx)',
                'Spreadsheet with formatting',
                isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatButton(
                theme,
                'csv',
                '📄 CSV (.csv)',
                'Plain text, comma-separated',
                isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatButton(
    ThemeData theme,
    String format,
    String title,
    String description,
    bool isLoading,
  ) {
    final isSelected = _selectedFormat == format;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: isLoading ? null : () => _selectFormat(format),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, Icons.filter_list, 'Filters (Optional)'),
        const SizedBox(height: 12),

        // Quick Filter Pills
        if (_hasAnyFilters()) ...[
          _buildActiveFiltersPills(theme),
          const SizedBox(height: 16),
        ],

        // Filter Controls
        Row(
          children: [
            Expanded(
              child: _buildMultiSelectFilter(
                theme,
                'Plants',
                _selectedPlants,
                _availablePlants,
                isLoading,
                onChanged: _updatePlantFilters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMultiSelectFilter(
                theme,
                'Locations',
                _selectedLocations,
                _availableLocations,
                isLoading,
                onChanged: _updateLocationFilters,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildStatusFilter(theme, isLoading)),
            const SizedBox(width: 12),
            Expanded(child: _buildDateRangeFilter(theme, isLoading)),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveFiltersPills(ThemeData theme) {
    final activePills = <Widget>[];

    for (final plant in _selectedPlants) {
      activePills.add(
        _buildFilterPill(
          theme,
          'Plant: $plant',
          () => _removePlantFilter(plant),
        ),
      );
    }

    for (final location in _selectedLocations) {
      activePills.add(
        _buildFilterPill(
          theme,
          'Location: $location',
          () => _removeLocationFilter(location),
        ),
      );
    }

    for (final status in _selectedStatus) {
      final statusLabel = _getStatusLabel(status);
      activePills.add(
        _buildFilterPill(
          theme,
          'Status: $statusLabel',
          () => _removeStatusFilter(status),
        ),
      );
    }

    if (_dateRange != null) {
      activePills.add(
        _buildFilterPill(theme, 'Date Range', () => _clearDateRange()),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...activePills,
        if (activePills.isNotEmpty) _buildClearAllButton(theme),
      ],
    );
  }

  Widget _buildFilterPill(
    ThemeData theme,
    String label,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllButton(ThemeData theme) {
    return InkWell(
      onTap: _clearAllFilters,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.clear_all, size: 16, color: Colors.red[700]),
            const SizedBox(width: 4),
            Text(
              'Clear All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectFilter(
    ThemeData theme,
    String label,
    List<String> selectedItems,
    List<String> availableItems,
    bool isLoading, {
    required Function(List<String>) onChanged,
  }) {
    return InkWell(
      onTap: isLoading
          ? null
          : () => _showMultiSelectDialog(
              label,
              selectedItems,
              availableItems,
              onChanged,
            ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedItems.isEmpty
                  ? 'Select $label...'
                  : '${selectedItems.length} selected',
              style: TextStyle(
                fontSize: 14,
                color: selectedItems.isEmpty
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(ThemeData theme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStatusChip(theme, 'A', 'Active', isLoading),
            _buildStatusChip(theme, 'C', 'Checked', isLoading),
            _buildStatusChip(theme, 'I', 'Inactive', isLoading),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    String status,
    String label,
    bool isLoading,
  ) {
    final isSelected = _selectedStatus.contains(status);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isLoading ? null : (selected) => _toggleStatusFilter(status),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontSize: 12,
      ),
    );
  }

  Widget _buildDateRangeFilter(ThemeData theme, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : _selectDateRange,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateRange == null
                  ? 'Select date range...'
                  : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
              style: TextStyle(
                fontSize: 14,
                color: _dateRange == null
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isLoading) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: isLoading ? null : _clearAllFilters,
          icon: const Icon(Icons.clear),
          label: const Text('Clear Filters'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _createExport,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.file_download),
            label: Text(isLoading ? 'Creating Export...' : 'Generate Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Event Handlers
  void _selectExportType(String type) {
    setState(() {
      _selectedExportType = type;
    });
    _updateConfiguration();
  }

  void _selectFormat(String format) {
    setState(() {
      _selectedFormat = format;
    });
    _updateConfiguration();
  }

  void _updatePlantFilters(List<String> plants) {
    setState(() {
      _selectedPlants.clear();
      _selectedPlants.addAll(plants);
    });
    _updateConfiguration();
  }

  void _updateLocationFilters(List<String> locations) {
    setState(() {
      _selectedLocations.clear();
      _selectedLocations.addAll(locations);
    });
    _updateConfiguration();
  }

  void _removePlantFilter(String plant) {
    setState(() {
      _selectedPlants.remove(plant);
    });
    _updateConfiguration();
  }

  void _removeLocationFilter(String location) {
    setState(() {
      _selectedLocations.remove(location);
    });
    _updateConfiguration();
  }

  void _toggleStatusFilter(String status) {
    setState(() {
      if (_selectedStatus.contains(status)) {
        _selectedStatus.remove(status);
      } else {
        _selectedStatus.add(status);
      }
    });
    _updateConfiguration();
  }

  void _removeStatusFilter(String status) {
    setState(() {
      _selectedStatus.remove(status);
    });
    _updateConfiguration();
  }

  void _clearDateRange() {
    setState(() {
      _dateRange = null;
    });
    _updateConfiguration();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedPlants.clear();
      _selectedLocations.clear();
      _selectedStatus.clear();
      _selectedStatus.add('A'); // Default to active
      _dateRange = null;
    });
    _updateConfiguration();
  }

  void _resetConfiguration() {
    setState(() {
      _selectedExportType = 'assets';
      _selectedFormat = 'xlsx';
      _selectedPlants.clear();
      _selectedLocations.clear();
      _selectedStatus.clear();
      _selectedStatus.add('A');
      _dateRange = null;
    });
    _updateConfiguration();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _updateConfiguration();
    }
  }

  Future<void> _showMultiSelectDialog(
    String title,
    List<String> selectedItems,
    List<String> availableItems,
    Function(List<String>) onChanged,
  ) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _MultiSelectDialog(
        title: title,
        selectedItems: selectedItems,
        availableItems: availableItems,
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  void _updateConfiguration() {
    final filters = ExportFiltersEntity(
      plantCodes: _selectedPlants.isNotEmpty ? _selectedPlants : null,
      locationCodes: _selectedLocations.isNotEmpty ? _selectedLocations : null,
      status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
      dateRange: _dateRange != null
          ? DateRangeEntity(from: _dateRange!.start, to: _dateRange!.end)
          : null,
    );

    final config = ExportConfigEntity(
      format: _selectedFormat,
      filters: filters,
    );

    context.read<ExportBloc>().add(UpdateExportConfig(config));
  }

  void _createExport() {
    final filters = ExportFiltersEntity(
      plantCodes: _selectedPlants.isNotEmpty ? _selectedPlants : null,
      locationCodes: _selectedLocations.isNotEmpty ? _selectedLocations : null,
      status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
      dateRange: _dateRange != null
          ? DateRangeEntity(from: _dateRange!.start, to: _dateRange!.end)
          : null,
    );

    final config = ExportConfigEntity(
      format: _selectedFormat,
      filters: filters,
    );

    context.read<ExportBloc>().add(
      CreateExportJobRequested(exportType: _selectedExportType, config: config),
    );
  }

  // Helper Methods
  bool _hasAnyFilters() {
    return _selectedPlants.isNotEmpty ||
        _selectedLocations.isNotEmpty ||
        _selectedStatus.length > 1 ||
        !_selectedStatus.contains('A') ||
        _dateRange != null;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'A':
        return 'Active';
      case 'C':
        return 'Checked';
      case 'I':
        return 'Inactive';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> selectedItems;
  final List<String> availableItems;

  const _MultiSelectDialog({
    required this.title,
    required this.selectedItems,
    required this.availableItems,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedItems.clear();
                      _selectedItems.addAll(widget.availableItems);
                    });
                  },
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedItems.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableItems.length,
                itemBuilder: (context, index) {
                  final item = widget.availableItems[index];
                  final isSelected = _selectedItems.contains(item);

                  return CheckboxListTile(
                    title: Text(item),
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedItems),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
