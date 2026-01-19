import 'package:flutter/material.dart';
import 'models.dart';
import 'question_text.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  int selectedAnswerIndex = -1;

  final List<Question> questions = [
    Question(
      question: 'Quelle entreprise développe Flutter ?',
      answers: [
        Answer(text: 'Google', isCorrect: true),
        Answer(text: 'Apple', isCorrect: false),
        Answer(text: 'Microsoft', isCorrect: false),
      ],
    ),
    Question(
      question: 'Quel langage est utilisé avec Flutter ?',
      answers: [
        Answer(text: 'Kotlin', isCorrect: false),
        Answer(text: 'Dart', isCorrect: true),
        Answer(text: 'Swift', isCorrect: false),
      ],
    ),
  ];

  void answerQuestion(bool isCorrect) {
    setState(() {
      if (isCorrect) score++;
      currentQuestion++;
    });
  }

  void selectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion >= questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Score final : $score / ${questions.length}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentQuestion = 0;
                    score = 0;
                  });
                },
                child: const Text('Rejouer'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Flutter - Question ${currentQuestion + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            QuestionText(questionText: question.question),
            const SizedBox(height: 20),
            // On génère les boutons de réponse directement ici
            ...question.answers.map((answer) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () {
                    selectAnswer(question.answers.indexOf(answer));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedAnswerIndex == question.answers.indexOf(answer)
                        ? Colors.blueAccent.shade100
                        : null,
                  ),
                  child: Text(answer.text),
                ),
              );
            }),
            Spacer(),
            ElevatedButton(
              onPressed: selectedAnswerIndex == -1 ? null : () {
                answerQuestion(
                    question.answers[selectedAnswerIndex].isCorrect);
                selectedAnswerIndex = -1;
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
