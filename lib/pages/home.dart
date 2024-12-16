import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:truesight/pages/data_collection.dart';
import 'package:truesight/pages/positive_affs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truesight/pages/semantic_test.dart';

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
        title: Text('Dashboard', style: GoogleFonts.lexend(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          
          children: [
            _buildDashboardButton(
              context,
              "Hallucination Detection",
              const Color.fromARGB(255, 139, 194, 238),
              const DataCollection(),
              110,
            ),
            _buildDashboardButton(
              context,
              "Positive Affirmations",
              const Color.fromARGB(255, 203, 177, 247),
              const PositiveAffs(),
              110,
            ),
            _buildDashboardButton(
              context,
              "Category Fluency Test",
              const Color.fromARGB(255, 217, 161, 112),
              SemanticTestPage(),
              110,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, Color color, Widget? page, double size) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SizedBox(
        height: size,
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16.0),
        textStyle: GoogleFonts.lexend(fontSize: 20),
        

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
    )
      ),
    
    );
  }
}
