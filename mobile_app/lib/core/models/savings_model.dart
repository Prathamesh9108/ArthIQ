class SavingsGoalModel {
  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final String iconType; // 'emergency', 'dream', 'gadget', etc.
  final DateTime? targetDate;

  const SavingsGoalModel({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    this.iconType = 'goal',
    this.targetDate,
  });

  double get percentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;

  SavingsGoalModel copyWith({
    String? id,
    String? title,
    double? currentAmount,
    double? targetAmount,
    String? iconType,
    DateTime? targetDate,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      iconType: iconType ?? this.iconType,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'iconType': iconType,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title'] as String? ?? 'Savings Goal',
      currentAmount: (json['currentAmount'] is num)
          ? (json['currentAmount'] as num).toDouble()
          : (double.tryParse(json['currentAmount']?.toString() ?? '') ?? 0.0),
      targetAmount: (json['targetAmount'] is num)
          ? (json['targetAmount'] as num).toDouble()
          : (double.tryParse(json['targetAmount']?.toString() ?? '') ?? 0.0),
      iconType: json['iconType'] as String? ?? 'goal',
      targetDate: json['targetDate'] != null ? DateTime.tryParse(json['targetDate'].toString()) : null,
    );
  }
}

class SavingsGuardConfig {
  final bool autoSaveEnabled;
  final double weeklyAutoSaveAmount;
  final String linkedAccount;

  const SavingsGuardConfig({
    this.autoSaveEnabled = true,
    this.weeklyAutoSaveAmount = 500.0,
    this.linkedAccount = 'HDFC Bank (Primary)',
  });

  SavingsGuardConfig copyWith({
    bool? autoSaveEnabled,
    double? weeklyAutoSaveAmount,
    String? linkedAccount,
  }) {
    return SavingsGuardConfig(
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      weeklyAutoSaveAmount: weeklyAutoSaveAmount ?? this.weeklyAutoSaveAmount,
      linkedAccount: linkedAccount ?? this.linkedAccount,
    );
  }
}
