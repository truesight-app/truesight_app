import 'package:flutter/material.dart';

class PageNavigatorController {
  void Function() nextPage;
  void Function() previousPage;

  PageNavigatorController({
    required this.nextPage,
    required this.previousPage,
  });
}

class PageNavigator extends StatelessWidget {
  final PageController pageController;
  int currentPage;
  bool canProceed;
  PageNavigatorController pageNavigatorController;

  PageNavigator({
    super.key,
    required this.pageController,
    required this.pageNavigatorController,
    required this.currentPage,
    required this.canProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: pageNavigatorController.previousPage,
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: canProceed ? pageNavigatorController.nextPage : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}