import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TrueSight",
      theme: ThemeData(),
      home: Scaffold(

        appBar: AppBar(
          title: const Text('Audio Logs'),
        ),

        body: Padding(padding: const EdgeInsets.all(16.0),child: 
        
        Container(
          
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              SizedBox(
                height: 100,
          
                child: TextButton(
                  
              style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 139, 194, 238)),
            ),
            onPressed:(){},
                  
              child: const Text(
                "Hallucination Detection",
                style: TextStyle(fontSize: 30),
              ),
                ),
              ),
          SizedBox(
            height: 100,
            child: TextButton(
               style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 203, 177, 247)),
              ),
              onPressed:(){},
               child: const Text(
                "Positive Affirmations",
                style:TextStyle(fontSize: 30),
              ),
            ),
          ),

            SizedBox(
            height: 100,
            child: TextButton(
               style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 203, 177, 247)),
              ),
              onPressed:(){},
               child: const Text(
                "Positive Affirmations",
                style:TextStyle(fontSize: 30),
              ),
            ),
          )],
          
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
      
    ),
    );
  }
}
