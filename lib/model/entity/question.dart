import 'package:mc_test/model/entity/answer.dart';

class Question {
  final String id;
  final String label;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.label,
    required this.answers,
  });
}
