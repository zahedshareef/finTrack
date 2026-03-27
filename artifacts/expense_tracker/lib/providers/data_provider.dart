import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart' as cat_model;
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/planned_payment.dart';
import '../models/gold_holding.dart';
import '../services/storage_service.dart';
import '../services/currency_service.dart';
import '../services/gold_service.dart';
import '../services/notification_service.dart';

class DataProvider extends ChangeNotifier {
  final StorageService _storage;
  final CurrencyService _currencyService = CurrencyService();
  final GoldService _goldService = GoldService();
  final _uuid = const Uuid();

  List<Account> _accounts = [];
  List<AppTransaction> _transactions = [];
  List<cat_model.Category> _categories = [];
  List<Debt> _debts = [];
  List<Budget> _budgets = [];
  List<Goal> _goals = [];
  List<PlannedPayment> _plannedPayments = [];
  List<GoldHolding> _goldHoldings = [];
  Map<String, double> _exchangeRates = {};
  double? _goldPriceUSD;
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  DataProvider(this._storage);

  List<Account> get accounts => _accounts;
  List<AppTransaction> get transactions => _transactions;
  List<cat_model.Category> get categories => _categories;

  cat_model.Category? getCategoryById(String id) {
    try { return _categories.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
  List<Debt> get debts => _debts;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;
  List<PlannedPayment> get plannedPayments => _plannedPayments;
  List<GoldHolding> get goldHoldings => _goldHoldings;
  Map<String, double> get exchangeRates => _exchangeRates;
  double? get goldPriceUSD => _goldPriceUSD;
  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;

  String get baseCurrency => _settings['baseCurrency'] ?? 'USD';

  Future<void> init() async {
    _accounts = _storage.getAccounts();
    _transactions = _storage.getTransactions();
    _categories = _storage.getCategories();
    _debts = _storage.getDebts();
    _budgets = _storage.getBudgets();
    _goals = _storage.getGoals();
    _plannedPayments = _storage.getPlannedPayments();
    _goldHoldings = _storage.getGoldHoldings();
    _settings = _storage.getSettings();
    _isLoading = false;
    notifyListeners();
    _fetchRatesAndGold();
  }

  Future<void> _fetchRatesAndGold() async {
    try {
      _exchangeRates = await _currencyService.getRates(baseCurrency);
      _goldPriceUSD = await _goldService.getGoldPriceUSD();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshRates() => _fetchRatesAndGold();

  // Convert amount to base currency
  double toBase(double amount, String fromCurrency) {
    if (fromCurrency == baseCurrency || _exchangeRates.isEmpty) return amount;
    final fromRate = _exchangeRates[fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[baseCurrency] ?? 1.0;
    return amount / fromRate * toRate;
  }

  double fromBase(double amount, String toCurrency) {
    if (toCurrency == baseCurrency || _exchangeRates.isEmpty) return amount;
    final fromRate = _exchangeRates[baseCurrency] ?? 1.0;
    final toRate = _exchangeRates[toCurrency] ?? 1.0;
    return amount / fromRate * toRate;
  }

  double get totalBalance {
    return _accounts
        .where((a) => a.includeInTotal)
        .fold(0.0, (sum, a) => sum + toBase(a.balance, a.currency));
  }

  // Settings
  Future<void> setBaseCurrency(String currency) async {
    _settings['baseCurrency'] = currency;
    await _storage.saveSettings(_settings);
    await _fetchRatesAndGold();
  }

  // Accounts CRUD
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await _storage.saveAccounts(_accounts);
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx != -1) {
      _accounts[idx] = account;
      await _storage.saveAccounts(_accounts);
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    _transactions.removeWhere((t) => t.accountId == id);
    await _storage.saveAccounts(_accounts);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Account? getAccount(String id) => _accounts.cast<Account?>().firstWhere((a) => a?.id == id, orElse: () => null);

  // Transactions CRUD
  Future<void> addTransaction(AppTransaction tx) async {
    _transactions.add(tx);
    final accIdx = _accounts.indexWhere((a) => a.id == tx.accountId);
    if (accIdx != -1) {
      _accounts[accIdx].balance += tx.isIncome ? tx.amount : -tx.amount;
      await _storage.saveAccounts(_accounts);
    }
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(AppTransaction tx) async {
    _transactions.removeWhere((t) => t.id == tx.id);
    final accIdx = _accounts.indexWhere((a) => a.id == tx.accountId);
    if (accIdx != -1) {
      _accounts[accIdx].balance -= tx.isIncome ? tx.amount : -tx.amount;
      await _storage.saveAccounts(_accounts);
    }
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(AppTransaction old, AppTransaction updated) async {
    // Reverse old effect on account
    final oldAccIdx = _accounts.indexWhere((a) => a.id == old.accountId);
    if (oldAccIdx != -1) {
      _accounts[oldAccIdx].balance -= old.isIncome ? old.amount : -old.amount;
    }
    // Apply new effect on account
    final newAccIdx = _accounts.indexWhere((a) => a.id == updated.accountId);
    if (newAccIdx != -1) {
      _accounts[newAccIdx].balance += updated.isIncome ? updated.amount : -updated.amount;
    }
    final idx = _transactions.indexWhere((t) => t.id == old.id);
    if (idx != -1) _transactions[idx] = updated;
    await _storage.saveAccounts(_accounts);
    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  List<AppTransaction> getTransactionsForAccount(String accountId) =>
      _transactions.where((t) => t.accountId == accountId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<AppTransaction> getFilteredTransactions({
    String? accountId,
    String? categoryId,
    DateTime? from,
    DateTime? to,
    bool? isIncome,
  }) {
    return _transactions.where((t) {
      if (accountId != null && t.accountId != accountId) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (from != null && t.date.isBefore(from)) return false;
      if (to != null && t.date.isAfter(to)) return false;
      if (isIncome != null && t.isIncome != isIncome) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> getExpensesByCategory({DateTime? from, DateTime? to}) {
    final txs = getFilteredTransactions(from: from, to: to, isIncome: false);
    final Map<String, double> result = {};
    for (final tx in txs) {
      result[tx.categoryId] = (result[tx.categoryId] ?? 0) + tx.amount;
    }
    return result;
  }

  List<MapEntry<String, double>> getMonthlyOutflow({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final month = DateTime(now.year, now.month - (months - 1 - i));
      final txs = _transactions.where((t) =>
          !t.isIncome && t.date.year == month.year && t.date.month == month.month);
      final total = txs.fold(0.0, (sum, t) => sum + t.amount);
      return MapEntry('${month.month}/${month.year}', total);
    });
  }

  double getSpendingThisMonth() {
    final now = DateTime.now();
    return _transactions
        .where((t) => !t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getSpendingLastMonth() {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1);
    return _transactions
        .where((t) => !t.isIncome && t.date.year == last.year && t.date.month == last.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<MapEntry<DateTime, double>> getDailyBalanceTrend({int days = 30}) {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    double runningBalance = _accounts
        .where((a) => a.includeInTotal)
        .fold(0.0, (sum, a) => sum + toBase(a.balance, a.currency));

    final result = <MapEntry<DateTime, double>>[];
    for (int i = 0; i < days; i++) {
      final day = now.subtract(Duration(days: i));
      result.add(MapEntry(day, runningBalance));
      final dayTxs = _transactions.where((t) =>
          t.date.year == day.year && t.date.month == day.month && t.date.day == day.day);
      for (final tx in dayTxs) {
        final acc = _accounts.cast<Account?>().firstWhere((a) => a?.id == tx.accountId, orElse: () => null);
        final txBase = toBase(tx.amount, acc?.currency ?? baseCurrency);
        runningBalance -= tx.isIncome ? txBase : -txBase;
      }
    }
    return result.reversed.toList();
  }

  double predictNextMonth() {
    final data = getMonthlyOutflow(months: 6);
    if (data.length < 2) return 0;
    final values = data.map((e) => e.value).toList();
    final n = values.length;
    final xMean = (n - 1) / 2;
    final yMean = values.reduce((a, b) => a + b) / n;
    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (i - xMean) * (values[i] - yMean);
      den += (i - xMean) * (i - xMean);
    }
    final slope = den != 0 ? num / den : 0;
    return (yMean + slope * (n - xMean)).clamp(0, double.infinity);
  }

  // Debts CRUD
  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    await _storage.saveDebts(_debts);
    notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    final idx = _debts.indexWhere((d) => d.id == debt.id);
    if (idx != -1) {
      _debts[idx] = debt;
      await _storage.saveDebts(_debts);
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
    await _storage.saveDebts(_debts);
    notifyListeners();
  }

  // Budgets CRUD
  Future<void> saveBudget(Budget budget) async {
    final idx = _budgets.indexWhere((b) => b.categoryId == budget.categoryId);
    if (idx != -1) {
      _budgets[idx] = budget;
    } else {
      _budgets.add(budget);
    }
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  double getSpentForBudget(Budget budget) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            !t.isIncome &&
            t.categoryId == budget.categoryId &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Goals CRUD
  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _goals[idx] = goal;
      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  // Planned Payments CRUD
  Future<void> addPlannedPayment(PlannedPayment payment) async {
    _plannedPayments.add(payment);
    await _storage.savePlannedPayments(_plannedPayments);
    notifyListeners();
    _schedulePaymentNotification(payment);
  }

  Future<void> updatePlannedPayment(PlannedPayment payment) async {
    final idx = _plannedPayments.indexWhere((p) => p.id == payment.id);
    if (idx != -1) {
      _plannedPayments[idx] = payment;
      await _storage.savePlannedPayments(_plannedPayments);
      notifyListeners();
      await NotificationService.cancelNotification(_notificationId(payment.id));
      if (!payment.isPaid) _schedulePaymentNotification(payment);
    }
  }

  Future<void> markPaymentAsPaid(String id) async {
    final idx = _plannedPayments.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _plannedPayments[idx];
      _plannedPayments[idx] = p.copyWith(isPaid: true);
      await NotificationService.cancelNotification(_notificationId(id));

      if (p.isRecurring) {
        final nextDue = _nextDueDate(p.dueDate, p.recurrencePeriod);
        final nextPayment = PlannedPayment(
          id: generateId(),
          name: p.name,
          amount: p.amount,
          currency: p.currency,
          accountId: p.accountId,
          categoryId: p.categoryId,
          dueDate: nextDue,
          isRecurring: true,
          recurrencePeriod: p.recurrencePeriod,
          isPaid: false,
          note: p.note,
          createdAt: DateTime.now(),
        );
        _plannedPayments.add(nextPayment);
        _schedulePaymentNotification(nextPayment);
      }

      await _storage.savePlannedPayments(_plannedPayments);
      notifyListeners();
    }
  }

  DateTime _nextDueDate(DateTime current, String period) {
    switch (period) {
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      case 'monthly':
      default:
        final nextMonth = current.month == 12 ? 1 : current.month + 1;
        final nextYear = current.month == 12 ? current.year + 1 : current.year;
        final lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        return DateTime(nextYear, nextMonth, current.day.clamp(1, lastDay));
    }
  }

  Future<void> deletePlannedPayment(String id) async {
    _plannedPayments.removeWhere((p) => p.id == id);
    await _storage.savePlannedPayments(_plannedPayments);
    notifyListeners();
    await NotificationService.cancelNotification(_notificationId(id));
  }

  int _notificationId(String paymentId) => paymentId.hashCode.abs() % 100000;

  void _schedulePaymentNotification(PlannedPayment payment) {
    if (payment.isPaid) return;
    NotificationService.schedulePaymentReminder(
      id: _notificationId(payment.id),
      name: payment.name,
      amount: payment.amount,
      dueDate: payment.dueDate,
    );
  }

  // Gold CRUD
  Future<void> addGoldHolding(GoldHolding holding) async {
    _goldHoldings.add(holding);
    await _storage.saveGoldHoldings(_goldHoldings);
    notifyListeners();
  }

  Future<void> deleteGoldHolding(String id) async {
    _goldHoldings.removeWhere((h) => h.id == id);
    await _storage.saveGoldHoldings(_goldHoldings);
    notifyListeners();
  }

  double get goldPricePerGramBase {
    if (_goldPriceUSD == null) return 0;
    if (baseCurrency == 'USD') return _goldPriceUSD!;
    return toBase(_goldPriceUSD!, 'USD');
  }

  String generateId() => _uuid.v4();
}
