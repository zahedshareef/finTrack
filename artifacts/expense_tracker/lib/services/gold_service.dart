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
    try {
      final response = await http
          .get(Uri.parse('https://api.frankfurter.app/latest?from=XAU&to=USD'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final usdPerOz = (data['rates']['USD'] as num).toDouble();
        final usdPerGram = usdPerOz / 31.1035;
        _cachedPriceUSD = usdPerGram;
        _cacheTime = DateTime.now();
        return _cachedPriceUSD;
      }
    } catch (_) {}
    return _cachedPriceUSD;
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
