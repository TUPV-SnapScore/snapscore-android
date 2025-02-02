class EssayQuestion {
  final int questionNumber;
  final String questionText;
  final String id;

  EssayQuestion({
    required this.questionNumber,
    required this.questionText,
    required this.id,
  });

  factory EssayQuestion.fromJson(Map<String, dynamic> json) {
    return EssayQuestion(
      questionNumber: json['questionNumber'] as int? ??
          (json['question_number'] as int?) ??
          1,
      questionText:
          json['questionText'] as String? ?? json['question'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionNumber': questionNumber,
      'questionText': questionText,
      'id': id,
    };
  }
}

class EssayCriteria {
  final int criteriaNumber;
  final String criteriaText;
  final double maxScore;
  final String id;

  EssayCriteria({
    required this.criteriaNumber,
    required this.criteriaText,
    required this.maxScore,
    required this.id,
  });

  factory EssayCriteria.fromJson(Map<String, dynamic> json) {
    return EssayCriteria(
      criteriaNumber: json['criteriaNumber'] as int? ??
          (json['criteria_number'] as int?) ??
          1,
      criteriaText:
          json['criteriaText'] as String? ?? json['criteria'] as String,
      maxScore: (json['maxScore'] as num).toDouble(),
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaNumber': criteriaNumber,
      'criteriaText': criteriaText,
      'maxScore': maxScore,
      'id': id,
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

  factory EssayData.fromJson(Map<String, dynamic> json) {
    // Check if this is form data or API response
    final isFormData = json.containsKey('questions');

    if (isFormData) {
      return EssayData(
        essayTitle: json['essayTitle'] as String,
        questions: (json['questions'] as List)
            .map((q) => EssayQuestion(
                  questionNumber: q['questionNumber'] as int,
                  questionText: q['questionText'] as String,
                  id: q['id'] as String,
                ))
            .toList(),
        criteria: (json['criteria'] as List)
            .map((c) => EssayCriteria(
                  criteriaNumber: c['criteriaNumber'] as int,
                  criteriaText: c['criteriaText'] as String,
                  maxScore: (c['maxScore'] as num).toDouble(),
                  id: c['id'] as String,
                ))
            .toList(),
        totalScore: (json['totalScore'] as num).toDouble(),
      );
    }

    // Handle API response format
    return EssayData(
      essayTitle: json['name'] as String? ?? json['essayTitle'] as String,
      questions: (json['essayQuestions'] as List?)
              ?.map((q) => EssayQuestion(
                    questionNumber: q['questionNumber'] as int? ??
                        ((json['essayQuestions'] as List).indexOf(q) + 1),
                    questionText: q['question'] as String,
                    id: q['id'] as String,
                  ))
              .toList() ??
          [],
      criteria: (json['essayQuestions'] != null &&
              (json['essayQuestions'] as List).isNotEmpty &&
              json['essayQuestions'][0]['essayCriteria'] != null)
          ? (json['essayQuestions'][0]['essayCriteria'] as List)
              .map((c) => EssayCriteria(
                    criteriaNumber: c['criteriaNumber'] as int? ??
                        ((json['essayQuestions'][0]['essayCriteria'] as List)
                                .indexOf(c) +
                            1),
                    criteriaText: c['criteria'] as String,
                    maxScore: (c['maxScore'] as num).toDouble(),
                    id: c['id'] as String,
                  ))
              .toList()
          : [],
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'essayTitle': essayTitle,
      'questions': questions
          .map((q) => {
                'questionNumber': q.questionNumber,
                'questionText': q.questionText,
                'id': q.id,
              })
          .toList(),
      'criteria': criteria
          .map((c) => {
                'criteriaNumber': c.criteriaNumber,
                'criteriaText': c.criteriaText,
                'maxScore': c.maxScore,
                'id': c.id,
              })
          .toList(),
      'totalScore': totalScore,
    };
  }
}
