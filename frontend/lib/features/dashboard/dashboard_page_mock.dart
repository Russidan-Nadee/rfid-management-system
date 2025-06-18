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
            const SizedBox(height: 24),
            _DashboardCard(
              title: '📈 การเติบโตของสินทรัพย์แต่ละแผนก',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'แผนก:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: 'IT',
                        items: ['IT', 'โรงงาน', 'Logistics', 'อื่นๆ'].map((
                          dept,
                        ) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'ม.ค.',
                                  'ก.พ.',
                                  'มี.ค.',
                                  'เม.ย.',
                                  'พ.ค.',
                                  'มิ.ย.',
                                ];
                                if (value.toInt() < months.length) {
                                  return Text(months[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 5), // ม.ค. +5%
                              FlSpot(1, 8), // ก.พ. +8%
                              FlSpot(2, 12), // มี.ค. +12%
                              FlSpot(3, 18), // เม.ย. +18%
                              FlSpot(4, 15), // พ.ค. +15%
                              FlSpot(5, 22), // มิ.ย. +22%
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('• แผนก IT มีการเติบโต 22% ในครึ่งปีแรก'),
                  const Text(
                    '• เพิ่มขึ้นอย่างต่อเนื่องจาก Digital Transformation',
                  ),
                  const Text('→ คาดการณ์เติบโต 40% ภายในสิ้นปี'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DashboardCard(
              title: '🏭 การเติบโตของสินทรัพย์แต่ละพื้นที่ปฏิบัติการ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'พื้นที่:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: 'Curing Oven Area',
                        items:
                            [
                              'Curing Oven Area',
                              'E-Coat Line 1',
                              'Maintenance Workshop',
                              'Phosphating Line 1',
                              'Pre-Treatment Section',
                              'Paint Spray Booth 1',
                              'Quality Control Lab',
                              'Wastewater Treatment',
                            ].map((location) {
                              return DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}%');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'ม.ค.',
                                  'ก.พ.',
                                  'มี.ค.',
                                  'เม.ย.',
                                  'พ.ค.',
                                  'มิ.ย.',
                                ];
                                if (value.toInt() < months.length) {
                                  return Text(months[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 8), // ม.ค. +8%
                              FlSpot(1, 12), // ก.พ. +12%
                              FlSpot(2, 15), // มี.ค. +15%
                              FlSpot(3, 11), // เม.ย. +11%
                              FlSpot(4, 18), // พ.ค. +18%
                              FlSpot(5, 25), // มิ.ย. +25%
                            ],
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.purple.withOpacity(0.1),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• พื้นที่ Curing Oven มีการเติบโต 25% ในครึ่งปีแรก',
                  ),
                  const Text('• การปรับปรุงเตาอบเพิ่มประสิทธิภาพการผลิต'),
                  const Text(
                    '→ เป้าหมายเพิ่มเครื่องจักรใหม่ 2 ชุดภายในไตรมาส 4',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _DashboardCard(
              title: '📋 ความคืบหน้าการตรวจสอบประจำปี',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'แผนก:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: 'ทั้งหมด',
                        items: ['ทั้งหมด', 'IT', 'โรงงาน', 'Logistics', 'อื่นๆ']
                            .map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              );
                            })
                            .toList(),
                        onChanged: (v) {
                          // Handle department change
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Circle
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: 0.28, // 28%
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        ),
                        Column(
                          children: const [
                            Text(
                              '28%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              'เสร็จแล้ว',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: const [
                          Text(
                            '350',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            'ตรวจแล้ว',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: const [
                          Text(
                            '890',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'รอตรวจ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: const [
                          Text(
                            '1,240',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'ทั้งหมด',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('• ความคืบหน้าภาพรวม 28% ของการตรวจสอบประจำปี'),
                  const Text('• เป้าหมายให้เสร็จสิ้นภายในไตรมาส 3'),
                  const Text(
                    '→ ต้องเร่งความเร็วเพิ่มขึ้น 15% เพื่อทันเป้าหมาย',
                  ),
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


// การกระจายสินทรัพย์ตามแผนก

// Pie Chart (กราฟวงกลม): แสดงสัดส่วนภาพรวมแต่ละแผนก

// Bar Chart (กราฟแท่ง): เปรียบเทียบปริมาณสินทรัพย์ของแต่ละแผนก

// Treemap Chart: แสดงสัดส่วนเชิงลึกแบบแบ่งเป็นกลุ่มย่อย

// Stacked Bar Chart: เปรียบเทียบสินทรัพย์รวมและแยกย่อยตามแผนก

// การเติบโตของสินทรัพย์แต่ละแผนก / พื้นที่ปฏิบัติการ

// Line Chart (กราฟเส้น): ดูแนวโน้มและการเติบโตตลอดเวลา

// Bar Chart (กราฟแท่ง): เปรียบเทียบการเติบโต ณ จุดเวลาต่างๆ

// Area Chart: เน้นแสดงปริมาณและแนวโน้มเติบโตที่มีน้ำหนัก

// Combo Chart (Line + Bar): แสดงเทรนด์และปริมาณเปรียบเทียบพร้อมกัน

// ความคืบหน้าการตรวจสอบประจำปี

// Circular Progress Indicator (วงกลมความคืบหน้า): แสดง % เสร็จแล้วเด่นชัด

// Bar Chart (กราฟแท่ง): แสดงความคืบหน้ารายส่วนหรืองานย่อย

// Gauge Chart (มาตรวัด): แสดงสถานะความคืบหน้าแบบเข็มชี้

// Bullet Chart: เทียบความคืบหน้ากับเป้าหมายได้ชัดเจน

// Progress Bar (แถบความคืบหน้า): แบบเรียบง่าย แสดง % งานเสร็จ