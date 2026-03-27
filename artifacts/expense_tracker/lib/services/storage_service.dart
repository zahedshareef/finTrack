import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/planned_payment.dart';
import '../models/gold_holding.dart';

class StorageService {
  static const String _accountsKey = 'accounts';
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';
  static const String _debtsKey = 'debts';
  static const String _budgetsKey = 'budgets';
  static const String _goalsKey = 'goals';
  static const String _paymentsKey = 'planned_payments';
  static const String _goldKey = 'gold_holdings';
  static const String _settingsKey = 'settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Settings
  Map<String, dynamic> getSettings() {
    final data = _prefs.getString(_settingsKey);
    if (data == null) return {'baseCurrency': 'USD', 'goldCurrency': 'USD'};
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  // Accounts
  List<Account> getAccounts() {
    final data = _prefs.getString(_accountsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    await _prefs.setString(_accountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  // Transactions
  List<AppTransaction> getTransactions() {
    final data = _prefs.getString(_transactionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => AppTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTransactions(List<AppTransaction> transactions) async {
    await _prefs.setString(_transactionsKey, jsonEncode(transactions.map((t) => t.toJson()).toList()));
  }

  // Categories
  List<Category> getCategories() {
    final data = _prefs.getString(_categoriesKey);
    if (data == null) return defaultCategories;
    final list = jsonDecode(data) as List;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    await _prefs.setString(_categoriesKey, jsonEncode(categories.map((c) => c.toJson()).toList()));
  }

  // Debts
  List<Debt> getDebts() {
    final data = _prefs.getString(_debtsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Debt.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveDebts(List<Debt> debts) async {
    await _prefs.setString(_debtsKey, jsonEncode(debts.map((d) => d.toJson()).toList()));
  }

  // Budgets
  List<Budget> getBudgets() {
    final data = _prefs.getString(_budgetsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBudgets(List<Budget> budgets) async {
    await _prefs.setString(_budgetsKey, jsonEncode(budgets.map((b) => b.toJson()).toList()));
  }

  // Goals
  List<Goal> getGoals() {
    final data = _prefs.getString(_goalsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    await _prefs.setString(_goalsKey, jsonEncode(goals.map((g) => g.toJson()).toList()));
  }

  // Planned Payments
  List<PlannedPayment> getPlannedPayments() {
    final data = _prefs.getString(_paymentsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => PlannedPayment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> savePlannedPayments(List<PlannedPayment> payments) async {
    await _prefs.setString(_paymentsKey, jsonEncode(payments.map((p) => p.toJson()).toList()));
  }

  // Gold Holdings
  List<GoldHolding> getGoldHoldings() {
    final data = _prefs.getString(_goldKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => GoldHolding.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveGoldHoldings(List<GoldHolding> holdings) async {
    await _prefs.setString(_goldKey, jsonEncode(holdings.map((h) => h.toJson()).toList()));
  }
}
