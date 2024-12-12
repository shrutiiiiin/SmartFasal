import 'dart:async';
import 'dart:convert'; // For JSON encoding
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:innovators/features/home/widgets/bar_graph/bar_graph.dart';
import 'package:innovators/features/home/widgets/home_widget/soil_parameters.dart';
import 'package:innovators/features/home/widgets/home_widget/weather_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SoilAnalaysis extends StatefulWidget {
  const SoilAnalaysis({Key? key}) : super(key: key);

  @override
  State<SoilAnalaysis> createState() => _SoilAnalaysisState();
}

class _SoilAnalaysisState extends State<SoilAnalaysis> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  Map<dynamic, dynamic>? _data;
  late StreamSubscription<DatabaseEvent> _dataSubscription;
  String? recommendedCrop;
  double nitrogen = 0;
  double phosphorus = 0;
  double potassium = 0;
  String fertlizerQuality = 'Good';
  double ph = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToDataChanges();
  }

  void _subscribeToDataChanges() {
    _dataSubscription = _databaseRef.child('data').onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue == null) {
        print("No data found at the specified path.");
      } else {
        setState(() {
          _data = snapshotValue as Map<dynamic, dynamic>?;
          _updateGridData();
          _updateNPKValues();
          _sendPostRequest();
          _storeDataInFirestore();
        });
      }
    }, onError: (error) {
      print("Error getting live data: $error");
    });
  }

  // void _initializeNPKValues() {
  //   setState(() {
  //     nitrogen = 6; // Hardcoded value for nitrogen
  //     phosphorus = 4; // Hardcoded value for phosphorus
  //     potassium = 5.0; // Hardcoded value for potassium
  //   });
  // }

  void _updateNPKValues() {
    if (_data != null) {
      setState(() {
        nitrogen = double.tryParse(_data!['nitrogen']?.toString() ?? '') ?? 6.0;
        phosphorus =
            double.tryParse(_data!['phosphorus']?.toString() ?? '') ?? 4.0;
        potassium =
            double.tryParse(_data!['potassium']?.toString() ?? '') ?? 5.0;
        ph = double.tryParse(_data!['potassium']?.toString() ?? '') ?? 6.50;

        // Use the class-level `fertlizerQuality` variable
        fertlizerQuality = 'Good';
      });

      // Pass the correct `fertlizerQuality` variable to the sendSMS method
      // sendSMS(
      //   '+919321481297',
      //   nitrogen,
      //   phosphorus,
      //   potassium,
      //   fertlizerQuality,
      //   ph, // Pass the correct variable
      // );
    }
  }

  Future<void> _storeDataInFirestore() async {
    if (_data != null) {
      try {
        // Create a document in the user's collection with a timestamp as the document ID
        await _firestore
            .collection('users')
            .doc('realtime data value')
            .collection('soil_data')
            .doc(DateTime.now().toIso8601String())
            .set({
          'nitrogen': nitrogen,
          'phosphorus': phosphorus,
          'potassium': potassium,
          'ph': ph,
          'fertilizerQuality': fertlizerQuality,
          'recommendedCrop': recommendedCrop,
          'temperature': _data!['temperatureC'],
          'humidity': _data!['humidity'],
          'waterLevel': _data!['waterLevel'],
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
        });

        print('Data successfully stored in Firestore');
      } catch (e) {
        print('Error storing data in Firestore: $e');
      }
    }
  }

  Future<void> sendSMS(
    String phoneNumber,
    double nitrogen,
    double phosphorus,
    double potassium,
    String fertilizerQuality,
    double ph,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://npk-sms.onrender.com/send-npk-sms'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to_number': phoneNumber, // Corrected field name
          'nitrogen': nitrogen,
          'phosphorus': phosphorus,
          'potassium': potassium,
          'fertilizer_quality': fertilizerQuality,
          'ph': ph,
          'message':
              'Your NPK values are:\nNitrogen: $nitrogen\nPhosphorus: $phosphorus\nPotassium: $potassium \n ph Value: $ph\nFertilizer Quality: $fertilizerQuality.',
        }),
      );

      if (response.statusCode == 200) {
        print("SMS sent successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SMS sent successfully!")),
        );
      } else {
        print("Failed to send SMS: ${response.statusCode}");
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send SMS: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Error sending SMS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending SMS: $e")),
      );
    }
  }

  // POST request to /predict API
  Future<void> _sendPostRequest() async {
    if (_data != null) {
      try {
        // Prepare the body for the POST request
        var body = jsonEncode({
          'N': 90,
          'P': 42,
          'K': 43,
          'temperature': _data!['temperatureC'] ?? 25,
          'humidity': _data!['humidity'] ?? 86,
          'ph': _data!['pH'] ?? 6.5,
          'rainfall': 220
        });

        // Send POST request
        final response = await http.post(
          Uri.parse(
            'https://chatbot-nr5k.onrender.com/predict',
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          // Decode the response
          final data = jsonDecode(response.body);
          setState(() {
            recommendedCrop =
                data['recommended_crop']; // Save the recommended crop
          });
          print('Recommended Crop: ${data['recommended_crop']}');
        } else {
          print('Failed to get crop recommendation');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> gridData = [
    // {
    //   'title': 'Soil Moisture %',
    //   'value': 'N/A',
    //   'image': 'assets/home/images/soil.png',
    //   'color': const Color(0xff9FDAB0).withOpacity(0.75)
    // },
    // {
    //   'title': 'Temperature',
    //   'value': '25°C',
    //   'image': 'assets/home/images/temp.png',
    //   'color': const Color(0xffFCA74C).withOpacity(0.55)
    // },
    // {
    //   'title': 'Fertlizer level',
    //   'value': 'N/A',
    //   'image': 'assets/home/images/water level.png',
    //   'color': const Color(0xff4CB3FC).withOpacity(0.55)
    // },
    {
      'title': 'pH Level',
      'value': 'N/A',
      'image': 'assets/home/images/ph.png',
      'color': const Color(0xffA6EDFF).withOpacity(0.75)
    },
  ];

  void _updateGridData() {
    if (_data != null) {
      setState(() {
        gridData = [
          // {
          //   'title': AppLocalizations.of(context)!.soilMoisture,
          //   'value': _data!['soilMoisture'] != null
          //       ? "${double.parse(_data!['soilMoisture'].toString()).toStringAsFixed(2)} %"
          //       : 'N/A',
          //   'image': 'assets/home/images/soil.png',
          //   'color': const Color(0xff9FDAB0).withOpacity(0.75)
          // },
          // {
          //   'title': AppLocalizations.of(context)!.temperature,
          //   'value': _data!['temperatureC'] != null
          //       ? "${_data!['temperatureC'].toString()} °C"
          //       : '25°C',
          //   'image': 'assets/home/images/temp.png',
          //   'color': const Color(0xffFCA74C).withOpacity(0.55)
          // },
          {
            'title': AppLocalizations.of(context)!.fertilizerLevel,
            'value': _data!['waterLevel']?.toString() ?? 'N/A',
            'image': 'assets/home/images/water level.png',
            'color': const Color(0xff4CB3FC).withOpacity(0.55)
          },
          {
            'title': AppLocalizations.of(context)!.phLevel,
            'value': _data!['pH'] != null
                ? double.parse(_data!['pH'].toString()).toStringAsFixed(2)
                : 'N/A',
            'image': 'assets/home/images/ph.png',
            'color': const Color(0xffA6EDFF).withOpacity(0.75)
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: WeatherBar(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
          SizedBox(height: screenHeight * 0.014),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: screenHeight * 0.3,
              width: double.infinity,
              child: BarGraph(
                nitrogen: nitrogen,
                phosphorus: phosphorus,
                potassium: potassium,
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.18,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: soil_parameters(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                gridData: gridData,
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 18, right: 14, bottom: 20),
          //   child: Crop_recommendation(
          //     screenWidth: screenWidth,
          //     screenHeight: screenHeight,
          //     recommendedCrop: recommendedCrop ?? 'Loading...',
          //   ),
          // ),
        ],
      ),
    );
  }
}
