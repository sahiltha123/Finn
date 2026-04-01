import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.currencyCode,
    required super.currencySymbol,
    required super.avatarColorHex,
    required super.onboardingComplete,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      uid: map['uid']! as String,
      name: map['name']! as String,
      email: map['email']! as String,
      currencyCode: map['currencyCode']! as String,
      currencySymbol: map['currencySymbol']! as String,
      avatarColorHex: map['avatarColorHex']! as String,
      onboardingComplete: map['onboardingComplete']! as bool,
      createdAt: DateTime.parse(map['createdAt']! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'avatarColorHex': avatarColorHex,
      'onboardingComplete': onboardingComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
