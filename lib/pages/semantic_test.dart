import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

class SemanticTestPage extends StatefulWidget {
  const SemanticTestPage({super.key});

  @override
  State<SemanticTestPage> createState() => _SemanticTestPageState();
}

class _SemanticTestPageState extends State<SemanticTestPage> {
  bool started = false;
  bool finished = false; // finished the entire analysis
  // int timeLeft = 45;
  ValueNotifier<int> timeLeft = ValueNotifier(45);
  Timer? _timer;
  FocusNode testFieldFocusNode = FocusNode();
  final PageController _controller = PageController(initialPage: 0);
  int currentPage = 0;
  late List<Widget> pages;
  TextEditingController _animalController = TextEditingController();
  List<String> animals = [];

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timer?.cancel();
        if (started && !finished) {
          finished = true;
          _controller.animateToPage(2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
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
                  "List as many animals as possible in 45 seconds!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    started = true;
                    timeLeft.value = 45;
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
                            value: val / 45,
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
      future: evaluateAnimals(animals),
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
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
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
                          animals.join(", "),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        MarkdownBody(
                          data: snapshot.data.toString(),
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.lexend(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              started = false;
                              finished = false;
                              timeLeft.value = 45;
                              animals.clear();
                            });
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

  Future<String> evaluateAnimals(List<String> animals) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyBz8SnJ4nBLT7WsmEw8PN0fZU60WD-Mo4o',
      );

      const prompt = '''
You are an expert in cognitive assessment specializing in semantic fluency analysis. Analyze these animals for semantic clustering and switching patterns:

Perform the following analysis:

1. Identify semantic clusters (groups of related animals), such as:
   - Farm animals
   - Wild animals
   - Pets
   - Marine animals
   - Birds
   - Insects
   - Geographic regions
   - Habitats

2. Calculate:
   - Number of distinct clusters
   - Average cluster size
   - Number of switches between clusters
   - Any repetitions or invalid entries

3. Evaluate response patterns:
   - Are animals within each cluster semantically related?
   - Are transitions between clusters logical?
   - Is there evidence of organized thinking in the clustering?

4. Provide one of these assessments based on specific criteria:

A. If the response shows these characteristics:
   - Multiple clear semantic clusters (3 or more)
   - Logical transitions between clusters
   - Related animals within clusters
   - Few or no repetitions
   Return: "Normal semantic pattern detected. Your responses show organized thinking with clear semantic clustering and logical transitions between animal categories."

B. If the response shows these characteristics:
   - Few or no clear semantic clusters (0-2)
   - Random or unrelated transitions
   - Unrelated animals within attempted clusters
   - Multiple repetitions or invalid entries
   Return: "Category fluency test research indicates that you may have problems organizing your thoughts semantically. Research indicates that there is a correlation between people having this issue and schizophrenia.

Source: Nour, M. M., McNamee, D., Liu, Y., & Dolan, R. J. (2023). Trajectories through semantic spaces in schizophrenia and the relationship to ripple bursts. Proceedings of the National Academy of Sciences of the United States of America, 120(42). https://doi.org/10.1073/pnas.2305290120"

Provide a detailed breakdown of your analysis before stating the final assessment.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'No evaluation generated';
    } catch (e) {
      throw Exception('Failed to evaluate animals: $e');
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
          resultsPage(),
        ],
      ),
    );
  }
}
