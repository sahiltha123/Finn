import 'package:cloud_firestore/cloud_firestore.dart';

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
    super.fcmToken,
    super.monthlyIncome,
  });

  factory UserModel.fromMap(Map<String, Object?> map) {
    final createdAtValue = map['createdAt'];
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: (map['name'] ?? 'Finn User') as String,
      email: (map['email'] ?? '') as String,
      currencyCode: (map['currency'] ?? map['currencyCode'] ?? 'INR') as String,
      currencySymbol: (map['currencySymbol'] ?? 'Rs.') as String,
      avatarColorHex:
          (map['avatarColor'] ?? map['avatarColorHex'] ?? '0xFF1A73E8')
              as String,
      onboardingComplete: map['onboardingComplete'] as bool? ?? true,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : (createdAtValue != null
                ? DateTime.parse(createdAtValue as String)
                : DateTime.now()),
      fcmToken: map['fcmToken'] as String?,
      monthlyIncome: map['monthlyIncome'] != null
          ? (map['monthlyIncome'] as num).toDouble()
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'currency': currencyCode,
      'currencySymbol': currencySymbol,
      'avatarColor': avatarColorHex,
      'onboardingComplete': onboardingComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
      if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? currencyCode,
    String? currencySymbol,
    String? avatarColorHex,
    bool? onboardingComplete,
    DateTime? createdAt,
    String? fcmToken,
    double? monthlyIncome,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }
}
