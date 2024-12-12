import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:innovators/features/home/screens/home.dart';
import 'package:innovators/phone_login/phonelogin_screen.dart';
import 'package:innovators/phone_login/phonelogin_services.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(Locale) setLocale;

  const WelcomeScreen({super.key, required this.setLocale});

  // Function to show ModalBottomSheet for language selection
  void _showLanguageBottomSheet(BuildContext context) {
    final List<Map<String, dynamic>> languages = [
      {
        'name': 'English',
        'locale': const Locale('en'),
        'nativeName': 'English'
      },
      {'name': 'Hindi', 'locale': const Locale('hi'), 'nativeName': 'हिन्दी'},
      {'name': 'Marathi', 'locale': const Locale('mr'), 'nativeName': 'मराठी'},
      {'name': 'Tamil', 'locale': const Locale('ta'), 'nativeName': 'தமிழ்'},
      {'name': 'Telugu', 'locale': const Locale('te'), 'nativeName': 'తెలుగు'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        languages[index]['nativeName'],
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      subtitle: Text(
                        languages[index]['name'],
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Locale selectedLocale = languages[index]['locale'];
                        print("Selected Language: ${languages[index]['name']}");

                        setLocale(selectedLocale);

                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhoneLoginScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF228B22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF228B22),
        elevation: 0, // Remove shadow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Text(
                  AppLocalizations.of(context)!.welcomeToSmartFasal,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32, // Reduced from 42
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/home/images/new_logo.jpg',
                      width: 200, // Added fixed width
                      height: 200, // Added fixed height
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 220), // Added space before button
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: () {
                      _showLanguageBottomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.continuebutton,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
