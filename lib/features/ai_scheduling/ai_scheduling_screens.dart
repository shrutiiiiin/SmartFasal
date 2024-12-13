import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AiScheduling extends StatefulWidget {
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;

  const AiScheduling({
    super.key,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
  });

  @override
  _AiSchedulingState createState() => _AiSchedulingState();
}

class _AiSchedulingState extends State<AiScheduling> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String npkValues = '';
  DateTime _selectedDateTime = DateTime.now(); // Initialize the variable here

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

    DateTime reminderDate = _selectedDay!.add(const Duration(days: 3));

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
        'reminderDate': reminderDate.toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NPK values saved successfully!')),
      );
    } catch (e) {
      print("Error saving NPK values: $e");
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<Map<String, dynamic>?> fetchValuesNPK(DateTime selectedDay) async {
    try {
      // Define the start and end of the selected day
      DateTime startOfDay =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      // Query Firestore for documents within the selected day's range
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc('realtime data value')
          .collection('soil_data')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        print('No data found for the selected day.');
        return null;
      }
    } catch (e) {
      print("Error fetching NPK values: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('AI Scheduling')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NPK Update Feed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchValuesNPK(_selectedDay!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error fetching data');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text(
                        'No data available for the selected day.');
                  }

                  final data = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fetched NPK Values:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text('Nitrogen: ${data['nitrogen'] ?? 'N/A'}'),
                      Text('Phosphorus: ${data['phosphorus'] ?? 'N/A'}'),
                      Text('Potassium: ${data['potassium'] ?? 'N/A'}'),
                      Text('pH: ${data['ph'] ?? 'N/A'}'),
                      Text(
                          'Recommended Crop: ${data['recommendedCrop'] ?? 'N/A'}'),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Fertilizer Reminder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 338,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: ShapeDecoration(
                  color: Colors.white12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time & Date',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: _selectDateTime,
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: const ShapeDecoration(
                              color: Color(0x91D9D9D9),
                              shape: OvalBorder(),
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/Ai_scheduling/edit_icon.png',
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/Ai_scheduling/clock_icon.png',
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              DateFormat('hh:mm').format(_selectedDateTime),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF494E54),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              DateFormat('a').format(_selectedDateTime),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF494E54),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        Text(
                          DateFormat('dd MMM, yyyy').format(_selectedDateTime),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF494E54),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 0.09,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
