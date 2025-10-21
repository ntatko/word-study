import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/hive_word_study_provider.dart';
import '../utils/constants.dart';
import '../widgets/flexible_step_progress_indicator.dart';
import '../services/navigation_service.dart';
import 'final_notes_screen.dart';

class CrossReferencesScreen extends StatefulWidget {
  const CrossReferencesScreen({super.key});

  @override
  State<CrossReferencesScreen> createState() => _CrossReferencesScreenState();
}

class _CrossReferencesScreenState extends State<CrossReferencesScreen> {
  final TextEditingController _manualVerseController = TextEditingController();
  final Set<String> _selectedReferences = {};
  final List<String> _manualReferences = [];

  late WebViewController _webViewController;
  String _selectedVersion = AppConstants.bibleVersions.first;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final wordStudy = context.read<HiveWordStudyProvider>().currentStudy;
    if (wordStudy == null) {
      Navigator.of(context).pop();
      return;
    }

    final url =
        'https://www.blueletterbible.org/search/search.cfm?Criteria=${Uri.encodeComponent(wordStudy.selectedWord)}&t=$_selectedVersion#s=s_primary_0_1';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _injectCSS();
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _injectCSS() {
    _webViewController.runJavaScript('''
      // Hide navigation elements to save space
      var responsiveNav = document.getElementById('responsiveNav');
      if (responsiveNav) responsiveNav.style.display = 'none';
      
      var mobAppSoc = document.getElementById('mobAppSoc');
      if (mobAppSoc) mobAppSoc.style.display = 'none';
      
      // Hide other navigation elements
      var header = document.querySelector('header');
      if (header) header.style.display = 'none';
      
      var footer = document.querySelector('footer');
      if (footer) footer.style.display = 'none';
      
      // Hide sidebar elements
      var sidebar = document.querySelector('.sidebar');
      if (sidebar) sidebar.style.display = 'none';
      
      // Make main content take full width
      var mainContent = document.querySelector('main') || document.querySelector('.main-content');
      if (mainContent) {
        mainContent.style.width = '100%';
        mainContent.style.margin = '0';
        mainContent.style.padding = '10px';
      }
      
      // Hide donation banners and promotional content
      var donationBanners = document.querySelectorAll('[class*="donation"], [class*="banner"], [class*="promo"]');
      donationBanners.forEach(function(element) {
        element.style.display = 'none';
      });
      
      // Remove top padding from main content area
      var wholeDiv = document.getElementById('whole');
      if (wholeDiv) {
        wholeDiv.style.paddingTop = '0';
        wholeDiv.style.marginTop = '0';
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final wordStudy = context.watch<HiveWordStudyProvider>().currentStudy;

    if (wordStudy == null) {
      return const Scaffold(body: Center(child: Text('No study in progress')));
    }

    final provider = context.read<HiveWordStudyProvider>();
    final isCompleted = provider.isStudyCompleted(wordStudy);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cross References: ${wordStudy.selectedWord}'),
        actions: [
          DropdownButton<String>(
            value: _selectedVersion,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedVersion = newValue;
                  _isLoading = true;
                });
                _initializeWebView();
              }
            },
            items: AppConstants.bibleVersions.map((String version) {
              return DropdownMenuItem<String>(
                value: version,
                child: Text(version),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: FlexibleStepProgressIndicator(
              currentStep: 3,
              totalSteps: 4,
              isEditingCompleted: isCompleted,
              onStepTap: (step) =>
                  NavigationService.navigateToStep(context, step),
            ),
          ),
          // WebView for Blue Letter Bible search
          Expanded(
            flex: 3,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: _webViewController),
          ),
          // Manual verse input section
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips display (including current passage)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          _manualReferences.length +
                          1, // +1 for current passage
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Current passage chip (non-removable)
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppConstants.spacing,
                            ),
                            child: Chip(
                              label: Text(wordStudy.passageReference),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          );
                        } else {
                          // Manual verse chips (removable)
                          final verse = _manualReferences[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppConstants.spacing,
                            ),
                            child: Chip(
                              label: Text(verse),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeManualVerse(verse),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing),
                  // Input field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualVerseController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., John 3:16',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing),
                      IconButton(
                        onPressed: _addManualVerse,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.padding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _proceedToNextStep,
                    child: const Text('Next: Final Notes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addManualVerse() {
    final verse = _manualVerseController.text.trim();
    if (verse.isNotEmpty && !_manualReferences.contains(verse)) {
      setState(() {
        _manualReferences.add(verse);
        _selectedReferences.add(verse);
      });
      _manualVerseController.clear();
    }
  }

  void _removeManualVerse(String verse) {
    setState(() {
      _manualReferences.remove(verse);
      _selectedReferences.remove(verse);
    });
  }

  void _proceedToNextStep() {
    // Update the current study with cross-references
    context.read<HiveWordStudyProvider>().updateCrossReferences(
      _selectedReferences.toList(),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FinalNotesScreen()));
  }

  @override
  void dispose() {
    _manualVerseController.dispose();
    super.dispose();
  }
}
