// class UserModel {
//
//   final int? id;
//   final String email;
//   final String password;
//
//   UserModel({
//     this.id,
//     required this.email,
//     required this.password
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       "id": id,
//       "email": email,
//       "password": password,
//     };
//   }
//
//   factory UserModel.fromMap(Map<String, dynamic> map) {
//     return UserModel(
//       id: map['id'],
//       email: map['email'],
//       password: map['password'],
//     );
//   }
// }


class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
}