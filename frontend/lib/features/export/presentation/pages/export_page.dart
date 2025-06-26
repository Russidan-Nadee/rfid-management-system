// Path: frontend/lib/features/export/presentation/pages/export_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../widgets/export_config_widget.dart';
import '../widgets/export_history_widget.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => getIt<ExportBloc>()..add(const LoadExportHistory()),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            'Export',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0, // Modern flat design
          scrolledUnderElevation: 1,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            labelStyle: AppTextStyles.button.copyWith(fontSize: 13),
            unselectedLabelStyle: AppTextStyles.button.copyWith(fontSize: 13),
            tabs: const [
              Tab(
                icon: Icon(Icons.upload, size: 20),
                text: 'Create Export',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: Icon(Icons.history, size: 20),
                text: 'History',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [ExportConfigWidget(), ExportHistoryWidget()],
        ),
      ),
    );
  }
}
