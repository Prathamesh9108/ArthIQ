class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final String period; // 'monthly', 'weekly', etc.

  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    this.period = 'monthly',
  });

  double get remaining => limit - spent > 0 ? limit - spent : 0.0;
  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  bool get isExceeded => spent > limit;
  bool get isWarning => percentage >= 0.85;

  BudgetModel copyWith({
    String? id,
    String? category,
    double? limit,
    double? spent,
    String? period,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'spent': spent,
      'period': period,
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      category: json['category'] as String? ?? 'Uncategorized',
      limit: (json['limit'] is num)
          ? (json['limit'] as num).toDouble()
          : (double.tryParse(json['limit']?.toString() ?? '') ?? 0.0),
      spent: (json['spent'] is num)
          ? (json['spent'] as num).toDouble()
          : (double.tryParse(json['spent']?.toString() ?? '') ?? 0.0),
      period: json['period'] as String? ?? 'monthly',
    );
  }
}
