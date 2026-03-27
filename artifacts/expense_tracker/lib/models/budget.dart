class Budget {
  final String id;
  String categoryId;
  double limit;
  String period;
  DateTime createdAt;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.period,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'limit': limit,
        'period': period,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'],
        categoryId: json['categoryId'],
        limit: (json['limit'] as num).toDouble(),
        period: json['period'] ?? 'monthly',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
