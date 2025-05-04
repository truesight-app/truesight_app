import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindbalance/providers/formStateProvider.dart';

class DataCollection extends ConsumerStatefulWidget {
  const DataCollection({super.key});
  @override
  ConsumerState<DataCollection> createState() => _DataCollectionState();
}

class _DataCollectionState extends ConsumerState<DataCollection> {
  final TextEditingController _descriptionController = TextEditingController();
  bool canProceed = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_checkWordCount);
  }

  void _checkWordCount() {
    final text = _descriptionController.text;
    final wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    setState(() {
      canProceed = wordCount >= 5;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sound Analysis',
          style: GoogleFonts.lexend(
            color: const Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What do you hear?",
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Describe the sounds around you in detail (minimum 5 words)",
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
                  controller: _descriptionController,
                  onChanged: (value) {
                    _checkWordCount();
                    ref
                        .read(formStateProvider.notifier)
                        .setAudioDescription(_descriptionController.text);
                  },
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: const Color(0xFF2D3142),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share what you\'re hearing...',
                    hintStyle: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_descriptionController.text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length}/5 words',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: canProceed ? Colors.green : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canProceed
                      ? () {
                          Navigator.pushNamed(context, '/record');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6246EA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    'Continue to Recording',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
