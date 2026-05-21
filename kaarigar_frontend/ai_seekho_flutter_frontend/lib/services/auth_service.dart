import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/firebase_bootstrap.dart';
import '../core/network/http_client.dart';

class AuthService {
  AuthService({required this.firebaseEnabled}) {
    if (firebaseEnabled) {
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          try {
            final token = await user.getIdToken();
            HttpClient.bearerToken = token;
            HttpClient.demoUid = user.uid;
          } catch (_) {}
        } else {
          HttpClient.bearerToken = null;
          HttpClient.demoUid = null;
        }
      });
    }
  }

  final bool firebaseEnabled;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  String? get userId {
    if (firebaseEnabled) {
      return _auth.currentUser?.uid;
    }
    return HttpClient.demoUid;
  }

  Future<void> signInWithPhone(
    String phoneNumber, {
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  }) async {
    if (!firebaseEnabled) {
      onError('Firebase not configured — use demo OTP flow');
      return;
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (!firebaseEnabled) return false;
    if (_verificationId == null) return false;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    if (firebaseEnabled) {
      await _auth.signOut();
    }
    HttpClient.bearerToken = null;
    HttpClient.demoUid = null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final enabled = ref.watch(firebaseEnabledProvider);
  return AuthService(firebaseEnabled: enabled);
});
