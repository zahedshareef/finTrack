import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';
  static Map<String, double> _cachedRates = {};
  static String _cachedBase = '';
  static DateTime? _cacheTime;

  static const List<String> supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'KWD', 'AED', 'SAR', 'BHD', 'QAR', 'OMR',
    'JPY', 'CNY', 'INR', 'AUD', 'CAD', 'CHF', 'SEK', 'NOK', 'DKK',
    'SGD', 'HKD', 'NZD', 'MXN', 'BRL', 'TRY', 'RUB', 'EGP', 'PKR',
    'IDR', 'THB', 'MYR', 'PHP', 'ZAR', 'NGN', 'KES', 'GHS',
  ];

  Future<Map<String, double>> getRates(String base) async {
    if (_cachedBase == base &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 60) {
      return _cachedRates;
    }
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$base')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = (data['rates'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
        _cachedRates = rates;
        _cachedBase = base;
        _cacheTime = DateTime.now();
        return rates;
      }
    } catch (_) {}
    if (_cachedRates.isNotEmpty) return _cachedRates;
    return {base: 1.0};
  }

  Future<double> convert(double amount, String from, String to, Map<String, double> rates) async {
    if (from == to) return amount;
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return amount / fromRate * toRate;
  }
}
