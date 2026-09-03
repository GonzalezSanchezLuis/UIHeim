class SurveyModel {
  final int? userId;
  final String transportNeed;
  final String registrationReason;
  final String barrierReason;

  SurveyModel({
    this.userId,
    required this.transportNeed,
    required this.registrationReason,
    required this.barrierReason,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'transportNeed': transportNeed,
      'registrationReason': registrationReason,
      'barrierReason': barrierReason,
    };
  }

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      userId: json['userId'],
      transportNeed: json['transportNeed'] ?? '',
      registrationReason: json['registrationReason'] ?? '',
      barrierReason: json['barrierReason'] ?? '',
    );
  }
}
