class Debt {
  final String id;
  String contactName;
  double amount;
  double paidAmount;
  String currency;
  String note;
  DateTime dueDate;
  bool iOwe;
  String status;
  DateTime createdAt;

  Debt({
    required this.id,
    required this.contactName,
    required this.amount,
    required this.paidAmount,
    required this.currency,
    required this.note,
    required this.dueDate,
    required this.iOwe,
    required this.status,
    required this.createdAt,
  });

  double get remaining => amount - paidAmount;
  bool get isSettled => status == 'settled';

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactName': contactName,
        'amount': amount,
        'paidAmount': paidAmount,
        'currency': currency,
        'note': note,
        'dueDate': dueDate.toIso8601String(),
        'iOwe': iOwe,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'],
        contactName: json['contactName'],
        amount: (json['amount'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] ?? 'USD',
        note: json['note'] ?? '',
        dueDate: DateTime.parse(json['dueDate']),
        iOwe: json['iOwe'] ?? true,
        status: json['status'] ?? 'pending',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
