import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class fertilizercalc extends StatefulWidget {
  const fertilizercalc({super.key});

  @override
  State<fertilizercalc> createState() => _fertilizercalcState();
}

class _fertilizercalcState extends State<fertilizercalc> {
  String? selectedCrop;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedUnit = 'Acre'; // Default unit
  double landArea = 0.0;
  double nitrogenValue = 0.0;
  double phosphorusValue = 0.0;
  double potassiumValue = 0.0;

  double calculateUreaDosage() {
    return nitrogenValue / 0.46; // Urea contains 46% nitrogen
  }

  final List<Map<String, String>> crops = [
    {"name": "Wheat", "image": "assets/home/images/wheat.png"},
    {"name": "Rice", "image": "assets/home/images/rice.png"},
    {"name": "Cotton", "image": "assets/home/images/cotton.png"},
    {"name": "Maize", "image": "assets/home/images/maize.jpg"},
    {"name": "Sugarcane", "image": "assets/home/images/sugarcane.jpg"},
  ];

  Future<Map<String, dynamic>?> fetchValuesNPK(DateTime selectedDay) async {
    try {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.handleFertilizerCalc),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Select Crop',
              ),
              value: selectedCrop,
              items: crops.map((crop) {
                return DropdownMenuItem<String>(
                  value: crop['name'],
                  child: Row(
                    children: [
                      Image.asset(
                        crop['image']!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Text(crop['name']!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCrop = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          if (selectedCrop != null)
            Text(
              'You selected: $selectedCrop',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Enter Land Area',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                landArea = double.tryParse(value) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Select Land Unit',
            ),
            value: selectedUnit,
            items: ['Acre', 'Hectare', 'Square Meter', 'Bigha']
                .map((unit) => DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedUnit = value;
              });
            },
          ),
          const SizedBox(height: 20),
          if (selectedCrop != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NPK Values for $selectedCrop:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Nitrogen (N): $nitrogenValue kg'),
                Text('Phosphorus (P): $phosphorusValue kg'),
                Text('Potassium (K): $potassiumValue kg'),
                const SizedBox(height: 10),
                Text(
                  'Urea Dosage (kg): ${calculateUreaDosage().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
