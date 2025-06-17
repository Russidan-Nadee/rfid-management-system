import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPageMock extends StatelessWidget {
  const DashboardPageMock({super.key});

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
                  subtext: '+5% YoY',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeCheck,
                  label: 'ใช้งานอยู่',
                  value: '1,100',
                  subtext: '89% Utilization',
                  valueColor: Colors.green,
                ),
                _SummaryCard(
                  icon: LucideIcons.badgeX,
                  label: 'ไม่ใช้งาน',
                  value: '140',
                  subtext: '11% Idle Assets',
                  valueColor: Colors.red,
                ),
                _SummaryCard(
                  icon: LucideIcons.packagePlus,
                  label: 'สินทรัพย์ใหม่ (ปีนี้)',
                  value: '320',
                  subtext: '+18% YoY',
                  valueColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DashboardCard(
              title: '📊 วิเคราะห์สินทรัพย์ใหม่ที่เพิ่มเข้าระบบ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• ปีนี้มีการเพิ่ม Asset ใหม่ 320 ชิ้น (+18% เทียบกับปีก่อน)',
                  ),
                  Text('• ส่วนใหญ่เป็นอุปกรณ์ IT และเครื่องมือผลิต'),
                  Text('• บ่งชี้แนวโน้มการลงทุนเชิงรุกด้านเทคโนโลยี'),
                  Text(
                    '→ ควรตรวจสอบว่าลงทะเบียนครบ และใช้งานอย่างมีประสิทธิภาพ',
                  ),
                ],
              ),
            ),
            _DashboardCard(
              title: '🏢 การกระจายสินทรัพย์ตามแผนก',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 45,
                            title: 'IT',
                            color: Colors.blue,
                          ),
                          PieChartSectionData(
                            value: 30,
                            title: 'โรงงาน',
                            color: Colors.orange,
                          ),
                          PieChartSectionData(
                            value: 15,
                            title: 'Logistics',
                            color: Colors.green,
                          ),
                          PieChartSectionData(
                            value: 10,
                            title: 'อื่นๆ',
                            color: Colors.grey,
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('• IT ใช้งบลงทุนมากที่สุด (45%)'),
                  const Text('• โรงงานรองลงมา (30%) → เน้นการผลิต'),
                  const Text('→ วิเคราะห์ ROI แยกแผนก เพื่อวางกลยุทธ์ปีถัดไป'),
                ],
              ),
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
