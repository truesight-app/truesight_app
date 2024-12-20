import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomFormState {
  String audio_description;
  String transcribed_audio;

  String llm_response;

  CustomFormState({
    this.audio_description = '',
    this.transcribed_audio = '',
    this.llm_response = '',
  });

  get audioDescription => audio_description;
  get transcribedAudio => transcribed_audio;
  get llmResponse => llm_response;

  CustomFormState copyWith({
    String? audio_description,
    String? transcribed_audio,
    String? llm_response,
  }) {
    return CustomFormState(
      audio_description: audio_description ?? this.audio_description,
      transcribed_audio: transcribed_audio ?? this.transcribed_audio,
      llm_response: llm_response ?? this.llm_response,
    );
  }

  factory CustomFormState.fromJson(Map<String, dynamic> json) {
    return CustomFormState(
      audio_description: json['audio_description'],
      transcribed_audio: json['transcribed_audio'],
      llm_response: json['llm_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audio_description': audio_description,
      'transcribed_audio': transcribed_audio,
      'llm_response': llm_response,
    };
  }
}

class CustomFormStateprovider extends StateNotifier<CustomFormState> {
  CustomFormStateprovider() : super(CustomFormState());

  void setAudioDescription(String description) {
    state.audio_description = description;
  }

  void setTranscribedAudio(String transcription) {
    state.transcribed_audio = transcription;
  }

  void setLLMResponse(String response) {
    state.llm_response = response;
  }
}

final formStateProvider =
    StateNotifierProvider<CustomFormStateprovider, CustomFormState>((ref) {
  final handler = CustomFormStateprovider();
  return handler;
});
