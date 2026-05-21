import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import '../core/config/firebase_config.dart';

/// A full‑screen authentication gate.
///
/// If no user is signed in, it shows the Firebase UI `SignInScreen`
/// with Email and Google providers. The Google client ID is read from
/// the `.env` file (key `GOOGLE_CLIENT_ID`). When the user is
/// authenticated the app navigates to the home route.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while the auth state is being resolved.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          // Not signed in – display the sign‑in UI.
          return ui.SignInScreen(
            providers: [
              ui.EmailAuthProvider(),
              GoogleProvider(clientId: dotenv.maybeGet('GOOGLE_CLIENT_ID') ?? ''),
            ],
            // Additional UI customization can be added here.
          );
        }
        // User signed in – navigate to the home screen.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home-v2');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
