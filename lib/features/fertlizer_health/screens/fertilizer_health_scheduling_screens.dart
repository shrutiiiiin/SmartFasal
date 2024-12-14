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
  List<dynamic>? _selectedDayData; // To store selected day's data
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedNutrient = 'Nitrogen'; // Default nutrient
  int _selectedDay = DateTime.now().weekday; // Default to current day
  double _selectedDayMaxValue =
      0.0; // To store the max value for the selected day

  @override
  void initState() {
    super.initState();
    // Fetch data for the entire week initially
    _fetchNPKDataWeek();
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
            // Store weekly data for chart display
            _npkData = flattenedData;
            // Initially filter data for the current day
            _selectedDayData = _filterDataForDay(_selectedDay);
            _selectedDayMaxValue = _getMaxNutrientValueForDay(_selectedDay);
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

  List<dynamic> _filterDataForDay(int day) {
    if (_npkData == null) return [];

    return _npkData!.where((dataPoint) {
      DateTime date = DateTime.parse(dataPoint['timestamp']);
      return date.weekday == day;
    }).toList();
  }

  double _getMaxNutrientValueForDay(int day) {
    double maxNutrientValue = 0.0;
    for (var dataPoint in _npkData!) {
      DateTime date = DateTime.parse(dataPoint['timestamp']);
      if (date.weekday == day) {
        double nutrientValue;
        switch (_selectedNutrient) {
          case 'Nitrogen':
            nutrientValue = double.parse(dataPoint['nitrogen'] ?? '0');
            break;
          case 'Phosphorus':
            nutrientValue = double.parse(dataPoint['phosphorus'] ?? '0');
            break;
          case 'Potassium':
            nutrientValue = double.parse(dataPoint['potassium'] ?? '0');
            break;
          default:
            nutrientValue = 0.0;
        }
        maxNutrientValue = max(maxNutrientValue, nutrientValue);
      }
    }
    return maxNutrientValue;
  }

  List<BarChartGroupData> _createChartData() {
    if (_npkData == null || _npkData!.isEmpty) return [];

    // Initialize a map to hold nutrient values for each day of the week
    Map<int, double> maxNutrientValues = {
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0,
      7: 0.0
    };

    // Process each data point and store maximum values per weekday
    for (var dataPoint in _npkData!) {
      DateTime date = DateTime.parse(dataPoint['timestamp']);
      int dayOfWeek = date.weekday; // Monday=1, Sunday=7
      double nutrientValue;

      switch (_selectedNutrient) {
        case 'Nitrogen':
          nutrientValue = double.parse(dataPoint['nitrogen'] ?? '0');
          break;
        case 'Phosphorus':
          nutrientValue = double.parse(dataPoint['phosphorus'] ?? '0');
          break;
        case 'Potassium':
          nutrientValue = double.parse(dataPoint['potassium'] ?? '0');
          break;
        default:
          nutrientValue = 0.0;
      }

      // Update maximum nutrient value for each day
      maxNutrientValues[dayOfWeek] =
          max(maxNutrientValues[dayOfWeek]!, nutrientValue);
    }

    // Ordered days from Sunday to Saturday
    List<int> orderedDays = [7, 1, 2, 3, 4, 5, 6];

    return orderedDays.map((day) {
      double value = maxNutrientValues[day] ?? 0.0;

      Color barColor;

      if (_selectedDay == day) {
        // Highlight selected day
        barColor = Colors.red; // Different color for selected day
      } else {
        barColor = Colors.greenAccent; // Default color
      }

      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            width: 20,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    }).toList();
  }

  void _onBarTapped(int day) {
    setState(() {
      _selectedDay = day; // Store the tapped day using the correct x value
      _selectedDayData =
          _filterDataForDay(day); // Filter data for the selected day
      _selectedDayMaxValue =
          _getMaxNutrientValueForDay(day); // Get max value for the tapped day
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NPK Data', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display the message indicating that the chart shows maximum values
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Chart displays the maximum nutrient values for each day of the week.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
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
                            const Icon(Icons.grain),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedNutrient = newValue!;
                        // Re-filter data for the currently selected day when nutrient changes
                        _selectedDayData = _filterDataForDay(_selectedDay);
                        _selectedDayMaxValue = _getMaxNutrientValueForDay(
                            _selectedDay); // Update max value
                      });
                    },
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Space between dropdown and chart
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : Column(
                            children: [
                              SizedBox(
                                height: 250,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: _createChartData(),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toStringAsFixed(0),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                          reservedSize: 40,
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
                                                    daysOfWeek.length];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
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
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(
                                      drawHorizontalLine: true,
                                      drawVerticalLine: false,
                                    ),
                                    barTouchData: BarTouchData(
                                      touchCallback: (event, response) {
                                        if (response != null &&
                                            response.spot != null) {
                                          final tappedDay = response
                                              .spot!
                                              .touchedBarGroup
                                              .x; // Use x value of the group
                                          _onBarTapped(tappedDay);
                                        }
                                      },
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) =>
                                            Colors.blueAccent,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            '${group.x}: ${rod.toY.toStringAsFixed(2)}',
                                            const TextStyle(
                                                color: Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Show the maximum value when a bar is tapped
                              if (_selectedDayMaxValue > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'Max $_selectedNutrient value for ${[
                                      'Sun',
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat'
                                    ][_selectedDay - 1]}: ${_selectedDayMaxValue.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              // Display individual day tiles
                              if (_selectedDayData != null &&
                                  _selectedDayData!.isNotEmpty)
                                Column(
                                  children: [
                                    ..._selectedDayData!.map((dataPoint) =>
                                        Card(
                                          elevation: 4,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            leading: const Icon(
                                              Icons.grain,
                                              color: Colors.green,
                                            ),
                                            title: Text(
                                              'Date: ${DateTime.parse(dataPoint['timestamp']).toLocal().toString().split(' ')[0]}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              '$_selectedNutrient: ${dataPoint[_selectedNutrient.toLowerCase()] ?? "No Data"}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                            ],
                          )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
