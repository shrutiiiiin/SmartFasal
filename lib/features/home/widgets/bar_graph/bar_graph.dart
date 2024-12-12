import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final double nitrogen;
  final double phosphorus;
  final double potassium;

  const BarGraph({
    super.key,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 300, // Adjusted maximum value on the Y axis
        minY: 100, // Adjusted minimum value on the Y axis
        barGroups: _createBarGroups(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles:
                  true, // Set to false if you want to hide the Y-axis titles
              reservedSize: 40, // Adjust this value for spacing
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 1:
                    return const Text(
                      'Nitrogen',
                      style: TextStyle(fontSize: 10),
                    );
                  case 2:
                    return const Text(
                      'Phosphorus',
                      style: TextStyle(fontSize: 10),
                    );
                  case 3:
                    return const Text(
                      'Potassium',
                      style: TextStyle(fontSize: 10),
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return [
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: nitrogen,
            color: const Color(0xffF66464),
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
              toY: phosphorus, color: const Color(0xffF6E764), width: 20),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
              toY: potassium, color: const Color(0xff7564F6), width: 20),
        ],
      ),
    ];
  }
}
