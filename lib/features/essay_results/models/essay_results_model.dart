import 'package:snapscore_android/features/essays/models/essay_model.dart';

class EssayResult {
  final String id;
  final String studentName;
  final String assessmentId;
  final List<EssayQuestionResult> questionResults;
  final String paperImage;
  final DateTime createdAt;
  final int totalScore;

  EssayResult({
    required this.id,
    required this.studentName,
    required this.assessmentId,
    required this.questionResults,
    this.paperImage = 'notfound.jpg',
    DateTime? createdAt,
    int? totalScore,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.totalScore = totalScore ?? calculateTotalScore(questionResults);

  factory EssayResult.fromJson(Map<String, dynamic> json) {
    return EssayResult(
      id: json['id']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? 'Unknown Student',
      assessmentId: json['assessmentId']?.toString() ?? '',
      questionResults: (json['questionResults'] as List?)
              ?.map((e) => EssayQuestionResult.fromJson(e))
              .toList() ??
          [],
      paperImage: json['paperImage']?.toString() ?? 'notfound.jpg',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      totalScore: (json['score'] as num?)?.toInt(),
    );
  }

  static int calculateTotalScore(List<EssayQuestionResult> questionResults) {
    return questionResults.fold(
        0,
        (total, question) =>
            total +
            question.essayCriteriaResults
                .fold(0, (sum, criteria) => sum + criteria.score));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'assessmentId': assessmentId,
      'questionResults': questionResults.map((qr) => qr.toJson()).toList(),
      'score': totalScore,
      'paperImage': paperImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EssayQuestionResult {
  final String id;
  final String answer;
  final String questionId;
  final String resultId;
  final int score;
  final EssayQuestion question;
  final List<EssayCriteriaResult> essayCriteriaResults;
  final DateTime createdAt;

  EssayQuestionResult({
    required this.id,
    required this.answer,
    required this.questionId,
    required this.resultId,
    required this.score,
    required this.question,
    required this.essayCriteriaResults,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory EssayQuestionResult.fromJson(Map<String, dynamic> json) {
    return EssayQuestionResult(
      id: json['id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      resultId: json['resultId']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      question: EssayQuestion.fromJson(json['question'] ?? {}),
      essayCriteriaResults: (json['essayCriteriaResults'] as List?)
              ?.map((e) => EssayCriteriaResult.fromJson(e))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
      'questionId': questionId,
      'resultId': resultId,
      'score': score,
      'question': question.toJson(),
      'essayCriteriaResults':
          essayCriteriaResults.map((cr) => cr.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EssayCriteriaResult {
  final String id;
  final int score;
  final String criteriaId;
  final String questionResultId;
  final EssayCriteria criteria;
  final DateTime createdAt;

  EssayCriteriaResult({
    required this.id,
    required this.score,
    required this.criteriaId,
    required this.questionResultId,
    required this.criteria,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory EssayCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EssayCriteriaResult(
      id: json['id']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      criteriaId: json['criteriaId']?.toString() ?? '',
      questionResultId: json['questionResultId']?.toString() ?? '',
      criteria: EssayCriteria.fromJson(json['criteria'] ?? {}),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'criteriaId': criteriaId,
      'questionResultId': questionResultId,
      'criteria': criteria.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
