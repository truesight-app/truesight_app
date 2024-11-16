import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truesight/widgets/page_navigator.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key, required this.navigatorController});
  final PageNavigatorController navigatorController;

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isRecording = false;
  bool isPlaying = false;
  bool hasRecording = false;
  bool isInitialized = false;
  int recordingSeconds = 0;
  final maxDuration = const Duration(seconds: 15);
  Timer? recordingTimer;
  late final RecorderController recorderController;
  late final PlayerController playerController;
  String recordingPath = '';

  @override
  void initState() {
    super.initState();
    widget.navigatorController.canProceed = false;
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    try {
      recorderController = RecorderController();
      playerController = PlayerController();
      await _initializeRecording();
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('Error initializing controllers: $e');
      // Handle initialization error - maybe show a dialog to user
    }
  }

  Future<void> _initializeRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      recordingPath = '${dir.path}/recording.m4a';

      if (File(recordingPath).existsSync()) {
        await playerController.preparePlayer(
          path: recordingPath,
          noOfSamples: 100,
        );
        setState(() {
          hasRecording = true;
        });
      }
    } catch (e) {
      print('Error initializing recording: $e');
      rethrow;
    }
  }

  void _startTimer() {
    recordingTimer?.cancel();
    recordingSeconds = 0;
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          recordingSeconds++;
          if (recordingSeconds >= maxDuration.inSeconds) {
            _stopRecording();
          }
        });
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      if (!isInitialized) {
        print('Controllers not initialized');
        return;
      }

      // Reset player if there was a previous recording
      if (hasRecording) {
        await playerController.stopPlayer();
        isPlaying = false;
      }

      await recorderController.record(path: recordingPath);
      _startTimer();
      setState(() {
        isRecording = true;
        hasRecording = false;
        isPlaying = false;
      });
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        isRecording = false;
      });
      // Consider showing an error message to the user
    }
  }

  Future<void> _stopRecording() async {
    try {
      recordingTimer?.cancel();

      if (isRecording) {
        final wasRecording = await recorderController.stop().then((_) => true);
        if (wasRecording) {
          await Future.delayed(const Duration(
              milliseconds: 200)); // Small delay to ensure file is written
          await playerController.preparePlayer(
            path: recordingPath,
            noOfSamples: 100,
          );

          if (mounted) {
            setState(() {
              isRecording = false;
              hasRecording = true;
              recordingSeconds = 0;
              widget.navigatorController.canProceed = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          isRecording = false;
          // Consider setting hasRecording based on whether the file exists
        });
      }
      // Consider showing an error message to the user
    }
  }

  Future<void> _togglePlayback() async {
    if (!hasRecording) return;

    try {
      if (playerController.playerState.isStopped ||
          playerController.playerState.isPaused) {
        await playerController.pausePlayer();
      } else {
        await playerController.startPlayer();
      }
      if (mounted) {
        setState(() {
          isPlaying = !isPlaying;
        });
      }
    } catch (e) {
      print('Error toggling playback: $e');
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    recorderController.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Record your surroundings",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? "Recording in progress..."
                : hasRecording
                    ? "Recording complete! You can play it back or record again."
                    : "Press the microphone button to start recording",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Recording waveform
          if (!hasRecording)
            Container(
              height: 140,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width - 80, 100),
                recorderController: recorderController,
                enableGesture: true,
                waveStyle: const WaveStyle(
                  backgroundColor: Colors.transparent,
                  showMiddleLine: false,
                  extendWaveform: true,
                  spacing: 5.0,
                  scaleFactor: 100,
                  waveCap: StrokeCap.round,
                  showBottom: false,
                ),
              ),
            ),

          // Playback waveform
          if (hasRecording)
            Container(
              height: 140,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width - 80, 100),
                playerController: playerController,
                enableSeekGesture: true,
                backgroundColor: Colors.black,
                playerWaveStyle: const PlayerWaveStyle(
                  scaleFactor: 0.8,
                  waveCap: StrokeCap.round,
                  spacing: 6.0,
                  liveWaveColor: Colors.blue,
                  showBottom: false,
                  seekLineColor: Colors.blue,
                  seekLineThickness: 4,
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Recording timer or playback controls
          if (isRecording)
            Text(
              '${maxDuration.inSeconds - recordingSeconds} seconds remaining',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),

          if (hasRecording && !isRecording)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _togglePlayback,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Record Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Record button
          if (!hasRecording || isRecording)
            Container(
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : Colors.blue)
                        .withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 48.0,
                onPressed: isRecording ? _stopRecording : _startRecording,
                icon: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.red,
                ),
                padding: const EdgeInsets.all(16),
              ),
            ),
        ],
      ),
    );
  }
}
