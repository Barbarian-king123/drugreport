import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/auth/role_based_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/officer/officer_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DrugReport App',
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryCoral),
            ),
          );
        }

        final user = authSnap.data;
        if (user == null) {
          return const PhoneAuthScreen();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.bg,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryCoral),
                ),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const Scaffold(
                backgroundColor: AppColors.bg,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryCoral),
                ),
              );
            }

            final userData = userSnap.data!.data() as Map<String, dynamic>?;

            final onboarded = userData?['onboarded'] as bool? ?? true;
            if (!onboarded) {
              return const RoleSelectionScreen();
            }

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