class PasswordModel {
  final String password;
  final int length;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSymbols;
  final DateTime generatedAt;
  final String? name;

  PasswordModel({
    required this.password,
    required this.length,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumbers,
    required this.hasSymbols,
    required this.generatedAt,
    this.name,
  });

  int get strength {
    int score = 0;

    if (length >= 12) {
      score += 25;
    } else if (length >= 8) {
      score += 15;
    }
    else {
      score += 5;
    }
    if (hasUppercase) {
      score += 20;
    }
    if (hasLowercase) {
      score += 20;
    }
    if (hasNumbers) {
      score += 20;
    }
    if (hasSymbols) {
      score += 25;
    }

    int typesUsed = 0;
    if (hasUppercase) {
      typesUsed++;
    }
    if (hasLowercase) {
      typesUsed++;
    }
    if (hasNumbers) {
      typesUsed++;
    }
    if (hasSymbols) {
      typesUsed++;
    }
    if (typesUsed >= 3) {
      score += 10;
    }
    return score.clamp(0,100);
  }

  String get strengthLabel {
    if (strength >= 80) {
      return 'Molto forte';
    }
    if (strength >= 60) {
      return 'Forte';
    }
    if (strength >= 40) {
      return 'Media';
    }
    if (strength >= 20) {
      return 'Debole';
    }
    return 'Molto debole';
  }

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'length': length,
      'hasUppercase': hasUppercase,
      'hasLowercase': hasLowercase,
      'hasNumbers': hasNumbers,
      'hasSymbols': hasSymbols,
      'generatedAt': generatedAt.toIso8601String(),
      'name': name,
    };
  }

  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      password: json['password'],
      length: json['length'],
      hasUppercase: json['hasUppercase'],
      hasLowercase: json['hasLowercase'],
      hasNumbers: json['hasNumbers'],
      hasSymbols: json['hasSymbols'],
      generatedAt: DateTime.parse(json['generatedAt']),
      name: json['name'],
    );
  }
}