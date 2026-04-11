import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoldPriceService {
  final String apiKey = 'goldapi-1wwsrsmhk1a21u-io';

  // 1 troy ounce = 31.1035 grams
  static const double GRAMS_PER_TROY_OUNCE = 31.1035;

  /// Fetches gold price per troy ounce and converts to INR (per gram and per kg)
  /// Stores the values in SharedPreferences
  Future<Map<String, dynamic>?> fetchAndStoreGoldPrice() async {
    final url = Uri.parse('https://www.goldapi.io/api/XAU/INR');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-access-token': apiKey,
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Extract price per troy ounce (1 oz)
        final double pricePerOz = (data['price'] ?? 0).toDouble();
        
        // Convert to per gram
        final double pricePerGram = pricePerOz / GRAMS_PER_TROY_OUNCE;
        
        // Convert to per kg
        final double pricePerKg = pricePerGram * 1000;

        // Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('gold_price_per_gram', pricePerGram);
        await prefs.setDouble('gold_price_per_kg', pricePerKg);
        await prefs.setString('gold_price_updated_at', DateTime.now().toString());

        print('✅ Gold price fetched and stored');
        print('   Per Gram: ₹${pricePerGram.toStringAsFixed(2)}');
        print('   Per KG: ₹${pricePerKg.toStringAsFixed(2)}');

        return {
          'price_per_gram': pricePerGram,
          'price_per_kg': pricePerKg,
          'updated_at': DateTime.now().toString(),
        };
      } else {
        print('❌ API Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Network error: $e');
      return null;
    }
  }

  /// Retrieves stored gold price per gram from SharedPreferences
  /// Returns cached value if available, otherwise fetches fresh
  Future<double> getGoldPricePerGram({bool forceFresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!forceFresh) {
      final cached = prefs.getDouble('gold_price_per_gram');
      if (cached != null) {
        print('📦 Using cached gold price per gram: ₹${cached.toStringAsFixed(2)}');
        return cached;
      }
    }

    // Fetch fresh if not cached or forceFresh is true
    final result = await fetchAndStoreGoldPrice();
    return result?['price_per_gram'] ?? 0.0;
  }

  /// Retrieves stored gold price per kg from SharedPreferences
  /// Returns cached value if available, otherwise fetches fresh
  Future<double> getGoldPricePerKg({bool forceFresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!forceFresh) {
      final cached = prefs.getDouble('gold_price_per_kg');
      if (cached != null) {
        print('📦 Using cached gold price per kg: ₹${cached.toStringAsFixed(2)}');
        return cached;
      }
    }

    // Fetch fresh if not cached or forceFresh is true
    final result = await fetchAndStoreGoldPrice();
    return result?['price_per_kg'] ?? 0.0;
  }

  /// Clear cached gold prices
  Future<void> clearCachedPrice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gold_price_per_gram');
    await prefs.remove('gold_price_per_kg');
    await prefs.remove('gold_price_updated_at');
    print('🗑️ Cleared cached gold prices');
  }
}
