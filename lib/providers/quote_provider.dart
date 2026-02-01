import 'package:flutter/material.dart';
import 'package:movestreak/models/quote.dart';
import 'package:movestreak/services/quote_service.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteService _quoteService;
  Quote? _quote;
  bool _isLoading = false;

  QuoteProvider({QuoteService? quoteService})
      : _quoteService = quoteService ?? QuoteService();

  Quote? get quote => _quote;
  bool get isLoading => _isLoading;

  Future<void> loadDailyQuote() async {
    _isLoading = true;
    notifyListeners();

    try {
      _quote = await _quoteService.getDailyQuote();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
