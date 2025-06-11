import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Make sure this is in your pubspec.yaml
import 'package:intl/intl.dart'; // Make sure this is in your pubspec.yaml

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'), // Changed title for clarity
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 🏠 Overview (สรุปภาพรวม) ---
            Text('🏠 Overview (สรุปภาพรวม)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _SummaryCard(
                  icon: LucideIcons.boxes,
                  label: 'สินทรัพย์ทั้งหมด',
                  value: '1,240',
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeCheck,
                  label: 'ใช้งานอยู่',
                  value: '1,100',
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeX,
                  label: 'ไม่ใช้งาน',
                  value: '140',
                ),
                _SummaryCard(
                  icon: LucideIcons.scanLine,
                  label: 'Scan วันนี้',
                  value: '57',
                ),
                _SummaryCard(
                  icon: LucideIcons.fileUp,
                  label: 'Export สำเร็จ (7d)',
                  value: '12',
                ),
                _SummaryCard(
                  icon: LucideIcons.fileX,
                  label: 'Export ล้มเหลว (7d)',
                  value: '2',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // สถานะล่าสุดของ Asset ทั้งหมด (Pie Chart) - ควรอยู่บน Dashboard
            _DashboardCard(
              title: 'สถานะล่าสุดของ Asset ทั้งหมด',
              child: SizedBox(
                height: 200,
                child: Center(
                  // TODO: แทนที่ด้วย Widget กราฟวงกลมแสดงสถานะสินทรัพย์จริง
                  child: Text(
                    'Placeholder: Pie Chart - Asset Status',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 🏭 Asset Monitoring (สรุป) ---
            Text(
              '🏭 Asset Monitoring (สรุป)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // ตาราง: รายการ Asset ล่าสุดที่ถูก Scan (10 รายการ) - ควรอยู่บน Dashboard
            _MockTable(
              title: 'รายการ Asset ล่าสุดที่ถูก Scan (5 รายการ)',
              onViewAll: () {
                // TODO: นำทางไปยังหน้า Asset Monitoring เต็มรูปแบบ
                print('Navigate to Asset Monitoring Page');
              },
            ),
            const SizedBox(height: 12),
            // กราฟ: Scan per day (7 วัน) - ควรอยู่บน Dashboard
            _DashboardCard(
              title: 'Scan per day (7 วัน)',
              child: SizedBox(
                height: 200,
                child: Center(
                  // TODO: แทนที่ด้วย Widget กราฟแท่ง/เส้น แสดงจำนวน Scan ต่อวันจริง
                  child: Text(
                    'Placeholder: Graph - Scan per Day',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 📄 Export Tracking (สรุป) ---
            Text(
              '📄 Export Tracking (สรุป)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // ตาราง: Export jobs ล่าสุด (สถานะ, ประเภท, ขนาดไฟล์) - ควรอยู่บน Dashboard
            _MockTable(
              title: 'Export jobs ล่าสุด (5 รายการ)',
              onViewAll: () {
                // TODO: นำทางไปยังหน้า Export Tracking เต็มรูปแบบ
                print('Navigate to Export Tracking Page');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Widgets (ปรับปรุง _MockTable) ---

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: theme.primaryColor),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MockTable extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll; // เพิ่ม callback สำหรับปุ่ม "ดูทั้งหมด"

  const _MockTable({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _DashboardCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simplified mock table rows
          ...List.generate(3, (index) {
            // แสดง 3 รายการเพื่อความกระชับบน Dashboard
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ข้อมูลรายการ ${index + 1}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    DateFormat('HH:mm').format(
                      DateTime.now().subtract(Duration(minutes: index * 10)),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // ปุ่ม "ดูทั้งหมด"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewAll, // ใช้ callback ที่ส่งมา
              child: const Text('ดูทั้งหมด >'),
            ),
          ),
        ],
      ),
    );
  }
}
