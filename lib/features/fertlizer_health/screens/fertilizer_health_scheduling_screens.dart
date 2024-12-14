import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:innovators/features/home/npk_temp_data_generator.dart';

class NPKDataScreen extends StatefulWidget {
  const NPKDataScreen({super.key});

  @override
  _NPKDataScreenState createState() => _NPKDataScreenState();
}

class _NPKDataScreenState extends State<NPKDataScreen> {
  final NPKDataGenerator _dataGenerator = NPKDataGenerator();
  List<dynamic>? _npkData; // To store weekly data
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedNutrient = 'Nitrogen'; // Default nutrient
  String _dataMode = 'day';

  @override
  void initState() {
    super.initState();

    _fetchNPKDataWeek(); // Fetch weekly data on init
  }

  Future<void> _fetchNPKDataWeek() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      DateTime now = DateTime.now();
      String year = now.year.toString();
      String month = NPKDataGenerator.months[now.month - 1];
      String week = 'Week ${_getCurrentWeekNumber(now)}';

      dynamic data = await _dataGenerator.getNPKData(
        year: year,
        month: month,
        week: week,
      );

      if (data != null && data is Map<String, dynamic>) {
        List<dynamic> flattenedData = [];
        data.forEach((day, dayData) {
          if (dayData is List) {
            flattenedData.addAll(dayData);
          }
        });

        if (flattenedData.isNotEmpty) {
          setState(() {
            _npkData = flattenedData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No data found for the selected week.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No data found for the selected week.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  int _getCurrentWeekNumber(DateTime date) {
    int firstDayOfMonth = DateTime(date.year, date.month, 1).weekday;
    return ((date.day + firstDayOfMonth - 2) ~/ 7) + 1;
  }

  Future<void> _fetchNPKDataDay(String dayName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dataMode = 'day';
    });
    try {
      DateTime now = DateTime.now();
      String year = now.year.toString();
      String month = NPKDataGenerator.months[now.month - 1];
      String week = 'Week ${_getCurrentWeekNumber(now)}';
      String day = dayName;
      print(day);

      dynamic data = await _dataGenerator.getNPKData(
        year: year,
        month: month,
        week: week,
        day: day,
      );
      print(data);

      if (data != null && data is List) {
        setState(() {
          _npkData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No data found for the selected day.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  List<BarChartGroupData> _createChartData() {
    if (_npkData == null || _npkData!.isEmpty) return [];

    Map<int, double> maxNutrientValues =
        {}; // Use integers for day of the week (1=Mon, 7=Sun)

    for (var dataPoint in _npkData!) {
      DateTime date = DateTime.parse(dataPoint['timestamp']);
      int dayOfWeek = date.weekday; // Monday=1, Sunday=7
      double nutrientValue;

      switch (_selectedNutrient) {
        case 'Nitrogen':
          nutrientValue = double.parse(dataPoint['nitrogen']);
          break;
        case 'Phosphorus':
          nutrientValue = double.parse(dataPoint['phosphorus']);
          break;
        case 'Potassium':
          nutrientValue = double.parse(dataPoint['potassium']);
          break;
        default:
          nutrientValue = 0.0;
      }

      if (maxNutrientValues.containsKey(dayOfWeek)) {
        maxNutrientValues[dayOfWeek] =
            max(maxNutrientValues[dayOfWeek]!, nutrientValue);
      } else {
        maxNutrientValues[dayOfWeek] = nutrientValue;
      }
    }

    // Sort the entries by day of the week (1=Mon, ..., 7=Sun)
    List<int> orderedDays = [7, 1, 2, 3, 4, 5, 6]; // Sunday first
    return orderedDays.map((day) {
      double value = maxNutrientValues[day] ?? 0.0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.greenAccent,
            width: 20,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPK Data', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: _selectedNutrient,
                  items: <String>['Nitrogen', 'Phosphorus', 'Potassium']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          const Icon(Icons.grain), // Add an icon here
                          const SizedBox(width: 8),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNutrient = newValue!;
                    });
                  },
                  isExpanded: true,
                  underline: Container(),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ), // Space between dropdown and chart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : SizedBox(
                          height: 250,
                          child: BarChart(BarChartData(
                            barGroups: _createChartData(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(
                                          0), // Format as integers
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                  reservedSize:
                                      40, // Increase space for better alignment
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const daysOfWeek = [
                                      'Sun',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat'
                                    ];
                                    String title = daysOfWeek[
                                        (value.toInt() - 1) %
                                            7]; // Map x value to day name
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hide top titles
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false), // Hide right titles
                              ),
                            ),
                            borderData:
                                FlBorderData(show: false), // Hide borders
                            gridData: const FlGridData(
                              drawHorizontalLine: true,
                              drawVerticalLine: false,
                            ), // Show horizontal grid lines only
                          )),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
