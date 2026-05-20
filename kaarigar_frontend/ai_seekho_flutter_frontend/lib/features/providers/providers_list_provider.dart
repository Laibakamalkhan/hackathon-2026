import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_service.dart';
import '../../main.dart';
import '../../models/provider_model.dart';
import '../../services/mock_data_service.dart';

final providersListProvider = FutureProvider<List<ServiceProvider>>((ref) async {
  final backendOnline = ref.watch(backendOnlineProvider);

  try {
    final response = await apiService.getProviders();
    final List<dynamic> rawList = response['providers'] ?? [];
    return rawList.map((json) => ServiceProvider.fromJson(json)).toList();
  } catch (e) {
    if (!backendOnline) {
      return MockDataService.providers;
    }
    throw Exception('Failed to load providers: $e');
  }
});
