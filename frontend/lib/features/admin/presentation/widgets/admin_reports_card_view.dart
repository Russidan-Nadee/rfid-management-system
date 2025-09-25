import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import 'admin_report_card_widget.dart';

class AdminReportsCardView extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onReportUpdated;

  const AdminReportsCardView({
    super.key,
    required this.reports,
    required this.onReportUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: _UniformCardGrid(
        reports: reports,
        onReportUpdated: onReportUpdated,
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