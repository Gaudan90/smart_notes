class PinSecurityModel {
  final String pinHash;
  final String securityQuestion;
  final String answerHash;
  final bool isSetupComplete;

  PinSecurityModel({
    required this.pinHash,
    required this.securityQuestion,
    required this.answerHash,
    required this.isSetupComplete,
  });

  Map<String, dynamic> toJson() {
    return {
      'pinHash': pinHash,
      'securityQuestion': securityQuestion,
      'answerHash': answerHash,
      'isSetupComplete': isSetupComplete,
    };
  }

  factory PinSecurityModel.fromJson(Map<String, dynamic> json) {
    return PinSecurityModel(
      pinHash: json['pinHash'] ?? '',
      securityQuestion: json['securityQuestion'] ?? '',
      answerHash: json['answerHash'] ?? '',
      isSetupComplete: json['isSetupComplete'] ?? false,
    );
  }
}