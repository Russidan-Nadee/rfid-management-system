import 'package:flutter/material.dart';
import '../../../../l10n/features/admin/admin_localizations.dart';

class AssetSearchWidget extends StatefulWidget {
  final BoxConstraints? constraints;
  final Function({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  }) onSearch;

  const AssetSearchWidget({
    super.key,
    this.constraints,
    required this.onSearch,
  });

  @override
  State<AssetSearchWidget> createState() => _AssetSearchWidgetState();
}

class _AssetSearchWidgetState extends State<AssetSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPlant;
  String? _selectedLocation;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AdminLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.searchTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResponsiveLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    final screenWidth = widget.constraints?.maxWidth ?? MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;
    
    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    final l10n = AdminLocalizations.of(context);
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: l10n.searchHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.statusFilter,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.statusAll)),
                  DropdownMenuItem(value: 'A', child: Text(l10n.statusAwaiting)),
                  DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
                  DropdownMenuItem(value: 'I', child: Text(l10n.statusInactive)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _performSearch,
                child: Text(l10n.searchButton),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _clearSearch,
                child: Text(l10n.clearButton),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    final l10n = AdminLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: l10n.searchHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: l10n.statusFilter,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.statusAll)),
                  DropdownMenuItem(value: 'A', child: Text(l10n.statusAwaiting)),
                  DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
                  DropdownMenuItem(value: 'I', child: Text(l10n.statusInactive)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _performSearch,
              child: Text(l10n.searchButton),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _clearSearch,
              child: Text(l10n.clearButton),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    final l10n = AdminLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: l10n.searchHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: l10n.statusFilter,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.statusAll)),
              DropdownMenuItem(value: 'A', child: Text(l10n.statusAwaiting)),
              DropdownMenuItem(value: 'C', child: Text(l10n.statusChecked)),
              DropdownMenuItem(value: 'I', child: Text(l10n.statusInactive)),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _performSearch,
          child: Text(l10n.searchButton),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: _clearSearch,
          child: Text(l10n.clearButton),
        ),
      ],
    );
  }

  void _performSearch() {
    widget.onSearch(
      searchTerm: _searchController.text.trim().isNotEmpty 
          ? _searchController.text.trim()
          : null,
      status: _selectedStatus,
      plantCode: _selectedPlant,
      locationCode: _selectedLocation,
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _selectedPlant = null;
      _selectedLocation = null;
    });
    _performSearch();
  }
}