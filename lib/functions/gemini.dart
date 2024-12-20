import 'package:google_generative_ai/google_generative_ai.dart';

Future<String?> getPositiveAffirms(String description) async {
  const apiKey = "AIzaSyBz8SnJ4nBLT7WsmEw8PN0fZU60WD-Mo4o";
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.5),
      systemInstruction: Content.text(
          "Give markdown output. Give a positive affirmation and give a reason why it is true. For example, if the user says everyone is out to get me, you could respond with, that's not true, your friends care about you and want to see you succeed."));

  final prompt = description;
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  return response.text;
}

Future<String?> compareTranscriptionAndDescription(
    String transcription, String description) async {
  // compare the yamn audio transcription and the description the user gave
  // llm determines if the user is in fact not being paranoid or not

  const apiKey = "AIzaSyBz8SnJ4nBLT7WsmEw8PN0fZU60WD-Mo4o";
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0.5),
      systemInstruction: Content.text(
          "Given an audio transcription from the user's surroundings, and a description of what the user says they are hearing, aim to determine if there may be some schizophrenia or paranoia present. If the user says they hear voices, and the transcription says they hear nothing, you could respond with, that's not true, the transcription says you hear nothing."
          ". But respond in a way that is helpful and not dismissive."));

  final prompt =
      "<transcription> $transcription </transcription> <description> $description </description>";
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  return response.text;
}
