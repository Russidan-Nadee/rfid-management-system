// Path: frontend/lib/features/search/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/theme/app_decorations.dart';
import '../../../../l10n/features/search/search_localizations.dart';
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
import '../widgets/search_result_detail_dialog.dart';

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

  void _showResultDetail(SearchResultEntity result, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => SearchResultDetailDialog(result: result),
    );
  }

  Color _getEntityColor(String entityType) {
    switch (entityType) {
      case 'assets':
        return AppColors.primary;
      case 'plants':
        return AppColors.success;
      case 'locations':
        return AppColors.warning;
      case 'departments':
        return AppColors.chartBlue;
      case 'users':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ACTIVE':
        return AppColors.success;
      case 'C':
      case 'CREATED':
        return AppColors.info;
      case 'I':
      case 'INACTIVE':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = SearchLocalizations.of(context);

    return BlocProvider(
      create: (context) => getIt<SearchBloc>(),
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            l10n.pageTitle,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? theme.colorScheme.onSurface
                  : AppColors.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
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
                          padding: AppSpacing.paddingLG,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${l10n.searchResultsFor} "${state.query}"',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalSpaceSM,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: AppDecorations.custom(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? theme.colorScheme.surface.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppColors.primarySurface,
                                  borderRadius: AppBorders.pill,
                                ),
                                child: Text(
                                  '${state.totalResults} ${l10n.totalItems}',
                                  style: AppTextStyles.caption.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? theme.colorScheme.onSurface
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (state.fromCache) ...[
                                AppSpacing.horizontalSpaceSM,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: AppDecorations.custom(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.darkSurfaceVariant
                                        : AppColors.successLight,
                                    borderRadius: AppBorders.pill,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.cached,
                                        size: 12,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.success,
                                      ),
                                      AppSpacing.horizontalSpaceXS,
                                      Text(
                                        l10n.cached,
                                        style: AppTextStyles.caption.copyWith(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: AppSpacing.screenPaddingAll,
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final result = state.results[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                                child: SearchResultCard(
                                  result: result,
                                  getEntityColor: _getEntityColor,
                                  getStatusColor: _getStatusColor,
                                  onTapped: () =>
                                      _showResultDetail(result, theme),
                                ),
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
