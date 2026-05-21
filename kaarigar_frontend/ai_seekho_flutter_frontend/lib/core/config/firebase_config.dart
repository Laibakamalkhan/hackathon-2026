import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for web platforms.
/// Values are loaded from the .env file at runtime. Missing values default to empty strings.
final FirebaseOptions firebaseOptionsWeb = FirebaseOptions(
  apiKey: dotenv.maybeGet('FIREBASE_API_KEY') ?? '',
  authDomain: dotenv.maybeGet('FIREBASE_AUTH_DOMAIN') ?? '',
  projectId: dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? '',
  storageBucket: dotenv.maybeGet('FIREBASE_STORAGE_BUCKET') ?? '',
  messagingSenderId: dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID') ?? '',
  appId: dotenv.maybeGet('FIREBASE_APP_ID') ?? '',
  measurementId: dotenv.maybeGet('FIREBASE_MEASUREMENT_ID') ?? '',
);
