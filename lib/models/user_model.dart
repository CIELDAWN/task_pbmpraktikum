class UserModel {
  final int id;
  final String name;
  final String username;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['data']['user']['id'],
      name: json['data']['user']['name'],
      username: json['data']['user']['username'],
      token: json['data']['token'],
    );
  }
}