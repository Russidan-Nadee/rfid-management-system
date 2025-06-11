// Path: frontend/lib/features/search/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../domain/entities/search_result_entity.dart';

// Import all separated UI widgets
import '../widgets/search_input_bar.dart';
import '../widgets/search_initial_view.dart';
import '../widgets/search_loading_view.dart';
import '../widgets/search_empty_view.dart';
import '../widgets/search_error_view.dart';
import '../widgets/search_result_card.dart';
import '../widgets/search_result_detail_dialog.dart'; // <<< เพิ่มการนำเข้าไฟล์ Dialog ใหม่

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to show detail dialog
  void _showResultDetail(SearchResultEntity result, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => SearchResultDetailDialog(
        result: result,
      ), // <<< เปลี่ยนมาเรียกใช้ Dialog ใหม่
    );
  }

  // Helper method for entity color
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

  // Helper method for status color
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => getIt<SearchBloc>(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Search',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 1,
        ),
        body: Column(
          children: [
            BlocBuilder<SearchBloc, SearchState>(
              builder: (blocBuilderContext, state) {
                return SearchInputBar(
                  searchController: _searchController,
                  onChanged: (query) {
                    blocBuilderContext.read<SearchBloc>().add(
                      SearchQueryChanged(query),
                    );
                  },
                  onSubmitted: (query) {
                    blocBuilderContext.read<SearchBloc>().add(
                      SearchSubmitted(query),
                    );
                  },
                  onClear: () {
                    _searchController.clear();
                    blocBuilderContext.read<SearchBloc>().add(ClearSearch());
                  },
                );
              },
            ),

            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchInitial) {
                    return const SearchInitialView();
                  } else if (state is SearchLoading) {
                    return SearchLoadingView(query: state.query);
                  } else if (state is SearchSuccess) {
                    return Column(
                      children: [
                        Container(
                          color: theme.colorScheme.surface,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                'Search Results for "${state.query}" (${state.totalResults} items)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  child: Text(
                                    'Cached',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final result = state.results[index];
                              return SearchResultCard(
                                result: result,
                                getEntityColor: _getEntityColor,
                                getStatusColor: _getStatusColor,
                                onTapped: () =>
                                    _showResultDetail(result, theme),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is SearchEmpty) {
                    return SearchEmptyView(query: state.query);
                  } else if (state is SearchError) {
                    return SearchErrorView(
                      message: state.message,
                      query: state.query,
                      onRetry: () => context.read<SearchBloc>().add(
                        SearchSubmitted(state.query),
                      ),
                    );
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
}
