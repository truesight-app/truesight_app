import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

import 'package:tflite_flutter/tflite_flutter.dart';

Color calculate_scale(double data) {
  if (data < 1.0) {
    return Colors.red;
  } else if (data < 2.0) {
    return Colors.orange;
  } else if (data < 3.0) {
    return Colors.yellow;
  } else if (data < 4.0) {
    return Colors.lightGreen;
  } else if (data < 5.0) {
    return Colors.green;
  } else if (data < 6.0) {
    return Colors.blue;
  } else {
    return Colors.purple;
  }
}

class SemanticTestPage extends StatefulWidget {
  const SemanticTestPage({super.key});

  @override
  State<SemanticTestPage> createState() => _SemanticTestPageState();
}

class _SemanticTestPageState extends State<SemanticTestPage> {
  bool started = false;
  bool finished = false; // finished the entire analysis
  // int timeLeft = 13;
  ValueNotifier<int> timeLeft = ValueNotifier(13);
  Timer? _timer;
  FocusNode testFieldFocusNode = FocusNode();
  final PageController _controller = PageController(initialPage: 0);
  int currentPage = 0;
  late List<Widget> pages;
  TextEditingController _animalController = TextEditingController();
  List<String> animals = [];
  late Map<String, int> vocab;

  @override
  void initState() {
    super.initState();
    loadVocab();
  }

  Future<void> loadVocab() async {
    final String jsonString = await rootBundle.loadString('assets/vocab.json');
    vocab = Map<String, int>.from(json.decode(jsonString));
  }

  int? encodeAnimal(String animal) {
    return vocab[animal] ?? vocab['<UNK>'];
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timer?.cancel();
        if (started && !finished) {
          finished = true;
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => resultsPage()));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _animalController.dispose();
    super.dispose();
  }

  Widget introPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade100,
            const Color.fromARGB(255, 231, 190, 200)
          ],
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, size: 64, color: Colors.purple),
                const SizedBox(height: 24),
                const Text(
                  "Category Fluency Test",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "List as many animals as possible in 13 seconds!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    started = true;
                    timeLeft.value = 13;
                    startTimer();

                    _controller.animateToPage(1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start Test",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<double> evaluateAnimals() async {
  //   double val = 0;
  //   OrtEnv.instance.init();
  //   final sessionOptions = OrtSessionOptions();
  //   const assetFileName = 'assets/aninet.onnx';
  //   final rawAssetFile = await rootBundle.load(assetFileName);
  //   final bytes = rawAssetFile.buffer.asUint8List();
  //   final session = OrtSession.fromBuffer(bytes, sessionOptions!);

  //   int batch_size = 32;

  //   if (animals.length % 2 != 0) {
  //     animals.removeLast();
  //   }

  //   final List<String> animalsCopy = List.from(animals);
  //   //iterate in pairs
  //   for (int i = 0; i < animalsCopy.length; i += 2) {
  //     String animal1 = animalsCopy[i];
  //     String animal2 = animalsCopy[i + 1];
  //     var a1 = encodeAnimal(animal1);
  //     var a2 = encodeAnimal(animal2);

  //     // Prepare the input tensors
  //     final animal1Data = [a1]; // Single value for animal1
  //     final animal2Data = [a2]; // Single value for animal2
  //     final shape = [1, 1]; // Shape: [batch_size, 1]

  //     // Create OrtValueTensor for both inputs
  //     final animal1Ort =
  //         OrtValueTensor.createTensorWithDataList(animal1Data, shape);
  //     final animal2Ort =
  //         OrtValueTensor.createTensorWithDataList(animal2Data, shape);

  //     // Create inputs map
  //     final inputs = {'animal1': animal1Ort, 'animal2': animal2Ort};

  //     final runOptions = OrtRunOptions();
  //     final output = await session?.runAsync(runOptions, inputs);
  //     final scale_min = 1.0;
  //     final scale_max = 7.0;
  //     output?.forEach((element) {
  //       // Assuming the output is a similarity score
  //       var data = (element!.value as List<List<double>>)[0][0];
  //       var scaled_data = data * (scale_max - scale_min) + scale_min;
  //       val += scaled_data;

  //       element?.release();
  //     });
  //   }

  //   val = val / (animalsCopy.length / 2);
  //   sessionOptions.release();
  //   session.release();

  //   return val;
  // }
  Future<double> evaluateAnimals() async {
    final interpreter = await Interpreter.fromAsset('assets/aninet.tflite');
    double val = 0;

    if (animals.length % 2 != 0) {
      animals.removeLast();
    }

    print('Input shape: ${interpreter.getInputTensor(0).shape}');
    print('Output shape: ${interpreter.getOutputTensor(0).shape}');

    for (int i = 0; i < animals.length; i += 2) {
      String animal1 = animals[i];
      String animal2 = animals[i + 1];
      var a1 = encodeAnimal(animal1)!;
      var a2 = encodeAnimal(animal2)!;

      // Create input tensors
      final input1 = List.filled(1, List.filled(1, a1));
      final input2 = List.filled(1, List.filled(1, a2));

      // Create output buffer
      var outputBuffer = List.filled(1, List<double>.filled(1, 0));

      // Run model
      interpreter.runForMultipleInputs([input1, input2], {0: outputBuffer});

      // Scale the output from [0,1] back to [1,7] range
      double scaled = outputBuffer[0][0] * 6.0 + 1.0;
      print('Pair ${animal1}-${animal2} score: $scaled');
      val += scaled;
    }

    // Calculate average
    final result = val / (animals.length / 2);

    interpreter.close();
    print('Final average: $result');
    return result;
  }

  Widget timerPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                    valueListenable: timeLeft,
                    builder: (context, val, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: val / 13,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              val > 10 ? Colors.purple : Colors.red,
                            ),
                          ),
                        ),
                        Text(
                          '$val',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: val > 10 ? Colors.purple : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    focusNode: testFieldFocusNode,
                    autofocus: true,
                    controller: _animalController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      hintText: 'Type an animal and press Enter',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.pets),
                    ),
                    onEditingComplete: () => _addAnimal(_animalController.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Animals Listed:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animals.isEmpty
                        ? "No animals listed yet"
                        : animals.join(", "),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultsPage() {
    return FutureBuilder(
      future: evaluateAnimals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade100, Colors.purple.shade100],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            ),
          );
        }
        {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade100, Colors.purple.shade100],
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Test Results",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Animals Listed:",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          animals.join(", "),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Average Semantic Similarity Score:",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 24),
                        LinearProgressIndicator(
                          value: (snapshot.data as double) / 7.0,
                          minHeight: 20,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              calculate_scale(snapshot.data as double)),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              started = false;
                              finished = false;
                              timeLeft.value = 13;
                              animals.clear();
                            });
                            Navigator.of(context).pop();
                            _controller.animateToPage(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Take Test Again",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _addAnimal(String animal) {
    if (animal.isNotEmpty) {
      setState(() {
        animals.add(animal);
        _animalController.clear();
      });
      testFieldFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semantic Test',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        controller: _controller,
        children: [
          introPage(),
          timerPage(),
        ],
      ),
    );
  }
}
