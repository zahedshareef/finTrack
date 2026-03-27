import 'package:flutter/material.dart';

class Account {
  final String id;
  String name;
  double balance;
  String currency;
  int colorValue;
  String type;
  bool includeInTotal;
  DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.colorValue,
    required this.type,
    this.includeInTotal = true,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'currency': currency,
        'colorValue': colorValue,
        'type': type,
        'includeInTotal': includeInTotal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        name: json['name'],
        balance: (json['balance'] as num).toDouble(),
        currency: json['currency'],
        colorValue: json['colorValue'],
        type: json['type'],
        includeInTotal: json['includeInTotal'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Account copyWith({
    String? name,
    double? balance,
    String? currency,
    int? colorValue,
    String? type,
    bool? includeInTotal,
  }) =>
      Account(
        id: id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        colorValue: colorValue ?? this.colorValue,
        type: type ?? this.type,
        includeInTotal: includeInTotal ?? this.includeInTotal,
        createdAt: createdAt,
      );
}

const List<String> accountTypes = [
  'Cash',
  'Checking',
  'Savings',
  'Credit Card',
  'Investment',
  'Loan',
  'Other',
];
