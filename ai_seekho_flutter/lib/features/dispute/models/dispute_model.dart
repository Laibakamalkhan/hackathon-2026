class DisputeResolutionModel {
  final String type;
  final int amountPkr;
  final String reasoning;
  final String urduReasoning;
  final String empatheticResponse;

  DisputeResolutionModel({
    required this.type,
    required this.amountPkr,
    required this.reasoning,
    required this.urduReasoning,
    required this.empatheticResponse,
  });

  factory DisputeResolutionModel.fromJson(Map<String, dynamic> json) {
    return DisputeResolutionModel(
      type: json['type'] ?? '',
      amountPkr: json['amount_pkr'] ?? 0,
      reasoning: json['reasoning'] ?? '',
      urduReasoning: json['urdu_reasoning'] ?? json['reasoning_urdu'] ?? '',
      empatheticResponse:
          json['empathetic_response'] ?? json['urdu_email'] ?? '',
    );
  }
}

class DisputeModel {
  final String disputeId;
  final String bookingId;
  final String type;
  final String description;
  final String status;
  final DisputeResolutionModel? resolution;

  DisputeModel({
    required this.disputeId,
    required this.bookingId,
    required this.type,
    required this.description,
    required this.status,
    this.resolution,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    final res = json['resolution'];
    return DisputeModel(
      disputeId: json['dispute_id'] ?? json['did'] ?? '',
      bookingId: json['booking_id'] ?? json['bid'] ?? '',
      type: json['type'] ?? json['dispute_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      resolution: res != null ? DisputeResolutionModel.fromJson(res) : null,
    );
  }
}
