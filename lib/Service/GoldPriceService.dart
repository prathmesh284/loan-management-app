import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoldPriceService {
  final String apiKey = 'goldapi-1wwsrsmhk1a21u-io';

  // 1 troy ounce = 31.1035 grams
  static const double GRAMS_PER_TROY_OUNCE = 31.1035;
  
  // Cache expiry in hours
  static const int CACHE_EXPIRY_HOURS = 12;

  /// Check if cached gold price is still valid (within 12 hours)
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedAtStr = prefs.getString('gold_price_updated_at');
      
      if (updatedAtStr == null) {
        debugPrint('📍 [GOLD-CACHE] No cache found');
        return false;
      }

      final DateTime updatedAt = DateTime.parse(updatedAtStr);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(updatedAt);
      final int hoursElapsed = difference.inHours;

      if (hoursElapsed < CACHE_EXPIRY_HOURS) {
        debugPrint('✅ [GOLD-CACHE] Cache valid - ${CACHE_EXPIRY_HOURS - hoursElapsed} hours remaining');
        return true;
      } else {
        debugPrint('⏰ [GOLD-CACHE] Cache expired - ${hoursElapsed}h elapsed (max: ${CACHE_EXPIRY_HOURS}h)');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [GOLD-CACHE] Cache validation error: $e');
      return false;
    }
  }

  /// Get cached gold price data
  Future<Map<String, dynamic>?> _getCachedPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pricePerGram = prefs.getDouble('gold_price_per_gram');
      final pricePerKg = prefs.getDouble('gold_price_per_kg');
      final updatedAt = prefs.getString('gold_price_updated_at');

      if (pricePerGram != null && pricePerKg != null && updatedAt != null) {
        debugPrint('💾 [GOLD-CACHE] Retrieved from cache - Per Gram: ₹${pricePerGram.toStringAsFixed(2)}, Per KG: ₹${pricePerKg.toStringAsFixed(2)}');
        return {
          'price_per_gram': pricePerGram,
          'price_per_kg': pricePerKg,
          'updated_at': updatedAt,
          'from_cache': true,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ [GOLD-CACHE] Error retrieving cache: $e');
      return null;
    }
  }
  /// Fetches gold price per troy ounce and converts to INR (per gram and per kg)
  /// Checks cache first (12-hour validity), then fetches fresh if expired
  /// Stores the values in SharedPreferences
  Future<Map<String, dynamic>?> fetchAndStoreGoldPrice() async {
    debugPrint('🔄 [GOLD-FETCH] Starting gold price fetch...');
    
    // Check if cache is still valid
    final isCacheValid = await _isCacheValid();
    if (isCacheValid) {
      final cachedData = await _getCachedPrice();
      if (cachedData != null) {
        return cachedData;
      }
    }

    // Cache expired or not found, fetch fresh from API
    debugPrint('📡 [GOLD-FETCH] Cache expired/not found, fetching from API...');
    final url = Uri.parse('https://www.goldapi.io/api/XAU/INR');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-access-token': apiKey,
          'Content-Type': 'application/json'
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ [GOLD-FETCH] API request timeout - returning cached value');
          return http.Response('Timeout', 408);
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

        debugPrint('✅ [GOLD-FETCH] Gold price fetched and stored');
        debugPrint('   Per Gram: ₹${pricePerGram.toStringAsFixed(2)}');
        debugPrint('   Per KG: ₹${pricePerKg.toStringAsFixed(2)}');
        debugPrint('   Next refresh needed in: $CACHE_EXPIRY_HOURS hours');

        return {
          'price_per_gram': pricePerGram,
          'price_per_kg': pricePerKg,
          'updated_at': DateTime.now().toString(),
          'from_cache': false,
        };
      } else if (response.statusCode == 408) {
        // Timeout - try to return cached value
        debugPrint('⏱️ [GOLD-FETCH] Request timeout, returning cached value if available');
        final cachedData = await _getCachedPrice();
        if (cachedData != null) {
          return cachedData;
        }
        return null;
      } else {
        debugPrint('❌ [GOLD-FETCH] API Error ${response.statusCode}: ${response.body}');
        // On API error, return cached value if available
        final cachedData = await _getCachedPrice();
        if (cachedData != null) {
          debugPrint('📦 [GOLD-FETCH] Returning cached value due to API error');
          return cachedData;
        }
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ [GOLD-FETCH] Network error: $e');
      // On network error, return cached value if available
      final cachedData = await _getCachedPrice();
      if (cachedData != null) {
        debugPrint('📦 [GOLD-FETCH] Returning cached value due to network error');
        return cachedData;
      }
      return null;
    }
  }

  /// Retrieves stored gold price per gram from SharedPreferences
  /// Returns cached value if available (within 12 hours), otherwise fetches fresh
  Future<double> getGoldPricePerGram({bool forceFresh = false}) async {
    if (!forceFresh) {
      final isCacheValid = await _isCacheValid();
      if (isCacheValid) {
        final cached = (await _getCachedPrice())?['price_per_gram'] as double?;
        if (cached != null) {
          debugPrint('💾 [GOLD-PRICE] Using cached gold price per gram: ₹${cached.toStringAsFixed(2)}');
          return cached;
        }
      }
    }

    // Fetch fresh if not cached or forceFresh is true
    final result = await fetchAndStoreGoldPrice();
    return result?['price_per_gram'] ?? 0.0;
  }

  /// Retrieves stored gold price per kg from SharedPreferences
  /// Returns cached value if available (within 12 hours), otherwise fetches fresh
  Future<double> getGoldPricePerKg({bool forceFresh = false}) async {
    if (!forceFresh) {
      final isCacheValid = await _isCacheValid();
      if (isCacheValid) {
        final cached = (await _getCachedPrice())?['price_per_kg'] as double?;
        if (cached != null) {
          debugPrint('💾 [GOLD-PRICE] Using cached gold price per kg: ₹${cached.toStringAsFixed(2)}');
          return cached;
        }
      }
    }

    // Fetch fresh if not cached or forceFresh is true
    final result = await fetchAndStoreGoldPrice();
    return result?['price_per_kg'] ?? 0.0;
  }

  /// Clear cached gold prices
  Future<void> clearCachedPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gold_price_per_gram');
      await prefs.remove('gold_price_per_kg');
      await prefs.remove('gold_price_updated_at');
      debugPrint('🗑️ [GOLD-CACHE] Cleared cached gold prices');
    } catch (e) {
      debugPrint('❌ [GOLD-CACHE] Error clearing cache: $e');
    }
  }
}
