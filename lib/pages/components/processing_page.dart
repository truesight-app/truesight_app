import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truesight/providers/recordingProvider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  const ProcessingPage({super.key});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends ConsumerState<ProcessingPage> {
  bool isProcessing = false;

  Future<void> getPrediction() async {
    final interpreter = await Interpreter.fromAsset('assets/yam.tflite');
    PlayerController playerController = PlayerController();
    var samples = await playerController.extractWaveformData(path: ref.read(recordingProvider.notifier).filePath);
    // normalize to -1 to 1
    samples = samples.map((e) => e / 32768.0).toList();

    // Convert stereo to mono by averaging channels if necessary
    if (samples.length > 1) {
      samples = [samples.reduce((a, b) => a + b) / samples.length];
    }

    print(samples.length);
  }

  

  @override
  Widget build(BuildContext context) {
    var recording_handler = ref.read(recordingProvider.notifier).filePath;

    if (recording_handler != null && !isProcessing) {
      isProcessing = true;
      getPrediction();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing Inputs'),
      ),
      body: Container(),
    );
  }
}

/**
 * 
 * import tensorflow as tf
import keras
import numpy as np
import scipy.io.wavfile as wavfile
import scipy
import csv

# Load the model from tflite
class_file = open('classes.csv', 'r')
class_reader = csv.reader(class_file)
class_read = next(class_reader)
classes = []
for row in class_reader:
    
    classes.append(row[2])
interpreter = tf.lite.Interpreter(model_path="yam.tflite")

wav_file_name = 'silence.wav'

def ensure_sample_rate(original_sample_rate, waveform,
                      desired_sample_rate=16000):
    """Resample waveform if required."""
    if original_sample_rate != desired_sample_rate:
        desired_length = int(round(float(len(waveform)) /
                              original_sample_rate * desired_sample_rate))
        waveform = scipy.signal.resample(waveform, desired_length)
    return desired_sample_rate, waveform

# Allocate memory for the model
interpreter.allocate_tensors()

# Read and preprocess audio
sample_rate, wav_data = wavfile.read(wav_file_name, 'rb')
sample_rate, wav_data = ensure_sample_rate(sample_rate, wav_data)

# Show some basic information about the audio
duration = len(wav_data)/sample_rate
print(f'Sample rate: {sample_rate} Hz')
print(f'Total duration: {duration:.2f}s')
print(f'Size of the input: {len(wav_data)}')

# Get model details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
input_shape = input_details[0]['shape']
print(f"Required input shape: {input_shape}")

# Preprocess the data
wav_data = wav_data / 32768.0  # Normalize to float

# Convert stereo to mono by averaging channels if necessary
if len(wav_data.shape) > 1:
    wav_data = np.mean(wav_data, axis=1)

# Ensure the length matches the model's expected input
if len(wav_data) > input_shape[0]:
    wav_data = wav_data[:input_shape[0]]  # Truncate
elif len(wav_data) < input_shape[0]:
    wav_data = np.pad(wav_data, (0, input_shape[0] - len(wav_data)))  # Pad

# Ensure correct shape and data type
wav_data = wav_data.astype(np.float32)
wav_data = np.reshape(wav_data, input_shape)

print(f"Final input shape: {wav_data.shape}")

# Set the tensor and run inference
interpreter.set_tensor(input_details[0]['index'], wav_data)
interpreter.invoke()

# Get the output
output_data = interpreter.get_tensor(output_details[0]['index'])
output = np.argmax(output_data)
print(f"Predicted class: {classes[output]}")
 */