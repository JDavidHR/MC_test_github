import 'package:mc_test/model/entity/question.dart';
import 'package:mc_test/model/entity/answer.dart';

class MockQuestions {
  static final List<Question> questions = [
    Question(
      id: 'q1',
      label: 'What is the capital of France?',
      answers: [
        Answer(id: 'a1', label: 'Berlin'),
        Answer(id: 'a2', label: 'Paris', isCorrect: true),
        Answer(id: 'a3', label: 'Madrid'),
      ],
    ),
    Question(
      id: 'q2',
      label: 'Which planet is known as the Red Planet?',
      answers: [
        Answer(id: 'a1', label: 'Earth'),
        Answer(id: 'a2', label: 'Mars', isCorrect: true),
        Answer(id: 'a3', label: 'Jupiter'),
      ],
    ),
    Question(
      id: 'q3',
      label: 'What is the largest mammal?',
      answers: [
        Answer(id: 'a1', label: 'Elephant'),
        Answer(id: 'a2', label: 'Blue Whale', isCorrect: true),
        Answer(id: 'a3', label: 'Giraffe'),
      ],
    ),
  ];
}
