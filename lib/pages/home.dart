import 'package:flutter/material.dart';
import 'package:truesight/pages/data_collection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('Audio Logs'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 139, 194, 238)),
                    ),
                    onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DataCollection(),
                      ),
                    );
                  },
                    child: Text(
                      "Hallucination Detection",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 203, 177, 247)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Positive Affirmations",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 203, 177, 247)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Schizoprenia Diagnostics",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                )
              ],
            ),
          ),

          // bottomNavigationBar: BottomNavigationBar(items: [
          //   BottomNavigationBarItem(
          //     icon: Icon(Icons.home),
          //     label: 'Home',
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(Icons.home),
          //     label: 'Bookmarks',
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(Icons.check),
          //     label: 'Home',
          //   )
          // ]),
        ),
      );
  }
}