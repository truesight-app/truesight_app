import 'package:flutter/material.dart';

class DataCollection extends StatefulWidget {
  const DataCollection({super.key});

  @override
  State<DataCollection> createState() => _DataCollectionState();
}

class _DataCollectionState extends State<DataCollection> {
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: [
                Container(
                  color: Colors.red,
                  child: Center(child: Text('Page 1')),
                ),
                 Container(
                  color: Colors.red,
                  child: Center(child: Text('Page 1')),
                ),
                 Container(
                  color: Colors.red,
                  child: Center(child: Text('Page 1')),
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}