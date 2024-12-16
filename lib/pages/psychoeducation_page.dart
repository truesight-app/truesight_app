// psychoeducation_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PsychoeducationPage extends StatelessWidget {
  const PsychoeducationPage({super.key});

  Widget _buildOptionButton(
      BuildContext context, String title, Color color, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 110,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(20.0),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Psychoeducation',
          style: GoogleFonts.lexend(
            color: const Color(0xFF2D3142),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              _buildOptionButton(
                context,
                "Facts about Schizophrenia",
                const Color(0xFF8E94F2),
                const FactsPage(),
              ),
              _buildOptionButton(
                context,
                "Most Common Symptoms of Schizophrenia",
                const Color(0xFFBB9CD9),
                const SymptomsPage(),
              ),
              _buildOptionButton(
                context,
                "How to deal with Psychoeducation",
                const Color(0xFFDBA5C7),
                const CopingPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages for Cindy to implement
class FactsPage extends StatelessWidget {
  const FactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('Facts about Schizophrenia', style: GoogleFonts.lexend())),
      body: const Center(child: Text('Content to be added by Cindy')),
    );
  }
}

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Common Symptoms', style: GoogleFonts.lexend())),
      body: const Center(child: Text('Content to be added by Cindy')),
    );
  }
}

class CopingPage extends StatelessWidget {
  const CopingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Coping Strategies', style: GoogleFonts.lexend())),
      body: const Center(child: Text('Content to be added by Cindy')),
    );
  }
}
