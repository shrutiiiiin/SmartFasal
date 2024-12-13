import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:innovators/features/home/screens/home.dart';
import 'package:innovators/firebase_options.dart';
import 'package:innovators/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LocalizationApp());
}

class LocalizationApp extends StatefulWidget {
  const LocalizationApp({super.key});

  @override
  State<LocalizationApp> createState() => _LocalizationAppState();
}

class _LocalizationAppState extends State<LocalizationApp> {
  Locale _locale = const Locale('en');

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('ta'),
        Locale('te'),
      ],
      locale: _locale,
      home: AuthChecker(onLocaleChanged: _updateLocale),
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  final Function(Locale) onLocaleChanged;

  const AuthChecker({super.key, required this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // Redirect to HomeScreen if user is signed in
          return const Home();
        }

        return WelcomeScreen(
          setLocale: (Locale locale) {
            onLocaleChanged(locale);
          },
        );
        // return AiScheduling();
      },
    );
  }
}
