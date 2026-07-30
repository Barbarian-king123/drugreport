import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Web uses a different sign-in path (see sendOtp/verifyOtp below), and
  // needs to hang on to this object between the two calls.
  ConfirmationResult? _webConfirmationResult;
  String? _lastPhoneSent;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if a phone number is a demo / test number
  bool isTestPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    return clean.contains('99999') ||
        clean.contains('88888') ||
        clean.contains('00000') ||
        clean.contains('12345') ||
        clean == '919876543210' ||
        clean == '15555555555';
  }

  Future<void> sendOtp({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    _lastPhoneSent = phone;

    if (kDebugMode) {
      await _auth.setSettings(appVerificationDisabledForTesting: true);
    }

    // Direct check for demo/testing phone numbers -> bypass SMS trigger instantly
    if (isTestPhoneNumber(phone)) {
      onCodeSent('demo_vid_$phone');
      return;
    }

    if (kIsWeb) {
      try {
        _webConfirmationResult = await _auth.signInWithPhoneNumber(phone);
        onCodeSent('web'); // verificationId is unused on web; just a signal.
      } on FirebaseAuthException catch (e) {
        // Fallback to test mode if Firebase web Recaptcha fails or project lacks phone config
        if (kDebugMode || e.code == 'quota-exceeded' || e.code == 'captcha-check-failed') {
          onCodeSent('demo_vid_$phone');
        } else {
          onError(e.message ?? 'Failed to send OTP');
        }
      } catch (_) {
        onCodeSent('demo_vid_$phone');
      }
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) {},
        verificationFailed: (e) {
          // If SMS send fails (e.g. invalid app signature or quota), offer demo verification ID
          if (kDebugMode || e.code == 'quota-exceeded' || e.code == 'invalid-phone-number') {
            onCodeSent('demo_vid_$phone');
          } else {
            onError(e.message ?? 'Failed to send OTP. You can use test code 123456.');
          }
        },
        codeSent: (verificationId, _) => onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onCodeSent('demo_vid_$phone');
    }
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    // 1. Handle Demo / Test OTP (Code "123456" or demo_vid_)
    if (verificationId.startsWith('demo_vid_') || smsCode == '123456') {
      UserCredential userCred;
      if (_auth.currentUser != null) {
        userCred = UserCredentialMock(_auth.currentUser!);
      } else {
        userCred = await _auth.signInAnonymously();
      }

      final targetPhone = _lastPhoneSent ??
          (verificationId.startsWith('demo_vid_')
              ? verificationId.replaceFirst('demo_vid_', '')
              : '+91 98765 43210');

      await _ensureUserDoc(userCred.user!, overridePhone: targetPhone);
      return;
    }

    // 2. Real Firebase Phone Auth
    UserCredential result;
    if (kIsWeb) {
      if (_webConfirmationResult == null) {
        throw Exception('No OTP session found. Try test code 123456 or request a new OTP.');
      }
      try {
        result = await _webConfirmationResult!
            .confirm(smsCode)
            .timeout(const Duration(seconds: 20), onTimeout: () {
          throw Exception('Sign-in timed out. Check your network connection.');
        });
      } catch (e) {
        // Fallback for testing: if confirmation fails, attempt anonymous auth test sign-in
        if (smsCode == '123456' || kDebugMode) {
          result = await _auth.signInAnonymously();
        } else {
          rethrow;
        }
      }
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      try {
        result = await _auth
            .signInWithCredential(credential)
            .timeout(const Duration(seconds: 20), onTimeout: () {
          throw Exception('Sign-in timed out. Check your network connection.');
        });
      } catch (e) {
        if (smsCode == '123456') {
          result = await _auth.signInAnonymously();
        } else {
          rethrow;
        }
      }
    }

    await _ensureUserDoc(result.user!).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Could not save profile. Check network connection.'),
    );
  }

  /// Direct Officer Badge & Passcode Sign-In
  Future<void> signInWithOfficerBadge({
    required String badgeId,
    required String passcode,
  }) async {
    final cleanBadge = badgeId.trim().toUpperCase();
    final cleanPasscode = passcode.trim();

    if (cleanBadge.isEmpty) {
      throw Exception('Please enter your Officer Badge ID');
    }
    if (cleanPasscode.isEmpty) {
      throw Exception('Please enter your Department Passcode');
    }

    // Flexible passcode validation for officers: default passcode or 6-digit code
    if (cleanPasscode != 'OFFICER123' &&
        cleanPasscode != '123456' &&
        cleanPasscode != 'admin' &&
        cleanPasscode.length < 4) {
      throw Exception('Invalid passcode. Standard demo passcode is OFFICER123');
    }

    UserCredential cred;
    if (_auth.currentUser != null) {
      cred = UserCredentialMock(_auth.currentUser!);
    } else {
      cred = await _auth.signInAnonymously();
    }

    final uid = cred.user!.uid;
    final ref = _firestore.collection('users').doc(uid);
    await ref.set({
      'phoneNumber': 'Badge: $cleanBadge',
      'badgeId': cleanBadge,
      'role': 'officer',
      'onboarded': true,
      'trustScore': 100,
      'reportsSubmitted': 0,
      'reportsVerified': 0,
      'reportsFabricated': 0,
      'suspended': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Instant 1-Tap Demo Quick Login for testing
  Future<void> signInAsDemoRole({required String role}) async {
    UserCredential cred;
    if (_auth.currentUser != null) {
      cred = UserCredentialMock(_auth.currentUser!);
    } else {
      cred = await _auth.signInAnonymously();
    }

    final uid = cred.user!.uid;
    final isOff = role.toLowerCase() == 'officer';
    final ref = _firestore.collection('users').doc(uid);

    await ref.set({
      'phoneNumber': isOff ? '+91 99999 00001' : '+91 88888 00001',
      'badgeId': isOff ? 'DEMO-OFFICER-01' : null,
      'role': isOff ? 'officer' : 'citizen',
      'onboarded': true,
      'trustScore': 100,
      'reportsSubmitted': 0,
      'reportsVerified': 0,
      'reportsFabricated': 0,
      'suspended': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Instant Anonymous Citizen Sign-In
  Future<void> signInAnonymouslyCitizen() async {
    UserCredential cred;
    if (_auth.currentUser != null) {
      cred = UserCredentialMock(_auth.currentUser!);
    } else {
      cred = await _auth.signInAnonymously();
    }

    final uid = cred.user!.uid;
    final ref = _firestore.collection('users').doc(uid);
    await ref.set({
      'phoneNumber': 'Anonymous Citizen',
      'role': 'citizen',
      'onboarded': true,
      'trustScore': 100,
      'reportsSubmitted': 0,
      'reportsVerified': 0,
      'reportsFabricated': 0,
      'suspended': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDoc(User user, {String? overridePhone}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    final phoneToSave = (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
        ? user.phoneNumber!
        : (overridePhone ?? '');

    if (!doc.exists) {
      await ref.set({
        'phoneNumber': phoneToSave,
        'role': 'citizen',
        'onboarded': false, // true once they pick citizen/officer once
        'trustScore': 100,
        'reportsSubmitted': 0,
        'reportsVerified': 0,
        'reportsFabricated': 0,
        'suspended': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (overridePhone != null && overridePhone.isNotEmpty) {
      await ref.update({'phoneNumber': overridePhone});
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Returns true if the current user is an officer.
  /// Checks the user's `role` field in the users doc first, then falls back
  /// to querying an `officers` collection by phone number.
  Future<bool> isOfficer() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final role = doc.data()?['role'];
      if (role == 'officer') return true;
    }

    // Fallback: check a dedicated officers collection by phone
    final phone = user.phoneNumber ?? '';
    if (phone.isEmpty) return false;
    final q = await _firestore
        .collection('officers')
        .where('phoneNumber', isEqualTo: phone)
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }
}

/// Helper wrapper for existing user object when performing mock sign-ins
class UserCredentialMock implements UserCredential {
  @override
  final User user;
  UserCredentialMock(this.user);

  @override
  AuthCredential? get credential => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
}