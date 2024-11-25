import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truesight/main.dart';

class RecordingState {
  final String filePath; // assume we haven't recorded anything yet
  RecordingState({required this.filePath});

  RecordingState copyWith({String? filePath}) {
    return RecordingState(filePath: filePath ?? this.filePath);
  }
}

class RecordingProvider extends StateNotifier<RecordingState> {
  RecordingProvider() : super(RecordingState(filePath: ''));

  Future<void> setFilePath(String recordingName) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$recordingName';
    state = state.copyWith(filePath: path);
  }

  get filePath => state.filePath;
}
final recordingProvider = StateNotifierProvider((ref) => RecordingProvider());
