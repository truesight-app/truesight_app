import 'package:flutter/material.dart';

class SemanticTestPage extends StatefulWidget {
  const SemanticTestPage({super.key});

  @override
  State<SemanticTestPage> createState() => _SemanticTestPageState();
}

class _SemanticTestPageState extends State<SemanticTestPage> {
  bool started = false;
  bool finished = false;

  final PageController _controller = PageController();

  int currentPage = 0;

  late var pages;

  @override
  void initState() {
    super.initState();
    pages = [
      introPage(),
      timerPage(),
      resultsPage(),
    ];
  }

  Widget introPage() {
    return Container(
      child: Column(
        children: [
          Text("Instructions here"),
          ElevatedButton(
              onPressed: () {
         
                  _controller.animateToPage(1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInBack);
                  print("Navigated to Timer Page");
          
              },
              child: Text("Start Test"))
        ],
      ),
    );
  }

  Widget timerPage() {
    return Container(
      child: Column(
        children: [
          Text("Timer"),
          ElevatedButton(
              onPressed: () {
           
                  _controller.animateToPage(2,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInBack);
                  print("Navigated to Results Page");
        
              },
              child: Text("End Test"))
        ],
      ),
    );
  }

  Widget resultsPage() {
    return Container(
      child: Column(
        children: [
          Text("Results"),
          ElevatedButton(
              onPressed: () {
  
                  _controller.animateToPage(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInBack);
                  print("Navigated to Intro Page");
           
              },
              child: Text("Restart test"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: PageView(
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
              print("Current Page: $currentPage");
            });
          },
          controller: _controller,
          children: pages,
        ),
      ),
    );
  }
}
