import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/officer/officer_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drug Report App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFFE53341),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFFE53341),
              surface: const Color(0xFF17171F),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D12),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53341),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Color(0xFF2A2A35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF17171F),
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF23232E)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17171F),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF23232E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF23232E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53341)),
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE53341).withValues(alpha: 0.15),
          labelStyle: const TextStyle(
            color: Color(0xFFE53341),
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// TEMP: bypasses phone OTP login using Firebase Anonymous Auth so you can
/// test all screens without a real phone/SMS. Revert to phone auth flow
/// (PhoneAuthScreen) before real use, since anonymous users have no
/// verified phone number tied to them.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _bypassSignIn() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _bypassSignIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final uid = FirebaseAuth.instance.currentUser!.uid;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData = userSnap.data!.data() as Map<String, dynamic>?;
            final role = userData?['role']?.toString().toLowerCase() ?? 'citizen';
            if (role == 'officer') {
              return const OfficerHomeScreen();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
