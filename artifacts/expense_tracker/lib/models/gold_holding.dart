class GoldHolding {
  final String id;
  double weightGrams;
  double buyPricePerGram;
  String currency;
  DateTime buyDate;
  String note;
  DateTime createdAt;

  GoldHolding({
    required this.id,
    required this.weightGrams,
    required this.buyPricePerGram,
    required this.currency,
    required this.buyDate,
    required this.note,
    required this.createdAt,
  });

  double get totalCost => weightGrams * buyPricePerGram;

  double profitLoss(double currentPricePerGram) =>
      (currentPricePerGram - buyPricePerGram) * weightGrams;

  double profitLossPercent(double currentPricePerGram) =>
      buyPricePerGram > 0 ? ((currentPricePerGram - buyPricePerGram) / buyPricePerGram) * 100 : 0;

  double currentValue(double currentPricePerGram) => weightGrams * currentPricePerGram;

  Map<String, dynamic> toJson() => {
        'id': id,
        'weightGrams': weightGrams,
        'buyPricePerGram': buyPricePerGram,
        'currency': currency,
        'buyDate': buyDate.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GoldHolding.fromJson(Map<String, dynamic> json) => GoldHolding(
        id: json['id'],
        weightGrams: (json['weightGrams'] as num).toDouble(),
        buyPricePerGram: (json['buyPricePerGram'] as num).toDouble(),
        currency: json['currency'] ?? 'USD',
        buyDate: DateTime.parse(json['buyDate']),
        note: json['note'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
