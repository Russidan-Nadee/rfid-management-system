// Path: frontend/lib/features/export/presentation/widgets/export_item_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/export_job_entity.dart';

class ExportItemCard extends StatelessWidget {
  final ExportJobEntity export;
  final VoidCallback onTap;

  const ExportItemCard({super.key, required this.export, required this.onTap});

  @override
  Widget build(BuildContext context) {
    print(
      '🔍 Export ${export.exportId}: status=${export.status}, canDownload=${export.canDownload}',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildStatusIcon(),
        title: Text(
          'Export ID: ${export.exportId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${export.statusLabel}'),
        trailing: IconButton(
          onPressed: export.canDownload
              ? () {
                  print(
                    '🎯 Download button tapped for export ${export.exportId}',
                  );
                  onTap();
                }
              : null,
          icon: Icon(
            Icons.file_upload,
            color: export.canDownload ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (export.isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (export.isFailed) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return const Icon(Icons.hourglass_empty, color: Colors.orange);
  }
}
