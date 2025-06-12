import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏠 Overview (สรุปภาพรวม)',
                  style: theme.textTheme.titleLarge,
                ),
                DropdownButton<String>(
                  value: '7 วัน',
                  items: ['วันนี้', '7 วัน', '30 วัน'].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _SummaryCard(
                  icon: LucideIcons.boxes,
                  label: 'สินทรัพย์ทั้งหมด',
                  value: '1,240',
                  subtext: '+5% จากสัปดาห์ก่อน',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeCheck,
                  label: 'ใช้งานอยู่',
                  value: '1,100',
                  subtext: '+2%',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeX,
                  label: 'ไม่ใช้งาน',
                  value: '140',
                  subtext: '-3%',
                  valueColor: Colors.red,
                ),
                _SummaryCard(
                  icon: LucideIcons.scanLine,
                  label: 'Scan วันนี้',
                  value: '57',
                  subtext: '+12%',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.fileUp,
                  label: 'Export สำเร็จ (7d)',
                  value: '12',
                  subtext: '+1%',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.fileX,
                  label: 'Export ล้มเหลว (7d)',
                  value: '2',
                  subtext: '+100%',
                  valueColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            _DashboardCard(
              title: 'สถานะล่าสุดของ Asset ทั้งหมด',
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 78,
                        color: Colors.green,
                        title: 'ใช้งาน',
                      ),
                      PieChartSectionData(
                        value: 22,
                        color: Colors.red,
                        title: 'ไม่ใช้งาน',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _DashboardCard(
              title: '⚠️ แจ้งเตือนสำคัญ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('• สินทรัพย์ 12 รายการไม่มีการสแกนเกิน 30 วัน'),
                  Text('• Export ล้มเหลวต่อเนื่อง 2 ครั้ง'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              '🏭 Asset Monitoring (สรุป)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _MockTable(
              title: 'รายการ Asset ล่าสุดที่ถูก Scan (5 รายการ)',
              onViewAll: () => print('Navigate to Asset Monitoring Page'),
            ),
            const SizedBox(height: 12),
            _DashboardCard(
              title: 'Scan per day (7 วัน)',
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 10),
                          FlSpot(1, 12),
                          FlSpot(2, 14),
                          FlSpot(3, 18),
                          FlSpot(4, 16),
                          FlSpot(5, 20),
                          FlSpot(6, 22),
                        ],
                        isCurved: true,
                        gradient: LinearGradient(colors: [theme.primaryColor]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              '📄 Export Tracking (สรุป)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _MockTable(
              title: 'Export jobs ล่าสุด (5 รายการ)',
              onViewAll: () => print('Navigate to Export Tracking Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtext;
  final Color? valueColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtext,
    this.valueColor,
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
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(color: valueColor),
          ),
          if (subtext != null)
            Text(
              subtext!,
              style: theme.textTheme.bodySmall?.copyWith(color: valueColor),
            ),
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
  final VoidCallback onViewAll;

  const _MockTable({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _DashboardCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(3, (index) {
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewAll,
              child: const Text('ดูทั้งหมด >'),
            ),
          ),
        ],
      ),
    );
  }
}
