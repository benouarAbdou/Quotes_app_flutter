import 'package:flutter/material.dart';
import 'package:quotes/model/quote.dart';
import 'package:screenshot/screenshot.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/quote_service.dart';
import '../widgets/quote_actions.dart';
import '../widgets/quote_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuoteService _quoteService = QuoteService();
  Quote _quote = Quote(quote: '', author: '');
  bool _isLoading = true;
  late final ScreenshotController _screenshotController;

  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
    });
    final quote = await _quoteService.fetchRandomQuote();
    setState(() {
      _quote = quote;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Skeletonizer(
                enabled: _isLoading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuoteDisplay(
                      quote: _quote,
                      isLoading: _isLoading,
                      screenshotController: _screenshotController,
                    ),
                  ],
                ),
              ),
            ),
            QuoteActions(
              quote: _quote,
              onRefresh: _fetchQuote,
              screenshotController: _screenshotController,
            ),
          ],
        ),
      ),
    );
  }
}
