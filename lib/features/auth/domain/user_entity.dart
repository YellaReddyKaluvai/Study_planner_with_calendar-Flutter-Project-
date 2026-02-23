class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserEntity.empty() {
    return const UserEntity(uid: '', email: '');
  }

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
