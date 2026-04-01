class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.currencyCode,
    required this.currencySymbol,
    required this.avatarColorHex,
    required this.onboardingComplete,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String currencyCode;
  final String currencySymbol;
  final String avatarColorHex;
  final bool onboardingComplete;
  final DateTime createdAt;
}
