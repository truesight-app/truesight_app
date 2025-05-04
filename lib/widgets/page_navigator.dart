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
        final isLastPage = pageNavigatorController.currentPage ==
            pageNavigatorController.numPages - 1;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pageNavigatorController.numPages,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.circle,
                      size: 8.0,
                      color: index == pageNavigatorController.currentPage
                          ? const Color(0xFF6246EA)
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pageNavigatorController.currentPage > 0)
                    ElevatedButton(
                      onPressed: pageNavigatorController.previousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6246EA),
                        side: const BorderSide(color: Color(0xFF6246EA)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  if (!isLastPage)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: pageNavigatorController.currentPage > 0
                              ? 16.0
                              : 0,
                        ),
                        child: ElevatedButton(
                          onPressed: pageNavigatorController.canProceed
                              ? pageNavigatorController.nextPage
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6246EA),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Continue'),
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
