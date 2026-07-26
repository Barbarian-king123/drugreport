import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Web uses a different sign-in path (see sendOtp/verifyOtp below), and
  // needs to hang on to this object between the two calls.
  ConfirmationResult? _webConfirmationResult;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendOtp({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    if (kDebugMode) {
      await _auth.setSettings(appVerificationDisabledForTesting: true);
    }

    if (kIsWeb) {
      // verifyPhoneNumber's internal invisible RecaptchaVerifier on web has
      // a known bug where a failed reCAPTCHA Enterprise init + fallback to
      // v2 can double-complete an internal Future ("Bad state: Future
      // already completed"), which silently kills sign-in and leaves the
      // UI spinning forever. signInWithPhoneNumber is the dedicated web
      // API and doesn't hit this path.
      try {
        _webConfirmationResult = await _auth.signInWithPhoneNumber(phone);
        onCodeSent('web'); // verificationId is unused on web; just a signal.
      } on FirebaseAuthException catch (e) {
        onError(e.message ?? 'Failed to send OTP');
      }
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) {},
      verificationFailed: (e) => onError(e.message ?? 'Failed to send OTP'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    UserCredential result;

    if (kIsWeb) {
      if (_webConfirmationResult == null) {
        throw Exception('No OTP session found. Please request a new code.');
      }
      result = await _webConfirmationResult!
          .confirm(smsCode)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw Exception(
            'Sign-in timed out. Check your network connection and try again.');
      });
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      result = await _auth
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw Exception(
            'Sign-in timed out. Check your network connection and try again.');
      });
    }

    await _ensureUserDoc(result.user!).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
          'Could not save your profile. Check Firestore rules/network.'),
    );
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'phoneNumber': user.phoneNumber ?? '',
        'role': 'citizen',
        'onboarded': false, // true once they pick citizen/officer once
        'trustScore': 100,
        'reportsSubmitted': 0,
        'reportsVerified': 0,
        'reportsFabricated': 0,
        'suspended': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
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