// Path: frontend/lib/features/scan/presentation/pages/asset_detail_page.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/scanned_item_entity.dart';

class AssetDetailPage extends StatelessWidget {
  final ScannedItemEntity item;

  const AssetDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดครุภัณฑ์'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Basic Information
            _buildSectionCard(
              title: 'ข้อมูลพื้นฐาน',
              icon: Icons.inventory_2_outlined,
              children: [
                _buildDetailRow('Asset Number', item.assetNo),
                _buildDetailRow('Description', item.description ?? '-'),
                _buildDetailRow('Serial Number', item.serialNo ?? '-'),
                _buildDetailRow('Inventory Number', item.inventoryNo ?? '-'),
              ],
            ),

            const SizedBox(height: 16),

            // Quantity Information
            _buildSectionCard(
              title: 'ข้อมูลจำนวน',
              icon: Icons.straighten,
              children: [
                _buildDetailRow(
                  'Quantity',
                  item.quantity != null ? '${item.quantity}' : '-',
                ),
                _buildDetailRow('Unit', item.unitName ?? '-'),
              ],
            ),

            const SizedBox(height: 16),

            // Creation Information
            _buildSectionCard(
              title: 'ข้อมูลการสร้าง',
              icon: Icons.person_outline,
              children: [
                _buildDetailRow('Created By', item.createdByName ?? '-'),
                _buildDetailRow(
                  'Created Date',
                  item.createdAt != null
                      ? Helpers.formatDateTime(item.createdAt)
                      : '-',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getStatusColor(item.status),
              _getStatusColor(item.status).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(_getStatusIcon(item.status), color: Colors.white, size: 48),

            const SizedBox(height: 12),

            Text(
              item.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(item.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'checked':
        return Colors.blue;
      case 'unknown':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'checked':
        return Icons.verified;
      case 'unknown':
        return Icons.help;
      default:
        return Icons.inventory_2;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'checked':
        return 'Checked';
      case 'unknown':
        return 'Unknown';
      default:
        return status;
    }
  }
}
