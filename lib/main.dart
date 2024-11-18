import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truesight/pages/home.dart';

late var temporaryDirectory;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  temporaryDirectory = await getTemporaryDirectory();
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "TrueSight",
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}
