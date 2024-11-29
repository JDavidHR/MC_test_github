class Answer {
  final String id;
  final String label;
  bool isCorrect;

  Answer({
    required this.id,
    required this.label,
    this.isCorrect = false,
  });
}
