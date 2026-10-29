enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String? receiptPath;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.receiptPath,
    this.note,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? receiptPath,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptPath: receiptPath ?? this.receiptPath,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'receiptPath': receiptPath,
      'note': note,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title'] as String? ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: json['category'] as String? ?? 'Other',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
      receiptPath: json['receiptPath'] as String?,
      note: json['note'] as String?,
    );
  }
}
