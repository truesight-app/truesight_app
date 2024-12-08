import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesight/providers/recordingProvider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

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
      print('Initialization error: $e');
      _updateDebug('Init error: $e');
    }
  }

  void _updateDebug(String message) {
    print(message);
    if (mounted) {
      setState(() {
        debugMessage = message;
      });
    }
  }

  int argmax(List<double> list) {
    var largest = 0;
    for (var i = 1; i < list.length; i++) {
      if (list[i] > list[largest]) {
        largest = i;
      }
    }
    return largest;
  }

  Future<Map<int, String>> loadLabels() async {
    Map<int, String> labels = {};
    try {
      var file = await rootBundle.loadString('assets/labels.txt');
      var lines = file.split('\n');
      for (var i = 1; i < lines.length; i++) {
        var parts = lines[i].split(' ');
        if (parts.length >= 2) {
          var idx = int.tryParse(parts[0]);
          if (idx != null) {
            labels[idx] = parts[1];
          }
        }
      }
    } catch (e) {
      _updateDebug('Error loading labels: $e');
    }
    return labels;
  }

  Future<List<double>> preprocessAudio(String audioPath) async {
    try {
      _updateDebug('Starting audio preprocessing...');

      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      // convert file to wav
      final wavPath = audioPath.replaceAll('.m4a', '.wav');
      await FFmpegKit.executeAsync(
          '-i $audioPath -acodec pcm_s16le -ac 1 -ar 16000 $wavPath');

      // Get file bytes directly
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Audio file is empty');
      }

      _updateDebug('Audio file loaded, size: ${bytes.length} bytes');

      // Convert to list of doubles (assuming 16-bit PCM)
      List<double> samples = [];
      for (int i = 0; i < bytes.length - 1; i += 2) {
        int sample = bytes[i] + (bytes[i + 1] << 8);
        if (sample > 32767) sample -= 65536;
        samples.add(sample / 32768.0);
      }

      _updateDebug('Converted to ${samples.length} samples');

      // Ensure we have exactly 16000 samples
      if (samples.length > 16000) {
        samples = samples.sublist(0, 16000);
      } else if (samples.length < 16000) {
        samples = List.from(samples)
          ..addAll(List.filled(16000 - samples.length, 0.0));
      }

      _updateDebug('Final samples prepared: ${samples.length}');
      return samples;
    } catch (e) {
      _updateDebug('Preprocessing error: $e');
      rethrow;
    }
  }

  Future<void> _processRecording() async {
    if (isProcessing) {
      _updateDebug('Already processing, skipping...');
      return;
    }

    setState(() {
      isProcessing = true;
      predictionResult = null;
      errorMessage = null;
    });

    try {
      _updateDebug('Starting processing...');

      final filePath = ref.read(recordingProvider.notifier).filePath;
      if (filePath == null) {
        throw Exception('No recording file path available');
      }
      _updateDebug('File path: $filePath');

      // Verify file exists and has content
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Recording file not found');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Recording file is empty');
      }

      _updateDebug('File verified, size: $fileSize bytes');

      // Load labels
      final labels = await loadLabels();
      _updateDebug('Labels loaded: ${labels.length}');

      // Preprocess audio
      final samples = await preprocessAudio(filePath);
      _updateDebug('Audio preprocessed');

      // Initialize interpreter
      final interpreter = await Interpreter.fromAsset('assets/yam.tflite');
      _updateDebug('Interpreter initialized');

      // Prepare input data
      var input = samples.map((e) => [e]).toList();
      var outputShape = interpreter.getOutputTensor(0).shape;
      var output = List.generate(
          outputShape[0], (_) => List<double>.filled(outputShape[1], 0.0));

      // Run inference
      interpreter.run(input, output);
      _updateDebug('Inference completed');

      // Get prediction
      var prediction = argmax(output[0]);

      if (mounted) {
        setState(() {
          predictionResult = labels[prediction] ?? 'Unknown';
          isProcessing = false;
          debugMessage = 'Processing completed successfully';
        });
      }

      // Clean up
      interpreter.close();
    } catch (e) {
      _updateDebug('Error: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Audio'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Debug message
              if (debugMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    debugMessage!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],

              if (isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing audio...'),
                  ],
                )
              else if (errorMessage != null)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processRecording,
                      child: const Text('Try Again'),
                    ),
                  ],
                )
              else if (predictionResult != null)
                Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Prediction: $predictionResult',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processRecording,
                      child: const Text('Process Again'),
                    ),
                  ],
                )
              else
                const Text('No recording to process'),
            ],
          ),
        ),
      ),
    );
  }
}
