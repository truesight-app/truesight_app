import 'package:flutter/material.dart';
import 'package:truesight/functions/gemini.dart';
import 'package:truesight/pages/components/recording_page.dart';
import 'package:truesight/widgets/page_navigator.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class PositiveAffs extends StatefulWidget {
  const PositiveAffs({super.key});

  @override
  State<PositiveAffs> createState() => _PositiveAffsState();
}

class _PositiveAffsState extends State<PositiveAffs> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    // execute this function when the page is loaded
    super.initState();
  }

  @override
  void dispose() {
    // free up memory when we leave this page

    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildTop() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("What negative thoughts are you having?",
            style:GoogleFonts.lexend(fontSize: 20)),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            maxLines: 5,
            onChanged: (value) {},
            controller: _descriptionController,
            decoration:  InputDecoration(
              hintText: 'Write down your thoughts here',
              hintStyle: GoogleFonts.lexend(fontSize: 18), 
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.generating_tokens),
          onPressed: () {
            // generate new response
            setState(() {});
          },
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              buildTop(),
              if (_descriptionController.text.isNotEmpty)
                FutureBuilder(
                  future: getPositiveAffirms(_descriptionController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(child: Markdown(
                        data: snapshot.data ?? '',
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lexend(fontSize: 18),
                        ),
                      ),);
                    }
                    return const CircularProgressIndicator();
                  },
                ),
            ],
          ),
        ),
      ),
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
