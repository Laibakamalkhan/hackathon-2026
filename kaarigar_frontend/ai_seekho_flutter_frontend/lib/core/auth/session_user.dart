import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../network/http_client.dart';

T _read<T>(dynamic ref, ProviderListenable<T> provider) {
  if (ref is WidgetRef) {
    return ref.read(provider);
  }
  if (ref is Ref) {
    return ref.read(provider);
  }
  throw ArgumentError('Expected WidgetRef or Ref');
}

/// Resolves the active user id for API calls: Firebase uid when signed in,
/// otherwise [HttpClient.demoUid], then hackathon fallback.
String resolveUserId(dynamic ref) {
  final auth = _read(ref, authServiceProvider);
  return auth.userId ?? HttpClient.demoUid ?? 'user_demo_001';
}
