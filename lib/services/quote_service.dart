import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quotes/model/quote.dart';

class QuoteService {
  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.https('zenquotes.io', '/api/random'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Quote.fromJson(jsonData[0]);
      } else {
        return Quote(quote: 'Check your wifi connection', author: '');
      }
    } catch (e) {
      print('Error fetching quote: $e');
      return Quote(quote: 'Check your wifi connection', author: '');
    }
  }
}
