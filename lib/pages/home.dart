import 'package:flutter/material.dart';
import 'package:truesight/pages/data_collection.dart';
import 'package:truesight/pages/positive_affs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildDashboardButton(
              context,
              "Hallucination Detection",
              const Color.fromARGB(255, 139, 194, 238),
              const DataCollection(),
            ),
            _buildDashboardButton(
              context,
              "Positive Affirmations",
              const Color.fromARGB(255, 203, 177, 247),
              const PositiveAffs(),
            ),
            _buildDashboardButton(
              context,
              "Schizophrenia Diagnostics",
              const Color.fromARGB(255, 203, 177, 247),
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, Color color, Widget? page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16.0),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: page != null
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => page,
                ),
              );
            }
          : null,
      child: Text(title, textAlign: TextAlign.center),
    );
  }
}
