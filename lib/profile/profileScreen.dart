import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final Function(Locale) setLocale;
  final String npkValues; // Assuming NPK values are passed as a string

  const ProfileScreen({
    super.key,
    required this.setLocale,
    required this.npkValues,
  });

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
                padding: const EdgeInsets.all(16.0),
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
                        setLocale(selectedLocale);
                        Navigator.pop(context);
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
    final User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Circle Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Phone Number
            Text(
              user?.phoneNumber ?? '9004789376',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // NPK Values
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.science, color: Colors.green),
                title: Text(
                  npkValues,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  npkValues,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Change Language Button
            ElevatedButton(
              onPressed: () {
                _showLanguageBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context)!.localeName,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
