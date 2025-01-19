import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mindbalance/pages/data_collection.dart';
import 'package:mindbalance/pages/positive_affs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindbalance/pages/semantic_test.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Education', style: GoogleFonts.lexend(fontSize: 24)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildDashboardButton(
                  context,
                  "Facts",
                  const Color.fromARGB(255, 139, 194, 238),
                  const DataCollection(),
                  110,
                ),
                _buildDashboardButton(
                  context,
                  "Symptoms",
                  const Color.fromARGB(255, 203, 177, 247),
                  const PositiveAffs(),
                  110,
                ),
                _buildDashboardButton(
                  context,
                  "Treatment",
                  const Color.fromARGB(255, 243, 207, 233),
                  SemanticTestPage(),
                  110,
                ),
                _buildDashboardButton(
                  context,
                  "Resources",
                  const Color.fromARGB(255, 243, 207, 233),
                  SemanticTestPage(),
                  110,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, Color color,
      Widget? page, double size) {
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
          )),
    );
  }
}
