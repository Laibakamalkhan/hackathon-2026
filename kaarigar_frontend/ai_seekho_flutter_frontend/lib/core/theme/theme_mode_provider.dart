import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Provides the current [ThemeMode] for the app.
///
/// The default is `ThemeMode.system` so the app follows the device
/// setting. You can toggle between `ThemeMode.light` and `ThemeMode.dark`
/// (e.g., via a switch widget) by writing to this provider.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
