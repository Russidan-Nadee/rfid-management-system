import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';

class AlertsSection extends StatelessWidget {
  final List<Alert> alerts;

  const AlertsSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Text('No alerts available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alerts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...alerts.map(
          (alert) => Card(
            child: ListTile(
              leading: Icon(
                Icons.warning,
                color: alert.isError
                    ? Colors.red
                    : alert.isWarning
                    ? Colors.orange
                    : Colors.blue,
              ),
              title: Text(alert.type), // ใช้ type แทน title
              subtitle: Text(alert.message), // ใช้ message แทน description
              trailing: alert.hasCount
                  ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(alert.count.toString()),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
