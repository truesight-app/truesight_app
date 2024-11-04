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
  bool canProceed = false;

  @override
  void initState() {
    // execute this function when the page is loaded
    super.initState();
    pageNavigatorController =  PageNavigatorController(
                nextPage: () {
                 _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,                 );
                },
                previousPage: ()  {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
                    
                }
                
              );
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
      children: [
        const Text("Give a brief description on what you are hearing.",
            style: TextStyle(fontSize: 26)),
        const SizedBox(height: 20),
        TextField(
          maxLines: 5,
          onChanged: (value) {
            if (value.split(' ').length >= 10) {
              setState(() {
                canProceed = true;
              });
            } else {
              setState(() {
                canProceed = false;
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
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: PageView(
              controller: _pageController,
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
              pageController: _pageController,
              currentPage: _pageController.hasClients
                  ? _pageController.page!.toInt()
                  : 0,
              canProceed: canProceed,
            ),
          ),
        ],
      )),
    );
  }
}

int clamp(int value, int min, int max) {
  return value < min
      ? min
      : value > max
          ? max
          : value;
}
