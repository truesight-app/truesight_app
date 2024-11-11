import 'package:flutter/material.dart';

class PageNavigatorController extends ChangeNotifier {
  void Function() nextPage;
  void Function() previousPage;
  int currentPage;
  bool canProceed;
  final PageController pageController;

  PageNavigatorController({
    required this.nextPage,
    required this.previousPage,
    required this.currentPage,
    required this.canProceed,
    required this.pageController,
  });

  void toggleCanProceed(bool value) {
    canProceed = value;
    notifyListeners();
  }

  void update({
    required void Function() nextPage,
    required void Function() previousPage,
    required int currentPage,
    required bool canProceed,
  }) {
    this.nextPage = nextPage;
    this.previousPage = previousPage;
    this.currentPage = currentPage;
    this.canProceed = canProceed;
    notifyListeners();
  }
}

class PageNavigator extends StatelessWidget {

  PageNavigatorController pageNavigatorController;

  PageNavigator({
    super.key,
    required this.pageNavigatorController,
  
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
            onPressed: pageNavigatorController.canProceed ? pageNavigatorController.nextPage : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
