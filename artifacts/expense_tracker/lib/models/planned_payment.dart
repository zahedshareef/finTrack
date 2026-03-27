class PlannedPayment {
  final String id;
  String name;
  double amount;
  String currency;
  String accountId;
  String categoryId;
  DateTime dueDate;
  bool isRecurring;
  String recurrencePeriod;
  bool isPaid;
  String note;
  DateTime createdAt;

  PlannedPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.accountId,
    required this.categoryId,
    required this.dueDate,
    required this.isRecurring,
    required this.recurrencePeriod,
    required this.isPaid,
    required this.note,
    required this.createdAt,
  });

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
  bool get isDueSoon => !isPaid && dueDate.difference(DateTime.now()).inDays <= 3 && dueDate.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'currency': currency,
        'accountId': accountId,
        'categoryId': categoryId,
        'dueDate': dueDate.toIso8601String(),
        'isRecurring': isRecurring,
        'recurrencePeriod': recurrencePeriod,
        'isPaid': isPaid,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PlannedPayment.fromJson(Map<String, dynamic> json) => PlannedPayment(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] ?? 'USD',
        accountId: json['accountId'] ?? '',
        categoryId: json['categoryId'] ?? 'other',
        dueDate: DateTime.parse(json['dueDate']),
        isRecurring: json['isRecurring'] ?? false,
        recurrencePeriod: json['recurrencePeriod'] ?? 'monthly',
        isPaid: json['isPaid'] ?? false,
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
