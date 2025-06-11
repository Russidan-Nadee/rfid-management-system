// Path: frontend/lib/features/search/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../domain/entities/search_result_entity.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchBloc>(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Search'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Input
                  BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      return TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ค้นหา assets, plants, locations...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<SearchBloc>().add(
                                      ClearSearch(),
                                    );
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (query) {
                          context.read<SearchBloc>().add(
                            SearchQueryChanged(query),
                          );
                        },
                        onSubmitted: (query) {
                          context.read<SearchBloc>().add(
                            SearchSubmitted(query),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Filter Buttons
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Active', 'Inactive'].map((
                              filter,
                            ) {
                              final isSelected = _selectedFilter == filter;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: Colors.blue[100],
                                  checkmarkColor: Colors.blue,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return _buildInitialState();
                  } else if (state is SearchLoading) {
                    return _buildLoadingState(state.query);
                  } else if (state is SearchSuccess) {
                    return _buildSuccessState(state);
                  } else if (state is SearchEmpty) {
                    return _buildEmptyState(state.query);
                  } else if (state is SearchError) {
                    return _buildErrorState(state);
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'เริ่มต้นค้นหา',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'พิมพ์คำค้นหาเพื่อดูผลลัพธ์',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('กำลังค้นหา "$query"...'),
        ],
      ),
    );
  }

  Widget _buildSuccessState(SearchSuccess state) {
    return Column(
      children: [
        // Results Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'ผลการค้นหา "${state.query}" (${state.totalResults} รายการ)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (state.fromCache) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Cached',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Results List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final result = state.results[index];
              return _buildResultCard(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(SearchResultEntity result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEntityColor(result.entityType),
          child: Text(result.entityIcon, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.subtitle),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getEntityColor(result.entityType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.entityType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getEntityColor(result.entityType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (result.status != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(result.status!).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(result.status!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to detail page
          _showResultDetail(result);
        },
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'ไม่พบผลลัพธ์สำหรับ "$query"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'ลองใช้คำค้นหาอื่น หรือตรวจสอบการสะกด',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SearchError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<SearchBloc>().add(SearchSubmitted(state.query));
            },
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  Color _getEntityColor(String entityType) {
    switch (entityType) {
      case 'assets':
        return Colors.blue;
      case 'plants':
        return Colors.green;
      case 'locations':
        return Colors.orange;
      case 'users':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ACTIVE':
        return Colors.green;
      case 'C':
      case 'CREATED':
        return Colors.blue;
      case 'I':
      case 'INACTIVE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showResultDetail(SearchResultEntity result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${result.entityType}'),
            Text('ID: ${result.id}'),
            if (result.description != null)
              Text('Description: ${result.description}'),
            if (result.status != null) Text('Status: ${result.statusLabel}'),
            if (result.plantCode != null) Text('Plant: ${result.plantCode}'),
            if (result.locationCode != null)
              Text('Location: ${result.locationCode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
