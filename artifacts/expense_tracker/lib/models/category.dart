import 'package:flutter/material.dart';

class Category {
  final String id;
  String name;
  String icon;
  int colorValue;
  bool isIncome;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.isIncome,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
        'isIncome': isIncome,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        colorValue: json['colorValue'],
        isIncome: json['isIncome'] ?? false,
      );
}

final List<Category> defaultCategories = [
  Category(id: 'investments', name: 'Investments', icon: '📈', colorValue: 0xFFE91E63, isIncome: false),
  Category(id: 'housing', name: 'Housing', icon: '🏠', colorValue: 0xFFFF9800, isIncome: false),
  Category(id: 'entertainment', name: 'Life & Entertainment', icon: '🎭', colorValue: 0xFF4CAF50, isIncome: false),
  Category(id: 'food', name: 'Food', icon: '🍔', colorValue: 0xFFFF5722, isIncome: false),
  Category(id: 'vehicle', name: 'Vehicle', icon: '🚗', colorValue: 0xFF9C27B0, isIncome: false),
  Category(id: 'financial', name: 'Financial Expenses', icon: '💳', colorValue: 0xFF00BCD4, isIncome: false),
  Category(id: 'communication', name: 'Communication', icon: '📱', colorValue: 0xFF3F51B5, isIncome: false),
  Category(id: 'health', name: 'Health', icon: '❤️', colorValue: 0xFFF44336, isIncome: false),
  Category(id: 'shopping', name: 'Shopping', icon: '🛍️', colorValue: 0xFFFFEB3B, isIncome: false),
  Category(id: 'education', name: 'Education', icon: '📚', colorValue: 0xFF795548, isIncome: false),
  Category(id: 'travel', name: 'Travel', icon: '✈️', colorValue: 0xFF607D8B, isIncome: false),
  Category(id: 'salary', name: 'Salary', icon: '💰', colorValue: 0xFF4CAF50, isIncome: true),
  Category(id: 'freelance', name: 'Freelance', icon: '💼', colorValue: 0xFF2196F3, isIncome: true),
  Category(id: 'investment_return', name: 'Investment Return', icon: '📊', colorValue: 0xFF009688, isIncome: true),
  Category(id: 'other_income', name: 'Other Income', icon: '💵', colorValue: 0xFF8BC34A, isIncome: true),
  Category(id: 'other', name: 'Other', icon: '📦', colorValue: 0xFF9E9E9E, isIncome: false),
];
