import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quotes/model/quote.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quotes',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Quote quote = Quote(quote: "", author: "");
  late ScreenshotController screenshotController;
  bool isLoading = true;

  Future<void> getQuote() async {
    setState(() {
      isLoading = true;
    });

    try {
      var req = await http.get(
        Uri.https('zenquotes.io', 'api/random'),
      );

      if (req.statusCode == 200) {
        var jsonData = jsonDecode(req.body);
        setState(() {
          quote = Quote(quote: jsonData[0]["q"], author: jsonData[0]["a"]);
          isLoading = false;
        });
      } else {
        setState(() {
          quote = Quote(
            quote: "Check your wifi connection",
            author: "",
          );
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        quote = Quote(
          quote: "Check your wifi connection",
          author: "",
        );
        isLoading = false;
      });
      print("Error fetching quote: $error");
    }
  }

  void copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: "'${quote.quote}' -${quote.author}"))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    });
  }

  Future<void> shareQuote() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      String? capturedFilePath = await screenshotController.captureAndSave(
        directory.path,
        fileName: 'screenshot${DateTime.now().toIso8601String()}.jpeg',
      );

      if (capturedFilePath != null && await File(capturedFilePath).exists()) {
        await Share.shareFiles([capturedFilePath], text: quote.quote);
      } else {
        print("File does not exist: $capturedFilePath");
      }
    } catch (error) {
      print("Error sharing quote: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
    getQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Skeletonizer(
                enabled: isLoading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoading ? "Loading quote..." : quote.quote,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.normal,
                                fontFamily: "PTSans",
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              isLoading ? "Loading author..." : quote.author,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: getQuote,
                    child: const Text(
                      "tap for more",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: copyTextToClipboard,
                        child: Icon(
                          Icons.copy,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: shareQuote,
                        child: Icon(
                          Icons.share,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
