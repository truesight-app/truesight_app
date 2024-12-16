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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildTop() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's on your mind?",
            style: GoogleFonts.lexend(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Share your thoughts, and let's transform them together.",
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              maxLines: 5,
              onChanged: (value) {
                setState(() {});
              },
              controller: _descriptionController,
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: const Color(0xFF2D3142),
              ),
              decoration: InputDecoration(
                hintText: 'Write down your thoughts here...',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3142)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Positive Affirmations',
            style: GoogleFonts.lexend(
              color: const Color(0xFF2D3142),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF6246EA),
          onPressed: () {
            setState(() {});
          },
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: Text(
            'Transform',
            style: GoogleFonts.lexend(color: Colors.white),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              buildTop(),
              const SizedBox(height: 24),
              if (_descriptionController.text.isNotEmpty)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: FutureBuilder(
                      future: getPositiveAffirms(_descriptionController.text),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Markdown(
                            data: snapshot.data ?? '',
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.lexend(
                                fontSize: 18,
                                color: const Color(0xFF2D3142),
                                height: 1.6,
                              ),
                              h1: GoogleFonts.lexend(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                              h2: GoogleFonts.lexend(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6246EA),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Transforming your thoughts...',
                                style: GoogleFonts.lexend(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
