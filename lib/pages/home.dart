import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:truesight/pages/data_collection.dart';
import 'package:truesight/pages/positive_affs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truesight/pages/psychoeducation_page.dart';
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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Dashboard',
          style: GoogleFonts.lexend(
            fontSize: 24,
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
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
              const SemanticTestPage(),
              110,
            ),
            _buildDashboardButton(
              context,
              "Psychoeducation",
              const Color(0xFF8E94F2),
              const PsychoeducationPage(),
              110,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, Color color,
      Widget? page, double size) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(16.0),
            textStyle: GoogleFonts.lexend(fontSize: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
        ),
      ),
    );
  }
}
