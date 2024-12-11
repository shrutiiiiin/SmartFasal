import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AiScheduling extends StatefulWidget {
  const AiScheduling({super.key});

  @override
  _AiSchedulingState createState() => _AiSchedulingState();
}

class _AiSchedulingState extends State<AiScheduling> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String npkValues = '';

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initialize with the current date
  }

  // Fetch NPK values for the selected day from Firebase
  Future<void> _fetchNPKValues() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('fertilizer_checkups')
          .doc(user.uid)
          .collection('checkups')
          .doc(_selectedDay.toString())
          .get();

      if (snapshot.exists) {
        setState(() {
          npkValues = snapshot['npk_values'] ?? 'No NPK values available';
        });
      } else {
        setState(() {
          npkValues = 'No NPK values for this day';
        });
      }
    } catch (e) {
      print("Error fetching NPK values: $e");
    }
  }

  // Save NPK values to Firebase for the selected day
  Future<void> _saveNPKValues(String npkValue) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('fertilizer_checkups')
          .doc(user.uid)
          .collection('checkups')
          .doc(_selectedDay.toString())
          .set({
        'npk_values': npkValue,
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
      appBar: AppBar(
        title: const Text('AI Scheduling'),
      ),
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
            // Calendar widget
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

                // Fetch and display NPK values for the selected day
                _fetchNPKValues();
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
            // Display NPK values for the selected day
            Text(
              'NPK Values: $npkValues',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Button to set NPK values for the selected day
            ElevatedButton(
              onPressed: () {
                if (_selectedDay != null) {
                  _showNPKDialog(context);
                }
              },
              child: const Text('Set NPK Values for Selected Day'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog to input NPK values for the selected day
  void _showNPKDialog(BuildContext context) {
    String npkValue = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter NPK Values'),
          content: TextField(
            onChanged: (value) {
              npkValue = value;
            },
            decoration: const InputDecoration(hintText: 'Enter NPK values'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (npkValue.isNotEmpty) {
                  _saveNPKValues(npkValue);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
