import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

class SemanticTestPage extends StatefulWidget {
  const SemanticTestPage({super.key});

  @override
  State<SemanticTestPage> createState() => _SemanticTestPageState();
}

class _SemanticTestPageState extends State<SemanticTestPage> {
  bool started = false;
  bool finished = false;
  int timeLeft = 60;
  Timer? _timer;

  final PageController _controller = PageController(initialPage: 0);
  int currentPage = 0;
  late List<Widget> pages;
  TextEditingController _animalController = TextEditingController();
  List<String> animals = [];

  @override
  void initState() {
    super.initState();
    pages = [
      introPage(),
      timerPage(),
      resultsPage(),
    ];
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
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
                  "List as many animals as possible in 60 seconds!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      started = true;
                      timeLeft = 60;
                      startTimer();
                    });
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: timeLeft / 60,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            timeLeft > 10 ? Colors.purple : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '$timeLeft',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: timeLeft > 10 ? Colors.purple : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
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
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          animals.add(value);
                          _animalController.clear();
                        });
                      }
                    },
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
                        "You listed ${animals.length} animals:",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        snapshot.data.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            started = false;
                            finished = false;
                            timeLeft = 60;
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
          );
        }
      },
    );
  }

  Future<String> evaluateAnimals(List<String> animals) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyBz8SnJ4nBLT7WsmEw8PN0fZU60WD-Mo4o',
      );

      final prompt = '''
You are a schizophrenia expert. Analyze these animals for semantic correlation:
${animals.join(', ')}

Instructions:
If the animals have no semantic correlation with each other, indicate potential abnormality with this exact response:
"Category fluency test research indicates that you may have problems organizing your thought semantically. Research indicates that there is a correlation between people having this issue and schizophrenia.

Source: Nour, M. M., McNamee, D., Liu, Y., & Dolan, R. J. (2023). Trajectories through semantic spaces in schizophrenia and the relationship to ripple bursts. Proceedings of the National Academy of Sciences of the United States of America, 120(42). https://doi.org/10.1073/pnas.2305290120"

Otherwise, indicate normal semantic correlation.
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
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
        children: pages,
      ),
    );
  }
}
