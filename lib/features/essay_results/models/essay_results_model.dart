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
    // Handle the case where id might be null
    final String id = json['id']?.toString() ?? '';

    return EssayResult(
      id: id,
      studentName: json['studentName']?.toString() ?? 'Unknown Student',
      assessmentId: json['assessmentId']?.toString() ?? '',
      questionResults: (json['questionResults'] as List?)
              ?.map((e) => EssayQuestionResult.fromJson(e))
              .toList() ??
          [],
      paperImage: json['paperImage']?.toString() ?? 'notfound.jpg',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      totalScore: json['score'] != null ? (json['score'] as num).toInt() : null,
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
  final EssayQuestion? question; // Made nullable since it might be missing
  final List<EssayCriteriaResult> essayCriteriaResults;
  final DateTime createdAt;

  EssayQuestionResult({
    required this.id,
    required this.answer,
    required this.questionId,
    required this.resultId,
    required this.score,
    this.question, // Made optional
    required this.essayCriteriaResults,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory EssayQuestionResult.fromJson(Map<String, dynamic> json) {
    return EssayQuestionResult(
      id: json['id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      resultId: json['resultId']?.toString() ?? '',
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      question: json['question'] != null
          ? EssayQuestion.fromJson(json['question'])
          : null,
      essayCriteriaResults: (json['essayCriteriaResults'] as List?)
              ?.map((e) => EssayCriteriaResult.fromJson(e))
              .toList() ??
          (json['criteriaResults'] as List?) // Handle alternative field name
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
      'question': question?.toJson(),
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
  final EssayCriteria? criteria; // Made nullable
  final DateTime createdAt;
  final String? justification; // Added this field

  EssayCriteriaResult({
    required this.id,
    required this.score,
    required this.criteriaId,
    required this.questionResultId,
    this.criteria, // Made optional
    this.justification, // Added optional justification
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory EssayCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EssayCriteriaResult(
      id: json['id']?.toString() ?? '',
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      criteriaId: json['criteriaId']?.toString() ?? '',
      questionResultId: json['questionResultId']?.toString() ?? '',
      criteria: json['criteria'] != null
          ? EssayCriteria.fromJson(json['criteria'])
          : null,
      justification: json['justification']?.toString(),
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
      'criteria': criteria?.toJson(),
      'justification': justification,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
