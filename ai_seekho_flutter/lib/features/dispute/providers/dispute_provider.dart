import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../models/dispute_model.dart';

class DisputeState {
  final bool isLoading;
  final String? error;
  final DisputeModel? resolvedDispute;

  DisputeState({this.isLoading = false, this.error, this.resolvedDispute});

  DisputeState copyWith({
    bool? isLoading,
    String? error,
    DisputeModel? resolvedDispute,
  }) {
    return DisputeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      resolvedDispute: resolvedDispute ?? this.resolvedDispute,
    );
  }
}

class DisputeNotifier extends Notifier<DisputeState> {
  @override
  DisputeState build() {
    return DisputeState();
  }

  Future<bool> fileEmpatheticDispute({
    required String bookingId,
    required String disputeType,
    required String description,
  }) async {
    final repository = ref.read(disputeRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resolved = await repository.fileDispute(
        bookingId: bookingId,
        disputeType: disputeType,
        description: description,
      );
      state = state.copyWith(isLoading: false, resolvedDispute: resolved);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearDisputeState() {
    state = DisputeState();
  }
}

final disputeStateProvider = NotifierProvider<DisputeNotifier, DisputeState>(
  () {
    return DisputeNotifier();
  },
);
