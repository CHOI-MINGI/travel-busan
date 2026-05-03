class GuiderRegisterRequest {
  final List<String> activeRegions;
  final List<String> availableLanguages;
  final String experiencePeriod;
  final List<LanguageScoreDto> languageScores;
  final String introduction;
  final List<String> specialties;

  GuiderRegisterRequest({
    required this.activeRegions,
    required this.availableLanguages,
    required this.experiencePeriod,
    required this.languageScores,
    required this.introduction,
    required this.specialties,
  });

  Map<String, dynamic> toJson() {
    return {
      'activeRegions': activeRegions,
      'availableLanguages': availableLanguages,
      'experiencePeriod': experiencePeriod,
      'languageScores': languageScores.map((e) => e.toJson()).toList(),
      'introduction': introduction,
      'specialties': specialties,
    };
  }
}

class LanguageScoreDto {
  String exam;   // final 제거 (UI에서 직접 수정 가능하도록)
  String score;  // final 제거

  LanguageScoreDto({required this.exam, required this.score});

  Map<String, dynamic> toJson() => {
        'exam': exam,
        'score': score,
      };

  factory LanguageScoreDto.fromJson(Map<String, dynamic> json) {
    return LanguageScoreDto(
      exam: json['exam'] ?? '',
      score: json['score'] ?? '',
    );
  }
}

class GuiderRegisterResponse {
  final String? guideId;
  final String message;

  GuiderRegisterResponse({this.guideId, required this.message});

  factory GuiderRegisterResponse.fromJson(Map<String, dynamic> json) {
    return GuiderRegisterResponse(
      guideId: json['guideId'],
      message: json['message'] ?? '',
    );
  }
}
