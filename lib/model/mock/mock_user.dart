import 'package:mc_test/model/entity/user.dart';

class MockUsers {
  static final List<User> users = [
    User(
      id: 'u1',
      name: 'A',
      email: 'a',
      sumitted: true,
    ),
    User(
      id: 'u2',
      name: 'Bob Johnson',
      email: 'bob.johnson@example.com',
    ),
  ];
}
