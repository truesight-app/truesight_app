import 'package:flutter/material.dart';
import 'package:truesight/pages/components/recording_page.dart';
import 'package:truesight/widgets/page_navigator.dart';


class PositiveAffs extends StatefulWidget {
  const PositiveAffs({super.key});

  @override
  State<PositiveAffs> createState() => _PositiveAffsState();
}

class _PositiveAffsState extends State<PositiveAffs> {
  late final PageController _pageController = PageController();
  final TextEditingController _descriptionController = TextEditingController();
  late PageNavigatorController pageNavigatorController;

  int currentPage = 0;
  bool canProceed = false;

  @override
  void initState() {
    // execute this function when the page is loaded
    super.initState();
    pageNavigatorController = PageNavigatorController(
        canProceed: canProceed,
        currentPage: currentPage,
        pageController: _pageController,
        numPages: 1,
        nextPage: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        },
        previousPage: () {
          _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        });
  }

  @override
  void dispose() {
    // free up memory when we leave this page
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildAudioDescription() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
  
      children: [
        Text("You can do this.",
        style:TextStyle(fontSize: 50)),
        const Text("What negative thoughts are you having?",
            style: TextStyle(fontSize: 26)),
        const SizedBox(height: 20),
        TextField(
          maxLines: 5,
          onChanged: (value) {
            if (value.split(' ').length >= 10) {
              setState(() {
                pageNavigatorController.toggleCanProceed(true);
              });
            } else {
              setState(() {
                pageNavigatorController.toggleCanProceed(false);
              });
            }
          },
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  
  
}

int clamp(int value, int min, int max) {
  return value < min
      ? min
      : value > max
          ? max
          : value;
}
