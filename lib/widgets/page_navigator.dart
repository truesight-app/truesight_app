import 'package:flutter/material.dart';

class PageNavigatorController extends ChangeNotifier {
  void Function() nextPage;
  void Function() previousPage;
  int currentPage;
  int numPages;
  bool canProceed;
  final PageController pageController;

  PageNavigatorController({
    required this.nextPage,
    required this.previousPage,
    required this.currentPage,
    required this.canProceed,
    required this.pageController,
    required this.numPages,
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
  final PageNavigatorController pageNavigatorController;

  const PageNavigator({
    super.key,
    required this.pageNavigatorController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pageNavigatorController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pageNavigatorController.numPages,
                  (index) => Icon(
                    Icons.circle,
                    size: 8.0,
                    color: index == pageNavigatorController.currentPage
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: pageNavigatorController.previousPage,
                    child: const Text('Back'),
                  ),
                  if (pageNavigatorController.currentPage <
                      pageNavigatorController.numPages - 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pageNavigatorController.canProceed
                            ? pageNavigatorController.nextPage
                            : null,
                        child: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
