import 'package:flutter/material.dart';
import 'package:quotes/model/quote.dart';
import 'package:screenshot/screenshot.dart';

class QuoteDisplay extends StatelessWidget {
  final Quote quote;
  final bool isLoading;
  final ScreenshotController screenshotController;

  const QuoteDisplay({
    super.key,
    required this.quote,
    required this.isLoading,
    required this.screenshotController,
  });

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        padding: const EdgeInsets.all(40.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLoading ? 'Loading quote...' : quote.quote,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                fontFamily: 'PTSans',
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              isLoading ? 'Loading author...' : quote.author,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
