import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/http_client.dart';

/// True when [Firebase.initializeApp] succeeded this session.
final firebaseEnabledProvider = Provider<bool>((ref) => false);

/// Attempts Firebase init. Returns whether phone auth can use Firebase.
Future<bool> bootstrapFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase not configured — using demo session: $e');
    }
    return false;
  }
}

/// Demo OTP path when Firebase is unavailable (no google-services / options).
void activateDemoSession({String? phoneDigits}) {
  final suffix = (phoneDigits ?? '').replaceAll(RegExp(r'\D'), '');
  HttpClient.demoUid = suffix.isNotEmpty
      ? 'demo_$suffix'
      : 'user_demo_001';
  HttpClient.bearerToken = null;
}
