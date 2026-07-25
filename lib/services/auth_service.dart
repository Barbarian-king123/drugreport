import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendOtp({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) {},
      verificationFailed: (e) => onError(e.message ?? 'Failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    await _ensureUserDoc(result.user!);
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'phoneNumber': user.phoneNumber ?? '',
        'role': 'citizen',
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
    final q = await _firestore.collection('officers').where('phoneNumber', isEqualTo: phone).limit(1).get();
    return q.docs.isNotEmpty;
  }
}
