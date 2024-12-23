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
                const Color(0xFFDBA5C7),
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
# Schizophrenia: Medical Overview

## Definition
Schizophrenia is a complex neuropsychiatric disorder that affects approximately 1% of the global population, impacting how individuals perceive reality, think, and behave.

## Core Symptoms

### Positive Symptoms (Additions to Normal Experience) 
* Hallucinations - most commonly auditory (hearing voices), though visual, tactile, and other sensory experiences can occur. These experiences feel entirely real to the person experiencing them. The voices may give commands, comment on the person's behavior, or engage in conversation.

* Delusions - fixed false beliefs that persist despite contrary evidence. Common types include paranoid delusions (believing others are plotting against them), grandiose delusions (believing they have special powers), or referential delusions (believing random events have special meaning for them).

* Disorganized thinking and speech - including derailment (switching topics abruptly), tangentiality (giving unrelated answers to questions), or word salad (incomprehensible mixture of words and phrases).

### Negative Symptoms (Reductions in Normal Function)
* Reduced emotional expression ("flat affect") - diminished facial expressions, monotone voice, and reduced body language.

* Avolition - severe reduction in motivated self-initiated purposeful activities.

* Social withdrawal - decreased interest in social relationships and difficulty maintaining connections.

* Anhedonia - reduced ability to experience pleasure from activities.

## Cognitive Symptoms
* Working memory deficits - difficulty using information immediately after learning it.

* Attention problems - challenges focusing and filtering out distractions.

* Executive functioning issues - problems with planning, organizing, and decision-making.

## Causes and Risk Factors
* Genetic factors - having a close relative with schizophrenia increases risk.

* Environmental factors - including:
 - Pregnancy/birth complications
 - Cannabis use in adolescence
 - Childhood trauma
 - Urban environment
 - Migration
 - Social isolation

## Treatment Approaches
* Antipsychotic medications - primary pharmacological treatment targeting dopamine systems.

* Psychosocial interventions - including:
 - Cognitive Behavioral Therapy (CBT)
 - Family psychoeducation
 - Social skills training
 - Vocational rehabilitation

* Comprehensive treatment plans typically combine medication with psychosocial support.

## Course and Prognosis
* Onset typically occurs between late teens and early 30s.

* Course varies significantly between individuals - some experience episodes with periods of remission, others have more continuous symptoms.

* Early intervention generally associated with better outcomes.

* With proper treatment and support, many people with schizophrenia live fulfilling lives and manage their symptoms effectively.

## Scientific Research
* Current research focuses on:
 - Neurobiological mechanisms
 - Genetic risk factors
 - Novel treatment approaches
 - Early intervention strategies
 - Prevention methods

## Support and Resources
* Treatment typically involves a team of healthcare professionals including psychiatrists, psychologists, social workers, and case managers.

* Support groups and family education programs play important roles in comprehensive care.

* Crisis intervention services and supported housing/employment programs may be beneficial components of treatment.
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
        child: renderMarkdown(""),
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
      body: const Center(child: Text('Content to be added')),
    );
  }
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resources', style: GoogleFonts.lexend())),
      body: const Center(child: Text('Content to be added')),
    );
  }
}
