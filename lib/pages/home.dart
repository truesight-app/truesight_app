import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truesight/pages/data_collection.dart';
import 'package:truesight/pages/positive_affs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truesight/pages/psychoeducation_page.dart';
import 'package:truesight/pages/semantic_test.dart';
import 'package:truesight/providers/formStateProvider.dart';

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
        actions: [
          // report page
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReportList(),
                ),
              );
            },
            icon: const Icon(Icons.report),
          ),
        ],
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
              "Category Fluency Test",
              const Color.fromARGB(255, 184, 221, 255),
              const SemanticTestPage()
              ,
              110,
            ),
            _buildDashboardButton(
              context,
              "Positive Affirmations",
              const Color.fromARGB(255, 184, 209, 255),
              const PositiveAffs(),
              110,
            ),
            _buildDashboardButton(
              context,
              "Hallucination Detection",
              const Color.fromARGB(255, 184, 186, 255),
              const DataCollection(),
              110,
            ),
            _buildDashboardButton(
              context,
              "Education",
              const Color.fromARGB(255, 201, 188, 255),
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
            textStyle: GoogleFonts.lexend(fontSize: 20, color: Colors.black),
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

class ReportList extends StatefulWidget {
  const ReportList({super.key});

  @override
  State<ReportList> createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  Future<List<CustomFormState>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<CustomFormState> reports = [];
    final savedData = prefs.getString('report_data_list');
    if (savedData != null) {
      List<dynamic> reportList = json.decode(savedData);
      reports =
          reportList.map((report) => CustomFormState.fromJson(report)).toList();
    }

    // Sort reports by timestamp if you have one, or you can add a timestamp field
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Records"),
      ),
      body: FutureBuilder<List<CustomFormState>>(
        future: getRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reports found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // Navigate to detail view
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(report: report),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Audio Description Preview
                        Text(
                          'Audio Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.audioDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Transcribed Audio Preview
                        Text(
                          'Transcribed Audio',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.transcribedAudio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                // Delete report then overwrite the saved data
                                var idx =
                                    reports.indexWhere((r) => r == report);
                                reports.removeAt(idx);

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'report_data_list',
                                  json.encode(reports),
                                );

                                setState(() {});
                              },
                              child: const Text('Delete'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                // Navigate to detail view
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReportDetailPage(report: report),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Report Detail Page
class ReportDetailPage extends StatelessWidget {
  final CustomFormState report;

  const ReportDetailPage({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(report.audioDescription),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcribed Audio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(report.transcribedAudio),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LLM Response',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(report.llmResponse),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
