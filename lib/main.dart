import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.read(recordingProvider.notifier).init();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "mindbalance",
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}
