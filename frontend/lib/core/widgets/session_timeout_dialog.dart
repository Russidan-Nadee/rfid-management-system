import 'package:flutter/material.dart';
import '../services/session_timer_service.dart';

class SessionTimeoutDialog extends StatefulWidget {
  final VoidCallback onExtend;
  final VoidCallback onLogout;

  const SessionTimeoutDialog({
    super.key,
    required this.onExtend,
    required this.onLogout,
  });

  @override
  State<SessionTimeoutDialog> createState() => _SessionTimeoutDialogState();
}

class _SessionTimeoutDialogState extends State<SessionTimeoutDialog> {
  final SessionTimerService _sessionTimer = SessionTimerService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Session Timeout Warning'),
        ],
      ),
      content: ValueListenableBuilder<int>(
        valueListenable: _sessionTimer.remainingTime,
        builder: (context, remainingTime, child) {
          final minutes = (remainingTime / 60000).floor();
          final seconds = ((remainingTime % 60000) / 1000).floor();
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your session will expire in:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Would you like to extend your session or logout?',
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: widget.onLogout,
          child: const Text('Logout'),
        ),
        ElevatedButton(
          onPressed: widget.onExtend,
          child: const Text('Extend Session'),
        ),
      ],
    );
  }
}