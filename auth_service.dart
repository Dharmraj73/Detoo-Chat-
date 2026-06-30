import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String _verificationId = '';

  /// Send OTP to Indian phone number (+91)
  Future<void> sendOTP({
    required String phoneNumber, // e.g. +919876543210
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerify(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'OTP bhejne me error aaya');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Verify OTP entered by user
  Future<UserCredential> verifyOTP(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    UserCredential result = await _auth.signInWithCredential(credential);
    return result;
  }

  /// Create user profile in Firestore after successful OTP verification
  Future<void> createUserProfile({
    required String uid,
    required String phoneNumber,
    required String name,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'phoneNumber': phoneNumber,
      'name': name,
      'status': 'Hey there! I am using Detoo',
      'isOnline': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    notifyListeners();
  }

  Future<bool> userProfileExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (currentUser == null) return;
    await _firestore.collection('users').doc(currentUser!.uid).update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> signOut() async {
    await updateOnlineStatus(false);
    await _auth.signOut();
    notifyListeners();
  }
}
