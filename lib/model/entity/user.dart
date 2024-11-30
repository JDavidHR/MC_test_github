class User {
  final String id;
  final String name;
  final String email;
  bool sumitted;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.sumitted = false,
  });
}
