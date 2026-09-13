class YawUser {
  const YawUser({required this.id, required this.name, required this.email});

  factory YawUser.fromJson(Map<String, Object?> json) {
    return YawUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'YAW user',
      email: json['email'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String email;
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final YawUser user;
}
