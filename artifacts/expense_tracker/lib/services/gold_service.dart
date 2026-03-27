import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldService {
  static double? _cachedPriceUSD;
  static DateTime? _cacheTime;

  Future<double?> getGoldPriceUSD() async {
    if (_cachedPriceUSD != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inMinutes < 30) {
      return _cachedPriceUSD;
    }
    final price = await _fetchFromMetals() ?? await _fetchFromExchangeRate();
    if (price != null) {
      _cachedPriceUSD = price;
      _cacheTime = DateTime.now();
    }
    return _cachedPriceUSD;
  }

  Future<double?> _fetchFromMetals() async {
    try {
      // gold-api.com: free, no key, returns price in USD per troy oz
      final response = await http
          .get(Uri.parse('https://api.gold-api.com/price/XAU'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['price'] != null) {
          final usdPerOz = (data['price'] as num).toDouble();
          return usdPerOz / 31.1035;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<double?> _fetchFromExchangeRate() async {
    try {
      // Fallback: use open.er-api rates to build USD/XAU from USD base rates
      // XAU is listed as a currency in some rate APIs relative to USD
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>;
          if (rates.containsKey('XAU')) {
            // rates['XAU'] = how many troy oz per 1 USD => 1/rates['XAU'] = USD per oz
            final usdPerOz = 1.0 / (rates['XAU'] as num).toDouble();
            return usdPerOz / 31.1035;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<double?> getGoldPriceInCurrency(String currency, Map<String, double> rates) async {
    final usdPrice = await getGoldPriceUSD();
    if (usdPrice == null) return null;
    if (currency == 'USD') return usdPrice;
    final rate = rates[currency] ?? 1.0;
    final usdRate = rates['USD'] ?? 1.0;
    return usdPrice * rate / usdRate;
  }
}
