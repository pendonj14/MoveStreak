import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movestreak/models/quote.dart';
import 'package:intl/intl.dart';

class QuoteService {
  static const String _quoteCacheKey = 'cached_quote_date';
  static const String _quoteCacheDataKey = 'cached_quote_data';
  static const String _quotesApi = 'https://api.quotable.io/random?tags=motivational';

  Future<Quote> getDailyQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final cachedDate = prefs.getString(_quoteCacheKey);

      // Return cached quote if it's the same day
      if (cachedDate == today) {
        final cachedData = prefs.getString(_quoteCacheDataKey);
        if (cachedData != null) {
          final json = jsonDecode(cachedData);
          return Quote.fromJson(json);
        }
      }

      // Fetch new quote
      final quote = await _fetchQuoteFromApi();

      // Cache the quote
      await prefs.setString(_quoteCacheKey, today);
      await prefs.setString(_quoteCacheDataKey, jsonEncode(quote.toJson()));

      return quote;
    } catch (e) {
      // Return fallback quote if API fails
      return Quote(
        content: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
      );
    }
  }

  Future<Quote> _fetchQuoteFromApi() async {
    try {
      final response = await http.get(Uri.parse(_quotesApi)).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Quote.fromJson(json);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      throw Exception('Error fetching quote: $e');
    }
  }
}
