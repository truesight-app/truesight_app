import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesight/pages/components/processing_page.dart';
import 'package:truesight/providers/recordingProvider.dart';
import 'package:truesight/widgets/page_navigator.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truesight/main.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordingPage extends ConsumerStatefulWidget {
  const RecordingPage({super.key, required this.navigatorController});
  final PageNavigatorController navigatorController;

  @override
  ConsumerState<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends ConsumerState<RecordingPage> {
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
    hasRecording = false;
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
    }
  }

  Future<void> _initializeRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      recordingPath = '${dir.path}/recording.m4a';

      // Delete existing recording file
      if (File(recordingPath).existsSync()) {
        await File(recordingPath).delete();
      }

      setState(() {
        hasRecording = false;
      });
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

      // Stop playback if it's playing
      if (isPlaying) {
        await playerController.stopPlayer();
        setState(() {
          isPlaying = false;
        });
      }

      // Delete existing recording if any
      if (File(recordingPath).existsSync()) {
        await File(recordingPath).delete();
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
    }
  }

  Future<void> _stopRecording() async {
    try {
      recordingTimer?.cancel();

      if (isRecording) {
        await recorderController.stop();
        // Add a small delay to ensure file is written
        await Future.delayed(const Duration(milliseconds: 200));

        if (File(recordingPath).existsSync()) {
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

          ref.read(recordingProvider.notifier).setFilePath(recordingPath);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording saved!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (!hasRecording) return;

    try {
      if (isPlaying) {
        await playerController.pausePlayer();
        setState(() {
          isPlaying = false;
        });
      } else {
        if (playerController.playerState.isStopped) {
          await playerController.startPlayer(finishMode: FinishMode.stop);
        } else {
          await playerController.startPlayer();
        }
        setState(() {
          isPlaying = true;
        });

        // Listen for playback completion
        playerController.onCompletion.listen((_) {
          if (mounted) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      }
    } catch (e) {
      print('Error toggling playback: $e');
      setState(() {
        isPlaying = false;
      });
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Record your surroundings",
            style: GoogleFonts.lexend(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? "Recording in progress..."
                : hasRecording
                    ? "Recording complete! You can play it back or record again."
                    : "Press the microphone button to start recording",
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Recording waveform
          if (!hasRecording)
            Container(
              height: 160,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6246EA),
                    const Color(0xFF6246EA).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6246EA).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width - 96, 100),
                recorderController: recorderController,
                enableGesture: true,
                waveStyle: const WaveStyle(
                  backgroundColor: Colors.transparent,
                  showMiddleLine: false,
                  extendWaveform: true,
                  spacing: 6.0,
                  scaleFactor: 80,
                  waveCap: StrokeCap.round,
                  showBottom: false,
                  waveColor: Colors.white,
                ),
              ),
            ),

          // Playback waveform
          if (hasRecording)
            Container(
              height: 160,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width - 96, 100),
                playerController: playerController,
                enableSeekGesture: true,
                backgroundColor: Colors.transparent,
                playerWaveStyle: const PlayerWaveStyle(
                  scaleFactor: 0.8,
                  waveCap: StrokeCap.round,
                  spacing: 6.0,
                  liveWaveColor: Color(0xFF6246EA),
                  showBottom: false,
                  seekLineColor: Color(0xFF6246EA),
                  seekLineThickness: 2,
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Recording timer
          if (isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.red[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${maxDuration.inSeconds - recordingSeconds} seconds remaining',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),

          // Playback controls
          if (hasRecording && !isRecording)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _togglePlayback,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  label: Text(
                    isPlaying ? 'Pause' : 'Play',
                    style: GoogleFonts.lexend(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6246EA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh, color: Color(0xFF6246EA)),
                  label: Text(
                    'Record Again',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF6246EA),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF6246EA)),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Record button
          if (!hasRecording || isRecording)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isRecording
                      ? [Colors.red[400]!, Colors.red[600]!]
                      : [
                          const Color(0xFF6246EA),
                          const Color(0xFF6246EA).withOpacity(0.8),
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording
                            ? Colors.red[400]!
                            : const Color(0xFF6246EA))
                        .withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: isRecording
                      ? () async {
                          await ref
                              .read(recordingProvider.notifier)
                              .setFilePath(recordingPath);
                          _stopRecording();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Recording saved!',
                                style: GoogleFonts.lexend(),
                              ),
                              backgroundColor: const Color(0xFF6246EA),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProcessingPage(),
                            ),
                          );
                        }
                      : _startRecording,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
