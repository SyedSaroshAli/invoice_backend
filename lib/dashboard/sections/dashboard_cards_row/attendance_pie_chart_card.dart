/* import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AttendancePieChartCard extends StatelessWidget {
  final int present;
  final int absent;
  final int leave;

  const AttendancePieChartCard({
    super.key,
    required this.present,
    required this.absent,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    final total = present + absent + leave;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.pieChart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Attendance Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 35,
                            sections: [
                              PieChartSectionData(
                                value: present.toDouble(),
                                title: '',
                                color: const Color(0xFF10B981),
                                radius: 45,
                              ),
                              PieChartSectionData(
                                value: absent.toDouble(),
                                title: '',
                                color: const Color(0xFFEF4444),
                                radius: 45,
                              ),
                              PieChartSectionData(
                                value: leave.toDouble(),
                                title: '',
                                color: const Color(0xFFF59E0B),
                                radius: 45,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$total',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Days',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCompactLegendItem(
                        context,
                        'Present',
                        const Color(0xFF10B981),
                        present,
                        total,
                        LucideIcons.checkCircle2,
                      ),
                      const SizedBox(height: 8),
                      _buildCompactLegendItem(
                        context,
                        'Absent',
                        const Color(0xFFEF4444),
                        absent,
                        total,
                        LucideIcons.xCircle,
                      ),
                      const SizedBox(height: 8),
                      _buildCompactLegendItem(
                        context,
                        'Leave',
                        const Color(0xFFF59E0B),
                        leave,
                        total,
                        LucideIcons.userMinus,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLegendItem(
    BuildContext context,
    String label,
    Color color,
    int value,
    int total,
    IconData icon,
  ) {
    final percentage = total > 0
        ? ((value / total) * 100).toStringAsFixed(0)
        : '0';

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}  */
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AttendancePieChartCard extends StatelessWidget {
  final int present;
  final int absent;
  final int leave; // This maps to 'late' from your API
  final int total;
  final bool isLoading;

  const AttendancePieChartCard({
    super.key,
    required this.present,
    required this.absent,
    required this.leave,
    required this.total,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if data is being fetched
    if (isLoading) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  LucideIcons.pieChart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Attendance Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Pie Chart Section
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                            startDegreeOffset: -90,
                            sections: _buildChartSections(),
                          ),
                        ),
                        // Center Text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Days',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend Section
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        context,
                        'Present',
                        const Color(0xFF10B981),
                        present,
                        LucideIcons.checkCircle2,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        context,
                        'Absent',
                        const Color(0xFFEF4444),
                        absent,
                        LucideIcons.xCircle,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        context,
                        'Late', // Displays as Leave, data comes from 'late'
                        const Color(0xFFF59E0B),
                        leave,
                        LucideIcons.userMinus,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    // If no data exists yet, show a grey empty circle
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade200,
          value: 1,
          radius: 40,
          showTitle: false,
        )
      ];
    }

    return [
      PieChartSectionData(
        value: present.toDouble(),
        title: '',
        color: const Color(0xFF10B981),
        radius: 40,
      ),
      PieChartSectionData(
        value: absent.toDouble(),
        title: '',
        color: const Color(0xFFEF4444),
        radius: 40,
      ),
      PieChartSectionData(
        value: leave.toDouble(),
        title: '',
        color: const Color(0xFFF59E0B),
        radius: 40,
      ),
    ];
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int value,
    IconData icon,
  ) {
    final percentage = total > 0 ? ((value / total) * 100).toStringAsFixed(0) : '0';

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
