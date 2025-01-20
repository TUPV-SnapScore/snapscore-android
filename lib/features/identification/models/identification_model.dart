// identification_models.dart
class IdentificationAnswer {
  final int number;
  final String answer;

  IdentificationAnswer({
    required this.number,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'answer': answer,
    };
  }
}

class IdentificationData {
  final String assessmentName;
  final int numberOfQuestions;
  final List<IdentificationAnswer> answers;

  IdentificationData({
    required this.assessmentName,
    required this.numberOfQuestions,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'assessmentName': assessmentName,
      'numberOfQuestions': numberOfQuestions,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}
