import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindbalance/functions/gemini.dart';
import 'package:mindbalance/services/api_service.dart';
import 'package:mindbalance/providers/recordingProvider.dart';
import 'package:mindbalance/providers/formStateProvider.dart';
import 'package:mindbalance/pages/report.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  const ProcessingPage({super.key});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends ConsumerState<ProcessingPage> {
  bool isProcessing = false;
  String? predictionResult;
  String? errorMessage;
  List<Map<String, dynamic>> predictions = [];

  @override
  void initState() {
    super.initState();
    _processRecording();
  }

  Future<void> _processRecording() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      predictionResult = null;
      errorMessage = null;
      predictions = [];
    });

    try {
      final filePath = ref.read(recordingProvider.notifier).filePath;
      if (filePath == null) throw Exception('No recording found');

      // Send to server for analysis
      final result = await ApiService.analyzeAudio(filePath);
      predictions =
          List<Map<String, dynamic>>.from(result['predictions'] ?? []);

      if (mounted) {
        setState(() {
          predictionResult =
              predictions.isNotEmpty ? predictions.first['label'] : null;
          isProcessing = false;
        });

        if (predictions.isNotEmpty) {
          final predictionText = predictions
              .map((p) =>
                  '${p['label']} (${p['confidence'].toStringAsFixed(1)}%)')
              .join(', ');
          ref
              .read(formStateProvider.notifier)
              .setTranscribedAudio(predictionText);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isProcessing = false;
        });
      }
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analysis',
          style: GoogleFonts.lexend(
            color: const Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (isProcessing) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6246EA),
                          ),
                          strokeWidth: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Analyzing your audio...',
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This might take a moment',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ] else if (errorMessage != null) ...[
                      Icon(Icons.error_outline,
                          color: Colors.red[400], size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Analysis Failed',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _processRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6246EA),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ] else if (predictions.isNotEmpty) ...[
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[400],
                        size: 64,
                      ),
                      const SizedBox(height: 32),
                      ...predictions
                          .map((pred) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pred['label'],
                                        style: GoogleFonts.lexend(
                                          fontSize: 16,
                                          color: const Color(0xFF2D3142),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFF6246EA).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${pred['confidence'].toStringAsFixed(1)}%',
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: const Color(0xFF6246EA),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _processRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6246EA),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF6246EA)),
                          ),
                        ),
                        child: Text(
                          'Analyze Again',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: predictions.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  final audioDescription =
                      ref.read(formStateProvider).audioDescription;
                  final transcription =
                      ref.read(formStateProvider).transcribedAudio;
                  final response = await compareTranscriptionAndDescription(
                      transcription, audioDescription);
                  ref
                      .read(formStateProvider.notifier)
                      .setLLMResponse(response!);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ReportPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6246EA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Generate Report',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
