import 'package:flutter/material.dart';
import '../../domain/entities/recent_activity.dart';

class RecentActivitiesSection extends StatelessWidget {
  final RecentActivity recentActivities;

  const RecentActivitiesSection({super.key, required this.recentActivities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentActivities.hasScans) ...[
          const Text(
            'Recent Scans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...recentActivities.recentScans.map(
            (scan) => ListTile(
              title: Text('${scan.assetNo} - ${scan.assetDescription}'),
              subtitle: Text(
                'Scanned by ${scan.scannedBy} at ${scan.formattedTime}',
              ),
              trailing: Text(scan.location),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (recentActivities.hasExports) ...[
          const Text(
            'Recent Exports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...recentActivities.recentExports.map(
            (export) => ListTile(
              title: Text('${export.typeLabel} (${export.statusLabel})'),
              subtitle: Text(
                'Exported by ${export.userName} at ${export.formattedTime}',
              ),
              trailing: Text('${export.totalRecords} records'),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (!recentActivities.hasActivity)
          const Text(
            'No recent activities found.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}
