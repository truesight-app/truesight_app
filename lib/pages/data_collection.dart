import 'package:flutter/material.dart';
import 'package:truesight/pages/components/recording_page.dart';
import 'package:truesight/widgets/page_navigator.dart';

class DataCollection extends StatefulWidget {
  const DataCollection({super.key});

  @override
  State<DataCollection> createState() => _DataCollectionState();
}

class _DataCollectionState extends State<DataCollection> {
  late final PageController _pageController = PageController();
  final TextEditingController _descriptionController = TextEditingController();
  late PageNavigatorController pageNavigatorController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageNavigatorController = PageNavigatorController(
      canProceed: false,
      currentPage: currentPage,
      pageController: _pageController,
      nextPage: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
      previousPage: () {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
    );

    // Listen to text changes
    _descriptionController.addListener(_checkWordCount);
  }

  void _checkWordCount() {
    final text = _descriptionController.text;
    final wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    pageNavigatorController.toggleCanProceed(wordCount >= 15);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildAudioDescription() {
    return Column(
      children: [
        const Text(
          "Give a brief description on what you are hearing.",
          style: TextStyle(fontSize: 26),
        ),
        const SizedBox(height: 20),
        TextField(
          maxLines: 5,
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Description (minimum 15 words)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Prevent swiping
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                  // Reset canProceed for new page
                  pageNavigatorController.toggleCanProceed(false);
                });
              },
              children: [
                buildAudioDescription(),
                RecordingPage(navigatorController: pageNavigatorController),
                Container(
                  color: Colors.red,
                  child: const Center(child: Text('Page 3')),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: PageNavigator(
              pageNavigatorController: pageNavigatorController,
            ),
          ),
        ],
      ),
    );
  }
}
