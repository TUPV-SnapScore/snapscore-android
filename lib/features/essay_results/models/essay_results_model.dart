import 'package:snapscore_android/features/essays/models/essay_model.dart';

class EssayResult {
  final String id;
  final String studentName;
  final String assessmentId;
  final List<EssayQuestionResult> questionResults;
  final double totalScore;

  EssayResult({
    required this.id,
    required this.studentName,
    required this.assessmentId,
    required this.questionResults,
    required this.totalScore,
  });

  factory EssayResult.fromJson(Map<String, dynamic> json) {
    return EssayResult(
      id: json['id']?.toString() ?? '', // Convert to string and provide default
      studentName: json['studentName']?.toString() ?? 'Unknown Student',
      assessmentId: json['assessmentId']?.toString() ?? '',
      questionResults: (json['questionResults'] as List?)
              ?.map((e) => EssayQuestionResult.fromJson(e))
              .toList() ??
          [],
      totalScore: calculateTotalScore(json['questionResults'] ?? []),
    );
  }

  static double calculateTotalScore(List<dynamic> questionResults) {
    double total = 0;
    for (var questionResult in questionResults) {
      final criteriaResults = questionResult['essayCriteriaResults'] as List?;
      if (criteriaResults != null) {
        for (var criteriaResult in criteriaResults) {
          total += (criteriaResult['score'] as num?)?.toDouble() ?? 0.0;
        }
      }
    }
    return total;
  }
}

class EssayQuestionResult {
  final String id;
  final String answer;
  final String questionId;
  final String resultId;
  final EssayQuestion question;
  final List<EssayCriteriaResult> essayCriteriaResults;

  EssayQuestionResult({
    required this.id,
    required this.answer,
    required this.questionId,
    required this.resultId,
    required this.question,
    required this.essayCriteriaResults,
  });

  factory EssayQuestionResult.fromJson(Map<String, dynamic> json) {
    return EssayQuestionResult(
      id: json['id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      resultId: json['resultId']?.toString() ?? '',
      question: EssayQuestion.fromJson(json['question'] ?? {}),
      essayCriteriaResults: (json['essayCriteriaResults'] as List?)
              ?.map((e) => EssayCriteriaResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EssayCriteriaResult {
  final String id;
  final double score;
  final String criteriaId;
  final String questionResultId;
  final EssayCriteria criteria;

  EssayCriteriaResult({
    required this.id,
    required this.score,
    required this.criteriaId,
    required this.questionResultId,
    required this.criteria,
  });

  factory EssayCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EssayCriteriaResult(
      id: json['id']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      criteriaId: json['criteriaId']?.toString() ?? '',
      questionResultId: json['questionResultId']?.toString() ?? '',
      criteria: EssayCriteria.fromJson(json['criteria'] ?? {}),
    );
  }
}
