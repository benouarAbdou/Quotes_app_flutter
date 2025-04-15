import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotes/model/quote.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QuoteActions extends StatelessWidget {
  final Quote quote;
  final VoidCallback onRefresh;
  final ScreenshotController screenshotController;

  const QuoteActions({
    super.key,
    required this.quote,
    required this.onRefresh,
    required this.screenshotController,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: "'${quote.quote}' -${quote.author}"))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    });
  }

  Future<void> _shareQuote() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'screenshot${DateTime.now().toIso8601String()}.jpeg';
      final capturedFilePath = await screenshotController.captureAndSave(
        directory.path,
        fileName: fileName,
      );
      if (capturedFilePath != null && await File(capturedFilePath).exists()) {
        await Share.shareXFiles(
          [XFile(capturedFilePath)],
          text: quote.quote,
          subject: 'Quote',
        );
      } else {
        print('File does not exist: $capturedFilePath');
      }
    } catch (e) {
      print('Error sharing quote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onRefresh,
            child: const Text(
              'tap for more',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _copyToClipboard(context),
                child: Icon(
                  Icons.copy,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 20.0),
              GestureDetector(
                onTap: _shareQuote,
                child: Icon(
                  Icons.share,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
