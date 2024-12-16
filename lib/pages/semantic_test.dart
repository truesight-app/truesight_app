import 'package:flutter/material.dart';

class SemanticTestPage extends StatefulWidget {
  const SemanticTestPage({super.key});

  @override
  State<SemanticTestPage> createState() => _SemanticTestPageState();
}

class _SemanticTestPageState extends State<SemanticTestPage> {
  bool started = false;
  bool finished = false;

  final PageController _controller = PageController(initialPage: 0);

  int currentPage = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      introPage(),
      timerPage(),
      resultsPage(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget introPage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Instructions here",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                started = true;
                _controller.animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                print("Navigated to Timer Page");
              },
              child: const Text("Start Test"))
        ],
      ),
    );
  }

  Widget timerPage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Timer",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                if (started == false) return;
                finished = true;
                _controller.animateToPage(2,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                print("Navigated to Results Page");
              },
              child: const Text("End Test"))
        ],
      ),
    );
  }

  Widget resultsPage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Results",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                started = false;
                _controller.animateToPage(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                print("Navigated to Intro Page");
              },
              child: const Text("Restart test"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semantic Test'),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
            print("Current Page: $currentPage");
          });
        },
        controller: _controller,
        children: pages,
      ),
    );
  }
}
