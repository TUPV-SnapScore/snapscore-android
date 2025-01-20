// essay_models.dart
class EssayQuestion {
  final int questionNumber;
  final String questionText;

  EssayQuestion({
    required this.questionNumber,
    required this.questionText,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionNumber': questionNumber,
      'questionText': questionText,
    };
  }
}

class EssayCriteria {
  final int criteriaNumber;
  final String criteriaText;
  final double maxScore;

  EssayCriteria({
    required this.criteriaNumber,
    required this.criteriaText,
    required this.maxScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'criteriaNumber': criteriaNumber,
      'criteriaText': criteriaText,
      'maxScore': maxScore,
    };
  }
}

class EssayData {
  final String essayTitle;
  final List<EssayQuestion> questions;
  final List<EssayCriteria> criteria;
  final double totalScore;

  EssayData({
    required this.essayTitle,
    required this.questions,
    required this.criteria,
    required this.totalScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'essayTitle': essayTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
      'criteria': criteria.map((c) => c.toJson()).toList(),
      'totalScore': totalScore,
    };
  }
}
