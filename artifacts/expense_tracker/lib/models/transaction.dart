class AppTransaction {
  final String id;
  String accountId;
  String categoryId;
  double amount;
  bool isIncome;
  String note;
  DateTime date;
  DateTime createdAt;

  AppTransaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.isIncome,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'isIncome': isIncome,
        'note': note,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppTransaction.fromJson(Map<String, dynamic> json) => AppTransaction(
        id: json['id'],
        accountId: json['accountId'],
        categoryId: json['categoryId'],
        amount: (json['amount'] as num).toDouble(),
        isIncome: json['isIncome'] ?? false,
        note: json['note'] ?? '',
        date: DateTime.parse(json['date']),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
