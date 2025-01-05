import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PsychoeducationPage extends StatelessWidget {
  const PsychoeducationPage({super.key});

  Widget _buildOptionButton(
      BuildContext context, String title, Color color, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.8,
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
          'Education',
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
          child: ListView(
            children: [
              _buildOptionButton(
                context,
                "Facts",
                const Color(0xFF8E94F2),
                const FactsPage(),
              ),
              _buildOptionButton(
                context,
                "Symptoms",
                const Color(0xFFBB9CD9),
                const SymptomsPage(),
              ),
              _buildOptionButton(
                context,
                "Treatment",
                const Color(0xFFDBA5C7),
                const TreatmentPage(),
              ),
              _buildOptionButton(
                context,
                "Resources",
                const Color.fromARGB(255, 226, 176, 189),
                const ResourcesPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget renderMarkdown(String content) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          textScaleFactor: 1.5,
          h1: GoogleFonts.lexend(),
          h2: GoogleFonts.lexend(),
          h3: GoogleFonts.lexend(),
          listBullet: GoogleFonts.lexend(),
          
        ),
      ),
    ),
  );
}

// implement here
class FactsPage extends StatelessWidget {
  const FactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('Facts about Schizophrenia', style: GoogleFonts.lexend())),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: renderMarkdown("""

* Schizophrenia affects about 1% of the world’s population, (60 million people, around the world)\


* Schizophrenia is a mental illness, just like stroke, Parkinson’s disease, Alzheimer’s disease and others.\

* About 50% of patients with schizophrenia do not take their prescribed medications as directed because they are unaware of their condition.\

* Lack of treatment leads to severe negative health outcomes, including a life expectancy shortened by an average of 28.5 years.  



      """),
      ),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: renderMarkdown("""

* Delusions: Believing in things that aren't real or true.\

* Hallucinations: Seeing or hearing things that other people don't observe.\

* Disorganized speech and thinking.\

* Extremely disorganized or unusual motor behavior: Childlike silliness or being agitated for no reason.\

* Negative symptoms: Lose interest in everyday activities, socially withdraw and have a hard time planning ahead.\
      """),
      ),
    );
  }
}

class TreatmentPage extends StatelessWidget {
  const TreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Coping Strategies', style: GoogleFonts.lexend())),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: renderMarkdown("""

* Psychotherapy: A therapist or psychiatrist can teach a patient how to deal with their thoughts and behavior, how to improve their attention, memory, and ability to organize their thoughts\

* Psychosocial therapy: It teaches a patient social skills, helps them build a sense of optimism, provides job counseling, and education in money management.\

* Medication: There are many antipsychotic drugs. However, some drugs can cause weight gain and raise blood sugar and cholesterol levels. Changes in nutrition and exercise along with medication intervention can help address these side effects.\
      """),
      ),
    );
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resources', style: GoogleFonts.lexend())),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: renderMarkdown("""

* S&PAA - Schizophrenia & Psychosis Action Alliance\

* CureSZ Foundation\

* NAMI - National Alliance on Mental Illness\

* TAC - Treatment Advocacy Center\
      """),
      ),
    );
  }
}
