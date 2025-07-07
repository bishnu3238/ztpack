// src/domain/entities/user_entity.dart
abstract class UserEntity {
  String get id;
  String get name;
  String get email;
  // Optional fields for flexibility
  String? get profileImage => null;
  Map<String, dynamic>? get metadata => null;

  Map<String, dynamic> toMap();
  T fromMap<T>(Map<String, dynamic> json);
}
