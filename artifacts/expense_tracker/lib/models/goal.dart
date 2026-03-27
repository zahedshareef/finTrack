class Goal {
  final String id;
  String name;
  double targetAmount;
  double savedAmount;
  String currency;
  DateTime targetDate;
  String icon;
  DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.currency,
    required this.targetDate,
    required this.icon,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;
  bool get isComplete => savedAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'currency': currency,
        'targetDate': targetDate.toIso8601String(),
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] ?? 'USD',
        targetDate: DateTime.parse(json['targetDate']),
        icon: json['icon'] ?? '🎯',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
