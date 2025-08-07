import 'package:flutter/material.dart';

class AssetSearchWidget extends StatefulWidget {
  final Function({
    String? searchTerm,
    String? status,
    String? plantCode,
    String? locationCode,
  }) onSearch;

  const AssetSearchWidget({
    super.key,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Assets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Asset No, Description, Serial No...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'A', child: Text('Active')),
                      DropdownMenuItem(value: 'I', child: Text('Inactive')),
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
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _clearSearch,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
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