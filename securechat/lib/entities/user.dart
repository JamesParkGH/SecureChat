//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q
class UserModel {
  final String email;
  final bool isOutOfOffice;
  const UserModel({required this.email, required this.isOutOfOffice});

  UserModel.fromJson(Map<String, Object?> json)
      : this(
        email: json['email'] as String,
        isOutOfOffice: json['isOutOfOffice'] as bool
      );

  toJson() {
    return {
      "email": email,
      "isOutOfOffice": isOutOfOffice
    };
  }
}
