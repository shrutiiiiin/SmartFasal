import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class NPKPieChart extends StatelessWidget {
  final double nitrogen;
  final double phosphorus;
  final double potassium;

  NPKPieChart({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPK Pie Chart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Soil Nutrient Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 50,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = nitrogen + phosphorus + potassium;

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: (nitrogen / total) * 100,
        title: '${((nitrogen / total) * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: (phosphorus / total) * 100,
        title: '${((phosphorus / total) * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: (potassium / total) * 100,
        title: '${((potassium / total) * 100).toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Nitrogen (N)', Colors.blue),
        _buildLegendItem('Phosphorus (P)', Colors.green),
        _buildLegendItem('Potassium (K)', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
