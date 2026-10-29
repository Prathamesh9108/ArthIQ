class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String currency;
  final bool biometricsEnabled;
  final double monthlyIncome;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.currency = '₹',
    this.biometricsEnabled = false,
    this.monthlyIncome = 20000.0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? currency,
    bool? biometricsEnabled,
    double? monthlyIncome,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'currency': currency,
      'biometricsEnabled': biometricsEnabled,
      'monthlyIncome': monthlyIncome,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      currency: json['currency'] as String? ?? '₹',
      biometricsEnabled: json['biometricsEnabled'] as bool? ?? false,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 20000.0,
    );
  }

  // Pre-populated default user from the design Rahul Sharma
  static const UserModel defaultUser = UserModel(
    id: 'user_rahul_01',
    name: 'Rahul Sharma',
    email: 'rahul@gmail.com',
    phone: '+91 98765 43210',
    avatarUrl: null,
    currency: '₹',
    biometricsEnabled: true,
    monthlyIncome: 20000.0,
  );
}
