import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseFirestore.instance.collection('config').doc('trustScore').set({
    'verifiedPoints': 5,
    'rejectedPoints': -20,
    'levels': [
      {
        'min': 80,
        'max': 100,
        'label': 'Excellent',
        'sub': 'Keep it up!',
        'color': '#4CAF50',
      },
      {
        'min': 50,
        'max': 79,
        'label': 'Good',
        'sub': "You're doing well.",
        'color': '#8BC34A',
      },
      {
        'min': 20,
        'max': 49,
        'label': 'Warning',
        'sub': 'At risk of ban.',
        'color': '#FF9800',
      },
      {
        'min': 0,
        'max': 19,
        'label': 'Banned',
        'sub': 'Account banned.',
        'color': '#F44336',
      },
    ],
  });

  debugPrint('✅ trustScore config seeded successfully!');
}
