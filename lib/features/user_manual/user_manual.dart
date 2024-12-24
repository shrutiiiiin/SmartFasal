import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserManualFarmer extends StatefulWidget {
  const UserManualFarmer({super.key});

  @override
  State<UserManualFarmer> createState() => _UserManualFarmerState();
}

class _UserManualFarmerState extends State<UserManualFarmer> {
  double _nitrogen = 0;
  double _phosphorus = 0;
  double _potassium = 0;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _dataSubscription;

  Map<String, double> _dataMap = {
    "Nitrogen (N)": 40,
    "Phosphorus (P)": 35,
    "Potassium (K)": 25,
  };
  Map<String, double> normalizeData(Map<String, double> data) {
    return {
      'Nitrogen': data['Nitrogen (N)'] ?? 0.0,
      'Phosphorus': data['Phosphorus (P)'] ?? 0.0,
      'Potassium': data['Potassium (K)'] ?? 0.0,
    };
  }

  @override
  void initState() {
    super.initState();
    _subscribeToDataChanges();
  }

  void _fetchSoilData() {
    _dataSubscription = _databaseRef.child('data').onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue != null) {
        if (snapshotValue is Map) {
          setState(() {
            _nitrogen =
                double.tryParse(snapshotValue['nitrogen']?.toString() ?? '') ??
                    0.0;
            _phosphorus = double.tryParse(
                    snapshotValue['phosphorus']?.toString() ?? '') ??
                0.0;
            _potassium =
                double.tryParse(snapshotValue['potassium']?.toString() ?? '') ??
                    0.0;

            // Update and normalize _dataMap
            _dataMap = {
              "Nitrogen (N)": _nitrogen,
              "Phosphorus (P)": _phosphorus,
              "Potassium (K)": _potassium,
            };

            // Normalize for consistency
            _dataMap = normalizeData(_dataMap);
          });
          print("Normalized Data: $_dataMap");
        } else {
          print("Unexpected data type: ${snapshotValue.runtimeType}");
        }
      } else {
        print("No data found at the specified path.");
      }
    }, onError: (error) {
      print("Error fetching data: $error");
    });
  }

  void _subscribeToDataChanges() {
    _dataSubscription = _databaseRef.child('data').onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue != null && snapshotValue is Map) {
        setState(() {
          _dataMap = {
            "Nitrogen (N)":
                double.tryParse(snapshotValue['nitrogen']?.toString() ?? '0') ??
                    0.0,
            "Phosphorus (P)": double.tryParse(
                    snapshotValue['phosphorus']?.toString() ?? '0') ??
                0.0,
            "Potassium (K)": double.tryParse(
                    snapshotValue['potassium']?.toString() ?? '0') ??
                0.0,
          };
        });
        print("Updated DataMap: $_dataMap"); // Add this to debug
      } else {
        print("No data or invalid data structure: $snapshotValue");
      }
    }, onError: (error) {
      print("Error getting live data: $error");
    });
  }

  String selectedType = 'Organic Manure'; // Default selection

  final List<Map<String, dynamic>> researchData = [
    {
      'type': 'Fermented Liquid',
      'npk': {'Nitrogen': 2.5, 'Phosphorus': 1.2, 'Potassium': 3.8}
    },
    {
      'type': 'Organic Manure',
      'npk': {'Nitrogen': 2.0, 'Phosphorus': 2.5, 'Potassium': 1.0}
    },
  ];

  // Map<String, Map<String, double>> kitValues = {
  //   'Fermented Liquid': {'Nitrogen': 0.0, 'Phosphorus': 0.0, 'Potassium': 0.0},
  //   'Organic Manure': {'Nitrogen': 0.0, 'Phosphorus': 0.0, 'Potassium': 0.0},
  // };

  final List<Map<String, String>> manualSections = [
    {
      'title': 'Switch on the battery source for the kit',
      'content': 'Led switch will glow indicating the kit is ready to use ',
      'imagePath': 'assets/home/images/light.jpg',
    },
    {
      'title': 'Time to test',
      'content': 'Place the kit in the fertilizer ',
      'imagePath': 'assets/home/images/test.jpg',
    },
    {
      'title': 'Live NPK Readings',
      'content':
          'You will wait for 10 secs and you can see the readings of npk and ph on the lcd screen',
      'imagePath': 'assets/home/images/result.jpg',
    },
  ];

  @override
  void dispose() {
    _dataSubscription
        .cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final researchValues = researchData.firstWhere(
      (data) => data['type'] == selectedType,
    )['npk'] as Map<String, dynamic>;

    final normalizedResearchValues = normalizeData(
      researchValues.map((key, value) => MapEntry(key, value.toDouble())),
    );

    final normalizedDataMap = normalizeData(_dataMap);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual for Farmers'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // First section with image and text
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light background color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        'assets/home/images/farmercutout.png',
                        height: 200,
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double fontSize =
                              constraints.maxWidth > 600 ? 16 : 15;

                          return Text(
                            'Thank you for choosing our NPK Sensor Kit! This kit is designed to help you monitor the vital nutrients in your soil, ensuring optimal growth for your crops.',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.start,
                            softWrap: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'With this kit, you can take control of your farm\'s soil health and improve your crop yield.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              // ListView for additional sections
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: manualSections.length,
                itemBuilder: (context, index) {
                  return _buildManualSection(manualSections[index], index);
                },
              ),
              // Divider(
              //   thickness: 2,
              //   height: 500,
              // ),
              const Text(
                'Overview of our app accuracy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              _buildAccuracyChart(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Understanding Your Nutrients:\n'
                  '• Nitrogen (Green): Promotes leaf growth and plant vigor\n'
                  '• Phosphorus (Blue): Supports root development and flowering\n'
                  '• Potassium (Red): Enhances overall plant health and stress resistance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  // textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Last Updated: ${DateTime.now().toString().substring(0, 16)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'NPK Comparison: Research vs Kit Values',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

              DropdownButton<String>(
                value: selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: researchData.map<DropdownMenuItem<String>>((data) {
                  return DropdownMenuItem<String>(
                    value: data['type'],
                    child: Text(data['type']),
                  );
                }).toList(),
              ),

              // Bar chart for NPK comparison
              const SizedBox(height: 20),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: 500,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = [
                              'Nitrogen',
                              'Phosphorus',
                              'Potassium'
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < titles.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  titles[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(
                      show: true,
                      horizontalInterval: 100,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    barGroups: [
                      // Nitrogen comparison
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: researchValues['Nitrogen']! * 100,
                            color: Colors.green.shade300,
                            width: 20,
                          ),
                          BarChartRodData(
                            toY: normalizedDataMap['Nitrogen']!,
                            color: Colors.green.shade700,
                            width: 20,
                          ),
                        ],
                      ),
                      // Phosphorus comparison
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY:
                                (researchValues['Phosphorus'].toDouble() ?? 0) *
                                    100,
                            color: Colors.blue.shade300,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                          BarChartRodData(
                            toY: normalizedDataMap['Phosphorus'] ?? 0,
                            color: Colors.blue.shade700,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      // Potassium comparison
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: (researchValues['Potassium'].toDouble() ?? 0) *
                                100,
                            color: Colors.red.shade300,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                          BarChartRodData(
                            toY: normalizedDataMap['Potassium'] ?? 0,
                            color: Colors.red.shade700,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    ],
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          const nutrients = [
                            'Nitrogen',
                            'Phosphorus',
                            'Potassium'
                          ];
                          final nutrient = nutrients[group.x.toInt()];
                          final source = rodIndex == 0 ? 'Research' : 'Kit';
                          BarTooltipItem(
                            '$source $nutrient\n${rod.toY.toStringAsFixed(2)} mg/kg',
                            const TextStyle(color: Colors.white),
                          );
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Research indicator
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green
                              .shade300, // Using the lighter shade as in the chart
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Research Value'),
                    ],
                  ),
                  const SizedBox(width: 24), // Spacing between indicators
                  // Test Kit indicator
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green
                              .shade700, // Using the darker shade as in the chart
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Test Kit Value'),
                    ],
                  ),
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: buildLineChart(researchValues, _dataMap),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBarChart(
      Map<String, dynamic> researchValues, Map<String, dynamic> kitValues) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 5,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['Nitrogen', 'Phosphorus', 'Potassium'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          horizontalInterval: 1,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: [
          buildBarGroup(0, researchValues['Nitrogen'], kitValues['Nitrogen'],
              Colors.green),
          buildBarGroup(1, researchValues['Phosphorus'],
              kitValues['Phosphorus'], Colors.blue),
          buildBarGroup(2, researchValues['Potassium'], kitValues['Potassium'],
              Colors.red),
        ],
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              const nutrients = ['Nitrogen', 'Phosphorus', 'Potassium'];
              final nutrient = nutrients[group.x.toInt()];
              final source = rodIndex == 0 ? 'Research' : 'Kit';
              return BarTooltipItem(
                '$source $nutrient\n${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  BarChartGroupData buildBarGroup(
      int x, double researchValue, double kitValue, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: researchValue,
          color: Colors.green.shade600,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: kitValue,
          color: Colors.green.shade800,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget buildLineChart(
      Map<String, dynamic> researchValues, Map<String, dynamic> kitValues) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Nitrogen', 'Phosphorus', 'Potassium'];
                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        titles[value.toInt()],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('hellooo');
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, researchValues['Nitrogen'].toDouble()),
                FlSpot(1, researchValues['Phosphorus'].toDouble()),
                FlSpot(2, researchValues['Potassium'].toDouble()),
              ],
              isCurved: true,
              color: Colors.green.shade700,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              barWidth: 3,
            ),
            LineChartBarData(
              spots: [
                FlSpot(0, kitValues['Nitrogen']?.toDouble() ?? 0),
                FlSpot(1, kitValues['Phosphorus']?.toDouble() ?? 0),
                FlSpot(2, kitValues['Potassium']?.toDouble() ?? 0),
              ],
              isCurved: true,
              color: Colors.green.shade300,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: _dataMap['Nitrogen (N)'] ?? 0,
              color: Colors.green,
              title:
                  'Nitrogen (N)\n${_dataMap['Nitrogen (N)']?.toStringAsFixed(1) ?? '0'}',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: _dataMap['Phosphorus (P)'] ?? 0,
              color: Colors.blue,
              title:
                  'Phosphorus (P)\n${_dataMap['Phosphorus (P)']?.toStringAsFixed(1) ?? '0'}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: _dataMap['Potassium (K)'] ?? 0,
              color: Colors.red,
              title:
                  'Potassium (K)\n${_dataMap['Potassium (K)']?.toStringAsFixed(1) ?? '0'}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 3,
          borderData: FlBorderData(show: false),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }

  Widget _buildManualSection(Map<String, String> section, int index) {
    bool isEvenIndex = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isEvenIndex
            ? [
                Expanded(
                  child: _buildContent(
                      index + 1, section['title']!, section['content']!),
                ),
                Expanded(
                  child: _buildImage(section['imagePath']!),
                ),
              ]
            : [
                Expanded(
                  child: _buildImage(section['imagePath']!),
                ),
                Expanded(
                  child: _buildContent(
                      index + 1, section['title']!, section['content']!),
                ),
              ],
      ),
    );
  }

  Widget _buildContent(int sectionNumber, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display section number along with the title
          Text(
            '$sectionNumber. $title', // Add the section number before the title
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.start,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

Widget _buildImage(String imagePath) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.asset(
      imagePath,
      height: 200,
      width: 200,
      fit: BoxFit.contain,
    ),
  );
}
