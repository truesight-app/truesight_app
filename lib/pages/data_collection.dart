import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truesight/pages/components/processing_page.dart';
import 'package:truesight/pages/components/recording_page.dart';
import 'package:truesight/providers/formStateProvider.dart';
import 'package:truesight/widgets/page_navigator.dart';

class DataCollection extends ConsumerStatefulWidget {
  const DataCollection({super.key});
  @override
  ConsumerState<DataCollection> createState() => _DataCollectionState();
}

class _DataCollectionState extends ConsumerState<DataCollection> {
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
      numPages: 2,
      nextPage: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentPage = 1;
        });
      },
      previousPage: () {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentPage = 0;
        });
      },
    );
    _descriptionController.addListener(_checkWordCount);
  }

  void _checkWordCount() {
    final text = _descriptionController.text;
    final wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    pageNavigatorController.toggleCanProceed(wordCount >= 5);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildAudioDescription() {
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
                final wordCount = value
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((word) => word.isNotEmpty)
                    .length;
                setState(() {
                  pageNavigatorController.toggleCanProceed(wordCount >= 5);
                });
                // set value in provider for use in the next pages
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
          Builder(
            builder: (context) {
              final wordCount = _descriptionController.text
                  .trim()
                  .split(RegExp(r'\s+'))
                  .where((word) => word.isNotEmpty)
                  .length;
              return Text(
                '$wordCount/5 words',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: wordCount >= 5 ? Colors.green : Colors.grey[600],
                ),
              );
            },
          ),
        ],
      ),
    );
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                  pageNavigatorController.toggleCanProceed(false);
                });
              },
              children: [
                buildAudioDescription(),
                RecordingPage(navigatorController: pageNavigatorController),
                const ProcessingPage(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: PageNavigator(
                pageNavigatorController: pageNavigatorController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
