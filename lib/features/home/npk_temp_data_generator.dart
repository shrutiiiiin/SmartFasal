import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NPKDataGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Helper method to get week number in month
  int _getWeekNumberInMonth(DateTime date) {
    int firstDayOfMonth = DateTime(date.year, date.month, 1).weekday;
    return ((date.day + firstDayOfMonth - 2) ~/ 7) + 1;
  }

  Future<void> generateNestedNPKData() async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user signed in');
      return;
    }

    // Get the current date
    DateTime now = DateTime.now();

    // Nested data structure
    Map<String, dynamic> nestedData = {};

    // Generate data for the current year
    for (int month = 1; month <= 12; month++) {
      // Get the number of days in this month
      int daysInMonth = DateTime(now.year, month + 1, 0).day;

      // Create month entry
      nestedData[now.year.toString()] ??= {};
      nestedData[now.year.toString()][months[month - 1]] ??= {};

      // Iterate through days in the month
      for (int day = 1; day <= daysInMonth; day++) {
        DateTime currentDate = DateTime(now.year, month, day);

        // Get week number and day of week
        int weekNumber = _getWeekNumberInMonth(currentDate);
        String weekKey = 'Week $weekNumber';
        String dayOfWeek = daysOfWeek[currentDate.weekday - 1];

        // Create week and day entries
        nestedData[now.year.toString()][months[month - 1]][weekKey] ??= {};
        nestedData[now.year.toString()][months[month - 1]][weekKey]
            [dayOfWeek] ??= [];

        // Generate multiple data points for this day
        List<Map<String, dynamic>> dailyDataPoints = [];
        int dataPointsCount = 3 + _random.nextInt(8); // 3 to 10 data points

        for (int i = 0; i < dataPointsCount; i++) {
          // Generate NPK values
          double nitrogen = 40 + _random.nextDouble() * 20; // 40-60 range
          double phosphorus = 30 + _random.nextDouble() * 20; // 30-50 range
          double potassium = 35 + _random.nextDouble() * 20; // 35-55 range

          // Ensure one value is the highest
          int maxIndex = _random.nextInt(3);
          if (maxIndex == 0) {
            nitrogen = max(nitrogen, max(phosphorus, potassium));
          } else if (maxIndex == 1) {
            phosphorus = max(nitrogen, max(phosphorus, potassium));
          } else {
            potassium = max(nitrogen, max(phosphorus, potassium));
          }

          dailyDataPoints.add({
            'dataPointId': i + 1,
            'nitrogen': nitrogen.toStringAsFixed(2),
            'phosphorus': phosphorus.toStringAsFixed(2),
            'potassium': potassium.toStringAsFixed(2),
            'ph': (6.5 + _random.nextDouble()).toStringAsFixed(2),
            'timestamp': currentDate.toIso8601String(),
          });
        }

        // Add daily data points
        nestedData[now.year.toString()][months[month - 1]][weekKey][dayOfWeek] =
            dailyDataPoints;
      }
    }

    // Save to Firestore
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('npk_history')
        .doc('structured_data')
        .set(nestedData);

    print('Nested NPK data generated and stored successfully.');
  }

  // Method to fetch and print sample data (for demonstration)
  Future<void> printSampleData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('npk_history')
          .doc('structured_data')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Print sample data - current year, first month, first week, first day
        String currentYear = DateTime.now().year.toString();
        String firstMonth = months[0];
        String firstWeek = 'Week 1';
        String firstDay = daysOfWeek[0];

        print('Sample Data Structure:');
        print('Year: $currentYear');
        print('Month: $firstMonth');
        print('Week: $firstWeek');
        print('Day: $firstDay');

        var sampleDayData = data[currentYear][firstMonth][firstWeek][firstDay];
        print('\nData Points for $firstDay:');
        for (var dataPoint in sampleDayData) {
          print('Data Point ID: ${dataPoint['dataPointId']}');
          print('Nitrogen: ${dataPoint['nitrogen']}');
          print('Phosphorus: ${dataPoint['phosphorus']}');
          print('Potassium: ${dataPoint['potassium']}');
          print('pH: ${dataPoint['ph']}');
          print('Timestamp: ${dataPoint['timestamp']}');
          print('---');
        }
      }
    } catch (e) {
      print('Error fetching sample data: $e');
    }
  }

  // Method to retrieve specific data
  Future<dynamic> getNPKData({
    String? year,
    String? month,
    String? week,
    String? day,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('npk_history')
          .doc('structured_data')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        dynamic result = data;
        if (year != null) result = result[year];
        if (month != null) result = result[month];
        if (week != null) result = result[week];
        if (day != null) result = result[day];

        return result;
      }
    } catch (e) {
      print('Error retrieving NPK data: $e');
    }
    return null;
  }
}
