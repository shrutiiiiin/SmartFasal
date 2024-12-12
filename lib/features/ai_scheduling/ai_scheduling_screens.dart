import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AiScheduling extends StatefulWidget {
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;

  const AiScheduling({
    Key? key,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
  }) : super(key: key);

  @override
  _AiSchedulingState createState() => _AiSchedulingState();
}

class _AiSchedulingState extends State<AiScheduling> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String npkValues = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateNPKValues();
  }

  void _updateNPKValues() {
    setState(() {
      npkValues =
          'Nitrogen: ${widget.nitrogen}, Phosphorus: ${widget.phosphorus}, Potassium: ${widget.potassium}';
    });
  }

  Future<void> _saveNPKValues() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('fertilizer_checkups')
          .doc(user.uid)
          .collection('checkups')
          .doc(_selectedDay.toString())
          .set({
        'nitrogen': widget.nitrogen,
        'phosphorus': widget.phosphorus,
        'potassium': widget.potassium,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NPK values saved successfully!')),
      );
    } catch (e) {
      print("Error saving NPK values: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Scheduling')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart AI Scheduling for Seamless Farm Management',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Day: ${_selectedDay?.toLocal().toString().split(' ')[0] ?? 'No day selected'}',
            ),
            const SizedBox(height: 20),
            Text(
              'NPK Values: $npkValues',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNPKValues,
              child: const Text('Save NPK Values for Selected Day'),
            ),
          ],
        ),
      ),
    );
  }
}
