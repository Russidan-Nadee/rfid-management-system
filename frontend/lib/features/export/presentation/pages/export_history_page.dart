// Path: frontend/lib/features/export/presentation/pages/export_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import '../widgets/export_history_list.dart';
import '../widgets/export_progress_widget.dart';

class ExportHistoryPage extends StatelessWidget {
  const ExportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExportBloc>()
        ..add(const LoadExportHistory())
        ..add(const LoadExportStats()),
      child: const ExportHistoryPageView(),
    );
  }
}

class ExportHistoryPageView extends StatefulWidget {
  const ExportHistoryPageView({super.key});

  @override
  State<ExportHistoryPageView> createState() => _ExportHistoryPageViewState();
}

class _ExportHistoryPageViewState extends State<ExportHistoryPageView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'all';
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final newFilter = _getFilterForTab(_tabController.index);
    if (newFilter != _statusFilter) {
      setState(() => _statusFilter = newFilter);
      _loadHistoryWithFilter(newFilter);
    }
  }

  String _getFilterForTab(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'P'; // Pending
      case 2:
        return 'C'; // Completed
      case 3:
        return 'F'; // Failed
      default:
        return 'all';
    }
  }

  void _loadHistoryWithFilter(String filter) {
    final statusFilter = filter == 'all' ? null : filter;
    context.read<ExportBloc>().add(
          LoadExportHistory(statusFilter: statusFilter, refresh: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = Helpers.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: BlocListener<ExportBloc, ExportState>(
        listener: _handleStateChanges,
        child: Column(
          children: [
            if (_shouldShowProgress()) _buildProgressSection(),
            _buildStatsHeader(theme),
            _buildTabBar(theme),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.history,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Export History'),
        ],
      ),
      actions: [
        BlocBuilder<ExportBloc, ExportState>(
          builder: (context, state) {
            if (state is ExportHistoryLoaded && state.hasExports) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'selection_mode',
                    child: Row(
                      children: [
                        Icon(
                          _isSelectionMode ? Icons.close : Icons.checklist,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(_isSelectionMode ? 'Exit Selection' : 'Select Mode'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cleanup',
                    child: Row(
                      children: [
                        Icon(Icons.cleaning_services, size: 20),
                        SizedBox(width: 8),
                        Text('Cleanup Expired'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_stats',
                    child: Row(
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 8),
                        Text('View Statistics'),