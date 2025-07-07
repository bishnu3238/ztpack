// // src/data/models/user_model.dart
// import '../../domain/entities/user_entity.dart';
//
// enum UserMetadata { phoneNo, address, city, state, country, zipCode }
//
// class User implements UserEntity {
//   @override
//   final String id;
//
//   @override
//   final String name;
//
//   @override
//   final String email;
//
//   final String? profileImage;
//
//   final Map<String, dynamic>? metadata;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profileImage,
//     this.metadata,
//   });
//
//   User copyWith({
//     String? id,
//     String? name,
//     String? email,
//     String? profileImage,
//     Map<String, dynamic>? metadata,
//   }) => User(
//     id: id ?? this.id,
//     name: name ?? this.name,
//     email: email ?? this.email,
//     profileImage: profileImage ?? this.profileImage,
//     metadata: metadata ?? this.metadata,
//   );
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'] ?? '',
//       email: json['email'],
//       profileImage: json['profile_image'],
//       metadata: json['metadata'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'profile_image': profileImage,
//       'metadata': metadata,
//     };
//   }
// }
