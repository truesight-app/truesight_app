import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesight/functions/gemini.dart';
import 'package:truesight/pages/report.dart';
import 'package:truesight/providers/formStateProvider.dart';
import 'package:truesight/providers/recordingProvider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
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
  String? debugMessage;
  PlayerController? playerController;
  List<Map<String, dynamic>> predictions = [];

  @override
  void initState() {
    super.initState();
    _initializeProcessing();
  }

  Future<void> _initializeProcessing() async {
    try {
      playerController = PlayerController();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _processRecording();
      }
    } catch (e) {
      _updateDebug('Init error: $e');
    }
  }

  void _updateDebug(String message) {
    if (mounted) {
      setState(() {
        debugMessage = message;
      });
    }
  }

  Future<Map<int, String>> loadLabels() async {
    Map<int, String> labels = {};
    try {
      final file = await rootBundle.loadString('assets/labels.txt');
      final lines = file.split('\n');
      for (var line in lines) {
        // Skip empty lines
        if (line.trim().isEmpty) continue;

        // Split only on the first space to keep the rest of the label intact
        final firstSpace = line.indexOf(' ');
        if (firstSpace == -1) continue;

        final idxStr = line.substring(0, firstSpace).trim();
        final label = line
            .substring(firstSpace + 1)
            .trim()
            // Remove any quotes from the label
            .replaceAll('"', '');

        try {
          final idx = int.parse(idxStr);
          labels[idx] = label;
        } catch (e) {
          print('Error parsing index: $idxStr');
          continue;
        }
      }
    } catch (e) {
      _updateDebug('Error loading labels: $e');
    }
    return labels;
  }

  Future<List<double>> preprocessAudio(String audioPath) async {
    try {
      _updateDebug('Converting audio format...');

      // Convert to WAV with correct parameters for YAMNet
      final wavPath = '${audioPath.replaceAll('.m4a', '')}_processed.wav';
      await FFmpegKit.execute(
          '-i $audioPath -acodec pcm_s16le -ac 1 -ar 16000 $wavPath');

      final wavFile = File(wavPath);
      if (!await wavFile.exists()) {
        throw Exception('WAV conversion failed');
      }

      final bytes = await wavFile.readAsBytes();
      List<double> samples = [];

      // Skip WAV header (44 bytes) and convert to mono float32
      for (int i = 44; i < bytes.length - 1; i += 2) {
        int sample = bytes[i] + (bytes[i + 1] << 8);
        if (sample > 32767) sample -= 65536;
        samples.add(sample / 32768.0);
      }

      // YAMNet expects 0.975 seconds of audio (16000 * 0.975 = 15600 samples)
      if (samples.length > 15600) {
        samples = samples.sublist(0, 15600);
      } else if (samples.length < 15600) {
        samples.addAll(List.filled(15600 - samples.length, 0.0));
      }

      return samples;
    } catch (e) {
      _updateDebug('Preprocessing error: $e');
      rethrow;
    }
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

      final labels = await loadLabels();
      final samples = await preprocessAudio(filePath);

      // Initialize YAMNet
      final interpreter = await Interpreter.fromAsset('assets/yam.tflite');

      // Prepare input tensor (1, 15600, 1)
      final input = [
        samples.map((e) => [e]).toList()
      ];

      // Prepare output tensor (1, 521)
      var outputShape = interpreter.getOutputTensor(0).shape;
      var output = List.generate(
          outputShape[0], (_) => List<double>.filled(outputShape[1], 0.0));

      // Run inference
      interpreter.run(input, output);

      // Process top predictions
      final scores = output[0];
      final sortedIndices = List.generate(scores.length, (i) => i)
        ..sort((a, b) => scores[b].compareTo(scores[a]));

      // Get top 5 predictions
      predictions = sortedIndices.take(5).map((index) {
        return {
          'label': labels[index] ?? 'Unknown',
          'confidence': scores[index] * 100,
        };
      }).toList();

      // all 5 predictions as a string
      String preds = '';
      for (var pred in predictions) {
        preds +=
            '${pred['label']} (${pred['confidence'].toStringAsFixed(1)}%), ';
      }

      ref.read(formStateProvider.notifier).setTranscribedAudio(preds);

      if (mounted) {
        setState(() {
          predictionResult = predictions.first['label'];
          isProcessing = false;
        });
      }

      interpreter.close();
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
      appBar: AppBar(
        title: const Text('Processing Audio'),
      ),
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Card
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
                      const SizedBox(height: 16),
                      Text(
                        'Analysis Complete',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
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
                          'Analyze Again',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            final audioDescription =
                                ref.read(formStateProvider).audioDescription;

                            final transcription =
                                ref.read(formStateProvider).transcribedAudio;

                            final response =
                                await compareTranscriptionAndDescription(
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
                          child: Text("Generate Report"))
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
