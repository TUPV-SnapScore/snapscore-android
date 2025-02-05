class EssayAssessment {
  final String id;
  final String name;
  final List<EssayQuestion> essayQuestions;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EssayAssessment({
    required this.id,
    required this.name,
    required this.essayQuestions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EssayAssessment.fromJson(Map<String, dynamic> json) {
    return EssayAssessment(
      id: json['id'],
      name: json['name'],
      essayQuestions: (json['essayQuestions'] as List)
          .map((q) => EssayQuestion.fromJson(q))
          .toList(),
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class EssayQuestion {
  final String id;
  final String question;
  final List<EssayCriteria> essayCriteria;
  final String assessmentId;

  EssayQuestion({
    required this.id,
    required this.question,
    required this.essayCriteria,
    required this.assessmentId,
  });

  factory EssayQuestion.fromJson(Map<String, dynamic> json) {
    return EssayQuestion(
      id: json['id'],
      question: json['question'],
      essayCriteria: (json['essayCriteria'] as List)
          .map((c) => EssayCriteria.fromJson(c))
          .toList(),
      assessmentId: json['assessmentId'],
    );
  }
}

class EssayCriteria {
  final String id;
  final String criteria;

  EssayCriteria({
    required this.id,
    required this.criteria,
  });

  factory EssayCriteria.fromJson(Map<String, dynamic> json) {
    return EssayCriteria(
      id: json['id'],
      criteria: json['criteria'],
    );
  }
}

class IdentificationAssessment {
  final String id;
  final String name;
  final List<IdentificationQuestion> identificationQuestions;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdentificationAssessment({
    required this.id,
    required this.name,
    required this.identificationQuestions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IdentificationAssessment.fromJson(Map<String, dynamic> json) {
    return IdentificationAssessment(
      id: json['id'],
      name: json['name'],
      identificationQuestions: (json['identificationQuestions'] as List)
          .map((q) => IdentificationQuestion.fromJson(q))
          .toList(),
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identificationQuestions': identificationQuestions,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class IdentificationQuestion {
  final String id;
  final String correctAnswer;
  final String assessmentId;

  IdentificationQuestion({
    required this.id,
    required this.correctAnswer,
    required this.assessmentId,
  });

  factory IdentificationQuestion.fromJson(Map<String, dynamic> json) {
    return IdentificationQuestion(
      id: json['id'],
      correctAnswer: json['correctAnswer'],
      assessmentId: json['assessmentId'],
    );
  }
}
