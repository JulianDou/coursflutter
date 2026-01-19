class Answer {
  final String text;
  final bool isCorrect;

  Answer({required this.text, required this.isCorrect});
}

class Question {
  final String question;
  final List<Answer> answers;

  Question({required this.question, required this.answers});
}
