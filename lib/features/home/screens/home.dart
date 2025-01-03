import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:innovators/features/chatbot.dart';
import 'package:innovators/features/fertlizer_health/screens/fertilizer_calculate.dart';
import 'package:innovators/features/fertlizer_health/screens/fertilizer_health_scheduling_screens.dart';
import 'package:innovators/features/home/npk_temp_data_generator.dart';
import 'package:innovators/features/home/screens/soil_analaysis.dart';
import 'package:innovators/features/marketplace/screens/crop_realtime.dart';
import 'package:innovators/features/user_manual/user_manual.dart';
import 'package:innovators/profile/profileScreen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  String _pumpStatus = "Off";
  String _pumpEmoji = "🚫";
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _dataSubscription;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isChatBotVisible = false;

  // NPK and Soil Analysis Variables
  double _nitrogen = 0;
  double _phosphorus = 0;
  double _potassium = 0;
  double _ph = 0;
  final String _fertilizerQuality = 'Good';

  void _fetchSoilData() {
    print(FirebaseAuth.instance.currentUser!.phoneNumber);
    _databaseRef.child('data').onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue != null) {
        final data = snapshotValue as Map<dynamic, dynamic>;
        print(data);
        setState(() {
          _nitrogen = double.tryParse(data['nitrogen']?.toString() ?? '') ?? 0;
          _phosphorus =
              double.tryParse(data['phosphorus']?.toString() ?? '') ?? 0;
          _potassium =
              double.tryParse(data['potassium']?.toString() ?? '') ?? 0;
          _ph = double.tryParse(data['pH']?.toString() ?? '') ?? 0;
        });
      }
    });
  }

  Future<void> _sendWhatsAppMessage() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in')),
      );
      return;
    }

    final payload = {
      "nitrogen": _nitrogen.round().toString(),
      "phosphorus": _phosphorus.round().toString(),
      "potassium": _potassium.round().toString(),
      "fertilizer_quality": _fertilizerQuality,
      "ph": _ph.round().toString(),
      "to_number": "whatsapp:${currentUser.phoneNumber}",
      "state": "haryana",
      "language": Localizations.localeOf(context).languageCode,
    };

    // Detailed logging
    print('Payload JSON: ${jsonEncode(payload)}');
    print('Payload Length: ${jsonEncode(payload).length}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff323F23)),
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse('https://npk-sms.onrender.com/send-npk-whatsapp'),
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers from Postman
        },
        body: jsonEncode(payload),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Remove loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A message has been sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error sending message'),
        ));
      }
    } catch (e) {
      // Remove loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error sending message'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAsyncMethods(); // Call the method without await
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeAsyncMethods() async {
    _fetchPumpStatus();
    _fetchSoilData();
    generateTempData();
  }

  void generateTempData() async {
    NPKDataGenerator generator = NPKDataGenerator();
    // await generator.generateNestedNPKData();
    await generator.printSampleData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dataSubscription.cancel();
    super.dispose();
  }

  void _fetchPumpStatus() {
    _dataSubscription = _databaseRef.child('data').onValue.listen((event) {
      final snapshotValue = event.snapshot.value;
      if (snapshotValue == null) {
        print("No data found at the specified path.");
      } else {
        final data = snapshotValue as Map<dynamic, dynamic>;
        print(data);
        setState(() {
          _pumpStatus = data['pumpStatus'] ?? 'Unknown';
          _pumpStatus == "On" ? _pumpEmoji = "💧" : _pumpEmoji = "🚫";
        });
      }
    }, onError: (error) {
      print("Error getting live data: $error");
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _showOptionsBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            children: [
              ListTile(
                leading: Image.asset(
                  'assets/home/icons/Chatbot.png',
                  width: 24,
                ),
                title: Text(
                  AppLocalizations.of(context)!.chatBot,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handlechatBot();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.history_outlined,
                ),
                title: Text(
                  AppLocalizations.of(context)!.ai,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleAIScheduling();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calculate_outlined,
                ),
                title: Text(
                  AppLocalizations.of(context)!.handleFertilizerCalc,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handlefertilizercalculation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAIScheduling() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NPKDataScreen(),
      ),
    );
  }

  void _handlefertilizercalculation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserManualFarmer(),
      ),
    );
  }

  void _handlechatBot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatBotScreen(),
      ),
    );
  }

  void _toggleChatBot() {
    setState(() {
      _isChatBotVisible = !_isChatBotVisible;
      if (_isChatBotVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childrens = [
      const SoilAnalaysis(),
      Container(),
      FertilizerProductsScreen(
        currentLanguage: Localizations.localeOf(context).languageCode,
      ),
      ProfileScreen(
        setLocale: (Locale locale) {
          print('Locale changed to: $locale');
        },
        npkValues:
            'N: $_nitrogen , P: $_phosphorus, K: $_potassium', // Replace with actual NPK values
      ),
    ];
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 4),
              child: Text(
                AppLocalizations.of(context)!.appName,
                style: GoogleFonts.poppins(
                  color: const Color(0xff323F23),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/home/images/whatsapp.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: _sendWhatsAppMessage,
                  ),
                  Text(
                    AppLocalizations.of(context)!.fertilizer_status,
                    style: GoogleFonts.poppins(
                      color: const Color(0xff323F23),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xff323F23),
            height: 0.25,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 15,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/home/icons/Agriculture.png',
              width: screenWidth * 0.08,
            ),
            label: AppLocalizations.of(context)!.analysis,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: AppLocalizations.of(context)!.moreoptions,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/home/icons/irrigationScheme.png',
              width: screenWidth * 0.08,
            ),
            label: AppLocalizations.of(context)!.scheme,
          ),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/home/icons/Profile.png',
                width: screenWidth * 0.08,
              ),
              label: AppLocalizations.of(context)!.profile),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            childrens[_selectedIndex],
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  bottom:
                      _animation.value * MediaQuery.of(context).size.height -
                          MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const ChatBotScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
