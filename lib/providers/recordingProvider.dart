import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mindbalance/main.dart';

class RecordingState {
  final String filePath; // assume we haven't recorded anything yet
  RecordingState({required this.filePath});

  RecordingState copyWith({String? filePath}) {
    return RecordingState(filePath: filePath ?? this.filePath);
  }
}

class RecordingProvider extends StateNotifier<RecordingState> {
  RecordingProvider() : super(RecordingState(filePath: ''));

  Future<void> setFilePath(String path) async {
    state = state.copyWith(filePath: path);
  }

  Future<void> init() async {
    final directory = await getDownloadsDirectory();
    final path = '${directory!.path}/recording.m4a';
    state = state.copyWith(filePath: path);
  }

  get filePath => state.filePath;
}

final recordingProvider = StateNotifierProvider((ref) => RecordingProvider());
