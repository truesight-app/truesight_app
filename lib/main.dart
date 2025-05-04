import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindbalance/pages/components/processing_page.dart';
import 'package:mindbalance/pages/components/recording_page.dart';
import 'package:mindbalance/pages/data_collection.dart';
import 'package:mindbalance/pages/report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mindbalance/pages/home.dart';
import 'package:mindbalance/providers/recordingProvider.dart';

late var temporaryDirectory;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  temporaryDirectory = await getDownloadsDirectory();

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "mindbalance",
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/collect': (context) => const DataCollection(),
        '/record': (context) => const RecordingPage(),
        '/process': (context) => const ProcessingPage(),
        '/report': (context) => const ReportPage(),
      },
    );
  }
}
