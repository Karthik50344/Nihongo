import 'package:equatable/equatable.dart';

/// User entity - Domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl, createdAt];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name)';
  }
}